---
title: Récap du deuxième jour de Kubecon Europe 2022 - Jeudi
authors:
  - zwindler
type: post
date: 2022-05-19T20:00:00+00:00
excerpt: "Récap' du deuxième jour (jeudi) de la KubeCon + CloudNativeCon Europe 2022"
url: /2022/05/20/kubecon-eu-2022-jour-2-jeudi
image: /2022/05/PXL_20220519_110225897.jpg
categories:
  - Conférence
tags:
  - Kubecon
  - Kubecon Europe
  - Kubecon Europe 2022
  - Conférence
  - Kubernetes
  - CloudNative

---

Cet article fait partie d'une suite de 3 posts :
* [Récap du premier jour de Kubecon Europe 2022 - Mercredi](/2022/05/19/kubecon-eu-2022-jour-1-mercredi)
* Récap du deuxième jour de Kubecon Europe 2022 - Jeudi
* [Récap du troisième et dernier jour de Kubecon Europe 2022 - Vendredi](/2022/05/22/kubecon-eu-2022-jour-3-vendredi)

## Kubernetes Project Updates

Deuxième jour de Kubecon ! La première Keynote était l'habituelle "Kubernetes Project Updates"

Jasmine James nous a parlé des évolutions apportées par la dernière version de Kubernetes. Malheureusement je suis arrivé un poil en retard, mais je ne pense pas avoir raté grand-chose.

![](/2022/05/PXL_20220519_070748374.MP.jpg)

Au-delà de la suppression du support de docker-shim (enfin !), j'ai noté plusieurs améliorations à destination du Scheduling (ce n'est pas plus mal) en fonction de plusieurs critères (en fonction du stockage disponible, SIG scheduling).

Il y a aussi eu des annonces tout au long des keynotes sur les travaux en cours sur la partie Jobs / Batch (là aussi, ça ne peut pas faire de mal).

## Securing Shopify's Software Supply Chain

Encore une keynote très sympa. Ce n'était probablement pas un deep dive mais moi qui suis pas expert sur ce sujet, j'ai beaucoup apprécié.

![](/2022/05/PXL_20220519_072136507.MP.jpg)

Shane Lawrence, Staff Infrastructure Security Engineer chez Shopify, a introduit, avec beaucoup d'humour, les problématiques de la supply chain, notamment la sécurité. Il a parlé de choses qu'on ne devrait pas faire, sur nos postes :

> npm fix-error
> curl | bash
> go get ...

Aujourd'hui cet aspect devient particulièrement complexe à sécuriser.

Shane nous a parlé de Software Bill of Material, de divers outils permettant de sécuriser notre supply chain, etc.

Dans les challenges qui restent, selon Shane à adresser, il reste le fait que les logiciels non packagé passent encore entre les mailles du filet, et que parmi totalité des vulnérabilités détectés, le "triage" est encore une opération difficile à réaliser.

## Landscape Sustainability: The Pillars of Cloud Native Growth

Dave Zolotusky, Software Engineer chez Spotify & Katie Gamanji, Senior Kubernetes Field Engineer chez Apple nous ont parlé du TOC, et son rôle dans l'évolution du landscape CNCF.

Les points principaux étaient :

* Open governance et Transparence dans le processus de "graduation"
* Comment faire avancer la technique et l'opérabilité
  * des experts dans les TAGs aident le TOC à prendre de meilleures décisions
* Les OpenStandards bénéficient à tout le monde
  * Vendors : innovation
  * end users : extensibilité
  * Community : inter-operabilité

![](/2022/05/PXL_20220519_074339749.MP.jpg)

Dave et Katie ont également insisté sur le fait que, dans un landscape aussi riche, l'aspect "developper experience" devient de plus en plus important. Tout comme la Sustainability (dont un WG bien d'être créé, on en parlait hier en keynote), dont les buts sont a priori surtout "éducatifs" :

* raise awareness
* give guidance and best practices
* educate

## Building Bridges: Cloud Native and High Performance Computing

Ricardo Rocha, Computing Engineer au CERN, nous a raconté l'histoire de leur adoption de Kubernetes, en 2017.

L'idée était d'avoir une plateforme plus moderne et plus flexible pour gérer à la fois la quantité de compute nécessaire lors des expériences au collisionneur, mais aussi de tirer parti de tout ce compute disponible pour réaliser des calculs de type "Batch", entre chaque expérience quand les clusters sont inutilisés.

![](/2022/05/PXL_20220519_080739368.MP.jpg)

Son talk était donc assez focus sur les challenges habituels des gens qui font du HPC et des Batch avec Kube :
* Low latency if jobs are working with each other
* High throughput
* NUMA awareness
* Software distribution
* Advanced scheduling

Forcément, il nous a également parlé des initiatives en cours et à venir sur les Batch dans Kubernetes :
* Workloads
* Queues
* Priorities
* Fair share
* ...

Note : je saute volontairement le récap' de plusieurs keynotes qui ne m'ont pas inspiré...

## Fun with Continuous Compliance

Premier talk de la journée ! Lors de cette Kubecon, difficile d'échapper aux sujets "Compliance". Chaque année il y a un gros sujet qui sort du lot et cette année, j'ai vraiment l'impression que c'est lui qui est ressorti, avec la sécurité de la supply chain.

Ann Wallace de chez Shopify & Zeal Somani de chez Google ont présenté OSCAL, un projet qui vise à rendre la compliance "fun".

> Compliance != Fun || Compliance == Fun

En vrai, plus que "fun", l'idée est d'arrêter que ce soit d'horribles formulaires Word à remplir à l'arrache une semaine avant la deadline ;)

L'idée était de montrer des outils, en cours de conception, pour mettre en place des rapports de *compliance* automatisés et en continue, pour que la compliance ne soit plus le *pain point* que cela peut être aujourd'hui.

> OSCAL helps to reduce compliance info collecting by automating it in the CICD platform and generated a compliance report in machine readable format

![](/2022/05/PXL_20220519_092651667.jpg)

Là encore, ce n'est pas directement mon domaine de compétence, mais je vois bien la valeur et l'intérêt pour les gens qui sont obligés de remplir ces rapports ;)

## GitOps to Automate the Setup, Management and Extension a K8s Cluster

J'avais prévu d'aller voir *OpenTelemetry: The Vision, Reality, and How to Get Started*, mais je suis arrivé trop tard, la salle était pleine à craquer.

Je suis donc allé **au hasard** à la salle d'à côté 😅.

Je suis tombé sur un workshop sur Flux CD, les Sealed Secrets et Crossplane, animé par Kim Schlesinger, DevAdvocate chez DigitalOcean.

![](/2022/05/PXL_20220519_095506196.MP.jpg)

C'était une assez bonne surprise, j'ai suivi la démonstration qui s'est déroulé sans heurts.

Le workshop est disponible [ici](https://github.com/digitalocean/kubecon-2022-doks-workshop). Je le referai à tête reposée.

## Sponsors

J'avais prévu d'aller voir, après la pause déjeuner :

> How to Migrate 700 Kubernetes Clusters to Cluster API with Zero Downtime

Encore une fois, je suis arrivé un poil trop tard pour pouvoir rentrer dans la salle et voir ce talk de Tobias Giese & Sean Schneeweiss et Mercedes-Benz Tech Innovation... C'est rageant, il me semble pas avoir eu ce genre de soucis en 2018 à Copenhague et je regarderai le replay.

J'en ai profité pour faire le tour des sponsors, dont quelques découvertes sympa comme solo.io et env0. Je n'en ai pas l'usage pour l'instant. Mais qui sait pour le futur.

Je suis également allé discuter avec [LaunchDarkly](https://launchdarkly.com/) (merci Henry), InfluxDB, Elastic, mes copains d'OVHCloud, Rancher, ... et plein d'autres 😉.

## Alerting in the Prometheus Ecosystem: The Past, Present and Future

2 fois OK, mais pas 3. J'ai retenu la leçon, je suis arrivé avec 25 minutes en avance pour avoir une place. Et HEUREUSEMENT. Encore une fois, la salle était pleine. 

Josue (Josh) Abreu de Grafana Labs nous a présenté la façon dont ils ont géré les alertes sur le SaaS, avec les problématiques de scaling et les fonctionnalités qui leur manquait.

![](/2022/05/PXL_20220519_134559897.jpg)

Le REX était intéressant mais comme le talk a commencé en retard (Pascal Martin aurait dit de toujours avoir son support sur une clé USB en cas de problème de laptop ;-P), le speaker a dû parler très vite et le récit était un peu dur à suivre.

Le talk s'est terminé par des "prédictions" sur les features du futur pour l'alert manager.

## From `docker push` to Bytes on Disk: Inside Distribution

Wayne Warren & Adam Wolfe Gordon, tous deux ingénieurs à DigitalOcean nous ont parlé de Docker registries et de Docker images.

![](/2022/05/PXL_20220519_142300968.MP.jpg)

Le talk est présenté comme un 101 (donc pour débutants). Il est fun et très bien expliqué. 

Le talk se limite à l'implementation "officielle" [github.com/distribution/distribution](https://github.com/distribution/distribution), donnée à la CNCF par Docker en 2020.

Je n'en dirais pas plus, je pense qu'il faut le voir si vous ne connaissez pas bien ce sujet (les experts n'apprendront pas grand chose, j'ai quand même appris un ou deux trucs car c'est pas si 101 que ça, en fait).

## How a Couple of Characters (and GitOps) Brought Down Our Site

Dernier talk de la journée (ouf !). Guy Templeton & Stuart Davidson de Skyscanner ont fait un REX sur un incident de prod dû, encore, à du Gitops !

Là encore, pas de spoil de ma part. Je dirais juste que c'est drôle, car dans tous les REX récents, j'ai vraiment l'impression qu'on est vraiment dans le tweet de Devops Borat de 2011 :-p
> To make error is human. To propagate error to all server in automatic way is #devops.

## All-Attendee Party 🎉 à Masía Aldamar

La journée s'est terminée sur l'habituelle All-attendee Party. C'était grandiose (lieu magnifique, traiteurs exceptionnels) mais nous étions trop nombreux, dans un espace trop restreint.

![](/2022/05/PXL_20220519_171352263.MP.jpg)

Avec la fatigue des deux jours j'avais besoin de calme et je n'ai pas apprécié comme j'aurais pu le faire, dans d'autres circonstances. Dommage.

Je n'avais jamais vu une Paella aussi grande. Et il y en avait 2.

![](/2022/05/PXL_20220519_165431188.jpg)

Et un barbecue... et de la découpe de jambons... et des sushis...

![](/2022/05/PXL_20220519_171238963.jpg)


## Talks que j'aurais aimé voir

Si jamais pu me cloner (ou rentrer dans les salles pleines 😭), je serais probablement aussi allé voir :

* Implementing Cert-manager in K8s - Jose Manuel Ortega, Freelance
* Sharing Knowledge: Writing Good Docs for Quick Approval - Jared Bhatti, Waymo
* How to Migrate 700 Kubernetes Clusters to Cluster API with Zero Downtime - Tobias Giese & Sean Schneeweiss, Mercedes-Benz Tech Innovation
