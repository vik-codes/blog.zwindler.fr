---
title: '[Update] Les salaires de l’IT dans un Kibana'
authors:
  - zwindler
type: post
date: 2020-07-10T18:46:29+00:00
excerpt: "Étude des salaires de l'IT lancée par Shirley Almosni Chiche et dont les résultats sont accessibles librement, consolidés dans Kibana"
url: /2020/07/10/les-salaires-de-lit-dans-un-kibana/
image: /2020/07/shirley2-2.png
categories:
  - autohebergement
  - DIY
  - Monitoring
tags:
  - Etude
  - Kibana
  - Salaire

---
## Update

Shirley a eu la gentillesse de rajouter de nouvelles valeurs dans son sondage. J’ai donc intégré les résultats dans le Kibana (après nettoyage).

![](/2020/09/shirley-new.png) 

Comme la dernière fois, n’hésitez pas à me demander les accès !

## Étude des salaires dans l’IT de Shirley Almosni Chiche

Shirley Almosni Chiche (agent de carrière IT, pour ceux qui ne la connaissent pas encore) a lancé il y a quelques jours une étude des salaires en « Open Source », comme elle dit. Elle est limitée aux salariés et à la France.

![](/2021/tweet_shirley.png)

L’avantage de sa démarche, c’est que les résultats (dont les personnes ont accepté la diffusion) sont librement accessible sur un Google Docs !

## Ça vous rappelle pas quelque chose ?

Ceux qui me suivent sur LinkedIn se souviennent peut être que j’avais déjà participé à une étude sur les salaires dans l’IT ([association Okiwi][2] cette fois là), mais limitée à la région bordelaise.

Là aussi, les résultats étaient librement accessibles et j’avais utilisé les résultats pour alimenter un dashboard Kibana.

![](/2020/07/okiwi.png)

> Une capture d’écran d’une partie du dashboard Okiwi 2019/2020

Et comme je suis quelqu’un de sympa, je n’avais pas gardé ça juste pour moi et avait mis à disposition le dashboard à tous ceux qui me l’avaient demandé.

## Vous me voyez venir...

Et oui, j’ai récidivé !

J’ai une nouvelle fois exploité les données librement accessibles pour faire un nouveau dashboard, cette fois ci plus limité à la seule région bordelaise mais à toute la France (salariés uniquement) !

Voici quelques screenshots de ce que je commence à avoir :

![](/2020/09/shirley.png)

## Pourquoi Kibana ?

Après tout, on aurait simplement pu se contenter d’utiliser le fichier sur Google Sheet et y ajouter des graphiques en sélectionnant les colonnes !

En vrai, ça fonctionne très bien. 

Cependant (là encore c’est possible), ça devient plus compliqué de le rendre dynamique. Par exemple, si je ne veux sélectionner que les femmes dans mes graphiques, il faut utiliser des filtres, potentiellement des formules, si je veux quelque chose de plus poussé.

Avec Kibana, tout est dynamique,nativement. 

Si je ne veux afficher que les réponses de femmes dans l’IT, il me suffit de simplement cliquer sur « femmes » dans mon donut des genres, et paf :

![](/2020/07/shirley3.png) 

Idem si je veux faire une recherche uniquement sur les SRE, etc... 

Vous l’aurez compris, c’est méga super trop chouette :D

## Comment y avoir accès ?

Et c’est là où j’ai besoin de vous !

Pourquoi ?

Tout simplement parce que c’est étude ne valent pas grand chose si elles ne sont pas remplies par le plus grand nombre.

En 3 jours, Shirley avait déjà récolté plus de 400 réponses (250 librement accessibles). C’est pas mal, mais pour être encore plus pertinents, il nous en faut plus.

C’est pourquoi, si jamais vous voulez un accès à mon dashboard Kibana, je vous demanderai d’abord de remplir le questionnaire de Shirley en premier. Ce n’est pas très long et ça nous permettra à tous d’avoir les résultats les plus pertinents possibles. 

Et comme ça, tout le monde est gagnant :)

Le formulaire :

* [docs.google.com/forms/d/e/1FAIpQLScMWthuEaxmP9zGBKzM0MOZmWOLT4hYO9ngKNiU6m53IogmZA/viewform](https://docs.google.com/forms/d/e/1FAIpQLScMWthuEaxmP9zGBKzM0MOZmWOLT4hYO9ngKNiU6m53IogmZA/viewform)
 

Et une fois rempli, si jamais vous voulez accéder au Kibana, n’hésitez pas à me demander les accès en m’envoyant un message sur ~~Twitter~~ ou sur LinkedIn.

Have fun !

 [2]: https://okiwi.org/
