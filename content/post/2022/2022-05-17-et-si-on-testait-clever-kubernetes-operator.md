---
title: Et si on testait le Clever Operator pour Kubernetes ?
authors:
  - zwindler
type: post
date: 2022-05-17T10:00:00+00:00
excerpt: "Test de Clever Operator, un opérateur pour piloter des ressources dans Clever Cloud depuis Kubernetes"
url: /2022/05/17/et-si-on-testait-clever-kubernetes-operator/
image: /2022/05/clever-trott.jpg
categories:
  - Cloud
tags:
  - Clever
  - Clever Cloud
  - Operator
  - Kubernetes
  - DBaaS
  - PaaS

---
## Clever Operator

Il y a quelques mois, je suis tombé sur cet article de Clever Cloud qui disait avoir [annonçait la sortie de l'Operator pour Kubernetes](https://www.clever-cloud.com/fr/blog/fonctionnalites/2022/03/16/clever-operator/).

> Nous avons commencé à travailler sur le Clever Operator suite aux retours de certains de nos clients utilisant k8s ou Openshift qui n’étaient pas vraiment satisfaits des solutions de gestion de base de données fournies par ces plateformes.

C'est pas un secret, j'ai beaucoup râlé sur les gens qui disent que Kubernetes c'est compliqué et/ou que ça apporte plus de problèmes que ça n'en résout (cf https://blog.zwindler.fr/2019/09/03/concerning-kubernetes-combien-de-problemes-ces-stacks-ont-generes/). On en a notamment parle avec Quentin ADAM ;-).

Mais ce que je ne disais pas clairement à cette époque, c'est que Kubernetes, c'est quand même plus simple quand il s'agit d'autonomiser les devs sur des workloads stateless. 

Ou alors du stateful, mais pas trop violent : genre stockage de fichiers (Prometheus par exemple), voire fichiers partagés (avec un FS distribué, partagé entre plusieurs apps ou instances d'une même app).

Par contre, les bases de données, là, on rigole tout de suite beaucoup moins... 

Attention, je ne dis pas que c'est impossible. Plein de gens le font, en prod (moi compris). Mais c'est tout de suite un autre niveau de complexité, car il faut gérer le cycle de vie de la base de données, les mises à jours, les pertes de noeuds proprement, etc.

Pour faciliter ça, il existe les "Opérateurs" dans Kubernetes, qui ont pour but d'ajouter toute une logique fonctionnelle pour gérer ça (comme celui pour [MongoDB dont je parle dans cet article](https://blog.zwindler.fr/2020/09/28/mes-bases-mongodb-dans-kubernetes/)), mais c'est pas encore parfait.

Ajoutez à cela le fait que DBA, c'est un job "à part", avec des compétences bien spécifiques et qui nécessite vraiment de savoir ce qu'on fait. 

Du coup... j'aurais pu dire (en moins classe) :

> Les DBs dans Kube, c'est ch**nt. Ca serait cool si quelqu'un dont c'est l'expertise pouvait gérer ça pour moi, en dehors de Kube.

Qui a dit "Clever Cloud" ?

## Clever Operator

Ok, admettons qu'on ait un Kubernetes fonctionnel. On va plugger Clever Cloud dessus pour voir ce qu'on peut faire. Le billet sur le blog de Clever indique 2 manières de déployer l'operator (plot twist, il y en a une 3ème qui est mieux).

La première consiste à utiliser [operatorhub.io](https://operatorhub.io/), un site communautaire pour partager des opérateurs Kubernetes.

Pour utiliser cette méthode, il faut déployer le `operator-lifecycle-manager`, lui-même un opérateur, dans notre kubernetes. J'ai essayé et j'ai plein de critiques à faire sur ce tool.

Déjà, la doc nous demande de faire un `curl | bash` (déjà une hérésie en soit), ensuite, il se déploie sans prévenir sur mon contexte Kubernetes par défaut. Enfin, c'est pas bien clair ce qu'il faut faire pour le customiser (notamment pour ajouter nos credentials). 

J'ai essayé 1h, j'ai laissé tomber, mais si vous avez l'habitude d'utiliser Operatorhub.io vous aurez peut être des infos que je n'ai pas.

La seconde méthode proposée est de déployer (ou de builder) soit même le container Docker dans notre cluster Kubernetes.

> Vous pouvez le built à partir du code source sur Github ou utiliser notre image docker sur Docker Hub.
> Puis, configurez le. Ça se résume à paramétrer les variables d’environnement CLEVER_OPERATOR_*. Par exemple, vous devez créer un token pour vous connecter à l’API.

Je suis un poil sceptique sur le "ça se résume à" 😏.

Quand on va voir le code du clever operator ([ici](https://github.com/CleverCloud/clever-operator/tree/main/deployments/kubernetes/v1.21.0)), on se rend tout de suite compte qu'il va falloir déployer **beaucoup** de ressources Kube et pas juste un container (~650 lignes de YAML).

En même temps c'est logique, il y a le fichier du `Deployment`, des `Roles`, plusieurs définitions de `CRDs`, bref...

## DIY

Edit du 24/05 : depuis la rédaction de l'article, j'ai proposé une PR à Florentin (le dev de la feature chez Clever) pour ajouter une Helm Chart. Le principe est le même, on va devoir renseigner des valeurs dans values.yaml donc vous pouvez quand même dérouler l'article.

```console
cd deployments/kubernetes/helm
helm install clever-operator -n clever-operator --create-namespace -f values.yaml .
```

Du coup, j'ai déjà spoilé la solution (qui est d'ailleurs mise en avant dans le README.md du [dépot Github.com](https://github.com/CleverCloud/clever-operator/blob/main/deployments/kubernetes/v1.21.0/10-custom-resource-definition.yaml)). On va déployer le YAML à la main.

On installe les `CRDs` :

```console
kubectl apply -f https://raw.githubusercontent.com/CleverCloud/clever-operator/main/deployments/kubernetes/v1.21.0/10-custom-resource-definition.yaml
customresourcedefinition.apiextensions.k8s.io/postgresqls.api.clever-cloud.com configured
customresourcedefinition.apiextensions.k8s.io/redis.api.clever-cloud.com configured
customresourcedefinition.apiextensions.k8s.io/mysqls.api.clever-cloud.com configured
customresourcedefinition.apiextensions.k8s.io/mongodbs.api.clever-cloud.com configured
customresourcedefinition.apiextensions.k8s.io/pulsars.api.clever-cloud.com configured
customresourcedefinition.apiextensions.k8s.io/configproviders.api.clever-cloud.com configured
customresourcedefinition.apiextensions.k8s.io/elasticsearches.api.clever-cloud.com configured

kubectl api-resources --api-group=api.clever-cloud.com
  NAME          SHORTNAMES   APIVERSION                     NAMESPACED   KIND
  mongodbs      mo           api.clever-cloud.com/v1        true         MongoDb
  mysqls        my           api.clever-cloud.com/v1        true         MySql
  postgresqls   pg           api.clever-cloud.com/v1        true         PostgreSql
  pulsars       pulse,pul    api.clever-cloud.com/v1beta1   true         Pulsar
  redis         r            api.clever-cloud.com/v1        true         Redis

```

Si je peux me permettre ce commentaire, je trouve ça audacieux, ces shortnames 😱... Attention aux collisions avec d'autres CRDs 🤔.

Et ensuite on récupère et on va modifier le fichier du `Deployment`

```bash
curl -LO https://raw.githubusercontent.com/CleverCloud/clever-operator/main/deployments/kubernetes/v1.21.0/20-deployment.yaml
```

## Préparer la configuration

Bon, à un moment donné, il va bien falloir que je connecte l'API clever cloud avec mon operator, notamment en renseignant les fameuses variables d’environnement `CLEVER_OPERATOR_*` dont parle l'article.

Si on regarde la tête de notre fichier `20-deployment.yaml`, on remarque qu'il existe une ressource `ConfigMap` prévue pour renseigner les credentials (ligne 100).

```
---
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: clever-operator-system
  name: clever-operator-configuration
data:
  config.toml: |
    [api]
    token = ""
    secret = ""
    consumerKey = ""
    consumerSecret = ""
```

Si vous êtes curieux (c'est mon cas), ce volume est ensuite appelé dans le `Deployment`

```
      volumes:
      - name: config
        configMap:
          name: clever-operator-configuration
          items:
          - key: "config.toml"
            path: "config.toml"
```

Puis monté dans la spec du template de container

```
          volumeMounts:
          - name: config
            mountPath: "/etc/clever-operator"
            readOnly: true
```

Note : Idéalement, on voudra éviter de faire ça, dans la vraie vie. Les `ConfigMaps` (comme les `Secrets`) dans Kubernetes sont lisibles par beaucoup de monde (la seule différence pour les `Secrets`, c'est que les chaines de caractères sont *base64ifiée*. Si si, c'est dans le dico, "base64ifier") et donc absolument pas adaptés pour la gestion de *secrets*. 
On pourrait aussi ajouter ces secrets comme variables d'environnement dans le `Deployment` (comme proposé dans la méthode 2 par l'article), mais c'est pire (on peut en débattre) encore niveau sécu.
Idéalement, il faudra injecter ces valeurs avec un gestionnaire de secret tier, comme [Vault par exemple](/2020/08/31/gerez-vos-secrets-kubernetes-dans-vault).

## Mais où on les trouve, ces valeurs à renseigner ?

Alors je n'avais jamais utilisé Clever Cloud avant, donc ça n'était pas super évident pour moi 😅.

On va d'abord devoir créer une **organisation** et récupérer son ID (en haut à droite de l'interface). Elle a la forme `orga_xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx`

Pour la partie **consumerKey** et **consumerSecret**, j'ai trouvé avec la documentation officielle. Dans mon organisation côté UI de Clever Cloud, on peut cliquer sur "Create... / an oauth consumer"

![](/2022/05/oauth_consumer.png)

Pour la partie **token** et **secret**, je n'ai pas trouvé comment en créer un en console web et je n'ai pas trouvé dans la doc. 

En bidouillant un peu (monkey testing), j'ai trouvé qu'on pouvait en récupérer en utilisant la [CLI de clever cloud](https://www.clever-cloud.com/doc/getting-started/cli/)

```console
curl -fsSL https://clever-tools.clever-cloud.com/gpg/cc-nexus-deb.public.gpg.key | gpg --dearmor -o /usr/share/keyrings/cc-nexus-deb.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/cc-nexus-deb.gpg] https://nexus.clever-cloud.com/repository/deb stable main" | tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install clever-tools

clever login
Opening https://console.clever-cloud.com/cli-oauth?cli_version=2.9.1&cli_token=... in your browser to log you in…
We're still waiting for the login process (in your browser) to be completed…
Login successful as Denis GERMAIN <...>
```

Une fenêtre de navigateur s'ouvre pour se loguer et magie magie, on a un **token** et un **secret**

```bash
CLEVER_TOKEN=aaa
CLEVER_SECRET=aaa
```

Tadaa !

## Deployer l'opérateur

> Tout est prêt, allons-y.

On peut apply le manifest et déployer le deployment

```console
kubectl apply -f 20-deployment.yaml
namespace/clever-operator-system created
serviceaccount/clever-operator created
clusterrole.rbac.authorization.k8s.io/system:clever-operator created
clusterrolebinding.rbac.authorization.k8s.io/system:clever-operator created
poddisruptionbudget.policy/clever-operator created
networkpolicy.networking.k8s.io/clever-operator created
configmap/clever-operator-configuration created
deployment.apps/clever-operator created
```

~~Note: la dernière version de l'image Docker du Clever Operator a "un bug" du à une version trop ancienne de la GLIBC. Florentin de chez Clever est en discussion avec Redhat pour fix ça (`GLIBC_2.29' not found).~~

~~Il "suffit" de prendre une version plus ancienne de l'image et ça remarche, en attendant un fix définitif.~~ (FIXED)

## On teste tout ça

Normalement, là on est bons.

Dans la liste des bases (des add-ons dans la terminology Clever Cloud) supportées par ce operator, il y a donc :
- ElasticSearch
- MongoDb
- MySql
- PostgreSql
- Pulsar
- Redis

La documentation des CRDs [est disponible ici](https://github.com/CleverCloud/clever-operator/blob/main/docs/40-custom-resources.md) et elle est bien faite.

Je ferai des tests plus poussés (déployer une vraie application) plus tard, mais déjà pour tester, j'ai pu lancer un mysql managée;

```
cat mysql.yml
---
apiVersion: api.clever-cloud.com/v1
kind: MySql
metadata:
  namespace: default
  name: mysql
spec:
  organisation: orga_xxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx
  options:
    version: 80
    encryption: false
  instance:
    region: par
    plan: dev

kubectl apply -f mysql.yml
mysql.api.clever-cloud.com/mysql created

kubectl get my
NAME    AGE
mysql   14s
```

![](/2022/05/db_clever.png)

L'opérateur a également la gentillesse de nous créer un `Secret` avec les variables de connexion. C'est donc hyper simple de relier notre app à notre nouvelle DB :

```console
kubectl get secret mysql-secrets -o yaml
apiVersion: v1
data:
  MYSQL_ADDON_DB: aaa=
  MYSQL_ADDON_HOST: aaa==
  MYSQL_ADDON_PASSWORD: aaa=
  MYSQL_ADDON_PORT: aaa==
  MYSQL_ADDON_URI: aaa==
  MYSQL_ADDON_USER: aaa==
  MYSQL_ADDON_VERSION: aaa
kind: Secret
```

```
kubectl run -it mysqlclient --image mysql /bin/bash
root@mysqlclient:/# mysql aaa --host aaa-mysql.services.clever-cloud.com --user aaa -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
[...]
mysql> 
```

## Conclusion

J'ai été très content de tester cet operator, et surtout de pouvoir échanger avec son développeur, Florentin DUBOIS, qui m'a aidé et à qui j'ai pu remonter quelques petits défauts de jeunesse de l'outil.

L'intégration entre Clever et Kubernetes marche vraiment bien, c'est fluide. La documentation des `CRDs` est bien faite, on est pas perdus. Enfin, la génération à la volée du `Secret` contenant les informations de connexion directement dans Kubernetes est vraiment une fonctionnalité bien pratique, puisqu'on voudra souvent monter directement les informations qu'il contient dans un `Pod` du même namespace.

~~De mon point de vue, il manque une Chart Helm, pour rentre le déploiement simple et flexible de l'opérateur, et sans trop spoiler ça devrait arriver bientôt ;-).~~ (FIXED)

A moi le pouvoir tout puissant des bases de données que je n'ai pas à gérer !
