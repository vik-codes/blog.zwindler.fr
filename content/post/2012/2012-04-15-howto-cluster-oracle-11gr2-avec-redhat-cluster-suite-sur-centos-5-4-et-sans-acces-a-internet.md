---
title: '[Tutoriel] Cluster Oracle 11gR2 avec Redhat Cluster Suite sur CentOS 5.4 (offline)'
authors:
  - zwindler
type: post
date: 2012-04-15T07:54:09+00:00
url: /2012/04/15/howto-cluster-oracle-11gr2-avec-redhat-cluster-suite-sur-centos-5-4-et-sans-acces-a-internet/
image: /2014/03/lbvm1.png
categories:
  - Cluster
  - Logiciel
  - systeme
tags:
  - CentOS
  - heartbeat
  - MCSG
  - Oracle 11gR2
  - Redhat
  - Redhat Cluster Suite

---
J’avais pour objectif de proposer une architecture sous Redhat permettant d’héberger en clustering une base de données Oracle en mode actif/passif (sans RAC donc) pour un nouveau client. L’architecture actuelle/connue était à base de serveurs HP-UX fonctionnant avec un cluster HP MCSG qui fonctionnait très bien, mais pour des raisons de support sur l’ERP le passage à Linux était obligatoire.

MCSG sur Redhat n’étant pas encore (est ce que ça va changer?) supporté officiellement par Redhat et HP, et heartbeat étant une solution trop légère pour ce genre d’application critique au business, il a bien fallut que je fasse une maquette basée sur Redhat Cluster suite. Le faible nombre de blogs traitant du sujet et le nombre d’échecs parmi les rares articles que j’ai trouvés auraient du me mettre la puce à l’oreille quant à la difficulté d’installation/configuration de ce produit. Et pour cause : malgré une documentation officielle relativement bien faite, certains passages sont carrément obscur pour ceux qui rentrent dans le sujet sans expérience préalable des clusters.

Ayant galérer pour faire marcher la solution dans les grandes lignes, je pense qu’il est de mon devoir (oui oui, rien que ça :-p) de faire partager la documentation que j’ai tiré de mes diverses expérimentations :

  * La documentation en elle même [zwindler\_redhat\_cluster_suite][1]

  * Le fichier doc qui contient les [scripts][2]. Oui, c’est affreux mais wordpress n’autorise en upload que quelques extensions et je n’ai pas l’envie de chercher une solution de contournement...

Autre chose : au début, je pensais qu’être coupé d’Internet sur les serveurs d’un admin n’était pas monnaie courante. Avec le peu de recul que j’ai aujourd’hui, je me rend compte que je subis très régulièrement cette contrainte! Ayant été obligé de me passer du net sur ma maquette, j’ai aussi indiqué les solutions de contournement que j’ai trouvé dans la documentation, au cas où certains seraient dans la même configuration.

Cependant, dans tous les cas, je ne conseille pas l’utilisation de RHCS sur une prod **si vous débutez et/ou si vous n’avez pas d’accès à Internet** pour effectuer des mises à jours du système : **les bugs de cette version ainsi que les erreurs de débutant que j’ai pu faire sur ma maquette auraient assez vite corrompu la base de données d’une production**.

N’hésitez pas à me faire remonter toute imperfection dans la documentation, que je puisse corriger pour les suivants

 [1]: /2012/04/zwindler_redhat_cluster_suite.pdf
 [2]: /2012/04/scripts.docx
