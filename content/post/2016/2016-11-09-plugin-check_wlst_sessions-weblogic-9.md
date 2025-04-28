---
title: Plugin de supervision check_wlst_sessions (WebLogic 9+)
authors:
  - zwindler
type: post
date: 2016-11-09T13:00:18+00:00
url: /2016/11/09/plugin-check_wlst_sessions-weblogic-9/
image: /2016/10/check_wlst_sessions-1.png
categories:
  - Monitoring
tags:
  - Icinga
  - Nagios
  - nagios exchange
  - Shinken
  - WebLogic
  - WLST

---
Dans la série : plugin pour les outils de supervision Nagios(r) like et « Nagios(r) compatibles » (Icinga, Naemon, Shinken, ...), je met à disposition un script que j’ai écris il y a quelques années et qui permet de vérifier et de grapher que vous n’avez pas atteint un certain nombre de sessions concurrentes dans le serveur d’application Java WebLogic d’Oracle.

Mon problème initial était que je n’arrivais pas à avoir de manière simple le nombre de sessions sur une JVM WbLogic. Je pouvais compter le nombre de processus/threads, mais ça ne correspond pas forcément à un nombre d’utilisateurs actifs.

Or, l’éditeur du progiciel nous avait fourni un sizing en fonction d’un nombre d’utilisateurs. Il était donc important d’avoir ce chiffre de manière fiable.

Il existait un plugin similaire pour la version 8 du serveur d’application ([développé par Sergei Haramundanis][1]), mais qui utilisait un module Weblogic.Admin, déprécié dans la version 10 que j’utilise.

Je me suis donc basé sur le WebLogic Scripting Tool (WLST) qui permet d’administrer et de récupérer des informations des serveurs WebLogic via des commandes Python interprété par Java (-_-« ). En fait, on peut réaliser l’ensemble des opérations disponibles dans la console WebLogic (l’AdminServer) en script.

![](/2016/10/check_wlst_sessions3.png)

La documentation du WLST est [disponible à l’URL suivante][3].

Voilà ce que ça donne, une fois mis en place :

![](/2016/10/check_wlst_sessions2.png)

![](/2016/10/check_wlst_sessions-1.png)

Comme d’habitude pour le téléchargement et la documentation, c’est sur [Nagios Exchange][6] et [Github][7] que ça se passe.

Pour rappel, vous trouverez aussi mes autres plugins Nagios dans le [même repository Github.][8]

 [1]: https://exchange.nagios.org/directory/Plugins/Java-Applications-and-Servers/Weblogic/check_weblogic_sessions/details
 [3]: http://docs.oracle.com/cd/E13222_01/wls/docs90/config_scripting/reference.html
 [6]: https://exchange.nagios.org/directory/Plugins/Java-Applications-and-Servers/Weblogic/check_wlst_sessions/details
 [7]: https://github.com/zwindler/check_wlst_sessions
 [8]: https://github.com/zwindler/
