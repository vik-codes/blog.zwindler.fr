---
title: Kubecon Europe 2021 – Récap’ du vendredi
authors:
  - zwindler
type: post
date: 2021-05-12T07:00:00+00:00
excerpt: Résumé de la 3ème et dernière journée de Kubecon Europe 2021
url: /2021/05/12/kubecon-europe-2021-recap-du-vendredi/
image: /2021/05/kasten-1.jpeg
categories:
  - conference
tags:
  - GPU
  - kind
  - Kubecon
  - KubeCon Europe
  - kubecon europe 2021
  - Kubernetes
  - Nvidia
  - podCIDR

---
## **Dernier jour de Kubecon !**

C’est déjà la fin de la Kubecon :-(. 

Bon, en vrai, faire une conférence en ligne sur 3 jours était hyper intense et je suis rincé et je suis aussi un peu content que la conférence ait une fin ;-p.

J’ai énormément appris de choses et je ne me suis pas trop trompé dans les talks que j’ai sélectionné. Visiblement, le board qui choisi les talks est bien rôdé maintenant et je pense que la très grande majorité des conférences étaient de grande qualité.

Si vous avez lu le résumé des jours précédents, vous aurez remarqué que j’ai fait un gros focus sur la partie réseau et sécurité de l’écosystème autour de Kubernetes. Et c’est bien normal puisque c’est une bonne partie du travail qui m’attend dans les prochains mois...

* [/2021/05/05/kubecon-europe-2021-recap-du-mercredi/](/2021/05/05/kubecon-europe-2021-recap-du-mercredi/)

* [/2021/05/06/kubecon-europe-2021-recap-du-jeudi/](/2021/05/06/kubecon-europe-2021-recap-du-jeudi/)

## Keynotes

J’ai eu un peu de mal à suivre les keynotes ainsi que certaines conférences de cette journée pour une raison que je détaillerai dans un dernier article, avec mes conclusions. Voilà quand même ce que j’ai noté :

J’ai raté la keynote sur WASM, celle sur l’innovation dans l’open source (Success Through Failure), donnée par Thomas Di Giacomo, Chief Technology & Product Officer chez SUSE, ainsi que celle sur COVID Tracker.

La keynote suivante était une keynote sponsorisée par Vijoy Pandey, un VP chez Cisco, qui était assez basique sur l’intérêt des services mesh. Le talk aurait pu être résumé en une seule slide (la seule intéressante) qui disait que les services mesh servent à 4 choses : Discover, Consume, Connect, Observe.

Un keynote vraiment sympa (de mon point de vue) était la keynote de Daniel Mangum. Il a présenté l’architecture RISC-V (propriétaire) puis un projet open source pour l’Instruction Set Architecture, qui a permis le portage de nombreux projets open source sur RISC-V. A force de portages, d’abord go, puis des projets en go, puis docker et enfin Kubernetes ont été portés sur RISC-V (ce qui est aussi fun qu’inutile).

On a également eu un chouette talk sur la community culture pour le projet Kubernetes par Aeva Black (Microsoft) et Bob Killen (Google). 

Globalement, j’en ai retenu que les communautés sur des projets si vastes (des milliers de contributeurs, dont des entreprises multinationales) étaient mouvantes et qu’il fallait mettre en place des processus parfois complexes de manière à garder de la cohérence mais surtout de la confiance dans le travail des uns et des autres.

J’ai aussi beaucoup aimé ce diagramme:

![](/2021/05/dunbar.jpeg)

## Gateway API: A New Set of Kubernetes APIs for Advanced Traffic Routing

* [Page de la session](https://kccnceu2021.sched.com/event/iE39/gateway-api-a-new-set-of-kubernetes-apis-for-advanced-traffic-routing-harry-bagdi-kong-inc-rob-scott-google)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/19/%5BSIG-NETWORK%5D%20Gateway%20API_%20A%20New%20Set%20of%20Kubernetes%20APIs%20for%20Advanced%20Traffic%20Routing.pdf)

Cette session avait vocation à présenter la Gateway API, une nouvelle API permettant d’étendre les capacités en termes de routage des requêtes HTTP par rapport à ce qu’on peut faire actuellement avec les Services (trop focus sur les Loadbalancers tiers) ou les Ingress (trop limités).

![](/2021/05/api-model.png)

> [gateway-api.sigs.k8s.io/](https://gateway-api.sigs.k8s.io/)

Au delà de l’ajout indéniable de features comme le traffic splitting, les header matching, ... out of the box, l’avantage de la Gateway API est qu’elle ajoute des couches d’abstractions, notamment au niveau implémentation. 

Cela permet notamment (dans un contexte multi cloud par exemple) d’avoir des contrôleurs différents dans des clusters distincts, et ainsi fournir une expérience unifiée pour les développeurs d’un cluster à l’autre, ou alors de faciliter la migration d’un service mesh à un autre.

Aujourd’hui, les composants/logiciels suivants implémentent la Gateway API : Contour, kong, solo, gke, traefik, istio.

## Kubernetes Advanced Networking Testing with KIND

* [Page de la session](https://kccnceu2021.sched.com/event/iE3g/kubernetes-advanced-networking-testing-with-kind-antonio-ojea-redhat?iframe=no)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/df/Kubernetes%20_Advanced_Networking_Testing%20_with_KIND_Antonio_Ojea_Kubecon_2021.pdf)

Ce talk était plus une grande démo de KIND (Kubernetes in Docker) qu’autre chose. 

![](/2021/05/kind_logo.png)

Le speaker a montré qu’il était possible d’émuler sans trop de bidouilles plusieurs clusters Kubernetes sur un même laptop avec KIND.

Meh.

## A Deep Dive on Supporting Multi-Instance GPUs in Containers and Kubernetes

Même si j’en ai effectivement « un peu » besoin puisque j’ai des workloads GPU à administrer, ce talk était plus un talk plaisir qu’autre chose ;)

Dans ce talk, ça a parlé de GROS GPU, [notamment les A100](https://www.nvidia.com/en-us/data-center/a100/), et des outils que NVidia met à disposition pour les splitter en plusieurs GPU virtuels. Ca a parlé de MIG (Multi Instance GPU), de GPU Instance, de compute instance et de memory slices.

Comme c’est littéralement une des premières choses que j’ai essayé de faire lorsque j’ai commencé à travailler il y a 12 ans (même si c’était pas pour Kubernetes à l’époque, bien sûr), j’ai vraiment adoré ce talk même si je n’ai pas appris grand chose.

Ce qu’il faut retenir, c’est que « oui », c’est possible de splitter des GPU dans Kubernetes, mais que ce n’est pas trivial et qu’il y a plein de limitations (en tout cas pour l’instant) qui rende le splitting pas flexible pour un sou. 

Si ça vous intéresse, je vous invite à lire [les slides](https://static.sched.com/hosted_files/kccnceu2021/e9/KubeconEU-2021-MIG-Deep-Dive-Containers-Kubernetes.pdf) qui décrivent pas mal les problématiques que vous pourriez rencontrer.

## Discontiguous CIDRs for Dynamic Cluster Scaling

* [Page de la session](https://kccnceu2021.sched.com/event/iE3F/discontiguous-cidrs-for-dynamic-cluster-scaling-rahul-joshi-sudeep-modi-google)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/49/Discontiguous_CIDRs_For_Dynamic_Cluster_Scaling_RahulJoshi_SudeepModi_50721_v1.pdf)

Comme j’avais déjà eu par le passé des problématiques de CIDR trop petit dans un cluster Kubernetes, j’ai voulu voir ce talk donné par deux ingénieurs de chez Google cloud, par curiosité. 

Même si j’ai appris quelques trucs sur les raisons de pourquoi on doit trasher un cluster si le clusterCIDR qu’on a choisi est trop petit, je n’ai pas été super emballé par la façon dont c’était présenté (« on vous montre ce qu’on veut proposer comme solution à ce problème pour le projet Kubernetes ») qui faisait plus promo de leur implémentation de solution qu’un réel talk pour expliquer.

![](/2021/05/podCIDR.png)

C’était quand même intéressant, en faisant abstraction de l’aspect « campagne électorale », puisqu’on a deep dive sur la façon dont les CIDR sont affectés et les composants qui utilisent le cluster CIDR (nodeIPAM controller & kube-proxy).

## Les talks que j’aurai aimé voir

Après m’être un peu cassé les dents sur un problème de liveness probe pétée avec Rook, j’aurais bien aimé pouvoir voir le talk [Rook: Intro and Ceph Deep Dive](https://kccnceu2021.sched.com/event/iE6R/rook-intro-and-ceph-deep-dive-blaine-gardner-red-hat-satoru-takeuchi-cybozu-inc) de Satoru Takeuchi et Blaine Gardner, deux mainteneurs de Rook, en particulier sur la partie Ceph. 

Les [slides sont disponibles ici.](https://static.sched.com/hosted_files/kccnceu2021/82/Slides.pdf)

J’aurais aimé aussi voir [Multi-tenancy vs. Multi-cluster: When Should you Use What?](https://kccnceu2021.sched.com/event/iE66) mais un collègue est allé le voir alors je suis sûr qu’il me fera un retour ;)

## Conclusion

Malgré quelques points négatifs (j’y reviendrais dans un dernier article la semaine prochaine), faire une Kubecon en ligne n’était pas un exercice vain. 

Je repars avec beaucoup d’idées, beaucoup de motivation. C’était donc compliqué car intense, mais utile.

Les intervenants et leurs talks (je mets de côté les keynotes) étaient de grande qualité et il n’y a pas eu de créneaux « creux » où je n’avais rien envie d’aller voir (c’était même plutôt le contraire).

J’ai hâte de refaire des conférences IRL (voire en tant que speaker qui sait ?).

En attendant, have fun ;-)
