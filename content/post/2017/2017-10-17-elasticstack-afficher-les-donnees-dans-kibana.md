---
title: 'ElasticStack : Visualisez vos données dans Kibana'
authors:
  - zwindler
type: post
date: 2017-10-17T11:30:19+00:00
url: /2017/10/17/elasticstack-afficher-les-donnees-dans-kibana/
image: /2017/10/elastic_3.png
categories:
  - Monitoring
tags:
  - Beats
  - Dashboard
  - ElasticSearch
  - ElasticStack
  - ELK
  - Kibana
  - Logstash

---
## Collecter, c’est bien ; visualiser, c’est mieux

Cet article fait partie d’une suite d’articles sur ElasticStack, un produit [elastic.co][1], composé des produits ElasticSearch, Logstash, Kibana et depuis plus récemment des agents Beats.

Pour ceux qui auraient raté les articles précédents, j’explique plus en détail de quoi il s’agit dans 2 articles. Et bon DevOps que je suis, tout est bien entendu entièrement automatisé par des playbooks Ansible (et oui, vous n’avez rien à faire) :

  * [ElasticStack : Déployer Kibana, Elasticsearch, Logstash & Beats avec Ansible](/2017/10/03/elasticstack-kibana-elasticsearch-logstash-beats/)
  * [ElasticStack : Collecter et exploiter des métriques provenant de nginx](/2017/10/10/elasticstack-collecter-et-exploiter-des-logs-nginx/)

## On en est où ?

![](/2017/10/elk-infrastructure.png)

Dans les deux articles précédents nous avons donc travaillé en amont d’ElasticSearch. Les données des serveurs ont été collectées, centralisées, traitées puis intégrées dans ElasticSearch. On sait faire des requêtes simples dessus via des curl.

C’est bien beau tout ça, mais on en fait quoi maintenant ? Et bien maintenant on va aller en aval et travailler avec Kibana !

## Premiers pas avec Kibana

Normalement si tout s’est bien passé, on peut maintenant se connecter à Kibana, et Kibana peut communiquer avec ElasticSearch.

L’URL par défaut est `http://@IP_MON_SERVEUR_ELK:5601`

![](/2017/10/kibana_log.png)

> Joli logo qui change de couleur pendant le chargement

S’il y a un souci de connexion entre les deux logiciels qu’on vient de citer, vous aurez rapidement un message d’erreur plutôt explicite qui vous indiquera que ElasticSearch n’est pas joignable. Parfois c’est temporaire, par exemple lorsque vous démarrez ElasticSearch il arrive qu’il mette du temps à récupérer les index mais ça sera indiqué dans le message d’erreur.

![](/2017/10/kibana_elastic_ko.png)

## Création des Index Patterns

La première page sur laquelle vous devriez tomber est une page de Management pour la création des Index Pattern. Il s’agit ni plus ni moins d’indiquer à Kibana quels sont les données (index) dans ElasticSearch nous intéressent (on peut en avoir plusieurs) et ensuite de lister les différentes colonnes pour chaque information contenue dans l’index en question.

![](/2017/10/elk1.1.png)

**Attention il s’agit là d’une notion importante** : Plus les données présentes dans un même index seront différentes (différentes sources, différents champs), plus le nombre de champs dans votre « index pattern » sera important (logique).

Ça compliquera d’autant plus la création de nouveau graphique et l’exploitation de l’outil en général. Si vous voulez ajouter un nouveau graphique, il faudra filtrer potentiellement beaucoup de données pour n’extraire que celle qui vous intéresse et EN PLUS, de nombreux champs ne vous serviront à rien du tout et compliqueront la conception des visualisation.

Dans la mesure du possible, on s’astreindra donc à séparer en amont (lors de la configuration Logstash ou Beats) les données trop différentes dans des index distincts.

Si vous avez suivi les 2 premiers tutos, ça devrait fonctionner tout seul puisque les playbooks utilisent l’index par défaut, **logstash-***. Sélectionnez @timestamp comme **Time Filter** puis cliquez simplement sur **Create**.

## Discover

L’interface d’ELK est relativement simple une fois qu’on sait à quoi sert chaque menu. Maintenant que les index sont configurés, la conception des graphiques peut commencer, dans l’onglet Discover.

Cette vue est la plus importante pour la conception des graphiques puisque c’est là que vous pourrez explorer puis filtrer vos données, pour en tirer des indicateurs pertinents à surveiller.

![](/2017/10/elk_discover.png)

Cette vue se découpe en plusieurs parties que je vais décrire ici :

* En jaune, l’index courant et l’ensemble des champs qu’il possède. Dans mon cas, j’en ai pratiquement 200 sur cet index, d’où la nécessité de ne pas trop en rajouter !
* En vert, un rapide graphique permettant de visualiser le nombre d’occurrences correspondant aux filtres et à la plage horaire sélectionnée. Très pratique pour avoir une idée du volume de données récoltées avec le filtre en cours.
* En bleu, un extract des données en elles même. On peut ainsi analyser ce qui tombe dans notre filtre, et ainsi concevoir les graphiques en fonction.
* En violet, la plage horaire sélectionnée (ici 7 jours en relatif, on peut aussi définir un intervalle fixe avec des dates/heures).
* En rouge, la grande force de l’outil => vous pouvez écrire à la main des requêtes pour filtrer en live vos données.
* En orange, les filtres en cours d’utilisation. Ici, j’ai cliqué sur la remote IP 80.74.x.x ce qui a eu pour effet d’immédiatement filtrer et restreindre à cette seule IP.

La barre de recherche s’utilise de la façon suivante : on entre les infos qu’on souhaite voir (ou ne pas voir avec « -« ) et hop, ça filtre !

![](/2017/10/elk4.png)

Une fois qu’on est content de son filtre, on peut le sauvegarder grâce au menu **Save** en haut à droite. Il suffit de lui donner un nom explicite, puis de confirmer en cliquant sur le bouton **Save** Bleu.

![](/2017/10/elk5.png)

## Visualize

Le but du jeu avant de passer à cet étape est donc de créer un ensemble de requêtes plus ou moins complexes permettant de récupérer les données qui nous sont pertinentes.

![](/2017/10/elk6.png)

L’onglet Visualize sert donc à créer des graphiques à partir de ses sources de données pertinentes (aka filtrées). Dans mon cas, je vais donc directement m’appuyer sur la recherche que je viens de sauvegarder pour ne récuperer que les données dont le type est égale à « nginx_access ».

![](/2017/10/elk7.png)

A partir de là, le 2ème gros travail commencer. Ce n’est pas si simple de trouver les champs pertinents pour visualiser nos données de manières efficaces.

Comme j’ai un peu bossé pour vous dans l’article précédent, j’ai déjà ajouté dans la configuration logstash un champ qui n’est pas présent par défaut : à savoir **geoip.ip**.

![](/2017/10/elk2.5.png)

Avec ce champ, je vais pouvoir me baser sur l’adresse IP pour déterminer plusieurs informations pour chacune des requêtes arrivant sur mon frontal nginx.

Je tire donc partie de ce champ pour réaliser un comptage de toutes les adresses IP distinctes pour l’axe des ordonnées.

![](/2017/10/elk8.png)

Pour l’axe des abscisse, dans la majorité des cas, on se contentera du temps via le timestamp.

![](/2017/10/elk9.png)

Cliquez sur le petit logo « Play » en haut pour visualiser le résultat :

![](/2017/10/elk9.5.png)

Même principe que dans « Discover », on sauvegarde la visualisation en cliquant sur le menu Save en haut à droite, puis en validant avec le bouton Save bleu.

![](/2017/10/elk10.png)
## D’autre exemples de visualisations

En sélectionnant un graphique de type « Pie Chart », avec comme Aggregation « Count » et en séparant les tranches via le terme response.keyword, on peut faire un camembert des codes retours HTML.

![](/2017/10/elk11.png)

En utilisant le module **geoip**, dont j’ai parlé plus haut, on peut créer une carte des visiteurs d’un site web :

![](/2017/10/elk11.2.png)

Vous n’êtes donc maintenant (presque) limités que par votre imagination. Je dis « presque » parce qu’il n’est, à ma connaissance, pas facile voire impossible de réaliser des opérations mathématiques sur un graphique donné. 

Un exemple : si je souhaite afficher la RAM consommée par un container Docker en Mo et non pas en octets (ce qui est illisible), a priori je ne peux pas le faire (à moins d’utiliser une obscure fonction permettant de dupliquer un index en lui appliquant une formule mathématique, bref, c’est compliqué).

Pour remédier à ça, elastic.co a sorti un outil appelé Timelion, intégré dans Kibana, mais ce n’est pas le sujet d’aujourd’hui ;-).

## Dashboard

Le plus simple maintenant ! On peut créer des Dashboard dans l’onglet Dashboard, simplement en sélectionnant les graphiques précédemment créés puis en les réagençant avec des drags and drops. E-Z !

![](/2017/10/elk_dashboard.png)

Voilà quelques uns des dashboards que j’ai créés pour les besoins de cet article pour vous donner une idée, mais on peut bien entendu faire bien plus complexe !

![](/2017/10/elk15.png)

![](/2017/10/elk16.png)

Have fun !

 [1]: https://www.elastic.co/fr/
