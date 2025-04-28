---
title: 'CIVO : du kubernetes managé à partir de 4$/mois, vraiment ?'
authors:
  - zwindler
type: post
date: 2021-07-16T07:00:00+00:00
excerpt: "J'ai testé pour vous le kubernetes managé de CIVO, qui vante son utilisation de k3s et une tarification dès 4$ par mois"
url: /2021/07/16/civo-du-kubernetes-manage-a-partir-de-4-mois-vraiment/
image: /2021/07/PXL_20210715_193337426.jpg
categories:
  - Virtualisation
tags:
  - AKS
  - azure
  - k3s
  - Kubernetes
  - OVH
  - ovhcloud
  - scaleway

---
Pendant la [Kubecon EU 2021](/recherche/?keyword=kubecon+2021), un provider que je ne connaissais pas a mis le paquet pour s’assurer de la visibilité : [CIVO](https://www.civo.com). Et avec une promesse plus qu’alléchante : un Kubernetes managé basé sur [k3s (que j’adore](/2019/03/21/deployer-en-5-minutes-un-cluster-kubernetes-sur-arm-avec-k3s-et-ansible/)) et avec un tarif **à partir de** 4$/mois ! 

![](/2021/07/00_civo.png)

Chez les concurrents, on a rien sous les 15€ / mois (Scaleway), quand ce n’est pas 30 voire 80… De quoi piquer ma curiosité donc.

## Un de plus ?

J’ai donc pris un compte d’essai proposé par l’entreprise aux participants de la Kubecon et j’ai créé un compte.

La première chose que j’ai testé, c’est l’interface (il y a aussi une CLI). Forcément, chez un pure player, c’est simple et efficace, on s’y retrouve et l’interface est léchée. On est loin du gloubiboulga visuel de chez Azure (cf [mon test d’AKS](/2018/12/18/jai-teste-pour-vous-aks-la-plateforme-kubernetes-managee-dazure/)). Après, c’est un minimum... c’est forcément plus simple quand on commence de zéro et qu’on a pas des centaines de produits ;-p.

![](/2021/07/01_civo_dashboard.png)

On a un dashboard avec les opérations réalisées chronologiquement, un menu pour créer des clusters kube, un menu pour créer du compute et des LB « nus ». Rien de bien révolutionnaire, ça fait le job.

La partie « KubeQuest », c’est de la bête gamification (« Créez un cluster pour passer niveau 2!!! »), je ne m’y attarderai même pas.

## Bon, on le créé ce cluster à 4$ ?

Bon, ne vous enflammez pas, l’offre « à partir de 4$/mois » ne sera pas utilisable en prod, pas de miracle. Mais c’est déjà un tour de force qu’ils arrivent à le proposer, notamment grâce à k3s.

Pas de surprise, le pricing des nodes est immédiatement affiché, et voilà à quoi ça ressemble :

![](/2021/07/02_civo_4dollars.png)

Pour 4$ par mois, on vous propose un « cluster » d’un seul node, avec seulement 1 vCPU et 1 Go de RAM. Pas de quoi faire tourner grand chose d’autre que quelques containers nginx... Si ça jamais ça fonctionne ?! (on y reviendra)

Au delà, les prix sont similaires à ce que l’on trouve sur le marché « bon marché » (Scaleway notamment). Si on veut être un peu sérieux et comparer ce qui est comparable, on peut booter des machines avec 2vCPU et 4 Go de RAM à16$/mois l’unité (moins de ~13,5€ en ce moment).

## Kubernetes easy to install

La plupart des offres managées de Kubernetes (si ce n’est toutes) viennent avec une certaine quantité de personnalisation préinstallée. Chez Azure, vous pouvez choisir parti 2 CNIs et le dashboard (ou pas). Chez Scaleway si c’est Calico qui est préinstallé ou pas.

Chez CIVO, ils ont poussé le concept beaucoup plus loin, en reprenant l’idée de Rancher ou d’Openshift du « marketplace ».

Avant de boostraper votre cluster, vous avez accès à tout un magasin d’applications (ni plus ni moins que des charts helm avec une icône pour cliquer dessus) et éventuellement une très petite personnalisation avec un dropdown menu (mais vraiment trivial, très peu de choix).

![](/2021/07/03_civo_marketplace-2.png)

Et là, pour le coup en terme d’UX je trouve ça très très malin. En quelques clics, j’ai (dé)sélectionné les composants qui m’intéressent et ils ont été préinstallés pour moi avec mon cluster.

![](/2021/07/04_civo_security.png)

On peut même préinstaller des produits de sécurité, notamment Kyverno avec un ensemble de règles de sécurité préconfigurées.

## Et c’est pas fini !

Pour ce qui est des composants d’infrastructure, je comprend l’incentive. Pour certains devs, l’infra c’est ch\***t. 

> Mon cluster je le veux up and running sans perte de temps, sans pour autant que mes données soient à poil sur Internet

Mais comme tout ce qui « cache » la complexité du métier d’Ops (cf mon article « Au secours, le métier d’Ops va disparaître »), la difficulté n’est pas tant le déploiement que le « day 2 operations ». Et si vous voulez modifier un paramètre, vous êtes marrons.

Tout de même, préconfigurer cette partie dès le bootstrap du cluster est malin. Et ce qui est encore plus malin, c’est qu’ils ont open sourcé leur marketplace. 

Qu’est ce qu’ils y gagnent, me direz vous ? 

Et bien, s’il y a un nouveau « shiny composant » qui fait rêver tout le monde, vous pouvez aller faire une PR pour ajouter une tuile dans l’UI de CIVO. Comme ça vous bossez pour eux. Elle est pas belle la vie ? ;-p (je troll, mais je trouve ça cool, en vrai).

![](/2021/07/07_civo_githubpr.png)

## Et le cluster, il boote vite ?

C’est un peu la guéguerre entre Kubernetes managés à qui bootstrappera le control plane et les workers le plus vite. Azure met plus de 20 minutes. OVH bootstrappe le control plane en une minute mais met des plombes à sortir les VMs à cause de leur OpenStack. Exoscale fait le tout (control plane + workers) en moins de 2 minutes.

![](/2021/07/05_civo_creating-1.png)

CIVO nous promet 90 secondes et c’était pas loin d’être vrai. Je ne dirai pas que c’est les plus rapides mais ils sont dans le top 3 de tous les kubes managés que j’ai pu tester, sans hésiter.

Une fois le cluster opérationnel, on vous propose évidemment de télécharger votre kubeconfig et roule ma poule

![](/2021/07/06_civo_kubeconfig.png)

## Mais qu’est ce qu’on peut faire tourner dans Kube avec 1 (ou 4) Go de RAM ?

Le souci avec ce genre de « petites machines », c’est que si vous n’avez pas OS et kubernetes optimisés, une part non négligeable de la VM ne sera pas utilisable pour vos workloads et vous n’aurez que (dans le pire des cas) 2 Go de libre.

Et c’est là toute la « _malinerie_ » d’utiliser k3s plutôt qu’un k8s vanilla. k3s est spécialement pensé pour tourner sur des petites machines (en edge notamment). J’avais pu installer un master kubernetes sur un raspberry pi 1 (model B, 1 CPU ridicule et 512 Mo de RAM) tellement l'empreinte mémoire demandée est faible.

Associé à un magasin d’applications maison pré-tuné pour consommer peu (très petites requests pour fit les petites machines sans tout bloquer), on arrive avec des nodes quasiment sans overhead. Dans cet exemple, j’ai cliqué sur plusieurs composants (cert-manager, kyverno, ha-proxy, prometheus+alertmanager+grafana, metrics-server, falco). Je me retrouve avec des nodes (4vCPU 8Go) quasiment vides !

```
kubectl --kubeconfig civo-zwindler-kubeconfig top nodes  
NAME                                   CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
k3s-zwindler-deadbeef-node-pool-31af   230m         5%     945Mi           12%       
k3s-zwindler-deadbeef-node-pool-6609   97m          2%     471Mi           6%        
k3s-zwindler-deadbeef-node-pool-e07c   141m         3%     874Mi           11%    
```

Du coup, pour du lab perso ou des workloads qui nécessitent très peu de puissance, l’offre de CIVO est plutôt bien positionnée. Je ne suis pas complètement convaincu de l’intérêt de l’offre extra small à 4$ qui est plus là pour la _prouesse technique_ qu’une réelle utilisation. Mais dès small ou medium, on a un service qui fonctionne, moins cher que de nombreux concurrents et surtout bien plus optimisé en terme de ratio overhead/puissance totale.

Au delà de kubernetes, l’offre est quasiment inexistante. Des VMs (plus chères que les workers kubes !!! wtf) et des loadbalancer à 10$/mois (Scaleway le fait à 8€, on est dans les prix « pas cher ») et c’est tout...

Autant dire que c’est kubernetes ou rien. Du coup, est ce qu’il y a un marché pour ce besoin, je ne suis pas certain... mais pourquoi pas ? En tout cas, bonne surprise !
