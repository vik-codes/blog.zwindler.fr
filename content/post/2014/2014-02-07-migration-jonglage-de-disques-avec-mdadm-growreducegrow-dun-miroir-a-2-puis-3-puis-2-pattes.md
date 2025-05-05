---
title: 'Migration, jonglage de disques avec MDADM : grow/reduce/grow d’un miroir à 2 puis 3 puis 2 pattes'
authors:
  - zwindler
type: post
date: 2014-02-07T16:37:01+00:00
url: /2014/02/07/migration-jonglage-de-disques-avec-mdadm-growreducegrow-dun-miroir-a-2-puis-3-puis-2-pattes/
image: /2014/02/8-Bay_Raid_Station_04.jpg
categories:
  - autohebergement
  - materiel
  - Stockage
  - Virtualisation
tags:
  - CentOS
  - grow
  - KVM
  - LVM
  - mdadm
  - reduce
  - Ubuntu
  - Xubuntu

---
Dans le cadre d’une migration de ma plateforme de virtualisation de Xubuntu (shame) vers CentOS (j’en parlerai dans un prochain article), j’ai été amené à me faire des nœuds aux cerveaux pour trouver comment passer **de manière sure** d’un disque de 1 To contenant des données, des VMs et mon Xubuntu vers un CentOS avec deux disques en miroirs de 1 To, et en ne disposant que d’un spare de 400Go.

J’aurai pu installer l’OS par dessus l’Ubuntu mais je préfère repartir from scratch, et je voulais éviter de transférer les VMs sur le disque de 400Go car je n’étais pas très sur de sa fiabilité.

A noter que dans un cas plus simple que le mien, mdadm permet de passer d’un système sans redondance vers un RAID (very pratique, j’aurai fais ça si jamais je n’avais pas eu la migration d’OS à faire), ou si vos disques ont la taille suffisante, de remplacer online le disque.



Première étape, j’ai réinstallé from scratch CentOS sur un RAID assemblé avec un disque de 400 Go (sdc) et un disque de 1 To (sda) vides, et j’ai branché par la suite le disque de 1To de l’Ubuntu (sdb).

Pour le partitionnement, j’ai du faire une première partition sur chaque disque, agrégées sur md0, et dédiée au boot. Pour la partie OS et données, j’ai voulu partir sur du LVM, cependant j’étais limité par la taille du disque de 400Go, inférieur en taille. J’ai donc créé une partition prenant tout l’espace disponible sur les deux disques, mais qui m’a donné un device md1 limité à 400Go.

Une fois l’OS installé, j’ai pu, vérifier que les disques étaient bien synchronisés correctement :

```
cat /proc/mdstat
```


Deuxième étape, j’ai copié les données que je voulais récupérer (dont les VMs) sur le RAID. Une fois les données aux chaud sur le nouveau RAID, j’ai pu formatter en toute tranquillité le disque sdb, avec le même layout que le device sda, grâce à cette commande très pratique qu’est sfdisk (le -d imprime le layout, la partie après le pipe formatte). **ATTENTION à ne pas se tromper de sens, ça casse tout ;-)**!

```
sfdisk -d /dev/sda | sfdisk /dev/sdb #--force #peut être nécessaire si l'opération ne se fait pas sans
```


Troisième étape, maintenant que je dispose d’un disque de 1To identique à l’autre, je peux l’intégrer à mon miroir, qui devient un miroir à 3 pattes! Toujours plus...

```
mdadm --add /dev/md0 /dev/sdb1
mdadm --add /dev/md1 /dev/sdb2
mdadm --grow /dev/md0 --raid-devices=3
mdadm --grow /dev/md1 --raid-devices=3

cat /proc/mdstat
```


Etape suivante, se débarrasser sur disque de 400Go. Pour se faire, on doit commencer par le flaguer comme « failed », puis le retirer et indiquer au RAID qu’on est de nouveau sur 2 pattes et plus 3. A faire sur les deux devices md0 (partition de boot) et md1 (partition LVM). On peut le faire en deux étapes ou d’un seul coup.

```
mdadm --manage /dev/md0 --fail /dev/sdc1
mdadm --manage /dev/md0 --remove /dev/sdc1
mdadm /dev/md0 --grow --raid-devices=2

mdadm --manage /dev/md1 --fail /dev/sdb2 --remove /dev/sdb2
mdadm /dev/md1 --grow --raid-devices=2

mdadm --detail /dev/md0
```


Dernière étape, le RAID est resté « bloqué » sur la taille limitée par le disque de 400Go (md1 uniquement). Pour se faire, on doit lui faire comprendre qu’il dispose de plus d’espace et qu’il doit l’utiliser (on peut voir ce que voit mdadm au niveau de nos partitions avec le --examine).

```
mdadm --examine /dev/sda2
mdadm --examine /dev/sdc2

mdadm --grow /dev/md1 -z max
mdadm: component size of /dev/md1 has been set to 976117760K
```


Dans les options intéressantes qu’on peut utiliser dans le cas présent, j’ai retenu les deux suivantes. La première permet d’économiser le temps de resynchronisation de la nouvelle taille du miroir. Comme on peut lire dans le man, on peut l’utiliser **normalement** pour un RAID1, mais ce n’est pas conseillé... **Beware**...

```
mdadm --grow /dev/md1 -z max --assume-clean
#It can also be used when creating a RAID1 or RAID10 if you want to avoid  the initial resync, however this practice — while normally safe — is not recommended. Use this only if you really know what you are doing.
```


Plutôt qu’utiliser toute la taille disponible, on peut se limiter à une certaine taille

```
mdadm --grow /dev/md1 -z [size_in_kBytes]
```


Enfin, puisqu’il s’agit d’un volume LVM, on termine par un PV resize, qui permet de prendre en compte au niveau PV puis VG qu’on a plus de place disponible qu’avant

```
pvresize /dev/md1
Physical volume '/dev/md1' changed
1 physical volume(s) resized / 0 physical volume(s) not resized
```
