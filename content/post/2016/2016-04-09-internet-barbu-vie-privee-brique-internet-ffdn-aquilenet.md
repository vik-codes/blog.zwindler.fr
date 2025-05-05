---
title: 'Internet barbu, autohébergement et vie privée : brique Internet, FFDN, Aquilenet, …'
authors:
  - zwindler
type: post
date: 2016-04-09T11:00:22+00:00
url: /2016/04/09/internet-barbu-vie-privee-brique-internet-ffdn-aquilenet/
image: /2016/04/brique.png
categories:
  - autohebergement
tags:
  - Aquilenet
  - Brique Internet
  - DNS menteur
  - FAI
  - FDN
  - FFDN
  - Loi renseignement
  - Orange
  - sécurité
  - SFR

---
Si c’est probablement vu et revu pour les plus accros à la vie privée et/ou à la sécurité informatique d’entre vous, je voudrais tout de même faire un petit article pour parler de plusieurs projets sympa, notamment les FAI associatifs et la Brique Internet.

## Fournisseur d’accès associatif ?

Si vous vous intéressez un tant soit peu comme moi d’auto-hébergement, vous êtes probablement tombé dans des cas bien casse pied où votre FAI grand public ne vous laisse pas faire ce que vous voulez sur votre ligne Internet. Le [wiki d’auto-hebergement.fr][1] que j’ai déjà cité est une réelle bible en la matière et recense les mauvais élèves qui :

  * Bloquent des ports
  * Ne fournissent pas d’adresse IPv4 fixe (nécessité de passer par des solutions de type [DynHost](/2014/09/22/mise-a-jour-de-votre-dns-chez-ovh-avec-dynhost/) ou DynDNS) et pas d’adresse IPv6 (du tout !)
  * Proposent des [routeurs aux redirection de ports erratique][3]
  * ...

En bref, tout est fait pour que vous ne sortiez pas de l’utilisation d’un utilisateur lambda, même en connaissance de cause.

Une bonne solution pour se débarrasser de toutes ces contraintes (et bien plus encore !), c’est la possibilité méconnue de vous tourner vers des FAI associatifs. Ce sont des associations déclarées comme opérateurs à l’ARCEP qui commandent des lignes aux opérateurs nationaux, montent un VPN puis gèrent votre accès à Internet depuis leurs propres infrastructures.

Le gros avantage c’est que du coup, le FAI national n’a plus la main sur les données qui transitent dans la ligne, il ne voit plus que du flux chiffré sur lequel il n’a aucun contrôle :

  * pas de bridage de [certains protocoles/sites][4] et pas de partenaires avec qui le débit serait meilleurs
  * plus de blocage de sites par [DNS menteur lien mort, j'utilise Internet Archive](https://web.archive.org/web/20190203042541/http://www.nextinpact.com/archive/52873-sfr-dns-menteur-redirection-publicite.htm)
  * pas d’exploitation/revente des données personnelles
  * pas besoin de s’arracher les cheveux pour héberger des services parce que les [redirections de ports sont horribles][3] et les IPs pas fixes (17€/mois chez Orange, ahahaha), des ports bloqués

Cela va donc bien au delà du simple confort pour l’auto-hébergement.

On pourra citer la plus ancienne de ces associations en France : [French Data Network][6], ainsi que [FFDN][7], la fédération qui regroupe les autres association, comme [Aquilenet][8] sur la région bordelaise.

## L’Internet barbu c’est sexy mais moi j’aime bien ma _totobox_ car elle a une appli « commande sushis » que je trouve très pratique

Oui, car il faut le reconnaitre, les FAI nationaux ont quand même pour eux nos box, qui fournissent beaucoup de fonctionnalités/services (triple/quadruple play) plus ou moins utiles au grand public que les routeurs classiques ne font pas _nativement_.

J’insiste sur nativement car dans le fond, vous pouvez tout faire du moment que vous avez Internet. Il faut juste bidouiller pour y arriver, ce qui n’est pas nécessairement à la portée de tout le monde.

Dans ce cas là, vous pouviez jusqu’à présent profiter avec certains FAI associatif de VPN qui vous permettait de faire la même chose mais sur une ligne classique avec une box. C’est notamment vrai pour [Aquilenet][9] (pour ne pas les citer une seconde fois). La encore, ce n’est pas forcément hyper accessible pour des non informaticiens car il faut alors paramétrer les PC/terminaux mobiles pour tirer parti du VPN.

Cependant, depuis quelque temps, un nouveau projet à vu le jour : **la Brique Internet**.

![](/2016/04/brique2.png)

Le principe est archi-simple. Votre FAI associatif vous met à disposition une boite de la taille d’un Raspberry Pi (attention je ne suis pas en train de dire que c’est un raspberry, je n’en suis pas sûr. Je donne juste la taille) que vous branchez en RJ45 sur votre Box. A partir de là, la brique Internet s’interpose entre vous et votre box que vous avez toujours à côté (vous vous connectez sur le wifi de la brique). Tout le trafic de vos devices sort sur le VPN de l’association au lieu de sortir directement sur Internet.

Ainsi, l’accès Internet est aussi respectueux de votre vie privée que ne le serait un lien fournit par une association membre de FFDN, de manière très simple et sans la contrainte d’abandonner les services triple play des FAI classiques (télévision, téléphone fixe).

La brique peut également être déplacée sur n’importe quel autre accès Internet (ou si vous déménagez, ou si vous changez de FAI), sans avoir besoin de reconfigurer quoique ce soit. Les PCs sont toujours connectés à l’accès point de la brique, peu importe où elle est connectée.

## Bonus : auto-hébergement for dummies

Deuxième gros point positif, la brique Internet, via [YunoHost][10], permet de base d’héberger de manière très simple vos propres services comme les emails (attention aux filtres à spam sur les gmail et consor cela dit), des blogs wordpress, du partage de fichiers...

![](/2016/04/y-u-no-guy.jpg)

Cela permet donc à n’importe qui de se lancer dans l’auto-hébergement, sans avoir nécessairement toutes les connaissances informatiques jusqu’à présent obligatoires. \o/

## En savoir plus

Si vous voulez plus d’information, le site est très bien fait et il y a notamment une vidéo qui résume bien tout ce que je viens de dire :

  * [Site de la Brique Internet][11]

 [1]: http://wiki.auto-hebergement.fr/
 [3]: http://communaute.orange.fr/t5/ma-connexion/SSH-impossible-en-NAT-sur-livebox-play/td-p/359843
 [4]: http://www.journaldugeek.com/2015/03/11/marie-a-google-les-problemes-de-youtube-avec-free-sont-de-lhistoire-ancienne/
 [6]: http://www.fdn.fr/
 [7]: https://www.ffdn.org/
 [8]: http://www.aquilenet.fr/content/foire-aux-questions
 [9]: http://www.aquilenet.fr/content/vpn
 [10]: https://yunohost.org/#/
 [11]: https://labriqueinter.net/
