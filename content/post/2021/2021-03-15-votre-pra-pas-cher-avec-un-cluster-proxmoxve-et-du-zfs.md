---
title: Votre PRA pas cher avec un cluster ProxmoxVE et ZFS
authors:
  - zwindler
type: post
date: 2021-03-15T07:30:34+00:00
excerpt: Installer ZFS sur Proxmox VE sur des machines chez OneProvider pour faire un PRA maison
url: /2021/03/15/votre-pra-pas-cher-avec-un-cluster-proxmoxve-et-du-zfs/
image: /2021/03/cover2.jpg
categories:
  - Autohébergement
  - Cluster
  - Stockage
  - Virtualisation
tags:
  - asynchrone
  - oneprovider
  - PRA
  - Proxmox
  - Proxmox VE
  - replication
  - RPO
  - rto

---
 

## OneProvider, le retour de la vengeance

Ça fait un moment que je monte régulièrement des cluster Proxmox VE avec du ZFS, de manière à avoir un PRA sur mes infras perso. 

Pour ne pas exploser les coûts, j’utilise depuis longtemps des machines dédiées (les moins chères possibles) et j’utilise la fonctionnalité réplication asynchrone des machines virtuelles via des pools ZFS dans Proxmox VE. **ZFS est donc le prérequis**.

Vous l’avez compris, je suis re-re-retourné chez OneProvider. Je ne suis pas plus satisfait de la relation client qu’avant, mais... ils sont vraiment imbattables, en prix sur du dédié et il va m’en falloir 3.

## Pourquoi un cluster, tu n’héberges rien de pro !

Ben d’abord parce que j’ai envie. 

Mais si vous voulez une explication plus rationnelle que ça : 

  * J’aime bien que mon blog (qui est ma vitrine) ne soit pas down quand je donne une conférence ou passe un entretien d'embauche (certes c’est pas souvent en ce moment)
  * Je n’ai pas envie de tout perdre à la mode SBG2

![](/2021/03/I7UHKZ4PTJFD7MK23SPVVVLSFE.jpg)

> Belotte

## Alors, pourquoi pas un PCA ? Pourquoi pas du synchrone ?

La réplication synchrone du stockage, c’est vraiment chouette. Avoir un cluster Ceph sur Proxmox VE ça permet d’avoir de la vraie haute disponibilité, avec 0 (quasiment) perte de données en cas de crash d’un nœud et des clusters capable de migrer les machines automatiquement en cas de souci. 

La première limitation c’est que Ceph, pour bien fonctionner demande d’avoir des disques de type SSD plutôt cher et plutôt véloces. Ça colle pas avec mon budget.

Mais le plus gros souci, c’est que le synchrone à un gros défaut, il faut une latence très faible entre toutes les machines. Beaucoup plus faible que ce que nécessite Corosync pour la mise en cluster de Proxmox lui même puisqu’on est sur des latences de l’ordre de la milliseconde. 

Corollaire de cette limitation, les machines doivent être sur des distances très courtes, notamment à cause de la vitesse de la lumière... Sauf à avoir la possibilité d’avoir des machines physiques dans des DCs proches (<100 km) chez votre provider, on se retrouve donc à monter un cluster qui va probablement se trouver dans le même DC (voire la même salle). 

![](/2021/03/I7UHKZ4PTJFD7MK23SPVVVLSFE.jpg)

> Rebelotte

## OK. Et c’est plus facile de faire un PRA / de l’asynchrone ?

Oui !

L’avantage de la réplication asynchrone par rapport à un cluster de stockage synchrone (comme Ceph) est qu’on peut le faire sur une distance beaucoup plus importante puisque ce n’est synchrone (thank you captain obvious). 

On a pas besoin d’avoir une latence <1-2 ms et ça nous autorise à faire des clusters Paris-Amsterdam-Bordeaux sans problème (exemple totalement au hasard).

Et comme cette réplication est totalement intégrée à Proxmox VE, on va pouvoir choisir simplement (dans la GUI) que des VMs sont à répliquer sur un serveur du cluster situé loin et Proxmox se chargera tout seul de synchroniser régulièrement les disques puis le delta des modifs (pour soulager le réseau).

Ça me permet d’avoir un « PRA du pauvre » avec des bascules manuelles de VMs :

  * RPO à 15 minutes (arbitraire, dépend totalement de la fréquence de la synchro delta, mais c’est la valeur par défaut)
  * RTO en quelques minutes dans le meilleur des cas (en gros, quand j’ai le temps de basculer les VMs et les records DNS)

Le plus important dans tout ça c’est que je peux le faire **sans me fatiguer** puisque c’est géré par Proxmox (et vous savez à quel point je déteste me fatiguer).

![](/2021/03/replication.png)

**Note : avoir toutes mes VMs en réplication asynchrone ne me dispense pas d’avoir des sauvegardes (offsite) de toutes les machines virtuelles. Ça me permet juste de remonter l’infra plus rapidement et de perdre moins de données. Mais n’oubliez pas que sans backup, vous ne le savez pas encore, mais vous êtes déjà morts.**

## Ok, comment on fait ?

Mais si c’était si facile que ça à faire (chez OneProvider), je n’en aurais pas fait un article. Comme vous allez le voir, on va en baver un peu pour y arriver ;-).

Le besoin est donc : 

  * Un cluster Proxmox VE 6 avec quorum (donc 3 machines minimum)
  * 2 DCs distinct minimum, avec des localisations relativement proches (pas trop de latence quand même, pas plus de 20 ms / 1000 km entre les serveurs)
  * **Avoir du ZFS pour pouvoir faire de la réplication asynchrone des machines**
  * Contrainte perso : du QEMU (donc VT-x) sur au moins un des nœuds
  * Contrainte perso : le moins cher possible

## SNCF, c’est possible

Pour 30 euros par mois (qu’on peut optimiser à ~25€ selon les promos et la durée d’engagement), chez OneProvider et avec quelques concessions, c’est possible.

J’ai sélectionné 2 types d’instances, disponibles sur Paris et Amsterdam :

  * un serveur principal avec 16 Go de RAM et un quadcore Xeon L3426 (une antiquité de 2009, mais à 18€ / mois voire 15€ en promo, c’est cadeau), avec 2 disques de 2 To
  * deux serveurs secondaires / de secours avec 4 Go de RAM et un Atom C2350 (pas de virtualisation, que des containers LXC)

Un poil plus cher (39€ / mois), vous pouvez aussi avoir une variante pour que vos 3 machines soient capables de faire de la virtualisation complète (VT-x) en prenant 3 Atom C2750, qui sont des octocores avec « seulement » 8 Go de RAM chacun.

## On installe Proxmox avec OneProvider

Oui, OneProvider propose (maintenant depuis quelques années) d’installer Proxmox directement sur les machines. 

![](/2021/03/oneprovider_reinstall.png)

En vrai, ça doit dater de Proxmox VE 5 puisque c’est la seule version qu’on a. On passera donc par la case upgrade, mais on y reviendra car il y a « plus grave ».

On ne peut pas partitionner et changer des options comme on veut (contrairement à ce tuto de [mon test de Proxmox chez Hetzner par exemple](/2019/11/19/changement-de-provider-mon-hyperviseur-sur-un-dedie-hetzner/)) et comme je dois avoir du ZFS, je suis **_couané_** (comme on dit chez moi). 

Et on ne peut pas utiliser la console IPMI (on peut la demander sur simple ticket au support) car dans le cas du L3426, le firmware est si vieux qu’aucun navigateur / version de java que j’ai testé ne supporte la console JNDI...

Ahhhh, ça me rappelle cette bonne époque où je gardais une version de java pour chaque switch SAN !

## On va devoir faire avec l’install de OneProvider donc...

Encore une fois, pas de bol. Le L3426 est livré de base en RAID0 avec tout l’espace disque utilisé… 

Oui oui... j’ai bien dis **_RAID0_**, donc les deux disques sont strippés et 2 fois plus de chances que votre RAID array casse. Bref... c’est useless.

Il faut changer la conf du RAID dans l’interface web et refaire une install. Si vous ne voulez pas de ZFS, vous pouvez choisir l’option RAID1 qui vous permettra d’avoir un miroir géré côté hardware (pas forcément une super idée vu qu’on est sur une config premier prix).

Dans mon cas, comme je veux du ZFS, utiliser le contrôleur RAID est un non-sens et j’ai donc choisi NORAID

![](/2021/03/oneprovider_noraid.png)

Bon du coup, une fois réinstallé, Proxmox installé sans utiliser le RAID hardware... mais... il n’y a plus de place pour ajouter un pool ZFS. Et pour continuer la blague : en utilisant NORAID, je m’attendais à ce que Proxmox ne soit installé que sur un disque et je me suis retrouvé avec un RAID 1 logiciel MDADM. 

Super...

## Qu’à cela ne tienne !

On va donc s’amuser à retailler les disques en ligne de commande, à l’aide de l’image de rescue via SSH. 

> Fun fun fun fun
> --Rebecca Black - Friday

Grosso modo, l’idée c’est de réduire le FS porté par le device **mdadm** (/dev/md126 dans mon cas en **rescue**) à 100G (par exemple), puis de réduire le volume **mdadm** lui même (un poil plus grand, genre 110G), puis de terminer en retaillant (encore à la hausse) les deux partitions disques.

![](/2021/03/oneprovider_bootmode.png)

**_NOTE ATTENTION DANGER : Comme d’habitude à chaque fois que j’écris un tuto avec des opérations dangereuses il y a toujours des gens pour venir râler que j’ai cassé un truc chez eux. Donc comme d’habitude, je mets un pavé pour expliquer que ce genre de commandes n’est à réaliser que si vous êtes sûr de ce que vous faites, que vous avez des sauvegardes ou que vous vous en fichez de tout perdre. Nous ne sommes jamais à l’abri d’une typo, d’un comportement différent chez vous par rapport à chez moi ou d’un rayonnement cosmique aléatoire._** **_Si vous voulez avoir plus d’info sur ce genre d’opérations, j’ai mis des liens en fin d’article._**

```
resize2fs /dev/md126 100G
# Il demandera préalablement un e2fsck, faites lui plaisir

mdadm --grow /dev/md126 --size=115343360 # ça fait 110G
cat /proc/mdstat # vérifiez que la modification est bien prise en compte

parted
(parted) select /dev/sda
(parted) resizepart 
Partition number? 2
End? 120G

# Et faire pareil avec sdb
```


Pour la partie avec **parted**, n’hésitez pas à BIEN prendre de la marge par rapport à l’opération avec **mdadm**, car j’ai eu des soucis à quelques Go près à cause d’une sombre histoire d’arrondis et de base 1000 versus base 1024...

## Et sinon pour les Atoms ?

Les Atoms eux n’ont qu’un disque. L’avantage c’est donc qu’on ne risque pas d’avoir des soucis de RAID à la noix. bon... On a pas de RAID ni de MDADM mais... on a du LVM.

![](/2021/03/cover2.jpg)

Le layout est relativement classique, on a un partitionnement standard LVM avec une partition 3 étendue et une partition 5 pour le PV… 

Il va falloir donc réduire le FS (qui prend tout le PV/VG/LV), puis le LV, puis le PV, puis la partition, avec une marge de sécurité là aussi. Et en mode **rescue** aussi, bien sûr ;)

```
# Le FS
e2fsck -f /dev/system-lyqmb/root
resize2fs /dev/system-lyqmb/root 100G

# Le LV/PV
lvreduce /dev/system-lyqmb/root -L 105G
pvresize /dev/sda5 --setphysicalvolumesize 110g

# La partition
parted
[...]
(parted) resizepart
Partition number? 5
End? [1000GB]? 120G
Warning: Shrinking a partition can cause data loss, are you sure you want to continue?
Yes/No? yes
```


## Upgrade

Une fois rebooté, on a maintenant des machines Proxmox propre, bien qu’obsolètes, avec de la place sur les disques. On peut maintenant passer à la mise à jour de PVE 5 à PVE 6, qu’il vaut mieux réaliser avant la mise en cluster (plus simple).

On commence par mettre à jour et faire le ménage, car c’est le bazar ici :

```
apt update
apt upgrade
apt autoremove
```


Pour passer à PVE 6, la première étape est d’installer corosync 3, prérequis à la migration.

```
echo "deb http://download.proxmox.com/debian/corosync-3/ stretch main" > /etc/apt/sources.list.d/corosync3.list
apt update
apt dist-upgrade --download-only
apt dist-upgrade
```


Le second prérequis est le passage de Debian Strech à Buster comme OS de base

```
sed -i 's/stretch/buster/g' /etc/apt/sources.list
sed -i -e 's/stretch/buster/g' /etc/apt/sources.list.d/pve-install-repo.list 
apt update
apt dist-upgrade
```


Un petit reboot pour prise en compte du changement de kernel et de nouveau un peu de ménage

```
reboot

# Après reboot
apt autoremove
```


Maintenant, on est à jour !

## Install ZFS et préparation des partitions

> AT LAST !!!

On a des OS fraichement installés, à jour et avec de la place sur les disques. On peut donc préparer notre install de ZFS ainsi que la création des pools. Pas de surprise ici, on est sur Linux donc l’implémentation zfs est ZFSonLinux

```
apt-get install zfsutils-linux
```


Bon, on a fait de la place sur nos Atom et notre Xeon, mais on a pas encore fait de partition avec la place en plus. Maintenant que j’y pense, on aurait surement dû le faire en même temps que le redimensionnement mais bon c’est pas grave car comme c’est de l’espace libre on peut le faire à chaud avec fdisk cette fois-ci (sans **rescue**).

Le principe est le même sur les 3 serveurs, seul le numéro de partition change (sda4 et sdb4 pour le L3426, sda6 pour les Atoms).

```
fdisk /dev/sda
[...]
Command (m for help): n
All space for primary partitions is in use.
Adding logical partition 6

First sector (234377049-1953523711, default 234377216): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (234377216-1953523711, default 1953523711): 

Created a new partition 6 of type 'Linux' and of size 819.8 GiB.

Command (m for help): w
The partition table has been altered.
Syncing disks.
```


**Note performance** : il est déconseillé par les concepteurs de ZFS de faire des pools avec des bouts de disques comme ça... Mais en vrai, on s’en fiche un peu. Vous êtes sur des machines antédiluviennes, sur une install où vous bidouillez de partout, sur un OS patché et vous venez d’installer une réécriture de ZFS pour qu’il soit compatible GPL... autant dire que ces points de tuning de perf ZFS seront le cadet de nos soucis.

## Préparation du pool ZFS

Normalement, zfs est installé et fonctionne. La commande **zpool list** doit renvoyer qu’il n’y a pas encore de pool

```
zpool list
no pools available
```


Sur la machine avec 2 disques, on va créer un pool en miroir sur sda4 et sdb4

```
zpool create -o ashift=12 rpool mirror /dev/sda4 /dev/sdb4

zpool list
NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
rpool 1.70T   480K  1.70T        -         -     0%     0%  1.00x    ONLINE  -
```


Le **ashift=12** est un paramètre de perf, qui indique que les disques utilisent des blocs de 4096 (Advanced Format) et non plus de 512 comme « avant ».

```
Quand j'étais jeune
```


Je ne suis pas complètement sûr que ce soit nécessaire de l’indiquer, mais j’ai eu des problèmes par le passé avec les premières implémentations de **ZFSonLinux**, donc je préfère le mettre.

Et pour les Atoms :

```
zpool create -o ashift=12 rpool /dev/sda6
```


Et mon histoire elle est ... FI-NIE :D

## Comment ça « FI-NIE » ?

Oui bon, pour la mise en cluster, j’ai déjà traité le sujet plusieurs fois... vous pouvez continuer sur mes autres tutos qui en parle déjà, inutile de faire une redite.

**Le but de cet article était de montrer la marche à suivre pour réussir à faire un « PRA du pauvre » avec un cluster de machines à bas coût chez OneProvider en tirant parti de Proxmox VE et de la réplication asynchrone avec ZFS.**

Et ça, c’est maintenant c’est bon ;)

(La suite ici, du coup)

* [Cluster Proxmox VE, v6 cette fois ci !](/2019/08/20/cluster-proxmox-ve-v6-cette-fois-ci/)

(ou là)
* [Proxmox VE 6 + pfsense sur un serveur dédié (1/2)](/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie/)

## Sources

* [doc.ubuntu-fr.org/raid_logiciel](https://doc.ubuntu-fr.org/raid_logiciel)
* [www.howtoforge.com/how-to-resize-raid-partitions-shrink-and-grow-software-raid](https://www.howtoforge.com/how-to-resize-raid-partitions-shrink-and-grow-software-raid)
* [www.thegeekdiary.com/replacing-a-failed-mirror-disk-in-a-software-raid-array-mdadm/](https://www.thegeekdiary.com/replacing-a-failed-mirror-disk-in-a-software-raid-array-mdadm/)

 [1]: /2021/03/replication.png
 [2]: /2021/03/oneprovider_reinstall.png
