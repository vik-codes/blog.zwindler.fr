---
title: Superviser des appliances HPE StoreVirtual VSA (LeftHand) avec Nagios/Centron/Shinken
authors:
  - zwindler
type: post
date: 2019-01-08T12:45:34+00:00
url: /2019/01/08/superviser-des-appliances-hp-storevirtual-vsa-lefthand-os-avec-nagios-centron-shinken/
image: /2017/02/hp_vsa-1.png
categories:
  - Cluster
  - Stockage
  - systeme
  - Virtualisation
tags:
  - Centreon
  - HP VSA
  - HPe
  - Nagios
  - nagios exchange
  - plugin
  - Shinken
  - StoreVirtual
  - Supervision
  - VSA

---
## Superviser des Lefthand ?

Dans une vie antérieure (article dans mes tiroirs depuis fin 2015 a priori XD), j’ai eu à gérer, _on premise_, du stockage hautement disponible HPE VSA pour mes clusters VMware.

Si vous êtes ici, c’est sûrement parce que vous aussi, vous avez acheté des LeftHand (StoreVirtual P4000) et/ou des HPE VSA, et que vous voulez les superviser.

La plupart des tâches d’administration se font depuis la CMC (Centralized Management Console), mais clairement ce n’est pas hyper pratique. La section 7 du manuel StoreVirtual traite de la supervision en général : h20628.www2.hp.com/km-ext/kmcsdirect/emr_na-c04581885-1.pdf (lien mort, pas sauvegardé par Internet Archive).

![](/2017/02/hpvsa_ftp.png)

Heureusement, la documentation explicite clairement qu’il est possible d’activer SNMP pour externaliser tout ça.

A noter, je n’ai pas pu m'empêcher de glousser en lisant cette petit phrase dans un manuel d’administration un peu plus ancien, qui dit que vous ne pouvez pas changer, ni même supprimer (#Sécurité), les communautés par défaut :

![](/2018/12/sanmon.png)

> Section 7 du manuel d’administration http://www.hp.com/ctg/Manual/c01865545.pdf

## Nagios / Centreon / Shinken

Pour superviser mes machines dans mes DC « on-premise », j’utilisais Centreon. Tout naturellement je me suis tourné vers Nagios Exchange pour voir s’il n’y avait pas déjà des gens qui avaient fait le travail.

2 plugins ont attirés mon attention :

* [exchange.nagios.org/directory/Plugins/Hardware/Storage-Systems/SAN-and-NAS/check_lefthand-2Epl/details](https://exchange.nagios.org/directory/Plugins/Hardware/Storage-Systems/SAN-and-NAS/check_lefthand-2Epl/details)
* [exchange.nagios.org/directory/Plugins/Hardware/Storage-Systems/SAN-and-NAS/check_lhc/details](https://exchange.nagios.org/directory/Plugins/Hardware/Storage-Systems/SAN-and-NAS/check_lhc/details)

## Prérequis

Le plus récent et le plus téléchargé, **check_lhc**, nécessite le téléchargement de MIB. Je les avaient trouvé sur **circitor** (ex. [www.circitor.fr/Mibs/Html/L/LEFTHAND-NETWORKS-NUS-COMMON-CLUSTERING-MIB.php](http://www.circitor.fr/Mibs/Html/L/LEFTHAND-NETWORKS-NUS-COMMON-CLUSTERING-MIB.php)), puis de les déposer dans votre serveur Nagios/Centreon/Shinken

```
/usr/share/snmp/mibs/
```


J’avais également trouvé des ressources sur le site d’HPE, mais comme ils passent leur temps à le refaire les 3 liens que j’avais sauvegardés sont maintenant HS. Voilà voilà.

En gros, ce que ça disait, c’est que les MIB sont contenues dans l’installeur, celui qui est utilisé pour instancier les VSA la première fois.

![](/2015/11/01_storevirtual.png)


![](/2015/11/02_storevirtual.png)


Fallait le savoir...

## Configurer SNMP

Comme les deux plugins utilisent SNMP, on va... l’activer. **#ThanksCaptainObvious**.

Depuis la CMC, on peut donc configurer nos StoreVirtual pour qu’elles acceptent des connexions SNMP et configurer une communauté (voir [le manuel d’admin, page 93][5]). Clairement, ce n’est pas sorcier.

Dans le **Management Group**, on a un menu **Event**, dans lequel on peut configurer un serveur SMTP (pratique pour recevoir les mails qui m’informe que mon cluster est à plat et que mes données sont définitivement corrompues et que je peux aller pointer à _Paul Emploi_).

Et, **SNMP**.

![](/2015/11/03_storevirtual.png)


## Checker

Maintenant que vous avez activé SNMP (avec une communauté bien complexe, readonly et des restrictions IP à vos seuls serveurs de supervision, on est d’accord), on peut voir si ça marche.

Personnellement j’ai préféré **check_lefthand**, car la doc est plus fournie et les options plus nombreuses .

```
./check_lefthand.pl -H 10.10.10.16 -C hyperdifficultcommunity

Cowardly exiting, not instructed to check anything!
check_lefthand.pl -H  -C  [-t timeout] [-p port] 

Additional Options:
--module-space
report the available space on each 'module' within a management group

--module-status
report on the various status elements for each 'module' within a management group

--volume-space
report the available space on each volume within a management group

--volume-status
report on the various status elements for each volume within a management group

--cluster-space
report the available space for each cluster within a management group

--cluster-status
report the status of each cluster within a management group
```


Les deux alertes que j’ai mises en place sont l’état du clusters, et le status de mes volumes (synchronisés ou pas entre les 2 salles).

```
centreon$ ./check_lefthand.pl -H 10.10.10.16 -C hyperdifficultcommunity --cluster-status
OK - mgmt group: MyAwesomeHPVSA 5/5 Cluster Managers Active.

centreon$ ./check_lefthand.pl -H 10.10.10.16 -C public --volume-status
OK - mgmt group: MyAwesomeHPVSA 4 Volumes with valid replication and Data Protection.
```


A noter, tout n’est pas parfait. Dans certains cas, j’ai remarqué que l’alerte ne se déclenchait pas quand des nœuds étaient DOWN, car le compteur « total » de nœuds décrémentait en même temps que les nœuds tombaient (ce qui est très bête...).

Mais c’est quand même un début :)

## Bonus : Rage

Ouais, je sais...HPE VSA (maintenant HPe StoreVirtual VSA), quoi. L’alternative « géniale » de HPE à VSAN.

Ne me blâmez pas... A l’époque, on m’avait donné le choix entre 2 appliances physiques NetApps **plus chères** et **même pas hautement disponibles** (actif/passif) et donc les fameuses HPE VSA Storevirtual. Et puis sur le papier, ça paraissait robuste. C’est basé sur un produit éprouvé, les Lefthands (appliances physiques) et un OS Linux.

> What could go wrong?

Maintenant que je ne m’en occupe plus, je peux dire que c’est grâce à ce superbe outil que j’aurai fais un week end non-stop quasiment sans dormir au téléphone avec des techs HPE et VMware de tout autour du monde (mais je me suis fait payer plus de 25 heures d’astreinte **#youpi**) parce que les nœuds tombaient les uns après les autres sans raison apparente.

Pour les curieux, c’était un problème de hotspare qui se mettait en veille et bloquaient les nodes, les uns après les autres, dès qu’une commande « refresh storage usage » était lancée par l’ESXi (automatique ou manuel).

C’est aussi mon record personnel **du ticket support le plus longtemps**, tout constructeur/éditeur confondu. Les chiffres sont impressionnants :

  * un mois pour trouver un workaround (désactiver les hotspares, #genious)
  * plus de 200 emails
  * 5 mises à jours (dont 4 inutiles)
  * 3 interventions le soir sur la prod
  * Et last but not least : **2 ans** pour trouver le fix (alors que le problème était détecté puisqu’on savait qu’il suffisait de désactiver les hotspares).

_<b>DEUX... ANS...</b>_

Au final, je ne suis même pas vraiment sûr que le problème soit fixé.

Je ne suis plus sûr de rien, à part du niveau de compétence de HPE sur le sujet des serveurs et du stockage.

Mais qui peut les blâmer, ce n’est pas leur cœur de métier après tout. **#ohwait**

 [5]: http://h20628.www2.hp.com/km-ext/kmcsdirect/emr_na-c04581885-1.pdf
