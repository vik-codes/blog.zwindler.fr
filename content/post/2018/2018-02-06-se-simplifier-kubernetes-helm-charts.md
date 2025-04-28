---
title: Se simplifier Kubernetes avec Helm et les Charts
authors:
  - zwindler
type: post
date: 2018-02-06T12:45:16+00:00
url: /2018/02/06/se-simplifier-kubernetes-helm-charts/
image: /2018/02/Kubernetes-Helm.png
categories:
  - Cluster
  - Logiciel
  - Virtualisation
tags:
  - charts
  - Helm
  - Kubernetes
  - MySQL
  - tiller
  - Xwiki
  - YAML

---
## Helm, Tiller, Charts : c’est quoi tout ça ?

Ceux qui suivent un peu le blog savent que [je bidouille pas mal avec Kubernetes en ce moment](/recherche/?keyword=Kubernetes). Dans mon travail précédent on commençait à peut être se dire que Swarm n’allait pas être suffisant (ahaha) et j’avais donc décidé de prendre les devants histoire de savoir de quoi je parle au moment où la décision serait prise de foncer ;-). Et rapidement je me suis rendu compte, qu’avec Kubernetes, on se retrouve vite à devoir écrire du YAML à tour de bras pour configurer nos ressources ([« petit » exemple avec XWiki, une application Tomcat + SGBDr](/2017/10/24/tutoriel-xwiki-ma-premier-appli-stateful-sur-kubernetes/)). C’est là que Helm (et Tiller) et les Charts entrent en jeu.

L’idée derrière Helm et les Charts ? Avoir un magasin en ligne d’applications multi-tiers déployables en une seule ligne de commande.

> The package manager for Kubernetes

Il faut voir celà comme un magasin un peu sur la philosophie de Dockerhub (applications officielles ou fournies par la communauté), permettant de déployer sur notre cluster des applications potentiellement complexes et/ou multi-tiers de manière automatique (un peu comme un docker-compose mais pour Kubernetes).

Avant d’aller plus loin, un peu de terminologie :

  * **Charts** : Collection de fichiers YAML variabilisés décrivant des ressources qui, misent bout à bout, donnent une application déployable sur Kubernetes
  * **Helm** : Client permettant de récupérer des Charts et de les appliquer sur un cluster Kubernetes
  * **Tiller** : Partie serveur permettant à un client Helm donner des ordres au cluster Kubernetes visé

## Installation de Helm

Ne faisons pas durer le suspens plus longtemps et attaquons nous à l’installation des composants nécessaires !

A noter, je pars du principe que vous disposez d’un cluster Kubernetes fonctionnel et que celui ci tourne sous Linux. Si ce n’est pas le cas je vous propose de lire mes tutoriels sur le déploiement de cluster Kubernetes, soit avec [Ansible (Kubespray)](/2017/10/05/installer-kubernetes-kubespray-ansible/) soit avec [l’outil Kubeadm](/2017/06/07/installer-cluster-kubernetes-vm-centos/).

A l’heure où j’écris ces lignes, l’outil Helm est disponible à sa version 2.8.0. Vous pouvez [retrouver la documentation officielle sur le Github][5] et [sur le site de Helm][6].

En réalité, il s’agit simplement d’une copie du binaire.

```
curl -o helm.tar.gz https://kubernetes-helm.storage.googleapis.com/helm-v2.8.0-linux-amd64.tar.gz
tar xzf helm.tar.gz
mv linux-amd64/helm /usr/local/bin
```

## Contexte

Dans le cas où vous ne seriez pas directement sur une des machines du cluster, il est nécessaire de disposer de **kubectl** et surtout d’avoir correctement configuré son « contexte ».

Dans le cas où le contexte n’est pas configuré vous aurez le message suivant :

```
kubectl config current-context
    error: current-context is not set
```


Cependant, si vous vous mettez en SSH directement sur un serveur qui est master, cette étape est potentiellement inutile (le contexte par défaut est administrateur dans ce cas).

On vérifie qu’on arrive bien à requêter le cluster :

```
kubectl cluster-info
    Kubernetes master is running at http://localhost:8080
    KubeDNS is running at http://localhost:8080/api/v1/namespaces/kube-system/services/kube-dns/proxy
```


## Tiller

Maintenant qu’on dispose d’un client Helm ayant accès au contexte de notre cluster, on peut installer Tiller. Utiliser la commande « helm init ». Attention : Tiller sera installé dans le contexte courant, ne vous trompez pas de cluster ;-).

```
helm init
    Creating /root/.helm
    Creating /root/.helm/repository
    Creating /root/.helm/repository/cache
    Creating /root/.helm/repository/local
    Creating /root/.helm/plugins
    Creating /root/.helm/starters
    Creating /root/.helm/cache/archive
    Creating /root/.helm/repository/repositories.yaml
    Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
    Adding local repo with URL: http://127.0.0.1:8879/charts
    $HELM_HOME has been configured at /root/.helm.

    Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.
    Happy Helming!
```


## Et maintenant, on fait quoi ?

Maintenant qu’on a installé tous les composants dont nous avions besoin (et oui déjà), on va se contenter de dans un premier temps de suivre les exemples fournis. La documentation officielle nous propose de déployer une base MySQL.

Bonne idée, voyons ce que ça donne !

La première étape qu’on nous demande de faire est de mettre à jour la liste des Charts disponibles sur le dépôt officiel :

```
helm repo update #mettre à jour la liste des charts disponibles sur le store officiel
  Hang tight while we grab the latest from your chart repositories...
  ...Skip local chart repository
  ...Successfully got an update from the "stable" chart repository
  Update Complete. ⎈ Happy Helming!⎈
```


J’adore le petit caractère « barre de navigateur » ;-)

Plus sérieusement, l’étape d’après est simplement de faire un **helm install**, qui va se charger de récupérer tous les YAML nécessaires pour déployer MySQL. La liste des composants Kubernetes créés apparaitra ensuite à l’écran (et vous pouvez les retrouver sur votre cluster avec un **kubectl**).


```
helm install stable/mysql
  NAME:   silly-moose
  LAST DEPLOYED: Tue Dec  5 10:12:58 2017
  NAMESPACE: default
  STATUS: DEPLOYED

  RESOURCES:
  ==> v1/Secret
  NAME               TYPE    DATA  AGE
  silly-moose-mysql  Opaque  2     1m

  ==> v1/PersistentVolumeClaim
  NAME               STATUS   VOLUME  CAPACITY  ACCESS MODES  STORAGECLASS  AGE
  silly-moose-mysql  Pending  1m

  ==> v1/Service
  NAME               TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)   AGE
  silly-moose-mysql  ClusterIP  10.233.54.164         3306/TCP  1m

  ==> v1beta1/Deployment
  NAME               DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
  silly-moose-mysql  1        1        1           0          1m

  ==> v1/Pod(related)
  NAME                                READY  STATUS   RESTARTS  AGE
  silly-moose-mysql-3998799777-hk5fj  0/1    Pending  0         1m
```


Sans surprise on retrouve un **Secret** (le mot de passe de votre utilisateur), un **PersistentVolumeClaim** (pour stocker vos données), un **Service** de type _ClusterIP_ pour accéder et un **Deployment** pour MySQL lui même.

**A noter :** par défaut, Kubernetes donne un _petit nom aléatoire_ à nos composants pour les rendre uniques, car nous n’avons pas donné de nom en arguments.

On remarquera la délicate attention des gens qui ont écrit le Chart et qui affiche, une fois le déploiement terminé, les étapes suivantes pour vérifier que tout fonctionne et se connecter une première fois.

```
NOTES:
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
silly-moose-mysql.default.svc.cluster.local

To get your root password run:
    kubectl get secret --namespace default silly-moose-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo

To connect to your database:

1. Run an Ubuntu pod that you can use as a client:
    kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

2. Install the mysql client:
    $ apt-get update && apt-get install mysql-client -y

3. Connect using the mysql cli, then provide your password:
    $ mysql -h silly-moose-mysql -p
```


## OK je teste alors !

Et normalement, si vous essayez, **ça ne marchera pas !**

Pourquoi ça ? On a bien tous les composants pour faire marcher MySQL.

Tous ?

Non ! Un irréductible gaulois résiste à l’envahisseur. Vous l’avez trouvé ?

![](/2017/12/pvc_for_mysql.png)

Et oui ! La documentation nous dit juste de faire un **helm install**... sans nous rappeler que le **PersistentVolumeClaim** qui sera créé nécessite ... un **PersistentVolume** ! Pour ceux qui n’auraient pas révisé leur terminologie Kubernetes, en gros MySQL attend qu’un disque se libère mais aucun n’est disponible.

Le **Deployment** se bloque donc à l’étape de _Claim_ et y restera indéfiniment tant qu’un PV compatible n’est pas disponible.

![](/2017/12/pvc_not_bound.png)

On doit donc créer un PV. Personnellement [j’ai créé un volume gluster parce que j’aime bien GlusterFS](/recherche/?keyword=gluster) et j’ai créé le PV manquant dans Kubernetes.

```
gluster volume create gluster-pv-mysql replica 3 node01:/brick/gluster-pv-mysql node02:/brick/gluster-pv-mysql node03:/brick/gluster-pv-mysql force
    volume create: gluster-pv-mysql: success: please start the volume to access data
    
gluster volume start gluster-pv-mysql
    volume start: gluster-pv-mysql: success

cat > gluster-pv-mysql.yaml << EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gluster-pv-mysql
spec:
  capacity:
    storage: 20Gi
  accessModes:
  - ReadWriteOnce
  glusterfs:
    endpoints: gluster-cluster
    path: /gluster-pv-mysql
    readOnly: false
  persistentVolumeReclaimPolicy: Delete
EOF

kubectl apply -f gluster-pv-mysql.yaml
```


A partir de là, votre **Deployment** devrait reprendre la main.

**Facile, hein ?**

## Ouais ok mais moi je veux modifier le nom de ma base MySQL

Ok on est capable de déployer MySQL, super. Mais généralement on veut personnaliser les composants qu’on déploie !

C’est bien évidemment prévu par les Charts, c’est même leur but premier.

Pour savoir ce qui peut être personnalisé et qui dépendra de chaque **Chart** que vous utiliserez, pas le choix : il faut aller lire [la documentation du Chart de MySQL (ici sur Github)][10].

![](/2017/12/stable_mysql_chart_variables.png)

Pour vous donner un petit exemple de ce qu’on peut faire avec notre MySQL, voici quelques arguments utiles que vous pouvez personnaliser :

```
helm install --name test \
  --set mysqlLRootPassword=secretpassword,mysqlUser=zwindler,mysqlPassword=supermotdepasse,mysqlDatabase=zwindlerdb \
    stable/mysql
```


Après déploiement, on peut retester la connexion via un container ubuntu temporaire (comme la fois d’avant), et s’assurer qu’on peut se connecter sur notre base MySQL avec notre nouvel utilisateur _zwindler_ et son _supermotdepasse_ !

```
[root@node01 ~]# kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il
If you don't see a command prompt, try pressing enter.
root@ubuntu:/#
root@ubuntu:/# apt-get update && apt-get install mysql-client -y
[…]
mysql -h test-mysql -u zwindler -p
#supermotdepasse
```


## Et on nettoie tout : supprimer un Chart

Dans le cas où vous voudriez tout nettoyer d’un coup, vous pouvez utiliser Helm pour supprimer en même temps tous les composants que vous auriez déployés via un « helm install mon-chart ».

Ici, je peux supprimer l’ensemble des composants qui ont été créés dans cet exemple « silly-moose-mysql ».

```
helm delete silly-moose-mysql
release "silly-moose-mysql" deleted
```

 [5]: https://github.com/kubernetes/helm
 [6]: https://docs.helm.sh/using_helm/#quickstart-guide
 [10]: https://github.com/kubernetes/charts/tree/master/stable/mysql
