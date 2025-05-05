---
title: Configurer ses contextes kubernetes dans kubectl sur un poste client
authors:
  - zwindler
type: post
date: 2018-10-16T11:45:00+00:00
url: /2018/10/16/configurer-ses-contextes-pour-kubectl-sur-un-poste-client/
image: /2017/11/kubernetes2.png
categories:
  - Cluster
  - systeme
  - Virtualisation
tags:
  - CAcert
  - kubectl
  - Kubernetes

---
## Mais d’où il sort ce contexte ?

Encore un article qui traînait dans mon tiroir, depuis des mois ;-). Vous avez peut être suivi un de mes tutoriels pour installer Kubernetes, que ce soit avec [kubeadm](/2017/06/07/installer-cluster-kubernetes-vm-centos/), [kubespray](/2017/12/05/installer-kubernetes-kubespray-ansible/), ou plus récemment avec [Minikube](/2018/09/12/installer-minikube-sur-windows-10-et-hyper-v-part-1/). Vous avez peut être également lu le petit article que j’ai fais sur [kubectx/kubens](/2018/08/28/utiliser-kubectx-kubens-pour-changer-facilement-de-context-et-de-namespace-dans-kubernetes/), pour se faciliter la gestion des contexts, quand on en a beaucoup.

Mais après avoir instancié un cluster et avant d’avoir à jongler entre plusieurs contextes, j’ai peut être zappé une (petite) étape entre les deux. Un détail, vraiment... il faut configurer les contextes en question !

La documentation officielle, si elle est riche et complète, a aussi l’inconvénient d’être assez troublante pour un néophyte, car il faut trier parmi plusieurs pages et une multitude de cas particuliers :

  * [Users in Kubernetes][5]
  * [Using RBAC Authorization][6]
  * [Accessing Clusters][7]
  * [Configure access to multiple clusters][7]

## Authentification depuis l’arrivée du RBAC dans Kubernetes

Si vous suivez un peu Kubernetes, vous êtes peut être au courant d’une révolution qui est arrivée (et heureusement) dans l’administration des clusters Kubernetes. Depuis la version 1.7 (oui ce brouillon est en attente depuis la 1.7), on est passé du mode _ABAC_ où les permissions des **ServicesAccount** étaient gérées dans un fichier de configuration et où les permissions étaient souvent très laxistes par défaut, à un mode _RBAC_ ([Role-based access control][6]), bien plus riche et souvent mieux maîtrisé.

Maintenant, on peut donc créer des **ServicesAccount** (pour nos applications), et les relier à des **Roles** (limité à un namespace) ou des **ClusterRoles** (pour tout le cluster), eux mêmes respectivement reliés par des **RolesBindings** et des **ClusterRoleBindings**. Vous me suivez ?

## Créer l’utilisateur (sur un master)

Le plus propre serait évidement de disposer d’une source d’authentification externe (type LDAP/AD ou autre) mais pour les besoins du tuto on va rester basique et fonctionner avec ce dont on dispose dans le K8s seulement, c’est à dire les **ServiceAccounts**. A noter, _n’utilisez pas cela en production, ce n’est pas conseillé. Mettez en place une source externe type LDAP/AD/...._

Sur un des masters où l’on a installé Kubernetes, on va donc créer un **ServiceAccount** avec **kubectl**. On l’utilisera par la suite pour se connecter en kubectl depuis notre poste client :

```
cat > myserviceaccount.yaml << EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myserviceaccount
EOF

kubectl apply -f myserviceaccount.yaml
serviceaccount/myserviceaccount created
```


Par défaut, ce **ServiceAccount** n’aura accès à pratiquement rien. On va donc créer un **ClusterRoleBinding** qui va lier notre **ServiceAccount** avec un **ClusterRole** existant avec le niveau de privilèges qu’on souhaitera.

Pour obtenir la liste des **ClusterRoles** disponibles sur votre cluster, vous pouvez les lister avec la commande suivante :

```
kubectl get clusterrole
NAME                                                                   AGE
admin                                                                  1d
cluster-admin                                                          1d
[...]
view                                                                   1d
```


On privilégiera un **ClusterRole** avec juste les permissions nécessaires et pas plus, par exemple « **view** » pour commencer.

```
cat > crbmyserviceaccount.yaml << EOF
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: crbmyserviceaccount
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: myserviceaccount
  namespace: default
EOF

kubectl apply -f crbmyserviceaccount.yaml
clusterrolebinding.rbac.authorization.k8s.io/crbmyserviceaccount created
```


Note : Si le **ClusterRole** de vos rêves n’existe pas, vous pouvez toujours en créer un vous même avec les privilèges que vous souhaitez.

## Récupérer les informations du cluster (sur un master)

Maintenant qu’on a créé le **ServiceAccount** et qu’il dispose d’un **ClusterRole** grâce au **ClusterRoleBinding**, un token a été créé par défaut et enregistré dans un **Secret**.

On le retrouve, puis on l’exporte

```
kubectl get secrets
NAME                                TYPE                                  DATA   AGE
[...]
myserviceaccount-token-bmwwd        kubernetes.io/service-account-token   3      5m
```


```
kubectl describe secret myserviceaccount-token-xxxxx
Name:         myserviceaccount-token-xxxxx
[...]
token:      eyJhbGciOiJSUzI1.....
```


Éventuellement aussi on récupère l’URL d’accès à l’API server permettant de contrôler Kubernetes

```
kubectl config view | grep server | cut -f 2- -d ":" | tr -d " "
https://@IPMYAWESOMECLUSTERNAME:6443
```

## Configuration de kubectl (sur le client)

Pour me simplifier la vie, je _sette_ la variable **K8SAPI** pour éviter de retaper à chaque fois l’URL de l’API server qu’on a récupéré juste avant, mais rien ne vous y oblige ! On configure le « cluster » dans notre kubeconfig

```
K8SAPI=https://@IPMYAWESOMECLUSTERNAME:6443
kubectl config set-cluster myawesomecluster --server=${K8SAPI}
```


Maintenant que le cluster est configuré, on créé des credentials, à partir du token qu’on vient de récupérer

```
kubectl config set-credentials myawesomecluster-myserviceaccount --token=<token_récupéré_sur_le_master>
```


Enfin, on créé un contexte, à partir du cluster et du credential qu’on a créé précédemment

```
kubectl config set-context myawesomecluster --cluster=myawesomecluster --user=myawesomecluster-myserviceaccount --namespace=default
kubectl config use-context myawesomecluster

kubectl config get-contexts
CURRENT NAME CLUSTER AUTHINFO NAMESPACE
* myawesomecluster myawesomecluster myawesomecluster-myserviceaccount default
```


Vous devriez maintenant avoir accès à votre cluster depuis votre poste client !

```
kubectl get nodes
```


## BONUS : fichier .kube/config

Pour information, tout ceci est stocké dans un fichier config, créé par défaut dans dossier .kube de votre home directory (~/.kube/config). Si jamais vous êtes aventuriers, vous pouvez d’ailleurs tout écrire vous même, à la main ;-). Plus sérieusement, il peut être utile de savoir où il est pour pouvoir effectuer des modifications de masse, plus pratique qu’avec la ligne de commande **kubectl config**.

Ce fichier est le fichier par défaut, mais rien ne vous empêche d’en avoir plusieurs si vous ne voulez pas gérer vos contextes dans un seul et même fichier. Si vous décider d’en avoir plusieurs, il faudra indiquer à **kubectl** QUEL fichier vous voulez utiliser.

Soit en modifiant la variable d’environnement :

```
export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config
```


Soit en spécifiant explicitement le fichier config à utiliser à chaque commande :

```
kubectl --kubeconfig <PATHTOKUBECONFIG> .....
```


## BONUS : Erreur certificate signed by unknown authority

En cas d’erreur « Unable to connect to the server: x509: certificate signed by unknown authority », vous avez 2 possibilités :

Le plus « quick and dirty », c’est de tout simplement ignorer le certificat du cluster. On peut, à chaque appel de **kubectl** dire qu’on souhaite ignorer le certificat avec le flag « --insecure-skip-tls-verify », mais tant qu’à faire bourrin, autant le setter directement au niveau du cluster :

```
kubectl config set-cluster myawesomecluster --server=${K8SAPI} --insecure-skip-tls-verify
```


La seconde méthode consiste à récupérer le fake-ca généré par Kubernetes, et l’ajouter en tant que certificate authority dans votre **.kube/config** :

```
kubectl config set-cluster myawesomecluster --server=${K8SAPI} --certificate-authority=fake-ca-file
```

 [5]: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#users-in-kubernetes
 [6]: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
 [7]: https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/
