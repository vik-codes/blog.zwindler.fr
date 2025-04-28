---
title: 'Transformer un logo PNG en objet 3D'
authors:
  - zwindler
type: post
date: 2024-08-29T12:00:00+02:00
url: /2024/08/29/transformer-logo-png-objet-3d/
image: /2024/08/finish.jpg
categories:
  - DIY
tags:
  - Impression 3D
  - logo
  - PNG
  - SVG
  - gimp
  - blender

---

## Impression 3D

Mes ancien⋅nes collègues m'ont offert à mon "pot de départ" une imprimante 3D et pour l'instant, je ne suis contenté d'imprimer des modèles tout prêts (ou à effectuer des modifications simples comme des modifications de taille, ce genre de choses).

![](/2024/08/sidewinder.jpg)

Cependant, je me suis décidé à prendre un peu de temps pour faire de petits objets simples hier matin et j'ai trouvé le processus simple et amusant.

D'où un article de blog :\).

## Prérequis

Le plus simple pour commencer, c'est de transformer un logo en porte-clé (ou badge, enfin un truc plat quoi). J'ai décidé de prendre des logos et de les transformer en petits objets 3D.

À partir d'un PNG de logo, j'utilise 3 outils pour réaliser la transformation :

* GIMP (ou Inkscape ou photofiltre ou ...) pour éditer l'image PNG
* un outil pour transformer le PNG final en SVG
* Blender pour transformer l'image vectorielle SVG en objets 3D

## GIMP

La première chose est de récupérer un PNG (ou un SVG, ça marche aussi), idéalement déjà détouré avec un fond transparent.

Dans le cas du logo que j'ai choisi ici, c'est déjà bon, mais sinon un coup de l'outil "baguette magique" et ça se fait assez simplement la plupart du temps, surtout pour des logos.

Si jamais le logo n'est pas contigu (comme celui de deezer, qui n'est pas d'un seul tenant), une petite astuce peut être d'ajouter une bordure blanche.

Pour ce faire, je sélectionne le vide (pour récupérer tout ce qui n'est pas le logo) avec la "baguette magique" (une fois de plus), puis j'inverse la sélection (pour sélectionner tout ce qui est logo) avec **\[CTRL\] + i**.

![](/2024/08/gimp2.png)

Ensuite, on va artificiellement ajouter une bordure à l'aide de la fonction **Sélection / Agrandir la sélection** :

![](/2024/08/gimp3.png)

![](/2024/08/gimp4.png)

Un coup de pot de peinture et on ajoute une bordure en gris (important pour la suite de ne pas prendre du blanc, les services de conversion *PNG to SVG* considèrent parfois le blanc comme du "transparent").

![](/2024/08/gimp5.png)

## PNG to SVG

Je n'ai pas trop creusé cette partie là, mais je n'ai pas trouvé comme "rapidement" transformer un PNG en SVG. Et à vrai dire, je ne me suis pas trop fatigué, car il existe des services en ligne très simples qui le font pour moi (il suffit de taper "PNG to SVG" dans son moteur de recherche préféré pour en trouver plusieurs gratuits).

![](/2024/08/png-to-svg.png)

Cependant, je regarderai à l'occasion, car j'ai quand même envie de savoir comment le faire "moi-même".

L'intérêt du SVG par rapport au PNG est qu'il est "vectoriel", ce qui va nous permettre d'interagir avec les différentes formes du logo (notamment les différentes couleurs qu'on va pouvoir utiliser de manière indépendante) dans la prochaine étape.

## Blender

Le troisième outil que je vais utiliser est blender. Je ne connaissais rien de blender ce matin, mais j'ai abondamment utilisé UnrealEd dans mes jeunes années (l'éditeur de cartes du FPS Unreal Tournament).

Rien de bien sorcier, on a un espace 3D et on peut se déplacer dans l'espace et jouer avec des formes en les ajoutant ou en soustrayant des formes à d'autres.

![](/2024/08/blender1.png)

Ici, le but du jeu va être de transformer notre SVG (une image, donc par définition en 2D) en un objet en 3D, si possible avec un relief un peu sympa qui nous permettra de reproduire les formes et les couleurs avec notre imprimante 3D.

On commence par supprimer le cube (**\[SUPPR\]**) et simplement importer le SVG via la fonction : **File / Import / Scalable Vector Graphcs (.svg)**

![](/2024/08/blender2.png)

![](/2024/08/blender3.png)

Note : ici, on remarque des stries bizarres sur notre logo. C'est un artefact visuel qui apparait typiquement quand on a deux extrémités qui se chevauchent (ici, notre logo et sa bordure qui occupent partiellement le même espace au centre). Rien de grave.

En fonction de là où on clique sur le logo, on peut voir qu'on peut manipuler telle ou telle partie.

![](/2024/08/svg1.png)

![](/2024/08/svg2.png)

D'ailleurs, les différentes parties sont référencées dans la liste des objets de la scène actuelle, en haut à droite de notre blender.

![](/2024/08/svg3.png)

## Modifier le SVG

Si on laisse le SVG tel quel, les proportions par défaut sont microscopiques. Ce n'est pas un réel problème en soi puisque les dimensions peuvent être revues à la hausse avant l'impression dans le logiciel qui gère le "slicing", mais tant qu'à faire, autant modifier pour avoir dès le début les bonnes côtes.
File / Export / STL (.stl)
Dans tous les exemples que j'ai pu tester, j'ai trouvé que rajouter un rapport 10 sur X et Y était un bon ratio (**Object properties / Scale X** et **Scale Y**) :

![](/2024/08/scale.png)

Une fois fait pour toutes les "curves", l'aspect du logo devrait être le même, juste 10 fois plus grand.

## Ajouter du relief

À partir de là, le plus simple pour donner du relief à notre logo est d'utiliser la fonction **Object Data Properties / Geometry / Extrude**.

Pour la bordure dans cet exemple, j'ai "extrude" de 0.03m, alors que pour le logo lui-même, j'ai opté pour 0.06m. C'est évidemment à adapter à ce qu'on veut faire, mais pour un porte-clé, un badge ou un dessous de verre, le mieux est d'éviter de faire des trucs trop épais (je trouve).

![](/2024/08/extrude.png)

Le truc un peu pénible avec l'outil extrude en revanche, c'est qu'il fait l'extrusion dans les deux axes Z (Z+ et Z-). On se retrouve donc avec un logo biface. Ça peut être sympa dans certains cas, mais ce n'est pas du tout ce que je veux et ça va être pénible à imprimer, car la bordure se retrouve dans le vide.

On peut "tricher" en modifiant la position de l'objet (**Object properties / Location Z**) en fonction de la taille de l'extrusion et au final ça ne rend pas trop mal. Il est aussi possible de soustraire la partie du bas en appliquant un "Modifier" sur tout ce qui est en Z < 0, mais j'ai trouvé cette manipulation plus fastidieuse.

![](/2024/08/extrude2.png)

## Et donc les "Modifiers" ?

Avec blender, on peut modifier des formes à l'aide de ce qu'on appelle des Modifiers. Le plus simple des Modifiers est celui qui va modifier la forme d'un objet à partir d'un autre objet (le Modifier Binaire).

Grosso modo, si je veux faire un trou dans mon modèle 3D pour faire un porte-clé, il va falloir que je crée un cylindre avec blender, que j'applique une soustraction de la forme du cylindre dans le modèle 3D de mon porte-clé.

Cependant, le nombre de Modifiers, et notamment le "Binaire" est plus restreint pour les objets blender de type "curves", et ce sont justement ces types d'objets qu'on manipule depuis le début.

Je vais donc devoir transformer mes "curves" en "mesh" pour pouvoir appliquer des Modifiers dessus.

Pour le faire, je dois utiliser un autre menu de blender. En haut à gauche, quand on est dans la vue **Object mode**, cliquer sur **Object / Convert / Mesh**, pour chacune de nos curves.

![](/2024/08/curves-to-mesh.png)

Une fois que c'est fait, on va ajouter un cylindre :

![](/2024/08/add-cylinder.png)

On se retrouve avec un GROS cylindre qu'on va devoir déplacer et redimensionner :

![](/2024/08/add-cylinder2.png)

* Pour le déplacer, il faut le sélectionner, puis appuyer sur la touche **g**.
* Pour le redimensionner, on peut utiliser la Scale X, Y ou Z comme on a fait précédemment, ou passer en "Edit mode" et utiliser le raccourci **\[Alt\] + s** pour activer le mode Shrink / Fatten et modifier la taille de l'objet à la souris.

![](/2024/08/shrink.png)

Une fois qu'on a bien positionné notre cylindre, on peut alors sélectionner les meshes (un par un) qu'il traverse (ici la bordure et l'élément central), puis aller dans le menu **Modifiers Properties / Add Modifier / Boolean**.

![](/2024/08/modifier1.png)

![](/2024/08/modifier2.png)

Garder **Difference** (pour soustraire le cylindre aux deux meshes), et pour l'option **Object**, appliquer le mesh **Cylinder**. 

![](/2024/08/modifier3.png)

Enfin, valider la modification en cliquant sur **Apply**.

![](/2024/08/modifier4.png)

Une fois que c'est fait sur toutes les meshes traversées par le cylindre et les modifiers appliqués, on peut supprimer le cylindre (**SUPPR**) et notre modèle 3D est terminé :\).

![](/2024/08/modifier5.png)

## Finaliser le tout

Pour exporter notre modèle 3D en un langage que comprendra le slicer, le plus simple est d'exporter le modèle dans le format le plus utilisé pour s'échanger des fichiers 3D : le .stl.

Blender supporte ce format et il suffit donc de cliquer sur **File / Export / STL (.stl)**.

Ce n'était pas compliqué et plutôt rigolo :\)