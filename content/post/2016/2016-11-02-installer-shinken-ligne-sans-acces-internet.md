---
title: Comment installer Shinken 2.4 hors ligne (sans accès à Internet)
authors:
  - zwindler
type: post
date: 2016-11-02T15:11:10+00:00
url: /2016/11/02/installer-shinken-ligne-sans-acces-internet/
image: /2016/11/LogoShinken.png
categories:
  - Monitoring
tags:
  - CPAN
  - createrepo
  - Hors ligne
  - Internet
  - npmjs
  - offline
  - pip
  - pipy
  - RPM
  - Shinken
  - Shinken 2.4
  - Yum

---
## Pourquoi installer un logiciel (et notamment Shinken) hors ligne ?

[Aparté] Pour ceux qui ne connaissent pas encore bien Shinken, je vous propose de lire mes [précédents articles sur le sujet](/recherche/?keyword=shinken) et notamment celui où [j’introduis le logiciel ainsi que ces fonctionnalités principales](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-1/). [/Aparté]

De plus en plus -même si ça fait bien longtemps que la tendance s’est installée- les packages (dépôts Debian like/RHEL/whatever) mais aussi les langages & les frameworks ([perl][3], [pear (php)][4], [npmjs][5]), voire même les logiciels vous simplifie la vie. On vous met à disposition un gestionnaire/binaire/ligne de commande pour télécharger de nouveaux modules/composants depuis un dépôt sur Internet, avec une gestion des dépendances et l’installation (voire compilation) automatisée.

Et c’est vrai que c’est quand même super pratique.

Qui n’a jamais pesté de ne pas avoir le CPAN de Perl à disposition ? Devoir télécharger manuellement sur le site CPAN.org puis compiler des modules selon un arbre de dépendances long comme le bras ? Et avec deux méthodes de compilation différentes (Make & Build) selon le module si possible !

![](/2016/11/cpan.jpg)

Pour ceux qui n’ont pas connus ce « fun ultime » je vous propose de jeter un œil à cet article où je récapitule [comment installer sur EON et CentOS une sonde Nagios (oui, une seule) en 161 lignes de commande](/2010/09/08/installer-3-plugins-nagios-dans-eon-1-2-coupe-dinternet-level-2/).

Pour autant, il n’est pas rare que les administrateurs réseaux du DataCenter, par souci de sécurité et respect des bonnes pratiques, refuse par défaut l’accès direct à Internet pour les serveurs. Dans le meilleur des cas, il existe des dépôts locaux qui sont le miroir de ce qu’on trouve sur Internet à un instant T, mais :

  * Ils ne contiennent jamais l’exhaustivité des RPM/DEB/...
  * Les versions des packages évoluent tout le temps et garder un ensemble cohérent de tous les modules et leur dépendances et quasi impossible (notamment les rpm pour des modules PHP... $\*%$$\*)
  * On ne peut pas avoir l’ensemble des gestionnaires qui existent (rien que la courte liste que je cite plus haut, c’est compliqué)
  * Dernier cas : il n’existe pas nécessairement de méthode pour stocker dans le DC une copie des modules

Il faut donc s’y résigner : il arrive des fois où l’installation hors ligne de dépendances est malheureusement incontournable.

## Le cas de Shinken

Il m’est arrivé à plusieurs reprises à devoir installer Shinken hors ligne dans des DC coupés d’Internet et a priori je ne suis pas le seul (quelques anciens collègues, un commentaire sur le blog, ...). Pour autant, de ce que j’ai pu voir, il n’existe pas dans la documentation (ou alors plus) qui mentionne la méthode pour le faire.

Mais vous avez de la chance, la méthode existe !

Je ne vais pas rentrer autant dans les détails de l’installation et de la configuration de Shinken. Cette partie est traitée de manière exhaustive dans les tutoriels précédemment publiés ([ici](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-2/) puis [ici](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-3/)). Pour autant, voici la marche à suivre lorsque Shinken fait appel à Internet et que vous souhaitez réaliser l’opération **hors ligne**.

## Pour les dépendances RPM via yum

Note : cette partie de l’article est applicable au delà de Shinken, je l’utilise tous les jours pour constituer mes bases de RPM pour l’ensemble des distributions et des logiciels que j’administre.

Pour les dépendances RPM, 2 solutions :

  * Soit vous montez votre propre dépôt local, par exemple avec **createrepo** et un serveur Apache. C’est très simple à mettre en place et c’est un bonne idée lorsque vous avez beaucoup de packages a installer, ou plusieurs version de distrib’ a administrer.
  * Soit vous vous créez un dossier dans lequel vous récupérer tous les RPM et leurs dépendances. Vous copierez ce dossier sur le serveur où vous souhaitez installer Shinken.

Quoiqu’il arrive, vous devrez donc passer par la case « téléchargement manuel » de tous les RPM nécessaires.

### yumdownloader

Dans le meilleur des cas, vous disposez d’un Linux de la même version et qui a un accès à Internet. Et là vous allez vous simplifier la vie avec le binaire **yumdownloader**.

Ce binaire fonctionne de la même manière que yum, à ceci près qu’il télécharge les packages au lieu de les installer. Vous n’aurez donc qu’a ajouter dans votre **/etc/yum.repo.d**/ l’ensemble des dépôts qui seront nécessaires à l’installation de Shinken (probablement CentOS-Base et EPEL Release pour un CentOS), puis télécharger tous les RPMs dont vous avez besoin avec la commande :

```
yum install yum-utils
mkdir shinken_deps && cd shinken_deps
yumdownloader --resolve mon_package
```


A noter cependant, d’expérience le _--resolve_ censé télécharger les dépendances du package en même temps est peu fiable. Vous aurez surement des dépendances manquantes à télécharger de manière complémentaire.

### A la mimine

Si vous n’êtes pas dans le cas cité plus haut, alors cette opération peut être fastidieuse. Elle va alors consister à taper dans votre moteur de recherche favori des mots clés du type « mon_package rpm el6 » (dans le cas d’un RHEL6 ou CentOS6), puis de télécharger la version qui y est disponible sur des sites comme *rpm.pbone.net* et *www.rpmfind.net*.

Et bien sûr, comme vous ne pouvez pas deviner aisément si les dépendances qui y sont affichées sont actuellement disponibles ou pas sur votre serveur, il y a un risque que ce soit une opération itérative, jusqu’à ce que vous ayez enfin toutes les dépendances pour tous les cas de figure.

...

Et qu’il n’y ait pas de conflits entre versions de packages interdépendants...

### Installation

Votre base de RPM est enfin complète. Pour installer les RPMs nécessaires à Shinken !

#### Si vous avez choisi le dépôt local

Un simple ajout du dépôt sur le serveur vous permettra donc d’installer toutes les dépendances comme s’y vous étiez sur Internet

```
yum install package1 package2 ...
```


> Transparent !

#### Si vous avez plutôt une clé USB/DVD/disque 5&Prime;1/4 avec toutes les dépendances dessus

Pendant longtemps, quand j’avais des RPMs à installer, je m'embêtais à les installer dans l’ordre de dépendance avec la commande **rpm -hiv mon_package**. Et des fois je pestais parce que je ne l’avais pas fais dans le bon ordre...  
Mais vous avez quand même de la chance, _yum_ est bien pensé. Il permet également d’installer des RPMs locaux et gère les dépendances de lui même, qu’elles soient sur déposés sur le serveur ou sur vos dépôts. Vous n’avez donc à vous soucier que des packages qui ne sont pas sur vos dépôts, _yum_ fera le tri parmi toutes les sources disponibles. Et ça simplifie grandement la vie.

```
cd shinken_deps/
yum install *.rpm
```


## Installation des modules Python via pip (dont Shinken lui même)

Shinken étant codé majoritairement en python, vous ne serez donc pas surpris d’apprendre qu’il faut utiliser pip (ou pipy) pour installer des dépendances à Shinken, et même d’ailleurs Shinken lui même.

Rappel des tutos précédents, pour installer Shinken sur un CentOS qui a accès au net, il faut « juste » faire

```
rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum update
yum install python-pip
adduser shinken
pip install shinken
```


Si vous avez quand même partiellement accès à Internet via un proxy, vous pourrez vous en sortir en indiquant dans la variable http**s**_proxy l’URL du proxy HTTPS pour _pip_ (notez le S).

```
export https_proxy=http://@IP_proxy_https:8080/
```


Mais dans le cas où vous êtes réellement coupé d’Internet et que vous devez récupérer des packages _pipy_ a priori, vous pourrez quand même le faire de la façon suivante :

  * Récupérer le tar.gz du module pipy sur le site Internet. Par exemple, pour Shinken, il existe [une page dédiée sur pipy][10]
  * Déposer le fichier shinken-2.4.x.tar.gz sur le serveur où on souhaite installer Shinken
  * Installer le module pipy simplement à l’aide de la commande **pip install shinken-2.4.x.tar.gz**

Cette méthode est valable pour toutes les dépendances Python de Shinken, mais aussi pour Shinken lui même, comme on vient de le voir.

## Pour l’installation des modules de Shinken (comme webui2 par exemple)

Mais au delà de l’installation de Shinken, de ses dépendances RPMs et Python, il reste encore un dernier problème : les modules de Shinken !

Les développeurs de Shinken ont mis à disposition sur **shinken.io** une liste de modules (plus de 100 je crois) optionnels et qui ne sont pas inclus dans le logiciel de base. Pour autant, certains sont quand même très utiles voir carrément importants. C’est notamment le cas de [la webui][11] (interface graphique officielle de Shinken).

![](/2016/11/shinken_webui_offline.png)

Et pour vous simplifier la vie, l’installation de ces fameux « modules de shinken » se fait via une ligne de commande très simple, qui se charge de télécharger et d’installer pour vous les dépendances :

```
shinken install webui
```


C’est une super idée, mais, là encore, sans Internet, impossible de télécharger ce module de cette manière.

N’ayez crainte ! En réalité, bien qu’il ne soit pas (ou plus, ou je n’ai pas trouvé) documenté, il existe un mécanisme d’installation locale de la même manière qu’avec _yum_ ou _pip_. Ouf !

### Dépendances

La première étape consiste à récupérer les dépendances pipy listées dans le mod-webui/requirements.txt qu’on peut trouver dans le code source du module.

Dans le cas de la webui, il s’agit (à date) de **bottle==0.12.8, pymongo>=3.0.3, requests, arrow et passlib**. On les récupèrent donc tous sur pipy, et on les installe comme je viens de le décrire avec un **pip install monmodule.tar.gz**

### Récupérer les sources du modules

Ensuite, on récupère les sources en un zip, qu’on dézippe sur le serveur. Pour le module **webui**, les sources sont sur github [github.com/shinken-monitoring/mod-webui](https://github.com/shinken-monitoring/mod-webui)

On peut enfin installer le module de Shinken à la main, à l’aide du flag **--local**

```
shinken install --local webui
```


Facile, non ?

;-)

 [3]: http://www.cpan.org/
 [4]: http://pear.php.net/
 [5]: https://www.npmjs.com/
 [10]: https://pypi.python.org/pypi/Shinken
 [11]: http://shinken.io/package/webui
