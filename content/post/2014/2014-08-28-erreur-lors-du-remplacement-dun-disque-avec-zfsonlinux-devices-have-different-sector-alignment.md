---
title: 'Erreur lors du remplacement d’un disque avec ZFSonLinux : devices have different sector alignment'
authors:
  - zwindler
type: post
date: 2014-08-28T10:08:49+00:00
url: /2014/08/28/erreur-lors-du-remplacement-dun-disque-avec-zfsonlinux-devices-have-different-sector-alignment/
image: /2014/08/zfs-linux.png
categories:
  - DIY
  - Matériel
  - Stockage
tags:
  - advanced format
  - ashift
  - ashift 12
  - ashift 9
  - murrayju
  - sector alignment
  - Ubuntu
  - ubuntu-zfs
  - ZFS
  - ZFSonLinux
  - zpool replace

---
Ceux qui me lisent savent que j’adore ZFS.

ZFS, c’est juste génial.

Les types qui ont inventé ce FS ont pris toutes les fonctionnalités intéressantes qu’on peut trouver dans un FS moderne, et les ont intégrés. Pour rappel, quelques unes qui me tiennent à cœur :

  * b-tree FS
  * transactions en mode copy-on-write
  * abstraction du stockage, création de FS simplifiée
  * gestion des snapshots
  * partages NFS/CIFS natifs
  * compression/déduplication native
  * gestion de caches SSD native
  * ...

Mais ils ont aussi eu le malheur de le développer pour Solaris ... et lui coller la malédiction d’un OS en perdition avec une licence le rendant difficilement compatible à un portable sur le kernel Linux... C’est la vie ;-)

Toujours est-il que ça n’a pas arrêté certaines personnes pour le porter, avec le projet ZFSonLinux, et permettre au ZFS fanboy que je suis d’avoir du ZFS sur mon NAS sous Linux, sans passer par la méthode ZFS/fuse en userland.

Cependant, ce projet relativement confidentiel n’est pas sans ses petits accros. C’est notamment ce que j’ai pu constater amèrement l’an dernier, quand ma grappe Z-RAID s’est dégradée suite à la perte d’un disque...



```
zpool status tank
   pool: tank
  state: DEGRADED
 status: One or more devices could not be used because the label is missing or
       invalid.  Sufficient replicas exist for the pool to continue
       functioning in a degraded state.
 action: Replace the device using 'zpool replace'.
    see: http://zfsonlinux.org/msg/ZFS-8000-4J
   scan: resilvered 31,5K in 0h0m with 0 errors on Sun Mar 24 12:44:41 2013
 config:
```

```
NAME            STATE     READ WRITE CKSUM
       tank            DEGRADED     0     0     0
         raidz1-0      DEGRADED     0     0     0
           ata-WDC_WD20EARX-00PASB0_WD-WCAZAH899460  ONLINE       0     0     0
           scsi-SATA_SAMSUNG_HD204UIS2HGJ90B632655   ONLINE       0     0     0
           ata-ST2000DL003-9VT166_5YD769R0-part3     UNAVAIL      0     0     1
```


OK. J’ai un disque HS. J’en achète un autre, et je le remplace. Finger in ze noz !

```
zpool replace tank ata-ST2000DL003-9VT166_5YD769R0-part3 ata-ST2000DL003-9VT166_5YD769R0
cannot replace ata-ST2000DL003-9VT166_5YD769R0-part3 with ata-ST2000DL003-9VT166_5YD769R0: devices have different sector alignment

zpool get ashift tank
NAME PROPERTY VALUE SOURCE
tank ashift 0 default
```


Malheureusement, à la création du pool, j’avais des vieux disques ne supportant pas les blocs de 4K (Advanced format), qui a donc été créé par défaut en mode legacy, à savoir 512 octets. Jusque là, rien de critique : le disque récent en 4k devra fonctionner sur des blocs de 512, ce qui restreindra ses performances brutes mais je ne suis pas à ça près, je veux juste remplacer mon fichu disque... Bien sur, j’ai testé ...

```
zpool set ashift=12 tank
```


... et ça ne fonctionne pas. Faut pas croire au père noël, ce paramètre est malheureusement inscrit en dur lors de la création du pool, et ne peux pas être modifié à postériori.

Cependant, ça n’explique pas pourquoi je ne pouvais pas ajouter mon disque 4k dans un pool en 512.

Et là, c’est le drame...en fait il s’agit d’un bug qui avait été introduit dans ZFSonLinux qui empêche le remplacement d’un disque de format différent de celui du pool :

  * [github.com/zfsonlinux/zfs/issues/1328](https://github.com/zfsonlinux/zfs/issues/1328)
  * [groups.google.com/a/zfsonlinux.org/forum/?fromgroups=#!topic/zfs-discuss/igoAmmKXz5E](https://groups.google.com/a/zfsonlinux.org/forum/?fromgroups=#!topic/zfs-discuss/igoAmmKXz5E)

Plutôt gênant... Heureusement, je suis tombé sur des gens suffisamment calé en code pour comprendre le problème, et proposer une solution. Voici ce que j’ai du faire pour remplacer la version ZFSonLinux officielle d’Ubuntu par une version patchée qui elle acceptait le remplacement.

```
apt-get install git uuid-dev alien
git clone https://github.com/murrayju/zfs

cd zfs
./autogen.sh
./configure

apt-get install uuid-dev
./configure
make deb

dpkg -l | grep zfs

apt-get remove zfsutils zfs-fuse zfs-dkms ubuntu-zfs libzfs1

dpkg -i *.deb
dpkg -l | grep zfs

init 6 #dans le doute

zpool status

zpool replace tank ata-ST2000DL003-9VT166_5YD769R0-part3 ata-ST2000DL003-9VT166_5YD769R0
zpool status
   pool: tank
  state: DEGRADED
 status: One or more devices is currently being resilvered.  The pool will
       continue to function, possibly in a degraded state.
 action: Wait for the resilver to complete.
   scan: resilver in progress since Sun Mar 24 14:00:28 2013
   20,8M scanned out of 2,59T at 2,98M/s, 253h10m to go
   6,25M resilvered, 0,00% done
 config:
       NAME            STATE     READ WRITE CKSUM
       tank            DEGRADED     0     0     0
         raidz1-0      DEGRADED     0     0     0
           ata-WDC_WD20EARX-00PASB0_WD-WCAZAH899460  ONLINE       0     0     0
           scsi-SATA_SAMSUNG_HD204UIS2HGJ90B632655   ONLINE       0     0     0
           replacing-2 UNAVAIL      0     0     0
             ata-ST2000DL003-9VT166_5YD769R0-part3   UNAVAIL      0     0     0
             ata-ST2000DL003-9VT166_5YD769R0         ONLINE       0     0     0  (resilvering)
```


Je ne vous raconte pas le soupir de soulagement que j’ai poussé lorsque j’ai vu ceci à l’écran
