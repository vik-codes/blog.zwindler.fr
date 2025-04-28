---
title: 'Récap’ du premier jour de KubeCon Europe 2018'
authors:
  - zwindler
type: post
date: 2018-05-02T22:09:43+00:00
url: /2018/05/03/recap-du-premier-jour-de-kubecon-europe-2018/
image: /2018/05/kubecon.jpg
categories:
  - Divers
tags:
  - aws
  - azure
  - Bellacenter
  - CERN
  - cisco
  - Copenhague
  - envoy
  - ibm pivotal
  - Kubecon
  - KubeCon Europe
  - KubeCon2018
  - Kubernetes
  - nginx
  - prometheus
  - root
  - turbine labs
  - VMware
  - zalando

---
## Premier jour de KubeCon aujourd’hui !

Hier soir, je suis arrivé à Copenhague pour participer à la KubeCon + CloudNativeCon Europe 2018. Vous ne savez pas de quoi il s’agit ? C’est LA conférence sur 3 jours, organisée par la CNCF, qui parle de Kubernetes et tout ce qui gravite autour.

Ce n’est pas la première conf que je couvre sur le blog, j’avais déjà fais [un récapitulatif de la Hack-It-N 2018](/2018/01/26/recap-hack-it-n-2018/).


![](/2018/05/20180502_090306.jpg)


> On est environ 4300...

La journée a commencée par des Keynotes, ponctuées par des petites interventions de Liz Rice et Kesley Hightower. La plupart étaient un peu humoristiques, mais j’ai retenu ceci parmis les keynotes du matin :

### Où en sont les projets de la CNCF ?

_Keynote: CNCF Project Update - Liz Rice, Technology Evangelist, Aqua Security; Sugu Sougoumarane, CTO, PlanetScale Data; Colin Sullivan, Product Manager, Synadia Communications, Inc. & Andrew Jessup, Co-founder..._

Cette année, le moins que l’on puisse dire est que la CNCF a réellement pris de l’ampleur, en terme de projets notamment.

L’ajout de plusieurs projets à l’état « Sandbox » :

Rook (abstraction du stockage), One Policy Agent (politiques de sécurité pour l’ensemble de la stack), SPIFFE (langage de spec) & SPIRE (runtime env) qui a pour but d’établir un lien de confiance entre l’infrastructure et les workloads.

Plusieurs projets sont à l’état « Incubator » :

CoreDNS, Linkerd (service mesh), Envoy (distributed proxy), Prometheus, OpenTracing, Jaeger (distributed tracing), Fluentd (Splunk Entreprise connector + fluentd daemonset for kubernetes), Fluent bit (client lightweight un peu comme Beats d’Elastic), NATS (messaging), Container Network Interface (CNI), gRPC (client/server), Container runtime (Containerd / Kubernetes CRI), TUF (The Update Framework), Notary, Vitess (distribution de données sur MySQL avec Sharding/resharding automatic)

La liste est vertigineuse.

Kubernetes est également passé à l’état « Graduated » (premier projet CNCF a passé à l’état « production ready » pour la plupart des projets informatiques, pas seulement pour les tech enthousiasts et les early adopters.

Si j’ai tout listé, c’est que l’ensemble de ces projets ont par la suite droit à une ou plusieurs confs et j’aurai l’occasion de revenir dessus si je participe aux confs en question.

### Re-thinking Networking for Microservices

_Keynote: Re-thinking Networking for Microservices - Lew Tucker, VP/CTO Cloud Computing, Cisco Systems, Inc._

Le CTO Cloud Computing de Cisco est venu nous expliquer que maintenir l’ensemble des services permettant au microservice d’échanger avec le monde extérieur, c’est compliqué, et qu’il vaut mieux utiliser du service mesh (découpler tous les services de communication et externes aux services comme logging, api, auth, ...).

### REX du CERN

[_Keynote: CERN Experiences with Multi-Cloud Federated Kubernetes_][3]

On ne présente pas le CERN (mais en fait on a quand même eu droit à une présentation ;-p ), mais au delà des travaux scientifiques, il faut des ops pour faire tourner la puissance de calcul brute.

10000 hyperviseurs, des quantités de données très importantes (1 Po/s généré, 10 Go/s enregistré).

Malgré cette force de frappe plus qu’honnête, lors de grosses campagnes de calculs scientifiques, il faut tirer parti de ressources externes (clouds, universités), ce qui induit la nécessité d’un outils permettant de fédérer des machines provenant de tous horizons.

Le CERN utilise la fédération de cluster de Kubernetes, avec en plus l’outil [HTCondor][4] qui étend l’API de Kubernetes et leur permet de lancer les jobs sur les machines (distantes ou pas) en fonction du job demandé.

### Mini talk du VP & Chief Open Source Officer de VMware

_Keynote: From Innovation to Production - Dirk Hohndel, VP & Chief Open Source Officer, VMware_

Au delà du présentation plus que rapide des produits opensource sur lesquels contribue VMware, (Harbor, pivotal, BOSH), Dirk Hohndel a surtout utilisé les 5 minutes qu’il avait pour nous faire remarquer que les gens de l’audience sont en grande majorité des hommes blancs et qu’il y a un vrai problème de mixité dans nos métiers. J’ai regardé autour de moi, difficile de lui donner tort.

## Et les vraies conférences ont pu commencer !

### Pourquoi y a-t-il autant de runtimes ?

[_Whats Up With All The Different Container Runtimes? - Ricardo Aravena, Branch Metrics_][5]

Ricardo Aravena a brossé un tableau de l’évolution des containers runtimes sous Linux, puis a listé leurs avantages et leurs inconvénients. Un talk plutôt sympa en mode comparaisons et Pros/Cons sur les différents runtimes du marché.

### Créer et gérer une communauté open source

[_Building an Open Source Community to Achieve Innovation-Through-Openness - Jonas Rosland, {code}_][6]

Un talk « non technique » auquel j’avais vraiment envie d’aller. J’avais été assez surpris de remarquer l’ouverture de Dell EMC en 2015 avec l’équipe {code}, alors forcément, un REX sur comment gérer une communauté open source et le erreurs qui ont pu être faites m’intéressait forcément.

Au final, le talk, même s’il est resté très haut niveau, a donné de bons conseils (planification de la roadmap, transparences, SIGs, focus sur les individus plus que les projets) et des ressources complémentaires (opensource.com guides, codeofconducts), qui n’existaient pas à l’époque où {code} s’est mise en place.

### REX de Turbine labs a propos de leur migration de nginx vers envoy

[_Replacing NGINX with Envoy in a Traffic Control System - Mark McBride, Turbine Labs, Inc_][7]

Le CEO de Turbine Labs nous a fait un REX sur un changement majeur qu’ils ont eu à réaliser sur leur produit : le changement de **nginx** (limité pour leurs besoins spécifiques) pour **Envoy**. Ce changement impliquait (1) d’écrire une partie des features manquantes dans Envoy (extensions maisons spécifiques à Turbine Labs pour leurs besoins propres) et la façon la plus progressives de migrer ce composant central dans leur architecture.

![](/2018/05/20180502_141232-2.jpg)

Si le talk était intéressant en soit (et permet d’avoir un premier aperçu de Envoy), c’était aussi l’occasion de se poser les bonnes questions pour tout migration, qu’elle qu’elle soit.

### REX Zalando, la mise à jour des clusters Kubernetes

[_Continuously Deliver your Kubernetes Infrastructure - Mikkel Larsen, Zalando SE_][9]

Le site de e-commerce Zalando est quelque chose d’assez énorme. On ne s’en rend pas forcément compte, mais ce sont des dizaines de clusters Kubernetes qui sont nécessaires pour gérer la partie développement des nouvelles applications.

Zalando est connue comme faisant partie des sociétés qui communiquent beaucoup sur leurs (bonnes) pratiques en terme d’IT. D’ailleurs l’amphi était plein à craquer :

![](/2018/05/20180502_144136_HDR.jpg)


Mikkel Larsen n’y a pas coupé et nous a méthodiquement expliqué pas à pas tout ce qui était mis en place pour assurer (1) des mises à jours des clusters Kubernetes complètement transparentes et quasi automatiques, et (2) des test ends to ends complet permettant de repérer des régressions mêmes subtiles.

Côté technique, Zalando travaille sur AWS, sur plusieurs availability zones, avec des Stack Cloud Formations, 1 seule AMI pour toutes les VMs, des clusters etcd externalisés des nœuds Kubernetes (rendant les masters stateless, et donc plus facile à mettre à jour), ...

### The Route to rootless container

[_The Route To Rootless Containers - Ed King, Pivotal & Julz Friedman, IBM_][11]

Je ne vais pas le cacher, je suis allé pour le titre de la conf et je n’ai pas été déçus côté clins d’œils / memes (ni par le contenu, mais c’est toujours plus agréables quand les speakers sont bons).

Si Ed King et Julz Friedman ont commencé par dire qu’ils étaient contents qu’autant de gens soient présents pour un « sujet aussi basique », le talk n’était clairement pas à destination de débutants !

Point par point, ils ont expliqué quels technologies et couches de sécurités étaient disponibles, contre quoi elle protégeaient et ne protégeaient pas. Dans une seconde partie, ils ont ensuite expliqués comment réussir à faire fonctionner des containers exécutés côté hôte par un utilisateurs non privilégié mais privilégié au sein du container. Mais surtout, pourquoi ça fonctionne et pourquoi ça n’était pas grave.

Une vraie surprise car j’avais mal compris la conf (je pensais qu’on allait expliquer comment faire pour que les applications ne soient pas root DANS le container).

### Améliorer la sécurité des workloads Kubernetes avec la virtualisation matérielle

[_Improving your Kubernetes Workload Security with Hardware Virtualization - Fabian Deutsch, Red Hat & Samuel Ortiz, Intel_][12]

Une conf’ amusante où deux projets dont le but est de faire tourner des workloads Kubernetes dans des machines virtuelles (Kata et KubeVirt), _soit disant non concurrents,_ ont été présentés en même temps.

La subtilité, selon eux, c’est que :

  * Kata containers est plutôt à destination des personnes qui souhaitent : 
      * ajouter une couche de sécurité/ségrégation supplémentaire à la conteneurisation simple en ajoutant l’isolation via la virtualisation matérielle
      * utiliser des kernels différents pour des containers différents sur un même groupe d’hôtes Kubernetes
  * Kubevirt permet l’adoption plus rapide de Kubernetes en permettant l’ajout des workload de type legacy « non containerisables » dans un cluster Kubernetes. Ces workloads deviennent des Pods qui tournent dans Kubernetes, ce qui a l’immense avantage d’ajouter toutes les fonctionnalités de Kubernetes sur les Pods, mais aussi la gestion de réseau et du stockage.

A vous de me dire si vous êtes convaincus qu’il faut absolument 2 projets ;-).

## Et vous reprendrez bien quelques keynotes

### Anatomy of a Production Kubernetes Outage

_Keynote: Anatomy of a Production Kubernetes Outage - Oliver Beattie, Head of Engineering, Monzo Bank_

Un postmortem d’un incident qui a bloqué la prod d’une banque « digital native ». Très bien présenté et d’autant plus intéressant que les « erreurs » qui ont été faites tendent plus de la malchance et de fausses bonnes idées que de l’erreur a proprement parler; il était très facile de m’imaginer à la place des équipes qui ont géré cet incident.

### Container Native Dev and ops Experience

_Keynote: Container-Native Dev-and-ops Experience: It’s Getting Easier, Fast. - Ralph Squillace, Principal PM – Azure Container Platform, Microsoft_

Je ne vais pas mentir, je suis un peu passé à côté de cette keynote. Ralph Squillace nous a fait une démo en live de code qui se déploie, se débugue et tourne sur Kubernetes pour nous prouver à quel point c’est simple. Moui, ok.

Au delà de ça, j’ai surtout remarqué que son PC était sous Ubuntu. Venant de quelqu’un qui bosse chez Microsoft (même si c’est une team Kubernetes), c’est quand même quelque chose qui aurait été impensable il y a quelques années ;-p

![](/2021/tweet_kubecon_2018.png)

### Cloud native observability & security

_Keynote: CNCF End User Awards - Presented by Chris Aniszczyk, COO, Cloud Native Computing Foundation_

Un résumé des annonces faites aujourd’hui par Google à l’occasion de la Kubecon.

  * gVisor, un système révolutionnaire qui va résoudre tous les pb de sécurité des containers
  * stackdriver, un outil de monitoring (observability) génial, qui rendre nos vies géniales

Peut être que le format était mal choisi, mais je suis extrêmement sceptique et je vais attendre d’en savoir plus ;)

### Prometheus 2.0

_Keynote: Prometheus 2.0 – The Next Scale of Cloud Native Monitoring - Fabian Reinartz, Software Engineer, Google_

Une tonne de slides pour nous brosser l’historique de Prometheus dans un premier temps, puis nous expliquer qu’un gros problème est arrivé, la TSDB de Prometheus était trop lente sur de très gros workloads. Déluge de slides pour nous montrer à quel point Prometheus 2 est bien meilleur.

Maintenant c’est mieux.

## Et demain ?

Et bien demain rebelote (enfin si je poste pas très vite, on va déjà être demain...).

Si ça vous intéresse, vous pouvez suivre les confs que je vais voir sur [kccnceu18.sched.com/d.germain](https://kccnceu18.sched.com/d.germain).

 [3]: https://schd.ws/hosted_files/kccnceu18/d0/CERN.pdf
 [4]: https://research.cs.wisc.edu/htcondor/
 [5]: https://schd.ws/hosted_files/kccnceu18/08/What%E2%80%99s%20Up%20With%20All%20the%20Container%20Runtimes.pdf
 [6]: https://schd.ws/hosted_files/kccnceu18/28/Building%20an%20Open%20Source%20Community%20-%20KubeCon%202018%20-%20Final.pptx
 [7]: https://schd.ws/hosted_files/kccnceu18/a6/Turbine%20Labs_Move%20to%20Envoy%20Deck_V2.pdf
 [9]: https://schd.ws/hosted_files/kccnceu18/18/2018-05-02%20Continuously%20Deliver%20your%20Kubernetes%20Infrastructure%20-%20KubeCon%202018%20Copenhagen.pdf
 [11]: https://schd.ws/hosted_files/kccnceu18/08/route_to_rootless_slides.pdf
 [12]: https://schd.ws/hosted_files/kccnceu18/9f/2018-03%20KubeCon%20EU%20-%20Improving%20your%20Kubernetes%20Workload%20Security%20with%20Hardware%20Virtualization.pdf
