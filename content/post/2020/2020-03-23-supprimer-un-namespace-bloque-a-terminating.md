---
title: Supprimer un namespace bloqué à Terminating
authors:
  - zwindler
type: post
date: 2020-03-23T07:15:00+00:00
excerpt: "Checklist des choses à vérifier lorsque vous n'arrivez pas à supprimer un namespace dans Kubernetes ou qu'il reste à l'état Terminating"
url: /2020/03/23/supprimer-un-namespace-bloque-a-terminating/
image: /2020/01/terminated.jpg
categories:
  - Cluster
  - Système
  - Virtualisation
tags:
  - kubectl
  - Kubernetes
  - namaspace
  - productivité
  - tips
  - tricks

---

## Forcer la suppression d’un namespace bloqué à "Terminating" dans Kubernetes
  
  
Il y a quelques mois, j’ai eu des soucis pour supprimer un namespace lorsque j’ai voulu démonter mon [cluster Ceph (monté avec Rook)](/2019/09/10/du-ceph-dans-mon-kubernetes/).

On aurait pu croire que ça m’a énervé (bon ok, si un peu quand même) mais ça m’a permis de mettre la main sur plusieurs commandes sympa avec kubectl donc tout n’est pas perdu ;-).

Voyez ce récit comme une checklist des choses à vérifier si jamais vous avez du mal à supprimer des objets dans Kubernetes !

Note: dans la même veine, n’hésitez pas à aller voir les articles que j’ai écris sur [kubectl, notamment les tips and tricks !](/recherche/?keyword=kubectl)

## La base
  
  
Pensant avoir correctement supprimé les objets Ceph dans mon cluster, j’ai donc terminé le nettoyage par une suppression toute bête du namespace :

```bash
kubectl --context=sandbox delete ns rook-ceph
```

Sauf que, patatra, en essayant de vérifier qu’il était bien supprimé :

```bash
kubectl --context=sandbox get ns rook-ceph
NAME        STATUS        AGE
rook-ceph   Terminating   88d
```

Le namespace est toujours présent, et reste bloqué à l’état "Terminating".

Qu’à cela ne tienne, je tente de le re-supprimer. Ça ne marche pas :

```bash
kubectl --context=sandbox delete ns rook-ceph
Error from server (Conflict): Operation cannot be fulfilled on namespaces "rook-ceph": The system is ensuring all content is removed from this namespace.  Upon completion, this namespace will automatically be purged by the system
```

## Forcer la suppression
  
Une rapide recherche sur le net me conseille d’ajouter les flags `--force`, à obligatoirement associer avec le flag `--grace-period=0` (si vous ne le mettez pas, il vous dira de le mettre de toute façon...)

```bash
kubectl --context=sandbox delete ns rook-ceph --force --grace-period=0
warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
Error from server (Conflict): Operation cannot be fulfilled on namespaces "rook-ceph": The system is ensuring all content is removed from this namespace.  Upon completion, this namespace will automatically be purged by the system.
```

Flute !

## Vérifier qu’il ne reste pas des objets Kubernetes, dans le namespace ou associés
  
Bon, généralement quand j’arrive pas à supprimer un namespace, c’est qu’il reste un PVC qui traine, lui même attaché à un PV. Mais là non plus, rien :

```bash
kubectl --namespace=rook-ceph get pvc
No resources found in rook-ceph namespace.
kubectl get pv
```

## Vérifier les CRD aussi !
  
Un truc à vérifier aussi dans le cas de rook, c’est qu’il ne reste pas de CRD (CustomRessourceDefinition) que vous n’avez pas l’habitude de manipuler, qui seraient encore présentes et qui bloqueraient l’opération :

```bash
dgermain$ kubectl delete storageclass rook-ceph-block
Error from server (NotFound): storageclasses.storage.k8s.io "rook-ceph-block" not found
dgermain$ kubectl delete storageclass rook-cephfs
Error from server (NotFound): storageclasses.storage.k8s.io "rook-cephfs" not found

dgermain$ kubectl --context=sandbox get crd
volumes.rook.io                                  2019-08-19T09:46:08Z
dgermain$ kubectl --context=sandbox delete crd volumes.rook.io
```

## Utiliser des scripts pour débloquer les objets en "Terminating"
  
Là ça commence à devenir pénible. Comme je ne suis évidemment pas le premier à avoir le problème, des gens ont écris des scripts pour faciliter la suppression d’objets bloqués au stade Terminating. Ces scripts prennent en charge la plupart des cas courants. Attention cependant à ce que vous faites avec (soyez sûrs de vous) !

```bash
dgermain:~/sources/knsk$ git clone https://github.com/thyarles/knsk/

dgermain:~/sources/knsk$ kubectl config use-context sandbox
Switched to context "sandbox".

dgermain:~/sources/knsk$ chmod +x knsk.sh
dgermain:~/sources/knsk$ ./knsk.sh
Deleting rook-ceph... done!
```

## Lister tous les Objets du cluster qui s’appellent rook-ceph
  
Last but not least. La solution j’ai fini par la trouver en utilisant la commande suivante, qui permet de lister TOUS les types objets existants dans votre cluster :

```
kubectl api-resources --verbs=list --namespaced -o name
```

A partir de là, j’ai rajouté un petit xargs pour rechercher, dans tout le cluster, tous les objets s’appelant rook-ceph parmis tous les types d’objets qui existent. Et là surprise :

```
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get -n rook-ceph
No resources found in rook-ceph namespace.
No resources found in rook-ceph namespace.
No resources found in rook-ceph namespace.
[...]
No resources found in rook-ceph namespace.
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   STATE     HEALTH
rook-ceph   /var/lib/rook     1          88d   Created   HEALTH_OK
No resources found in rook-ceph namespace.
[...]
No resources found in rook-ceph namespace.
Error from server (NotAcceptable): the server was unable to respond with a content type that the client supports (get pods.metrics.k8s.io)
No resources found in rook-ceph namespace.
[...]
```

OUPS ! Il restait un CRD "cephcluster" que j’avais oublié de supprimer ! Sauf que cet objet n’apparaissait pas avec une requête d’affichage classique.

```
kubectl -n rook-ceph get cephcluster
NAME        DATADIRHOSTPATH   MONCOUNT   AGE   STATE     HEALTH
rook-ceph   /var/lib/rook     1          88d   Created   HEALTH_OK

kubectl -n rook-ceph delete cephcluster rook-ceph
cephcluster.ceph.rook.io "rook-ceph" deleted
```

## Et c’est pas fini !
  
Malheureusement, ce n’est pas totalement terminé ! Notre namespace n’a plus d’objets qui bloquent sa suppression. Pour autant, il est encore bloqué dans l’état Terminating.

```
kubectl -n rook-ceph delete cephcluster rook-ceph
cephcluster.ceph.rook.io "rook-ceph" deleted
^C
```

Dans ce cas de figure, on peut soit relancer le script knsk, soit, à la main, patcher l’objet pour vider la metadata "finalizers" et débloquer le processus de suppression. Ca revient au même, mais je vous le met pour que vous compreniez ce que vous faites :

```bash
dgermain:~/sources/knsk$ kubectl -n rook-ceph patch cephclusters.ceph.rook.io rook-ceph -p '{"metadata":{"finalizers": []}}' --type=merge
cephcluster.ceph.rook.io/rook-ceph patched
```

Et maintenant, votre namespace est supprimé !

## Sources
  
* [How to fix Kubernetes namespace deleting stuck in Terminating State](https://medium.com/@newtondev/how-to-fix-kubernetes-namespace-deleting-stuck-in-terminating-state-5ed75792647e)
* [github.com/thyarles/knsk : Kubernetes namespace killer](https://github.com/thyarles/knsk/blob/master/knsk.sh)
* [Documentation Ceph : Ceph Teardown](https://rook.io/docs/rook/latest/Getting-Started/ceph-teardown/)
      
