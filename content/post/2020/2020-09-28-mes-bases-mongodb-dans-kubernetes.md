---
title: Mes bases MongoDB dans Kubernetes
authors:
  - zwindler
type: post
date: 2020-09-28T06:15:00+00:00
excerpt: Tutoriel pour installer MongoDB Community Kubernetes Operator et déployer facilement des cluster de base de données NoSQL MongoDB
url: /2020/09/28/mes-bases-mongodb-dans-kubernetes/
image: /2020/09/mongodb_operator.png
categories:
  - Cluster
  - Système
  - Virtualisation
tags:
  - controller
  - Kubernetes
  - mongodb
  - operator

---

## Introduction
  
> NON MAIS T’ES MALADE OÙ QUOI ? Une base de données (MongoDB en plus, du NoSQL) dans Kubernetes... N’importe quoi ! Les containers c’est pour du Stateless seulement.

Si j’avais écris cet article en 2017, c’est probablement 98% des commentaires que j’aurai reçu ;)

Vous l’avez compris, aujourd’hui, je vais vous présenter le **MongoDB Kubernetes Operator**, l’outil officiel de chez Mongo qui permet de déployer à tour de bras des bases de données NoSQL dans vos clusters Kubernetes.

![](/2020/09/go_wrong.jpg)


Note: Pour ceux qui ne l’ont pas, on parle d’[Operator dans Kubernetes](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/) pour désigner un ensemble composé d’objets logiques (les CRD, aka Custom Resource Definitions) et d’un (ou plusieurs) Controller pour étendre les possibilités offertes nativement par Kubernetes. C’est très pratique et il y en a plein qui existent, comme par exemple celui pour déployer [Prometheus](https://github.com/coreos/prometheus-operator) qui est un premiers...

## MongoDB Community Kubernetes Operator
  
  
Depuis tout à l’heure, je vous parle de MongoDB Kubernetes Operator, mais c’est un abus de langage, car il existe en fait 2 versions différentes de l’Operator : Entreprise et Community.

Vous vous en doutez, la version Community, gratuite, est bien moins complète que la version Entreprise, qui nécessite elle une souscription... Le projet est disponible sur Github : [MongoDB Community Kubernetes Operator](https://github.com/mongodb/mongodb-kubernetes-operator).

> This is a Kubernetes Operator which deploys MongoDB Community into Kubernetes clusters.
>
> If you are a MongoDB Enterprise customer, or need Enterprise features such as Backup, you can use the MongoDB Enterprise Operator for Kubernetes.

![](/2020/09/mongodb_operator.png)

Pour ceux qui auraient déjà des bases MongoDB licenciées, sachez donc que la version [Entreprise (dispo ici)](https://github.com/mongodb/mongodb-enterprise-kubernetes), est plus complète avec des features comme les sauvegardes, ainsi que de plus nombreuses options de déploiements et un Chart Helm.

## Prérequis
  
Allez, on y va.

Pour ce tutoriel, je suis parti d’un cluster AKS vierge, et je partirai du principe que vous avez fait de même, avec un Kubernetes 1.18 (ou mieux) et les VMSS d’activés.

```
az aks create --resource-group zwindlerk8s_rg --name zwindlerk8s --node-count 3 --node-vm-size Standard_DS2_v2 --kubernetes-version 1.18.2 --ssh-key-value ~/.ssh/mypublicsshkey.pub
```



Normalement, par défaut, le cluster AKS est configuré avec des StorageClass par défaut. Si vous ne travaillez pas sur AKS (ou un autre cloud provider car ils en ont tous), il vous faudra nécessairement configurer une StorageClass par défaut car nous allons provisionner des volumes (bah oui, c’est pas du _Stateless_ on a dit ;-p).


```
kubectl --context=zwindlerk8s get StorageClass
NAME                PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
azurefile           kubernetes.io/azure-file   Delete          Immediate           true                   47m
azurefile-premium   kubernetes.io/azure-file   Delete          Immediate           true                   47m
default (default)   kubernetes.io/azure-disk   Delete          Immediate           true                   47m
managed-premium     kubernetes.io/azure-disk   Delete          Immediate           true                   47m
```



Si vous avez un cluster _on premise_ par exemple, vous pouvez vous baser sur ces tutoriels que j’ai écris il y a quelques années pour [déployer un cluster GlusterFS _extérieur_ et l’intégrer à Kubernetes](/2017/10/24/tutoriel-xwiki-ma-premier-appli-stateful-sur-kubernetes/) ou bien encore celui là qui utilise Rook (un autre operator) pour [déployer un cluster de stockage Ceph _dans_ Kubernetes](/2019/09/10/du-ceph-dans-mon-kubernetes/).

## Installation
  
OK, on peut commencer !

La première chose à faire est évidemment de récupérer les sources de l’opérateur.


```
git clone https://github.com/mongodb/mongodb-kubernetes-operator.git
cd mongodb-kubernetes-operator/
```



### Les CRDs
  
Une fois que c’est fait, on va pouvoir déployer les CRDs (mongodb.mongodb.com`) :

```
kubectl --context=zwindlerk8s create -f deploy/crds/mongodb.com_mongodb_crd.yaml
customresourcedefinition.apiextensions.k8s.io/mongodb.mongodb.com created

kubectl --context=zwindlerk8s get crd/mongodb.mongodb.com
NAME                  CREATED AT
mongodb.mongodb.com   2020-06-16T09:29:26Z
```



### L’opérateur (contrôleur)
  
  
Pour faire propre, je met toujours les services techniques (ingress controllers, controllers, ...) dans un namespace séparé.

Cependant ici, il faut savoir que le contrôleur a besoin d’être dans le même namespace que les bases qu’il est censé déployer.

On créé donc un namespace qui va contenir notre contrôleur et les bases qui iront avec. Je choisi donc un nom très original :


```
kubectl --context=zwindlerk8s create ns mongodb
namespace/mongodb created

kubectl --context=zwindlerk8s get ns mongodb
NAME             STATUS   AGE
mongodb   Active   13s
```



Et enfin je le déploie :


```
kubectl --context=zwindlerk8s create -f deploy/ --namespace mongodb

  deployment.apps/mongodb-kubernetes-operator created
  role.rbac.authorization.k8s.io/mongodb-kubernetes-operator created
  rolebinding.rbac.authorization.k8s.io/mongodb-kubernetes-operator created
  serviceaccount/mongodb-kubernetes-operator created
```



Comme vous pouvez le constater, le retour de la commande nous permet de voir que l’on a créé les objets suivants :
  
* Un Deployment `mongodb-kubernetes-operator`, qui contient l’intelligence de l’opérateur
* Un ServiceAccount `mongodb-kubernetes-operator`, un Role `mongodb-kubernetes-operator` et le RoleBinding associé `mongodb-kubernetes-operator` pour les intéractions entre l’opérateur et Kubernetes.
      
  
Au passage, le fait qu’il s’agisse d’un RoleBinding et non par d’un ClusterRoleBinding confirme bien qu’on soit ici sur un opérateur qui n’a pas de droits sur tout le cluster, mais que sur une division de celui ci.

## Déployer des bases MongoDB
  
  
Maintenant qu’on a configuré notre Operator dans son Namespace, on peut se pencher sur la création d’une base.

En réalité, on ne va que rarement vouloir déployer qu’une seule base. Si vous connaissez MongoDB, vous savez que la base propose nativement une fonctionnalité de haute disponibilité via les ReplicaSets (à ne pas confondre avec les ReplicaSets de Kubernetes, qui sont un autre concept).

Grosso modo, on va avoir 3 instances de la même base, contenant les mêmes données. L’une d’entre elle sera élue PRIMARY, les deux autres seront SECONDARY et la PRIMARY streamera toutes les modifs en écriture au SECONDARY. Basique.

Comme on a maintenant un CRD mongodb dans notre Kubernetes, on peut donc définir avec ces quelques lignes de YAML qu’on veut un nouveau cluster _zwindler-mongodb_, composé de _3_ noeuds dans un même _ReplicaSet_ (mongodb) en version _4.2.6_ dans le Namespace _mongodb_.

```
cat > zwindler-mongodb.yaml << EOF
apiVersion: mongodb.com/v1
kind: MongoDB
metadata:
  name: zwindler-mongodb
  namespace: mongodb
spec:
  members: 3
  type: ReplicaSet
  version: "4.2.6"
EOF

kubectl --context=zwindlerk8s apply -f zwindler-mongodb.yaml
  mongodb.mongodb.com/zwindler-mongodb created

kubectl --context=zwindlerk8s --namespace mongodb get mongodb
  NAME               PHASE   VERSION
  zwindler-mongodb
```



Et PAF ! En deux coups de cuillère à pot, on a un cluster MongoDB (bon en vrai il faut attendre quelques minutes qu’il s’initialise) :


```
kubectl --context=zwindlerk8s --namespace=mongodb get all
NAME                                               READY   STATUS    RESTARTS   AGE
pod/mongodb-kubernetes-operator-6cfbf85479-bcj85   1/1     Running   0          92m
pod/zwindler-mongodb-0                             2/2     Running   0          8m8s
pod/zwindler-mongodb-1                             2/2     Running   0          5m55s
pod/zwindler-mongodb-2                             2/2     Running   0          3m33s

NAME                           TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
service/zwindler-mongodb-svc   ClusterIP   None         <none>        27017/TCP   8m8s

NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mongodb-kubernetes-operator   1/1     1            1           92m

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/mongodb-kubernetes-operator-6cfbf85479   1         1         1       92m

NAME                                READY   AGE
statefulset.apps/zwindler-mongodb   3/3     8m8s
```

## Tester notre cluster
  
Vous pouvez me croire sur parole, mais c’est quand même mieux de pouvoir vérifier que le cluster est bel et bien fonctionnel

> La confiance n’exclue pas le contrôle
>
> (Vinz, si tu me lis ;-p)

Si vous avez un client mongoDB d’installé sur votre machine, alors le plus simple est de simplement faire du port forward entre vos Pods et votre machine avec kubectl :

```
kubectl port-forward --context=zwindlerk8s --namespace=mongodb service/zwindler-mongodb-svc 27018:27017
Forwarding from 127.0.0.1:27018 -> 27017
Forwarding from [::1]:27018 -> 27017
```

A partir de là, je peux utiliser mon client mongoDB pour me connecter et vérifier le status du ReplicaSet :


```
mongo 127.0.0.1:27018
MongoDB shell version v3.6.3
connecting to: mongodb://127.0.0.1:27018/test
MongoDB server version: 4.2.6
[...]
zwindler-mongodb:PRIMARY> rs.status().members
[
  {
    "_id" : 0,
    "name" : "zwindler-mongodb-0.zwindler-mongodb-svc.mongodb.svc.cluster.local:27017",
    "health" : 1,
    "state" : 1,
    "stateStr" : "PRIMARY",
[...]
```



Je vous passe les détails, mais on voit bien que je me suis connecté ici sur le PRIMARY et si je lis toute la tartine de JSON que me renvoie MongoDB, j’ai bien mes 3 noeuds actifs.

## Tester la résilience
  
Ce qu’il y a de bien avec Kubernetes, c’est que si une application, ou même un serveur complet tombe en panne, tout ce qui a besoin d’être redémarrer/déplacé va l’être, de manière automatique. La base MongoDB sera redémarrée sur un autre serveur et son disque détaché de l’ancien serveur puis rattaché sur le nouveau.

C’est particulièrement pratique si vous êtes chez un cloud provider dont la stabilité des machines virtuelles est contestable (*cough cough* _azure_ *cough*), que vous n’aimez pas particulièrement être réveillé la nuit en astreinte et que vous n’avez pas le temps ou les moyens de mettre en place de coûteux mécanismes de redondance.

Note : si vous voulez troller sur ce point précis, sachez que j’ai écris un billet d’humeur à ce sujet il y a 2 ans, je vous invite à venir m’en parler là bas

* [Concerning Kubernetes : « combien de problèmes ces stacks ont générés ? »](/2019/09/03/concerning-kubernetes-combien-de-problemes-ces-stacks-ont-generes/)

Dans ce test de résilience, je vais donc partir du cas le plus défavorable dans un ReplicaSet MongoDB, à savoir la perte du serveur Kubernetes qui héberge le MongoDB actuellement PRIMARY.

Dans le cas présent, les connexions des applications clients seront coupées environ une seconde, le temps que l’élection se fasse, qu’un SECONDARY devienne le nouveau PRIMARY et que les applications s’y reconnecte. Côté applications, la coupure sera donc assez courte.

Pour autant, côté MongoDB, il manquera un noeud dans le ReplicaSet. Et il faut que ce noeud revienne de lui même à la vie, sinon, la prochaine panne nous sera fatale (on dépassera largement cette "1 seconde" d’indisponibilité).

J’ai donc, depuis ma console Azure, complètement supprimé le noeud `aks-nodepool1-42601413-vmss000000`. Kubernetes ayant été configuré pour contenir 3 noeuds et qu’il fonctionne avec un VMSS, un `aks-nodepool1-42601413-vmss000003` prend donc sa place.

Au bout de quelque minutes, on remarque que `zwindler-mongodb-0`, la base MongoDB qui a été supprimée, a été Rescheduled par Kubernetes sur `aks-nodepool1-42601413-vmss000003` et fonctionne à nouveau.


```
zwindler-mongodb-0                             2/2     Running   0          28m   10.244.3.4   aks-nodepool1-42601413-vmss000003   <none>           <none>
zwindler-mongodb-1                             2/2     Running   0          89m   10.244.0.5   aks-nodepool1-42601413-vmss000001   <none>           <none>
zwindler-mongodb-2                             2/2     Running   0          87m   10.244.2.4   aks-nodepool1-42601413-vmss000002   <none>           <none>
```

> So far, so good
  
Et en se connectant une nouvelle fois via le mongo client, on remarque que le nouveau PRIMARY est mongo-1 et que mongo-0 a rejoins le cluster en tant que SECONDARY.

```
[...]
      "name" : "zwindler-mongodb-0.zwindler-mongodb-svc.mongodb.svc.cluster.local:27017",
      "health" : 1,
      "state" : 2,
      "stateStr" : "SECONDARY",
[...]
      "name" : "zwindler-mongodb-1.zwindler-mongodb-svc.mongodb.svc.cluster.local:27017",
      "health" : 1,
      "state" : 1,
      "stateStr" : "PRIMARY",
[...]
```



CQFD :)
