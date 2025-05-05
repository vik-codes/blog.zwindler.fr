---
title: 'Echec déploiement package OVF: Cette tâche a été annulée par un utilisateur'
authors:
  - zwindler
type: post
date: 2015-03-30T21:18:12+00:00
url: /2015/03/30/echec-deploiement-package-ovf-cette-tache-a-ete-annulee-par-un-utilisateur/
image: /2015/03/Failed-to-deploy-OVF-Package1.png
categories:
  - systeme
  - Virtualisation
tags:
  - annulée
  - cdrom
  - Déploiement
  - échec
  - ESX(i)
  - OVA
  - OVF
  - sha1sum
  - tâche
  - tar
  - VMDK
  - VMware
  - VMware tools
  - vSphere 5.0
  - vSphere 5.1
  - vSphere 5.5

---
[Edit]MAJ le 19/10 avec quelques captures d’écran[/Edit]

Une manière simple de créer et de déployer des templates sous ESXi lorsqu’on ne dispose pas du vCenter et de la licence qui va bien est d’utiliser les templates OVF/OVA ([cf un de mes tous premiers articles](/2011/03/20/copier-une-vm-windows-xp-sous-esxi-sans-vcenter/)). Je l’utilise d’ailleurs toujours aujourd’hui pour pallier le manque de licences sur certains sites distants/secondaires.

Cependant, depuis la version 5 (ou peut être 5.1), j’ai été confronté à plusieurs reprises à l’erreur suivante lors du déploiement de l’OVA :

> Echec déploiement package OVF: Cette tâche a été annulée par un utilisateur

WTF ? Pas de code d’erreur, et un message pas vraiment loquasse...

J’ai eu beaucoup de mal à trouver la réponse à cette erreur en Français et il a d’ailleurs fallu que je le traduise mot pour mot en anglais pour trouver des ressources pour m’aider :

> Failed to deploy OVF package: The task was canceled by a user.

[Edit] En 5.5, j’ai également rencontré le message suivant qui donne un peu plus d’informations sur le problème réel :

> OVF Deployment Failed: File ds:///vmfs/volumes/uuid/_deviceImage-0.iso was not found

![](/2015/03/01_ovf_device.png)

[/Edit]

Et là on commence à trouver un peu d’aide sur le web. Parmi les liens intéressants sur le sujet, on peut citer le KB de VMware et lukebarklimore qui rentre un peu dans le détail de l’anatomie d’un OVF/OVA de chez VMware :

  * KB VMware (lien mort, comme d'habitude)
  * [lukebarklimore.wordpress.com/2012/10/25/esxi-5-1-fixing-failed-to-deploy-ovf-package-the-task-was-canceled-by-a-user/](https://lukebarklimore.wordpress.com/2012/10/25/esxi-5-1-fixing-failed-to-deploy-ovf-package-the-task-was-canceled-by-a-user/)

Ce qu’il faut en retenir, c’est :

* un OVA n’est en fait qu’une simple archive **tar** (qu’on peut donc ouvrir avec un « _tar xf_ » ou un 7zip pour les Windowsiens
* Il contient un fichier **.ovf** au format XML qui respecte la norme des OVF (enfin, si on peut appeler ça une norme ! _troll_) et qui est en fait un descripteur du matériel virtuel de votre VM
* un ou plusieurs fichiers **.vmdk**, vos disques durs virtuels
* un fichier **.mf** qui ne contient en fait que le hash **sha1** du fichier, pour le contrôle de la cohérence

![](/2015/03/03_ovf_device.png)


Pour en venir au problème en lui même : il se produit lorsque les VMware Tools sont mal démontés ou se sont mal installés (ou mal terminé d’installer). La machine virtuelle garde en mémoire la présence de l’ISO et celui ci reste inscrit dans le descripteur OVF. Lorsqu’on déploie la VM, l’ISO n’est plus présent sur le serveur de destination et on obtient l’erreur susnommée.

Pour résoudre le problème, il faut donc :

  * Extraire le fichier OVF de l’archive OVA
  * Editer le fichier OVF, et remplacer la mention **_vmware.cdrom.iso_** par la valeur **_vmware.cdrom.atapi_** ou **_vmware.cdrom.remotepassthrough_**
  * Recalculer le nouveau hash SHA1 du fichier OVF édité
  * Recréer une archive et y ajouter DANS CET ORDRE les fichiers .ovf PUIS .mf et .vmdk.

![](/2015/03/04_ovf_device.png)


```
tar xf maVM.ova #extraction des fichiers de l'archive
rm maVM.ova
vi maVM.ovf #si vous êtes sages je vous donnerai un "sed" pour éviter d'avoir à éditer le fichier

sha1sum maVM.ovf #récupérer le retour et remplacer le hash de l'OVF par la nouvelle valeur dans le fichier maVM.mf

tar cf maVM.ova maVM.ovf #recréation de l'archive
tar uf maVM.ova *.mf *.vmdk
```


Si vous omettez de recalculer le checksum, VMware vous expliquera bien gentiment que le checksum n’est pas bon, et donc l’archive toute entière, donc pas de flemme !

Et si vous ne les mettez pas dans cet ordre, vous aurez une autre erreur, très explicite cette fois ci qui vous expliquera que votre OVA est invalide car les fichiers ne sont pas dans le bon ordre... Oui... Vraiment.
