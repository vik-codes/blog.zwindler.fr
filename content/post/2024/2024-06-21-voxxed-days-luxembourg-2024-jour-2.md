---
title: Récap du deuxième jour de Voxxed Days Luxembourg 2024 - Vendredi
authors:
  - zwindler
type: post
date: 2024-06-21T20:00:00+02:00
excerpt: "Récap' du deuxième jour de Voxxed Lu"
url: /2024/06/21/voxxed-days-luxembourg-2024-jour-2
image: /2024/06/voxxed_lu_24_j2.jpg
categories:
  - conference
tags:
  - Voxxed Luxembourg 2024
  - VoxxedLu

---

[Note vous pouvez retrouver mon récap' de la veille (jeudi) ici](/2024/06/21/voxxed-days-luxembourg-2024-jour-1)

## Technique et géopolitique, quel rapport ?

Deuxième jour de Vooxxed Lu ! Prêt ? Lezgoooooo

![](/2024/06/bayart.jpg)

La journée commence avec une keynote de Benjamin Bayart (Cofondateur de la quadrature du net, exPrésident de FDN, créateur de la FFDN...). 

Comme je l'ai dit sur Twitter, ça fait du bien de commencer une journée de conférence avec une personne aussi *habitée* par les sujets de données personnelles et des conséquences sociales de l'informatique.

Benjamin est aussi passionné que passionnant, et met les bons coups de pieds, dans les bonnes fourmilières.

Quelques concepts sympa, pèle mêle :

> L'ordinateur est fatal (NDLR "irrémédiable")

> Tout fichier est une maltraitance potentielle

> Les gens ne sont pas des choses. Il faut considérer les gens comme des choses pour les (mal)traiter en masse ([réification](https://fr.wikipedia.org/wiki/R%C3%A9ification))

> Je ne suis que la somme des données qui me décrivent

> Le medium, c'est le message. Ca va structurer la société d'une certaine manière (exemple avec la radio)

> Les systèmes auto-organisés fonctionnent, c'est la pensée "anarchiste". Il y a des règles, juste, pas de chef pour les imposer

> L'auto-organisation ça touche à la structure du pouvoir en entreprise. Lorsque ça ne marche pas, c'est souvent parce que le pouvoir change de mains.

## Il faut sauver le dernier giga de RAM

Damien Lucas et Ivan Béthus (deux compatriotes bordelais !) nous ont joué REX scénarisé en mode storytelling : "vous avez 3 semaines pour éviter l'explosion d'une application dont le pic de charge est imminent".

![](/2024/06/giga.jpg)

> Quand on fait du java, au moment de la conception on ne se soucie pas du tout la mémoire, c'est le garbage collector qui s'en occupe.

> Sur les ordinateurs, on a plein de RAM, parfois plus qu'en prod. Quand on a des soucis de prod, on ne sait pas comment s'y prendre.

Damien et Ivan ont ensuite présenté sur un exemple relativement réaliste de code différentes méthodes (heapdump OOM, JFR, pgstat statement, IntelliJ profiler, hypersistence) et des méthodes (streams, query hint) pour trouver là où la RAM est consommée et réduire les problématiques.

N'étant pas Javaiste, il a fallu que je reste bien concentré pour bien comprendre, mais c'était intéressant à voir et ça donne des clés pour un éventuel futur contexte ;-).

## C'est l'heure du Check-Up de vos pipelines CI/CD !

Après le déjeuner, je suis allé voir le talk d'Aurélien Coget qui nous a présenté la plateforme R2Devops.

> le code des pipelines est aussi important que le code applicatif

Le logiciel permet d'avoir une cartographie des différentes pipelines de CICD d'une entreprise, avec une attention toute particulière aux attaques de type supply-chain, ou la mesure de la conformité de ces pipelines en fonction de divers critères (qualité de code, ISO27000...)

La plateforme R2Devops a l'air bien fichue, très configurable et permettant d'avoir une vision d'ensemble, mais s'adresse quand même à des entreprises ayant un certain nombre de pipelines.

![](/2024/06/r2devops.jpg)

## Tabby, mon "Copilot" libre

Rafik Ferroukh nous a présenté une alternative à Github Copilot (ou équivalent JetBrains AI / tabnine / CodeWhisperer) avec Tabby ML (Tab by ML), un projet Open Source.

![](/2024/06/tabby.jpg)

Contrairement aux modèles de type copilot payants et propriétaires, Tabby by ML peut être customisé (on peut changer de LLM par exemple), est utilisable hors ligne et donc sans risque de leek de code propriétaire.

Parmi les fonctionnalités de l'outil, il y a :
* la complétion de code directement dans l'IDE
* la possibilité de récupérer du code sur des dépôts pour donner le contexte (RAG)
* un chat playground

A voir la pertinence des différents modèles de langage spécialisés par rapport aux modèles payants, mais l'outil a l'air prometteur. A tester ! 

## Rendez l'agilité aux développeuses et aux développeurs !

![](/2024/06/fanny.jpg)

J'avais déjà vu ce talk de Fanny Klauk en 2022, mais que ça fait du bien de le revoir :\)

Sous prétexte d'autonomie et d'auto-organisation des équipes, on met une pression extraordinaire sur les équipes de techs.

Ca parle de bonnes pratiques humaines (onboarding, suivi opérationnel...). Je ne spoil pas, c'est un livre dont on est le héros, il faut le voir (en replay, ou encore mieux, en vrai !).

## Cracking the Quantum Code: Découvrons la révolution quantique !

Laurent Grangeau a décidé de nous faire découvrir l'informatique Quantique pour le tout dernier créneau de VoxxedLu. Un talk sur un sujet léger à la toute fin du deuxième jour de conférence, rien de mieux 🤣.

On ne va pas se mentir (Laurent est d'accord), si vous n'avez pas un minimum de connaissances en physique, notamment quantique, ce talk peut être un peu ardu à aborder.

Cependant, Laurent a pris le temps d'introduire très progressivement les différents concepts (électronique classique, algèbre de bool, puis le pendant quantique, le qubit, ses propriétés, etc).

Ayant fait de la physique quantique en prépa et un module d'informatique quantique en école d'ingénieur (même si j'en avais tout oublié), j'ai beaucoup apprécié ce talk qui m'a donné envie d'y revenir, par curiosité.

![](/2024/06/quantum.jpg)

Le problème dans l'informatique quantique finalement, ce ne sont peut-être pas les équations (pas forcément hyper accessibles), mais plutôt le fait que cela reste encore très abstrait (peu d'applications concrètes malgrés les premiers ordinateurs).

## Sponsors, copain⋅es

Comme souvent, cette conférence a également été pour moi l'occasion de parler avec beaucoup de monde, aussi bien côté sponsors que côté speakers.

J'ai beaucoup discuté avec Thomas, Julien, Henri, Benjamin, Pietro, Geoffrey, Amine, Damien, Ivan, Fanny, Benjamin (bis), Thierry, Rachid, Fabien, Valentin, Erwann, Yannick, Annabelle, Aurélien, et celleux dont j'ai malheureusement oublié le prénom.

Un immense merci à Pierre-Antoine (merci merci merci, vraiment !), Gildas, et tout le reste de l'équipe d'organisation pour cette fantastique conférence.

PS: je les ai tous attrappés :\)

![](/2024/06/stickers.jpg)

[Note vous pouvez retrouver mon récap' de la veille (jeudi) ici](/2024/06/21/voxxed-days-luxembourg-2024-jour-1)
