---
title: Sortie de XWiki 9.5 et mise à jour Docker
authors:
  - zwindler
type: post
date: 2017-06-30T10:30:12+00:00
url: /2017/06/30/sortie-de-xwiki-9-5-mise-a-jour-docker/
image: /2017/06/xwiki_docker.png
categories:
  - Logiciel
tags:
  - Docker
  - Dockerhub
  - flavor
  - MySQL
  - PostgreSQL
  - ui
  - ux
  - Xwiki

---
## Adieu à 8.4, bonjour XWiki 9.5 (.1)

J’évite de faire un article à chaque fois qu’une nouvelle version de XWiki sort, surtout les versions mineures. Le projet XWiki est assez dynamique : les versions (et les fonctionnalités supplémentaires qui vont avec) s’enchaînent assez vite. Effectivement, depuis mon dernier article sur comment [mettre à jour en 8.4 votre XWiki si vous utilisez mon image Docker de XWiki](/2016/11/30/mise-a-jour-xwiki-8-4-1-docker-tomcat-postgresql/) date d’à peine plus de 6 mois !

Mais j’ai deux occasions pour faire ce petit article.  
D’abord parce que je continue à maintenir mon image **zwindler/xwiki-tomcat8** qui fonctionne avec postgresql. Et je viens de déployer la dernière version sur le dockerhub.  
Et ensuite parce qu’au delà des nombreuses améliorations et modifications de l’interface (j’en fais la liste dessous), [la gestion des pages par défaut du XWiki (Flavor) a été découplée du Distribution Wizard pour permettre à la communauté de créer son propre « set » de pages par défaut][2].

![](/2017/06/xwiki_9.5_flavor_3.png)

Une bonne nouvelle car personnellement la première chose que je fais quand je déploie un XWiki, c’est supprimer la Sandbox et le Blog. J’attend donc les premiers Flavors avec impatience :).

## Pourquoi maintenir une version non officielle ?

Depuis mon dernier post, les gens de chez XWiki (surtout Vincent Massol) ont sorti leur propre version de XWiki sous Docker.

![](/2017/06/xwiki_9.5_03.png)

> 100k pulls dépassés, respect !

Vincent est même allé assez loin dans le travail, avec la promotion de son image en tant qu’image « officielle » (titre réservé aux éditeurs, et si j’ai bien compris gagner ce titre n’a pas été une mince affaire), ainsi que la création d’un build automatisé multiple pour plusieurs version de XWiki et le support de plusieurs bases de données :

![](/2017/06/xwiki_dockerhub_support.png)

> De nombreuses versions disponibles, comme les plus grands

Alors dans ces conditions, à quoi bon maintenir ma propre image ?

Eh bien déjà parce que XWiki a été ma première expérience avec Docker et que construire cette image m’a permis de mettre le pied à l’étrier. Aujourd’hui encore, quand je teste une techno ou un outil dans l’écosystème Docker, une installation simple XWiki + postgresql me sert de base de comparaison.

Du coup j’utilise XWiki avec ma propre image, et la mettre à jour lorsque je veux profiter des dernières version. Accessoirement, ça me permet aussi de faire la course avec Vincent et de parfois mettre à jour ma version de XWiki containerisé avant l’image officielle (je plaisante ;-) ).

(Elle est aussi plus légère car je n'embarque pas le serveur Open Office que je n’utilise pas, mais ce n’est probablement pas un argument en ma faveur).

## Quoi de neuf docteur ?

> J’aurais bien fais la blague « quoi de neuf, Docker » mais j’ai découvert récemment que c’est une chaine Youtube qui existe déjà...

Pour ceux qui n’ont pas le temps de lire l’ensemble des releases notes depuis la 8.4, voici la liste des fonctionnalités et des changements les plus notables qui ont été ajoutées depuis (de 9.0 à 9.5) :

  * La 9.0 a surtout servi à marquer le changement de branche et n’ajoute que quelques ajustements sur la taille max des pièces jointes et de la corbeille
  * Depuis la 9.1, ajout d’une protection contre la suppression accidentelles de page du système

![](/2017/06/xwiki_9.5_supprimer.png)

  * Depuis la 9.1, l’export HTML prend mieux en compte les nested pages (pages filles) ! Un grand soulagement pour ceux qui font des exports pour avoir des versions figées comme moi !
  * Depuis la 9.2, les options en terme de notification (pour les utilisateurs en cas d’abonnement, etc) a été enrichi. Et depuis la 9.4, on peut s’abonner aux commentaires d’une page, une fonctionnalité qui m’a déjà été demandé et qui manquait, effectivement ! Des filtres ont également été ajoutés pour plus de finesse dans les notifications.

![](/2017/06/xwiki_9.4_commentaires.png)

  * Depuis la 9.2, et à la suite d’un sondage parmi les utilisateurs de XWiki, les ergonomes de chez XWiki on réorganisé la page d’administration pour améliorer l’expérience utilisateur. Certains changements sont subtils mais bienvenus (notamment l’ordre des menus).

![](/2017/06/xwiki_9.5.1_interface.png)

  * Depuis la 9.4, pour répondre de nombreuses remarques venant de novices et suite à une consultation sur la dev-list, les menus pour interagir avec une page ont été refondus et des labels (pour modifier et créer) ont été ajoutés pour être plus explicites. Ce n’est pas forcément vrai pour tout le monde, mais c’est vrai que dans certain cas, trouver comment faire une action sur une page (renommer pour déplacer) n’était pas toujours intuitif.

![](/2017/06/xwiki_menu_page.png)

  * l’éditeur CKEditor a été amélioré à plusieurs reprise pour une meilleure intégration avec XWiki et notamment ses macros, ...
  * l’API REST a été améliorée et permet maintenant (entre autre) de déployer des XWiki de manière non interactive et d’interagir avec les différents éléments du XWiki (dont la corbeille). Personnellement je sous-utilise énormément l’API et c’est une erreur car je pense que nous pourrions gagner beaucoup de temps...
  * Diverses améliorations graphiques dans les diff entre révisions d’une page/extension, sur les calendriers, des preview sur les images en attachement, ...

## Bon et donc la 9.5, on fait comment pour l’avoir ?

Rien ne vous empêche d’installer la 9.5 vous même, ou bien d’attendre que la version XWiki Docker officielle ne sorte, mais si vous utilisez mon image, elle est disponible :-p.

Pour rappel, les sources sont [disponibles sur Github][10] et l’image est elle [accessible sur Dockerhub][11] ou encore via une simple commande du type :

```
docker network create -d bridge xwiki-nw
docker run --net=xwiki-nw -itd --name xwiki-postgres -e POSTGRES_DB=xwiki -e POSTGRES_USER=xwiki -e POSTGRES_PASSWORD=xwiki postgres
docker run --net=xwiki-nw -itd --name xwiki-tomcat -p 8080:8080 -e POSTGRES_INSTANCE=xwiki-postgres zwindler/xwiki-tomcat8
```


Si vous voulez un tutoriel plus complet sur ma version, [je vous conseille cet article](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/) ou tout simplement de suivre les instructions sur Dockerhub.

Have fun !

 [2]: http://www.xwiki.org/xwiki/bin/view/Blog/XWiki%20Enterprise%20is%20dead%2C%20long%20live%20XWiki%21
 [10]: https://github.com/zwindler/docker-xwiki
 [11]: https://hub.docker.com/r/zwindler/xwiki-tomcat8/
