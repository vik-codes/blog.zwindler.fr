---
title: kubectl tips and tricks n°4
authors:
  - zwindler
type: post
date: 2021-09-06T06:55:00+00:00
excerpt: Tips and tricks pour améliorer votre productivité avec kubectl ou juste apprendre de nouvelles possibilités en CLI
url: /2021/09/06/kubectl-tips-and-tricks-n4/
image: /2019/10/kubectl2.png
categories:
  - Cluster
  - Virtualisation
tags:
  - kubectl
  - Kubernetes
  - productivité
  - resources
  - tips and tricks

---
 

## Encore des tips pour kubectl !!

J’en suis donc bien au numéro 4 pour ces [tips and tricks sur kubectl (sans compter d’autres articles plus généralistes)](/recherche/?keyword=kubectl) et il y a encore beaucoup à dire !!

## J’arrive plus à me loguer sur mon cluster Kubernetes &#x1f62d;

Dans plusieurs contextes, j’ai eu à aider des collègues qui n’arrivaient plus à utiliser **kubectl** (après expiration d’un jeton, changements de confs dans le cluster, etc).

Un moyen rapide pour « régler » une partie des problèmes dans ce genre de cas peut être simplement de supprimer le contenu des caches de kubectl :

```
rm -r ~/.kube/cache 
rm -r ~/.kube/http-cache
```


## Non mais ya quoi dans mon cluster ?

Vous le savez, Kubernetes c’est plein d’API misent bout à bout (portée par l’API server et persistée par etcd) et d’autres composants qui se connectent dessus pour faire des choses utiles. Ça implique qu’il y ait un certain nombre d’objets logiques à connaître pour interagir avec l’API server et déployer vos applications. Cependant, difficile pour le néophyte de les connaître tous. 

Bien sûr, on peut toujours parcourir [l’API à coup de cURL](https://kubernetes.io/docs/reference/using-api/api-concepts/) mais vous avouerez qu’il y a plus user-friendly comme méthode ;). Et même pour l’admin chevronné, l’ajout de [CRDs (Custom Resource Definition)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/), difficile de savoir, sur des clusters un peu touffus, quel objet est présent et à quoi il sert.

Pour ça, vous disposez de deux aides avec **kubectl**

**_kubectl api-resources_** va vous permettre de lister la totalité des objets logiques de l’API disponibles (CRDs comprises) sur votre cluster, ainsi qu’une autre information très utile, s’ils sont « namespacés » ou non.

Dernier intérêt de cette commande, elle permet également de connaitre les abréviations (shortnames) autorisés, pratique pour sous économiser quelques caractères ;-)

```
kubectl api-resources
NAME                              SHORTNAMES   APIGROUP                       NAMESPACED   KIND
bindings                                                                      true         Binding
componentstatuses                 cs                                          false        ComponentStatus
configmaps                        cm                                          true         ConfigMap
endpoints                         ep                                          true         Endpoints
events                            ev                                          true         Event
limitranges                       limits                                      true         LimitRange
namespaces                        ns                                          false        Namespace
nodes                             no                                          false        Node
[...]
```


Un autre outil intéressant pour savoir à quoi sert tel ou tel objet/API est _**kubectl explain**_, qui va vous afficher la documentation en ligne :

```
kubectl explain RoleBinding
KIND:     RoleBinding
VERSION:  rbac.authorization.k8s.io/v1

DESCRIPTION:
     RoleBinding references a role, but does not contain it. It can reference a
     Role in the same namespace or a ClusterRole in the global namespace. It
     adds who information via Subjects and namespace information by which
     namespace it exists in. RoleBindings in a given namespace only have effect
     in that namespace.

FIELDS:
   apiVersion   <string>
[...]
```


Malheureusement, j’ai remarqué que plusieurs éditeurs mettant à disposition des CRDs ne mettent pas de doc accessible avec « explain ». C’est vraiment super dommage :/

## Afficher des labels

Tous les objets Kubernetes que vous créés peuvent être agrémentés de labels et d’annotations. Au delà de l’aspect informatif (ce **Pod** appartient à tel équipe, ce **Node** à telle capacité en RAM), c’est aussi très pratique pour filtrer les informations renvoyées par les commandes **kubectl get**.

Dans le tout premier [kubectl tips and tricks](/2019/10/30/kubectl-tips-tricks-1/), j’avais parlé de l’option **--selector**, qui permet de filtrer l’action d’une commande kubectl (get, delete, ...) à un couple label+valeur

![](/2021/08/image.png)

* [blog.zwindler.fr/2019/10/30/kubectl-tips-tricks-1/](/2019/10/30/kubectl-tips-tricks-1/)

Par défaut, les informations renvoyées par le kubectl get sont assez concises et parfois on manque un peu d’information. 

Dans ce genre de cas, la première chose à tester est simplement d’ajouter un « -o wide » qui permet d’ajouter quelques colonnes (qui dépendent du type d’objet requêté) :

```
kubectl get nodes -o wide
NAME                                             STATUS   ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP    OS-IMAGE                        KERNEL-VERSION     CONTAINER-RUNTIME
scw-k8s-zealous-chaum-default-4b71eda80e934790   Ready    <none>   24m   v1.21.3   10.70.116.23   51.158.79.36   Ubuntu 20.04.1 LTS c200a86960   5.4.0-80-generic   containerd://1.5.4
```


Cependant, dans le cas ça n’est toujours pas suffisant et qu’on ne veut pas filtrer mais bien obtenir rapidement la valeur d’un label bien particulier sur un ensemble d’objets Kubernetes, il existe une option « --label-columns » qui permet d’ajouter des colonnes supplémentaires en fonction d’un ou plusieurs labels donnés.

```
kubectl get nodes --label-columns=kubernetes.io/os
NAME                                             STATUS   ROLES    AGE   VERSION   OS
scw-k8s-zealous-chaum-default-4b71eda80e934790   Ready    <none>   19m   v1.21.3   linux
```

Les labels sont donc d’autant plus utiles qu’ils sont faciles à afficher !

Note : les plus chevronnés d’entre vous savent certainement peut aller encore plus loin dans les colonnes ou les informations qu’on peut afficher avec kubectl (notamment via le « -o »). Mais je garde ça pour un prochain épisode... Donc en attendant, have fun ;-)
