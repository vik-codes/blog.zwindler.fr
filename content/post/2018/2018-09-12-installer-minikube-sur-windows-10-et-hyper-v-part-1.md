---
title: Installer Minikube sur Windows 10 et Hyper-V – part 1
authors:
  - zwindler
type: post
date: 2018-09-12T11:45:26+00:00
url: /2018/09/12/installer-minikube-sur-windows-10-et-hyper-v-part-1/
image: /2018/09/minikube.png
categories:
  - Script
  - systeme
  - Virtualisation
tags:
  - hyper-v
  - k8s
  - kubectl
  - Kubernetes
  - minikube
  - Windows 10

---
## Minikube sur Hyper-V, c’est facile ?

Un bon moyen de commencer à bidouiller avec [**Kubernetes**](/recherche/?keyword=kubernetes), c’est d’utiliser **Minikube**.

Pour ceux qui ne connaissent pas, il s’agit d’un script qui va récupérer une machine virtuelle préconfigurée avec tous les composants nécessaires à Kubernetes, et l’installer sur votre machine. Ce script est disponible sur Windows, Mac et Linux, et vous trouverez de nombreux tutos pour l’installer via le logiciel de virtualisation **Virtual Box** (à installer préalablement, en prérequis donc).

Mais admettons que vous ayez commencés à bidouiller avec Docker avec « Docker for Windows ». Quoi de plus normal de passer sur K8s (le petit nom de Kubernetes, plus court) après avoir joué avec Docker.

Et paf ! vous n’arrivez pas à installer, à cause d’un obscur message qui vous parle de Virtual Box (alors que vous ne l’utilisez pas). On coince dès les prérequis, ça commence mal.

Et oui... « Docker for Windows » active Hyper-V... et si Hyper-V est activé, impossible d’installer Virtual Box !

Si la plupart des tutoriels mettent en avant Virtual Box justement (car c’est l’option par défaut), vous n’avez peut être pas envie de désinstaller Docker for Windows pour autant !

Ou peut être que vous n’avez pas envie d’installer Virtual Box alors que votre Windows 10 vous fourni déjà « out of the box » un logiciel de virtualisation parfaitement valide (attention, je dis ça uniquement pour Windows 10, sur un PC **client**... Pour un serveur, c’est juste une grosse blague cette plateforme de virtu...).

## On va quand même s’en sortir

En gros, on est censé dérouler simplement les prérequis : avoir VT-x/AMD-v d’activés dans le BIOS. Là je ne vais pas vous faire l’explication car ça dépend grandement de votre machine.

Ensuite, on ajoute la fonctionnalité Hyper-V sur votre Windows 10. Pour se faire, on ouvre le menu des « fonctionnalités Windows ».

![](/2018/09/minikube01.png)

![](/2018/09/minikube02.png)

Si ce n’est pas déjà fait cocher « Hyper-V », validez, et on vous demandera très probablement de redémarrer. Attention, à partir de là vous ne pourrez plus utiliser Virtual Box (c’est tout le but de cet article, mais bon) ou VMware player ou autre.

Et enfin, pour éviter des conflits avec Docker pour Windows, on va créer un réseau virtuel dédié dans notre console Hyper-V. Lancer le gestionnaire Hyper-V :

![](/2018/09/minikube03.png)

Sur le menu tout à droite, on créé un Commutateur virtuel dédié. Pour réaliser cette opération, on clique sur **Gestionnaire de commutateur virtuel**, puis dans la fenêtre qui s’ouvre, en haut à gauche dans la liste des **Commutateurs virtuels**, on clique sur **Nouveau commutateur réseau virtuel**.

![](/2018/09/minikube04.png)

Dans les propriétés, on lui donne un petit nom (minikube par exemple) et on oublie pas de cocher « Réseau externe » (pour utiliser une des cartes physiques comme un bridge) et de cocher ensuite « Autoriser le système d’exploitation de gestion à partager cette carte réseau (surtout si c’est votre seule carte réseau !).

Pour finir, on récupère Minikube [ici][6] et on lance la commande suivante depuis un Powershell :

```
minikube start --vm-driver hyperv --hyperv-virtual-switch "minikube"
```


## Option 1 : « J’ai de la chance »

Si tout se passe bien, tant mieux pour vous !

Vous avez de la chance, tout se passe bien et vous avez Minikube d’installé sur votre poste. C’est la fête, vous allez pouvoir déployer des containers à Gogo !

```
PS D:\> minikube status
minikube: Running
cluster: Running
kubectl: Correctly Configured: pointing to minikube-vm at 172.16.25.173
```

## Protips : Et maintenant ?

Pour aller plus loin, vous pouvez commencer par jeter un oeil sur [mes autres articles qui parlent de Kubernetes](/recherche/?keyword=kubernetes), notamment le tutoriel pas à pas où j’explique comment [déployer une application complète et Statefull sur Kubernetes](/2017/10/24/tutoriel-xwiki-ma-premier-appli-stateful-sur-kubernetes/).

Mais voici quelques protips supplémentaires spécialement dédiées aux spécificités de minikube.

### Les Ingress !

Pour le fun, on va certainement vouloir ajouter le support des Ingress (pas activés par défaut) :

```
PS D:\> minikube addons enable ingress
ingress was successfully enabled
```


### Accéder au dashboard

On peut accéder au Dashboard (l’interface web qui permet de contrôler k8s sans passer par _kubectl_ ou les API) n’est pas directement accessible avec un _kubectl proxy_ comme sur un Kubernetes standard.

Elle est cependant bien disponible sans ajout supplémentaire, à l’aide de la commande suivante :

```
minikube dashboard
```

### Se loguer sur la machine virtuelle K8s

Si pour une raison ou pour une autre, vous voulez vous connecter en SSH sur la VM qui contient votre environnement Kubernetes, c’est possible ! Récupérez l’IP affectée à la VM (afficher avec un _minikube status_ ou un _kubectl config view_).

Il existe un user « docker » avec pour mot de passe « tcuser » (mot de passe ultrasecure, s’il en est). A noter, ce compte à un accès **sudo** à la machine en _NOPASSWD_.

Ca peut être utile par exemple pour vérifier que les Adminission Controllers sont bien actifs (on en aura besoin dans un prochain article)

```
ps -ef | grep api
kube-apiserver --admission-control=Initializers,NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota --requestheader-allowed-names=front-proxy-client --service-account-key-file=/var/lib/localkube/certs/sa.pub --tls-private-key-file=/var/lib/localkube/certs/apiserver.key --kubelet-client-key=/var/lib/localkube/certs/apiserver-kubelet-client.key --proxy-client-cert-file=/var/lib/localkube/certs/front-proxy-client.crt --requestheader-group-headers=X-Remote-Group --enable-bootstrap-token-auth=true --allow-privileged=true --requestheader-username-headers=X-Remote-User --requestheader-extra-headers-prefix=X-Remote-Extra- --client-ca-file=/var/lib/localkube/certs/ca.crt --proxy-client-key-file=/var/lib/localkube/certs/front-proxy-client.key --insecure-port=0 --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --advertise-address=172.16.25.173 --service-cluster-ip-range=10.96.0.0/12 --tls-cert-file=/var/lib/localkube/certs/apiserver.crt --kubelet-client-certificate=/var/lib/localkube/certs/apiserver-kubelet-client.crt --requestheader-client-ca-file=/var/lib/localkube/certs/front-proxy-ca.crt --secure-port=8443 --authorization-mode=Node,RBAC --etcd-servers=https://127.0.0.1:2379 --etcd-cafile=/var/lib/localkube/certs/etcd/ca.crt --etcd-certfile=/var/lib/localkube/certs/apiserver-etcd-client.crt --etcd-keyfile=/var/lib/localkube/certs/apiserver-etcd-client.key
```

```
kubectl api-versions | findstr "admissionregistration.k8s.io/v1beta1"
admissionregistration.k8s.io/v1beta1
```

## Option 2

Rien ne marche !

Et pour être parfaitement honnête, c’est ce qui m’est arrivé ! Du coup, je vous prépare un nouvel article avec toutes les astuces de troubleshooting. [La suite - dans le prochain épisode](/2018/10/02/minikube-sur-hyper-v-part-2-troubleshooting-de-linstallation/), donc ;-)

## Sources

  * [La documentation officielle][6]
  * [La documentation « officielle » et minimaliste pour installer Minikube avec Hyper-V][9]
  * l’article MSDN de Microsoft : [Setting up Kubernetes on Windows10 Laptop with Minikube][10]
  * [un autre tutoriel pour installer Minikube avec Hyper-V mais qui ne donne pas beaucoup plus d’info que le billet de MSDN][11]

 [6]: https://kubernetes.io/docs/tasks/tools/install-minikube/
 [9]: https://docs.microsoft.com/fr-fr/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v
 [10]: https://blogs.msdn.microsoft.com/wasimbloch/2017/01/23/setting-up-kubernetes-on-windows10-laptop-with-minikube/
 [11]: https://medium.com/@JockDaRock/minikube-on-windows-10-with-hyper-v-6ef0f4dc158c
