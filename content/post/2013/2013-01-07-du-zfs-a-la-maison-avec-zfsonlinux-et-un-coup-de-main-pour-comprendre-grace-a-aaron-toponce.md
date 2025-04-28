---
title: Du ZFS à la maison avec ZFSonLinux et un coup de main pour comprendre grâce à Aaron Toponce
authors:
  - zwindler
type: post
date: 2013-01-07T17:59:37+00:00
url: /2013/01/07/du-zfs-a-la-maison-avec-zfsonlinux-et-un-coup-de-main-pour-comprendre-grace-a-aaron-toponce/
image: /2014/08/zfs-linux.png
categories:
  - Autohébergement
  - Stockage
  - Système
tags:
  - debian
  - Oracle
  - Sun
  - Ubuntu
  - ZFS
  - ZFSonLinux

---
Je l’ai déjà dis, je suis un sysadmin/technophile. Et comme je ne peux rien faire comme tout le monde, quand j’ai décidé de me monter mon NAS/MediaCenter perso, j’ai voulu le faire aussi bien au niveau hardware que software. Ceci m’a permis, à coût égal, de faire au moins aussi bien qu’un NAS tout prêt, et même beaucoup mieux dans certains domaines... au prix de multiples passes/améliorations/prises de tête ;-).

Pour toutes ces raisons, je ne pouvais PAS passer à côté de ZFSonLinux, une implémentation du FS introduit par Sun dans Solaris, car ZFS et à mon sens un des filesystems les plus aboutis en terme de fonctionnalités et surtout de sécurité des données :

  * b-tree file system
  * checksuming de tous les blocks à 256 bits (eux même checksumés) et équivalent du fsck à chaud
  * équivalent de parité/RAID en natif
  * gestion de FS simplifiée avec des propriétés qui peuvent être héritées ou modifiées
  * compression et même déduplication (!!!) en natif
  * protocoles de présentations sur le réseau en natif
  * snapshots quasiment illimités
  * ... (j’en oublie sûrement beaucoup => go site officiel/wikipédia)

Sans aller plus loin, je vous propose juste d’aller voir un travail assez complet sur ZFSonLinux, qui regroupe l’équivalent de plusieurs documentations ZFS expliquées et appliquées au cas qu’est ZFSonLinux :

  * Rappel des concepts de ZFS
  * Mise en place étape par étape
  * Best Practices et ressenti de l’auteur sur la techno et la stabilité des fonctionnalités délivrées par cet implémentation

Je ne ferais pas mieux que lui pour expliquer, c’est un must-read pour tout ceux qui voudraient en savoir plus sans savoir où commencer

  * [Install ZFS on Debian (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20230904234829/https://pthree.org/2012/04/17/install-zfs-on-debian-gnulinux/)

En bonus track, je vous linke aussi la documentation officielle Oracle pour aller plus loin dans l’utilisation de la CLI et un bon vieux troll de 2007 ;-)

  * [Docs Oracle](http://docs.oracle.com/cd/E19253-01/819-5461/index.html)
  * [blogs.oracle.com/bonwick/entry/rampant\_layering\_violation (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20130909121359/https://blogs.oracle.com/bonwick/entry/rampant_layering_violation)

