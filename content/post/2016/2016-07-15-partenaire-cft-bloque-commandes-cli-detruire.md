---
title: Un partenaire CFT bloque tout, les commandes CLI pour tout détruire
authors:
  - zwindler
type: post
date: 2016-07-15T13:00:55+00:00
url: /2016/07/15/partenaire-cft-bloque-commandes-cli-detruire/
image: /2016/07/axway2-1.jpg
categories:
  - Divers
tags:
  - CFT
  - Sopra
  - Synchrony
  - Transfert
  - XFB

---
## Tout commence comme souvent en astreinte

[Aparté] Pour ceux qui ne savent pas de quoi il s’agit, CFT (Cross File Transfert) est un logiciel de transfert de fichier développé par la société Axway, aujourd’hui acquise par Sopra Group. [/Aparté]

Il y a quelques jours, j’ai été réveillé en astreinte à cause d’une contention dans CFT. Ceux qui utilisent le produit se demandent peut être de quoi je parle ...

Aujourd’hui, pour des raisons de traitements des fichiers un peu complexes, notre plateforme de production ne repose pas que sur des mécanismes standards. Nous utilisons des scripts personnalisés qui gèrent de manière plus complexe que ce que l’outil gère nativement la façon dont sont envoyés les fichiers (notamment avec des files).

Nous n’utilisons finalement que la fonction première de CFT. C’est à dire envoyer/recevoir des fichiers, réessayer si ça n’a pas marché. Sauf que lorsqu’un partenaire ne répond plus, il arrive que la machine s’enraye.

Typiquement, dans ce cas, le script envoyait 50 fichiers au partenaire HS. Toutes les 5 minutes. Jusqu’à bloquer tous les autres transferts de production. Et même faire planter le catalogue (base de données des transferts avec une rotation quotidienne). Pour info le logiciel bride à 30000 le nombre d’enregistrements maximum.

## Heureusement il y a la CLI. La CLI ! (sur une musique de Findus ndlr)

Habituellement, pour se _« faciliter la vie »_ nous utilisons une GUI Java pour administrer tout ça. Ahaha tiens Java parlons en.

Les navigateurs évoluent, pas la GUI sur le serveur de production (whoops). Du coup la GUI ne fonctionne plus que sur un serveur qui a encore Internet Explorer 8 et Java 6... C’est vrai pour la plupart des produits d’administration pour nos switchs, nos baies de disques, ... Super les devs. Merci. Vraiment fallait pas !

Tout ça pour dire que même quand la GUI fonctionne, je me voyais mal annuler 50 transferts toutes le 5 minutes pendant toute la nuit. J’ai donc dégainé les quelques commandes de CLI que je connais pour supprimer automatiquement tous les transferts dès qu’ils apparaissent. Et juste parce que je suis sympa, j’ai ajouté une structure conditionnelle qui vérifie que le port 1765 (port CFT par défaut) ne se mette pas à répondre, des fois que mes homologues d’une société de service nantaises se réveillent et fasse leur travail ;-).

```
#/bin/bash
#Script de la mort pour supprimer tous les transferts en état D d'un partenaire
PART_IP=$1
PART_CODE=$2
nc -z $PART_IP 1765
if [ "$?" -ne 0 ]; then
echo "port ko"
su - cft -c "cftutil delete part=$PART_CODE, state=D"
echo partenaire $PART_CODE hs | mail -s 'Partenaire $PART_CODE CFT HS' coucou@blog.zwindler.fr
else
echo "port ok"
fi
```

Bien entendu, ça marche aussi avec les status H et K qui s'empilent suite aux problèmes de connexion avec le serveur distant.

```
su - cft -c "cftutil delete part=$PART_CODE, state=H"
su - cft -c "cftutil delete part=$PART_CODE, state=K"
```

## Bonus, un peu de docs complémentaires

On trouve assez peu de documentation sur Internet à propos de l’outil CFT. Je vous donne les quelques liens que j’ai pu accumuler avec le temps et qui expliquent plutôt bien comment administrer l’outil :

* [wiki.tuxunix.com/index.php/Doc_CFT (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20200221214654/http://wiki.tuxunix.com/index.php/Doc_CFT)
* [jfgg.free.fr/cmsms/index.php?page=principales-cdes-cft](http://jfgg.free.fr/cmsms/index.php?page=principales-cdes-cft)
* [jfgg.free.fr/cmsms/sources/doc-cft.pdf](http://jfgg.free.fr/cmsms/sources/doc-cft.pdf)
* [jlbicquelet.free.fr/produits/cft/cft_faq.php](http://jlbicquelet.free.fr/produits/cft/cft_faq.php)
* docs.axway.com/u/documentation/transfer\_cft/3.1.3/webhelp\_portal/content/cftutil/cftutil\_start\_here.htm (lien mort, pas dispo sur Internet Archive)
