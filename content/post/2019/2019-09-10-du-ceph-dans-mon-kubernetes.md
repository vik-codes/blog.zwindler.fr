---
title: Du Ceph dans mon Kubernetes
authors:
  - zwindler
type: post
date: 2019-09-10T06:45:22+00:00
excerpt: Tutoriel pour installer simplement un cluster Ceph sur un cluster Kubernetes en utilisant Rook
url: /2019/09/10/du-ceph-dans-mon-kubernetes/
image: /2017/11/kubernetes2.png
classic-editor-remember:
  - block-editor
categories:
  - Cluster
  - Stockage
  - Virtualisation
tags:
  - Ceph
  - GlusterFS
  - k8s
  - Kubernetes
  - stateful
  - stateless
  - Xwiki

---

  
## Stateful K8s
  
  
La semaine dernière, [j’ai partagé mon sentiment sur le fait qu’il y a un intérêt à utiliser (dans certains cas) Kubernetes](/2019/09/03/concerning-kubernetes-combien-de-problemes-ces-stacks-ont-generes/). Particulièrement dans le cas d’une infrastructure micro-services fortement hétérogène !

  
Cependant, certains pourraient être tentés de me faire remarquer que cette infrastructure logicielle a été conçue pour être stateless (l’ensemble des états étant stockés à part, dans une base de données externalisées). Et ainsi, elle s’intègre facilement dans Kubernetes (on se mord la queue).

  
C’est vrai, en partie. Kubernetes simplifie VRAIMENT la vie dans un contexte comme celui ci. Pour autant, ça ne veut pas dire non plus qu’il n’est pas possible (ni même complexe) de faire du stateful avec Kubernetes.

  
D’ailleurs, un de mes premiers articles sur Kube en parlait, [puisque j’avais PoCé (PoCqué ? que c’est moche parfois le Franglais...) le stateful sur K8s avec XWiki, début 2018](/2017/10/24/tutoriel-xwiki-ma-premier-appli-stateful-sur-kubernetes/). Dans cet article, j’avais créé un instance XWiki + PostgreSQL avec du stockage hautement disponible via GlusterFS, installé directement SUR les machines K8s.

  
## Et Ceph dans tout ça ?
  
  
[Ceph](https://rook.github.io/), c’est une autre paire de manches. D’abord, c’est du stockage bloc en mode synchrone (alors que GlusterFS est un FS distribué). C’est donc pas du tout la même chose.

  
> Thanks captain obvious
  
Ensuite, c’est quand même un poil plus compliqué à installer et configurer. GlusterFR on se contente d’un démon (ou deux) et de connecter les nœuds entre eux puis déclarer des briques. Sur Ceph, en revanche, il existe plusieurs notions complémentaires (les OSD, les moniteurs, les managers, ...).

  
Une fois de plus, je ne dis pas que ça serait compliqué à faire dans K8s, mais bon... pourquoi s'embêter ?

## Et donc Rook ?
  
  
Pourquoi s'embêter alors qu’un projet intégré à la CNCF prend en charge l’abstraction de Ceph (et d’autre) directement comme des ressources de Kubernetes ?

  
> A Storage Orchestrator for Kubernetes Rook turns distributed storage systems into self-managing, self-scaling, self-healing storage services. It automates the tasks of a storage administrator: deployment, bootstrapping, configuration, provisioning, scaling, upgrading, migration, disaster recovery, monitoring, and resource management.

  
Grosso modo, Rook nous automatise la gestion de stockage hautement disponible, en gérant le stockage comme une ressource dans Kubernetes.

  
Dans ce tuto, je vous propose donc de se concentrer sur Ceph uniquement, mais [vous pouvez très bien déployer autre chose (en suivant la doc](https://rook.github.io/docs/rook/v1.0/quickstart-toc.html)).

  
Sachez que Ceph vient de passer en V1 dans le projet Rook, signe de stabilité. Cependant, vous avez plein d’autres options (Cassandra, Minio, ...) à divers niveaux de maturité dans leur intégrations avec le projet Rook.

  
## Prérequis
  
D’abord les prérequis => [rook.github.io/docs/rook/v1.0/k8s-pre-reqs.html](https://rook.github.io/docs/rook/v1.0/k8s-pre-reqs.html).

  
Rook est disponible depuis un moment, mais si vous voulez vous évité des soucis, il est conseillé de rester sur une version _relativement_ récente de Kubernetes. Rook est officiellement supporté sur les K8s 1.10+.

  
Il vous faudra un compte avec les prévilèges cluster-admin pour bootstrapper Rook. Ne vous inquiétez pas, c’est juste le temps de créer les rôles et les CRDs.

  
Si vous n’en possédez pas, il est possible de demander à votre admin préféré de configurer directement les bons droits pour Rook à la main ([rook.github.io/docs/rook/v1.0/psp.html](https://rook.github.io/docs/rook/v1.0/psp.html)).

  
Enfin, il sera nécessaire d’avoir sur les machines qui exécutent Rook+Ceph de disposer du module Kernel rbd et d’avoir le package lvm2 d’installé.


```
modprobe rbd
```



Ne doit rien retourner.

  
> If it says ‘not found’, you may have to rebuild your kernel or choose a different Linux distribution.

  
## On déploie Rook et Ceph !
  
  
Rook nous met à disposition des fichiers d’exemples sur le dépôt principal, notamment pour configurer Ceph de A à Z :


```
git clone https://github.com/rook/rook.git
cd rook/cluster/examples/kubernetes/ceph
kubectl create -f common.yaml
kubectl create -f operator.yaml
kubectl create -f cluster-test.yaml
```



Le fichier common.yaml va créer les CRD nécessaires à Rook, les (Cluster)Roles, les services accounts et enfin les (Cluster)RoleBindings associés.

  
Le fichier **operator.yaml** créé un déploiement **rook-ceph-operator**, qui va nous permettre de gérer les demandes de créations de CRD de Rook (lien vers un tuto pour expliquer ce que sont les CRD et les operators)

  
Le dernier fichier, **cluster-test.yaml** est celui qui va réellement créer le cluster Ceph dans votre Kubernetes. C’est lui qui va déterminer le nombre de chaque composant de Ceph dont vous aller disposer.


```
apiVersion: ceph.rook.io/v1
kind: CephCluster
metadata:
  name: rook-ceph
  namespace: rook-ceph
spec:
  cephVersion:
    image: ceph/ceph:v14.2.2-20190722
    allowUnsupported: true
  dataDirHostPath: /var/lib/rook
  mon:
    count: 1
    allowMultiplePerNode: true
  dashboard:
    enabled: true
  monitoring:
    enabled: false  # requires Prometheus to be pre-installed
    rulesNamespace: rook-ceph
  network:
    hostNetwork: false
  rbdMirroring:
    workers: 0
  storage:
    useAllNodes: true
    useAllDevices: false
    directories:
    - path: /var/lib/rook
```



Note: Dans mon cas, j’ai ajouté à mes machines un disques /dev/sdd; j’ai donc remplacé les dernières lignes par "deviceFilter: sdd"

  
Une fois que vous avez exécuté la dernière commande, vous avez un cluster Ceph "de démo" opérationnel.

  
Il n’est pas conseillé de l’utiliser tel quel en production, car plusieurs composants ne sont pas redondés comme on a pu le voir en lisant le YAML ci dessus, et le stockage est assuré par un dossier sur chaque hôte Kubernetes, ce qui n’est pas du tout conseillé.

  
Cependant, on a l’ensemble des features qui sont activées, c’est parfait pour un test (mode bloc, objet ou fichier)

  
## Vérifier que tout fonctionne
  
  
La documentation de Ceph recommande d’utiliser un déploiement appelé [rook-toolbox](https://rook.github.io/docs/rook/v1.0/ceph-toolbox.html) pour vérifier que tout fonctionne.

  
Dans un premier temps, on peut commencer par simplement regarder si tous nos pods sont vivants :


```
kubectl --namespace=rook-ceph get pods
NAME                                                   READY   STATUS      RESTARTS   AGE
csi-cephfsplugin-5r648                                 2/2     Running     0          2d22h
csi-cephfsplugin-provisioner-0                         3/3     Running     0          2d22h
csi-rbdplugin-m7299                                    2/2     Running     0          2d22h
csi-rbdplugin-provisioner-0                            4/4     Running     0          2d22h
rook-ceph-agent-b79dl                                  1/1     Running     0          2d22h
rook-ceph-mgr-a-86586f9f4d-lz5df                       1/1     Running     0          2d22h
rook-ceph-mon-a-5fdc888bc4-qqb4m                       1/1     Running     0          2d22h
rook-ceph-operator-698b5d4fcc-dwdth                    1/1     Running     6          2d22h
rook-ceph-osd-0-667dcd84cf-h2tz8                       1/1     Running     0          2d22h
rook-ceph-osd-prepare-aks-agentpool-12737853-0-ntrn5   0/2     Completed   0          5h26m
rook-discover-sfdj4                                    1/1     Running     0          2d22h
```



Comme on peut le voir, tout est OK dans mon exemple.

  
On peut ensuite déployer la toolbox, dont le fichier YAML est présent dans le même dossier :


```
kubectl create -f toolbox.yaml

kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash
```



Une fois connecté, on peut lancer les commandes suivantes et commencer à interagir avec Ceph


```
ceph status
  cluster:
    id:     7099fc42-a47f-4412-8775-f6f3d4ce669d
    health: HEALTH_OK
 
  services:
    mon: 1 daemons, quorum a (age 111s)
    mgr: a(active, since 78s)
    osd: 1 osds: 1 up (since 60s), 1 in (since 60s)
 
  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   12 GiB used, 84 GiB / 97 GiB avail
    pgs:   


ceph osd status
+----+--------------------------+-------+-------+--------+---------+--------+---------+-----------+
| id |           host           |  used | avail | wr ops | wr data | rd ops | rd data |   state   |
+----+--------------------------+-------+-------+--------+---------+--------+---------+-----------+
| 0  | aks-agentpool-12737853-0 | 12.4G | 84.4G |    0   |     0   |    0   |     0   | exists,up |
+----+--------------------------+-------+-------+--------+---------+--------+---------+-----------+
```



## Créer un pool Ceph
  
  
Dans cet exemple, comme je n’ai qu’un seul OSD (un seul "disque", ici un dossier sur un serveur), je vais créer un pool sans réplication.

  
Si vous utilisez Rook en Production, vous aurez donc vous des disques dédiés (au minimum un sur tous les serveurs, ou à minima, au moins 3). Voir la [documentation officielle pour plus d’info](https://rook.github.io/docs/rook/v1.0/ceph-block.html).


```
---
apiVersion: ceph.rook.io/v1
kind: CephBlockPool
metadata:
  name: replicapool
  namespace: rook-ceph
spec:
  failureDomain: host
  replicated:
    size: 1
```



De même, on va créer une StorageClass, qui va permettre à Kubernetes de réaliser la création des volumes à la demande (les PVs sont créés lorsqu’une application demande la création d’un volume via un Persistent Volume Claim)


```
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: rook-ceph-block
provisioner: ceph.rook.io/block
parameters:
  blockPool: replicapool
  clusterNamespace: rook-ceph
  fstype: xfs
reclaimPolicy: Retain
```



A partir de là, vous avez maintenant un stockage hautement disponible et réparti équitablement sur vos serveurs Kubernetes.

  
Si vous voulez tester, dans le même dépôt, on a à disposition 2 fichiers YAML d’exemple pour déployer MySQL + WordPress


```
zwindler:~/sources/rook/cluster/examples/kubernetes$ kubectl create -f mysql.yaml
service/wordpress-mysql created
persistentvolumeclaim/mysql-pv-claim created
deployment.apps/wordpress-mysql created

zwindler:~/sources/rook/cluster/examples/kubernetes$ kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
mysql-pv-claim   Bound    pvc-d245dd2d-d0a1-11e9-9f5c-26f444bf7bdc   20Gi       RWO            rook-ceph-block   10s

zwindler:~/sources/rook/cluster/examples/kubernetes$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS      REASON   AGE
pvc-d245dd2d-d0a1-11e9-9f5c-26f444bf7bdc   20Gi       RWO            Retain           Bound    default/mysql-pv-claim   rook-ceph-block            26s
```



Elle est pas belle là vie :) ?
