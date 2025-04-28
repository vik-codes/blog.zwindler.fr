---
title: Android Auto sur R-LINK 1 - Chérie, j'ai briqué la voiture...
authors:
  - zwindler
type: post
date: 2022-04-08T16:00:00+00:00
url: 2022/04/08/androidauto-rlink1-cherie-jai-brique-la-voiture
image: /2022/04/androidauto_ok.jpg
categories:
  - DIY
tags:
  - renault
  - android auto
  - rlink
  - OBDII
  - USB
  - hack

---

## Chérie, j'ai briqué la voiture

Qui n'a jamais eu envie de casser sa voiture en allant trifouiller dans les paramètres de l'ordinateur de bord ? Probablement personne, en fait...

Mais rassurez-vous, j'ai mis le titre pour la ref à "[chérie, j'ai rétréci les gosses](https://fr.wikipedia.org/wiki/Ch%C3%A9rie,_j%27ai_r%C3%A9tr%C3%A9ci_les_gosses)", film de mon enfance. *Aucun véhicule motorisé n'a été blessé lors de la réalisation de cet article*.

**Note de service : je vous conseille de NE PAS reproduire ça et je vous enverrai paitre si vous m'accusez d'avoir cassé votre RLINK suite à une mauvaise manipulation.**

D'abord un peu de contexte. Mon véhicule principal (même si je ne l'utilise pratiquement plus), date de 2014. A l'époque, Renault équipait ses nouveaux véhicules d'une tablette Android depuis 2012, modifiée avec une interface maison qu'ils appellent le RLINK (version 1 à l'époque), en partenariat avec Tomtom.

Cette tablette est une vraie m***e. Buguée (l'autoradio se bloque même moteur coupé/voiture verrouillée, son à fond... sympa pour la batterie), compatible avec à peu près aucune application (encore moins qui seraient utiles), cartographie payante (très chère), en retard de près de plus de 6 mois au moment où vous l'achetez et plus compatible avec la carte SD initiale car trop grande...

![](/2022/04/europe.png)

> 90€ pour une carte pas à jour, que je peux pas faire rentrer sur ma SD sur un système de navigation bugué : l'affaire du siècle !

## Android Auto à la rescousse

A peu près au même moment, Google a annoncé en 2014-2015 la sortie du système Android Auto : vous connectez votre smartphone en USB à une tablette Android compatible, et hop, c'est les applications de votre smartphone que vous retrouvez à l'écran.

Waze, Deezer, etc. Tout ce dont j'ai besoin pour de longs trajets !

Sauf que la spec pour sélectionner les appareils compatibles avec le système Android Auto est sortie vraisemblablement un peu trop tard pour que Renault puisse rendre le système RLINK certifié compatible par Google...

## Qu'à cela ne tienne

Alors, si encore c'était vraiment pas conçu pour et qu'on ne pouvait pas du tout l'avoir pour de bonnes raisons techniques, j'en aurais fait mon deuil et j'aurais payé des cartographies comme tous les autres automobilistes captifs de leur constructeur...

Sauf qu'assez vite, je suis tombé sur des posts de gens qui avaient réussi à "activer" Waze sur leur RLINK-1.

Et je dis bien "activer". Car la fonctionnalité est intégrée à la tablette, il y a "juste" un booléen à passer à true pour que ça fonctionne... de quoi piquer ma curiosité.

Bon... en vrai, il a fallu que je m'y reprenne plusieurs fois avant de réussir à le faire marcher, car il y a pas mal d'étapes et d'embûches. Il existe depuis 2018 un tutoriel pour y parvenir, disponible sur le site [gps-carminat.com](http://www.gps-carminat.com/v3/r-link/activer-android-auto-waze-sur-r-link-1/). 

Le but de cet article n'est pas de faire une redite des informations présentes sur ce site. Mais comme souvent, les tutos qu'on trouve sur le net ne sont pas toujours hypers clairs, pas toujours très jours, omettent des choses... Et je sais pas vous mais je trouve quand même marrant (et dangereux) de toucher au soft de sa voiture donc je vous propose de vous montrer ce que j'ai fait pour arriver à mes fins.

## MyRenault ou les limbes d'un logiciel à l'abandon

Le premier prérequis avant de commencer à imaginer débloquer Android Auto sur un RLINK est d'abord de le mettre à jour (>11.343). Et c'est presque le plus difficile aujourd'hui, tant ce système est abandonné depuis des années par Renault...

Liens cassés, navigation pétée quelque-soit le navigateur, UI de l'enfer avec des liens cachés qui envoient vers des liens de liens... Ca a l'air réparé aujourd'hui, mais ça n'a pas marché  pendant plusieurs mois, me renvoyant systématiquement des erreurs

> https://www.renault.fr/?error=9

![](/2022/04/rlink.appli.png)

En théorie, il faut se rendre sur [myr.renault.fr, puis ouvrir le r-link-store](https://myr.renault.fr/r-link-store.html) une fois qu'on a sélectionné son véhicule.

![](/2022/04/comment_procéder.png)

Là, on peut télécharger le RLINK Toolbox (un soft qui ne marche que sous Windows et MacOS) et suivre les instructions pour mettre à jour la tablette (via la carde SD que vous aurez probablement récupéré dans la voiture).

* [fr.rlinkstore.com/installation](https://fr.rlinkstore.com/installation)

Le processus de mise à jour est pénible de mémoire mais ça fonctionne la plupart du temps (c'est juste très long et il faut un lecteur de carte SD). Une fois à jour, votre RLINK devrait ressembler à ça (ici j'ai la 11.346)

![](/2022/04/rlink_up_to_date.jpg)

## Matériel

Pour hacker une voiture, il ne faut pas seulement du logiciel. Il va nous falloir du matériel et on va devoir mettre les mains dans le cambouis.

Normalement, pour accéder à l'ordinateur de bord de la voiture, il existe une interface universelle appelée [OBD-II](https://fr.wikipedia.org/wiki/Diagnostic_embarqu%C3%A9_(automobile)). Vous connaissez surement ça sans le savoir, c'est ni plus ni moins que le port que votre garagiste branche quand "il branche la valise", qui est un PC+écran et une interface OBD-2.

Pendant longtemps, ce système était couteux et réservé aux pros car cher. Cependant, il existe maintenant depuis des années de boitiers USB, WIFI ou bluetooth qui permettent de faire l'interface avec la voiture. N'importe quel ordinateur devient donc une "valise de garagiste", pour environ 20€.

J'ai pris comme conseillé dans le tuto une sonde ELM (celle en WIFI, car l'USB n'était plus dispo) et une rallonge OBD.

![](/2022/04/20210217_155052.jpg)

Note : pas de bol pour moi, la sonde WIFI n'a jamais marché et j'ai abandonné pendant plusieurs mois alors qu'il fallait juste en prendre une autre... J'ai insisté récemment, en en prenant une autre, en USB, pas spécialement conseillée mais qui a très bien fonctionné.

Comme chez Renault ce sont de petits blagueurs, on va aussi devoir modifier le cablâge de notre sonde (d'où la rallonge), car pour accéder au système OBD du RLINK, il faut changer de place certains fils !!!

C'est très bien expliqué sur le tuto de gps-carminat :

![](/2022/04/rallonge_obd.png)

* [www.gps-carminat.com/v3/r-link/activer-android-auto-waze-sur-r-link-1](http://www.gps-carminat.com/v3/r-link/activer-android-auto-waze-sur-r-link-1)

Grosso modo, ça donne ça :

![](/2022/04/20210217_163410.jpg)

![](/2022/04/20210217_164148.jpg)

## Installer DDT4ALL

Le gros de modifs vont être réalisées à l'aide de l'outil DDT4ALL que Cédric PAILLE a gentiment opensourcé. Je lui ai fait un petit don et si ce soft vous ait utile je vous invite à faire de même. 

Sous Linux, il suffit de cloner le projet et d'installer quelques packages pip3

```bash
git clone https://github.com/cedricp/ddt4all.git && cd ddt4all
pip3 install PyQt5
pip3 install PyQtWebEngine

python ddt4all.py 
```

Sous Windows, il y a un [installer de l'outil](https://github.com/cedricp/ddt4all/releases), compatible depuis novembre 2020 avec Windows 10 et Python 3 (ce qui n'était pas le cas lors de mes premiers tests)

Dans les deux cas, on obtient une interface graphique pour modifier notre véhicule (hinhinhin).

## Trouver une base DDT2000

Vu que le tuto de gps-carminat ne propose pas de téléchargement pour cette partie ni même de liens pour la trouver... je me demande si posséder ou partager cette base est totalement légal... 

Enfin... en insistant un peu on finit par trouver un fichier `DDT2000data.zip`.

Cette partie n'est pas super claire dans le tuto. Il faut copier le dossier contenu dans l'archive, sans changer le nom "ddt2000data" dans `C:\Program Files (x86)\ddt4all`. On se retrouve donc avec un dossier `C:\Program Files (x86)\ddt4all\ddt2000data` avec plusieurs sous dossiers.

## Brancher la sonde

Si vous ne savez pas où brancher la sonde OBD sur votre voiture, [outilsobdfacile est un site qui permet, entre autres, de le trouver](https://www.outilsobdfacile.fr/emplacement-prise-connecteur-obd.php), quelque soit votre véhicule.

![](/2022/04/20210217_165655.jpg)

![](/2022/04/20210217_165844.jpg)

## Lancer le logiciel DDT4ALL

Cette partie-là n'était pas non plus hyper claire dans le tuto. Une fois la sonde choisie dans le premier menu, le tuto nous dit d'abord de cliquer sur l'icône Einstein \[5\] puis choisir le mode "After sale" dans le menu déroulant.

![](/2022/04/ddt4all_marche_a_suivre.png)

En réalité, ce n'est pas (ou plus ?) du tout le bon ordre. Il faut d'abord choisir son véhicule \[1\] dans la première liste déroulante, tout en haut à gauche.

Ensuite, on cherche le menu Navigation, puis MFD 5.4 \[2\] (le tuto parle de MFD 4.6 mais il n'existe pas sur mon véhicule).

Et une fois qu'on l'a trouvé, on double clique dessus, ce qui le fait apparaitre dans le menu juste en dessous \[3\] et on clique là où il vient d'apparaitre.

Une fois toutes ces étapes passées, on peut cliquer sur "Ecrans", "Configuration" et chercher le fameux menu **13 – ECU configuration ADAS** dans lequel configurer Android Auto \[4\].

A partir de la seulement, on peut le sélectionner, **puis** sélectionner le mode "After sales" \[6\]. J'ai tatônné un moment avant de comprendre ça.

Après application des modifications, reboot de la tablette (5 fois Home) et branchement du smartphone, c'est une victoire :)

![](/2022/04/androidauto_ok.jpg)

## Sites utiles

* [Le tutoriel de gps-carminat.com](http://www.gps-carminat.com/v3/r-link/activer-android-auto-waze-sur-r-link-1/)
* [Le github de Cedric PAILLE / ddt4all](https://github.com/cedricp/ddt4all)
* [Le lien de MyRenault / RLink Store](https://myr.renault.fr/r-link-store.html)
* [Le lien direct pour télécharger la dernière version de RLink Toolbox](https://cdn.sa.services.tomtom.com/static/rltb/Windows/InstallRLinkToolbox.exe)
* [outilsobdfacile, un site pour trouver l'emplacement pour brancher le connecteur OBD-2](https://www.outilsobdfacile.fr/emplacement-prise-connecteur-obd/)
* [Un forum qui parle de ces choses-là](https://www.tlemcen-electronic.com/forum/forumdisplay.php?f=96)
