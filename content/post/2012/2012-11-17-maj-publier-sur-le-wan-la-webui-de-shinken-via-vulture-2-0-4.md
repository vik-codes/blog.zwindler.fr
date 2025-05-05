---
title: 'MàJ : Publier sur le WAN la WebUI de Shinken via Vulture (2.0.4+)'
authors:
  - zwindler
type: post
date: 2012-11-17T17:45:15+00:00
url: /2012/11/17/maj-publier-sur-le-wan-la-webui-de-shinken-via-vulture-2-0-4/
image: /2014/12/logo2-white1.png
categories:
  - autohebergement
  - Logiciel
  - Monitoring
tags:
  - content rewrite
  - Shinken
  - vulture
  - websso
  - webui

---
## Vulture et Shinken, encore

Petit update de l’article [Publier sur le WAN la WebUI de Shinken via Vulture](/2012/10/21/publier-sur-le-wan-la-webui-de-shinken-via-vulture/)

Depuis la mise à jour de vulture en 2.0.4, il est possible d’avoir des virtuals hosts, qui évitent ainsi le besoin d’avoir deux URLs distinctes du point de vue FQDN pour la WebUI et pour pnp4nagios.

On se retrouve donc avec deux applications comme suit :

> Shinken            - shinken.vulture.fr            - http://@IP_shinken:7767  
> Shinken pnp4nagios - shinken.vulture.fr/pnp4nagios - http://@IP_shinken/pnp4nagios

ATTENTION : Le « / » à la fin de pnp4nagios dans l’URL privée est très important

Pensez à modifier vos filtres de réécriture d’URL à la volée pour qu’il pointe bien vers cette URL.

![](/2012/11/rewritepnp_new.png)

> C’est beaucoup plus propre avec un FQDN unique

**Petite note additionnelle** : Attention pour ceux qui sont en 2.0.X avant 2.0.3, la mise à jour doit se faire par un réinstallation. Pour éviter de devoir tout refaire à la main, l’idéal est de désinstaller vulture en ayant préalablement copié la base de données, d’installer la nouvelle version, puis de mettre manuellement à jour la base de données.

La partie « export/import » de la configuration dans vulture fait planter vulture si la base a changé de version entre l’export et l’import (car la base de données n’est pas identiques). Tout sera planté ;-)
