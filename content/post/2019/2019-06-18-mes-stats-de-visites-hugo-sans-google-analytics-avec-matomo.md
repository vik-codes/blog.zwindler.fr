---
title: Mes stats dans Hugo sans Google Analytics (Matomo)
authors:
  - zwindler
type: post
date: 2019-06-18T11:45:24+00:00
excerpt: Comment mettre en place Matomo pour récupérer des statistiques sur les utilisateurs avec un blog statique Hugo (CentOS + nginx)
url: /2019/06/18/mes-stats-de-visites-hugo-sans-google-analytics-avec-matomo/
image: /2019/06/hugo_matomo.png
classic-editor-remember:
  - block-editor
categories:
  - Autohébergement
tags:
  - hugo
  - Kibana
  - "Let's Encrypt"
  - matomo
  - nginx
  - piwik
  - wordpress

---

## Matomo, pour faire quoi ?

La semaine dernière j’ai écris un article pour expliquer que j’étais en train de [migrer de WordPress vers Hugo, mais que ce n’était pas si facile](/2019/06/10/comment-migrer-de-wordpress-a-hugo/). D’abord, parce que WordPress fait PLEIN de choses (et c’est à la fois son avantage et son inconvénient) et notamment vous fournir des stats sur vos visiteurs. Et, vous vous en doutez, avec un site statique, on n’a pas ça. C’est là que Matomo rentrera en jeu...

![](/2019/06/wordpress_stats.png) 

## Écraser une mouche avec un bulldozer

Alors OK, les statistiques fournies par Jetpack, ce n’est pas forcément un truc fou non plus.

En réalité, on pourrait se rapprocher de ce qu’on peut faire avec WordPress en terme de statistiques avec ce que j’avais fais lorsque [je testais ElasticStack et en récupérant les stats de nginx](/2017/10/17/elasticstack-afficher-les-donnees-dans-kibana/).



![](/2017/10/elk16.png) 

Mais clairement, pour en arriver au même niveau de détail, il va falloir passer pas mal de temps à nettoyer les données de références (les logs nginx) et à concevoir les tableaux de bord (dans Kibana).

Au final, on pourra même aller encore plus loin, mais ça sera nécessairement très coûteux en temps de développement / configuration.

## Méfie-toi du côté obscur. Plus rapide, plus facile, plus séduisant
  
Si c’est la simplicité que l’on cherche, alors clairement, le plus facile sera probablement d’ouvrir un compte Google Analytics et d’ajouter le petit bout de code fourni clé en main.

De ce point de vue, ça sera clairement le plus simple et vous aurez à votre disposition un outil à la fois simple et puissant. Et qu’importe si Google ~~espionne~~ profile (un peu plus) vos utilisateurs ?

Je vais partir du principe que si vous auto-hébergez comme moi, vous n’avez pas envie de faciliter la tâche à Google. Et c’est donc pour cela que je vous propose une autre option : [Matomo](https://matomo.org/).

## Donc on ne sait toujours pas ce que c’est que Matomo, en fait...
  
  
Pour ceux qui l’ont connu, [Matomo](https://matomo.org/) est le successeur de Piwik (ça vous parle peut être plus, le projet a été renommé en 2018) et permet d’obtenir un outil similaire à Google Analytics, mais open source ET que vous pouvez auto-héberger.
Exit donc, Google, pour un résultat similaire et le tout chez vous.
A noter, Matomo propose également une plateforme Analytics managée (payante), qui fera office de concurrent stricto sensu à Google Analytics et a priori plus vertueux envers la vie privée de vos utilisateurs (mais je n’ai pas vérifié).

## Le usecase

J’ai donc sur les bras une plateforme Hugo pour le blog, sans aucune stat. Dans mon cas, Hugo est hébergé sur une plateforme CentOS / nginx. Idéalement, j’aimerai bien pouvoir garder mon Matomo sur la même machine, pour faire simple.

Et malheureusement pour moi, la plupart des gens qui ont fait des tutos sur le net ont eux installés ça sur Ubuntu (ça c’est respectable) et souvent sur Apache HTTPd (là par contre, emoji-qui-vomi).

## Installation des prérequis

C’est donc parti pour installer Matomo dans un premier temps (on verra ensuite pour Hugo). La stack technique de Matomo étant basée sur PHP/MySQL, on va devoir installer php-fpm pour le moteur PHP et MariaDB.

Et comme sur CentOS, PHP et ses dépendances datent de Mathusalem, on va faire appel une fois de plus aux répos de rémi. Encore une fois, merci à lui...

```
sudo yum install epel-release
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum install yum-utils
sudo yum-config-manager --enable remi-php72

sudo yum update
sudo yum install mariadb-server nginx php-fpm php-mysql php-mbstring php-dom php-xml php-gd freetype unzip wget
```

Dans le cas (probable) où vous souhaitez aussi avoir une meilleure localisation de vos lecteurs/visiteurs, il faudra ajouter des modules complémentaire pour GeoIP

```
sudo yum install gcc php-devel
```

Maintenant que c’est fait, on peut démarrer php-fpm et l’activer au démarrage de la machine

```
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

sudo systemctl start mariadb
sudo systemctl enable mariadb
```

As usual, quand on installe pour la première fois mariadb (ou mysql), on n’oublie surtout pas de passer le petit tool de nettoyage/sécurisation "minimal" :

```
mysql_secure_installation
```

Ok, on a un moteur de base de données utilisable maintenant. On va donc créer une base et un utilisateur dédiés à Matomo :

```
mysql -u root -p
mysql> CREATE DATABASE matomo;
mysql> CREATE USER 'matomo'@'localhost' IDENTIFIED BY 'myawesomepassword';
mysql> GRANT ALL ON matomo.* TO 'matomo'@'localhost';
mysql> FLUSH PRIVILEGES;
exit
```

## Installer Matomo

On a fait le tour des prérequis. On peut maintenant installer et commencer à configurer notre Matomo. Le plus simple reste de télécharger le dernier build sur le site de matomo, et de déposer les sources dans notre "dossier root" nginx :

```
cd /tmp
wget https://builds.matomo.org/matomo-latest.zip
unzip matomo-latest.zip
sudo mv matomo /usr/share/nginx/html
```

Dans les prérequis que vous auriez peut être loupés, Matomo conseille également d’ajouter un job de nettoyage dans la crontab. Ce n’est pas nécessaire pour démarrer, mais autant faire les choses bien dès le début. Pour faire simple, j’ai créé un fichier matomo-archive dans _/etc/cron.d_ (mais un crontab -e ferait tout aussi bien l’affaire) :

```
cat /etc/cron.d/matomo-archive
MAILTO="awesome@email.provider"
5 * * * * nginx /usr/bin/php /usr/share/nginx/html/matomo/console core:archive --url=https://matomo.youexample.org/ > /var/log/nginx/matomo.archive.log
```

Ensuite, je vais partir du principe que vous allez exposer votre Matomo sur Internet, donc forcément en 443, avec une génération de certificat automatique via [Let’s Encrypt](/recherche/?keyword=let%27s+encrypt).

Là c’est clairement un peu plus touchy, donc si vous voulez plus de détails sur le pourquoi du comment de chaque bloc de configuration nginx, je vous renvoie au [fichier d’exemple disponible sur le github de Matomo](https://github.com/matomo-org/matomo-nginx/blob/master/sites-available/matomo.conf). La subtilité par rapport au fichier d’exemple est que comme nous sommes sur CentOS et pas Ubuntu, on n’utilise pas le socket unix pour accéder à php-fpm, mais le port 9000

```
sudo vi /etc/nginx/sites-available/matomo.example.org.conf

server {
  listen 443 ssl http2;
  server_name matomo.example.org;

  ssl_certificate /etc/letsencrypt/live/matomo.example.org/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/matomo.example.org/privkey.pem;

  index index.php;
  root /usr/share/nginx/html/matomo;

  access_log /var/log/nginx/matomo.access.log;
  error_log /var/log/nginx/matomo.error.log;

  index index.php;

  location ~ ^/(index|matomo|piwik|js/index).php {
    include fastcgi.conf; 
    fastcgi_param HTTP_PROXY "";
    fastcgi_pass 127.0.0.1:9000;
  }

  location = /plugins/HeatmapSessionRecording/configs.php {
    include fastcgi.conf;
    fastcgi_param HTTP_PROXY "";
    fastcgi_pass 127.0.0.1:9000;
  }

  location ~* ^.+\.php$ {
    deny all;
    return 403;
  }

  location / {
    try_files $uri $uri/ =404;
  }

  location ~ /(config|tmp|core|lang) {
    deny all;
    return 403; 
  }

  location ~ /\.ht {
    deny all;
    return 403;
  }

  location ~ \.(gif|ico|jpg|png|svg|js|css|htm|html|mp3|mp4|wav|ogg|avi|ttf|eot|woff|woff2|json)$ {
    allow all;
    expires 1h;
    add_header Pragma public;
    add_header Cache-Control "public";
  }

  location ~ /(libs|vendor|plugins|misc/user) {
    deny all;
    return 403;
  }

  location ~/(.*\.md|LEGALNOTICE|LICENSE) {
    default_type text/plain;
  }
}
```

Maintenant que notre matomo est prêt à être accéder depuis l’extérieur, n’oubliez pas de :
  
* Créer le record DNS pour matomo.example.org
* Générer le certificat Let’s Encrypt
  
Activez le site en créant un lien symbolique entre sites-enabled et sites-available, vérifiez la conf et rechargez nginx

```
sudo ln -s /etc/nginx/sites-available/matomo.example.org.conf /etc/nginx/sites-enabled/matomo.example.org.conf
nginx -t
sudo systemctl reload nginx
```

A partir de maintenant, le site est accessible, à l’URL https://matomo.example.org/index.php

Éditer la configuration pour forcer le TLS puis redémarrer php-fpm

```
vi /usr/share/nginx/html/matomo/config/config.ini.php
[General]
salt = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
trusted_hosts[] = "matomo.example.org"
trusted_hosts[] = "blog.example.org"
force_ssl = 1
```

Tuner la configuration de MariaDB pour faire plaisir à Matomo

```
vi /etc/my.cnf
max_allowed_packet=128M

systemctl restart mariadb
```

Et pour finir, cette partie manque pas mal dans la doc (genre, pas documenté du tout) et me parait pourtant essentiel. Il faut compiler les modules manquants pour ajouter GeoIP 2 (libmaxminddb et MaxMind-DB-Reader-php).

```
wget https://github.com/maxmind/libmaxminddb/releases/download/1.3.2/libmaxminddb-1.3.2.tar.gz
tar xzf libmaxminddb-1.3.2.tar.gz && cd libmaxminddb-1.3.2
./configure
make
sudo make install
sudo ldconfig

cd ..
wget https://github.com/maxmind/MaxMind-DB-Reader-php/archive/v1.4.1.tar.gz
tar xzf v1.4.1.tar.gz && cd MaxMind-DB-Reader-php-1.4.1/ext
phpize
/configure
make
sudo make install
echo "extension=maxminddb.so" > /etc/php.d/30-maxminddb.ini
systemctl restart php-fpm
```



![](/2019/06/matomo.png) 

> Tadaaaa ! 

## Configurer Hugo pour ajouter le code Matomo
  
Cool ! Tout est correctement configuré dans Matomo. Maintenant, il faut terminer par ajouter le code de Hugo pour communiquer avec Matomo.

Pour se faire, on peut utiliser le projet suivant, qui agit comme un thème complémentaire et étend le code généré par Hugo pour inclure le code de Matomo


```
git submodule add https://github.com/holehan/hugo-components-matomo.git themes/matomo
```

Dans cet exemple, j’ajoute simplement « matomo » comme 2ème thème de mon blog static dans le fichier de configuration **config.toml**

```
theme = ["aether", "matomo"]
```

Et je termine par ajouter la balise suivante dans le thème que j’utilise (ici aether, donc par exemple themes/aether/layouts/partials/head.html)

```
{{ partial "matomo-tracking" . }}
```

## Vie privée
    
Pour que tout soit vraiment terminé, il faut également ajouter la ligne suivante dans la page dédiée à la vie privée

```
{{ matomo-optout }}
```

Et voilà le travail :)
