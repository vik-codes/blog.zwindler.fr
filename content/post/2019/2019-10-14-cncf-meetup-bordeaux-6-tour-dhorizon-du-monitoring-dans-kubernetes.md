---
title: 'CNCF Meetup Bordeaux #6 : Tour d’horizon du monitoring dans Kubernetes'
authors:
  - zwindler
type: post
date: 2019-10-14T15:30:18+00:00
excerpt: Je donne une nouvelle fois un Talk au CNCF Meetup de Bordeaux, cette fois ci sur Thanos, après une première partie sur Prometheus
url: /2019/10/14/cncf-meetup-bordeaux-6-tour-dhorizon-du-monitoring-dans-kubernetes/
image: /2019/10/cncfbdx_thanos.png
categories:
  - Monitoring
  - Conférence
tags:
  - CNCF
  - gekko
  - k8s
  - Kubernetes
  - Le wagon
  - Meetup
  - prometheus
  - thanos

---
## CNCF Meetup Bordeaux

Et rebelotte !

Je récidive et vais de nouveau venir vous raconter comment je travaille au CNCF Meetup de Bordeaux (pour rappel, vous pouvez retrouver [les slides de mon passage précédent, dans lequel j’avais fais un REX des incidents qu’on a eu sur Kubernetes](/2019/01/28/cncf-meetup-bordeaux-3-rex-kubernetes-et-chaos-engineering/)).

Pour cette 6ème édition, ça se passera le 24 octobre à partir de 19h00 dans les locaux de « Le Wagon » à Bordeaux.

[][2][Le lien vers le meetup et l’inscription][3]

Si vous êtes du coin et que vous êtes de passage et que vous voulez échanger avec vos pairs sur les solutions open sources de containérisation et autres sujets ayant trait au cloud, c’est « the place to be ».

Comme d’habitude, attention car les places partent très vite. Généralement, en 2 jours c’est plié...

## CNCF ?

Pour rappel, [la Cloud Native Computing Foundation][4], c’est la fondation « spin-off » de la Linux Foundation qui a été créée pour fédérer, piloter, organiser l’ensemble des projets open source ayant trait aux containers, aux microservices et aux services clouds.

> The Cloud Native Computing Foundation builds sustainable ecosystems and fostersa community around a constellation of high-quality projects that orchestrate containers as part of a microservices architecture.


Elle a été créée lorsque Google a légué le code de Kubernetes en 2015.

## Le programme

A 19H15, Etienne Coutaud, le co organisateur, nous fera son traditionnel « tour des news de l’écosystème CNCF ».

**#1 Monitorer mon cluster Kubernetes (quasiment) sans les mains.**

A 19h30, Etienne embraye sur la supervision avec Prometheus dans Kubernetes

> Il est impensable de mettre une plateforme en production sans monitoring, ceci est aussi vrai pour du Kubernetes managé ou non. Kubernetes est conçu pour s’intégrer parfaitement avec un autre produit phare de la CNCF Prometheus. Nous verrons durant ce talk comment mettre en œuvre les deux, comment cela s’architecture et comment l’opérer. Nous verrons également comment cette architecture est faite pour nativement accueillir les métriques issus de votre propre code.


**#2 Besoin de métriques Prometheus à long terme ? Thanos fera des Marvels !**

Et ensuite, c’est mon tour. J’irai un peu plus loin avec Prometheus en vous parlant de Thanos.

> Prometheus, aussi puissant soit il, repose sur plusieurs postulats qui ne collent pas avec tous les cas d’usage. Les métriques doivent être stockées sur un medium local et rapide, il faut un serveur par zone (failure domain) et donc potentiellement un grand nombre de serveurs Prometheus indépendants, difficiles à corréler, … Arrive alors Thanos (rien à voir avec le bonhomme violet avec un gant doré) ! Celui ci va nous permettre de stocker nos métriques infiniment, tout en les rassemblant au sein d’une même source de données et en améliorant la performance de nos requêtes les plus coûteuses.


**Lier l’utile à l’agréable**

A 21h, nous nous retrouverons pour échanger autour d’une bière et d’une part de pizza offert par Gekko (Merci à eux :-D).

 [2]: https://www.meetup.com/fr-FR/Cloud-Native-Computing-Bordeaux/events/258351142/?rv=ea1_v2&_xtd=gatlbWFpbF9jbGlja9oAJDI3YTAzNzNhLWY2YmEtNDdjMy1hN2QwLWEyYWVhZjllZjc0OQ
 [3]: https://www.meetup.com/fr-FR/Cloud-Native-Computing-Bordeaux/events/265657289
 [4]: https://www.cncf.io/
