---
title: 'Quand Vulture 2.0 planne au dessus de la carcasse d’un Lenny et de son fidèle Mediawiki'
authors:
  - zwindler
type: post
date: 2011-11-01T17:03:35+00:00
url: /2011/11/01/quand-vulture-2-0-planne-au-dessus-de-la-carcasse-dun-lenny-et-de-son-fidele-mediawiki/
image: /2014/12/logo2-white1.png
categories:
  - Autohébergement
tags:
  - apache
  - Firewall
  - lenny
  - mediawiki
  - sécurité
  - squeeze
  - sso
  - vulture
  - websso

---
Peut être que vous connaissez Vulture, mais peut être pas. Pour ceux d’entre vous qui ne se sont jamais vraiment posé la question de la sécurité pour les contenus web que vous diffusez sur Internet, protéger un minimum ses applications web devient très rapidement vital si elles sont autohébergées, et encore plus (\*shock\*) si vous les avez développées vous même. On aimerait bien éviter de devenir la porte ouverte à toute les fenêtres...

De plus, une fois la peur des pirates informatique américo-chinois (ou autre gouvernement soutenant ouvertement les pirates informatiques : il n’y a bien que la France pour n’avoir que des équipes de « défense ») étant partiellement écartée, on peut aussi disposer de beaucoup de contenus publiés, disposant chacun de leur propre méthode d’authentification, et souhaiter pouvoir faire du Single Sign On pour éviter d’avoir 50 comptes différents et de taper ses logins/passwords toute la journée! Aaaaah le Single Sign On. Les SSII nous en auront vendu, des solutions clés en mains permettant de s’interfacer avec tout en un clic, ou presque! Toute la nuance étant dans le « ou presque ».

Aujourd’hui, je ne vais donc pas vous vendre la solution ultime à tous vos problématiques de sécurisation de vos applications web ni vous donner un portail SSO universel, mais tout de même... 

## Présentation

Vulture est un projet open source, permettant de faire la plupart des tâches qu’on attend d’un portail Web SSO. Depuis plusieurs mois, il n’y avait pas eu beaucoup d’activité sur le projet, qui est resté pendant un bon moment aux versions 1.98 et 1.99. Cependant il manquait à la version 1.XX certaines fonctionnalités utiles, notamment la propagation de l’authentification via cookies (utilisé par exemple pour mediawiki). Un peu dommage pour un SSO si on doit se ré-authentifier pour aller sur son Wiki pour aller chercher des infos techniques rapidement.

Cependant, cet été, une version 2.0 a vu le jour, même si le fait que cela soit une beta ou non n’est pas très clair je trouve ([EDIT] A priori on est toujours en béta, donc pas de prod je vous prie).

> Vulture est un reverse-proxy offrant des fonctions Web-SSO et firewall applicatif.

Un des gros points noir du projet Vulture est le manque de clarté dans leur documentation, notamment pour les débutants dans les reverse-proxy. A mon avis, un petit tutoriel pas à pas s’impose pour pouvoir configurer « au minimum » l’accès à quelques applications.

## Installation

La première chose que je dois vous dire, c’est que j’ai effectué l’installation sur une machine virtuelle vieillissante en Debian Lenny. Je vais donc tout de suite commencer par vous **déconseiller de tester sur une Lenny**, mais plutôt de le faire sur une Squeeze, pour des raisons de paquets non disponibles dans les dépôts...

La documentation relative à l’installation en elle même est disponible sur le site du projet 

* [www.vultureproject.org/documentation/installation/](http://www.vultureproject.org/documentation/installation/)

Une fois toutes les dépendances installées comme indiqué sur le site puis le paquet .deb installé, vérifiez que vous n’avez aucune erreur lors du lancement de l’application (automatique).

A priori vous devriez pouvoir vous connecter sur l’interface web de vulture en local sur le port 9090 (et local seulement). Pour ceux qui voudraient ne pas être obligés de faire ça en local justement (VM sans environnement graphique ou réseau local bien protégé), vous pouvez faire un tunnel SSH ou modifier les paramètres apache de Vulture, comme indiqué dans la doc d’installation.

Personnellement je suis sur un réseau NATé, donc le seul moyen d’accéder au port 9090 est d’être sur mon réseau local, et j’ai pu laisser des paramètres de sécurité apache très lights. Le plus propre serait évidemment d’interdire toutes les IP autres que votre poste d’administration.

```
Listen *:9090
[...]
<Virtualhost *:9090>
```


Pour ceux qui n’ont rien écouté et qui ont quand même voulu installer leur vulture sur un Lenny, si vous vous retrouvez avec l’erreur suivante, c’est parce que le paquet libdb4.8 n’est tout simplement pas installé pour une raison simple : elle n’est pas disponibles dans les dépôts standards.

```
Starting vulture: apache2: Syntax error on line 40 of /var/www/vulture/conf/1.conf: Cannot load /usr/lib/apache2/modules/mod_security2.so into server: libdb-4.8.so: cannot open shared object file: No such file or directory
apache2: Syntax error on line 40 of /var/www/vulture/conf/2.conf: Cannot load /usr/lib/apache2/modules/mod_security2.so into server: libdb-4.8.so: cannot open shared object file: No such file or directory
```


Une façon de s’en sortir est heureusement d’installer le fameux paquet depuis un site tiers

```
wget http://backports.debian.org/debian-backports/pool/main/d/db/libdb4.8_4.8.24-1~bpo50+1_i386.deb
dpkg -i libdb4.8_4.8.24-1~bpo50+1_i386.deb
```


## Configuration

Maintenant on entre dans le vif du sujet. Nous sommes parvenus à installer Vulture, et il est maintenant accessible en local ou pas (c’est selon).

Pour se connecter, c’est facile, le mot de passe administrateur est parfaitement secure puisqu’il s’agit de admin/admin, donc vous pouvez le laisser tel quel :-p.

Ceux qui connaissent déjà la version précédente de Vulture ne seront pas trop surpris : elle est strictement identique. Bien que la documentation soit assez claire sur la fonction de chacun des champs dans chacun des menus ([documentation de Vulture](http://www.vultureproject.org/documentation/configuration/)), il n’y a pour l’heure aucun tutoriel pour permettre à tout le monde d’installer Vulture.

Voici donc, une liste d’étapes commentées pour vous permettre de mettre en place le **strict minimum** : un **portail** commun pour vos application web faisant office de **firewall applicatif**, avec une **authentification** simple, ainsi que l’ajout d’**une application** (mediawiki ici) sans SSO.

Les problématiques plus poussées seront développées dans un prochain article (SSO, ajout d’une authentification LDAP, ...).

### Gestion des utilisateurs

Comme dit plus haut, la première priorité est donc de changer le mot de passe de l’administrateur. Pour se faire, il suffit de cliquer sur le menu _Users_ puis de cliquer sur la petite icône représentant une feuille et un crayon pour éditer l’utilisateur.

Pour une raison que j’ignore, même si je doute que ce soit une nouvelle fonctionnalité révolutionnaire, le mot de passe est affiché via son hash MD5. Et pour le modifier il faut entrer également un hash MD5 du nouveau mot de passe.

Une fois qu’on a modifié le mot de passe de l’administrateur, on peut ensuite créer tous les utilisateurs qu’on veut autoriser à se connecter au portail et au applications.

### Creation d’un module de log

Pour générer les fichiers de journalisation sur les erreurs et les accès apache de chacun des composants interfacés au portail, Vulture se base sur le module apache mod_log.

Contrairement à la version précédente de Vulture, il est nécessaire de créer/paramétrer son propre module de logging avant de pouvoir commencer à déclarer les interfaces. A mon avis, là aussi, c’est juste un oubli, qui sera rajouté par la suite.

En attendant, voici les champs à remplir pour pouvoir disposer d’une journalisation correcte sur chaque interfaces et chaque application :

**Name :** Combined  
**Error Log Verbosity :** error  
**Access Log Format :** « %h %l %u %t « %r » %>s %b « %{Referer}i » « %{User-agent}i » »  
**Directory where to place Logfiles :** /var/log/

![](/2011/11/mod_log.png)

![](/2011/11/interface1.png)
![](/2011/11/mod_log1.png)

### Création d’une interface

Vulture permet de créer un certain nombre d’interfaces, qui correspondent en fait aux virtualhosts en écoute pour le portail qui regroupe toutes les applications.

Il est donc nécessaire d’en créer au moins une, que l’on liera par la suite à toute nos applications.

![](/2011/11/interface1.png)
Dans mon cas, j’ai souhaité que toutes les applications web que je publie sur Internet soient centralisées par un portail HTTPS. Pour ce faire, j’ai créé plusieurs alias DNS qui pointent tous vers l’IP du portail vulture (192.168.0.XX), ainsi qu’un alias pour le portail lui même (portail.example.org).

J’ai ensuite généré les certificats SSL (autosignés ici). Pour générer plus rapidement les certificats, il est possible d’utiliser le modèle fournit sur le site [vulture.open-source.fr (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20121027093700/http://vulture.open-source.fr/download/samples/openssl.cnf), puis exécuter la commande :

```
openssl req -x509 -days 1825 -newkey rsa:1024 -batch -out server.crt -keyout server.key -nodes -config openssl.cnf
```


Pour créer l’interface il suffit donc de remplir les champs correspondants

![](/2011/11/interface2.png)

### Creation de l’application

Une fois l’interface créée sans encombre, reste maintenant à définir les paramètres de vulture pour l’application que l’on souhaite protéger derrière le Vulture. Ici, il s’agit d’un Mediawiki, sur lequel on peut s’authentifier via une base de données interne, ou via LDAP. Dans les deux cas, il n’était pas possible d’interfacer Mediawiki avec Vulture 1.99. Ici, je ne détaillerai pas la méthode pour effectuer ce SSO normalement disponible depuis la 2.00, pour la simple raison que je ne l’ai pas encore testé, mais cela fera l’objet d’un prochain article.

Ici, les champs à remplir sont :

  * Internet Name : l’alias que l’on a décidé pour l’application, mediawiki.example.org par exemple
  * Interface : L’interface qu’on vient de créer
  * Private URL : L’url complète vers laquelle on doit pointer pour trouver l’application web. Ici il s’agit de l’IP et du numéro de port du mediawiki
  * Authentication : les méthodes qui sont autorisées pour décider si l’utilisateur à l’accès ou non. Ici la seule méthode dont on dispose pour l’instant est vulture (il faut donc la sélectionner)

![](/2011/11/application_mediawiki.png)

Après une petit redémarrage de l’interface (logo avec les deux flèches vers en cercle), le portail et l’application devraient être disponible

Enjoy

