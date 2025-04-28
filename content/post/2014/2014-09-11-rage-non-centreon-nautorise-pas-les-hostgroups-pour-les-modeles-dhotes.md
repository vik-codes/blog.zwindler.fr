---
title: 'Non, Centreon n’autorise pas de hostgroup pour les modèles d’hôtes'
authors:
  - zwindler
type: post
date: 2014-09-11T10:23:08+00:00
url: /2014/09/11/rage-non-centreon-nautorise-pas-les-hostgroups-pour-les-modeles-dhotes/
image: /2015/04/Centreon-Monitoring-Services-AllServices-2.jpg
categories:
  - Monitoring
tags:
  - best practice
  - Centreon
  - "groupe d'hôte"
  - héritage
  - host template
  - hostgroup
  - "modèle d'hôte"
  - Nagios
  - service

---
Ce post met en avant un manque dans Centreon, outil que j’utilise par ailleurs en production depuis plusieurs années. A part ces fameux manques que je vais détailler, c’est un très bon outil.

Il permettra aux personnes qui découvrent Nagios ou Centreon d’avoir une meilleure approche des deux outils sur les problématiques d’industrialisation et de mutualisation de la configuration.

**Disclaimer :** ce n’est pas parce que je rencontre des difficultés pour réaliser certaines opérations que je connais toutes les manières de gérer une configuration Centreon de manière optimale. J’ai des habitudes qui me viennent de l’utilisation d’autres outils (de supervision ou non) qui biaisent peut être mon jugement.

[Edit] Dans les commentaires j’ai reçu une réponse de Laurent Pensivy (apparemment) de Centreon. Il propose d’utiliser un mécanisme de Centreon qui contourne le problème, selon lui. [Voilà ce que j’en pense][1]. [/Edit]



## Industrialisation/mutualisation : de quoi parle t-on ?

Dans la supervision Nagios et les outils compatibles/similaires, les templates (modèles) permettent de gagner du temps. On définit X modèles qui permettent eux mêmes de définir une bonne fois pour toutes les paramètres communs à plusieurs hôtes ou à des services. Cette façon de penser est héritée de la programmation orientée objet.

C’est très utile pour les contacts de nos hôtes/services (les problèmes sur les hôtes windows génèrent des alertes pour les administrateurs windows) ou les fréquences de vérifications (on vérifie le ping des serveurs toutes les 5 minutes, quelque soit le serveur), mais pas seulement.

On peut aussi vouloir affecter au modèle « serveurs windows » toutes les vérifications (checks) d’usage qui sont normalement attendues pour la supervision minimale d’un serveur windows. On définit ainsi un socle commun (ping, disque C:, et RAM par exemple).

Dans Nagios, je peux lier un service à des hôtes ou des groupes d’hôtes (ou les deux). Mais pour ce qui est des modèles d’hôtes, ajouter un service à un modèle d’hôte n’a strictement aucun effet.

Et en fait c’est logique : je me répète, mais Nagios a une configuration orienté objet. Du coup, un « service » doit être vu comme un « objet réel » (i.e. qui existe), contrairement à modèle qui est lui un objet abstrait. On ne peut pas affecter un objet réel à un objet abstrait. En réalité, il faut passer par un modèle de service, si on souhaite affecter automatiquement des services à un groupe.

## Ce que moi je souhaite faire

Concrètement, si je souhaite affecter un même service à un ensemble donné d’hôtes, les premières solutions simples qui me viennent à l’esprit sont :

  * affecter le service serveur par serveur (ou une liste de serveur)
  * lier le service à un groupe d’hôtes : si j’ajoute ou je supprime un serveur du groupe, je n’ai pas de modification à apporter sur le service
  * lier un modèle de service à un modèle d’hôte, puis affecter ce modèle aux hôtes concernés. Idem

Les trois solutions sont parfaitement valides dans une configuration Nagios.

Cependant, vous conviendrez que la première méthode est difficilement maintenable sur un parc important avec de nombreux services, et on préfèrera généralement utiliser les deux suivantes.

En outre, la dernière à l’avantage de permettre de créer des sous-modèles (qui héritent eux même de modèles) et ainsi gérer certains cas particuliers.

## Les cas particuliers: parlons en !

Imaginons que j’ai un groupe d’hôte hostgroup-linux, qui contient mes 200 serveurs Linux, et que j’ai lié 5 services communs à ce groupe d’hôtes. Cependant, pour des besoins qui me sont propres, j’ai 3 serveurs dont je vérifie l’état de la RAM via SNMP dont les seuils diffèrent de la grande majorité.

En ne résonnant qu’avec des hostgroups, je pourrais :

  * soit créer deux groupes distincts (hostgroup-linux et hostgroup-linux-specific-RAM) pour gérer les deux seuils, mais cela m’obligerait à dupliquer l’ensemble des autres services communs aux deux groupes.
  * soit de garder un groupe mutualisant tous les services communs, et créer deux groupes contenant juste le service avec les deux seuils distancts.

Dans tous les cas, je multiple les services et les groupes à gérer, ce qui multiplie également le risque d’erreurs.

Si maintenant j’utilise des modèles d’hôtes. Je vais :

  * créer un modèle d’hôte host-linux sur lequel j’affecte les modèles de services avec les seuils qui vont bien pour mes 5 services
  * créer un module d’hôte host-linux-specific-RAM qui hérite du modèle host-linux, et auquel je n’ajoute qu’un seul modèle de service (la RAM avec le seuil spécifique)

Ainsi, je n’ai dupliqué que ce qui est nécessaire pour gérer mes deux cas et je limite les erreurs possibles.

## Comment Centreon gère sa configuration

Un des avantages de Centreon par rapport à un serveur Nagios simple (ou même d’autres outils similaires/compatibles avec la configuration Nagios) est qu’il vous permet de gérer la configuration de votre supervision et de votre parc depuis l’interface graphique web. C’est un gros point positif pour les équipes techniques qui ne disposent pas d’un « Nagios Guru » et qui veulent s’affranchir de la maintenance de la configuration par fichier plat.

Cependant, comme Centreon n’est ni plus ni moins qu’une surcouche à Nagios (un peu moins vrai aujourd’hui puisque Merethis développe de plus en plus, et notamment son propre moteur), ce choix implique la gestion d’un référentiel à part (MySQL) qui est ensuite utilisé pour générer une configuration texte « Nagios-compatible » à la demande.

Cela a impliqué des choix, notamment en terme de simplification de la configuration générée. Les possibilités offertes par Nagios en terme de configuration sont très riches, et tout implémenter aurait probablement conduit à des erreurs de configuration lors de la génération. La configuration générée est donc un peu simplifiée par rapport à ce que Nagios peut gérer.

Par exemple, alors qu’un seul service (1 seul objet) peut être défini pour X hôtes et Y groupes d’hôtes, Centreon génère un service pour chaque hôtes et chaque groupes d’hôtes concernés, ce qui simplifie grandement la génération de la configuration texte pour Centreon mais la rend illisible pour un administrateur habitué à lire sa conf Nagios.

Mais ce n’est pas tout, car comme je le martèle depuis le début, toutes les possibilités ne sont pas possibles, et certaines sont beaucoup plus visibles!

## Les bests pratices de Centreon

Pour permettre à tout le monde de s’en sortir, Centreon fourni une liste de best practices sur l’utilisation des templates pour expliquer leur fonctionnement spécifiquement dans Centreon.

* [blog.centreon.com/good-practices-host-templates-and-service-templates-how-they-work-together/](https://blog.centreon.com/good-practices-host-templates-and-service-templates-how-they-work-together/)

(ou la version Française [blog.centreon.com](https://blog.centreon.com/40/?lang=fr))

On y apprend grosso modo la même chose que ce que je viens de dire, à savoir qu’il est plus malin de créer des templates pour associer les services à des hôtes que de le faire à la main.

## Pourquoi ça me gène de ne pas pouvoir mettre d’hostgroup dans mon template

L’article et ses commentaires montre bien que les équipes de Centreon et leur communauté ont bien conscience de l’importance des templates, de l’ordonnancement des templates lors de la création d’un hôte et du besoin de donner accès à le plus de mécaniques de Nagios possible pour industrialiser la gestion d’un parc (qui évolue dans le temps).

Bien ! Pourtant, il me semble qu’ils ne sont pas allés au bout de la démarche. Comme on peut le voir lors dans l’article de Centreon (ou en réalité), la modification d’un modèle d’hôte permet d’affecter **à la création** les services liés aux modèles d’hôtes (UNIQUEMENT!!!).

Si pour une raison ou pour une autre, vous avez besoin d’ajouter un nouveau service à un template (et donc l’ajouter pour l’ensemble des hôtes qui héritent de se template), vous devrez donc retourner sur tous les hôtes qui héritent de ce template pour cliquer sur le bouton de création des services liés. On perd dont l’intérêt du template (flexibilité/évolutivité).

![](/2014/09/centreon_template_1.png)

Un moyen de contourner cette limitation serait de pouvoir affecter des groupes d’hôtes à des modèles d’hôtes. C’est possible dans Nagios, c’est même plutôt recommandé pour définir des icônes ou des contacts par défaut.

Ici, plutôt que d’affecter le modèle de service à un modèle d’hôte, on passe par l’intermédiaire d’un groupe d’hôte. Concrètement, le service service-XXX est lié au groupe d’hôtes hostgroup-XXX, et les membres du groupes d’hôtes sont définit dynamiquement par l’héritage des hôtes au template host-template-XXX.

Ainsi, si on enlève ou ajoute des hôtes avec le bon template, les services seront créés/supprimés dynamiquement. Idem si on lie/délie des services au groupe d’hôtes. Cependant, cette fonctionnalité est absente de Centreon. Il n’est à date pas possible de définir des groupes d’hôtes sur un modèle d’hôtes (alors que l’écran dans l’interface graphique web semble prête pour).

![](/2014/09/centreon_template_2.png)

Comme dirait Dark Vador

> Sense : the absence of this feature makes none

![](/2014/09/darthvaderintheocean.jpg) 

[Edit] Dans les commentaires j’ai reçu une réponse de Laurent Pensivy (apparemment) de Centreon. Il propose d’utiliser un mécanisme de Centreon qui contourne le problème, selon lui. [Voilà ce que j’en pense](/2015/04/18/centreon-hostgroups-modeles-dhotes-la-reponse-de-centreon-a-mon-article/). [/Edit]
