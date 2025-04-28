---
title: 'Okiwi - Sondage des salaires dans la Tech Girondine 2022-2023 + première analyse'
authors:
  - zwindler
type: post
date: 2022-11-21T06:30:00+02:00
excerpt: "Grille de salaires anonyme dans la Tech Girondine 2022 2023 poussée par l'association Okiwi avec un dashboard Kibana"
url: /2022/11/21/okiwi-sondage-des-salaires-dans-la-tech-girondine-2022-2023-analyse/
image: /2022/11/okiwi23.png
categories:
  - Divers
tags:
  - association
  - Bordeaux
  - indépendant
  - IT
  - Okiwi
  - Salaire
  - salarié
  - sondage

---
## Salaires : c’est reparti pour 2022-2023 !

C'est Noël avant l'heure avec [Okiwi](https://okiwi.org/) :) après 2019, 2020, 2021... c'est reparti pour un tour !

Le grand sondage sur les montants des salaires de celles et ceux qui vivent ou travaillent dans **la Tech et l'IT en Gironde** revient pour l'édition 2022-2023 🎉🎉🎉.

* [💰 Sondage pour les salariés](https://docs.google.com/forms/d/e/1FAIpQLSeN1cbz17D6GnLsLkb03AIp8n-Y17IAfyPYYcDGXC9dVP2Q7w/viewform)
* [💰 Sondage pour les indépendants ](https://docs.google.com/forms/d/e/1FAIpQLSeU7JVofzMr85MgAl9HKuj8Wdw2O5L21DkCfEKYrbiP2LNMlQ/viewform)

**Je ne demande pas ça souvent : pour que les données soient fiables, j’ai besoin que vous partagiez le formulaire (ou ce post) un MAXIMUM !**. 

Et comme d'habitude, je me suis chargé d'héberger et de générer un dashboard interactif Kibana pour que vous puissiez faire joujou avec les résultats, dont les accès sont disponibles dans le formulaire. Les versions précédentes sont également toujours disponibles :).

## Les premiers chiffres

Avec "seulement" 200 participants, on est pas encore sur des chiffres aussi élevés que les années précédentes (environ 350 en 2020 et en 2021).

Cependant, je veux bien m'aventurer à donner quelques chiffres et mon avis (totalement non professionnel) dessus.

Disclaimer : Je rappelle une fois de plus que notre sondage n'est en rien professionnel, contient de nombreux biais que nous ne nions pas, et qu'il donne juste une tendance, à [confirmer avec d'autres sources (cf Salaires de la tech en 2022 : quelques ressources externes)](/2022/07/06/salaires-dans-la-tech-quelques-ressources-externes/).

## Représentativité relative

D'abord, cette année nous avons 89% d'hommes dans les répondant·e·s, contre 87% l'an dernier. C'est beaucoup trop quand on sait que quand on parle de femmes dans la tech (au sens large, pas juste les devs), on estime leur part à environ 25%. Il faudra travailler sur ce point...

![](/2022/11/okiwi23-genres.png)

Au niveau du profil des répondant·e·s, on note, comme chaque année une part importante de bac+5 (ou plus), venant de l'université ou d'écoles d'ingénieurs, avec de l'expérience (>5 ans dans une écrasante majorité) et se sentant expérimentés. Pour l'expérience, ce n'est pas très étonnant, sachant que les profils qui communiquent et participent le plus à diverses communautés sont probablement ceux qui ont "le plus de bouteille".

Mais dans tous les cas, ça va fausser les médianes salariales. Il faudra là aussi qu'on trouve comment mieux "toucher" les devs juniors ou issus de formations plus courtes. Je note quand même un essor des profils de type reconversion dans les réponses (quasiment 10%, contre 2% l'an dernier).

![](/2022/11/okiwi23-profils.png)

On note aussi une représentation de CDI quasi exclusive et un nombre relativement faible de travailleurs/travailleuses à temps partiel. C'est en tout cas moins (en proportions) dans ces deux catégories que l'an dernier.

![](/2022/11/okiwi23-profils2.png)

## Salaire et sentiment sur le salaire

Je suis assez content de cette catégorie :)

![](/2022/11/okiwi23-salaires.png)

Le graphique de gauche (une "heatmap") représente la répartition des salaires déclarés par années d'ancienneté. On note une belle courbe qui débute autour de 30-40k€, qui monte jusqu'à 60k€ (et plus) à environ 10 ans d'expérience. Au-delà, l'expérience ne semble plus avoir d'impact significatif (c'était pareil les années précédentes).

Le graphique de droite est une répartition du sentiment qu'ont les répondant·e·s sur leur salaire en fonction de leur expérience.

Sans trop de surprises :
* les répondant·e·s débutants qui gagnent plus de 50-60k€ s'estiment surpayés et ceux à 30k€ s'estiment sous-payés
* les répondant·e·s expérimentés qui gagnent 45k€ s'estiment sous-payés et à partir de 70k€ ils s'estiment surpayés.

Note : La question était bien le sentiment "par rapport au reste du marché". Ca ne dit rien de leur valeur réelle et les quelques "devs à 100k" qui ont répondu le méritent certainement amplement ;-).

## Salaires médians et 10/90 percentiles

Les salaires médians et 10/90 percentiles des répondant·e·s sont les suivants (tous profils confondus) :

![](/2022/11/okiwi23-mediane.png)

On note une légère amélioration quand on est bac+5 ou plus, mais rien d'extra-ordinaire, sauf en début de carrière (ça ne me surprend pas).

![](/2022/11/okiwi23-mediane-bac-5-et-plus.png)

Il ne fait pas très bon pour le porte-monnaie d'être embauché par une SSII/ESN, comme les chiffres suivants semblent le montrer...

![](/2022/11/okiwi23-mediane-esn.png)

Enfin, avec seulement 22 femmes (c'est vraiment trop peu pour tirer une conclusion), ce dernier chiffre est à prendre avec toutes les pincettes de rigueur, mais on a une médiane de 7% inférieure à celle des hommes.

![](/2022/11/okiwi23-mediane-femmes.png)

## Autres stats "amusantes"

J'ai été surpris par l'aspect "pyramidal" de la répartition des répondant·e·s en fonction de la taille de l'entreprise qui les emploient. C'était même encore plus flagrant au début. Grosso modo, on a surtout des grands groupes, assez peu de PME.

![](/2022/11/okiwi23-taille.png)

Je ne sais pas si ça a un impact sur la représentativité des salaires ou pas, il faudrait avoir des statistiques sur les tailles moyennes des entreprises dans la tech pour voir s'il y a corrélation ou pas.

Dans les trucs que je trouve aberrants, j'ai été choqué de voir que très peu d'entreprises organisent la formation / autorise l'autoformation de leurs employés 

![](/2022/11/okiwi23-formation.png)

1 salarié(e) de la tech girondine sur 2 a moins de 3 jours de formation/autoformation/conférence/hackaton par an. Dans nos métiers en perpétuelle réinvention, je ne comprends pas comment cette situation est tenable.

Aucune femme ne s'est classée dans la catégorie "Très expérimentée" (12% chez les hommes).

Sur les 10 profils à temps partiel, 6 sont des femmes (alors qu'elles ne représentent que 11% du panel).

## Conclusion

Je mettrais probablement à jour cet article quand on aura plus de réponses et j'ajouterais peut-être quelques infos supplémentaires.

En attendant, je vous laisse remplir / partager à vos connaissances le sondage (encore ouvert) histoire d'avoir une meilleure représentativité. Je vous laisse aussi aller jouer avec le dashboard Kibana (et les années précédentes) :-).

Have fun !
