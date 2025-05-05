---
title: 'J’ai testé pour vous AKS, la plateforme Kubernetes managée d’Azure'
authors:
  - zwindler
type: post
date: 2018-12-18T12:45:33+00:00
url: /2018/12/18/jai-teste-pour-vous-aks-la-plateforme-kubernetes-managee-dazure/
image: /2018/12/aks.jpg
categories:
  - systeme
  - Virtualisation
tags:
  - ACI
  - AKS
  - azure
  - EKS
  - GKE
  - k8s
  - Kubernetes

---
## AKS = Azure Kubernetes Service

Après EKS (Amazon) et GKE (Google) (et plein d’autres en fait), Azure a fini par lancer aussi son service managé de Kubernetes ([preview en octobre 2017][1]).

Ce service ne doit pas être confondu avec ACI (Azure Container Instances) qui est le service d’Azure CaaS, où vous pouvez instancier les containers à la demande sur les Kubernetes d’Azure, où Kubernetes vous est complètement caché.

Vous verrez aussi peut être dans la littérature des références à ACS (l’ancien nom d’AKS) ou alors de [ACS-engine][2], qui est le projet utilisé par Azure pour déployer des clusters Kubernetes (sur du IaaS) pour leur besoins propres et qu’ils ont open sourcé.

Il s’agit donc bien d’un service fourni par Azure, qui masque toute la complexité du déploiement des machines et des composants de Kubernetes. Vous n’aurez pas accès aux VMs, on n’est donc pas sur du IaaS. Mais contrairement à ACI, vous aurez les pleins pouvoir sur le _control plane_ de Kubernetes, et vous pourrez l’administrer comme bon vous semble.

## C’est vraiment facile à installer ?

Oui, c’est vraiment simple. L’installation peut se faire depuis le portail ou en quelques commandes « az cli »

Pour tout vous dire, Microsoft a même pousser le vice jusqu’à faciliter l’installation du binaire **kubectl**, ainsi que la configuration de votre cluster dans les contextes (via des commandes « az cli »). Dans l’absolu, les commandes qu’on va faire ci dessous sont équivalentes à celles que j’ai décrites dans l’article  [Installer kubectl et Configurer kubectl][3].

> Nice to have

## C’est parti !!

Depuis le portail, cherchez « Kubernetes services », puis cliquez sur « Add ».

![](/2018/12/aks_setup2.png)

Et si vous préférez comme moi le faire en lignes de commande, ça donne quelque chose comme ça :

```
az group create --name myownkubernetescluster --location westeurope --subscription "mysubscription"
az aks create --resource-group myownkubernetescluster --name myawesomeclsuter --node-count 3 --enable-addons monitoring --node-vm-size Standard_B2s --kubernetes-version 1.10.9 --ssh-key-value ~/.ssh/mypublicsshkey.pub --subscription "mysubscription"
```

Si vous l’avez fait depuis le portail, vous verrez également une popup sur la droite pour vous aider à configurer kubectl (mais vous pouvez aussi les utiliser si vous avez monté le cluster avec les commandes précédentes aussi).

Les commandes à lancer après avoir déployé le cluster sont les suivantes :

![](/2018/10/aks_login01.png)

```
az aks install-cli
Downloading client to /usr/local/bin/kubectl from https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl
Please ensure that /usr/local/bin is in your search PATH, so the `kubectl` command can be found.
```


Si vous essayez de les lancer sans avoir fait votre **az login**, vous aurez l’erreur suivante

```
az aks get-credentials --resource-group myownkubernetescluster --name myawesomeclsuter
Resource group 'test_AKS' could not be found.
```


On se logue, donc

```
az login

Note, we have launched a browser for you to login. For old experience with device code, use "az login --use-device-code"
```


Comme l’indique la commande, **az cli** à récemment changé de méthode d’authentification par défaut.

Si vous lancez ces commandes et que vous n’avez pas d’environnement graphique (dans une petite VM par exemple), vous pouvez toujours utiliser l’ancienne méthode avec un code à recopier dans une page web avec la commande suivante :

```
az login --use-device-code
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code TOTOTOTOTO to authenticate.
```


Dans mon cas, j’ai accès à un abonnement Visual Studio en plus de mes souscriptions habituelles.

Par défaut, cette souscription est filtrée, donc **az cli** continuera à ne pas « voir » le ressource group que j’aurai créé pour l’occasion. L’idéal est de l’indiquer explicitement en ajoutant un « --subscription ». Une autre solution, plus simple, pour éviter le problème est de positionner cette souscription comme « par défaut »

```
az account set --subscription "Visual Studio"
```


Maintenant ça devrait marcher. On récupère les crédentials et les informations du contexte.

Par défaut, **az cli** va merger ces informations avec votre **.kube/config** existant s’il existe. Si vous avez peur qu’il fasse des bêtises, pensez à le sauvegarder avant.

```
az aks get-credentials --resource-group myownkubernetescluster --name myawesomeclsuter
/root/.kube/config has permissions "644".
It should be readable and writable only by its owner.
Merged "testaksdge" as current context in /root/.kube/config
```


![](/2018/10/aks_login02.png)
Maintenant que l’outil **az cli** a configuré notre contexte pour nous, on peut interagir avec le cluster normalement :

```
kubectl get nodes
NAME                       STATUS   ROLES   AGE   VERSION
aks-nodepool1-36034183-0   Ready    agent   26m   v1.10.9
aks-nodepool1-36034183-1   Ready    agent   26m   v1.10.9
aks-nodepool1-36034183-2   Ready    agent   26m   v1.10.9
```


Lancer le « proxy » (pour afficher le dashboard et accéder à l’API)

```
az aks browse --resource-group myownkubernetescluster --name myawesomeclsuter
[...]
Proxy running on http://127.0.0.1:8001/
Press CTRL+C to close the tunnel...
[...]
```

![](/2018/10/aks_login03.png)

## Etape supplémentaire si vous avez activé le RBAC

Si vous avez activé le RBAC, **ce que je vous conseille fortement et qui devrait être le choix par défaut**, votre dashboard n’aura pratiquement accès à rien !

Il faut lui ajouter des droits sur le cluster. La procédure complète d’Azure [vous indique la marche à suivre ici][8]. Ce que eux conseillent, qui est effectivement le plus simple (mais pas le plus sage), est de donner les droits **cluster-admin** au service account **kubernetes-dashboard**...

```
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
```


Mais attention aux conséquences ! De très nombreuses personnes laissent le dashboard ouvert sur Internet et si EN PLUS votre dashboard est admin du cluster, vous allez rapidement miner des cryptocurrencies et lancer des mails de SPAM à votre insu...

N’autorisez donc pas le portail depuis l’extérieur.

## Et après ?

Dans le cycle de vie d’un cluster Kubernetes, deux tâches vont très vite vous intéresser. Sauvegarder vos objets (ce qu’on peut faire avec [Ark de Heptio][9]) et mettre à jour votre cluster (ce qu’on peut faire avec AKS).

Ces deux points seront le focus d’articles futurs ;-)

 [1]: https://azure.microsoft.com/en-us/blog/introducing-azure-container-service-aks-managed-kubernetes-and-azure-container-registry-geo-replication/
 [2]: https://github.com/Azure/acs-engine
 [3]: /2018/10/16/configurer-ses-contextes-pour-kubectl-sur-un-poste-client/
 [4]: /2018/12/aks_setup2.png
 [5]: /2018/10/aks_login01.png
 [6]: /2018/10/aks_login02.png
 [7]: /2018/10/aks_login03.png
 [8]: https://docs.microsoft.com/fr-fr/azure/aks/kubernetes-dashboard
 [9]: https://github.com/heptio/ark
