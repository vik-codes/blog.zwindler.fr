---
title: 'Découvrir Prometheus et Grafana par l’exemple'
authors:
  - zwindler
type: post
date: 2020-04-13T06:40:00+00:00
excerpt: "Tutoriel de l'utilisation de Grafana et Prometheus par l'exemple pour découvrir comment créer des Dashboard, ajouter des variables, choisir la métrique, ..."
url: /2020/04/13/decouvrir-prometheus-et-grafana-par-lexemple/
image: /2020/01/20200102_084825-2.jpg
categories:
  - Monitoring
  - Virtualisation
tags:
  - affinity
  - anti-affinity
  - bucket
  - Dashboard
  - grafana
  - Kubernetes
  - metric
  - prometheus

---

## Grafana et Prometheus
  
  
Ça fait plusieurs articles que je vous parle de [Prometheus et de Grafana](/recherche/?keyword=Prometheus), notamment pour l’installer. Mais je n’avais pas encore pris le temps de faire un article pour vous montrer comment les utiliser (et pourquoi ces deux outils sont géniaux) !

Typiquement, ça va nous permettre de réaliser ce genre de dashboard, qui permettra aux équipes (production, dev, voire même équipes fonctionnelles) de voir en un coup d’œil si tout va bien ou au contraire, ce qui va mal.



![](/2020/01/20200102_084825-2-1.jpg) 


## Un cas utile
  
  
Et tant qu’à présenter les outils, je me suis dis que j’allais utiliser un des exemples que j’avais eu à mettre en place _dans la vraie vie_ : tester que mes déploiements Kubernetes respectent bien l’anti-affinité.

Cet exemple est volontairement "un peu complexe", car il a vocation à vous permettre d’appréhender d’un seul coup plusieurs concepts qui seront utiles pour bien débuter dans Grafana et Prometheus. Notamment, la sélection de la bonne métrique, le langage PromQL, l’ajout de variables dans les dashboards, etc.

Note : Pour ceux qui ne l’ont pas, dans l’orchestrateur de containers Kubernetes, il est possible d’indiquer à l’outil que 2 replicas d’une même application (pour la redondance) ne doivent pas être exécutée sur la même ressource. Ça permet entre autre de garantir qu’il n’y a pas un SPOF au niveau de l’hôte qui exécute les containers alors qu’on croit avoir une application redondante.



## Trouver les métriques dans Prometheus
  
  
Je vais partir du principe que vous avez déjà une plateforme opérationnelle, équipée d’un Prometheus et d’un Grafana. Si ce n’est pas le cas, je vous invite à faire une rapide recherche sur votre moteur de recherche préféré ou de [consulter mes précédents articles sur le sujet](/recherche/?keyword=prometheus).

La première étape avant de commencer à essayer de monter de beaux dashboards consiste à chercher la métrique qui nous intéresse. Car, il faut bien l’admettre, généralement Prometheus en collecte BEAUCOUP !



![](/2019/12/prometheus_timeseries01.png) 

> Rien que Prometheus lui même expose et stocke plus de 700 métriques 


On va donc se connecter sur notre serveur Prometheus, puis requêter l’ensemble des métriques disponibles pour en trouver une qui permette de répondre simplement à notre problème.
Pour reprendre l’exemple que j’ai choisi, je veux :
  
* pour tous les Pods
* m’assurer que plusieurs Pods d’un même déploiement ne sont pas exécuté sur le même serveur
      
  
Pour ça, j’ai donc besoin d’avoir une métrique qui me permettre d’avoir tous les Pods, un information sur le Deploiement concerné, ainsi que le Node sur lequel le Pod est exécuté.

## container_last_seen
  
  
Il y a probablement plusieurs façon de répondre à cette interrogation, mais une des solutions qui marchent plutôt bien pour moi est d’utiliser la métrique _container_last_seen_.

En recherchant des métriques dans la console de Prometheus, j’ai pu remarquer que cette métrique donne, pour tous les containers, la date à laquelle il a été vu pour la dernière fois, ainsi qu’un certain nombre d’information sur chaque container.

## On valide sur un cas particulier
  
  
Pour vérifier que la métrique que je vous indique répond bien à notre problème, je vous propose de tester avec un exemple.

La requête PromQL suivante permet d’afficher les containers responsable de la résolution DNS interne de mon Kubernetes (déployé dans le namespace _kube-system_) :



![](/2018/09/prometheus1-1.png) 

```
container_last_seen{container_name=~".*dns.*",namespace=~"kube-system"}

container_last_seen{[...],container_name="dns",instance="node1",namespace="kube-system",pod_name="coredns-xxxxxxxx-yyyyy",[...]}	1577569793
container_last_seen{[...],container_name="dns",instance="node2",namespace="kube-system",pod_name="coredns-xxxxxxxx-zzzzz",[...]}	1577566730
container_last_seen{[...],container_name="dns",instance="node3",namespace="kube-system",pod_name="coredns-xxxxxxxx-aaaaa",[...]}	1577569313
```



Pour ceux qui débutent en PromQL, il s’agit du langage de requêtage de Prometheus, et qui permet entre autre de filtrer les timeseries affichées en fonction de critères (listés dans la partie entre les accolades).

Dans les résultats de la requête, on a bien :
  
* le nom de notre Deployment (container_name)
* le nom de l’hôte qui héberge le container (instance)
* le nom du Pod (pod_name)
* le namespace
      


## Créer notre visualisation dans Grafana
  
  
Maintenant qu’on a trouvé la métriques qui nous intéresse, on peut aller dans Grafana et créer un nouveau Dashboard



![](/2019/12/grafana_reate_dashboard.png) 


Puis un nouveau Panel dans notre Dashboard fraîchement créé :



![](/2019/12/grafana_nouveau_panel.png) 


A partir de là, on pourrait directement afficher les données de notre métrique, mais ça ne serait pas très informatif. On serait noyé sous une masse de conteneurs, chacun avec leurs variables.



![](/2019/12/grafana_query.png) 


Bref, on va devoir restreindre tout ça, notamment via des variables, pour que ça devienne exploitable !



## Il y en a beaucoup trop
  
  
Dans la capture que j’ai faite juste avant, j’ai quand même été obligé de restreindre à un seul namespace, pour ne pas noyer Prometheus et Grafana. Et encore, c’est (toujours) parfaitement inexploitable.

Clairement, on ne va pas vouloir se contenter d’une sélection "statique" des namespaces, au risque de devoir faire un _graphique_ par _namespace_ Kubernetes (et vous en avez peut être beaucoup).

On va donc récupérer la liste des namespaces disponibles dans Prometheus et l’afficher dans une liste déroulante dans notre Dashboard. Cette liste permettra de filtrer les données par namespace pour ne pas faire planter Prometheus.

## Les variables dans le Dashboard
  
  
Pour se faire, on va devoir de nouveau trouver la valeur la plus adaptée dans notre source de données Prometheus.

Je ne vais pas vous faire retourner dans Prometheus pour ça, celle que moi j’utilise, c’est celle ci :

```
kube_namespace_labels{namespace!~"kube-.*|default"}
```



Cette requête PromQL permet de lister l’ensemble des namespaces présents dans votre cluster Kubernetes, puis, entre les accolades, de filtrer pour retirer les namespaces respectant les regexp "kube-.*" et "default".



![](/2018/09/variables2.png) 


Pour autant, on est pas encore complètement sorti d’affaire puisqu’on doit maintenant récupérer uniquement la partie rouge dans ma capture d’écran, qui est la liste des noms des namespaces.

Arrive alors Grafana, qui fournit une fonction supplémentaire label_values, et qui permet, à partir d’une liste des timeseries Prometheus, de récupérer la valeur d’un seul champ de la timeserie :


```
label_values(kube_namespace_labels{namespace!~"kube-.*|default"},namespace)
```



Et tant qu’a y être, on va également se garder sous le coude une autre requête, quasiment identique, mais qui va nous permettre d’avoir la liste des déploiements présents dans votre cluster pour un (ou plusieurs) namespaces donnés :


```
label_values(kube_deployment_labels{namespace=~"$k8snamespace"}, deployment)
```



A partir de là, je peux ajouter des Variables dans mon Dashboard. Pour le faire, on doit cliquer sur la roue crantée en haut à droite de notre Dashboard :



![](/2019/12/grafana_roue_crantee.png) 


Puis ouvrir le menu "Variables" et ajouter les variables



![](/2019/12/grafana_variable_3.png)


A partir du moment où votre source de données et votre requête est entrée dans les champs _Data source_ et _query_, Grafana va vous donner un aperçu des valeurs qui seront disponibles (tout en bas du formulaire). Un bon moyen de vérifier que tout est bon avant de passer à l’étape suivante.



## Dans le dashboard, nos variables apparaissent !
  
  
On sauvegarde et on retourne dans notre Dashboard.

Si tout s’est bien passé, on a maintenant, en haut de notre Dashboard, plusieurs variables avec des menus déroulant pour les sélectionner.



![](/2018/09/variables3.png) 


Mais ce n’est pas magique pour autant...

Point un peu pénible, on va devoir maintenant modifier toutes nos visualisations (graphiques) pour prendre en compte le fait qu’on ajoute une variable.

Je ne saurai donc que trop vous conseiller de bien réfléchir à _comment_ vous allez variabiliser vos Dashboard _avant_ d’avoir trop de visualisation statiques...



## Ajout de la variable dans notre visualisation
  
  
On va donc ajouter la variable de manière à rendre nos graphiques dynamiques en fonction des valeurs sélectionnées dans le Dashboard, en modifiant la requête précédente par celle ci :


```
container_last_seen{namespace=~"$k8snamespace",container_name=~"$k8sdeployment.*",container_name!="POD"}
```



Qu’est ce qui a changé ?

Déjà, votre requête devrait répondre beaucoup plus vite ! Et pour cause, on vient non seulement de restreindre à un seul namespace (celui correspondant à la variable Grafana $k8snamespace et non plus la valeur fixe "kube-system") mais aussi à un seul Deployment donné (via $k8sdeployment).

_Note: on a également dégagé les containers s’appelant "POD", qui vont fausser les statistiques._

Pour autant, notre graphique n’est toujours pas exploitable... On voit bien qu’il existe 2 Pods pour mon Deployment, et si on cherche bien on pourra voir dans la timeserie sur quel Node chaque replica tourne, mais c’est fastidieux...



![](/2019/12/grafana_var1.png) 

> La valeur de chaque timeserie monte de manière constante. C’est normal, c’est un « uptime » 


## Compter le nombre de Pod par Node
  
  
On va s’en sortir en tirant parti d’une autre variable présente dans nos timeseries (qu’on a justement remarqué plus haut) : instance, ainsi que d’une fonction d’aggrégation du PromQL : count.

Cette variable permet, dans notre requête de savoir sur quel Node Kubernetes se situe notre Pod.

Voilà ce qu’on obtiendra en modifiant la requête de notre visualisation :


```
count(container_last_seen{namespace=~"$k8snamespace",container_name=~"$k8sdeployment.*",container_name!="POD"}) by (instance)
```


![](/2018/09/grafana1.png)

> Avec restriction sur le déploiement 


Là, c’est encore fastidieux, mais on commence à entrevoir la réponse à notre question initiale.
Dans les derniers graphiques, les couleurs représentent les Nodes Kubernetes, et la valeur numérique le nombre de Pods qui tournent dessus pour un Namespace donné. On voit donc que globalement, pour cet exemple précis, les Pods semblent bien répartis (puisque qu’on sélectionne un seul Deployment, on a bien un Pod par Node).



## Et la solution ?
  
  
Comment on fait pour voir tous les déploiements d’un coup ? Là, ça commence à devenir un peu plus touchy.

En vrai, la solution n’a plus vraiment d’intérêt en terme de découverte dans l’utilisation de Prometheus et de Grafana, dont j’ai montré les fonctionnalités lors des précédents paragraphes. Cependant, je ne vais pas vous laisser sur un cliffhanger ;-)

Je ne vais _tout_ détailler, mais dans l’idée, la solution que j’ai trouvée (il y en a peut être de plus élégantes) est :

* de lister tous les couples nom du déploiement + nom de l’hôte qui l’héberge
* de regrouper _par déploiement_ les items de la liste précédente et d’en faire une somme pour chaque déploiement
* de diviser chacun des items de cette dernière liste par le nombre total de container par déploiement
* d’afficher la liste des valeurs inférieures à 1


```
1. count(container_last_seen{namespace=~"$k8snamespace",container_name!~"^$|POD"}) by (container_name,instance))

2. count(count(container_last_seen{namespace=~"$k8snamespace",container_name!~"^$|POD"}) by (container_name,instance)) by (container_name)

3. count(count(container_last_seen{namespace=~"$k8snamespace",container_name!~"^$|POD"}) by (container_name,instance)) by (container_name) / count(container_last_seen{namespace=~"$k8snamespace",container_name!~"^$|POD"}) by (container_name)

4. count(count(container_last_seen{namespace=~"$k8snamespace",container_name!~"^$|POD"}) by (container_name,instance)) by (container_name) / count(container_last_seen{namespace=~"$k8snamespace",container_name!~"^$|POD"}) by (container_name) < 1
```



Ainsi, avec cette dernière formule, on peut lister l’ensemble des Deployments Kubernetes dont il existe un nombre de replica supérieur au nombre de Nodes qui les hébergent (et donc, de dénicher des soucis sur l’anti-affinités et par extension, de potentiels SPOF).



![](/2018/09/grafana6.png) 

CQFD :-D
