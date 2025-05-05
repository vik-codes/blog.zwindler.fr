---
title: 'Création d’un DynHost avec le nouveau manager OVH'
authors:
  - zwindler
type: post
date: 2015-06-24T15:51:50+00:00
url: /2015/06/24/creation-dun-dynhost-avec-le-nouveau-manager-ovh/
image: /2015/06/ovh.png
categories:
  - autohebergement
tags:
  - BBox
  - CNAME
  - DNS
  - DynDNS
  - DynHost
  - FreeBox
  - ipcheck.py
  - Livebox
  - No-IP
  - OVH

---
Cet article fait suite à un [précédent article](/2014/09/22/mise-a-jour-de-votre-dns-chez-ovh-avec-dynhost/) qui explique pas à pas comment mettre en place le client permettant de mettre à jour votre DNS OVH si votre IP n’est pas fixe. Je vous conseille d’y jeter un œil après celui ci, si vous êtes intéressés par **DynHost**.

Pour rappel, DynHost est un service qui au même titre que **No-IP** ou **DynDNS**, permet de mettre à jour de manière dynamique une adresse IP dans un DNS si elle est dynamique. C’est particulièrement pratique dans le cas de l’auto hébergement sur un ISP comme Orange, qui ne propose pas (ou pas vraiment) d’IP fixe pour les lignes ADSL pour particuliers.

L’avantage est que le service est gratuit et intégré à  votre « manager » si vous disposez d’un domaine chez OVH, ce qui est mon cas.

Jusqu’à il y a peu, lorsqu’OVH a migré vers le nouveau manager (beaucoup plus joli), il n’était plus possible de créer, de modifier ni même de voir les champs de type « DynHost » dans la partie DNS de votre compte. Cela ne pouvait plus se faire que depuis l’ancien manager, heureusement encore disponible.

![](/2015/06/00_dynhost.png)

C’est maintenant de nouveau disponible, et voici un petit tuto pour vous guider car la documentation d’OVH n’est pas à jour.

## Création du compte

La première chose à faire est de se connecter dans votre Manager OVH, puis de vous connecter dans la partie « Domaines ».

![](/2015/06/02_dynhost.png)

Une fois le domaine sélectionné, si vous allez dans le sous menu « DynHost », il ne devrait pour l’instant rien y avoir.

![](/2015/06/03_dynhost.png)

Il faut commencer par cliquer sur « Gérer les accès », puis « Créer un identifiant ». Un formulaire de création de compte s’ouvrira. Le plus simple est de juste mettre votrdomaine.fr-dynh0st comme login, et dynh0st.votredomaine.fr comme sous-domaine.

![](/2015/06/04_dynhost.png)

Conservez bien ce login/mdp, il sera à renseigner dans le client de mise à jour du DynHost.

## Entrée DynHost dans la zone DNS

A partir de là, le compte est créé. Mais pour l’instant votre DNS n’a toujours pas connaissance de ce sous domaine. Pour cela, il faut revenir dans l’onglet DynHost, et créer une entrée en cliquant sur « Ajouter un DynH0st ».

![](/2015/06/05_dynhost.png)
Renseignez les champs avec d’une part le sous domaine que vous avez renseigné lors de la création du compte, d’autre part l’adresse IP actuelle vers laquelle vous voulez que votre DynH0st redirige.

![](/2015/06/06_dynhost.png)
Si vous hébergez plusieurs applications chez vous (et surtout si vous disposez d’un reverse proxy), le plus « propre » est de créer des alias pour chacune d’entre elle qui pointeront sur le sous domaine. Ainsi, lorsque celui ci sera mis à jour, tous vos sous domaines associés le seront également.

Par exemple, imaginons que vous hébergez un wiki mediawiki et un blog wordpress :

* `dynmediawiki.votredomaine.fr` sera un alias de d`ynhost.votredomaine.fr`
* `dynblog.votredomaine.fr` sera un alias de `dynhost.votredomaine.fr`
* `dynhost.votredomaine.fr` sera mis à jour automatiquement à chaque bascule de votre adresse IP dynamique

Sous le manager OVH, ça se traduirait par la configuration suivante :

![Vue « Zone DNS » dans le Manager OVH](/2015/06/07_dynhost.png)

![Vue « DynHost » dans le Manager OVH](/2015/06/08_dynhost.png)

Pour aller plus loin, et notamment la configuration du client pour mettre à jour le DynHost depuis chez vous :

* [Mise à jour de votre DNS chez OVH avec Dynhost](/2014/09/22/mise-a-jour-de-votre-dns-chez-ovh-avec-dynhost/)
* [Doc officielle, mais pas à jour du tout!](http://guide.ovh.com/DynDns)
