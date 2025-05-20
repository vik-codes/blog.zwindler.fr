---
title: 'Quelques replays de DevoxxFR 2025'
authors:
  - zwindler
type: post
date: 2025-05-19T17:00:00+00:00
excerpt: Un mois après devoxxfr 2025 je vous conseille quelques replays
url: /2025/05/19/quelques-replays-devoxxfr-2025
image: /2025/04/devoxxfr-jour1.png
categories:
  - conference
tags:
  - DevoxxFR 2025
  - replay
  - youtube

---

Maintenant que les replays de DevoxxFR sont disponibles, je vous ai fait une petite sélection de talks à (re)voir entre ceux que j'ai vu en vrai, et ce que j'ai vu en replay.

Prêts ? Partez !!

## Kubernetes : 5 façons créatives de flinguer sa prod 🔫

Charité bien ordonnée, commence par soi-même.

Si vous voulez savoir quels sont les incidents rigolos que j'ai eus en prod ces 7-8 dernières années avec Kubernetes, j'ai fait un petit best of de 5 incidents. Ça a pas mal plu même si je ne peux pas m'empêcher de voir les petits axes d'amélioration pour ce talk ;-\)

* https://www.youtube.com/watch?v=IeIuUCmjXUQ

## Ne perdez plus vos photos de vacances 🔥🏠🔥 (ou tout autre fichier important)

Mon deuxième talk de cette édition, si vous voulez un aperçu en 15 minutes de ce qu'il faut / ne faut pas faire pour perdre ses données personnelles, ce replay est fait pour vous.

* https://www.youtube.com/watch?v=FsItkp58sP0

![](/2025/05/backblaze-fine.jpeg)

Dommage que j'aie appris trois jours plus tard que Backblaze était en proie à de très grandes difficultés financières et à une gestion très très louche des dirigeants. J'en ai parlé sur LinkedIn, je n'ai pas encore eu le temps de remettre le post au propre (désolé pour le crosspost de l'enfer).

* https://www.linkedin.com/posts/denis-germain_devoxxfr-activity-7322626928757125121-SaVN
* https://www.morpheus-research.com/backblaze/

## Et si vous interrogiez le recruteur ? Pour bien choisir sa futur aventure pro !

Henri Gomez et Guillaume Mathieu s'interrogent sur les questions que vous devriez poser si jamais vous voulez changer d'entreprise.

J'ai beaucoup aimé ce talk. C'est rigolo parce que toutes les questions "à poser" qu'il cite, je les collecte / pose instinctivement à chaque processus.

Mais s'ils n'en avaient pas la liste, je n'aurais pas su la dire !

* https://www.youtube.com/watch?v=17yOGRRo3Ug

## 👨‍💻 TDD et IA 🤖 - Benoit Prioux

Un talk TRES intéressant sur la façon de faire du TDD avec une IA par mon ami et ex-collègue Benoit Prioux à base d'un petit exemple et de live codings.

Générer du code avec la GenAI, PUIS lui demander de générer les tests n'a quasiment aucun sens. Il y a de grandes chances que sur un code métier un peu complexe les tests ne servent à rien. C'est encore plus vrai si on a un peu de logique métier dans son code, comme le prouve la démo de binout.

En revanche, le faire en TDD (c'est-à-dire demander à la GenAI de générer les tests, PUIS le code) fonctionne mieux, dans son expérience.

* https://www.youtube.com/watch?v=ayaD_RuQgxM

## 45 min pour mettre son application à genoux : le guide complet du test de charge

Loïc Ortola et Mathilde Lorrain présentent les concepts et la théorie d'une stratégie de load testing ainsi qu'une implémentation en live talk sur une appli web Java avec Gatling.

Intéressant à voir quand on n'a pas fait ça depuis longtemps.

N'hésitez pas à regarder l'intro en 125%. Si vous avez la ref, c'est un petit bonbon :-p

* https://www.youtube.com/watch?v=rXYq4Mhe80M

## PostgreSQL : Le couteau suisse dont vous avez besoin (sans le savoir)

Lætitia Avrot présente un talk sur PG utile pour tout le monde (même moi, c'est dire).

L'exemple est super parlant, les concepts introduits de manière progressifs.

* https://www.youtube.com/watch?v=sYOldn23bNE

## Anatomie d'une faille

Excellent talk d'Olivier Poncet sur la faille (et tout ce qui se passe avant) xz-utils.

Si vous en avez entendu du bien, ce n'est pas pour rien. Même en ayant suivi l'histoire, j'ai pris un plaisir fou à l'écouter (alors que j'étais stressé par mon propre talk juste après). Je suis très content de l'avoir vu en vrai.

* https://www.youtube.com/watch?v=1cxdCcG7y8U

## L’Intelligence Artificielle n’existe pas

La keynote d'ouverture du premier jour avec L’Intelligence Artificielle n’existe pas de Luc Julia

* https://www.youtube.com/watch?v=JdxjGZBtp_k

Vraiment top. 

Je recommande aussi "Silicon Fucking Valley" sur Arte, au passage, c'est court, intéressant et rigolo (6X15 minutes)

![](/2025/05/sfv.png)

* https://www.arte.tv/fr/videos/RC-025898/silicon-fucking-valley/


## GitHub Copilot : Aller encore plus loin que la completion de code

Encore de l'IA, Kim-Adeline Miguel et Sandra Parlant ont présenté les features les plus récentes de Github Copilot.

Assez intéressant pour un non-utilisateur du service qui n'aurait pas suivi les évolutions (moi). En vrai, ça m'a donné envie de tester Copilot. Il faut que je trouve un peu de temps et un projet adapté.

* https://www.youtube.com/watch?v=9kE9JWW2Y1k

## Burrito est un TACoS : une alternative open-source à Terraform Cloud

Un talk de Lucas Marques et Luca Corrieri, sur Burrito, un logiciel maison, clone de ArgoCD MAIS pour Terraform. 

Après une rapide introduction avec un constat sur tous les griefs qu'ils ont avec terraform (j'ai les mêmes), ils ont présenté une démo de l'outil. J'ai bien aimé.

Pas sûr que ça me réconcilie avec ce langage d'IaC, mais c'est un bon début.

* https://www.youtube.com/watch?v=DSuSCgPQlso

## Évolution continue de clusters Kubernetes/NOSQL supportant 300 Millions de QPS

Un talk assez chouette que j'ai malheureusement raté d'Erwan Velu, Flavien Quesnel, Geoffrey Beausire.

Si vous aimez les gros clusters et les problèmes de perf à l'échelle, c'est LE talk qu'il faut voir. On part de tout en bas et on remonte progressivement les couches, en passant par du débug bien piquant.

* https://www.youtube.com/watch?v=gCOPjk-xGzw

## Envie de booster ta carrière ? Open source-toi !

Un chouette REX de David Pilato sur une belle histoire de contribution open source qui a changé une carrière pro ;-)

* https://www.youtube.com/watch?v=ReAvGonT31E

## Kubernetes en 2025

Alain Regnier fait un chouette talk sur les features de Kubernetes que vous auriez pu louper. C'est probablement un talk que je vais rajouter dans ma banette des ressources utiles que je conseille aux débutants, pour être à jour dès le début :

* https://www.youtube.com/watch?v=Eh8jKVVSVKA

## Communiquer à 36000 km : l'art de l'efficacité avec moins d'un Watt

Très loin de la tech qu'on fait au jour le jour, Paul Pinault explique comment faire communiquer des objets dans l'espace. Très intéressant (pour les petits enfants fan de l'espace comme j'ai été).

* https://www.youtube.com/watch?v=GkSs18PBX5c