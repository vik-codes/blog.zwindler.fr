---
title: Retrouver des fichiers supprimés sur une brick Gluster
authors:
  - zwindler
type: post
date: 2017-08-16T11:45:27+00:00
url: /2017/08/16/recuperer-des-fichiers-sur-brick-gluster/
image: /2017/02/proxmox_and_glusterfs.png
categories:
  - Stockage
  - Système
  - Virtualisation

---
## Un sous titre qui ne casse pas des bricks

> Mais si, tu vas voir, c’est drôle comme vanne, parce qu’en fait, tu vois dans Gluster ya des bricks, et... bon ok, j’arrête.

Comme vous le savez peut être [si vous avez lu mon article sur ProxMox et GlusterFS](/2017/02/28/tutoriel-creer-un-cluster-de-stockage-glusterfs-sous-proxmox/), j’aime bien GlusterFS. C’est simple à installer, ça marche assez vite, c’est là depuis longtemps et plutôt stable. Mes perfs ne sont pas extraordinaires mais c’est lié à 100% à mon infrastructure qui ne respecte absolument pas les prérequis, à savoir : un stockage sur un réseau dédié et local, alors que moi je fais ça sur une ligne ADSL avec des disques grands public.

Bref, je synchronise des données sur les Internets et j’en suis très content. Mais ça c’était avant le drame.

## Une promo chez Kimsufi

C’est les soldes; Kimsufi brade le serveur que j’utilise à 18€/mois au lieu de 24. Je leur aurais bien demandé de juste me faire une réduction et puis basta, mais je ne suis pas sûr que ça serait passé ;-).

J’ai donc résilié mon contrat pour « Executor » (le petit nom de mon KS-3) et migré mes machines vers mon nouveau serveur (appelé ici glusternode).

![](/2017/08/superstardestroyer_executor.gif)

> Goodbye old friend

Et pour éviter de devoir resynchroniser un trop gros volume de données entre mes serveurs Gluster via ADSL, j’ai eu une de mes fameuses « idées de génie ». Supprimer tous les bricks sauf 1 sur mon volume Gluster, réduire la volumétrie réellement utile pour en avoir un minimum, puis resynchroniser le volume en ajoutant à nouveau une brick.

Pour ceux qui veulent savoir comment faire ça, vous pouvez suivre un tuto sur [le site du support de rackspace][3].

Sauf que je n’ai pas supprimé les fichiers depuis mon client Gluster, mais directement depuis le filesystem /data/brick1/gv0...

## Quel est le problème ?

Le problème, je l’ai vite vu. Après avoir libéré environ 60 Go d’espace, « du » me renvoie bien l’espace libéré...

```
root@glusternode:/data/brick1/gv0# du -shx *
30G dump
0 images
0 template
```


... mais pas « df » !

```
root@glusternode:/data/brick1/gv0# df .
Sys. de fichiers blocs de 1K Utilisé Disponible Uti% Monté sur
/dev/mapper/pve-data_brick1 104806400 93579732 11226668 90% /data/brick1
```


Heureusement je ne suis pas le seul sysadmin « tête en l’air »... J’ai trouvé la solution sur [la devlist GlusterFS][4].

## Comment ça marche GlusterFS ?

Et c’est intéressant car ça m’a permis de descendre un peu sous le capot de GlusterFS. En réalité, lorsqu’on affiche le contenu du filesystem distribué, on ne voit pas tout !

Si on descend sur la brick elle même et qu’on regarde le contenu du filesystem en incluant les fichiers cachés, on peut découvrir un dossier « .glusterfs ». Et comme par magie :

```
root@glusternode:/data/brick1/gv0# du -shx .glusterfs/
90G .glusterfs/
```


Voilà mon espace disque perdu ! Une partie des fichiers sont visibles (30 Go) dans le dossier dump, à la racine de gv0, mais la totalité des fichiers sont aussi visibles dans le .glusterfs (30 Go + mes 60 Go perdus)... Comment est ce possible que j’ai 120 Go alors que le FS n’en fait que 100 ?

Et bien en fait, c’est parce que GlusterFS utilise un lien de type « hardlink ». Vous n’êtes peut être pas familier de la notion car elle n’est pas souvent utilisée mais c’est un système Unix qui permet, au sein d’un même filesystem, d’avoir un seul fichier référencé par 2 (ou plus) arborescences distinctes sans pour autant le stocker 2 fois.

Cette notion est à distinguer du lien symbolique (créé avec le « -s » de la commande « ln »), car si on supprime le fichier cible, le lien symbolique reste mais est brisé. Là, avec le « hardlink », tant qu’il reste un chemin vers le fichier, un « rm » ne fait que supprimer le pointeur en question. Seul le _dernier_ « rm » vers le dernier pointeur supprime réellement les données.

On peut vérifier qu’il s’agit bien de ça avec les commandes suivantes :

Afficher le numéro d’inode de nos fichiers :

```
root@glusternode:/data/brick1/gv0/dump# ls -li
total 31411464
201326698 -rw-r--r-- 2 root root 1394 févr. 27 21:07 vzdump-qemu-100-2017_02_27-21_06_55.log
201326704 -rw-r--r-- 2 root root 2287 févr. 27 22:12 vzdump-qemu-100-2017_02_27-22_09_27.log
201326716 -rw-r--r-- 2 root root 3183 juil. 12 03:03 vzdump-qemu-100-2017_07_12-03_00_01.log
```


Ici dans la première colonne on obtient pour chaque fichier un « identifiant unique » au sein de notre filesystem. On peut donc vérifier que Gluster utilise des hardlinks en cherchant un même numéro d’inode pointant vers 2 chemins différents :

```
root@glusternode:/data/brick1/gv0# find . -links 2 -ls | grep 201326847
201326847 4 -rw-r--r-- 2 root root 3267 août 9 02:05 ./.glusterfs/24/80/2480dbf8-0f59-49aa-afca-9ad3595f11ca
201326847 4 -rw-r--r-- 2 root root 3267 août 9 02:05 ./dump/vzdump-qemu-121-2017_08_09-02_02_39.log
```


C’est deux chemins pointent vers un même inode et représentent ici un fichier (vzdump-qemu-121-2017\_08\_09-02\_02\_39.log) normalement présent sur le brick (c’est à dire un que je n’ai pas charcuté bêtement comme les autres).

Du coup le but du jeu dans mon cas est de retrouver les fichiers de données qui n’ont qui n’ont qu’une seule référence et non 2 (en mettant de côté les fichiers qui ont l’air importants genre « gv0.db » ou « health_check »).

J’ai fais un petit find dégueux qui fait ça pour nous, et j’ai rajouté un -exec file pour savoir si c’est bien un fichier de sauvegarde de proxmox (archive LZO dans mon cas).

```
find .glusterfs/ -mindepth 3 -size +1 -links 1 -type f -ls -exec file {} \;
201326708 1437628 -rw-r--r-- 1 root root 1472129448 juil. 29 02:12 .glusterfs/3f/1c/3f1cf4a6-8d36-4a08-b4c2-d82f88745b09
.glusterfs/3f/1c/3f1cf4a6-8d36-4a08-b4c2-d82f88745b09: lzop compressed data - version 1.030, LZO1X-1, os: Unix
201326736 10235876 -rw-r--r-- 1 root root 10481534660 juil. 19 05:00 .glusterfs/0f/e1/0fe1a6e3-61a4-4216-97c9-15b074d0a3a1
.glusterfs/0f/e1/0fe1a6e3-61a4-4216-97c9-15b074d0a3a1: lzop compressed data - version 1.030, LZO1X-1, os: Unix
[...]
```


## A vous de jouer

Maintenant qu’on sait où sont nos données, à vous de choisir ce que vous voulez en faire. Dans mon cas, j’aurai pu me contenter de tout supprimer. Mais vous pouvez aussi tenter de les restauter si vous savez quel fichier correspond à quoi !

Dans mon cas encore, j’ai été capable de remettre finalement à disposition le fichier via une petite boucle :

```
root@glusternode:/data/brick1/gv0# for i in $(find .glusterfs/ -mindepth 3 -size +1 -links 1 -type f); do ln $i dump/vzdump-qemu-$(basename $i).vma.lzo; done
root@glusternode:/data/brick1/gv0# ll dump/
total 93441940
-rw-r--r-- 2 root root 10481534660 juil. 19 05:00 vzdump-qemu-0fe1a6e3-61a4-4216-97c9-15b074d0a3a1.vma.lzo
-rw-r--r-- 2 root root 1506948985 août 5 02:17 vzdump-qemu-149fd851-905e-4e60-bfb3-6f60d4142df2.vma.lzo
-rw-r--r-- 2 root root 1278854342 août 5 02:29 vzdump-qemu-2bdaa890-0753-42a7-948b-a9cd58c9f673.vma.lzo
-rw-r--r-- 2 root root 1472129448 juil. 29 02:12 vzdump-qemu-3f1cf4a6-8d36-4a08-b4c2-d82f88745b09.vma.lzo
-rw-r--r-- 2 root root 14089336831 juil. 29 03:33 vzdump-qemu-5c2a1f8e-3f86-4b2b-b924-b0ae6cb7739b.vma.lzo
-rw-r--r-- 2 root root 1474206817 août 2 02:08 vzdump-qemu-5e0467b5-8ac8-4774-8b24-2b37238cfd31.vma.lzo
[...]
```


On repasse sur le vrai point de montage pour voir si ça a bien marché :

```
cd /mnt/pve/GlusterBkp/dump
root@glusternode:/mnt/pve/GlusterBkp/dump# ll
total 93441733
-rw-r--r-- 2 root root 10481534660 juil. 19 05:00 vzdump-qemu-0fe1a6e3-61a4-4216-97c9-15b074d0a3a1.vma.lzo
-rw-r--r-- 2 root root 1506948985 août 5 02:17 vzdump-qemu-149fd851-905e-4e60-bfb3-6f60d4142df2.vma.lzo
-rw-r--r-- 2 root root 1278854342 août 5 02:29 vzdump-qemu-2bdaa890-0753-42a7-948b-a9cd58c9f673.vma.lzo
-rw-r--r-- 2 root root 1472129448 juil. 29 02:12 vzdump-qemu-3f1cf4a6-8d36-4a08-b4c2-d82f88745b09.vma.lzo
-rw-r--r-- 2 root root 14089336831 juil. 29 03:33 vzdump-qemu-5c2a1f8e-3f86-4b2b-b924-b0ae6cb7739b.vma.lzo
-rw-r--r-- 2 root root 1474206817 août 2 02:08 vzdump-qemu-5e0467b5-8ac8-4774-8b24-2b37238cfd31.vma.lzo
[...]
```


Et les fichiers réapparaissent dans l’interface de ProxMox ;-)

![](/2017/08/vzdump_lzo.png)

 [3]: https://support.rackspace.com/how-to/add-and-remove-glusterfs-servers/
 [4]: http://lists.gluster.org/pipermail/gluster-users/2014-March/016726.html
