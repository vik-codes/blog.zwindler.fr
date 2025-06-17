---
title: 'SLO, SLI, Error Budget et Critical User Journey expliqués simplement (et pourquoi ce ne sont pas des SLA !) (en 2 prompts)'
authors:
  - zwindler
type: post
date: 2025-06-17T18:00:00+02:00
excerpt: "Comment définir la fiabilité de vos services avec les concepts SRE : SLO, SLI, Error Budget et Critical User Journey"
url: /2025/06/17/slo-sli-error-budget-critical-user-journey-expliques-simplement/
image: /talks/2022-sre-sre-partout/binaries/sre_sre_partout.jpg
categories:
  - monitoring
  - systeme
tags:
  - SRE
  - SLO
  - SLI
  - Error Budget
  - Monitoring
  - Observability

---

## Introduction : "C'est quoi ces acronymes barbares ?"

Alors que je rédigeais un autre article plus technique cette semaine, je me suis rendu compte que j'utilisais allègrement des termes comme SLO, SLI, Error Budget sans les expliquer. Et puis, je me suis dit que c'était peut-être l'occasion de faire un petit article de vulgarisation sur ces concepts qui sont au cœur de la philosophie SRE (Site Reliability Engineering).

Parce qu'en vrai, même si ces acronymes peuvent paraître intimidants, les concepts derrière sont plutôt simples à comprendre. Et surtout, ils sont diablement utiles pour améliorer la fiabilité de vos services !

Fun fact : j'avais déjà abordé ces sujets dans [mon talk sur le SRE en 2022](/conferences/), mais je me dis qu'un article dédié ne fait pas de mal :-).

## SLA vs SLO : ne mélangeons pas tout !

Avant de rentrer dans le vif du sujet, petit aparté important : **ne confondez pas SLA et SLO** !

- **SLA (Service Level Agreement)** : c'est un contrat, souvent avec des pénalités financières si pas respecté. Genre "si le service est en panne plus de X heures dans le mois, on vous rembourse Y€".
- **SLO (Service Level Objective)** : c'est un objectif **interne** que vous vous fixez pour la fiabilité de votre service.

La différence est importante : les SLA sont souvent moins stricts que les SLO pour avoir une marge de manœuvre. Si votre SLA c'est 99,9% de disponibilité, votre SLO interne sera peut-être à 99,95%.

Bon, maintenant qu'on a éclairci ça, rentrons dans le détail !

## Critical User Journey : commencer par ce qui compte vraiment

> Est-ce que le **client** est content d'utiliser le service ?

C'est LA question fondamentale. Et pour y répondre, il faut d'abord identifier les **Critical User Journey** (CUJ), autrement dit les parcours utilisateurs critiques.

Concrètement, ça veut dire quoi ?

Prenons l'exemple d'une plateforme e-commerce :
- **CUJ 1** : Un utilisateur peut rechercher et consulter un produit
- **CUJ 2** : Un utilisateur peut ajouter un produit au panier et passer commande
- **CUJ 3** : Un utilisateur peut se connecter à son compte

On ne va pas définir des SLO pour toutes les fonctionnalités (la page "À propos" de votre site, on s'en fiche un peu), mais se concentrer sur celles qui, si elles tombent en panne, vont vraiment énerver vos utilisateurs.

Et c'est là que ça devient intéressant : définir les CUJ, c'est souvent un exercice qui doit impliquer le business, pas seulement les équipes techniques. C'est eux qui savent ce qui rapporte de l'argent !

## SLI : mesurer ce qui compte

Une fois qu'on a identifié nos CUJ, il faut les **mesurer**. C'est là qu'interviennent les **SLI (Service Level Indicators)**.

Un SLI, c'est simplement une métrique qui indique si votre service fonctionne bien du point de vue de l'utilisateur. Les plus classiques :

- **Disponibilité** : % de requêtes qui réussissent
- **Latence** : temps de réponse du service
- **Débit** : nombre de requêtes traitées par seconde
- **Qualité** : % de réponses correctes (pas d'erreurs de données)

L'idée clé ici, c'est de mesurer depuis le point de vue de l'utilisateur, pas depuis vos serveurs. Peu importe que votre CPU soit à 10% si l'utilisateur voit des erreurs 500 !

Exemple concret pour notre CUJ "recherche de produit" :
- SLI disponibilité : `(requêtes HTTP 200 sur /search) / (total requêtes sur /search) * 100`
- SLI latence : `95% des requêtes sur /search répondent en moins de X ms`

## SLO : se fixer des objectifs réalistes

Maintenant qu'on sait **quoi** mesurer, il faut se fixer des **objectifs**. C'est le rôle des **SLO (Service Level Objectives)**.

Un SLO, c'est tout simplement une valeur cible pour vos SLI sur une période donnée.

Exemples :
- "99,9% des requêtes de recherche doivent réussir sur une période de 30 jours"
- "95% des pages de recherche doivent s'afficher en moins de 500ms sur une période de 7 jours"

### Quelques conseils pour bien définir vos SLO

**1. Commencez par mesurer l'existant**
Inutile de viser 99,99% si votre service actuel est à 98%. Regardez vos métriques historiques et fixez-vous des objectifs atteignables mais ambitieux.

**2. Pensez S.M.A.R.T.**
Vos SLO doivent être Spécifiques, Mesurables, Atteignables, Réalistes et Temporellement définis. Comme tout bon objectif !

**3. N'oubliez pas que 100% c'est mal**
Comme le dit si bien Ben Treynor Sloss (le papa du SRE chez Google) :

> 100% is the **wrong** reliability target for basically everything

Plus on veut de "9", plus ça coûte cher exponentiellement. Et au-delà d'un certain seuil, les utilisateurs ne voient même plus la différence !

## Error Budget : retourner le problème

Et là, c'est le moment où ça devient vraiment malin. Au lieu de raisonner en "disponibilité", les équipes SRE raisonnent en **Error Budget** (budget d'erreur).

C'est un simple changement de perspective :
- Service accessible 99,9% = service **inaccessible** 0,1% du temps
- Sur 30 jours, ça fait environ 43 minutes d'indisponibilité "autorisée"

Cette approche change complètement la donne ! Au lieu de voir les pannes comme des échecs, on les voit comme un **budget à dépenser intelligemment**.

### Comment utiliser son Error Budget ?

Contre-intuitivement... **IL FAUT L'UTILISER** !

Si votre SLO est respecté (utilisateurs contents), vous pouvez "dépenser" votre error budget pour :
- Faire des déploiements plus risqués
- Tester des nouvelles fonctionnalités en prod
- Faire du chaos engineering
- Réaliser des maintenances disruptives

À l'inverse, si vous "cramez" votre error budget (SLO pas atteint), alors là, stop : on arrête tout ce qui n'améliore pas la fiabilité du service !

C'est un formidable outil de priorisation entre les équipes produit (qui veulent des nouvelles features) et les équipes ops (qui veulent de la stabilité).

## Exemple concret : une API de recommendation

Bon, assez de théorie, prenons un exemple concret. Imaginons qu'on ait une API de recommandation de produits.

### 1. Définir le CUJ
"Un utilisateur doit pouvoir récupérer des recommandations personnalisées en moins de 1 seconde"

### 2. Choisir les SLI
- **Disponibilité** : `(réponses HTTP 200) / (total requêtes) * 100`
- **Latence** : `P95 du temps de réponse`

### 3. Fixer les SLO
- "99,5% des requêtes sur l'API de recommandation doivent réussir sur 30 jours"
- "95% des requêtes doivent répondre en moins de 800ms sur 7 jours"

### 4. Calculer l'Error Budget
- 99,5% de disponibilité = 0,5% d'indisponibilité autorisée
- Sur 30 jours = environ 3,6 heures d'indisponibilité "budgetées"

Simple, non ?

## Les pièges à éviter

**Piège n°1 : Trop de SLO**
N'essayez pas de mettre des SLO partout. Commencez par 2-3 SLO sur vos CUJ les plus critiques. Vous pourrez étendre ensuite.

**Piège n°2 : SLO trop stricts**
Si vous mettez la barre trop haut, vous allez passer votre temps en "SLO violation" et personne ne prendra plus ça au sérieux.

**Piège n°3 : Oublier l'aspect organisationnel**
Les Error Budgets ne marchent que si toute l'organisation (business inclus) adhère au principe. Sinon, vous aurez beau être en SLO violation, on vous demandera quand même de déployer la nouvelle feature...

## Comment commencer ?

Si vous n'avez jamais fait de SLO, voici un plan d'action simple :

1. **Identifiez 1-2 CUJ critiques** (avec le business !)
2. **Regardez vos métriques actuelles** sur ces parcours
3. **Définissez des SLO réalistes** mais un peu ambitieux
4. **Mettez en place l'alerting** quand vous êtes en train de consumer votre error budget
5. **Itérez !** Les SLO ne sont pas gravés dans le marbre

## Conclusion

J'espère que cet article vous aura donné envie de creuser ces concepts ! Les SLO/SLI/Error Budget ne sont pas juste des buzzwords, c'est vraiment un changement de paradigme dans la façon d'appréhender la fiabilité.

Et le plus beau, c'est que ça marche autant pour une startup avec 3 développeurs que pour une GAFAM avec 10000 ingénieurs. L'important, c'est de commencer simple et d'itérer.

Pour aller plus loin, je vous recommande chaudement le [SRE Book de Google](https://sre.google/sre-book/service-level-objectives/) (gratuit !) et leur [guide pratique pour définir des SLO](https://cloud.google.com/blog/products/management-tools/practical-guide-to-setting-slos).

Et si vous voulez approfondir le sujet SRE en général, n'hésitez pas à jeter un œil aux [slides de mon talk de 2022](/conferences/) ;-).

Tags pour moi-même : `SRE`, `observability`, `monitoring`

Bon monitoring !
