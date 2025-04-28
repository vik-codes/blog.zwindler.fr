---
title: '[Tutoriel] Shinken 2.4  sur CentOS/RHEL 7 – partie 3'
authors:
  - zwindler
type: post
date: 2015-09-22T16:32:00+00:00
url: /2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-3/
image: /2015/09/shinken.png
categories:
  - Monitoring
tags:
  - arbiter
  - broker
  - CentOS 7
  - configuration
  - module
  - mongodb
  - pip
  - poller
  - reactionner
  - receiver
  - requirements
  - RHEL 7
  - scheduler
  - Shinken 2.4
  - shinken.io
  - systemd

---
Cet article fait parti d’une série d’articles (au moins 3) que je vais publier sur le sujet et que j’ai séparé pour les rendre un peu plus digestes. Je vous conseille quand même de ne pas en sauter pour bien comprendre de quoi on parle ;-) :

* [Partie 1 : Présentation de Shinken](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-1/)
* [Partie 2 : Installation de Shinken 2.4 sur RHEL/CentOS 7](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-2/)
* [Partie 3 : Configuration initiale de Shinken 2.4 sur RHEL/CentOS 7](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-3/)

## Les modules

L’ensemble des modules et en particulier le broker n’a donc aucun module d’activé. Or les interfaces graphiques sont gérées par des modules du broker pour ne citer qu’eux.

### Les modules et shinken.io

Par convention (ce n’était pas forcément le cas dans les précédentes versions), la configuration des modules est définie dans des fichiers de configurations individuels qui seront stockés dans le sous dossier modules de **/etc/shinken/**.

On peut trouver les fichiers liés aux modules dans le répertoire **/var/lib/shinken/modules/** (par défaut, mais vous pouvez le modifier dans le fichier **shinken.cfg** ou dans les « .ini » des démons).

```
cat /etc/shinken/modules/sample.cfg
# Here is a sample module that will do nothing :)
#define module{
#     module_name    module-sample
#     module_type    module-sample
#     key1           value1
#     key2           value2

ll /var/lib/shinken/modules
total 24
drwxr-xr-x 2 shinkn shinkn 4096 17 sept. 14:34 dummy_arbiter
drwxr-xr-x 2 shinkn shinkn 4096 17 sept. 14:34 dummy_broker
drwxr-xr-x 2 shinkn shinkn 4096 17 sept. 14:34 dummy_broker_external
drwxr-xr-x 2 shinkn shinkn 4096 17 sept. 14:34 dummy_poller
drwxr-xr-x 2 shinkn shinkn 4096 17 sept. 14:34 dummy_scheduler
-rw-r--r-- 1 shinkn shinkn 919 17 sept. 14:34 __init__.py
```


Autant dire que pour l’instant on ne peut pas faire grand chose !

C’est un choix technique qui a été fait à partir de la version 2 (si je ne m’abuse) et qui permet de n’avoir que ce dont on a vraiment besoin, ce qui est une très bonne pratique.

Pour autant, pour éviter de trop alourdir le processus d’installation de multiples modules, l’équipe a mis au point un catalogue d’extensions qui permet d’installer les modules manquants à l’aide d’une simple ligne de commande, ce qui est très pratique.

La première fois, il faut commencer par « initialise » notre Shinken 2.4, avec la commande suivante :

```
shinken --init
```


Le site [shinken.io](http://shinken.io/browse/modules/updated) référence à date pas moins de 138 packages dont les fameux modules qui nous manquent.

### Premier module : les logs comme nagios.log

Pour installer le module de log plat à la mode « Nagios », il faut installer simple-log.

```
shinken install simple-log
  Grabbing : simple-log
  OK simple-log
```


Pas mal hein?

Si vous avez l’erreur suivante qui apparaît, c’est que vous n’avez pas fait la commande shinken init à l’étape précédente.

```
shinken install simple-log
[1442761511] ERROR: [Shnken] Cannot load cli commands, missing paths or cli entry in the config
[1442761511] ERROR: [Shnken] CLI loading not done: missing configuration data. Please run --init

shinken --init
Creating ini section paths
Creating ini section shinken.io
Saving the new configuration file /root/.shnken.ini
```


### Installer la WebUI, l’interface graphique officielle du projet

Pour installer l’interface graphique « officielle » (aka la WebUI), il faut se rendre sur la page [suivante](http://shinken.io/package/webui2) (et la documentation qui détaille sont installation sont disponibles [ici](https://github.com/shinken-monitoring/mod-webui/wiki/Installation)).

Toutes les dépendances python peuvent être installées via pip et le fichier requirements.txt. Pour mongodb, je vous l’ai déjà fait installer un peu plus tôt donc ça devrait déjà être fait (enfin... si vous avez suivi... sinon :-p retournez à l’article précédent).

```
pip install -r https://raw.githubusercontent.com/shinken-monitoring/mod-webui/develop/requirements.txt
shinken install webui2
  Grabbing : webui2
  OK webui2
```


Par défaut, le fichier de configuration **webui2.cfg** est créé dans le dossier **/etc/shinken/modules/** et les fichiers du modules ont été déposés dans **/var/lib/shinken/modules/**.

Pour que notre authentification par fichier **htpasswd** soit prise en compte, il faut dé-commenter la ligne contenant le paramètre **htpasswd_file**.

[Deprecated]Vous devriez aussi changer tout de suite le paramètre **auth_secret** dans le fichier de configuration **webui2.cfg**. Remplacez CHANGEME par la valeur que vous voulez.

Historiquement il fallait changer soit même le paramètre **auth_secret** dans le fichier de configuration mais cette option a été remplacée par un fichier autogénéré. Cette méthode est plus sécurisante car elle évite d’oublier de le faire ;-).

```
htpasswd_file              /etc/shinken/htpasswd.users
[...]
   # Authentication secret for session cookie
   #auth_secret                BOBLEPONGE
   #                           ; CHANGE THIS or someone could forge cookies
   auth_secret_file            /var/lib/shinken/auth_secret
[...]
```


Pour l’instant, seule l’authentification par Apache htpasswd est activé (vu qu’on vient de le décommenter). On pourra en rajouter d’autres par la suite mais pour faire simple, on va juste y ajouter un compte pour commencer.

```
htpasswd -c /etc/shinken/htpasswd.users admin
```


Ensuite on démarre la base mongodb

```
systemctl enable mongod
systemctl start mongod
```


### Câbler le tout

On a installé deux modules, mais aucun des deux n’ont été reliés au broker : ils ne seront pas utilisés au démarrage. On modifie donc la configuration du broker en conséquence.

```
vi /etc/shinken/brokers/broker-master.cfg
    modules     simple-log,webui2
```


Pour plus de détails sur la configuration du broker, je vous renvoie vers la page [broker](https://shinken.readthedocs.org/en/latest/08_configobjects/broker.html) de la documentation officielle.

Redémarrez l’outil pour prendre en compte la modification de configuration et connectez vous à l’URL `http://@IP_shinken:7767`

```
systemctl restart shinken
```


![](/2015/09/shinken2.png")

> Yata !

![](/2015/09/03_shinken.png)

> Le dashboard. Mais pour l’instant il n’y a pas grand chose !

## En cas de problèmes

Par défaut, les logs sont stockés dans le répertoire **/var/log/shinken/**, avec un fichier par démon.

Ils sont généralement assez détaillés et on peut moduler le niveau de détails dans les fichiers de configuration des démons que j’ai présenté un peu plus tôt.

Dans le cas où la configuration (**shinken.cfg** et tous les autres .cfg qui en découlent) contiendrait une erreur, l’arbiter plantera au démarrage et les informations sur son plantage seront contenues dans le fichier **/tmp/bad\_start\_for_arbiter**. Ça peut être utile.

## Aller plus loin

Ça y est. Votre nouvel outil de supervision fonctionne et vous disposez d’une interface graphique pour voir ce qu’il s’y passe.

Voici quelques pistes pour réellement terminer le travail que vous venez de commencer :

  * D’abord vous pourriez commencer par ajouter des plugins et quelques serveurs à votre configuration pour voir comment Shinken réagit quand on lui donne un peu de travail. Et pourquoi ne pas vous économiser du travail de configuration en utilisant [les packs](http://shinken.io/browse/packs/updated), dans ce but ultime d’automatiser toujours plus (pour travailler moins) ?
  * Ensuite, vous pourriez ajouter des modules à la WebUI, comme par exemple [ui-graphite](http://shinken.io/package/ui-graphite) ou [ui-pnp](http://www.shinken.io/package/ui-pnp) pour ajouter la gestion des graphes dans votre WebUI.
  * Enfin, vous pourriez vous pencher sur les aspects [de haute disponibilité, de répartition de charge](https://shinken.readthedocs.org/en/latest/06_medium/high-availability.html) et de [gestion des royaumes](https://shinken.readthedocs.org/en/latest/07_advanced/distributed-with-realm.html), histoire de répondre à des problématiques plus complexe ?
  