---
title: '[Tutoriel] Créer un cluster de stockage GlusterFS sous Proxmox'
authors:
  - zwindler
type: post
date: 2017-02-28T13:00:59+00:00
url: /2017/02/28/tutoriel-creer-un-cluster-de-stockage-glusterfs-sous-proxmox/
image: /2017/02/proxmox_and_glusterfs.png
categories:
  - Stockage
  - Virtualisation
tags:
  - debian
  - Gluster client
  - Gluster Server
  - GlusterFS
  - Proxmox
  - Proxmox VE
  - stockage répliqué

---
## Installation de GlusterFS sur 2 serveurs Proxmox

Dans ce tutoriel je vais vous guider pas à pas pour ajouter la fonctionnalité de stockage distribué sur deux serveurs Proxmox. Ce tutoriel est également valable pour tout serveur sous Debian (Proxmox est une distribution Debian modifiée) ou même n’importe quelle autre distribution Linux modulo quelques ajustements.

## Mais comment en suis-je arrivé là ?

Et bien récemment, j’ai commandé un serveur Kimsufi dans le but de pouvoir tester 2 ou 3 nouvelles technos sans encombrer un peu plus le dressing.

![](/2014/03/img_20140309_175554.jpg)

> Un aperçu de mon dressing

Me retrouvant donc avec 2 serveurs Kimsufi, j’ai voulu voir si je ne pouvais pas clusteriser tout ça. Pour la partie cluster de virtualisation, malheureusement ce n’est pas possible si les deux serveurs sont dans des réseaux distincts, pour des problèmes de multicast.

Une solution aurait pu être de monter un VPN entre les deux mais j’ai préféré ne pas insister et voir si je ne pouvais pas me concentrer sur un autre point : créer un cluster de stockage !

Dans les dernières versions, Proxmox VE propose directement dans la console une visualisation des volumes Ceph ainsi qu’un tutoriel pour [configurer la partie serveur directement sur les hôtes de virtualisation][2]. Sur le papier, c’était donc le mécanisme de réplication de stockage à privilégier. Cependant, dans mon cas d’un « lab » avec seulement 2 serveurs sur un WAN, ce n’était pas l’idéal :

> Before you start with Ceph, you need a working Proxmox VE cluster with 3 nodes (or more).

Je me suis donc rabattu sur GlusterFS, qui a l’avantage d’être un peu plus simple de mise en place côté serveur même s’il n’est pas aussi bien intégré côté Proxmox.

## Le principe

Déjà on peut commencer par la définition Wikipedia

> GlusterFS est un système de fichiers libre distribué en parallèle, qui permet de stocker jusqu’à plusieurs pétaoctets (10^15 octets). C’est un système de fichiers de clusters. Livré en deux parties - un serveur et un client

En gros, _Gluster Server_ se charge de faire communiquer entre eux les hôtes et on défini des « _bricks_ » (espace de stockage sur un serveur donné) qu’on assemble entre elles pour donner un _volume_ (espace de stockage répliqué ou non). Et _Gluster Client_ vous permet d’accéder à un espace de fichiers qui va écrire simultanément sur l’ensemble des _bricks_ du _volume_ de manière transparente.

Assez de théorie, maintenant, la pratique !

## Prérequis

Sur les 2 serveurs Proxmox, j’ai créé en préventif un Fflesystem de 5G dédié à la configuration de Gluster. Pourquoi ? Car il y a un gros risque de plantage en cas de remplissage :

> Note: GlusterFS stores its dynamically generated configuration files at /var/lib/glusterd. If at any point in time GlusterFS is unable to write to these files (for example, when the backing filesystem is full), it will at minimum cause erratic behavior for your system; or worse, take your system offline completely. It is advisable to create separate partitions for directories such as /var/log to ensure this does not happen.

```
lvcreate -L 5G -n var_lib_glusterd pve
Logical volume "var_lib_glusterd" created.
mkfs.ext4 /dev/pve/var_lib_glusterd
mkdir -p /var/lib/glusterd
echo '/dev/pve/var_lib_glusterd /var/lib/glusterd ext4 defaults 1 2' >> /etc/fstab
mount -a
```


On récupère ensuite les sources sont disponibles sur le site [gluster.org][3]. Selon les distributions, la marche à suivre peut être différentes, notamment pour Ubuntu qui utilise un PPA.

```
wget -O - http://download.gluster.org/pub/gluster/glusterfs/3.9/rsa.pub | apt-key add -
echo deb http://download.gluster.org/pub/gluster/glusterfs/3.9/LATEST/Debian/jessie/apt jessie main > /etc/apt/sources.list.d/gluster.list
apt-get update
apt-get install glusterfs-server
```


Maintenant que le serveur est opérationnel, on créé nos bricks de 100Go sur un LV sur chaque serveur et on le monte.

```
lvcreate -L 100G -n data_brick1 pve
mkfs.xfs /dev/pve/data_brick1
mkdir -p /data/brick1
echo '/dev/pve/data_brick1 /data/brick1 xfs defaults 1 2' >> /etc/fstab
mount -a && mount
```


Vérification du service sous Proxmox (Debian)

```
service glusterfs-server status
* glusterfs-server.service - LSB: GlusterFS server
   Loaded: loaded (/etc/init.d/glusterfs-server)
   Active: active (running) since Wed 2017-02-08 23:21:00 CET; 3 days ago
   CGroup: /system.slice/glusterfs-server.service
           └─29562 /usr/sbin/glusterd -p /var/run/glusterd.pid

Feb 08 23:21:00 srv2 glusterfs-server[29557]: Starting glusterd service: glusterd.
Feb 08 23:21:00 srv2 systemd[1]: Started LSB: GlusterFS server.
```


Comme les nœuds ont besoin d’échanger des informations entre eux, il va falloir ouvrir quelques ports, à savoir :

  * 111/UDP et TCP
  * 24007/TCP
  * 24008/TCP
  * PUIS, un port par brique en partant du port 49152/TCP

Sous iptables ça devrait donner quelque chose comme cela

```
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 24007:24008 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 49152 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 111 -j ACCEPT
service iptables save
service iptables restart
```


ATTENTION : J’ai lu sur plusieurs sites qu’il faut ouvrir des ports à partir de 24009 pour les bricks. **Ce n’est plus vrai depuis la version 3.4 !**

Si vous êtes dans ces versions plutôt ancienne, c’est effectivement le port 24009 et + qu’il faut ouvrir mais ce n’est maintenant plus le cas ! Vous aurez des problèmes difficiles à débuguer car vos noeuds serveurs dialoguerons mais les bricks d’un même volumes répliqué ne se synchroniseront pas.

J’ai également lu qu’il était conseillé de s’assurer que la résolution soit toujours opérationnelle et donc de renseigner le fichier hosts mais ça, c’est à vous de voir.

```
vi /etc/hosts
```


On connecte maintenant les deux serveurs entre eux en exécutant cette commande que sur un des deux serveurs.

```
gluster peer probe srv2
  peer probe: success.
```


A partir de là, le cluster est actif. On peut le vérifier avec les 2 commandes suivantes :

```
gluster peer status
    Number of Peers: 1
    Hostname: srv2
    Uuid: aaaa-7d57-41c1-aaaa-c51f7e1c076a
    State: Peer in Cluster (Connected)

gluster pool list
    UUID                                    Hostname                State
    aaaa-7d57-41c1-aaaa-c51f7e1c076a    srv2                    Connected
    aaaa-6a78-44ce-aaaa-2feb3cfb3627    localhost               Connected
```


Sur les deux nœuds du cluster srv1 et srv2 :

```
mkdir -p /data/brick1/gv0
```


Depuis un des deux serveurs, on créé notre premier volume à partir des deux bricks de nos deux serveurs.

```
gluster volume create gv0 replica 2 srv1:/data/brick1/gv0 srv2:/data/brick1/gv0
    volume create: gv0: success: please start the volume to access data
gluster volume start gv0
    volume start: gv0: success
```


On vérifie que le volume est marqué « Started » :

```
gluster volume info

Volume Name: gv0
Type: Replicate
Volume ID: a3ffa060-ac5b-4b36-8b6c-8e77bad98cca
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: srv1:/data/brick1/gv0
Brick2: srv2:/data/brick1/gv0
Options Reconfigured:
transport.address-family: inet
performance.readdir-ahead: on
nfs.disable: on
```


A partir de là, notre volume est opérationnel est on peut commencer à le monter pour inscrire des données dedans !

## Afficher des infos sur le volume

Afficher des infos très précises sur les performances du volume à l’aide des commandes suivantes :

```
root@srv2:~# gluster volume profile gv0 start
Starting volume profile on gv0 has been successful
root@srv2:~# gluster volume profile gv0 info
Brick: srv2:/data/brick1/gv0
---------------------------------------------
Cumulative Stats:
   Block Size:                512b+               65536b+              131072b+
 No. of Reads:                    4                     5                    22
No. of Writes:                   78                   219                    44

   Block Size:             262144b+              524288b+             1048576b+
 No. of Reads:                    0                     0                     0
No. of Writes:                   35                    47                   919

 %-latency   Avg-latency   Min-Latency   Max-Latency   No. of calls         Fop
 ---------   -----------   -----------   -----------   ------------        ----
      0.00       0.00 us       0.00 us       0.00 us              5     RELEASE
      0.00       0.00 us       0.00 us       0.00 us            442  RELEASEDIR
      0.03      22.00 us      22.00 us      22.00 us              1      STATFS
      0.04      32.00 us      32.00 us      32.00 us              1    GETXATTR
      0.29     110.50 us      55.00 us     166.00 us              2      LOOKUP
     99.64   38491.00 us   32866.00 us   44116.00 us              2       WRITE

    Duration: 87590 seconds
   Data Read: 3213312 bytes
Data Written: 1033611264 bytes
[...]

Brick: srv1:/data/brick1/gv0
--------------------------------------------
Cumulative Stats:
   Block Size:                512b+               65536b+              131072b+
 No. of Reads:                    0                     0                     0
No. of Writes:                   78                   218                    44

   Block Size:             262144b+              524288b+             1048576b+
 No. of Reads:                    0                     0                     0
No. of Writes:                   34                    45                   906

 %-latency   Avg-latency   Min-Latency   Max-Latency   No. of calls         Fop
 ---------   -----------   -----------   -----------   ------------        ----
      0.00       0.00 us       0.00 us       0.00 us              5     RELEASE
      0.00       0.00 us       0.00 us       0.00 us              1  RELEASEDIR
      0.26      75.00 us      75.00 us      75.00 us              1      STATFS
      0.35     103.00 us     103.00 us     103.00 us              1    GETXATTR
      1.38     200.50 us     189.00 us     212.00 us              2      LOOKUP
     98.01   14246.50 us    4943.00 us   23550.00 us              2       WRITE

    Duration: 87589 seconds
   Data Read: 0 bytes
Data Written: 1018144768 bytes
```


Je vous rassure, ici, si les performances sont catastrophiques, c’est parce que le test a été réalisé en WAN sur ma lien ADSL pour particulier.

## Configuration dans proxmox (partie cliente)

Maintenant que la partie serveur est configurée, on doit accéder au volume répliqué via le client. En effet, c’est seulement par ce biais que l’on pourra écrire en Y sur notre volume. Écrire directement dans le dossier d’un brick n’aura pas l’effet escompté.

Depuis la console Proxmox, dans le menu « Stockage », cliquer sur « Ajouter / GlusterFS »

![](/2017/01/gluster_proxmox1.png)

![](/2017/01/gluster3.png)

Dans la capture suivante, vous pouvez admirer ma connexion ADSL saturée en upload par la copie d’un fichier d’une machine virtuelle depuis mon serveur dans mon dressing vers mon kimsufi. Et après vérification, on a bien le fichier de machine virtuelle des deux côtés :-).

![](/2017/01/gluster2.png)

## Sources

* [www.0rion.netlib.re/forum4/viewtopic.php?t=298 (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20170312163612/https://www.0rion.netlib.re/forum4/viewtopic.php?t=298)
* www.guillaume-leduc.fr/le-stockage-distribue-avec-glusterfs.html (lien mort, site fermé par son auteur en 2018, pas dispo sur Internet Archive)
* [pve.proxmox.com/wiki/Storage:_GlusterFS](https://pve.proxmox.com/wiki/Storage:_GlusterFS)
* [docs.gluster.org/en/latest/Administrator-Guide/Monitoring-Workload/](https://docs.gluster.org/en/latest/Administrator-Guide/Monitoring-Workload/)

 [2]: https://pve.proxmox.com/wiki/Ceph_Server
 [3]: https://download.gluster.org/pub/gluster/glusterfs/LATEST/Debian/
