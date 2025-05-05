---
title: 'DevoxxFR - Récap du vendredi (jour 3)'
authors:
  - zwindler
type: post
date: 2025-04-18T14:00:00+00:00
excerpt: Je suis à la DevoxxFR 2025 et je fais un récapitulatif de cette troisième journée de conférence
url: /2025/04/18/devoxxfr-2025-recap-jour-3/
image: /2025/04/devoxxfr-jour3.jpg
categories:
  - conference
tags:
  - Quantum Computing
  - DevoxxFR 2025
  - DevOps
---

Les résumés des 3 jours de DevoxxFR 2025

* [DevoxxFR - Récap du mercredi (jour 1)](/2025/04/17/devoxxfr-2025-recap-jour-1/)
* [DevoxxFR - Récap du jeudi (jour 2)](/2025/04/18/devoxxfr-2025-recap-jour-2/)
* [DevoxxFR - Récap du vendredi (jour 3)](/2025/04/18/devoxxfr-2025-recap-jour-3/)

## Troisième jour de DevoxxFR 2025

Cette fois-ci, je me suis couché tôt(-ish, j'ai écrit l'article du jour 2 au lieu de dormir). Je suis donc arrivé assez tôt pour voir la keynote, mais pas dans l'amphi bleu (à 10 personnes près).

C'est parti pour le récap' du jour 3.

## Plongez dans l'ère quantique : décryptez et anticipez la révolution à venir

Fanny Bouton, directrice de l'informatique quantique chez OVHcloud, nous a plongés dans l'univers de l'informatique quantique.

![](/2025/04/fanny_bouton.jpg)

Elle a expliqué que la suprématie quantique, la "Formule 1" du quantique, n'est pas attendue avant 15 à 30 ans. Actuellement, nous avons des ordinateurs quantiques avec 10 à 156 qubits (IBM). En France, il y a six ordinateurs quantiques. Et c'est assez unique, car nous avons 6 différents types sur les 10 types d'ordinateurs quantiques qui existent.

Un peu comme l'IA, il ne faut pas avoir "peur" de l'informatique quantique, qui ne va pas mettre au chômage l'informatique classique.

Elle reste nécessaire pour piloter les ordinateurs quantiques, qui peuvent accélérer certains calculs (notamment des simulations).

En revanche, Fanny a insisté sur l'importance de former tout le monde pour aller vers le futur. Elle a abordé le fait que les concepts comme l'intrication et la superposition d'état nécessitent de réapprendre les bases de l'informatique quand la quantique sera **vraiment** là.

Enfin, elle a parlé du fait qu'elle avait fait l'acquisition pour OVHcloud d'un ordinateur QRNG permettant de générer de meilleurs nombres aléatoires (il y a donc déjà des usages aujourd'hui) et que, en attendant la suprématie quantique, on pouvait déjà simuler les calculs quantiques sur des HPC classiques, pour amorcer le virage quantique en douceur et soutenir les acteurs locaux.

## Les LLM rêvent-ils de cavaliers électriques ?

À 09:35, Thibaut Giraud, alias Mr Phi, a présenté une hypothèse intrigante : les LLM (Large Language Models) ne comprennent rien et sont des perroquets stochastiques. Ils répètent sans comprendre, sans représentation interne.

![](/2025/04/mr_phi.jpg)

Cependant, il a très vite pris le contrepied de cette hypothèse : selon lui, les LLM ne sont pas **vraiment** des perroquets stochastiques. Certains modèles peuvent *comprendre* un peu les échecs et jouer avec un bon niveau. GPT-3.5 turbo instruct, par exemple, a un ELO de 1700-1800 (la mesure du niveau d'une personne aux échecs; 1800 représente le niveau d'un joueur en club).

La démonstration est assez longue et joue un peu sur les mots, je trouve.

En revanche, Thibaut a partagé une expérience amusante où, si on donne à ChatGPT 3.5 deux ELO très forts et que les noirs donnent leur dame au début, la partie continue de manière bizarre avec les noirs donnant volontairement **toutes** leurs pièces. 

Il a également mentionné une autre expérience montrant qu'on peut entraîner des LLM avec 4 GPU et beaucoup de PGN (le standard pour décrire les mouvements dans une partie d'échecs).

## PostgreSQL : Le couteau suisse dont vous avez besoin (sans le savoir)

Laetitia Avrot a donné un excellent talk sur PostgreSQL, et notamment certaines fonctionnalités méconnues et pourtant très utiles.

Bien que je ne sois pas DBA Postgres, la mise en scène (un loueur de vélo) a permis une introduction progressive des différents concepts.

![](/2025/04/laetitia.jpg)

Elle a abordé des sujets comme les types de données Range, qui permettent d'éviter à la sources des erreurs de conception classiques, les colonnes générées, les triggers, la recherche fulltext, et les notifications. Les exemples étaient extrêmement clairs et la présentation assez drôle. Laetitia est une personne que j'admire beaucoup.

Petite citation *random* qui m'a beaucoup parlé 

> Mon blog mydbanotebook, je l'écris pour moi parce que je suis plus toute jeune. Je sais que quand je trouve un truc intéressant et que je veux le retrouver 2 ans plus tard, je le retrouverai sur mon site." 

Combien de fois suis-je retombé sur mon propre blog en cherchant la solution à un problème que j'avais déjà résolu ?

## 45 minutes pour mettre son application à genoux : le guide complet du test de charge

Malgré cinq minutes d'avance, je n'ai pas pu entrer dans l'amphi Maillot pour cette session. Trop de queue devant l'amphi... 

Caramba. Encore raté.

## Speechless

Je me suis fait embarquer un peu par hasard dans le "Speechless", organisé par Jean-François Garreau. 

Un exercice intriguant où trois speakers doivent "jouer" une présentation sur un sujet choisi en partie au hasard, en partie par le public, et avec des slides loufoques qu'ils ne connaissent pas à l'avance.

![](/2025/04/speechless.jpg)

Je ne suis pas fan d'impro, mais c'était assez intéressant à voir. 

A la base, j'avais prévu d'aller voir le récit de David Pilato "Envie de booster ta carrière ? Open source-toi !". A priori, c'était super en plus. Hop, sur la liste aussi.

## Après-midi

L'après-midi a été écourtée par le fait que j'ai dû prendre le train retour en milieu d'après-midi. 

Cependant, j'ai eu des super discussions avec Ane, Idriss, Stéphane, Julien, Horacio, et Laetitia.

J'ai pu échanger avec des gens qui avaient vu mes talks (au moins Sacha, Jérôme, Jérôme, plus ceux d'hier) et j'ai eu des retours très positifs, ainsi que quelques suggestions d'amélioration.

Je remercie chaleureusement toute l'équipe d'organisation qui, cette année encore, a fait un travail incroyable. J'ai remercié de vive voix Arnaud avant de partir, mais j'espère que tous les organisateurs / organisatrices savent que je leur suis très reconnaissant, à tous/toutes, individuellement.

Et merci aux sponsors pour s'occuper des gourmands comme moi xD

![](/2025/04/sponsors.png)

Vivement l'année prochaine !