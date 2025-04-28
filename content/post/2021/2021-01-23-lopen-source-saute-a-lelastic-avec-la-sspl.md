---
title: 'L’open source saute à L’Elastic avec la SSPL'
authors:
  - zwindler
type: post
date: 2021-01-23T21:32:48+00:00
excerpt: "Récapitulatif de l'épisode Elastic versus AWS et de son passage en SSPL qui a fait couler pas mal d'encre numérique ces derniers jours."
url: /2021/01/23/lopen-source-saute-a-lelastic-avec-la-sspl/
image: /2021/01/sp_vole_travail.jpg
categories:
  - Divers
tags:
  - agpl
  - aws
  - Elastic
  - licence
  - opensource
  - sspl

---

\[Mise à jour : 30 aout 2024\] : Shay Bannon est revenu sur sa décision, Elastic est de nouveau Open source au sens de l'OSI. Voir ce petit article de blog pour plus de détails :

![](/2024/08/30/elastic-redevient-un-produit-open-source)

## SSPL, le retour de la vengeance

Depuis 2018 et le passage de MongoDB d’AGPLv3 en SSPL, j’ai envie d’écrire un article là-dessus. Ou alors d’en parler dans mon talk « Le logiciel libre a-t-il de beaux jours devant lui » que j’ai déjà donné en conf à [Bordeaux](/2019/11/15/le-support-de-ma-conf-logiciel-libre-a-bdx-i-o-2019/) et à [Nantes][1]. Mais je n’ai jamais pris le temps de le faire...

Alors forcément, quand Elastic (la société qui édite la « suite Elastic » que vous connaissez très probablement pour les outils ElasticSearch et Kibana, entre autres) a décidé d'emboiter le pas à Mongo et d'embrasser elle aussi la SSPL, c’était l’occasion rêvée d’en reparler.

![](/2021/01/shay_bannon.png)


C’est un sujet super complexe et si vous avez écumé le web ces derniers temps, vous aurez peut-être remarqué que personne n’est vraiment d’accord sur comment interpréter ce changement de licence par Elastic. 

Grosso modo, il y a un groupe majoritaire qui dit « AWS, c’est des méchants ». Mais si on gratte un peu, vous verrez que c’est un peu plus subtil.

J’ai donc écrit cet article dans l’idée de donner une vue plus complète (et documentée par des gens bien plus talentueux que moi) de la question.

[Edit] Je ne nie pas à Elastic ou MongoDB le fait qu’ils aient le droit de changer de licence. Ils peuvent le faire car ils font signer à tous les contributeurs des CLA, qui demande à l’auteur du patch d’abandonner une partie de ses droits, notamment dans ce genre de cas.[/Edit]

[Edit2]On m’a fait remarqué que, comme je parle très peu d’AWS, ça laisse penser que j’en pense du bien dans cette affaire. Ce n’est pas le cas. Je pense que l’attitude d’AWS n’est pas clean. Mais j’ai trouvé que tapper uniquement sur AWS était trop simpliste et que Shay Banon nous prennait un peu trop de pour des sots.[/Edit]

## Les licences

Les licences, c’est un sujet qui me touche dans mon travail, notamment celles de [MongoDB](/recherche/?keyword=mongo) et d’[Elastic](/recherche/?keyword=elastic) puisque je travaille avec. Ça fait des années que je bosse dans des contextes où les licences de logiciels libres/open source (plus généralement) sont un sujet de discussions animées.

Souvent, la crainte des licences, c’est du bête [FUD](https://fr.wikipedia.org/wiki/Fear,_uncertainty_and_doubt). Une peur un peu vague entretenue par les vendeurs de logiciels privateurs et repartagée par ceux qui en ont été biberonnés depuis des années. Et dans le monde des PME qui tournent en full Microsoft / Oracle / whatever, c’est encore très très ancré. 

Il y a moins d’un mois, dans une discussion qui n’avaient rien à voir (le cloud Gaia X), voilà le genre de tweets qu’on pouvait trouver :

![](/2021/01/fud.png)

Je vais pouvoir encore donner mon talk « Le logiciel libre a-t-il de beaux jours devant lui » un paquet de fois, je pense.

Mais parfois les craintes peuvent être moins illégitimes.

## Back to 2018

On rembobine. En 2018, MongoDB, la société qui s’occupe majoritairement du logiciel de base de données NoSQL MongoDB est en conflit avec AWS. 

MongoDB reproche à AWS de distribuer une version SaaS de son logiciel, d’y faire des améliorations, mais de ne pas reverser les modifications dans le code de MongoDB, comme la licence AGPL l’y oblige. 

(Ce qui n’est pas à exclure, ne soyons pas Candides...)

En creux, mais sans jamais vraiment le dire, MongoDB reproche **surtout à AWS de lui piquer son business**, mais c’est plus dur de fédérer des gens autour de ce point précis. 

Pour fédérer les gens, mieux vaut dire que big-AWS, c’est des gros vilains qui ne respectent pas l’AGPL (une faute légale), plutôt que d’expliquer que Mongo perd du business parce qu’AWS se sert de l’open source pour faire du blé sans pour autant contribuer à l’effort de développement du logiciel (une faute morale).

![](/2021/01/sp_vole_travail.jpg)

> South Park : « Ils nous volent notre travail »

## Que décide de faire MongoDB ?

MongoDB décide de sortir une feuille de papier, de prendre l’AGPL v3, de rayer la section 13 et d’écrire tout ce qui lui passe par la tête. Et ça donne ça :

> If you make the functionality of the Program or a modified version available to third parties as a service, you must make the Service Source Code available via network download to everyone at no charge, under the terms of this License. Making the functionality of the Program or modified version available to third parties as a service includes, without limitation, enabling third parties to interact with the functionality of the Program or modified version remotely through a computer network, _offering a service the value of which entirely or primarily derives from the value of the Program_ or modified version, or offering a service that accomplishes for users the primary purpose of the Software or modified version.
>
> “Service Source Code” means the Corresponding Source for the Program or the modified version, and the Corresponding Source for all programs that you use to make the Program or modified version available as a service, including, without limitation, _management software, user interfaces, application program interfaces, automation software, monitoring software, backup software, storage software and hosting software_, all such that a user could run an instance of the service using the Service Source Code you make available.

J’ai surligné les deux passages que je pense importants.

## Mais c’est incompréhensible ton truc !

Oui, c’est bien le problème, c’est incompréhensible. Heureusement, l’article de Matthew Garrett, posté en octobre 2018, explique bien ce qui est problématique (en anglais).

* [Initial thoughts on MongoDB’s new Server Side Public License](https://mjg59.dreamwidth.org/51230.html)

Le problème principal est que cette section 13 est volontairement floue et extrêmement large, dans le but **avoué** de faire la nique à tous les éditeurs SaaS. Grosso modo, elle oblige quiconque « offre un service dont la valeur dérive entièrement ou principalement de la valeur du programme à open source tout le code de son application en SSPL, mais également le code de **tout** ce qui permet de faire fonctionner le service ». 

Déjà, c’est quoi « majoritairement » ? J’ai bossé avec des logiciels qu’on vendait en SaaS et qui utilisaient extensivement MongoDB comme base de données NoSQL. 

Si je lis la FAQ de MongoDB, je ne suis pas concerné. Mais une FAQ, ce n’est pas une licence. La FAQ n’a aucune portée dans un tribunal.

> - Oui mais Elastic et Mongo, c’est les gentils; ils veulent juste se défendre contre AWS même si leur licence est floue
>
> - Toi, t’as jamais subi un audit Oracle

Ensuite, si on interprète littéralement, cela ne touche donc pas _**juste**_ votre code. Ca concerne tout ce qui permet de faire tourner votre service. Et si je suis jusqu’auboutiste ça va jusqu’au microcode du CPU, en passant par l’OS et tout ce qui contient du code entre les deux.

Tout ça, ce n’est pas moi qui le dit. 

C’est VM (Vicky) Brasseur (ancienne VP à Open Source Initiative), dans un article passionnant qui vient de sortir peu après l’annonce du passage en SSPL d’Elastic. Si vous avez un peu de temps, je vous invite à lire son avis (en anglais aussi du coup).

> By using an SSPL project in your code, you are agreeing that if you provide an online service using that code then you will release not only that code but also the code for every supporting piece of software, all under the SSPL. It’s not a stretch to interpret the wording of the license as requiring users of the SSPL’d software therefore to release the code for everything straight down to the bare metal.
>
> [Elasticsearch and Kibana are now business risks](https://anonymoushash.vmbrasseur.com/2021/01/14/elasticsearch-and-kibana-are-now-business-risks)

## SS - PL - on en - veut - pas !

> N’hésitez pas à m’appeler si vous avez besoin de moi pour vos sloggans de manif’, I’m on fire

Au-delà de ces deux individus, ça a beaucoup déplu quand la SSPL est sortie.

Plusieurs concurrents open source ont dit que c’était cracra, [notamment Scylla DB](https://www.scylladb.com/2018/10/22/the-dark-side-of-mongodbs-new-license/), une autre base de données AGPL. Vous allez me dire « c’est des concurrents, c’est normal ». Mais leur point de vue est bien argumenté et très bien construit, notamment sur le fait que contrairement à ce qu’Elastic tente de faire croire dans son blogpost, ça ne concerne PAS QUE les cloud providers de SaaS mais bien tous les utilisateurs (sauf ceux qui payent)

> Here’s where things get complicated. Let’s imagine the usage of a hypothetical company like a Twilio or a PubNub (these are just presented for example, this is not to assert whether they do or ever have used MongoDB). Imagine they use MongoDB and provide APIs on top of their core service. Would this be considered a fair usage? They do provide a service and make money by using database APIs and offering additional/different APIs on top of it. At what point is the implementation far enough from the original?

Percona, une entreprise tierce d’expertise en bases de données donne un avis intéressant également sur la façon dont MongoDB tue la compétition avec la SSPL :

> SSPL requires anyone who wants to offer MongoDB as a DBaaS to either release all surrounding infrastructure as SSPL or get a commercial license from MongoDB. The first is impractical for cloud vendors as licensing MongoDB directly allows MongoDB Inc. to exercise significant control over end-user pricing, meaning there is no true competition.
>
> [Why is MongoDB’s SSPL Bad For You?](https://www.percona.com/blog/2020/06/16/why-is-mongodbs-sspl-bad-for-you/)

C’est d’ailleurs dans cet article que j’ai appris que le CEO avait dit dans une interview texto qu’ils n’avaient pas vraiment Open sourcé mongoDB par conviction mais juste pour mettre en place un business Freemium. 

> “MongoDB was built by MongoDB. There was no prior art. We didn’t open source it for help; we open sourced it as a freemium strategy”
>
> [Dev Ittycheria (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20200906172618/https://www.cbronline.com/interview/mongodb-ceo-interview)

Ce qui renforce ma conviction qu’ils ont surtout « le seum » qu’AWS leur pique leurs clients plutôt qu’un problème de non-respect de l’AGPL...

Devant la nocivité de cette licence et les risques légaux (licence floue) induits, Debian et Redhat ont retirés tous les produits en SSPL de leurs distributions :

Red Hat drops MongoDB over concerns related to its Server Side Public License (SSPL) (lien mort)

> _To consider the SSPL to be “Free” or “Open Source” causes that shadow to be cast across all other licenses in the FOSS ecosystem, even though none of them carry that risk_
>
> Fedora

> _The SSPL is clearly not in the spirit of the DFSG (Debian’s free software guidelines), let alone complimentary to the Debian’s goals of promoting software or user freedom”_
>
> Debian

Last, but not least, le passage de mongoDB de l’AGPL à la SSPL a été mal vécu par de nombreux contributeurs, qui ont vu leurs contributions passées intégrées dans une licence fermée qui baffouent leur conviction.

## Et Elastic dans tout ça ?

En 2021, Elastic dit avoir les mêmes problèmes que MongoDB. AWS utilise le soft pour vendre un service SaaS, l’améliorer mais sans **reverser** ces améliorations.

Dans une série de tweet, Shay Banon (le PDG d’Elastic) fait une liste à la prévert de toutes les choses « NOT OK » qu’AWS a faite. Certaines sont clairement abusives, notamment le fait d’utiliser Elastic dans le nom de ses produits alors qu’il s’agit d’une marque déposée, et le fait d’intégrer du code propriétaire sans autorisation. D’autres, me font lever les yeux au ciel...

![](/2021/01/shaybanon2.png)

> Tu as déposé un brevet sur tes features ou bien ?

Mais une fois encore, ce qui est reproché sans jamais vraiment le dire, c’est qu’Amazon fasse de l’argent sur le dos d’ElasticStack, sans pour autant contribuer significativement à son développement.

> [...] Amazon Elasticsearch Service [...] profit from our open source software without contributing back
>
> [www.elastic.co/fr/blog/licensing-change](https://www.elastic.co/fr/blog/licensing-change)

Je rappelle qu’Elastic était sous licence Apache, bien moins restrictive que l’AGPL de MongoDB. Se plaindre qu’AWS ne contribue pas à la hauteur des gains qu’ils engrenge est encore plus difficile, selon moi, à défendre, quand on a délibérément choisi une licence dite « permissive ». D’autant qu’Amazon a poussé quelques patchs (peu si on en crois leur blog post, mais pas 0).

Et je ne parle même pas des gens qui, comme pour MongoDB, se retrouve à avoir contribué et donné du temps pour un logiciel qui décide d’**abandonner l’open source**.

> Elastic has spit in the face of every single one of 1,573 contributors, and everyone who gave Elastic their trust, loyalty, and patronage. This is an Oracle-level move.
>
> [Elasticsearch does not belong to Elastic](https://drewdevault.com/2021/01/19/Elasticsearch-does-not-belong-to-Elastic.html)

Car notez que le blog post à propos du changement de licence n’utilise plus le terme open source pour qualifier le futur produit sous SSPL. Shay Banon sait très bien que cette licence n’est pas une licence **Open Source** approuvée par l’OSI (et ne le sera jamais).

> The license du jour is the Server Side Public License. This license was submitted to the Open Source Initiative for approval but later [withdrawn by the license steward](http://lists.opensource.org/pipermail/license-review_lists.opensource.org/2019-March/003989.html) when it became clear that the license would not be approved.
>
> Open Source Initiative - [The SSPL is Not an Open Source License](https://opensource.org/node/1099)

## Conclusion

Dans l’article [Doubling down on open, Part II](https://www.elastic.co/fr/blog/licensing-change) (sic), Shay Banon explique qu’il sait que ses concurrents risquent de le basher sur ce choix de la SSPL et qu’ils vont répandre du méchant FUD

> We expect that a few of our competitors will attempt to spread all kinds of FUD around this change. Let me be clear to any naysayers. We believe deeply in the principles of free and open products, and of transparency with the community. Our track record speaks to this commitment, and we will continue to build upon it.

Mais pas besoin de naysayers. Le FUD, il le répand lui même en choisissant une licence largement décriée depuis sa création en 2018, car mal écrite et volontairement floue (cf les interrogations de VM Vasseur et de Matthew Garrett) !

Bref. Elastic m’a vraiment énervé. Autant que MongoDB m’avait énervé. 

En voulant se battre contre Amazon, la seule chose qu’ils vont réussir à faire avec leur licence moisie, c’est entretenir un flou, une angoisse, auprès de leurs clients et des avocats en entreprise. 

En gros, du FUD. Ce contre quoi on se bat depuis des années. 

Amazon, pendant se temps, s’est fendue d’un blog post qui fleure bon le « LOL, RAF ».

![](/2021/01/aws.png)

Comme prévu, ils ont toute la puissance de feu nécessaire pour faire un fork, qui sera probablement de qualité et on se retrouve juste avec une communauté scindée en deux.

**GG Elastic.**

Les IBM, Oracle et autres vendeurs de FUD doivent bien se marrer.

## Bonus

[Edit3]Le point de vue d’un avocat qui pense le contraire d’une partie de ce que j’écris et surtout des gens que j’ai cité dans cet article :
[writing.kemitchell.com/2021/01/20/Righteous-Expedient-Wrong.html](https://writing.kemitchell.com/2021/01/20/Righteous-Expedient-Wrong.html)
[/Edit]

Pour aller plus loin, une TRES bonne lecture l’**Open Source et les gens qui en font un business**. A lire absolument (en anglais aussi)

* [Open source confronts its midlife crisis](http://dtrace.org/blogs/bmc/2018/12/14/open-source-confronts-its-midlife-crisis/)

Des débats passionnants à ce sujet de cette news sur Ycombinator

* [news.ycombinator.com/item?id=25776657](https://news.ycombinator.com/item?id=25776657)

 [1]: /2020/09/22/rrll-2020-les-slides-du-talk-le-logiciel-libre-a-t-il-de-beaux-jours-devant-lui/
