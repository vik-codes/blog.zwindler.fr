---
title: 'Devoxx France 2023 - Récap du jour 2'
authors:
  - zwindler
type: post
date: 2023-04-14T16:00:00+02:00
excerpt: Je suis à Devoxx France 2023 et je fais un récapitulatif de cette deuxième journée de conférence
url: /2023/04/14/devoxx-2023-recap-jour-2/
image: /2023/04/denis_amphi_bleu.jpg
categories:
  - conference
tags:
  - Kubernetes
  - Devoxx 2023
  - Devoxx 

---

Les résumés des 3 jours de DevoxxFR 2023

* [Mercredi](/2023/04/13/devoxx-2023-recap-jour-1/)
* [Jeudi](/2023/04/14/devoxx-2023-recap-jour-2/)
* [Vendredi](/2023/04/15/devoxx-2023-recap-jour-3/)

## Deuxième jour de DevoxxFR !!

Hier, j'ai fait un petit compte rendu de [ma première journée de conférence](/2023/04/13/devoxx-2023-recap-jour-1/) et il est donc logique que je continue aujourd'hui. 

J'vais pas mentir, il y avait un peu plus de pression car c'est le jour où j'avais mes talks ;-\).

## Le cache HTTP

La première session que je suis allé voir est celle de Hubert SABLONNIÈRE sur le(s) cache(s) HTTP. 

C'était un très bon talk ! Même en connaissant tout ou partie des couches entre le navigateur et le serveur, je pense qu'on a tous appris un petit quelque chose. 

Le but d'un cache, c'est de réduire les temps de chargements. Sauf que la spec est pas toujours super claire ou explicite, et qu'on a ajouté au fil du temps pas mal de couches de caches dans le web moderne. On a donc parfois des comportements rigolos.

![](/2023/04/hubert.jpg)

Au travers une série d'exemples et de démos, Hubert nous a montré comment marchent les directives de cache dans les URLs ont un impact sur ce qui transite vraiment sur le réseau.

On a parlé de max-age, de no-cache, de no-store, de revalidation de cache, de requêtes conditionnelles, ...

Le mieux sera de revoir les démos quand le replay sera disponible. Il vaut vraiment le coup, c'est une de mes sessions préférées de ce DevoxxFR.

## De chroot à Docker, Podman, et maintenant les modules Wasm, 40 ans d'évolution de la containeurisation

J'avais prévu d'aller voir cette session de Thomas SCHWENDER, mais j'ai passé trop de temps à discuter avec des gens passionnants et n'ai donc pas pu rentrer dans la salle. 

Je ne sais pas trop comment le sujet a été traité, mais je regarderai le replay car j'avais prévu de faire un talk similaire mais n'ai jamais sauté le pas.

Le résumé et le support sont [disponibles ici](https://github.com/Ardemius/history-of-containerization/blob/main/chronology-all-dates.adoc) en attendant.

## Gestion de la dette d'architecture dans un contexte d'hypercroissance

Pour la session d'après, j'étais donc à l'heure pour aller voir Cyril BESLAY parler de dette technique, et en particulier de dette d'architecture.

![](/2023/04/dette_archi.jpg)

Après un rappel de ce qu'on appelle la dette technique (Ward Cunningham), Cyril a détaillé la dette d'architecture, plus pernicieuse et difficile à calculer / résoudre.

Il a ensuite parlé des causes (internes / externes) de la dette et de comment faire pour "éviter la banqueroute" (quand on a tellement de dette technique qu'on doit tout jeter et tout refaire).

Quelques points que j'ai retenus (et approuvé fortement) :
* il faut éviter à tout prix d'arriver à la banqueroute
* vouloir réduire totalement la dette est illusoire et (très) coûteux
* il faut mieux former les équipes, notamment sur la partie métier / besoins fonctionnels, pour prendre de meilleures décisions
* il faut documenter les choix techniques (ADRs, radar)

C'était intéressant et je vois certains parallèles avec l'infra.

## Démystifions les composants internes de Kubernetes

A 16h45, mon stress était au niveau maximal. C'était ma session, en plus en amphi Bleu, la plus grande salle (pour l'instant) de DevoxxFR.

![](/2023/04/tweet.png)

J'ai donc démystifié le comportement interne de Kubernetes devant une salle quasiment pleine.

C'était une super expérience, tous les retours que j'ai reçus pour l'instant étaient bons, je suis donc ravi.

Vous pouvez relire [mon article à ce sujet](/2022/02/13/retrouvez-moi-a-devoxx-2023/), ou [relire les slides](/talks/2023-demystifions-kubernetes) / [rejouer le code](https://github.com/zwindler/demystifions-kubernetes) en attendant le replay.

Note : j'ai oublié de le dire pendant la session, mais ce talk était inspiré par 2 talks, que j'ai modifié à ma sauce et remis à jour :
* [Kubernetes Deconstructed de Carson Anderson](https://www.youtube.com/watch?v=90kZRyPcRZw)
* [Dessine moi un cluster de Jérôme Petazzoni](https://www.youtube.com/watch?v=3KtEAa7_duA) 

J'étais très fier que Jérôme soit dans la salle (merci pour le coup de main sur `ctr` !) et me fasse un retour positif. Tu es une source d'inspiration pour beaucoup de monde (moi inclus), Jérôme.

## Dockerfile vs Jib vs Pack vs image native : quelle est la meilleure méthode de création d'image de conteneur

J'ai suivi un copain et je suis allé voir Christian NADER qui présentait les avantages et les inconvénients de différentes façon de créer un container pour packager une application Java.

Je ne connaissais pas du tout cet univers et le talk était assez "débutant" pour que ça soit parlant pour moi.

Christian nous a expliqué les différents concepts pour chaque manière.

Les plus grosses différences venaient surtout de 2 philosophies différentes dans la compilation du code :
- JIT pour just in time (précompile peu de choses)
- AOT pour ahead of time (précompile plus de choses)

Cette image résume bien les avantages et les inconvénients de chaque solution :

![](/2023/04/jit_aot.jpg)

Bonus, j'ai découvert `termgraph` et `hey`, utilisés dans les démos pour faire de jolis démos/stress tests en live.

Si Christian me lit, je voudrais lui dire qu'il ne devrait pas se dévaloriser comme il a pu le faire plusieurs fois pendant le talk. Il était totalement légitime de faire ce talk et a bien fait passer son message.

## Infra : Donnez de l'autonomie à vos développeurs avec OctoDNS

Mon collègue Julien BRIAULT nous a présenté OctoDNS, un tool pour gérer facilement des records DNS dans du code simple, cross provider.

> Qui n'a jamais rêvé de donner la possibilité à tout un chacun de gérer des records DNS (pas juste les ops) ?

Hum... Je sais pas trop, Julien. On est quand même bien des nerds alors je suis pas sûr qu'on soit représentatifs (trollface).

Après un historique des solutions existantes pour gérer les DNS et les problématiques que ça engendre dans un contexte DevOps, Julien nous a présenté les avantages de la solution OctoDNS (utilisée actuellement en prod chez Deezer).

Je ne suis évidemment pas objectif, mais j'ai trouvé ce talk excellent. Julien était très à l'aise, ses démos ont bien marché. 

En tant que speaker avec un poil plus d'expérience, j'avais relu les slides et j'avais un peu peur de la quantité de GIF sur le support (certains speakers vont jusqu'à dire qu'il faut les bannir complètement). 

Finalement, j'avais tort de m'inquiéter, ça a bien fonctionné, le talk était fluide. Bravo Julien !

## Retrospective Kubernetes Community Days France 2023, ou comment monter une conf tech de zéro

A 21h, j'avais encore du travail !

Mes collègues d'organisation de Kubernetes Community Days ([pour rappel](/2023/03/11/ma-premiere-experience-d-orga-kcd-france-2023)) Jean-Christophe SIROT et Smaine KAHLOUCH avaient prévu de faire un BoF (Bird of Feather) en fin de journée sur l'organisation d'une conférence tech.

Comme j'étais disponible, je suis évidemment venu les rejoindre. On était pas super nombreux mais c'était cool de pouvoir échanger sur nos succès et nos échecs de manière ouverte.

## Stands, meet and greet et "le Jam"

J'ai passé une partie de la journée à faire le tour des stands. J'ai une des discussions sympas avec certains d'entre eux, comme Adeo (Leroy merlin), Adelean, Positive thinking, Redis, Microsoft et OVH.

J'ai aussi croisé plein de gens que je n'avais pas encore croisé la veille. Super content de vous avoir vu François, Geoffrey, Pierre Antoine, Olivier (avec qui on a parlé 30 minutes, c'était top !), Sébastien, Idriss, Katia.

J'ai déjeuné avec la team Clever Cloud, c'était fun.

Lors du meet and greet, j'ai pu revoir Marcy, Juliette, Amélie, rencontrer ENFIN Shirley IRL (depuis le temps qu'on discute ensemble). Belle rencontre aussi avec Théa et Aly.

J'avais très envie de chanter au Jam (sans trop oser) et le fait que j'ai le BoF sur l'organisation de KCD a fait que j'en ai raté un bonne partie. 

![](/2023/04/jam.jpg)

La perf de Quentin sur Boogie Woogie était épique 🤣. Difficile de passer après. J'espère revenir avec plus de confiance en moi l'an prochain.

![](/2023/04/jam2.jpg)

Last but not least, après plusieurs mois à se suivre mutuellement sans jamais se parler, j'ai rencontré Guillaume Grillat, ex Deezer et maintenant LeBonCoin. J'ai très hâte qu'on collabore pour organiser des événements tech 😎.

![](/2023/04/tweet_lbc.png)
