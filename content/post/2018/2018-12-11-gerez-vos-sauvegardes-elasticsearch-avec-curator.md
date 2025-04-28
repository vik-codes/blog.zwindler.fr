---
title: Gérez vos sauvegardes ElasticSearch avec Curator
authors:
  - zwindler
type: post
date: 2018-12-11T12:45:39+00:00
url: /2018/12/11/gerez-vos-sauvegardes-elasticsearch-avec-curator/
image: /2017/10/elastic_3.png
categories:
  - Cluster
  - Stockage
  - Système
tags:
  - API
  - Curator
  - curl
  - Elastic
  - ElasticSearch
  - ElasticStack
  - restauration
  - sauvegarde

---
## Curator et Elasticsearch

Il y a quelques mois, j’ai écris un article pour parler de mon expérience [« supprime tes données dans ton cluster Elasticsearch par erreur »](/2018/07/04/sauvegarder-et-restaurer-des-index-dans-elasticsearch/). Et par conséquent, [de la sauvegarde que j’avais mis en place](/2018/07/04/sauvegarder-et-restaurer-des-index-dans-elasticsearch/) pour éviter de se retrouver sans rien en cas de récidive ;-).

Le moins qu’on puisse dire, c’est que l’utilisation des API pour une opération aussi régulière qu’une sauvegarde (ou la suppression des vieux index, par exemple) est quelque chose d’assez lourd à mettre en place.

Un des lecteurs avait pris le temps de me conseiller un outil fourni par les gens de chez Elastic, et qui permet de gérer plus simplement ces tâches fastidieuses : [Curator](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/index.html).

## Prérequis côté serveur

J’avais donc dis que je regarderai et j’ai donc profité d’un de mes clusters ElasticSearch sur Kubernetes pour tester l’outil.

La première chose à faire est donc de récupérer l’adresse IP (ou le nom DNS) qui nous permet d’accéder à l’API web de notre cluster ElasticSearch. Pour rester cohérent avec l’exemple, je vais dérouler la procédure de mise en place d’une sauvegarde avec **Curator** dans un cluster Kubernetes qui contient un cluster ElasticSearch existant (ça ne complique pas beaucoup). Mais dans tout les cas il vous faudra une adresse ;-).

```
kubectl --context=andromeda --namespace=elastic get svc elasticsearch
NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)             AGE
elasticsearch   ClusterIP   10.10.10.15           9200/TCP,9300/TCP   115d
```


En se connectant dans le container Elastic, je peux regarder comment est configuré la base, et en particulier les destinations physiques « repo ».

```
kubectl --context=andromeda --namespace=elastic exec -it docker-elasticsearch-0 /bin/bash
cat /opt/elasticsearch/config/elasticsearch.yml
[...]
path:
  data: ${ELASTICSEARTCH_DATA_DIR}/data
  logs: ${ELASTICSEARTCH_DATA_DIR}/logs
  repo: ${REPO_LOCATIONS}
[...]
```


Dans le cas d’ElasticSearch en tant que container Docker, il existe dans l’image Docker officielle une variable **REPO_LOCATIONS**. Dans mon cas, j’ai donc modifié la configuration de mon déploiement pour spécifier à ElasticSearch où trouver les variables.

```
[...]
- env:
  - name: REPO_LOCATIONS
    value: '["/data/bkp"]'
[...]
```


Pour ceux qui n’utilisent pas Elasticsearch en tant que cluster Docker ([si vous l’avez installé avec un de mes playbooks Ansible par exemple](/2017/10/03/elasticstack-kibana-elasticsearch-logstash-beats/)), vous pouvez éditer le fichier de configuration et ajouter les lignes suivantes (et vous assurer que le chemin existe effectivement) :

```
sudo vim /etc/elasticsearch/elasticsearch.yml
[...]
path:
  repo: ["/my/backup/directory/path"]
[...]
```


Redémarrer ElasticSearch pour prise en compte (ou _deletez_ le pod, niark niark niark). Notre base ElasticSearch sait maintenant où déposer les futures sauvegardes.

## Prérequis côté client

Lancer un curl sur l’adresse IP que vous avez collecter au début du tuto, pour voir si on arrive à lister les indices présents.

Dans mon cas, je lance un container Ubuntu directement dans le cluster K8s pour faire simple.

```
kubectl --context=andromeda run my-shell --rm -i --tty --image ubuntu -- bash

#install prerequisites for curl
apt-get update
apt-get -y install curl

#do the actual curl
curl -X GET "10.10.10.15:9200/_cat/indices?v"

health status index                       uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   awesomeapp-health-2018.11.30  6VrEZk-XTGm3eeKJEzDZnA   5   1      17054            0        2mb            2mb
[...]
```


OK ! On a bien accès à l’API. On peut maintenant configurer la variable d’environnement REPO_LOCATIONS

```
curl -XPUT 'http://10.10.10.15:9200/_snapshot/svg' -H 'Content-Type: application/json' -d '{
  "type": "fs",
  "settings": {
    "location": "/data/bkp",
    "compress": true
  }
}'
```


Cette commande devrait vous renvoyer ceci :

```
{"acknowledged":true}
```


## Et maintenant ?

Cette partie du tuto était identique (à Kubernetes près) au tutoriel précédent. Maintenant, ça diffère.

On va installer **Curator**, mais pas via le gestionnaire de package du système. En effet, si vous avez une version récente d’ElasticSearch et que vous vous contentez d’APT, vous risquez d’obtenir l’erreur suivante :

```
apt-get install elasticsearch-curator
curator_cli show_indices
elasticsearch.exceptions.ElasticsearchException: Unable to create client connection to Elasticsearch.  Error: Elasticsearch version 6.3.0 incompatible with this version of Curator (5.2.0)
```


La version conseillée par Elastic est l’utilisation du gestionnaire de package Python (pip) :

```
apt-get update
apt-get -y install curl python
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py

python get-pip.py --force-reinstall
pip install elasticsearch-curator --user
```


Dans ce tutoriel, on va commencer par utiliser la CLI de **Curator**. Mais il faut savoir qu’il existe aussi une version qui permet de jouer des scenarii prédéfinis (les **Actions**). Du coup, il est logique que tout la partie connexion et authentification soit gérée par un fichier de configuration. Malheureusement, cette partie n’est pas super bien documentée si on se contente de la doc d’install (il faut fouiller un peu). Dans les grandes lignes, voilà ce qu’il faut faire :

```
mkdir ~/.curator
cat > ~/.curator/curator.yml << EOF
client:
  hosts: 10.10.10.15
  port: 9200
  url_prefix:
  use_ssl: False
  certificate:
  client_cert:
  client_key:
  ssl_no_validate: False
  http_auth:
  timeout: 30
  master_only: False

logging:
  loglevel: INFO
  logfile: /data
  logformat: default
  blacklist: ['elasticsearch', 'urllib3']
EOF
```


Ici, j’ai juste ajouté mon IP et mon port de connexion à l’API, mais on peut donc aussi configurer pas mal de choses en plus.

Curator maintenant configuré, on peut tester la même commande qu’avec le cURL pour lister les indices.

```
/root/.local/bin/curator_cli show_indices
awesomeapp-health-2018.11.12
awesomeapp-health-2018.11.13
awesomeapp-health-2018.11.14
[...]
```


## Création d’un snapshot

Maintenant qu’on a **Curator** qui peut se connecter à ElasticSearch, on va enfin pouvoir lancer notre sauvegarde, via la feature des snapshots ! (Plus d’info sur les filtres, vous pouvez aller sur  [la page de documentation officielle](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/singleton-cli.html))

```
root/.local/bin/curator_cli  snapshot --repository svg --filter_list '{"filtertype":"none"}'
```


La commande devrait prendre un certain temps, en particulier si vous avez beaucoup de données. Une fois qu’elle a rendu la main, vérifiez que le snapshot existe, avec la CLI, et en allant voir le contenu du dossier configuré précédemment.

```
root/.local/bin/curator_cli show_snapshots --repository svg
curator-20181204095300

ll /data/bck
total 36
drwxr-xr-x  3 elasticsearch elasticsearch 4096 Dec  4 09:54 ./
drwxr-xr-x  6 elasticsearch elasticsearch 4096 Dec  4 09:47 ../
-rw-r--r--  1 elasticsearch elasticsearch   29 Dec  4 09:54 incompatible-snapshots
-rw-r--r--  1 elasticsearch elasticsearch 5522 Dec  4 09:54 index-0
-rw-r--r--  1 elasticsearch elasticsearch    8 Dec  4 09:54 index.latest
drwxr-xr-x 56 elasticsearch elasticsearch 4096 Dec  4 09:53 indices/
-rw-r--r--  1 elasticsearch elasticsearch  103 Dec  4 09:53 meta-yMBl9IsPRYGCitWqGjxh2Q.dat
-rw-r--r--  1 elasticsearch elasticsearch  470 Dec  4 09:54 snap-yMBl9IsPRYGCitWqGjxh2Q.dat
```


## Je suis expert en sauvegarde moi, pas en restauration...

> True story

Bon, sauvegarder c’est bien, restaurer c’est mieux ! Il existe bien évidemment une commande restore pour ça ;)

```
root/.local/bin/curator_cli restore --repository svg --name curator-20181204095300 --filter_list '{"filtertype":"none"}'
```

## Et après !

Clairement, on ne va pas se contenter de ça. C’est déjà mieux que précédemment avec les appels d’API, mais on peut faire encore mieux. Déjà, si vous avez fait attention, j’ai teasé qu’on pouvait gérer les indices (et ainsi virer les plus vieux) avec **Curator**. C’est clairement un usecase hyper sympa de l’outil.

Ensuite, j’ai également teasé la possibilité de gérer des tâches en mode batch, avec les actions, qui sont des fichiers de définition simple de vos actions à faire avec **Curator**. Il y aura bien entendu des articles à suivre pour en apprendre plus ;-)

## Ressources additionnelles

* [www.elastic.co/guide/en/elasticsearch/reference/current/\_list\_all_indices.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/_list_all_indices.html)
* [postmarkapp.com/blog/tools-we-use-curator-for-elasticsearch](https://postmarkapp.com/blog/tools-we-use-curator-for-elasticsearch)
* [ikeptwalking.com/taking-elasticsearch-snapshots-using-curator/](http://ikeptwalking.com/taking-elasticsearch-snapshots-using-curator/)
