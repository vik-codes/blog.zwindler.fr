---
title: 'Stockage pour un admin geek : QNAP TS431P2 ou Synology DS418(j) ?'
authors:
  - zwindler
type: post
date: 2018-01-23T12:45:24+00:00
url: /2018/01/23/stockage-pour-un-admin-geek-qnap-ts431p2-ou-synology-ds418j/
image: /2018/01/qnap22.jpg
categories:
  - autohebergement
  - Matériel
tags:
  - ARM
  - Docker
  - QNAP
  - Snapshot
  - Synology
  - VM

---
## Behold!

![](/2018/01/qnap22.jpg)

> Mon TS431P2

J’en ai déjà parlé sur le blog, j’ai entamé une phase de _dés-auto-hébergement_. Oui je sais, c’est triste.

Au delà des problématiques de disponibilités des services plus réduite en auto-hébergement (sauf à réaliser des efforts conséquents) par rapport à des services en ligne, héberger son serveur, ce n’est pas toujours très écolo et ça peut coûter plus cher.

Louer une machine physique et y installer un hyperviseur chez Kimsufi (ou OneProvider ou autre) permet de faire des économies pour une qualité de service supérieure ([cf les articles de M4vr0x](/recherche/?keyword=m4vr0x)). Alors ce n’est certainement pas aussi fun [que de concevoir](/2014/03/09/construction-dun-helmer-like-pour-mon-infra-perso-part-1-le-design/) et [monter son propre meuble « rack » et y visser une carte mère dedans](/2014/03/10/construction-dun-helmer-like-pour-mon-infra-perso-part-3-lassemblage-et-lamenagement-interieur/) mais c’est probablement aussi plus rationnel.

![](/2014/03/meuble_v3-1.png)

N’ayant plus que le « serveur NAS » dans mon Red Helmer maison, j’ai donc décidé d’aller au bout de la démarche et d’abandonner mon Xubuntu customisé pour acquérir un QNAP TS431 P2.

![](/2018/01/qnap24.jpg)

> Migration en cours

## Synology ou QNAP, un choix de société ? Vous avez 4 heures !

Je vais esquiver (ou au moins tenter d’esquiver) un flame war Synology versus QNAP et simplement lister mes besoins. Je veux remplacer un NAS existant à base d’OS Linux disposant des caractéristiques et fonctionnalités suivantes :

  * Matériel : 
      * [Intel Pentium (dual core 3GHz)][7]
      * [8 Go de RAM][8]
      * ~6 To via 3x 3To de [HDD Western Digital Red][9] en grappe RAID 5 via **mdadm**
    . Le but est de réutiliser ces disques.
    
      * **4 baies 3,5&Prime; minimum** (cf ligne précédente)
  * Performances : 
      * Je souhaite disposer d’un NAS capable **_a minima_ de saturer le port gigabit Ethernet** (>100 Mo/seconde en lecture ou écriture séquentielle) **sans perte de performance** sur les autres services
  * Fonctionnalités : 
      * Partages NFS, CIFS, iSCSI 
          * Serveur SFTP, Plex et _Deluge centralisant les téléchargement démarrés depuis tous les PC du foyer_
      * Accès SSH en admin (pour hébergement de petits services complémentaires comme des scripts de supervision, [mise à jour de DynHost OVH](/2014/09/22/mise-a-jour-de-votre-dns-chez-ovh-avec-dynhost/), ...)
  * Prix : 
      * Le moins cher possible une fois que les critères de performances et fonctionnalités sont respectés

Si on met de côté le serveur Deluge qui est un besoin un peu exotique, les fonctionnalités nécessaires sont relativement basiques. Ce n’est donc pas réellement un critère de choix.

## Shortlister du matériel

Je me suis néanmoins limité à Synology et QNAP (les deux leaders) pour m’assurer un meilleur support et une meilleure assurance d’avoir de nouvelles fonctionnalités dans les années à venir car leurs OS sont régulièrement mis à jour.

J’ai donc épluché les références sur le site des deux marques ([Synology][11] et [QNAP][12]) et voilà les modèles qui ont retenus mon attention :

  * QNAP TS431P2 (Home - Middle range)
  * QNAP TS451* (Home - High end)
  * Synology DiskStation DS418j (Home - Middle range)
  * Synology DiskStation DS418 (Home - Middle range)

Clairement, le TS451 (et ses déclinaisons) est overkill. Outre la sortie HDMI dont je n’ai que faire (le NAS est dans le dressing, loiiiin de la TV), le TS451 dispose d’un Celeron, capable sur le papier de faire tourner des VMs. L’argument est intéressant mais je ne pense pas en avoir l’utilité à la maison, toutes mes VMs ayant été transportées sur les serveurs chez Kimsufi.

La vraie « battle » s’est donc faite entre le TS431P2 et les deux Synology DS418 et sa version « j ».

## Comparer des oranges et des bananes

Voici un petit tableau comparatif des trois NAS :

![](/2018/01/qnap25-1.png)

### La RAM

Il y a clairement 2 philosophies. Synology se vante d’avoir doublé la capacité de la RAM de ces modèles de 2018 (2G/1G) par rapport à ceux de 2016 (1G/512M). En même temps on partait de tellement loin ! Chez QNAP, si les modèles d’entrée de gamme sont aussi en 1Go, on hésite pas à proposer des modèles avec 2, 4, voire 8 Go, et à indiquer que tous les modèles sont upgradables. Dans l’optique d’héberger de futurs services supplémentaires à la maison, c’est rassurant, mon TS431P2 ne manquera pas de RAM.

### Performance brute

A première vue, les 3 NAS disposent de processeurs ARM récents et se valent.

Pourquoi je parle de CPU ? Au delà de la vitesse des disques qui est indépendante du NAS choisi, et de la vitesse des ports Gigabit (bridée... à 1 Gbit ! surprise !), c’est le CPU le facteur limitant sur la plupart des NAS sur le marché.

Or dans le cas présent, les 3 saturent les ports Ethernet en lecture ou écriture séquentielles (le DS418j n’a qu’un port Ethernet, d’où les débits 2x inférieurs).

C’était une vraie inquiétude pour moi car les premiers Synology que j’avais pu manipuler il y a quelques années étaient plombés par des ARM sous dimensionnés induisant des plateaux à 40-50 Mo/s et bloquant toutes les autres opérations (CPU à 100%). C’était la raison pour laquelle j’ai monté plusieurs [« NAS maisons » depuis 2011](/2011/06/29/nasmediacenter-do-it-yourself-or-not/), avec des performances bien plus importantes à tarif égal.

### Comparer les ARM entre eux

A ma connaissance, il n’existe pas de base de données en ligne de benchmark sur les différents CPU ARM ([comme on peut trouver pour Intel et AMD par exemple][15]), donc pas de possibilité de comparer comme cela.

Cependant, en fouillant un peu plus, j’ai pu me rendre compte que l’Alpine AL-314 semble surclasser très (très) largement les deux autres. En épluchant la fiche technique du TS431**X**2 (un NAS QNAP entrée de gamme pour PME avec un port... 10GbE fibre !) qui a le même processeur, on découvre des performances maximales théoriques de 1014 Mo/s en lecture et 580 Mo/s en écriture ! On sature même le 10GbE en lecture...

Cet avantage se confirme sur les transferts chiffrés. Le DS418 ne sature plus qu’un seul port Ethernet et le DS418j tombe même bien en dessous des 100Mo/s en écriture.

Parallèlement, le TS431P2 garde un débit assez proche de la saturation de ses deux ports Ethernet. Autant dire qu’avec ce processeur, le NAS s’ennuie quand on transfère à 100 Mo/s (ce que j’ai pu vérifier IRL).

Il n’y a donc aucune contrindication à héberger des services supplémentaires et les gros transferts n’ont aucun impact sur les performances globales du NAS (si ce n’est congestionner le réseau).

## Killer features (containers et snapshots)

Déjà, côté matoss, le QNAP est donc devant.

Côté fonctionnalités, si DSM (OS des Synology) [possède beaucoup plus de paquets/applications][16] que QTS (OS des QNAP), les DS418(j) _ne sont pas compatibles avec l’application **Docker**_ alors que le TS431P2 (et tous les autres QNAP) propose une application officielle pour gérer les containers **_LXC_** ET **_Docker_**.

![](/2018/01/qnap23.png)

> Container Station

Dans l’optique de remonter mon serveur Deluge sur le NAS (et d’autres services par la suite), c’est donc un autre point positif pour QNAP.

Deux derniers point mis en avant par QNAP, la possibilité de gérer **sur tous les modèles de la gamme** des snapshots de tous les volumes avec la dernière version (QTS 4.3.4), ce qui n’est pas possible sur les DS418(j), ainsi qu’une application pour gérer des devices de type IoT.

## User friendly versus bidouilleur

Clairement, le positionnement de Synology est de proposer des boitiers _suffisants_ pour la plupart des utilisateur, _un peu_ moins customisables et performants mais aussi _un peu_ plus simple d’utilisation. C’est pour ça que, pour tout autre personne que moi (ou un geek sysadmin), je conseille les Synology.

J’insiste : les différences sont vraiment infimes car QNAP est aussi très user friendly. L’interface est très fluide et très intuitive, mais on a clairement plus la main (pas encore autant que je voudrais :-p) et un néophyte serait probablement plus à l’aise sur un Synology.

![](/2018/01/qnap13-1.png)

> Le « bureau » de QNAP

![](/2018/01/qnap26.png)

> Administration et Filestation

Mais le fait que le CPU soit bien plus costaud côté sur les QNAP et qu’on ait la possibilité d’augmenter la RAM sont clairement des points qui plaisent aux bidouilleurs dont je fais partie.

L’ajout de fonctionnalités comme Docker/LXC, les snapshots ou le support de l’IoT sur toute la gamme aussi.

Sans trop d’hésitation, j’ai donc choisi le TS431P2. En profitant d’une promo j’ai réussi à avoir le modèle 1 Go avec une barrette de RAM 8 Go pour pratiquement le même prix que sans. Je ferai peut être un petit article sur la partie upgrade de la RAM ;-)

## Sources

  * [Liste des NAS 4 Baies Synology][11]
  * [Performance des NAS 4 Baies Synology][20]
  * [Liste des NAS 4 Baies QNAP][12]
  * [Performance des NAS 4 Baies QNAP][21]
  * [Plugins Nagios et compatibles pour superviser un QNAP][22]

 [7]: https://www.amazon.fr/gp/product/B015VPX05A/ref=as_li_tl?ie=UTF8&camp=1642&creative=6746&creativeASIN=B015VPX05A&linkCode=as2&tag=zwindsrefle-21&linkId=075f115800c86d9c88cd85db55f2f28a
 [8]: https://www.amazon.fr/gp/product/B0089JIDLC/ref=as_li_tl?ie=UTF8&camp=1642&creative=6746&creativeASIN=B0089JIDLC&linkCode=as2&tag=zwindsrefle-21&linkId=0a7d5dcc2f1502ccb97bf9da4ec7a0b4
 [9]: https://www.amazon.fr/gp/product/B00EHBERSE/ref=as_li_tl?ie=UTF8&camp=1642&creative=6746&creativeASIN=B00EHBERSE&linkCode=as2&tag=zwindsrefle-21&linkId=93fe7aceebe269e31d1a928e4735e5b3
 [11]: https://www.synology.com/fr-fr/products?bays=4
 [12]: https://www.qnap.com/fr-fr/product/?conditions=0-4
 [15]: https://www.cpubenchmark.net/
 [16]: https://www.synology.com/fr-fr/dsm/packages
 [20]: https://www.synology.com/fr-fr/products/performance#4bay
 [21]: https://www.qnap.com/en/product_x_performance/group.php?goal_csn=8
 [22]: https://exchange.nagios.org/directory/Plugins/Network-Connections%2C-Stats-and-Bandwidth/Check-QNAP-Disk/details
