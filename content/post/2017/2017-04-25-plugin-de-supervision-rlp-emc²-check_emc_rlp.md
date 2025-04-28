---
title: 'check_emc_rlp : supervision des LUNs dans le RLP sur baies VNX EMC²'
authors:
  - zwindler
type: post
date: 2017-04-25T12:00:51+00:00
url: /2017/04/25/plugin-de-supervision-rlp-emc²-check_emc_rlp/
image: /2017/04/check_emc_rlp03.png
categories:
  - Monitoring
  - Script
tags:
  - Centreon
  - EMC
  - github
  - graph
  - Icinga
  - LUN
  - Nagios
  - nagios exchange
  - performance
  - RLP
  - Shinken

---
## Dans la série ...

... plugins pour les outils de supervision Nagios(r) like et « Nagios(r) compatibles » (Icinga, Naemon, Shinken, …), je met à disposition un script que j’ai écris il y a quelques années et qui permet de vérifier et de grapher que vous disposez toujours des LUNs dans le RLP (Reserved LUN Pool). Je l’ai appelé sobrement check\_emc\_rlp et j’en parle aussi dans [cet article à propos de NaviSecCli](/2017/04/18/naviseccli-pour-piloter-ses-baies-emc-vnx-depuis-linux/).

Mon problème initial était que j’avais plusieurs fois eu mes snapshots bloqués lors de l’utilisation un peu trop intensive du LUN source. Il n’y avait plus de place sur les LUNs dans le RLP, ce qui a pour effet de bloquer le snapshot et donc la base de préproduction que j’avais dessus. Un petit script qui vérifie qu’il y a toujours au moins 1 LUN non utilisé par LUN snapshoté permet de garder un peu de marge avant plantage.

Voilà ce que donne ce `check_emc_rlp` une fois mis en place dans Centreon :

![](/2017/04/check_emc_rlp04.png)

> Le script nous informe qu’il reste suffisamment de LUN dans le RLP lorsqu’il y a des snapshots actifs

![](/2017/04/check_emc_rlp01.png)

> La courbe de performance (PERFDATA Nagios) indique ici qu’il reste 3 LUN par LUN snapshoté (12 en fait en tout), et qu’on remonte à 6 par LUN à minuit (moment où on rafraichit notre préproduction et que les snapshots se vident)

![](/2017/04/check_emc_rlp03.png)

> La vue agrégée avec à la fois le nombre de LUN disponibles dans le RLP ainsi que le remplissage des LUN utilisés pour stocker le différentiel, par LUN snapshoté. Ce qui est intéressant ici c’est qu’on voit bien l’évolution du remplissage et le moment où la baie décide qu’elle a besoin d’un nouveau LUN en provenance du RLP

Comme d’habitude pour le téléchargement et la documentation, c’est sur [Nagios Exchange][5] et [Github][6] que ça se passe.

Pour rappel, vous trouverez aussi mes autres plugins Nagios dans le [même repository Github.][7]

 [5]: https://exchange.nagios.org/directory/Plugins/Hardware/Storage-Systems/SAN-and-NAS/EMC-Clarion/check_emc_rlp/details
 [6]: https://github.com/zwindler/check_emc_rlp
 [7]: https://github.com/zwindler/
