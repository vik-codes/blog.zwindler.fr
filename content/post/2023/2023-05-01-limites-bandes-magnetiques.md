---
title: 'Les limites des bandes magnétiques'
authors:
  - zwindler
type: post
date: 2023-05-01T16:00:00+02:00
url: /2023/05/01/limites-bandes-magnetiques/
image: /2023/05/LTO.jpg
categories:
  - Divers
tags:
  - LTO
  - Dataprotector
  - bandes magnétiques

---

## Pourquoi on parle de LTO aujourd'hui ?

Cet article fait suite à un thread de Nidouille à propos des bandes.

![](/2023/05/nidouille.png)

Loin de moi l'idée de catégoriser les bandes comme une techno du passé, au contraire. Mais j'ai envie que les gens qui n'en ont jamais manipulés soient conscients des limites.

Contexte : J'ai travaillé avec des lecteurs de bandes LTO 4 puis 5 de 2011 à 2016. Je travaillais pour une petite DSI, sur un site "industriel" avec environ 200 serveurs. On n'avait pas beaucoup de moyens mais nos salles serveurs étaient quand même réparties sur 2 sites distants.

On disposait même de deux dispositifs LTO (un dans chaque salle) avec chacun 2 lecteurs de bandes LTO 4 (HP) et 4 chargeurs de 12 cassettes (48 par appareil). Ce sont des appareils qui ont coûté assez cher (50k€ ? Plus ?) par rapport à notre budget et on a dû les garder un moment pour les rentabiliser.

J'ai ensuite travaillé plus tard avec d'autres sites équipés en LTO 5 (1 lecteur / 24 cassettes) et globalement les problèmes étaient similaires.

Note : je n'ai cependant travaillé qu'avec HP et [DataProtector](https://blog.zwindler.fr/recherche/?keyword=DataProtector), donc je ne sais pas dire si mes déboires étaient liés au constructeur ou pas.

## C'est beaucoup de manutention

On a des sauvegardes daily, des sauvegardes weekly et des sauvegardes monthly. L'utilitaire de sauvegarde DataProtector se charge de mettre les fichiers sur les bonnes bandes, pour peu qu'on ait préalablement correctement tagué à la main dans l'outil quelles bandes sont dédiées daily/weekly/monthly. Ça prend du temps.

Toutes les semaines, il faut donc aller relever les bandes qui sont sur les deux sites. Il faut choisir les bandes où sont stockés les weekly/monthly, aller les mettre au coffre et mettre d'autres bandes "vides" à la place.

On dirait pas comme ça, mais 10-20 bandes c'est assez lourd / encombrant à transporter sur des longues distances / dans des escaliers. C'est pas "difficile" mais clairement c'est pas quelque chose qu'on peut faire juste en les portant à la main.

Si vous êtes riches, vous avez un stock de bandes vierges. Si vous avez moins de moyens, il faut sélectionner les bandes "daily", les marquer comme expirées et les recycler.

Régulièrement, les bandes recyclées doivent être "nettoyées". On les sélectionne dans l'outil et on lui dit quelles bandes il doit nettoyer (pendant ce temps ça immobilise un lecteur bien entendu).

Les lecteurs aussi doivent être nettoyés, avec une bande spéciale. Heureusement là le logiciel le faisait tout seul (si vous avez un chargeur de 12/24 emplacements, ça vous fait juste perdre une place).

A force de changer de bandes, il arrivait que nos lecteurs se bloquent. La bande reste dedans et ne veut pas sortir. J'étais même parfois obligé de retourner en DC pour forcer l'éjection en façade.

Forcément, tout ce qui est mécanique, c'est des risques de pannes supplémentaires. Ca arrivait tellement souvent que c'est probablement le premier script de supervision centreon que j'ai écrit. Le support de chez HP n'a jamais été capable de nous réparer ça.

Toute cette manutention, c'est pénible.

# Quid de la vitesse d'écriture / restauration ?

Ça a forcément dû beaucoup s'améliorer depuis LTO 4, mais copier des tonnes de petits fichiers était un enfer. Et même en écriture sequencielle, on ne dépasse pas les 40 Mo/s avec l'appareil que j'avais.

Pour la restauration, même galère. Bon courage si vous devez restaurer table (même une petite) de votre ERP de plus d'un To en urgence avec une bande qui plafonne a 40 Mo/s. Le temps d'aller au coffre, de trouver la/les bonne(s) bande(s), de la mettre dans le lecteur, de restaurer le dump, de restaurer la table... On est au minimum sur 2h d'indisponibilité, même au pas de course.

Et là, je ne parle de gros fichiers et de lecture séquentielle, le meilleur scénario. Malheur à vous si vous avez des milliers de petits fichiers répartis sur plusieurs bandes à restaurer, car vous vous êtes fait cryptolock un serveur de fichiers (#trueStory).

Même les étiquettes "code barre", c'est pénible à utiliser. Les jeux d'étiquettes sont payés une fortune (100 euros pour quelques pages de stickers, ce racket). On a essayé de trouver comment en imprimer nous même mais ça n'a jamais très bien marché.

Attention à ne pas les mettre de travers. Si on a le malheur de les coller à l'envers (difficile de deviner quand on a le support vierge dans les mains) ça met le bazar dans le lecteur.

# La pérennité des bandes

Un des arguments de LTO est la pérennité des sauvegardes.

Le support est assez stable dans le temps et il est rare que j'aie été incapable de lire le contenu d'une bande. Mais c'est arrivé (probablement à cause du fait qu'on avait beaucoup de bandes recyclées).

Sauf qu'un lecteur LTO ne sait gérer que les sauvegardes jusqu'à 2 générations précédentes. Aujourd'hui, allez trouver des lecteurs capables de lire du LTO 4 dans l'urgence (DC brûlé par exemple, c'est de saison). Je dis pas que c'est impossible, mais vous allez suer à grosses gouttes (on en est au LTO 8 je crois, donc un lecteur neuf ne peut pas lire plus ancien que LTO 6).

La stratégie est donc de changer de lecteur au fil des générations (ça coûte cher !), d'aller régulièrement récupérer vos vieilles bandes, les lire (c'est très long, on en a parlé) et les recopier sur des bandes plus récentes. Pendant ce temps vos sauvegardes ne sont plus au coffre et donc plus sécurisées.

Dernier point, une LTO 4 c'est 800 Go. Compressé on mettait environ 2 fois plus. Grosso modo c'est 1 à 2 heures de lecture par bande. Multipliez ça par les dizaines de bandes que vous avez (on en avait au moins une centaine) et vous en avez pour quelques jours de fun (et d'immobilisation de vos lecteurs).

# Conclusion

Le problème principal dans mon usage dans la bande est que je n'avais à l'époque QUE la bande pour sauvegarder. Les sauvegardes sur disques étaient trop coûteuses et nous n'aurions pas pu nous le permettre.

Et c'est peut-être en ça qu'on pourrait dire que la bande est """une techno du passé""".

Oui, les bandes, c'est une super solution aujourd'hui pour garder dans le temps une ARCHIVE offline peu couteuse, "when all else fail".

Mais pour la SAUVEGARDE plus régulière, ce n'est plus du tout la panacée. Les bandes sont trop lentes à écrire/lire, trop pénibles à manutentionner, à moins d'avoir quelqu'un à temps plein pour s'en occuper. Pour de la gestion de sauvegarde / restauration au quotidien (hors incident majeur), la sauvegarde sur disques est un bien meilleur outil.

Je trouve d'ailleurs que ça annihile l'argument "la bande ce n'est pas cher pour la sauvegarde", puisque finalement, on doit avoir les deux pour gérer la sauvegarde récurrente ET l'archivage.

Beaucoup de petites DSI ne peuvent probablement pas se payer une sauvegarde sur disques de qualité ET un lecteur de bandes correct et choisiront par défaut l'un ou l'autre (probablement pour de mauvaises raisons).

Attention aux générations des LTOs, pensez à changer régulièrement de génération aussi bien pour vos lecteurs que vos supports, et partez du principe que certaines bandes seront illisibles (ça arrive).

Et enfin, attention aux problématiques RGPD et droit à l'oubli (ça a été cité dans le thread de Nidouille, il y a des solutions mais c'est non trivial).

Pour toutes ces problématiques, ça fait tout de suite beaucoup plus de sens pour un hébergeur type OVHCloud / Scaleway qui peut se permettre d'avoir un grand nombre de lecteurs et des équipes dédiées pour gérer ça de manière industrielle.

Bref, j'espère ne plus jamais avoir à gérer des lecteurs de bandes de toute ma vie.
