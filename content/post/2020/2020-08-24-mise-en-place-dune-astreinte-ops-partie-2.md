---
title: 'Mise en place d’une astreinte OPS – partie 2'
authors:
  - zwindler
type: post
date: 2020-08-24T06:05:00+00:00
excerpt: "Mise en place d'une astreinte, partie 2 qui se concentre sur la conception de l'astreinte et le choix des outils pour la réaliser"
url: /2020/08/24/mise-en-place-dune-astreinte-ops-partie-2/
image: /2020/07/on-call-helmet.png
categories:
  - Droit
  - Monitoring
tags:
  - alerting
  - astreinte
  - gestion des incidents
  - grafana
  - prometheus

---

## "J’peux pas, j’suis d’astreinte"
  
Voici la seconde partie de mon (gros) article dédié à la mise en place d’une astreinte, dans le cadre du maintien en conditions opérationnelles d’un service informatique. Dans la première partie ([disponible ici si vous l’avez loupé](/2020/08/17/mise-en-place-dune-astreinte-partie-1/)), j’ai introduis ce qu’était réellement une astreinte, pourquoi on en met en place et enfin les textes en vigueur.

Dans cette deuxième partie, je vais donc rentrer un peu plus dans le concret.

Pour rappel, il y a 2 ans, j’ai intégré une équipe d’ingénieurs systèmes cloud qui venait de se créer. Quand les premiers produits et les premiers clients sont arrivés en production, le besoin d’assurer la continuité d’activité s’est fait sentir. Et donc, par extension, le besoin d’une astreinte.

J’ai donc eu la chance de pouvoir participer, étant directement concerné (et surtout un peu renseigné sur le sujet) à l’élaboration de cette astreinte. Ça a été l’occasion de traiter directement les aspects suivants :
  
* problématiques droit du travail
* organisationnel
* implémentation technique


## Concevoir son astreinte
  
### Comment organiser les astreintes ?

Après la compensation (récupération ou rémunération), c’est souvent LE gros sujet quand on met en place une astreinte.

Dans tous les cas, il n’est pas souhaitable de mettre 365j/an une seule et même personne d’astreinte ; il faut définir un roulement.

Pour le roulement, est-ce qu’une même personne est d’astreinte toute la semaine ? Seulement quelques jours ? Est-ce que tous les jours, on change ?

Dans le premier cas, les périodes d’astreinte sont plus espacées, mais plus longues (et potentiellement génératrices de plus de fatigue). Dans le dernier, même en cas de semaine chaotique, le changement régulier permet de mieux répartir la fatigue entre astreinteurs, mais on est très souvent d’astreinte (pendant de courtes périodes).

Est-ce que l’astreinte va concerner une journée complète de 24h, ou au contraire, considère-t-on que la journée l’équipe d’exploitation peut gérer les incidents, et l’astreinte à juste vocation à prolonger les horaires de bureaux ?

Ces questions ne sont pas anodines.

Au-delà de l’impact que le fait d’être d’astreinte a sur la vie privée (on ne peut pas faire autant de choses que l’on veut quand on est d’astreinte, c’est pour ça qu’on est compensé...), cela peut avoir des effets très importants sur l’organisation de l’équipe.


### Pourquoi ça peut coincer ?

Pour expliciter un peu où je veux en venir, prenons un exemple. Imaginons qu’une équipe de 4 OPS décide de créer une astreinte informatique 7j/7. Les incidents de la journée sont traités par l’équipe et en dehors des horaires de bureau (18h => 9h le lendemain), l’astreinteur prend le relais.

L’astreinteur prend son astreinte le vendredi 18h. Pas de chance, le week end est chaotique ! Des appels ont lieu le samedi et le dimanche, nécessitant des interventions à chaque fois.



![](/2020/07/astreinte_cas1.png) 

A aucun moment du week end, l’astreinteur n’a eu ses 35h de repos hebdomadaire consécutives.

Dans ce cas un peu extrême (mais vécu IRL), le code du travail l'empêche de reprendre le travail que mardi matin. Son absence lundi provoque un déséquilibre dans l’organisation de l’équipe...

Le problème ne se limite évidemment pas au week end. On peut avoir le genre de problèmes si les appels d’astreinte ont lieu la nuit (un à 23h, l’autre à 5h par exemple).

Et le problème est exacerbé si en plus, les appels continuent de pleuvoir pendant la journée. Dans ce cas, si on continue à avoir des alertes en journée, le compteur de repos n’arrive jamais à 11h.



![](/2020/07/astreinte_cas2.png) 


Quelle que soit l’organisation que vous choisissez, il est dans tous les cas impératif de se débrouiller pour que les appels arrivent le moins souvent possible (travailler pour réduire les alertes intempestives).
  
Il n’y a qu’en travaillant sur la réduction du nombre d’incidents qu’on peut réussir à impacter le moins possible l’organisation de l’équipe "de jour".

## Quel outillage pour réussir son astreinte ?
  
Je n’imagine pas une seule seconde une astreinte où l’on aurait pas "le kit de l’astreinteur". Sauf à imposer à l’astreinteur d’être assigné à résidence, ce qui va à l’encontre de la définition de l’astreinte je pense, il est nécessaire pour l’astreinteur OPS d’avoir :

* PC portable
* smartphone
* connexion 4G de qualité (je résiste à insérer un troll 5G).
      
  
Ces 3 items fonctionnent ensemble. Le smartphone permet de recevoir les appels et les alertes automatiques (via la 4G). Le PC portable permet d’y remédier en se connectant rapidement sur l’infra, via le modem 4G du smartphone.

On pourrait également considérer qu’un astreinteur pouvant être seul, il est nécessaire qu’il dispose d’un [PTI/DATI (protection travailleur isolé)](https://fr.wikipedia.org/wiki/Protection_du_travailleur_isol%C3%A9). Ça serait particulièrement vrai dans le cas où l’astreinte nécessite des interventions sur site (en DC par exemple), où un accident, hors des horaires de bureaux, pourrait être dramatique.

Bon, ça, c’est le strict minimum.

Si on se contente de ça, on va avoir une astreinte qui subit. Les astreinteurs seront prévenus des incidents par les clients (ou le management) et il sera parfois trop tard pour réparer la situation.

Mettre en place une astreinte efficace nécessite donc quasi obligatoirement d’avoir une plateforme de supervision la plus complète et la plus pertinente possible


### Surveiller et alerter en cas de problème

D’abord, ça permet de ne plus subir.

L’astreinteur est prévenu de manière automatique qu’un incident est en cours. Ça permet de retirer un facteur humain dans la chaîne d’intervention (attendre que quelqu’un se plaigne du souci et pense à prévenir la bonne personne) et donc de gagner du temps.

Parfois, on peut même être prévenu **avant** la catastrophe (eh, ho, ton disque il est bientôt plein là !).

On devient donc proactif.

Ensuite, ça permet, en cas d’incident grave qu’on a pas pu éviter, de savoir exactement ce qui s’est passé et quand. Sans supervision (ou sans métriques pertinentes), impossible de faire un diagnostic correct de ce qui s’est passé et d’engager des actions correctives pour que ça ne se reproduise plus (post-mortem).

Toute la difficulté de l’exercice repose donc dans l’exhaustivité et la pertinence des métriques MAIS la parcimonie des alertes. Pas assez d’alertes, c’est des clients mécontents, mais trop d’alertes, c’est pire... l’astreinteur sera sollicité trop souvent...

### Alert fatigue
  
  
Au delà de la simple fatigue provoqué par trop d’alertes (et des conséquences que ça peut avoir dans l’équipe comme je l’ai exposé plus haut), ce surplus a un autre effet pervers.

S’ils sont constamment noyés dans des alertes, les astreinteurs vont s’y habituer et cela va inexorablement les conduire à les ignorer. Ce ne sera pourtant pas par flemme ni par manque de professionnalisme.

En fait, le phénomène est connu sous le terme d’"Alert fatigue", que vous connaissez peut-être mieux depuis votre tendre enfant au travers la fable du garçon criant au loup.

> Alarm fatigue or alert fatigue occurs when one is exposed to a large number of frequent alarms (alerts) and consequently becomes desensitized to them. Desensitization can lead to longer response times or missing important alarms. [https://en.wikipedia.org/wiki/Alarm_fatigue](Page wikipedia de l’Alarm fatigue)
  
Concrètement, dans le cas des alertes automatiques, trop d’alertes risque de conduire le cerveau des administrateurs à ignorer un problème important en pensant que c’ est "une erreur normale, habituelle".

Il va donc être crucial de n’alerter l’administrateur en astreinte que quand c’est réellement nécessaire.

## Implémenter l’astreinte
  
  
Maintenant qu’on a bien les idées claires sur ce qu’on doit mettre en place, je vous présente maintenant des solutions que nous avons envisagé (voire retenu).
  
Cela n’a pas vocation a être une réponse universelle, mais ça convient aux besoins et aux contraintes que nous avions.

### L’organisation de l’astreinte
  
  
L’idée était de trouver un compromis entre :

* fatigue
* risque d’absence (à cause du repos quotidien ou hebdomadaire)
* répétitions pas trop régulières
      
  
Pour toutes les raisons que j’ai cité dans le chapitre sur la conception, le roulement qui nous a paru le plus pertinent, et que nous avons mis en place est le suivant :



![](/2020/07/astreinte_planning.png) 

Cette organisation permet de garantir que :
  
* si jamais le repos hebdo n’a pas pu être pris en entier, le changement d’astreinteur le lundi lui permet de se reposer
* les appels en journée ne gênent pas la prise du repos quotidien au cas où il n’a pas pu être pris pendant la nuit précédente
* A 5, on a en moyenne 2 semaines sans aucune astreinte, puis une période de 3 ou 4 jours
      
  
Ceci permet de garantir donc à la fois les repos et nous parait être un bon compromis entre fréquence et durée des astreintes.

### Les outils de la chaîne de supervision
  
  
Le choix de l’outil dépendra obligatoirement du contexte. Si vous travaillez dans une équipe réseau, vous n’aurez pas les mêmes besoins et donc pas les mêmes outils qu’une équipe d’exploitation cloud.
  
Sans citer directement le nom des produits que nous utilisons, je vais vous donner une liste des types d’outils que nous avons mis en place :
  
  
* Un groupe de serveurs [Prometheus + Thanos](/2020/04/13/decouvrir-prometheus-et-grafana-par-lexemple/) pour collecter et stocker les métriques de nos applications dans Kubernetes, mais aussi des services de notre cloud provider (IaaS, SaaS, DBaaS) et des middlewares que nous gérons nous-même (message brokers, bases NoSQL)
* Un outil d’alerting, AlertManager, le composant d’Alerting de Prometheus
* Une plateforme de visualisation [Grafana](/2020/04/13/decouvrir-prometheus-et-grafana-par-lexemple/) qui nous permet de visualiser les métriques provenant de différentes sources (majoritairement Prometheus, mais aussi les métriques du cloud providers)
* Une plateforme pour centraliser les logs des applications (ex. Splunk/[ElasticStack](/recherche/?keyword=ElasticStack))
* Un outil de supervision externe (ex. Pingdom/StatusCake) pour visualiser l’accès aux services web que nous exposons sur Internet depuis plusieurs points dans le monde
* Un outil d’APM (Application Performance Monitoring, ex. AppDynamics/Dynatrace) pour valider que le ressenti des utilisateurs ne se dégrade pas (plus pernicieux que la coupure franche)
* Un outil pour communiquer en temps réel avec les équipes (chat+audio+visio, de type Teams/Slack/Discord).
      
  
Pour le dernier point, Slack nous était tellement utile pour gérer les incidents que j’ai même créé un bot pour créer des channels dédiés pour chaque incident et y inviter les personnes concernées (managers, ops, call center). Si ça vous intéresse, [ça s’appelle redalert, c’est open source](https://github.com/zwindler/redalert) et j’en parle dans cet article :

* [redalert : gérer les incidents avec un bot Slack](/2020/06/15/redalert-gerer-des-incidents-avec-un-bot-slack/)


### One tool to rule them all
  
  
Comme vous pouvez le voir, ça fait quand même beaucoup de types d’outils différents. Et même si les éditeurs tentent de vous convaincre que vous pouvez tout faire avec un seul outil, c’est probablement faux dès que votre contexte est un peu complexe.
  
Cependant, pour éviter de se retrouver avec un trop grand nombre de sources de données distinctes, le mieux est de remonter toutes les alertes vers une seule et même plateforme :
  
  
* Un outil de réponse aux incidents (tel que OpsGenie/PagerDuty par exemple). L’outil de réponse aux incidents permet de gérer les rotations de notre équipe d’astreinte, l’éventuelle escalade, d’avoir des métriques de base sur les incidents, leur provenance et leur durée, etc. Mais le plus important : de notifier la personne d’astreinte sur différents types de canaux (notification push sur smartphone, SMS, appel vocal via TTS, slack, ...), de manière entièrement configurable.
      
  
Cet outil est vraiment la pièce maîtresse, qui apporte la cohérence à tout le reste. Choisissez donc le bien !

## Qu’est ce qu’il manque ?
  
  
Vous aurez très certainement besoin de sortir des informations (dashboards, statistiques) sur les incidents du mois (pour suivre la charge, la fatigue des équipes, gérer la paie si les heures d’intervention sont payées ou récupérées).
  
Généralement, on peut utiliser le reporting intégré à l’outil de réponse aux incidents, mais c’est souvent assez pauvre.
  
Comme nous voulions pouvoir faire des stats et "déclarer" les durées des astreintes ainsi que leur nombre aux RHs (pour calculer les récupérations), nous avons pris le parti de tenir à jour nous-même un fichier des interventions.



![](/2020/07/astreinte_saisie.png) 


Cette feuille de calcul, assez riche (avec beaucoup de macros et de formules magiques), nous permet d’avoir toutes les données pour ensuite calculer tous les indicateurs dont nous avons besoin.

Actuellement, la seule chose qui pourrait manquer est un outil pour calculer si le repos quotidien/hebdomadaire a été respecté ou non.

Ceci pourrait être fait via la feuille de calcul (puisqu’on a toutes les infos) mais n’est pas très user friendly (ni trivial à implémenter).

J’ai demandé sur Twitter s’il existait un outil pour faire ça, mais a priori rien n’existe "out of the box"...

![](/2021/tweet_astreinte.png)

## Et vous, vous faites comment ?
  
  
Enfin fini ! Je suis bavard, je sais ;). Mais comme vous avez pu le voir, c’est un sujet aussi complet que complexe.

Cependant, ces deux posts n’étaient que ma vision propre de l’astreinte. Je suis sûr que vous avez vous aussi des besoins et des contraintes différentes.

Donc vraiment (encore plus que d’habitude) n’hésitez pas à utiliser les commentaires pour donner votre avis et nous parler de votre propre organisation.

Ça pourra en aider d’autres :).
