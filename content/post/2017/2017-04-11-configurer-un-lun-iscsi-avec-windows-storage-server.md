---
title: Configurer un LUN iSCSI avec Windows Storage Server
authors:
  - zwindler
type: post
date: 2017-04-11T11:30:23+00:00
url: /2017/04/11/configurer-un-lun-iscsi-avec-windows-storage-server/
image: /2017/03/windows_iscsi.png
categories:
  - Stockage
  - Système
  - Virtualisation
tags:
  - ESX(i)
  - iSCSI
  - Stockage
  - VMware
  - Windows Server
  - Windows Storage

---
## Mais pourquoi Windows Storage Server ?

Dans le cadre d’un déménagement vers de nouveaux locaux, ma société a souhaité s’équiper dans ses nouvelles agences de NAS pour éviter de charger les liens avec le Datacenter national ainsi que de petits ESXi pour les besoins type DNS, DHCP, etc. Cependant, pour des raisons de simplicité et de diminution des coûts, il a été décidé de n’acquérir qu’une seule « boite » qui servirait à la fois de NAS ainsi que de stockage iSCSI pour les serveurs. Il se trouve que notre intégrateur préféré nous a alors proposé la solution de chez HP, les StoreEasy. En réalité, il s’agit ni plus ni moins qu’un serveur banal préinstallés avec 4 disques de 1 To et la version Windows Storage Server 2012 R2.

Il y a des jours où je me dis qu’on aurait mieux faire d’acquérir un NAS type QNAP (les modèles pro sont excellents) qui serait à la fois plus performant (oui, à ce point) et bien plus stable. Mais c’est sans compter le plaisir de pouvoir faire un article sur Windows Server Storage 2012 R2, la version orientée PME&ROBO de l’OS de Microsoft. Enfin, à vrai dire je ne connais pas la différence avec 2012R2 Standard...

# Installation

Dans mon cas, au premier boot, le serveur était préinstallé avec certains outils HP permettant de « simplifier » la configuration initiale. Un login/mdp, et hop en quelques minutes, le tour était joué. Le produit est effectivement simple.

# Création d’un groupe d’interfaces réseau (teaming)

Si vous avez suivi l’intro, notre idée était de « limiter » les risques de pannes en se créant un hybride NAS/SAN à moindre coût. Par souci du détail, nous avons donc voulu commencer par « double attacher » notre StoreEasy au LAN, via la fonctionnalité Teaming de Microsoft.

Dans le gestionnaire de serveur, ouvrir l’utilitaire « Association de cartes réseau ».

![](/2017/03/image2.png)

En cliquant sur « Désactivé », l’utilitaire ouvre une fenêtre.

![](/2017/03/image3.png)

Créer une équipe (Teaming) avec « Nouvelle équipe ».

![](/2017/03/word-image-73.png)

Sélectionner les deux cartes réseaux.

![](/2017/03/word-image-74.png")

![](/2017/03/word-image-75.png)

A partir de là, j’ai donc un groupe d’interface réseaux en équilibrage de charge.  Pas si mal...

# Création d’un Datastore iSCSI pour VMware ESXi 5.5

## Création du volume sous Windows Storage

Depuis Windows 2012, Microsoft propose une méthode de stockage similaire à ce qu’on retrouve sous Unix avec LVM. Il existe un logiciel dans le serveur qui permet d’abstraire les disques physiques pour en faire un genre de gros « pool » de disques, puis de redistribuer ce stockage virtuel en sous disques/partitions virtuelles. J’ai envie de dire ENFIN ! Dans la suite, je ferai donc régulièrement le lien avec LVM car sinon je ne m’y retrouve pas.

Une fois le serveur installé, on peut donc commencer par créer les disques qui seront présentés à VMware via le protocole iSCSI.

Ouvrir le « Gestionnaire de serveur ».

![](/2017/03/word-image-76.png) 

Les rôles préinstallés dans notre édition « Storage Server » apparaissent dans le tableau de bord.

![](/2017/03/word-image-77.png)

Le rôle qui permet de gérer les disques est le rôle Services de « fichiers de de stockage ».

![](/2017/03/image9.png)

Sélectionner « Pools de Stockage » pour créer le premier « LV ».

![](/2017/03/word-image-79.png)
Dans notre StoreEasy, on remarque que le serveur a été préconfiguré avec un « Pool de stockage » (nos PV). Les 4 disques SATA de 1 To sont tous intégrés dans le Pool de Stockage 1_A, configuré en RAID6 (double parité), d’une capacité de 2 To. Pourquoi RAID6 et pas RAID10 (qui serait théoriquement plus performant mais à capacité égale ?).

> « Beats me », diront les anglosaxons.

Le LV contenant l’OS (le C:) est un des disques virtuels de ce pool de stockage, et fait 100 Go.

Pour créer notre nouveau volume logique qui contiendra notre datastore VMware, il faut faire un clic droit sur le Pool de Stockage.

![](/2017/03/word-image-80.png)

Un assistant s’ouvre et guide l’utilisateur pour la création du disque. Suivre les options par défaut, et spécifier le nom du disque, et la taille.

![](/2017/03/image12.png)

![](/2017/03/word-image-82.png)

Cocher « Créer un volume lorsque l’Assistant se ferme », et valider les options par défaut. L’assistant permet de faire plusieurs choses en même temps. Le disque créé est ensuite formatté par l’assistant suivant, et monté sur l’OS avec la lettre E:.

![](/2017/03/image14.png)

![](/2017/03/word-image-84.png)

![](/2017/03/image16.png)

Maintenant qu’on dispose d’un disque virtuel disponible,  on peut ouvrir le menu « iSCSI », et lancer l’assistant de création de disques iSCSI.

![](/2017/03/word-image-86.png)

Sélectionner le disque qui vient d’être créé pour accueillir le Datastore et lui donner un nom et une taille.

![](/2017/03/word-image-87.png)

![](/2017/03/image19.png)

Donner lui la taille maximum.

![](/2017/03/word-image-89.png)

Créer la nouvelle cible d’accès (serveur VMware) qui sera autorisée à se connecter au datastore.

![](/2017/03/image21.png)

Si le DNS n’est pas encore configuré, on peut simplement entrer une adresse IP, sinon, on peut aussi entrer le nom d’hôte.

Dans notre contexte, comme le réseau avait été taillé au plus juste, la connexion « réseau de stockage » avait été faite en direct entre le serveur NAS StoreEasy et le serveur ESXi. La connexion a donc été faite sur un réseau privé « fictif » en 192.168.200.0/24.

Je vous laisse adapter à votre contexte.

![](/2017/03/image22.png)

On peut ajouter autant de cible (client) que l’on souhaite. On peut également ajouter une authentification de type CHAP.

![](/2017/03/image23.png)

Une fois validé, le nouveau disque créé s’initialise.

![](/2017/03/image24.png)

Attendre que le disque soit prêt côté NAS avant de passer à l’étape suivante.

## Création du réseau de stockage en connexion directe sous VMware

Fini de jouer avec Windows, on peut passer sur ESXi. La première chose à faire sous VMware est de préparer le réseau virtuel et les interfaces physiques qui vont va discuter en iSCSI.

Ouvrir la console, sélectionner le menu « Configuration » de l’hôte, et ajouter le réseau 192.168.200.0/24 dans le menu « Mise en réseau ».

![](/2017/03/word-image-94.png)

![](/2017/03/word-image-95.png)

Sélectionner l’adaptateur réseau qui a détecté le réseau 192.168.200.0/24 (rappel : connexion directe Ethernet entre les deux serveurs dans mon cas).

![](/2017/03/image27.png)

![](/2017/03/word-image-97.png)

Sélectionner « Propriété » sur le vSwitch qu’on vient de créer.

![](/2017/03/word-image-98.png)

Cliquer sur « Ajouter », et un VMKernel pour pouvoir y affecter l’adresse IP 192.168.200.100.

![](/2017/03/image30.png)

## Création du datastore sous VMware

Le réseau, c’est bon, pour autant on ne peut pas tout de suite créer notre Datastore. En effet, par défaut, il n’y a pas d’adaptateur de stockage pour l’iSCSI sur les serveurs ESXi. Il faut l’activer.

Ouvrir le menu « Adaptateurs de stockage », et cliquer sur « Ajouter ».

![](/2017/03/word-image-100.png)

Une fois l’adaptateur iSCSI créé, il faut le configurer (clic droit, puis « Propriétés »).

![](/2017/03/word-image-101.png)

Sélectionner la carte réseau de connexion directe vers le NAS (ou celle qui est sur le réseau de stockage si vous avez plus de moyens que nous).

![](/2017/03/word-image-102.png)

![](/2017/03/image34.png)

Le réseau doit apparaitre comme « Conforme ». Point important : Si vous avez 2 cartes réseaux connectées en iSCSI (voir le Teaming de tout à l’heure par exemple), il est nécessaire de créer 2 VMKernel distinct avec un seule interface à chaque fois. Si vous mettez les deux dans le même VMKernel, le VMNetwork ne sera pas Conforme.

![](/2017/03/word-image-104.png)

Si l’erreur suivante s’affiche, c’est qu’on n’a pas correctement affecté l’IP dans le vSwitch (menu « Mise en réseau »).

![](/2017/03/word-image-105.png) 

Dans l’onglet « Général », ajouter les informations de logins/mdp si elles ont été définies côté NAS.

![](/2017/03/word-image-106.png)

![](/2017/03/image38.png)

Dans l’onglet « Découverte dynamique », cliquer sur « Ajouter » et entrer l’adresse IP du NAS.

![](/2017/03/image39.png)

Valider. VMware doit proposer un rebalayage de l’adaptateur, pour découvrir les targets disponibles (hôte NAS).

![](/2017/03/word-image-109.png)

Le disque doit apparaitre dans la liste des « Périphériques ».

![](/2017/03/word-image-110.png)

Ouvrir le menu « Stockage », puis cliquer sur « Ajouter stockage ».

![](/2017/03/word-image-111.png)

![](/2017/03/word-image-112.png) 

Sélectionner le disque iSCSI, et VMFS-5, et entrer un nom de banque de données.

![](/2017/03/word-image-113.png) 

![](/2017/03/image45.png)

And voilà ! Vous savez maintenant configurer une cible iSCSI sur Windows Storage 2012 R2 et le connecter à votre ESXi en iSCSI !
