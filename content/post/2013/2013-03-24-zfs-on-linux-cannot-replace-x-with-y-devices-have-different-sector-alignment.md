---
title: 'ZFS on Linux : cannot replace X with Y: devices have different sector alignment'
authors:
  - zwindler
type: post
date: 2013-03-24T14:27:45+00:00
url: /2013/03/24/zfs-on-linux-cannot-replace-x-with-y-devices-have-different-sector-alignment/
image: /2014/08/zfs-linux.png
categories:
  - autohebergement
  - Matériel
  - Stockage
  - Système
tags:
  - DIY
  - NAS
  - RAIDZ-1
  - sector alignment
  - Ubuntu
  - ZFSonLinux

---
Pour une obscure raison que je détaillerai dans un prochain article je me suis retrouvé avec un disque de ma grappe RAID-Z1 avec 2 partitions, une en ext4 et l’autre pour la grappe ZFS. Vous savez surement que pour des raisons de performances et de taille utile de la grappe ZFS, il est préférable de disposer d’un disque entier pour la création des VDEV.

Une fois le nettoyage fait au niveau de la partition non ZFS, je me suis retrouvé face à un dilemme. Comment remplacer le device **disque3-part2** par **disque3**. Et c’est ainsi qu’a commencé ma descente aux enfers (relativement brève heureusement).



La première idée que j’ai essayé pour me débarrasser du disque a été le **zpool replace**, mais forcément ça ne peut pas marcher, puisque c’est le même disque, il est donc **busy**.

Ma seconde idée a été de passer **disque3-part2** en **offline**, mais là encore, comme **offline** ne correspond pas à un état « détruit », mais plutôt « mis de côté pour plus tard », ça n’a pas été bien loin.

Ma troisième idée a été de profiter du fait que le **disque3-part2** était offline pour passer disque3 comme _spare_ de mon zpool. Alors effectivement, au final ça a marché mais ce n’est pas tout à fait la façon dont je voulais le faire. En fait, le disque a été entièrement formaté...

```
zpool status tank
pool: tank
state: DEGRADED
status: One or more devices could not be used because the label is missing or
invalid.  Sufficient replicas exist for the pool to continue
functioning in a degraded state.
action: Replace the device using 'zpool replace'.
see: http://zfsonlinux.org/msg/ZFS-8000-4J
scan: resilvered 31,5K in 0h0m with 0 errors on Sun Mar 24 12:44:41 2013
config:

NAME             STATE     READ WRITE CKSUM
tank             DEGRADED     0     0     0
raidz1-0         DEGRADED     0     0     0
disque1          ONLINE       0     0     0
disque2          ONLINE       0     0     0
disque3-part2    UNAVAIL      0     0     1
```


Bon « ce qui est fait est fait », le **disque3-part2** étant pour toujours indisponible (paix à son âme), je me suis dis que j’allais au moins enfin pouvoir importer le **disque3** en entier pour ma grappe. Mais comme une bonne nouvelle n’arrive jamais seule, voilà en face de quoi je me suis retrouvé.

```
zpool replace tank disque3-part2 disque3
    cannot replace disque3-part2 with disque3: devices have different sector alignment
```


OMG... Je sens que ça va me plaire cette histoire... En fait il s’agit d’un module de ZFS qui cherche à savoir si vos disques utilisent des tailles physiques de bloc de 512 octets ou de 4ko (les plus récents), pour pallier à des problèmes de performances rencontrés... Normalement je suis bien en default, la zpool doit choisir elle même...

```
zpool get ashift tank
    NAME  PROPERTY  VALUE   SOURCE
    tank  ashift    0       default
```


Le soucis c’est que ce paramètre indique juste qu’à la création, la zpool choisit toute seule son alignement (9 pour 512 ou 12 pour 4k), ce qui est vraiment facheux car à mon humble avis mes disques sont tous en 4k... Et bien sûr, plus moyen de modifier à la volée...

```
zpool set ashift=12 tank
```


Après avoir sué a grosses gouttes avec une grappe en DEGRADED pendant quelques minutes (surtout parce que je ne savais pas si j’allais savoir le fixer), j’ai quand même réussi à récupérer la « solution » grâce à la communautés, en attendant un vrai patch des développeurs.

  * [ZfSonLinux issue 1328](https://github.com/zfsonlinux/zfs/issues/1328)
  * [ZFSonLinux google group](https://groups.google.com/a/zfsonlinux.org/forum/?fromgroups=#!topic/zfs-discuss/igoAmmKXz5E)

En gros, **murrayju** a patché le code, et il « suffit » de compiler ses propres modules ZFS pour contourner le problème

```
apt-get install git uuid-dev alien

git clone https://github.com/murrayju/zfs

cd zfs
./autogen.sh
./configure
make deb

dpkg -l | grep zfs
```


Les packages existant provoquent (forcément) des conflits avec ceux qui viennent d’être compilés, il faut donc se débarrasser de tout ce qui ressemble de près ou de loin à un module ZFS

```
apt-get remove zfsutils zfs-fuse zfs-dkms ubuntu-zfs libzfs1

dpkg -i *.deb
dpkg -l | grep zfs
apt-get remove zfsutils
```


A partir de là, un reboot permet de se débarraser des modules noyaux encore chargés et de booter sur l’ancien code, qui lui accepte bien mes disque 4K sur mon pool 512

```
init 6

zpool replace tank disque3-part2 disque3
zpool status

pool: tank
state: DEGRADED
status: One or more devices is currently being resilvered.  The pool will
continue to function, possibly in a degraded state.
action: Wait for the resilver to complete.
scan: resilver in progress since Sun Mar 24 14:00:28 2013
20,8M scanned out of 2,59T at 2,98M/s, 253h10m to go
6,25M resilvered, 0,00% done
config:

NAME            STATE     READ WRITE CKSUM
tank            DEGRADED     0     0     0
raidz1-0        DEGRADED     0     0     0
disque1         ONLINE       0     0     0
disque2         ONLINE       0     0     0
replacing-2     UNAVAIL      0     0     0
disque3-part2   UNAVAIL      0     0     0
disque3         ONLINE       0     0     0  (resilvering)
```


Elle est pas belle la vie?

Bon ... par contre ... après ça, j’imagine que vous ne serez pas surpris d’apprendre que je suis passé en ext4 avec mdadm ...
