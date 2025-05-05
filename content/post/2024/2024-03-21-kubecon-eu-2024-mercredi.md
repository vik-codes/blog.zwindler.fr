---
title: Récap du premier jour de Kubecon Europe 2024 - Mercredi
authors:
  - zwindler
type: post
date: 2024-03-21T10:00:00+00:00
excerpt: "Récap' du premier vrai jour (mercredi) de la KubeCon + CloudNativeCon Europe 2024"
url: /2024/03/21/kubecon-eu-2024-mercredi
image: /2024/03/10years.jpg
categories:
  - conference
tags:
  - Kubecon
  - Kubecon Europe
  - Kubecon Europe 2024
  - conference
  - Kubernetes
  - CloudNative

---

Cet article fait partie d'une suite de 4 posts :
* [Récap du premier jour de Kubecon Europe 2024 - Mardi - colocated events](/2024/03/19/kubecon-eu-2024-mardi-colocated)
* [Récap du (vrai) premier jour de Kubecon Europe 2024 - Mercredi](/2024/03/21/kubecon-eu-2024-mercredi)
* [Récap du deuxième jour de Kubecon Europe 2024 - Jeudi](/2024/03/22/kubecon-eu-2024-jeudi)
* [Récap du dernier jour de Kubecon Europe 2024 - Vendredi](/2024/03/22/kubecon-eu-2024-vendredi)

## Keynotes

Aujourd'hui, c'est mercredi. C'est donc parti pour les premières Keynotes !!

Priyanka a commencé par nous donner quelques chiffres sur l'édition en cours (qui va rassembler 12000 personnes sur site, la plus grosse Kubecon de tous les temps).

Elle a ensuite donné le ton pour les prochaines keynotes (et aussi toute la conférence, en vrai).

> AI is everywhere, with irrational exuberance

Même si Kubernetes a maintenant 10 ans, il est probable qu'on en parle encore pendant un moment, puisque ce sont aujourd'hui les technologies "cloud native" (et donc Kubernetes) qui sont la base de cette révolution de l'IA.

Elle a ensuite insisté sur le fait qu'à l'instar de ce qui avait pour standardiser les technologies liées aux containers (OCI par exemple), il allait falloir s'extirper du modèle propriétaire dans le monde de l'IA.

Elle a terminé par une petite démo à base de LLAVA / BAKLLAVA (description d'images) et ollama (model registry service)

* [github.com/cncf/llm-in-action](https://github.com/cncf/llm-in-action)

![](/2024/03/pryianka.jpg)

## Panel

Juste après, elle a accueilli 3 personnes du monde de l'IA

* Timothée Lacroix - Mistral
* Paige Bailey - Google
* Jeffrey Morgan - Ollama

Il y a eu quelques discussions intéressantes dans ce panel :

* Ollama est très proche de l'architecture des projets cloud native, tout simplement par ce que son créateur a travaillé dans ces technologies pendant 10 ans
* Mistral utilise Kubernetes pour s'abstraire de toutes les problématiques d'infrastructure et se concentrer sur sa valeur ajouté
* il y a beaucoup d'Opensource washing en ce moment

## Accelerating AI Workloads with GPUs in Kubernetes

La keynote suivante, présentée par Kevin Klues et Sanjay Chatterjee, parlait du travail qu'il reste à faire pour tirer parti au maximum des GPUs dans Kubernetes.

Il y a deux niveaux d'améliorations sur lesquelles il faut travailler :

* bas niveau : comment rendre les GPUs mieux "partageable"
* haut niveau : comment rendre "topology aware" nos clusters Kubernetes et nos workloads

Sans trop rentrer dans les détails, il reste du travail, mais ça avance.

Quand j'ai regardé la suite des keynotes (AI, AI, AI, AI, ...), j'ai laissé tomber et je suis parti faire un petit tour des sponsors...

## 10 Years of Kubernetes Patterns Evolution

Étant administrateur de cluster Kubernetes en production depuis bientôt 8 ans, je n'ai pas appris grand-chose à cette session. Cependant, ce talk était très agréable.

![](/2024/03/patterns.jpg)

Les speakers Bilgin Ibryam & Roland Huss sont pédagogues et quand j'ai appris qu'ils étaient en fait les auteurs du livre "Kubernetes patterns", j'ai voulu le récupérer.

L'idée du livre (et de ce talk, qui en est une version très raccourcie) est de lister des éléments de design réutilisables pour concevoir des applications cloud native.

Note : l'idée de ce livre est inspirée d'autres livres plus anciens, comme "A Pattern Language", un livre d'architecture, et "Design patterns" (principes logiciels orienté objet)

Les auteurs ont présenté les patterns suivants :

* Health probes
* Structual patterns (avec l'exemple du sidecar)
* Behavioural patterns (avec l'exemple du singleton)
* Configuration patterns
* Security patterns
* Advanced patterns

Je suis allé récupérer le livre juste après ;-\)

![](/2024/03/book.jpg)

## Impossible de rentrer dans les salles

Je suis vraiment en colère.

Je n'ai pas pu rentrer ni dans **I'll Let Myself In: Kubernetes Privilege Escalation Tactics** (pourtant au même niveau dans le bâtiment), ni dans **Crossplane Intro and Deep Dive - the Cloud Native Control Plane Framework**.

Les files interminables pour rentrer dans les salles semblent être la norme cette année (encore). A quoi bon faire venir 12 000 personnes sur site si c'est pour que la moitié d'entre elles se retrouvent obligés de regarder les talks en replay trois semaines plus tard ?

![](/2024/03/fullrooms.jpg)

## Podcast et Brussels Beer Project

Pour ne rien arranger, et après une petite photo avec la team KCD France, j'ai dû partir tôt, car j'avais l'enregistrement d'un podcast qui était prévue de longue date.

![](/2024/03/kcdfrance.jpg)

Je n'ai donc pas pu tenter ma chance dans une autre session, mais j'ai cru comprendre que c'était à peu près pareil.

L'après midi n'était pas perdue pour autant puisque après le podcast, j'ai pu prendre un verre avec mes collègues parisiens que je ne vois pas si souvent que ça.

![](/2024/03/bbp.jpg)

## Networking, again

J'ai eu la chance de pouvoir parler un long moment avec mon ex-binôme et ses collègues de BackMarket. La discussion était productive ;-\).

J'ai aussi croisé Mathieu, Philippe, James, Nicolas, Remy, Zineb et par un hasard à peine croyable, Paul.

![](/2024/03/paul.jpeg)
