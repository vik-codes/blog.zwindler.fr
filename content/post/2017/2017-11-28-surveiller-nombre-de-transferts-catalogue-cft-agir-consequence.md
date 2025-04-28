---
title: Superviser le nombre de transferts dans le catalogue CFT et agir en conséquence
authors:
  - zwindler
type: post
date: 2017-11-28T12:45:14+00:00
url: /2017/11/28/surveiller-nombre-de-transferts-catalogue-cft-agir-consequence/
image: /2017/11/check_cft_listcat.png
categories:
  - Monitoring
  - Script

---
## Petit rappel de ce qu’est CFT

CFT (Cross File Transfer) est un logiciel d’entreprise publié par Axway qui permet de gérer de manière sécurisée les transferts de fichiers entre plusieurs clients/serveurs.

Bien qu’il existe des alternatives libres pour réaliser des choses similaires ([notamment Waarp][1]), CFT est un des seuls logiciels sur le marché Français permettant de communiquer avec le protocole PESIT (entre autres) et il n’est pas rare de le retrouver dans de grandes entreprises Françaises qui ont un historique difficile à migrer.

Il y a un court article sur Wikipedia qui parle [de CFT][2] et de [Pesit][3].

Quand on utilise CFT, il existe une notion de catalogue. Au-delà du simple logiciel de transfert de fichier, CFT est aussi appelé moniteur de transfert car il permet de visualiser l’état des transferts avec un historique et une gestion des erreurs.

## Pourquoi un script pour surveiller le catalogue ?

Il se trouve que ce catalogue est limité en taille via le fichier de configuration de CFT. Sauf erreur de ma part, on ne peut pas aller au-delà de 30000 comme taille de catalogue dans la configuration.

Quand on approche de cette limite fatidique, vous pouvez soit purger le catalogue, soit faire une rotation du catalogue (le remplacer par un catalogue vide). Si vous ne le faites pas, CFT se bloquera et refusera tous les traitements futurs (en entrée ou en sortie).

Il est donc important de garder cette limite en visibilité en supervision ;-) .

## Installation

Le script que je vous met à disposition sur github est très simple, il ne repose que sur sh et cftutil (l’utilitaire de CLI de CFT).

  * La version française est [disponible ici][4]
  * La version anglaise est [disponible ici][5]

## Configuration

On utilise la commande de la façon suivante :

```
/usr/local/nagios/libexec/check_cft_listcat.sh [warning] [critical]
```


Là encore, tout est très simple. Comme **cftutil** est présent par défaut sur les serveurs CFT, le plus simple est de passer par NRPE pour exécuter le script directement sur la machine CFT.

```
cat /etc/nagios/nrpe.cfg
[...]
command[check_cft_listcat]=/usr/local/nagios/libexec/check_cft_listcat.sh $ARG1$ $ARG2$
```


Voici les codes retours que vous pouvez récupérer (le script gère les perfdata et génère donc des graphes si votre supervision le supporte) :

```
./check_cft_listcat 25000 28000
OK: 1977 transfers in catalog. | nbre=1977;25000;28000;;

./check_cft_listcat 250 2800
WARNING: 1977 transfers in catalog. CFT will stop at 30000 !! | nbre=1977;250;2800;;

./check_cft_listcat 250 280
CRITICAL: 1977 transfers in catalog. CFT will stop at 30000 !! | nbre=1977;250;280;;
```


![](/2017/11/check_cft_listcat.png)

## Bonus : event handler

Alerter c’est bien, mais réagir automatiquement, dans certains cas, c’est bien aussi.

Parfois, il peut être acceptable de réaliser automatiquement la rotation ou la purge du catalogue plutôt que de risquer le plantage de CFT. Pour se faire, vous pouvez utiliser les events handlers de nagios (ou autres outils compatibles) pour exécuter, via une commande cftutil qui va déclencher l’action au moment de l’alerte.

### Exemple de purge du catalogue

Côté Centreon, dans la configuration du service :

![](/2017/11/check_cft_listcat_event1.png)

Côté Centreon, la commande handler :

![](/2017/11/check_cft_listcat_event2.png)

Côté Centreon, la commande qui exécute un SSH si le seuil est CRITICAL :

```
#!/bin/bash
#Script permettant la purge du catalogue CFT via Nagios
#$1 => IP de l'hote, variable $HOSTNAME$
#$2 => Status cote Nagios, variable $SERVICESTATE$

echo "`date` : appel du script automatique de purge cft avec les parametres '$1' et '$2'" >> /tmp/event_handler

if [[ $2 == 'CRITICAL' ]] || [[ $2 == 'WARNING' ]] ; then
        echo "PURGE!" >> /tmp/event_handler
        ssh cft@$1 '/home/cft/purge_transfert.sh  1>/dev/null 2>&1 && echo "`date` : purge declanchee suite au passage a letat critical" >> /tmp/event_handler'
        echo "CODE RETOUR $?" >> /tmp/event_handler
fi
exit 0
```


Côté serveur CFT

```
#!/bin/bash
. ~/.bash_profile
moment=`date '+%H'`
exec 1>/tmp/purge_transfert_${moment}.log
exec 2>>/tmp/purge_transfert_${moment}.log
#Purge du catalogue"
cftutil listcat content=full,state=CD
CFTUTIL DELETE IDT=* ,PART=*, STATE=T
cftutil listcat content=full,state=CD
```


Comme d’habitude avec mes plugins « Nagios compatibles », les sources sont disponibles sur Github à l’adresse suivante :

Le lien pour [Nagios Exchange est également disponible ici !][9]

Mes autres plugins sont également disponibles sur le Github :

  * [Plugin check\_mem\_ng.sh compatible RHEL 7+](/2015/07/16/plugin-check_mem_ng-sh-compatible-rhel-7/)
  * [check\_emc\_rlp : supervision des LUNs dans le RLP sur baies VNX EMC²](https://blog.zwindler.fr/2017/04/25/plugin-de-supervision-rlp-emc%C2%B2-check_emc_rlp/)
  * [Plugin de supervision check\_wlst\_sessions (WebLogic 9+)](/2016/11/09/plugin-check_wlst_sessions-weblogic-9/)
  * [Supervisez vos URLs bloquées par le proxy](/2017/11/21/supervisez-vos-urls-bloquees-proxy/)

 [1]: https://www.waarp.fr/
 [2]: https://fr.wikipedia.org/wiki/Cross_File_Transfer
 [3]: https://fr.wikipedia.org/wiki/PESIT
 [4]: https://github.com/zwindler/check_cft_listcat/blob/master/check_cft_listcat.fr.sh
 [5]: https://github.com/zwindler/check_cft_listcat/blob/master/check_cft_listcat.sh
 [9]: https://exchange.nagios.org/directory/Plugins/Software/check_cft_listcat/details