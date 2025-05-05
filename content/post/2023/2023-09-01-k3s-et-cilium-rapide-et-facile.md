---
title: k3s et cilium rapide et facile
authors:
  - zwindler
type: post
date: 2023-09-01T10:00:00+02:00
url: /2023/09/01/k3s-et-cilium-rapide-et-facile
aliases:
  - /2023/09/18/k3s-et-cilium-rapide-et-facile
image: /2023/09/k3s_cilium.png
categories:
  - Cluster
  - DIY
  - systeme
  - Virtualisation
tags:
  - k3s
  - k8s
  - Kubernetes
  - cilium
  - flannel
  - eBPF

---

## Contexte

[K3s](https://k3s.io/) est une distribution de Kubernetes éditée par Rancher (et certifiée par la CNCF) que je trouve super pratique car légère et supportant plusieurs plateformes (en particulier ARM): 
* x86_64
* armhf
* arm64/aarch64
* s390x

Je l'ai déjà utilisée par le passé ([ici](https://blog.zwindler.fr/2019/03/21/deployer-en-5-minutes-un-cluster-kubernetes-sur-arm-avec-k3s-et-ansible/)) pour faire un cluster kubernetes avec des vieux Raspberry Pi. A l'époque, on pouvait même faire tourner les nodes "workers" sur des RPi 1 (je ne sais pas si c'est toujours possible).

La particularité de k3s est que tout est intégré dans un seul binaire. Nécessairement, des choix techniques ont été fais pour rendre l'installation et l'utilisation la plus légère possible. Parmi ces choix techniques, il y a l'utilisation de [flannel comme "CNI plugin"](https://github.com/flannel-io/flannel) (pour faire simple, le réseau virtuel qui permet aux containers de parler en eux).

Je ne suis vraiment PAS fan de flannel qui m'a posé beaucoup de soucis en production, qui ne supporte pas les "Network Policies", qui a pendant plusieurs années utilisé comme backend etcd2 alors que ce logiciel était marqué comme obsolète (deprecated) depuis plusieurs années, ...

A l'inverse, je suis très fan de [cilium](https://cilium.io/), qui a beaucoup de fonctionnalités sympa grâce à l'usage de eBPF en termes de performance et de sécurité et a pas mal de traction dans l'écosystème.

## Prérequis

Dans ce tutoriel, je pars du principe que vous avez installé un serveur avec Ubuntu 22.04.

Cilium est très friand d'eBPF, dont il tire la plupart de ces fonctionnalités. Et comme eBPF est quelque chose d'assez récent dans le kernel Linux, le mieux est de mettre à jour notre serveur et de lui mettre un kernel plus récent :

```bash
$ sudo apt update -y
$ sudo apt upgrade -y
$ sudo apt install curl linux-image-generic-hwe-22.04 -y
```

Une fois que c'est fait, on reboot le serveur pour la prise en compte du nouveau kernel.

## Installation de k3s

On installe donc [k3s](https://docs.k3s.io/installation), en remplaçant flannel par cilium (voir documentation [Installation - Network options](https://docs.k3s.io/installation/network-options)). La doc conseille de retirer le support des network-policy. Je me demande comment c'est géré puisque flannel n'est pas censé les supporter :thinking_face:.

```bash
$ curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='--flannel-backend=none --disable "traefik"' sh -s - --disable-network-policy
```

On vérifie que k3s est démarré et fonctionne :

```bash
$ systemctl status k3s
● k3s.service - Lightweight Kubernetes
     Loaded: loaded (/etc/systemd/system/k3s.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-09-01 12:32:55 UTC; 1min 13s ago
       Docs: https://k3s.io
    Process: 1724 ExecStartPre=/bin/sh -xc ! /usr/bin/systemctl is-enabled --quiet nm-cloud-setup.service (code=exited, status=0/SUCCESS)
    Process: 1726 ExecStartPre=/sbin/modprobe br_netfilter (code=exited, status=0/SUCCESS)
    Process: 1727 ExecStartPre=/sbin/modprobe overlay (code=exited, status=0/SUCCESS)
[...]
```

Par défaut, le "kubeconfig" d'administration est déposé dans le fichier `/etc/rancher/k3s/k3s.yaml`, dont le propriétaire est root. Il existe un flag `--write-kubeconfig-mode` dans k3s pour modifier les droits de ce fichier mais cela le rendrait "world readable". 

Pour éviter de faire ça, on récupère le kube/config pour notre utilisateur "ubuntu". 

Comme le binaire k3s embarque tout, dont kubectl, on va aussi devoir lui dire de ne pas utiliser ce fichier en forçant la variable d'environnement $KUBECONFIG.

```bash
$ mkdir ~/.kube
$ sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
$ sudo chown ubuntu:ubuntu ~/.kube/config
$ chmod 600 ~/.kube/config
$ export KUBECONFIG=~/.kube/config

$ kubectl get nodes
NAME     STATUS     ROLES                  AGE   VERSION
kube01   NotReady   control-plane,master   70s   v1.27.4+k3s1

```

Ici, kube01 est marqué NOTREADY. C'est normal car on a pas de CNI plugin (donc pas de réseau interne). 

## Ajout d'un second node

Sur le premier node, récupérez le token pour que le second puisse rejoindre le cluster :

```bash
cat /var/lib/rancher/k3s/server/node-token
```

Une fois que c'est fait, connectez vous sur le node à rajouter au cluster, installez le kernel `hwe`, rebootez

```
sudo apt update
sudo apt upgrade
sudo apt install curl linux-image-generic-hwe-22.04 -y

sudo reboot
```

Une fois que le node est à jour et prêt à rejoindre le cluster, lancez la commande suivante :

```bash
IP_MASTER=IP.DE.VOTRE.MASTER
K3STOKEN=le:token:du:master
curl -sfL https://get.k3s.io | K3S_URL=https://${IP_MASTER}:6443 K3S_TOKEN=${K3STOKEN} sh -
```

Au bout de quelques secondes, votre node va apparaître dans la liste des nodes.

## CNI plugin + ingressController

Nos nodes sont toujours en "Not Ready". On installe helm et on ajoute le CNI plugin :

```bash
$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
$ CILIUM_VERSION="1.14.2"
$ helm repo add cilium https://helm.cilium.io/
$ helm upgrade --install cilium cilium/cilium --version=${CILIUM_VERSION} \
    --set global.tag="v${CILIUM_VERSION}" --set global.containerRuntime.integration="containerd" \
    --set global.containerRuntime.socketPath="/var/run/k3s/containerd/containerd.sock" \
    --set global.kubeProxyReplacement="strict" \
    --set global.bpf.masquerade="true" \
    --set ingressController.enabled=true \
    --set ingressController.default=true \
    --namespace cilium \
    --create-namespace
```

Note: pour le fun, j'ai aussi ajouté le support de l'ingressController de cilium. Comme ça c'est fait :D.

Au bout de quelques secondes, notre cluster devrait devenir opérationnel. On a aussi metric server (pour les stats de base).

```bash
$ kubectl get pods -A
NAMESPACE     NAME                                     READY   STATUS    RESTARTS   AGE
kube-system   cilium-operator-86dbc96dd6-hlgtt         1/1     Running   0          56s
kube-system   cilium-operator-86dbc96dd6-h7sq6         1/1     Running   0          56s
kube-system   cilium-pxrrz                             1/1     Running   0          56s
kube-system   cilium-psjr4                             1/1     Running   0          56s
kube-system   svclb-cilium-ingress-c27a13c6-x7tld      2/2     Running   0          32s
kube-system   local-path-provisioner-957fdf8bc-5w9n9   1/1     Running   0          6m9s
kube-system   coredns-77ccd57875-zlvpc                 1/1     Running   0          6m9s
kube-system   svclb-cilium-ingress-c27a13c6-8dbf6      2/2     Running   0          34s
kube-system   metrics-server-648b5df564-xr29p          1/1     Running   0          6m9s
```

## Conclusion

Voilà pour ce très court article sur k3s et cilium.

Ce setup, rapide à installer sur une install fraîche est ma base pour beaucoup d'expérimentations avec Kubernetes.
