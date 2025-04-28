---
title: Cloud Alpes
authors:
  - zwindler
type: post
date: 2023-09-07T08:00:00+02:00
url: /2023/09/07/cloud-alpes
image: /2023/09/insalyon.jpg
categories:
  - Conférence
tags:
  - Cloud Alpes
  - LDLC
  - Lyon
  - INSA Lyon

---

## J'étais à Cloud Alpes

Aujourd'hui hier (6 septembre) a eu lieu la conférence Cloud Alpes, à l'INSA Lyon. Comme à mon habitude, je vais vous faire un petit REX des talks que j'ai pu voir aujourd'hui.

## MakAir

La keynote d'ouverture de la journée [a été donné par Quentin ADAM](https://cloudalpes.fr/sessions/VQSIlIWaJ2pZc6kuNyym), qui a présenté le projet [MakAir](https://makair.life/). 

Pour rappel, ce projet a été initié en réponse à l'urgence sanitaire de la pandémie de COVID-19 en 2020. L'équipe du MakAir s'est attelée à la conception d'un respirateur artificiel à faible coût, capable de répondre aux besoins médicaux urgents.

Ce talk a déjà été donné par Quentin (je l'avais déjà vu en replay) et il a voulu axer sa présentation sur un angle un peu différent :
* Quentin a expliqué que le problème principal de créer un "MakAir" n'était pas seulement un problème d’ingénierie, c'est aussi un problème industriel et un problème réglementaire
* La force de l'équipe de MakAir a été de savoir 
  * concevoir un appareil dans un contexte de pandémie et de ruptures
  * savoir faire parler les différentes parties prenantes, y compris des experts médicaux et des ingénieurs
  * trouver les bonnes personnes (certification médicale) dans un temps record

Quentin a aussi fait les louages de la recherche et de l'industrie française dans ce bel exemple de collaboration qui a permis de sortir ces respirateurs en un temps record.

## L'intelligence artificielle expliquée en 20 minutes pour les devs

Le deuxième talk, de [Stéphane Philippart](https://cloudalpes.fr/sessions/lintelligence-artificielle-exp), a abordé le sujet de l'intelligence artificielle (IA). 

![](/2023/09/ia20min.jpg)

En 20 minutes, Stéphane nous a présenté les différentes catégories d'IA, les explications des concepts de Machine / Deep learning, des applications les plus courantes (NLP, IA générative, ...)

On a abordé les problématiques d'apprentissage supervisé et non supervisé, de l'importance de la qualité des données et de la création de jeux de données pour l'entraînement des modèles, des notions de biais, ...

Au final, c'était une bonne introduction même si j'avais (personnellement) toutes les bases.

## Julien Landuré - introduction au FinOps

[Julien Landuré](https://cloudalpes.fr/sessions/introduction-au-finops-avec-go) a donné un talk sur le FinOps, qui consiste à gérer efficacement les coûts liés à l'infrastructure informatique. 

![](/2023/09/finops.jpg)

Les points clés de sa présentation comprenaient :

* La tarification fine basée sur l'utilisation, notamment avec les services serverless
* L'importance du dimensionnement approprié des ressources informatiques
* Les avantages de l'auto-scale pour gérer les pics de charge plutôt que de sur-provisionner h24
* Les avantages du Serverless et des différents "pricing models" associés
* L'utilisation d'outils de suivi des coûts

Julien a aussi parlé dans son talk d'un groupement d'acteurs qui ont créé la "FinOps fondation
". Il nous a mis en avant une partie de leurs travaux, dont des "State of reports".

![](/2023/09/finops2.jpg)

## Table ronde sur les femmes dans la tech

Une table ronde a réuni [Nida Légé, Sarah Haïm-Lubczanski, Houleymatou Baldé et Angélique Jard](https://cloudalpes.fr/sessions/GPCSDX1scOBynXV4HM6H), toutes travaillant dans la tech pour discuter de la représentation des femmes dans ce secteur.

![](/2023/09/tableronde.jpg)

Les sujets abordés comprenaient :

* Les différentes façons dont les femmes sont attirées par la tech, y compris les roles models (Houleymatou a été inspirée par Chloé O'Brian de 24h chrono) et les expériences personnelles.
* Les défis auxquels les femmes sont confrontées dans la tech, tels que les stéréotypes de genre et les responsabilités familiales.
* La sous-représentation des femmes dans le domaine technologique et les efforts nécessaires pour inverser cette tendance (qui continue à baisser).
* Les expériences personnelles des panélistes en tant que femmes travaillant dans la tech.

J'ai particulièrement aimé la réaction d'Angélique à la question "Comment viennent les femmes à l'informatique ???" et qui a répondu "Je ne sais pas trop répondre à cette question. Comment viennent les hommes dans l'informatique ?".

En revanche, je n'ai pas trop apprécié le moment où un des organisateurs a souhaité absolument rebondir sur "le drama" autour de la publication du premier agenda de la conférence qui ne contenait aucune femme (gros problème de communication à mon avis).

## "The walking pods", les hordes de clusters envahissent le SI

Le talk suivant était [un REX sur l'utilisation de Kubernetes à la SNCF, présenté par Antoine BERMON](https://cloudalpes.fr/sessions/the-walking-pods-les-hordes-de) et une autre personne dont je n'ai pas enregistré le nom (désolé). Ce que j'ai le plus retenu de ce talk a été le retour sur les défis organisationnels qu'ils ont affrontés (la technique finalement, c'est le plus simple dans ce genre d'organisations).

![](/2023/09/walkingpods.jpg)

L'équipe Kubernetes devait accompagner les nombreuses équipes des différentes entités de la SNCF, sans pour autant pouvoir tout faire à la place des équipes.

La première chose qu'ils font, c'est de s'assurer que les équipes ont le bagage technique minimum avant de donner le go à la création d'un cluster, quitte à envoyer les devs en formation. Il n'y a pas de lobbying pour "pousser" à Kubernetes, le risque d'échec serait trop grand pour certaines équipes. Des sages décisions ;-\)

Un problème pour les équipes sont les montées de versions de Kubernetes, qui sortent tous les 4 mois. L'équipe Kubernetes de la SNCF ont trouvé que les équipes métiers avaient du mal à accepter toutes les montées de versions, mais que 2 fois ou une fois c'était OK.

C'était intéressant d'avoir un REX d'un grand groupe.

## Coup d'oeil sous le capot d'un plugin kubectl facilitant l'accès aux clusters k8s créés via CAPI

[Matthieu DUFOURNEAUD a présenté un plugin kubectl](https://cloudalpes.fr/sessions/coup-doeil-sous-le-capot-dun-p) qu'il a développé en Golang pour faciliter les opérations de connexion sur des clusters gérés par la Cluster API.

Matthieu nous a montré un peu le code en go (pas tout) et ce n'était pas hyper facile à suivre.

En revanche, pour avoir développé des cli pour Kubernetes en go pour d'autres opérations, j'ai trouvé les choix techniques assez cohérents.

## De villageoise à IT Woman

[Ce témoignage de Houleymatou Baldé (originaire de Guinée et vivant et ayant fait ses études en France)](https://cloudalpes.fr/sessions/FrDMLAiMoYjvelceZiOj) sur les difficultés des femmes et des racisées dans la tech, ainsi que les roles models, est trop fort pour être décrite ici en quelques lignes.

![](/2023/09/itwoman.jpg)

J'espère qu'elle aura l'occasion de refaire son intervention à une autre conférence, il mérite d'être vu en live.

## La semaine de 4 jours

En keynote de fin, Cloud Alpes a réussi un tour de force. Inviter [Laurent de la Clergerie pour parler de "la semaine de 4 jours" qu'il a instauré à LDLC](https://cloudalpes.fr/sessions/o2Z0atrKYM7zwp3czSjg).

J'étais vraiment impatient de voir ce talk (et aussi un peu déçu de devoir partir un peu avant la fin, pour ne pas rater mon vol), car Laurent de la Clergerie fait partie de ces leaders qui m'inspirent, notamment dans les luttes pour plus de bien être au travail.

![](/2023/09/ldlc.jpg)

Après un historique de son entreprise depuis sa création plus de 25 ans auparavant, pour que nous comprenions bien les tenants et les aboutissants des décisions qui ont été prises, on est rentré dans le vif du sujet : le jour où il a annoncé à son board qu'il voulait passer à la semaine de 4 jours, puis le jour où il a annoncé, en NAO, alors que personne n'était au courant.

Il nous a parlé des résistances (surtout au niveau managérial, mais pas que !), de la façon dont ça a été mis en place, des problématiques de planning. On a fini sur les résultats, que lui considère comme un gain de productivité supérieur à 20% (puisqu'il n'a pas dû embaucher plus, que le turnover est quasi inexistant, que l'absentéisme a drastiquement diminué, ...)

J'étais vraiment heureux de rencontrer un des leaders d'opinion qui m'inspire, et je regrette d'avoir dû partir avant la fin de son intervention (avion à prendre).

## Conclusion

Pour une première, c'était très bien réalisé ! Je suis content que les organisateurs aient su rebondir suite à la publication de la première version de l'agenda.

Au delà des conférences, plutôt niveau "beginner", j'ai adoré échanger avec les participants. Le fait que nous étions "relativement en petit comité" (moins d'une centaine) dans un petit amphi a facilité les discussions.

J'ai pu parler avec Angélique, Quentin, Maxime, David. J'ai rencontré en vrai pour la première fois The Bidouilleur et Nida (avec qui j'avais déjà abondamment parlé sur Internet), Laetita Avrot (discussion passionnantes autour des DBs), Julien (qui m'avait invité à parler à un GDG), les SRE de chez Malt, les gens de la SNCF... Bref, une journée riche en échanges.

Les organisateurs ont déjà "spoilé" qu'il y aurait d'autres événements de ce type, pas seulement sur Lyon et bien avant l'an prochain. Hâte de voir ce qu'ils ont en tête.

Fun fact : les stickers deezer shiny passent pas la sécurité de l'aéroport (lol)

![](/2023/09/deezer.jpg)
