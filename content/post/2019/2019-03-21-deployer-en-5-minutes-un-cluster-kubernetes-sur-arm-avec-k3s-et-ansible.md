---
title: Déployer en 5 minutes un cluster Kubernetes sur ARM avec k3s et Ansible
authors:
  - zwindler
type: post
date: 2019-03-21T13:00:14+00:00
url: /2019/03/21/deployer-en-5-minutes-un-cluster-kubernetes-sur-arm-avec-k3s-et-ansible/
image: /2019/03/k3s_scaleway.png
categories:
  - Cluster
  - DIY
  - systeme
  - Virtualisation
tags:
  - ansible
  - ARM
  - Docker
  - github
  - k3s
  - k8s
  - Kubernetes
  - playbook
  - rancher
  - scaleway

---
## C’est quoi k3s ?

Il y a quelques jours, vous avez peut être vu passer dans vos fil d’actus **k3s**, ce nouveau projet  [open sourcé par Rancher][1].

> Lightweight Kubernetes. 5 less than k8s.

Il s’agit d’une version réduite de Kubernetes, sans pour autant être minimaliste, qui nous vante la possibilité de monter des clusters Kubernetes avec très peu de ressources nécessaires. On parle de moins de 512 Mo de RAM pour un master, encore moins pour un worker, tout dans un binaire de 40 Mo, support de **armhf**, et **arm64**, ...

> Great for Edge, IoT, CI, ARM, and situations where a PhD in k8s clusterology is infeasible

Cerise sur le gâteau, comme tout est regroupé dans un seul et même binaire, l’installation est ultra simple et se résume en :

  * Récupérer un binaire
  * Lancer le binaire sur le master
  * Lancer le binaire sur le worker avec l’URL du master et un token

## Mais c’est génial !

Nécessairement, pour arriver à ça, il a fallut faire quelques concessions mais pour l’instant je ne les trouves pas très gênantes. Parmi les modifications notables, on retrouve :

  * Suppression des features alpha, legacy et non standard
  * Suppression de tous les add-on des cloud providers
  * Remplacement de etcd3 par sqlite3 (même si etcd3 peut être toujours être utilisé)

## J’en veux un !

Autant dire que pas mal de bidouilleurs du dimanche se sont jetés dessus.

Le premier exemple qui vient à l’esprit est de monter un cluster Kubernetes sur Raspberry pi. Nombre de personnes ont déjà installé Docker sur un raspberry qui traînait dans un tiroir (moi compris), et le nombre d’articles avec Docker Swarm sur plusieurs Raspberry pullule sur le web.

* [Geekerie du week end : installer Docker sur un Raspberry Pi](/2016/09/05/geekerie-du-week-end-installer-docker-sur-un-raspberry-pi/)

Tout ça c’est très bien mais jusqu’à présent, il était difficile d’installer Kubernetes sur ce genre de machines, assez limités en CPU/RAM. Du coup, vous vous en doutez, je ne suis pas le premier à parler de ça.

Vincent RABAT aka **itwars** (que vous connaissez sûrement si vous écumez les meetups sur Bordeaux) m’a coiffé au poteau en [releasant un playbook Ansible pour installer k3s][2], et notamment sur un Raspberry Pi (mais pas que).

A charge de revanche, Vincent ;-).

## Un peu différent

Du coup, pour me démarquer, je vous propose aujourd’hui quelque chose d’un peu différent. N’ayant pas suffisament de raspberry sous la main, j’ai voulu faire un PoC de k3s en me basant sur des machines ARM créées chez un cloud provider.

L’idée étant que si ça marche sur des machines de faible puissance en ARM, ça marchera partout (x64, raspberry, etc).

Ça fait plusieurs fois que j’utilise [Scaleway][3] comme hébergeur pour des petits projets, et en particulier pour déployer rapidement des machines car leur API est pas trop mal fichues et surtout ils disposent de modules Ansible très bien fait, notamment avec la feature « inventaire dynamique », ce que beaucoup ne font pas.

Pour ceux que ça intéresse, mon talk sur BDX.IO était basé sur le même principe :

https://www.youtube.com/watch?v=WPRE1_f0pyg

Dans ce tuto, je vais donc vous montrer comment en quelque commande, monter un cluster k3s sur des machines ARM créées à la volée chez Scaleway, le tout avec Ansible (vous l’aurez compris).

## Quelques prérequis

La première chose à faire est de cloner sur votre machine les playbooks Ansible que j’ai mis à disposition sur Github à l’adresse suivante : [github.com/zwindler/ansible-scaleway-k3s](https://github.com/zwindler/ansible-scaleway-k3s)

Pour réaliser ce tuto, je pars du principe que vous avec déjà un compte sur Scaleway, que vous avez un clé SSH qu’on déposera à la racine du projet, appelée **admin.pub** (c’est original).

Il faudra également installer les package **pipy** suivant sur la machine locale :

```
pip install jinja2 PyYAML paramiko cryptography packaging
```


Ensuite, vous devrez installer Ansible depuis les sources (>= 2.8devel) et éventuellement le binaire **jq** pour requêter dans les output JSON (ça c’est juste pour se faciliter la vie)

Dans la console Scaleway, vous devrez créer un token sur le site de Scaleway pour les accès distants et le stocker dans un fichier **scaleway_token**

```
export SCW_API_KEY='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
```


Et enfin sourcer le fichier pour avoir la variable dans votre environnement

```
source scaleway_token
```


## OK, on est prêt

La première étape de cette procédure va être de générer des instances ARM pour héberger le master et le worker Kubernetes. Pour ça, le playbook Ansible **create\_arm\_vms.yaml** va :

  * récupérer l’ID d’organisation du compte Scaleway
  * récupérer un ID d’image compatible debian Stretch
  * ajouter si nécessaire la clé SSH de l’admin
  * créer autant de machines que nécessaire

On lance la commande suivante :

```
ansible-playbook create_arm_vms_scaleway.yml
```


ET C’EST TOUT !

Normalement en 2 minutes, vous devriez avoir 2 instances ARM sur le datacenter de Paris (par1).

A noter, il se peut qu’elles ne soient pas accessibles tout de suite en SSH. J’adapterai peut être le playbook pour qu’il ne rende pas la main tant que les machines ne sont pas accessibles, et qu’on enchaîne automatiquement sur l’étape suivante (TODO).

## Inventaire automatique

Je le disais plus haut, la grande force de Scaleway avec Ansible est le fait qu’ils ont fait l’effort de coder **l’inventaire dynamique**. Vous n’avez pas besoin de renseigner à la main les IPs des instances que vous venez de créer dans un fichier ansible/hosts. Grâce à l’API, la découverte se fait automatiquement. On va dont pouvoir enchaîner sur la suite directement.

De base, voici le contenu de mon fichier d’inventaire (inventory.yml) :

```
plugin: scaleway
regions:
  - par1
tags:
  - k3smaster
  - k3sworker
```


Maintenant que les machines sont UP, on peut vérifier ce que nous renvoie Scaleway avec la commande **ansible-inventory**. Ça devrait ressembler à ça :

```
ansible-inventory --list -i inventory.yml
{
    "_meta": {
        "hostvars": {
            "x.x.x.x": {
                "arch": "arm64",
                "commercial_type": "ARM64-2GB",
                "hostname": "k3smaster1",
[...]
    "k3sworker": {
        "hosts": [
            "x.x.x.x",
            "y.y.y.y",
            "z.z.z.z"
        ]
    }
```


## SSH fingerprints

Une étape qui est souvent fastidieuse, surtout quand on ajoute beaucoup de serveur, est l’étape de vérification de l'empreinte SSH des nouveaux serveurs lors de la première connexion. Cette authentification est très importante et il <b>n’est pas du tout conseillé</b> (comme je le vois parfois) d’ajouter l’option **ANSIBLE\_HOST\_KEY_CHECKING=False**.

Ici, je vous propose de scanner automatiquement _la première fois_ l'empreinte, et l’ajouter dans votre known_hosts. Ainsi, si l'empreinte change en cours de route, vous serez prévenus. Cependant, ce n’est à utiliser que dans le cas de notre bidouille, pas en production.

```
ansible-inventory --list -i inventory.yml | jq -r '.k3smaster.hosts | .[]' | xargs ssh-keyscan >> ~/.ssh/known_hosts
ansible-inventory --list -i inventory.yml | jq -r '.k3sworker.hosts | .[]' | xargs ssh-keyscan >> ~/.ssh/known_hosts
```


Vous pouvez maintenant ajouter votre clé SSH dans le ssh-agent, et vérifier qu’on vous pouvez vous connecter à tous les serveurs via Ansible :

```
eval `ssh-agent`
ssh-add myprivate.key
```


## Préparation du serveur

C’était facile, non ?

Et bien la suite l’est encore plus, à l’exception de cette petite subtilité/piège => Il se trouve que l’image ARM par défaut proposée par Scaleway ne dispose ni de python ni de sudo. Pour faire du Ansible, c’est très très handicapant.

J’ai donc écris un petit playbook, à n’exécuter la première fois, qui installe les prérequis non présents sur l’image de base (**python** et **sudo**)

```
ansible-playbook -i inventory.yml -u root install_prerequisites_scaleway.yml
```


Si vous n’êtes pas sur ce genre de machines, vous n’aurez pas à faire cette étapes.

Maintenant qu’on a des machines avec python et sudo, on peut installer k3s normalement avec Ansible :

```
ansible-playbook -i inventory.yml -u root install_k3s_scaleway.yml
```


Une fois de plus : ET C’EST TOUT !

Le cluster est maintenant opérationnel. Les serveurs ont Kubernetes installé et fonctionnel. Le ou les workers ont rejoint le master et font parti d’un même cluster. Un Ingress controller Treafik est créé, on peut jouer dessus directement :-)

## Bonus : accéder au cluster

Bon je vous ai un peu feinté.

Certes, on peut se connecter en SSH sur le master et le piloter avec les commandes **kubectl** classique (mais il faut rajouter k3s devant car le binaire kubectl est intégré à k3s). Mais c’est quand même plus simple si on peut y accéder à distance, depuis votre machine locale.

Là encore, j’ai donc fais un petit playbook qui va aspirer la configuration **kubectl** et la coller dans le fichier **~/.kube/config.k3smaster**

```
ansible-playbook -i inventory.yml -u root configure_kubeconfig.yml
```


A partir de là, vous devriez pouvoir tester votre nouveau cluster depuis votre PC :-)

```
cd
kubectl --kubeconfig=.kube/config.k3smaster get nodes
NAME         STATUS    ROLES     AGE       VERSION
k3smaster1   Ready     <none>    2d        v1.13.3-k3s.6
k3sworker1   Ready     <none>    2d        v1.13.3-k3s.6
```


Enjoy !!!

 [1]: https://k3s.io/
 [2]: https://github.com/itwars/k3s-ansible
 [3]: https://www.scaleway.com/
