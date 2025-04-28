---
title: 'Reverse du Blinky, le gyrophare connecté des copains de chez Enix - part 3'
authors:
  - zwindler
type: post
date: 2023-06-23T12:00:00+02:00
url: /2023/06/23/reverse-blinky-enix-part3/
image: /2023/06/blinky2.jpg
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

## Rappel des épisodes précédents

Dans les articles précédents, j'avais reçu un gyrophare connecté conçu par les copain⋅es de chez Enix et plutôt que de tester leur produit en SaaS (la vraie proposition de valeur), j'ai décidé de faire un peu de reverse engineering dessus. 

A l'issue du tout dernier article, j'ai réussi à piloter les LEDs et faire des patterns rigolos avec.

## Bouton ?

Je n'ai toujours pas le code source à ma disposition donc je teste un peu tout ce que je trouve, au fur et à mesure.

Un des composants que j'avais repérés lors de mon exploration était un bouton poussoir. Je ne savais jusqu'à présent pas comment l'utiliser, mais j'avais repéré 2 choses visiblement en rapport :

```python
>>> help(app)
>>> >>> help(app)
object <module 'firmware_blinky_esp32' from 'firmware_blinky_esp32.py'> is of type module
[...]
  handle_button_release -- <function handle_button_release at 0x3ffe7ad0>
[...]
  BUTTON -- Pin(13)
[...]
```

J'avais déjà essayé de jouer avec, mais j'avais reçu l'erreur suivante :

```python
>>> app.handle_button_release()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: function takes 1 positional arguments but 0 were given
```

Ne sachant pas trop quel type d'argument était attendu... J'ai testé une string au hasard

```python
>>> app.handle_button_release("toto")
ets Jul 29 2019 12:21:46

rst:0xc (SW_CPU_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
configsip: 0, SPIWP:0xee
clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
mode:DIO, clock div:2
load:0x3fff0018,len:4
load:0x3fff001c,len:4252
load:0x40078000,len:11920
load:0x40080400,len:3344
entry 0x4008060c
```

<div id=video><video controls="controls" height="500" src="/2023/06/blink.mp4"></video></div>

AH !

Au moment où on pousse déclenche la fonction, le blinky fait 3 flashs très brefs (bleu, vert, rouge, je ne sais pas dans quel ordre) et redémarre.

J'en déduis que c'est comme cela que l'acquittement des "alertes", reçues depuis le SaaS, est réalisé.

A noter, on s'en servira peut-être plus tard, mais **SPI_FAST_FLASH_BOOT** m'a permis de trouver des [informations complémentaires sur la façon dont boot l'ESP32 ici](https://docs.espressif.com/projects/esptool/en/latest/esp32/advanced-topics/boot-mode-selection.html).

Visiblement il y a plusieurs modes de boot et je pourrais peut-être trouver des choses intéressantes là dessus.

## Bouton encore

Tout ça c'est intéressant, mais j'aimerais pouvoir réaliser autre chose que juste flasher très vite et reboot l'ESP32...

Le code précédent que j'ai trouvé laisse penser que le bouton c'est le Pin(13). Je cherche des tutos sur le net pour savoir comment jouer avec un bouton et je tombe [sur ce tutoriel](https://microcontrollerslab.com/push-button-esp32-esp8266-micropython-digital-input/).

En théorie, j'ai juste à vérifier la valeur du **Pin(13)** en position IN pour détecter un appui.

Sauf que j'ai beau appuyer sur le bouton, la valeur reste toujours à 0. Je commence à me demander si c'est le bon Pin...

```
>>> app.Pin(2, app.Pin.IN).value()
0
>>> app.Pin(2, app.Pin.IN).value()
0
>>> app.Pin(2, app.Pin.IN).value()
0
```

Après quelques tests bourrins (j'ai testé plusieurs valeurs), bingo !

```
>>> app.Pin(16, app.Pin.IN).value()
0
>>> app.Pin(16, app.Pin.IN).value()
1
```

La valeur passe à 1 quand je maintiens le bouton appuyé ! Pour le fun j'ai écrit un petit bout de code qui change la couleur du NeoPixel quand on clique :

```python
[CTRL-E]
from time import *
from random import randint
def led_color_random_when_clicked():
    button_state = 0
    while True:
        current_state = app.Pin(16, app.Pin.IN).value()
        if current_state and not button_state:
            r = randint(0, 100)
            g = randint(0, 100)
            b = randint(0, 100)
            for led in range(1, 13):
                app.NEO_PIXEL[led] = (r, g, b)
            app.NEO_PIXEL.write()
        button_state = current_state
        sleep_ms(50)
[CTRL-D]
```

<div id=video><video controls="controls" height="500" src="/2023/06/click.mp4"></video></div>

Note : la valeur du click est pas super stable au moment où on lâche le bouton. D'où l'ajout d'un sleep de 50ms pour stabiliser la valeur du bouton.

## Du son ?

Lors de mon démontage, j'avais pensé repérer un buzzer (cf [le premier article](/2023/06/16/reverse-blinky-enix-part1/)). Une rapide recherche sur Internet sur la marque **FUET** me laisse penser que c'est plutôt un speaker et qu'on peut donc jouer plus que des sons mais aussi des WAV.

Assez rapidement, je suis tombé sur la doc de [micropython à ce sujet](https://docs.micropython.org/en/latest/library/machine.I2S.html) et j'ai pu déterminer qu'il fallait chercher des exemples de codes avec "I2S".

J'ai donc trouvé un bout de code assez bien documenté et complet pour expliquer comment enregistrer et jouer des sons avec plusieurs types de boards, avec micropython.

Malheureusement, même en changeant certaines combinaisons de paramètres (notamment les pins SCK_PIN, WS_PIN et SD_PIN), j'ai été incapable de faire fonctionner le speaker, même sur un exemple simple avec une bête tonalité.

* [github.com/miketeachman/micropython-i2s-examples/blob/master/examples/play_tone.py](https://github.com/miketeachman/micropython-i2s-examples/blob/master/examples/play_tone.py)

Si j'avais réussi, j'aurai profité de ce que j'ai appris lors du deuxième article pour copier un WAV et vous faire marrer avec une idée à la c**.

## Du stockage ?

Tant qu'on parle de tests non concluants, j'ai aussi remarqué la présence d'un composant appelé **W25Q128JVSIQ**, de marque **winbond**. On peut [trouver les specs ici](https://www.mouser.fr/ProductDetail/Winbond/W25Q128JVSIQ?qs=qSfuJ%252Bfl%2Fd6tLXvPR4fl9w%3D%3D). Il s'agit d'une mémoire flash de 128 Mbit et qui coûte entre 1 et 2 euros.

En re-parcourant tous les objets en mémoire, j'ai (re)découvert la présence d'un objet "bdev" qui semble être une partition (probablement le stockage monté dans /flash, qui contient le fichier `hw_version` ainsi qu'un couple clé privée/clé publique ? cf [le premier article](/2023/06/16/reverse-blinky-enix-part1/)).

```
>>> help(bdev)
object <Partition type=1, subtype=129, address=2097152, size=2097152, label=vfs, encrypted=0> is of type Partition
  find -- <staticmethod>
  info -- <function>
  readblocks -- <function>
  writeblocks -- <function>
  ioctl -- <function>
  set_boot -- <function>
  mark_app_valid_cancel_rollback -- <classmethod>
  get_next_update -- <function>
  BOOT -- 0
  RUNNING -- 1
  TYPE_APP -- 0
  TYPE_DATA -- 1
>>> bdev.info()
(1, 129, 2097152, 2097152, 'vfs', False)
>>> uos.statvfs('/')
(4096, 4096, 512, 509, 509, 0, 0, 0, 0, 255)
>>> uos.statvfs('/flash')
(512, 512, 32768, 32758, 32758, 0, 0, 0, 0, 255)
```

Quelques docs en vrac :
* [docs.micropython.org/en/latest/library/machine.SDCard.html](https://docs.micropython.org/en/latest/library/machine.SDCard.html)
* [micropython.fr/modules_center/seriel_spi/module_sd_card_spi/](https://micropython.fr/modules_center/seriel_spi/module_sd_card_spi/)

## Conclusion ?

On ne va pas se mentir... Je suis un poil déçu de ne pas avoir réussi à trouver le code source...

Je me demande vraiment comment c'est possible de lancer du code python sans qu'il soit visible sur le filesystem. Je me dis que j'ai forcément loupé un truc et ça me laisse un sentiment d'inachevé.

Mais j'y ai passé beaucoup de temps (tout n'est pas détaillé ici mais j'ai été cherché par mal d'infos, notamment sur la façon dont on boot la board et sur le stockage flash/SD, sans succès).

Un peu déçu aussi de ne pas avoir trouvé les bons paramètres pour piloter le speaker, j'aurais bien fait un petit bout de code avec du son en plus de la lumière. A voir ce que l'équipe ajoutera de ce côté.

J'ai laissé tomber la partie MQTT. Je suis certain que j'aurais réussi à faire marcher la communication avec l'ESP32 et un serveur Mosquitto ou RabbitMQ et j'avais déjà configuré le réseau ([dans le 2ème article](/2023/06/21/reverse-blinky-enix-part2/)).

Pour autant, ce n'est pas la fin !

Maintenant que je met sde côté (au moins provisoirement) le reverse du blinky, je peux me concentrer sur la partie SaaS et enfin "enroll" mon device dans le site mis à disposition par Enix, pour commencer à jouer avec "pour de vrai".

On verra si ça m'amène d'autres idées. En attendant, have fun :-\)
