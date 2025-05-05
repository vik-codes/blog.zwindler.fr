---
title: 'Harbor : la registry Docker open source de VMware – part 2'
authors:
  - zwindler
type: post
date: 2018-06-26T11:45:04+00:00
url: /2018/06/26/decouverte-de-harbor-la-registry-docker-open-source-de-vmware/
image: /2017/10/harbor.png
categories:
  - systeme
  - Virtualisation
tags:
  - Docker
  - Harbor
  - Open Source
  - registry
  - VMware

---
## Harbor, la registry Docker de VMware

Il y a quelques mois, j’avais écris un article à propos d’une bonne surprise de la part de VMware : Harbor. Pour ceux qui n’ont pas lu mon article sur le sujet, j’ai développé dans la première partie ce qu’était Harbor et ce que cette solution apporte par rapport aux autres outils du marché, puis j’ai expliqué pas à pas comment l’installer et la configurer ([vous pouvez vous rattraper ici](/2018/02/27/harbor-la-docker-registry-dentreprise-open-source-de-vmware-part-1/)).

Rapidement, Harbor est un des produits open sourcé par VMware. C’est un serveur permettant de stocker « on premise » ou dans le cloud des images Docker, au même titre que le produit historiquement appelé Docker Registry (maintenant _Docker Distribution_), mais avec des fonctionnalités supplémentaires, notamment :

  * Gestion de la sécurités, des comptes, rôles, habilitation (RBAC)
  * Réplication des images entre plusieurs instances de Harbor
  * Portail web
  * Logging de toutes les opérations à des fins d’audit
  * API RESTful
  * Scan de vulnérabilité intégré
  * Nettoyage automatique des images inutiles (garbage collection)
  * Intégration native avec Notary pour la signature des images

Dans cette deuxième partie, j’ai voulu explorer un peu plus l’utilisation et l’administration de la plateforme que nous venons d’installer.

## Administration de base

Dans l’article précédent, on a installé Harbor à l’aide [d’un Docker Compose et d’Ansible][2] pour faciliter la récupération de certains prérequis et la configuration des différents composants.

### Démarrer/arrêter Harbor

Du coup, comme tout est configuré avec docker compose, l’arrêt et le redémarrage de la plateforme se limite à un simple docker-compose up ou down.

```
docker-compose up
[...]
docker-compose down
    Stopping nginx ... done
    Stopping harbor-jobservice ... done
    Stopping harbor-ui ... done
    Stopping harbor-db ... done
    Stopping registry ... done
    Stopping harbor-adminserver ... done
    Stopping harbor-log ... done
    WARNING: Found orphan containers (notary-server, notary-signer, notary-db) for this project. If you removed or renamed this service in your compose file, you can run this command with the --remove-orphans flag to clean it up.
    Removing nginx ... done
    Removing harbor-jobservice ... done
    Removing harbor-ui ... done
    Removing harbor-db ... done
    Removing registry ... done
    Removing harbor-adminserver ... done
    Removing harbor-log ... done
    Removing network harbor_harbor
```


### Supprimer / Réinstaller Harbor

Contrairement à ce qu’on pourrait penser naïvement, un simple **docker-compose down** ne suffit pas. Si les containers sont bien supprimé (cf. le « Removing... » pour chaque composants plus haut), il reste encore les fichiers de configurations et les données des différents containers, toujours présents sur disques et persistés à l’aide de **volumes Docker**.

Il est nécessaire de supprimer ces fichiers créés par l’installation précédente, notamment le contenu de **common/config** et le fichier **secretkey**. Par défaut, l'emplacement de ces fichiers est configuré par le playbook Ansible que je vous ai proposé. **common/config** est par défaut dans **/usr/local/harbor**, et la **secretkey** dans dans **/data** (configurable dans le fichier _/usr/local/harhor/harbor.cfg_).

```
cd /usr/local/harbor
ll common/config/
    total 0
    drwxr-xr-x 2 root root 16 20 oct. 11:38 adminserver
    drwxr-xr-x 2 root root 16 20 oct. 11:38 db
    drwxr-xr-x 2 root root 31 20 oct. 11:38 jobservice
    drwxr-xr-x 9 root root 139 20 oct. 11:38 nginx
    drwxr-xr-x 3 root root 27 20 oct. 11:38 notary
    drwxr-xr-x 2 root root 38 20 oct. 11:38 registry
    drwxr-xr-x 2 root root 53 20 oct. 11:38 ui

cat harbor.cfg
[...]
    secretkey_path /data
[...] 
```


Voilà donc la bonne méthode pour tout supprimer (maintenant qu’on a vérifié que les chemins configurés correspondent).

```
docker-compose down 
rm -rf /usr/local/harbor/common/config/
rm -rf /data/secretkey
```

## Pousser (push) une image depuis un client configuré vers la Registry

Pour vous permettre d’organiser un peu vos images et donner des droits plus fins aux utilisateurs, les accès aux images sont découpés via des « projet » dans Harbor.

Du coup, avant de pousser un image sur la registry, il est nécessaire de « taguer » l’image avec le nom du serveur registry ET son projet associé, au lieu de simplement taguer un nom d’image comme on l’aurait fait normalement avec la Docker Registry.

```
REGISTRY=[hostname_de_la_registry]
DOCKER_IMAGE=[your-docker-image]
HARBOR_PROJET=library

docker login https://$REGISTRY
   Username: admin
    Password:
    Login Succeeded

docker tag $DOCKER_IMAGE $REGISTRY/$HARBOR_PROJECT/$DOCKER_IMAGE
docker push $REGISTRY/$HARBOR_PROJECT/$DOCKER_IMAGE
    The push refers to a repository [xxx/library/xwiki-tomcat8]
    ac33aaa78bac: Pushed
    [...]
    fe40aaa9465f: Pushed
    cf4aaa492384: Pushed
    latest: digest: sha256:81b3a60d6936a07e9zzzzzzccb29ead8a1d1035fa5042297ac54f71a6c1e95bb size: 4504
```


L’image apparaît sur la console :  
![](/2017/10/harbor_push01.png)

## Tirer (pull) une image depuis un client configuré

Même principe que pour le push, il faut être authentifié et sélectionner le projet dans lequel est située l’image

```
REGISTRY=[hostname_de_la_registry]
DOCKER_IMAGE=[your-docker-image]
HARBOR_PROJET=library

docker login https://$REGISTRY
   Username: admin
    Password:
    Login Succeeded

docker pull $REGISTRY/$HARBOR_PROJECT/$DOCKER_IMAGE
```


Tout simplement !

## Interface web : Projects

La vue **Projects** a vocation a permettre la segmentation de la plateforme en plusieurs projets distincts.

![](/2017/10/harbor_projects01.png)

Chaque projet peut être _privé_ ou _public_, disposer d’habilitations et règles de réplications qui lui sont propres.

![](/2017/10/harbor_projects02.png)

## Interface web : Logs

La vue **Logs** permet aux **administrateurs** d’avoir une vue d’ensemble des logs (pull, push, etc) de TOUS les projets de manière centralisée.

![](/2017/10/harbor_logs01.png)

![](/2017/10/harbor_logs02.png)

Chaque projet peut également voir ses propres logs dans la vue du projet.

![](/2017/10/harbor_logs03.png)

Clairement, ce n’est pas transcendant en terme de logging (à des fins d’audit par exemple) mais c’est mieux que rien (Docker Registry...) et relativement intuitif.

## Interface web, partie Administration

Le sous-menu **Users** permet d’avoir une liste des utilisateurs et de les administrer.

![](/2017/10/harbor_admin_users01.png)

Le sous-menu **Replication** permet de gérer les endpoints de réplication et la réplication des projets (_Replication Rule_) de manière globale.

![](/2017/10/harbor_admin_replication01.png)

Le sous-menu **Configuration** permet de visualiser et modifier une partie des paramètres généraux de la plateforme. Une partie des ces paramètres proviennent de la configuration **harbor.cfg** renseignée lors de l’instanciation (via Ansible dans notre cas). Certains ne peuvent pas être changés depuis l’interface (comme la méthode d’authentification par exemple, mais je ne le testerai pas si j’étais vous...).

![](/2017/10/harbor_admin_configuration01.png)

Par défaut, la création de projets est permis pour tout le monte et l’enregistrement d’utilisateurs est possible. Pour des raisons de sécurité, il est préférable de le désactiver si ce n’est pas nécessaire.

## Erreurs rencontrées

Dans l’ensemble, Harbor est un produit sympa et plutôt bien fini, qui étend avec des fonctionnalités vitales en entreprise la bête Docker Registry.

Pour autant, le produit étant récent, il n’était pas exempt de quelques bugs à sa sortie (en grande partie corrigés depuis). Voilà ceux que j’ai rencontré au moment où j’ai rédigé le premier article (il y a quelques mois maintenant)

### Modification du secretkey_path

Si on modifie le paramètre **secretkey_path**, le container **harbor-adminserver** part en crash loop. Le problème est référencé sur ce ticket

* [github.com/vmware/harbor/issues/2208](https://github.com/vmware/harbor/issues/2208)

```
docker ps
[...]
7dcd18a310bc vmware/harbor-adminserver:v1.2.0 "/harbor/harbor_ad..." 19 seconds ago Restarting (1) 3 seconds ago harbor-adminserver

docker-compose up
[...]
harbor-adminserver | 2017-10-20T09:56:16Z [INFO] initializing system configurations...
harbor-adminserver | 2017-10-20T09:56:16Z [INFO] the path of json configuration storage: /etc/adminserver/config/config.json
harbor-adminserver | 2017-10-20T09:56:16Z [DEBUG] [driver_json.go:46: path of configuration file: /etc/adminserver/config/config.json]
harbor-adminserver | 2017-10-20T09:56:16Z [INFO] the path of key used by key provider: /etc/adminserver/key
harbor-adminserver | 2017-10-20T09:56:16Z [INFO] configurations read from storage driver are null, will load them from environment variables
harbor-adminserver | 2017-10-20T09:56:16Z [FATAL] [main.go:46: failed to initialize the system: read /etc/adminserver/key: is a directory]
```


A priori il n’y a pas encore de correctif, la seule solution est de remttre le paramètre **secretkey_path** à la valeur par défaut

```
secretkey_path /data
```


### Crash loop sur nginx lorsqu’on utilise Notary

En cas d’installation avec Notary, le container frontend nginx (reverse proxy) part en crashloop

```
nginx | 2017/10/20 10:05:40 [emerg] 1#0: host not found in upstream "notary-server:4443" in /etc/nginx/conf.d/notary.upstream.conf:3
nginx | nginx: [emerg] host not found in upstream "notary-server:4443" in /etc/nginx/conf.d/notary.upstream.conf:3
nginx exited with code 1
```


A priori, il s’agit d’un problème d’ordonnancement du démarrage des containers dans le Docker Compose (notary n’est pas accessible au moment du démarrage du nginx). Un redémarrage du container nginx (uniquement )après le « docker compose up » règle la plupart du temps le problème.

 [2]: https://github.com/zwindler/ansible-deploy-harbor
