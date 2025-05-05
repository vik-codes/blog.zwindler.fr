---
title: 'Accélérer le rebuild/resync d’un volume RAID mdadm'
authors:
  - zwindler
type: post
date: 2015-03-04T14:00:45+00:00
url: /2015/03/04/accelerer-le-rebuildresync-dun-volume-raid-mdadm/
image: /2015/03/mdadm.png
categories:
  - Stockage
  - systeme
tags:
  - CentOS
  - debian
  - Linux
  - mdadm
  - RAID1
  - Redhat
  - RHEL
  - speed_limit_max
  - speed_limit_min
  - Ubuntu

---
## Débrider la reconstruction (resync) du RAID MDADM

Ça fait plusieurs fois que je tombe sur des articles de blogs qui détaillent que la reconstruction (resync) de leur miroir MDADM (RAID1) est trèèèès lente à cause d’un paramètre système dans /proc :

```
/proc/sys/dev/raid/speed_limit_min
```


Par défaut sous Linux (ou au moins la plupart des distribs que je côtoie), ce paramètre « min » est fixé à 1000, soit grossièrement 1Mo par seconde, ce qui est effectivement très lent, à l’heure des disques grand public de 6 To (ou 8? ou 10, je ne suis pas sûr d’être à jour).

Personnellement, je n’ai jamais été bloqué par ce paramètre comme ces personnes, au moins sur les distributions récentes (tout est relatif, en 2015 je parle de 2012 et +). Il s’agissait peut être d’un bug fixé depuis, qui sait?

Par contre, là où j’ai été effectivement bloqué, c’est plutôt par la variable /proc/sys/dev/raid/speed\_limit\_max.

```
cat /proc/mdstat
md1 : active raid1 sdc[0] sdd[1]
336592832 blocks [2/2] [UU]
[===========>.........] resync = 59.4% (199958272/336592832) finish=11.3min speed=200006K/sec
```


Quoi, mes disques resync à 200006K/sec? Comment dire ? C’est louche !

En effet, cette valeur est fixée par défaut à 200000, soit 200 Mo/s. Ça peut paraitre assez haut pour du RAID à la maison, mais sur du matériel d’entreprise, je n’ai pas eu de mal à atteindre cette limite.

```
cat /proc/sys/dev/raid/speed_limit_min
1000
cat /proc/sys/dev/raid/speed_limit_max
200000
```


```
echo 500000 > /proc/sys/dev/raid/speed_limit_max

cat /proc/mdstat
md1 : active raid1 sdc[0] sdd[1]
336592832 blocks [2/2] [UU]
[===============>.....] resync = 76.4% (257424960/336592832) finish=2.6min speed=505767K/sec
```


« And voila »
