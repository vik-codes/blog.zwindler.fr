---
title: Mise à jour de votre DNS chez OVH avec DynHost
authors:
  - zwindler
type: post
date: 2014-09-22T20:03:47+00:00
url: /2014/09/22/mise-a-jour-de-votre-dns-chez-ovh-avec-dynhost/
image: /2014/09/entreprise-ovh-roubaix.jpg
categories:
  - Autohébergement
  - DIY
  - Script
tags:
  - CNAME
  - curl
  - DynDNS
  - DynHost
  - ipcheck.py
  - Livebox
  - No-IP
  - OVH

---
**Info : Pour les plus pressés, le script « corrigé » est en fin d’article. 
Il est également disponible sur le [repo github suivant, et vous pouvez récupérer le script simplement via un git clone](https://github.com/zwindler/dynhost)**

```
cd /usr/local/
git clone https://github.com/zwindler/dynhost
chmod +x dynhost/dynhost
```


Pour ceux qui n’ont pas la chance d’avoir une IP fixe pour leur besoins d’auto-hébergement et qui disposent d’un domaine chez OVH, vous avez plusieurs solutions pour continuer à héberger vos sites et vos services chez vous (comme un indispensable serveur minecraft pour vos collègues ou un serveur web des dernières photos récupérées depuis iCloud).

La plus simple est d’utiliser le client DynDNS ou No-IP de votre routeur ou de votre **totobox**. Dans mon cas (Orange), les Livebox proposent effectivement ce genre de clients, mais on les retrouve aussi sur des routeurs Linksys ou autre. Malheureusement pour nous pauvres autohébergeurs, les solutions anciennement gratuites DynDNS et No-IP se sont considérablement réduites, et il faut souvent payer à partir d’un certain nombre de sous-domaines.

Pour éviter de devoir payer (c’est une idée fixe un peu chez moi), une solution alternative consiste lorsqu’on a beaucoup de sous domaines à créer des CNAME qui pointent tous vers le même nom de domaine DynDNS du type :

```
sousdomaine1.mondomaine.com IN CNAME mondomaine.dyndns.org
sousdomaine2.mondomaine.com IN CNAME mondomaine.dyndns.org
```

Dans le principe c’est parfait. Dans la pratique, j’ai rencontré quelques difficultés dans la mise à jour de l’IP et les caches DNS de mes clients. J’ai donc profité du fait que j’étais en train de bidouiller sur le sujet pour tester les solutions proposées par OVH (DynHost).

## DynHost par OVH

OVH vous propose de faire ça « vous même » : [guide.ovh.com/DynDns](http://guide.ovh.com/DynDns) !

L’idée ici est de créer depuis le manager un champ de type DynHost ([voir ici pour le tuto complet](/2015/06/24/creation-dun-dynhost-avec-le-nouveau-manager-ovh/)) ainsi qu’un compte sur le service en ligne éponyme, puis d’installer un petit soft sur un serveur ou une VM dans votre LAN. Ce client va régulièrement vérifier que vous n’avez pas changé d’IP et mettre à jour le cas échéant le DNS chez OVH via le compte DynHost.

![](/2014/09/DynHost.png)

Historiquement, OVH proposait sur son guide DynDNS un client pour mettre à jour le DynHost depuis Linux. Cependant, ce client hébergé par **bozorokus.net** (DynHost.tgz) comprenant un script shell et un fichier python **ne sont plus disponibles**.

J’ai donc réécris le script qui a été amélioré au fil du temps à l’aide des commentaires à ce post.

## Modification du script pour nos besoins

Le script initial ne fonctionnait que lorsque le serveur sur lequel il tournait avait un accès direct à Internet avec un adresse IP publique. Ce qui n’est bien entendu pas le cas de la plupart des gens qui passent par un box (ou un routeur) et sur laquelle nous n’avons pas la main.

Historiquement, la ligne en question pour récupérer l’IP publique était

```
IP=`/sbin/ifconfig $IFACE | fgrep 'inet ad' | cut -f2 -d':' | cut -f1 -d' '
```


Ici, on récupère sans vergogne l’adresse IP de l’interface réseau concernée et on l’envoie sur Internet dans le champs DynHost renseigné dans votre DNS OVH. Dans mon cas, je me retrouvais avec une IP privée, donc ça ne marchait pas.

Sans avoir besoin de réinventer la roue, un court passage sur StackOverflow m’a permis de remplacer la ligne précédente par une version plus adaptée à l’aide de curl

```
IP=`curl https://4.ifcfg.me`
```


C’est si simple que ça ? Et ben oui visiblement. Curl, c’est magique... Il va falloir que je passe du temps sur Curl ! Mais ce n’est pas tout ce qu’on peut améliorer.

## Optimisations

Pour éviter de mettre à jour trop souvent le DNS lorsque ça n’est pas nécessaire, le script commençait également par vérifier si l’IP a changée en gardant en mémoire l’ancienne IP dans un fichier texte et en réalisant une simple comparaison.

Cette méthode simple a pourtant ses limites. Si pour une raison ou pour une autre, la mise à jour du DNS se passe mal, le fichier est mis à jour avec la nouvelle IP, et les appels futurs de la commande de mise à jour de l’IP n’iront plus mettre à jour le DNS, que l’on croit faussement à jour.

Plutôt que de comparer l’IP qu’on a « mise en cache local » dans le fichier old.ip, il suffit de réaliser une simple requête DNS sur votre dynhost. Ainsi, si votre IP publique correspond au dynhost, on ne touche à rien, par contre, dans le cas contraire, on met à jour. Tadam!

```
OLDIP=`dig +short $HOST`
```


## La version complète du script ... {#script}

Voici (enfin) le script que vous devez déposer sur votre serveur Linux.

```
#!/bin/sh
################################################################################
#This file is part of zwindler/dynhost
#Copyright (C) 2016  Denis GERMAIN
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see http://www.gnu.org/licenses/.
################################################################################
#Logfile: dynhost.log
#
#CHANGE: « HOST », « LOGIN », « PASSWORD » and « LOG_FILE » to reflect YOUR account variables
#OR: use, in argument, a custom file contains « HOST », « LOGIN », « PASSWORD » and « LOG_FILE »
CONFIG_FILE=$1

if [ -f $CONFIG_FILE ]; then
  source $CONFIG_FILE
else 
  echo "$CONFIG_FILE not found, using $HOST, $LOGIN and given PASSWORD ENV"
  LOG_FILE='/usr/local/dynhost/dynhost.log'
fi

echo '----------------------------------' >> $LOG_FILE
echo `date` >> $LOG_FILE

IP=`curl https://4.ifcfg.me`
OLDIP=`dig +short $HOST`
if [ -n "$DEBUG" ]; then
  echo "DEBUG ENV: " $CONFIG_FILE $HOST $LOGIN $PASSWORD $LOG_FILE
fi

if [ "$IP" ]; then
  if [ "$OLDIP" != "$IP" ]; then
    echo -n "Old IP: [$OLDIP]" >> $LOG_FILE
    echo -n "New IP: [$IP]" >> $LOG_FILE
    curl "http://www.ovh.com/nic/update?system=dyndns&hostname=$HOST&myip=$IP" -u $LOGIN:$PASSWORD
  else
    echo "Notice: IP $HOST [$OLDIP] is identical to WAN [$IP]! No update required." >> $LOG_FILE
  fi
else
  echo "Error: WAN IP not found. Exiting!" >> $LOG_FILE
fi
```


[Edit du 14/11/2016]J’ai ajouté la possibilité d’utiliser un fichier de configuration simple (les variables sont juste déportées vers un fichier à part) suite à une suggestion de « Manu ». Merci à lui.

```
vi /usr/local/dynhost/dynhost.cfg
#CHANGE: « HOST », « LOGIN », « PASSWORD » and « LOG_FILE » to reflect YOUR account variables
HOST='DYNHOST.VOTREDOMAIN.FR'
LOGIN='VOTREDOMAINOVH-LOGIN'
PASSWORD='VOTREMDP'
LOG_FILE='/usr/local/dynhost/dynhost.log'
```


[/Edit]

## ...et son automatisation

Un petit passage en crontab, et hop, DYNHOST.VOTREDOMAIN.FR se met à jour toutes les heures !

```
crontab -e
00 * * * * /usr/local/dynhost/dynhost
```


Si vous utilisez le fichier de configuration plutôt que les variables par défaut dans le script, il faut juste le rajouter

```
crontab -e
00 * * * * /usr/local/dynhost/dynhost /usr/local/dynhost/dynhost.cfg
```


## Client ddclient

[Edit 17/05/2016]

A priori il existe un client dans les dépôts Ubuntu qui fait la même chose... c’est un script Perl avec **beaucoup** de lignes (le code de hein, pas la configuration qui est identique) donc j’imagine qu’il gère plus de choses. Cependant des utilisateurs m’ont remonté des difficultés à le faire fonctionner (bugs?).

  * [sourceforge.net/projects/ddclient/files/ddclient](https://sourceforge.net/projects/ddclient/files/ddclient/)
  * [www.arowan.be/2016/05/07/dyndns-by-ovh](https://www.arowan.be/2016/05/07/dyndns-by-ovh/)

[/Edit]


