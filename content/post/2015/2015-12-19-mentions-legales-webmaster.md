---
title: Mentions légales pour un webmaster
authors:
  - zwindler
type: post
date: 2015-12-19T17:30:56+00:00
url: /2015/12/19/mentions-legales-webmaster/
image: /2022/05/cnil.png
categories:
  - autohebergement
tags:
  - CNIL
  - Cookies
  - extension
  - Mention légales
  - plugin
  - wordpress

---
[Edit]Mis à jour le 10/11 suite à la découverte d’un générateur de mentions légales[/Edit]

Lorsqu’on édite un site sur Internet, il faut savoir qu’il y a un **certain nombre de règles** à respecter, notamment face à la CNIL.

Ces règles (mentions légales, cookies, déclaration)  sont un peu « procédurières » mais en théorie, en cas non respect de ces règles, les sanctions peuvent être extrêmement lourdes. Jugez par vous même pour le cas de cookies :

> Avant de déposer ou lire un cookie, les éditeurs de sites ou d’applications doivent :
> - informer les internautes de la finalité des cookies,
> - obtenir leur consentement,
> - fournir aux internautes un moyen de les refuser.
> 
> [...] Le manquement à l’une de ces obligations peut être sanctionné jusqu’à un an d'emprisonnement, 75 000 € d’amende pour les personnes physiques et 375 000 € pour les personnes morales. - [service-public.fr](https://www.service-public.fr/professionnels-entreprises/vosdroits/F31228)

Dans la pratique, si vous éditez votre petit weblog dans votre coin, il y a fort à parier que vous écoperez simplement d’un rappel à l’ordre si jamais la CNIL venait à constater une infraction.

Mais est ce bien nécessaire d’en arriver là ? Autant se mettre en conformité tout de suite...

## Mentions légales d’un site web

Que vous éditiez un blog, un site professionnel ou un site de commerce en ligne, vous devrez dans **tous les cas** remplir une page de mentions légales avec des informations sur vous. Au minimum vos noms, prénoms, adresse, numéro de téléphone. Oui c’est désagréable mais c’est comme ça...

S’ajoute à cela des informations sur votre hébergeur.

Et en fonction des cas vous aurez beaucoup plus d’informations à remplir, comme des informations sur votre entreprise si c’est un site commercial, des CGV, voire même un numéro de déclaration du site à la CNIL.

Si jamais vous cherchez un peu de lecture sur le sujet, du plus accessible au plus dense/technique :


* une notice user-friendly -- [wbcreation.fr/bien-rediger-ses-mentions-legales.html (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20170810000301/https://wbcreation.fr/bien-rediger-ses-mentions-legales.html)
* une meilleure explication du pourquoi et du comment de chaque obligation -- [www.journaldunet.com/ebusiness/le-net/mentions-legales-site.shtml](http://www.journaldunet.com/ebusiness/le-net/mentions-legales-site.shtml)
* information officielle, la plus complète et relativement concise -- [www.service-public.fr/professionnels-entreprises/vosdroits/F31228](https://www.service-public.fr/professionnels-entreprises/vosdroits/F31228)
* arrêtez tout : [j’ai trouvé (via un partage sur Twitter) un générateur de mentions légales !!!](https://www.subdelirium.com/generateur-de-mentions-legales/)


## Déclaration CNIL du site

Selon le type de site que vous éditez, les règles légales ne sont pas les mêmes, on l’a bien vu. Le cas de la déclaration du site web pour agrément de la CNIL en fait partie. Dans le cas où vous n’enregistreriez rien du tout sur les utilisateurs qui se connectent à votre site, vous n’avez pas besoin de déclarer quoique ce soit à la CNIL. Si à l’inverse, vous disposez d’informations des utilisateurs de votre site (notamment pour une boutique en ligne), dans ce cas là, voici les différents type de déclarations que vous devez effectuer en fonction des informations collectées.

> **La déclaration simplifiée :** elle est nécessaire dans le cas de collecte de données non sensibles et nécessaires à un fichier client.  
> **La déclaration normale :** celle-ci doit être réalisée si l’éditeur récupère des données professionnelles sur un internaute, qu’il s’agisse de son CV ou de sa scolarité.  
> **La demande d’autorisation :** elle intervient en cas de collecte de données dites sensibles comme son appartenance politique, religieuse ou encore son orientation sexuelle. - Journal du net

Reste pour moi un cas flou pour lequel je ne sais dire avec certitude s’il faut déclarer le site ou non : le blog.

Dans le cas d’un blog wordpress pour citer mon cas, j’ai une base de données qui contient des informations de consultation des pages qui me donne une répartition des visites par pays. Cela signifie donc qu’à un moment donné, des informations (type IP, voire langue du browser) ont été collectées sans que je ne fasse rien.

Idem pour les commentaires. L’adresse IP et éventuellement l’adresse email des utilisateurs qui souhaitent bien la renseigner est enregistrée dans ma base de données. Toutes ces données sont des données qui pourraient potentiellement intéresser la CNIL. Pour autant, dois-je déclarer le blog ?

WB Création donne quelques clés supplémentaires sur le sujet mais pas de réponse claire à mon sens :

* [lien mort, j'utilise Internet Archive](https://web.archive.org/web/20161105121710/http://wbcreation.fr/declaration-site-internet-cnil.html)

## Message indiquant l’utilisation de cookies sur le site

Parlons maintenant des **cookies**. Vous n’en avez probablement même pas conscience, mais des cookies sont très probablement déposés sur les périphériques de vos visiteurs . Pour ne citez qu’eux _Google Analytics_, _Adsense_, les boutons « réseaux sociaux » ou tout autre module complémentaire de ce style déposent des cookies. Et voilà ce qu’en [pense la CNIL](http://www.cnil.fr/vos-obligations/sites-web-cookies-et-autres-traceurs/) :

> La loi impose désormais aux responsables de sites et aux fournisseurs de solutions d’informer les internautes et de recueillir leur consentement avant l’insertion de cookies ou autres traceurs. - CNIL

C’est clair : c’est à vous de trouver un moyen de bloquer l’utilisation des cookies sur votre site si l’utilisateur ne l’a pas accepté.

La CNIL donne quelques exemples et même des scripts si jamais vous hébergez votre site vous même, mais le plus simple dans mon cas (j’utilise WordPress) c’est bien entendu d’installer une extension qui fera le travail pour vous.

Comme plusieurs blogs l’ont conseillés, j’ai téléchargé l’extension [Cookie Notice](https://wordpress.org/plugins/cookie-notice/) pour la gestion automatiques de mes Cookies sur le blog (aussi parce que c’est la plus téléchargée).

![](/2015/11/cookies2.png)

> Le message est sobre, discret et efficace, en footer de la page

Les options sont simples mais néanmoins utiles car vous pouvez modifier certains paramètres. J’ai notamment coché l’option permettant de valider automatiquement le message dans le cas où l’utilisateur scrolle vers le bas. Ça permet aux utilisateurs qui ont la flemme de cliquer de ne pas s’offusquer de cette barre en bas de leur écran (mon cas ;-) ).

Par défaut, **Cookie Notice** ne met pas de bouton refuser. Je l’ai aussi ajouté pour être sûr de ne pas avoir de problèmes même si le message « Si vous continuez à utiliser ce dernier, nous considérons ... » est probablement suffisant.

Si vous voulez plus d’informations sur les cas qui disposent de message, vous pouvez allez voir [cet article un peu plus détaillé](http://wpformation.com/wordpress-loi-cookies/) sur le sujet sur wpformation.com.

Voilà; vous savez tout !

