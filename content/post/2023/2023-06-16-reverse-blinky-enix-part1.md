---
title: 'Reverse du Blinky, le gyrophare connecté des copains de chez Enix - part 1'
authors:
  - zwindler
type: post
date: 2023-06-16T12:00:00+02:00
url: /2023/06/16/reverse-blinky-enix-part1/
aliases:
- /2023/06/16/revere-blinky-enix/
image: /2023/06/blinky.jpeg
categories:
  - DIY
tags:
  - Blinky
  - Gyrophare
  - Reverse engineering

---

Cet article fait partie d'une suite d'articles sur le reverse engineering d'un prototype de Gyrophare connecté appelé Blinky :
* [Reverse du Blinky, le gyrophare connecté des copains de chez Enix - part 1](/2023/06/16/reverse-blinky-enix-part1/)
* [Reverse du Blinky, le gyrophare connecté des copains de chez Enix - part 2](/2023/06/21/reverse-blinky-enix-part2/)
* [Reverse du Blinky, le gyrophare connecté des copains de chez Enix - part 3](/2023/06/23/reverse-blinky-enix-part3/)

## Introduction

Il y a quelques mois, j'ai rejoint une beta pour un projet de "gyrophare connecté", **Blinky**, lancé par [les copain⋅es de chez Enix](https://enix.io/fr/).

**Yaaaar 🦍🏴‍☠️**

La semaine dernière, j'ai donc reçu une version de test/PoC du fameux gyrophare, par la Poste (il y avait une soirée de lancement sur Paris, mais je n'étais pas disponible).

Sauf qu'un petit malin à la soirée parisienne a (a priori) récupéré le petit papier expliquant ce qu'il fallait en faire.

En temps normal, un adulte responsable aurait juste demandé aux membres de l'équipe de l'aide. Mais c'est sans compter mon côté gamin espiègle, qui a pris le dessus.

![](/2023/06/hackerman.jpg)

Pourquoi prendre 5 minutes pour demander de l'aide alors qu'on peut passer plusieurs heures à faire du ✨ *reverse engineering* ✨ ?

Note : je précise que je ne suis pas un spécialiste du reverse engineering, que je n'ai jamais bidouillé d'IoT et que je n'y connais rien en impression 3D. Je débute dans tous ces domaines. Vous pardonnerez donc mon côté noob ;-\).

## Par où commencer ?

Au moment où je décide de commencer ma session de retro ingénierie, je me dis juste qu'il y a sûrement une image Docker qui traîne quelque part pour communiquer avec le Blinky. 

Note : A ce moment-là, je ne sais pas encore que c'est un produit SaaS et je pense qu'on peut le faire tourner en local.

J'en trouve une que je télécharge, je fais quelques tests et voilà ce que ça donne quand j'arrive à la faire fonctionner :

![](/2023/06/blinky_docker_image.png)

En lisant tout ça, j'en retire plusieurs infos. Je repère les termes `esp32`, `pyboard` et je remarque surtout que l'image Docker disponible sur Internet est en version **1.0.3** alors que l'image sur mon Blinky est elle en version **2.1.0**. 

On va essayer d'éviter de l'écraser, du coup !

Comme je ne sais plus trop où chercher, je cherche des informations supplémentaires sur le site [getblinky.io](https://getblinky.io).

Je vois tout de suite une animation qui montre les entrailles du Blinky.

![](/2023/06/capture_blinky.png)

C'est pas très net, mais j'ai l'impression d'apercevoir les LEDs, un bouton poussoir, un buzzer et la mention Espressif sur le plus gros composant.

## On ouvre le Blinky pour voir

La capture d'écran faites à l'arrache est pas super nette. Comme j'ai l'objet dans les mains, le plus simple c'est de l'ouvrir pour aller voir par moi-même !

![](/2023/06/impression.jpeg)

J'y connais rien en impression 3d mais sans trop de doute, ici ça en est 😉. Je découvre par la même qu'il existe des filaments translucides, pratique pour les LEDs ;-\)

Pour ouvrir la bestiole, je vois 3 vis 6 pans. Heureusement que j'avais des tournevis étoile (t8) sous la main, ça marche quand même...

La partie supérieure est composée de plusieurs morceaux imprimés en 3d :

![](/2023/06/morceaux.jpeg)

La partie translucide, la partie supérieure sont relativement simples. La partie blanche est plus travaillée en revanche, et permet de faire "ressort" pour le bouton poussoir.

Dans la partie inférieure, on trouve les pas de vis, fusionnées.

![](/2023/06/vis.jpeg)

Je ne savais pas comment c'était possible de faire ça, heureusement le *Twitter makers* m'a expliqué que ça se faisait super simplement, à l'aide d'un fer à souder ([cf cette vidéo](https://www.youtube.com/watch?v=hwq15qH-4x4))!

Et voilà le morceau que vous attendiez tous/toutes : le circuit imprimé qui pilote tout ça :

![](/2023/06/back.jpeg)
![](/2023/06/front.jpeg)

On retrouve tout ce que j'avais pu observer sur la capture d'écran faite sur le site http://getblinky.io mais sur quelque chose de bien plus clean. Il y a des LEDs, un buzzer, le bouton poussoir et... le fameux esp32 espressif !

![](/2023/06/espressif.jpeg)

A priori, je l'ai remonté sans rien casser 🤣

## A la découverte de l'ESP32

Maintenant que j'ai une photo plus nette de l'ESP32, je peux commencer à me documenter dessus.

Il s'agit d'un **ESP32-WROOM-32E** de chez ESPRESSIF, dont [les specs sont disponibles ici](https://espressif.com/sites/default/files/documentation/esp32-wroom-32e_esp32-wroom-32ue_datasheet_en.pdf) 

Je remarque qu'il dispose du WI-FI, j'en ai déduit que c'était probablement une machine autonome, une fois connectée au réseau.

Niveau puissance, on est sur un *dual-core 32-bit LX6* 🤷, qui monte jusqu'à (tenez-vous bien) 240 MHz ! 

Je blague, mais en vrai c'est même trop pour ce qu'on va en faire ;-\).

Par curiosité, je suis allé voir mon copain Ali, et ça coûte 3,34€ pièce pour ce modèle exact (https://fr.aliexpress.com/item/33007945338.html).

En revanche, je n'ai aucune idée de combien ça coûte de faire produire le circuit sur lequel il est branché (c'est visiblement fait en usine).

## On se connecte ?

Une fois que je connecte en USB mon Blinky, je vois apparaître une ligne ` Silicon Labs CP210x UART Bridge` quand je lance la commande `lsusb`.

Une rapide recherche permet de comprendre que c'est bien notre port série virtuel (via USB)

https://silabs.com/developers/usb-to-uart-bridge-vcp-drivers

> The CP210x USB to UART Bridge Virtual COM Port (VCP)

Donc ça, ça fonctionne correctement.

La [doc officielle sur le site **espressif**](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/establish-serial-connection.html#example-output) dit d'ajouter son utilisateur au groupe *dialout*

```bash
sudo usermod -a -G dialout $USER
```

Puis d'utiliser `putty` pour se connecter en série sur le **ttyUSB0** :-/. Personnellement (sous Linux), je n'ai pas réussi. En revanche, je remarque qu'on peut utiliser `screen`, sous Mac. Pas de raison que ça ne marche pas sous Linux.

Et effectivement, ça fonctionne. 

![](/2023/06/screen.png)

Le `screen` a l'air bloqué mais... un simple [Ctrl-C] et me voilà dans le terminal python...

```
Traceback (most recent call last):
  File "main.py", line 7, in <module>
  File "firmware_blinky_esp32.py", line 92, in main
  File "uasyncio/core.py", line 1, in run_forever
  File "uasyncio/core.py", line 1, in run_until_complete
  File "firmware_blinky_esp32.py", line 69, in start
  File "serial_cli.py", line 101, in poll_cli
KeyboardInterrupt: 
MicroPython v1.18 on 2023-04-26; ESP32 module with ESP32
Type "help()" for more information.
>>> 
```

C'est le moment dans les films d'espions où le hacker dit "I'm in" 😎.

## On va essayer de trouver du code

Maintenant qu'on a la main sur l'interpréteur Python, on va pouvoir farfouiller un peu :\).

J'avais déjà vu mention de `pyboard` dans l'image Docker, ce qui m'avait emmené sur [la doc de MicroPython](https://docs.micropython.org/en/latest/). Ici, on a bien la confirmation que c'est MicroPython qui tourne sur le Blinky.

> MicroPython v1.18 on 2023-04-26; ESP32 module with ESP32

La première idée qui vient à l'esprit est de parcourir le filesystem, pour voir si je peux pas trouver les sources.

```python
>>> import os
>>> os.[TAB]
remove          VfsFat          VfsLfs2         chdir
dupterm         dupterm_notify  getcwd          ilistdir
listdir         mkdir           mount           rename
rmdir           stat            statvfs         umount
uname           urandom
>>> os.getcwd()
'/'
>>> os.listdir()
['flash', 'boot.py']
>>> os.listdir('/flash')
['client.crt', 'client.key', 'hw_version']
>>> with open('flash/hw_version') as f:
...     s = f.read()
... 
>>> print(s)
v1mk3
```

La capture précédente montre tout ce que je peux voir sur le FS et je ne vois pas le code source. Le fichier `boot.py` ne contient rien (tout est commenté), `hw_version` affiche juste **v1mk3**, la version de mon Blinky (comme on a pu le voir au dos du circuit imprimé).

## Je découvre des trucs en Python

Un peu par hasard, j'ai testé la commande `dir()`, qui m'affiche ce qui est chargé en mémoire, et qu'on peut afficher des infos dessus avec `help()` :

```
>>> dir()
['uos', '__name__', 'app', 'gc', 'bdev', 'mount_flash']
```

Il y a tout un tas de type d'objets, des strings (`__name__`), des fonctions, des modules...

Il y en a une entrée qui me fait de l’œil : "app". Il se trouve que c'est un module.

```
>>> dir(app)
['__class__', '__name__', 'main', 'start', '__file__', 'Pin', 'log', 'machine', 'network', 'uasyncio', 'NEO_PIXEL', 'handle_pbpv2_message', 'BEACON_ID', 'PATTERNS', 'STATUS', 'BUTTON', 'VERSION', 'load_config', 'check_config', 'poll_cli', 'MQTT', 'set_status_pixel', 'init_logger', 'resetting', 'handle_button_release', 'greetings', 'exception_handler']
```

Et avec plus de détails :

```
>>> help(app)
object <module 'firmware_blinky_esp32' from 'firmware_blinky_esp32.py'> is of type module
[...]
  set_status_pixel -- <function set_status_pixel at 0x3ffe73a0>
[...]
```

Note : j'omets volontairement une grande partie des infos qu'on peut dénicher, on y reviendra plus tard.

La première chose qui me saute aux yeux est qu'il existe une fonction `set_status_pixel()`

Si je la lance telle quelle, j'apprends qu'elle attend un argument : 

```
>>> app.set_status_pixel()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: function takes 1 positional arguments but 0 were given
```

Et comme par hasard, j'ai une structure **STATUS** qui contient des tuples qui ressemblent très fortement à des codes RGB.

```
[...]
  STATUS -- {'configuring': (0, 0, 255), 'connecting_to_wifi': (255, 0, 0), 'connecting_to_mqtt': (255, 100, 0), 'ready': (0, 255, 0)}
```

Qu'est ce qu'il se passe si je lance la fonction suivante ??? 🕵️‍♂️

```python
>>> app.set_status_pixel((255, 0, 0))
```

![](/2023/06/red.jpeg)

BINGO !

## La suite ?

Je m'arrête ici pour que l'article reste digeste, mais j'ai plein d'idée pour aller plus loin (j'ai d'ailleurs bien commencé).

Le but du jeu va être de trouver comment piloter les LEDs (voire plus ?), comment communiquer avec le Blinky (MQTT ?) et continuer à chercher pour trouver où est ce coquin de code source ;-\)
