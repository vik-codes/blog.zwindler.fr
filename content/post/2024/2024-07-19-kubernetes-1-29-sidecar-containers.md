---
title: 'Kubernetes 1.29 - sidecar container - à quoi ça peut bien servir ?'
authors:
  - zwindler
type: post
date: 2024-07-19T12:00:00+02:00
url: /2024/07/19/kubernetes-1-29-sidecar-containers/
image: /2024/07/race.jpeg
categories:
  - Virtualisation
tags:
  - Kubernetes
  - sidecar
  - sidecar container
  - initContainer
  - startupProbe
  - race condition
  - cloud sql

---

## Introduction

J'ai un copain qui doit lancer un traitement périodique. Ce traitement est réalisé par un bout de code qui tourne dans un container (sur un cluster GKE), et qui a besoin de requêter une base de donnée Cloud SQL.

Pour ce genre de choses, Google Cloud fourni une image à mettre à côté de son application (sidecar pattern) qui sert de passe plat (proxy) pour que l'application se connecte à l'instance Cloud SQL chez Google cloud.

* [cloud.google.com/sql/docs/mysql/connect-kubernetes-engine?hl=fr](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine?hl=fr)

Pas de bol, il se trouve que cette image met parfois un peu de temps à démarrer, et son absence fait crasher l'application de mon ami. On se retrouve avec une race condition et il m'a demandé si j'avais des idées de solutions pour régler ce problème.

Parmis d'autres propositions (que je détaille dans le tout dernier paragraphe), je lui propose d'essayer une toute nouvelle fonctionnalité qui est en béta dans Kubernetes 1.29 que je n'avais pas encore testé moi même : les sidecar containers !

* [kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/)

*Fun* fact: en cherchant de la documentation sur cloud sql sidecar, je suis tombé sur cet article d'une personne qui a exactement le même problème que mon ami.

* [hwchiu.medium.com/exploring-kubernetes-1-28-sidecar-container-support-ed1a39ac7fe0](https://hwchiu.medium.com/exploring-kubernetes-1-28-sidecar-container-support-ed1a39ac7fe0)

Une fois n'est pas coutume, pour que vous puissiez bien comprendre le problème et sa résolution, je vous propose de faire cette découverte de feature avec une démo.

La totalité du code et les instructions pour le refaire en anglais sont disponibles sur le dépôt github [github.com/zwindler/sidecar-container-example](https://github.com/zwindler/sidecar-container-example).

L'idée est la suivante : on va simuler le problème de mon poto avec deux images Docker créées pour l'occasion :
* **zwindler/slow-sidecar** un helloworld basique en *V lang* ([vhelloworld](https://github.com/zwindler/vhelloworld)) qui fait un sleep de 5 secondes avant d'écouter le port 8081.
* **zwindler/sidecar-user** un script bash qui `curl` et `exit 1` si le `curl` échoue.

## Prérequis

Comme dit précédemment, la fonctionnalité a été introduite dans Kubernetes 1.28 en tant que fonctionnalité alpha. Si vous utilisez cette version et souhaitez la tester, vous devez activer spécifiquement le flag de fonctionnalité.

À partir de Kubernetes 1.29, cette fonctionnalité est passée en bêta et devrait être activée par défaut sur votre cluster.

## Sans conteneurs sidecar

D'abord, on va essayer de déployer le CronJob de manière naïve sur un cluster :

```bash
$ cat 1-cronjob-without-sidecar-container.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sidecar-cronjob
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sidecar-user
            image: zwindler/sidecar-user
          - name: slow-sidecar
            image: zwindler/slow-sidecar
            ports:
            - containerPort: 8081
          restartPolicy: Never

$ kubectl apply -f 1-cronjob-without-sidecar-container.yaml
```

Cela devrait échouer car le conteneur "slow sidecar" ne sera pas prêt lorsque le conteneur "sidecar user" essaiera de faire un `curl`.

```bash
$ kubectl get pods
NAME                             READY   STATUS   RESTARTS   AGE
sidecar-cronjob-28689938-5n5x9   1/2     Error    0          9s

$ kubectl describe pods sidecar-cronjob-28689938-5n5x9
[...]
Containers:
  slow-sidecar:
[...]
    State:          Running
      Started:      Fri, 19 Jul 2024 15:38:03 +0200
    Ready:          True
[...]
  sidecar-user:
[...]
    State:          Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Fri, 19 Jul 2024 15:38:05 +0200
      Finished:     Fri, 19 Jul 2024 15:38:05 +0200
    Ready:          False
    Restart Count:  0
[...]
```

slow-sidecar fonctionne bien mais notre requête sidecar-user a échoué car le sidecar était trop lent à démarrer.

Petit nettoyage avant de recommencer :

```bash
kubectl delete cronjob sidecar-cronjob 
```

Utiliser un conteneur init n'est pas une option non plus car le conteneur init ne se terminera jamais (ce n'est pas son but) et le conteneur "sidecar user" attendra éternellement son tour. Si vous voulez essayer, convertissez simplement slow-sidecar en initContainer.

```diff
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sidecar-cronjob
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sidecar-user
            image: zwindler/sidecar-user
+         initContainers:
          - name: slow-sidecar
            image: zwindler/slow-sidecar
            ports:
            - containerPort: 8081
          restartPolicy: Never
```

Et lancez-le

```bash
$ kubectl apply -f 2-cronjob-with-init-container.yaml

$ kubectl get pods
NAME                             READY   STATUS     RESTARTS   AGE
sidecar-cronjob-28689955-lzbnf   0/1     Init:0/1   0          27s
```

Et on reste boqué à cette étape jusqu'à la fin de teeeeeeemps.

## Avec des conteneurs sidecar

Pour éviter ce type de race condition, mettons à jour le manifest en convertissant slow-sidecar en initContainer MAIS EN AJOUTANT également `restartPolicy: Always` dans la déclaration du container slow-sidecar.

Cette bidouille est la manière de dire à Kubernetes de lancer ce conteneur en tant qu'initContainer mais de ne PAS attendre qu'il se termine (ce qu'il ne fera jamais puisqu'il s'agit d'un serveur web écoutant sur 8081 jusqu'à la fin des temps) pour démarrer l'application principale.

```diff
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sidecar-cronjob
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sidecar-user
            image: zwindler/sidecar-user
+         initContainers:
          - name: slow-sidecar
            image: zwindler/slow-sidecar
+           restartPolicy: Always
            ports:
            - containerPort: 8081
          restartPolicy: Never
```

**Note:** C'est la manière officielle de déclarer un conteneur sidecar dans Kubernetes. Je n'ai pas encore lu le KEP donc je ne peux pas dire pourquoi l'équipe de développement n'a pas introduit un nouveau mot-clé `sidecarContainers` dans le schéma de spécification du Pod et a réutilisé les `initContainers` déjà existants.

```bash
$ kubectl apply -f 3-cronjob-with-sidecar-container.yaml
```

Cette fois, le conteneur init devrait se lancer et ENSUITE seulement, l'application :

```bash
$ kubectl get pods -w
NAME                             READY   STATUS    RESTARTS   AGE
sidecar-cronjob-28689958-zrmhh   0/2     Pending   0          0s
sidecar-cronjob-28689958-zrmhh   0/2     Pending   0          0s
sidecar-cronjob-28689958-zrmhh   0/2     Init:0/1   0          0s
sidecar-cronjob-28689958-zrmhh   1/2     PodInitializing   0          2s
sidecar-cronjob-28689958-zrmhh   1/2     Error             0          3s
```

On voit que c'est mieux (sidecar-user démarre dans un second temps) mais dans cet exemple particulier, ça échoue encore...

## Avec des conteneurs sidecar ET une startupProbe

Par défaut, le kubelet considère que le conteneur sidecar est up dès que le processus dans le conteneur est en cours d'exécution, puis si les autres initContainers ont tous terminé (ou s'il n'y en a pas), passe à la phase principale de démarrage des containers.

Malheureusement, dans notre cas, le conteneur sidecar est très lent (sleep 5), donc le fait que le processus soit en cours d'exécution n'est pas une indication de l'état du sidecar...

Nous devons ajouter une `startupProbe` pour que Kubernetes sache QUAND passer la phase d'init et démarrer la phase principale.

> After a sidecar-style init container is running (the kubelet has set the started status for that init container to true), the kubelet then starts the next init container from the ordered .spec.initContainers list. That status either becomes true because there is a process running in the container and no startup probe defined, or as a result of its startupProbe succeeding.

```diff
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sidecar-cronjob
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sidecar-user
            image: zwindler/sidecar-user
          initContainers:
          - name: slow-sidecar
            image: zwindler/slow-sidecar
            restartPolicy: Always
            ports:
            - containerPort: 8081
+           startupProbe:
+             httpGet:
+               path: /
+               port: 8081
+             initialDelaySeconds: 5
+             periodSeconds: 1
+             failureThreshold: 5
          restartPolicy: Never
```

Une dernière fois :

```bash
$ kubectl apply -f 4-cronjob-with-sidecar-container-and-startup-probe.yaml && kubectl get pods -w
cronjob.batch/sidecar-cronjob created
NAME                             READY   STATUS    RESTARTS   AGE
sidecar-cronjob-28689977-lt77c   0/2     Pending   0          0s
sidecar-cronjob-28689977-lt77c   0/2     Pending   0          0s
sidecar-cronjob-28689977-lt77c   0/2     Init:0/1   0          0s
sidecar-cronjob-28689977-lt77c   0/2     Init:0/1   0          1s
sidecar-cronjob-28689977-lt77c   0/2     PodInitializing   0          6s
sidecar-cronjob-28689977-lt77c   1/2     PodInitializing   0          6s
sidecar-cronjob-28689977-lt77c   1/2     Completed         0          7s
```

Hooray!

## Bonus : si vous n'avez pas sidecarContainers activé

Si vous êtes toujours en Kubernetes 1.28 (ou pire) et que vous n'avez pas la possibilité d'activer les alpha featureFlags, il va falloir trouver une autre méthode.

Malheureusement, il est probable que la solution soit de modifier le code de votre application principale ou son image Docker. Vous pouvez :

* ajouter une politique de retry dans l'application sidecar-user
* ajouter un script dans l'application sidecar-user qui attend un peu (sleep) avant d'essayer de contacter le sidecar

La première est une bonne pratique lorsqu'on traite avec des microservices et vous devriez l'envisager de toute façon pour gérer les problèmes temporaires de connexion à la base de données.

La deuxième est une rustine sur une jambe de bois. Je le déconseille fortement car la vitesse de démarrage peut varier dans le sidecar et ajouter trop de délai dans l'application est également mauvais lorsqu'on doit gérer des incidents et des bugs en prod (induisant potentiellement d'autres problèmes).
