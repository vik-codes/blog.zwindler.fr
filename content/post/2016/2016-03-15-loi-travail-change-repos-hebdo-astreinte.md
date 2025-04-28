---
title: Est ce que la loi travail a changé le repos quotidien en astreinte ?
authors:
  - zwindler
type: post
date: 2016-03-15T07:15:36+00:00
url: /2016/03/15/1865/
image: /2016/03/loitravail_logo.png
categories:
  - Droit
tags:
  - astreinte
  - diff
  - fractionnement
  - JuriTravail
  - Legifrance
  - loi
  - Loi travail
  - loitravail.lol
  - projet
  - vrai-faux

---
## Avec la loi travail, le repos quotidien ne serait plus nécessairement consécutif en cas d’intervention en astreinte ?

_[Disclaimer] Je ne suis pas juriste, juste sceptique de nature, procédurier et têtu. Cette analyse est donc à prendre avec les pincettes de rigueur._  
 _Et c’est d’ailleurs là où je veux en venir avec cet article : Ne croyez pas tout ce qu’on vous dit !!!_  
 _Si un sujet vous tient à cœur, allez vérifier vous même de quoi il retourne pour vous faire une idée plutôt que tout gober tout cru ! [/Disclaimer]_

En tant que Sysadmin, on croise souvent l’astreinte. Alors quand j’ai lu ça il y a quelques semaines sur [loitravail.lol][1], je vous laisse imaginer ma colère :

> Aujourd’hui, si le salarié est amené à intervenir au cours de sa période d’astreinte, il a droit à un repos intégral (donc de onze heures) après cette intervention. Désormais, on pourra décompter des onze heures le temps d’astreinte ayant précédé l’intervention.

Ceux qui sont régulièrement d’astreinte savent comme moi que lorsqu’on intervient entre minuit et 2h puis de 4h à 6h du matin, il n’y a aucune chance pour qu’on soit prêt à repartir pour une journée de travail dans de bonnes conditions le lendemain à 9h. Même si ça fait effectivement 11h de repos (exemple en débauchant à 18h, début de l’astreinte) et surtout si ça dure comme ça toute une semaine !

## OK ok, Mais est ce vrai ?

Alors, bien sûr, de formation scientifique et sceptique de nature, j’ai voulu vérifier ma source. _[Aparté]Parce que déjà c’est en partie erroné. Il me semble que si vous avez déjà eu vos 11h et que vous êtes appelé APRÈS, vous avez eu vos 11h de repos quotidien, pas la peine d’en réclamer 11 de plus.[/Aparté]_

Il ne m’a pas fallu longtemps pour trouver le « Vrai-Faux » du gouvernement que vous avez sans aucun doute croisé sur le Net tant il a été repris, décortiqué, trituré par tous les sites d’informations ces derniers jours.

![](/2016/03/loi_travail.png)

Bon, moi je vois un site en *.**gouv.fr**, c’est un document officiel de promotion de la loi : on peut leur faire confiance ! S’ils disent qu’on pourra fractionner le repos quotidien dans le cadre de l’astreinte alors qu’avant on ne pouvait pas, c’est que c’est bien le projet.

S’ensuit donc naturellement un départ en croisade contre cette idée saugrenue qu’on peut **fractionner le repos légal en astreinte sans craindre que les astreinteurs ne finissent sur les rotules** en fin de semaine (vécu...).

## LAC : Law As Code

A l’occasion du ralliement de la CFDT à ce texte de loi, je décide qu’il est temps de m’armer d’un peu plus d’arguments factuels sur le sujet pour attaquer comme les jurisprudences et les textes de loi (notamment Européens) sur la question.

Je tombe sur [cet article de JuriTravail][2]. Je suis très surpris de ne rien voir sur cette histoire de fractionnement des heures du repos consécutif qui me parait pourtant être une modification majeure dans la façon de gérer l’astreinte. Les gens de JuriTravail sont bons à ma connaissance (et ils sont juristes eux, contrairement à moi!), donc j’ai de nouveau un doute.

Ni une ni deux, je file sur Internet pour me livrer à un petit « diff » entre l’avant projet de loi ([disponible en PDF ici (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20230804065839/https://www.gouvernement.fr/sites/default/files/contenu/piece-jointe/2016/02/avant-projet_de_loi_visant_a_instituer_de_nouvelles_libertes_et_de_nouvelles_protections_pour_les_entreprises_et_les_actifs.pdf), même si ce n’est pas celui avec les modifications d’aujourd’hui) et [les textes de loi actuels sur Legifrance][4].

![](/2016/03/winmerge_projet_loi-1.png)

De ce que j’en vois, les différences sont :

  1. Une modification de la définition de ce qu’est une période d’astreinte où on rappelle bien qu’on est pas sur son lieu de travail (aka permanence) et qui retire « l’obligation de demeurer à son domicile ou à proximité » **ce qui me parait être une bonne chose**.
  2. Une modification du délai de prévenance de 15 jours (ou 1 en cas de dérogation) par « un délai raisonnable ». Moins rigide, peut être la porte ouverte à des abus ? De toute façon la clause des « circonstances exceptionnelles » permettaient déjà aux patrons qui veulent abuser de le faire donc **je ne vois pas de différence fondamentale**.
  3. Un paragraphe est ajouté pour préciser que le salarié qui intervient pour son entreprise pendant sa période d’astreinte doit bénéficier, à l’issue de la période d’intervention, d’un repos compensateur au moins égal au temps d’intervention.  
    Dans l’absolu, je n’arrive pas à voir quel cas ce paragraphe couvre et qui n’était pas couvert avant, mais **ça n’a pas l’air d’un recul** en terme de droits pour le salarié (et c’est l’avis de JuriTravail).
  4. Une refonte des conditions de mise en place de l’astreinte en 3 phases (Ordre public/Négociations collectives/Dispositions supplétives), qu’on retrouve d’ailleurs dans tout le projet de loi et qui apporte de la cohérence à l’ensemble mais qui fait aussi beaucoup grincer des dents (permettant aux dirigeants d’imposer des choses à défaut d’accords).

Alors bien sûr, je peux avoir loupé quelque chose ailleurs dans le projet de loi qui ferai que tout ce que je dis est faux. Et si vous en avez la preuve, je vous prie de me la donner ;-).

Mais pour l’instant, je ne vois _rien_ qui indique explicitement que maintenant (et pas avant) _on pourra décompter des onze heures le temps d’astreinte ayant précédé l’intervention_. NADA. Soit c’était déjà le cas aujourd’hui, soit ce ne sera pas le cas demain.

Ça ne change pas fondamentalement l’avis que j’ai sur la loi dans son ensemble et que je me garderai de donner ici. En revanche, ça me rappelle à l’ordre : toujours vérifier ses sources !

> Just my 2 cents.

## Bonus track - Définition du repos quotidien et hebdomadaire

Tout mon argumentaire pourrait s’effondrer si jamais les articles L 3131-1 et L. 3131-2 définissant le repos quotidien et hebdomadaire (cités dans les articles traitant de l’astreinte) sont modifiés dans ce sens.

Et ils ont été modifiés justement ! En voici le WinMerge :

![](/2016/03/repos_quotidien.png)

Là encore, la seule partie qui pourrait faire craindre un fractionnement du repos quotidien lors des astreintes est le fragment « ou par des périodes d’interventions fractionnées ».

Mais ce fragment de phrase est déjà dans la loi aujourd’hui !

Au risque de me répéter : soit c’était déjà le cas aujourd’hui, soit ce ne sera pas le cas demain.

 [1]: http://loitravail.lol/
 [2]: http://www.juritravail.com/Actualite/astreintes/Id/236941
 [4]: https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000006195760&cidTexte=LEGITEXT000006072050&dateTexte=20160314
