---
title: vCenter, où, quand, comment ? Que choisir … en 2015 !
authors:
  - zwindler
type: post
date: 2015-07-23T17:00:56+00:00
url: /2015/07/23/vcenter-ou-quand-comment-que-choisir-en-2015/
image: /2015/07/vCSA.jpg
categories:
  - systeme
  - Virtualisation
tags:
  - ESX
  - ESX(i)
  - physique
  - vCenter
  - vCSA
  - virtuel
  - VMware
  - zwindler

---
Un de mes articles qui intéresse le plus, et ce depuis le début du blog, est celui où je me pose la question "[Où est ce qu’il est le plus opportun de situer un vCenter dans une infrastructure virtuelle VMware?][1]".

Si une bonne partie des recommandations et du retour d’expérience que je détaille dans cet article sont toujours valides, les choses ont quand même un peu changées depuis 2010. Et comme l’article attire toujours les visites, j’ai décidé que cela méritait bien un petit dépoussiérage, histoire que les nouveaux visiteurs puissent profiter d’un avis plus récent sur la question.

Attention : Une fois encore, cet article est plutôt long, ne contient pas vraiment de technique pure mais plutôt un retour sur expérience et mon ressenti face à des choix techniques que j’ai du faire. Il y a vraiment plusieurs solutions et bien malin celui qui peut donner « la bonne ».

# Résumé des épisodes précédents

A l’époque, le contexte professionnel dans lequel je travaillais s’éveillait peu à peu à la virtualisation d’entreprise.

Pour tout dire, les serveurs de production étaient encore massivement physiques sans autre raison réelle que notre plateforme de virtualisation en place était encore un peu jeune pour la DSI. On parle de quelques Terminal Servers sous Windows 2003/2008 et un ou deux RedHat, une broutille.

Cependant, la virtualisation prenant de l’ampleur et des machines de productions étant prévues pour arriver directement sur l’hyperviseur sans passer par la case « serveur physique », j’ai du faire un choix pour savoir **où migrer** le vCenter. Il était alors hébergé sur un poste de travail crachotant gérant à la fois la supervision sous Linux et une machine virtuelle sous XP dédiée au vCenter. Autant dire que ça ne tenait pas du tout la route et qu’il fallait une solution plus pérenne pour assurer la production.

Deux (trois) solutions s’étaient alors présentées, que j’avais affectueusement nommés comme ceci :

  * 1) La simplicité : booster le fameux poste de travail dans l’idée de garder la console d’administration **hors du cluster qu’elle administre.**
  * 2) La brutalité : réinstaller le vCenter sur un vrai serveur physique. Le problème était de savoir comment migrer la base de données ou **comment transformer la VM sous XP en serveur physique.** Autant vous dire que j’ai vite compris qu’espérer faire du V2P (virtual to physical) était peine perdue, là où le P2V était bien rôdé (et c’est toujours le cas aujourd’hui).
  * 3) Le choix VMware : j’avais été particulièrement surpris de voir que VMware **conseille et supporte** l’intégration du vCenter directement sur un des serveurs ESX(i) qu’il administre, dans le cas de petites installations.

Cette dernière solution m’avait particulièrement interloqué. Mais en y réfléchissant, j’avais assez vite compris l’intérêt de la chose :

  * 3a) Une machine virtuelle n’a pas de raison de tomber en panne, là où la machine physique le peut, surtout lorsque c’est un vieux serveur de récup’, réutilisé pour l’occasion.
  * 3b) A l’inverse, un serveur VMware demandant plus de puissant, _c’était probablement_ une machine plus haut de gamme, moins sensible à la panne qu’un serveur lambda.
  * 3c) Ensuite, la machine virtuelle se fiche de savoir sur quel serveur elle tourne => dans le pire des cas,  le serveur qui héberge le vCenter tombe en panne. Pourtant, elle peut être redémarrée sur l’autre (ou les autres) serveur qui lui fonctionne toujours. Le principe reste le même si on doit déplacer le vCenter vers un autre serveur ESX(i), suite à un upgrade de la plateforme, par exemple.
  * 3d) Enfin, la machine virtuelle peut évoluer sans contrainte, contrairement au serveur physique qui vivra sa vie et finira par devenir obsolète ou sous(/sur)dimensionné.

J’en avais donc déduis à l’époque que sur de petits clusters vCenter, la virtualisation de ce composant sur un serveur Windows paraissait une bonne idée, ne réservant les installations physiques que pour les gros clusters avec déport de base de données Oracle. Petit aparté, l’un n'empêche pas l’autre : on peut très bien avoir un vCenter virtuel et base Oracle déportée, mais je ne vois pas bien dans quel contexte.

# D’accord. Mais en 2015?

Et bien en 2015, comme je le dis en introduction, les points que je cite dans la partie précédente sont toujours valables.

J’aime toujours le principe de séparer une console d’administration du cluster qu’elle administre, mais les gains apportés par la solution 2 me paraissent supérieurs à cet inconvénient. Je reste convaincu que cette dernière solution est la meilleure dans la plupart des cas, au bémol près que le point 2b) n’est pas (plus?) à généraliser.

On pourrait arguer que dans certains cas aujourd’hui, ça serait plutôt le contraire : les serveurs de virtualisation (nœuds _Compute_ dans le jargon du « cloud ») sont devenus totalement remplaçables au sein des clusters, une panne n’ayant pas plus d’impact que la perte de redondance dans un RAID.

# vCSA

Mais. Il y a bien un « Mais » sinon je ne récrirais pas cet article.

Mais depuis, VMware a publié diverses versions d’une machine virtuelle préinstallée sous Linux permettant de gérer le rôle vCenter sans licence (Microsoft) supplémentaire : la vCenter Server Appliance (vSCA), sous SLES 11. Et c’est d’autant plus sympa de la part de VMware qu’on a une licence SLES 11 incluse dans votre licence vCenter.

« Génial ! » me direz vous, car vous aimez Linux et vous avez bien raison (troll). « Pas si vite », je vous répondrais. Il y a des limitations.

## Awww, man :-( too bad

D’abord, il faut savoir que les prérequis pour faire tourner la machine dans de bonnes conditions sont conséquentes : d’expérience, comptez environ 8Go de RAM, même pour un contexte de type HomeLab avec un serveur et quelques VMs. C’est assez gourmand, surtout quand on voit que le Tomcat réserve 3 Go à lui tout seul. Ça s’est cependant bien amélioré avec la version 5.5 (et voir le tuning sur la 5.1 [ici][2])

Ensuite, **gros gros gros point noir** : il faut savoir que **VMware Update Manager** n’est pas non plus compatible avec Linux et donc vCSA. Pour mettre à jour vos ESXi, il faudra donc impérativement installer le module VUM sur un serveur Windows, ce qui annule l’avantage de la vCSA pour l’affranchissement de Windows dans des environnements full Linux/Unix/whatever.

Enfin, il y a quelques fonctionnalités que je n’utilise pas mais néanmoins assez utilisées et pas compatibles, comme :

  * Microsoft SQL en temps que base de données déportée pour vCenter.
  * le vCenter Server en « Linked Mode »
  * vCenter Server Heartbeat
  * et même le support de IPv6.

## Hell yeah !!!

Pour autant, cette façon d’installer un vCenter est révolutionnaire. Via l’OVF, en quelques clics (5 minutes montre en main), vous avez une VM autonome jouant le rôle de vCenter pour vos ESXi, et vous amenant les fonctionnalités suivantes :

  * vSphere Web Client
  * vCenter Single Sign On (SSO)
  * vSphere Auto Deploy Server
  * ESXi Dump Collector
  * Inventory Service
  * Syslog Collector

Et si dans un premier temps, cet appliance ne convenait que pour les petites installation (5 hosts/50 VMs il me semble), elles peuvent maintenant atteindre les **400 serveurs et 4000 machines virtuelles**. De quoi voir venir !

Non, franchement, le vCenter sur une machine virtuelle à de beaux jours devant lui

## Quelques ressources supplémentaires sur la vSCA

  * [Changer le clavier qwerty par défaut de l’appliance vCenter vCSA de 4 à 5.5][3]
  * [Réduire la RAM consommée par VMware vCenter Server Appliance 5.1 (vCSA 5.1)][2]
  * Le KB de VMware pour « sizer » son vCSA (lien mort, comme tous les KBs VMware)
  * [Un avis sur le célèbre site Yellow-Bricks à propos de vCSA, un peu daté mais toujours d’actualité][5]


 [1]: /2010/06/01/vcenter-ou-quand-comment/
 [2]: /2013/05/07/reduire-la-ram-consommee-par-la-vmware-vcenter-appliance-5-1/
 [3]: /2015/04/08/changer-le-clavier-qwerty-par-defaut-de-lappliance-vcenter-vma-de-4-a-5-5/
 [5]: http://www.yellow-bricks.com/2011/08/10/vcenter-appliance/
