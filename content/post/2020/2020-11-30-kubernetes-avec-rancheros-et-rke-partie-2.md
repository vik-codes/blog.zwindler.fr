---
title: Kubernetes avec RancherOS et RKE – partie 2
authors:
  - zwindler
type: post
date: 2020-11-30T07:45:00+00:00
excerpt: "Tutoriel pas à pas pour déployer Kubernetes avec RKE, un binaire de Rancher pour vous faciliter l'administration de Kube"
url: /2020/11/30/kubernetes-avec-rancheros-et-rke-partie-2/
image: /2020/11/rke.png
categories:
  - Autohébergement
  - Cluster
  - Virtualisation
tags:
  - k3s
  - k8s
  - Kubernetes
  - Minukube
  - rancher
  - RancherOS

---
## Déployer Kubernetes avec RKE

Il y a quelques semaines, je vous ai présenté un petit projet que j’avais commencé pour le fun: déployer Kubernetes à l’aide de deux composants de Rancher : **RancherOS** et **RKE**.
* [Kubernetes avec RancherOS et RKE - partie 1](/2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/)

## Mais c’est quoi RKE ?

Rancher est une boite pléthorique de solutions pour le monde des containers. Parmi toutes les solutions qu’ils proposent, on a Rancher, k3s, k3os, k3d, Longhorn (pour le stockage), et donc : RancherOS et RKE.


> RKE is a CNCF-certified Kubernetes distribution that runs entirely within Docker containers.
  
  
RKE est donc une manière d’installer mais surtout de gérer de manière simple Kubernetes.


    It solves the common frustration of installation complexity with Kubernetes by removing most host dependencies and presenting a stable path for deployment, upgrades, and rollbacks.
  
  
Car si déployer Kubernetes commence à devenir relativement trivial (on peut installer Kubernetes avec microk8s ou minikube sur son portable en quasiment une ligne de commande, Kubeadm est GA,...), ce n’est pas toujours le cas des mises à jour de vos clusters en prod, que ce soit pour l’OS lui-même, ou bien les composants de Kube. C’est le fameux day2 operation [dont je vous ai déjà parlé](/2020/07/29/au-secours-le-metier-dops-va-disparaitre/).

## RKE pour nous sauver

RKE a donc vocation à nous simplifier la vie, en nous proposant une méthode (plus) simple pour gérer le cycle de vie de nos clusters : un binaire qui manipulera tous les composants de notre Kubernetes dans des containers.

L’idée est intéressante (même si pas nouvelle, de nombreuses distributions de Kubernetes containerisent les composants internes), du coup j’ai voulu voir ce que Rancher proposait.

Et comme je ne veux rien faire comme les autres, je me suis rajouté une difficulté supplémentaire en partant du principe que si Rancher proposait une distrib Linux, j’allais utiliser leur distrib comme base pour les nodes.

Ainsi, l’OS (et Docker) est géré par RancherOS, et la gestion du cycle de vie de mon cluster Kubernetes est gérée par RKE.

## Disclaimer

Qu’on se mette d’accord tout de suite. Je ne vous conseille pas du tout de faire la même chose. J’étais simplement curieux de voir si ces 2 solutions proposées par Rancher se mariaient bien ensemble.

Et en fait, j’ai d’ailleurs été assez critique envers RancherOS dans le post précédent... J’ai même découvert grâce à un des lecteurs que RancherOS allait tout simplement être abandonné dans les mois qui viennent...

A priori ce n’est pas le cas de RKE, mais on peut tout de même rester prudent ;-).

## RKE, c’est quand même pas mal

Heureusement, cette partie s’est globalement mieux passée. 

De base, j’ai tout de suite remarqué qu’il n’y avait pas de documentation officielle pour installer RKE sur des machines RancherOS. J’ai trouvé ça un peu étonnant (et même carrément inquiétant) mais vous allez voir au final que ça fonctionne.

Le code source de RKE est disponible sur Github à l’adresse suivante : [github.com/rancher/rke](https://github.com/rancher/rke)

Comme je le disais plus haut, RKE est simplement un binaire (à l’instar de kubeadm), écrit en go.

On va donc, dans la majorité des cas, simplement le télécharger avec un bête cURL ou wget sur un de nos serveurs RancherOS (ou autre, du coup), à partir de la page des [releases dans Github](https://github.com/rancher/rke/releases/tag/v1.2.3).

```
wget https://github.com/rancher/rke/releases/download/v1.2.3/rke_linux-amd64
mv rke_linux-amd64 rke
chmod +x rke
./rke --version
```


La dernière commande devrait vous renvoyer « rke version v1.2.3 » (ou celle que vous aurez installé).

Pour pouvoir s’installer sur tous les nœuds de votre cluster, vous vous doutez bien qu’il va falloir avoir un moyen de vous identifier sur ces nœuds en devenir. 

J’ai donc généré une clé SSH via OpenSSL sur ma machine locale, et j’ai ajouté cette clé dans celles autorisées pour l’utilisateur **rancher** sur tous les membres du futur cluster.

```
openssl genrsa -out rancher.private.pem 2048
openssl rsa -in rancher.private.pem -outform PEM -pubout -out rancher.public.pem

ls -l
total 8
-rw------- 1 toto toto 1679 Aug 12 14:56 rancher.private.pem
-rw-r--r-- 1 toto toto  451 Aug 12 15:00 rancher.public.pem
```


## Configuration du cluster

A partir de là, vous allez pouvoir commencer à décrire à RKE ce que vous souhaitez qu’il fasse. 

Dans mon cas, j’avais juste sous la main qu’une seule machine RancherOS. J’ai donc déployé le « cluster » le plus trivial qui soit, un cluster à une seule machine avec tout dessus.

Rancher donne plusieurs exemples de configuration et dans mon cas j’ai utilisé celui-ci : [rancher.com/docs/rke/latest/en/example-yamls/#minimal-cluster-yml-example](https://rancher.com/docs/rke/latest/en/example-yamls/#minimal-cluster-yml-example)

```
cat > cluster.yml << EOF
nodes:
    - address: 192.168.1.14
      user: rancher
      role:
        - controlplane
        - etcd
        - worker
      ssh_key_path: /home/toto/rancher.private.pem
EOF
```


On voit donc que la configuration est assez simple et claire à comprendre. On liste nos nodes ainsi que leurs rôles dans ce cluster (ici controlplane, etcd, ET worker) et c’est tout.

Vous pouvez également générer un fichier de configuration via la ligne de commande suivante, qui vous posera plein de questions en lignes de commandes (TUI)

```
./rke config --name cluster-new.yml
[+] Cluster Level SSH Private Key Path [~/.ssh/id_rsa]: /home/toto/rancher.private.pem
[+] Number of Hosts [1]:
[+] SSH Address of host (1) [none]: 192.168.1.14
[+] SSH Port of host (1) [22]:
[+] SSH Private Key Path of host (192.168.1.14) [none]: /home/toto/rancher.private.pem
[+] SSH User of host (192.168.10.214) [ubuntu]: rancher
[...]
```


Maintenant qu’on a configuré notre cluster.yml (notre fichier de description du cluster) on le « bootstrape » avec un simple **rke up** :

```
./rke up
INFO[0000] Running RKE version: v1.2.3                  
INFO[0000] Initiating Kubernetes cluster                
INFO[0000] [dialer] Setup tunnel for host [192.168.1.14] 
INFO[0000] Checking if container [cluster-state-deployer] is running on host [192.168.1.14], try #1 
[...]
NFO[0068] [ingress] Setting up nginx ingress controller 
INFO[0068] [addons] Saving ConfigMap for addon rke-ingress-controller to Kubernetes 
INFO[0068] [addons] Successfully saved ConfigMap for addon rke-ingress-controller to Kubernetes 
INFO[0068] [addons] Executing deploy job rke-ingress-controller 
INFO[0094] [ingress] ingress controller nginx deployed successfully 
INFO[0094] [addons] Setting up user addons              
INFO[0094] [addons] no user addons defined              
INFO[0094] Finished building Kubernetes cluster successfully 
```


A la fin du processus, vous devriez avoir un cluster Kubernetes « up and running » ainsi qu’un fichier **cluster.rkestate** ainsi qu’un fichier **kube\_config\_cluster.yml** dans le répertoire courant.

C’est ce dernier fichier qu’il faut utiliser pour se connecter à votre cluster en kubectl

```
kubectl --kubeconfig kube_config_cluster.yml get nodes
NAME             STATUS   ROLES                      AGE    VERSION
192.168.1.14     Ready    controlplane,etcd,worker   108d   v1.19.4
```


## Final thoughts

Si mon avis était très très mitigé sur RancherOS, je suis beaucoup plus satisfait par l’expérience (courte) que j’ai eue avec RKE.

L’outil ne révolutionne pas vraiment le déploiement de cluster Kubernetes et je ne pense pas que je vais rester sur cette stack RancherOS/RKE (c’était vraiment par curiosité pour le portfolio de Rancher).

Mais de ce que j’ai pu voir, c’est simple à utiliser, ça fonctionne plutôt bien (même sur RancherOS et c’est dire...). 

La configuration par fichier YAML est agréable et très complète à la fois, et permet de planifier à l’avance ce qu’on veut faire avec les machines qu’on a. J’ai également testé une mise à jour de Kubernetes 1.18.5 vers 1.19.4 qui est très bien passée. 

De ce que j’ai cru comprendre, il existe des synergies avec d’autres produits de Rancher (notamment Rancher lui-même), donc je pense qu’on peut dire que si vous êtes dans un écosystème Rancher, RKE est probablement un tool plutôt safe pour déployer vos clusters.

Dans le cas contraire, même si RKE semble une option totalement viable, je pense qu’il vaut tout de même mieux étudier d’autres solutions en parallèle. Elles seront potentiellement plus adaptées à votre contexte (AKS engine si vous louez du IaaS sur Azure, kubeadm ou kubespray pour du « on-prem », ...).

Have fun :)
