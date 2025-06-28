---
title: 'DevoxxFR - Récap du mercredi (jour 1)'
authors:
  - zwindler
type: post
date: 2025-04-17T12:00:00+00:00
excerpt: Je suis à la DevoxxFR 2025 et je fais un récapitulatif de cette première journée de conférence
url: /2025/04/17/devoxxfr-2025-recap-jour-1/
image: /2025/04/devoxxfr-jour1.png
categories:
  - conference
tags:
  - AI
  - DevoxxFR 2025
  - DevOps
---

Les résumés des 3 jours de Conférence Tech 2025

* [DevoxxFR - Récap du mercredi (jour 1)](/2025/04/17/devoxxfr-2025-recap-jour-1/)
* [DevoxxFR - Récap du jeudi (jour 2)](/2025/04/18/devoxxfr-2025-recap-jour-2/)
* [DevoxxFR - Récap du vendredi (jour 3)](/2025/04/18/devoxxfr-2025-recap-jour-3/)

## Premier jour de Conférence Tech 2025

Comme vous l'avez peut-être vu (j'ai abondamment communiqué sur les réseaux 🙃), après quasiment un an sans conférence en tant que speaker, me revoilà sur "les planches", à DevoxxFR !

Evidemment, vous vous en doutez, j'en ai profité pour voir un max de confs, comme à mon habitude ;-\).

C'est parti pour le récap' du premier.

## L'IA n'existe pas

Luc Julia a ouvert la journée (dans un amphi bleu blindé) avec un exposé acide et décalé sur l'évolution de l'IA. Selon lui, il n'y a pas de révolution, mais plutôt une évolution continue depuis les années 50-60, puis 90-2000.

> Nous en France, les révolutions, on connait et c'est pas ça.

![](/2025/04/lucjulia.jpg)

Le titre est un rappel au fait que l'IA générative manque de créativité et que les IA omnipotentes d'Hollywood n'existent pas. Il faut toujours un humain derrière.

Luc a également abordé des problématiques comme la propriété intellectuelle, en citant des cas où l'IA générative open source Stability diffusion a produit des images avec des watermarks Getty Images clairement visibles, et un peu les problématiques environnementales, avec des chiffres complètement bidons (dommage).

## Github Copilot

À 11h35, j'ai assisté à une démonstration de Github Copilot, réalisée par Kim-Adeline Miguel et Sandra Parlant en particulier sur les dernières fonctionnalités.

![](/2025/04/githubcopilot.jpg)

Les deux speakeuses ont montré le chat en mode immersif, le changement de modèle, la configuration des instructions personnalisées. N'ayant pas encore utilisé Copilot (oui oui...), ça donne envie d'essayer.

J'ai été plutôt impressionné par la capacité de Copilot à faire des revues de code sur les PRs et la même chose sur les analyses de sécurité.

## Ne perdez plus vos photos de vacances (ou tout autre fichier important)

Mon talk du jour !!

![](/2025/04/power.jpg)

C'était un sujet qui me tient assez à cœur et ça s'est très bien passé. J'ai eu de bons retours, notamment avec des discussions assez riches qui ont suivi.

Je suis vraiment content, j'ai déroulé comme je voulais. J'ai eu des suggestions pertinentes et je postulerai à nouveau (peut-être) ailleurs :).

Les slides :

* [Ne perdez plus vos photos de vacances 🔥🏠🔥 (ou tout autre fichier important)](https://blog.zwindler.fr/talks/2025-3-2-1/index.html)

## Comment nous avons transformé les Restos du Coeur en Cloud Provider

À 13h30, (mon ancien collègue) Julien Briault et Stéphane Trognon nous ont raconté comment ils ont contribué à transformer les Restos du Cœur en véritable fournisseur de cloud. 

De l'organisation initiale chaotique à une infrastructure professionnelle, ils nous ont partagé un voyage de transformation, du "DC au WC" jusqu'aux 3 DCs multi AZs from scratch gérés par 11 bénévoles.

![](/2025/04/cloudducoeur.jpg)

Ils utilisent désormais OpenStack avec Kubernetes, et plus globalement des solutions open source pour la plupart de leurs besoins. Ils ont même développé des solutions spécifiques, comme des systèmes de monitoring pour les chambres froides qui coûtaient avant ça "un pognon de dingue" (ça, c'est moi qui le dit).

Ce projet est vraiment un coup de cœur (pun intended) que je suis depuis longtemps (j'avais déjà vu un autre talk de Julien qui en parlait).

Grâce à leur approche d'éco-conception et à l'utilisation d'équipements de récupération, ils ont réussi à économiser des millions ~d'euros~ de repas distribués, tout en fournissant des services essentiels permettant de s'affranchir d'AWS (en particulier dans le contexte géopolitique actuel).

## Ca marche dans mon .devcontainer

À 17h00, j'ai assisté à une présentation sur les devcontainers par Benoit Moussaud.

![](/2025/04/devcontainer.jpg)

J'ai souri quand il a commencé en plantant le décor en disant qu'il avait dû re-travailler sur Windows en étant embauché par Microsoft et que c'était la galère (il ne l'a pas dit comme ça, mais ceux qui font du WSL ont compris).

Pour celles et ceux qui ne connaissent pas bien les CDE (pour cloud development environments), cela permet de créer des environnements complets de développement dans des containers, ce qui est extrêmement utile pour l'onboarding, la gestion des versions et des outils, ainsi que pour l'isolation entre l'environnement du laptop et l'environnement spécifique au projet.

La démo s'est bien passée, avec la création d'un devcontainer qui clone le repository dans le container. Dans la spécification, on peut aussi ajouter des "features" pour customiser l'environnement, comme ajouter Vegeta pour du load testing. 

Le côté "automagique" de l'injection des credentials Git de l'utilisateur dans le devcontainer a été aussi abordé, mais ça soulève autant de questions que de réponses...

Cependant, il n'y a pas de support pour Windows, GPU, ou private endpoints via GitHub Codespace.

## Burrito est un TACoS : une alternative open-source à Terraform Cloud

À 17h50, j'ai découvert Burrito, une alternative open-source à Terraform Cloud, qui adresse plusieurs soucis de l'IaC, en particulier avec Terraform.

Luca et Lucas (ahah) nous ont présenté Burrito, leur opérateur Kubernetes inspiré d'ArgoCD, offrant des fonctionnalités de réconciliation, détection de drift pour terraform.

![](/2025/04/burrito1.jpg)

Clairement, je me suis tout de suite retrouvé dans leurs constats des faiblesses de terraform et j'ai été séduit par leur approche.

![](/2025/04/burrito1.jpg)

Burrito est compatible avec Terraform, Terragrunt et Opentofu, et exécute terraform plan/apply dans un container Kubernetes.

Ils ont parlé ouvertement des challenges qu'ils ont rencontrés à l'échelle :

* Problématiques I/O pour le téléchargement des providers et des binaires.
* Problématiques CPU avec des plan/apply très réguliers.

Pour y répondre, ils ont implémenté un caching de provider et des fenêtres de synchronisation pour gérer 800 layers Terraform en parallèle. Pour la suite, ils envisagent d'ajouter du polling, l'autodiscovery, le RBAC, et l'intégration de plugins (Checkov, Terracost).

J'ai eu une discussion très intéressante par la suite avec tous les deux, c'était très sympa.

## Diner des speakers

La soirée s'est terminée par un diner des speakers, où j'ai pu parler avec pas mal de gens :\)

Impossible de citer tout le monde (j'ai beaucoup parlé XD), mais j'ai particulièrement apprécié parler avec Olivier, Marie, Alice & Théotime, Jean-Christophe, Aline, Thierry, et aussi Erwan, pendant cette soirée :\).

Bon... on avait faim... alors, on a dû finir par un MacDo 💀.