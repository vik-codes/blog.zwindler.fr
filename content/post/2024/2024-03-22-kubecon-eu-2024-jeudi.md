---
title: Récap du deuxième jour de Kubecon Europe 2024 - Jeudi
authors:
  - zwindler
type: post
date: 2024-03-22T00:00:00+02:00
excerpt: "Récap' du deuxième vrai jour (jeudi) de la KubeCon + CloudNativeCon Europe 2024"
url: /2024/03/22/kubecon-eu-2024-jeudi
image: /2024/03/keynote_jeudi.jpg
categories:
  - Conférence
tags:
  - Kubecon
  - Kubecon Europe
  - Kubecon Europe 2024
  - Conférence
  - Kubernetes
  - CloudNative

---

Cet article fait partie d'une suite de 4 posts :
* [Récap du premier jour de Kubecon Europe 2024 - Mardi - colocated events](/2024/03/19/kubecon-eu-2024-mardi-colocated)
* [Récap du (vrai) premier jour de Kubecon Europe 2024 - Mercredi](/2024/03/21/kubecon-eu-2024-mercredi)
* [Récap du deuxième jour de Kubecon Europe 2024 - Jeudi](/2024/03/22/kubecon-eu-2024-jeudi)
* [Récap du dernier jour de Kubecon Europe 2024 - Vendredi](/2024/03/22/kubecon-eu-2024-vendredi)

## Keynote: 🇫🇷 Hip, Hip, Beret! No Cap, Just Cloud Native Facts

Dans cette keynote d'ouverture, Taylor Dolezal, Head of Ecosystem de la Cloud Native Computing Foundation nous a présenté quelques statistiques de la CNCF, avec un focus particulier sur les contributions des "end users".

![](/2024/03/endusers.jpg)

Sans surprise, Backstage arrive comme d'habitude largement en tête, avec KCL et Argo ensuite.

Pour faciliter les contributions, la CNCF a lancé un programme "from Zero to merge project" pour inciter les personnes qui n'osent pas contribuer à le faire. À voir si c'est vraiment utile, ou non ?

## Keynote Panel Discussion: Revolutionizing Cloud Native Architectures with WebAssembly

Le talk suivant était un panel avec :

* Ralph Squillace, Principal Product Manager, Microsoft
* Michelle Dhanani, Principal Software Engineer, Fermyon Technologies
* Kai Walter, Distinguished Architect, ZEISS

Pour faire simple, Michelle Dhanani nous a montré les avantages de lancer des workloads WASI (WebAssembly mais côté serveur, pas dans un navigateur) depuis Kubernetes, avec une mini-démo. Pour en savoir plus, je suis allé voir une session dans l'après midi.

Suite à cette keynote, j'ai écouté d'une oreille la suite (les awards pour les end users) mais pas de quoi en faire un récap.

## We Tested and Compared 6 Database Operators. The Results are In!

Ce talk avait été fait en français l'an dernier à KCD France. J'en avais eu d'excellents retours, mais je n'avais pas vu le voir puisque [j'étais moi même organisateur de l'événement](/2023/03/11/ma-premiere-experience-d-orga-kcd-france-2023/) (eh oui, c'est le côté ingrat de l'orga ;-P).

Jérôme Petazzoni et Alexandre Buisine ont fait un REX de l'usage des opérateurs de base de données pour les clients d'Enix, le tout en étant habillés comme des Pirates.

![](/2024/03/pirates.jpg)

Voici les 6 opérateurs qui ont été comparés :

* CNPG, StackGres, postgres-operator (Zalando)
* Moco, mariadb-operator, percona operator

Sur une liste de critères (d'opérabilité surtout), Jérôme et Alex ont comparé les différents opérateurs et expliqué pourquoi ils les aimaient / n'aimaient pas, et à la toute fin, lesquels ils utilisent en production.

Plutôt que de tout paraphraser, voici les slides :

* [Lien docs.google.com](https://docs.google.com/presentation/d/12g4VFhwKwweFrBnGmc_AUADJy8D4Cl43L_E8ltSxGbo/mobilepresent?pli=1&slide=id.g19c3225ce84_0_0&authuser=1)

## Kubernetes Controllers in Rust: Fast, Safe, Sane

Le talk que j'ai vu ensuite était une présentation de Matei David, ingénieur chez Buoyant (les développeurs de Linkerd).

![](/2024/03/rust.jpg)

Matei nous a expliqué qu'une des raisons (ce n'est pas la seule) pour laquelle la plupart des controllers d'opérateurs Kubernetes sont codés en golang : les libraries client-go et controller-runtime sont les bibliothèques les plus complètes pour interagir avec l'API server.

Cependant, ça ne veut pas dire que rust n'est pas un langage de choix pour coder des operateurs.

Il existe un crate kube-rs, qui est l'équivalent de client-go et qui permet déjà de rédiger du code de qualité pour intéagir avec Kubernetes. Il existe [kubert](https://github.com/olix0r/kubert) qui ajoute une couche d'abstraction au code rust pour coder des opérateurs.

Matei a ensuite montré des exemples de codes et expliqué pourquoi ils avaient commencé à écrire du code rust pour Linkerd (problématiques complexes de mutex en go et gestion de la mémoire plus safe en rust).

N'était pas très à l'aise en rust, j'ai compris juste assez pour que ce soit intéressant, mais pas assez pour avoir envie de tester. C'était un bon talk.

## Leveling up Wasm Support in Kubernetes

Ce talk sur les produits de Fermyon Spin et KubeSpin était relativement intéressant. C'était une version longue de la keynote du matin, avec les mêmes intervenants, et une démo plus longue et live.

![](/2024/03/kubespin.jpg)

Pour faire simple pour ceux qui ne sauraient pas, WASM est un format permettant d'exécuter du code bas niveau sur n'importe quel device et n'importe quel architecture dans un environnement sandboxé et sécurisé.

> boring definition: it's another bytecode format

Pour donner un exemple concret, Figma utilise du code C++ compilé en WASM pour exécuter du code nécessitant des performances importantes depuis un navigateur et importé simplement avec du javascript.

On nous a présenté Spin, un ensemble d'outils pour développeurs permettant de faciliter l'adoption de WASM dans un environnement serverless, puis SpinKube, le framework permettant de faciliter l'intégration de ces stacks dans Kubernetes.

> Spin is like "rails"

SpinKube utilise runwasi, un containerd shim écrit en rust (encore du Rust...). La démo (sur 5 RPi) était sympa et donne envie de tester.

## Keeping the Bricks Flowing: The LEGO Group's Approach to Platform Engineering for Manufacturing

Ce talk de Mads Høgstedt Danquah & Jeppe Lund Andersen, de The LEGO Group, était mon petit bonbon.

Comme beaucoup de nerds, je suis un fan de briques Lego depuis mon enfance et travailler là-bas serait un peu un rêve. Je ne suis donc pas du tout objectif dans mon récit de ce talk.

![](/2024/03/lego.jpg)

Mads et Jeppe ont commencé par poser le décors. Lego est une entreprise industrielle qui se repose beaucoup sur l'automatisation pour rester compétitive. Il y a donc beaucoup de machines, nécessitant beaucoup de services logiciels et donc beaucoup d'infrastruture.

Ce talk était donc un REX des pratiques que The Lego Group a mis en place pour obtenir une infrastruture agréable à utiliser pour ses 1200 ingénieur⋅es logiciels.

Voici quelques conseils qu'ils ont pu donner au cours de la présentation :

> Provide a cloud like experience (self service, API enabled) accessible with IDP
>
> User adoption is not a given, it must be earned. But how do we earn our users trust?
>
> Focus on early value

> Private on-prem cloud is way easier than it ever was

> Value time over quality
> 
> Quality over speed (pick from the landscape)

Words to live by.

## Make Your Cluster Fly: Embed a Multi-Node Kubernetes Cluster Inside an Aircraft Using Puppet & Flux

En toute fin de journée, je suis allé voir ce talk de Thalès de Alexis Bonnin & Guillaume Maquinay.

![](/2024/03/thales.jpg)

En réalité, j'y suis allé parce que je connais quelqu'un qui a participé en partie à ce projet et j'avais envie de voir ce qu'ils allaient en dire, même si j'étais bien fatigué de la journée...

Grosso modo, Alexis et Guillaume ont bien présenté les problématiques liées à des avions qui n'ont par définition par toujours du réseau et qu'il faut réussir à mettre à jour de manière automatisée et industrialisée dans des conditions pas habituelles (edge).

Si les technos ne sont pas super sexy (Puppet ☠️☠️☠️), les challenges sont intéressants, car non conventionnels, et nécessite des solutions à base d'operator pour éviter de pull des images quand on a plus de réseau.

![](/2024/03/thales2.jpg)

## Blabla

Honnêtement, j'ai vu tellement de monde aujourd'hui que ça n'a plus vraiment de sens d'en faire une liste. J'ai eu plusieurs conversations super enrichissantes avec Aurélie, Stéphane, Théotime et Eddy sur le stand OVHCloud, au café avec Laetitia, passé un bon moment avec Zed pendant la pause, profité de la team deezer pendant le déjeuner et au food court le soir, revu Thoms (le bouncer) et Christian totalement par hasard dans le métro en rentrant de diner...

Et surtout, j'ai fait une super photo avec la team frenchies sur le rooftop :

![](/2024/03/frenchies.jpeg)

Good times.
