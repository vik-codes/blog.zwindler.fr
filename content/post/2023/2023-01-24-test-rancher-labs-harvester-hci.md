---
title: Test (incomplet) de Rancher Labs Harvester, plateforme de virtualisation hyperconvergée 
authors:
  - zwindler
type: post
date: 2023-01-24T06:30:00+02:00
excerpt: Découverte et installation d'Harvester, le plateforme de virtualisation hyperconvergée de Rancher Labs
url: /2023/01/24/test-rancher-labs-harvester-hci/
image: /2023/01/harvester.png
categories:
  - Cluster
  - DIY
  - Système
  - Virtualisation
tags:
  - k8s
  - Kubernetes
  - rancher
  - HCI
  - Hyperconverged Infrastructure
  - Longhorn

---

## Je ne dirais pas que c'est un échec. Je dirais que ça n'a pas marché !

**Disclaimer !** 

Je vous préviens tout de suite, même si j'ai réussi à installer Harvester et avoir un cluster fonctionnel, j'ai eu beaucoup de mal à l'utiliser, car mes machines étaient trop peu puissantes pour le faire fonctionner.

En effet, en lisant la doc (lol, qui fait ça ?) je me suis rendu compte que les prérequis sont relativement élevés :

![](/2023/01/requirements.jpeg)

> Harvester : great for "edge HCI" !
>
> Also Harvester : 16-core/64 GB RAM or above preferred for production

Je ne vais donc pas totalement au bout du test, ne soyez pas déçu / vous êtes prévenus.

![](/2023/01/pas_marché.png)

## Lab maison

Il y a quelques mois, j'ai décidé d'acheter des petites machines pour me faire un "lab" à la maison.

L'idée était de pouvoir tester des technos telles que des hyperviseurs, sans galérer avec des VMs (et avoir des perfs pourries en "nested virt") ou galérer avec les interfaces types ILO pas toujours très bien supportées par les différents hébergeurs "pas chers".

Pour éviter de me ruiner, j'ai décidé d'acheter d'occasion 3 Dell micro (pour avoir un nombre impair de machines) de la gamme 3050 ou équivalent et avec les caractéristiques suivantes :
* i5-6500T à 4 cores
* entre 4 et 16 Go de RAM DDR3(L) ou DDR4
* un emplacement 2"5 SATA et éventuellement un emplacement NVMe

![](/2023/01/lab.jpg)

D'abord, ces machines sont assez peu couteuses (entre 100 et 150€ sur LeBonCoin ou les reconditionneurs en cherchant bien). Ensuite, elles consomment très peu grâce au i5-T (autour de 10w en idle) ce qui me permet de les laisser allumées quelques heures sans me sentir mal pour ma facture d'électricité ou la planète. Enfin, elles sont super compactes, presque silencieuses et jolies. On est loin du rack qui fait tâche dans le salon.

Une fois que je les ai reçues, je vous ai demandé sur Twitter/Masto ce que vous vouliez que je mette dessus. Parmis vos réponses, c'est Harvester qui a attiré ma curiosité parmis vos réponses.

## Mais c'est quoi Harvester ?

[Harvester](https://www.rancher.com/products/harvester) est un produit de chez Rancher Labs (compagnie achetée par Suse en 2020).

![](/2023/01/harvester.png)

> Harvester is the next generation of hyperconverged infrastructure designed for the modern cloud-native environment.

C'est donc un produit de virtualisation, dans la gamme des solutions "hyperconvergées", où le stockage de chaque *noeud* est mis dans un pool commun de stockage distribué. 

Vous avez sûrement entendu parler de Nutanix ou de VMware vSAN, ou peut être de Proxmox VE qui propose un cluster Ceph natif, pour faire la même chose en open source.

Ce que met en avant en premier Rancher, c'est que Harvester est un outil **simple** à utiliser.

> Hyperconverged infrastructure doesn’t need to be complex or expensive. With Harvester and Rancher, IT operators now have access to an enterprise-ready, simple-to-use infrastructure platform that cohesively manages their virtual machines and Kubernetes clusters alongside one another. 

Ok, why not. Mais là où ça se complique, c'est quand on creuse un peu sur **comment** c'est fait :

> Built by the Rancher engineering team, Harvester is powered by 100% open source cloud native technology including Kubernetes, Longhorn and Kubevirt. 

Mkay. Utiliser Kubernetes pour faire des VMs, ça "marche" (Kubevirt), mais c'est clairement pas l'idée que j'aurais en premier.

## Techniquement c'est quoi ?

Pour aller voir de plus près comment ça marche, le plus simple est d'aller voir le repository officiel de harvester (c'est open source, tout est disponible sur Github.com).

Le plus intéressant est ce fichier [harvester/deploy/charts/harvester/Chart.yaml](https://github.com/harvester/harvester/blob/master/deploy/charts/harvester/Chart.yaml) dans lequel on peut voir tout ce qui est déployé par défaut sur nos machines Harvester :
* kubevirt-operator
* harvester-network-controller
* harvester-node-disk-manager
* csi-snapshotter
* longhorn
* kube-vip
* harvester-load-balancer
* whereabouts
* harvester-node-manager

Ca fait pas mal de composants et ça explique certainement les requirements élevés en nombre de CPUs minimum (on a tendance à **réserver** plus de CPU qu'on en consomme sur les composants techniques d'un cluster Kubernetes, par sécurité).

## Voyons voir comment ça s'installe.

Bon là, c'est relativement classique, on peut booter Harvester via un serveur PXE ou [l'installer via un ISO avec une clé USB](https://docs.harvesterhci.io/v1.1/install/usb-install).

J'avais la flemme de monter un serveur PXE (mais il va falloir que je m'y mette, on en reparlera dans un autre article, cela dit) donc je suis resté simple et efficace.

Un petit coup de [balena Etcher](https://www.balena.io/etcher/) et on en parle plus.

```bash
wget https://releases.rancher.com/harvester/v1.1.1/harvester-v1.1.1-amd64.iso

chmod +x balenaEtcher-1.13.1-x64.AppImage
./balenaEtcher-1.13.1-x64.AppImage
```

![](/2023/01/balena.png)

On a ensuite une interface d'install assez basique et plutôt simple dans laquelle on renseigne hostname, IP, token pour créer ou joindre un cluster existant. Dans un contexte plus pro/industrialisé, le boot PXE et une config automatisée prendront évidemment tout leur sens.

![](/2023/01/iso_install.jpg)

> non, ce n'est pas de la neige sur l'écran, il est juste affreusement sale...

Effectivement, je n'ai eu aucun souci à ce niveau et c'était très simple. Une fois l'installation de nos 3 noeuds terminée, on se retrouve avec une interface comme celle ci :

![](/2023/01/harvester_cluster_ok.jpg)

## On se connecte

Maintenant qu'on a un cluster fonctionnel, on peut aller faire un tour sur l'interface de management.

On nous avait promis quelque chose de simple et c'est pas des blagues ! C'est simple, pour ne pas dire simpliste.

![](/2023/01/menu1.png)

Un menu pour les VMs, un pour les volumes, un pour le réseau, un pour les backups (et quelques autres).

## La première VM

On ne perd pas de temps, je suis tout de suite allé créer un VM (on est quand même là pour ça).

Préalablement, c'est mieux si on a créé un *Namespace* (oui, vous vous souvenez c'est du Kubernetes !) et uploadé une clé SSH. Le menu reste simple, on est proche de ce qu'on va trouver chez les grands cloud providers, par exemple.

![](/2023/01/vm1.png)

Il y a juste une petite subtilité pour ce qui est de la création de volumes, je trouve le wizard pas hyper clair la première fois. Pour créer la VM, il va vous falloir probablement soit un ISO, soit un volume que vous aurez préalablement créé contenant l'OS sur lequel booter. 

Sauf que l'interface ne parle que de "disques" sans plus de détails. Il faut comprendre qu'on va ajouter un CDROM (ISO) et un disque (HDD).

Et il faut changer de menu pour uploader l'ISO, car on ne peut pas le faire directement dans le menu de création de VM. 

On a vu plus simple comme UX d'un hyperviseur. Heureusement l'interface des ISOs a quand même l'avantage de proposer de rentrer une URL et de DL le fichier pour nous (comme Proxmox VE), ce qui gagne du temps.

![](/2023/01/iso1.png)

![](/2023/01/iso2.png)

On peut ensuite ajouter à notre VM des volumes (en cliquant sur Volumes dans le menu au milieu à gauche) et ajouter l'ISO et un volume vide.

![](/2023/01/vm2.png)

Ce qui est intéressant ici, c'est que mon volume est provisionné dans le stockage `longhorn`, à savoir, le fameux pool de stockage distribué aggrégeant les disques de tous mes serveurs, géré "automagiquement".

Si j'ajoute des noeuds, le stockage s'étend. Si j'en retire, toutes les données sont redistribuées.

Ca me fait toujours un peu flipper ce genre de solutions. Quand "ça se passe mal", c'est quand même bien d'avoir la main et j'aurais probablement plus confiance dans un Ceph (sur Proxmox VE) sur lequel j'ai plus facilement la main pour réparer/rebalance, que sur un longhorn prépackagé pour moi.

Mais peut-être que c'est juste une histoire d'habitude et que ça se gère tout aussi bien.

## On la boote, cette VM ?

Une fois configurée, on peut donc commencer à booter notre VM et voir si elle fonctionne comme attendue.

Et c'est là où les choses ont commencé à sérieusement se gâter pour moi. En effet, je l'ai dit tout au début de l'article, mes machines ne sont tout simplement pas assez puissantes pour héberger une solution hyperconvergée de ce type.

Les SSDs étaient trop lents (je n'ai pas encore investi dans des NVMe pour avoir les données séparées du disque SATA de l'OS) et surtout, les CPUs étaient au max.

Sans aucune VM, à vide, Harvester réserve déjà quasiment les 4 CPUs de mes 3 machines. Pire, sur la machine harvester01, l'interface me disait réserver plus de cores que ce que la machine disposait (4.5 cores). Niveau RAM, ça allait même si à l'usage 10-12 Go par machine aurait probablement été juste.

![](/2023/01/ressources.png)

Le résultat était que la plupart des fonctionnalités étaient extrêmement lentes. Ma VM a mis une 20aines de secondes à se créer puis booter.

![](/2023/01/vm3.png)

Même la navigation dans l'interface était parfois pénible. J'ai mis plusieurs minutes avant de pouvoir afficher la console VNC de ma VM. Le stockage avait du mal à se synchroniser entre les nodes.

![](/2023/01/vm4.png)

Je ne parle même pas de tester des fonctionnalités plus avancées comme les live-migrations, les snapshots, les backups/restaurations. J'ai donc décidé de finir d'explorer les menus puis de couper court à l'essai.

## Les autres menus

Au-delà de la partie purement HCI (hyperconverged infrastructure), Rancher Labs met en avant le fait qu'il existe de belles synergies entre Harvester et Rancher. Typiquement, il est possible de gérer ses clusters Harvester depuis Rancher (si j'ai bien compris) et inversement de créer plus facilement des clusters Kubernetes/Rancher grâce à Harvester.

N'ayant pas du tout l'infra pour tester, je ne peux pas trop juger de la pertinence de cette fonctionnalité.

J'ai aussi trouvé intéressant l'ajout d'extension directement dans l'interface d'Harvester. On est proche de l'expérience Kubernetes packagée par certains cloud providers qui fournissent presque plus un PaaS propulsé par Kubernetes qu'un KaaS.

On peut très facilement déployer une stack de monitoring Prometheus ou de logging avec fluentbit

![](/2023/01/extensions.png)

![](/2023/01/extensions2.png)

Je n'ai pas testé non plus, mais il existe des providers terraform officiels assez complets qui permettent d'automatiser pas mal d'actions. Je ferai peut être un test avec un update de l'article.

* [registry.terraform.io/providers/harvester](https://registry.terraform.io/providers/harvester/harvester/latest/docs)

## Conclusion && pour aller plus loin

J'imagine que comme moi, vous restez sur votre faim. Je n'ai vraiment pas pu aller loin à cause de mes problématiques de matériel. Si vous voulez en savoir plus, je vous invite donc à regarder la vidéo [Harvester deep dive](https://youtu.be/hu6p4CPXSDI) avec Saiyam Pathak (Kubesimplify) et Guangbo Chen (Rancher Labs).

Personnellement, comme pour mon précédent test de [RancherOS (un autre produit Rancher Labs)](https://blog.zwindler.fr/2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/), j'ai du mal à bien comprendre à **qui** s'adresse ce genre d'outils.

Harvester est présenté comme une solution HCI basée sur Kubernetes mais **avec une interface simplifiée à l'extrême** pour permettre à des opérateurs IT (vos équipes IT traditionnelles, disons) qui ne maîtrisent pas ces technos, de le gérer. La simplicité est vraiment l'argument principal mis en avant et l'interface reflète cette promesse.

Mais... au-delà des éventuelles synergies avec l'écosystème Rancher Labs... pourquoi est ce qu'une équipe IT aurait **envie** d'installer un hyperviseur basé sur Kubernetes (+ Kubevirt + longhorn) ???

Des solutions de virtualisation **vraiment** simples existent sur le marché (qu'elles soient open source ou pas, on-prem ou managées). Kubernetes n'est pas pensé pour faire du [Pet (vs Cattle)](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/) et ce n'est clairement pas dans un usecase d'hyperviseur simple que je le mettrais en avant.

Dernier point, dans un monde où l'électricité coûte un bras et où tout le monde se targue d'être plus green que green (c'est pour la planète), peut-on vraiment accepter qu'une solution de virtualisation demande des prérequis en ressources aussi importants ? 

Peut-être que j'ai tout faux, mais tout ça me parait assez peu efficient...
