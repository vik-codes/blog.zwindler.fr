---
title: Installer un cluster Kubernetes sur des VMs CentOS 7
authors:
  - zwindler
type: post
date: 2017-06-07T12:00:53+00:00
url: /2017/06/07/installer-cluster-kubernetes-vm-centos/
image: /2017/06/kubernetes2.png
categories:
  - Système
  - Virtualisation
tags:
  - Borg
  - calico
  - CentOS
  - CoreOS
  - Docker
  - Docker CE
  - flannel
  - Google
  - kubeadm
  - kubelet
  - Kubernetes
  - RHEL

---
## Kubernetes, c’est quoi ça ?

Dans cet article, je vais vous guider pour installer pas à pas un cluster Kubernetes sur des serveurs CentOS/RHEL 7. Attention cet article est un gros morceau !

Pour ceux qui ne connaissent pas Kubernetes, il faut savoir que c’est un des leaders dans le domaine des orchestrateurs de containers Docker ou Rkt.

![](/2017/06/kubernetes01.png)

> Un bel empilage de couches, pour au final exécuter des applications dans des containers LXC (ou Windows)

Pour ce qui est de la genèse de Kubernetes, c’est un outil dont le code provient de Borg d’un outil maison de chez Google. Au bout de 10 ans d’utilisation, quand les containers Linux ont commencés à percer, le code source a été légué en 2015 à la [CNCF (Cloud Native Computing Foundation)][2]. L’outil est donc maintenant open source.

Sa couverture fonctionnelle est (pour l’instant) supérieure à celle de [Docker Swarm](/2017/01/31/premiers-pas-avec-swarm-fr/), notamment grâce à :

  * une gestion de la multitenancy via les namespaces
  * une gestion des secrets (bien que limitée)
  * une gestion des replicas pour un même container, avec scale-up/down
  * une gestion native du loadbalancing
  * une gestion des rolling upgrades
  * ...

Un article sympa d’Octo [résume pas mal l’écosystème et la guerre qui fait rage dans ce domaine][4].

## Prérequis

Avant de commencer le tutoriel, il faut déjà avoir une bonne connaissance de l’écosystème de la containerisation (sujet sur lequel [j’ai écris quelques articles](/recherche/?keyword=container) mais qui est bien plus vaste que ça!).  
Il faut savoir que Kubernetes est aussi un outil assez complet mais complexe, avec ses propres concepts et sa terminologie associée. Je vous conseille d’abord de vous familiariser avec ces concepts sur [un des tutos de Digital Ocean (ils sont souvent très biens fait)][6].

Pour ceux qui sont extrêmement pressés, on peut dire brièvement que, dans la terminologie Kubernetes :

  * un **Node** est un serveur qui exécute les applications
  * le **Kubelet** est un service (au sens démon) présent sur tous les nodes qui leur permet de discuter et de recevoir les ordres
  * un **Pod**, généralement décrit comme « la plus petite unité de traitement de Kubernetes ». Il est composé d’un ou plusieurs containers et on le caractérise généralement comme « **une** application »
  * un **Service** représente un répartiteur de charge qui est conscient de la présence d’un ensemble de containers (backend) et qui permet de rediriger les flux entrants vers eux
  * un **Deployment** est un ensemble de sous éléments (comme les Pods et les Services, mais aussi d’autres que je ne présentent pas) qui permet de déployer une application avec toutes ses caractéristiques (volumes, secrets) et ses contraintes (nombres de réplicas)
  * toutes les interactions avec Kubernetes se font avec une seule commande : **kubeadm**

![](/2017/06/kubernetes02.png)

> Source : kubernetes.io

## Solutions de déploiement

D’abord, la première chose à dire est qu’il existe de nombreuses manières de déployer Kubernetes qui a donc créé un page dédiée à centraliser [l’ensemble des solutions possibles][8]. Et elle est longue !

![](/2017/05/kubernetes2.png)

> Ceci n’est qu’une fraction des solutions actuellement proposées sur le site. Ça ne rentre pas sur mon écran 29 pouces...

Dans mon cas, je suis parti du plus simple pour moi, avec les ressources que j’ai à disposition, c’est à dire 2 machines virtuelles sous CentOS 7.3 :

  * controlplane01 : 192.168.100.100
  * worker01 : 192.168.100.101

Pour autant, les solutions avec Vagrant ou sur des clouds publics sont aussi des solutions valables pour commencer si vous maitrisez ces outils. Je vous laisserai regarder la documentation associée si ça vous intéresse.

**A noter**, en fonction de la solutions choisie, il existe aussi des considérations réseaux à avoir, et [elles sont documentées ici][10].

## Le plus simple : Minikube

Je ne vais pas m’attarder sur cette méthode mais celle qui me semble vraiment la plus simple si vous voulez commencer rapidement à jouer avec Kubernetes est d’utiliser **minikube**. Elle utilise de la virtualisation pour déployer l’environnement Kubernetes de manière automatisée sur votre poste et ça fonctionne très bien.

```
minikube start
Starting local Kubernetes cluster...
Running pre-create checks...
Creating machine...
Starting local Kubernetes cluster...
```


## La solution de l’article : Utiliser Kubeadm

On ne va pas se le cacher, installer Kubernetes à la main est complexe. Tellement complexe qu’il existe de nombreuses méthodes clé en main pour automatiser le processus.

La solution que je vous présente ici est un script qui package l’installation des différents composants de Kubernetes. Ces composants sont en fait containerisés pour faciliter leur déploiement.

La documentation officielle de cette méthode est disponible à l’adresse [suivante](https://kubernetes.io/docs/getting-started-guides/kubeadm/).

### Configuration des dépôts

**Sur les deux nœuds**

A noter : Dans le cas où vous ne disposeriez pas d’un serveur DNS en propre, le plus simple est de configurer sur vos deux machines leurs noms complets dans le fichier « hosts ». Cela vous évitera des bugs et effets de bords.

```
echo "192.168.100.100  controlplane01.example.org
192.168.100.101  worker01.example.org" >> /etc/hosts
```


Configurer les repositories officiels :

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#yum install -y yum-utils
#yum-config-manager \
#    --add-repo \
#    https://download.docker.com/linux/centos/docker-ce.repo
```


J’ai volontairement commenté l’ajout du dépôt de Docker car à date, la dernière version de Kubernetes n’a pas encore complètement validé les dernières versions de Docker (celles depuis le grand renommage, qui sont sur le modèle YY.MM comme la 17.03). C’est pourquoi j’utilise dans ce tutoriel la version packagée par mon OS, la 1.12.6.

### SELinux

A l’heure actuelle, SELinux est mal supporté par kubelet, le client de Kubernetes présent sur chaque machine. Il est donc malheureusement nécessaire de désactiver cette sécurité pour pouvoir utiliser Kubernetes, pour l’instant.

> Disabling SELinux by running setenforce 0 is required in order to allow containers to access the host filesystem, which is required by pod networks for example. You have to do this until SELinux support is improved in the kubelet.

Il se peut aussi que le firewall pose des problèmes s’il est activé et mal configuré

> firewalld is active, please ensure ports [6443 10250] are open or your cluster may not function correctly

Dans le cadre d’un PoC, on pourra éventuellement se permettre de désactiver le firewall et SELinux si on estime que l’environnement est suffisamment sécurisé. C’est bien entendu hors de question pour tout autre environnement non éphémère !

```
setenforce 0
vi /etc/selinux/config
[...]
SELINUX=disabled

systemctl disable firewalld
systemctl stop firewalld
```


### Installation des packages

Comme dit plus haut, j’installe la version Docker de l’OS et non la dernière version. Dans les versions suivantes, Kubernetes aura probablement rattrapé ce retard (si ce n’est pas déjà le cas). On termine par démarrer Docker puis le démon kubelet.

```
yum install -y docker kubelet kubeadm kubectl kubernetes-cni
#yum install -y docker-ce kubelet kubeadm kubectl kubernetes-cni

systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet
```


## Initialisation du cluster

**Sur le controlplane**

Maintenant que les prérequis sont installés, on peut démarrer Kubernetes. L’ensemble des commandes de Kubernetes utilise le binaire kubeadm et la première à utiliser est kubeadm init.

Attention cependant, la commande kubeadm init peut nécessiter des arguments complémentaires en fonction du fournisseur de réseau qui sera choisi.

```
kubeadm init
#ou
kubeadm init --pod-network-cidr 10.244.0.0/16 #Si on utilise flannel
#ou
kubeadm init --pod-network-cidr=192.168.0.0/16 #Si on utilise Calico
```


Si vous avez un proxy chez vous, n’hésitez pas d’exporter la variable http_proxy et à configurer docker pour l’utiliser (voir [ce thread sur stackoverflow][11]).

```
export http_proxy=http://@IP_proxy.zwindler.fr:8080/
export no_proxy=localhost,127.0.0.0,[@IP_control_plane]
mkdir /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
    [Service]
    Environment="HTTP_PROXY=http://@IP_proxy.zwindler.fr:8080/"
EOF
systemctl daemon-reload
systemctl restart docker
```


On termine l’initialisation côté serveur controlplane avec les commandes suivantes (indiquées dans le retour donné par le kubeadm init) :

```
mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


A noter, en toute fin de retour, kubeadm nous donne la ligne de commande nécessaire pour ajouter des nœuds supplémentaires au cluster via un token. Copiez et conservez cette partie pour plus tard. NE PAS LE FAIRE MAINTENANT !

```
#You can now join any number of machines by running the following on each node
#as root:
#  kubeadm join --token <token> <ip_controlplane>:6443
```


A partir de là, le cluster va s’initialiser et déployer tous les containers nécessaires. Cela peut prendre un certain temps et certains containers peuvent passer par un état Fail, mais au final tout doit être dans l’état « Running », à l’exception des kube-dns*.

```
kubectl get pods --all-namespaces
NAMESPACE     NAME                                          READY     STATUS    RESTARTS   AGE
kube-system   etcd-controlplane01.example.org                      1/1       Running   0          13m
kube-system   kube-apiserver-controlplane01.example.org            1/1       Running   0          12m
kube-system   kube-controller-manager-controlplane01.example.org   1/1       Running   0          13m
kube-system   kube-dns-3913472980-gnt72                     0/3       Pending   0          13m
kube-system   kube-proxy-4m1nd                              1/1       Running   0          13m
kube-system   kube-scheduler-controlplane01.example.org            1/1       Running   0          13m
```


Vérifiez la présence du controlplane avec la commande :

```
kubectl get nodes
NAME                  STATUS     AGE       VERSION
controlplane01.example.org   NotReady   12m       v1.6.2
```


A noter : Le Nœud restera à NotReady tant que les containers « kube-dns- » ne seront pas démarrés. Or, les « kube-dns- » ne démarreront pas tant que la configuration des « Network Pods » n’est pas faite (on va voir ça plus loin), ce qui est donc normal pour l’instant.

### « waiting for the control plane to become ready » qui ne rend jamais la main

En cas de blocage sur l’étape « _[apiclient] Created API client, waiting for the control plane to become ready_« , vérifier les logs dans **/var/log/messages**.

```
Apr 26 16:27:58 controlplane01 kubelet: error: failed to run Kubelet: failed to create kubelet: misconfiguration: kubelet cgroup driver: "cgroupfs" is different from docker cgroup driver: "systemd"
Apr 26 16:27:58 controlplane01 systemd: kubelet.service: main process exited, code=exited, status=1/FAILURE
Apr 26 16:27:58 controlplane01 systemd: Unit kubelet.service entered failed state.
Apr 26 16:27:58 controlplane01 systemd: kubelet.service failed.
```


Ceci est du à un [bug de kubeadm sur CentOS][12].

Il n’y a pas vraiment de solution à partir de là. On ne peut pas utiliser « kubeadm reset » pour désinstaller proprement car cela supprime le fichier **10-kubeadm.conf**, celui qui doit être corrigé/modifié.  
La seule possibilité d’est d’interrompre le processus « kubeadm init », de modifier le 10-kubeadm.conf puis de recommencer.

```
[CTRL-C]
sed -i 's#Environment="KUBELET_KUBECONFIG_ARGS=-.*#Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --cgroup-driver=systemd"#g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
systemctl daemon-reload
systemctl restart kubelet

#Puis relancer
kubeadm init #--pod-network-cidr 10.244.0.0/16
  [kubeadm] WARNING: kubeadm is in beta, please do not use it for production clusters.
  [init] Using Kubernetes version: v1.6.2
  [init] Using Authorization mode: RBAC
  [preflight] Running pre-flight checks
  [preflight] WARNING: docker version is greater than the most recently validated version. Docker version: 17.03.1-ce. Max validated version: 1.12
  [preflight] Some fatal errors occurred:
        /etc/kubernetes/manifests is not empty
[preflight] If you know what you are doing, you can skip pre-flight checks with `--skip-preflight-checks`

kubeadm init --skip-preflight-checks
#Là, ça devrait fonctionner
```


### Taint node

Par défaut, Kubernetes n’utilise pas le controlplane pour faire tourner des pods. Si vous voulez changer ce comportement, on peut le faire avec la commande suivante :

```
kubectl taint nodes --all node-role.kubernetes.io/controlplane-
```


## Configuration des Network Pods

La première chose à configurer sur le cluster est le « Network Pod ». On a le choix entre un certain nombre de modules, dont la liste est disponible sur [cette documentation][13].

### Flannel

La configuration la plus couramment utilisée semble être flannel (de CoreOS), donc le fichier de configuration yaml est disponible sur Github

**Sur le controlplane**

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    serviceaccount "flannel" created
    configmap "kube-flannel-cfg" created
    daemonset "kube-flannel-ds" created
```


### Calico

On peut aussi essayer [Calico][14]. Personnellement j’ai eu des disfonctionnement avec la version Flannel et donc j’utilise Calico.

**Sur le controlplane**

```
kubectl apply -f http://docs.projectcalico.org/v2.4/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
    configmap "calico-config" created
    daemonset "calico-etcd" created
    service "calico-etcd" created
    daemonset "calico-node" created
    deployment "calico-policy-controller" created
    clusterrolebinding "calico-cni-plugin" created
    clusterrole "calico-cni-plugin" created
    serviceaccount "calico-cni-plugin" created
    clusterrolebinding "calico-policy-controller" created
    clusterrole "calico-policy-controller" created
    serviceaccount "calico-policy-controller" created
```


Les pods pour le réseaux se créent. Vérifiez que tout a bien fonctionné avant d’ajouter des nœuds dans le cluster :

```
kubectl get pods --all-namespaces
```


## Ajout de nœuds supplémentaires

A partir de cette étape, le cluster Kubernetes fonctionne réellement, tous les composants sont opérationnels, à ceci près que c’est un cluster avec seulement une machine. On peut donc maintenant intégrer les machines supplémentaires.

Récupérez la commande avec le token que vous avez conservé précédemment (lors du kubeadm init) et exécutez la sur le nœud « worker ».

**Sur le worker**

```
kubeadm join --token <token> 192.168.100.100:6443
```


Si on obtient l’erreur suivante, il faut ajouter 2 lignes dans le fichier « sysctl.conf » et appliquer la modification.

```
[preflight] Some fatal errors occurred:
        /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
[preflight] If you know what you are doing, you can skip pre-flight checks with `--skip-preflight-checks`

echo "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sysctl -p
```


**Sur le controlplane**

Vérifier la présence du controlplane et de son worker avec la commande kubectl :

```
kubectl get nodes
NAME                  STATUS     AGE       VERSION
worker01.example.org     NotReady   1m        v1.6.2
controlplane01.example.org   Ready      33m       v1.6.2
```


## Déployer la console web

Bravo, votre cluster Kubernetes fonctionne !

Un bon moyen de débuter est d’installer la WebUI de Kubernetes. Comme tout le reste sur Kubernetes, elle se déploie simplement avec un fichier YAML. La documentation officielle est [disponible à cette adresse][15].

```bash
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```


La console est déployée. Elle est accessible de 2 manières.

### kubectl proxy

Cette sous commande kubectl permet de faire un tunnel entre le poste depuis lequel la commande est lancée et le serveur exécutant les pods. Cette commande est pratique pour tester les connexions à des pods sans avoir à travailler sur le serveur (depuis son poste par exemple).

Le Dashboard deviendra accessible via l’URL :

  * http://localhost:8001/ui

Cependant, dans ce cas là, l’interface ne sera disponible que depuis votre poste, ce qui peut ne pas vous convenir.

### Via le serveur controlplane

On peut également accéder à la console directement depuis l’URL /ui, qui pointe sur le serveur « controlplane » (controlplane01 dans notre cas).

  * https://@ip_controlplane]/ui

La console demandera un login/mdp que l’on peut retrouver avec kubectl

```
kubectl config view
```


## Le mot de la fin

Ça y est, vous savez tout.

Vous êtes maintenant en mesure de déployer vos premières applications avec Kubernetes, et vous amuser à Scale-up & scale-down, faire des rolling upgrades, tester la haute disponibilité et la répartition de charge !

Have fun :)

 [2]: https://www.cncf.io/
 [4]: http://blog.octo.com/docker-en-production-la-bataille-sanglante-des-orchestrateurs-de-conteneurs/
 [6]: https://www.digitalocean.com/community/tutorials/an-introduction-to-kubernetes
 [8]: https://kubernetes.io/docs/setup/
 [10]: https://kubernetes.io/docs/concepts/cluster-administration/networking/
 [11]: https://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy
 [12]: https://github.com/kubernetes/kubernetes/issues/43805
 [13]: https://kubernetes.io/docs/concepts/cluster-administration/addons/
 [14]: http://docs.projectcalico.org/v2.1/getting-started/kubernetes/installation/hosted/kubeadm/
 [15]: https://kubernetes.io/docs/tasks/web-ui-dashboard/
