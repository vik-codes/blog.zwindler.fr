---
title: NaviSecCLI pour piloter ses baies EMC² VNX depuis Linux
authors:
  - zwindler
type: post
date: 2017-04-18T11:35:31+00:00
url: /2017/04/18/naviseccli-pour-piloter-ses-baies-emc-vnx-depuis-linux/
image: /2017/04/vnx5300-2.jpg
categories:
  - Script
  - Stockage
  - Système
tags:
  - Clariion
  - EMC
  - NaviCLI
  - NaviSecCLI
  - Navisphere
  - Perl
  - RLP
  - VNX

---
## NaviSecCLI : à quoi bon snapshoter nos LUNs si on ne peut pas le scripter ?

Lorsque j’ai intégré mes premières baies EMC² VNX (lien mort, pas dispo sur Internet Archive) 5300 en 2012, on m’a présenté les avantages de la baies (et notamment la possibilité de réaliser des clones et des snapshots comme toutes les autres baies) , la première chose que j’ai demandé c’est « Oui mais est ce qu’on peut le scripter ». Et heureusement la réponse a été « Oui avec NaviCLI » (ou la version « sécurisée » NaviSecCLI).

Note : Vous connaissez peut être NaviCLI (la CLI Navisphere) disponible sur les CLARiiON, sachez qu’elle a été remplacée par NaviSecCLI. La version non sécurisée ne fonctionnera pas sur les VNX mais rassurez vous, les commandes sont identiques !

Quelques exemples de ce que j’avais en tête et que nous avons mis en production assez rapidement :

  * Créer un script permettant de disposer d’une préproduction ISO-prod en terme de données, rafraichie toutes les semaines tout en limitant l’interruption pour la production ET la préproduction. Ce script par une brève coupure de la base de données de production pendant une fenêtre de maintenance, créé un snapshot de baie et monte la préproduction dessus
  * Créer un script Nagios pour vérifier qu’il reste des RLP (Reserved LUN Pool) pour que les snapshots de la préproduction ne se bloquent pas en cas d’écriture intensive côté production (ou préproduction)
  * ...

![](/2017/04/vnx5300.jpg)

Le but de cette procédure est de lister les étapes permettant d’installer la NaviSecCLI sur un serveur Redhat Entreprise Linux.

## Installation

Pour une installation de la CLI sous Redhat, EMC² propose un RPM (c’est sympa de leur part). Enfin bon, encore faut il le trouver ! EMC² a vraiment du travail à faire pour simplifier la recherche de fichiers sur leur site... Je ne me risquerais pas à vous fournir un lien, j’ai peur qu’il ne soit pas valide longtemps. Sachez qu’il faut trouver un fichier du type « NaviCLI-Linux-64-x86-xxx.rpm ».

```
yum install NaviCLI-Linux-64-x86-en_US-7.32.0.5.54-1.x86_64.rpm #version compatible sur les RHEL 5
yum install NaviCLI-Linux-64-x86-en_US-7.33.3.0.72-1.x86_64.rpm #version nécessaire pour les RHEL 6
```


Normalement, le RPM est assez basique et il y a peu de chance que l’opération échoue. Une fois installé, il faut ensuite sélectionner le niveau de sécurité que l’on souhaite appliquer sur le serveur en question. Pour être parfaitement honete, je ne suis pas complètement certain de comprendre les différence entre les deux niveaux proposés (moyen ou élevé). J’imagine qu’il s’agit probablement de paramètres disponibles pour assurer de la rétrocompatibilité avec des matériels plus anciens.

```
/opt/Navisphere/bin/setlevel_cli.sh
```


Il faut ensuite rajouter des variables d’environnement dans le fichier .profile de **l’utilisateur que l’on souhaite utiliser** pour lancer les scripts. Voici les lignes à intégrer dans un fichier (type .bashrc par exemple si l’utilisateur utilise bash comme interpréteur de commandes)

```
PATH=/usr/sbin:$PATH:/sbin:/home/root:/opt/Navisphere/bin
SHLIB_PATH=$SHLIB_PATH:/opt/Navisphere/lib/seccli
NAVI_SECCLI_CONF=$NAVI_SECCLI_CONF:/opt/Navisphere/seccli
```


Enfin, toujours sur le même utilisateur, il faut initialiser un fichier de sécurité (certificat) qui permettra de ne pas spécifier en clair les mots de passes des baies (dans un script, par exemple) à chaque utilisation

```
naviseccli -user admin_de_la_baie -password passwordpassecure -scope 0 -AddUserSecurity
```


Pour tester si NavisecCLI peut adresser la baie sans mettre le user/password. Le contrôleur interrogé renverra des informations :

```
naviseccli –h 10.1.1.10 getagent
```


## Aller plus loin

Et bien maintenant il ne vous reste plus qu’à écrire vos scripts ! L’ensemble des commandes disponibles sont listées dans ce guide d’utilisation disponible [sur le site d’EMC (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150724000538/http://www.emc.com/collateral/support-training/support/069001038-navisphere-cli.pdf).

Si vous voulez un exemple de script utilisant la NaviSecCLI pour surveiller le nombre de RLP encore disponible et compatible avec Nagios, je vous invite [sur mon Github check\_emc\_rlp.pl][4].

 [4]: https://github.com/zwindler/check_emc_rlp
