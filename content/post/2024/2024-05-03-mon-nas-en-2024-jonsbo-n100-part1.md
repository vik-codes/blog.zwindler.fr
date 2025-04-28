---
title: 'Mon NAS en 2024 - Jonsbo N2 × Intel N100 - hardware'
authors:
  - zwindler
type: post
date: 2024-05-03T12:00:00+02:00
url: /2024/05/03/mon-nas-en-2024-jonsbo-n100-part1/
image: /2024/05/nas2024.jpeg
categories:
  - Autohébergement
  - Matériel
tags:
  - QNAP
  - Jonsbo
  - Jonsbo N2
  - Intel
  - N100
  - Ethernet
  - NVMe

---

Cet article fait partie d’une série dans laquelle je parle de mon nouveau NAS que j’ai construit moi-même :

* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - hardware](/2024/05/03/mon-nas-en-2024-jonsbo-n100-part1/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - software](/2024/05/19/mon-nas-en-2024-jonsbo-n100-part2/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - stress tests et conclusion](/2024/07/04/mon-nas-en-2024-jonsbo-n100-part3/)
* [Bonus - Installer plex sur TrueNAS (SCALE)](/2024/05/10/installer-plex-sur-truenas-scale/)

## Mon NAS, quatrième itération ?

Depuis 2011, je change de NAS régulièrement.

2011, c'était de la récup' ([un vieux Qbic Soltek, une carte mère avec un Atom fanless](https://blog.zwindler.fr/2011/06/29/nasmediacenter-do-it-yourself-or-not/)).

![](/2011/06/dscn1178.jpg)

2014, c'était encore plus bidouille, car j'avais juste posé une carte mère dans mon Red Helmer.

![](/2014/03/img_20140309_153018.jpg)

2018, j'en avais marre de gérer moi-même l'OS, les problèmes d'upgrades de l'OS, etc. J'étais donc passé sur un NAS du commerce ([un QNAP](https://blog.zwindler.fr/2018/01/23/stockage-pour-un-admin-geek-qnap-ts431p2-ou-synology-ds418j/)).

![](/2018/01/qnap22.jpg)

Après 6 ans de bons et pas très loyaux services ([QNAP désactive des features au fur et à mesure](https://blog.zwindler.fr/2022/06/13/qnap-debranche-lxc-workaround/)), j'ai décidé de m'en reconstruire un nouveau, moi-même.

## Les critères hardware

À force d'itérations, je commence à savoir ce que je veux / ne veux pas pour mon NAS. En voici la liste :

* quatre emplacements
* un ou plusieurs ports ethernet 2.5 Gbps
* un beau boitier, qui fasse un peu sérieux, relativement compact (pas une tour)
* pas de bruit, peu de chauffe
* une consommation électrique raisonnable
* possibilité de hotswap les disques

Ces critères sont surtout hardware, mais j'en rajoute qui est plutôt software, tout en restant lié au hard :

* la possibilité de faire des machines virtuelles (si jamais j'en ai l'envie) et des containers

## Le choix des composants

C'est l'étape la plus compliquée quand on fait un NAS DIY.

Le problème principal est de trouver un boitier qui convient. Ça fait des années que je cherche (même en 2011 / 2014) et souvent les boitiers sont rares, chers, volumineux et/ou moches. Le côté hotswap et fréquemment absent.

Heureusement, j'ai trouvé un boitier qui coche toutes les cases, même s'il est difficile à trouver en France : [le Jonsbo N2](https://www.jonsbo.com/en/products/N2Black.html). J'avais entendu parler de cette marque sur Next Inpact avec le Jonsbo N1, plus compact, mais qui n'avait pas de hotswap.

Le Jonsbo N2 corrige ce défaut. C'est grosso modo un cube de 22 cm de côté, il est plutôt beau même si un peu gros à mon goût.

![](/2024/05/jonsbon2.jpg)

![](/2024/05/jonsbon2-2.jpg)

Niveau compatibilité, on peut l'alimenter avec une PSU au format SFX et une carte mère au format Mini ITX. C'est relativement attendu, vu la compacité, mais ça nous rajoute tout un tas de problématiques complémentaires.

## Alimentation

D'abord, les alimentations SFX sont plus rares, plus chères et moins efficaces. Trouver un modèle peu puissant, économe, bon marché et semi-passif (pour le bruit) est impossible.

Le mieux que j'ai trouvé est une alimentation [Be Quiet SFX Power 3 de 300w](https://www.bequiet.com/fr/powersupply/sfx-power/763). Elle n'est pas semi-passive (donc fait continuellement du bruit, même si c'est raisonnable) et seulement 80Plus Bronze (donc il y a des pertes significatives d'énergie). En alternative, j'aurais pu prendre (à vérifier, la taille n'est pas claire) les SFX-L de Be Quiet, qui ont l'avantage d'être 80 Plus Gold et modulaires.

## Carte mère

Ensuite, les cartes mères mini-ITX ont souvent peu de ports SATA, ce qui ne colle pas avec mon besoin de quatre disques. À partir de là, il y a 3 solutions, aucune n'étant vraiment "ouf".

La plupart des cartes Mini ITX ont 2 (voire 1) ports SATA, mais certaines ont aussi des ports M.2 pour NVMe et/ou un port PCIe :
* Il existe des adaptateurs 1 NVMe => 6 SATA
* Il existe des cartes d'extension PCIe => SATA

![](/2024/05/nvme6sata.jpg)

Mais je n'ai absolument pas confiance dans la qualité de ces machins, donc j'ai abandonné l'idée. D'autant que j'aurais peut-être besoin du port PCI-e pour ajouter une carte d'extension pour avoir le 2.5 Gbps.

J'avais trouvé une carte avec quatre ports SATA et le support du socket AM4 (exemple [ASRock B550M-ITX/AC](https://www.ldlc.com/fiche/PB00348184.html)). Si je rajoute un Ryzen 5 5600G, je coche la case "possibilité de faire des VMs", mais c'est relativement cher (~260€ au total) et surtout le CPU consomme beaucoup d'électricité (TDP 22w).

Dernière solution, il existe aussi quelques OVNI [comme la carte ASRock Rack X570D4I-2T avec des ports OCuLink](https://www.asrockrack.com/general/productdetail.asp?Model=X570D4I-2T#Specifications) permettant de gérer 4 SATA chacun, mais c'est quasiment impossible à trouver et très cher.

En fouillant Aliexpress, je suis assez vite tombé sur ce genre de modèles de cartes "noname" :

![](/2024/05/n100-1.png)

![](/2024/05/n100-2.png)

Il existe plein de modèles et de variations du même genre de cartes. Grosso modo, c'est un chipset intel compatible Atom de différentes générations avec 4 ports Ethernet 2.5 Gbps, 6 SATA, parfois fanless, parfois non.

Sur le papier, c'est pile ce que je cherche. J'ai une carte mère et son N100 (seulement 6w de TDP) + ventirad qui coche tous mes critères. Il faut juste pas trop avoir peur du côté "carte mère noname".

J'ai pris le risque, j'ai choisi cette carte, que j'ai réussi à avoir autour de 200€ (ici 250 sur la capture d'écran).

![](/2024/05/n100-3.jpeg)

## Misc

Pour installer l'OS de mon NAS, j'ai ajouté un SSD NVMe de 500 Go (le moins cher de marque que j'ai trouvé).

J'ai aussi ajouté 16 Go de RAM DDR5, dans l'idée que j'aurais peut-être besoin de ça pour des containers / VMs.

Comme je n'ai pas encore de réseau en 2.5 Gbps chez moi, j'ai donc dû faire l'upgrade. J'ai choisi un switch "noname" sur Aliexpress (là encore), une carte PCI-e pour mon PC perso.

Pour les disques, j'ai fait l'erreur (on en reparlera) de récupérer des vieux disques Western Digital Red de 4 To que j'avais en stock...

![](/2024/05/achats1.jpeg)

![](/2024/05/achats2.jpeg)

## Montage

Le boitier est très beau, bien conçu, semble être de bonne qualité / bonne facture. La carte mère est en haut, l'alimentation se positionne sur le bas + côté et les disques de l'autre.

![](/2024/05/jonsbo-vide.jpg)

Côté carte mère, elle est livrée avec une grosse surface de contact en cuivre sur laquelle j'ai ajouté le ventirad low profile.

![](/2024/05/mobo.jpg)

![](/2024/05/ventirad.png)

Pour être parfaitement honnête, je me demande si le ventilateur est réellement nécessaire. On en reparlera dans le prochain article.

Pour pouvoir être hotswap, les disques durs sont connectés à un backplane, aéré par un ventilateur low profile (15 mm d'épaisseur) que j'ai remplacé par un 25mm (classique) car j'ai lu qu'il était bruyant. Le souci, c'est qu'il y a très peu d'espace, pas assez pour un 25mm, mais ça rentre au chausse-pied.

![](/2024/05/hotswap.png)

![](/2024/05/backplane.jpeg)

Note : il existe des plans d'impression 3D pour corriger ce problème, si nécessaire. Mais je n'en ai pas eu besoin.

## Conclusion

Une fois le montage fini, je trouve ça plutôt clean :\)

![](/2024/05/montage-fini.jpg)

![](/2024/05/nas2024.jpeg)

Dans le prochain article, on parlera des différents tests de performance que j'ai réalisés.