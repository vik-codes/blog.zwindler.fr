---
title: 'KubeCon Europe 2021 – Récap’ du mercredi'
authors:
  - zwindler
type: post
date: 2021-05-05T18:24:05+00:00
excerpt: Récapitulatif du mercredi 05 mai à la Kubecon Europe 2021
url: /2021/05/05/kubecon-europe-2021-recap-du-mercredi/
image: /2021/05/kubecon_2021.jpeg
categories:
  - conference
tags:
  - Kubecon
  - KubeCon Europe
  - kubecon europe 2021

---
## **(Mon) Premier jour de Kubecon**

C’est la deuxième fois que je participe directement à une Kubecon (j’avais fais un [récapitulatif quotidien de la Kubecon 2018 à Copenhague](/2018/05/03/recap-du-premier-jour-de-kubecon-europe-2018/)).

Cette année, comme l’an dernier, c’est en ligne ue ça se passe, bien entendu (COVID-19 oblige). Elle se déroule toute la semaine du 03 au 07 mai.

Le 03 était dédié aux « co-located conferences » (notamment la PromCon que j’ai faillis faire aussi mais finalement c’était trop intense). La journée de Mardi (hier) était dédiée majoritairement à des événements sponsorisés (j’ai juste vu un _deep dive sur le Networking dans Kubernetes_).

Ce mercredi (le 05) est donc le premier _vrai_ jour de la Kubecon, avec une série de keynotes en début de journée, suivi d’un condensé de talks en simultanés (minimum 10 pour chaque créneau horaire). 

Il a donc fallu faire des choix (et choisir, c’est renoncer) T_T.

![](/2021/05/zwindler_kubecon.png)

## **Keynotes**

Comme dans toutes les conférences, la journée commence donc par des keynotes. Là, ce n’est pas moins de 8 keynotes (!!!) qui se sont enchaînées de 10h à 12h.

La Kubecon a commencée par un talk (un peu surjoué) de Priyanka Sharma, General Manager de la CNCF. Elle nous a vanté les bienfaits des projets de la CNCF dans la lutte contre la crise sanitaire mondiale et l’accélération apportée par les logiciels la composant pour les startups et les grandes entreprises de la tech (mouais). Elle a également, avec Zain Asgar de New Relic le don de [Pixie](https://newrelic.com/blog/nerd-life/open-source-observability-pixie) (observabilité) à la CNCF.

Cheryl Hung a ensuite interviewé 6 entreprises qui contribuent en tant qu’End Users à la CNCF et a décerné le prix du End User de l’année à Spotify, notamment pour sa contribution de [Backstage](https://backstage.io/), une plateforme de portail de développement assez intéressante.

Jim Haughwout, VP chez Peloton a parlé de la manière dont les outils de la CNCF, en particulier Kubernetes, leur ont permis de soutenir leur croissance à 3 chiffres de cette année. Il indique notamment que Peloton a switché la totalité de son trafic externe en juste 1 an (de 0% à 100% sur Kubernetes).

Stefan Prodan, Developer Experience Engineer chez Weaveworks a fait un rapide talk sur Flux et ce qu’il apporte aux développeurs. Ça m’a beaucoup intéressé et j’ai d’ailleurs participé à une AUTRE conférence animée là aussi par Weaveworks sur Flux plus tard dans la journée.

Rapidement, je cite aussi 2 keynotes sponsorisées (IBM et Redhat... donc... IBM !) qui ne m’ont pas laissé un souvenir impérissable (meh).

La keynote de la Kubecon s’est terminée sur un talk de Liz Rice (Isovalent) et Lei Zhang (Alibaba) sur les « prédictions » du Technical Oversight Committee. Globalement, encore beaucoup de projets arrivent très fort sur des sujets comme les services Mesh, la sécurité mais aussi la dev experience / ops experience.

Ce dernier point m’a vraiment fait tiquer... **Qu’est-ce que ça dit sur l’écosystème CNCF** quand 11 projets arrivent dans l’écosystème pour faciliter l’adoption des autres ?

## **Sandbox**

Je ne l’ai pas listé dans la section précédente, mais une des Keynotes était animée par Justin Cormack, (CTO Docker).

Il a égrainé tous les projets en Sandbox, plusieurs dizaines ! Il y aurait moyen de faire un article rien que sur cette liste, je vais me contenter de juste lister les projets qui ont le plus retenu mon attention :

  * **Tremor** pour l’event processing, permet de remplacer logstash :trollface:
  * **Backstage** portail de développement, véritable boite à outils avec plein de features comme un catalogue de logiciels internes, des outils pour faciliter le templating de projets, les docs, ...
  * **k3s** comme distribution de kube IoT/edge (j’adore)
  * **crossplane**, qui facilite l’extension de l’API de Kubernetes
  * **Dex**, un portail OpenID Connect pour faciliter l’ajout d’authentification tierce dans Kubernetes
  * **Metal3.io** et **tinkerbell** pour le provisionning de Kubernetes sur du baremetal
  * **Trickster**, qui sert entre autre à mettre en cache des TSDB

![](/2021/05/sandbox.png)

> [Un extrait des projets en sandbox](https://www.cncf.io/sandbox-projects/)

## **Introduction and Deep Dive into Containerd**

Les keynotes passées, j’ai juste eu le temps de me faire des pâtes (moins de 20 minutes de pause, la Kubecon c’est hardcore), pour enchaîner sur un deep dive sur containerd !

* [Page de la session](https://kccnceu2021.sched.com/event/iE6v/introduction-and-deep-dive-into-containerd-kohei-tokunaga-akihiro-suda-ntt-corporation?iframe=no)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/d3/containerd-KubeConEU2021.pdf)

Kohei Tokunaga et Akihiro Suda, deux ingénieurs chez NTT, nous ont dans un premier temps présenté l’architecture de containerd.

* [Containerd](https://containerd.io/) est donc un container runtime de la CNCF au status Gratuated depuis 2019. Il est disponible sur Linux et sur Windows, et peut être utilisé par Docker, Kubernetes ainsi que des applications tierces via des clients. Il est utilisé par la plupart des gros cloud providers pour leurs Kubernetes managés.

Point intéressant, on peut interagir avec containerd de deux manières : soit avec la containerd API (utilisé par Docker), soit au travers de la CRI (container runtime interface) pour Kubernetes.

Containerd disposent de composants permettant de réaliser les tâches nécessaire à la containerisation (content store pour les images, snapshotter pour gérer les layers et les FS sous-jacents, runtime pour communiquer avec les runtimes supportés).

![](/2021/05/containerd-architecture.png)

source : [containerd.io](https://containerd.io/)

Une fois l’architecture du projet présentée, les deux présentateurs ont fait un focus plus poussé sur l’implémentation de clients (la plupart du temps en Go) pour réaliser des applications tierces qui interagissent avec containerd.

Je vous laisse lire les slides plus en détails si cette partie vous intéresse.

## **Helm Users! What Flux 2 Can Do For You**

* [Page de la session](https://kccnceu2021.sched.com/event/iE1e/helm-users-what-flux-2-can-do-for-you-scott-rigby-kingdon-barrett-weaveworks?iframe=no)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/12/kccnceu2021-helm-users-flux-guide.pdf)

Cette session dédiée à ce que Flux 2 peut apporter aux utilisateurs de Helm était très prometteuse. Je ne me suis pas beaucoup penché sur les aspects CI/CD dans Kubernetes et j’ai beaucoup râlé sur Helm ([dont un article il y a peu sur Helm 2](/2021/04/19/pourquoi-helm-2-doit-disparaitre/)).

La phrase à retenir du talk est je pense :

> Helm is imperative, Flux is declarative


L’aspect sur lequel les deux ingénieurs de chez Weaveworks ont bien insisté c’est donc cette reconciliation loop qui fait toute la différence. On bascule de l’Ops au GitOps. Du manuel à l’automatisation et à l’idempotency.

La plus grosse partie de la présentation était une démo live de ce qu’on peut faire avec Flux et ce que cela apporte par rapport à du Kustomize ou du Helm. Et en 30 minutes, c’est vrai que c’était assez bluffant. La réconciliation peut s’appliquer régulièrement ou via l’utilisation de webhooks programmable. 

Il existe également un composant (flagger) chargé de communiquer avec les IngressController ou service mesh de notre Kubernetes pour automatiser toute la partie le canary / A/B testing, ...

Vraiment très hypé par cet outil, **à tester d’urgence**.

## **Multi-Tenancy in Kubernetes: How We Avoided Clusters Sprawl With Capsule**

* [Page de la session](https://kccnceu2021.sched.com/event/iE2c/multi-tenancy-in-kubernetes-how-we-avoided-clusters-sprawl-with-capsule-dario-tranchitella-clastix-maksim-fedotov-wargamingnet?iframe=no)

* Slides ([1](https://static.sched.com/hosted_files/kccnceu2021/d8/Multi-Tenancy%20in%20Kubernetes%3A%20How%20We%20Avoided%20Clusters%20Sprawl%20With%20Capsule%20-%20Dario%20Tranchitella%2C%20CLASTIX.pdf) et ([2](https://static.sched.com/hosted_files/kccnceu2021/88/%20Multi%20Tenancy%20In%20Kubernetes-%20How%20We%20Avoided%20Clusters%20Sprawl%20With%20Capsule%20Max%20Fedotov%2C%20Wargaming.pdf))

J’étais un peu sceptique sur le fait que cette session soit découpée en 2 présentations distinctes mais finalement c’était très fluide / agréable.

La première partie de la présentation présentée par Dario Tranchitella de CLASTIX.io (société qui a créé Capsule), se concentrait sur la présentation de l’outil en lui même. Capsule est un operator permettant d’introduire une notion de multi-tenancy dans Kubernetes (absente par défaut).

Si Dario a d’abord insisté sur le fait que beaucoup de ce qui est implémenté dans Capsule peut être fait soit-même, à la main, il faut reconnaître que c’est beaucoup de travail. Et surtout que Capsule permet s’abstraire toutes les règles d’isolation que l’on souhaite, très simplement dans une CRD très claire.

![](/2021/05/capsule_crd.png)

La deuxième partie était un case study de la mise en place de l’outil chez Wargaming (éditeur de World of Tanks) qui dispose d’équipes de développement internes vues comme des clients par l’infra. L’utilisation de Capsule leur a permis de fournir à leurs clients (internes) des clusters en apparence distincts tout en ayant à gérer qu’un seul gros cluster par région (et une réduction du toil).

L’outil semble très prometteur et même si je ne suis pas bien sûr d’en avoir l’utilité, mérite d’être regardé avec attention.

## **eBPF on the Rise**

* [Page de la session](https://kccnceu2021.sched.com/event/iE5N/ebpf-on-the-rise-getting-started-quentin-monnet-isovalent?iframe=no)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/ca/kubecon-eu-2021_ebpf-on-the-rise.pdf)

Je ne m’étais pas encore intéressé à eBPF mais comme de plus en plus d’outils tirent parti d’eBPF (avec des fonctionnalités quasi magiques pour le profane), il était plus que temps de s’y intéresser. Je n’ai pas été déçu car l’intervenant, Quentin Monnet (ingénieur logiciel chez Isovalent) était excellent.

eBPF (pour extended Berkeley Packet Filter) est un moteur permettant de passer des appels systèmes bpf depuis l’userspace vers le kernel space, de manière efficace et sécurisée.

Cela permet d’avoir une vision très poussée de ce qui se passe sur la machine et c’est notamment ce qui permet aux outils de tracing/profiling d’obtenir des informations si précises sur ce qui se passe sur un host Kubernetes (ce que fait falco par exemple). 

Un autre usage d’eBPF se situe sur l’aspect réseau. On peut faire beaucoup de chose comme du traffic control, de l’anti-DDOS et même optimiser le chemin réseau utilisé par les pods d’un cluster Kubernetes pour communiquer entre eux (Cilium Datapath)

![](/2021/05/cilium_datapath.png)

La comparaison pod-to-pod via iptables versus eBPF pique... Quel sac de nouilles !

Bref, visiblement les possibilités sont folles et je vais devoir dig encore un peu pour bien comprendre ce qu’on peut faire avec ;-p.

## **Les sessions que j’ai loupé**

Je l’ai dit en début d’article, choisir, c’est renoncer. Malheureusement, je ne suis pas capable de suivre 2 (ou 3) streams de Kubecon à la fois... J’ai donc « loupé » deux conférences qui m’auraient intéressé :

**Get In Containerds, We’re Going Securing: Kubernetes SIG Security is Here!**  
Animée entre autre par Ian Coldwater, cette table ronde avait pour but de présenter le SIG dédié à la sécurité. A priori la session présentation était assez légère (genre vraiment niveau débutant) mais la partie Q+A était hyper intéressante... too bad.

![](/2021/05/ian.png)

> Du beau monde

**CSI Volume Attacks – The SRE Strikes Back**  
Une présentation des « failles » facilement exploitables au niveau du stockage dans Kubernetes. C’était probablement un peu léger là aussi, mais ça fait du bien de revoir les bases parfois. Dommage.

## Demain, c’est loin !

Passer la journée sur son laptop devant des confs en anglais (avec l’accent de tous les pays du monde) et finir la journée par un récap’, c’est assez ambitieux ;-)

Mais je commence à connaître maintenant donc je vais essayer de tenir le rythme et de refaire un article sur la Kubecon demain et un autre lundi (car vendredi soir, c’est **Koh lanta**, faut pas déconner).

![](/2021/02/ah.gif)

Alors en attendant, have fun !
