---
title: 'MicroRack v1 - un rack compact pour les Dell Micro de mon homelab'
authors:
  - zwindler
type: post
date: 2024-02-15T17:00:00+02:00
url: /2024/02/15/microrack-v1-pour-dell-micro/
image: /2024/02/microrack.png
categories:
  - DIY
  - Matériel
tags:
  - Cluster
  - DYI
  - Helmer
  - Rack
  - Homelab
  - Dell micro
  - i5

---

## Yet another homelab (again)

Il y a quasiment 10 ans (à 1 mois près), je concevais et construisais mon propre "meuble" pour mon homelab de l'époque, composé de plusieurs cartes MicroATX et de matériel récupéré. 

Je m'étais inspiré de Ike-hackers (pour ceux qui ne connaissent pas les [Ikea-hacks](https://ikeahackers.net/) ou Ikeacks, je vous laisse chercher, ça vaut le coup) qui transformaient un meuble "Red helmer" en cluster de rendering 3D.

Depuis, mon homelab a changé 45 fois (à peu près) et récemment, je me suis lancé dans un lab basé sur des dell micro, des tout petits desktops (il y en a aussi chez HP et Lenovo) qui consomment peu (donc peu puissants) et sont assez robustes :

![](/2023/07/trofast2.png)

* [L'article à ce sujet](https://blog.zwindler.fr/2023/03/16/lab-2023-dell-micro-occasion/)

## Crude but effective

On ne va pas se mentir, trimballer ça dans un bac "Trofast" de chez Ikea, c'est quand même un peu bourrin. Mais faute de mieux c'était pas mal.

Quelques mois plus tard, un très bon copain (dont le seul défaut est qu'il vit en Australie et que bon, c'est un peu loin pour les apéros) m'envoie ça :

![](/2024/02/printables.png)

* [printables.com - SergeiBuilds - Mini Lab Rack For Dell Optiplex MFF Servers](https://www.printables.com/fr/model/499181-mini-lab-rack-for-dell-optiplex-mff-servers)

Un "rack" compact et propre pour ranger des dell micro ??? A faire en DIY ?

Mais c'est trop bien !!

## Problème(s)

Bon, sur le papier ça a l'air cool, mais il y a quand même plusieurs problèmes à régler. D'abord, le lien sur printables.com est assez peu détaillé. Les photos sont pas tops (on ne voit pas comment c'est monté), on sait juste qu'il faut imprimer des pièces (dont les modèles sont fournis) et qu'il faut monter ça dans un cadre en aluminium.

> The frame is assembled from 4x 200mm, 4x 300mm, 4x 400mm & 2x 360mm 2020 aluminium extrusion and held together with L corner brackets. The overall dimensions are 240mm wide, 400mm high & 340mm deep.

D'abord: je n'ai pas d'imprimante 3D (et je n'y connais rien).

![](/2024/02/twitter1.png)

On m'a conseillé plusieurs moyens de contournement. En acheter une (le plus simple xD), demander à un copain, passer dans un fablab, la faire imprimer sur Internet (ça coûte assez cher).

(Finalement, j'ai trouvé une âme charitable pour me les imprimer au boulot, merci Fabien)

Ensuite, comment on l'achète et on le monte ce fichu cadre en aluminium ?

A force de recherches (**décembre 2023**), j'ai fini par trouver que les "2020 aluminium extrusion" s'appellent en bon français des "profilés aluminium 20x20".

On peut en trouver sur Amazon pré-coupés (c'est fort cher). Et même si on en prend des grands à recouper soi-même, j'avais un peu peur de la précision de coupe (même si je suis outillé).

Heureusement, on a fini par me donner l'adresse d'un site industriel qui en vend à la découpe (motedis.fr).

* [Profilé aluminium 20x20 Type B rainure 6 ](https://www.motedis.fr/fr/Profile-aluminium-20x20-Type-B-rainure-6)

Pour assembler les profilés, il faut des équerres internes (`L corner brackets`, fallait deviner...). Heureusement on en trouve aussi chez Motedis, je suis tombé dessus par hasard en fouillant les vidéos du site !

* [Équerre interne 20 B-Type rainure 6 M5 Alternative ](https://www.motedis.fr/fr/Equerre-interne-20-B-Type-rainure-6-M5-Alternative)

Il en faut 20 (ce que ne dit pas ce cher *SergeiBuilds*, j'ai compté 3 fois pour être bien sûr).

Une fois que vous avez pris ces deux trucs là, vous en avez déjà pour 60€ (dont 20€ de frais de port)...

Il faut aussi des écrous à glisser dans les rails pour fixer nos pièces de PLA, ainsi que des vis M5. J'en ai compté 24 mais je ne les ai pas achetés (on y reviendra dans la section suivante).

## Et là, c'est le drame

Je laisse passer décembre (trop occupé) et je commande tout ça (**mi-janvier 2024**)

Au bout de quelques jours, ma commande Motedis est arrivée et j'étais comme un gosse à Noël. Mais je déchante très très vite...

![](/2024/02/twitter2.png)

**Les équerres ne rentrent pas dans le profilé**. Un peu bourrin (oui je suis pas toujours très fin), je tape dessus au marteau. Sur les extrémités ça marche (bien). Au milieu, j'arrive à mettre le premier. Mais je casse les suivantes.

![](/2024/02/equerres2.jpeg)

Pourtant c'est bien du 2020 mon profilé 🤔...

Bon, je ne vous fais pas mariner trop longtemps. La raison c'est que je n'ai pas pris le bon profilé 2020. Il existe 2 sortes, toutes les deux disponibles sur Motedis et j'ai pris la mauvaise :

![](/2024/02/typeBI.png)

Grosso modo, j'ai pris par erreur les types I, qui ont une rainure "arrondie" de 5, alors que ceux qu'il fallait, c'était des types B, avec une rainure trapézoïdale de 6...

A partir de là, 2 solutions :
* je rachète tout
* je m'adapte

Ca m'ennuie de jeter de l'alu parce que j'ai été trop bête... J'ai donc décidé (**5 février**) de trouver des solutions, quitte à ce que le rendu soit moins "net". J'ai donc remplacé l'usage des écrous+vis M5 par visser les parties imprimées.

![](/2024/02/rack1.jpeg) ![](/2024/02/rack2.jpeg) ![](/2024/02/rack3.jpeg)

Clairement, le résultat me parait acceptable.

Mais ne faites pas la même erreur que moi, car il sera impossible d'avoir un rendu parfait avec des vis plantées dans un rail alu. L'avantage des équerres et des écrous + vis M5, c'est que c'est repositionnable juste en desserrant / resserrant la vis.

Le **13 février**, j'ai reçu de la part de mon collègue les pièces imprimées en PLA.

Premier problème : comme je dois les visser directement dans le rail alu (puisque je ne peux pas insérer d'écrous pour mes vis M5) je ne peux pas les positionner correctement. Même en faisant de mon mieux, j'ai parfois des petits "jours" d'un 1/2 millimètre.

Deuxième problème : je ne peux pas non plus visser la cage pour le switch, car je ne pourrais pas passer un tournevis. Je laisse ce problème de côté dans un premier temps.

![](/2024/02/rack4.jpeg) ![](/2024/02/rack5.jpeg)

Troisième problème, je n'ai pas vérifié, mais mon switch est trop épais. Je découpe donc à la Dremel (content de l'avoir même si elle sert pas souvent) et à la pince perroquet mon bout de PLA. Petite surprise (évidente) : le PLA, ça fond 😅.

![](/2024/02/pla1.jpeg) ![](/2024/02/pla2.jpeg)

J'arrive quand même à tout assembler et à obtenir un résultat correct. C'est fonctionnel, ça reste joli malgré quelques imprécisions, et c'est assez pratique à l'usage.

![](/2024/02/rack6.jpeg) ![](/2024/02/rack7.jpeg)

## La suite ?

Après avoir posté ça sur Twitter et à quelques copains, on m'a donné quelques idées d'améliorations, qui serviront pour une V2 :
* Ajouter des pieds, en taraudant le tube central des profilés
* Remplacer le passe câble Ethernet du haut et la cage pour le switch en dessous par un support caché pour un switch 8 ports. Il n'y a vraiment de raison fonctionnelle à ce que les ports soient visibles et 5 ports c'est trop limité. Pourquoi pas acheter un managé tant qu'à y être.
* En profiter pour ajouter un étage de plus (dell micro ? Raspberry pi ?)
* Remplacer la multiprise (en prendre une connectée ?) et trouver un moyen de la fixer proprement sur les rails
* Trouver un moyen de fixer les alims pour qu'elles ne pendouillent pas
* Ajouter un pikvm (cher++ !) pour se passer du mini écran ? A voir
* Éventuellement couvrir une partie des côtés avec du plexi ? A voir

Pour l'instant je ne vais rien faire, car je suis content du résultat (et un peu fatigué de tout ces rebondissements !). Mais on verra après un peu d'usage ce que je fais / ne fais pas :\)

En attendant, have fun !
