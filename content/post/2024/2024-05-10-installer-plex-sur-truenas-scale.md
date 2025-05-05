---
title: 'Installer plex sur TrueNAS (SCALE)'
authors:
  - zwindler
type: post
date: 2024-05-10T18:00:00+02:00
url: /2024/05/10/installer-plex-sur-truenas-scale/
image: /2024/05/truenas-plex-2.png
categories:
  - autohebergement
  - Matériel
tags:
  - QNAP
  - k3s
  - plex
  - TrueNAS
  - SCALE

---

Cet article fait partie d’une série dans laquelle je parle de mon nouveau NAS que j’ai construit moi-même :

* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - hardware](/2024/05/03/mon-nas-en-2024-jonsbo-n100-part1/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - software](/2024/05/19/mon-nas-en-2024-jonsbo-n100-part2/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - stress tests et conclusion](/2024/07/04/mon-nas-en-2024-jonsbo-n100-part3/)
* [Bonus - Installer plex sur TrueNAS (SCALE)](/2024/05/10/installer-plex-sur-truenas-scale/)

## Plex sur mon NAS

Un des prérequis quand je construis / achète un NAS, c'est la possibilité d'installer dessus Plex Media Server.

D'expérience, même s'il est possible d'avoir une VM sur un hyperviseur à côté qui gère la médiathèque "à côté" du NAS, ou même de déléguer ce rôle "serveur plex" à la box de l'opérateur ou même notre smartTV, c'est souvent plus pénible qu'autre chose :

* je n'ai pas toujours un hyperviseur allumé à la maison et monté la médiathèque sur Internet est hors de question
* le volume partagé qui héberge les médias entre le NAS et la VM peut sauter, et c'est pénible à debug / corriger quand ça arrive
* les box / smartTV sont souvent trop limitées en hardware (espace disque pour les apps, CPU rachitique, RAM insuffisante...)
* je change de box opérateur plus souvent que de NAS

Note : je suis certain qu'on ne sera pas d'accord avec moi sur certains de ces points, et c'est OK. Moi, je trouve que c'est mieux comme ça, mais vous faites bien comme vous voulez ;-P.

J'ai donc envie d'avoir Plex sur mon NAS et de ne pas trop m'embêter pour la gestion au quotidien.

## Les "apps" dans TrueNAS

Et ça tombe plutôt bien, car nos amis de chez TrueNAS maintiennent à jour une application Plex pour TrueNAS. Sauf que sur le papier, elle est pas hyper simple à installer, d'où cet article pour vous guider ;-\).

Tout cet article part du principe que vous utilisez TrueNAS SCALE et pas TrueNAS Core.

Si vous ne connaissez pas la différence, le mieux est que vous alliez voir par vous-même [la documentation officielle - compare TrueNAS software](https://www.truenas.com/compare/). 

TL;DR TrueNAS Core, c'est la version historique basée sur FreeBSD (qui s'appelait d'ailleurs FreeNAS, initialement). Cependant, depuis quelques années, iXsystems, l'entreprise qui développe TrueNAS, met à disposition une version basée sur Debian (donc GNU/Linux).

Pour des raisons que j'expliciterai dans l'article sur le choix du software (oui je viens donc de vous spoiler l'article suivant), j'ai TrueNAS SCALE et pas Core.

Pour faire tourner les "apps", TrueNAS s'est appuyé sur un standard du marché : Kubernetes. Et oui, n'en déplaise à ses détracteurs, Kubernetes **est** devenu un standard du marché. Ca ne dit pas si c'est une bonne chose (on peut juger le précédent standard, aka VMware, à l'aune de l'actualité, par exemple). Mais c'est juste un fait.

## Activer les apps

Par défaut, TrueNAS n'active pas les "apps". Ca va être à nous de le faire. En soit, ce n'est pas forcément un mal : si vous n'en avez pas besoin aucune raison de consommer des ressources pour rien.

Et quand on parle de consommation de ressources et de Kubernetes je vois déjà les gens dans le fond qui font les gros yeux. Rassurez-vous (pas sûr que ça vous rassure, mais moi oui), les équipes d'iXsystems ont eu la sagesse de choisir [k3s](https://blog.zwindler.fr/recherche/?keyword=k3s) et non un kubernetes vanilla pour héberger Kubernetes sur notre NAS. Les ressources consommées par le control plane seront donc minimales (quelques centaines de Mo au max).

On va donc dans l'onglet "Apps" et on active k3s en l'installant simplement sur un de nos pools. Dans mon cas, j'en ai deux. Un avec mes disques durs classiques, et un avec un (unique) SSD.

Initialement j'avais installé le k3s sur le pool de HDDs, histoire de mutualiser le stockage et de maximiser la disponibilité (j'ai un RAID-Z1). Cependant, le k3s de TrueNAS a tendance à écrire pas mal sur les disques, qui se retrouvaient à gratouiller sous mon bureau pendant une demie seconde toutes les 5 secondes environ. Très énervant.

J'ai donc recréé un pool spécial pour les apps sur un SSD que j'avais en rab.

On clique sur **Settings** en haut à droite, puis **Choose Pool**

![](/2024/05/truenas-plex-1.png)

## Installer plex media server via les apps

Au bout de quelques secondes / minutes, k3s est installé et on peut commencer à chercher une app parmi le catalogue (>100). Ici on recherche plex et on clique sur **Install**

![](/2024/05/truenas-plex-2.png)

A partir de là, une fenêtre avec plein de paramètres va apparaitre. Mais avant d'aller plus loin, on va aller sur la page [www.plex.tv/claim/](https://www.plex.tv/claim/). Une fois loggué sur votre compte, la page va vous générer un token temporaire, qui va permettre de relier directement le serveur une fois qu'il aura démarré sur votre NAS avec votre compte. Pratique !

![](/2024/05/truenas-plex-3.png)

Dans la looongue page de configuration, on a que quelques paramètres à changer. D'abord, il faut renseigner le token qu'on vient de générer dans la section **Plex Configuration**. Si vous avez le Plex pass, vous pouvez aussi changer **Image** :

![](/2024/05/truenas-plex-4.png)

Ensuite, dans la partie **Storage configuration**, il va falloir indiquer le chemin vers le pool qui contient les médias. Moi c'est /mnt/rpool/tank/Vidéos. rpool est le nom de mon pool RAID-Z1, tank est mon volume principal.

![](/2024/05/truenas-plex-5.png)

Attention : assurez-vous que l'utilisateur unix (local) "apps" a bien accès en lecture/exécution sur toute l'arborescence, sinon vous ne verrez pas le dossier quand Plex sera lancé (très frustrant, il n'y a aucun message d'erreur, juste "rien").

De manière optionnelle, vous pouvez tuner les "limits" (au sens docker/kubernetes du terme) de votre app. Par défaut, la chart plex de TrueNAS propose 4 CPUs et 8 Go de RAM, ce qui est beaucoup. Mon plex ne consomme que 100 Mo au repos. J'ai baissé à 2 CPUs (avec un risque de throttling, mais là on rentre dans des notions un peu tricky de Kubernetes que je préfère esquiver aujourd'hui dans cet article) et 4 Gio de RAM (j'en ai 16 mais je veux garder le plus de cache possible).

![](/2024/05/truenas-plex-6.png)

Une fois terminé, l'application se déploie, puis affiche Running. On a alors un cartouche **Application Info** dans **Details** qui devrait afficher un bouton **Web Portal** qui devrait nous rediriger sur l'IP de notre NAS sur le port 32400 (celui habituel de plex).

On peut donc se laisser guider par le wizard de configuration de Plex Media Server, lui donner un nom mignon et aller chercher nos médiathèques dans /data. Normalement, le dossier que vous avez donné lors de l'étape **Storage configuration** devrait apparaitre.

![](/2024/05/truenas-plex-7.png)

![](/2024/05/truenas-plex-8.png)

## Bonus

Pour une raison que j'ignore (peut être parce que c'est un container avec un adressage à part), j'ai dû explicitement indiquer le port public (32400 sur ma box, qui redirige sur l'IP de mon NAS et le port 32400) pour que le Control à distance fonctionne et que l'accès direct (sur le réseau local) fonctionne correctement.

![](/2024/05/truenas-plex-9.png)
