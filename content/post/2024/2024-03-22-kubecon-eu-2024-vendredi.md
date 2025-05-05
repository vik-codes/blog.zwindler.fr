---
title: Récap du dernier jour de Kubecon Europe 2024 - Vendredi
authors:
  - zwindler
type: post
date: 2024-03-22T18:00:00+02:00
excerpt: "Récap' du dernier jour (vendredi) de la KubeCon + CloudNativeCon Europe 2024"
url: /2024/03/22/kubecon-eu-2024-vendredi
image: /2024/03/frenchies.jpg
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

## This is the end

4ème (en comptant les colocated events) et dernier jour de Kubecon. C'était intense !!

![](/2024/03/4.jpg)

La keynote de la journée a été ouverte par Chris Anisczcyk, CTO de la Linux Foundation (CNCF).

Quelques chiffres amusants : c'est la 20ème Kubecon, en juin 2014, Kubernetes a été open sourcé (il aura donc 10 ans cette année).

![](/2024/03/today.jpg)

![](/2024/03/ten.jpg)

Chris a fait un petit récap du chemin parcouru depuis cette date :

* 2015 - Kubernetes devient 1.0
* novembre 2015, première Kubecon à San Francisco avec seulement quelque centaines de participants
* 2016 - création de la CNCF
* 2019 - Création des événements KCD
* 2020 - Création des Cloud native community groups

Pour fêter les 10 ans de Kubernetes, la CNCF a créé un site [kubertenes.cncf.io](https://kubertenes.cncf.io).

Dernier point, un nouveau groupe de personnes reconnues dans la communauté a été créé (en plus des ambassadors), les Kubestronauts. Il s'agit des personnes qui ont fait toutes les certications (CKA, CKAD, CKS, KCNA, KCSA).

## Keynote: Success Not Guaranteed

La keynote suivante, de Bob Wise, CEO de Heroku, était aussi, d'une certaine manière, un regard dans le rétro, mais plus orienté sur sa propre carrière... Bob Wise a déroulé les choix dans sa carrière qu'il a dû faire pour créer du "cloud native" quand ça n'existait pas encore.

> We had built our own orchestration system, everything was working in dev, but not in prod

Lorsqu'il était dans la team Coud Native de Samsung, Bob a parlé des obstacles que lui et son équipe avaient décelé et qui auraient pu freiner l'adoption de Kubernetes.

Le premier était les problématiques de performance (comment dépassér les 100 nodes, supporter plusieurs patterns de déploiements, comme par exemple des clusters multi AZ). Ces challenges ont été traités par le Scaling SIG dont il faisait partie.

Le second était la gouvernance. Bob a estimé que la création de la CNCF et que la standardisation des containers avec OCI plutôt que forker docker avaient été les "bons moves".

> Open source is not enough, you need true community gouvernance

## Keynote: A 10-year Detour: The Future of Application Delivery in a Containerized World

À croire que réminiscence était le mot d'ordre de la journée, car c'était ensuite au tour de Solomon Hykes de jeter un coup d'œil dans le rétroviseur. Cependant, lui l'a fait avec de la sensibilité et une touche d'humour qui était très agréable.

![](/2024/03/solomon.jpg)

Solomon a reparlé de son parcours, notamment au sein de dotCloud puis de Docker, de ce qui a mené à l'adoption de la technologie des containers

> Serious people don't launch serious workloads in the cloud

Après avoir expliqué qu'on ne devait pas céder aux sirènes de la nostalgie en repensant aux PaaS des années 2010 (en mode "winner takes all"), et qu'il ne fallait pas y revenir.

Pour finalement changer complètement de sujet et parler tout à coup d'usine logicielle ("ne pas céder à la tentation de tout faire soi-même"). Difficile de ne pas y voir un clin d'œil à Dagger.io.

## Keynote Panel Discussion: Unity in Diversity: A Decade of Inclusive Growth in the Cloud Native Community

Kasper Borg Nissen a animé un panel sur la diversité dans l'écosystème cloud native :

* Jinhong Brejnholt, Saxo Bank
* Andrea Giardini, Independent
* Anastasiia Gubska, BT Group
* Stéphane Este-Gracias, ITQ

![](/2024/03/panel4.jpg)

Au travers des différentes actions des panélistes, nous avons pu nous rendre compte qu'il existe de nombreuses initiatives pour rendre la communauté cloud native plus diverse, plus durable (au sens écologique du terme).

On a parlé du SIG deaf and hard of hearing, des non-code contributions (la documentation), de Kubetrain (l'initiative visant à venir à la kubecon en train sponsorisé), des KCD, ...

Le témoignage de Anastasiia Gubska (sourd-muette) était particulièrement fort, touchant, inspirant.

## Three’s a Crowd: How to Achieve 2-Node HA at the Edge and Make Your CFO Smile

Tyler Gillson et Pedro Oliveira de Spectro Cloud (les développeurs principaux de Kairos, une distribution de Kubernetes) nous ont présenté les challenges qui les ont motivés à trouver une solution pour obtenir un cluster Kubernetes en "edge" avec seulement deux machines et non pas trois.

Les problématiques edges sont particulières. On ne peut pas se permettre dans certains cas de ne se reposer que sur un seul node, au risque d'avoir un SPOF. On ne peut pas non plus utiliser de cluster etcd externe ou de compter sur un "witness" (3ème vote, pour un quorum) car on peut avoir une mauvaise connectivité.

Le but était aussi de pas réinventer trop de choses, notamment dans les couches basses.

Il a donc été choisi d'utiliser k3s avec kine (kine is not etcd) avec une base postgres en mode actif passif.

![](/2024/03/ha2.jpg)

Si le nœud principal tombe en panne ou devient inaccessible, le nœud secondaire est promu, l'instance postgres devient principale et le control plane du node secondaire est redémarré. En théorie, ça fonctionne, sans trop de choses à modifier.

La démo n'a malheureusement pas fonctionné, mais la discussion qui a suivi avec les développeurs du projet était très intéressante.

## Trimaran: Load-Aware Scheduling for Power Efficiency and Performance Stability

Asser Tantawi & Chen Wang d'IBM nous ont présenté des plugins pour le scheduler qui permettent de placer de manière plus intelligente les pods sur les nodes, via un calcul de "score" basé sur des données des nodes et de statistiques.

Il en existe pour l'instant trois, mais il est en théorie très facile d'en écrire des similaires en modifiant les paramètres.

![](/2024/03/trimaran1.jpg)
![](/2024/03/trimaran2.jpg)

À tester.

## Sponsors

Une conférence comme la Kubecon se fait surtout grâce à la présence des sponsors.

Au cours de ces 3 derniers jours, j'ai pu faire le tour des sponsors. J'ai eu des discussions intéressantes avec Canonical, OVHCloud, Rancher, Nirmata (Kyverno), Isovalent, Mirantis, Otterize, Postman et VictoriaMetrics.

![](/2024/03/sighonk.jpg)

C'était l'occasion de découvrir de nombreux nouveaux outils (ou que je ne connaissais pas encore), tel que Trimaran, Karmada, Kube-rs, Kube-burner, et plein d'autres que j'oublie de citer.

J'ai passé aussi beaucoup de temps sur le "rooftop", pour parler avec des gens de tous les horizons, certains ayant des problématiques très semblables aux nôtres sans qu'on le sache (coucou Boursorama !).

![](/2024/03/frenchies.jpg)

Merci à toustes pour ces grands moments :\). 

See you next year?
