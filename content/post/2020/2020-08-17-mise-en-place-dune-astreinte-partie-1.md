---
title: 'Mise en place d’une astreinte OPS – partie 1'
authors:
  - zwindler
type: post
date: 2020-08-17T06:43:56+00:00
excerpt: "Mise en place d'une astreinte, partie 1 qui se concentre sur les raisons d'une astreinte ainsi que les aspects législatifs"
url: /2020/08/17/mise-en-place-dune-astreinte-partie-1/
image: /2020/07/on-call-helmet.png
categories:
  - Droit
tags:
  - astreinte
  - droit
  - droit du travail
  - Legifrance

---

## Pourquoi parler d’astreinte ?
  
  
Il y a quelques ~~jours~~ semaines, on m’a fait passer un article sur le blog tech de [Decitre](https://tech.decitre.fr/posts/fonctionnement-asteintes-au-sein-de-decitre-interactive), qui décrit pourquoi et surtout comment ils ont mis en place leur astreinte Ops.

Étant moi-même d’astreinte depuis des années, c’est un sujet qui me parle particulièrement. Il y a plein de choses à aborder quand on parle d’astreinte, de l’organisationnel à la mise en place des outils techniques, en passant par un peu de droit du travail (et vous savez comme [ça me plait](/categories/droit/)).

Dans cette première partie, je vais parler de ce qu’est une astreinte, de pourquoi on en met en place et des lois en vigueur pour les instaurer.

Dans la seconde partie (plus fun) que je publierais plus tard (semaine prochaine ?), je parlerai des moyens techniques et de l’organisation de l’astreinte, telle que nous l’avons conçue.

## L’astreinte _ex nihilo_
  
  
J’ai déjà eu à travailler dans plusieurs contextes avec des astreintes. Mettre des gens en astreinte ne se fait _que_ pour répondre à un besoin bien précis (qui colle aux contraintes de la production). Souvent, les façons de faire de l’astreinte sont donc très différentes d’un contexte à l’autre.

Il y a 2 ans, j’ai intégré une équipe d’ingénieurs systèmes cloud qui venait de se créer. Quand les premiers produits et les premiers clients sont arrivés en production, le besoin d’assurer la continuité d’activité s’est fait sentir. Et donc, par extension, le besoin d’une astreinte.

J’ai donc eu la chance de pouvoir participer, étant directement concerné (et surtout un peu renseigné sur le sujet) à l’élaboration de cette astreinte. Ça a été l’occasion de traiter directement les aspects suivants :
  
* problématiques droit du travail
* organisationnel
* implémentation technique
      
  
Et je me disais que ça pourrait vous intéresser aussi de voir comment on fait pour créer une astreinte informatique en partant de rien.

## Mais d’abord, l’astreinte, pourquoi ?
  
  
Dès que la production (usine, magasin, ou tout autre activité) dépend de la disponibilité du SI. Le risque zéro n’existant pas (le fameux mythe du RPO / RTO = 0 qui fait tant rire les intégrateurs), il va donc falloir mettre des humains en bout de chaîne pour rétablir le service quand celui ci vient à tomber.

L’astreinte est de manière quasiment systématique une composante du métier d’administrateur système (ou toute les variantes type DBA, NetOps, SRE, etc). Elle est directement liée aux besoins de disponibilité du SI, eux mêmes dictés par ceux de la production.

Les contre-exemples existent forcément, dans des contextes où le maintien en conditions opérationnelles du SI n’est pas vital en dehors des horaires de travail. Mais dans un monde où les SI deviennent omniprésents, c’est de plus en plus rare.

## Comment mettre des salariés en astreinte ?

Dans cette première partie, je vais vous parler de "droit du travail" car c’est un prérequis pour comprendre les aspects organisationnels et bien construire son astreinte.

Pour avoir un résumé des points importants, le gouvernement à mis au point une fiche sur [service-public.fr](https://www.service-public.fr/particuliers/vosdroits/F20873) à ce sujet.

Voilà la définition de l’astreinte qui englobe pratiquement tous les points importants :

> L’astreinte correspond à une période pendant laquelle le salarié doit être en mesure d’intervenir pour accomplir un travail au service de l’entreprise. Le salarié d’astreinte n &lsquo;a pas l’obligation d’être sur son lieu de travail et ou à la disposition permanente et immédiate de l'employeur. Les astreintes sont mises en place sous conditions. Des compensations sont prévues pour les salariés concernés.

## Lieu et temps de travail
  
  
L’astreinte ne se fait pas sur le lieux de travail, sinon c’est une garde ou une permanence.

Le distinction est importante, car en droit français, le temps passé en garde/permanence est du temps de travail effectif (ce qui n’est pas le cas en astreinte). En astreinte, seul le temps d’intervention est du temps de travail effectif.

Pour ceux qui trouveraient la notion de temps de travail effectif peu claire, il faut le comprendre comme les heures de travail qui rentrent dans vos 35h (si vous êtes aux 35h). Ces heures d’intervention en astreinte doivent donc être rémunérées et/ou récupérées, contrairement aux heures où vous êtes d’astreinte mais pas appelé (et là c’est 0).

Concernant le temps d’intervention, il englobe toute la durée de ladite intervention. Ca commence à partir du moment où l’astreinte est déclenchée (appel téléphonique, alerte automatique, etc), jusqu’à sa résolution. ([L3121-9 et L3121-10](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033001537&cidTexte=LEGITEXT000006072050)).

Si le salarié doit effectuer un déplacement (prendre son véhicule pour aller dans un datacenter par exemple), le temps de trajet est inclus dans le temps d’intervention.

## Accord d’astreinte
  
  
Les astreintes ainsi que leurs modalités doivent être fixés par convention ou accord d’entreprise (ou si elles existent, par accord de branche). En l’absence d’accord, l’entreprise peut fixer les conditions de mise en place de l’astreinte après avoir informé le CSE ([L3121-11](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033001561&cidTexte=LEGITEXT000006072050)).

Dans tous les cas, il devra informer également l’inspection du travail.

L’accord d’astreinte va définir toutes les modalités de l’astreinte, comme les compensations, les conditions d’interventions ainsi que le suivi de ces astreintes. Au delà de quelques grands principes que je citerai, il y a assez peu de cadre législatif, ce qui a l’avantage d’être très flexible mais aussi un peu flou.

Note : Si jamais vous êtes appelés à négocier avec votre employeur pour la mise en place d’astreintes, faites une recherche de ce qui existe dans votre métier/région. Les accords sont souvent disponibles librement sur Internet (j’en ai trouvé une dizaine en peu de temps). Faites vous une liste d’accords, piochez ce qui vous parait pertinent dans votre cas et arrivez avec des arguments à la table de négociation ;-).

Exemple de recherche dans votre moteur de recherche préféré :

> astreinte informatique filetype:pdf
  
### Compensations
  
  
Le fait d’être en astreinte et de réaliser des interventions est compensé.

Chaque mois, un décompte doit être fourni au salarié ayant réalisé des astreintes ([R3121-2](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033441994&cidTexte=LEGITEXT000006072050)).

Au delà de ça, rien n’est obligatoire. Les conventions collectives (a minima Syntec et Metallurgies) sont également très muettes à ce sujet.

A vous de fixer les compensations pour les périodes où vous êtes d’astreinte, si les heures d’interventions sont récupérées ou payées, s’il y a des majorations lors de heures réalisées la nuit, du montant de la "prime" pour être mis d’astreinte une semaine, un jour, un jour férié, ...

Ce ne sont que des exemples, tout est possible dans la limite des quelques contraintes que j’ai cité plus haut.
  
### Être prévenu à temps
  
  
Le salarié doit être prévenu à temps qu’il va devoir réaliser une astreinte. On parle d’a minima 15 jours avant, réductible à 1 jour en cas de circonstances exceptionnelles dans la loi ([L3121-12](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033001574&cidTexte=LEGITEXT000006072050)), mais les accords d’entreprise ou de branches peuvent modifier ces délais.

### Respecter les repos quotidien et hebdomadaire
  
Il s’agit là d’un des points les plus _touchy_, car il nécessite beaucoup d’organisation de la part des équipes: la notion de repos.

Qu’on soit d’astreinte ou pas, le code du travail prévoit que tout salarié dispose d’un temps de 11h de repos consécutives par jour ([L3131-1](https://www.legifrance.gouv.fr/affichCodeArticle.do?cidTexte=LEGITEXT000006072050&idArticle=LEGIARTI000006902578&dateTexte=&categorieLien=cid)) et 24h de repos par semaine ([L3132-2](https://www.legifrance.gouv.fr/affichCodeArticle.do?cidTexte=LEGITEXT000006072050&idArticle=LEGIARTI000006902581&dateTexte=&categorieLien=cid)).

En théorie, cela signifie, dans le cas de l’astreinte, que si vous avez terminé votre journée de travail à 18h et que vous recevez un appel d’astreinte à minuit, vous n’avez pas eu vos 11h de repos de manière ininterrompue. Il faudra donc attendre 11h le lendemain avant de retourner travailler (sans aucun autre nouvel appel d’astreinte, sinon on repart à 0).

Pire, le week end, le repos quotidien s’additionne au repos hebdomadaire. Vous devez donc avoir 35h de repos ininterrompues le week end !

En pratique, je connais beaucoup d’entreprises qui ne respectent pas cette règle. En effet, elle induit potentiellement de longues périodes pendant lesquelles le salarié ne peut pas revenir au travail, provoquant un déséquilibre dans l’organisation de l’équipe. Certains salariés refusent également d’appliquer cette règle, par solidarité avec leurs collègues. D’autres sont parfois menacés par les directions.

Cependant, le risque en cas d’accident du travail pour un salarié qui n’aurait pas respecté les 11h est très important. La responsabilité de la direction est directement engagée, même si c’est le salarié qui de lui même a décidé de ne pas respecter cette contrainte.

### Suivi de la charge que représente l’astreinte sur les salariés
  
  
Un peu dans la même veine que le respect des repos, l'employeur est tenu de s’assurer que la mise en place d’astreinte n’a pas d’effet néfastes sur la santé des salariés.
  
Vous vous imaginez qu’être réveillé la nuit tous les jours pendant une semaine risque fort d’avoir un impact (a minima sur l’humeur).

Cela passe donc par la mise en place :
  
  
* d’un suivi du nombre et des temps d’intervention
* si nécessaire, d’un suivi médical plus régulier avec la médecine du travail
      
  
En cas de dérive (ex. les salariés sont très régulièrement en intervention toute la nuit par exemple), l'employeur sera tenu de prendre les actions correctives nécessaires pour éviter tout accident qui risquerait de lui être reproché.

## Et la suite ?
  
  
Voilà, vous savez maintenant les points législatifs les plus importants en ce qui concernent la mise en place d’une astreinte en France. Promis, on n’en parle plus.

C’était le prérequis pour l’article suivant qui permettra lui de voir la façon dont elle a été réalisée, tant du point de vue technique que du point de vue organisationnel dans mon équipe.

## Sources
  
  
* [saisirprudhommes - Astreinte et droit du travail](https://www.saisirprudhommes.com/fiches-prudhommes/astreinte-droit-du-travail)
* [droit-finances - Astreinte au travail, gardes](https://droit-finances.commentcamarche.com/faq/15545-astreinte-au-travail-definition-et-droit-du-travail#garde)
* [Est ce que la loi travail a changé le repos quotidien en astreinte ?](/2016/03/15/1865/)
* Code du travail : articles [L3131-1](https://www.legifrance.gouv.fr/affichCodeArticle.do?cidTexte=LEGITEXT000006072050&idArticle=LEGIARTI000006902578&dateTexte=&categorieLien=cid) et [L3132-2](https://www.legifrance.gouv.fr/affichCodeArticle.do?cidTexte=LEGITEXT000006072050&idArticle=LEGIARTI000006902581&dateTexte=&categorieLien=cid)(repos), [L3121-9 et L3121-10](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033001537&cidTexte=LEGITEXT000006072050), [L3121-11](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033001561&cidTexte=LEGITEXT000006072050), [L3121-12](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033001574&cidTexte=LEGITEXT000006072050) et [R3121-2](https://www.legifrance.gouv.fr/affichCode.do?idSectionTA=LEGISCTA000033441994&cidTexte=LEGITEXT000006072050)
      
