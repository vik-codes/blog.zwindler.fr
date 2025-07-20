---
title: 'Créer un cluster Kubernetes sur Clever Cloud avec les apps Linux'
authors:
  - zwindler
type: post
date: 2025-07-20T09:00:00+02:00
description: "Guide pour déployer un control plane Kubernetes sur Clever Cloud en utilisant les nouvelles apps de type Linux. Projet éducatif et clin d'œil au futur Kubernetes managé."
draft: true
excerpt: "Comment j'ai créé un cluster Kubernetes complet sur Clever Cloud avec les nouvelles apps Linux, en attendant leur offre Kubernetes managée."
url: /2025/07/20/kubernetes-sur-clever-cloud-linux/
image: /2025/07/k8s-clever.jpg
categories:
  - autohebergement
  - cluster
tags:
  - Clever Cloud
  - Kubernetes
  - Linux
  - k8s
  - Control Plane
  - Workers
  - DIY

---

## Introduction

Après avoir testé les [apps statiques chez Clever Cloud](/2025/07/07/je-reessaye-les-sites-statiques-chez-clever/), j'ai voulu pousser plus loin l'exploration des nouvelles fonctionnalités. 

Clever Cloud a en effet lancé récemment un nouveau type d'application : les **apps Linux**. Ces dernières permettent de déployer des applications génériques sur une machine Linux, sans runtime prédéfini. Un peu comme avoir sa propre VM, mais managée par Clever Cloud.

Du coup, pour "rigoler" (et par pure curiosité technique), j'ai décidé de créer un **control plane Kubernetes** complet sur ce type d'instance. Pourquoi ? 

D'abord parce que je parle tout le temps de Kubernetes. Et ensuite, pour faire un petit clin d'œil aux copains de chez Clever cloud : ils annoncent depuis des mois (voire des années) leur offre Kubernetes managée qui devrait sortir prochainement. 

Et en poussant les runtimes linux dans leurs retranchements, ça m'a permis de découvrir pas mal de fonctionnalités que (j'avoue) je ne connaissais pas chez Clever.

**Disclaimer** : ce projet est purement éducatif et expérimental. Ne l'utilisez pas, même pour un usage personnel !

## Le projet : k8s-on-clever-linux

J'ai créé un dépôt GitHub dédié à ce projet : [k8s-on-clever-linux](https://github.com/zwindler/k8s-on-clever-linux).

Le principe est simple : déployer tous les composants du control plane Kubernetes (etcd, kube-apiserver, kube-controller-manager, kube-scheduler) comme des processus sur une app Linux Clever Cloud. 

Le projet s'inspire de mon tutoriel [demystifions-kubernetes](https://github.com/zwindler/demystifions-kubernetes). Et d'ailleurs, pour tester le proof of concept, c'est ce que j'ai bêtement déroulé, pour valider la faisabilité.

Cependant, dans le cas de Clever, plutôt que de lancer tous les composants un par un en déroulant un script bash (ce qui est fait dans github.com/zwindler/demystifions-kubernetes), j'ai fait un poil plus rusé...

## Découverte de Mise.

Mais d'abord un peu de contexte :

> Clever Cloud platform provides a multi-runtime environment, including many tools to deploy and run your applications. The Linux runtime is a versatile solution to build and deploy any kind of application. The Mise package manager helps you to install and manage any supported dependencies Clever Cloud doesn’t provide by default such as Dart, Gleam, Zig for example.

* [Documentation officielle des Linux runtimes chez Clever cloud](https://www.clever-cloud.com/developers/doc/applications/linux/)

Déjà, ça parle d'un truc qui s'appelle **Mise package manager**. C'est quoi ça ?

Il s'agit d'un projet de Jeff Dickey (jdx.dev). Sur nos app Linux, ça va nous permettre d'installer une partie des dépendances d'une part, et d'ordonnancer le lancement de commandes pour build, puis pour run notre projet dans l'instance Linux

* [mise.jdx.dev](https://mise.jdx.dev/dev-tools/)


## Découpage de l'application

Maintenant qu'on en sait plus, voilà comment j'ai découpé l'application avec Mise :

**Initialisation (`mise.toml`)**

Même si tous les prérequis ne sont pas tous disponibles dans Mise, je peux quand même déléguer le téléchargement d'une partie d'entre eux, ce qui va alléger le script de téléchargement des dépendances par rapport à **démystifions kubernetes**. C'est toujours bon à prendre

```toml
[tools]
cfssl = "latest"
etcd = "latest"
kubectl = "latest"
helm = "latest"
```

**Phase de build (`.mise-tasks/build`)**

- Télécharge tous les binaires Kubernetes
- Génère les certificats pour l'authentification des composants
- Configure les paramètres statiques
- **Mise en cache** : cette phase n'est exécutée que lors des changements de code

De cette manière, en cas de reboot de l'application, on ne perd pas les certificats et on gagne un peu de temps pour le redéploiement.

**Phase de run (`.mise-tasks/run`)**  

- Génère les tokens dynamiques

## Focus sur Mise pour installer les dépendances

Concrêtement, comment ça se présente quand on lance une app dans Clever cloud avec un mise.toml ?

Ben tout simplement comme ça :

```
2025-07-20T15:54:04.304Z mise etcd@3.6.2      install
2025-07-20T15:54:05.302Z mise etcd@3.6.2      download etcd-v3.6.2-linux-amd64.tar.gz
2025-07-20T15:54:06.403Z mise etcd@3.6.2      checksum etcd-v3.6.2-linux-amd64.tar.gz
2025-07-20T15:54:06.422Z mise etcd@3.6.2      extract etcd-v3.6.2-linux-amd64.tar.gz
2025-07-20T15:54:06.705Z mise etcd@3.6.2    ✓ installed
```

La liste des tools disponibles avec mise est ici :

* [mise.jdx.dev/registry](https://mise.jdx.dev/registry.html)

Et on peut remarquer que les tools viennent de différentes sources telles que aqua, pipx, ubi, asdf... Ça me donne envie de tester ça pour les dépendances qui me manquent donc attendez-vous à un prochain article sur le sujet :).

## Mais... ils sont où les binaires du control plane de Kubernetes ?

Initialement, j'avais mis tout ça dans la phase de "run". Sauf que David m'a proposé de découvrir une autre fonctionnalité de Clever Cloud que je n'avais jamais utilisée : les Workers.

Les **Workers** sont des processus en arrière-plan qui tournent en parallèle de votre application principale.

Pour notre cluster Kubernetes, c'est **parfait** ! Plutôt que de lancer tous les composants dans un script bash, chaque composant du control plane devient un worker dédié :

```bash
CC_WORKER_COMMAND_0=./run-etcd.sh
CC_WORKER_COMMAND_1=./run-apiserver.sh  
CC_WORKER_COMMAND_2=./run-controller-manager.sh
CC_WORKER_COMMAND_3=./run-scheduler.sh
```

Avec en bonus la possibilité de configurer le comportement de redémarrage :
- `CC_WORKER_RESTART=on-failure` (par défaut) : redémarre seulement en cas d'erreur
- `CC_WORKER_RESTART=always` : redémarre toujours
- `CC_WORKER_RESTART_DELAY=1` : délai en secondes avant redémarrage

## Installation et configuration

Bon, clairement, cette partie n'est pas la plus user-friendly du tutoriel. Si vous voulez plus de détails sur ce qui est fait et pourquoi, vous pouvez aller jeter un œil directement sur le dépôt [github.com/zwindler/k8s-on-clever-linux](https://github.com/zwindler/k8s-on-clever-linux).

Les grandes étapes sont :

* Créer l'app Linux `clever create --type linux --github zwindler/k8s-on-clever-linux`

* Configuration de la redirection TCP

> Linux runtime only requires a CC_RUN_COMMAND to execute, with a working web application listening on 0.0.0.0:8080.

Là, on rencontre un premier hic. Clever Cloud s'attend à ce qu'on expose une app en HTTP non sécurisé sur le port 8080. Sauf que moi, je veux exposer l'API server Kubernetes en HTTPS. On va donc activer la "redirection TCP" : Clever Cloud attribue un port aléatoire (dans les 5XXX) qui redirige vers le port 4040 de votre application (et donc je dois dire à l'API server de ne pas écouter sur le 6443, mais 4040) :

```bash
$ clever tcp-redirs add --namespace default
Successfully added tcp redirection on port: 5131
```

* Configuration du domaine

Une fois le port TCP connu, on peut configurer notre domaine. 

```bash
clever domain add k8soncleverlinux.domain.org
```

Dans mon cas, l'API server sera accessible sur le domaine `k8soncleverlinux.zwindler.fr` et sur le port `5131`. Comme ces deux valeurs seront différentes pour vous, j'ai vite codé un script qui permet de prendre les valeurs par défaut pour moi, mais vous permettre de les écraser si vous spécifiez des valeurs sur VOTRE app Clever Cloud :


```bash
clever env set K8S_DOMAIN k8soncleverlinux.zwindler.fr
clever env set K8S_TCP_PORT 5131
```

Je suis vraiment sympa.

* Configuration des workers : pour ça j'ai fait un script `./setup-clever-workers.sh`

Ce script configure 5 workers gérés par systemd :

- **Worker 0** : etcd (base de données)
- **Worker 1** : kube-apiserver
- **Worker 2** : kube-controller-manager  
- **Worker 3** : kube-scheduler
- **Worker 4** : serveur HTTP

Pourquoi un serveur HTTP ? Eh bien tout simplement parce que 

> Linux runtime only requires a CC_RUN_COMMAND to execute, with a working web application listening on 0.0.0.0:8080.

Si je ne mets rien en écoute sur le port 8080, Clever va logguer que mon app est en panne (alors que non).

## Déploiement et test

Si tout s'est bien passé, l'app devrait correctement se lancer, Mise devrait lancer la phase de build, puis la phase de run.

Les workers en tâche de fond devraient démarrer tous les composants de notre control plane Kubernetes. Au bout de quelques secondes (1 minute max), on devrait avoir un control plane fonctionnel, et tout un tas de certificats et autres secrets.

Mais comment le tester ? Via SSH sur l'instance Clever Cloud ! Car oui, on peut SSH sur cette instance :)

```bash
$ clever ssh
Last login: Fri Jul 18 20:17:00 UTC 2025 on pts/0

bas@yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy ~ $ cd app_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/
bas@yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy ~/app_xxx $ export KUBECONFIG=admin.conf

bas@yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy ~/app_xxx $ kubectl version
Client Version: v1.33.2
Kustomize Version: v5.6.0
Server Version: v1.33.2
```

🎉 **Ça marche !** On a bien un control plane Kubernetes qui tourne sur Clever Cloud !

Et si vous avez bien travaillé (c'est à dire correctement configuré votre domaine et le port), on peut même l'utiliser depuis l'extérieur en copiant le fichier `admin.conf` localement et en modifiant l'endpoint :

```bash
$ kubectl cluster-info
Kubernetes control plane is running at https://k8soncleverlinux.zwindler.fr:5131
```

## Ajout d'un worker node

Deuxième hic dans mon histoire. Un control plane sans worker, c'est pas terrible. 

Et je ne peux pas utiliser l'app de type Linux de chez Clever car je n'ai pas assez de privilèges pour changer les options kernel (routage) et installer containerd.

Mais je n'allais pas en rester là. Dans mon projet "Démystifions Kubernetes", j'installe un worker directement sur la machine du control plane et j'utilise le admin.conf (cluster-admin) pour enrôler l'hôte courant en tant que Node.

C'est cracra. J'ai donc fait l'effort d'aller regarder comment faire pour enrôler des Nodes avec un bootstrap token et c'est assez intéressant. La doc est plutôt bien faite et je ferai peut-être un article à part sur le sujet, c'est assez facile en fait, avec un flag à ajouter dans l'API server, quelques RBAC et un secret bien spécifique à générer.

Je vous épargne les détails, le projet va générer automatiquement un script pour ajouter des nodes externes :

```bash
# Script généré automatiquement
#!/bin/bash
# External Worker Node Setup Script for Kubernetes

API_SERVER_ENDPOINT="https://k8soncleverlinux.zwindler.fr:5131"
BOOTSTRAP_TOKEN="xxxxxx.xxxxxxxxxxxxxxxx"
# ... (configuration complète incluse)
```

Il suffit de copier ce script sur une VM Linux quelconque et de l'exécuter. Le script :

- Installe containerd, kubelet, kube-proxy
- Configure automatiquement l'authentification via bootstrap token
- Démarre les services

```bash
✓ Worker node setup completed!

$ kubectl get nodes
NAME       STATUS     ROLES    AGE   VERSION
dumber01   NotReady   <none>   13m   v1.33.3
```

Le node apparaît en "NotReady" car il manque le plugin CNI. Flannel fonctionne parfaitement :

```bash
$ kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

$ kubectl get nodes
NAME       STATUS   ROLES    AGE   VERSION
dumber01   Ready    <none>   30m   v1.33.3

$ kubectl get pods -A
NAMESPACE      NAME                    READY   STATUS    RESTARTS   AGE
kube-flannel   kube-flannel-ds-b65jg   1/1     Running   0          14m
```

Le **cluster est fonctionnel 😎😎😎 !**

On a maintenant un cluster Kubernetes complet avec control plane sur Clever Cloud et worker externe... Avant la sortie du kube managé de Clever.

![](/2025/07/Trollface.png)

## Limitations et évolutions possibles

Le worker externe n'étant pas dans le réseau Clever Cloud, l'API server ne peut pas communiquer avec le kubelet (dans le sens api-server -> kubelet uniquement). Cela limite les fonctionnalités comme `kubectl logs`, `kubectl exec`, etc. Une solution possible serait d'utiliser les [Network Groups](https://www.clever-cloud.com/developers/doc/develop/network-groups/) de Clever Cloud pour créer un réseau privé sécurisé.

Si ce projet continue de m'amuser, plusieurs améliorations sont envisageables :

* exploration des Network Groups (dont je viens de parler)
* intégration de [Kine](https://github.com/k3s-io/kine). Cela permettrait d'utiliser les bases de données existantes de Clever Cloud (PostgreSQL, MySQL) comme DB pour Kubernetes, ce qui permettrait éventuellement de rendre cette install "HA" ce qui serait aussi débile que rigolo
* création des packages aqua/ubi manquants (les binaires de kubernetes et `cfssljson`)

## Conclusion

J'ai commencé ce projet comme une blague et j'ai finalement mis le doigt dans plein de petites fonctionnalités cools de chez Clever Cloud et dont j'ignorais l'existence (ou alors, que j'avais vu passer mais pas creusé).

Même si ça m'a pris quelques soirées, c'était super intéressant. La première itération a été très vite fonctionnelle et je me suis pris au jeu des améliorations successives.

Le code complet est disponible sur [GitHub](https://github.com/zwindler/k8s-on-clever-linux) si vous voulez reproduire l'expérience ou contribuer !

Et vous, quels projets fous avez-vous envie de tester avec les apps Linux ? 😄
