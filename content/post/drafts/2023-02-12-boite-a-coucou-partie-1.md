---
title: La boite à coucou - partie 1
authors:
  - zwindler
type: post
date: 2023-02-12T06:00:00+02:00
draft: true
url: /2023/02/12/boite-a-coucou-partie-1
image: /2021/11/wordpress-to-hugo.png
categories:
  - Divers
tags:

---

Je préviens tout de suite, je n'ai pas encore terminé ce **side project**, pour plein de bonnes et de mauvaises raisons.

Cependant, j'avais pas mal avancé et je trouve dommage de ne pas vous partager les premières étapes dans une série d'articles que je sortirai au fur et à mesure.

## Introduction

Une blague des Guignols de l'info a bercé mon enfance : la boite à coucou.

Pour les plus jeunes d'entre vous (ou vieux pas *branchés* canal), il s'agissait d'un running gag dans lequel la marionnette de Johnny Hallyday faisait sonner un "coucou" en prononçant la phrase "à que coucou". A l'époque, ça faisait beaucoup rire (surtout l'enfant que j'étais).

[Vimeo - compilation de sketchs de la "boite à coucou"](https://vimeo.com/59258528?embedded=true&source=vimeo_logo&owner=16304447)

Depuis, le monde à changé. Les guignols ne sont plus drôles, Johnny est mort. Sur une note plus positive, je suis devenu papa et l'absurdité de ce sketch me fait toujours rire. 

Si bien que je l'ai montré à ma fille de 2 ans et demi (à l'époque de l'écriture des premières lignes de cet article), et elle aussi adore ce sketch.

C'était donc l'occasion rêvée pour avoir une excuse pour bidouiller un truc débile : fabriquer une boite à coucou comme dans le sketch.

## De quoi on a besoin ?

Avant de faire une liste de course et dépenser tout notre argent, il faut déjà penser à ce dont on a *vraiment* besoin, fonctionnellement parlant.

* Dans le sketch de la boite à coucou, Johnny dispose d'une boite (souvent cubique, environ 10 cm de côté). 
* Dans cette boite, il y a un mécanisme de type "coucou d'horloge", composé d'un petit oiseau. 
* Cet oiseau sort de la boite et émet un son lorsque Johnny prononce la phrase "ah que coucou".

On se rend bien compte, avec cet énoncé qu'il va nous falloir des choses différentes. On va pouvoir *lotir* le projet puisque plusieurs parties sont indépendantes les unes des autres.

D'abord, il faut être capable d'écouter les bruits ambiants et déclencher une réponse (action) dès que la phrase "ah que coucou !" est prononcée. 

On va donc avoir besoin d'un micro et bien sûr d'un circuit électronique capable de traiter le son en entrée et déterminer si la phrase magique a été prononcée ou non.

Une fois la phrase détectée, l'action résultante se découpe en deux parties : ouvrir la boite et faire sortir le coucou, et simultanément, jouer un son.

Pour la première partie, on a donc besoin d'un moteur ainsi que d'un petit mécanisme capable de faire sortir puis re-rentrer le coucou. Et bien sûr, il nous faudra être capable de piloter ça avec un minimum de précision et si possible doit se faire assez rapidement (comme dans le sketch).

Pour la deuxième partie, le circuit électronique doit être capable de stocker et "jouer" un son de coucou. Il faut donc aussi un haut parleur.

Enfin, le tout doit loger dans une boite, pas trop grosse. Idéalement cette boite doit être autonome (sur batterie, éventuellement sans aucune connexion au réseau).

## Lotissement du projet

Oui, je place du jargon de gestion de projet juste pour le plaisir.

Le projet est quand même relativement ambitieux pour un bidouilleur du dimanche comme moi. Il y a plusieurs domaines que je ne maitrise pas.

Aussi, pour limiter les risques d'échecs, le plus simple est de découper (et même sous-traiter) le projet en plusieurs parties.

Il y a clairement une partie plus "matérielle". Cette partie se découpe elle même en deux parties :
* La boite, avec le mécanisme pour ouvrir le couvercle / faire monter le coucou 
* La partie électronique avec le moteur qui va réaliser cette montée / descente

On a aussi une partie "logicielle" de notre "boite à coucou". On a besoin d'un ordinateur et d'un programme informatique capable :
* d'enregistrer et traiter de la voix à la volée
* de jouer un son
* de contrôler le moteur de notre mécanisme de coucou

Chacun de ces "bullets points" sont des lots qu'on peut traiter à part dans un premier temps.

J'ai d'ailleur délégué la partie "matérielle" à mon père, qui est électronicien de formation et qui adore ce genre de choses. 

Nous avons maintenant un projet transgénérationnel :)

## La liste de courses

Maintenant qu'on sait comment va marcher le projet, de quoi a-t-on besoin, pour faire un boite à coucou ?

* D'un **micro-ordinateur** suffisament compact et économe en énergie pour rentrer dans la boite à coucou
* D'un **microphone** et d'un **haut parleur** à raccorder à notre micro-ordinateur
* D'une **boite**, avec un couvercle articulé, suffisament grande pour faire rentrer le tout
* D'un **mécanisme** et d'un **moteur** pour soulever le couvercle et le coucou
* D'un **circuit électronique** pour actionner le moteur

Pour la partie "micro-ordinateur", j'ai choisi un raspberry pi 4 par facilité (un 3b aurait très certainement fait l'affaire). A l'époque où le projet a été commencé, il était encore pas difficile d'en trouver.

Il sera beaucoup plus simple de réaliser les tâches logicielles que nous auront à faire car :

* C'est un micro-ordinateur compact et polyvalent, extrèmement souvent utilisé pour ce genre de projet. Il est adapté et on trouvera plus facilement du support en cas de problème
* Il est relativement puissant et la reconnaissance vocale est potentiellement consommatrice de ressources
* On peut installer facilement Linux dessus, ce qui nous permet d'avoir accès à de nombreux langages de programmation et librairies toutes faire pour éviter de tout réécrire nous même
* Il consomme "relativement peu" (même si c'est bien plus qu'un Arduino, c'est quand même négligeable) ce qui permet de l'alimenter via une batterie si on veut sans difficulté

Idéalement, il faudrait aussi que le **circuit électronique** pour actionner le moteur soit le raspberry pi lui même. 

Cependant, dans un premier temps, mon père étant plus à l'aise avec les circuits de type arduino, on est partis sur cette hypothèse là, en sachant qu'on devra les faire communiquer d'une façon ou d'une autre (via les ports IO du raspberry, ça parait faisable).

## Le choix du langage

Je pourrais dire que j'ai choisi Python pour ses qualités pour ce projet (langage interprété donc pratique pour bidouiller et tester unitairement en mode trial&error, également très utilisé pour le machine learning, etc).

La réalité et qu'à l'époque, c'était le seul langage où je me sentais suffisamment à l'aise pour avancer rapidement.

Cependant, c'était un bon choix comme nous le verrons dans cet article et les suivants, car l'écosystème python est relativement riche par rapport à toutes les briques logicielles dont je vais avoir besoin pour réaliser le projet.

## Récupérer le son

Histoire de capitaliser rapidement sur un "quick-win", j'ai tout de suite travaillé sur la partie la plus simple du projet : "jouer un son".

Je n'ai pas trouvé le son de la **boite à coucou** dans une banque de sons. C'est dommage car je l'avais ce son (en WAV) quand j'étais enfant. Je m'amusais beaucoup avec, d'ailleurs.

Pour récupérer le son de "la boite à coucou", je me suis donc rabattu sur Youtube. J'ai trouvé une vidéo qui contenait ce son, et j'ai téléchargé la vidéo.

Le plus simple est d'installer `youtube-dl`, utilitaire plus que connu pour réaliser ce genre de choses.

```bash
pip3 install youtube-dl
youtube-dl  https://youtu.be/XXXXXXXXX
```

Comme la vidéo contenait des bouts de sketchs complets et que je ne souhaite garder que la partie où le coucou fait "coucou", j'ai donc utilisé audacity pour manipuler la piste audio de la vidéo téléchargée, et en extraire la partie qui m'intéresse.

```bash
sudo apt-get install audacity
audacity fichier_telecharge.mp4
```

![](/2023/02/audacity.png)

## Jouer le son

Les premiers tutos que j'ai trouvé pour jouer des sons en Python parlaient de `tk`. Cependant ça marchait assez mal, j'ai du faire tout un tas de bidouilles à base de liens symboliques.

J'ai donc cherché un peu lui loin et j'ai trouvé un exemple utilisant le module python `simpleaudio` qui lui a marché du premier coup :

```bash
sudo apt-get install libasound2-dev
pip3 install simpleaudio
```

On peut jouer le son avec un bout de Python trivial : 

```python
#!/usr/bin/env python3
from playsound import playsound

playsound("binaries/boite_a_coucou.wav")
```

## Suite

TODO

## Sources

Le sketch de la boite à coucou

* [BFMTV.com - "Ah que coucou": la petite histoire de la célèbre marionnette de Johnny aux Guignols](https://www.bfmtv.com/people/ah-que-coucou-la-petite-histoire-de-la-celebre-marionnette-de-johnny-aux-guignols_AN-201712060090.html)
* [Vimeo - compilation de sketchs de la "boite à coucou"](https://vimeo.com/59258528?embedded=true&source=vimeo_logo&owner=16304447)

Jouer un son

* [linuxhint - How to Play Sound in Python](https://linuxhint.com/play_sound_python/)
* [ubuntu forums - could not gain access to /dev/sound/dsp for writing](https://ubuntuforums.org/showthread.php?t=1402442)
