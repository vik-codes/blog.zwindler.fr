---
title: 'redalert : gérer les incidents avec un bot Slack'
authors:
  - zwindler
type: post
date: 2020-06-15T06:40:00+00:00
excerpt: "redalert, un sideproject de bot en python pour faire de l'incident management dans Slack. Simple et efficace, inspiré de FireFighter de ManoMano"
url: /2020/06/15/redalert-gerer-des-incidents-avec-un-bot-slack/
image: /2020/06/Enterprise-D-bridge_2371-640x266-1.jpg
categories:
  - DIY
  - Logiciel
tags:
  - Dispatch
  - Firefighter
  - Incident Management
  - ManoMano
  - Netflix
  - side project

---
Il y a quelques mois, j’ai vu passer cet article écrit par un SRE de chez ManoMano : [Incident Management with a bot][1]. Il a été pas mal partagé et il m’a beaucoup plus, car il me permettait de creuser 2 sujets qui m’intéressaient justement à ce moment-là : les bots slack et la gestion d’incidents.

Dans mon équipe actuelle, nous utilisons énormément Slack pour communiquer en interne. Au-delà du chit-chat quotidien, nous avons également pour habitude de créer des channels dédiés et d’y inviter les personnes concernées lors d’incidents sur la plateforme que nous administrons, de manière à centraliser les efforts entre les Ops, les Devs et les équipes support client.

L’idée de pouvoir avoir un tool permettant à la fois de nous éviter de gérer à la main ces incidents tout en restant dans Slack était hyper séduisante... Malheureusement, après avoir contacté l’auteur, celui-ci m’a confirmé qu’à l’heure actuelle, le tool de ManoMano n’était pas Open Source.

Moult déceptions.

## Yet another standard

Clairement, j’étais grognon à l’idée de passer à côté d’un tool qui faisait EXACTEMENT ce que je voulais. Comme je n’aime pas réinventer la roue, je suis allé voir sur les Internets ce qui se fait ailleurs.

Grosso modo, la solution qui m’a le plus plu est un outil qui a été open sourcé par Netflix et qui s’appelle **Dispatch**.

Dispatch est [un VRAI outil d’Incident Management][2], avec des workflows et de nombreuses interactions avec des outils tiers. C’est très très classe, [il y a une doc superbe][3]. Bref, c’est Netflix.

Mais ce n’était pas tout à fait ce que je voulais. Aujourd’hui, Dispatch est clairement overkill pour les besoins de l’équipe. A l’heure actuelle, un simple workflow « j’ouvre un channel, j’invite des gens, j’archive le channel » nous suffit. D’où l’idée du bot slack de ManoMano.

## Make it so

Bon... ManoMano a pondu l’idée du bot slack... j’ai toujours eu envie d’écrire un bot slack... et je suis en train de me (re)former à Python. Vous me voyez venir ?

Et c’est ainsi que naquit [Redalert, mon propre bot slack d’Incident Management][4] (très... très très) basique. 

Pour ceux qui ont un doute sur l’inspiration pour le nom, sachez que j’ai l’infâme défaut de n’avoir jamais joué à « Command and Conquer » (pas tapper), mais qu’en revanche je suis très fan de Star Trek.

![](/2020/06/Enterprise-D-bridge_2371-640x266-1.jpg)

## A quoi ça ressemble ?

Assez de teasing, voilà à quoi ressemble l’outil une fois installé. Lorsqu’un incident arrive, n’importe qui peut écrire dans le channel slack « /incident open » et une fenêtre de dialogue va s’ouvrir dans Slack avec un certain nombre d’options.

![](/2020/06/redalert_slash_incident.png)

![](/2020/06/screen_redalert.png)

> Quand on tape « /incident open » dans un channel, voilà la popup qui s’ouvre

C’est simple (voire simpliste) mais efficace.

## Ce que l’outil fait

Je ne vais pas vous copier-coller le contenu du README.md du projet, mais grosso modo les features actuelles (le « MVP » comme on dit dans le milieu) sont :

  * ouvrir une popup dans Slack via une commande « /incident open », permettant d’entrer un certain nombre d’informations puis d’ouvrir un channel Slack en fonction de ces paramètres
  * configurer soit même les différents niveaux d’incident possibles
  * ajouter de manière automatique une liste d’individus dans certains ou tous les niveaux d’incidents (de manière configurable)
  * lister tous les incidents ouverts et/ou fermés (archivés)
  * fermer un incident (en utilisant la fonction archiver de Slack)

## Ce que l’outil ne fait pas (encore)

Idéalement, dans le futur j’aimerais ajouter les fonctionnalités suivantes (quelque part entre « un jour » et « jamais »).

  * Faciliter l’installation de redalert via une application packagée slack
  * ajouter de manière optionnelle une base externalisée des incidents pour permettre des analyses a posteriori
  * une gestion du « problem management » (au sens ITIL du terme, càd relier des incidents entre eux, entre autre)
  * interagir avec des systèmes tiers tels que PagerDuty (prévenir l’OPS en astreinte), Trello, Confluence (Postmortems), ...
  * Permettre dans le dialog d’ouverture d’incident d’ajouter plusieurs personnes d’un coup (a priori [pas techniquement possible pour l’instant dans l’API Slack][5])
  * Un vrai fichier de configuration custom qui remplace les valeurs par défaut du config.py pour ne pas avoir à le réécrire complètement.

## Comment l’installer ?

Comme je suis sympa avec vous, j’ai mis à disposition sur le projet Github zwindler/redalert [toute la documentation d’installation][4].

Actuellement, le projet est distribué de 3 manières :

  * les sources du code python, que vous pouvez lancer sur n’importe quelle machine disposant de python 3.6+ avec les modules (pip) slack et flask
  * une image Docker préconfigurée, disponible sur le Dockerhub
  * un Chart que vous pouvez déployer sur Kubernetes avec Helm

Tout est décrit pas à pas dans le [README.md][4] du projet.

Je pense que le plus important a été dit. Donc en attendant vos retours => Have fun :D

## Bonus : comment ça marche ?

Je ne vais pas passer trop de temps là-dessus (quitte à faire un article un peu plus long dédié à ça une autre fois), mais l[&lsquo;API mise à disposition par Slack est relativement bien documentée][6] et il existe des modules dans la plupart des langages courants qui intègrent des méthodes pour toutes les appels qui existent sur l’API. 

Autant dire que même pour un OPS, c’est accessible, si jamais vous avez une autre idée de bot slack en tête.

Le seul vrai souci que j’ai rencontré a été que [les exemples donnés][7] pour le sdk python du client Slack le sont dans 2 versions, et que les premiers exemples de code sur lesquels je suis tombé (les plus approchant de ce que je voulais faire) sont en version 1 alors que la version actuelle est la 2 (bien sûr...).

Le code source du projet en lui-même est relativement trivial. Mon serveur Flask écoute sur 3 URLs :

  * un /, notamment pour les healthchecks dans Kubernetes
  * un /incident qui reçoit toutes les commandes « /incident open|list|close » et qui redispatche ensuite en fonction du contexte
  * un /dialog qui, comme son nom laisse penser, permet de gérer le retour POST du dialog qui est popé après le /incident open

## Bonus 2 : contribuer ?

Pour être parfaitement honnête, il y a peu de chance que je bosse énormément dessus. Ce projet a été développé sur mon temps perso initialement, en side project un peu bébête. Et même si au final, on a fini par l’adopter en production sur notre Slack pro, pour l’instant il nous suffit tel qu’il est.

Néanmoins, je suis plus qu’ouvert à toutes les propositions d’amélioration ou de contributions, dans le cas où cet outil vous plairait. 

Cela se fera en best effort et sans aucune garantie, mais si on est d’accords sur ce point, moi ça me fera plaisir de savoir que ça peut être utile à quelqu’un !

 [1]: https://medium.com/manomano-tech/incident-management-with-a-bot-7e80deb5b5e5
 [2]: https://netflixtechblog.com/introducing-dispatch-da4b8a2a8072
 [3]: https://hawkins.gitbook.io/dispatch/
 [4]: https://github.com/zwindler/redalert
 [5]: https://stackoverflow.com/questions/48523512/slack-interactive-message-menu-select-multiple
 [6]: https://api.slack.com/#read_the_docs
 [7]: https://api.slack.com/tutorials
