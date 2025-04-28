---
title: Plugin check_mem_ng.sh compatible RHEL 7+
authors:
  - zwindler
type: post
date: 2015-07-16T12:28:35+00:00
url: /2015/07/16/plugin-check_mem_ng-sh-compatible-rhel-7/
image: /2010/04/nyanonymous2.png
categories:
  - Monitoring
  - Script
tags:
  - buffer
  - cache
  - CentOS 7
  - check_mem.sh
  - check_mem_ng.sh
  - Free
  - graph
  - Linux
  - memory
  - Nagios
  - nagios exchange
  - perfdata
  - plugin
  - RHEL 7
  - Unix

---
Si vous utilisez Nagios(r) ou un des produits compatibles, vous « graphez » probablement l’usage de la RAM sur vos serveurs Linux.

Il existe plusieurs méthodes pour le faire : via SNMP, via NRPE, ... Un des scripts que j’utilisais en production sur l’ensemble de mes Linux (qui m’avait plu par sa simplicité) était [check_mem.sh](https://exchange.nagios.org/directory/Plugins/System-Metrics/Memory/check_mem-2Esh/details). Je l’exécutais à distance à l’aide de NRPE.

Cependant, depuis la version 7 de RedHat, un changement dans la commande « free » remontait un résultat erroné (changement du nombre de colonnes).

J’en ai donc profité pour le réécrire, corrigeant ainsi le « bug » et en ajoutant quelques fonctionnalités qui me manquaient, comme des valeurs par défaut, des options supplémentaires et une meilleure gestion des perfdata(*).

![](/2015/07/graph.png)

> Le nouveau mode de graphiques ...

Je l’ai laissé compatible avec les installations check_mem.sh existantes. En théorie, vous avez juste à remplacer le script et tout devrait fonctionner comme avant, sans dépendances supplémentaires ou modification de configuration côté client et côté serveur.

C’est ici que ça se passe :

  * [Page Github du plugin](https://github.com/zwindler/check_mem_ng)
  * [Page Nagios Exchange](https://exchange.nagios.org/directory/Plugins/System-Metrics/Memory/check_mem_ng-2Esh/details)

Pour rappel, vous trouverez aussi mes autres plugins Nagios dans le [même repository Github](https://github.com/zwindler)

* * *

(*)pour mon usage. Mais je donne aussi la possibilité de conserver les perfdata historique à l’aide de la variable **PERFDATA_LEGACY** que vous pouvez positionner à **1**, ou utiliser l’option **check\_mem\_ng.sh -l**

![](/2015/07/graph_legacy.png)

> ... et le mode legacy
