---
title: Installer 3 plugins Nagios dans EON 1.2, coupé d’Internet, level 3
authors:
  - zwindler
type: post
date: 2010-09-15T08:47:41+00:00
url: /2010/09/15/installer-3-plugins-nagios-dans-eon-1-2-coupe-dinternet-level-3/
image: /2010/09/icone_EON.png
categories:
  - Monitoring
tags:
  - check_mssql_health
  - EyesOfNetwork
  - FreeTDS
  - MS SQL Server 2005
  - Perl
  - vCenter

---
Pour le dernier plugin, [check_mssql_health](http://labs.consol.de/lang/en/nagios/check_mssql_health/), j’ai vraiment dû faire face à de gros ennuis. Ce script Perl, très bien fait une fois installé, permet de vérifier à peu près tout ce qu’on pourrait vouloir vérifier dans une base de donnée MS SQL. C’est vraiment très impressionnant, et assez bien documenté une fois qu’on est sur le site officiel, heureusement en anglais (certains sites ne référencent que la partie allemande de l’aide, ce qui peut s’avérer particulièrement inutile quand on ne connait pas plus d’Allemand que quelques paroles de Rammstein).

Même si c’est probablement dû à mon cas particulier, j’ai souvent dû faire face à des documentations incomplètes pour l’installation des différents composants. J’ai passé un bon moment à tâtonner, chercher de la doc à droite à gauche, tester, râler... C’est pourquoi un passage en revue de tous les aspects de la chaine me parait utile.

D’abord, commençons par redire qu’il s’agit d’un script Perl. Pour fonctionner, celui-ci nécessite plusieurs choses. D’abord, il utilise un module Perl permettant de communiquer avec des bases de données. Mais ce module nécessite bien sûr d’un client de base de données, et enfin, ce client de base de données nécessite les bibliothèque qui vont bien pour s’installer.

Voyons cela plus en détails... Le **plugin check\_mssql\_health** nécessite du module **DBD::Sybase**, qui est en fait un module permettant de s’interfacer avec des base de données Sybase, en passant par l’intermédiaire d’un client fournit par Sybase. On pourrait se dire que c’est un choix curieux sachant qu’on veut communiquer avec une base MSSQL, mais en fait, le module permet également d’utiliser un autre client, **FreeTDS** (qui est une réimplémentation ce précédent client), qui gère également les bases **MSSQL 2000 ou supérieure** (le vCenter 2.5 utilise une base de données MS SQL Server 2005 Express).

La première chose à faire est d’installer le client **FreeTDS**. Pour ce faire, il faut d’abord ajouter les paquets suivant avec Yum :

```
# yum install unixODBC
# yum install unixODBC-devel
```

Si vous vous en tenez à la documentation de **FreeTDS**, vous ne lirez nulle part qu’il faut installer **unixODBC-devel**, et si vous ne le faites pas, le script d’installation continuera inlassablement à vous indiquer que vous n’avez pas installé **unixODBC** (alors que si!).

Une fois que ceci est fait, il faut télécharger [les sources de freetds](http://www.freetds.org/software.html), car le DVD d’EyesOfNetwork qui nous sert de répository local ne contient pas le paquet pour l’installer. Pour fonctionner correctement, notre script Perl nécessitera au moins la version 6.2 de FreeTDS, sachant que je n’ai testé que la version que la 8.2. De préférence, choisir la version dite **stable**.

```
# tar xvzf freetds-stable.tgz
#cd freetds-[version_stable]
# ./configure
# make
# make install
```


Maintenant que FreeTDS est installé, il faut le configurer. Si on lit la documentation de check\_mssql\_health, il est indiqué que pour des raisons de sécurité, il vaut mieux passer le protocole de communication de FreeTDS de la version 4.2 (par défaut) à la version 8.0. Pour ma part, ce n’est pas un conseil, c’est une obligation. check\_mssql\_health n’a jamais fonctionné tant que je n’ai pas modifié de paramètre. Et ce n’est pas plus mal, quand on sait que cette version 4.2 du protocole envoie votre mot de passe en clair sur le réseau, lors des authentifications avec la base de données (O_o).

Pour changer cette version de protocole, éditez le fichier **/etc/freetds.conf** pour qu’il ressemble à ça :

```
[global]
#TDS protocol version
tds version = 8.0
[...]
```


Maintenant que nous disposons du client, que celui-ci est correctement configuré, il faut installer les dépendances Perl. Par rapport à la dernière fois, il ne m’en manquait que deux :

  * DBD::Sybase 
      * DBI

Par contre, avant de pouvoir installer **DBD::Sybase**, il est nécessaire de le configurer (contrairement aux autres modules Perl installés jusqu’à présent). Dans les fichiers d’aide **README** et **README.freetds** contenus dans l’archive **DBD::Sybase**, il est indiqué que le chemin vers FreeTDS doit être connu par le script **Makefile.PL**. Cette valeur doit normalement être renseignée en enregistrant le chemin vers FreeTDS dans la variable d’environnement SYBASE.

Pour des raisons qui me sont totalement inconnues, je n’ai jamais réussi à faire fonctionner ce script avec cette méthode. La variable n’était jamais prise en compte, et même si l’installation continuait, le module n’était pas fonctionnel, puisqu’il n’avait pas accès au client. Pour contourner ce problème, j’ai utilisé une solution radicale et pas très élégante. Dans **Makefile.PL**, j’ai remplacé les lignes

```
Sub configure{
my $sybase_dir = $ENV{SYBASE};
[...]
```

par

```
Sub configure{
my $sybase_dir = '[chemin_vers_freetds]';
```

Après cela, l’installation du module s’est déroulée sans encombres, et le script à pu être compilé :

```
# tar xvzf check_mssql_health_[version].tar.gz
# cd check_mssql_health_[version]
# ./configure --prefix'/srv/eyesofnetwork/nagios-3.0.6' --with-nagios-group=eyesofnetwork
# make
# make install
```


Une fois encore, il est important de ne pas mettre de **/** final dans le chemin indiqué dans la ligne **./configure**. Une fois les commandes exécutées avec succès, le script est installé dans le dossier **/srv/eyesofnetwork/nagios-3.0.6/libexec**.

Ca y est ? Non...

Même si maintenant tout est correctement configuré et installé côté plugin, il est encore nécessaire de configurer votre base MSSQL pour qu’elle accepte les connexions. Je ne traiterai pas de l’aspect création d’un utilisateur avec des droits suffisant pour lire l’état de la base, je ne suis vraiment pas un expert, et j’imagine qu’on trouve de très bon tutos sur le net, expliquant bien chaque type de droit, et la manière de bien le faire. Vous pouvez soit chercher du côté de MS SQL Server Management Studio, soit effectuer les autorisations manuellement via le tuto du [site de mssql_health_check](http://labs.consol.de/lang/en/nagios/check_mssql_health/).

Pour que la base accepte les connexions distantes de notre client FreeTDS, il faut d’abord s’assurer que le pare feu Windows laisse bien entrer les connexions **TCP** sur le port **1433**, et que le serveur les accepte, lui aussi.

Pour se faire, il suffit d’utiliser l’utilitaire **SQL Server Configuration Manager**, installé par défaut avec la base de données, puis d’aller dans **Configuration du réseau SQL Server 2005/Protocole pour [nom\_base\_données]/TCP/IP**. Dans l’onglet **Protocoles**, choisir **Oui** pour la valeur **Activer**. Le serveur doit ensuite être redémarré pour que les modifications soient bien prises en compte.

Ouf... Il ne reste plus qu’à lancer vos sondes depuis Nagios, maintenant!
