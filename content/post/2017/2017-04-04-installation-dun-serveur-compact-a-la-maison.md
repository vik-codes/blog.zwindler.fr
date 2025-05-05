---
title: 'Choix d’un serveur compact pour la maison'
authors:
  - zwindler
type: post
date: 2017-04-04T12:00:45+00:00
url: /2017/04/04/installation-dun-serveur-compact-a-la-maison/
image: /2017/04/monter_serveur_perso.jpg
categories:
  - autohebergement
  - Matériel
tags:
  - debian
  - DIY
  - Do it yourself
  - ESX(i)
  - Hardware
  - HCL
  - MicroServer
  - Proliant
  - Proxmox
  - Serveur
  - WAF
  - Whitebox

---
## Monter des serveurs à la maison est une de mes passions

Dès 2010, à la création de ce blog, je me suis monté un NAS maison à partir de hardware de récupération ainsi que mon propre serveur ESXi : une « whitebox » comme on dit dans le milieu. Il fallait trouver du matériel compatible à l’époque ; [vm-help tenait à jour une liste maintenue par la communauté du matériel compatible][1]. Depuis, j’ai aussi conçu puis construit moi même un meuble, en m’inspirant de [Red Helmer](/recherche/?keyword=helmer
), pour héberger dans mon dressing la dernière version de mon serveur personnel ainsi que de mon NAS.

Bref, vous l’aurez compris, le hardware, ça m’éclate ! Alors, lorsqu’un proche m’a demandé de lui donner un coup de main pour lui concevoir son serveur personnel, j’ai bien entendu sauté sur l’occasion.

## Le besoin

La personne en question avait besoin de se monter un serveur compact (et donc silencieux) pour bidouiller un peu.

> Je pense acheter un serveur pour la maison pour m’amuser un peu avec Linux, yunohost, docker, samba... Et comme l’expert c’est toi, je me demande si tu as des suggestions.

Une alternative aurait pu être simplement de commander en fonction du besoin des petites instances éphémères dans le cloud type AWS, mais :

  1. c’est finalement vite coûteux en dehors de besoins ponctuels (par rapport à une machine à la maison)
  2. on perd la main sur la partie baremetal (à moins de commander un serveur entier bien entendu, ce qui n’était pas le but)

De plus, la personne en question souhaitait également en profiter pour stocker des vidéos et pourquoi mais monter un serveur vidéo de type Plex directement sur le LAN.

## La conception

Sachant que mon invité mystère n’est pas dans l’administration système, j’ai commencé par lui conseiller le plus simple. Depuis quelques années, HP fait un excellent serveur compact, plutôt « beau » (pratique pour le faire accepter par la petite famille, aussi connu comme WAF) et bien conçu.

_Le ProLiant G7 et la dernière version en date, le G8_

![](/2017/04/hp-proliant-microserver-g7-n54l.jpg)
[Microsvr Gen8 G1610t](https://www.amazon.fr/gp/product/B013UBCHVU)

Personnellement, je trouve que ce produit est un très bon produit, qui est même _un peu_ modulable en plus d’être fiable.  Cependant, pour les besoins du projet, il était nécessaire d’ajouter plus de 4 disques (c’était théoriquement possible sur le G7), et changer quelque uns des composants figés du Proliant... J’ai donc proposé la conception d’une plateforme « maison », depuis 0.

[Edit]<b class="fn">[Strik-Strak](https://www.strak.ch)</b> de Strak.ch a écrit un article similaire au mien, même si nous avons quelques divergences sur une partie des composants. C’est pour la bonne et simple raison que la personne qui m’a demandé un coup de main s’en est servi comme base de départ. [Je vous invite à jeter un œil à son article][5] si vous voulez un 2ème avis[/Edit]

### La liste de courses

Voilà ce que nous avons retenus comme composants au final :

  * **Boitier** : [Node 304 de Fractal Design, au format mini-ITX](https://www.amazon.fr/gp/product/B009PIEMUC).
  * **Carte mère** : Dans notre cas, nous avons choisi une carte mère plutôt « high-end », la Asrock E3C236D2I (lien mort). Bien que couteuse, cette carte mère à de nombreux avantages. Elle dispose de 2 ports Ethernet Gigabit + 1 port réseau séparé dédié IPMI/BMC, une console distant pour piloter son serveur comme avec un iLO ou un iDRAC. Elle est également compatible avec de la RAM ECC (attention, UDIMM seulement !!!).
  * **CPU** : Là, clairement c’était overkill mais si vous avez le budget, le [Xeon E3-1220v5](https://www.amazon.fr/gp/product/B015T3Q39E) est un quadcore de premier choix.
  * **RAM** : Si vous le pouvez, il est « conseillé » de prendre de la RAM « serveur » de type ECC. Par exemple, ce kit de 2 barrettes de [2x16Go Crucial](https://www.amazon.fr/gp/product/B0736W5BH2). Ces barrettes de RAM disposent d’un mécanisme autocorrecteur en cas de corruption de bloc en RAM. En théorie, une erreur en RAM peut avoir des conséquences catastrophiques sur vos données. Cependant pour un lab perso, c’est probablement overkill là aussi.
  * **Carte graphique** : Attention, dans les dernières version, les processeurs Intel Xeon se distinguent en 2 catégories. Ceux qui intègrent un chipset graphique et ceux qui n’en ont pas. Dans les processeurs comme le Xeon E3-1220, il n’y en a pas mais dans le E3-1225 oui. Cependant, j’avais lu sur le forum de ProxMox (l’OS cible de notre serveur) que le chipset graphique était mal supporté. Je suis donc resté sur le 1220 sans chipset graphique, mais il faut donc ajouter une carte graphique supplémentaire. dans ce cas, n’importe quelle carte AMD ou NVidia un peu récente et peu puissante fera l’affaire. [Par exemple celle ci](https://www.amazon.fr/gp/product/B016AUXVJA) qui a l’avantage d’être « low-profile » ce qui est pratique dans notre Node 304.
* **Stockage** : Idéalement, un petit SSD pour stocker l’OS est forcément un plus (attention au TRIM à activer sous Linux). Dans notre cas, nous avions besoin de stocker pas mal de données et donc nous sommes partis sur 4x [4 To de WD Red](https://www.amazon.fr/gp/product/B00EHBERSE)! Ces disques sont conçus pour fonctionner 24h/24 7j/7 et fournissent des performances très bonnes, similaires aux disques durs performants dans les PCs de bureau. Sur mon NAS, un RAID5 logiciel de 3x3To sature le port Ethernet gigabit (>120 Mo/sec).

### Alternatives plus raisonnables

  * **Carte mère** : Si vous optez pour un modèle moins cher, gardez à l’esprit que le modèle doit être Mini-ITX si vous prenez le Node 304, et que du coup il faut faire attention au nombre de slot de RAM et au nombre de ports SATA sur ce format de carte mère. Il arrive qu’on ait des surprises si on y fait pas attention !
  * **CPU** : Dans un contexte beaucoup plus raisonnable, [Le G4560 est un très bon choix](https://www.amazon.fr/gp/product/B01N7U18M1).
  * **RAM** : un kit de type [Corsair Value Select 8G](https://www.amazon.fr/gp/product/B00SV7IILC) sera probablement suffisant pour la plupart des besoins !
  * **Stockage** : n’importe quel disque dur qui traine chez vous où même récupéré sur un ordinateur portable fera l’affaire ;-).

## L’installation

Maintenant, passons au plus FUN, le montage de l’ensemble !!!

Comme un gamin le matin de noël

![](/2017/04/20170311_091727.jpg)

Le Fractal Design Node 304 est extrêmement bien pensé quoiqu’un peu compact.

![](/2017/04/20170311_092321.jpg)

Contrairement à la plupart des boitiers classiques, l’alimentation est dans le boitier, sous les cages de disques, et pas à l’arrière. Habitué des Barebone, je peux vous dire que le gain de place est significatif !

![](/2017/04/20170311_095218.jpg)

La carte mère Asrock mini-itx

![](/2017/04/20170311_100528.jpg)

Grave erreur ! Ce kit Crucial est un kit **R**DIMM. La carte mère supporte certes la DDR4 ECC, mais **U**DIMM seulement ! Impossible de booter avec.

![](/2017/04/20170311_100617.jpg)

Mon préssssssssieux !

![](/2017/04/20170311_101622.jpg)

Lors de la conception du serveur, nous étions tombé sur un autre blog qui vantait les mérites du Noctua NH-L12 (low profile) pour le refroidissement. J’ai effectivement vu plusieurs « build » sur le net avec le Node 304 et ce ventilateur mais j’étais très sceptique. Et effectivement, lors du montage, il s’est avéré que le ventilateur ne rentrait pas lorsque les cages de disques sont présentes !! Heureusement le 1220v5 est livré avec le ventilateur stock d’Intel, qui est largement suffisant pour les workloads standard.

![](/2017/04/20170311_125106.jpg)

2ème mauvais point pour le Noctua, la backplate ne passait pas, car écrasait un composant sur la carte mère (il fallait utiliser les vis simples)

![](/2017/04/20170311_103848.jpg)

Les amateurs de « cable management » vont me tuer

![](/2017/04/20170311_124947.jpg)

Les amateurs de « cable management » vont me tuer BIS. Bon en vrai je les ai mieux attachés depuis...

![](/2017/04/20170311_125025.jpg)

Génial :D

 [1]: http://www.vm-help.com//esx40i/esx40_whitebox_HCL.php
 [5]: https://strak.ch/monter-son-serveur-de-virtualisation-partie-1-choix-du-materiel/
