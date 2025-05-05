---
title: '« device-mapper: create ioctl failed » et « Cannot open /dev/sdX: Device or resource busy »'
authors:
  - zwindler
type: post
date: 2015-04-13T15:49:42+00:00
url: /2015/04/13/device-mapper-create-ioctl-failed-et-cannot-open-devsdx-device-or-resource-busy/
image: /2015/05/multipathmap1.png
categories:
  - Stockage
  - systeme
tags:
  - device or resource busy
  - device-mapper
  - ioctl failed
  - LVM
  - mdadm
  - mirroring LVM
  - mirrorlog
  - RHEL
  - tag LVM
  - vgchange

---
Lorsqu’on travaille avec LVM, on tombe des fois sur des comportements plus qu’étranges et qui viennent d’un composant de bas niveau que je connaissais mal jusqu’à présent : le device-mapper.

Pour y voir plus clair, voici la description donnée par Wikipedia ([Device Mapper sur Wikipedia](http://en.wikipedia.org/wiki/Device_mapper)) :

> The **device mapper** is [Linux kernel][1]&lsquo;s [framework][2] for mapping physical [block devices][3]{.mw-redirect} onto higher-level _virtual block devices_. It forms the foundation of [LVM2][4]{.mw-redirect}, software [RAIDs][5] and [dm-crypt][6] disk encryption, and offers additional features such as file system [snapshots][7].<sup id="cite_ref-redhat-dm_1-0" class="reference"></sup>

C’est donc, **entre autre**, la base sur laquelle reposent à la fois MDADM et LVM. Et ça tombe bien, c’est justement d’une erreur MDADM et un autre de LVM dont je vais vous parler.

## MDADM : Cannot open /dev/sdx: Device or resource busy

```
mdadm --create /dev/md1 --level=1 --verbose --raid-devices=2 /dev/sdc /dev/sdd
mdadm: Cannot open /dev/sdc: Device or resource busy
```


Dans certains cas rares, il peut arriver que le miroir MDADM cesse de fonctionner (suppression, coupure brutale, ...) mais qu’on ne puisse ni le remonter, ni même le reconstruire en repartant des disques supposément vierges. Les serveurs refusent de reconstruire le miroir, prétextant que les disques sont « busy », sans raison apparente puisque le miroir a été détruit.

En fait, ce n’est pas au niveau MDADM qu’il y a un problème, mais au niveau du device mapper. On peut afficher la table pour afficher l’ensemble des entrées enregistrées

```
dmsetup table
  VGRoot-appli: 0 20971520 linear 9:0 71303552
  VGRoot-home: 0 4194304 linear 9:0 50332032
  VGRoot-slash: 0 41943040 linear 9:0 384
  VGRoot-swap: 0 20971520 linear 9:0 92275072
  VGRoot-tmp: 0 8388608 linear 9:0 41943424
  VGRoot-var: 0 8388608 linear 9:0 54526336
  VGRoot-var_log: 0 8388608 linear 9:0 62914944
  vg_mdadm-lv_mdadm: 0 2097152 linear 8:48 304087424
 ```


Ici, c’est la dernière ligne qui pose problème. Il n’est plus censé y avoir de référence à ce VG, car il aurait du disparaître avec le miroir. Pourtant il apparaît toujours dans la table (et rebooter ne sert à rien car cette table résiste au reboot).

La seule solution ici pour « libérer » les disques sdc et sdd qui composent mon miroir est de supprimer manuellement l’entrée avec la commande suivante :

```
dmsetup remove vg_mdadm-lv_mdadm
```


## Miroir LVM

J’ai pas mal « joué » avec les miroirs LVM malgré les limitations qu’ils imposent dans la version 5 de RedHat Entreprise Linux et je suis tombé sur des erreurs similaires invoquant des problèmes de lock sur les volumes sans pour autant que je puisse les déceler au niveau FS ou même au niveau LVM.

En fait, le problème vient encore d’entrées obsolètes dans la table du device mapper.

Dans certains cas de perte d’un membre (PV) suite à une coupure SAN par exemple, les membres inaccessibles sont écartés des LVs en miroir. Le cas est même encore plus fréquent lorsque le journal du miroir (mirrolog) n’est pas lui même en miroir (modifiable avec un « lvconvert --mirrorlog mirrored monLV »).

On tombe alors sur l’erreur suivante lors de l’activation des LVs

```
vgchange --addtag server01-hb -ay vg_prod_dump
  Volume group "vg_prod_dump" successfully changed
  device-mapper: create ioctl failed: Périphérique ou ressource occupé
  0 logical volume(s) in volume group "vg_prod_dump" now active
```


Ici, comme le LV n’est pas activé, il n’y a pas de raison pour que les 4 dernières lignes soient présentes.

```
dmsetup table
  VolGroup01-LogVol00: 0 102367232 linear 104:2 384
  VolGroup01-LogVol01: 0 69926912 linear 104:2 206242176
  VolGroup01-lv_appli: 0 103874560 linear 104:2 102367616
  vg_prod_dump-lv_dump_mimage_1: 0 1677713408 linear 120:208 384
  vg_prod_dump-lv_dump_mimage_1: 1677713408 469770240 linear 120:224 8576
  vg_prod_dump-lv_dump_mlog_mimage_1: 0 8192 linear 120:160 469770624
  vg_prod_dump-lv_dump_mlog_mimage_0: 0 8192 linear 120:224 384
```


Il faut donc les détruire à la main.

```
dmsetup remove vg_prod_dump-lv_dump_mimage_1
```


 [1]: http://en.wikipedia.org/wiki/Linux_kernel "Linux kernel"
 [2]: http://en.wikipedia.org/wiki/Software_framework "Software framework"
 [3]: http://en.wikipedia.org/wiki/Block_device "Block device"
 [4]: http://en.wikipedia.org/wiki/LVM2 "LVM2"
 [5]: http://en.wikipedia.org/wiki/RAID "RAID"
 [6]: http://en.wikipedia.org/wiki/Dm-crypt "Dm-crypt"
 [7]: http://en.wikipedia.org/wiki/Snapshot_%28computer_storage%29 "Snapshot (computer storage)"
