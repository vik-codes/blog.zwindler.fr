---
title: Exposer des applications containerisées Kubernetes (nginx Ingress Controller)
authors:
  - zwindler
type: post
date: 2018-03-06T12:45:47+00:00
url: /2018/03/06/exposer-des-applications-kubernetes-en-dehors-des-cloud-providers-nginx-ingress-controller/
image: /2018/02/kubernetes_nginx.png
categories:
  - Logiciel
  - Système
  - Virtualisation
tags:
  - container
  - Docker
  - HAproxy
  - Ingress
  - Ingress Controller
  - k8s
  - Kubernetes
  - LoadBalancer
  - nginx
  - NodePort

---
## Ingress et Ingress Controller versus Baremetal

Autant le dire tout de suite, cet article s’adresse surtout aux admins qui font du Kubernetes (K8s pour les intimes) et en plus qui font tout eux même. Mais comme je suis sympa j’explique tout et j’ai mis des schémas si vous êtes curieux ;-).

Je vous plante le décors : [vous avez suivi un de mes tutos sur Kubernetes](/recherche/?keyword=Kubernetes) et vous avez maintenant un cluster opérationnel en dehors des gros cloud providers (Amazon, Google, ...) et de leurs solutions clés en main (sur vos propres VMs et/ou serveurs physiques). Vous êtes super contents et il y a de quoi.

Seulement voilà, maintenant que vous pouvez spawner des containers à tire larigot, vous voulez pouvoir y accéder depuis l’Internet.

## Mais là, comment faire ?

Le premier problème que vous risquez d’avoir est que les applications que vous déployez dans Kubernetes ne sont de base accessibles que DANS Kubernetes.

> On va être très très vite limité, niveau usecases.

Pour accéder à un container (ou faire discuter 2 containers comme un serveur web et une base de données), on passe par l’intermédiaire d’un objet appelé **Service**. C’est cet objet qui permet le service discovery, le scaling aisé de nos applications et la résolution de nom au sein du cluster.

Cependant, hors du cluster, pas de résolution de nom et/ou d’accès aux ressources par ce biais. Vous allez donc devoir passer par un DNS externe pour spécifier aux clients où sont vos applications et trouver un moyen de différencier quelle requête externe doit aboutir dans quelle container.

## Accéder aux ressources

Le premier problème est donc de réussir à accéder à notre service. S’il est possible de créer des **Services** (les points d’entrées de nos containers) de type **LoadBalancer** sur AWS, Azure et GCP, qui ont l’avantage de permettre un accès direct au service depuis Internet (magie !), le mieux que l’on puisse faire par défaut sur un cluster Baremetal, c’est un **Service** de type **NodePort**.

Si vous n’êtes pas chez un cloud provider comme nous l’avons dit au départ, vous allez vite vous rendre compte qu’il n’est pas trivial de présenter un container sur HTTP:80 ou HTTPS:443. Car par défaut, les **Services NodePort** exposent nos container sur un port aléatoire compris entre 30000 et _3X000-je-sais-pas-combien_ (mate la précision) sur tous les nœuds du clusters.

Il y a deux choses importantes dans cette dernière phrase :

  * D’abord, on va se retrouver avec des URLs du type : `http://@IP_node:32251` pour accéder à un serveur web depuis l’extérieur. Pas glop.
  * Ensuite, pour un **Service** de type **NodePort** donné, le port alloué l’est sur TOUS les membres du cluster, que le container tourne dessus ou pas. Ça veut dire que _peu importe quel nœud Kubernetes on interroge_, le 32251 répondra TOUJOURS sur le même container (les requêtes sont forwardé au bon nœud de manière transparente). Ça veut aussi dire qu’il n’y aura qu’un seul service qui aura le privilège d’utiliser le 32251 et aucun autre **Service** ne pourra le réserver.

![](/2018/02/Kubernetes1-1.png)

Clairement, c’est tout sauf idéal. On se retrouve donc à différencier les applications simplement avec les numéros des ports qu’on accède.

## Le DNS

Et c’est pas fini...

Si on prend un cas simple : un site web à exposer sur Internet, on va souvent vouloir relier une URL humainement compréhensible au container qui gère ce site. Cependant cette notion n’a pas vraiment de sens avec Kubernetes.

Vous ne savez pas _a priori_ **où** va être instancié votre container dans le cluster (i.e. sur quelle machine et donc sur quelle IP). Ça sera un des nœuds du cluster, mais lequel ? D’autant que le **Pod** bouge d’un nœud à l’autre au gré de la vie de l’application (_drain_ du node pour maintenance ou incident). Difficile donc de donner avec certitude un enregistrement DNS fiable dans le temps.

Alors bien sûr, vous pouvez toujours fixer en dur l’adresse IP d’un des nœuds Kubernetes dans un enregistrement DNS mais cette méthode trouve très vite sa limite : le moindre arrêt du serveur cause la perte de l’accès à l’application, qui pourtant a probablement été redémarrée sur un nœud du cluster.

![](/2018/02/Kubernetes2.png)

> Vous me pardonnerez ce « comic » en mode Draw.io. On s’amuse comme on peut ;-)

A quoi ça sert d’avoir un cluster dans ce cas là ?

Vous aurez peut être alors l’idée d’utiliser un moyen automatique ([genre ce script qui utilise Dynhost, au hasard](/2014/09/22/mise-a-jour-de-votre-dns-chez-ovh-avec-dynhost/)) pour mettre à jour le DNS dès que l’application change de nœud. Mais c’est clairement de la bidouille et on se retrouvera avec pleins d’utilisateurs dont les caches DNS ne sont pas à jour.

## La méthode simple

On peut quand même bosser avec ce qu’on a et présenter à nos gentils utilisateurs des URLs user-friendly sans trop de difficultés, dans la majorité des cas.

La première chose qu’on peut faire c’est simplement mettre en face de notre cluster Kubernetes un bête reverse proxy et/ou répartiteur de charge. Après tout, c’est ni plus ni moins ce que font AWS et autre avec leur implémentation du **Service** de type **Loadbalancer**.

L’ensemble des requêtes HTTP(S) sont donc dirigées vers le reverse proxy, qui se charge de masquer la complexité de l’URL (l’aiguillage via des ports chelous et le maintiens à jour de l’ensemble des nœud du cluster qu’on arrive à contacter) à l’utilisateur final.

![](/2018/02/Kubernetes3.png)

Personnellement, **pour mes projets perso**, ça m’ennuie d’avoir un composant externe au cluster K8s pour faire ça. J’ai déjà investi dans un cluster pour rendre mes applications hautement disponibles (ce qui est déjà overkill), je ne vais pas en plus :

  * soit ajouter un SPOF en ajoutant une seule machine pour faire mon reverse proxy
  * soit ajouter un cluster de machines rien que pour le reverse proxy

## Et les Ingress dans tout ça ?

Donc on l’a vu, tout ça c’est pas super propre et on ajoute potentiellement un SPOF, mais ça « marche ». Mais on peut faire mieux :)

Si vous manipulez un peu Kubernetes, vous avez donc peut être vu qu’il existe un autre type d’objet qui s’appelle les **Ingress** et les **Ingress Controllers**.

Pour ceux qui n’ont pas eu le temps de potasser, un **Ingress** est une règle qui permet de relier une URL à un **Service** et un **Ingress Controller** est un composant qui permet de piloter un reverse-proxy pour implémenter cette règle. C’est _LA_ méthode propre pour traduire une URL provenant d’un client en requête interne dans le cluster K8s pour atteindre le bon service.

L’**Ingress Controller** le plus utilisé est probablement celui pour nginx, mais il existe des **Ingress Controllers** pour [traefik][6] ou ha-proxy (ou autre) qui ont été développés et qui sont plus ou moins aboutis.

## Helm

Helm c’est super. [J’en ai parlé dans un autre article il n’y a pas longtemps](/2018/02/06/se-simplifier-kubernetes-helm-charts/), c’est un genre de gestionnaire d’application pour Kubernetes et ça simplifie grandement son utilisation. Mais il faut être honnête, ce n’est pas toujours une super idée...

Déjà, la documentation sur [la page d’accueil du Chart est super light][8]. Si vous ne trouvez pas d’infos sur comment le déployer, c’est normal, c’est parce qu’il faut aller dans le dossier « deploy » du dépôt pour [trouver la doc d’installation][9].

Du coup, confiant, j’y suis allé avant d’avoir trouvé cette page, et je me suis pris ma première claque ;-)

```
helm install stable/nginx-ingress --name nginx-ingress
NAME: nginx-ingress
LAST DEPLOYED: Sun Feb 25 16:24:11 2018
NAMESPACE: default
STATUS: DEPLOYED
[...]
NOTES:
The nginx-ingress controller has been installed.
```


Oh cool, ça marché déjà ?

```
kubectl get pods
NAME READY STATUS RESTARTS AGE
nginx-ingress-controller-7c6f79d45c-jwqkp 0/1 CrashLoopBackOff 14 47m
nginx-ingress-default-backend-6664bc64c9-2zpg4 1/1 Running 0 47m
```


Ah ben non en fait parce que je suis en RBAC (K8s > 1.7.0) ! Il faut créer des autorisations et un compte de service pour l’**Ingress Controller**.

```
kubectl logs nginx-ingress-controller-7c6f79d45c-jwqkp

-------------------------------------------------------------------------------
NGINX Ingress controller
Release: 0.10.2
Build: git-fd7253a
Repository: https://github.com/kubernetes/ingress-nginx
-------------------------------------------------------------------------------

I0225 16:11:13.374547 7 flags.go:159] Watching for ingress class: nginx
I0225 16:11:13.376659 7 main.go:181] Creating API client for https://10.233.0.1:443
I0225 16:11:13.438774 7 main.go:193] Running in Kubernetes Cluster version v. (v1.9.0+coreos.0) - git (clean) commit 1b69a2a6c01194421b0aa17747a8c1a81738a8dd - platform linux/amd64
F0225 16:11:13.442654 7 main.go:80] &#x2716; It seems the cluster it is running with Authorization enabled (like RBAC) and there is no permissions for the ingress controller. Please check the configuration
```


Ok, pas grave... On supprime et on recommence !

```
helm list
  NAME REVISION UPDATED STATUS CHART NAMESPACE
  nginx-ingress 1 Sun Feb 25 16:24:11 2018 DEPLOYED nginx-ingress-0.9.1 default

helm delete nginx-ingress
  release "nginx-ingress" deleted

helm install stable/nginx-ingress --name nginx-ingress --set rbac.create=true

[...]
```


Bon, ne vous fatiguez pas. Ça aura l’air de marcher mais en fait, le _nginx-ingress-controller_ se base sur un **Service** de type... **Loadbalancer** ! Si vous n’êtes pas sur AWS, GCE ou Azure, votre **Service** restera indéfiniment à l’état _Pending_ en attente d’une IP publique ;-)

```
kubectl get svc
  NAME TYPE CLUSTER-IP EXTERNAL-IP PORT(S) AGE
  nginx-ingress-controller LoadBalancer 10.233.52.122  80:30215/TCP,443:31438/TCP 41m
  nginx-ingress-default-backend ClusterIP 10.233.29.8  80/TCP 41m
```


## Donc on laisse tomber Helm pour cette fois

En réalité, le mieux c’est de repartir sur le projet nginx Ingress Controller, qui donne (pour qui trouve la documentation) la bonne marche à suivre pour instancier rapidement son **Ingress Controller**.

* [github.com/kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx)
* [github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md#bare-metal](https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md#bare-metal) (lien mis à jour le 08/10/2018)

Partie à exécuter dans tous les cas

```
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/namespace.yaml \
| kubectl apply -f -

curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/default-backend.yaml \
| kubectl apply -f -

curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/configmap.yaml \
| kubectl apply -f -

curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/tcp-services-configmap.yaml \
| kubectl apply -f -

curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/udp-services-configmap.yaml \
| kubectl apply -f -
```


Partie spécifique à ajouter pour déployer l’**Ingress Controller** dans un environnement de type RBAC (K8s >= 1.7)

```
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/rbac.yaml \
| kubectl apply -f -

curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/with-rbac.yaml \
| kubectl apply -f -
```


Partie spécifique à ajouter en dernier, dans le cas où on est sur un cluster baremetal (i.e. en dehors des cloud providers).

```
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/provider/baremetal/service-nodeport.yaml \
| kubectl apply -f -
```


## OK, on a quoi maintenant ?

Et bien, c’est pas encore fini malheureusement... En fait, tel quel, le dernier fichier YAML qu’on a créé nous créé un service de type NodePort...

Oui vous l’avez compris : retour à la case départ ! Nous avons un composant reverse proxy intégré à K8s, mais qui est en écoute sur un port 3XXXX au lieu du 80, et 3YYYY au lieu du 443. Là encore, on aurait pas du tout ce problème si on était chez AWS, car un service de type Loadbalancer (avec une IP publique) aurait été créé pour nous.

Rassurez vous, il y a des solutions, moyennant un peu de bidouille. J’en ai trouvé 2 dans notre cas.

  * [blog.will3942.com/nginx-kubernetes-bare-metal][11]
  * <a href="https://medium.com/@olegsmetanin/how-to-setup-baremetal-kubernetes-cluster-with-kubespray-and-deploy-ingress-controller-with-170cdb5ac50d>

Pour faire simple, la première nécessite juste de modifier unfichier de configuration de Kubernetes pour autoriser le composant **NodePort** à utiliser des ports en dessous de la limite arbitraire des 30000. Je ne suis pas fan du tout de cette solution mais elle « fonctionne » donc je vous laisse juger.

En revanche, je trouve la seconde bien plus élégante quoique peut être un peu moins flexible. On peut modifier le **Service** de l’**Ingress Controller** en y listant toutes les adresses IPs de tous vos serveurs K8s. Ce n’est pas super confortable dans le cas où ils changent souvent, mais ça à l’effet qu’on recherche, à savoir ouvrir les ports 80 et 443 et rediriger l’ensemble des requêtes HTTP vers les **Ingress**.

La modification à réaliser se situe au niveau du champ **externalIPs** :

```
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/cb876766897806ed60b1f2f36564d5f3af8a18c8/deploy/provider/baremetal/service-nodeport.yaml -o ingress-nginx-service-nodeport.yaml

vi ingress-nginx-service-nodeport.yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    protocol: TCP
  externalIPs:
    - 10.0.0.1
    - 10.0.0.2
    - 10.0.0.3
  selector:
    app: ingress-nginx

kubectl apply -f ingress-nginx-service-nodeport.yaml
```


Normalement après application de la modification vous devriez avoir la joie (oui oui, carrément) de voir apparaitre sur tous les serveurs (que vous aurez listés) les ports 80 et 443 en écoute !!

```
ss -lnt 
LISTEN      0      128    8.8.8.8:80                            *:*
LISTEN      0      128    8.8.8.8:443                           *:*
```


## Super, et maintenant c’est bon, mon container nginx est accessible ?

Ah ben non, toujours pas. On a configuré l’**Ingress Controller**, mais ça fait un moment qu’on parle plus des **Ingress**...

Comme je l’ai dis plus haut, les **Ingress** sont donc les règles de notre reverse proxy, permettant de mapper les URLs entrant dans le cluster sur les ports 80 et 443 (ou autre si on en définit d’autres) vers les **Services** définis dans le K8s.

Heureusement c’est partie est assez simple à configurer. Voici l’exemple minimaliste d’une application dont le **Service** _toto-app-svc_ écoute sur le port 8080 à l’intérieur du cluster Kubernetes. Ce service est maintenant accessible pour toute requête HTTP aboutissant sur un des noeuds du cluster et accédé avec l’URL toto.zwindler.fr.

```
cat nginx-ingress.yaml

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: nginx-ingress
spec:
  rules:
  - host: toto.zwindler.fr
    http:
      paths:
        - path: /
          backend:
            serviceName: toto-app-svc
            servicePort: 8080
```


Point intéressant à noter, il n’est plus nécessaire de faire du **NodePort** maintenant, on peut se contenter des **ClusterIP** par défaut. En effet, l’**Ingress Controller** étant interne au cluster K8s, il sait résoudre les Services sans passer par un port crado en 30000. Autant ne plus les exposer donc et bannir les **NodePorts** à présent !

Bon vous avez vu ? Cette dernière étape n’est pas la plus dure qu’on ait fait !

Et maintenant, à vos **Ingress** !

 [6]: https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-ingress/
 [8]: https://github.com/kubernetes/ingress-nginx
 [9]: https://github.com/kubernetes/ingress-nginx/tree/master/deploy
 [11]: https://medium.com/@olegsmetanin/how-to-setup-baremetal-kubernetes-cluster-with-kubespray-and-deploy-ingress-controller-with-170cdb5ac50d
