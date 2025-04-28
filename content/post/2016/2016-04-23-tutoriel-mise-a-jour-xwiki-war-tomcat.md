---
title: '[Tutoriel] Mise à jour XWiki depuis un war dans Tomcat'
authors:
  - zwindler
type: post
date: 2016-04-23T10:30:59+00:00
url: /2016/04/23/tutoriel-mise-a-jour-xwiki-war-tomcat/
image: /2015/11/1434473398.png
categories:
  - Logiciel
tags:
  - Mise à jour
  - Tomcat
  - WAR
  - Xwiki
  - XWiki 7.2
  - XWiki 7.4

---
Cette procédure donner les étapes pour mettre à jour un XWiki depuis la nouvelle version du fichier war dans Tomcat. L’exemple que je donne permet de faire une mise à jour (mineure) entre la 7.2 et la 7.4.2 qui corrige plusieurs bugs de la version 7.2 et ajoute quelques fonctionnalités supplémentaires.

## Mise à jour WAR

Coupez le serveur d’application

```
service tomcat stop
```


Récupérez le dossier xwiki dans webapps pour archive

```
cd /var/lib/tomcat/webapps/
mv xwiki /distrib/archive_xwiki_7.2
```


Déposez le fichier xwiki-enterprise-web-7.4.2.war dans **/var/lib/tomcat/webapps** puis relancer T0mcat pour démarrer l’extraction du war

```
service tomcat start
```


Vérifiez dans les logs que l’application se déploie bien

```
tail -f /var/log/messages
   Dec 30 10:43:48 xwiki01 server: INFOS: Démarrage du service Catalina
   Dec 30 10:43:48 xwiki01 server: déc. 30, 2015 10:43:48 AM org.apache.catalina.core.StandardEngine startInternal
   Dec 30 10:43:48 xwiki01 server: INFOS: Starting Servlet Engine: Apache T0mcat/7.0.54
   Dec 30 10:43:48 xwiki01 server: déc. 30, 2015 10:43:48 AM org.apache.catalina.startup.HostConfig deployWAR
   Dec 30 10:43:48 xwiki01 server: INFOS: Déploiement de l'archive /var/lib/t0mcat/webapps/xwiki-enterprise-web-7.4.2.war de l'application web
```


Une fois que c’est fait, nettoyez les fichiers. Habituellement je renomme le dossier pour simplifier la gestion de l’URL d’accès à l’application mais on pourrait le faire avec une redirection nginx/apache/vultureSSO ou tout simplement un lien symbolique sur le dossier.

```
[root@xwiki01 webapps]# rm xwiki-enterprise-web-7.4.2.war
rm : supprimer fichier « xwiki-enterprise-web-7.4.2.war » ? y
[root@xwiki01 webapps]# ll
total 0
drwxr-xr-x. 7 t0mcat t0mcat 94 30 déc.  10:43 xwiki-enterprise-web-7.4.2
[root@xwiki01 webapps]# mv xwiki-enterprise-web-7.4.2 xwiki
[root@xwiki01 webapps]#
```


Arrêtez tomcat pour modifier les fichiers de configuration

```
service tomcat stop
```


Copiez du connecteur java postgresql (ou mysql) dans les libs de XWiki

```
cp /distrib/archive_xwiki/WEB-INF/lib/postgresql-9.2-1004.jdbc41.jar /var/lib/tomcat/webapps/xwiki/WEB-INF/lib/
#ou /distrib/archive_xwiki/WEB-INF/lib/mysql-connector-java-5.1.22-bin.jar
```


En théorie, il faut faire attention et comparer les nouveaux fichiers de configuration apportés par la nouvelles version dans le cas où il y aurait des modifications entre les deux versions.

```
[root@xwiki01 webapps]# cd /distrib/xwiki_archive_7.2/WEB-INF/
cp hibernate.cfg.xml xwiki.cfg xwiki.properties /var/lib/tomcat/webapps/xwiki/WEB-INF/
   cp : voulez-vous écraser « /var/lib/t0mcat/webapps/xwiki/WEB-INF/hibernate.cfg.xml » ? y
   cp : voulez-vous écraser « /var/lib/t0mcat/webapps/xwiki/WEB-INF/xwiki.cfg » ? y
   cp : voulez-vous écraser « /var/lib/t0mcat/webapps/xwiki/WEB-INF/xwiki.properties » ? y
```


Pour mettre à jour le schéma de la base de données, ajoutez la ligne suivante dans le fichier **xwiki.cfg**. N’oubliez pas de le retirer une fois la mise à jour effectuée, car ce paramètre rallonge le temps de démarrage du Xwiki.

```
xwiki.store.migration=1
```


Maintenant que le WAR est mis à jour et les fichiers de configuration remis à niveau, on peut passer à la mise à jour dans l’application elle même.

```
[root@xwiki01 lib]# systemctl start tomcat
```


## Mise à jour application XWiki

Se connecter sur le XWiki, le serveur s’initialise.

![](/2016/03/xwiki_upgrade.png)

L’assistant de distribution, identique à celui qui s’ouvre lors du premier lancement après installation apparait.

![](/2016/03/xwiki_upgrade-2.png)

L’assistant nous propose la version 7.4 qu’on souhaite installer.

![](/2016/03/xwiki_upgrade-3.png)

Cliquer sur « Installer ». Le wiki se met à jour. Dans le cas où certaines pages importés entrent en conflit, l’assistant propose soit de mettre à jour, soit de laisser tel quel. Dans la plupart des cas, il vaut mieux tout accepter mais si vous savez ce que vous faites, vous pouvez refuser l’écrasement de la page.

![](/2016/03/xwiki_upgrade-4.png)

Une fois le processus terminé, le wiki redevient accessible.
