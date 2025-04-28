---
title: Récap du premier jour de Voxxed Days Luxembourg 2024 - Jeudi
authors:
  - zwindler
type: post
date: 2024-06-21T08:00:00+02:00
excerpt: "Récap' du premier jour de Voxxed Lu"
url: /2024/06/21/voxxed-days-luxembourg-2024-jour-1
image: /2024/06/voxxed_lu_24.jpg
categories:
  - Conférence
tags:
  - Voxxed Luxembourg 2024
  - VoxxedLu

---

[Note : vous pouvez retrouver mon récap' du lendemain (vendredi) ici](/2024/06/21/voxxed-days-luxembourg-2024-jour-2)

## Back to Luxembourg!

![](/2024/06/train.jpg)

Comme je le disais dans le post précédent, je suis pour deux jours au Luxembourg pour la conférence VoxxedDays Luxembourg. J'avais déjà fait cette conférence en 2022 donc j'ai cette fois ci un peu plus mes marques.

## Keynote astropierre

La journée a commencé très très fort avec une keynote d'@astropierre (de son vrai nom Pierre Henriquet), médiateur scientifique, sur "les robots dans l'espace".

![](/2024/06/robots.jpg)

Après une rapide définition de ce qu'est pour lui un robot, astropierre a commencé à nous raconter un peu la course à l'espace notamment dont les robots sont en effet très présents.

De sputnik en 57 à Mars 3 en passant par Viking 1 et Voyager, Pierre a eu à coeur d'adapter son discours à l'auditoire, en insistant sur les capacités techniques (souvent quelques ko de mémoire) et les bugs (logiciel des batteries de Viking, problème de conversion avec Mars Orbiter, rayons cosmiques pour Voyager...).

Petit garçon fan de science fiction que je suis, cette keynote m'a évidemment beaucoup plu.

## Main room - Henri Gomez - SRE, Mythes vs Réalités

J'étais forcément un peu spoilé pour cette conf d'Henri Gomez pour deux raisons. D'abord, j'en ai donné une similaire dans plusieurs conférences ces dernières années (voir [SRE ! SRE partout](https://blog.zwindler.fr/talks/2022-sre-sre-partout/index.html)).

Ensuite parce qu'on a mangé ensemble la veille :-p.

![](/2024/06/sre.jpg)

Après avoir expliqué d'où vient le terme SRE, ce que sont ses missions, Henri a ensuite décrit ce qu'iels étaient et n'étaient pas, avec assez de justesse.

Le SRE est avant tout un individu pluridisciplinaire, un bon généraliste, pas un super héros qui maitrise toutes les stacks (de plus en plus pléthoriques).

Henri donne quelques conseils sympa pour éviter de tomber dans le piège de "Google fait ça, il faut qu'on fasse pareil". J'ai bien aimé son ratio d'équipe "1 senior pour 2 juniors", et aussi la règle de "Tu veux un nouveau soft dans la stack ? Retire en deux d'abord !". A tester ;-\)

## Comment nous avons transformé les restos du coeur en cloud provider

Je ne pouvais pas louper ce talk de mon collègue Julien Briault, qui mène littéralement une double vie puisqu'il cumule, en plus de son emploi le jour chez DEEZER, une activité très intense au sein du SI des Restos du Coeur.

![](/2024/06/rdc.jpg)

Je ne pense pas spoiler le talk, je vous invite plutôt à le voir. Julien explique avec humour et humilité le contexte technique qui a poussé l'antenne locale à proposer de concevoir et d'héberger de l'informatique interne pour les restos au national.

## Demystifions les composants internes de Kubernetes

Après un bon déjeuner, c'était l'heure de mon talk !

![](/2024/06/demystifions.jpg)

Je vous rappelle le pitch :

> De nos jours, beaucoup d'entre vous (devs, sysadmins, ...) utilisent Kubernetes, d'une manière ou d'une autre. Vous savez ce qu'est un container et qu'on peut faire confiance à Kubernetes pour le déployer de manière fiable en production.
> 
> Mais au-delà de ça, vous êtes vous demandé "comment" Kubernetes fonctionne ?
> 
> Entre le moment où vous faites un `kubectl apply` (ou un `helm install`) sur votre PC et le moment où l'application est accessible, que s'est-il passé ?
> 
> Quand un nœud tombe en panne, qu'est-ce qui fait que l'application est relancée sur un autre nœud sans qu'on ait besoin de réveiller l'humain en astreinte ?
> 
> Comment se fait-il qu'on puisse accéder à n'importe quel container de notre cluster sans faire appel à une administratrice réseau chevronnée à chaque nouveau déploiement ?
> 
> Je vous propose de décortiquer ensemble tous les composants internes de Kubernetes pour découvrir que "non, Kubernetes, ce n'est pas automagique".

## Réagir à temps aux menaces dans vos clusters Kubernetes avec Falco et son écosystème

Rachid Zarouali et Thomas Labarussias ont ensuite fait une longue démonstration des capacités de Falco, un outil de détection des menaces au runtime dans les environnements Linux et Kubernetes.

![](/2024/06/falco.jpg)

Après quelques rappels sur les fondamentaux (syscalls, kernel modules), Thomas et Rachid ont introduit eBPF et notamment ses avantages dans le cadre de la collecte des syscall par sysdig (éviter de patcher/recompiler les kernels : Compile Once Run Everywhere).

Ils nous ont ensuite montré comment comprendre / écrire des règles dans falco, puis des exemples d'alertes, et nous ont présenté Falco Sidekick et Falco Talon.

On a fini par une démo de bout en bout, qui s'est bien passée 😅.

Pas de bol, en même temps il y avait TROIS conférences que j'aurais aimé voir :
* Pull Request Professionnelle : Comment Promouvoir son travail en interne “ 
* Renovate, où comment garder son projet à jour !
* Argo et Flux sont dans un Kargo, lequel tombe à l'eau ?

Je regarderai les replays.

## Au secours ! Mon manager me demande des KPIs !

Après une bonne pause sponsor pour ma part, je suis allé voir le talk de Geoffrey Graveaud. Il s'est attaqué à un sujet épineux pour beaucoup : les KPIs. Surtout celles qui viennent d'en haut (top down), sans retour des contributeurs individuels (bottom up).

![](/2024/06/geoffrey.jpg)

Pèle mèle, ça parle de DORAs metrics (LTC, DF, TTR, CFR...), d'Accelerate, la technique d'interview, de pratiques de développement, de retours (sans influencer les opinions), de psychométrie (voir [Albert Moukheiber](https://fr.wikipedia.org/wiki/Albert_Moukheiber_(scientifique)))...

Pour ceux qui ne connaissent pas Geoffrey, il est très fort pour raconter des histoires. Je n'en dis pas plus pour ne pas spoil, mais je vous invite à voir sa session, présentée de manière aussi inhabituelle que réussie. Je vous invite à voir le replay plutôt que de dénaturer sa présentation.

Je garde juste cette petite citation juste comme ça :\) :

> Des compteurs sans moteurs, ça ne vaut rien

## Astropierre le retour, puis soirée speaker

Nous avons fini la journée sur une seconde keynode d'Astropierre, sur la fusion thermo-nucléaire cette fois-ci. Ca m'a rappelé mes cours de physiques en prépa, c'était cool :\)

Merci Astropierre, c'était très agréable de finir cette première journée là-dessus, on sent la passion de la transmission du savoir (pierre et très pédagogue et très accessible) autant que de la technique.

![](/2024/06/iter.jpg)

Et après l'effort, le réconfort ! Je n'ai pas pris de photos pour bien profiter. C'était un chouette moment d'échange avec mes pairs.

[Note : vous pouvez retrouver mon récap' du lendemain (vendredi) ici](/2024/06/21/voxxed-days-luxembourg-2024-jour-2)
