---
title: Une issue ouverte sur un projet, 7 ans après ?
authors:
  - zwindler
type: post
date: 2023-11-24T14:00:00+02:00
url: /2023/11/24/issue-ouverte-apres-7-ans
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

---

## Introduction

Il y a 7 ans, en août 2016 (!!), je créais ma première "vraie" image docker.

Il s'agissait d'une image custom pour un outil que j'utilisais énormément [XWiki](https://blog.zwindler.fr/recherche/?keyword=xwiki), un outil de Knowledge management open source (et français) que j'apprécie particulièrement et qui remplace avantageusement un Confluence (si vous voulez mon avis).

A l'époque, mon image fournissait un XWiki prêt à l'emploi avec Tomcat 8 et le driver JDBC pour postgresql.

* [github.com/zwindler/docker-xwiki](https://github.com/zwindler/docker-xwiki)

J'avais fait ce projet car les images officielles du projet étaient encore balbutiantes (ça date !) et ne proposaient pas cette alternative.

[J'avais d'ailleurs écrit un article pour l'occasion (Installer XWiki 8.2.1 avec Docker (compose) en 2 lignes de commandes)](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/) et fourni au fil des mois suivants des manifests pour Kubernetes.

## Et aujourd'hui ?

Ca fait bien longtemps que ce projet n'a plus aucun intérêt, même si mes images ont été téléchargées environ 30000 fois (quand même !), avec un dernier téléchargement l'an dernier, malgré une version vielle de plus de 6 ans (mais pourquoiiiiii ?).

* [hub.docker.com - zwindler/xwiki-tomcat8](https://hub.docker.com/repository/docker/zwindler/xwiki-tomcat8/general)

Les images officielles proposent désormais (depuis bien longtemps) toutes les options les plus courantes pour toutes les versions supportées

![](/2023/11/dockerhub_xwiki.png)

## Pourtant ?!?

Pourtant, début novembre, j'ai reçu une issue, d'un utilisateur qui m'informait qu'il ne pouvait pas rebuild mon image car l'URL permettant de télécharger les artefacts WAR ne répondait plus (effectivement, elle a changé).

Même si au début j'étais un peu interloqué, je me suis dis que ça pouvait être fun de remettre les mains dedans et de tenter de mettre à jour mon image sur toute la stack, pour voir si ça fonctionne encore.

## Voyons voir ce qui a changé depuis 2016...

Évidemment, beaucoup de choses !

D'abord, les versions de XWiki (de 10 à 14), qui ont forcément évoluées, ainsi que cette fameuse URL de téléchargement des artefacts qui avait changé.

La version de postgres est passée de 9.5 à 16, les versions du driver JDBC ont évoluées de plusieurs mineures.

Plus impactant, tomcat est passé de la version 8 à la version 10, avec un gros breaking change entre la 9 et la 10, notamment à cause de JEE, renommé en JakartaEE !

Ca parlera aux Javaistes ;-)

![](/2023/11/javax.png)

Plus anecdotique, le MAINTAINER a disparu depuis bien longtemps des Dockerfile (remplacé par un LABEL opencontainers), le MaxPermSize n'existe plus en Java et le format des fichiers docker-compose est passé en version 3.

## Les modifs

Pour le fun, j'ai donc réparé mon image pour qu'elle marche (et pas plus), puis j'ai passé le repo en readonly, pour la postérité, en prenant soin d'informer l'auteur de l'issue qu'il valait mieux regarder du côté des images officielles ;-).

[Le code de fix est disponible ici, pour les curieux/curieuses](https://github.com/zwindler/docker-xwiki/commit/c5955f1c35f809cdf3b4f56b20cc204a37a27f17).

Mais... ça fonctionne :-p

![](/2023/11/xwiki-14.png)
