---
title: 'Kubernetes avec Kubespray part 2 – Astuces & troubleshooting'
authors:
  - zwindler
type: post
date: 2018-01-30T12:45:54+00:00
url: /2018/01/30/astuces-troubleshooting-kubespray/
image: /2017/12/kubespray.png
categories:
  - Cluster
  - Logiciel
  - Script
  - Système
  - Virtualisation
tags:
  - ansible
  - equalto
  - k8s
  - Kubernetes
  - kubespray
  - kubespray-defaults
  - python-netaddr
  - swap enabled
  - Too many nameservers
  - Troubleshooting

---
## Kubespray ?

Pour ceux qui ne savent pas ce qu’est Kubernetes, [je vous invite à lire les articles que j’ai écris à ce sujet][1]. Kubernetes est un produit permettant de gérer des clusters de machines exécutant des containers en production. Et pour ceux qui ne connaissent pas Kubespray, il s’agit d’un outil principalement basé sur Ansible permettant de simplifier l’installation (relativement complexe) de Kubernetes.

En théorie, si vous partez avec des machines vierges et qui peuvent discuter entre elles, vous devriez avoir _un cluster Kubernetes opérationnel en une vingtaine de minutes et en deux lignes de commande_, en suivant [ce tutoriel pas à pas][2].

```
ansible-playbook -i inventaire_kubernetes/inventory.cfg cluster.yml -b -v --private-key=~/.ssh/id_rsa
  [...]
  Monday 29 January 2018  15:57:07 +0100 (0:00:00.050)       0:17:56.289 ********
  ===============================================================================
```


Bon... j’ai quand même eu quelques erreurs et j’ai décidé de les consigner « à part » de l’article d’installation. Je le mettrais à jour dès que j’en rencontre de nouvelles.

## Erreur kubespray-defaults : Configure defaults

Si l’installation plante à cette étape avec une très loooongue erreur bien rouge, vérifier qu’il n’y a pas écrit en fin de ligne

```
The ipaddr filter requires python-netaddr be installed on the ansible controller
```


Si c’est le cas, vous avez probablement oublié d’installer le paquet **python-netaddr** comme indiqué [au début du tutoriel d’installation][2].

## Erreur « kubernetes/preinstall : Stop if swap enabled »

Cette erreur est assez explicite : vous avez oublié de désactiver la swap sur un des nœuds.

```
TASK [kubernetes/preinstall : Stop if swap enabled] *********************************************************************************************************
Monday 29 January 2018  15:06:44 +0100 (0:00:00.092)       0:00:23.562 ********
fatal: [kube01.zwindler.fr]: FAILED! => {
    "assertion": "ansible_swaptotal_mb == 0",
    "changed": false,
    "evaluated_to": false
}
```


On peut facilement la désactiver avec la boucle Ansible suivante :

```
ansible kube*.zwindler.fr -m shell -a "swapon -s"
  kube01.zwindler.fr | SUCCESS | rc=0 >>
  Nom de fichier                          Type            Taille  Utilisé Priorité
  /dev/sda3                               partition       1048572 25812   -1
  [...]

ansible kube*.zwindler.fr -m shell -a "swapoff -a"
  kube01.zwindler.fr | SUCCESS | rc=0 >>
```


Mais il ne faudra pas oublier de passer **aussi dans la fstab** pour que le changement soit permanent (attention le sed est un peu brut, je vous invite à vérifier ce qu’il fait) !

```
ansible kube*.zwindler.fr -m shell -a "grep swap /etc/fstab"
  kube01.zwindler.fr | SUCCESS | rc=0 >>
  UUID=18eaabbe-aaaa-aaaa-aaaa-205cdaa94fe6 swap                    swap    defaults        0 0

ansible kube*.zwindler.fr -m shell -a "sed -i.bak '/swap/d' /etc/fstab"
 [WARNING]: Consider using template or lineinfile module rather than running sed
  kube01.zwindler.fr | SUCCESS | rc=0 >>
```


## Too many nameservers

Typiquement c’est vraiment une erreur « à la c** ». Pas de bol pour moi, ça a planté directement avec l’erreur « Too many nameservers ». O-kay...

Effectivement, j’ai plusieurs serveurs DNS renseignés sur mon OS et Kubespray ne supporte pas plus de 2 out of the box.

Bon pas de drame, l’utilitaire nous indique qu’on peut contourner cette « erreur » simplement en modifiant une variable :

> You can relax this check by set docker\_dns\_servers_strict=no and we will only use the first 3.

Dans le fichier **cluster.yml**, recherchez le block suivant et ajouter les lignes **-vars** puis **- docker\_dns\_servers_strict: no**

```
vi cluster.yml
[...]
- hosts: k8s-cluster:etcd:calico-rr
  any_errors_fatal: "{{ any_errors_fatal | default(true) }}"
  vars:
    - docker_dns_servers_strict: no
  roles:
    - { role: kubespray-defaults}
    - { role: kernel-upgrade, tags: kernel-upgrade, when: kernel_upgrade is defined and kernel_upgrade }
    - { role: kubernetes/preinstall, tags: preinstall }
    - { role: docker, tags: docker }
    - role: rkt
      tags: rkt
      when: "'rkt' in [etcd_deployment_type, kubelet_deployment_type, vault_deployment_type]"
[...]
```


## Proxy pour pull les images Docker

J’ai été pas mal embêté par le proxy lors de l’installation de mon cluster avec **kubeadm**. Même si je n’ai pas été _bloqué_ avec Kubespray, j’ai quand même été un peu embêté ;-).

Le contournement est simple, ici il suffit de configurer le proxy sur les démons docker de toutes les machines du cluster. Avec Ansible :

```
ansible -m shell master* worker* -a 'cat > /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
[Service] Environment="HTTP_PROXY=http://@IP-mon-super-proxy:8080/"' 

ansible -m shell master* worker* -a "systemctl daemon-reload" 
ansible -m shell master* worker* -a "systemctl restart docker" 
```


Attention au _restart_ si vous avez des containers qui tournent... mais je vais partir du principe que nous puisque vous êtes en train d’installer un cluster Kubernetes (depuis zéro).

## The error was: no test named &lsquo;equalto’

Vous avez probablement oublié [un des prérequis du tutoriel][2] : la version de jinja n’est pas pas à jour...

```
pip install --upgrade Jinja2 
```


## Messages d’information à chaque exécution de kubectl

J’ai aussi eu un petit bug (non bloquant) une fois l’installation terminée. A chaque exécution de kubectl, j’avais les messages suivants qui s’affichaient dans le terminal.

```
kubectl describe service kubernetes-dashboard --namespace=kube-system 

2017-08-24 10:20:09.035979 I | proto: duplicate proto type registered: google.protobuf.Any 
2017-08-24 10:20:09.036050 I | proto: duplicate proto type registered: google.protobuf.Duration 
2017-08-24 10:20:09.036066 I | proto: duplicate proto type registered: google.protobuf.Timestamp 
[…] 
```


Une « issue » a été remontée sur [le github de la version de Kubernetes déployée par Azure, à savoir acs-engine][3], mais est applicable dans notre cas aussi. A priori c’est une version de **kubectl** qui a le problème.

Le problème devrait être résolu avec la version qu’on trouve sur les repository.

```
mv /usr/local/bin/kubectl /usr/local/bin/kubectl.old 
yum install -y kubectl 
ln -s /usr/bin/kubectl /usr/local/bin/kubectl 
```


 [1]: /recherche/?keyword=Kubernetes
 [2]: /2017/12/05/installer-kubernetes-kubespray-ansible/
 [3]: https://github.com/Azure/acs-engine/issues/1083
