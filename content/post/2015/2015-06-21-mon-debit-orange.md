---
title: 'Est ce qu’Orange modifie les profils upload/download VDSL2 de ses clients ?'
authors:
  - zwindler
type: post
date: 2015-06-21T08:30:10+00:00
url: /2015/06/21/mon-debit-orange/
image: /2015/06/orange-w8.png
categories:
  - autohebergement
  - materiel
tags:
  - atténuation
  - débit
  - download
  - Free
  - gain
  - Livebox Play
  - Mini 4K
  - Orange
  - perte
  - Revolution
  - upload
  - VDSL2

---
[Edit]

A priori les tests de l’ARCEP semblent montrer qu’Orange est un « bon élève » en terme de débit par rapport aux autres opérateurs, même en upload. Pourtant, pour la même ligne, chez Free mon niveau d’atténuation est plus bas (donc débit plus élevé) et je n’ai pas d’erreurs de type CRC alors que c’était le cas avec Orange.

[Le dernier rapport de l’ARCEP et son analyse via NextInpact][1].

[/Edit]

Je ne suis pas fan de la théorie du complot. Mais j’ai quand même envie de partager cet étrange expérience que j’ai vécu chez Orange.

Petit recadrage sur le déroulement de l’histoire. D’abord, ça faisait des années que j’étais client Free. Etant à 874m du DSLAM, j’avais un débit ADSL2+ excellent avec une atténuation quasi parfaite (18Mbps/1Mbps). Cependant pour l’auto hébergement, l’upload était insuffisant. Je ne pouvais pas passer en VDSL2 pour des raisons marketing, même si ma ligne était éligible et même en changeant de modem (clients Révolution uniquement à l’époque).

Après m’être fâché tout rouge avec le service client de chez Free (qui n’a de service client que le nom, si vous voulez tout savoir), je suis momentanément parti chez Orange, qui pouvait enfin me faire profiter de VDSL2.

D’abord, j’ai découvert que le VDSL2 était très sensible à l’installation téléphonique du logement. Les débits dont je disposais initialement était inférieurs en download à de l’ADSL, et seulement légèrement supérieurs en upload, alors que j’espérais beaucoup mieux.

![](/2015/04/02_avant_coupure_branche_mortes2.png)

Avec l’aide de la communauté Orange, j’ai pu optimiser mon installation ([ici](/2014/09/11/enfin-du-vdsl2-supprimer-les-branches-mortes-quest-ce-que-cela-peut-bien-vouloir-dire/), et obtenir un débit download un peu meilleur. Mais surtout, c’est le gros gain sur l’upload par rapport à l’ADSL2+ qui était mon but initial. J’étais très content.

![](/2015/04/05_après_coupure_branche_mortes_et_changement_prise.png)

Après plusieurs semaines de débit stable (tests réguliers toutes les semaines), du jour au lendemain, j’ai vu mon débit descendant augmenter fortement et mon débit ascendant chuter d’autant. Bizarre. Je n’avais fais aucune modification sur mon installation, ni redémarré mes équipements.

Après quelques jours, ce débit s’est avéré être mon nouveau débit stable en VDSL2. J’ai demandé l’avis de la communauté sur le sujet mais n’ai eu que peu de réponses et n’ai pas eu de retours d’expériences similaires. Je ne peux donc pas généraliser. Cependant, le calendrier de la modification de mon débit concorde « étrangement » avec la publication de statistiques « Très haut débit » chez les opérateurs. Et comme par hasard, la notion de « Très Haut Débit » de l’ARCEP concerne les gens qui disposent entre autre d’une connexion avec un débit descendant supérieur à 30 Mbps... exactement comme mon nouveau débit descendant vu au niveau de la box (pas du speedtest : il y a toujours un delta)...

![](/2015/04/07_mon_debit.png)

![](/2015/04/06_après_evenement_inconnu.png)

Vous comprenez où je veux en venir. **Je n’ai aucune preuve de quoique ce soit, c’est juste mon ressenti**. A priori je ne suis pas un cas général car je n’ai vu personne d’autre sur les forums d’Orange avoir ce sentiment. J’imagine que dans le grand public, un gain en download est plutôt une bonne chose, même au détriment de l’upload.

Je ne sais même pas si c’est **techniquement possible** de « façonner » le débit montant/descendant.

Cependant, depuis que je suis retourné chez Free (Forfait Mini 4K, je ferai peut être un article ou deux), j’ai retrouvé EXACTEMENT le même débit que j’avais chez Orange au début, avec un download à un peu plus de 20 Mbps, et un upload à 5 Mbps.

![](/2015/04/09_après_mig_free.png)

Coïncidence? ...

 [1]: http://www.nextinpact.com/news/97221-qualite-internet-fixe-troisieme-bilan-beta-arcep-avec-debits-detailles-par-fai.htm
