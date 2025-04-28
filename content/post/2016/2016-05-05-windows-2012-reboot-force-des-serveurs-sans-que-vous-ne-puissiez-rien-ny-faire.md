---
title: 'Windows 2012 : reboot forcé des serveurs sans que vous ne puissiez rien n’y faire'
authors:
  - zwindler
type: post
date: 2016-05-05T11:30:06+00:00
url: /2016/05/05/windows-2012-reboot-force-des-serveurs-sans-que-vous-ne-puissiez-rien-ny-faire/
image: /2016/02/57UKydQS.png
categories:
  - Système
tags:
  - forcé
  - reboot
  - Windows 10
  - Windows 2012

---
Windows et les reboots, c’est un peu une histoire d’amour.

Hop hop hop : je vous entend déjà râler et dire

> Ah ça c’est bien une réflexion de gars qui n’y connait rien !

Vous aurez raison, je n’y connais rien. Pour autant, dans tous les contextes professionnels que j’ai pu voir jusqu’à présent, il doit y avoir un sacré paquet de gens qui n’y connaissent rien car on m’a souvent dit (je parle bien d’admins windows) « ah ouais ok mais bon un petit reboot ça fait jamais de mal » comme solution à tous les symptômes possibles et imaginables. Et le pire, c’est que ça marche !

## Culture du reboot

Là où je veux en venir c’est que la culture du reboot, _à tort ou à raison_, est quand même fortement ancrée dans la culture Windows, même dans l’environnement serveur.

> Dans le doute, reboot. Si ça rate, reformate. - Devise des admins Windows dans un open space d’une grande ESN Française

De quoi je parle :

  * Vous avez un bug? Vous rebootez.
  * Vous voulez installer un composant Windows supplémentaire ? Vous rebootez.
  * Vous installez un progiciel un peu costaud ? Vous rebootez.

Mettre à jour automatiquement les serveurs Windows, comme tous les OS est une bonne pratique. Et il n’est pas rare que l’application de cette mise à jour nécessite un reboot.

Jusque là (contrairement aux 3 précédents exemples), rien de choquant : sous Unix/Linux c’était le cas aussi (au moins jusqu’à ce que le Kernel Linux 4 ne permette les MAJ du Kernel à chaud).

Là où ça l’est moins, c’est quand, au bout d’un certain l’OS Windows vous incite fortement à faire le reboot avec de bonne grosse popup sur l’écran.

![](/2016/05/reboot.png)

Jusqu’aux dernières versions vous pouviez encore vous en sortir avec des bidouilles car dans certains cas il peut être intéressant de savoir bloquer ce comportement par défaut (temporairement par exemple).

## Toujours plus

Mais avec Windows 2012, Microsoft est allé un cran plus loin.

![](/2016/05/reboot2.png)

> What ? Wait ... Nooooooo !

Donc depuis Windows 8/2012, lorsque les mises à jours sont téléchargées, le système provoque parfois un reboot forcé du serveur avec un compte à rebours de 15 minutes si un administration ouvre une session.

Je sais pas vous, mais généralement lorsque j’ouvre une session sur un serveur, c’est parce que j’ai besoin de faire une opération sur le serveur en question... non ?

Dans les version précédentes, on pouvait encore annuler le redémarrage avec une commande

```
shutdown -a
```


Et bien maintenant, ça ne marche plus. Vous n’aurez pas de message d’erreur, la commande rendra bien la main. Vous penserez peut être que tout va bien.

Pourtant, 5 minutes plus tard, vous recevrez un message qui vous proposera deux choses : redémarrer tout de suite ou lorsque le compteur atteindra 0.

## Qu’est ce qui se passe vraiment ?

Certaines mises à jours critiques se téléchargent et s’installent par défaut (si vous avez des stratégies de groupes et/ou un serveur WSUS, les choses peuvent être un peu différentes bien entendu. Ici c’est le cas standard).

A partir de là, l’administrateur est « notifié » dans sa session qu’il va devoir penser à faire un reboot pour prise en compte. Bon, si comme moi il ne s’y connecte jamais, il ne sera pas plus au courant que cela, mais passons.

A bout de 3 jours, l’OS décidera alors de la planification d’un reboot lors de la prochaine plage de maintenance, qui sera fait s_&lsquo;il n’y a pas de risques de données_. En gros, si vous avez une session ouverte et/ou une application qui tourne.

On va faire confiance à Microsoft et dire que ça fonctionne bien. Parce que si ça ne fonctionne pas bien, votre serveur d’application ou votre base de données ... dommage ?

Admettons donc que l’OS estime que vous êtes en cours d’utilisation de votre serveur. Pour ne pas vous pénaliser et corrompre vos données, le reboot est reporté ... au prochain login d’un administrateur !

Dès que vous vous connecterez, vous avez 15 minutes pour couper proprement vos applications, sans possibilité de couper l’échéance fatidique.

![](/2016/05/jack.jpg)

Bon. Si vous en êtes là et que vous êtes désespérés parce que Windows est sur le point de se faire hara kiri, que ça couper votre production et que les utilisateurs vont vous attendre à la sortie avec des piques, a priori il n’y a plus d’espoir (sauf si une solution est sortie depuis la rédaction de cet article mais vous allez voir en fin d’article que c’est un choix assumé par Microsoft).

Pour la prochaine fois donc, voilà deux astuces pour éviter ces comportements via des modifications de clés dans le registre.

## Les mises à jours critiques qui s’installent provoquent la planification automatique d’un reboot

Ouvrir regedit en mode administrateur, puis naviguer jusqu’à **HKEY\_LOCAL\_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\**.

Créer la clé (dossier) avec pour nom **AU** si nécessaire, puis une clé de type **DWORD** à l’intérieur de cette clé avec comme nom **AlwaysAutoRebootAtScheduledTime** et comme valeur **** (ou **1** pour forcer le redémarrage).

## Lorsqu’un administrateur se connecte, le compte à rebours se déclenche

Ouvrez regedit en mode administrateur, puis naviguer jusqu’à là clé suivante :

> HKEY\_LOCAL\_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\

Créer la clé (dossier) avec pour nom **AU** (si nécessaire, i.e. si elle n’existe pas), puis une clé de type DWORD à l’intérieur de cette clé avec comme nom **NoAutoRebootWithLoggedOnUsers** avec pour valeur **1** (ou 0 si vous voulez au contraire ce comportement).

## Les mots de la fin

Petite note complémentaire, il faut avoir installé le **KB 2822241** pour que cela fonctionne.

Pour plus d’information, le [KB de Microsoft sur le sujet](https://support.microsoft.com/fr-fr/kb/2835627)

Et aussi un [article sur le blog MSDN](https://blogs.msdn.microsoft.com/b8/2011/11/14/minimizing-restarts-after-automatic-updating-in-windows-update/)



J’ai beaucoup ri en lisant cette phrase, censé aider à faire passer la pilule des reboots automatiques forcés (pour mettre à jour le code vulnérable en mémoire et corriger les failles le plus vite possible) :

> We know this architectural challenge is one that frustrates administrators and end-users alike, but it does represent the state of the art for Windows.

Et ça aussi, a propos du fait que WU ne gère que les mises à jours relatives à Windows et aux pilotes (contrairement à un gestionnaire de paquets sous Unix) :

> Lastly but not the least, I want to address the feedback from users who would like WU to update their 3rd-party applications. [...] People would like one updater for the entire system.  
> On the other hand, users have also told us that they trust the quality of updates distributed by WU [...]  
> We would not want to do anything that might reduce trust in the system by encouraging people to take on this management task manually and exposing their PCs to potential vulnerabilities for even short times.

Sur ce, have fun ;-)
