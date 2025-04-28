---
title: 'Devoxx France 2022 - Récap du jour 3'
authors:
  - zwindler
type: post
date: 2022-04-22T17:00:00+00:00
excerpt: Je suis à Devoxx France 2022 et je fais un récapitulatif de cette dernière journée de conférence
url: /2022/04/22/devoxx-2022-recap-jour-3/
image: /2022/04/devoxx_jour3.jpeg
categories:
  - Conférence
tags:
  - Devoxx 2022
  - Devoxx 

---

## Vendredi, dernier jour !

Les résumés des 3 jours de DevoxxFR 2022

* [Mercredi](https://blog.zwindler.fr/2022/04/20/devoxx-2022-recap-jour-1/)
* [Jeudi](https://blog.zwindler.fr/2022/04/21/devoxx-2022-recap-jour-1/)
* [Vendredi](https://blog.zwindler.fr/2022/04/22/devoxx-2022-recap-jour-3/)

Aujourd'hui, j'ai décidé que ça serait chill et que je prendrais mon temps. Évidemment, ça n'a pas été le cas 🙃, car vous allez voir que j'avais beaucoup de copains à aller voir.

## Futurospective digitale : le futur est-il encore ce qu’il était ?

> On a rêvé de voitures volantes, on a 140 caractères.

Ludovic CINQUIN, CEO d'Octo, a joué à la boule de cristal et tenté de prédire les tendances tech de l'avenir.

Il nous a fait un, je cite, "*mégatrends du digital*" avec comme axe les "*potentiels de disruption*" et la probabilité de réalisation.

![](/2022/04/megatrend.jpeg)

On va pas se mentir, c'est un peu bingo buzzword cette slide, hein ? ;-)

Ensuite, il a essayé de poursuivre 3 scenarios plausibles selon lui, en se basant sur ce qui est déjà arrivé :
* World tech company
  * Quelques entreprises avec un écosystème qui va subvenir à vos besoins
  * ex. aujourd'hui Apple à un CA équivalent au PNB de Singapour
  * Tensions entre ces sociétés et les états
* Digital Cold War
  * Internet passe d'un espace de liberté à un espace de domination économique
  * Première cyberguerre mondiale imminente
  * La Chine a plus d'ingénieurs, plus de data, pas de restriction pour la capturer, donc a l'avantage
* Digital detox
  * Intermittence dans l'énergie
  * Avoir des ordinateurs, c'est (de plus en plus) compliqué
  * Le offline revient en force

Après le #SlowTech d'hier, nouveau concept, on a droit au #RightTech
* respect de l'objet
* respect de l'usage
* respect de l'environnement
* respect de l'humain

## LesBonsclics, une plateforme pédagogique au service du 1er réseau européen d'aidants numériques

Le talk suivant de Thomas VANDRIESSCHE était sur l'illectronisme et une des façons de le combattre.

Thomas commence par plusieurs constats alarmants :
- 38% des usagers manquent d'une compétence numérique essentielle
- 68% des Français déclarent rencontrer des difficultés dans leurs usages du numérique

Même au sein des 16-25, beaucoup ne savent plus utiliser correctement un ordinateur (le tout smartphone).

On constate aussi que précarité sociale va souvent de pair avec précarité numérique, ce qui est une double peine puisque les gens à l'aise avec le numérique ont souvent plus d'employabilité et profite de gains de pouvoir d'achat.

La crise COVID a été un déclencheur de beaucoup de transformation, notamment dans l'action sociale qui s'est numérisée et utilise l'outil numérique pour mieux aider les gens qui en ont besoin. Sauf que ces personnes sont souvent aussi précaires du numérique.

[WeTechCare](https://wetechcare.org) a donc créé un outil de numérique inclusif, [LesBonsClics](https://www.lesbonsclics.fr/fr/), pour fournir des ressources pour aider les professionnels de l'action sociale à mieux inclure ces publics au numérique.

WeTechCare a également créé un observatoire de l'inclusion numérique. Vraiment, de beaux projets.

## La quête d'une gouvernance collaborative du web

Dans cette dernière Keynote de cette édition de Devoxx, Lê Nguyên HOANG nous a parlé de [tournesol.app](https://tournesol.app/), un outil visant à créer une gouvernance collaborative, auditable, sécurisée des algorithmes.

Il a commencé par parler du problème. Aujourd'hui, les algorithmes de recommendations sur Internet sont opaques et parfois même dangereux pour les personnes.

L'histoire récente a montré que les algorithmes des bigtechs sont calibrés pour plus mettre en avant la désinformation et la haine. Les états utilisent les règles des algorithmes pour inciter à la violence, voire au génocide.

Pour essayer de changer les choses, tournesol.app permet, de manière collaborative, de faire de nouvelles recommendations, de manière plus transparente.

## React dans tous ses états

Je suis allé voir le talk suivant d'une ancienne collègue, Amélie BENOIT, mais je n'ai pas forcément bien toutes les compétences "front" pour comprendre toutes les implications. Mes excuses par avances pour d'éventuelles imprécisions.

Amélie a commencé par définir ce qu'est un état et les différents types d'états dans une application React.

Ce qu'a ensuite expliqué Amélie, c'est que le "state" a besoin d'être dans le composant qui le nécessite, ou, à défaut, dans un composant parent quand il a besoin d'être partagé. On se retrouve donc souvent avec des composants parents gavés des states des enfants, ce qui pose plein de problèmes.

Avant qu'il n'existe des alternatives, les gens ont créé des microframeworks au dessus de React pour gérer le state dans des stores à part, mais ce n'est pas idéal.

Une des solutions réside dans Redux toolkit (anciennement redux starter kit), ainsi que Recoil.

![](/2022/04/react.jpeg)

Bon, je ne vais pas mentir : j'ai pas tout compris mais clairement dans les exemples qu'Amélie nous a montré, dans redux toolkit, la code a l'air mieux que redux tout court ;) et Recoil ça a l'air encore mieux. 

## Doctolib a besoin d'une base de données plus puissante. Ok, mais laquelle?

Grosse conférence, en amphi bleu, qui était par ailleurs bien rempli. Ce talk était donné par Bertrand PAQUET (SRE lead) et David GAGEOT.

Le maitre mot, chez Doctolib, est la "Boring architecture". Les composants techniques sont choisis pour leur coût au build, mais aussi au run.

En temps normal, leur unique cluster de bases de données PostgreSQL (historiquement sur Heroku, puis sur des instances EC2 et enfin sur Aurora) leur suffisait amplement pour tenir la charge.

![](/2022/04/docto_1.jpeg)

La campagne de vaccination COVID a complètement rebattu les cartes et les équipes SREs et devs de Doctolib ont dû trouver des solutions plus pérennes. Grosso modo, ça se limite à 2 scenarii :
* Une plus grosse DB en écriture
* Découper la DB

Pas de bol, Doctolib utilise déjà les plus grosses instances disponibles sur Aurora. Une migration a donc été envisagée, parmi :
* Spanner
* Yugabyte
* Citus MX
* Vitess

Sans spoiler le talk, la totalité des candidats cités plus hauts étaient bons, mais pas suffisamment pour que Doctolib puisse l'envisager sereinement.

"La mort dans l'âme", les équipes de Doctolib se sont donc résolue à splitter la DB, mais d'une manière qu'ils n'avaient pas imaginée initialement (via des foreign data wrappers).

![](/2022/04/docto_2.jpeg)

## Record du monde - Tour d’horizon et cas d’utilisation des records

Encore un talk d'un ex-collègue, Benoît PRIOUX !

Benoit a un background solide de Javaiste et il a voulu nous parler de cette nouvelle fonctionnalité que sont les "records", maintenant GA en Java 17, la façon de les utiliser et quelques conseils.

Globalement, il s'agit d'avoir en une ligne, une classe avec un constructeur, des attributs immutables, des méthodes pratiques comme tostring, equals, hashcode, implémentées par défaut.

Benoit a ensuite montré d'autres manières de le faire, en Java ou dans d'autres langages, en quoi ça pouvait bien servir (DDD, primitive obsession, quasi monoid), ainsi que quelques conseils.

Et... J'ai tout compris :D

## Qu'avons-nous appris après un an passé à développer des opérateurs Kubernetes ?

Etienne COUTAUD (un copain Bordelais, organisateur du CNCF meetup de Bordeaux) raconte par où ils sont passés chez Artifakt pour fournir à leur client un PaaS multicloud en développant des opérateurs Kubernetes.

Ils avaient déjà un front et un back, mais pour éviter de faire grossir inutilement ce dernier en ajoutant toujours plus de code pour gérer les interactions avec les cloud providers, ils ont décidé d'ajouter un composant "plateforme" dont c'est le but.

Pour ce faire, ils ont créé des opérateurs et des CRDs pour chacun des composants dont ont besoin leurs clients.

![](/2022/04/operator.jpeg)

Etienne a pris le temps de bien nous expliquer tous les concepts, puis de nous donner des conseils, si nous aussi nous souhaitons nous lancer dans l'expérience :
* Prendre le temps de définir sa CRD avec le métier
* Bien typer et indiquer les champs obligatoires, etc
* Utiliser un framework pour faciliter le développement de l'opérateur (shell-operator, kubebuilder, kopf, KUDO, etc).

Il a ensuite expliqué l'intérêt des **ValidatinWebhook** et des **MutatingWebhook** dans le cadre du développement d'opérateurs Kubernetes.

## Pourquoi DevOps ne tient pas ses promesses ?

J'ai terminé DevoxxFR sur ce talk de mon ancien camarade de promo et ami Gérôme EGRON et son collègue Guillaume MATHIEU, qui nous ont parlé de Devops avec ce titre un brin provocateur ;-p.

![](/2022/04/devops.jpeg)

J'ai bien aimé et j'ai retrouvé quelques similitudes avec mon talk "SREs ! SREs partout", mais du point de vue des développeurs. 

C'était très amusant de voir qu'on dit la même chose, au final, même si on est historiquement pas du même côté du "mur de la confusion".

Ce qui m'a le plus plu, c'est quand ils ont dit qu'une des raisons pour lesquelles le DevOps ne marchait pas était parce que :

> Quand on fait du DevOps, on fait souvent de l'outillage et pas de la culture

100% d'accord !

## Retour à Bordeaux

MERCI MERCI MERCI LES ORGAS !

![](/2022/04/keynote_jour3.jpeg)

Je rentre des paillettes dans les yeux (aïe, ça pique).
