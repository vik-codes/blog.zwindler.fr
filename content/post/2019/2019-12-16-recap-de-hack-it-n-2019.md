---
title: 'Récap’ de Hack-It-N 2019'
authors:
  - zwindler
type: post
date: 2019-12-16T07:45:00+00:00
excerpt: "Récapitulatif de la conférence cybersécurité Hack-It-N 2019 qui a eu lieu à l'ENSEIRB-MATMECA"
url: /2019/12/16/recap-de-hack-it-n-2019/
image: /2019/12/20191210_103154.jpg
categories:
  - conference
tags:
  - conference
  - hack-it-n
  - hack-it-n 2019
  - hacking
  - Kubernetes
  - sécurité
  - talk

---

## Dernière conférence de l’année, Hack-It-N 2019 !!
  
  
Le 10 décembre, j’étais à Hack-It-N 2019 [(voir le lien de la conférence)](https://www.hack-it-n.com/), une conférence cybersécurité qui se déroulait à l’ENSEIRB-MATMECA.

> Les thématiques de cyberdéfense et de cyberattaque sont au cœur des préoccupations, pour coller à la réalité technique et à l’actualité des menaces : hacking, cyber-espionnage, cyber-surveillance, etc. Venez découvrir les enjeux actuels de la cybersécurité, ainsi que les techniques offensives et défensives du moment !

Et il se trouve que j’étais aussi speaker pour cette édition ;-) [Je vous laisse aller voir l’article dédié](/2019/12/10/hack-it-n-2019-ciel-mon-kubernetes-mine-des-bitcoins/).

![](/2019/12/hack-it-n-2019.png)


## Introduction
  
La conférence a commencé par l’introduction de Laurent OUDOT, co-créateur et CTO de la société TEHTRIS (TEHTRIS est co-organisatrice d’Hack-It-N avec la promo RSR de l’ENSEIRB-MATMECA).

Laurent a entamé un rapide tour d’horizon de la cybersécurité cette année avec cette question :

> Plein d’entreprises tombent en ce moment et tout le monde se demande pourquoi ?

> D’après une étude Gartner : 80 % des entreprises US de plus de 5k employés n’ont pas d’EDR. Et pour les 20% restant, la plupart n’ont pas les options nécessaires pour coller au terrain ("le terrain commande").

Selon lui, aujourd’hui, les entreprises ont besoin de muscler leur arsenal pour ne pas être distancé par la guerre technologique menée par les cybercriminels/cyberactivistes.

Un petit clin d’œil appuyé à la solution éditée par TEHTRIS (un EDR justement).

## Keynote
  
La Keynote d’introduction a été faites par Bernard BARBIER, un ancien du CEA qui est passé par la DGSE puis responsable cybersécurité chez Capgemini.

Bernard BARBIER a brossé de manière un peu plus exhaustive l’état de situation. Sans surprise, les menaces sont en hausses, tous les indicateurs sont dans le rouge et de plus en plus d’entreprises sont attaquées et victimes de cyber-attaques.

Selon lui, la France devient de plus en plus dépendante d’outils développés par des puissances étrangères. Peu d’outils mondialement connus viennent de France dans le domaine des cyber-armes.

Un constat alarmant surtout quand on sait que des cyberarmées déposent des charges malveillantes dans les infrastructures Françaises (gouvernement, OIV, ...).

Face à cette professionnalisation des hackers (voire militarisation), il faut donc changer notre façon d’approcher le risque cyber et contre-attaquer dès que possible.

## Table ronde

après la keynote, Hack-It-N a commencé par une table ronde. Elle a été animée par Marie Le Pargneux (BPCE).
Les 3 intervenants, Olivier Grall (ANSSI), Sébastien Yves Laurent (Prof Université Bordeaux Science Po), Didier Spella (Dirigeant de Mirat Di Neride), ont eu a répondre à des questions ou des thèmes d’ordres plus philosophiques
* En quoi la cybercriminalité change notre mode de vie ?
* Comment se structurer face aux enjeux de la cybersécurité ?
* Conscience collective, comment on s’y prend ?
* Intelligence artificielles éthiques, cybersécu éthiques
      
  
Les participants sont unanimes. Eux aussi pensent que la situation est inquiétante. Il y a, en France et en entreprise, une sous estimation du risque cyber par rapport aux autres risques. Là où dans le monde physique, les gens seraient vigilant ou porteraient plainte en cas d’attaque, il y a une certain nonchalance côté cyber. Les RSSI ne sont pas associés aux décisions des comités exécutifs.

Pourtant, sans qu’on s’en rende compte, on est finalement assez précurseur en France et en Europe sur les enjeux de cybersécurité, de sécurité des données, d’intelligence artificielle.

Le souci principal semble que les investisseurs "boudent" les startup Française et Européennes. Les sociétés privées veulent innover, mais l’investissement reste compliqué en cyber en France.



![](/2019/12/20191210_103154.jpg) 

## Living off the land
  
André Lenoir, consultant Cybersecurité chez TEHTRIS, nous a fait un présentation sur l’approche Living Off The Land, de plus en plus en vogue dans les cyberattaques d’entreprises.

Contrairement aux rootkits et aux attaques du kernel qui sont complexes à mettre en place, peu stables, et aux attaques fileless en mémoire, qui commencent à être détectées par les antivirus et les EDR, les attaques de types Living Off the land se basent sur l’ensemble des binaires inclus dans les distributions et qui peuvent servir à un attaquant.

Contrairement à ce qu’on pourrait penser, ces outils "dual use" sont extrêmement nombreux ! Pas moins d’une centaine dans un Windows de base ([listés sur ce projet github](https://lolbas-project.github.io/#)).

De simple ping / telnet / netsh suffisent pour scanner et sniffer le réseau. Pour l’AD, net (group, view, use)... Et on peut faire de la remote execution, du rebond/pivot, ...

Les deux gros avantages de cette approche sont que les outils sont déjà présent et que vous aurez moins de chance de vous faire détecter que si vous amenez vos outils, et ensuite ces outils ont des utilisations légitimes (administrateurs) et sont donc difficiles à bloquer (sans gêner l’administration normale des postes).

Parmi les solutions (pêle-mêle) pour limiter les risques de ce type d’attaques on a : Utiliser des EDR, limiter ce qui tourne sur le parc, bloquer logiciellement ce que les utilisateurs non privilégiés peuvent faire, utiliser AppLocker de MS, créer un domaine AD de type "Domain layered mode avec, faire des tiers sur l’infra", bloquer les outils sur les tiers faibles, bloquer le trafic est/ouest.

Bref, il y a du boulot !



![](/2019/12/20191210_114254.jpg) 

## Mass scanning the Internet for web vulnerabilities
  
Ce talk a permis à Nicolas Surribas de nous parler d’un outil qu’il développe (Wapiti) et d’une campagne de scanning massif d’Internet à la recherche de vulnérabilités sur les sites web dans le monde.

Wapiti permet de scanner des sites, extraire les URL et les formulaires, chercher les vulnérabilité, générer un rapport. Il s’utilise en CLI, est écrit en Python.

Les résultats positifs ont été postés sur le site [OpenBugBounty](https://www.openbugbounty.org/), qui permet la "divulgation responsable" entre le chercheur et le propriétaire du site. 2126 sites ont ainsi été soumis, avec de nombreux contacts fructueux à la clé.

Deux points intéressants, pour obtenir sa liste de sites à scanner, Nicolas Surribas a utilisé 2 sources CertStream et CommonCrawl, qu’il a ensuite donné à manger à Wapiti par l’intermédiaire de RabbitMQ (bus de messages).



![](/2019/12/20191210_121248.jpg) 

> RabbitMQ + Python = coeur, ça m’a fait sourire vu que je pratique les 2 quotidiennement 

## AIS GSM tracking, les naufrageurs 4.0

David Le Goff (un de mes mentors ;D) est un habitué de Hack-It-N. Il a d’ailleurs été présent en tant que speaker à toutes les éditions !

Cette fois ci, il revenait avec un projet sur les technos qu’utilisent les bateaux pour naviguer dans le monde. Car, on ne le sait pas toujours, mais les bateaux sont finalement de grands SCADA flottants connectés (par radio, GSM, Internet).

Et le moins qu’on puisse dire, c’est que la sécurité à bord laisse à désirer...

## Ciel, mon Kubernetes mine des bitcoins
  
Juste après mon mentor, c’était donc à mon tour. Coïncidence amusante.

Je vous remet le pitch, vous comprendrez que je n’ai pas pris de notes pendant mon propre talk ;-)

> A tort ou à raison, Kubernetes s’est imposé, en l’espace de 3 ans, comme un des nouveaux standards dans la gestion des architectures microservices modernes.
> Cependant, cet outil complexe amène son lot de pièges dans lesquels les débutants ne manqueront pas de tomber… 
> Et ce n’est pas l’apparente facilité apportée par les offres Kubernetes as a Service qui va arranger les choses !
>
> Après un rapide tour de l’actualité sécurité autour de Kubernetes, Denis Germain vous donnera les clés pour éviter de nous faire voler (trop facilement) vos cycles CPU.

[Vous pouvez retrouver les slides de ce talk pour Hack-It-N sur ce lien](/talks/hackitn-ciel-mon-kube-mine-bitcoins/).

## Entrainement à la cybersécurité
  
  
Bernard Roussely de Beware Cyberlabs, nous a ensuite présenté sa vision des problématiques de sensibilisation des individus, notamment en entreprise, à la cybersécurité.
Le constat reste une fois de plus que les employés manquent de bon sens, et que des formations, à différents niveaux, sont nécessaires pour corriger ça :
  
* Sensibiliser les dirigeants et personnels non informaticiens
* Former des spécialistes
* Entraîner les personnes ayant des fonctions critiques
* Préparer à la crise : tout le monde
      
  
Petite pique à l’attention de nos dirigeants :

> Les parlementaires sont très mal protégés. Les dirigeants doivent montrer l’exemple.
Enfin, Bernard Roussely a conclu en insistant sur le fait que :
  
* la Sécurité ce n’est pas un Coût mais un Investissement
* "l’ingénierie de sécurité", certes moins attrayante aux yeux des étudiants que le hacking, est une discipline autant voire plus importante dans les entreprises.

## OWASP - Mobile Security Testing Guide
  
L’[OWASP (Open Web Application Security Project)](https://www.owasp.org/index.php/Main_Page) est une organisation a but non lucratif connue pour travailler à l’amélioration de la sécurité des applications Web (vous connaissez très probablement le Top Ten Project). Depuis quelques temps, il existe un guide de test dédié aux applications sur les terminaux mobiles.

Davy Douhine, consultant en cybersécurité chez Randorisec, a profité de ce talk pour nous faire un tour d’horizon des bonnes pratiques indiquées dans ce guide, ainsi que quelques exemples frappants d’applications ne respectant pas ces bonnes pratiques (avec des failles assez graves comme une vérification d’un PIN client-side only pour une application bancaire par exemple...).

[Les slides sont disponibles ici (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20200309104836/https://www.randorisec.fr/publications/HACKITN-OWASP_Mobile_Security_Testing_Guide.pdf).

## Active Directory : Hack-it & Harden-it

Rémi Escourrou, auditeur chez Wavestone, a ensuite parlé d’Active Directory et à quel point cet outil était souvent simple à compromettre en entreprise. Dans la plupart des cas, l’auditeur fini par trouver un serveur non patché, puis avec diverses techniques à récupérer la main sur un contrôleur de domaine.

Le meilleur moyen de s’en prémunir est selon lui d’adopter la segmentation par tiers dans l’architecture des domaines Active Directory, tout en continuant à respecter les basiques (respect de l’hygiène de base, honeypots, ...)

Rémi Escourrou nous a également donné quelques outils permettant d’auditer rapidement et visuellement les liens entre les objets dans l’AD (grouperer, Pingcastle, Bloodhound).

Il a enfin terminé par un bref tour de la nouvelle fonctionnalité AD => Azure AD avec un passage par un cloud hybride (A protéger comme le reste du tier 0).

[Les slides sont disponibles ici](https://fr.slideshare.net/RmiEscourrou/active-directory-hack-it-hardenit)



## Security Operating Center en entreprise : Comment superviser ses périmètres et risques critiques
  
Cécilien Charlot, expert sécurité chez CGI, nous a enfin fait un retour d’expérience sur la mise en place d’un SOC.

Les SOC sont très coûteux, et il est important, pour la réussite de cette mise en place, de sélectionner avec soin les événements et les alertes qui lui seront transférés.

Il a donc donné des pistes pour trouver les bons compromis entre événements génériques et événements spécifiques (métiers), flux critiques ou non, etc.
La valeur métier d’un événement peut se déterminer via une analyse de risques (risque brut vs risque résiduels après réduction)
Pour caractériser les scenarii de surveillance, ses conseils sont donc :
  
* Prioriser (pour ne pas avoir trop d’événement)
* faire le lien avec les risques
* se rapprocher des métiers

## La prochaine édition en décembre prochain

Lors de la fermeture de l’événement, Laurent OUDOT en a profité pour annoncer la date de la prochaine édition d’Hack-It-N de l’an prochain : ça sera le 12 décembre 2020, toujours à l’ENSEIRB-MATMECA.

Encore merci aux organisateurs de l’événement pour m’avoir fait confiance et pour cette édition plus que réussie !

A l’année prochaine :)
