---
title: Ça bouge pas mal sur le blog !
authors:
  - zwindler
type: post
date: 2019-12-24T09:00:00+00:00
excerpt: Performance, vie privée, trackers, soutient, ça a pas mal bougé sur le blog !
url: /2019/12/24/ca-bouge-pas-mal-sur-le-blog/
image: /2019/12/nyanonimous_rond_850x550.png
categories:
  - Divers
tags:
  - blog
  - financement
  - vie privée

---

D’habitude, j’attends un chiffre rond pour faire un article "récap" sur le blog. C’est d’ailleurs ce que j’avais fait pour le 100ème article, le 200ème et le 250ème article :
  
* [100ème article ! 5 ans de « Zwindler’s Reflection »](/2015/10/27/100eme-article-5-ans-de-zwindlers-reflection/)
* [200ème article : Comment je suis passé de 300 à 10000 vues par mois sur le blog](/2017/11/07/200eme-passer-de-300-a-10000-vues-par-mois/)
* [250ème article : un peu plus d’un an, de 10000 à 20000](/2019/02/27/250eme-article-un-peu-plus-dun-an-de-10000-a-20000/)
      
  
Mais je n’avais pas envie d’attendre les 10 ans pour parler des changements nombreux (et plus si récents) qui ont eu lieux sur le blog ces derniers mois.

## Performance

D’abord, je l’avais dis lors de l’article du 250ème article, j’ai fait un gros travail sur la performance.

Et il y avait du boulot. Même avec du cache, certaines pages s’affichaient en plus de 5 secondes (réduit à 3 en enlevant des plugins inutiles). Totalement inacceptable pour le rendu de texte et d’images !

À l’époque, je pensais que la solution viendrait d’un moteur de blog statique (Hugo notamment, j’avais fait un test de migration, [toujours dispo ici](/recherche/?keyword=hugo)). Mais je n’ai jamais réussi à sauter le pas du tout statique.

WordPress a ses défauts mais a quand même l’avantage d’apporter toutes les features que vous voulez (c’est une partie du problème _en même temps_).

En fait, le problème majeur de perf de mon install venait... de la stack que j’avais choisi. En remplaçant simplement Apache et le vieux PHP par nginx/fpm et un PHP à jour, je suis passé de 3 à 1s d’affichage, ce qui me parait bien plus acceptable !

## Vie privée sur le blog

Là, on arrive dans le gros du travail des derniers mois.

### echo "Google Analytics" | sed "s/Google/Matomo/"
  
Lors de [l’article du 250ème](/2019/02/27/250eme-article-un-peu-plus-dun-an-de-10000-a-20000/), j’avais également annoncé que j’allais réfléchir à comment être plus respectueux de la vie privée de mes lecteurs. C’est un choix militant, que j’assume.

La première étape (la plus simple) a été de supprimer Google Analytics. En vrai, j’utilisais assez peu Analytics, n’étant pas du tout aguerri dans le SEO. Pour garder un peu de stats, j’avais quand même en amont bossé sur Matomo (ex-Piwik).

Ce soft est excellent, et, à mon faible niveau, remplace en tout point un Google Analytics, à ceci près qu’il vous respecte, vous et votre vie privée.

Les données sont anonymisées par défaut, les utilisateurs ont une plus grande latitude sur les options pour ne pas être tracés, etc. Je n’ai pas encore tout paramétré mais ça me plait beaucoup plus que ces infos ne soient pas bêtement fournies à Google.

Fun fact : quasiment du jour au lendemain, mon nombre de visiteur a chuté de 20k+ à 15k pages vues mensuellement. Quelle part de coïncidence et/ou de trafic de bots mal comptés par WordPress expliquent cette chute, je ne saurai le dire. Je suis probablement parano...

### AMP
  
La deuxième chose que j’ai faite a été de dégager AMP (Google Accelerated Mobile Pages), qui n’est en fait qu’un rendu statique et épuré pour le mobile.

En gros, quand vous postez un lien sur un réseau social, souvent c’est AMP qui prend le relais et _CDN-ise_ vos pages pour les mobiles.

La plupart du temps, c’est relativement transparent, mais on m’a remonté à plusieurs reprises que le rendu était pourri (la faute à des plugins mal pris en charge par AMP).

Pourquoi les gens le mettent tous alors ? La réponse est similaire à la précédente :

> Une meilleure visibilité sur les pages de résultats de Google
  
Google l’a dit ouvertement dans ce cas précis. Les sites qui ont activé AMP auront une meilleure place dans les résultats Google pour mobile.

OSEF. Aucune raison que je laisse ce truc qui marche mal sur mon site et qui donne mon trafic (et vos données) à Google.

### Mailchimp

Pour gérer de manière un peu plus sexy la newsletter (et avoir des stats et un peu plus de contrôle sur les envois d'emails), j’ai utilisé le service tiers MailChimp. C’était cool mais là encore, pour des problématiques de trackers, j’ai préféré dégager la popup JS.

De toute façon, la newsletter est très peu active (quasiment plus de nouveaux inscris, alors que le flux RSS croit tout seul sans même que je ne le mette en avant...).

Reste encore un CSS que je dois tuner pour le dégager complètement mais ça devrait déjà être mieux en terme de privacy.



### Google Adwords (et Amazon Partenaires)
  
  
Le plus gros des trackers (après Analytics), c’est la pub.

Décision radicale, j’ai donc supprimé totalement mon compte Google Adwords. Les liens vers Amazon devraient suivre dans les semaines qui viennent (mais ça ne concerne que quelques articles de toute façon).

Ça fait nécessairement un peu mal au budget annuel hosting serveurs physiques (qui était pour moitié absorbé par la pub). Mais là encore, c’est un choix militant.

Le 2ème effet positif de ce choix a été de réduire significativement les temps de chargement des pages (ainsi que le nombre de domaines tiers appelés) ! Grosso modo, sur les pages avec peu d’images, on passe de 1s à quelques 300-400 ms.

Champagne ! (enfin, plutôt mousseux vu le budget du blog).

### Boutons de partage

Plusieurs news récentes ont confirmés que les boutons de partages de réseau sociaux rentraient bien dans le cadre du traitement des données de tiers pour le RGPD (responsabilité conjointe du gestionnaire du site).

Vous savez, ces petits boutons pour partager facilement sur vos RS préférés et qui comptent le nombre de likes.

Pour me mettre en conformité, j’ai donc supprimé tous les boutons de partages fournis par WordPress. Tout simplement.

[Edit]Merci Seboss666 pour l’astuce du code HTML tout bête, ça marche nickel. Les icônes sont crados, je ferai joli après la vacances[/Edit]

### WordPress
  
Et oui ! WordPress est lui même un bon gros tracker. J’ai commencé par supprimer les liens courts de type wp.me (easy). Mais après, c’est plus dur...

Pour Jetpack et Gravatar, je vois encore mal comment je pourrais m’en passer. Pour ce qui est de Gravatar, il est très intégré à WordPress et Jetpack. Et Jetpack, il me fourni mon "bloc" pour écrire les articles en Markdown et Akismet, l’anti-spam des commentaires.

Retirer ces deux dernières fonctionnalités n’est pas envisageable une seule seconde et il faut que je trouve comment garder ces deux fonctions facilement (c’est à dire sans tout réécrire) avant de pouvoir désactiver Jetpack et Gravatar. Mais j’y travaille !

## Les nouveautés

J’ai testé un nouveau thème, assez similaire au précédent, à ceci près qu’il :
  
* gère nativement un colonne de contenu plus large, avec du texte plus gros
* n’utilise pas les Google fonts (encore un tracker !)
* mais est un peu moins sexy, surtout la page de garde (dommage)

J’ai également volontairement ajouté un widget (donc un potentiel tracker) vers [StatusCake](https://www.statuscake.com/), un site web avec un _free tier_ qui me permet de savoir quand mon site ou un de mes serveurs est down. Je trouve ça rigolo et vu comment ils sont petits je ne pense pas qu’ils vendent vos données. On verra.

## Les perspectives pour le blog
  
  
On est pas ISO-fonctionnalité par rapport à avant le ménage, mais je pense que c’est pour le mieux. Les google fonts et AMP n’apportent rien. La mailing list est toujours là (mais il n’y a plus la pop-up) et les icônes de partage ont été remplacées par du HTML "sans tracker".

Pour ce qui est de l’acquisition de nouveaux lecteurs, je compte beaucoup plus sur le trafic apporté par la communauté Twitter/Masto (merci le Journal du Hacker) et LinkedIn (j’y suis assez actif), qui sont beaucoup plus souvent réellement intéressé par le contenu, plutôt qu’une recherche Google qui au final est refermée aussitôt.

## Soutenir le blog

Vous l’avez compris, pour écrire les articles, j’ai besoin de serveurs (et notamment de machines physiques pour faire tourner des hyperviseurs et des softs qui demandent beaucoup de RAM) et ça c’est pas gratuit. Mais j’ai aussi besoin de motivation.

Je sais que certains d’entre vous aimeraient me soutenir dans ma démarche de partage de connaissance. Il y a plusieurs moyens de le faire :
  
* D’abord, commentez mes posts, que ce soit pour donner un avis (positif ou négatif), des informations complémentaires (je ne suis pas experts dans tous les sujets, loin de là). C’est ultra motivant de pouvoir échanger avec vous.
* Ensuite, n’hésitez pas à le partager si vous l’aimez.
* De plus, si vous voulez vous lancer dans l’aventure du blogging mais que vous avez peur que ça vous prenne trop de temps, je le redis : j’héberge volontiers (en votre nom) des articles d’autres personnes. C’est déjà le cas pour M4vr0x et ventrachoux85.
* Enfin, si vous voulez (je sais que ça arrive) me soutenir financièrement, j’ai mis en place deux moyens de paiements.
      
  
Pour un don ponctuel et "simple", j’ai un compte Paypal séparé pour le blog qui existe depuis quelques années et que vous pouvez utiliser.

Et plus récemment, j’ai ouvert [un compte Tipeee](https://fr.tipeee.com/le-blog-de-zwindler/).

![](/2019/12/tip.png)

* [fr.tipeee.com/le-blog-de-zwindler/](https://fr.tipeee.com/le-blog-de-zwindler/)


Tipeee est un service en ligne qui est surtout utilisé par les vidéastes et autres créateurs, qui ont de plus en plus de mal à monétiser leur création à cause de appétit toujours grandissant des plateformes (ou des ayants-droits c’est selon).
  
Je ne suis pas le seul à faire ça au sein de la communauté blog IT puisque l’ami [Genma le fait déjà depuis des années ;-)](https://fr.tipeee.com/genma). Donc si l’envie vous en dit, ça sera avec grand plaisir (tout est expliqué sur le lien du Tipeee).

 [1]: https://app.statuscake.com/button/index.php?Track=3582085&Days=30&Design=1
