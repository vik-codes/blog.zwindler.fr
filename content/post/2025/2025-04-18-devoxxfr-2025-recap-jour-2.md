---
title: 'DevoxxFR - Récap du jeudi (jour 2)'
authors:
  - zwindler
type: post
date: 2025-04-18T08:00:00+00:00
excerpt: Je suis à la DevoxxFR 2025 et je fais un récapitulatif de cette deuxième journée de conférence
url: /2025/04/18/devoxxfr-2025-recap-jour-2/
image: /2025/04/devoxxfr-jour2.jpg
categories:
  - Conférence
tags:
  - AI
  - DevoxxFR 2025
  - DevOps
---

Les résumés des 3 jours de DevoxxFR 2025

* [DevoxxFR - Récap du mercredi (jour 1)](/2025/04/17/devoxxfr-2025-recap-jour-1/)
* [DevoxxFR - Récap du jeudi (jour 2)](/2025/04/18/devoxxfr-2025-recap-jour-2/)
* [DevoxxFR - Récap du vendredi (jour 3)](/2025/04/18/devoxxfr-2025-recap-jour-3/)

## Deuxième jour de DevoxxFR 2025

Après une soirée qui a fini bien tard, j'ai eu un peu de mal à me lever ce jeudi matin. Grave erreur... arriver à 9h00, c'est louper à coup sûr les keynotes...

C'est parti pour le récap' du jour 2 !

## Langage, IA et propagande : la guerre des récits a déjà commencé

Vous l'avez compris, j'ai donc loupé la première keynote, qui était a priori très réussie. Qu'à cela ne tienne, plutôt que me tasser dans une salle d'overflow (certaines étaient pleines aussi de toute façon !), je suis allé faire le tour des sponsors à la place.

Néanmoins, c'est une session que je vais certainement regarder en replay.

## Anatomie d'une faille - l'attaque xz utils

À 10h30, j'ai pu assister à une présentation qu'on m'avait déjà plusieurs fois recommandée.

Il faut dire qu'Olivier a fait un super travail sur son talk récapitulatif de l'attaque sur xz utils (**la** CVE de 2024, ciblant de manière indirecte openssh).

Olivier a bien planté le décor et ne s'est pas contenté d'une analyse technique. Je connaissais plutôt bien cette partie pour avoir lu pas mal d'articles sur le sujet, mais je n'avais pas creusé l'aspect social engineering pour pousser le maintainer Lasse Collin à donner les "clés du camion" à Jia Tan.

![](/2025/04/oponcet.jpg)

Un must à voir si vous avez vaguement suivi l'histoire et que vous voulez un récapitulatif complet en 45 minutes chrono.

## Kubernetes : 5 façons créatives de flinguer sa prod

Mon talk du jour !! En amphi bleu en plus. 

![](/2025/04/amphibleu.jpg)

On ne va pas mentir, l'amphi bleu, c'est quand même une sacrée scène et même pour un speaker non débutant, ça fait quelque chose (d'ailleurs, j'ai entendu Rachel Dubois dira à peu près la même chose un poil plus tard dans la journée).

Coutumier des retours d'expérience d'incidents sur Kubernetes, en particulier des erreurs liées au GitOops (j'ai fait une typo, mais je la laisse volontairement parce que c'est rigolo), j'avais envie de sortir un peu des sentiers battus et d'évoquer cinq anecdotes ayant conduit à des incidents en prod (ou quasiment) qui soient *peu communes*.

Je ne pensais pas avoir de temps pour des questions et finalement, j'ai eu presque 10 minutes d'échange avec le public. Inattendu, mais enrichissant.

Voilà les slides :

* [Kubernetes : 5 façons créatives de flinguer sa prod 🔫](https://blog.zwindler.fr/talks/2025-kubernetes-5-facon-de-flinguer-prod/index.html)

Et après l'effort, le réconfort !

![](/2025/04/réconfort.jpg)

## TDD et IA

Après mon talk, j'ai voulu souffler (comme je le fais d'habitude) et je me suis isolé le temps de reprendre mon énergie. Pas de bol, j'ai laissé le temps filé et je suis arrivé deux minutes trop tard à l'entrée de l'amphi Maillot et j'ai vu la porte se fermer DEVANT moi. 

Un peu deg', car j'avais très envie de voir mon ancien collègue et ami Benoit Prioux et son talk TDD et IA.

Je ne résiste cependant pas à republier (avec son accord) le sketchnote de mon amie Ane :

![](/2025/04/tdd-sketch.jpeg)

Encore un replay à regarder 🙃.

## Dans les coulisses des géants de la Tech !

À 13h30, Rachel Dubois, experte product ayant travaillé pour ou en contact avec plusieurs grosses licornes tech, a partagé des insights sur les problématiques "produit" et l'importance de mesurer l'impact business de ce qu'on code. 

Elle a insisté sur le fait que mouvement n'est pas la même chose que le progrès et que les ingénieurs doivent être au cœur de l'innovation.

![](/2025/04/licornes.jpg)

Grosso modo, ça a beaucoup parlé de mesure d'impact des features codées, de feature flipping, d'expérimentations lives sur des grandes populations, de design systems pour faciliter les créations de "variants" de l'UI/UX.

C'était plein de bon sens, mais je n'ai pas non plus été hyper surpris, notamment sur la partie "technique". Mais peut-être que c'est parce que Deezer faisait mieux les choses que la moyenne ?

Point que je note quand même, Rachel a insisté sur le fait que les ingénieurs ne sont pas des prestataires lambda et que tech == business. Et ça, même dans une belle boite tech, c'est un peu difficile à rentrer ça dans certains crânes.

## Pause sponsors

N'ayant pas de talks que je voulais *absolument* voir juste après, j'ai décidé de faire le tour des sponsors.

![](/2025/04/couloirs.jpg)

J'ai eu des discussions intéressantes avec des gens de chez Sonatype, Couchbase et Mirakl.

On a finalement assez peu parlé de leur business et échangé sur un peu tout et rien. C'était agréable de ne pas être vu comme un prospect :). Ou a minima, que je ne l'aie pas ressenti.

## Question pour un container

À 17h00, j'ai participé à un quizz rigolo réalisé par Sherine Khoury et Aurélie Vache sur les containers et la spec OCI. 

![](/2025/04/question_container.jpg)

Bon, ayant eu faux à la 2ème ou 3ème question (dans ce genre de quizz, les formulations sont parfois ambigües), je savais que c'était mort donc j'ai laissé tombé xD.

Mais j'ai regardé les démos et écouté les explications, c'était intéressant !

## Infisical : Le meilleur ami des devs pour des secrets bien gardés !

Encore un gros regret : j'ai aussi loupé le talk de Julien Briault sur Infisical...

J'ai encore trop discuté, on ne peut pas tout faire (voir plus bas...).

## Panel Staff 42

À 19h00, j'ai assisté à un panel de staff (et principal) engineers. 

Les panelists ont discutés de la manière de trouver l'impact par rapport au produit et au business, et aussi de comment un contributeur individuel peut continuer à évoluer sans devenir staff.

![](/2025/04/staff42.jpg)

C'était intéressant d'avoir plusieurs points de vue, les panelistes travaillant dans des entreprises très diverses et avec plusieurs niveaux de maturités par rapport aux ladders Staff+ (notamment en France).

Petites citations "random" :

> N'attendez pas qu'on vous sollicite pour faire des feedbacks. Donnez-en sans attendre qu'on vous le demande.

> Être staff, est-ce que ce n'est pas un peu être psy ? Écouter les gens, trouver les problèmes qu'ils / elles ne voient pas.

> Il faut valoriser le rôle de staff sans imposer aux gens de devenir staff pour évoluer en salaire.

On a terminé par une question un peu complexe qui n'a (a mon sens) pas été répondue. 

On demande aux gens de chercher la visibilité, en interne et parfois aussi en externe, s'ils veulent devenir staff (ou plus). Mais comment on fait pour garder l'équité avec ceux qui font **bien** leur travail pendant leurs heures, mais n'ont pas de temps (car on les charge trop ?) pour chercher cette visibilité durant les heures de travail ?

Et c'est encore plus vrai quand on **demande** de l'engagement **en dehors** des heures de travail (BBL, meetups le soir, conférences le week end).

C'est un point tricky et je n'ai pas plus de réponse.

## Meet and greet / réseautage tout au long de la journée 

Aujourd'hui, j'ai loupé plusieurs talks qui m'intéressaient, tout simplement parce que j'ai été absorbé par des discussions passionnantes avec de nombreuses personnes, rencontrées pour la première fois pour certaines, ou de vieux copains/copines.

Merci en particulier à Fanny, Erwan, Paul, Olivier, Pierre, le mystérieux "DarkSidious" (hihi), mais aussi Quentin, Geoffrey, Jean-Philippe, Loïc, Mickaël, Mazlum, Cécile et surement d'autres personnes que mon cerveau fatigué par deux jours de confs aura malheureusement zappé (désolé).

C'était vraiment top :-\).