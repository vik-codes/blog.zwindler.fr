---
title: Manipuler les disques hotspare sur serveur HP + ESXi avec hpssacli
authors:
  - zwindler
type: post
date: 2016-06-09T12:00:36+00:00
url: /2016/06/09/manipuler-hotspares-serveur-hp-esxi-hpssacli/
image: /2016/05/hpe_logo.png
categories:
  - Matériel
  - Virtualisation
tags:
  - cli
  - ESX(i)
  - Gen 9
  - hotspare
  - HPe
  - hpssacli
  - vSphere 6.X

---
## Avant de bidouiller sur hpssacli, tout commence par HP qui me demande d’extraire des logs juste pour me dire de mettre à jour au lieu de chercher à résoudre mon problème

Après avoir galéré sur vSphere 6 pour extraire les données provenant du contrôleur RAID HP Smart Storage Administrator ([article sur **hpssa**duesxi](/2016/01/30/erreur-hpssaduesxi-esxcli-vsphere-6/)), j’ai pu m’attaquer à la version interne du binaire qui vous permet de piloter la carte RAID**, hpssacli**. Vous allez voir, on peut faire beaucoup de choses avec cette CLI qui est très riche, SAUF extraire des rapports ADU.

Non, ne cherchez pas de logique.

## Sur ESXi custom HPe

Par défaut sur les images ESXi custom HPe (vous êtes obligés de les installer de toute façon puisque les serveurs HPe ont parfois des matériels qui ne sont pas supportés autrement comme des cartes RAID ou réseau), on retrouve un certain nombre de composants supplémentaires plus ou moins utiles ([HP AMS qui a longtemps fait planté les ESXi](/2015/05/30/bug-esxi-custom-hp-globalcartel-1-vmk_no_memory-cant-fork/) alors que personnellement je ne l’utilise pas...) et notamment la CLI pour contrôler les cartes RAID Smart Storage Administrator : **hpssacli**.

Ce binaire est commun à plusieurs OS, pas seulement à ESXi puisqu’on en retrouve au moins une version Windows et probablement une sous Linux aussi. Les commandes sont assez claires quoiqu’un peu verbeuses.

Par exemple, pour lister l’ensemble de mes contrôleurs, il me suffit de lancer

```
/opt/hp/hpssacli/bin/hpssacli controller all show status

Smart Array P440ar in Slot 0 (Embedded)
Controller Status: OK
Cache Status: OK
Battery/Capacitor Status: OK
```


Alors OK, je râle parce que c’est verbeux mais en fait, à la façon dont vous abrégeriez vos commandes sur un équipement réseau, tous les caractères qui ne sont pas nécessaire pour que la commande ne soit pas ambigüe sont optionnels. Ainsi on peut écrire aussi bien :

```
/opt/hp/hpssacli/bin/hpssacli ctrl all show
```


## Pourquoi j’aurai besoin de savoir manipuler la CLI ?

Dans un de mes contextes (ESXi + HP VSA), il se trouve que j’avais une micro coupure pour l’accès aux disques physiques lors d’un « rescan » côté VMware. Alors quand je dis « microcoupure » c’est le diagnostic HPe. En réalité des fois c’était 1 à 2 secondes, des fois des nœuds partaient carrément en timeout (60s+). D’autant plus que cela avait la fâcheuse tendance d’arriver pendant les mises à jour demandées par le support.

Et a force de tourner en rond (4 mois quand même) on a enfin fini par trouver que le pb venait de ces fichus hotspares donc (quelle idée...).

Dans mon exemple, je vais donc vous montrer comment j’ai désactivé (moi-même comme un grand) les hotspares sur mes contrôleurs et ainsi restauré une production quasi-normale (mes hotspares en moins). Si je veux voir les caractéristiques détaillées des disques physiques (pd = physical device) du contrôleur 0 présenté précédemment pour trouver le hotspare, voici la commande que je tape.

```
/opt/hp/hpssacli/bin/hpssacli ctrl slot=0 pd all show detail

physicaldrive 1I:1:23
Port: 1I
Box: 1
Bay: 23
Status: OK
Drive Type: Data Drive
Interface Type: SAS
Size: 1200.2 GB
Drive exposed to OS: False
Native Block Size: 512
Rotational Speed: 10500
Firmware Revision: HPD3
Serial Number: S4009WBT0000K5521FU7
Model: HP      EG1200JEMDA
Current Temperature (C): 28
Maximum Temperature (C): 47
PHY Count: 2
PHY Transfer Rate: 12.0Gbps, Unknown
Drive Authentication Status: OK
Carrier Application Version: 11
Carrier Bootloader Version: 6
Sanitize Erase Supported: False

physicaldrive 1I:1:24
Port: 1I
Box: 1
Bay: 24
Status: OK
Drive Type: Spare Drive
Interface Type: SAS
Size: 1200.2 GB
Drive exposed to OS: False
Native Block Size: 512
Rotational Speed: 10500
Firmware Revision: HPD3
Serial Number: S400AN1X0000K5521G8Q
Model: HP      EG1200JEMDA
Current Temperature (C): 23
Maximum Temperature (C): 42
PHY Count: 2
PHY Transfer Rate: 12.0Gbps, Unknown
Drive Authentication Status: OK
Carrier Application Version: 11
Carrier Bootloader Version: 6
Sanitize Erase Supported: False
```


Les données détaillées sont effectivement assez détaillés : c’est très appréciable. En tout cas moi j’aime bien. Au milieu de toutes les infos, notez le « Drive Type: Spare Drive » dans le retour de la commande : mon spare répond donc au doux sobriquet 1I:1:24.

A défaut d’exemple donné par le support, j’ai un peu tâtonné au début et j’ai tenté la commande suivante :

```
/opt/hp/hpssacli/bin/hpssacli ctrl slot=0 array all remove spares=1I:1:24

Error: This operation is not supported with the current configuration. Use the "show" command on devices to show additional details about the configuration.
Reason: Assignable spares not available
```


En fait, sur le contrôleur, j’ai deux « logical devices », qui sont en fait mes deux grappes RAID (SSD d’un côté, SAS de l’autre). Et comme les spares ne sont affectés dans le cas présent qu’à un des **ld**, il faut le retirer du **ld** en question, ce qui est somme toute assez logique.

```
/opt/hp/hpssacli/bin/hpssacli ctrl slot=0 ld 2 remove spares=1I:1:24
```


Pas de retour ni d’erreur ni de confirmation de la part de la CLI. On peut vérifier simplement que le disque n’est plus assigné de la façon suivante :

```
/opt/hp/hpssacli/bin/hpssacli ctrl slot=0 pd 1I:1:24 show detail

Smart Array P440ar in Slot 0 (Embedded)

unassigned

physicaldrive 1I:1:24
Port: 1I
Box: 1
Bay: 24
Status: OK
Drive Type: Unassigned Drive
Interface Type: SAS
Size: 1200.2 GB
Drive exposed to OS: False
Native Block Size: 512
Rotational Speed: 10500
Firmware Revision: HPD3
Serial Number: S400AN1X0000K5521G8Q
Model: HP      EG1200JEMDA
Current Temperature (C): 28
Maximum Temperature (C): 42
PHY Count: 2
PHY Transfer Rate: 12.0Gbps, Unknown
Drive Authentication Status: OK
Carrier Application Version: 11
Carrier Bootloader Version: 6
Sanitize Erase Supported: False
```


## Source

  * D’autres commandes chez [kallesplayground](https://kallesplayground.wordpress.com/useful-stuff/hp-smart-array-cli-commands-under-esxi/)
  * La doc ASCII de la CLI chez [HP (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20160531225319/http://h50146.www5.hp.com/products/software/oe/linux/mainstream/support/doc/general/mgmt/ssa_cli/v150/files/v150_40/hpssa-1.50-4.0.x86_64.rpm.txt)
  * La vraie doc qui traite plus largement de [HP Smart Storage Administrator (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150921064217/http://www.hp.com/ctg/Manual/c03909334) de chez HP (à partir de la page 60)
