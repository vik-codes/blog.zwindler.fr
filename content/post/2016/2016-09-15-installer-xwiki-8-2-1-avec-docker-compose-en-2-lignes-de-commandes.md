---
title: Installer XWiki 8.2.1 avec Docker (compose) en 2 lignes de commandes
authors:
  - zwindler
type: post
date: 2016-09-15T11:00:28+00:00
url: /2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/
image: /2016/09/article_docker_xwiki.png
categories:
  - autohebergement
  - Virtualisation
tags:
  - automatisation
  - Docker
  - docker compose
  - docker hub
  - DockerFile
  - git
  - github
  - PostgreSQL
  - Tomcat
  - Xwiki
  - xwiki 8.2.1
  - xwiki 8.X

---
## Automatiser l’installation du XWiki avec Docker compose

Pour ceux qui ne le savent, XWiki est une plateforme collaborative de gestion de la connaissance (généralement appelé wiki, KMDB en ITIL). L’exemple le plus connu de wiki est bien entendu Wikipedia qui tourne par contre lui sous Mediawiki (un autre wiki, moins convivial mais très répandu). J’ai déjà écris pas mal au sujet du XWiki donc si vous voulez un petit tour d’horizon de ce qu’on peut faire avec, vous pouvez [cliquer ici](/recherche/?keyword=xwiki).

Je commence à en avoir installé un certain nombre :

  * que ce soit pour tester les nouvelles version
  * en recette ou en production pour de nouvelles équipes
  * faire des tests sur Docker

Si l’installation d’un XWiki est simplissime si vous utilisez les outils préconfigurés par défaut dans l’installeur JAR, l’installation d’une instance XWiki avec Tomcat et PostgreSQL est un peu plus complexe. Du coup, j’ai eu besoin à plusieurs reprise d’ouvrir mon propre tutoriel qui guide pas à pas [l’installation de la version 7 de XWiki sur un Redhat Entreprise Linux 7 (ou CentOS)](/2015/12/16/installation-de-xwiki-redhat-7/).

## Vous avez dit Docker ?

Et c’est notamment grâce au besoin que j’ai eu de faire des tests sur Docker que j’en suis venu à réaliser une image Docker XWiki.

XWiki était le parfait exemple pour s’initier à :

  * la création d’un service multi-conteneurs séparés par Tiers (Tomcat, PostgreSQL)
  * la rédaction d’un DockerFile qui automatise entièrement l’installation et la configuration de l’application java XWiki à partir de l’image standard Tomcat 8
  * l’ajout d’une orchestration de base avec Docker Compose
  * la mise en ligne d’une image publique avec Docker Hub

Un des avantages de Docker, c’est que grâce à l’aspect « portable » des conteneurs :

  * Avec ce conteneur, je peux garantir que les fichiers de configuration que j'embarque avec l’image seront compatibles.
  * Sans conteneur, avec un serveur Tomcat déjà existant et en fonction des fichiers de configurations embarqués selon telle ou telle distribution, les instructions que je donne dans [mon article « pas à pas »](/2015/12/16/installation-de-xwiki-redhat-7/) pourraient ne pas toujours fonctionner.

## Pour les plus pressés

Quelque soit la méthode que vous choisirez, le XWiki sera opérationnel et accessible sur le port 8080 à l’issue de ces commandes. Il faudra juste passer le [« First Installation Wizard »](/2015/12/16/installation-de-xwiki-redhat-7/) et [commencer à configurer le XWiki](/2016/09/01/personnalisation-de-base-apres-installation-mise-a-jour-dun-xwiki/).

### Avec Docker Compose

Docker compose se charge pour vous, à partir du fichier **_docker-compose.yml_**, de :

  * télécharger/builder l’image des conteneurs Postgresql et XWiki
  * configurer ces conteneurs
  * démarrer les conteneurs.

C’est donc forcément plus simple de le faire marcher en 2 lignes de commandes ;-).

[Edit]  
A priori il n’est plus nécessaire de faire un « **chmod +x xwiki-tomcat/xwiki-tomcat-entrypoint.sh** » sinon ça ne fonctionne pas, j’ai corrigé les permissions sur le github  
[/Edit]

```
git clone https://github.com/zwindler/docker-xwiki.git && cd docker-xwiki
docker-compose -f compose/docker-compose.yml up -d
```


### Avec Docker depuis les sources

Avec Docker uniquement, il faudra forcément tout faire à la main. Donc il faudra créer le network, démarrer successivement l’image PostgreSQL puis l’image Tomcat modifiée par mes soins.

```
docker network create -d bridge xwiki-nw
docker run --net=xwiki-nw -itd --name xwiki-postgres -e POSTGRES_DB=xwiki -e POSTGRES_USER=xwiki -e POSTGRES_PASSWORD=xwiki postgres
```


```
git clone https://github.com/zwindler/docker-xwiki.git && cd docker-xwiki
chmod +x xwiki-tomcat/xwiki-tomcat-entrypoint.sh
docker build -t zwindler/xwiki-tomcat8:latest .
docker run --net=xwiki-nw -itd --name xwiki-tomcat -p 8080:8080 -e POSTGRES_INSTANCE=xwiki-postgres zwindler/xwiki-tomcat8
```


### Avec Docker et Docker Hub

Un cran plus simple que la version précédente car je viens d’uploader l’image zwindler/xwiki-tomcat sur Docker Hub. Elle est donc automatiquement téléchargée depuis Docker hub lors de la commande **docker run**. Pas besoin de « chmod » ni de builder l’image.

```
docker network create -d bridge xwiki-nw
docker run --net=xwiki-nw -itd --name xwiki-postgres -e POSTGRES_DB=xwiki -e POSTGRES_USER=xwiki -e POSTGRES_PASSWORD=xwiki postgres
docker run --net=xwiki-nw -itd --name xwiki-tomcat -p 8080:8080 -e POSTGRES_INSTANCE=xwiki-postgres zwindler/xwiki-tomcat8
```


## L’image en question

L’ensemble des sources sont disponibles sur [Github dans mon repository docker-xwiki][4].

Voici le contenu du DockerFile :

```
FROM tomcat:8-jre8
MAINTAINER Denis GERMAIN <dt.germain@gmail.com> 
ENV POSTGRES_INSTANCE=xwiki-pgsql
ENV POSTGRES_PORT=5432
ENV POSTGRES_DB=xwiki
ENV POSTGRES_USER=xwiki
ENV POSTGRES_PASSWORD=xwiki

RUN rm -rf webapps/* && \
    curl -L \
      'http://download.forge.ow2.org/xwiki/xwiki-enterprise-web-8.2.1.war' \
       -o xwiki.war && \
    unzip -d webapps/xwiki xwiki.war && \
    rm -f xwiki.war

RUN curl -L \
      'https://jdbc.postgresql.org/download/postgresql-9.4.1208.jar' \
      -o 'webapps/xwiki/WEB-INF/lib/postgresql-9.4-1208.jdbc42.jar'

COPY hibernate.cfg.xml webapps/xwiki/WEB-INF/
COPY xwiki.cfg webapps/xwiki/WEB-INF/
COPY setenv.sh bin/setenv.sh

RUN sed -i "s/redirectPort=\"8443\" /redirectPort=\"8443\" URIEncoding=\"UTF-8\" /" conf/server.xml

COPY xwiki-tomcat-entrypoint.sh /

ENTRYPOINT ["/xwiki-tomcat-entrypoint.sh"]
```


Des variables d’environnement ENV sont à votre disposition pour adapter à votre contexte (on en parlera un peu plus loin). La première étape consiste à télécharger la dernière version en date du XWiki, puis le pilote JDBC PostgreSQL correspondant.

Les fichiers de Tomcat sont adaptés pour un fonctionnement avec XWiki (Xmx java, autorisation des « / » dans les URLs, ...) et les fichiers de configuration de XWiki sont paramétrés pour accepter l’instance PostgreSQL.

## Personnalisation

Pour permettre un peu plus de souplesse dans l’utilisation de la base de données, j’ai volontairement ajouté des variables d’environnement et un script « ENTRYPOINT ». Ce script sert à paramétrer à la première exécution les valeurs définies en début de DockerFile (ENV).

Ceci permet à la fois de mettre à disposition une image Docker clé en main si l’utilisateur ne souhaite rien modifier et tout laisser par défaut, ou à l’inverse, de fournir des variables qui lui sont propres et personnaliser automatiquement son instance.

Vous pourrez ainsi par exemple changer le mot de passe et/ou le nom de l’instance PostgreSQL (soit via modification du docker-compose.yml, soit directement en modifiant le DockerFile).

## Problème ALLOW\_ENCODED\_SLASH=true

Malgré l’ajout de _ALLOW\_ENCODED\_SLASH=true_ dans **catalina.properties**, j’avais des problèmes pour ouvrir les pages avec des / dans les noms de pages.

J’en ai profité pour essayer de déplacer l’application du paramètres et l’intégrer au niveau du setenv.sh avec la variable d’environnement CATALINA_OPTS. Ca n’a pas corrigé le problème (situé à un autre niveau) mais a permis de simplifier le Dockerfile, ce qui est toujours bon à prendre.

En réalité, la variable était bien prise en compte dans les deux cas. Je l’avais vérifié et cela marchait depuis le début. En réalité, j’ai un reverse proxy Apache (ProxyPass) qui lui aussi fout le boxon avec les « / » dans mes titres de pages de XWiki.

La réponse suivante [sur StackOverflow explique très bien ce qu’il se passe][5]. Pour autant dans mon cas, impossible d’accéder à ces pages, quelque soit le paramètre essayé, dans le cas où le XWiki est derrière mon proxy Apache. Je peux y accéder sans, je vais donc devoir les renommer pour contourner le problème. De toute façon, ça ne me plait pas que ces pages aient un « / » dans leur URL ;-).

 [4]: https://github.com/zwindler/docker-xwiki
 [5]: http://stackoverflow.com/a/9933890
