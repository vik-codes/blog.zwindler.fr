---
title: Mise en place de Guacamole 0.9.5 sur CentOS 7
authors:
  - zwindler
type: post
date: 2015-05-31T09:49:36+00:00
url: /2015/05/31/mise-en-place-de-guacamole-0-9-5-sur-centos-7/
image: /2015/05/guac-tricolor.png
categories:
  - autohebergement
tags:
  - authentification
  - CentOS 7
  - Guacamole
  - html5
  - MariaDB
  - MySQL
  - RDP
  - RHEL 7
  - SSH
  - telnet
  - Tomcat
  - tutoriel
  - VNC

---
**Pour information** : je me suis basé sur le très bon article de **Deviant Engineer**, qui est concis, s’affranchit de la conf par fichier plat au profit du module MySQL, **et surtout** qui fonctionne, ce qui n’est pas le cas de tous les tutoriels que j’ai pu croiser sur la toile.

Aujourd’hui, au même titre que l’informatique s’est généralisée, Internet est de plus en plus présent, où qu’on se trouve. Mais ce n’est pas toujours un Internet comme à la maison.

Pour des raisons de sécurité et/ou de bande passante, certains ports/protocoles/site web sont souvent bloqués sur les points d’accès public ou d’entreprise. Il n’est pas rare que seul l’HTTP et l’HTTPS soient disponible, me privant ainsi de mes accès SSH/VPN/FTP/...  
C’est un vrai casse tête pour moi : je déploie des services chez moi et j’en deviens dépendant au point d’être agacé de ne pas y avoir accès en toutes circonstances. Et plutôt que de relativiser cet absence d’accès absolu à mes services/données, je préfère chercher des moyens de contournement ;).

Si l’autohébergement d’applications web et l’utilisation d’un reverse proxy (Vulture/Apache) répond à une partie de cette problématique, des fois, j’ai parfois besoin d’avoir accès aux machines qui hébergent ces services. C’est pourquoi j’utilisais jusqu’à présent Ajaxterm, puis Gateone pour disposer d’un accès SSH à mes serveurs en cas de filtrage.

Cependant, j’ai aussi besoin de me connecter en mode graphique sur mes serveurs. En présentant au travers d’une interface HTML5 des clients pour les protocoles SSH, VNC et RDP, Guacamole répond à ce besoin.

Quelques ressources pour bien commencer :

  * [le site officiel][1]
  * [la documentation d’installation officielle][2]
  * [le tutoriel de Devian Engineer (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20160814174529/https://deviantengineer.com/2015/02/guacamole-centos7/)

La documentation officielle décrit comment l’installer à partir des sources. Cependant, sur certains systèmes, les applications ont été packagées et sont disponibles (0.8.4 si je ne m’abuse sur RHEL et CentOS). Je voulais avoir la version la plus récente, je me suis donc penché sur la solution « compilation ».

Et pour avoir une compatibilité maximale en terme de fonctionnalités, il faut disposer de Tomcat 7, présent nativement dans RHEL7/CentOS7, que j’ai donc installé (mon premier CentOS7, youhou !)

## Prérequis

Forcément, la première chose à faire lorsqu’on installe une application web un peu exotique sur un CentOS, c’est d’installer les dépôts additionnels pour les dépendances (ici EPEL).

```
rpm -Uvh http://mirror.metrocast.net/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm # EPEL Repo
yum -y install wget
wget http://download.opensuse.org/repositories/home:/felfert/Fedora_19/home:felfert.repo && mv home\:felfert.repo /etc/yum.repos.d/ # Felfert Repo
yum -y install tomcat libvncserver freerdp libvorbis libguac libguac-client-vnc libguac-client-rdp libguac-client-ssh
yum -y install cairo-devel pango-devel libvorbis-devel openssl-devel gcc pulseaudio-libs-devel libvncserver-devel \
freerdp-devel uuid-devel libssh2-devel libtelnet libtelnet-devel tomcat-webapps tomcat-admin-webapps java-1.7.0-openjdk.x86_64
```


## Installation du composant « serveur »

Le logiciel est découpé en deux parties. Une partie « serveur » qui correspond au portail web, et une partie dite « cliente », qui se charge de la connexion aux différents serveurs SSH/~~telnet~~/VNC/RDP que vous aurez configurés. J’ai rayé telnet car je refuse d’utiliser ce protocole (à l’exception de certaines contraintes de travail très particulières).

```
cd /distrib
wget http://sourceforge.net/projects/guacamole/files/current/source/guacamole-server-0.9.5.tar.gz
tar -xzf guacamole-server-0.9.5.tar.gz && cd guac*0.9.5
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
```


## Installation du du composant « client »

La partie client peut directement être récupérée tel quel sur le site du projet.

```
mkdir -p /var/lib/guacamole && cd /var/lib/guacamole/
wget http://sourceforge.net/projects/guacamole/files/current/binary/guacamole-0.9.5.war -O guac.war
ln -s /var/lib/guacamole/guac.war /var/lib/tomcat/webapps/
rm -rf /usr/lib64/freerdp/guacdr.so
ln -s /usr/local/lib/freerdp/guacdr.so /usr/lib64/freerdp/
```


## MariaDB (MySQL)

Ne soyez pas surpris de découvrir MariaDB. MariaDB, c’est MySQL. Ou plutôt ce que MySQL aurait du devenir. Il s’agit d’un fork de MySQL initié par son créateur qui a réalisé qu’Oracle (qui a racheté Sun Microsystems en 2009) risquait d’envoyer le produit dans le mur (en concurrence avec Oracle Database).  
MariaDB a donc progressivement remplacé MySQL dans les communautés Open Source et les entreprises (citons Google en 2013), et RedHat a suivi le mouvement avec la version 7 de RHEL.  
Pas de mauvaise surprise si vous êtes habitués à MySQL : tout est identique en terme d’administration. Vos scripts fonctionneront toujours, les binaires n’ont pas changés.

### Installation de la base de données

```
yum -y install mariadb mariadb-server
cd /distrib
wget http://sourceforge.net/projects/guacamole/files/current/extensions/guacamole-auth-mysql-0.9.5.tar.gz
tar -zxf guacamole-auth-mysql-0.9.5.tar.gz
wget http://dev.mysql.com/get/Downloads/Connector/j/mysql-connector-java-5.1.32.tar.gz
tar -zxf mysql-connector-java-5.1.32.tar.gz
mv mysql-connector-java-5.1.32/mysql-connector-java-5.1.32-bin.jar guacamole-auth-mysql-0.9.5/lib/
mkdir /var/lib/guacamole/classpath/
cp /distrib/guacamole-auth-mysql-0.9.5/lib/* /var/lib/guacamole/classpath/
systemctl restart mariadb.service
```


### Configuration de la base de données

```
mysqladmin -u root password MySQLRootPass
mysql -u root -p # Enter above password
create database guacdb;
create user 'guacuser'@'localhost' identified by 'guacDBpass';
grant select,insert,update,delete on guacdb.* to 'guacuser'@'localhost';
flush privileges;
quit
```


### Création du schéma pour Guacd

```
cd /distrib/sqlauth/guacamole-auth-mysql-0.9.5/schema/
cat ./*.sql | mysql -u root -p guacdb # Enter SQL root password set above
```


## Configuration, création du fichier « .properties »

```
mkdir -p /etc/guacamole/ && vi /etc/guacamole/guacamole.properties
  # Hostname and port of gucamole proxy
  guacd-hostname: localhost
  guacd-port: 4822
  # Location to read extra .jar's from
  lib-directory: /var/lib/guacamole/classpath/
  # Authentication provider class
  auth-provider: net.sourceforge.guacamole.net.auth.mysql.MySQLAuthenticationProvider
  # MySQL properties
  mysql-hostname: localhost
  mysql-port: 3306
  mysql-database: guacdb
  mysql-username: guacuser
  mysql-password: guacDBpass
  # Additional settings
  mysql-disallow-duplicate-connections: false
```


## Post-installation

Ne pas oublier de nettoyer les répertoires contenant les sources (dans /distrib chez moi), ajouter un lien symbolique vers le fichier de configuration et ajouter le démarrage automatique des services

```
mkdir -p /usr/share/tomcat/.guacamole
ln -s /etc/guacamole/guacamole.properties /usr/share/tomcat/.guacamole/
systemctl enable tomcat.service && systemctl enable mariadb.service && chkconfig guacd on
```


Le serveur devrait être accessible à l’adresse http://@IP_serveur:8080/gucamole**/**. A partir de là, vous pouvez configurer vos serveurs SSH/RDP/VNC, créer des utilisateurs et vous connecter.

![](/2015/05/x_guacamole.png)

Deux derniers points :  
- les logs ne sont pas toujours très locaces. Chez moi, il se trouvent dans /var/log/messages et /var/log/tomcat/  
- il manque selon moi un menu pour gérer les connexions actives. Typiquement, dans le cas de VNC, le soft m’indique que j’ai 4 ou 5 sessions ouvertes. Elles n’ont pas l’air concurrentes (je n’en ai qu’une réellement active), mais me parait potentiellement même problématique

 [1]: http://guac-dev.org/
 [2]: http://guac-dev.org/doc/gug/installing-guacamole.html
