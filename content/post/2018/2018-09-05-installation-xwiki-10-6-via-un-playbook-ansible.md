---
title: Installation xwiki 10.6.1 via un playbook Ansible
authors:
  - zwindler
type: post
date: 2018-09-05T11:45:00+00:00
url: /2018/09/05/installation-xwiki-10-6-via-un-playbook-ansible/
image: /2018/09/xwiki_ansible.png
categories:
  - Script
tags:
  - ansible
  - CentOS
  - github
  - playbook
  - PostgreSQL
  - Tomcat
  - Xwiki

---
## Ansible + XWiki

Je sais ce que vous vous dites :

> Ça fait longtemps que zwindler n’a pas écrit un article sur Ansible ou XWiki !

Non ? Vous ne vous dites pas ça ? Bon tant pis c’est pas grave. Aujourd’hui, je rédige ENFIN l’article pour parler d’un playbook que j’ai déjà rédigé il y a presque un an déjà (et mis à jour et déployé de nombreuses fois). C’est dire si j’ai du retard dans les articles du blog...

## Petit rappel des épisodes précédents

J’ai déjà rédigé de manière extensive sur XWiki qui est un belle solution open source de gestion de la connaissance. Parmi les articles les plus susceptibles d’intéresser, il y a déjà :

  * [Installer facilement XWiki en 2 lignes de commandes avec Docker compose](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/)
  * [Tutoriel de migration d’un Mediawiki vers XWiki](/2016/09/12/migration-mediawiki-vers-xwiki/)
  * [Déploiement d’une application Stateful dans Kubernetes par l’exemple (XWiki + PostgreSQL)](/2017/10/24/tutoriel-xwiki-ma-premier-appli-stateful-sur-kubernetes/)
  * [Résoudre les erreurs de type « Fichier trop gros » lors de l’import d’un fichier dans XWiki](/2016/03/12/parametres-caches-de-xwiki-taille/)

Il y en a plein d’autre ([voir ici](/recherche/?keyword=xwiki)).

## Et Ansible ?

Et bien oui. Je vous rabâche aussi les oreilles avec Ansible, l’Infrastructure as Code, et l’Idempotence. (Là encore, [il y en a plein](/recherche/?keyword=ansible))

Alors pourquoi pas un playbook Ansible pour automatiser l’installation de XWiki, si vous n’avez pas de cluster Kubernetes sous la main et que vous êtes un Gaulois réfractaire à Docker ?

![](/2018/09/gaulois.png)

## Ya quoi dans ton playbook ?

Trêve de suspense, les sources sont disponibles sur [Github à cette adresse][8].

Ce playbook a été testé pour des RHEL/CentOS 7, en particulier de la version 7.2 jusqu’à 7.4. Une installation de RHEL/CentOS en mode minimale, même sans environnement graphique, devrait être suffisante. Je l’ai faite tourner en production sur des environnements Desktop dans des VMs, mais aussi en Minimal sur un container LXC dans Proxmox VE sans aucun souci.

L’installation n’utilise pas les serveurs web et de bases de données par « défaut » (MySQL), mais Tomcat 8 et PostgreSQL. Pour la version de Tomcat, c’est une version très particulière qu’il faut utiliser car des bugs ont étés introduits dans une version, puis RE-introduits quelques mois plus tard. Vous pouvez modifier la version par défaut qui est une variables de mon playbook (8.5.32) si elle ne vous convient pas. Les instructions d’installation se basent sur [la documentation officielle][9].

![](/2018/09/xwiki_warning.png)

```
- tomcat_version: 8.5.32
```


Vous pouvez également modifier la version de XWiki directement dans le playbook (c’est une variable là aussi) :

```
- xwiki_version: "10.6.1"
```


A noter, les vielles versions de XWiki n’étaient pas hébergées sur le même dépôt, qui a changé récemment, d’où les deux URLs dans le playbook.

## Prérequis

On va utiliser git pour récupérer le playbook et ansible (version de l’OS, rien d’exotique).

```
yum install ansible git

git clone https://github.com/zwindler/ansible-deploy-xwiki-tomcat-postgresql
cd ansible-deploy-xwiki-tomcat-postgresql
```


## Quand est ce qu’on installe XWiki ?

Maintenant !

Sur un poste qui dispose de git et Ansible :

```
ansible-playbook -l localhost ansible-deploy-xwiki-tomcat-postgresql.yml
```


Le playbook devrait vous prompter pour un mot de passe pour l’utilisateur de base de données PostgreSQL, n’hésitez pas à mettre quelque chose de complexe. Vous ne devriez pas en avoir besoin.

Si vous avez une erreur qui vous dit que localhost est ignoré, vous pouvez l’ajouter à votre fichier d’inventaire global : /etc/ansible/hosts

```
sudo vim /etc/ansible/hosts
[local]
localhost ansible_connection=local
```

Et Paf ! Vous avez un XWiki installé, disponible à l’adresse `http://@IP:8080/`. Il n’y a plus qu’à le configurer :)

 [8]: https://github.com/zwindler/ansible-deploy-xwiki-tomcat-postgresql
 [9]: https://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Installation/InstallationWAR/InstallationTomcat/
