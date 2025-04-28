---
title: '[Tutoriel] Shinken 2.4  sur CentOS/RHEL 7 – partie 1'
authors:
  - zwindler
type: post
date: 2015-09-22T16:30:24+00:00
url: /2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-1/
image: /2015/09/shinken.png
categories:
  - Monitoring
tags:
  - Haute disponibilité
  - modules
  - Nagios
  - Répartition de charge
  - Shinken
  - Shinken 2.4
  - Shinken Solutions

---
Cet article fait parti d’une série d’articles (au moins 3) que je vais publier sur le sujet et que j’ai séparé pour les rendre un peu plus digestes. Je vous conseille quand même de ne pas en sauter pour bien comprendre de quoi on parle ;-) :

* [Partie 1 : Présentation de Shinken](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-1/)
* [Partie 2 : Installation de Shinken 2.4 sur RHEL/CentOS 7](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-2/)
* [Partie 3 : Configuration initiale de Shinken 2.4 sur RHEL/CentOS 7](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-3/)

Note : Pour les plus pressés ou qui connaissent déjà bien Shinken, la partie _technique pure_ commence à partir du 2ème article.

## Pourquoi Shinken ?

Ça fait un moment déjà que je parle de Shinken sans pour autant l’avoir vraiment présenté. Le sujet avait déjà été traité par pas mal de gens relativement calés comme Nicolargo pour ne citer que lui (et quelques articles de Monitoring-FR) et j’estimais du coup ne pas avoir forcément beaucoup à ajouter.

Cependant, avec la sortie avant l’été de la version 2.4, ainsi que les récentes amélioration sur l’interface, j’ai voulu revenir sur le sujet car ça a pas mal bougé depuis, surtout la 2.0 qui a changé pas mal de choses !

## Ok, alors. Shinken c’est quoi?

Je suis tombé par hasard sur Shinken pratiquement à son début. Par pur hasard, je m’intéressais justement à des alternatives hautement disponibles à Nagios à l’époque et je suis tombé [sur la v0.1 (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20200224065218/http://www.gabes.fr/jean/2010/05/31/shinken-la-0-1-est-arrivee/).

Selon les propres mots de Jean Gabès son créateur en 2011, alors [interviewé par Nicolargo](http://blog.nicolargo.com/2011/08/interview-de-jean-gabes-le-createur-de-shinken.html).

> Shinken est un outil de supervision, une implémentation de Nagios en Python 'from scratch' qui a pour objectifs principaux de simplifier la vie des administrateurs de grands parcs et de coller au mieux à l’évolution de l’IT des dix dernières années, et si possible préparer les dix prochaines...

Si la définition a probablement un peu évolué aujourd’hui, les grandes lignes sont là et présente bien la philosophie du projet telle quelle l’était au départ. Et c’est probablement cette philosophie qui a permis à Shinken de gagner autant de point parmi la communauté supervision open source, surtout face à un Nagios en perte d’identité.

Pour les plus curieux, on découvre aussi pas mal de l’âme du projet [sur le blog de naparuba](https://web.archive.org/web/20190320085832/http://www.gabes.fr/jean/category/shinken/) (Jean Gabès donc).

## En quoi Shinken est mieux que Nagios ?

J’ai déployé mon premier Shinken sur un serveur complètement saturé qui surveillait un parc de développement de quelques milliers de serveurs.  
A l’époque, ce qui a convaincu la direction c’est surtout que Shinken étant beaucoup plus économe en ressources que Nagios : nous avons pu continuer à surveiller le parc avec le même serveur qui a retrouvé une seconde vie et avec _pratiquement aucune interruption_ puisque tout était compatible (agents, plugins, configuration des serveurs supervisés)

C’était très réducteur par rapport aux nombreux avantages de Shinken par rapport à Nagios, mais ça a permis de commencer à mettre le doigt dans l’engrenage. Voici quelques qualités que j’aime mettre en avant  :

  * Compatible avec la configuration, les agents et les plugins d’un Nagios existant
  * Des performances brutes bien meilleures que Nagios 3, la référence open source à l’époque
  * Les _root problems_ : meilleure gestion de la détection automatique des vrais problèmes
  * Multiplateforme - Shinken fonctionne sous Linux, Windows mais aussi sur Android. Vous pouvez l’installer sur un serveur ou un EeePC
  * Des mécanismes d’aide au démarrage via des « packs » préconfigurés pour un type d’équipement donné (AIX, Linux, baie EMC, ...)
  * Une architecture distribuée : découpage des fonctions principale du programme en modules, ce qui permet entre autre 
      * De la répartition de charge gérée nativement
      * De la haute disponibilité native
      * Une gestion des DMZ et des sites distants native

## Time to go live

Fort de ces arguments, Shinken a réussi à trouver une place dans le paysage de la supervision open source. Une version 1 est sortie, des prix d’innovations ont été gagnés, et Jean Gabès a décidé de se lancer totalement dans l’aventure en créant Shinken Solutions courant 2013.

Le cœur de Shinken reste libre et communautaire, mais une version entreprise est lancée avec notamment des fonctionnalités de découvertes avancées et d’alimentation de référentiel par le biais de connecteurs (ex. vers VMware, vers la CMDB, vers un Active Directory, etc). La société **Shinken Solutions** offre également un support aux entreprises qui le souhaitent.

## L’architecture distribuée : l’argument massue

Mais assez parlé du projet !

Pour débuter sur Shinken, la première chose à faire est de comprendre son architecture. Si la configuration et les plugins sont compatibles Nagios, Shinken n’en est pas moins très différent de son monolithique ancêtre.

Même si vous êtes un expert de Nagios, il faut bien comprendre les concepts fondateurs avant de s’y lancer (voir [la doc](https://shinken.readthedocs.org/en/latest/09_architecture/the-shinken-architecture.html#architecture-the-shinken-architecture)).

![](/2015/09/shinken-architecture.png)

Pour résumer :

  * l’**arbiter** est le chef de l’équipe. Il a la vision globale des démons et des modules. Du coup, il est responsable de découper la configuration générale vers les différents démons et gère la répartition de charge et la haute disponibilité.
  * le **scheduler** c’est l’ordonnanceur. Il réparti les checks et les notifications à réaliser respectivement entre les _pollers_ et les _reactioners_.
  * le **poller** récupère les checks actifs qu’il doit effectuer sur l’infrastructure depuis les ordres du _scheduler_ et renvoie le résultat au broker
  * le **receiver** reçoit les checks passifs provenant des serveurs et renvoie les résultat au broker (au même titre que le _poller_)
  * le **reactionner** déclenche les envoie de notifications et gère les _events handlers_.
  * le **broker** centralise et consolide les informations renvoyées par les _pollers_ et les _receivers_. On peut ensuite exploiter ces informations à l’aide des modules du broker qui présentent l’information (interfaces graphiques, exports de données, logs, ...)

## La suite ?

Si vous avez digéré tout ça, vous êtes prêt pour la [partie suivante](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-2/).
