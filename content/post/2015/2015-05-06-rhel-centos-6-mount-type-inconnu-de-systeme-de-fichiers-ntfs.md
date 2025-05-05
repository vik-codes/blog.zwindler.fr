---
title: "RHEL & CentOS 5 & 6 : « mount: type inconnu de système de fichiers &lsquo;ntfs' »"
authors:
  - zwindler
type: post
date: 2015-05-06T17:57:28+00:00
url: /2015/05/06/rhel-centos-6-mount-type-inconnu-de-systeme-de-fichiers-ntfs/
image: /2015/05/multipathmap1.png
categories:
  - Stockage
  - systeme
tags:
  - CentOS 6
  - disque dur externe
  - EPEL
  - mount
  - NTFS
  - ntfs-3g
  - ntfsprogs
  - RHEL 6
  - RPM
  - type inconnu de système de fichiers
  - unknown file system type
  - Yum

---
[Edit]La procédure étant similaire pour CentOS 5, les spécificités ont été ajoutés en fin d’article[/Edit]

## RHEL 6 / CentOS 6

Si vous avez déjà tenté de brancher un disque dur externe à un serveur fraîchement installé en RedHat 6 (ou CentOS 6), vous vous êtes peut être rendu compte que même en installation de type « Desktop » (je ne parle même pas de la « Minimal »), vous ne pouviez pas monter les partitions NTFS.

```
[root@monserveur appli]# mount /dev/sdb1 /mnt
mount: type inconnu de système de fichiers 'ntfs'
```


Si votre serveur a accès au net, il vous suffit d’ajouter le repository « EPEL release » (configurable rapidement via le RPM associé (lien mort, pas trouvé sur Internet Archive)

Mais dans le cas d’un réseau d’entreprise où vous en êtes coupés, pas de paniques. Voici les deux packages à récupérer et installer pour pouvoir monter votre partition NFTS.

* ntfs-3g (lien mort)
* ntfsprogs (lien mort)

Dans le cas où vous n’avez qu’un disque dur sur le serveur /dev/sda, le disque dur externe est souvent le suivant, et il n’y a en général qu’une seule partition, donc /dev/sdb1

```
yum install ntfs-3g-2014.2.15-8.el6.x86_64.rpm ntfsprogs-2014.2.15-8.el6.x86_64.rpm
mount /dev/sdb1 /mnt
```

## RHEL 5 / CentOS 5

Récupérer le package fuse-ntfs-3g-1.1004-1.el5.rf.x86_64.rpm sur repoforge (lien mort).

Installer le package et utiliser la commande suivante pour monter le disque dur

```
yum install fuse-ntfs-3g-1.1004-1.el5.rf.x86_64.rpm #récupérer éventuellement fuse et fuse-libs qui sont disponible dans les dépôts classiques
mount.ntfs-3g /dev/sdb1 /mnt
```

### Versions anciennes (<5.2)

Pour les versions RHEL/CentOS inférieures à 5.2, il faut également ajouter les packages dkms et dkms-fuse sinon le module kernel fuse ne s’activera pas (voir fin de [NTFS Tips and Tricks (lien mort, j'utilise Internet archive)](https://web.archive.org/web/20150326041937/https://wiki.centos.org/TipsAndTricks/NTFS))

```
yum install fuse-ntfs-3g-1.1004-1.el5.rf.x86_64.rpm fuse fuse-libs dkms dkms-fuse
modprobe fuse
```


### Erreur de signature

Ajoutez `--nogpgcheck` si vous n’avez pas envie d’ajouter la signature de repoforge dans la liste de vos signatures autorisées

### Limitation de la version 5

Pour information, il est **possible** que le disque ne soit pas _montable_ du tout s’il dépasse les 2 To. En fait, le kernel de la RHEL/CentOS 5 est trop ancien pour gérer correctement les disques de grande taille. C’était mon cas, avec l’erreur suivante

```
mount.ntfs-3g /dev/sdc1 /mnt
Failed to read last sector (732564991): Argument invalide
Perhaps the volume is a RAID/LDM but it wasn't setup yet, or the
wrong device was used, or the partition table is incorrect.
Failed to mount '/dev/sdc1': Argument invalide
The device '/dev/sdc1' doesn't have a valid NTFS.
Maybe you selected the wrong device? Or the whole disk instead of a
partition (e.g. /dev/hda, not /dev/hda1)? Or the other way around?
```

Un autre post qui traite du sujet sur [www.linuxquestions.org/questions/linux-general-1/mounting-usb-hard-drive-with-4kb-sectors-in-centos-5-8-a-4175477057/](http://www.linuxquestions.org/questions/linux-general-1/mounting-usb-hard-drive-with-4kb-sectors-in-centos-5-8-a-4175477057/)
