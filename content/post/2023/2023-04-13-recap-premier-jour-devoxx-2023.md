---
title: 'Devoxx France 2023 - Récap du jour 1'
authors:
  - zwindler
type: post
date: 2023-04-13T08:00:00+00:00
excerpt: Je suis à Devoxx France 2023 et je fais un récapitulatif de cette première journée de conférence
url: /2023/04/13/devoxx-2023-recap-jour-1/
image: /2023/02/devoxx_vangogh.jpg
categories:
  - conference
tags:
  - Kubernetes
  - Devoxx 2023
  - Devoxx 

---

Les résumés des 3 jours de DevoxxFR 2023

* [Mercredi](/2023/04/13/devoxx-2023-recap-jour-1/)
* [Jeudi](/2023/04/14/devoxx-2023-recap-jour-2/)
* [Vendredi](/2023/04/15/devoxx-2023-recap-jour-3/)

## Premier jour de DevoxxFR

Je suis vraiment très très fan de DevoxxFR et cette année, comme l'an dernier, j'ai la chance d'être speaker.

J'ai dû écourter mes vacances en Bretagne pour venir donc j'ai loupé la matinée

![](/2023/04/devoxxfr_train.jpg)

## Kubernetes, dépassionné et pour les ultra débutants

Sébastien BLANC, Horacio GONZALEZ et Sun TAN ont eu la lourde tâche d'expliquer Kubernetes "pour tout le monde".

On a parlé de YAML, de CRDs, de Limits/Requests pour les Deployments, ...

Il y avait beaucoup de démos et c'était très bon enfant, je pense que c'était une bonne entrée en la matière pour ceux qui ne connaissent pas encore mais qui voudraient vraiment comprendre l'utilisation.

J'avais forcément un peu peur que ce soit doublon avec mon talk mais au final pas du tout :\).

![](2023/04/kubernetes_debutants.jpg)

> Photo d'Horacio à l'état "sleep", le YAML pour le réveillé n'est pas encore appliqué

Ca m'a donné quelques idées pour la formation Kubernetes que je donne lors de l'onboarding des devs dans l'entreprise où je travaille. Merci à tous les trois :\).

## Comment être bien onboardée en tant que développeuse junior reconvertie ??

J'ai été voir ensuite le talk d'Amélie ABDALLAH. 

Elle même issue d'une reconversion suite à un burnout, Amélie nous a proposé de prendre du recul sur les profils issus de reconversion.

> Comment on en arrive à une reconversion ? 

![](/2023/04/onboarding_reconvertis.jpg)

On a rarement le contexte personnel des personnes, en général. On ne sait pas si la personne peut avoir des barrières en plus qui compliquent son parcours, en particulier dans le cadre d'une reconversion (temps pro/perso, argent, ...).

Alternante, elle a ensuite parlé de sa première entreprise, où elle a été "lâchée" dans la nature dès son premier jour, à coder : sans documentation, sans formation métier, pas de communication avec le client.

A l'inverse, elle a expliqué qu'à sa nouvelle entreprise (The Tribe), les profils reconvertis sont valorisés aussi pour leur expérience précédente, que chaque employé est formé, aussi bien techniquement que non techniquement, avant d'être considéré comme opérationnel.

Quelques autres pistes pour un onboarding (général) :
* café avec toutes les équipes
* rencontre avec un co-fondateur
* système de marrainage / parrainage
* rapport d'étonnement

Focus pour les profils reconversion :
* repository de mise à niveau technique
* sandbox sur les langages les plus utilisés dans l'entreprise
* mentoring / pair

## OPA, mais que fait la policy ? 👮

Même si je suis plutôt fan de Kyverno (cf [mes articles sur le sujet](/2022/08/01/vos-politiques-de-conformite-sur-kubernetes-avec-kyverno/)), j'avais envie de voir ce que je loupais avec OPA (depuis [mon test en 2020](/2020/07/20/vos-politiques-de-conformite-sur-kubernetes-avec-opa-et-gatekeeper/))

Jérôme GAUTHIER nous a d'abord présenté brièvement OPA (à prononcer oh-pa), un agent de politique.

Contrairement à Kyverno, OPA est un agent qui se connecte à des services (pas seulement Kubernetes donc). Il se veut générique, découplé, via un langage commun avec une bonne expérience dev et ops.

J'ai grincé pour cette dernière caractéristique... Cependant, quand Jérôme a détaillé ce qu'il voulait dire : on a de l'observabilité, l'outil est auditable, on a de la haute dispo, etc. et ça c'est vrai.

Pour le rego (que je n'aime pas), j'ai découvert qu'il existait un playground ([play.openpolicyagent.org](https://play.openpolicyagent.org)) pour se familiariser avec. 

![](/2023/04/opa_policy.jpg)

Les démos étaient sympas et ça m'a permis de comprendre que le but d'OPA était surtout de découpler le moteur de politiques des applications (métier), ce qui est bien plus large que l'usage que je peux en faire dans Kubernetes et qui fait bien plus sens (à mon avis).

Ca ne m'a pas réconcilié avec rego (et donc OPA par extension) cependant...

![](/2023/04/rego_playground.jpg)

J'avais aussi envie d'aller voir **Pourquoi quitter la tech**. Je le regarderai en replay.

## Télétravail asynchrone

Je ne pouvais pas finir la journée sans aller soutenir mon ex-collègue et ami Benoît PRIOUX, qui a présenté un talk sur un sujet qui me tient à coeur en tant que "nouveau" télétravailleur : comment réussir à (télé)travailler de manière asynchrone.

Défi : collaborer en asynchrone implique que le travail n'est pas fait en même temps, ajoute aussi un défi pour la gestion des notifications.

![](/2023/04/teletravail_asynchrone.jpg)

J'ai découvert plein d'outils et de façon de travailler pas toujours évidentes avec Slack (HPFO, team praise). L'exemple du daily asynchrone m'a beaucoup marqué. Comme Benoît, je commence beaucoup plus tôt que mes collègues et *j'attends* souvent l'heure du daily.

Deuxième exemple, pour éviter de faire des réunions, les employés de Alan utilisent les discussions Github.

Ce que j'ai trouvé "rigolo" avec ce talk, c'est de voir comment Alan "tord" l'usage standard/habituel des outils pour l'adapter au contexte asynchrone.

J'avais aussi envie d'aller voir **Découverte de Crossplane**. Je le regarderai en replay.

## Rencontres et repas speaker

J'ai aussi profité de la journée pour discuter avec les gens que j'ai croisés au hasard des couloirs.

La team clever cloud au grand complet, Stéphane, les copain⋅es devrel d'OVH, Stéphanie, Cécile, Zineb, Philippe, Benoît, Frédéric, ...

J'étais aussi content de recroiser les orgas de KCD qui sont aussi orgas côté Devoxx (JC, Manu, Athalane, Karine), quelques orgas.

J'ai encore plein de gens à qui j'ai promis de venir faire coucou que je n'ai pas eu le temps de voir mais je vais me rattraper jeudi / vendredi, c'est promis ;-\).

Je suis passé une demi-heure au repas speaker mais je ne suis finalement parti car j'ai eu une énorme migraine pendant toute l'après midi :-\(. Je reviendrais demain après une bonne nuit de sommeil.

Note à moi même, avoir du Doliprane dans le sac, pas seulement de l'eau.

![](/2023/04/jardin.jpg)
