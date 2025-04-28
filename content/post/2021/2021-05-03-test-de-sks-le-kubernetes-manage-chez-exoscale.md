---
title: Test de SKS, le Kubernetes managé chez Exoscale !
authors:
  - zwindler
type: post
date: 2021-05-03T06:20:00+00:00
excerpt: "Présentation et test de SKS (Scalable Kubernetes Service), la plateforme Kubernetes managée d'Exoscale"
url: /2021/05/03/test-de-sks-le-kubernetes-manage-chez-exoscale/
image: /2021/05/exoscale_sks_features.png
categories:
  - Cluster
  - Virtualisation
tags:
  - Exoscale
  - k8s
  - kubectl
  - Kubernetes
  - managé
  - saas
  - SKS

---
## Kewa ? Exoscale a un Kubernetes Managé ?

Lorsque [Mathieu Corbin](https://bsky.app/profile/mcorbin.bsky.social) m’a parlé du Kubernetes managé qu’ils étaient en train de monter chez Exoscale, je lui ai tout de suite proposé de me le montrer, pour que je lui donne mon point de vue.

Sans être un expert absolu des offres Kubernetes en SaaS, j’en ai quand même testé quelques uns, notamment [AKS d’Azure](/2018/12/18/jai-teste-pour-vous-aks-la-plateforme-kubernetes-managee-dazure/), [OVH ](/2019/07/09/jai-teste-pour-vous-loffre-kubernetes-as-a-service-dovh/)et quelques autres (GCP, Kapsule, … pour lesquels je n’ai pas fait d’article).

Et puis, bon, Kubernetes, c’est un peu mon métier maintenant ;-).

Au moment où j’ai rédigé le premier brouillon de cet article, on était encore en bêta fermée. Il n’y avait pas d’interface graphique dans le portail (uniquement la CLI), certains paramètres étaient pas totalement dans les règles de l’art (problèmes connus chez eux), …

Et puis le temps a passé et je n’ai pas sorti l’article (comme souvent par manque de temps) avant que la solution passe GA. 

Heureusement, le passage en GA c’est aussi une bonne occasion pour moi de refaire le test et de comparer le boulot qui a été accompli (en peu de temps) pour gommer les quelques défauts de jeunesse que la solution pouvait encore avoir.

## Mais d’abord, Exoscale ?

J’vais pas mentir, même si j’avais déjà croisé le nom d’Exoscale plusieurs fois, je n’avais jamais pris le temps de tester leur offre. Pour ceux qui l’ignorent donc, [Exoscale est un cloud provider](https://www.exoscale.com/) avec plusieurs points de présence en Europe.

Niveau taille de l’acteur, on est pas du tout comparables à un OVH (ou même Scaleway), mais ils sont suffisamment nombreux pour se permettre d’avoir une team dédiée à la release d’un Kubernetes managé. Tout en gardant suffisamment de bande passante pour quand même avoir une API ouverte et documentée, comme les grands.

## Et donc, SKS ?

Cette micro introduction d’Exoscale passée, revenons donc à nos nuages.

L’offre Kubernetes managée d’Exoscale s’appelle SKS (pour Scalable Kubernetes Service).

![](/2021/05/exoscale_sks_features.png)

On nous promet donc sur le site d’Exoscale un service scalable (horizontalement), qui démarre normalement en 90 secondes.

La gestion du cycle de vie du control plane est entièrement gérée, on peut le déployer via CLI, API, depuis le portail et [il existe aussi un provider terraform](https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_cluster). 

Enfin, Exoscale a développé un composant permettant de faciliter l’intégration de son load balancer managé dans SKS (pour l’instant).

Et comme je vous l’avais promis, [l’API de SKS est documentée ici](https://openapi-v2.exoscale.com/#endpoint-sks) si jamais vous aimez faire des cURL.

## Et ça coute cher ?

Dans les offres managées de Kubernetes, il y a plusieurs clans. Ceux qui proposent un SLA sur le control plane et ceux qui n’en proposent pas. Et il y a ceux qui font payer le control plane et ceux qui ne le font pas payer.

Souvent, ceux qui ne font pas payer le control plane sont également les mêmes qui ne proposent pas de SLA sur le control plane. 

Et pour avoir discuté avec un commercial de chez Azure en fait il y a une certaine logique à ne pas proposer de SLA sur un control plane gratuit. Un SLA étant un contrat, difficile de s’engager sur un service gratuit (et encore plus, difficile de vous rembourser ce que vous ne payer pas en cas de problème).

![](/2021/05/sub-buzz-8705-1503572294-5.jpg)

Chez Exoscale, c’est fromage ou dessert, vous avez le choix. SKS est offert en 2 offres distinctes :

  * une payante, avec SLA (99,95%)
  * l’autre gratuite, sans SLA

Classiquement, les workers sont quant à eux facturés au même prix que n’importe quelle machine IaaS chez Exoscale. 

Petite subtilité qui m’a fait sourire, là où les clouds providers se battaient sur qui bill à l’unité de temps la plus petite il y a 10 ans (d’abord l’heure, puis progressivement à la minute), chez Exoscale, vous êtes billé à la seconde. Difficile de faire plus précis.

Pour tout ce qui concerne le pricing, je vous laisse [aller voir ici](https://www.exoscale.com/pricing/). N’ayant aucun intérêt financier à vous pousser vers Exoscale (ou OVH, ou Azure), je ne vais pas insister plus que ça ;-).

## Bon, on teste ?

Maintenant qu’on a fait le tour de la question, et si on essayait un peu de voir ce que ça donne ?

La première chose à faire est de se créer un compte sur [www.exoscale.com](http://www.exoscale.com) et aussi télécharger la dernière version de la CLI.

J’insiste bien sur la « dernière version » car pendant la bêta j’avais téléchargé la mauvaise version et l’API et les paramètres avaient changé de manière significative en peu de temps.

A l’heure où j’écris l’article, la dernière version est la 1.28 (1.23 quand j’ai testé la bêta en début d’année) mais les releases sont dispos ici : [github.com/exoscale/cli/releases](https://github.com/exoscale/cli/releases)

```
wget https://github.com/exoscale/cli/releases/download/v1.28.0/exoscale-cli_1.28.0_linux_amd64.tar.gz
tar xzf exoscale-cli_1.28.0_linux_amd64.tar.gz
➜  ./exo 
Manage your Exoscale infrastructure easily
[...]
```


A noter, il existe aussi pour les distributions linux des packages (.deb, .rpm, etc).

## Configuration du compte

Maintenant qu’on a notre CLI sur notre poste, on va aller dans le portail créer une clé d’API qui va nous servir à nous authentifier.

[La documentation officielle est disponible ici.](https://community.exoscale.com/documentation/tools/exoscale-command-line-interface/)

![](/2021/05/exo_api_key_create.png)

Une fois que vous aurez cliqué sur « Create », l’ID de la clé ainsi que la clé apparaitra. Attention, comme toujours avec ce genre de mécanisme, la clé ne sera visible que cette fois ci. Sauvegardez là donc bien précieusement (sinon au pire il faudra en générer une nouvelle).
![](/2021/05/exo_key_3.png)

On peut ensuite configurer notre CLI

```
./exo config
```

![](/2021/05/exo_config.png)

Et on teste que la connexion marche bien avec la commande permettant de lister les versions de Kubernetes disponibles sur SKS

```
./exo sks versions
```

![](/2021/05/exo_cli_sks_versions.png)

Bon, je sais pas vous mais moi a me donne le sourire de voir que fin avril, Exoscale a déjà la 1.21 dispo :-)

## Création du security group

Exoscale dispose, comme tous les cloud providers, d’un système de firewalling qui permet d’appliquer des règles de sécurité à nos futures machines.

Même si la création d’un groupe de sécurité n’est pas obligatoire pour instancier notre cluster SKS, c’est mieux si on le fait dès le début.

Tout peut se faire via la CLI ou via le portail, comme pour le reste chez Exoscale

```
./exo firewall create sks-zwindler-sg
./exo firewall add sks-zwindler-sg -d "NodePort services" -p tcp -P 30000-32767
./exo firewall add sks-zwindler-sg -d "SKS Logs" -p tcp -P 10250
./exo firewall add sks-zwindler-sg -d "Calico traffic" -p udp -P 4789 -s sks-zwindler-sg
```


Si vous préférez le faie sur le portail, ça ressemblera à ça :

![](/2021/05/sks_sg_calico.png)

J’ai juste repris les valeurs par défaut dans la doc [de Quick Start](https://community.exoscale.com/documentation/sks/quick-start/)

## Créer un cluster

La commande `exo sks create` permet de créer notre cluster. On peut rajouter des flags pour modifier certains paramètres :

```
exo sks create -h
```


![](/2021/05/exo_sks_usage.png)

Au delà des options pour choisir la taille du cluster et le type de node, les options intéressantes sont les 3 « --no- » qui vous permettent de désactiver l’installation automatique de :

  * la CNI (Calico par défaut). Calico par défaut est un bon choix mais si vous préférez Cillium ou kube-router (ou flannel… nan j’déconne !).
  * la CCM (Cloud Controller Manager), composant développé en interne par Exoscale et qui permettra à Kube d’interagir avec les autres services d’Exoscale (notamment le loadbalancer)
  * metrics-server mais là je vois pas pourquoi vous ne voudriez pas metrics-server …

```
./exo sks create sks-zwindler --description "Test SKS cluster" --nodepool-name "sks-zwindler-pool" --nodepool-size 3 --nodepool-security-group "sks-zwindler-sg" --zone de-fra-1 --service-level pro
 &#x2714; Creating SKS cluster "sks-zwindler"... 1m57s
 &#x2714; Adding Nodepool "sks-zwindler-pool"... 3s
```


Je ne sais pas si je n’ai pas eu de chance car il me semblait que ça allait un peu plus vite que les deux minutes que j’affiche dans cet extrait de shell. Mais 2 minutes c’est déjà plus que respectable quand on sait que chez Azure, AKS met plus de 20 minutes à poper (quand ça ne plante pas), sans compter les VMs (qui elles aussi mettent parfois 10 minutes avant d’être disponibles)...

## kubeconfig

Disponible… ok … Mais comment on s’y connecte en fait ?

Pas de panique, la CLI permet de générer le kubeconfig qui va vous permettre de vous connecter à l’API server ! (ouf)

Un point intéressant de l’implémentation d’Exoscale est que vous pouvez tuner un peu le kubeconfig qu’il va vous générer (là où la plupart du temps, c’est un kubeconfig admin, point). Vous pouvez notamment choisir le groupe RBAC ainsi qu’une durée de vie.

Dans un environnement de production avec beaucoup d’utilisateurs, on préfèrera surement ajouter une authentification tierce (coucou OIDC), cependant, c’est quand même « nice to have ».

```
./exo sks kubeconfig sks-zwindler kube-admin --group system:masters --zone de-fra-1 > sks-zwindler-30d.kubeconfig
```


L’authentification se fait donc par certificat avec une durée que vous pouvez configurer en secondes (par défaut 30 jours). Bon, comme je vois que ce que je crois, j’ai fait le test avec 60 secondes et a priori ça marche ;-).

```
./exo sks kubeconfig sks-zwindler kube-admin --group system:masters --zone de-fra-1 --ttl 60 > test-60s.kubeconfig

kubectl --kubeconfig test-60s.kubeconfig get nodes
NAME               STATUS    ROLES     AGE       VERSION
pool-afa3f-apzqy   Ready     <none>    6h        v1.21.0
pool-afa3f-iehif   Ready     <none>    6h        v1.21.0
pool-afa3f-ysvki   Ready     <none>    6h        v1.21.0

#plus tard
kubectl --kubeconfig test-60s.kubeconfig get nodes
error: You must be logged in to the server (Unauthorized)
```


## Déployer une application disponible sur Internet

Comme la CCM nous permet de faire communiquer notre Kubernetes et Exoscale, on va en profiter pour créer un service Kubernetes de type Loadbalancer.

Ce service Loadbalancer va commander à Exoscale un NLB chez eux, ce qui va nous permettre de router le trafic Internet directement dans notre cluster (il vaudrait mieux passer par un IngressController brancher sur ce service Loadbalancer dans la vraie vie).

```
kubectl --kubeconfig sks-zwindler-30d.kubeconfig create service loadbalancer toto --tcp=80:80

kubectl --kubeconfig sks-zwindler-30d.kubeconfig get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP        8h
toto         LoadBalancer   10.111.39.139   <pending>     80:30001/TCP   22s

kubectl --kubeconfig sks-zwindler-30d.kubeconfig get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>           443/TCP        8h
toto         LoadBalancer   10.111.39.139   89.145.161.242   80:30001/TCP   23s
```


Puis on déploie un nginx de test avec un label similaire à celui créé par défaut par le service (app=toto)

```
kubectl --kubeconfig sks-zwindler-30d.kubeconfig run --image nginx --labels app=toto toto
```


Très rapidement, vous devriez avoir accès à votre pod via l’IP du NLB Exoscale


![](/2021/05/exoscale_nginx.png)

## Nettoyage

Si vous avez mis votre carte de crédit, n’oubliez de supprimer votre cluster de test avant de partir ;-)

```
./exo sks delete sks-zwindler -n
[+] Are you sure you want to delete Nodepool "sks-zwindler-pool"? [yN]: y
 &#x2714; Deleting Nodepool "sks-zwindler-pool"... 6s
[+] Are you sure you want to delete SKS cluster "sks-zwindler"? [yN]: y
 &#x2714; Deleting SKS cluster "sks-zwindler"... 18s
```


Et faites pareil si vous avez un instancié un Loadbalancer pour connecter vos services dans Kubernetes avec l’extérieur (j’avais oublié… oups).

## Conclusion

J’avais été impressionné par l’implémentation d’OVH de Kubernetes managé, mais je dois reconnaitre que je le suis encore plus par celui d’Exoscale.

Le cluster (control plane) est créé TRES vite, mais surtout les VMs popent également extrêmement vite (quelques secondes versus 10 minutes chez Azure !!!). C’est vraiment chouette !

De ce que j’ai vu (et pu échanger) des entrailles de SKS, tout me parait très sain et bien conçu (sécurité, best practices). Et pourtant, Exoscale donne quand même pas mal de libertés sur la customisation du cluster (CCM, CNI, configuration kubeconfig).

Les petits bugs de jeunesses (quelques erreurs de configuration du kubelet, des erreurs cosmétiques dans les commands lines, le CCM à installer soit même, …) que j’avais pu remonter à Mathieu lors de mon test en janvier/février ont toutes été gommés en moins de 2 mois.

Donc, selon moi, si vous cherchez un kube managé, SKS est une alternative viable.
