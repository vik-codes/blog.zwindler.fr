---
title: "zeropod : scale-to-zero avec checkpoint du container"
authors:
  - zwindler
type: post
date: 2025-06-20T19:00:00+02:00
description: "Test de zeropod, un runtime Kubernetes qui fait du scale-to-zero avec checkpointing automatique des conteneurs"
url: /2025/06/20/zeropod-scale-to-zero-kubernetes-checkpointing
image: /2025/06/zeropod.png
categories:
  - virtualisation
tags:
  - Kubernetes
  - k3s
  - zeropod
  - scale-to-zero
  - CRIU
  - containerd

---

## Qu'est-ce que zeropod ?

J'ai laissé le paragraphe d'intro de la doc du projet telle quelle parce que je la trouve top. Elle dit tout ce que vous devez savoir sur l'outil, ni trop ni trop peu. 

> Zeropod is a Kubernetes runtime (more specifically a containerd shim) that automatically checkpoints containers to disk after a certain amount of time of the last TCP connection.
>
> While in scaled down state, it will listen on the same port the application inside the container was listening on and will restore the container on the first incoming connection. 
>
> Depending on the memory size of the checkpointed program this happens in tens to a few hundred milliseconds, virtually unnoticable to the user.
>
> As all the memory contents are stored to disk during checkpointing, all state of the application is restored. 
>
> It adjusts resource requests in scaled down state in-place if the cluster supports it.
>
> To prevent huge resource usage spikes when draining a node, scaled down pods can be migrated between nodes without needing to start up.

Pour les anglophobes : ça va freezer votre app si elle ne reçoit pas de call TCP, et la restaurer quand un call arrive.

Si vous voulez comprendre plus en détail COMMENT ça marche vraiment, dans ce cas, je vous invite à aller lire la section "How it works" documentation officielle du projet, qui a le mérite d'être assez claire :

* https://github.com/ctrox/zeropod?tab=readme-ov-file#how-it-works

## Prérequis

On perd pas de temps, on se lance dans l'expérimentation. En prérequis, j'ai eu besoin de :

* un serveur Ubuntu avec k3s vanilla (flannel + traefik, un seul node). Si vous ne savez pas comment l'installer, vous pouvez toujours jeter un oeil à [mon article à ce sujet](/2023/09/18/k3s-et-cilium-rapide-et-facile).
* cert-manager. Pas forcément nécessaire mais j'aime bien avoir des certificats HTTPS valides.

```bash
# Install cert-manager CRDs and namespace
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=60s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cainjector -n cert-manager --timeout=60s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=webhook -n cert-manager --timeout=60s
```

Configuration du ClusterIssuer :

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: votre.email@example.org
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
```

Optionnel aussi, pour plus de facilité, j'ai modifié les  ports du service traefik en 30080 et 30443 car je n'ai pas de support des Services de type LoadBalancer sur ce cluster :

```bash
kubectl get svc -A
NAMESPACE      NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
cert-manager   cert-manager           ClusterIP      10.43.212.125   <none>          9402/TCP                     21h
cert-manager   cert-manager-webhook   ClusterIP      10.43.134.29    <none>          443/TCP                      21h
default        kubernetes             ClusterIP      10.43.0.1       <none>          443/TCP                      21h
kube-system    kube-dns               ClusterIP      10.43.0.10      <none>          53/UDP,53/TCP,9153/TCP       21h
kube-system    metrics-server         ClusterIP      10.43.83.225    <none>          443/TCP                      21h
kube-system    traefik                LoadBalancer   10.43.208.56    192.168.1.242   80:30080/TCP,443:30443/TCP   21h
```

### Installation de zeropod

Une fois qu'on a notre cluster fonctionnel avec tous les prérequis, on peut installer zeropod. La première étape consiste "juste" à appliquer le manifest kustomize suivant, qui va créer un DaemonSet customisé avec les bons paths pour qu'il puisse se brancher / patcher containerd.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: zeropod-node
  namespace: zeropod-system
spec:
  template:
    spec:
      volumes:
        - name: containerd-etc
          hostPath:
            path: /var/lib/rancher/k3s/agent/etc/containerd/
        - name: containerd-run
          hostPath:
            path: /run/k3s/containerd/
        - name: zeropod-opt
          hostPath:
            path: /var/lib/rancher/k3s/agent/containerd
```

```bash
kubectl apply -k https://github.com/ctrox/zeropod/config/k3s
```

Puis on va labéliser le Node et vérifier que le pod controller fonctionne :

```bash
kubectl label node zeropod zeropod.ctrox.dev/node=true
kubectl -n zeropod-system wait --for=condition=Ready pod -l app.kubernetes.io/name=zeropod-node
```

La documentation indique qu'il faut redémarrer le Node dans le cas de k3s car tout est packagé ensemble dans un k3s (probablement pareil pour k0s). C'est probablement pas nécessaire pour la plupart des distributions "normales".

```bash
NAMESPACE        NAME                                       READY   STATUS      RESTARTS      AGE
...
zeropod-system   zeropod-node-qntzh                         1/1     Running     1 (21h ago)   21h
```

Point intéressant : zeropod va ajouter sa propre runtimeClass (je vous laisse jeter un oeil [à la documentation Kubernetes](https://kubernetes.io/docs/concepts/containers/runtime-class/), ça vaut le détour si vous ne connaissez pas) :

```bash
kubectl get runtimeclass
NAME                  HANDLER               AGE
crun                  crun                  21h
[...]
zeropod               zeropod               21h
```

## Déploiement d'une application WordPress

**Quel est le meilleur cas d'usage pour Kubernetes ?**

Héberger un blog perso avec Wordpress et de l'autoscaling, bien entendu !! Tout le monde sait ça.

Au delà de la vanne, l'idée était de tester une application stateful, si possible avec une base de données, histoire de voir jusqu'ou on peut pousser l'outil. Car une des limitations des outils scale-to-zero dans kubernetes est justement qu'ils marchent super bien pour des workloads stateless (ou FaaS), mais que c'est plus compliqué quand on a un état.

Première chose à savoir : au delà du label qu'on a mis sur le node, il est nécessaire d'ajouter 2 points de configuration supplémentaires sur nos applications qu'on veut scale to zero. 

1. Les annotations zeropod ; pas trop besoin d'expliquer ce que ça fait : on lui donne le numéro du port, le container et la durée à partir de laquelle, si je n'ai pas de connexion, je scale down :

```yaml
annotations:
  zeropod.ctrox.dev/ports-map: "wordpress=80"
  zeropod.ctrox.dev/container-names: wordpress
  zeropod.ctrox.dev/scaledown-duration: 10s
```

2. La runtimeClass qui doit être définie :

```yaml
runtimeClassName: zeropod
```

## Manifests de l'application

Voilà à quoi ça pourrait grossièrement ressembler. On peut faire plus propre (charts helm) mais j'ai fait quick and dirty, ça suffit pour ce PoC :

Deployment WordPress :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php
spec:
  selector:
    matchLabels:
      app: php
  template:
    metadata:
      labels:
        app: php
      annotations:
        zeropod.ctrox.dev/ports-map: "wordpress=80"
        zeropod.ctrox.dev/container-names: wordpress
        zeropod.ctrox.dev/scaledown-duration: 10s
    spec:
      runtimeClassName: zeropod
      initContainers:
      - command:
        - sh
        - -c
        - |
          until mysql -h mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1"; do
            echo "Waiting for MySQL to be ready..."
            sleep 5
          done
          echo "MySQL is ready!"
          mysql -h mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS wordpress;"
          mysql -h mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'%';"
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: verySecurePassword
        image: mysql
        imagePullPolicy: IfNotPresent
        name: wait-for-mysql
      containers:
      - env:
        - name: WORDPRESS_DB_HOST
          value: mysql
        - name: WORDPRESS_DB_USER
          value: root
        - name: WORDPRESS_DB_PASSWORD
          value: verySecurePassword
        - name: WORDPRESS_DB_NAME
          value: wordpress
        image: wordpress:latest
        imagePullPolicy: Always
        name: wordpress
        ports:
        - containerPort: 80
          protocol: TCP
```

StatefulSet MySQL :

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  selector:
    matchLabels:
      app: mysql
  serviceName: "mysql"
  replicas: 1
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - image: mysql
          name: mysql
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: verySecurePassword
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 5Gi
```

Services et Ingress :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: php
  labels:
    app: php
spec:
  ports:
    - port: 8080
      name: http
      targetPort: 80
  selector:
    app: php
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  ports:
    - port: 3306
      name: mysql
  clusterIP: None
  selector:
    app: mysql
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: zeropod-ingress
  namespace: default
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  rules:
  - host: zeropod.example.org
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: php
            port:
              number: 8080
  tls:
  - hosts:
    - zeropod.example.org
    secretName: zeropod-tls
```

## Observation du comportement

Une fois déployé, on vérifie vite fait l'état des pods et des services :

```bash
kubectl get pods
NAME                  READY   STATUS    RESTARTS   AGE
mysql-0               1/1     Running   0          17h
php-dc7cb9cff-29hzb   1/1     Running   0          17h
```

```bash
kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
[...]
mysql        ClusterIP   None            <none>        3306/TCP   21h
php          ClusterIP   10.43.165.131   <none>        8080/TCP   21h
```

## Détection de l'absence de trafic

Peu après avoir déployé Apache PHP, zeropod remarque qu'il n'y a pas eu de connexion depuis un moment et met le container en pause.

Le truc rigolo, c'est que du point de vue Kubernetes, il ne s'est rien passé ! Le pod `php-dc7cb9cff-29hzb` existe toujours et est présent dans la liste des `Non terminated` pods du Node :

```bash
kubectl get pods php-dc7cb9cff-29hzb
NAME                  READY   STATUS    RESTARTS   AGE
php-dc7cb9cff-29hzb   1/1     Running   0          17h

kubectl describe nodes
[...]
Non-terminated Pods:          (11 in total)
  Namespace                   Name                                        CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                                        ------------  ----------  ---------------  -------------  ---
[...]
  default                     mysql-0                                     0 (0%)        0 (0%)      0 (0%)           0 (0%)         17h
  default                     php-dc7cb9cff-29hzb                         0 (0%)        0 (0%)      0 (0%)           0 (0%)         17h
[...]
```

Il n'apparait en revanche plus dans les métriques "top pods" collectés par metrics-server :

```bash
kubectl top pods
NAME      CPU(cores)   MEMORY(bytes)   
mysql-0   4m           460Mi    
```

Et si on cherche le processus apache2 sur le node, on ne le retrouvera pas :

```bash
sudo ps -ef | grep apache2

```

## Sous le capot, les logs de zeropod

Dans les logs de zeropod, on remarque d'abord la détection d'un container éligible au scale to zero :

```json
{"time":"2025-06-20T17:31:46.222502407Z","level":"INFO","msg":"subscribing to status events","sock":"/run/zeropod/s/5858a327ae5a70c2e12b5dad1e8320a4670ff11152476ad49605ebca5327f7d6.sock"}
{"time":"2025-06-20T17:31:47.572065537Z","level":"INFO","msg":"status event","component":"podlabeller","container":"wordpress","pod":"php-dc7cb9cff-29hzb","namespace":"default","phase":1}
{"time":"2025-06-20T17:31:47.5737556Z","level":"INFO","msg":"attaching redirector for sandbox","pid":64980,"links":["eth0","lo"]}
```

Et au bout de 10 secondes, comme il n'y a pas eu de connexion, zeropod l'éteint ("phase":0) :

```json
{"time":"2025-06-20T17:31:57.932464147Z","level":"INFO","msg":"status event","component":"podlabeller","container":"wordpress","pod":"php-dc7cb9cff-29hzb","namespace":"default","phase":0}
```

## Tests de performance

Quand le processus est checkpointé, on va voir que le curl met quand même un peu de temps à être servi. Rien de dramatique, mais quand même :

```bash
time curl https://zeropod.example.org:30443 -I
HTTP/2 200 
content-type: text/html; charset=UTF-8
date: Fri, 20 Jun 2025 17:41:29 GMT
link: <https://zeropod.example.org:30443/wp-json/>; rel="https://api.w.org/"
server: Apache/2.4.62 (Debian)
x-powered-by: PHP/8.2.28

real	0m0.454s
user	0m0.052s
sys	0m0.010s
```

En revanche, pour toutes les connexions suivantes, les temps sont corrects pour un Wordpress vide (et pas optimisé) :

```bash
time curl https://zeropod.example.org:30443 -I
HTTP/2 200 
content-type: text/html; charset=UTF-8
date: Fri, 20 Jun 2025 17:41:42 GMT
link: <https://zeropod.example.org:30443/wp-json/>; rel="https://api.w.org/"
server: Apache/2.4.62 (Debian)
x-powered-by: PHP/8.2.28

real	0m0.088s
user	0m0.053s
sys	0m0.008s
```

Donc, ça fonctionne ! 

La première connexion prend bien un peu plus de temps, pendant que le programme eBPF qui "écoute" le trafic pendant que le container est down ne le rallume et rende la main (ici +350-400ms sur une petite VM pas chère et assez chargée).

Une fois le conteneur restauré, on peut d'ailleur voir (ré)apparaitre les processus `apache2` avec un `ps` sur le Node :

```bash
ps -ef |grep apache2
root       67038   64955  1 18:56 ?        00:00:00 apache2 -DFOREGROUND
www-data   67055   67038  0 18:56 ?        00:00:00 apache2 -DFOREGROUND
www-data   67056   67038  0 18:56 ?        00:00:00 apache2 -DFOREGROUND
www-data   67057   67038  0 18:56 ?        00:00:00 apache2 -DFOREGROUND
www-data   67058   67038  0 18:56 ?        00:00:00 apache2 -DFOREGROUND
www-data   67059   67038  0 18:56 ?        00:00:00 apache2 -DFOREGROUND
www-data   67060   67038  0 18:56 ?        00:00:00 apache2 -DFOREGROUND
```

## Aller plus loin : test avec MySQL

Bon, par contre, scaler à 0 un serveur http, c'est rigolo, mais c'est pas révolutionnaire. Il existe déjà sur le marché des solutions de scale to zero dans Kubernetes, surtout pour tout ce qui est FaaS ou stateless. Mais si on pousse l'expérience jusqu'au bout ?

On a rarement envie de scaler à 0 une base de données dans la vraie vie. L'arrêter puis la redémarrer, ça peut prendre du temps, et potentiellement ça va faire des erreurs dans nos apps si le scaling est mal fait.

Cependant, avec zeropod, le principe est un peu différent, puisqu'on ne va pas vraiment arrêter le processus, juste le *freeze*.

Pour la science (ne faites pas ça en prod), j'ai donc ajouté zeropod sur la bdd MySQL aussi !

Comme pour wordpress, on met les annotations et la runtimeClass :

```yaml
template:
  metadata:
    labels:
      app: mysql
    annotations:
      zeropod.ctrox.dev/ports-map: "mysql=3306"
      zeropod.ctrox.dev/container-names: mysql
      zeropod.ctrox.dev/scaledown-duration: 10s
  spec:
    runtimeClassName: zeropod
    containers:
    # ...
```

Au bout de quelques secondes, zeropod passe la base de données mysql à la phase "0" :

```json
{"time":"2025-06-20T18:06:14.92372877Z","level":"INFO","msg":"status event","component":"podlabeller","container":"mysql","pod":"mysql-0","namespace":"default","phase":1}
{"time":"2025-06-20T18:06:14.925316023Z","level":"INFO","msg":"attaching redirector for sandbox","pid":69570,"links":["eth0","lo"]}
{"time":"2025-06-20T18:06:25.766097339Z","level":"INFO","msg":"status event","component":"podlabeller","container":"mysql","pod":"mysql-0","namespace":"default","phase":0}
```

`kubectl top pods` ne remonte plus aucun pod (et une erreur...) :

```bash
kubectl top pods
error: Metrics not available for pod default/php-dc7cb9cff-29hzb, age: 35m59.026573861s
```

Mais les pods restent bien visibles et "Running" du point de vue de Kubernetes :

```bash
kubectl get pods
NAME                  READY   STATUS    RESTARTS   AGE
mysql-0               1/1     Running   0          2m30s
php-dc7cb9cff-29hzb   1/1     Running   0          36m
```

## Test final : réveil en cascade

Le test final : est-ce qu'un call HTTP sur php va le réveiller, ce qui va déclencher une connexion à la base de données mysql qui va à son tour la réveiller aussi ?

**Roulement de tambours**

```bash
time curl https://zeropod.example.org:30443 -I
HTTP/2 200 
content-type: text/html; charset=UTF-8
date: Fri, 20 Jun 2025 18:09:24 GMT
link: <https://zeropod.example.org:30443/wp-json/>; rel="https://api.w.org/"
server: Apache/2.4.62 (Debian)
x-powered-by: PHP/8.2.28

real	0m0.978s
user	0m0.053s
sys	0m0.008s
```

Victoire !!

## Limitations

Au delà de cet exemple un peu nouille (qui n'a jamais voulu héberger un wordpress sur Kubernetes avec du scaling to zero ?), on se rend compte que la techno "marche" mais reste un peu flacky.

J'ai eu plusieurs cas dans lequel le scaling to zero se faisait sur le pod php, alors que j'étais en train de faire une boucle avec un "while true; do curl" (peut être lié à la chaine ingress -> service -> pod ?). Et le temps de checkpointing est quand même visible sur ma VM de test (400 ms par container, c'est pas rien).

Un point qui n'est pas abordé dans la doc du projet est qu'il est quasiment impossible de mettre des liveness / readiness **correctes** quand vous utilisez zeropod. 

Si vous mettez une liveness sur un service web, vous allez trigger un call sur le port TCP écouté par zeropod, et donc redémarrer l'app qui ne sera jamais checkpointée. Si vous mettez une readiness, même combat.

Et si vous comptez vous en sortir avec un liveness / readiness qui ne trigger pas un call HTTP sur le port surveillé par zeropod, vous allez vous retrouver avec une app vue par Kubernetes comme (respectivement) KO ou "Not ready", puisque le container ne sera pas disponible car checkpointé.

* [une issue ouverte sur le sujet - github.com/ctrox/zeropod/issues/34](https://github.com/ctrox/zeropod/issues/34#issuecomment-2524994973)

Techniquement, zeropod, c'est très rigolo et assez malin, je suis assez admiratif. 

Mais je ne vois pas trop dans quel monde on souhaiterait avoir des containers **en prod** sans liveness / readiness, donc je suis assez sceptique sur l'usage de cette techno en l'état, à part pour des exemples très peu critiques. Cette limitation me semble trop grande.
