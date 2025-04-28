---
title: 'Whitebox ESXi : avoir ESXi chez soit sans acheter du Dell Pro'
authors:
  - zwindler
type: post
date: 2010-07-25T18:03:58+00:00
url: /2010/07/25/whitebox-esxi/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - ESX(i)
  - Netbooting
  - Syslinux
  - tftpd
  - vm-help
  - Whitebox

---
Ça y est, j’ai ma whitebox ESXi!!!

Après avoir galéré à tenter d’installer ESXi 3.5 sur un vieu barebone toussotant en spare, je me suis résolu à acheter un nouveau fixe relativement puissant/silencieux (c’est mieux pour le laisser tourner H24) pour pouvoir profiter des avantages multiples d’ESXi 4.x

Mais ça n’a pas été de tout repos...

Sans rentrer dans les détails, puisque j’y reviendrai dans de prochains articles, je me suis basé sur les aides/résultats postés sur 

[www.vm-help.com](http://www.vm-help.com) pour choisir les pièces à acheter pour me monter une bécane compatible ESXi 4 sans trop me ruiner, mais sans avoir à trop me faire suer non plus.

L’idée, c’était de partir d’un matos non supporté par VMware, mais que je savais compatible après quelques petites modifications de l’iso de chez VMware :

  * une MB Asus P7P55D (entre milieu et haut de gamme pour particuliers)
  * un I7 860 (idem)
  * 8 Go de RAM Corsair (Pas de noname!)
  * ... (le reste importe peu)

Un bon informaticien est un informaticien fainéant (dixit un de mes profs). J’ai donc d’abord commencé par utiliser un script pour Newbie qui faisait tout à ma place. Malheureusement, pour cause de bug entre le script et la version 4.1 d’ESXi, que je n’ai découvert que bien plus tard, ça n’a pas marché. Je me suis donc dis que j’y arriverai mieux seul, une fois que j’aurai intégré les différents mécanismes, plus ou moins bien expliqués sur vm-help.

J’ai donc galéré pour tenter créer des clés USB bootables (problèmes de version du syslinux?). Après plusieurs échecs, j’ai abandonné et j’ai tenté une solution de netbooting pour mon ESXi (combo xinetd/tftpd problématique, suivit par des difficultés à recréer un ESXi modifié pour supporter mon matériel). Après ce second échec, j’ai faillis m’avouer vaincu.

3 jours plus tard, les bugs du script étaient fixés, et l’installation s’est faite toute seule.

J’étais un peu défait de ne pas avoir réussi seul, mais content que ça marche :-)

Plus de détails (techniques) plus tard : It’s Japanese food time...
