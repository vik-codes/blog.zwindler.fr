---
title: '[Tutoriel] XWiki, ma premier appli Statefull sur Kubernetes'
authors:
  - zwindler
type: post
date: 2017-10-24T11:30:52+00:00
url: /2017/10/24/tutoriel-xwiki-ma-premier-appli-stateful-sur-kubernetes/
image: /2017/10/xwiki_kubernetes.png
categories:
  - Logiciel
  - Système
  - Virtualisation
tags:
  - ansible
  - Compose
  - container
  - Deployment
  - Docker
  - Gluster
  - kubectl
  - Kubernetes
  - Persistent Volume
  - Pod
  - PostgreSQL
  - SDS
  - service
  - tutoriel
  - Xwiki

---
## Pourquoi déployer XWiki sur Kubernetes ?

Vous le savez surement maintenant vu le nombre d’article que j’ai écrit sur le sujet, j’aime bien [XWiki][1]. C’est un super projet mené par des gens passionnés, réactifs et surtout, c’est cet outil qui a permis à mon entreprise d’adopter ENFIN le wiki comme outil de documentation, que ce soit pour documenter les procédures, mais aussi documenter entièrement les concepts de l’outil que nous développons.

D’un outil quasi-confidentiel utilisés par quelques admins peu motivés (sous Mediawiki), nous sommes donc progressivement passés à un outil utilisé par toutes les équipes, du dev. au support en passant par les ergo. et les CPs, utilisés par plusieurs entités internes et même accepté comme document contractuel par nos prestataires. J’ai d’ailleurs [documenté la migration sur cet article](/2016/12/12/migration-mediawiki-vers-xwiki/).

![](/2016/12/mediawiki_to_xwiki_logo.png)

Mais j’aime aussi XWiki car c’est selon moi l’exemple parfait d’une appli 2 ou 3 tiers relativement simple pour explorer l’écosystème Docker (construction des images, les problématiques réseau et stockage, …). Je joue régulièrement avec [ma propre image sur le Dockerhub][3] pour explorer un peu plus cet écosystème riche (c’est rien de le dire).

Quelle meilleure application donc pour réellement tester mon tout nouveau cluster Kubernetes (je ne compte pas nginx ou helloworld) ?

## Kubernetes ?

Pour ceux qui ont besoin d’un rappel sur Kubernetes ou des premiers concepts et/ou comment l’installer, [je vous invite à lire/relire mon article précédent sur le sujet](/2017/06/07/installer-cluster-kubernetes-vm-centos/).

A noter également (j’ai pas mal communiqué là-dessus sur les réseaux sociaux), la Linux Foundation, qui gère également la Cloud Native Computing Foundation (et qui elle-même gère Kubernetes), a mis à disposition gratuitement un cour en ligne de type MOOC sur edX. Vous pouvez même vous « certifier » à la fin si vous réussissez le QCM, moyennant 100$.

![](/2017/10/kubernetes_edx.png)

A l’issue de ces lectures, vous devriez donc avoir :

  * la connaissance des différents concepts de Kubernetes
  * un cluster Kubernetes opérationnel (une ou plusieurs machines, ou simplement un minikube en local)

Ce sont les prérequis pour la suite de cet article, même si je vais essayer de détailler tout ce qui va suivre.

## Plan de bataille

Je ne vais pas vous le cacher, si on veut tout faire soit même, ce n’est pas « trivial ». Mais en décomposant toutes les étapes, vous allez voir que c’est logique.

Pour faire tourner mon image Docker [zwindler/xwiki-tomcat8][3], j’ai besoin, sur mon cluster Kubernetes, des choses suivantes :

  * un **Deployment** qui exécute la partie PostgreSQL. Ce **Deployment** contiendra : 
      * un **ReplicaSet** avec une seule instance car on ne souhaite avoir qu’un seul **Pod** avec l’image postgresql officielle
      * Un **Service** de type **ClusterIP** pour lui permettre de communiquer avec le XWiki mais pas avec le monde extérieur
      * Un **PersistantVolumeClaim** et son **PersistentVolume** associé pour stocker les données de la base
      * Des **Secrets** pour permet de configurer les mots de passes de postgres et de l’utilisateur XWiki
  * un **Deployment** qui exécute la partie XWiki. Ce **Deployment** contiendra : 
      * un **ReplicaSet** avec une seule instance car on ne fait tourner qu’un seul **Pod** avec l’image zwindler/xwiki-tomcat8, car on n’utilise qu’un tomcat à la fois pour exécuter XWiki
      * Un Service de type **NodePort** (ou mieux si vous avez des LoadBalancers ou des Ingress à dispo.) qui permettra d’exposer le port interne au cluster Kubernetes vers le monde extérieur
      * Un **PersistantVolumeClaim** avec le **PersistentVolume** pour stocker les pièces jointes car mon image Docker utilise l’option filesystem_store pour éviter de surcharger la base pour les PJ
      * et aussi le **Secret** défini précédemment pour accéder à la BDD.

OK.

Voir ça posé dans une liste comme ça, ça peut faire peur.

Alors vous allez me dire : « c’est plus facile de lancer ton DockerCompose » ([car j’ai montré qu’avec DockerCompose on peut démarrer une instance XWiki en 2 ou 3 lignes de commandes](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/)). Mais au final, tout ce que j’ai écris ici peut être concaténé dans un seul et même fichier YAML et le résultat est aussi simple dans l’absolu.

## Créer les Secrets

Clairement, c’est un des gros points forts par rapport à la solution plus simple avec juste Docker / DockerCompose : la gestion des Secrets (et des configurations, dans une moindre mesure).

Ici, plutôt que d’avoir un mot de passe en clair dans mon fichier compose, le mot de passe est renseigné à part, soit via un fichier, soit via l’API. Et ces mots de passes ne pourront plus être consultés via la CLI, mais pourront être utilisés.

Pour créer un secret dans Kubernetes en CLI, il existe plusieurs méthodes. Soit on utilise la CLI directement depuis le prompt ou depuis un fichier plat (qui va se charger d’encoder le secret en base64 et de générer le YAML pour nous), soit on décide de créer le YAML nous-même. Je vous met les deux méthodes :

```
echo -n "xwikidb" > ./POSTGRES_USER.txt
echo -n "xwikipwd" > ./POSTGRES_PASSWORD.txt
kubectl create secret generic postgresql-xwiki-user-password --from-file=POSTGRES_USER.txt --from-file=POSTGRES_PASSWORD.txt
	secret "postgresql-xwiki-user-password" created

#ou 
cat > postgresql_xwiki_user_password.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-xwiki-user-password
type: Opaque
data:
  username: $(cat POSTGRES_USER.txt| base64 -w 0)
  password: $(cat POSTGRES_PASSWORD.txt| base64 -w 0)
EOF
```


Au final, pour un déploiement unitaire pour vous même, ça ne change pas grand-chose bien sûr. Vous avez renseigné en clair le mot de passe (ou en base64 mais c’est pareil) à un moment donné.

Cependant, dans le cadre d’un gros projet avec des développeurs qui poussent du code régulièrement d’un côté et des admins qui gèrent de l’autre les utilisateurs et les mots de passes, on peut permettre aux développeurs consommer les mots de passe sans jamais avoir à les connaitre (**et laisser trainer sur Gitlab, ou pire, Github !**).

```
kubectl describe secret postgresql-xwiki-user-password
	Name:           postgresql-xwiki-user-password
	Namespace:      default
	Labels:         <none>
	Annotations:
	Type:           Opaque
	
	Data
	====
	password:       8 bytes
	username:       7 bytes
```


## Créer les Persistent Volumes

Dans mon infrastructure, j’ai déjà un cluster GlusterFS. GlusterFS étant un SDS, il est particulièrement indiqué comme stockage persistant dans le cadre d’un cluster Kubernetes (comme Ceph, Cinder, S3 ou autre). Ces types de méthodes de stockage peuvent facilement se piloter par API et sont hautement disponibles.

Création de l’endpoint GlusterFS

```
cat > gluster-endpoints.yaml <<EOF
apiVersion: v1
kind: Endpoints
metadata:
  name: gluster-cluster
subsets:
- addresses:              
  - ip: 10.0.0.1
  ports:                  
  - port: 1
    protocol: TCP
- addresses:
  - ip: 10.0.0.2
  ports:
  - port: 1
protocol: TCP
EOF 

kubectl apply -f gluster-endpoints.yaml
   endpoints "gluster-cluster" created 

kubectl get endpoints gluster-cluster
	NAME		ENDPOINTS		AGE
	gluster-cluster 10.0.0.1:1,10.0.0.2:1	39s 


cat > gluster-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: gluster-cluster
spec:
  ports:
- port: 1
EOF

kubectl apply -f gluster-service.yaml
	service "gluster-cluster" created

kubectl get service gluster-cluster
	NAME              CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
	gluster-cluster   10.96.114.181   <none>        1/TCP     1m
```


La partie GlusterFS a été configurée côté Kubernetes. On peut maintenant s’atteler à la création des PV et PVC associés. D’abord la base de données :

```
cat > gluster-pv-xwiki-pg.yaml << EOF 

apiVersion: v1
kind: PersistentVolume
metadata:
  name: gluster-pv-xwiki-pg
spec:
  capacity:
    storage: 5Gi     
  accessModes:
  - ReadWriteMany    
  glusterfs:         
    endpoints: gluster-cluster 
    path: /xwiki-pg-storage
    readOnly: false
persistentVolumeReclaimPolicy: Retain 
EOF

kubectl create -f gluster-pv-xwiki-pg.yaml 
persistentvolume "gluster-pv-xwiki-pg" created 

cat > gluster-pvc-xwiki-pg.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gluster-pvc-xwiki-pg
spec:
  accessModes:
    - ReadWriteMany    
  resources:
    requests:
      storage: 5Gi
EOF

kubectl create -f gluster-pvc-xwiki-pg.yaml
	persistentvolumeclaim "gluster-pvc-xwiki-pg" created
```


Et maintenant l’application XWiki

```
cat > gluster-pv-xwiki-app.yaml << EOF 
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gluster-pv-xwiki-app
spec:
  capacity:
    storage: 5Gi     
  accessModes:
  - ReadWriteMany    
  glusterfs:         
    endpoints: gluster-cluster 
    path: /xwiki-app-storage
    readOnly: false
persistentVolumeReclaimPolicy: Retain 
EOF 

kubectl create -f gluster-pv-xwiki-app.yaml
 persistentvolume "gluster-pv-xwiki-app" created 

cat > gluster-pvc-xwiki-app.yaml << EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gluster-pvc-xwiki-app
spec:
  accessModes:
    - ReadWriteMany    
  resources:
    requests:
storage: 5Gi
EOF

kubectl create -f gluster-pvc-xwiki-app.yaml
	persistentvolumeclaim "gluster-pvc-xwiki-app" created
```


Dans le cadre d’un test, vous pouvez vous contenter de faire simplement appel à un partage NFS ou même à du stockage local (si vous n’avez qu’un worker) mais sachez que vous n’aurez pas le même niveau de résilience ni les même facilités d’administration.

Si vous voulez un exemple de **PersistentVolume** utilisant NFS, je vous conseille cet article qui traite d’un sujet peu plus complexe mais qui donne les étapes de base pour mettre en place le PV et PVC : [Créer un cluster PostgreSQL avec un seul et même Deployment en utilisant les StatefulSets][7].

## Créer le Deployment postgreSQL

Voilà, on a tous les prérequis ! Il ne reste plus qu’à créer dans un premier temps notre base de données, puis notre XWiki. Comme indiqué au début, le **Deployment** contiendra tous les éléments qu’on a créé plus tôt, dont les **Secrets** et le **Persistent Volume**. Il manquera aussi un **Service**, que nous verrons plus tard.

```
cat > xwiki-pg.yaml << EOF
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: xwiki-pg
  labels:
    app: xwiki-pg
    application: xwiki
spec:
  replicas: 1
  selector:
    matchLabels:
      app: xwiki-pg
      application: xwiki
  template:
    metadata:
      labels:
        app: xwiki-pg
        application: xwiki
      name: xwiki-pg
    spec:
      containers:
      - image: postgres:9.6
        name: xwiki-pg
        env:
        - name: POSTGRES_DB
          value: xwiki
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgresql-xwiki-user-password
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-xwiki-user-password
              key: password
        ports:
            - containerPort: 5432
              name: xwiki-pg
        volumeMounts:
            - name: xwiki-pg-storage
              mountPath: /var/lib/postgresql/data/pgdata
      volumes:
          - name: xwiki-pg-storage
            persistentVolumeClaim:
              claimName: gluster-pvc-xwiki-pg
EOF

kubectl create -f xwiki-pg.yaml
```


Normalement, un **Pod** devrait se créer et monter le disque Gluster, puis s’initialiser avec les variables d’environnement qu’on lui a donné.

A partir de là, on ne peut cependant pas accéder à la base de données car on a pas encore créé le Service associé au **Deployment**. Par défaut, on ne donne pas de type, c’est donc un **ClusterIP**. Pour « savoir » vers quoi le Service doit rediriger, on a ajouté un **Selector**, qui pointe sur le tag « app » avec la valeur « xwiki-pg » définie plus haut.

```
cat > xwiki-pg-svc.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: xwiki-pg-svc
  labels:
    app: xwiki-pg
spec:
  ports:
  - port: 5432
    protocol: TCP
  selector:
    app: xwiki-pg
EOF

kubectl create -f xwiki-pg-svc.yaml
	service "xwiki-pg-svc" created
```


## Créer le Deployment XWiki

Youhou ! Plus qu’un ! Ici pas de grosses différences, le principe est le même. On doit créer un **Deployment** puis un **Service**.

```
cat xwiki-tomcat.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: xwiki-app
  labels:
    app: xwiki-app
    application: xwiki
spec:
  replicas: 1
  selector:
    matchLabels:
      app: xwiki-app
      application: xwiki
  template:
    metadata:
      labels:
        app: xwiki-app
        application: xwiki
      name: xwiki-app
    spec:
      containers:
      - image: zwindler/xwiki-tomcat8
        name: xwiki-app
        env:
        - name: POSTGRES_INSTANCE
          value: xwiki-pg
        - name: POSTGRES_DB
          value: xwiki
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgresql-xwiki-user-password
              key: username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-xwiki-user-password
              key: password
        ports:
          - containerPort: 8080
            name: tomcat-port
        volumeMounts:
            - name: xwiki-app-storage
              mountPath: /usr/local/tomcat/work/xwiki
      volumes:
          - name: xwiki-app-storage
            persistentVolumeClaim:
              claimName: gluster-pvc-xwiki-app

kubectl apply -f xwiki-tomcat.yaml
	deployment "xwiki-app" created

cat xwiki-tomcat-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: xwiki-app-svc
  labels:
    apps: xwiki-app
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: tomcat-port
    protocol: TCP
  selector:
    app: xwiki-app


kubectl apply -f xwiki-tomcat-svc.yaml
service "xwiki-app-svc" created

```


## Est-ce que ça marche ?

```
kubectl get svc
NAME              CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
gluster-cluster   10.96.114.181    <none>        1/TCP            4h
kubernetes        10.96.0.1        <none>        443/TCP          10d
xwiki-app-svc     10.103.218.140   <nodes>       8080:31484/TCP   4m
xwiki-pg-svc      10.108.219.88    <none>        5432/TCP         16m
```


## Tout d’un coup

Chose promise chose due ! Je vous ai dit en début d’article que vous pouviez tout déployer en quelques lignes de commandes. Dans l’absolu, vous pourriez tout déployer via un seul fichier. Je préfère découpler la partie stockage (qui va dépendre du stockage que vous allez utiliser) et la partie secret du reste pour les raisons que j’ai énoncé plus haut. Voilà ce que ça donne :

On récupère les sources sur github

```
git clone https://github.com/zwindler/docker-xwiki
```


A adapter en fonction de votre contexte, à minima les adresses IP si vous avez du gluster, et carrément à réécrire si vous utilisez autre chose (NFS ou CEPH par exemple) :

```
kubectl apply -f docker-xwiki/kubernetes/gluster-endpoints-service.yaml
endpoints "gluster-cluster" created
service "gluster-cluster" created
```


On injecte ensuite les secrets. A vous de les changer comme on a vu plus haut.

```
kubectl apply -f docker-xwiki/kubernetes/postgresql_xwiki_user_password.yaml
secret "postgresql-xwiki-user-password" created
```


Et on fini par... tout le reste ! Là normalement il n’y a rien à changer à part éventuellement des ports, les seules « variables » dans ce déploiement étant le stockage et les mots de passes (qu’on vient de gérer).

```
kubectl apply -f docker-xwiki/kubernetes/xwiki-tomcat-pg-allinone.yaml
persistentvolume "gluster-pv-xwiki-pg" created
persistentvolume "gluster-pv-xwiki-app" created
deployment "xwiki-pg" created
persistentvolumeclaim "gluster-pvc-xwiki-pg" created
service "xwiki-pg-svc" created
deployment "xwiki-app" created
persistentvolumeclaim "gluster-pvc-xwiki-app" created
service "xwiki-app-svc" created
```


## Le mot de la fin

Voilà, avec ce tutoriel vous avez maintenant une vue détaillée, étape par étape, de ce qu’il faut mettre en place pour gérer « proprement » le déploiement d’une application java + postgreSQL via Kubernetes.

Clairement, c’est bien plus complexe qu’un simple Docker compose comme j’ai pu le présenté dans l’article sur ce sujet. Pour autant, il faut comparer ce qui est comparable, les deux installations n’ont rien à voir !

D’un côté, vous avez une application déployée sur un nœud docker simple (éventuellement avec Swarm maintenant que les deux sont compatibles).

De l’autre, vous avez une application qui est déployée sur un cluster de machines :  
- Si l’une tombe en panne, la haute disponibilité est gérée : pas seulement sur le runtime, mais aussi sur le stockage !  
- Vous pouvez segmenter votre cluster en namespaces, et donner des droits à certains namespace à certains utilisateurs avec un gestion fine des autorisations (RBAC)  
- Vous disposez d’un dashboard et d’une API pour automatiser tous les déploiements (via Jenkins par exemple). Si vous voulez faire une mise à jour ou besoin de modifier un paramètre, c’est une simple commande ou un fichier de conf à appliquer à nouveau.  
- Vous avez la possibilité de faire du scaling up/down, voire de l’autoscaling.  
- ...

La liste est longue ! En bref, vous passez d’une bidouille à la production.

## Sources additionnelles

* docs.openshift.org/latest/install\_config/storage\_examples/gluster_example.html (lien mort, pas dispo sur Internet Archive)
* [coderjourney.com/using-kubernetes-persistent-volumes/](https://coderjourney.com/using-kubernetes-persistent-volumes/)
* [www.xenonstack.com/blog/how-to-deploy-postgresql-on-kubernetes](https://www.xenonstack.com/blog/how-to-deploy-postgresql-on-kubernetes)

 [1]: http://www.xwiki.org/xwiki/bin/view/Main/WebHome
 [3]: https://hub.docker.com/r/zwindler/xwiki-tomcat8/
 [5]: https://www.edx.org/course/introduction-kubernetes-linuxfoundationx-lfs158x
 [7]: http://blog.kubernetes.io/2017/02/postgresql-clusters-kubernetes-statefulsets.html
