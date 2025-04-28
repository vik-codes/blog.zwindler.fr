---
title: Récap du premier jour de Kubecon Europe 2024 - Mardi - colocated events
authors:
  - zwindler
type: post
date: 2024-03-19T20:00:00+00:00
excerpt: "Récap' du premier jour (mardi) de la KubeCon + CloudNativeCon Europe 2024 - colocated events"
url: /2024/03/19/kubecon-eu-2024-mardi-colocated
image: /2024/03/peday.jpg
categories:
  - Conférence
tags:
  - Kubecon
  - Kubecon Europe
  - Kubecon Europe 2024
  - Conférence
  - Kubernetes
  - CloudNative
  - colocated events

---

Cet article fait partie d'une suite de 4 posts :
* [Récap du premier jour de Kubecon Europe 2024 - Mardi - colocated events](/2024/03/19/kubecon-eu-2024-mardi-colocated)
* [Récap du (vrai) premier jour de Kubecon Europe 2024 - Mercredi](/2024/03/21/kubecon-eu-2024-mercredi)
* [Récap du deuxième jour de Kubecon Europe 2024 - Jeudi](/2024/03/22/kubecon-eu-2024-jeudi)
* [Récap du dernier jour de Kubecon Europe 2024 - Vendredi](/2024/03/22/kubecon-eu-2024-vendredi)

## Mardi

Cette année, pas de DevoxxFR pour moi (c'est pendant les vacances scolaires de Bordeaux). En revanche, je participe à la Kubecon Europe 2024, qui se déroule cette année à Paris !

Les deux précédentes Kubecon que j'ai faites en présentielles ([2018](/2018/05/03/recap-du-premier-jour-de-kubecon-europe-2018/) et [2022](/2022/05/19/kubecon-eu-2022-jour-1-mercredi/)), je n'avais pu participer qu'au 3 jours (""seulement"" mdr) de conférences, pas les "colocated events" qui se déroulent un jour avant. Cette année, je teste donc l'expérience complète (qui a même commencé lundi, avec la "Kubetrain party" où j'ai été gentiment invité :-D).

![](/2024/03/kubetrain.jpg)

## Platform Engineering day

En première partie de journée, j'ai décidé de choisir de regarder les talks de la track "Platform Engineering Day". 

Ce colocated event se concentre sur les problématiques de "developer experience", c'est-à-dire, comment améliorer l'expérience qu'ont les développeurs pour que le temps entre l'écriture du code et le moment où il est en production soit le plus court possible.

Ça nécessite évidemment un changement de mentalité (on parle de shift-left), car plus d'autonomie nécessite également plus de responsabilités.

## Sometimes lipstick is just what a pig need

J'ai vraiment adoré ce talk, qui est une très bonne introduction aux problématiques de la dev experience. Le talk est très bien présenté, plein d'énergie positive, avec la juste dose d'humour.

![](/2024/03/lipstick.jpg)

C'était aussi très malin de le mettre en tout début de journée.

Le pitch du talk était de démontrer que dans certains cas, les différents types d'interfaces versus les fonctionnalités qu'elles ont sont parfois peu pratiques, mais il est difficile de mettre le doigt sur LA raison pour laquelle, c'est le cas.

Abby Bangser et Whitney Lee ont fait tourner deux "roues" aléatoires pour faire des paires interface/capabilities :

![](/2024/03/wheel.jpg)

Pour chaque paire, elles ont essayé de trouver des interfaces existantes, puis elles se sont demandés quels problèmes pouvaient avoir ces interfaces. Et à chaque exemple, nous avons exploré un axe de réflexion pour ces paires :

**Autonomy**

L'échelle de l'autonomie qu'on souhaite donner à notre application et sa fonctionnalité. 

Exemple : si un développeur veut déployer un service ou une brique d'infrastructure :

* Est-ce qu'on veut donner un portail (exemple Backstage) aux développeurs pour qu'ils puissent déployer des objets eux même en prod ? 
* Est-ce qu'on veut juste ouvrir un ticket pour demander de l'aide à un administrateur.

**Contextual distance**

Est-ce qu'on reste sur le même outil (un plugin d'IDE), ou est-ce qu'on change d'outil ?

**Capability skill**

Est-ce que l'outil nécessite une connaissance approfondie pour être utilisé (un CLI), ou est-ce que l'outil cache la complexité totalement (un sidecar) ?

**Interface skill**

Est-ce que l'outil est simple/intuitif à utiliser ou non ?

Pour cette catégorie, les speakers ont eu une réflexion intéressante : les templates (de code) ne sont PAS des interfaces simples à utiliser. Dès qu'on veut changer quelque chose qui n'est pas le comportement par défaut, il faut modifier du code (pire, du code "de quelqu'un d'autre").

Le "takeaway" principal de ce talk est qu'il n'y a pas de réponse universelle et que lorsqu'on crée ou met en place un nouvel outil, il faut se poser ces questions, en fonction du contexte.

## Beyond Platform Thinking at Ritchie Brothers - Build Things No One Expects, in a Place No One Expect

Ce talk de Bryan Oliver était un REX de l'implémentation de la philosophie Platform Engineering au sein d'une société globale d'enchères d'engins de chantiers.

Parmi les quelques retours intéressant que j'ai bien aimés, Bryan a notamment rappelé qu'il fallait :

* voir la plateforme comme un produit
* qu'il s'agit avant tout d'un projet logiciel, pas un projet d'infrastructure
* que le but premier est avant tout de supprimer toute friction pour le développeur

Après quelques chiffres rapides pour la mise en contexte, Bryan a ensuite donné quelques exemples de ce qui pouvait être fait pour atteindre cet objectif.

Ça a donné quelques exemples assez "drôles", comme le fait qu'un admission controller ait été créé pour attendre la validation d'un JIRA pour mise en prod finale, ou alors l'usage intensif d'opérateur (concepts assez lourds, mais qui peuvent être indispensables pour aller au bout de la démarche d'autonomisation des devs quand aucune alternative sur étagère n'existe).

L'important est de séparer le travail pour rendre ce qui est livré "compliant" (qu'on peut "shift-left") du fait de vérifier que le travail compliant a été fait (qu'on garde côté "ops").

## Sponsored Keynote: Crossplane - The Best Kept Secret in Platform Engineering - Bassam Tabbara, Upbound

N'ayant toujours pas trouvé la page listant les talks par colocated event, je suis resté, un peu par erreur, pour ce "sponsored talk" d'Upbound.

Le CEO d'Upbound a raconté l'histoire de "l'API mandate" chez Amazon dans les années 2000 (la génèse d'AWS), décrété à marche forcée et par la menace par Jeff Bezos. Ça commençait bien...

Aussi brutal que soit ce changement, il faut quand même reconnaitre que c'est grâce à ça qu'a été construit, en un temps recort, des APIs pour tous les "services" offert par les équipes techniques d'Amazon (compute, storage, caching, etc), puis les API "control plane" (IAM, metering, ...) et enfin, le cloud computing tel qu'on le connait aujourd'hui.

Cependant, le talk a tourné au très mauvais goût quand le CEO d'Upbound a "réécrit" l'API mandate à sa sauce, en nous disant qu'il fallait qu'on migre tous nos services dans Kubernetes et Crossplane (LOL), et que sinon il fallait nous virer (pour reprendre la brutalité de Bezos).

![](/2024/03/upbound.jpg)

Je n'ai qu'un regret, **ne pas être parti avant la fin**.

## Building a Platform Engineering API Layer with kcp

Je suis arrivé alors que le talk avait déjà commencé, mais je pense avoir saisi la majorité du talk. Globalement, il s'agissait d'une présentation sur [kcp](https://github.com/kcp-dev/kcp), un outil open source permettant de segmenter un cluster Kubernetes en un ensemble de sous-clusters en forme d'arbre (via des workspaces).

![](/2024/03/building.jpeg)

On peut restreindre l'accès aux objets via héritage entre les branches de l'arbre et faciliter la création de plateformes par l'ajout d'API custom via des APIExports et des APIBindings.

Ce n'est pas totalement clair pour moi puisqu'il me manque un bout du talk mais j'imagine qu'un petit test sera le plus simple pour bien comprendre l'intérêt de l'outil dans la pratique.

## Hands-on lab Sysdig

Après une pause bien méritée sur le rooftop avec mes collègues...

![](/2024/03/dej.jpg)

![](/2024/03/eiffel.jpg)

... Il était grand temps de se diriger vers le Courtyard by Marriot pour un "hands on lab" avec Sysdig, plein à craquer :

![](/2024/03/sysdig.jpg)

Avant de commencer le lab, un intervenant dont je n'ai pas enregistré le nom nous a fait un talk assez bien construit sur tout ce qu'il faut sécuriser quand on est sur le cloud

> There is no "perimeter" in the cloud
> 
> You have to combine open source tools to get proper security in the cloud

Le problème le plus problématique étant que dans la majorité des cas, les incidents de sécurité dans le cloud sont dus à des erreurs humaines (permissions trop grandes, secrets leakés, ...), il faut une combinaison de plusieurs outils pour s'en sortir.

Après un tour d'horizon de plusieurs solutions couvrant une partie du scope (snyk, notary, wolfi, ...), l'intervenant a ensuite introduit Falco (développé par sysdig), l'un de ces outils.

Je connaissais l'outil donc je n'ai pas appris grand-chose (falco ne fait que détecter des comportements suspects, falcosidekick se charge des notifications, on doit ensuite agir via des outils tiers), mais la présentation était très bien faite et l'intervenant agréable à écouter. J'ai passé un très bon moment.

Le lab, en revanche était trop orienté super débutants et a eu un ou deux petits glitchs (429 sur les pulls, navigateurs figés…). Dommage

Quelques citations :

> It takes 207 days for a company to realize there was a breach, 70 days to contain it
> In reality, you have 10 minutes to fix the problem

> "I enjoy writing rego. Said no one ever"

![](/2024/03/loading.jpg)

## Paas Forward

Pour terminer la journée, j'ai ensuite filé vers l'événement conjoint OVHCloud + Rancher (et Enix, AMD, Netapp, NVidia), Paas Forward.

![](/2024/03/paas.jpg)

Après un peu de networking, nous avons eu droit à des conférences pour présenter les nouveaux produits sortis conjointement par OVHCloud et Rancher (pour faire court, un Rancher managé). Le tout animé par Alex Williams, le fondateur de [The New Stack](https://thenewstack.io/author/alex/).

![](/2024/03/paas2.jpg)

On a fini la soirée par du networking à nouveau et un concert de Kungs. C'était sympa :\) (mais trop fort x-o).

## Chit-chat

Comme d'habitude, les conférences sont aussi un endroit parfait pour se retrouver, se rencontrer et discuter. 

Entre hier soir et aujourd'hui, j'étais super content de pouvoir revoir ou rencontrer en vrai pour la première fois (après des échanges sur le net) Katia, Stéphane, Andrea, Aurèl, Jérôme, Réda, Smaine, Kévin, Olivier, Christian, Quentin, JC, Rachid, Jérôme (bis), Alan, Thomas, Olivier (bis), Thierry, Aurélie, Stéphane, la team frenchies sur Telegram, Alex, Sébastien, Fanny, Laurent, Boris, Rémi, Thomas (Bis) et tous les gens que j'oublie ou qu'on m'a présentés, car il est tard (bien trop pour écrire un article).

À demain pour le "vrai premier" jour !
