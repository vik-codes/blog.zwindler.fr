---
title: Piloter Nagios (API) à travers le nagios.cmd
authors:
  - zwindler
type: post
date: 2016-07-21T12:00:55+00:00
url: /2016/07/21/piloter-nagios-api-a-travers-nagios-cmd/
image: /2015/07/nagios1.png
categories:
  - Monitoring
  - Script
tags:
  - API
  - automatiser
  - cgi
  - cli
  - Nagios
  - nagios.cmd
  - notification
  - script
  - servicegroup

---
## I command thee, Nagios

Pas la peine de vous faire l’affront de vous présenter Nagios ! Si vous tombez sur cet article, c’est probablement que vous connaissez déjà l’outil et que vous cherchez juste à automatiser des tâches à l’aide d’une API ou d’un CLI pour étendre les fonctionnalités par défaut.

Car au delà de la configuration manuelle par fichier de configuration (ou via une interface web si vous utilisez Centreon par exemple), et l’interface web, il y a peu de moyens pour interagir avec Nagios.

Par manque de documentation, je me souviens avoir notamment galéré pour récupérer des statistiques de santé de Nagios. Alors qu’en fait il existe un binaire **nagiostats** ! Même s’il n’est pas forcément super facilement exploitable, c’est quand même un bon début...

Et donc, même si ce n’est pas du tout mis en avant par Nagios, OUI, il existe une méthode pour interagir avec le processus Nagios via des lignes de commandes. Mais je vous préviens tout de suite, il va falloir fouiller les docs archivées !

## Petite explication de la façon dont Nagios fonctionne

Nagios est une application monolithique écrite en C. L’interface graphique de Nagios est présentée par un serveur web apache à l’aide de scripts CGI. Je ne sais pas si le fait que l’interface de Nagios soit si ... « austère » (qui à dit « moche » ?) est une limitation liée aux choix technologique ou un réel choix ergonomique.

![](/2016/07/nagios.jpg)

Troll à part, il faut comprendre que par défaut, il n’y a pas de méthode native pour faire communiquer Apache et l’application en C. La méthode la plus simple sous Unix consiste alors à passer par un fichier particulier : un pipe nommé. Sans rentrer dans les détails techniques :

  1. L’utilisateur clique sur un lien lié à une action (comme acquitter une alerte)
  2. D’un côté, le script CGI écrit des commandes dans ce fichier fictif qu’est le pipe nommé
  3. De l’autre, au lieu que les commandes soient écrites sur disques, elles sont envoyées directement dans le processus Nagios qui les interprété.

## Eurêka, j’ai trouvé mon premier exemple !

A partir de là, on a trouvé la solution. Il est donc possible d’émuler le comportement de la GUI pour réaliser des actions en ligne de commande. Il suffit d’écrite dans le pipe nommé la bonne commande.

Forcément, on est par contre limité aux actions qu’on pourrait faire via la GUI. Typiquement, vous ne pourrez pas faire un script pour ajouter  des hôtes à chaud. Ce type d’actions ne sont possibles qu’en modifiant la configuration texte, pas de miracle...

Ça peut quand même être très utile. En astreinte, des administrateurs (rebelles) désactivaient les notifications des services qui les dérangeaient... Les fourbes ! Voilà un petit script pour réactiver tous les mardi matin les alertes appartenant au groupe de services « Services en astreinte ».

```
#!/bin/bash
#Script permettant de reactiver les notifications Nagios des services du groupe
#"Service_en_Astreinte" au cas ou elles auraient ete desactivees
################################################################################
now=`date +%s`
COMMANDFILE='/usr/local/nagios/var/rw/nagios.cmd'
SERVICEGROUP='Services_en_Astreinte'
/usr/bin/printf "[%lu] ENABLE_SERVICEGROUP_SVC_NOTIFICATIONS;$SERVICEGROUP\n" $now > $COMMANDFILE
```


Et un petit cron

```
# Reinitialisation des notifications sur le groupe Service_en_astreinte (le mardi en HO)
30 10 * * 2 /scripts/reset_production_notifications.sh
```


Pour trouver la liste des commandes disponibles, vous pouvez soit cliquer sur tous les boutons de l’interface graphique tout en surveillant le nagios.log (c’est comme ça que j’ai trouvé mes premières commandes ;-)), soit fouiller le site de Nagios pour retrouver les archives de la v2.

* [old.nagios.org/developerinfo/externalcommands/commandlist.php](https://old.nagios.org/developerinfo/externalcommands/commandlist.php)

## Deuxième exemple

En fouillant le site, je suis tombé sur une autre commande qui m’a paru très utile. Après avoir installé un nouveau site, j’ai voulu vérifier que l’envoi des notifications fonctionnaient bien sur les services important. Pour le tester, j’aurai pu créer un service à positionner exprès en CRITICAL. Cependant je préfère cette solution qui se base sur la commande SEND\_CUSTOM\_SVC_NOTIFICATION.

<table class="Content" border="0" width="750">
  <tr>
    <td class="LargeBold">
      SEND_CUSTOM_SVC_NOTIFICATION
    </td>
  </tr>
  
  <tr>
    <td class="MediumBold">
      Command Format:
    </td>
  </tr>
  
  <tr>
    <td>
      SEND_CUSTOM_SVC_NOTIFICATION;;;;;
    </td>
  </tr>
  
  <tr>
    <td class="MediumBold">
      Description:
    </td>
  </tr>
  
  <tr>
    <td>
      Allows you to send a custom service notification. Very useful in dire situations, emergencies or to communicate with all admins that are responsible for a particular service. When the service notification is sent out, the $NOTIFICATIONTYPE$ macro will be set to « CUSTOM ». The field is a logical OR of the following integer values that affect aspects of the notification that are sent out: 0 = No option (default), 1 = Broadcast (send notification to all normal and all escalated contacts for the service), 2 = Forced (notification is sent out regardless of current time, whether or not notifications are enabled, etc.), 4 = Increment current notification # for the service(this is not done by default for custom notifications). The comment field can be used with the $NOTIFICATIONCOMMENT$ macro in notification commands.
    </td>
  </tr>
</table>

Et le script qui va avec :

```
#!/bin/sh
now=`date +%s`
commandfile='/usr/local/nagios/var/rw/nagios.cmd'
/usr/bin/printf "[%lu] SEND_CUSTOM_SVC_NOTIFICATION;SERVER1;/var;0;Test_notifier;Petit coucou de la part de ma nouvelle installation!\n" $now > $commandfile
```


Avec ce petit script, j’ai bien reçu ma notification de la part du service /var de SERVER1 !

Il y a bien sûr plein d’autres scripts qu’on peut imaginer, avec les actions sur les acquittements, les commentaires, les rechecks, les actions externes, ... Je vous laisse y penser !
