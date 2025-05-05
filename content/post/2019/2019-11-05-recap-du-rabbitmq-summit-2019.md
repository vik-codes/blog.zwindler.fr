---
title: 'Récap’ du RabbitMQ Summit 2019'
authors:
  - zwindler
type: post
date: 2019-11-05T12:45:09+00:00
excerpt: Récapitulatif de la conférence RabbitMQ Summit 2019 à Londres
url: /2019/11/05/recap-du-rabbitmq-summit-2019/
image: /2019/11/20191104_085806.jpg
categories:
  - conference
tags:
  - best practices
  - broker
  - conference
  - Londres
  - message
  - Rabbit
  - RabbitMQ
  - RabbitMQ summit;

---

## Des lapins partout, nous étions au RabbitMQ Summit !
  
  
Dimanche soir, je suis arrivé à Londres pour participer, avec deux de mes collègues, au RabbitMQ Summit 2019. Cette journée est dédiée à mon broker de messages préféré, RabbitMQ (et non ce n’est pas Kafka - ceci est un troll gratuit pour mes collègues).

  
Pour ceux qui n’auraient pas suivi, [j’ai déjà écris quelques articles sur le sujet](/recherche/?keyword=rabbitmq) dont une [introduction si vous débutez](/2019/04/16/suivez-le-lapin-orange-intro-et-bonnes-pratiques-dinfra-rabbitmq/).

  
Cette journée a été l’occasion de pouvoir faire le plein de bonnes pratiques, REX, et autres protips pour optimiser nos clusters.



![](/2019/11/20191104_084114.jpg) 


## Keynote
  
  
Sans surprise, la keynote d’introduction était réalisée par des membres de la core team de RabbitMQ (Diana ParraCorbacho et Michael Klishin), qui ont parlé de l’actualité du Broker.

  
Une version majeure de RabbitMQ est sortie en octobre (la 3.8) et de nombreuses des features annoncées l’an dernier sont maintenant utilisables.

  
Je suis particulièrement enthousiaste à propos des quorum queues et des métriques Prometheus natives, qui sont clairement les deux stars de cette édition, avec plusieurs talks dédiés ou y faisant référence.

  
L’ajout de features flags pour faciliter les mises à jours (présents à partir de la 3.7.20+ ou 3.8+) est clairement un autre gros point positif. Michael Klishin a officiellement indiqué que le blue/green deployment n’était désormais plus la seule méthode supportée pour mettre un cluster à jour.



![](/2019/11/20191104_092344.jpg) 


La 3.8 étant maintenant derrière nous (seulement des bugs fix sortiront à partir de maintenant), cap sur la 3.9 !

  
Dans les points importants, un travail va être réalisé pour rendre le core de chaque protocole identique. En effet, aujourd’hui, chaque protocole supporté par RabbitMQ est un module spécifique. Une refonte de l’UI est aussi prévue.

  
Dans les annonces, une version entreprise (RabbitMQ Entreprise Edition) devrait également voir le jour dans les mois qui viennent. Identique à la version communautaire dans les grandes lignes, elle intégrera des modifications supplémentaires pour faciliter l’hébergement de cluster RabbitMQ inter-connecté sur un WAN ou crossDC. Bien évidemment un support pro fera parti du package.

  
Le dernier point abordé, pour le futur, est le gros travail sur le "moteur de stockage" utilisé par RabbitMQ (pour la configuration et la persistance). Aujourd’hui, ce travail est réalisé par un projet annexe appelé Mnesia. Michael Klishin a insisté sur le fait que même si le code restait pertinent, la base de code était elle vieillissante.

  
Un nouveau projet Mnevis avait donc été lancé. Cette réécriture de 0 à pour but de mieux prendre en compte des problématiques multi DC et une meilleure reprise sur incident.

  
Même si Mnevis ne sera pas officiellement pas disponible pour tout de suite, (probablement pas avant la version 4) un prototype devrait être disponible avec une version modifiée de RabbitMQ. [Les sources de Mnevis sont disponibles ici](https://github.com/rabbitmq/mnevis). On aura certainement plus d’infos au prochain RabbitMQ Summit !



## Practical Advice for the Care & Feeding of RabbitMQ
  
  
La keynote passée, Gavin Roy a présenté un REX sur plus de 10 ans d’utilisation de RabbitMQ en production, avec les pièges dans lesquels lui et son équipes étaient tombés.

  
De soucis de code PHP qui ouvrait des connexions éphémères (coûteuses dans RabbitMQ), jusqu’à l’envoi de messages contenant des payloads (alors que AMQP propose d’ajouter des metadata), en passant par des lenteurs dues à des erreurs de configuration, le talk a été riche en bonnes pratiques (ou plutôt, mauvaises pratiques à éviter !).

  
Même si certaines erreurs peuvent sembler faciles à éviter (surtout avec le recul), c’est un de mes talks préférés de la journée, avec de nombreuses réflexions à venir, une fois rentré.



## Prometheus Export
  
  
C’est le 2ème gros sujet de la journée. J’ai assisté à la présentation de l’ajout de métriques natives au format [OpenMetrics](https://openmetrics.io/) directement dans RabbitMQ.

  
Un des gros soucis de l’interface de management actuelle et des métriques qu’elle expose est qu’il est nécessaire de disposer de privilèges important pour les consulter. Dans un contexte multi-équipes (ou multitenant), ce n’est pas pratique. Le second est un problème de performance. Actuellement l’interface de management (plugin de RabbitMQ) arrive parfois à saturation, nécessitant en cas de charge plusieurs dizaines de secondes à s’afficher.

  
Pour éviter ces soucis, certains d’entre vous utilisent peut être le rabbitmq-exporter, qui récupère les données de la management UI et les expose à Prometheus au format [OpenMetrics](https://openmetrics.io/). Cependant, ce client, tributaire de la management UI, est nécessairement également limité en cas de surcharge.

  
La vraie solution qui vient de sortir en 3.8 est donc l’exposition native de métriques au format [OpenMetrics](https://openmetrics.io/). Cet ajout a _a priori_ déjà été énormément bénéfique à RabbitMQ et son écosystème, permettant de déceler plusieurs portions de code inefficientes dans le code de RabbitMQ et même dans le code de Erlang (bugs fixés depuis).



## Après déjeuner, 2 talks... un peu décevant...
  
  
Les talks suivants ("Source oriented exchanges pattern to keep events in order" et "RabbitMQ MQTT versus EMQX") ne sont pas simples à retranscrire.

  
Le premier était très générique, sur la façon de gérer correctement un processus nécessitant que les messages soient traités dans l’ordre.

  
Le second, un peu étonnant, comparait RabbitMQ avec un produit concurrent au travers du scope MQTT et sur un usecase très précis.

Quelques points que j’ai retenu :
  
* j’ai raté un talk de Wework qui parle de sharding et qui est probablement intéressant à (re)voir (Wework’s "good enough" order guarantee, je mettrai à jour le lien)
* il existe un outil appelé MZ Tool (???) qui permet de stress-tester vos infrastructures MQTT. Ce dernier peut être piloté par Ansible ou Terraform. J’ai trouvé un projet MZ-Tools qui n’a rien à voir... Je continue à chercher.
      


## RabbitMQ at Scale
  
  
Partenaires principaux du RabbitMQ Summit, les gens de Code84 ([CloudAMQP](https://www.cloudamqp.com/)) étaient présents, en nombre ! La société est spécialisée dans l’hébergement de serveurs RabbitMQ, mais aussi de Kafka, PostgreSQL et Mosquitto en mode PaaS. La société est également connue sur son [blog technique pléthorique](https://www.cloudamqp.com/blog/index.html).

![](/2021/tweet_rmq.png)

Lovisa Johansson (qui a écrit la plupart des articles du blog, que je recommande chaudement) et Anders Bälter nous ont présenté le cheminement de leur société depuis 2012. En partant de simples API Heroku et de serveurs AWS, la plateforme hébergement maintenant les serveurs RabbitMQ de milliers de clients, tout en publiant des métriques, des logs, des alertes, vers la plupart des composants SaaS connus.

  
Ce talk a aussi été l’occasion de présenter quelques statistiques d’utilisation, notamment sur les moyennes/maximums de métriques comme le nombre de messages par secondes, le nombre de vhosts ou de policy, etc.



## Feature complete: uncovering the true cost of different rabbitmq features and configurations
  
  
Le dernier talk auquel que nous avons vu a été donné par Jack Vanlightly, qui travaille maintenant chez Pivotal (l’éditeur de RabbitMQ).

  
Ce talk a été extrêmement riche et mérite d’être revu, à tête reposée.

  
Jack Vanlightly a fait une série de bench sur plusieurs types de serveurs, avec diverses compositions de producers/consumers, types d’exchanges et d’autres paramètres moins connus.

  
Les cas étaient parfois extrêmes, mais je pense que les différents cas qu’ils illustrent s’avéreront utiles pour tuner des comportements d’apparence anormaux dans des cas réels (quel paramètre tuner en fonction du nombre de consumers ou de la latence du réseau par exemple).



## Conclusion
  
  
Malgré notre envie de rester jusqu’au bout, nous devions partir pour arriver à l’heure pour notre vol retour.

  
Ce RabbitMQ Summit a été l’occasion de discuter avec d’autres utilisateurs de RabbitMQ et de revoir les bonnes pratiques avec des professionnels qui en hébergent des milliers (600000 connexions actives chez CloudAMQP tout de même !).

  
Ça a aussi été l’occasion de voir que nous n’étions pas aussi "petits" que nous pensions dans notre usage de RabbitMQ, même si nous sommes très loin des limites de l’application dans nos cas d’usage !

  
Les joies du Dual Tracks ont fait que nous avons forcément raté certains talks que nous aurions voulu voir... Heureusement qu’il y aura les vidéos sur YouTube dans quelques jours/semaines !

  
A refaire, donc !
