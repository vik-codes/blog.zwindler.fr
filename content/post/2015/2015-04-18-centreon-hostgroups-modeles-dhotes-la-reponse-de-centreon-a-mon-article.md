---
title: 'Centreon / hostgroups / modèles d’hôtes, la réponse de Centreon à mon article'
authors:
  - zwindler
type: post
date: 2015-04-18T21:05:59+00:00
url: /2015/04/18/centreon-hostgroups-modeles-dhotes-la-reponse-de-centreon-a-mon-article/
image: /2015/04/Centreon-Monitoring-Services-AllServices-2.jpg
categories:
  - Monitoring
tags:
  - Centreon
  - changement massif
  - host
  - hostgroup
  - modèle
  - "modèle d'hôte"
  - réponse
  - service
  - servicegroup
  - template

---
J’ai reçu une réponse par commentaire d’une personne de chez Centreon (apparemment) à la suite de mon article </2014/09/11/rage-non-centreon-nautorise-pas-les-hostgroups-pour-les-modeles-dhotes/>

Pour rappel, Centreon gère les héritages via les modèles d’une façon un peu différente de Nagios. Au moment de la création de l’hôte dans Centreon, l’héritage est « aplati » et les services sont unitairement créés sur l’hôte, qui devient autonome. La configuration ainsi générée est simplifiée.  
S’il y a surement de nombreuses raisons pour procéder de la sorte, une des conséquences et que, lorsqu’on met à jour un modèle d’hôte, les hôtes déjà créés ne bénéficient pas de cette mise à jour.

Je propose dans l’article en question plusieurs méthodes de contournement sans pour autant avoir de solution idéale, notamment via la liaison par de services à des groupes d’hôtes, qui eux restent dynamiques malgré quelques limitations.

**Laurent Pinsivy** (si c’est bien lui, on ne sait jamais trop avec L’Internet) en propose une autre.

## La « solution »

Admettons que je mette à jour mon modèle d’hôte Win_2K (par exemple, j’ajoute un service grâce à un modèle de service).  
Pour que les serveurs prennent en compte l’ajout du nouveau service, je commence par filtrer l’ensemble des serveurs qui héritent de ce modèle :  
![](/2015/04/01_technique_centreon.png)

Je peux ainsi sélectionner l’ensemble des serveurs qui héritent _directement_ (c’est important) de ce modèle, puis via l’option « Changement Massif » les modifier tous d’un coup.  
![](/2015/04/02_technique_centreon.png)

Pour que les paramètres modifiés dans le modèle soient propagés dans les hôtes en héritant, je coche l’option « Créer aussi les services liés au modèle ». Centreon réitère le processus d’aplatissement de l’héritage -comme lors de la création de l’hôte- ce qui a pour effet de remettre à jour nos hôtes.  
![](/2015/04/03_technique_centreon.png)

**Petite subtilité :** selon ce que l’on souhaite faire, il faut positionner le mode de mise à jour à « Incrémentale » dans le cas d’un ajout dans le modèle et « Remplacement » pour une modification d’un des attributs du modèle.

## Mon avis après test

J’ai quand même de gros doutes sur cette « solution » :

  1. [à mon gout] c’est beaucoup moins souple/pratique que le mode d’héritage de Nagios, voire même l’utilisation des services par groupes d’hôtes (même si il faut bidouiller pour gérer les exceptions).
  2. J’ai donné ici l’exemple d’un ajout ou de la modification d’un service existant. Pour la suppression d’un modèle, je ne suis sûr ni des impacts ni même que ça fonctionne...
  3. Si je modifie un modèle (generic-host par exemple) dont hérite un modèle fils (win_2k), et que je filtre sur le modèle père, je ne vais sélectionner que les hôtes qui héritent explicitement du modèle père.  
    On « oublie » alors tous ceux qui héritent du modèle fils (et donc implicitement du modèle père), alors qu’ils sont pourtant potentiellement concernés si le modèle fils n’écrase pas certains paramètres. C’est pourtant souvent le cas, c’est l’intérêt même de l’héritage multiple.

Une fois encore, je peux rater quelque chose. Mais en l’état, pour moi, le manque reste entier ;-)
