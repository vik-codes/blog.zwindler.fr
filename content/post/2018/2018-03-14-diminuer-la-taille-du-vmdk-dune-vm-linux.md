---
title: 'Hack : diminuer la taille du VMDK d’une VM Linux LVM'
authors:
  - ventreachoux85
type: post
date: 2018-03-14T12:45:43+00:00
url: /2018/03/14/diminuer-la-taille-du-vmdk-dune-vm-linux/
image: /2015/07/vmware2.png
categories:
  - Stockage
  - Système
  - Virtualisation
tags:
  - CentOS
  - ESX(i)
  - fdisk
  - gparted
  - LVM
  - pvresize
  - VMDK
  - VMFS
  - vmkfstools
  - VMware
  - Windows

---
## Réduire un VMDK

> Note : cet article n’est pas écrit par moi mais par mon ami et ancien collègue Steve aka ventreachoux85 (ahahah faut assumer maintenant Steve), que j’héberge avec grand plaisir sur le blog :-)

> Note 2: **Comme toute opération sur des disques, des partitions, des filesystems, elles sont à faire avec des backups préalables. Cette opération est dangereuse et est à vos risques et périls => vous voilà prévenus.**

Sur un serveur Linux (CentOS 6.9 pour la petite histoire) hébergé sur un serveur VMware, je souhaite réduire la taille de mon disque virtuel de 75 Go car la volumétrie ne va pas bouger. S’il est simple d’agrandir un disque virtuel sous VMware, le réduire est une autre paire de manches !

Si la machine avait été un serveur Windows, voilà ce que j’aurai fais :

* Réduction du volume depuis l’utilitaire de gestion de disques
* Modification de l’_extent description_ directement sur le fichier .vmdk depuis l’ESXi (en SSH)
* Migration de la VM sur un autre datastore => elle aurait eu la taille voulue à l’issue de l’opération
  
Je ne détaille volontairement pas cette procédure car celle qui suit est similaire et nous allons prendre le temps de tout voir.
  
Et donc du coup, là c’était pas pour des windows, mais pour des machines sous Linux ! J’ai demandé son avis à zwindler, qui m’a demandé en échange de rédiger une petite procédure pour le blog ;-)

## Réduction du FS
  
Voilà donc à quoi ressemble les disques de mon serveur avant l’opération :

![](/2018/03/word-image.png)
  
Dans mon cas, je n’ai pas besoin de réduire les Filesystems, j’ai déjà beaucoup de PE de disponibles. S’il avait fallut le faire, on aurait été obligé de réduire les FS à froid (dans le cas ext*), voire même de passer par un liveCD si on avait du redimensionner « / » ou un autre FS vital pour l’OS.

## Réduire un VMDK partitionné pour du LVM
  
Le problème avec la commande **pvs** est que la taille utilisée et la taille disponible est arrondie pour être au format « human readable » d’Unix. Idéalement, il nous faut une mesure exacte pour redimensionner au plus juste.

Une des manières simples de le faire est d’utiliser l’unité « secteur » de la commande **pvs** (512 octets). Il faut faire la différence entre le PSize et le PFree pour avoir la taille définitive du disque :

![](/2018/03/word-image-1.png")

Après un rapide calcul, si je veux réduire le disque de tous les PE disponibles :

> 209453056 – 164757504 = 44695552

La nouvelle taille du PV sera de 44965552 secteurs

> Note de zwindler : Personnellement j’aurai laissé quelques PE, par habitude (limitations de LVM1 pénibles quand il n’y a plus de PE) et parce que je suis un froussard, mais a priori « ça marche ».

On redimensionne le disque

![](/2018/03/word-image-2.png")

~~A noter, malgré le fait qu’on ait spécifié qu’il ne devait pas rester de PE de libre, a priori il en reste quand même quelques uns. Je ne sais pas si c’est une sécurité du pvresize ou si c’est lié aux arrondis et à la taille d’un PE sur ce PV.~~ C’était une erreur de calcul (cf voir les commentaires).

![](/2018/03/word-image-3.png") 

Pour vérifier que tout va bien, un petit **pvscan/vgscan**.

![](/2018/03/word-image-5.png")

![](/2018/03/word-image-4.png")

## Réduire la partition

A partir de là, ça se corse. On a réduit sans trop de difficulté le PV qui héberge nos LV, mais il nous reste maintenant à réduire la partition qui héberge ce PV. Même si théoriquement on peut le faire à chaud, **zwindler** m’a conseillé de faire ça à froid. 

Pour autant, si vous vous sentez l’âme d’un aventurier et/ou avec un OS récent et/ou que vous n’avez pas le choix, vous pouvez toujours aller lire ce post sur [Ask Ubuntu][1].

Le plus safe est quand même d’arrêter la VM puis booter sur un liveCD avec GParted.

Clic droit sur la partition à modifier – désactiver (sinon impossible de la redimensionner)

![](/2018/03/word-image-6.png)

Sélectionner la partition puis Redimensionner / Déplacer

![](/2018/03/word-image-7.png)

Attention : lors du premier redimensionnement, GParted ne prend ne réduit pas au maximum la partition. **Il reste 2 Go qui sont inutilisés**.

![](/2018/03/word-image-8.png)

On lance un nouveau redimensionnement pour récupérer la place disponible !!

> Note de zwindler : moi j’aurai laissé comme ça ;-)

**ATTENTION**

On voit que **/dev/sda2** fait 21.44 Go après le **pvresize** (cf. screenshot précédent). En essayant de réduire au maximum la place utilisée, on peut tout casser (expérience vécue !!!). Pour plus de sécurité, je conseille de resizer à l’entier supérieur (donc dans notre exemple 22 Gio soit 22528 Mio)

![](/2018/03/word-image-9.png")

![](/2018/03/word-image-10.png)

![](/2018/03/word-image-11.png)

## Redimensionner le VMDK

Maintenant que le disque est modifié au niveau de l’OS, il faut le redimensionner au niveau de VMware.

Et là, rebelote : c’est pas « simple » à faire. En effet, [VMware ne supporte pas la réduction des VMDK (que ce soit à chaud ou à froid)][2].

> **Note**: You cannot shrink virtual disks using **vmkfstools** in ESXi as the hypervisor is not aware of the file system layout and cannot ensure a safe shrink operation.

Heureusement, des petits malins ont trouvés la technique depuis bien longtemps :

* Se connecter en SSH sur l’ESX qui héberge la VM, se rendre dans le dossier de la VM et faire un **vi** sur le fichier _NomVM.vmdk_, qui est un fichier texte (configuration), contrairement au fichier _NomVM-flat.vmdk_ qui contient les données réelles.

* Modifier la valeur suivante :

```
# Extent description
RW 209715200 VMFS "testsba-flat.vmdk"
```

* La nouvelle valeur du paramètre _extent description_ sera « 22 GB = 22 x 1024 x 1024 x 1024 / 512 (octets/secteur) = 46137344 secteurs »

```
# Extent description
RW 46137344 VMFS "testsba-flat.vmdk"
```

## Déplacer la VM vers un autre Datastore

A partir de là, vous vous dites : « cool ! j’ai récupéré l’espace disque ». Et vous êtes déçus car rien ne se passe.

En effet, ce paramètre n’est pris en compte que lors de la création du disque, lorsque le fichier contenant réellement les données (le fameux _NomVM-flat.vmdk_ dont je vous ai parlé plus tôt) est créé. Vous pouvez mettre n’importe quoi, ça ne changera rien du tout.

Cependant, si vous avez la licence qui va bien sur votre cluster, vous pouvez feinter le cluster pour lui faire recréer un disque à chaud de la bonne taille avec un simple **Storage vMotion**.

* Avant le Storage vMotion :

![](/2018/03/word-image-12.png) 

* Après le Storage vMotion :

![](/2018/03/word-image-13.png)

## Pourquoi ça marche ?

**Petit aparté de zwindler :** Pour bien comprendre ce qu’il se passe, il faut comprendre comment marche un Storage vMotion. Au moment où vous demandez à VMware de déplacer un disque d’un datastore à l’autre, voici l’enchaînement des opérations :

  * Prise d’un snapshot du disque initial
  * Création d’un disque sur le datastore cible. Ce disque est identique au disque initial au moment du snapshot via la commande **vmkfstools**. Cette commande relis la valeur contenu dans _extent description_ pour savoir quelle taille le fichier doit faire physiquement, ce qui nous permet de feinter VMware et d’avoir un disque à la bonne taille._  
_ 
* L’ensemble des IO depuis le snapshot sont écrites simultanément sur les deux datastores, ce qui permet d’avoir 2 copies identiques au moment de la fin de la copie du snapshot
* Migration de la VM  sur le nouveau disque
* Suppression de l’ancien disque hébergé par l’ancien datastore

**Note de zwindler :** j’étais persuadé d’avoir fais un article là dessus (et en fait pas du tout) mais _il est évidemment possible de faire la même chose à la main sans Storage vMotion_, simplement avec **vmkfstools** à la main.

## Boot de la machine

Pour finir, une fois la VM bootée, il reste encore une petite opération de maintenance à réaliser. Il y a une petite différence de nombre de secteurs suite au redimensionnement.

![](/2018/03/word-image-14.png)

Il suffit de faire un **pvresize** avec le nombre de secteurs indiqué par la commande **pvs** précédente :

![](/2018/03/word-image-15.png)

Tout est dorénavant OK :

![](/2018/03/word-image-16.png")

 [1]: https://askubuntu.com/questions/24027/how-can-i-resize-an-ext-root-partition-at-runtime
 [2]: https://kb.vmware.com/s/article/1002019
