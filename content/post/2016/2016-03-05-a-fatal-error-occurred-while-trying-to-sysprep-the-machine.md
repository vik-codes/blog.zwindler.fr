---
title: 'Une erreur grave s’est produite lors de l’exécution de sysprep sur l’ordinateur'
authors:
  - zwindler
type: post
date: 2016-03-05T13:00:52+00:00
url: /2016/03/05/a-fatal-error-occurred-while-trying-to-sysprep-the-machine/
image: /2016/01/sysprep_error-1.png
categories:
  - systeme
  - Virtualisation
tags:
  - A fatal error occurred while trying to sysprep the machine
  - modèle
  - NewSID
  - regedit
  - RHEL
  - SID
  - sysprep
  - template
  - virtualisation
  - VMware
  - Windows

---
## Dépassement du nombre de sysprep autorisé

A force d'(ab)user de virtualisation de serveurs, on prend forcément gout aux fonctionnalités offertes par l’infrastructure. Hormis VMware qui fait encore payer les templates (tacle gratuit, même si on peut [s’en sortir comme ceci](/2011/03/20/copier-une-vm-windows-xp-sous-esxi-sans-vcenter/)), la plupart des éditeurs d’hyperviseurs proposent _**gratuitement**_ la fonctionnalité qui permet, à partir d’une machine virtuelle existante, de créer un modèle qui servira de socle pour les déploiement futurs.

On gagnera un temps fou en s’évitant l’installation de l’OS à chaque fois (même si ça s’automatise d’autres façons je l’accorde) et surtout à toujours reparametrer les mêmes choses comme les DNS, le NTP, le client de supervision, ...

Ça marchera plutôt bien sur vos bons vieux Linux (sauf dans pour [la gestion du réseau CentOS/RHEL6](/2016/02/20/nettoyage-carte-ethernet-apres-deploiement-dun-template-centos-rhel-6/), corrigé en 7), mais Microsoft, lui, ne l’entendra pas de cette oreille !

Lorsque vous déployez un serveur ou un poste de travail sous Windows, vous êtes limités dans le nombre de **sysprep** consécutifs que vous pouvez exécuter pour réinitialiser les variables de types SID dans le registre de la machine.

Or, pour des raisons de stabilité et de sécurité, de nombreux administrateurs réalisent un **sysprep** une fois que leur template est terminé, ce qui permet de réinitialiser le SID du modèle, ce qui rendra par la suite la future VM unique au moment de son déploiement. Et si vous modifiez régulièrement vos templates, la limite peut arriver vite.

## L’erreur et sa solution

Lorsque l’on déploie une image sur un poste ou un serveur et qu’on reçoit le message d’erreur suivant :

> Une erreur grave s’est produite lors de l’exécution de sysprep sur l’ordinateur
> 
> A fatal error occurred while trying to sysprep the machine

La procédure pour contourner le compteur de Microsoft se passe en plusieurs étapes.

### Regedit

Premièrement, il faut commencer par modifier les trois chaînes regedit suivantes :

  * HKEY\_LOCAL\_MACHINE\SYSTEM\Setup\Status\SysprepStatus\CleanupState:2
  * HKEY\_LOCAL\_MACHINE\SYSTEM\Setup\Status\SysprepStatus\GeneralizationState:7
  * HKEY\_LOCAL\_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\SkipRearm:1

Éventuellement, on peut préférer exécuter un fichier **.reg** contenant les lignes suivantes :

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\Setup\Status\SysprepStatus]
"GeneralizationState"=dword:00000007
"CleanupState"=dword:00000002

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform]
"SkipRearm"=dword:00000001
```


Deuxièmement, effectuer deux commandes (dans l’invité de commandes ou exécuter Powershell en tant qu’administrateur), en attendant 5 à 10 secondes entre chaque commandes. Cette opération est réellement nécessaire car j’ai eu des échecs en essayant de ne pas le faire, pour voir.

```
msdtc -uninstall
msdtc -install
```


### Dernière étape avant le sysprep : le skiprearm.xml

**Attention, ce fichier dépend de votre version.** Suite à un commentaire je me suis rendu compte que le fichier que je fournissais ne fonctionne plus sur les versions « récentes » de Windows.

Pour les vielles versions (2003 jusqu’à 2008 mais pas trop à jour?)

Troisièmement, créer un fichier nommé **c:\Windows\system32\sysprep\skiprearm.xml** contenant le texte suivant :

```
<?xml version="1.0" encoding="utf-8"?>
 <unattend xmlns="urn:schemas-microsoft-com:unattend">
   <settings pass="generalize">
     <component name="Microsoft-Windows-Security-Licensing-SLC" processorArchitecture="x86" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
       <SkipRearm>1</SkipRearm>
     </component>
   </settings>
 </unattend>
```


Pour les versions plus récentes et à jour

```
<?xml version="1.0" encoding="utf-8"?>
 <unattend xmlns="urn:schemas-microsoft-com:unattend">
  <settings pass="generalize">
    <component name="Microsoft-Windows-Security-SPP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        <SkipRearm>1</SkipRearm>
    </component>
  </settings>
 </unattend>
```


### Le sysprep

Une fois que ces trois étapes ont été réalisées, on reboot le serveur et on peut exécuter le sysprep en ligne de commande à la suite.

```
cd c:\windows\system32\sysprep
sysprep /generalize /oobe /shutdown /unattend:c:\Windows\system32\sysprep\skiprearm.xml
```


Dans mon exemple, je ne fais que couper la machine en fin de processus, il n’y a pas de reboot. Ceci me permet de transformer ma machine virtuelle en modèle à la suite. Ainsi, les VMs qui seront déployées avec ce modèle auront déjà eu leur sysprep au moment du premier boot, ce qui me gagne du temps.

## Note complémentaire

Il y a débat sur le fait que le **sysprep** soit toujours nécessaire aujourd’hui, surtout depuis l’article du TechNet « _The Machine SID Duplication Myth (and Why Sysprep Matters)_ » de Mark Russinovich, auteur de NewSID.exe, **l’Utilitaire**  (avec un grand U) utilisé pour réinitialiser les SID sous XP/2003.

On y apprend en gros qu’il n’y a aucun risques à cloner des machines Windows sans réinitialiser les SID et que dans la grande majorité des cas, le sysprep n’est donc pas nécessaire depuis 2008. C’est d’ailleurs pour cela que l’auteur indique ne plus maintenir son NewSID.exe.

Pour autant, je peux attester personnellement de deux contextes en Windows 2008 et pour lesquels la duplication du SID a provoqué un dysfonctionnement majeur du fonctionnement des applications Microsoft (notamment l’installation d’un domaine Active Directory). Donc jusqu’à preuve du contraire, je continuerai à faire des sysprep sur mes clones/templates Windows Server.

## Nombre de sysprep restants

Il existe une commande pour vérifier le nombre de sysprep qu’on peut encore refaire (trouvé sur [Power Shell](http://power-shell.blogspot.fr/2011/11/comment-eviter-que-la-commande-sysprep.html)) :

```
slmgr.vbs /dlv
```


![](/2016/03/sysprep_1.png)

## Sources additionnelles

  * [Le KB Microsoft qui explique le problème et donne quelques pistes pour le contourner](https://support.microsoft.com/en-us/kb/929828)
  * [L’article TechNet censé nous expliquer que les duplications de SID ne pose aucun problèmes réels](https://blogs.technet.microsoft.com/markrussinovich/2009/11/03/the-machine-sid-duplication-myth-and-why-sysprep-matters/)
  * [Une autre analyse sur le sujet de chez InfoWorld](http://www.infoworld.com/article/2628004/microsoft-windows/the-sid-debate--to-sysprep-or-not-to-sysprep.html)
