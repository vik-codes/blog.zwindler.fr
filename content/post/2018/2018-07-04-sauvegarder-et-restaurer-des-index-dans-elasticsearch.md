---
title: Sauvegarder et restaurer des index dans Elasticsearch
authors:
  - zwindler
type: post
date: 2018-07-04T11:45:55+00:00
url: /2018/07/04/sauvegarder-et-restaurer-des-index-dans-elasticsearch/
image: /2017/10/elastic_3.png
categories:
  - Logiciel
tags:
  - API
  - curl
  - ElasticSearch
  - ElasticStack
  - Kibana
  - REST
  - restauration
  - sauvegarde
  - Snapshot

---
## Un développeur s’est dit « J’ai BESOIN d’Elasticsearch ! »

Et ce qui devait arriver, arriva. Du jour au lendemain, vous n’avez pas eu le temps de dire « ouf » et vous avez déjà une base Elasticsearch à maintenir en production !

> Dure vie des #Ops ;-)

## On va apprendre comment sauvegarder et restaurer des données dans ELK

Cet article n’arrive pas par hasard. A la base je voulais faire un article sur l’utilisation d’ELK avec l’API REST. Mais en jouant avec les API (en voulant purger des données de manière ciblée), j’ai supprimé un mois complet de données.

S’il y a une chose que j’ai apprise avec ce blog, c’est qu’il faut toujours poster l’article sur la solution à un problème AVANT l’article où je parle du problème que j’ai eu. Certains lecteurs ont parfois un peu la tête en l’air, et mieux vaut avoir la solution sous le coude _a priori_. ;-)

![](/2017/10/elk_deleted_indexes.png)

> Oops

## Les snapshots

On ne peut pas dire que cette partie de la documentation d’Elastic soit hyper bien mise en avant. Ca fait partie de ces projets où la mise en place (_regardez comme c’est facile à installer_) et tellement mise en avant qu’on ne sait pas comment l’exploiter après.

Mais en insistant un peu on fini par tomber sur [les snapshots][2], la feature qui va vous permettre de faire des dumps de vos données à un instant T.

## Mise en place du dossier de snap

La première chose à faire est de configurer notre répertoire où on va déposer/récupérer nos fichiers snapshots. Assurez vous qu’Elasticsearch puisse lire/écrire dedans, bien entendu !

On commence par indiquer le chemin dans le fichier de configuration d’Elasticsearch (ici **/svg**)

```
vi /etc/elasticsearch/elasticsearch.yml
path.repo: ["/svg"]
```

On créé le dossier (ben oui) et on lui donne les droits qui vont bien.

```
mkdir /svg
```

## Créer l'emplacement des snapshots

Maintenant que notre Elasticsearch est configuré, on peut créer un snapshot. Les interactions avec Elasticsearch se font exclusivement en API, donc on dégaine notre plus beau JSON avec cURL :

```
curl -XPUT 'http://localhost:9200/_snapshot/svg' -H 'Content-Type: application/json' -d '{
  "type": "fs",
  "settings": {
    "location": "/svg",
    "compress": true
  }
}'
```


Dans cet exemple, j’exécute la requête en local (localhost), mais vous pouvez bien entendu lancer l’instruction sur des hôtes distants.

Notez aussi que j’ai ajouté l’option **compress**, pour des raisons évidentes d’économies d’espace disque et que j’ai indiqué la location à **/svg**, qu’on a défini précédemment.

On vérifie que la commande a bien été prise en compte (à partir de maintenant je vais omettre la partie cURL et juste mettre la requête) :

```
GET /_snapshot/svg 
{
  "svg": {
    "type": "fs",
    "settings": {
      "compress": "true",
      "location": "/svg"
    }
  }
}
```


## Ça y est, on a des sauvegardes ?

Non, pas encore tout à fait :-/

Maintenant que j’ai créé l'emplacement, je dois créer le snapshot :

```
PUT /_snapshot/svg/snapshot_1
{
  "accepted": true
}
```


Maintenant c’est bon. On peut ensuite vérifier où on en est avec la requête suivante :

```
GET /_snapshot/svg/snapshot_1
{
  "snapshots": [
    {
      "snapshot": "snapshot_1",
      "uuid": "s38NGqRES1uZfiyHiRNJVQ",
      "version_id": 5060299,
      "version": "5.6.2",
      "indices": [
        "logstash-2017.06.29",
        "logstash-2017.10.18",
        [...]
        "logstash-2017.09.10",
        "logstash-2017.10.11",
        "logstash-2017.10.09"
      ],
      "state": "IN_PROGRESS",
      "start_time": "2017-10-25T18:36:07.931Z",
      "start_time_in_millis": 1508956567931,
      "end_time": "1970-01-01T00:00:00.000Z",
      "end_time_in_millis": 0,
      "duration_in_millis": -1508956567931,
      "failures": [],
      "shards": {
        "total": 0,
        "failed": 0,
        "successful": 0
      }
    }
  ]
}
```

Le retour affiche la liste des snapshots existants (ici seulement **snapshot_1** puisque c’est notre premier). On voit l’ensemble des index (sous **indices**).

On remarque aussi que la variable _state_ à IN_PROGRESS et dans _shards_, _successful_ est à 0.

On peut surveiller l’avancement de notre snapshot avec la même commande, un peu plus tard. L’état est passé à SUCCESS.

```
GET /_snapshot/svg/snapshot_1
{
  "snapshots": [
    {
      "snapshot": "snapshot_1",
      "uuid": "s38NGqRES1uZfiyHiRNJVQ",
      "version_id": 5060299,
      "version": "5.6.2",
      "indices": [
        "logstash-2017.06.29",
        "logstash-2017.10.18",
        "logstash-2017.08.01",
        "logstash-2017.09.23",
        "logstash-2017.09.29",
        "logstash-2017.07.11",
        [...]
      ],
      "state": "SUCCESS",
      "start_time": "2017-10-25T18:36:07.931Z",
      "start_time_in_millis": 1508956567931,
      "end_time": "2017-10-25T18:46:14.231Z",
      "end_time_in_millis": 1508957174231,
      "duration_in_millis": 606300,
      "failures": [],
      "shards": {
        "total": 621,
        "failed": 0,
        "successful": 621
      }
    }
  ]
}
```

Si vous utilisez Kibana avec votre Elasticsearch, vous pouvez aussi vous passer de cURL et utiliser le menu Admin dans Kibana.

![](/2017/10/elk_snap01.png)

## Restauration

Maintenant qu’on a une sauvegarde, on est hyper contents :)

![](/2018/07/hyper_content.gif)

De tous les indices qu’on a sauvegarder, on peut en sélectionner un (ou plusieurs), et lancer une restauration !

On lancer la restauration avec une requête à l’API :

```
POST /_snapshot/svg/snapshot_1/_restore
{
  "indices": "logstash-2017.10.21",
  "ignore_unavailable": true,
  "include_global_state": true
}

```


Et paf ! Ça ne marche pas !

![](/2017/10/elk_cannot_restore_open01.png)

En fait c’est normal. L’index en question est encore ouvert. Il faut le fermer pour le restaurer

> However, an existing index can be only restored if it’s [closed][6]{.link} and has the same number of shards as the index in the snapshot. The restore operation automatically opens restored indices if they were closed and creates new indices if they didn’t exist in the cluster.

```
POST /logstash-2017.10.21/_close
```

![](/2017/10/elk_cannot_restore_open02.png)

Et maintenant on peut lancer notre restauration !

![](/2017/10/elk_restore1.png)

Si jamais on n’a pas envie de lancer la restauration des index un par un (ce qui peut être un peu long si vous en avez beaucoup à restaurer ;-p), on peut aussi utiliser des wildcard. Par exemple, si j’ai supprimé les index des 9 premiers jours du mois d’octobre :

```
POST /logstash-2017.10.0*/_close

POST /_snapshot/svg/snapshot_1/_restore
{
  "indices": "logstash-2017.10.0*",
  "ignore_unavailable": true,
  "include_global_state": true
}
```


![](/2017/10/elk_already_restore.png)

Une fois l’opération terminée, j’ai pu récupérer les index bêtement supprimés :

![](/2017/10/elk_restored.png)

> TADAAAAM

## Bonus : C’est pas très industrialisé tout ça !

Comme le fait remarquer à très juste titre **coom** dans les commentaires, il existe un moyen officiel de gérer ça de façon plus industrielle => via [curator][11].

Curator est un outil officiel d’elastic et il permet de faciliter l’administration de vos indices, et notamment la gestion des snapshots. La documentation contient également des exemples ([notamment l’exemple de la gestion des snapshots justement][12]).

Si j’ai le temps je ferai un petit article sur les capacités de Curator, qui sont nombreuses.

 [2]: https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-snapshots.html
 [6]: https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html "Open / Close Index API"
 [11]: https://github.com/elastic/curator
 [12]: https://www.elastic.co/guide/en/elasticsearch/client/curator/current/ex_snapshot.html
