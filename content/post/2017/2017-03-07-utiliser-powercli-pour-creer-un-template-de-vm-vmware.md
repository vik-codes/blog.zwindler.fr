---
title: Utiliser PowerCLI pour créer un template de VM VMware
authors:
  - zwindler
type: post
date: 2017-03-07T13:00:52+00:00
url: /2017/03/07/utiliser-powercli-pour-creer-un-template-de-vm-vmware/
image: /2017/03/PowerCLI.png
categories:
  - Script
  - Virtualisation
tags:
  - PowerCLI
  - PowerShell
  - sauvegarde
  - Snapshot
  - VIPerl
  - VMware
  - Windows 2008
  - Windows 2012

---
## VMware et PowerCLI

Ça fait un long moment que j’ai cet article dans les tiroirs et aujourd’hui je n’ai plus vraiment l’intention d’utiliser PowerCLI pour automatiser ce genre de choses.

Pour autant, il y a quelques années, on m’a demandé de réaliser une copie complète quotidienne d’une machine virtuelle donnée. N’ayant à l’époque qu’une vieille version de DataProtector (youpi...) sur site, je n’avais pas d’outil pour sauvegarder simplement une machine complète, et encore moins donner les moyens de la restaurer rapidement en cas de crash.

Ayant [déjà bidouillé avec GhettoVCB](/2010/06/09/sauvegarder-automatiquement-et-proprement-ses-vms-sur-esxi/), qui permet notamment de sauvegarder à chaud des machines virtuelles VMware même quand on a pas de vCenter, je savais qu’il y avait des possibilités.

Dans mon cas précis, il y avait un cluster vSphere avec un vCenter installé sur un serveur Windows (à l’ancienne). Et comme je souhaitais automatiser cette tâche de copie depuis le vCenter, je ne voulais pas utiliser le VIPerl. A ce moment là, Microsoft mettait en avant Powershell, ce qui incitait les éditeurs à fournir leurs modules compatibles. C’est ainsi que naquit PowerCLI.

_A noter, dans le cas présent, il sera nécessaire d’avoir le vCenter car le module PowerShell PowerCLI se base sur la même API fournie par VMware que celle utilisée par VIPerl._

Quand on a un vCenter, on peut faire beaucoup de choses via l’API (et donc via PowerCLI). Le plus simple pour résoudre le problème posé était de déclencher chaque jour la création d’un clone ou d’un template. Et c’est donc ce que j’ai fais !

Bon... du coup, je n’ose pas vraiment parler de « sauvegarde » car il s’agit de tout sauf ça. Mais ça permettait aux administrateurs de disposer rapidement d’une machine à J-1 en cas de corruption, sans passer une sauvegarde réelle, ce qui était le besoin.

# Installation de PowerCLI

Oui parce que bon. Ce n’est pas si simple ! Le VIPerl était casse pied à installer avec toutes les dépendances Perl, il n’y avait pas de raisons que le PowerCLI le soit plus. Merci VMware... ou Microsoft je ne sais pas ;-). Voici la marche à suivre

  * Récupérez l’installer sur le site de VMware (ex VMware-PowerCLI-5.1.0-793510.exe)
  * Exécutez l’installation en tant qu’administrateur de la machine.

Une fois installé, ouvrez le panneau de configuration pour désactiver la révocation des certificats :

  * **Panneau de configuration**/**Options Internet**/Onglet **Avancé**/Section **Sécurité**/Décocher **Vérifier la révocation du certificat des éditeurs**

A partir de là PowerCLI est « utilisable ». Pour autant, à l’époque sur les serveurs 2008 R2 (ça date !) il y avait un gros soucis de performance sur PowerCLI (VMware ou Microsoft, je n’ai jamais su), qui mettait plusieurs secondes (voire dizaines) avant de s’exécuter. La seule méthode permettant de gagner du temps était de précompiler le module PowerCLI (...) :

```
C:\Windows\Microsoft.NET\Framework\v2.0.50727\ngen.exe install "VimService51.XmlSerializers, Version=5.1.0.0, Culture=neutral, PublicKeyToken=10980b081e887e9f"
C:\Windows\Microsoft.NET\Framework64\v2.0.50727\ngen.exe install "VimService51.XmlSerializers, Version=5.1.0.0, Culture=neutral, PublicKeyToken=10980b081e887e9f"
```


Et avant de pouvoir exécuter des scripts PowerShell personnels, il faut modifier la politique de sécurité bloquant l’exécution dédits scripts. Personnellement je vous conseille de laisser en **RemoteSigned** mais à vous de voir.

Attention, comme il y a une partie x86 et une partie x64, il faudra lancer un prompt **PowerShell en 32 bits et un en 64 bits** avec les droits Administrateur (clic droit, lancer en tant qu’administrateur), puis exécuter la commande suivante dans les 2 terminaux :

```
Set-ExecutionPolicy RemoteSigned
```


Enfin, pour contourner 2 problèmes rencontrés IRL, on doit également lancer un prompt **PowerCLI** **en 32 bits et un en 64 bits** avec les droits Administrateur, puis exécuter les commandes suivantes (méthodes de contournement respectivement pour des problèmes de connexions dans les scripts et les problèmes de certificats) :

```
Set-PowerCLIConfiguration -ProxyPolicy NoProxy -Confirm:$False
Set-PowerCLIConfiguration -InvalidCertificateAction ignore -Confirm:$False
```


## Commandes à exécuter manuellement, pour voir

Dans un premier temps (c’est à dire avant d’exécuter un script en priant pour que ça marche), le mieux est quand même de lancer les commandes à la main pour vérifier qu’on arrive à le faire au moins une fois manuellement.

Exemple de connexion au serveur vCenter (windows\_vcenter) avec le login compte\_privilegie présent dans le même domaine AD le vCenter.

```
Connect-VIServer -server windows_vcenter

Name Port User
---- ---- ----
windows_vcenter 443 DOMAINEAD\compte_privilegie
```


Normalement, après quelque s secondes la connexion devrait se faire. A partir de là, toutes les commandes suivantes seront authentifiées sur le vCenter.

Maintenant qu’on a réussi à se connecter, on démarrage d’une copie d’une VM vers un template. Ici je prends l’exemple du serveur vm\_a\_copier.

```
New-Template -Name vm_copie -VM vm_a_copier -Datastore DATASTORE_COPIE -Location VMWARE

Name
----
vm_copie
```


Dans la console, la copie devrait être en cours. Mission accomplie !

Je vous invite à aller sur le site de [documentation VMware pour plus d’informations sur cette commande (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20140125145011/https://www.vmware.com/support/developer/PowerCLI/PowerCLI50/html/New-Template.html).

## Mise en place de la copie de la VM à proprement parler

### Le script PowerShell

Ce sera donc un script PowerShell qui gèrera la copie de la VM (C:\scripts\vm_copie.ps1). Voici les étapes de ce script « exemple », à adapter à votre besoin.

  * Chargement du module PowerShell pour VMware

```
Add-PSSnapin -Name "VMware.VimAutomation.Core"
```


  * Connexion au vCenter en local (pas d’authentification nécessaire dans ce cas là)

```
$Server = Connect-VIServer -Server windows_vcenter -User vmwaresvc -Password mot_de_passe
```


  * Vérification préalable de l’existence ou non du template en question (on l’exécute tous les jours) et suppression le cas échant. Attention à ce que vous faites ici, en fonction de votre contexte !

```
$BackupTemplate = Get-Template -Name backup_srsmvm-supervision01 -Location VMWARE
If ($BackupTemplate){
  Remove-Template -Template vm_copie -DeletePermanently -Confirm:$false
}
  New-Template -Name vm_copie -VM vm_a_copier -Datastore DATASTORE_COPIE -Location VMWARE
  Start-Sleep -s 10
  Disconnect-VIServer -Server $Server -Confirm:$false
```


Et on se déconnecte proprement parce qu’on est sympa (et propres).

## Permettre l’exécution automatique

On est contents, on a notre script. Pour autant ce n’est pas encore totalement terminé... Si vous connaissez un peu PowerShell (à voir si c’est toujours vrai sur les Windows Server récent, j’ai un doute...), vous savez qu’il était nécessaire de passer par un .bat ou un .vbs pour l’exécuter, ce qui n’était pas très pratique.

Avant de pouvoir créer une tâche planifiée Windows pour pouvoir automatiser notre copie, il va donc falloir créer un fichier vbs C:\scripts\vm_copie.vbs qui ne fera que lancer le fichier .ps1.

```
'Script VBScript de lancement des backups de VM
Set objShell = CreateObject("Wscript.Shell")
objShell.Run("powershell.exe C:\scripts\vm_copie.ps1")
```


Ce script vbs sera lancé par un compte de service (vmwaresvc par exemple) dans une tâche planifiée. Ce compte de service devra donc préalablement être autorisé à se connecter au vCenter et à réaliser des créations de templates.

## Création d’un profil de sécurité et d’un compte pour la copie

Pour se faire, connectez vous au vCenter avec un compte administrateur VMware, puis créez un rôle disposant uniquement des autorisations nécessaires.

Menu **Administration/Rôle/Ajouter…**

![](/2017/03/powercli1.png)

Nom **« Compte de service copie_template »  
** 

Sélectionnez les privilèges suivants

  * **Banque de données/Allouer espace**
  * **Machine virtuelle/Provisionnement/Créer un modèle à partir d’une machine virtuelle**
  * **Machine virtuelle/Inventaire/Créer à partir d’un modèle/d’une machine virtuelle existante**
  * **Machine virtuelle/Inventaire/Supprimer** (attention danger !)

**[Clic droit]Ajouter une autorisation**

**Ajouter…**

![](/2017/03/powercli2.png)

Dans le menu déroulant **Domaine**, sélectionner **VMWARE**, puis ajouter l’utilisateur **vmwaresvc**. Dans **Rôle assigné**, sélectionner **« Compte de service copie_template »**, et valider.

Et si vous avez bien suivi la logique, vous irez de vous même vous connecter au vCenter avec le compte **vmwaresvc** pour vérifier par vous même que l’opération fonctionne manuellement (car vous ne croyez que ce que vous voyez, et vous avez bien raison).

## Restauration

Je ne pouvais pas terminer l’article sans au moins dire comment revenir en arrière une fois que vous avez besoin de repartir du template.

Comme il ne s’agit pas vraiment d’une VM mais d’un template, pour « restaurer » la machine virtuelle, il faut cliquer sur le template créé par le script et sélectionner **Convertir en machine virtuelle** ou **Déployer machine virtuelle à partir de ce modèle**.

![](/2017/03/powercli3.png)

Et voilà ! Je vous laisse le soin d’aller plus loin dans PowerShell / PowerCLI. Soyez créatifs ;-)
