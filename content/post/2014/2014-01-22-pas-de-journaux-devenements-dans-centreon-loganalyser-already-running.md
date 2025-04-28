---
title: 'Pas de journaux d’événements dans Centreon, logAnalyser already running'
authors:
  - zwindler
type: post
date: 2014-01-22T10:32:21+00:00
url: /2014/01/22/pas-de-journaux-devenements-dans-centreon-loganalyser-already-running/
image: /2015/04/Centreon-Monitoring-Services-AllServices-2.jpg
categories:
  - Monitoring
tags:
  - already running
  - Centreon
  - "journaux d'événements"
  - lock
  - logAnalyser
  - MySQL
  - Nagios

---
[Edit]Commandes affinées et source de la solution ajoutée dans l’article[/Edit]

Si vous avez installé Nagios/Centreon, vous utilisez surement la fonctionnalité permettant d’afficher l’historique de tous les événements passés. Cependant, il arrive (notamment après un crash) que cette fonctionnalité se fige.

Les logs sont toujours visibles dans Nagios (http://@IP-Nagios/nagios/cgi-bin/history.cgi?host=all) ou directement dans les fichiers **nagios/var/nagios.log**, mais plus dans Centreon alors que cela fonctionnait avant (Si ça n’a jamais fonctionné, c’est autre chose ; probablement un problème de permissions ou de chemin lors de l’installation).

Dans mon cas, en lisant le log  dans **centreon/log/logAnalyser.log**, j’avais des lignes et des lignes avec le message suivant

```
22/1/2014 11:15:02 - logAnalyser already running...
22/1/2014 11:16:01 - logAnalyser already running...
```


Pourtant aucun processus logAnalyser n’était visible sur le serveur.

Une recherche sur Internet m’a mis sur la voie : forums.monitoring-fr.org/index.php?topic=5545.15 (lien mort, pas sauvegardé par Internet Archive)

En fait, c’est tout simplement que le logAnalyser était en cours d’exécution lors d’un plantage, et n’a pas pu libérer le lock, stocké dans la base MySQL. Pour débloquer la situation, et **après avoir revérifié qu’il ne tournait effectivement pas** :

```
mysql
use Centreon
select * from cron_operation;
+----+-----------------+---------+-------------+-------------------+--------+--------+---------+---------------------+----------+
| id | name            | command | time_launch | last_modification | system | module | running | last_execution_time | activate |
+----+-----------------+---------+-------------+-------------------+--------+--------+---------+---------------------+----------+
|  2 | centAcl.php     | NULL    |  1431338042 |                 0 | 1      | NULL   | 0       |                   1 | 1        |
|  3 | nagiosPerfTrace | NULL    |  1393761601 |                 0 | 1      | NULL   | 1       |                   1 | 1        |
|  4 | logAnalyser     | NULL    |  1430113466 |                 0 | 1      | NULL   | 1       |                 167 | 1        |
+----+-----------------+---------+-------------+-------------------+--------+--------+---------+---------------------+----------+

update `cron_operation` set running  = 0 where id = 4;

exit
```


Un petit redémarrage du démon centcore pour prise en compte et le tour est joué

```
service centcore restart
```
