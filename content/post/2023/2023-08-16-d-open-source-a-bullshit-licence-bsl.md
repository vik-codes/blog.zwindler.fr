---
title: 'D’open source à BullShit Licence (BSL)'
authors:
  - zwindler
type: post
date: 2023-08-16T12:00:00+02:00
url: 2023/08/16/d-open-source-a-bullshit-licence-bsl
image: /2023/08/28c1d418-5dd4-43c2-8345-4f4ce34f9ff2.png
categories:
  - Logiciel
  - systeme
tags:
  - bash
  - bashing
  - FOSS
  - humeur
  - Open Source
  - OSS
  - Hashicorp
  - Terraform
  - BSL
  - Business Source Licence
  - MPL
  - Mozilla Public Licence

---

## Résumé des épisodes précédents

Il y a à peine un mois, j'écrivais mon billet d'humeur annuel sur une boite, championne de l'open source (RHEL), qui utilise une faille de la licence GPL pour gratter un peu de thune en fermant ses sources aux "rebuilders" (je parle évidemment de l'article ["Oracle à la rescousse de Linux ? Quelle blague!"](/2023/07/11/oracle-a-la-rescousse-de-linux-quelle-blague)). 

Je ne pensais pas que je devrais REFAIRE un article d'humeur sur un sujet similaire, un mois plus tard.

Car jusqu'à présent, c'était plutôt des incidents "isolés" et dans des contextes assez spécifiques. [En 2021, c'était Elastic qui passait à la licence SSPL pour "lutter" contre les offres managées par AWS](/2021/01/23/lopen-source-saute-a-lelastic-avec-la-sspl/) (après Mongo qui avait fait pareil en 2018). 

Si AWS était évidemment fautif dans cette histoire, ce move est catastrophique et a amorcé pas mal de backlash côté communauté (justifié, à mon avis) ainsi qu'une tempête de FUD de tous les côtés. Au final, c'est l'open source, qui devenait tout juste respectée en entreprise, qui en pâtie.

## RHEL ouvre une brèche, l'open source se referme

Car à peine quelque jour après le move de RHEL pour faire la nique à Rocky+Alma, on pensait souffler mais non, les mauvaises nouvelles s'enchaînent.

Canonical, créateur de l'outil LXD (solution pour manager des containers LXC, que j'affectionne particulièrement) retire l'outil du Linux Containers project, un projet communautaire, qui le chapeautait.

> While the team behind Linux Containers regrets that decision and will be missing LXD as one of its projects, it does respect Canonical’s decision and is now in the process of moving the project over.

[linuxcontainers.org/lxd/](https://linuxcontainers.org/lxd/)

On peut aussi noter que ce move le lendemain de la démission d'un des développeurs de LXD chez Canonical :

[stgraber.org/2023/07/10/time-to-move-on/](https://stgraber.org/2023/07/10/time-to-move-on/)

Et que le créateur de LXD l'a forké :

[linuxiac.com/incus-project-lxd-fork/](https://linuxiac.com/incus-project-lxd-fork/)

> In response to Canonical’s takeover of LXD, the independent Incus project arose as a fork for this container and virtual machine manager.

## Moi je l'aime bien la MPL...

Et la semaine dernière (pendant mes vacances, ces cochons), Hashicorp a changé la licence de leurs produits de la MPL (Mozilla Public Licence, que je trouve être un bon compromis) à la BSL, une licence plus restrictive :

> BSL is a new alternative to closed source or open core licensing models. Under BSL, the source code is always publicly available. Non-production use of the code is always free, and the licensor can also make an Additional Use Grant allowing limited production use.

Qu'est ce que la BSL ?

Grosso modo, c'est une licence qui n'est PAS open source ([cf ce post de Sentry qui reconnait que BSL n'est pas open source dans le sens OSI du terme](https://blog.sentry.io/lets-talk-about-open-source/)), et qui permet à Hashicorp dans le cas présent de tuer la concurrence dans l'oeuf.

> You may make production use of the Licensed Work, provided such use does not include offering the Licensed Work to third parties on a hosted or embedded basis which is competitive with HashiCorp's products

Dans le [billet de blog pour parler du changement de licence](https://www.hashicorp.com/blog/hashicorp-adopts-business-source-license), voilà comment c'est dit :

> Vendors who provide competitive services built on our community products will no longer be able to incorporate future releases, bug fixes, or security patches contributed to our products.

Si vous voulez creuser un peu plus les réactions, The Register a fait un article assez cool sur ce move, les réactions et les conséquences que ça va avoir.

[www.theregister.com/2023/08/11/hashicorp_bsl_licence/](https://www.theregister.com/2023/08/11/hashicorp_bsl_licence/)

Et je vous partage aussi cet excellent thread sur Twitter et son tout aussi excellent follow up de iamvlaaaaaaad

Autant dire que de nombreuses personnes, dont des développeurs qui ont contribué à un projet open source et qui se retrouvent à avoir engraissé gratuitement Hashicorp, sont assez mécontents.

Pour essayer d'éteindre l'incendie, il y a évidemment [une FAQ pour dire que rien ne va changer](https://www.hashicorp.com/license-faq) et que l'utilisateur n'a rien à craindre, mais comme à chaque fois dans ces histoires de licences, c'est la licence qu'il faut lire, pas la FAQ. Ce n'est pas la FAQ qui vous sauvera du tribunal...

C'était exactement la même salade avec MongoDB et Elastic. Beaucoup de craintes, du FUD, notamment de la part des opposants aux modèles open source (ahah vous voyez c'est pas clair l'open source !), et surtout un flou juridique immense que personne n'a encore réellement éclairci...

Le point positif, c'est que ça fait travailler les devrels et les avocats (cf le thread de vlad).

## Hashi, c'est fini

Note: [ce sous titre est gracieusement offert par (volé à) Clementd](https://framapiaf.org/@clementd/110875367669781368).

Autant dans le cas du bras de fer entre Mongo/Elastic avec AWS, j'arrivais à peu près à comprendre les motivations. En revanche, pour Hashicorp, on peine à trouver qui est visé par cette modification.

Qu'avait à gagner Hashicorp à changer son modèle de licence, à part une communauté à dos et un fork dans les start-in blocks ?

La seule cible qui me vient en tête n'est pas un gros méchant cloud provider, mais plutôt des offres alternatives à Terraform Cloud/Entreprise, comme [Env0](https://www.env0.com/) ou [Spacelift](https://spacelift.io/). Et aussi de petit éditeurs / cloud providers locaux qui se reposent sur ces outils pour fournir de l'automatisation à leurs clients...

On est bien loin des méchants GAFAM qui "piquent not' travail" (ref south park, j'innove peu), ici il s'agit d'offres qui se sont construites "au-dessus" de Terraform, car elles ont apporté des choses **en plus** qu'on ne trouvait pas dans les offres d'Hashicorp. Ces offres se retrouvent tuées dans l'oeuf maintenant qu'elles sont concurrentes à certains produits d'Hashicorp. Pratique...

![](/2021/01/sp_vole_travail.jpg)

Plus cynique encore, on pourrait imaginer un scénario où une boite se créerait au dessus de terraform ou tout autre produit d'Hashicorp en étant totalement PAS concurrente de leurs offres, qui se mettrait à bien marcher. Hashicorp n'aurait qu'à artificiellement créer un produit concurrent (même tout pourri) et hop, on rafle le marché.

On est plus proche du [EEE](https://en.wikipedia.org/wiki/Embrace,_extend,_and_extinguish) que de la philosophie open source.

**Sauf que maintenant, c'est plus Microsoft : c'est RHEL, Canonical, Hashicorp...**

## Conclusion (rédigée par ChatGPT, pour le lulz)

Dans ce spectacle de l'open source, les spectateurs ne savent plus s'ils doivent rire ou pleurer

Les entreprises qui semblaient autrefois être les champions du partage et de la collaboration semblent désormais être en compétition pour le titre de "Licence la plus énigmatique". 

Et tandis que le rideau se lève sur ces actes étonnants, les développeurs, les utilisateurs et la communauté open source dans son ensemble se demandent peut-être si tout cela est un rêve étrange, ou simplement une réalité nouvelle et ironique.

## Bonus

* [La réaction d'Env0](https://www.env0.com/blog/hashicorp-license-change)
* [La réaction de Pulumi](https://www.pulumi.com/blog/pulumi-hearts-opensource/)
* [La réaction de Spacelift](https://spacelift.io/blog/spacelift-latest-statement-on-hashicorp-bsl)
