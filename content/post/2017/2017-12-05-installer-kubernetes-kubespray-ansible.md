---
title: Installer Kubernetes avec Kubespray (Ansible)
authors:
  - zwindler
type: post
date: 2017-12-05T12:45:25+00:00
url: /2017/12/05/installer-kubernetes-kubespray-ansible/
image: /2017/12/kubespray.png
categories:
  - Cluster
  - Script
  - systeme
  - Virtualisation
tags:
  - ansible
  - k8s
  - kubeadm
  - Kubernetes
  - kubespray

---
## Kubeadm quand on a pas ou mal accès à Internet

Rapidement pour resituer un peu le sujet, Kubernetes est un produit permettant de gérer des clusters de machines exécutant des containers en production. Un moyen simple d’installer cet outil complexe est d’utiliser l’outil **kubeadm**, qui était jusqu’à il y a peu déconseillé pour la production (la documentation de la version 1.8 ne le mentionne pas mais le message apparaît toujours lors du `kubeadm init`). Pour y voir plus clair, [vous pouvez lire les articles que j’ai écris à ce sujet](/recherche/?keyword=kubernetes).

Dans le cadre d’un déploiement d’un cluster Kubernetes on-premise, j’ai été assez ennuyé par le proxy. En théorie, on peut utiliser kubeadm derrière un proxy mais de nombreux utilisateurs remontent des difficultés de ce côté là (je ne suis pas le seul, ouf). Si vous voulez plus d’info à ce sujet j’ai mis un paragraphe en fin d’article.

## Kubespray à la rescousse

Depuis quelques mois, il existe une nouvelle manière de déployer Kubernetes, qui s’appelle **Kubespray**. Et cerise sur le MacDo, ce méthode utilise Ansible (et vous savez comme [je suis friand d’Ansible](/recherche/?keyword=ansible)).

J’ai donc décidé de tester et, vous vous en doutez puisque j’en fais un article, j’ai réussi à installer Kubernetes avec **Kubespray** derrière mon proxy capricieux ;-).

A noter, Kubespray ne se limite pas à déployer un Kubernetes _on premise_, puisqu’il supporte aussi AWS et OpenStack via l’utilisation de scripts Terraform (outil qui fera l’objet d’un petit article à venir).

Vous pouvez trouver la documentation sur les sites suivants :

  * [La documentation sur le site de Kubernetes (attention pas toujours à jour)](https://kubernetes.io/docs/setup/production-environment/tools/)
  * [La documentation sur le Github du projet][4]

## Installation des prérequis

Un petit tour sur le Github nous donne les prérequis :

![](/2017/11/requirement.png)

A ceci j’ajouterai le fait que Kubernetes demande maintenant que la swap soit désactivée sur tous les nœuds ! Si ce n’est pas déjà fait, il faut passer sur tous les serveurs et la désactiver (ne pas oublier **la fstab aussi!**)

**Kubespray** nécessite l’installation des outils de développements sur la machine qui exécute le script Ansible, ainsi que Python 3. Sur les CentOS / RHEL 7, la version de Python est la 2.7, qui n’est donc pas compatible avec le script Python 3 qui génère le fichier d’inventaire pour le déploiement Ansible.

En soit, ce n’est pas vital, mais ça facilite quand même le travail donc ça vaut le coup.

```
yum -y install yum-utils
yum -y groupinstall development
yum -y install https://centos7.iuscommunity.org/ius-release.rpm
yum -y install python36u python-netaddr
yum -y install python-pip
pip install --upgrade Jinja2
```


## Récupération et configuration de kubespray

Les sources de Kubespray sous sur Github, on les récupère

```bash
git clone https://github.com/kubernetes-incubator/kubespray
```


Récupérer les dépendances pip

```bash
sudo pip install -r requirements.txt
```


On copie le dossier inventory d’origine pour se faire sa propre conf :

```bash
cd kubespray
cp -r inventory inventaire_kubernetes
```


On déclare les adresses IPs des futurs nœuds kubernetes puis on lance le script pour générer l’inventaire :

```bash
declare -a IPS=(192.168.1.101 192.168.1.102 192.168.1.103 192.168.1.104)
CONFIG_FILE=inventaire_kubernetes/inventory.cfg python3.6 contrib/inventory_builder/inventory.py ${IPS[@]}
```


On peut regarder le contenu de modifier le fichier inventaire_kubernetes/inventory.cfg si nécessaire :

```yaml
[all]
master01         ansible_host=192.168.1.101 ip=192.168.1.101
worker01        ansible_host=192.168.1.102 ip=192.168.1.102
worker02        ansible_host=192.168.1.103 ip=192.168.1.103
worker03        ansible_host=192.168.1.104 ip=192.168.1.104

[kube-master]
master01
worker01

[kube-node]
master01
worker01
worker02
worker03

[etcd]
master01
worker01
worker02

[k8s-cluster:children]
kube-node
kube-master

[calico-rr]

[vault]
master01
worker01
worker02
```


Typiquement ici dans mon cas, n’ayant que 4 machines et ne souhaitant pas faire tourner de container sur les masters (bien que ce soit possible), j’ai prévu de ne mettre qu’un master et 3 workers.

Du coup, les groupes sont à adapter en fonction des rôles de chacun. J’ai retiré worker01 du groupe **kube-master**. Idéalement bien entendu, il aurait fallu avoir plus d’un master (3 idéalement ou au moins 2).

Idem pour la répartition du **vault** et du **etcd** sur les workers. Le mieux serait d’avoir un peu de haute disponibilité supplémentaire sur ces composants et donc de les répartir comme le propose le script d’inventaire, mais rien ne vous y oblige.

## Déploiement du cluster

Maintenant que notre inventaire est prêt, Kubespray déploie le cluster avec ce oneliner :

```bash
ansible-playbook -i inventaire_kubernetes/inventory.cfg cluster.yml -b -v --private-key=~/.ssh/id_rsa
```


Pas mal hein ? Par rapport à l’installation avec kubeadm que je décris dans [Installer un cluster Kubernetes sur des VMs CentOS 7](/2017/06/07/installer-cluster-kubernetes-vm-centos/), c’est quand même bien plus simple !

Oui oui, vous avez compris, c’est déjà fini !

## Bonus : Changer le service du dashboard de kubernetes pour le publier sur un port

Contrairement à kubeadm, Kubespray installe le dashboard par défaut, pas besoin d’importer et d’appliquer le YAML.

Cependant, même si normalement on préfère accéder au dashboard de Kubernetes avec le kubeproxy, on peut vouloir dans certains cas accéder directement au Dashboard depuis un port fixe.

Pour ce faire, on remplace le ClusterIP (interne à Kubernetes uniquement) par un Nodeport en récupérant la configuration du service, en la modifiant et en la ré-appliquant :

```yaml
kubectl get svc kubernetes-dashboard --namespace=kube-system -o yaml > kubernetes-dashboard-svc.yaml

vi kubernetes-dashboard-svc.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 9090
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort
```


Une fois les modification faites, on réapplique la configuration et on vérifie que ça a fonctionné

```bash
kubectl apply -f kubernetes-dashboard-svc.yaml

kubectl get svc --namespace=kube-system
NAME                   CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
kube-dns               10.233.0.3      <none>        53/UDP,53/TCP   97d
kubernetes-dashboard   10.233.33.140   <nodes>       80:30000/TCP    97d
```


Le Dashboard est disponible sur le port 30000 !

## Bonus : Kubeadm et les proxy internet

J’en parle en début de l’article, j’ai beaucoup galéré avec kubeadm et sa gestion de proxy. Si vous n’en avez pas, ça marche très bien mais si vous avez un proxy, kubeadm fait des appels à Internet via de multiples canaux (je n’ai pas vérifié si c’était mieux en 1.8) :

  * docker pull pour récupérer les images
  * un accès direct

J’ai eu beau ajouter &lsquo;with\_proxy’, configurer les variables HTTP\_PROXY/HTTPS\_PROXY/NO\_PROXY (et en minuscules) aussi bien au niveau de l’OS que du démon Docker mais rien n’y a fait...

Quelques pistes si vous voulez vous y essayer :

  * [Une personne qui a eu le même genre de soucis que moi (si je ne met pas  » »with-proxy= » ça bloque, si je le met, ça bloque un peu plus loin)][7]
  * [La documentation officielle de kubeadm init][8]
  * [kubeadm init should provide a HTTP_PROXY configure][9]
  * [Where does kubeadm take the proxy settings from?][10]
  * [with KUBE\_REPO\_PREFIX, but the kubeadm is using « gcr.io/google_containers/pause-amd64 »][11]

On peut même également installer un cluster Kubernetes avec kubeadm sans accès à Internet en préchargeant les images docker nécessaires, mais là encore, l’outil kubeadm se bloque au moment d’aller vérifier sur Internet s’il existe des images plus récentes à télécharger.

 [4]: https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting_started/getting-started.md
 [7]: https://github.com/kubernetes/kubeadm/issues/292
 [8]: https://kubernetes.io/docs/reference/generated/kubeadm/#kubeadm-init
 [9]: https://github.com/kubernetes/kubeadm/issues/182
 [10]: https://github.com/kubernetes/kubeadm/issues/324
 [11]: https://github.com/kubernetes/kubeadm/issues/257
