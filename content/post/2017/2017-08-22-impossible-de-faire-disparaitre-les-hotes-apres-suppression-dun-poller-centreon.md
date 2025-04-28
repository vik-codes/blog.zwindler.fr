---
title: 'Impossible de faire disparaitre les hôtes après suppression d’un poller Centreon'
authors:
  - zwindler
type: post
date: 2017-08-22T11:45:21+00:00
url: /2017/08/22/impossible-de-faire-disparaitre-les-hotes-apres-suppression-dun-poller-centreon/
image: /2017/08/centreon_logo.png
categories:
  - Monitoring
tags:
  - Centreon
  - centreon-broker
  - centreon-engine
  - Nagios
  - NDO
  - ndo2db
  - ndomod
  - poller

---
## Des hôtes qui n’existent plus sont toujours visible dans l’interface de Centreon

Je plante le décor : Vous avez une infrastructure supervisée avec Centreon. Cool :). Vous aviez des collecteurs distants (aka poller) et vous avez décidé de les supprimer finalement (je sais pas, imaginons que finalement le client décide d’annuler le projet par exemple, même si ça n’arrive jamais).

Et là, surprise. Vous n’aviez pas remarqué avant d’avoir définitivement supprimé la machine poller et toute sa configuration, mais les hôtes précédemment supervisés sont toujours visibles dans l’interface de Centreon, avec leur état en date de la dernière fois qu’un check a eu lieu, indéfiniment.


![](centreon_old_pollers_01.png)

> Ici, une capture d’écran du 17, avec des serveurs qui ont répondu la dernière fois le 16 !

Pourtant, ils n’existent plus dans votre configuration !! Tout est désactivé (ou supprimé). Vous ne voyez pas ce que vous pouvez faire de plus !

## Back in time

Il faut déjà se rappeler comment marche Centreon, dans un premier temps.

Historiquement, Centreon se basait sur Nagios. Et Nagios est un programme des années 2000, monolithique, codé en C, et qui ne dispose pas, par conception, de stockage pour historiser les états des serveurs surveillés.

Ça peut paraître fou aujourd’hui, mais Nagios n’a pas de base de données ! L’ensemble des états _à un moment donné_ des serveurs était (est) stocké dans un fichier plat, tout le temps réécrit et que vous pouvez trouver dans un sous répertoire de nagios (var/status.log).

![](/2017/08/nagios_01.png)

> Les premières lignes du status.log

Cette méthode de fonctionnement « simple » (l’interface HTTP en CGI a juste à lire le fichier plat pour afficher les états des serveurs) est catastrophique pour les performances. J’ai vu des contextes où ce fichier était stocké en RAM via un ramdisk pour essayer de supporter un peu mieux la charge...

Conscients du manque qu’occasionne l’absence de base de données pour historiser l’état des serveurs au delà de leur état instantané, les gens de chez Nagios ont créé un connecteur externe (le « broker » ndo2db) qui permet de transmettre une copie des résultats à une base de données (MySQL le plus souvent mais je me demande si il n’y a pas aussi Oracle ?). [Le modèle de la base NDO est accessible sur le site de Nagios][3].

## Où je veux en venir avec tout ça ?

Ce broker externe a été un peu détourné de son but initial par plusieurs projets, dont Centreon, qui l’a utilisé en tant que source principale pour afficher les status des serveurs. Utiliser la base NDO comme source principale a un 2ème avantage : il est possible d’agréger plusieurs serveur Nagios dans une même base de données. On a donc la possibilité de gérer plusieurs serveur depuis une même interface => c’est le principe utilisé par les collecteurs de Centreon.

Le collecteur par défaut (Central) est composé du cœur de Centreon lui même gérant l’interface et la configuration de tous les pollers ainsi que de la base NDO et du connecteur NDO2DB. Les pollers eux ne sont que des moteurs Nagios, leur configuration « Nagios » est générée par le Central, et les données sont collectées via ndomod (le connecteur qui envoie les données sur le ndo2db).  
[Avant de me prendre la remarque, ce que je dis ici n’est plus tout à fait vrai car Centreon et réécrit depuis longtemps tous ces composants, notamment centreon-broker pour ndo2db, centreon-engine pour le moteur Nagios. Mais le principe reste le même]

Comme la base contenant la configuration des pollers est distincte de la base NDO, il est « normal » que l’inactivation d’un poller n’ait pas d’impact sur le contenu de la base NDO. NDO ne stocke des données venant des serveurs Nagios, au fil de l’eau, et n’a aucune connaissance de la configuration dans Centreon...

## La vraie méthode

Si vous n’avez pas encore tout pété comme je le décris dans le premier paragraphe, vous serez content d’apprendre qu’il existe une meilleure méthode. La « vraie » méthode (à moins qu’il y en ait encore une autre que je ne connais pas) est décrite dans ce post que j’ai retrouvé sur le forum Monitoring-fr (lien mort, pas sauvegardé par Internet Archive).

David GUENAULT (un des piliers de Monitoring-fr et qui a contribué sur plusieurs projets) nous donne la solution :

> bah en fait c’est tout simple  
> tu réaffecte tes hôtes sur le poller principal :
> 
>   * configuration->hosts puis filtre sur le poller que tu veux enlever
>   * selection des hôtes
>   * dans la combo => massive change
>   * dans la combo monitored from => tu selectionne ton central et validation
> 
> tu supprimes ensuite le poller dans l’interface de centreon :
> 
>   * tu supprime ta config ndo relative au poller que tu veux enlever : configuration -> centreon -> ndomod
>   * tu supprime le poller dans : configuration->centreon->pollers
> 
> tu pousses ta configuration : configuration -> nagios -> generate

## Bon et si c’est trop tard ?

Mais si vous êtes sur cet article c’est peut être que c’est déjà trop tard et que vous n’avez plus moyen de réaliser la procédure ci-dessus ?

Et bien là, pas le choix. Il va falloir aller bidouiller la base de données NDO !

Le plus simple est de se connecter directement via le shell mysql depuis votre serveur Central. Dans la base de données NDO, on peut donc chercher les instances existantes :

```
select * from nagios_instances;
+-------------+---------------+----------------------+
| instance_id | instance_name | instance_description |
+-------------+---------------+----------------------+
|           1 | Central       |                      |
|           3 | Poller1       |                      |
|           4 | Poller2       |                      |
|           5 | Poller3       |                      |
+-------------+---------------+----------------------+
```


Dans mon cas, c’est Poller1 que j’ai supprimé. Pour essayer de ne pas trop faire n’importe quoi, je préfère toujours regarde un peu ce que je compte modifier avant de le faire ;-)

Je liste tous les objets de Nagios, puis je compare avec ceux de mon instance 3.

```
SELECT count(*) FROM nagios_objects;
+----------+
| count(*) |
+----------+
|    11820 |
+----------+
1 row in set (0.00 sec)

SELECT count(*) FROM nagios_objects where instance_id = 3;
+----------+
| count(*) |
+----------+
|      815 |
+----------+
1 row in set (0.00 sec)
```


Connaissant mon infra, cela parait cohérent. Le Poller1 est un petit poller peu chargé. Je peux donc utiliser ma baguette magique : on a de la chance, NDO prévoit un « flag » is_active qui permet d’activer ou non un objet. Et il se trouve que Centreon gère correctement ce flag. Pour cacher nos hôtes fantômes dans Centreon, il suffit juste de les désactiver avec la commande suivante :

```
UPDATE nagios_objects SET is_active=0 WHERE instance_id = 3;
```


Normalement c’est quasi-instantané. Tous les hôtes précédemment liés au Poller1 doivent disparaître de l’interface.

Et la même en un peu plus chirurgical :

```
select object_id,instance_id,name1,is_active from nagios_objects where name1 like &quot;VIEUX_SERVEUR_OUBLIE_HS&quot;;
+-----------+-------------+-------------------------+-----------+
| object_id | instance_id | name1                   | is_active |
+-----------+-------------+-------------------------+-----------+
|      6462 |           4 | VIEUX_SERVEUR_OUBLIE_HS |         1 |
|      6472 |           4 | VIEUX_SERVEUR_OUBLIE_HS |         1 |
+-----------+-------------+-------------------------+-----------+

UPDATE nagios_objects SET is_active=0 where name1 like &quot;VIEUX_SERVEUR_OUBLIE_HS&quot;;
Query OK, 2 rows affected (0.01 sec)
Rows matched: 2  Changed: 2  Warnings: 0
```


## « J’aime beaucoup les zèbres, les rayures sont bien parallèles. »

J’ai eu le plaisir récemment de ré-écouter le sketch de Pierre Desproges : « Le maniaque ». Voilà la toute première phrase du sketch :

> « Je ne suis pas à proprement parler ce qu’on appelle un maniaque. Simplement j’aime que tout brille et que tout soit bien rangé. »

Si vous non plus, vous ne pouvez pas vous résoudre à laisser trainer dans NDO des milliers d’objets, certes inactivés, mais toujours bien présents, cachés sous le tapis, la suite de cet article est pour vous (ou si vous êtes simplement curieux).

Pour descendre un peu plus dans les arcanes de NDO, je vous propose de regarder un peu ce qu’on peut trouver avec les requêtes suivantes :

```
select host_id,instance_id,display_name
from nagios_hosts
where instance_id != 1 limit 10;
+---------+-------------+--------------------+
| host_id | instance_id | display_name       |
+---------+-------------+--------------------+
|   32149 |           2 | AAAAAA-HHHHHH01    |
|   32157 |           2 | AAAAAA-DADADADAD02 |
|   32150 |           2 | AAAAAA-DAD02       |
|   32146 |           2 | AAAAAA-GGGG        |
|   32151 |           2 | AAAAAA-DDDDDA      |
|   32152 |           2 | AAAAAA-DDDDDB      |
|   32153 |           2 | AAAAAA-EEEE02      |
|   32154 |           2 | AAAAAA-FFFFFFF02   |
|   32155 |           2 | AAAAAA-FFFFFF02    |
|   32156 |           2 | AAAAAA-UUUUUUUUU01 |
+---------+-------------+--------------------+
10 rows in set (0.00 sec)

select object_id,instance_id,name1,name2,is_active from nagios_objects where instance_id != 1 limit 10;
+-----------+-------------+------------------+-------+-----------+
| object_id | instance_id | name1            | name2 | is_active |
+-----------+-------------+------------------+-------+-----------+
|      3307 |           0 | XXXXXXXXXX_ILO   | ping  |         0 |
|      5365 |           3 | check_icmp       | NULL  |         0 |
|      5366 |           3 | AAAAAA-CCC01     | NULL  |         0 |
|      5367 |           3 | 24x7             | NULL  |         0 |
|      5368 |           3 | AAAAAA-BBBBBA    | NULL  |         0 |
|      5369 |           3 | AAAAAA-BBBBBB    | NULL  |         0 |
|      5370 |           3 | AAAAAA-AAA       | NULL  |         0 |
|      5371 |           3 | AAAAAA-SAVE      | NULL  |         0 |
|      5372 |           3 | AAAAAA-SGBD01    | NULL  |         0 |
|      5373 |           3 | AAAAAA-VMOTION01 | NULL  |         0 |
+-----------+-------------+------------------+-------+-----------+
10 rows in set (0.01 sec)

select service_id,host_object_id,instance_id,display_name
from nagios_services
where instance_id != 1 limit 10;
+------------+----------------+-------------+------------------+
| service_id | host_object_id | instance_id | display_name     |
+------------+----------------+-------------+------------------+
|     213526 |           4686 |           2 | BasculeClusterHA |
|     213527 |           4686 |           2 | ping             |
|     213528 |           4687 |           2 | BasculeClusterHA |
|     213529 |           4687 |           2 | ping             |
|     213530 |           4688 |           2 | ping             |
|     213678 |           4669 |           2 | /appli           |
|     213531 |           4689 |           2 | ping             |
|     213532 |           4700 |           2 | ping             |
|     213533 |           4703 |           2 | ping             |
|     213534 |           4704 |           2 | ping             |
+------------+----------------+-------------+------------------+
10 rows in set (0.00 sec)

select nagios_hosts.display_name,nagios_services.display_name,nagios_services.instance_id
from nagios_hosts,nagios_objects,nagios_services
where nagios_hosts.host_object_id = nagios_objects.object_id
and nagios_services.host_object_id = nagios_objects.object_id
and nagios_services.host_object_id in
(select host_object_id from nagios_hosts where instance_id = 3) limit 10;
+-----------------+-------------------------------+-------------+
| display_name    | display_name                  | instance_id |
+-----------------+-------------------------------+-------------+
| SRV             | BasculeClusterHA              |           3 |
| SRV             | check_http_aaaa               |           3 |
| SRV             | check_mountpoint_cifs_log     |           3 |
| SRV             | check_mountpoint_cifs_spl     |           3 |
| SRV             | ping_lan                      |           3 |
| SRV2            | BasculeClusterHA              |           3 |
| SRV2            | ping_lan                      |           3 |
| SRV3            | BasculeClusterHA              |           3 |
| SRV3            | ping_lan                      |           3 |
| ILO             | ping_lan                      |           3 |
+-----------------+-------------------------------+-------------+
10 rows in set (0.01 sec)
```


[Aparté]Je pense qu’il faut que je trouve un module WordPress pour pseudonymiser les données automatiquement, je me fatiguerais moins à changer le nom des serveurs...[/Aparté]

Comme vous pouvez le constater, il y en a partout : c’est terrible !

```
DELETE FROM nagios_hosts WHERE instance_id =3;
DELETE FROM nagios_services WHERE instance_id =3;
DELETE FROM nagios_hostgroups WHERE instance_id =3;
DELETE FROM nagios_servicegroups WHERE instance_id =3;
DELETE FROM nagios_objects WHERE instance_id =3;
```

![](/2017/08/boom.gif)

 [3]: https://assets.nagios.com/downloads/nagioscore/docs/ndoutils/NDOUtils_DB_Model.pdf
