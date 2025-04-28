---
title: Monter une CoP (Community of Practice)
authors:
  - zwindler
type: post
date: 2021-03-23T07:20:00+00:00
excerpt: Monter une community of practice (CoP ou communauté de pratique) pour améliorer la diffusion de la connaissance au sein de votre entreprise / collectif
url: /2021/03/23/monter-une-cop-community-of-practice/
image: /2021/03/01_Icon-Community@2x.png
categories:
  - Divers
tags:
  - Agile
  - Community of practice
  - CoP
  - devops
  - LEAN
  - SAFe
  - SRE

---
## T’es ma meilleure CoP !

Il y a 6 mois, quand j’ai changé d’entreprise, j’entendais parler pour la première fois du terme CoP (« Community of Practice », « Communauté de Pratique » en français). 

L’entreprise dans laquelle je travaille est une des rares licornes Françaises. J’y ai découvert tout un tas de pratiques et en particulier **les CoP**. 

Ça tombait super bien que je n’y connaisse rien, parce que la première chose qu’on m’a demandé de faire lorsque je suis arrivé dans ma nouvelle entreprise, **c’est de monter une CoP**. Et vous le savez, j’adore apprendre des nouveaux trucs ;-).

## Mais revenons un instant aux fondamentaux

Ce terme a été inventé par **Etienne Wenger**, est un théoricien de l’éducation. Dans les années 90, il a étudié comment des groupes de personnes qui travaillent ensemble faisaient pour résoudre plus efficacement des problèmes qu’ils ont en commun.

Ce terme est ensuite repris par le SAFe (le Scale Agile Framework), qui voit les Community of Practices comme des piliers prépondérants des entreprises LEAN et qui en donne la définition suivante (Agile bingo spotted).

> Communities of Practice (CoPs) are organized groups of people who have a common interest in a specific technical or business domain. They collaborate regularly to share information, improve their skills, and actively work on advancing the general knowledge of the domain.
> © Scaled Agile, Inc.
> [www.scaledagileframework.com/communities-of-practice/](https://www.scaledagileframework.com/communities-of-practice/)

![](/2021/03/agile.png)

Une CoP est donc :

  1. **un groupe de personnes qui se retrouvent régulièrement**
  2. **pour parler d’un centre d’intérêt commun (souvent un sujet technique, mais pas forcément)**
  3. **pour partager et faire profiter les autres de leurs succès comme de leurs échecs et ainsi faire progresser tout le groupe**

On retrouve donc 3 notions importantes, qui sont d’ailleurs des notions qui proviennent du travail de Wenger (ça tombe bien !), que vous verrez peut-être sur Internet sous les noms « Domain (2.) », « Practice (3.) » et « Community (1.) ».

[Edit] Un point que j’oublie d’aborder et que la CoP, doit être un lieu de partage et d’inclusion. Il faut qu’elle se déroule dans un climat bienveillant pour que tout le monde puisse se sentir à même de partager. De ce fait, il est également conseillé d’y privilégier un cadre informel/détendu (ce qui me convient parfaitement, je peux faire des jeux de mot pourris en toute impunité).

## Mais est ce que ça sert vraiment ?

> Jean Michel Petit Chef : Ben oui, parce que ça coûte cher quand même tous ces meetings entre Dev (et Ops) alors bon faudrait pas que ça coûte plus cher que mes meetings productivity-bingo-bullshit. (troll inside)

Si jamais comme **JMPC** vous êtes un peu sceptiques, vous pouvez aussi jeter un œil au programme DORA (DevOps Research and Assessment) et son State of DevOps 2019, qui montre que les plus great-performers (ceux qui sont agiles et shiny) sont ceux qui implémentent, entre autres, ce genre de communautés. A l’inverse, les low-performers ont plutôt tendance à monter des centres d’excellence ou de formation, qui ont tendance à « siloter » la connaissance.

> High performers favor strategies that create community structures at both low and high levels in the organization, likely making them more sustainable and resilient to reorgs and product changes. The top ... strategies employed are Communities of Practice [...]
>
> Low performers tend to favor Training Centers (also known as DOJOs) and Centers of Excellence (CoE)—strategies that create more silos and isolated expertise.
>
> [DORA State of DevOps 2019](https://services.google.com/fh/files/misc/state-of-devops-2019.pdf)

Si vous vous présentez comme « le nouveau Google/Amazon/Uber français », vous savez maintenant ce qu’il vous reste à faire (troll, encore).

Dans mon entreprise, il existe une petite dizaine de CoP, de taille et de fréquence très diverses les unes des autres. 

La plupart du temps, le but est de partager l’expérience et les bonnes pratiques entre tous les membres de la CoP, mais aussi présenter de nouveaux outils, de nouvelles façons de travailler, discuter des « pain-points » qui pénalisent les équipes, leur trouver des solutions rapides ou bien préparer les arguments pour prioriser leur résolution au prochain trimestre.

Grosso modo, dès que vous avez des groupes d’experts quelconques qui rencontrent plus ou moins les mêmes genres de problématiques, ça vaut le coup de monter une CoP pour éviter de réinventer la roue. Ou qu’au contraire une partie du groupe utilise des roues **carrées** alors qu’une autre équipe a déjà des roues rondes à disposition.

## Tu m’as convaincu, comment j’en monte une ?

Avant de monter une CoP, il faudrait peut-être qu’elle ait une raison d’être, non ? Pour la trouver, il va falloir répondre aux questions suivantes :

  * « Quel sujet avons nous en commun et nous intéresse ? » (**Domain**)
  * « Qu’avons nous à partager ? Des retours d’expériences, des bonnes pratiques, de la technique pure? » (**Practice**)
  * « Qui sont les membres de la communauté ? » (**Community**)

Pour ces 3 questions, il n’existe pas de réponses universelles. 

### Domain

Il n’y a pas deux entreprises pareilles et il est donc normal qu’il n’y ait que **vous** qui puissiez savoir si une CoP sur le dernier framework Javascript à la mode, sur l’UX Design ou bien sur les principes SRE a du sens dans **votre** entreprise. 

### Community

On distingue deux types de communautés pour créer un CoP. Les communautés par Rôle (role-based), c’est à dire qui vont regrouper un certain type d’individus/de métier bien précis et les communautés par Sujet (Topic-based).

Pour ces derniers types de communautés (Topic-based), je pense qu’il faut construire la communauté la plus large possible du moment que les participants sont motivés. Ne soyez pas sectaires, tous les points de vue sont les bienvenus, pourvu qu’ils soient constructifs. 

Un exemple un peu bateau mais parlant, n’hésitez pas à intégrer des Devs qui s’intéresseraient à votre CoP sur les bonnes pratiques Ops (ou l’inverse).

> Regardez bien, je suis à deux doigts d’inventer le DevOps

</blockquote>

### Practice

Posez vous dès le début la question de ce que vous voulez partager en CoP (j’ai donné des exemples plus haut), mais aussi de la façon dont vous allez les organiser.

  * Quel format (présentation, séance de questions/réponses, brainstorming, mob, dojo ...) ? 
  * Quelle durée (30 minutes, 30 minutes + 30 minutes de questions, 2h, ...) ?
  * Quelle fréquence (hebdomadaire, mensuel, **toutes les lunes gibbeuses**, ...) ?

Il faut trouver la combinaison durée/créneau horaire qui arrange le plus de membres possible, tout en essayant de trouver une régularité qui favorisera la durée de vie de la CoP. Ne décidez pas de faire une CoP hebdomadaire si vous n’êtes pas capable de tenir le rythme sur le long terme !

> Ce n’est pas un sprint mais une course de fond

## La vie de la CoP

Comme toute organisation, une CoP n’a pas forcément vocation à être éternelle. On imagine bien qu’une CoP sur un framework qui n’existe plus dans l’entreprise disparaîtra d’elle même... 

De même, il est normal que certains membres de la CoP soient plus impliqués que d’autres. Si vous voulez que votre CoP ait un intérêt maximal, le but du jeu sera évidemment de fédérer le plus de gens **motivés** possibles. 

C’est évidemment plus facile à dire qu’à faire... #Yakafokon

Pour vous aider, n’hésitez pas à confronter l’idée que vous vous faites de votre CoP (Domain/Community/Practice) avec les gens que vous imaginez être vos futurs membres. Interrogez-les, faites un sondage sur ces points. 

Demandez à vos collègues s’ils ont des sujets dont ils souhaiteraient discuter en groupe. **Voire même des sujets qu’ils souhaiteraient présentez eux même.**

Ce dernier point est capital pour le succès de la CoP. Si c’est toujours la même personne qui présente, cela risque fort de devenir son travail à temps complet (surtout si vous avez une fréquence hebdo). 

Pire, les autres membres communauté seront passifs et les membres risquent de s’en désintéresser progressivement.

Il faut donc recruter des membres actifs, que tout le monde se sente impliqué.

## Les outils de la CoP

Pour faciliter la collaboration des membres et maintenir une activité, n’hésitez pas à mettre en place des outils.

Vous utilisez très probablement un outil de messagerie instantanée, n’hésitez pas à créer un channel public dans lesquels vos participants pourront échanger entre les réunions, soit pour rediscuter d’un point vu en CoP, soit pour partager un article déniché pendant la veille. Ce channel servira aussi à recruter d’autres membres et à rappeler les futurs meetings.

Vous pouvez aussi créer un board (type Kanban) dans lequel tous les sujets à venir sont listés dans des tickets. Les membres de la CoP peuvent en ajouter, voter pour les sujets qui les intéressent le plus (aka les aideront le plus dans leur travail), prendre certains sujets pour les présenter eux même. Les tickets sont déplacés dans les colonnes « En cours », « Planifié » et « Terminé » en fonction du planning.


![](/2021/02/COPS.png)

Dans la CoP que j’ai créé, j’ai également souhaité qu’à la fin de chaque meeting, un ROTI (Return on Time Invested) soit organisé. De cette manière, tous les participants peuvent donner un feedback honnête sur l’intérêt qu’ils portent sur le temps qu’ils viennent de consacrer. Cela permet de jauger l’intérêt que la communauté a pour les meetings que vous organisez, voire de corriger si jamais certains membres s’ennuient.

Une sorte de prise du pouls de votre CoP. 

En cette période de confinement, vous pouvez trouver des outils en lignes pour éviter de compter les doigts sur chaque main levée.

![](/2021/02/roti.png)

## Le facilitateur

En tant que « CoP leader », vous aurez un rôle de facilitateur. A vous de vous assurer qu’il y a suffisamment de sujets pour faire vivre la CoP, de recruter des orateurs pour présenter des sujets, d’animer le channel et le board.

Pendant la CoP, vous devrez aussi jouer le rôle de timekeeper. Entre passionnés, les discussions ont vite fait de traîner en longueur, car on s’égare sur un point précis qu’on trouve intéressant (moi le premier !). Or, il faut absolument se tenir au créneau choisi pour que tous les membres puissent participer dans de bonnes conditions. 

A vous aussi de vous assurer que ce n’est pas toujours les mêmes qui prennent la parole. C’est la partie que personnellement je trouve la plus dure, car je travaille avec des passionnés qui ont une très grande connaissance, mais il faut absolument laisser de la place pour tout le monde, notamment ceux qui maîtrisent moins.

Enfin, vous aurez peut-être besoin de jouer le rôle de scribe (prise de note et retranscription résumée des débats/questions, tenue d’une page de wiki, sauvegarde des vidéos, etc) pour garder une trace du travail réalisé et de l’éventuel suivi des actions réalisées et à faire.

Il n’est pas impossible que ce travail « autour de la CoP » soit aussi consommateur en temps (voire plus !) que la CoP. 

## Conclusion

J’ai vraiment adoré avoir la responsabilité de monter une Community of Practice. Les débats qu’on a lors des réunions sont passionnants et pour ne rien gâcher, les retours sont vraiment bons.

Après quelques meetings, la CoP semble maintenant bien implantée chez nous, avec plusieurs sujets à venir, de plusieurs speakers et une vingtaine de membres à chaque fois (sur 40 inscrits).

Plusieurs sujets utiles pour les membres ont été présentés, dont certains qui ont eu des impacts sur les déploiements en Prod (best practices).

La quantité de travail est conséquente. Je l’avais anticipé, mais j’ai été surpris par la quantité de travail **autour** de la CoP (le rôle de facilitateur).

Enfin, pour la fréquence des meetings, j’ai été un peu frileux. J’avais trop peur qu’on s’épuise, j’ai proposé un rythme mensuel, alors qu’on a trop de sujets à traiter. Résultat, les sujets n’avancent pas aussi vite qu’on voudrait et ça créé de la frustration pour ceux qui attendent les sujets pas encore traité. Pour autant, je préfère ça que le contraire, et il est encore temps de corriger en augmentant la fréquence.

J’espère vous avoir convaincu :)

## Sources

* [www.scaledagileframework.com/communities-of-practice](https://www.scaledagileframework.com/communities-of-practice/)
* [fr.wikipedia.org/wiki/Communauté_de_pratique](https://fr.wikipedia.org/wiki/Communaut%C3%A9_de_pratique)
* [www.communityofpractice.ca/background/what-is-a-community-of-practice/](http://www.communityofpractice.ca/background/what-is-a-community-of-practice/)
* [rework.withgoogle.com/blog/five-keys-to-a-successful-google-team/ (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20180726114909/https://rework.withgoogle.com/blog/five-keys-to-a-successful-google-team/)
  * [cloud.google.com/solutions/devops/devops-culture-westrum-organizational-culture (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20201107234846/https://cloud.google.com/solutions/devops/devops-culture-westrum-organizational-culture)
  * [cloud.google.com/solutions/devops/devops-culture-learning-culture (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20201101054850/https://cloud.google.com/solutions/devops/devops-culture-learning-culture)
