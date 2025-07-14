---
title: 'Mon NAS en 2024 - Jonsbo N2 × Intel N100 - hardware'
authors:
  - zwindler
type: post
date: 2024-05-03T12:00:00+02:00
description: "Guide complet pour construire un NAS DIY avec un boîtier Jonsbo N2 et processeur Intel N100. Choix des composants et montage détaillé."
excerpt: "Retour d'expérience sur la construction d'un NAS maison avec le boîtier Jonsbo N2 et un processeur Intel N100 : choix des composants, montage et conseils pratiques."
url: /2024/05/03/mon-nas-en-2024-jonsbo-n100-part1/
image: /2024/05/nas2024.jpeg
categories:
  - autohebergement
  - materiel
tags:
  - QNAP
  - Jonsbo
  - Jonsbo N2
  - Intel
  - N100
  - Ethernet
  - NVMe
  - NAS
  - DIY
  - stockage

---

Cet article fait partie d’une série dans laquelle je parle de mon nouveau NAS que j’ai construit moi-même :

* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - hardware](/2024/05/03/mon-nas-en-2024-jonsbo-n100-part1/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - software](/2024/05/19/mon-nas-en-2024-jonsbo-n100-part2/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - stress tests et conclusion](/2024/07/04/mon-nas-en-2024-jonsbo-n100-part3/)
* [Bonus - Installer plex sur TrueNAS (SCALE)](/2024/05/10/installer-plex-sur-truenas-scale/)

## Mon NAS, quatrième itération ?

Depuis 2011, je change de NAS régulièrement.

2011, c'était de la récup' ([un vieux Qbic Soltek, une carte mère avec un Atom fanless](https://blog.zwindler.fr/2011/06/29/nasmediacenter-do-it-yourself-or-not/)).

![NAS 2011 avec boîtier Qbic Soltek et carte mère Atom fanless](/2011/06/dscn1178.jpg)

2014, c'était encore plus bidouille, car j'avais juste posé une carte mère dans mon Red Helmer.

![NAS 2014 avec carte mère posée dans un meuble inspiré de Red Helmer](/2014/03/img_20140309_153018.jpg)

2018, j'en avais marre de gérer moi-même l'OS, les problèmes d'upgrades de l'OS, etc. J'étais donc passé sur un NAS du commerce ([un QNAP](https://blog.zwindler.fr/2018/01/23/stockage-pour-un-admin-geek-qnap-ts431p2-ou-synology-ds418j/)).

![NAS QNAP TS-431P2 acheté en 2018](/2018/01/qnap22.jpg)

Après 6 ans de bons et pas très loyaux services ([QNAP désactive des features au fur et à mesure](https://blog.zwindler.fr/2022/06/13/qnap-debranche-lxc-workaround/)), j'ai décidé de m'en reconstruire un nouveau, moi-même.

### Pourquoi construire son propre NAS en 2024 ?

Construire son propre NAS présente plusieurs avantages par rapport aux solutions commerciales :

- **Contrôle total** sur le matériel et le logiciel
- **Rapport performance/prix** souvent meilleur
- **Évolutivité** : possibilité d'upgrader facilement
- **Pas de vendor lock-in** : liberté de changer d'OS
- **Apprentissage** : comprendre le fonctionnement interne

Cependant, cela demande du temps, des connaissances techniques et implique de gérer soi-même la maintenance.

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

Le problème principal est de trouver un boitier qui convient. Ça fait des années que je cherche (même en 2011 / 2014) et souvent les boitiers sont rares, chers, volumineux et/ou moches. Le côté hotswap est fréquemment absent.

Heureusement, j'ai trouvé un boitier qui coche toutes les cases, même s'il est difficile à trouver en France : [le Jonsbo N2](https://www.jonsbo.com/en/products/N2Black.html). J'avais entendu parler de cette marque sur Next Inpact avec le Jonsbo N1, plus compact, mais qui n'avait pas de hotswap.

Le Jonsbo N2 corrige ce défaut. C'est grosso modo un cube de 22 cm de côté, il est plutôt beau même si un peu gros à mon goût.

![Boîtier Jonsbo N2 vue de face avec ses 4 emplacements de disques](/2024/05/jonsbon2.jpg)

![Boîtier Jonsbo N2 vue d'angle montrant sa forme cubique](/2024/05/jonsbon2-2.jpg)

Niveau compatibilité, on peut l'alimenter avec une PSU au format SFX et une carte mère au format Mini ITX. C'est relativement attendu, vu la compacité, mais ça nous rajoute tout un tas de problématiques complémentaires.

### Budget et coût total du projet

Avant de détailler chaque composant, voici un aperçu du budget total :

- **Boîtier Jonsbo N2** : ~120€
- **Carte mère Intel N100 avec ports 2.5GbE et de nombreux SATA** : ~200€
- **Alimentation SFX 300W** : ~80€
- **RAM DDR5 16Go** : ~60€
- **SSD NVMe 500Go** : ~40€
- **Switch 2.5 Gbps + carte réseau** : ~80€

**Total** : environ 580€ (hors disques de stockage)

## Alimentation SFX

D'abord, les alimentations SFX sont plus rares, plus chères et moins efficaces. Trouver un modèle peu puissant, économe, bon marché et semi-passif (pour le bruit) est impossible.

Le mieux que j'ai trouvé est une alimentation [Be Quiet SFX Power 3 de 300w](https://www.bequiet.com/fr/powersupply/sfx-power/763). Elle n'est pas semi-passive (donc fait continuellement du bruit, même si c'est raisonnable) et seulement 80Plus Bronze (donc il y a des pertes significatives d'énergie). En alternative, j'aurais pu prendre (à vérifier, la taille n'est pas claire) les SFX-L de Be Quiet, qui ont l'avantage d'être 80 Plus Gold et modulaires.

### Conseils pour choisir son alimentation SFX

Pour un NAS, les critères importants sont :
- **Efficacité énergétique** (80 Plus Gold ou l'équivalent avec les [nouvelles normes cybenetics](https://www.cybenetics.com/index.php?option=power-supplies))
- **Niveau sonore** (ventilateur semi-passif idéal)
- **Puissance adaptée** (300W largement suffisant pour ce type de build)
- **Câbles modulaires** pour faciliter le câblage dans l'espace restreint du JONSBO

## Carte mère Intel N100

Ensuite, les cartes mères mini-ITX ont souvent peu de ports SATA, ce qui ne colle pas avec mon besoin de quatre disques. À partir de là, il y a 3 solutions, aucune n'étant vraiment "ouf".

La plupart des cartes Mini ITX ont 2 (voire 1) ports SATA, mais certaines ont aussi des ports M.2 pour NVMe et/ou un port PCIe :
* Il existe des adaptateurs 1 NVMe => 6 SATA
* Il existe des cartes d'extension PCIe => SATA

![Adaptateur NVMe vers 6 ports SATA pour étendre les capacités de stockage](/2024/05/nvme6sata.jpg)

Mais je n'ai absolument pas confiance dans la qualité de ces machins, donc j'ai abandonné l'idée. D'autant que j'aurais peut-être besoin du port PCI-e pour ajouter une carte d'extension pour avoir le 2.5 Gbps.

J'avais trouvé une carte avec quatre ports SATA et le support du socket AM4 (exemple [ASRock B550M-ITX/AC](https://www.ldlc.com/fiche/PB00348184.html)). Si je rajoute un Ryzen 5 5600G, je coche la case "possibilité de faire des VMs", mais c'est relativement cher (~260€ au total) et surtout le CPU consomme beaucoup d'électricité (TDP 22w).

Dernière solution, il existe aussi quelques OVNI [comme la carte ASRock Rack X570D4I-2T avec des ports OCuLink](https://www.asrockrack.com/general/productdetail.asp?Model=X570D4I-2T#Specifications) permettant de gérer 4 SATA chacun, mais c'est quasiment impossible à trouver et très cher.

En fouillant AliExpress, je suis assez vite tombé sur ce genre de modèles de cartes "noname" :

![Carte mère Intel N100 avec 4 ports Ethernet 2.5 Gbps - vue 1](/2024/05/n100-1.png)

![Carte mère Intel N100 avec 6 ports SATA - vue 2](/2024/05/n100-2.png)

Il existe plein de modèles et de variations du même genre de cartes. Grosso modo, c'est un chipset Intel compatible Atom de différentes générations avec 4 ports Ethernet 2.5 Gbps, 6 SATA, parfois fanless, parfois non.

Sur le papier, c'est pile ce que je cherche. J'ai une carte mère et son N100 (seulement 6w de TDP) + ventirad qui coche tous mes critères. Il faut juste ne pas trop avoir peur du côté "carte mère noname".

### Pourquoi choisir l'Intel N100 ?

Le processeur Intel N100 présente de nombreux avantages pour un NAS :

- **Très faible consommation** : TDP de seulement 6W
- **Performance suffisante** : 4 cœurs jusqu'à 3.4 GHz
- **Support hardware** : décodage vidéo H.264/H.265, VT-x et VT-d pour la virtualisation
- **Connectivité moderne** : DDR5, PCIe 4.0
- **Prix abordable** : rapport performance/prix excellent

J'ai pris le risque, j'ai choisi cette carte, que j'ai réussi à avoir autour de 200€ (ici 250 sur la capture d'écran).

![Carte mère Intel N100 choisie pour le projet NAS](/2024/05/n100-3.jpeg)

## Composants complémentaires

Pour installer l'OS de mon NAS, j'ai ajouté un SSD NVMe de 500 Go (le moins cher de marque que j'ai trouvé).

J'ai aussi ajouté 16 Go de RAM DDR5, dans l'idée que j'aurais peut-être besoin de ça pour des containers / VMs.

Comme je n'ai pas encore de réseau en 2.5 Gbps chez moi, j'ai donc dû faire l'upgrade. J'ai choisi un switch "noname" sur AliExpress (là encore), une carte PCIe pour mon PC perso.

Pour les disques, j'ai fait l'erreur (on en reparlera) de récupérer des vieux disques Western Digital Red de 4 To que j'avais en stock...

### Liste des achats complémentaires

![Récapitulatif des achats pour le projet NAS - partie 1](/2024/05/achats1.jpeg)

![Récapitulatif des achats pour le projet NAS - partie 2](/2024/05/achats2.jpeg)

## Montage

Le boîtier est très beau, bien conçu, semble être de bonne qualité / bonne facture. La carte mère est en haut, l'alimentation se positionne sur le bas + côté et les disques de l'autre.

![Boîtier Jonsbo N2 ouvert montrant l'agencement interne](/2024/05/jonsbo-vide.jpg)

Côté carte mère, elle est livrée avec une grosse surface de contact en cuivre sur laquelle j'ai ajouté le ventirad low profile.

![Carte mère Intel N100 installée avec sa surface de refroidissement en cuivre](/2024/05/mobo.jpg)

![Ventirad low profile installé sur le processeur Intel N100](/2024/05/ventirad.png)

Pour être parfaitement honnête, je me demande si le ventilateur est réellement nécessaire. On en reparlera dans le prochain article.

### Installation du système de refroidissement

Le système de refroidissement du NAS est conçu pour être silencieux tout en restant efficace :

- le N100 devrait être simple à refroidir du fait de son faible TDP
- la ventilation des disques est assurée par le ventilateur à l'arrière

Pour pouvoir être hotswap, les disques durs sont connectés à un backplane, aéré par un ventilateur low profile (15 mm d'épaisseur) que j'ai remplacé par un 25mm (classique) car j'ai lu qu'il était bruyant. Le souci, c'est qu'il y a très peu d'espace, pas assez pour un 25mm, mais ça rentre au chausse-pied.

![Système hotswap avec connecteurs pour les disques durs](/2024/05/hotswap.png)

![Backplane du Jonsbo N2 avec ventilateur de refroidissement](/2024/05/backplane.jpeg)

Note : il existe des plans d'impression 3D pour corriger ce problème, si nécessaire. Mais je n'en ai pas eu besoin.

## Conclusion

Une fois le montage fini, je trouve ça plutôt clean :)

![NAS terminé - vue de face avec tous les composants installés](/2024/05/montage-fini.jpg)

![NAS Jonsbo N2 avec Intel N100 - résultat final 2024](/2024/05/nas2024.jpeg)

## Bilan de cette première partie

Cette première étape du projet NAS 2024 s'achève sur un bilan globalement positif :

- **Boîtier Jonsbo N2** : excellent compromis design/fonctionnalité
- **Intel N100** : performance/consommation remarquable
- **Assemblage** : relativement simple malgré l'espace restreint
- **Budget maîtrisé** : ~580€ pour une base solide

Quelques points d'attention tout de même : 
- la carte mère "noname" est un véritable pari
- la compacité pourrait rendre l'ensemble difficile à refroidir (en tout cas silencieusement)

Dans le prochain article, on parlera des différents tests de performance que j'ai réalisés et du choix du système d'exploitation.