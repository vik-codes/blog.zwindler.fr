---
title: 'La rentrée 2020 du blog : pas mal de changements, encore !!'
authors:
  - zwindler
type: post
date: 2020-09-14T06:05:00+00:00
excerpt: Retours sur les changements sur le blog de ces derniers mois, avec des améliorations techniques, la finalisation de la campagne de retrait des trackers, etc
url: /2020/09/14/2020-sur-le-blog-pas-mal-de-changements-encore/
image: /2017/11/blog.zwindler.fr_is_over_9000.jpg
categories:
  - Autohébergement
tags:
  - 2020
  - audimétrie
  - blog
  - cache
  - jetpack
  - nginx
  - trackers

---

## 2020, l’année du premier confinement (#trollface)
  
En décembre dernier, j’avais fais un petit recap’ de "mi-année" (d’habitude je le fais plutôt à l’anniversaire du blog) car beaucoup de choses [avaient été changées sur le blog](/2019/12/24/ca-bouge-pas-mal-sur-le-blog/). Notamment, j’avais fais un gros effort sur la vie privée, en retirant le plus de trackers possibles (Google Analytics, AMP, Mailchimp, Adwords) et un peu sur la perf.

Il restait du boulot mais vous allez voir, je n’ai pas chaumé ;-).

## Trackers et cookies
  
Dans l’article précédent, j’indiquais que j’avais retiré les boutons de partages (Facebook, Twitter, etc), car ils contenaient du code leakant des données privées. Seboss666 m’a fait remarquer en commentaire qu’il suffisait de copier les icônes et le code que lui utilisait (eux mêmes basés sur un tuto de Korben d’il y a perpet’), ce que j’ai partiellement fais. Les boutons de partages sont donc revenus, respectueux de votre vie privée :)

Un autre souci que j’avais était que j’utilise l’extension de WordPress Jetpack, qui aujourd’hui plein de features à WordPress dont certaines pas très très glop en terme de vie privée.

Notamment, des trackers (nécessaires pour bénéficier des statistiques des visites). Comme je suis passé sur Matomo, les statistiques de WordPress font double emploi mais j’ai mis du temps à trouver comment _désactiver uniquement les statistiques_ et pas le reste (j’utilise Akismet pour les spam en commentaire et Markdown pour la rédaction).

En réalité, les coquins (de chez WordPress) ont cachés l’option (qui était visible il y a 3 ans), mais elle est toujours disponible moyennant une petit bidouille, détaillée dans [ce topic sur le support de WordPress](https://wordpress.org/support/topic/disable-jetpack-stats-no-more-option/).

![](/2020/07/wordpress_stats.png)

Maintenant, WordPress ne collecte plus vos données quand vous visitez le site. Et ça c’est cool :)
Et enfin, j’ai changé l'email permettant de me contacter a propos du blog. Précédemment, le compte mail pour me contacter était en gmail. Pour plus de cohérence, j’ai migré le compte sur un compte protonmail (zwindl3r@protonmail.com), _a priori_ un peu plus respectueux sur la vie privée (enfin, c’est ce qu’ils disent)...

## Amélioration diverses
  
J’ai vu passer cet article de [y0no a propos des security.txt](https://y0no.fr/posts/decouverte-security-txt/). Pour faire simple, il s’agit d’un draft de RFC permettant aux hackers éthiques (ou simplement aux gens qui trouvent un trou de sécu béant dans votre site) de disposer des informations pour vous prévenir.

L’idée est tellement bonne et coûte tellement peu cher à mettre en place (un fichier texte de quelques lignes) que je vous invite très fortement à le mettre en place vous aussi :) !
  
J’ai refais une passe sur les mentions légales ([disponibles ici](/mentions-légales/)). Il s’agit d’un modèle généré via un site web ([subdelirium.com](https://www.subdelirium.com/generateur-de-mentions-legales/)) qui n’étaient plus tout à fait à jour.

Enfin, pour le lulz, j’ai voulu faire un test de PRA du blog. Car, oui, j’ai un plan de reprise d’activité pour mon blog perso, comme tous les admin systèmes tarés ;-p.

![](/2020/07/cavacouper.png)


Et bien sûr, comme tout test, ça a misérablement échoué car ma procédure de PRA n’était pas à jour. Après 30 minutes d’indispo, j’ai retrouvé les bonnes commandes... et j’ai rédigé un Post Mortem (dans un thread Twitter) !

![](/2020/07/postmortem.png)

## Performances
  
L’an dernier, j’avais fais un GROS travail pour améliorer les performances du blog. Certaines pages mettaient extrêmement longtemps à s’afficher, ce qui n’avait pas vraiment de sens. Après un gros travail de nettoyage des plugins, mise à jour de la stack technique et ajout de cache, j’avais réussi à descendre sous la seconde.

Histoire d’optimiser encore un peu plus, j’ai suivi quelques tutos dénichés ça et là :
  
  
* [Mise en place de la distribution des images au format wepb](https://www.abyssproject.net/2020/05/mettre-en-place-les-images-au-format-webp-sur-son-site-avec-nginx/) (merci Nicolas Simond)
* [Diverses astuces pour l’optimisation d’un WordPress](https://www.abyssproject.net/2020/06/diverses-astuces-pour-loptimisation-dun-wordpress/) (encore lui !)

Voici également quelques outils qui m’ont permis de savoir vers quoi concentrer mes efforts pour améliorer les performances générales :

* [GTmetrix](https://gtmetrix.com/)
* [Pagespeed](https://developers.google.com/speed/pagespeed/insights/)
* [Tools Pingdom](https://tools.pingdom.com/)

![](/2020/07/pingdom-1.png)

Je me suis concentré sur ces trois outils pour vraiment trouver les causes des problèmes de performances, mais vous pouvez en trouver d’autres (pour d’autres sujets) sur [ce billet qui en liste plein d’autres](https://lord.re/posts/124-site-outils-amelioration-sites/).

Et enfin, plutôt que de passer par une extension pour gérer le caching du blog, j’ai correctement configuré mon frontal nginx pour le faire :
  
* [A Guide to Caching with NGINX](https://www.nginx.com/blog/nginx-caching-guide/)
* [NGINX Content Caching](https://docs.nginx.com/nginx/admin-guide/content-cache/content-caching/)

## Audimétrie
  
Le blog a connu une TRÈS forte augmentation lors de la période de confinement en France, notamment car j’avais fait plusieurs articles sur la [mise en place de Jitsi pour la visioconférence](/2020/03/17/ta-visio-open-source-comme-un-pro-avec-jitsi/), avec un pic en avril à plus de 29000 vues, _sans compter_ les visiteurs qui ont activé l’entête DoNotTrack (entre 25 et 50% du trafic sur mon blog, soit plus de 50k).

![](/2020/07/traffic_matomo.png)

C’est assez colossal ; même si c’est un peu redescendu depuis (notamment cet été mais c’est tous les ans comme ça), autour de 20000-25000 vues par mois (~35000 si on ignore DNT), ça représente le double de trafic par rapport à l’an dernier, ce qui est complètement fou.

Cet été, vous avez été très nombreux à réagir à deux articles (dont un en deux parties), moins techniques :

* [Au secours, le métier d’Ops va disparaître !](/2020/07/29/au-secours-le-metier-dops-va-disparaitre/)
* [Mise en place d’une astreinte OPS - partie 1](/2020/08/17/mise-en-place-dune-astreinte-partie-1/)

J’essayerai de continuer à vous proposer, de temps en temps, ce genre de contenu, même si étonnamment ils réclament beaucoup plus d’efforts à rédiger.

## Conclusion

Je suis très touché par tous les retours que j’ai eu ces derniers mois alors une fois de plus, je vous remercie chaleureusement.

Sur ces mots, je vous souhaite une bonne rentrée et en attendant de se retrouver : **Have fun !**
