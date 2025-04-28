---
title: Ça bouge encore sur le blog
authors:
  - zwindler
type: post
date: 2025-01-15T20:00:00+02:00
excerpt: "Creative Commons, IA manifesto, hosting, liens morts"
url: /2025/01/15/ca-bouge-encore-sur-le-blog/
image: /2019/12/nyanonimous_rond_850x550.png
categories:
  - Divers
tags:
  - blog
  - ai manifesto
  - creative commons
  - cc by-sa 4.0
  - vie privée

---

À la toute fin 2019 (il y a cinq ans à 2 semaines près donc, c'est marrant comme j'ai une façon cyclique dans mon écriture), j'écrivais un long article pour détailler les nombreux (à l'époque) changements opérés sur le blog.

* [Ça bouge pas mal sur le blog !](/2019/12/24/ca-bouge-pas-mal-sur-le-blog/)

Les plus gros d'entre eux étant la suppression de toute forme de tracking intrusif, en particulier ceux des boites comme Google (AMP, Analytics, Adwords), Amazon (liens sponsorisés) et le début d'un virage vers l'abandon de Wordpress (qui m'aura finalement nécessité quelques années de plus pour être totalement terminé, on en reparlera).

## Creative Commons (CC BY-SA 4.0)

> Je passe tout le contenu qui m'appartient sur ce blog sous licence Creative Commons

Voilà la décision aussi militante que radicale que j'ai prise le 3 octobre dernier, suite à un énième vol de propriété intellectuelle entre bloggers et le drama qui en a suivi :

* [Le contenu du blog passe en Creative Commons CC BY-SA 4.0](/2024/10/03/blog-creative-commons)

Rétrospectivement, je me demande vraiment pourquoi j'ai attendu aussi longtemps pour le faire, car cette décision colle parfaitement à ma philosophie de vie depuis plusieurs années.

Ce n'est peut-être pas le cas de tout le monde (c'est leur droit), mais ce site n'existe pas pour me faire gagner de l'argent.

Je n'ai aucune raison de le monétiser, quelle qu'en soit la forme. 

**Son but unique est le partage de connaissance**. Et je n'ai pas la prétention d'être le meilleur ou de connaitre la meilleure façon de diffuser cette connaissance.

TL;DR : vous pouvez donc **copier, améliorer, redistribuer tout ou partie de ce blog, et même tirer directement ou indirectement des revenus**, tant que je suis cité quelque part comme l'auteur initial. Ça me fait plaisir si vous en profitez. Enjoy.

## Pas d'IA

J'ai adhéré au AI manifesto, popularisé par [Cassidy Williams / cassidoo](https://bsky.app/profile/cassidoo.co).

> Je pars du principe que si je ne prends pas la peine d'écrire moi-même le contenu de ce blog, vous ne devriez pas prendre la peine de le lire.

Je sais que **cette décision est un plus clivante** que le passage du blog en CC BY-SA 4.0, et que plusieurs personnes dans ma sphère tech sont en opposition avec ce principe. Là aussi, c'est leur droit. 

Moi, j'adhère totalement à cette vision.

Aucun de mes articles n'est écrit par l'IA. Ils ne sont même pas relus par des IAs pour les "améliorer". 

Note pour plus tard, je vais aussi essayer également de ne plus générer de visuels avec l'IA pour des problématiques de propriété intellectuelle.

## Fin de la migration Wordpress vers Hugo et ménage dans les liens morts

Lorsque j'avais entamé la migration Wordpress vers Hugo en 2020, je n'avais pas nettoyé tout le code qui avait été importé de Wordpress. Pas mal d'images restaient dans un format bâtard non-markdown, avec des balides HTML chelous.

De la même manière, ça doit faire plus de 10 ans que je n'ai pas fait une passe sur mon site pour nettoyer les liens morts derrière mois.

Comme je suis quelqu'un d'un peu têtu/bourrin, je me suis mis en tête qu'il était temps de finaliser cette migration, que j'ai quasiment faite d'une traite (je n'ai écrit que 2 articles entre le début et la fin). Quelques exemples :

![](/2025/01/html-to-markdown.png)

![](/2025/01/lien-mort.png)

Même à coup de regex et de tooling python pour automatiser le plus possible, cette énorme passe de nettoyage a duré plusieurs sessions de blogging, étalées sur plusieurs semaines (probablement 10 heures de travail). Quelques stats pour vous donner une idée :

* 360 fichiers modifiés (sur un peu moins de 500 articles)
* 3600 lignes modifiées
* plus de 200 liens morts
* plus de 120 contenus retrouvés (souvent manuellement) sur Internet Archive

Je ne remercie pas du tout HPe, VMware, Dell EMC, Microsoft, d'avoir supprimé la totalité des ressources sur lesquelle j'ai bloggé dans les années 2015 et +. Toutes les docs, les forums, les KBs, les fichiers de configuration ont été annihilés. Si une partie de ces contenus étaient effectivement obsolètes, ce n'était pas le cas de tous.

Je ne remercie pas non plus les boites comme Oracle, SAP ou autre qui ont racheté de plus petites entités et détruit des billets de blogs corporate pourtant toujours utiles aujourd'hui et que je n'ai pas toujours pu retrouver sur Internet Archive, malheureusement.

Je ne remercie toujours pas les entreprises ou les logiciels open source tels que Ansible, pfSense ou encore XWiki (que j'apprécie par ailleurs) qui ont décidé un jour de changer l'arborescence de leur site / leur documentation officielle sans mettre en place de redirection correcte...

Enfin, j'ai pu constater avec tristesse que de très nombreux blogs de petites entreprises ou de particulier, dont certains que j'aimais beaucoup, avaient disparu d'Internet sans laisser de traces... Souvent autour de 2020... J'espère ne pas y voir un signe lugubre 😔.

## Au revoir, Clever Cloud

Depuis que j'ai migré de Wordpress à Hugo (changement que je bénis chaque jour... que c'était horrible ce CMS de la mort), j'ai un peu hésité sur le provider pour héberger le blog statique (et l'infra pour le construire). 

J'ai fait de l'auto-hébergé, [vercel](https://vercel.com/), [froggit (gitlab runners + gitlab pages)](https://froggit.fr/), de l'auto-hébergé encore. Puis finalement, pour tester le produit des copains, j'ai essayé [Clever Cloud](https://www.clever-cloud.com/fr/).

* [Migration du blog sur Clever Cloud](/2023/12/30/its-migration-day-again)

Au début, j'étais plutôt content, et [j'ai même fait quelques articles](https://blog.zwindler.fr/recherche/?keyword=clever+cloud) de plus pour améliorer mon expérience (sur les conseils avisés de David). Mais au fil des mois, je me suis rendu compte que l'expérience utilisateur n'y était pas.

Pousser un commit sur un remote git spécial pour mettre à jour mon blog, ou alors trigger une github action au commit, qui lance la CLI avec un token, qui relance un build, ce n'est pas dingue. 

Et avoir une facture entre 7 et 8€ par mois (que j'aurais pu optimiser un peu, certes) pour ne pas avoir de compatibilité IPv6 ([une régression par rapport à mon site auto-hébergé en 2021](https://blog.zwindler.fr/2021/03/01/le-blog-en-ipv6-ca-aurait-du-etre-simple-et-pourtant/)), et autant de configuration manuelle et de "moving parts" pouvant planter à chaque commit, ce n'était vraiment pas pour moi.

Le dernier mois, j'ai eu de nombreux plantages, que ce soit la partie Github action, la partie build qui ne rendait pas la main, ou la partie Run qui ne se lançait pas correctement, ce qui laissait mes commits errer dans les limbes (et le compteur de temps d'instance M qui va avec).

![](/2025/01/clever.png)

Je ne pense pas qu'admettre que le produit n'était pas pour moi ne remette d'aucune façon en question la qualité de ce qui est fait chez Clever en tant que PaaS. Mais il était grand temps de repartir sur un setup plus simple à base d'auto-hébergement, que j'avais heureusement documenté (sur ce blog, ahahah) et que j'ai remonté en moins d'une soirée :

* [Automatiser son site Hugo sans Github Action ou Vercel](https://blog.zwindler.fr/2023/08/01/automatiser-hugo-sans-github-action/)

Ce blog est donc hébergé sur une VM ultra cheap à 1,20€ par mois chez IONOS, se rebuild en moins d'une minute à chaque commit via un webhook et est compatible IPv6 sans effort.

![](/2025/01/ipv6.png)

À ce prix-là, je ne m'attends pas à un très bon support utilisateur en cas de problème. Mais en réalité, je n'ai pas de SLO à tenir et je peux migrer n'importe où en très peu de temps (la preuve avec les multiples migrations faites ces cinq dernières années).

## Analytics

Pour ne pas m'embêter avec le RGPD (et ne pas avoir de bandeau à mettre), et n'utilisant même pas 1% des capacités de Matomo, j'avais retiré toute forme d'analytics sur un coup de tête.

Sur les conseils de Pierre, j'ai quand même remis le minimum l'an dernier (j'ai un an tout pile d'historique maintenant) [goatcounter.com](https://www.goatcounter.com/), un site d'analytics gratuit qu'on peut auto-héberger ou utiliser gratuitement en SaaS.

C'est moche, mais ça marche. Et ça me permet de savoir les articles qui marchent le mieux, **comme ma fameuse recette des pancakes à la banane sans PLV** (j'en parlais dans l'article [Dans le rétro de 2024 : trop de side projects](/2024/12/31/dans-le-retro-2024))

![](/2025/01/goat.png)

Et comme c'est un peu moche et que je suis [les aventures de Hugo Lassiège](https://eventuallycoding.com/) avec attention, je teste aussi en paralèlle son tout dernier produit d'analytics spécial bloggers [BlogTally](https://blogtally.com/)

> L'objectif étant de faire un outil de web analytics mais dédié aux bloggers

Je vous en dirais plus quand j'aurai de quoi comparer par rapport à toutes les solutions que j'ai pu tester jusqu'à présent.