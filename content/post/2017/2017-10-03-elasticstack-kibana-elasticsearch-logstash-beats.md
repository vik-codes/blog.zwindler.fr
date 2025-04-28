---
title: 'ElasticStack : Déployer Kibana, Elasticsearch, Logstash & Beats avec Ansible'
authors:
  - zwindler
type: post
date: 2017-10-03T11:30:03+00:00
url: /2017/10/03/elasticstack-kibana-elasticsearch-logstash-beats/
image: /2017/10/elastic_3.png
categories:
  - Logiciel
  - Monitoring
tags:
  - Beats
  - DockerFile
  - ElasticSearch
  - ElasticStack
  - ELK
  - Filebeat
  - Kibana
  - Logstash
  - Metricbeat
  - Unable to fetch mapping

---
## ElasticStack

Il y a quelques temps, je me suis mis à tester ElasticStack et j’avais préparé des playbooks Ansible et un tutoriel pour vous en parler. [m4vr0x](/recherche/?keyword=m4vr0x) (qui a déjà écrit quelques articles sur le blog) était super intéressé et je lui ai dit « t’inquiètes, j’écris un article _bientôt_ sur le sujet ».

La bonne blague : c’était en juillet (ce qui n’est pas si loin quand je regarde mes plus vieux brouillons :-p ).

## Présentation de la solution

Trêve de plaisanterie ! Plus connu sous son _ancien acronyme_ (ELK), ElasticStack est une suite logicielle développée par [elastic.co][2]. Le cœur de l’application est basée sur les logiciels :

  * **Elasticsearch**
  * **Logstash**
  * **Kibana**

Historiquement ces 3 produits étaient développés de manière indépendante (même si leur utilisation conjointe était conseillée). Courant 2016, [elastic.co][3] a décidé de refondre ces solutions et harmoniser les développements et les versions (tous les produits sont passés en version 5) pour proposer un ensemble complet cohérent.

Un bon article pour parler de ce renommage peut être consulté sur le site [monitoring-fr][4].

La nouvelle architecture « classique » de la suite ElasticStack est la suivante :

![](/2017/09/elk-infrastructure.png)

### Elasticsearch

Elasticsearch est un moteur de recherche et d’analyse RESTful distribué. C’est le cœur de la solution ElasticStack. Dans ce logiciel que sera stocké toutes les données qui seront collectés sur l’infrastructure. Les points forts de la solutions :

  * la résilience et l’architecture hautement disponible
  * la performance des requêtes grâce à l’indexation, particulièrement adapté à la recherche rapide de données de type métriques ou journaux

Paradoxalement, c’est la couche avec laquelle on interagit le moins au début, puisqu’on passe surtout du temps à configurer en amont la collecte des logs au niveau **Beats** et **Logstash**, puis en aval avec la visualisation dans **Kibana**.

### Beats

La (relative) nouveauté. Introduit depuis le renommage et la version 5 de la suite logicielle, **Beats** regroupe un ensemble de modules logiciels de type « agents » à déposer sur les serveurs à surveiller.  
Ce sont ces agents, adaptés pour chaque contexte, qui récoltent les données brutes et les transmettent à la brique suivante. Actuellement, il existe les agents suivants :

  * **Metricbeat**
  * **Packetbeat**
  * **Logbeat**
  * **Winbeat**

On peut directement collecter les données dans **Elasticsearch**, la couche **Logstash** étant optionnelle, mais on perd de nombreuses fonctionnalités et il est préférable de garder **Logstash**.

### Logstash

**Logstash** est le module de collecte « historique ». C’est lui qui était chargé de récolter logs et métriques pour les transmettre à **Elasticsearch**.

Aujourd’hui, **Logstash** étant plus gourmand en ressources que les agents **Beats**, il peut être préférable de ne plus l’utiliser pour la collecte en elle même.

Cependant, à l’inverse, les agents **Beats** n’ont pas la capacité, _contrairement à **Logstash**_, de traiter les données récoltées. Il est donc intéressant de conserver **Logstash** en coupure entre les agents **Beats** et **ElasticSearch** pour réaliser des traitements sur les données collectées.

Un bon exemple est la collecte des logs. Par défaut, les données collectées par **Filebeat** contiennent les informations suivantes :

  * un timestamp correspondant au moment de la collecte (attention, pas identique au moment où le log a été écrit!!!)
  * le serveur source
  * le fichier de log source
  * la version de filebeat (super :/)
  * la ligne complète collectée dans le log

Cependant, il est complexe d’exploiter les données ainsi collectées puisque les messages des logs contiennent souvent des informations multiples sur une même ligne. Par exemple dans **/var/log/messages**, on a les informations suivantes :

```
Date Heure Hostname Processus[PIDXXX]: le message
```


Avec **Logstash**, il est possible de « tronçonner » via une regexp cette ligne en plusieurs champs :

  * Date et heure de l’événement journalisé (réelle cette fois, pas l’heure de collecte)
  * Nom d’hôte
  * Nom du processus concerné
  * PID
  * Le message réel

A partir de ces informations et associées aux informations récoltées par **Beats**, on peut donc gérer de manière beaucoup plus simple nos recherches et les consolider dans des graphiques avec **Kibana**.

### Kibana

**Kibana** est une interface web qui permet d’explorer/de visualiser des informations provenant d’**Elasticsearch** et de les afficher sous formes de graphiques. On peut ensuite consolider les graphiques en tableaux de bords (dashboards).

Quelques exemples de dashboards qu’on peut créer :

![](/2017/09/elk15.png)

> Consommation des containers Docker sur une machine

 

![](/2017/09/elk16.png)

> Dashboard d’analyse des logs d’un serveur nginx

 

Un gros point positif de la solution est la possibilité de filtrer en temps réel sur une sous catégorie des données, soit via une barre de recherche, soit en cliquant directement sur les graphiques, en mode « _drill down_« .

Par exemple, si je veux obtenir plus de détails sur les code retours 404, il me suffit de cliquer sur le code 404 dans le camembert, et **Kibana** filtrera les données de TOUS les graphiques du dashboard pour ne m’afficher que les données correspondantes :

![](/2017/09/elk17.png)

## Déploiement d’ElasticStack via Docker

Vous y avez cru ? Je ne vais pas vous donner les étapes pour installer ElasticStack via l’usage des containers Docker officiels.

Pourquoi ? Ce n’est pas parce que je n’utilise pas Docker. J’ai déjà massivement adopté cette techno. aussi bien dans le contexte pro que perso.  
Mais tout simplement parce que c’est assez bien documenté sur le site et que c’est vraiment simple. Si l’article a vraiment beaucoup d’engouement et que c’est demandé gentiment, je ferai un effort ;-) .

## Installation d’ElasticStack sur un serveur via Ansible

C’est un peu plus compliqué si vous ne voulez PAS déployer ElasticStack via Docker. La documentation indique d’autres méthodes, dont l’installation classique via des RPMs.

Au moment où j’avais écris les premières lignes du tutoriel, j’avais remarqué qu’il y avait aussi une méthode automatisée via Ansible et comme j’adore Ansible j’ai voulu l’utiliser.

Sauf qu’elle n’existait que pour Elasticsearch et en plus pour la version 2.3.X (version d’avant le grand renommage de 2016 dont je parle plus haut) !

Je me suis donc attelé à la tâche de développer mes propres playbooks pour automatiser tout ça. Et comme je suis sympa, je vous les met à disposition.

## Installer la base, ELK

Le code suivant va vous permettre de déployer via Ansible les 3 logiciels ElasticSearch, Kibana et Logstash sur une seule et même machine. Mais comme les rôles ont été découpés en 3 playbooks, il est tout à fait envisageable d’installer ces rôles sur des machines différentes (ou juste une partie).

Les seuls prérequis sont d’avoir une machine CentOS 7 (ou RHEL ou équivalent) qui dispose d’Ansible et de git d’installé.

```
mkdir -p /etc/ansible/roles && cd /etc/ansible/roles
git clone https://github.com/zwindler/ansible-deploy-elasticsearch
git clone https://github.com/zwindler/ansible-deploy-kibana
git clone https://github.com/zwindler/ansible-deploy-logstash
```


A partir de là, vous n’avez plus qu’à créer un playbook qui va tirer parti de ces rôles :

```
cd /etc/ansible
cat deploy_kibana_elasticsearch_logstash.yml
---
- name: Install elastic stack
  hosts: localhost
  roles:
    - { role: ansible-deploy-kibana, tags: 'kibana' }
    - { role: ansible-deploy-elasticsearch, tags: 'elasticsearch' }
    - { role: ansible-deploy-logstash, tags: 'logstash' }
```


Et à lancer l’installation d’ELK sur l’hôte, affectueusement nommé « mon\_serveur\_elk » dans cet exemple, de la façon suivante :

```
ansible-playbook -l mon_serveur_elk deploy_kibana_elasticsearch_logstash.yml
ansible-playbook deploy_kibana_elasticsearch_logstash.yml

PLAY [Install elastic stack] ********************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************
ok: [mon_serveur_elk]

TASK [ansible-deploy-kibana : Add elasticsearch repository] ****************************************************************************************
changed: [mon_serveur_elk]
[...]
PLAY RECAP **************************************************************************************************************************************************
mon_serveur_elk               : ok=4   changed=21    unreachable=0    failed=0

```


A partir de là, on peut commencer à tester les composants uns par uns et vérifier que tout fonctionne.

## Tester une config Logstash

On peut vérifier que Logstash fonctionne comme il le doit grâce à la fonction « config.test\_and\_exit ». Juste pour les besoins du test, je vais donc créer un fichier logstash qui va lire le dmesg présent sur la machine. Ça n’a pas forcément d’intérêt mais comme ça on verra s’il n’y a pas de lézards.

```
cd /etc/logstash/conf.d 
cat > test.conf << EOF
input {
  file {
    path => "/var/log/dmesg"
    start_position => "beginning"
  }
}
output {
  elasticsearch {
    hosts => [ "localhost:9200" ]
  }
}
EOF

/usr/share/logstash/bin/logstash -f test.conf --config.test_and_exit
    WARNING: Could not find logstash.yml which is typically located in $LS_HOME/config or /etc/logstash. You can specify the path using --path.settings. Continuing using the defaults
    Could not find log4j2 configuration at path /usr/share/logstash/config/log4j2.properties. Using default config which logs errors to the console
    Configuration OK
```


On peut ignorer les warning ci dessus dans un premier temps. Tout fonctionne ! Si on le souhaite, on peut démarrer Logstash à la main et avec cette configuration avec la commande suivante :

```
/usr/share/logstash/bin/logstash -f test.conf --config.reload.automatic
```


Pour aller plus loin avec Logstash, je vous conseille de [lire la documentation][9] qui est assez progressive dans la difficulté. Les configurations de Logstash ne sont pas toujours évidentes et il peut y avoir pas mal de débuging les premières fois.

## Requêter Elasticsearch

Il est tout à fait possible de requêter à la main ElasticSearch, directement via l’API. Un moyen simple de s’en convaincre est de réaliser un simple « curl » sur la base mais vous pouvez bien entendu faire beaucoup plus complexe avec des outils prévu pour explorer les APIs.

Par exemple, on peut afficher les informations de la base comme ceci :

```
curl -XGET 'localhost:9200/'
{
  "name" : "anXc9nn",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "5P9XdOMJRZOPIy38NegdnQ",
  "version" : {
    "number" : "5.5.0",
    "build_hash" : "260387d",
    "build_date" : "2017-06-30T23:16:05.735Z",
    "build_snapshot" : false,
    "lucene_version" : "6.6.0"
  },
  "tagline" : "You Know, for Search"
}
```


Autres commandes sympas, vous pouvez afficher l’état de santé de vos nœuds Elasticsearch. Ici je n’en ai qu’un et c’est donc considéré comme dangereux (car pas de redondance), d’où l’état « yellow » et pas « green » :

```
curl -XGET 'localhost:9200/_cat/health?v&pretty'
    epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
    1506795865 20:24:25  elasticsearch yellow          1         1    516 516    0    0      516             0                  -                 50.0%

curl -XGET 'localhost:9200/_cat/nodes?v&pretty'
    ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
    x.x.x.x                 43          89   1    0.09    0.16     0.30 mdi       *      anXc9nn
```


Vous pouvez afficher la liste des fichiers correspondant à vos données avec cette commande :

```
curl 'localhost:9200/_cat/indices?v'
    health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
    yellow open filebeat-2017.06.19 w7tmj4L3ToqEdiHYmvHS8Q 5 1 981 0 270kb 270kb
    yellow open .kibana YFYjR5hFSGualaX-ahL_9g 1 1 2 0 23.5kb 23.5kb
```


Par défaut (et pour des questions de performance), on a pour habitude de segmenter les données dans Elasticsearch par jours. Au fil des jours de nouveaux fichiers seront créés et viendront remplir votre filesystem. Il ne faudra donc pas oublier de jeter un œil de temps et en temps et purger tout ça !

### Et Kibana ?

Normalement, Kibana est accessible à l’adresse `http://@IP_de_mon_serveur_elk:5601/`

![](/2017/10/kibana_log.png)

## Et maintenant, on collecte quoi ?

C’est bien gentil tout ça, mais pour l’instant on a rien du tout... Au delà de la simple connexion à Kibana, vous arriverez sur un écran de configuration qui cherchera, sans succès, des données dans elasticsearch.

![](/2017/10/elk1.png)
> Unable to fetch mapping

Peine perdue, ces données n’existent pas encore puisqu’on ne collecte rien pour l’instant !

Vous trouverez probablement de nombreux tuto sur Internet expliquant comment collecter des données provenant de fichiers depuis Logstash. Cependant, comme je l’ai indiqué en début d’article, la méthode conseillée est maintenant d’utiliser plutôt les agents Beats, qui envoient les données à Logstash lorsqu’un traitement est nécessaire.

Et là encore, je vous ai préparé des playbooks tout fait pour installer et configurer à la fois les modules Beats sur les serveurs supervisés ET le logstash côté serveur ELK. Plus rien à faire donc, juste à attendre le 2ème article !

Haaan, quel suspense ! A la semaine prochaine ;-)

[Edit]Les deux articles suivants sont là :

  * [ElasticStack : Collecter et exploiter des métriques provenant de nginx](/2017/10/10/elasticstack-collecter-et-exploiter-des-logs-nginx/)
  * [ElasticStack : Visualisez vos données dans Kibana](/2017/10/17/elasticstack-afficher-les-donnees-dans-kibana/)

[/Edit]

## Ressources complémentaires

  * [Installer ELK sous Ubuntu 16.04 (Digital Ocean, encore eux)][14]
  * [Sécurisation d’ElasticStack officielle avec les X-Pack][15] : attention c’est payants !
  * [Comment sécuriser une plateforme Elasticsearch et Kibana (EN)](https://web.archive.org/web/20190319133148/https://mapr.com/blog/how-secure-elasticsearch-and-kibana/) (lien mort, j'utilise Internet Archive)

 [2]: https://www.elastic.co/
 [3]: https://www.elastic.co/fr/
 [4]: https://www.monitoring-fr.org/2016/04/ne-dites-plus-elk-mais-the-elastic-stack/
 [9]: https://www.elastic.co/guide/en/logstash/current/first-event.html
 [14]: https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-16-04
 [15]: https://www.elastic.co/guide/en/x-pack/current/setting-up-authentication.html

