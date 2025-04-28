---
title: 'Configurer l’envoi de notification email et RSS dans XWiki'
authors:
  - zwindler
type: post
date: 2016-08-04T18:00:49+00:00
url: /2016/08/04/configurer-lenvoi-de-notification-email-rss-xwiki/
image: /2015/11/1434473398.png
categories:
  - Logiciel
tags:
  - abonnement
  - email
  - modification
  - notification
  - page favorite
  - rss
  - Watchlist
  - Xwiki

---
## Notifications (RSS et email) dans XWiki

Disponible nativement pratiquement depuis les toutes premières versions de XWiki (introduit autour de la 1.3), les utilisateurs peuvent être notifiés lors de la modification des pages auxquels ils se sont abonnés.

L’abonnement est géré de façon automatique via une politique qui est définie par défaut ou modifiée par l’utilisateur lui même.

A partir de cette liste des abonnements, l’utilisateur peut également définir la manière dont il souhaite être notifié : soit via un flux RSS des pages favorites, soit via un email contenant un export de type _diff_ des pages modifiées.04

Ce tutoriel a pour but de vous donner les étapes pour configurer ces notifications de bout en bout.

## Configurer le serveur de mail

Si vous souhaitez utiliser la notification par email, la première chose est bien entendu de configurer votre serveur pour l’envoi d'email ou de renseigner dans l’application un serveur SMTP qui pourra faire le relais. Tout se gère dans le menu d’administration du XWiki.

![](/2016/07/xwiki_notif_email00.1.png)

## Configurer les alertes par email (désactivé par défaut)

Ensuite, côté utilisateur, il faut configurer son compte pour recevoir des emails lors de modification de pages favorites. Se connecter au Wiki et ouvrir la page des préférences de l’utilisateur (située en haut à droite de l’écran).

![](/2016/07/xwiki_notif_email01.png)

On arrive alors sur les préférences de l’utilisateur. Cliquer sur le menu « Favoris » puis sur le crayon pour éditer les préférences actuelles.

![](/2016/07/xwiki_notif_email02.0.png)

![](/2016/07/xwiki_notif_email02.1.png)

> Sélectionner dans le menu déroulant la fréquence d’envoi d’email souhaitée.

![](/2016/07/xwiki_notif_email02.2.png)

> Ne pas oublier de valider avec Enregistrer en bas du formulaire.

Les nouveaux paramètres sont pris en compte.

Remarque : on peut également s’abonner au flux RSS sur cette même page :

![](/2016/07/xwiki_notif_rss.png)

> Je trouve la mise en page à la mode flux RSS plus plaisante car on a juste des liens vers les pages modifiées. Le diff est complexe à lire dans les notifications email.

## Sélection des pages « favorites »

Pour rappel, la plupart des fonctionnalités de votre XWiki sont gérées par des applications. Celle qui gère les pages favorites (notion d’abonnement) est [l’application Watchlist](https://extensions.xwiki.org/xwiki/bin/view/Extension/Watchlist+Application).

Les pages favorites sont sélectionnées automatiquement par XWiki si vous avez laissé les valeurs par défaut. Toutes les pages créées et auquel vous aurez contribué en tant qu’utilisateur seront automatiquement inscrites dans vos pages favorites.

Dans le cas où vous souhaiteriez en ajouter de nouvelles, vous pouvez le faire manuellement en cliquant sur le bouton en forme de cloche en haut à droite à côté de votre avatar de connexion.

![](/2016/07/xwiki_notif_email04.png)

Une fois la page favorite sélectionnée, on clique sur le bouton en forme de cloche, puis on sélectionne si on souhaite ne s’abonner qu’à cette page (premier bouton), à cette page et ses fils (second bouton) ou à tout le wiki dans sa globalité.

Dans le cas où l’on souhaite disposer de la liste des pages auxquelles on est abonné, il est possible d’en avoir la liste et si nécessaire d’en supprimer dans le menu des préférences utilisateur.

![](/2016/07/xwiki_notif_email05.png)

## Bonus : le planificateur de tâches

Petit bonus, lorsque j’ai fais les tests de notifications, je n’ai pas voulu attendre l’heure passée pour recevoir l'email ;-). J’ai donc été voir du côté du Scheduler, le planificateur de traitements interne au XWiki.

On peut couper/relancer ou même forcer le déclenchement des traitements de l’application WatchList (et des autres !).

![](/2016/07/xwiki_notif_email00.2.png)

**Enregistrer**
