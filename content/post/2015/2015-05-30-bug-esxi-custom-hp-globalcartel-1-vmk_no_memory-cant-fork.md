---
title: 'Bug ESXi custom HP : globalCartel-1, VMK_NO_MEMORY, can’t fork'
authors:
  - zwindler
type: post
date: 2015-05-30T10:00:04+00:00
url: /2015/05/30/bug-esxi-custom-hp-globalcartel-1-vmk_no_memory-cant-fork/
image: /2015/05/01_vmk_no_memory1.png
categories:
  - systeme
  - Virtualisation
tags:
  - 5.0
  - 5.1
  - 5.5
  - AMS
  - "can't fork"
  - custom HP
  - ESX(i)
  - globalCartel-1
  - HP
  - VMK_NO_MEMORY
  - VMware

---
Deux de nos serveurs de productions ESXi 5.5 se sont récemment comportés de manière erratique. Pour une raison inconnue, les machines virtuelles se sont mises à ne plus répondre correctement, et l’import d’un nouveau OVA a planté en fin de processus. Voilà quelques erreurs que j’ai pu rencontrer dans le client ou via la console :

> Heap globalCartel-1 a déjà la taille maximale XXXXXXX. Impossible de l’augmenter.  
> Heap globalCartel-1 already at its maximum size. Cannot expand.  
> msg.vmk.status.VMK\_NO\_MEMORY  
> can’t fork

![](/2015/05/01_vmk_no_memory1.png)

Plus aucune action d’administration n’était possible sur le serveur (démarrage/extinction de VM, modification des paramètres du serveur, ...). En fait, à partir du moment où les messages d’erreur apparaissent il est déjà trop tard. La seule solution est de rebooter le serveur dans un premier temps.

Il s’agit d’un bug de la surcouche HP des images ESXi modifiées par HP, qui a une fuite de mémoire. Quand les messages d’erreurs apparaissent, c’est que la mémoire est pleine, et le serveur n’arrive plus à forker.

> This is a known issue affecting ESXi 5.x. To resolve this issue, upgrade to AMS version 10.0.1.

![](/2015/05/02_vmk_no_memory.png)


Ce qui est à peine croyable, c’est que ce bug touche les versions modifiées par HP d’ESXi 5.0, 5.1 et 5.5 ! Rien que ça ! Moi qui pensais bien faire en prenant la peine d’installer la version customisé HP sur les serveurs HP avec ESXi, me voilà guéri de cet effort...

Pour plus de détails, voici le KB de chez VMware, qui liste les versions concernées, les symptômes et la marche à suivre pour contourner ou résoudre le problème (lien mort, comme tous les KBs VMware)

La seule « solution » est de mettre à jour la fameuse surcouche, via un patch offline à passer sur tous les serveurs qui dispose du build custom d’HP. Le contournement consiste simplement à couper le service incriminer, et à empêcher qu’il ne redémarre en le désinstallant.

Pour vérifier quelle version du composant incriminé est sur votre serveur

```
~ # esxcli software vib list | grep ams
hp-ams    550.10.0.0-18.1198610    Hewlett-Packard  PartnerSupported  2014-08-05
```


Pour supprimer le package AMS si la mise à jour n’est pas envisageable, il faut se connecter en SSH, couper le service, puis supprimer le « package » (VIB) et rebooter le serveur.

```
/etc/init.d/hp-ams.sh stop
esxcli software vib remove -n hp-ams
```


Pour mettre à jour votre 5.5 custom HP, voici le lien pour télécharger le bundle [hp.com (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150508055222/http://h20564.www2.hp.com/hpsc/swd/public/detail?swItemId=MTX_b05d4c644fb742aa87cb5f5da1)

Quelques liens supplémentaires :

* communities.vmware.com/message/2436136 (lien mort, comme tout ce que fait VMware)
* [blog.vmpros.nl/2015/03/29/vmware-could-not-start-vmx-msg-vmk-status-vmk\_no\_memory/ (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20240304011427/https://blog.vmpros.nl/2015/03/29/vmware-could-not-start-vmx-msg-vmk-status-vmk_no_memory/)
* [www.educationalcentre.co.uk/posts/could-not-start-vmx-msg-vmk-status-vmk\_no\_memory/](http://www.educationalcentre.co.uk/posts/could-not-start-vmx-msg-vmk-status-vmk_no_memory/)
