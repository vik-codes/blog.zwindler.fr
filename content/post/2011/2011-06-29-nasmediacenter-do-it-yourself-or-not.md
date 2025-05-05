---
title: 'NAS/MediaCenter : Do It (the hardware part) Yourself!'
authors:
  - zwindler
type: post
date: 2011-06-29T20:29:52+00:00
url: /2011/06/29/nasmediacenter-do-it-yourself-or-not/
image: /2011/06/dscn1178.jpg
categories:
  - materiel
  - Stockage
tags:
  - AT5IONT-I
  - Atom
  - ION2
  - MediaCenter
  - Mini ITX
  - NAS
  - ZFS

---
## Do it yourself

Après un long moment de silence presque religieux, me voilà pour raconter mon expérience de création d’un NAS/MediaCenter de A à Z; cet article tardif sur la partie hardware de la chose (ça fait maintenant plus de 8 mois que le tout fonctionne) va en fait servir d’introduction à un ou plusieurs articles qui vont suivre sur ZFS, et plus particulièrement ZFS-fuse pour Linux.

Je venais de terminer mon stage de fin d’étude, j’avais pas mal de temps sur les bras et un peu d’argent à consacrer à un projet qui se voulait le plus chronophage possible, en attendant de trouver du travail. Un NAS était le composant ESSENTIEL qui me manquait pour pouvoir geeker dans un environnement ressemblant vaguement à un vrai. Et plutôt que d’acheter un NAS tout fait et de jouer avec, je me suis dis que ça serait ENCORE  PLUS FUN de le faire moi même.

## Wife Acceptance Factor

Pour justifier l’utilité toute relative d’un tel achat, je me suis également mis en tête : « puisque le NAS allait se trouver devant la télé, autant qu’il serve à lire les vidéos en HD stockées localement », histoire d’éviter les transferts NAS => Affichage et les aléas du réseau domestique.

Ensuite, le projet étant un NAS fait maison, il fallait qu’il rivalise avec (voire surpasse) ses concurrents tout faits, aussi bien par ses performances (capacité, puissance électrique consommée, débit) que par son silence (c’est très important... si si si...).

Même si maintenant ce processeur commence à dater (on préfèrera les solutions ADM Série E ou un Céléron SU2300), la solution qui s’est imposée à l’époque pour réaliser un NAS performant et relativement peu cher étaient les processeurs D525 sur les cartes mères au format Mini ITX. Leur consommation est ridicule et certaines disposent d’une puce NVIDIA faible consommation assez puissante pour afficher des vidéos en HD.

## La config

Voici donc les composants que je me suis procurés :

  * Carte Mère AT5IONT-I (atom dual core hyperthreadé + NVidia ION 2, le tout sans ventilo)
  * 2*2Go de RAM Kingston (ou comment gaspiller son argent, car au final 2 Go c’est déjà presque trop)
  * 2*1 To de stockage (pour les données)
  * Une carte d’extension PCI-SATA pour combler le manque de ports SATA de la carte mère (seulement 2 ports!)
  * Une alimentation Silencieuse au format SFX, format aujourd’hui limité aux HTPC. Il y a aussi des possibilités d’alimentation externe appelé PicoPSU, à la manière des ordinateur portables
  * 1*160 Go \[stock\] (exclusivement pour le système)
  * 1 lecteur de DVD [stock]
  * 1 boitier provenant d’un vieux Barebone pour cartes mères, Flex-ATX, format totalement « has-been » \[stock\] (fort heureusement, c’est un format compatible Micro-ATX et donc compatible Mini ITX)

Pour donner une vague idée du prix, j’en ai eu pour moins de 350€ si je ne compte pas mes composants en stock. Un NAS acheté chez un fabriquant m’aurait couté un peu moins cher mais n’aurait pas eu les fonctionnalités graphique du MediaCenter. De plus :

  1. Le prix peut être probablement être réduit de 100 à 150€ si on met de côté l’aspect MediaCenter et qu’on se concentre sur l’aspect NAS
  2. On doit pouvoir mieux se débrouiller que moi, surtout avec la démocratisation du format Mini ITX jusqu’à présent très cher sans grande raison

Le choix de réutiliser un boitier non adapté a été motivé par l’absence de boitiers à la fois compacts mais pas trop, et pas trop cher : un NAS crédible doit rester bon marché, et nécessite des emplacements pour disques.

## Le boitier de mon Qbic

Malheureusement, le plus dur a été de tout faire rentrer dans le boitier en question, pourtant prévu pour une carte mère beaucoup plus grande... Le premier problème auquel j’ai été confronté a été la taille et le format de la plaque métallique entourant la connectique de ma carte mère. Mon bon vieux Qbic de chez Soltek appartient à une époque où les standards, ce n’était pas encore ça...

![](/2011/06/soltek_qbic_back.jpg)

> C’est très joli, mais pas vraiment pratique...

N’ayant pas vraiment de solution, j’ai du découper le boitier avec les moyens du bord. Paix à son âme, ainsi qu’à celle de mes poumons, maintenant enrichis aux poussières d’aluminium.

![](/2011/06/dscn1170.jpg)

> Oui, j’ai torturé ce pauvre boitier à la scie à métaux

Heureusement, ceux qui ont un matériel adéquat pourront le faire un peu mieux que moi...

![Contrairement à mon « interprétation » très personnelle de la modification à apporter, le résultat est bien plus réussi ici... Il me manquait une Dremel, en fait...](/2011/06/091208090622970839.jpg)

Mais le boitier n’avait pas terminé de me réserver des surprises, grâce à l’agencement très « old school » des connecteurs de la carte mère. J’ai du refaire tous les branchements pour arriver reproduire ce qui était décrit dans le manuel de ma carte mère.

![](/2011/06/dscn1180.jpg)

> On voit bien que tous les fils sont regroupés dans un coin pour fonctionner avec les cartes mères récentes

Quand je croyais que tout était enfin résolu. Mais c’était sans compter que ma carte mère n’acceptait pas mes barrettes de RAM ! Et il s’agissait pourtant de barrettes standard Kingston!

Il a fallut faire une mise à jour du bios en ayant au préalable acheté une barrette 1Go supportée. Évitez vous une crise cardiaque et vérifiez bien la compatibilité sur ces architectures pour l’instant peu vendues...

![](/2011/06/dscn1178.jpg)

> Il ne reste plus beaucoup de place... au milieu à gauche le radiateur de la carte mère (CPU + GPU). En haut à gauche l’alim, en haut à droite les disques et le lecteur DVD. En bas à gauche la carte d’extension SATA

Voilà qui conclu donc ce récit épique de la construction d’un NAS maison. De quoi, je l’espère, refroidir les bricoleurs du dimanche. Même avec des composants de marque, il reste pas mal de travail à faire!

Le prochain article sera consacrés aux choix software pour finaliser mon NAS/MediaCenter.
