---
title: 'Devoxx France 2023 - Récap du jour 3'
authors:
  - zwindler
type: post
date: 2023-04-15T04:00:00+02:00
excerpt: Je suis à Devoxx France 2023 et je fais un récapitulatif de cette troisième journée de conférence
url: /2023/04/15/devoxx-2023-recap-jour-3/
image: /2023/04/palais_des_congres.jpg
categories:
  - Conférence
tags:
  - Kubernetes
  - Devoxx 2023
  - Devoxx 

---

Les résumés des 3 jours de DevoxxFR 2023

* [Mercredi](/2023/04/13/devoxx-2023-recap-jour-1/)
* [Jeudi](/2023/04/14/devoxx-2023-recap-jour-2/)
* [Vendredi](/2023/04/15/devoxx-2023-recap-jour-3/)

## Troisième jour de DevoxxFR !!

Aujourd'hui, dernier jour de DevoxxFR. Moins de pression, vu que je n'ai plus de talk :\). Un peu moins d'énergie, aussi ;-P.

## Biais & Balivernes

J'ai suivi un collègue pour aller voir le talk de Thomas DURAND (aka Acermendax).

![](/2023/04/biais_balivernes.jpg)

Pour être parfaitement honnête, à part le nom de sa chaîne (La tronche en biais) je ne le connaissais pas du tout et j'ai cru comprendre qu'il ne fait pas toujours l'unanimité.

Au-delà de ça, j'ai plutôt bien aimé son talk, une vulgarisation des biais cognitifs les plus connus et dee ce que lui appelle des "balivernes" (les mensonges qu'on a envie de croire et qui se répandent particulièrement vite sur les RS). Il a essayé de définir ce qu'était l'intelligence, la rationalité, l'esprit critique, ...

Les slides étaient old(-old-old) school j'ai trouvé ça un peu déstabilisant mais Thomas est sans aucun doute un orateur très à l'aise. Le talk était agréable.

J'ai une punchline qui m'a décroché un sourire :

> La règle 1 du club Dunning Kruger, c'est que tu ne sais pas que tu fais partie du club (ref Fight Club)

A la toute fin, il a cité un documentaire que j'avais vu à l'époque où j'étais ado : "Opération Lune". C'est un souvenir incroyable.

## FoundationDB : le secret le mieux gardé des nouvelles architectures distribuées !

Steven LE ROUX et Pierre ZEMB on fait une présentation détaillée de FoundationDB, un moteur de stockage capable de gérer plusieurs databases sur une seule et même "fondation".

![](/2023/04/foundationdb.jpg)

Le principe repose dans l'idée que la différence entre les bases de données se situe surtout sur les couches modèles et query langage. FoundationDB unifie la partie basse, grâce à un scope de fonctionnalité très restreint.

Au-delà des avantages techniques (transactional, fault tolerant, actor based, ce qui le rend très scalable), FoundationDB intéresse fortement Clever Cloud pour sa capacité à être massivement simulé (le simulateur de FoundationDB permet de jouer des scénarios de fautes de manière déterministe).

Le sujet est passionnant mais on imagine surtout des cas d'usages pour de très (très) grandes entreprises ou des cloud providers (d'où l'intérêt de Clever dans le produit). Hâte d'en voir un peu plus sous le capot, c'est encore un peu théorique dans ma tête.

## Écoutez l'histoire de Sonos Voice et de ZIO...

Sans trop savoir dans quoi je m'engageais, je suis allé voir le talk de Pierre BAILLET qui travaille chez Sonos (un partenaire actuel de l'entreprise pour laquelle je travaille) parler de *Sonos Voice* et de *ZIO*.

![](/2023/04/sonosvox.jpg)

Je n'avais aucune idée de ce qu'était ZIO et j'ai omis de lire en détail l'abstract. Boulette.

> Type-safe, composable asynchronous and concurrent programming for Scala

Je me suis retrouvé dans une conférence de REX sur une librairie Scala pour faire de la programmation fonctionnelle 🤣.

Autant dire que j'étais *un peu* largué. 

Cependant, le speaker était très à l'aise et l'esprit bon enfant. Je me suis accroché pour suivre et au final, même si je ne connais rien à Scala ou ZIO, j'ai passé un bon moment.

Les anecdotes sur la mise en prod de leur service Sonos Voice étaient bien marrantes.

## Ressuscitons les ordinosaures !

Très chouette présentation d'Olivier PONCET qui nous parle de son expérience dans la rédaction d'émulateurs d'"ordinosaures". J'étais content de pouvoir la voir, ça fait un moment que j'ai vu passer de super retours dessus.

![](/2023/04/ordinosaures.jpg)

Olivier nous a parlé des composants principaux qu'il faut émuler pour faire marcher un ordinateur des années 80, puis nous a montré quelques exemples de codes en nous expliquant plus en détails ce que cela faisait.

C'était très fun, mais il y avait beaucoup d'informations à digérer en peu de temps (et je suis rouillé en C/C++), surtout un vendredi après midi.

## This is the end

J'ai tiré ma révérence après ça, même si j'avais initialement prévu d'aller voir un talk supplémentaire. La fatigue accumulée a pris le dessus.

Je suis content d'avoir vu Julie avant mon départ, qui donnait un talk juste après sur la sécurité des secrets dans Kubernetes. J'ai croisé Claudio, et à la toute fin, j'ai discuté quelques minutes avec François, qui m'avait invité à faire mon talk en meetup avant DevoxxFR. Ca m'a bien aidé pour hier, merci.

J'ai aussi revu des personnes que j'avais vu la veille mais c'était très bref.

C'était encore une fois une très très grande conférence (j'aime vraiment DevoxxFR, ça se voit ?) et je suis très fier d'avoir pu y participer une nouvelle fois en tant que speaker. Cette année, j'ai eu aussi pu y aller avec un collègue, ce qui est quand même plus sympa que d'y aller seul, même si je commence à connaître du monde.

Un grand bravo aux organisateurs, aux speakers, aux sponsors et aux participants qui font de DevoxxFR une conférence à part dans l'écosystème tech FR.

![](/2023/04/train_retour.jpg)
