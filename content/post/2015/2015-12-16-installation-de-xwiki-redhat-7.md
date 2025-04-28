---
title: '[Tutoriel] Installer XWiki 7.X sur RedHat/CentOS 7 (Tomcat + PostGreSQL)'
authors:
  - zwindler
type: post
date: 2015-12-16T17:30:53+00:00
url: /2015/12/16/installation-de-xwiki-redhat-7/
image: /2015/11/1434473398.png
categories:
  - Logiciel
tags:
  - CentOS 7
  - hibernate
  - javassist-3.19.0-GA.jar
  - LDAP
  - PostgreSQL
  - RedHat 7
  - Tomcat
  - tutoriel
  - WAR
  - XAR
  - Xwiki
  - XWiki 7.2
  - XWiki 7.X

---
## XWiki, c’est quoi ?

En entreprise, il n’est pas rare que les utilisateurs expriment leur besoin de stocker l’information de manière intelligente aux administrateurs systèmes. Ça peut passer par une GED, une plateforme de travail collaboratif, et même dans certains cas, un wiki (l’exemple le plus connu de wiki est [Wikipedia][1], au cas où ça ne voyez pas de quoi on parle).

Comme je travaille dans l’IT, je ne suis pas encore tombé dans un contexte où un wiki n’avait pas sa place et c’était même souvent un projet pris très au sérieux.

Très au sérieux, d’accord, mais quand même, le mieux serait que ça soit gratuit ! Argument que j’entends relativement souvent de la part des directions, et c’est de bonne guerre ;-).

Du coup, le choix est tout de suite plus restreint. De ce que j’ai pu trouver dans le marché du gratuit et/ou opensource et pas trop confidentiel pour avoir une chance que le projet survive quelques années, j’ai trouvé :

* [Mediawiki][2] => le logiciel sur lequel est basé Wikipedia, que j’ai utilisé à titre personnel mais qui nécessite de connaitre un peu la syntaxe pour obtenir un rendu visuel correct
* [Dokuwiki][3] =>que je n’ai pas utilisé ni même testé, mais j’ai eu de bon retours
* [XWiki][4] => un logiciel en Java dont la syntaxe est proche des autres logiciels wiki mais qui dispose surtout de manière native d’un éditeur WYSIWYG (_what you see is what you get_, autrement dit : comme word. Le resultat final est visible en temps réel)

La nécessité d’avoir un éditeur WYSIWYG étant un prérequis pour les utilisateurs, je n’ai pas vraiment cherché plus loin : **nous avons installé XWiki**.

Pour débuter, XWiki vous propose un fichier installeur sous Linux ou Windows où tout est pré-parametré avec une base de données interne et un serveur d’application web java intégré. Cependant, j’aime avoir un minimum la main sur ce que j’administre, je ne maitrise pas la base HSQLDB et j’ai eu des soucis avec les options de Jetty. C’est pourquoi j’ai préféré installer moi même le serveur de base de données PostgreSQL et le serveur java Tomcat.

Je vous propose donc d’installer XWiki via le WAR, avec un serveur RedHat Entreprise Linux 7 (ou CentOS 7, c’est pareil), un serveur Tomcat 7 et une base de données postgreSQL 9.2.

Ce tutoriel décrit de manière séquentielle l’ensemble des opérations nécessaires pour y parvenir, à partir des informations qu’on peut trouver dans plusieurs pages éparpillées dans la [documentation officielle][5] (et avec quelques captures d’écran en bonus track).

## Installation de l’OS

Comme indiqué plus haut, j’ai commencé par installer une machine virtuelle RedHat Entreprise Linux 7.1 au format Desktop (poste de travail). L’ensemble des prérequis sont listés dans la [documentation officielle][6].

Une fois que c’est réglé, on peut aller récupérer les sources [sur le site officiel][7]. Au moment où j’ai écris ces lignes, la version Xwiki 7.2 est la version dite stable (en fait en vrai on est pas loin de la 7.4, mais j’ai tardé à publier l’article. Le principe reste le même).

[EDIT 26/01/16] Attention si vous utilisez PostGreSQL, il y a [un bug en cours sur le widget qui affiche l’arborescence][8], du coup j’ai du rollback en 7.2.

J’avais voulu faire la mise à jour car la 7.4 corrige un bug qui date de la version 3.X sur certains PNG qui font planter l’export PDF.

[/EDIT]

Récupérez les fichiers suivants :

  * xwiki-enterprise-web-7.2.war
  * xwiki-enterprise-ui-mainwiki-all-7.2.xar

## Installation et configuration de Tomcat 7

Je n’ai pas voulu installer à la main tomcat, RHEL 7 propose une version _relativement_ récente de tomcat 7 qui convient très bien dans les repository officiels.

```
yum install tomcat
```


Les instructions pour configurer Tomcat pour XWiki sont listées [dans la page suivante][9].

Copiez le war dans l’arborescence **/var/lib/tomcat/webapps** :

```
[root@monwiki webapps]# pwd
/var/lib/tomcat/webapps
[root@monwiki webapps]# ll
[...]
-rw-r--r--. 1 root root 227064164 6 nov. 15:16 xwiki-enterprise-web-7.2.war
```


Passez le serveur en UTF-8 (au niveau du **connector** dans **/etc/tomcat/server.xml**) :

```
<Connector port="8080" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" URIEncoding="UTF-8" />
```


Ajoutez l’option suivante dans la configuration tomcat :

```
vi /etc/tomcat/tomcat.conf
    CATALINA_OPTS="-Xmx1024m -XX:MaxPermSize=192m"
```


Ajoutez l’option suivante dans les propriétés de tomcat :

```
vi /etc/tomcat/catalina.properties
    org.apache.tomcat.util.buf.UDecoder.ALLOW_ENCODED_SLASH=true
```


Déployez le war en lançant une première fois le service tomcat :

```
systemctl start tomcat
systemctl enable tomcat
```


Vérifiez que tout se passe bien avec _tail -f /var/log/tomcat/catalina.2015-11-10.log_ #remplacer par la date du jour

```
INFOS: Deployment of web application archive /var/lib/tomcat/webapps/xwiki-enterprise-web-7.2.war has finished in 31 a 560 ms
nov. 10, 2015 4:07:47 PM org.apache.coyote.AbstractProtocol start
INFOS: Starting ProtocolHandler ["http-bio-8080"]
nov. 10, 2015 4:07:47 PM org.apache.coyote.AbstractProtocol start
INFOS: Starting ProtocolHandler ["ajp-bio-8009"]
nov. 10, 2015 4:07:47 PM org.apache.catalina.startup.Catalina start
INFOS: Server startup in 31609 ms
```


Le seul inconvénient à choisir la version de tomcat présente dans les repositories est qu’un des mécanismes intégrés de scan des jar (archives java) dans cette version provoque l’apparition dans le log d’un très grand nombre de « stack trace » dans votre **catalina.out** :

```
GRAVE: Unable to process Jar entry [javassist/util/proxy/SerializedProxy.class] from Jar
[jar:file:/usr/share/tomcat/webapps/xwiki-enterprise-web-7.2/WEB-INF/lib/javassist-3.19.0-GA.jar!/] for annotations
java.io.EOFException
at java.io.DataInputStream.readUnsignedShort(DataInputStream.java:340)
at org.apache.tomcat.util.bcel.classfile.Utility.swallowMethodParameters(Utility.java:797)
at org.apache.tomcat.util.bcel.classfile.Attribute.readAttribute(Attribute.java:171)
[...]
```


Avec une version plus récente de tomcat, un warning est simplement indiqué dans le log. Cette erreur n’est pas bloquante, juste désagréable.

Copiez le driver jdbc 41 (.jar) pour postgreSQL 9.2 dans **WEB-INF/lib** du répertoire de XWiki dans tomcat. Vous pouvez le télécharger à l’adresse [suivante](https://jdbc.postgresql.org/download/).

```
cd /var/lib/tomcat/webapps/xwiki-enterprise-web-7.2/WEB-INF/lib
chown tomcat:tomcat postgresql-9.2-1004.jdbc41.jar
```

## Installation et configuration de PostGreSQL 9.2

La encore, j’ai préféré installer PostGreSQL par le biais des dépôts RPM plutôt que de l’installer à la main.

```
yum install postgresql postgresql-server postgresql-jdbc
```


Les informations permettant de configurer la base de données PostGreSQL pour XWiki sont disponible sur [la documentation officielle][10].

La première commande à passer sur la base PostGreSQL est de l’initialiser avec la commande suivante :

```
postgresql-setup initdb
```


Pour information, sur RHEL/CentOS 6, la base est en version 8.4 et pour l’initialiser il faut utiliser :

```
service postgresql initdb
```


Personnellement j’aime ajouter un lien symbolique pour retrouver mes logs dans /var/log mais c’est totalement un choix personnel.

```
ln -s /var/lib/pgsql/data/pg_log /var/log/pgsql
```


Mdofier la sécurité pour l’authentification des utilisateurs sans utiliser les utilisateurs Unix (changer ident par md5 ou éventuellement trust) :

```
vi /var/lib/pgsql/data/pg_hba.conf
    # IPv4 local connections:
    host all all 127.0.0.1/32 md5
```


Démarrez la base de données puis créer la base qui sera dédiée au xwiki et son utilisateur associé :

```
systemctl start postgresql
systemctl enable postgresql
su - postgres
createuser xwiki -S -D -R -P -Upostgres
createdb xwiki -Eunicode -Oxwiki -Upostgres
```


Je vous conseille aussi de faire un petit test de connexion pour vérifier que tout est bien configuré côté authentification :

```
psql -Uxwiki -h 127.0.0.1 -W
```


Pour information si jamais vous aviez besoin de la détruire a posteriori, la commande est :

```
dropdb -Upostgres xwiki
```


## Configuration de XWiki 7.2

Maintenant qu’on dispose d’une base de données et d’un serveur d’application java, on peut commencer à configurer l’application XWiki en elle même. Configurer hibernate pour que xwiki stocke sa base sur pgsql

```
vi /var/lib/tomcat/webapps/xwiki-enterprise-web-7.2/WEB-INF/hibernate.cfg.xml
```


Supprimez les lignes liées à la base hsqldb (interne) et décommenter les lignes « PostgreSQL configuration » (en affectant les bonnes valeurs).

```
<property name="connection.url">jdbc:postgresql://localhost:5432/xwiki</property>
    <property name="connection.username">xwiki</property>
    <property name="connection.password">VOTREMOTDEPASSE</property>
    <property name="connection.driver_class">org.postgresql.Driver</property>
    <property name="dialect">org.hibernate.dialect.PostgreSQLDialect</property>
    <property name="jdbc.use_streams_for_binary">false</property>
    <property name="xwiki.virtual_mode">schema</property>
    <mapping resource="xwiki.postgresql.hbm.xml"/>
    <mapping resource="feeds.hbm.xml"/>
    <mapping resource="activitystream.hbm.xml"/>
    <mapping resource="instance.hbm.xml"/>
    <mapping resource="mailsender.hbm.xml"/>
```


Remplacez la clé de chiffrement du cookie dans le **xwiki.cfg** (pour éviter qu’un attaquant puisse déchiffrer les cookies) et [activez temporairement le superadmin][11] pour se connecter au wiki pour la première connexion

```
vi /var/lib/tomcat/webapps/xwiki-enterprise-web-7.2/WEB-INF/xwiki.cfg
    xwiki.authentication.validationKey=1234totototototototototototototo
    xwiki.authentication.encryptionKey=1234titititititititititititititi
[...]
    xwiki.superadminpassword=system
```


Redémarrez tomcat

```
systemctl restart tomcat
```


Ouvrir un navigateur sur l’URL de votre Wiki `http://wiki.example.org:8080/xwiki-enterprise-web-7.2/bin/view/Main/`.

Le wizard de « premier déploiement » doit apparaître. Vous le verrez à nouveau en cas de mise à jour.

## Déployer le XAR « Main » qui contient l’ensemble des pages par défaut

**Attention :** Ce qu’il faut savoir c’est que par défaut, les XWiki sont installés sans aucunes pages. Les pages par défaut doivent être chargées manuellement via un import la première fois. C’est à ça que sert le fichier **xwiki-enterprise-ui-mainwiki-all-7.2.xar** que vous avez téléchargé au début de la procédure.

Tout est expliqué dans la [documentation officielle][12].

![](/2015/11/00_xwiki.png) 

![](/2015/11/01_xwiki.png) 

Ici on peut voir que la « User Interface » n’est pas disponible. J’ai l’impression que c’est le cas si votre VM n’a pas accès à Internet. Dans ce cas là, vous devez récupérer le xar contenant l’ensemble des pages par défaut pour les réimporter en tant que superadmin. Dans le cas où le bouton « Install » sous « User Interface », ce qui suit n’est pas nécessaire.

Cliquez sur [Later].

Normalement une page pratiquement vide doit apparaître. Il s’agit du squelette du XWiki 7.2.

Se connecter sur le wiki en tant que superadmin / system et ouvrir la page d’administration (sur le côté droit)

![](/2015/11/015_xwiki.png)  
![](/2015/11/02_xwiki.png) 

Cliquez sur « Import » et uploadez le fichier **xwiki-enterprise-ui-mainwiki-all-7.2.xar** préalablement téléchargé. Après upload, le package apparait dans « Available Packages »

![](/2015/11/03_xwiki.png) 

En cliquant sur le fichier xar qui vient d’être uploadé, on peut sélectionner les pages qu’on ne souhaite pas utiliser (typiquement j’ai désactivé Blog et Sandbox qui ne me servent pas).

![](/2015/11/04_xwiki.png) 

Cocher « Import as backup package », puis cliquer sur « Import ».

![](/2015/11/05_xwiki.png) 

Maintenant que les pages par défaut sont importées, on a un compte administrateur local pour se connecter (Admin / admin).

![](/2015/11/06_xwiki.png)  
![](/2015/11/07_xwiki.png) 

Voilà un wiki fonctionnel utilisable en entreprise.

## Bonus, pousser un peu la configuration du XWiki

Ok ça fonctionne. Mais bon, la première chose que vous voudrez peut être faire c’est passer le XWiki en Français.

Pour se faire, allez dans Administration, Localization, positionner les deux paramètres « en » à « fr » et enregistrer. La langue devrait changer automatiquement (sans redémarrage).  

![](/2015/11/08_xwiki.png) 

Et enfin voici les différents paramètres pour désactiver le superadmin, ajouter l’authentification LDAP (exemple Active Directory, mais je l’ai fais aussi marcher en Novell et en OpenLDAP) et activer les statistiques (désactivées par défaut pour améliorer les performances).

```
vi /var/lib/tomcat/webapps/xwiki-enterprise-web-7.2/WEB-INF/xwiki.cfg
    # xwiki.superadminpassword=system
[...]
    xwiki.authentication.ldap=1
    xwiki.authentication.ldap.server=dom
    xwiki.authentication.ldap.port=389
    xwiki.authentication.ldap.bind_DN=CN=ldapreadonly,OU=xxx,DC=xxx,DC=xxx
    xwiki.authentication.ldap.bind_pass=xxxxxxxxx
    xwiki.authentication.ldap.base_DN=OU=xxx,DC=xxx,DC=xxx
    xwiki.authentication.ldap.UID_attr=sAMAccountName
    xwiki.authentication.ldap.fields_mapping=name=sAMAccountName,last_name=sn,first_name=givenName,fullname=displayName,email=mail,ldap_dn=dn
[...]
    xwiki.stats=1
    xwiki.stats.default=1
```


Redémarrez Tomcat pour prise en compte des nouveaux paramètres.

```
systemctl restart tomcat
```


 [1]: https://fr.wikipedia.org/wiki/Wikip%C3%A9dia:Accueil_principal
 [2]: https://www.mediawiki.org/wiki/MediaWiki/fr
 [3]: https://www.dokuwiki.org/dokuwiki#
 [4]: http://www.xwiki.com/fr/
 [5]: http://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/InstallationWAR
 [6]: http://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Installation
 [7]: http://enterprise.xwiki.org/xwiki/bin/view/Main/Download
 [8]: http://jira.xwiki.org/browse/XWIKI-13025
 [9]: http://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/InstallationTomcat
 [10]: http://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/InstallationPostgreSQL
 [11]: http://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Configuration#HEnablesuperadminaccount
 [12]: http://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/InstallationWAR#HInstallingtheDefaultWikiXAR
