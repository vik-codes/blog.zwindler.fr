---
title: 'Mon FOSDEM 2023 - Dimanche'
authors:
  - zwindler
type: post
date: 2023-02-05T20:00:00+02:00
excerpt: Je suis pour la première fois de ma vie au FOSDEM et je fais un récapitulatif de cette deuxième journée de conférence
url: /2023/02/05/mon-fosdem-2023-dimanche/
image: /2023/02/ulb2.jpg
categories:
  - Conférence
tags:
  - FOSDEM 2023
  - FOSDEM

---

## Deuxième jour, je prends mes marques

Note : si vous n'avez pas lu [l'article sur samedi, il est ici](/2023/02/04/mon-fosdem-2023-samedi/).

J'ai un gros problème quand je vais en conférence. J'essaye toujours d'en voir LE PLUS POSSIBLE, un peu comme s'il fallait maximiser le temps passé à apprendre de nouvelles choses (alors que non).

Mais j'en suis conscient et c'est déjà un bon début pour essayer d'améliorer les choses. Aujourd'hui, j'ai donc essayé de voir moins de talk et de passer plus de temps avec **les gens**.

Je pense que ça a particulièrement de l'importance dans une conférence comme le FOSDEM, qui est **d'abord** la rencontre d'une communauté (ici, les développeurs de produits open source ou libres), **avant** d'être une conférence tech.

J'ai quand même été voir quelques talks dans la devroom "monitoring and observability".

## Observability in Postgres

Je suis arrivé juste à temps pour commencer par le [talk de Gregory Stark (Aiven)](https://fosdem.org/2023/schedule/event/postgres/).

![](/2023/02/postgresql.jpg)

Gregory a commencé par expliquer d'où on vient quand on parle de monitoring avec PostgreSQL, et pourquoi ça n'est pas adapté aux stack modernes de monitoring.

> Monitoring tools in PostgreSQL predates the modern tools

Effectivement, beaucoup des métriques qui permet de débugger des problématiques de performance dans PostgreSQL sont **en base**, ce qui nécessite de réaliser des requêtes SQL.

Ceci induit des limitations, notamment dans le cas où la base serait surchargée (justement LA où on aurait besoin d'avoir des stats). J'ai déjà vécu ce genre de situation et la solution est d'avoir un outil de collecte de stats *interne* à l'outil supervisé.

Un autre problème que Gregory a remonté est que ces stats ne sont pas adaptées pour les TSDB actuelles et qu'il y a pas mal de conversions et de postulats qui sont faits pour les rendre compatibles avec le format OpenMetrics, par exemple.

A la fin du talk, il a été pris par le temps et a parlé d'un tool qu'il était en train de développer qui permettait de résoudre ces problèmes. J'aurais bien aimé en savoir un peu plus.

## Application Monitoring with Grafana and OpenTelemetry

Les 3 talks suivants parlaient tous d'OpenTelemetry, d'une manière ou d'une autre.

Le premier était une [démo live de la stack d'observabilité de Grafana pour les 3 signals (métriques, traces, logs) de Fabian Stäber](https://fosdem.org/2023/schedule/event/apm/) (qui travaille chez Grafana Labs).

![](/2023/02/grafana.jpg)

L'exemple était simple (un *helloworld* avec 2 microservices) mais très efficace. J'avais déjà vu des démos, donc je savais que Grafana avait de sérieux arguments en tant que plateforme unifiée d'observabilité, mais je remarque que l'outil s'améliore de plus en plus.

Vous pouvez reproduire la démo avec le code qui est disponible sur ce repo [github.com/fstab/fosdem-2023](https://github.com/fstab/fosdem-2023).

## Practical introduction to OpenTelemetry tracing

Le second [talk sur OTel, de Nicolas Frankel](https://fosdem.org/2023/schedule/event/tracing/) était centré sur le tracing.

![](/2023/02/otel.jpg)

> Metrics is easy, logging also (even aggregating logs)
>
> Tracing is *the harder sport*

Après une intro un poil redondante avec le talk d'avant, ce talk a très bien expliqué la façon dont on peut ajouter du tracing dans une application, qu'elle soit gérée par un runtime ou pas.

La demo était vraiment très sympa, même si tout n'a pas fonctionné comme le speaker aurait voulu (l'effet démo...). Bravo !

## Exploring the power of OpenTelemetry on Kubernetes

[Pavol Loffay & Benedikt Bongartz ont fini cette série sur OTel](https://fosdem.org/2023/schedule/event/kubernetes/) par un focus sur l'intégration d'OpenTelemetry dans Kubernetes.

![](/2023/02/otel-kubernetes.jpg)

Ils ont expliqué comment la stack fonctionnait, ce qu'on pouvait faire avec l'opérateur.

Les fonctionnalités sont vraiment cool. On peut tirer parti de l'opérateur pour gérer les collecteurs, s'interfacer avec Prometheus, injecter des sidecars directement dans nos applications pour bénéficier de l'auto-instrumentation quand c'est possible via une simple annotation :

> sidecar.opentelemetry.io/inject: "true"

Sur ce dernier point, ils ont expliqué en détail ce qui se passe quand on ajoute l'annotation à un Pod. C'était assez intéressant et je comprends beaucoup mieux comment ça fonctionne !

## Simple, open, music recommendations with Python

Un peu par hasard, je me suis fait "embrigader" dans un talk sur un projet de recommendation de musique dans la DevRoom Python. Je n'avais même pas regardé le contenu de la track mais comme je travaille dans le domaine de la musique, ça faisait sens et je suis content d'y être allé.

[L'auteur du talk, Sam Thursfield](https://fosdem.org/2023/schedule/event/python_music_recommendation/) est parti du postulat que quand on était jeunes (oui oui), faire des playlists c'était d'abord faire des mixtapes sur des cassettes audio, puis partager des playlists winamp à partir de sa collection locale de MP3. Soit difficile à faire, soit difficile à partager.

![](/2023/02/python.jpg)

Aujourd'hui, si on parle de partager des playlists avec ses amis, on pense plutôt à partager une playlist qu'on aura créée sur une plateforme de streaming musical. Mais ce qu'il reproche à ses plateformes, c'est la recommandation qui est faite, avec tous les biais que ça peut créer.

> Easy to make / easy to share

L'auteur du talk à voulu savoir ce qu'il était nécessaire de mettre en place pour reproduire la création de playlists, à la maison, à partir de notre historique d'écoutes (en ligne) mais avec des fichiers locaux.

Il nous a donc présenté un projet qu'il a conçu et qui s'appelle [Calliope-music](https://pypi.org/project/calliope-music/) (attention il existe un autre projet en Python qui s'appelle Calliope, qui est bien plus connu mais qui n'a rien à voir).

Il nous a expliqué le principe du logiciel et nous a montré un exemple pour chaque fonctionnalité, de la récupération de trackID sur les plateformes de streaming à la génération d'une playlist via machine learning à partir d'une liste de contraintes.

Pour que l'exemple soit, les contraintes étaient limitées à une durée totale de playlist. Il serait intéressant de creuser un peu plus pour voir dans quelle mesure on peut ajouter des contraintes plus complexes (genre de la chanson, "mood" de la chanson...).

Note : moi qui suis dans ce business, je tiens à rappeler tout de même que la recommandation ne se limite pas à proposer des tracks qu'on aime déjà, mais à proposer aux gens des tracks qu'ils pourraient aimer ;-).

## Conclusion : le FOSDEM, c'est aussi des gens et de la nourriture

Au cours de ces deux jours de FOSDEM, eu la chance de pouvoir revoir ou rencontrer des gens avec qui j'échange sur les réseaux. Pas autant que j'aurais voulu, c'est un des points que j'améliorerai les prochaines fois.

Je n'ai pas toujours su bien choisir mes talks et j'étais très "stressé" par "le risque" de ne pas pouvoir rentrer dans une salle. L'an prochain, j'espère être plus détendu, car en vrai ce n'est pas grave.

Je suis aussi très content d'avoir revu ma binôme, fais coucou à Lady Julie & Damyr, pu déjeuner avec "Mr & Mme Doomer" et Alexandre, puis avec Pierre et François dimanche, d'avoir rencontré Edith, discuté avec des inconnus dans les files d'attente et tous ceux que j'ai croisé et que j'oublie de citer.

Je me suis gavé de frites et de gaufres. J'ai consommé quelques bières belges avec modération (ahah).

Je regrette de ne pas avoir pris un hôtel en plein centre, pour pouvoir sortir dans les bars iconiques du FOSDEM (Delirium notamment).

Mais par-dessus tout, je suis vraiment heureux d'avoir pu partager ces moments avec mes collègues, notamment mon padawan. 

**Un grand merci à toute l'équipe d'organisation pour cet événement titanesque**. Vivement l'année prochaine !

## Bonus

Petit Pêle-Mêle, sans commentaire.

![](/2023/02/pixlr_20230205194830718.jpg)

Note : la photo du tram dans la nuit est une photo de [@ztec@mamot.fr](https://mamot.fr/@ztec), publiée ici avec son accord. [Lien et licence](https://www.flickr.com/photos/ztec/52670237252/)

![](/2023/02/pixlr_20230205190814646.jpg)

![](/2023/02/pixlr_20230205190603961.jpg)
