---
title: Partage de VMDK entre plusieurs VMs
authors:
  - zwindler
type: post
date: 2015-01-07T16:05:17+00:00
url: /2015/01/07/partage-de-vmdk-entre-plusieurs-vms/
image: /2015/07/vmware2.png
categories:
  - Cluster
  - systeme
  - Virtualisation
tags:
  - Cluster
  - contrôleur SCSI
  - DRBD
  - ESX(i)
  - LVM
  - machine virtuelle
  - mirroring LVM
  - mode operatoire
  - partage
  - Redhat Cluster Suite
  - SCSI
  - tutoriel
  - VMDK
  - VMware

---
Si vous déjà voulu faire un POC de cluster Linux sur des machines virtuelles VMware, vous vous êtes déjà demandé comment vous alliez faire pour partager entre deux serveurs un espace de stockage commun à ces deux machines.

Une façon de faire consiste à rajouter une couche d’abstraction du stockage au dessus de l’OS (via GlusterFS ou DRBD par exemple), mais dans le cas d’un POC pour valider un cluster connecté au SAN, ce n’est pas forcément la première solution qui vient à l’esprit. Personnellement, la plupart des clusters que je construis sont encore dans un schéma plus simple à base de LUNs  iSCSI ou FC partagés sur un SAN en actif/actif ou actif/passif.

Cependant, pour simuler ce fonctionnement sur vos VMs, il va falloir bidouiller un peu.

En effet, pour éviter toute erreur malencontreuse (et même désastreuse), VMware interdit par défaut le démarrage de toute machine virtuelle qui aurait un disque en cours d’utilisation par une autre machine virtuelle. Aïe...

Voici un petit mode opératoire pour s’en sortir ;-)



Dans ce mode opératoire, les disques qu’on souhaite partager entre les deux serveurs sont des disques LVM en miroir, hébergés sur les baies de disques qui sont accessibles depuis les deux serveurs ESXi.

Cet exemple permet de valider la fiabilité de la méthode dans le cadre d’un cluster Linux virtuel de type RedHat Cluster Suite. Le principe reste tout de même valide pour une utilisation en dehors de RedHat Cluster Suite, certaines opérations ne seront juste pas nécessaires (qui peut le plus peut le moins).

## Prérequis

Pour les besoins de la documentation, deux machines virtuelles **test\_partage\_vmdk_1** et **test\_partage\_vmdk_2** ont été créés. Elles disposent des caractéristiques techniques suivantes :

  * **test\_partage\_vmdk_1** 
      * hébergée sur ESXi1
      * RedHat Entreprise Linux 5.8
      * 2 vCPU, 1 Go de RAM
      * 50 Go de disque interne sur un espace partagé
      * IP 192.168.111.1/24 sur un réseau virtuel
  * **test\_partage\_vmdk_2** 
      * hébergée sur ESXi2
      * RedHat Entreprise Linux 5.8
      * 2 vCPU, 1 Go de RAM
      * 50 Go de disque interne sur un espace partagé
      * IP 192.168.111.2/24 sur un réseau virtuel

## Création des disques virtuels

Les machines **test\_partage\_vmdk_1** et **test\_partage\_vmdk_2** doivent être éteintes avant de réaliser les modifications.

Ouvrir les paramètres de la machine virtuelle **test\_partage\_vmdk_1**, et ajouter un nouveau périphérique (Disque dur).

![](/2015/01/vmdk_partage1.png)

Le provisionnement du disque doit impérativement être « statique immédiatement mis à zéro ». De plus, il doit aussi être hébergé sur un datastore commun aux deux machines physiques ESXi.

![](/2015/01/vmdk_partage31.png)

Créer le disque et l’affecter à un _Nœud périphérique virtuel_ qui n’est pas encore utilisé.

Ici, le disque interne est stocké sur l’adresse SCSI (0:0). **Par défaut** VMware propose de créer le disque à la suite en SCSI (**0:**1).

**Il faut impérativement** dérouler la liste pour affecter le disque à l’adresse SCSI (**1:**0) qui représente un nouveau contrôleur SCSI.

![](/2015/01/vmdk_partage4.png)

De plus, pour permettre l’usage des snapshots sur la partie disque dur interne, les disques doivent être créés en Mode Indépendant/Persistant. _Dans le cas contraire, les snapshots seront impossibles sur la machine virtuelle_.

Une fois le disque créé, un nouveau contrôleur SCSI est également créé. Avant de valider la création du disque et du contrôleur SCSI, il faut modifier le paramètre de Partage de bus de SCSI en mode « Physique ».

![](/2015/01/vmdk_partage5.png)[4]Le second disque dur devra être créé de la même manière, et affecté au même contrôleur SCSI (on prendra l’adresse **1:1**).

Remettre **test\_partage\_vmdk_1** sous tension.

## Ajout des disques virtuels sur la deuxième machine virtuelle

Ouvrir les paramètres de la machine virtuelle **test\_partage\_vmdk_2**, ajouter un nouveau périphérique (Disque dur) puis sélectionner « Utiliser un disque virtuel déjà configuré ».

![](/2015/01/vmdk_partage6.png)

Sélectionner le premier disque créé précédemment.

![](/2015/01/vmdk_partage7.png)

De la même manière que précédemment, on doit créer un disque dur virtuel sur un nouveau contrôleur SCSI et en mode **Indépendant-Persistant**.

![](/2015/01/vmdk_partage8.png)

Modifier le nouveau contrôleur SCSI comme précédemment :

![](/2015/01/vmdk_partage9.png)

Ajouter enfin le second disque de la même manière à l’adresse SCSI (1:1).

![](/2015/01/vmdk_partage101.png)

Valider et mettre la machine virtuelle sous tension. Si elle boot correctement c’est que le partage fonctionne.

## Créer le miroir LVM partagé

Sur **les deux** serveurs, exécuter les commandes suivantes :

```
chkconfig acpid off #seulement pour RHCS
service acpid stop #seulement pour RHCS
vi /etc/lvm/lvm.conf
     filter = [ "a/.*/" ]
     #filter = [ "a|/dev/cciss/.*|", "a|/dev/mpath.*|", "r|.*|" ] #utiliser cette ligne en cas d’utilisation de multipath et de disques locaux présentés en tant que /dev/cciss. A adapter au contexte
[…]
volume_list = [ "vg01" , "@[TAG]" ]
```


Dans le cas de RedHat Cluster Suite, remplacer _[TAG]_ par le nom de la machine tel qu’il est définit dans le fichier /etc/cluster/cluster.conf.

En dehors du cas d’un traitement automatisé par cluster, n’importe quel tag convient du moment qu’il est unique à la machine. Dans le cas présent, les tags choisis sont respectivement tag\_vm1 et tag\_vm2.

Quelques précisions :

  * **filter** permet de traiter les cas où on doit ignorer certains disques. C’est typiquement nécessaire lorsque l’on utilise LVM avec multipath ou powerpath, car l’OS voit plusieurs « disques » sda ,sdb, ... pour un même disque mpath (1 sdX pour chaque chemin vers mpathY).
  * **volume_list** indique à LVM que seul le vg01 (interne) et les VG explicitement taggués avec le nom de la machine qui peuvent être utilisés. Cela permet de s’assurer qu’il n’y a qu’une seule machine qui peut activer le VG du moment qu’on n’ajoute jamais plus d’un tag au VG.

Même si les modifications du fichier lvm.conf sont prises en compte immédiatement, RedHat Cluster Suite impose une recompilation de l’initrd. Dans le cas d’un cluster RHCS, il faut donc lancer la commande suivante :

```
mkinitrd -f /boot/initrd-$(uname -r).img $(uname -r)
```


Sur un seul nœud (le premier) :

```
pvcreate /dev/sdb
pvcreate /dev/sdc
vgcreate -c n vg_mirror /dev/sdb /dev/sdc
```


Tagger le VG pour pouvoir travailler dessus sur ce nœud.

```
vgchange --addtag tag_vm1 -ay vg_mirror
lvcreate -n lv_mirror -m1  -l 5116 /dev/vg_mirror
     Logical volume "lv_mirror" created
```


Le journal des écritures doit lui aussi être en miroir

```
lvconvert --mirrorlog mirrored /dev/vg_mirror/lv_mirror
    Logical volume lv_mirror converted.
```


Il est enfin possible de formater le disque, et de le monter sur le **test\_partage\_vmdk_1**

```
mkfs.ext3 /dev/vg_mirror/lv_mirror
mount /dev/vg_mirror/lv_mirror /mnt
```


## Tester la bascule

Scanner les VGs pour vérifier que le nouveau VG est bien disponible sur le **test\_partage\_vmdk_2**

```
vgscan
vgs
```


Même s’il le VG est visible, il n’est pas possible de le monter car il n’a pas le bon tag (tel que spécifié dans le lvm.conf). Cela permet de vérifier que l’on ne pourra pas écrire sur les disques sur les deux nœuds en même temps.

```
Not activating vg_mirror/lv_mirror since it does not pass activation filter.
0 logical volume(s) in volume group “vg_mirror” now active
```


On peut démonter le FS, désactiver le vg et enlever le tag sur le serveur **test\_partage\_vmdk_1** et vérifier qu’on peut bien le monter et écrire dessus sur le **test\_partage\_vmdk_2**.

Ce comportement est automatique sous RedHat Cluster Suite, qui gère lui même les tags lors de la bascule d’un VG/LV.

Sur **test\_partage\_vmdk_1**

```
umount /mnt
vgchange --deltag tag_vm1 -an vg_mirror
```


Sur **test\_partage\_vmdk_2**

```
vgchange --addtag tag_vm1 -ay vg_mirror
mount /dev/vg_mirror/lv_mirror /mnt
```

**Have fun**
