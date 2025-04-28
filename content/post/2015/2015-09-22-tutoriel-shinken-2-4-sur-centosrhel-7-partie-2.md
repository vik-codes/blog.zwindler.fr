---
title: '[Tutoriel] Shinken 2.4 sur CentOS/RHEL 7 – partie 2'
authors:
  - zwindler
type: post
date: 2015-09-22T16:31:03+00:00
url: /2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-2/
image: /2015/09/shinken.png
categories:
  - Monitoring
tags:
  - CentOS 7
  - cherrypy
  - installer
  - mongodb
  - pip
  - poller
  - proxy
  - Python
  - python-crypto
  - RHEL 7
  - Shinken 2.4

---
## Tutoriel pas à pas pour installer Shinken 2.4 - partie 2

Cet article fait parti d’une série d’articles (au moins 3) que je vais publier sur Shinken 2.4 et que j’ai séparé pour les rendre un peu plus digestes. Je vous conseille quand même de ne pas en sauter pour bien comprendre de quoi on parle ;-) :

* [Partie 1 : Présentation de Shinken](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-1/)
* [Partie 2 : Installation de Shinken 2.4 sur RHEL/CentOS 7](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-2/)
* [Partie 3 : Configuration initiale de Shinken 2.4 sur RHEL/CentOS 7](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-3/)

## Installation

Vous savez maintenant c’est conçu, on peut se lancer dans le bain !

![OK. C’est simple. Mais peut être pas aussi simple que ça !](/2015/09/01_install.png)

En réalité, c’est un peu plus compliqué que cela ;-). D’autant plus que le logiciel a subit plusieurs modifications de philosophie et de fonctionnement au fil du temps et que la page de documentation [10 Minutes Shinken Installation Guide](https://shinken.readthedocs.org/en/latest/02_gettingstarted/installations/shinken-installation.html#gettingstarted-installations-shinken-installation
) n’est malheureusement plus à jour et parfois même incomplète.

### Prérequis et installation via pip

D’abord, il va falloir installer quelques prérequis si vous voulez pouvoir installer Shinken sur un serveur CentOS 7 « Desktop ». On les retrouve dans le 10 minutes Shinken installation Guide cité plus haut.

La méthode la plus simple consiste à utiliser **pip** qui récupère les sources directement depuis _pypi.python.org_ et les installe tout seul c’est donc celle là que je vais présenter. Pour CentOS 7, **pip** est contenu dans le package **python-pip**, lui même disponible via le dépôt EPEL Release.

[New]Si comme moi vous en avez marre d’installer des Desktop pou rien ca rvous n’utilisez pas la partie graphique, il faut ajouter le package redhat-lsb en Minimal, prérequis aux scripts de démarrage de Shinken

```
yum install epel-release
#ou rpm -iUvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum update
yum install python-pip
yum install redhat-lsb
```


A partir de là, on peut reprendre les commandes citées sur la page principale du site.

```
adduser shinken
pip install shinken
```


Auquel on nous conseille (sans trop nous le dire) d’ajouter

```
pip install cherrypy
yum install nagios-plugins
```


Et enfin quelques derniers prérequis pas du tout cités et qui seront utiles pour la suite :

```
yum install python-crypto #necessaire pour installer les modules via "shinken install"
yum install mongodb mongodb-server #necessaire pour plusieurs modules dont la WebUI
yum install httpd-tools #utile pour une authentification simple et rapide de la WebUI
```


Si vous êtes derrière un proxy (moi j’ai besoin de ntlmaps ou cntlm pour sortir sur Internet), n’oubliez pas de le positionner dans la variable https_proxy (notez le S de https).

```
export https_proxy=http://localhost:8080/
```


pip devrait maintenant se charger de tout récupérer sur Internet pour vous.

```
Collecting shinken
Downloading Shinken-2.4.tar.gz (26.7MB)
65% |#####################        | 17.5MB 106kB/s eta 0:01:27
```


Votre machine dispose maintenant du cœur de Shinken installé. C’était rapide, mais ne criez pas victoire trop vite.

Il faut maintenant configurer les démons et ajouter les modules.

## Configuration de base

Le cœur de la configuration se situe dans le fichier _/etc/shinken/shinken.cfg_.

C’est dans ce fichier que vous allez définir les paramètres globaux et les fichiers de configuration complémentaires à parcourir de la même façon que vous l’auriez fait avec _nagios.cfg_.

### Les démons

J’en parlais dans les articles précédents, l’architecture de Shinken diffère de celle de Nagios du fait que Shinken fonctionne avec des démons, chaque démons ayant un rôle particulier.

L’installation de base créé un fichier de configuration pour chaque type de démon dans son propre répertoire :

```
ll /etc/shinken/arbiters/
total 4
-rw-r--r--. 1 shinken shinken 2744 19 sept. 19:54 arbiter-master.cfg
```


**A ne pas confondre** : vous pourriez être surpris par la présence de fichiers **[demon]d.ini** dans le répertoire **daemons/**. Ces fichiers servent plutôt à la modification des paramètres « systèmes » des démons, comme le user+group, mais pas à l’ajout de modules ou à la définition de paramètres interne à Shinken, comme le fait que le démon soit un spare ou pas, affecté à un realm, etc.

```
ll /etc/shinken/daemons
-rw-r--r-- 1 shnkn shnkn 1231 17 sept. 14:34 brokerd.ini
-rw-r--r-- 1 shnkn shnkn 1223 17 sept. 14:34 pollerd.ini
-rw-r--r-- 1 shnkn shnkn  862 17 sept. 14:34 reactionnerd.ini
-rw-r--r-- 1 shnkn shnkn  856 17 sept. 14:34 receiverd.ini
-rw-r--r-- 1 shnkn shnkn  983 17 sept. 14:34 schedulerd.ini
```


### Démarrage automatique

On s’arrange pour qu’ils démarrent tous au démarrage. La documentation propose la boucle suivante pour ajouter tous les démons dans le démarrage pour un OS qui utilise **systemd** et plus **System V** (Debian/Ubuntu/RHEL/CentOS dans leurs dernières versions pour ne citer qu’eux).

```
for i in arbiter poller reactionner scheduler broker receiver; do
  systemctl enable shinken-$i.service;
done
```


Cela étant dit, j’ai plutôt utilisé le service shinken qui « chapeaute » le tout et qui suffit dans le cas d’une architecture standard (sans haute disponibilité et répartition de charge) comme celle que nous sommes en train d’installer. A votre convenance.

```
systemctl enable shinken
```


Quelque soit la méthode, un CentOS/RHEL 7 devrait vous renvoyer l’erreur suivante :

```
shinken.service is not a native service, redirecting to /sbin/chkconfig.
Executing /sbin/chkconfig shinken on
The unit files have no [Install] section. They are not meant to be enabled
using systemctl.
Possible reasons for having this kind of units are:
1) A unit may be statically enabled by being symlinked from another unit's
   .wants/ or .requires/ directory.
2) A unit's purpose may be to act as a helper for some other unit which has
   a requirement dependency on it.
3) A unit may be started when needed via activation (socket, path, timer,
   D-Bus, udev, scripted systemctl call, ...).
```


Il est probable que le script n’ait pas encore totalement été modifié pour fonctionner avec **systemd** (pour des raisons de compatibilité peut être ?). Ça mériterait un petit ticket sur github pour voir avec les core devs...

A ce stade, c’est « fonctionnel » dans le sens ou on peut lancer le démon principal et qu’on se rendra compte que tout « fonctionne ».

```
systemctl start shinken
systemctl status shinken
shinken.service - LSB: Shinken monitoring daemon
   Loaded: loaded (/etc/rc.d/init.d/shinken)
   Active: active (running) since dim. 2015-09-20 16:34:12 CEST; 7s ago
[...]
```


Pour autant, je ne suis pas certain que cela vous soit très utile car :

  * vous n’avez pas encore ajouté vos serveurs à superviser
  * vous n’avez pas encore d’interface graphique.

Direction [l’article suivant](/2015/09/22/tutoriel-shinken-2-4-sur-centosrhel-7-partie-3/) pour régler ça !
