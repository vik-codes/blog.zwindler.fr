---
title: Publier sur le WAN la WebUI de Shinken via Vulture
authors:
  - zwindler
type: post
date: 2012-10-21T19:13:14+00:00
url: /2012/10/21/publier-sur-le-wan-la-webui-de-shinken-via-vulture/
image: /2014/12/logo2-white1.png
categories:
  - autohebergement
  - Monitoring
tags:
  - content rewrite
  - html5
  - Nagios
  - pnp4nagios
  - Shinken
  - vulture
  - websso

---
Ceux d’entre vous qui me suivent savent déjà que je suis de manière avide tous les développements du projet Shinken, un outil de supervision compatible avec Nagios, mais qui apporte des fonctionnalités de haute dispo et de vue business bien supérieures à ce qu’on peut faire simplement avec Nagios. Depuis quelques temps, les développeurs de Shinken ont beaucoup bossé sur une interface plus épurée et pourtant plus puissante que celle de Nagios (voire même Centreon pour certaines idées) en HTML 5.

Dans les débuts de cette interface, j’ai eu le plus grand mal à la faire passer au travers de mon web proxy applicatif personnel (Vulture). Aujourd’hui, avec la stabilisation du code de la WebUI de Shinken et aussi une meilleure compréhension des mécaniques de vulture, j’ai réussi à la faire passer sur Internet et je peux donc consulter à tout instant l’état de mon infra perso, ce qui, vous en conviendrez, est une nécessité absolue.

Mais trêves de bavardages. La première chose que je tiens à dire, c’est que cet articule ne couvrira pas l’installation de Shinken, pour la bonne et simple raison que j’ai horreur d’écrire des articles quand des blogs/forum/wiki existent déjà pour dire la même chose. Pour rappel :

Si vous souhaitez installer Shinken, vous n’avez qu’à exécuter la commande suivante :

* [Page de download de Shinken (lien mort, remplacé par Internet Archive)](https://web.archive.org/web/20130120075004/http://www.shinken-monitoring.org/download/)

Pour configurer Shinken

* [10 Minute Shinken Installation Guide (lien mort, remplacé par Internet Archive)](https://web.archive.org/web/20130323210053/http://www.shinken-monitoring.org/wiki/shinken_10min_start)

Passons maintenant aux choses sérieuses. Dans un premier temps, vous avez installé et configuré Shinken, il fonctionne, et vous pouvez ouvrir votre WebUI en local

![](/2012/10/shinken_webui.png)

> Le dashboard classique de l’outil de supervision de base. C’est la moins sexy des vues de Shinken mais je reste un peu vieux jeu

Maintenant, tout se passe côté Vulture. Je pars du principe que vous disposer d’un nom de domaine (on n’a qu’à prendre vulture.fr, au hasard), et que vous avez mappé les adresses suivantes sur l’IP depuis votre domaine vers votre serveur vulture

* portal.vulture.fr
* shinken.vulture.fr
* pnp.vulture.fr

Vous l’aurez certainement deviné, la première sert au portail et est rattaché à la définition de l’interface vulture. Tout arrivera sur cette interface (pour ceux qui en ont plusieurs, pour les autres qui n’en ont qu’une, c’est évident). Cependant pour les deux autres, vous pouvez remarquer que j’ai été obligé d’utiliser deux noms différents pour ma WebUI (au moins dans un premier temps, en attendant de trouver une meilleure façon de faire). Et pour cause...  
Malheureusement, la WebUI utilise un composant python qui génère du code HTML 5 à la volée, en écoute sur le port 7767. Cependant, pour compléter un peu la vue des services et notament pour ce qui est des perfdata, l’équipe de Shinken à pris le parti de réutiliser le travail de pnp4nagios, qui est intégré directement dans l’interface. Or, pnp4nagios est un composant web tout ce qu’il y a de plus basique, qui tourne dans un apache sur le pour 80 (ou n’importe quelle autre port, on s’en fiche, juste pas le 7767).

Du coup, vu de vulture,  j’ai été contrains à créer deux applications, et donc à leur donner deux noms distincts. C’est là la partie qu’il reste à améliorer. Il est surement possible de faire mieux, pour l’instant je n’ai pas trouvé...

Une fois nos deux applications définies dans vulture, il reste encore un petite opération pour que le tout fonctionne. A l’heure actuelle, le code de Shinken à la facheuse tentance à générer des liens et à rediriger automatiquement vers des pages via des URLs absolues... du type http://@IP_locale/webui. En local, votre navigateur saura résoudre cette  IP privée, mais pas sur Internet. C’est pourquoi nous allons demander à vulture de réécrire tous les contenus qui posent problèmes à la volée. Pour cela il faut aller dans le menu « Plugin de réécriture de contenu ». Il faudra transformer toutes les requêtes qui sont en HTTP en local en HTTPS derrière vulture, et transformer les URL pnp pour qu’elles pointent vers la bonne application.

![](/2012/10/rewritewebui.png)

> Shinken crache des liens HTTP simple toutes les 30 secondes, ce qui est fâcheux quand votre vulture écoute sur du HTTPS

![](/2012/10/rewritepnp.png)

> la webui génère de moches adresses IP locales que vulture n’ose pas modifier sans notre accord explicite

Une fois ces étapes réalisées, vous devriez pouvoir afficher la webui derrière votre vulture comme si vous étiez en local. Reste donc à accepter les certificats autosigner, à s’authentifier dans la WebUI PUIS dans pnp4nagios, et le tour est joué. Et comme vulture est un SSO en plus d’être un firewall applicatif, il sera aussi possible de bypasser ces deux authentifications, mais ceci fera l’objet d’un article ultérieur (quand j’aurai pris le temps de comprendre comment ça fonctionne)

