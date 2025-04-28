---
title: Récap du premier jour de Kubecon Europe 2022 - Mercredi
authors:
  - zwindler
type: post
date: 2022-05-18T22:00:00+00:00
excerpt: "Récap' du premier jour (mercredi) de la KubeCon + CloudNativeCon Europe 2022"
url: /2022/05/19/kubecon-eu-2022-jour-1-mercredi
image: /2022/05/PXL_20220518_062030468.MP.jpg
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
* Récap du premier jour de Kubecon Europe 2022 - Mercredi
* [Récap du deuxième jour de Kubecon Europe 2022 - Jeudi](/2022/05/20/kubecon-eu-2022-jour-2-jeudi)
* [Récap du troisième et dernier jour de Kubecon Europe 2022 - Vendredi](/2022/05/22/kubecon-eu-2022-jour-3-vendredi)

## Good morning Kubecon Europe !

2022, c'est l'année du retour de beaucoup de conférences IRL, notamment un événement que j'affectionne particulièrement : la Kubecon !

![](/2022/05/PXL_20220518_064437765.jpg)

La Keynote d'ouverture a été animée par Priyanka Sharma, Executive Director de la Cloud Native Computing Foundation.

Cette keynote était l'occasion de faire passer quelques chiffres sur l'évolution de la Kubecon, et aussi de communauté "cloud native".

J'ai choisi de retenir :
* première Kubecon pour 65% des participants de cette conférence 
* 7000 participants / 10000 online (en plus ou en tout ?)
* 7M de développeurs contribuent à l'écosystème

![](/2022/05/PXL_20220518_070705043.jpg)

La keynote a été ponctué par plusieurs interventions (Je ne vais pas mentir, certaines ne m'ont pas laissé un souvenir impérissable...)

Je citerai Van Jones (CNN) qui nous a parlé de collaboration (et de pourquoi c'est difficile)

> Disagreement is constructive. Disrespect is destructive

Nous avons eu aussi une intervention filmée de Ihor Dvoretskyi, un senior dev advocate de la CNCF qui se trouve être également Ukrainien.

> You may think that you can't do anything. You have given us hope

Dans les petites news, la prochaine Kubecon aura lieu à Amsterdam, une nouvelle certification de la CNCF arrive (Prometheus certified Associate) ainsi qu'une "Certified CNF" (pour les telco) que Priyanka a quasiment sauté, car nous étions très en retard.

## 7 Years of Running Kubernetes for Mercedes-Benz

La keynote suivante était un REX de Mercedes-Benz (Sabine Wolz, Peter Mueller, Jens Erat), "very early adopter" de Kubernetes puisqu'ils ont commencé à l'utiliser dès la version 0.9 !

Ils ont commencé par peindre une situation (en 2014) bien connue de nombreux ops :
* Infrastructure optimisée pour les coûts, pas pour la vitesse
* Infrastructure optimisée pour la gouvernance aisée, par pour la dev-experience

Demander une VM à l'infra pouvait prendre des semaines, les logiciels étaient à sources fermées, les logiciels open source devaient être explicitement autorisés, ... Souvenirs, souvenirs.

2015 a été le déclic. Une équipe de développement a essayé de lancer le devops, avec l'utilisation de 100% de logiciels FOSS, l'autonomisation des développeurs (you build it, you run it, mise à dispo d'API pour déployer soi même), amélioration continue, etc. Le "lead time" est passé progressivement de jours à minutes dans certains cas.

![](/2022/05/PXL_20220518_080409505.MP.jpg)

Au début, les contributions des développeurs sur les logiciels open sources devaient être faites sur leur temps personnel (!!!), mais depuis, MB a un FOSS manifesto, qui autorise et incite tous les développeurs à contribuer.

Finalement un bel exemple à suivre.

## Finding Your Power to Accelerate to a Sustainable Future

Kate Mulhall et Emma Collins de chez Intel ont ensuite parlé de green IT, d'écoconception et de comment améliorer l'informatique pour consommer moins.

Je n'ai pas exactement compris qu'elles étaient les solutions qu'elles proposaient. 

Par exemple, un des chiffres mis en avant : les CPUs sont utilisés qu'à 20-40% de leur utilisation en moyenne. OK, mais on fait quoi pour améliorer ça ? Est-ce qu'un serveur qui consomme 100% de CPU consomme significativement moins que 5 serveurs qui en consomment 20 (tout compris) ?

Elles ont ressorti une étude (sans la sourcer) sur les langages de programmation qui consomment plus ou moins (dans quels cas ? en quelle année ?).

![](/2022/05/PXL_20220518_081335230.MP.jpg)

Ce talk était surtout une excuse pour parler (je pense) du nouveau SIG "CNCF Environmental Sustainability WG".

A voir ce qu'il y a dedans et si cela apporte des solutions concrètes.

## Incremental Deep Learning For Satellite with KubeEdge and MindSpore

L'avant dernière keynote de la journée était une keynote de Huawei. Xiaoman Hu, Zhipeng Huang et Yue Bao nous ont parlé de solutions open source sur lesquelles Huawei contribue dans le domaine des Low Earth Orbit Satellites.

En particulier, KubeEdge, KubeEdge Sedna et MindSpore, des projets qui permettent de gérer des workloads containerisés et des modèles de machine learning (léger) sur des flottes de satellites à basses orbites.

Ce talk a été l'occasion pour moi de découvrir l'architecture de KubeEdge. La présentation sur MindSpore était malheureusement inaudible (son de très mauvaise qualité, amplifié par les enceintes et l'écho de la salle).

## Supporting the Community – So Open Source Projects Can Grow and Thrive

La dernière keynote, de Le Tran de chez Kasten est celle qui m'a le plus intéressé après celle de Mercedes Benz.

Le Tran a expliqué comment ils travaillaient pour améliorer la vie et la santé des communautés de logiciels open source. Il a cité 4 piliers :
* Avoir le temps
    * il faut donner du temps aux employés pour qu'ils contribuent sur des projets open source (et même l'encourager)
* Avoir une vision claire
    * avoir une gouvernance claire, une roadmap publique, des guides pour contribuer a un impact fort sur les contributions externes
* Ressources et documentation
    * Les projets open source doivent faciliter l'intégration et les contributions de membres novices
    * Mettre à disposition de la documentation de qualité, des tutos vidéos, etc.
    * Créer des rassemblements réguliers, des espaces de discussions permanents type Slack, etc
* Promouvoir l'open source par défaut (open source first)

D'après ce que Kasten a pu vérifier sur plusieurs projets, ces approches donnent de réels résultats sur l'augmentation des communautés et des contributions.

## West Side CD: The Deployment Ballet Goes On

Je ne vais pas mentir, je suis allé voir ce talk en partie pour le titre (joli blague).

Benoit Moussaud, dans l'équipe VMware Tanzu, nous a présenté [Cartographer](cartographer.sh), un outil qui vise à résoudre plusieurs challenges que rencontrent les équipent qui mettent en plus des plateformes de CI/CD. C'est un projet récent (8 mois) mais actif. Benoît l'a présenté comme "an opinionated way to do CICD", pour plusieurs raisons.

![](/2022/05/PXL_20220518_091354554.MP.jpg)

D'abord, Cartographer a choisi de renverser le pattern de l'orchestration de la CICD, pour passer sur de la Chorégraphie (everyone knows its part). Pour faire simple, ce n'est pas les tests (valides) qui appellent la création d'un artifact, mais la génération de l'artifact qui génère le lancement des tests.

Ensuite, pour éviter que chaque équipe ne réimplémente à chaque fois les pipelines de livraison, Cartographer apporte une couche d'abstraction au-dessus de tout ça. Cartographer met à disposition des "blueprints" où chaque équipe n'a qu'à piocher pour créer sa pipeline.

A tester, mais j'ai un peu peur vu les captures d'écrans que j'ai pu voir, que pour tout ce qui est configuration, ce soit un peu une "usine à gaz" (mais je peux me tromper).

## Effective Disaster Recovery: The Day We Deleted Production 

Clairement, c'était un talk à voir (mon coup de coeur de la journée). D'ailleurs, la salle était pleine à craquer avec des gens assis par terre et debout dans les allées.

Ce talk de Rick Spencer & Wojciech Kocjan de chez InfluxData était un REX d'un incident qu'ils ont eu en prod.

Suite au merge d'une PR (de YAML), qui en apparence ne faisait qu'ajouter des choses, ArgoCD a trashé un cluster Kubernetes de production.

![](/2022/05/PXL_20220518_100343755.MP.jpg)

Tout est parti d'une erreur (mauvais copié collé dans une PR) qui a introduit un conflit de nom dans une ressource déployée par Argo.

Je ne vais pas spoiler le talk car il vaut vraiment le coup d'être vu quand les replays seront disponibles. Les speakers ont présenté :
* la cause
* la timeline des événements
* les actions jusqu'à la résolution
* le postmortem
* les actions correctives pour éviter que l'incident se reproduise dans le futur

Comme on dit sur Facebook, "ça fait réfléchir".

## Trampoline Pods: Node to Admin PrivEsc Built Into Popular K8s Platforms

Après la pause déjeuner, je suis allé voir le talk de Yuval Avrahami de Palo Alto Networks (Shaul Ben Hai étant absent). C'était encore un très bon talk.

En partant du fait que les containers ne sont pas une barrière de sécurité fiable, on peut imaginer un scénario dans lequel un attaquant a réussi à prendre le contrôle d'un container (car il avait une faille), PUIS, a réussi à sortir du container à cause d'une faille du kernel ou du CRI (il y en a eu plusieurs en 2022 déjà).

On part donc dans l'idée d'un node complet est compromis. Mais est ce que l'attaquant peut "rebondir" et prendre la main du cluster complet (aka être cluster admin) ?

Ce que Yuval nous a montré dans ce talk, c'est qu'il existe des workloads sur nos clusters (en particulier des DaemonSets) qui disposent de privilèges importants (pas forcément à première vue).

![](/2022/05/PXL_20220518_124304072.jpg)

Après avoir classifié les permissions "dangereuses", Yuval nous a fait une démo de rebond à partir de Cilium (corrigée depuis) et nous a présenté un outil [rbac-police](https://github.com/PaloAltoNetworks/rbac-police), permettant de faciliter ce genre d'audit sur nos clusters.

## Supporting Long-Lived Pods Using a Simple Kubernetes Webhook

Clément Labbe de Slack est venu nous parler d'un problème que de nombreux administrateurs de Kubernetes ont pu avoir dans le passé : certains Pods sont difficiles à tuer.

![](/2022/05/PXL_20220518_143314106.jpg)

Dans la liste des pods qu'il est embêtant de tuer, il a cité :
* des Batch-jobs (>1d)
* les caches distribués (warmup lent, datapull couteux)
* des Jenkins controllers (singleton)

Dans la vraie vie, il existe plein de cas où on va tuer ces pods pour pouvoir drain des nodes. Soit parce qu'ils sont trop vieux, soit parce qu'on veut faire une mise à jour, etc.

Clément nous a expliqué qu'ils ont fait ça en se basant sur des taints, des tolerations et un [admission webhook](https://github.com/slackhq/simple-kubernetes-webhook) (open sourcé).

La solution "fonctionne" mais c'est un peu bourrin. Je ne peux pas dire que je sois fan de la façon dont c'est fait. Si jamais ça vous intéresse, je vous laisse aller voir les slides ou le replay quand il sera disponible, pour bien comprendre.

Note : ce talk a été l'occasion pour moi de découvrir [bedrock CLI](https://github.com/microsoft/bedrock-cli), un outil permettant de générer le YAML d'objets Kube, que je ne connaissais pas. C'est toujours ça de pris ;-)

## Building a Nodeless Kubernetes Platform

Pour terminer, je suis allé voir un talk de William Denniss de chez Google Cloud. Peut-être que je n'ai pas été aidé par la fin de journée, mais j'ai trouvé le talk un peu long à devenir intéressant.

Note: Cette conférence, taguée "Serverless" sur Sched.com, ne parle à AUCUN moment de serverless. C'est un peu énervant. En vrai, le sujet était :

> Go behind the scenes of the creation of GKE Autopilot

Le but du talk était donc de voir les choix techniques et fonctionnels qui avaient été faits (et surtout pourquoi) lors de la création de l'offre GKE Autopilot de Google Cloud.

GKE, dans lequel on peut encore accéder aux VMs.  Autopilot, c'est la promesse de ne plus du tout avoir à gérer les nodes de Kubernetes (aka, ne plus du tout y avoir accès)

> Managed Kubernetes goal doesn't aim to simplify use of Kubernetes. It simplifies the task to install and manager Kubernetes nodes.

Nous avons donc passé en revu une bonne partie des choix techniques qui ont fait Autopilot, à savoir :
* utiliser des VMs comme pour GKE parce que c'est plus simple pour colocaliser des ressources "multi single-tenant" dessus
* une visibilité sur les nodes, mais pas d'API pour interagir avec
* pas de possibilité de s'y connecter (surtout pas par SSH)
* pas de pod disposant de capabilities permettant de rebondir sur le node (priviledged, mounting root FS, etc)

Les décisions intéressantes (par exemple, comment gérer le choix automatique de la taille des VMs instanciées) ne sont arrivés qu'à la toute fin.

## After LaunchDarkly, HoneyComb, Kong

Nous avons fini, Christian et moi, par un afterwork dans un bar au pied de la plage, dans lequel nous avons rencontré et échangés avec plusieurs de nos pairs. 

C'était vraiment très sympa :)

![](/2022/05/PXL_20220518_180024534.MP.jpg)

(Merci LaunchDarkly pour l'invitation)

## Ce que j'aurais aimé voir

Si jamais pu me cloner (plusieurs fois), je serais probablement aussi allé voir :

* Multi-cluster Failover Using Linkerd - Charles Pretzer, Buoyant, Inc.
* Kubernetes is Your Platform: Design Patterns For Extensible Controllers - Rafael Fernández López, SUSE & Fabrizio Pandini, VMware
* This is The Way: A Crash Course on the Intricacies of Managing CPUs in K8s - Swati Sehgal, Red Hat & Marlow Weston, Intel
* Bypassing Falco: How to Compromise a Cluster without Tripping the SOC - Shay Berkovich, BlackBerry
* Seeing is Believing: Debugging with Ephemeral Containers - Aaron Alpar, Kasten
* Securing Kubernetes Applications by Crafting Custom Seccomp Profiles - Sascha Grunert, Red Hat
* Create Your First CNCF Serverless Workflow Project with Kogito and Knative - Ricardo Zanini Fernandes, Red Hat
* Network-aware Scheduling in Kubernetes - José Santos, Ghent University
* Autoscaling Kubernetes Deployments: A (Mostly) Practical Guide - Natalie Serrino, New Relic (Pixie team)
