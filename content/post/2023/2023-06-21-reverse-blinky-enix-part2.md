---
title: 'Reverse du Blinky, le gyrophare connecté des copains de chez Enix - part 2'
authors:
  - zwindler
type: post
date: 2023-06-21T12:00:00+02:00
url: /2023/06/21/reverse-blinky-enix-part2/
image: /2023/06/noepixel2.jpeg
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

Dans l'article précédent, j'avais reçu un gyrophare connecté conçu par les copain⋅es de chez Enix. Comme je n'avais pas reçu les instructions comme les autres destinataires de ce prototype, j'avais décidé de faire un peu de reverse engineering dessus, même si à vrai dire je n'y connais pas grand-chose.

[L'article précédent est disponible ici](/2023/06/16/reverse-blinky-enix-part1/).

Je m'étais arrêté en changeant la couleur des LEDs, car j'avais réussi à deviner que la fonction `app.set_status_pixel()` prenait comme argument un tuple RGB.

Mais c'est encore un peu pénible de deviner comme utiliser le blinky sans avoir le code source. J'ai donc tenté de le trouver...

## inspect ?

Ma première idée a été de chercher sur les Internets comment aller récupérer le code source d'une fonction en mémoire en python.

En iPython, il existe un moyen d'afficher directement le code d'une fonction en ajoutant en suffixe d'une fonction "??". Pas de bol, Micropython n'implémente pas ça :\(

En CPython, il existe un module "inspect" en CPython qui permet (entre autres) de faire ce que je veux faire. Je suis assez vite tombé sur un module pip **micropython-inspect** 

* [pypi.org/project/micropython-inspect](https://pypi.org/project/micropython-inspect/)

> This is a module reimplemented specifically for MicroPython standard library, with efficient and lean design in mind.

Reste à trouver comment installer un module pip sur notre ESP32. Evidemment, comme je n'ai pas de shell, impossible de faire `pip install` directement.

ChatGPT (oui, j'ai demandé de l'aide 🤖) me propose 2 solutions :
- utiliser le module "upip" qui permet de télécharger les modules portés pour MicroPython
- télécharger un "remote shell" pour MicroPython

Essayons la première solution...

```python
>>> import upip
>>> upip.install("inspect")
Installing to: /lib/
Error: Unable to resolve micropython.org (no Internet?)
```

Evidemment ça ne peut pas marcher, vu que je n'ai encore pas configuré Internet 🤦. Mais on avait vu que c'était possible dans l'article précédent, puisque l'ESP32 Espressif du Blinky dispose de WIFI.

On trouve assez vite comment faire sur la doc de micropython :

```python
>>> import network
>>> wifi = network.WLAN(network.STA_IF)
>>> wifi.connect("xxxxxx", "xxxxxx")
>>> while not wifi.isconnected():
...     pass
...
>>>
>> print("Connected! IP address:", wifi.ifconfig()[0])
Connected! IP address: 192.168.x.y
```

La preuve donc que cette board a bien un module wifi fonctionnel !! Bon à savoir, ça sera utile :\)/

Une fois qu'on a le réseau, on peut télécharger des packages pour notre board... mais là, c'est le drame...

![](/2023/06/inspect.png)

``` python
inspect.getsource(app.main)
'<source redacted to save you memory>'
```

What the actuel frak???

En copiant collant la ligne de sortie, je tombe sur ce fichier source...

* [github.com/micropython/micropython-lib/blob/master/python-stdlib/inspect/inspect.py](https://github.com/micropython/micropython-lib/blob/master/python-stdlib/inspect/inspect.py#L67)

En gros, ce module ne fait de définir les fonctions, mais l'implémentation n'a pas été faite...

## rshell

Passons à la 2ème idée de ChatGPT, utiliser un shell depuis notre PC.

Sur mon PC :

```console
$ pip3 install rshell

rshell --port /dev/ttyUSB0
```

A partir de là, on peut lister les boards avec la commande `boards` (si on en a plusieurs connectées), faire des `cat`, des `cp` entre le PC et la board...

![](/2023/06/rshell-repl.png)

C'est assez utile pour du debug, mais comme je n'avais pas trouvé le code sur le filesystem dans mes tentatives précédentes (à part en mémoire), ça ne m'aide pas plus...

Quelques liens utiles 
* [wiki.mchobby.be/index.php?title=MicroPython-Hack-RShell](https://wiki.mchobby.be/index.php?title=MicroPython-Hack-RShell)
* [github.com/dhylands/rshell](https://github.com/dhylands/rshell)

## webrepl

Pendant mes premières explorations, j'avais remarqué qu'il y avait un fichier `boot.py` qui ne contenait que tu codes commenté. Je l'avais donc ignoré.

En allant relire le contenu du fichier je suis tombé sur ça :

```python
# This file is executed on every boot (including wake-boot from deepsleep)
#import esp
#esp.osdebug(None)
#import webrepl
#webrepl.start()
```

J'ai donc tenté de lancer les commandes dans mon shell Python sur la board :


```python
>>> import esp
>>> esp.osdebug(None)
>>> import webrepl
>>> webrepl.start()
WebREPL is not configured, run 'import webrepl_setup'
```

Qu'est ce que c'est que WebREPL ? 

```python
>>> import webrepl_setup
WebREPL daemon auto-start status: disabled

Would you like to (E)nable or (D)isable it running on boot?
(Empty line to quit)
> e
To enable WebREPL, you must set password for it
New password (4-9 chars): xxxxxx
Confirm password: xxxxxx
Changes will be activated after reboot
Would you like to reboot now? (y/n) y
```

Après reboot, je remarque la ligne suivante :

```
WebREPL daemon started on ws://192.168.x.y:8266
Started webrepl in normal mode
```

Ahah ! On va pouvoir accéder à un autre shell à distance !

En cherchant rapidement, je tombe sur [ce dépôt git](https://github.com/micropython/webrepl). Il explique comment ça marche et indique qu'il faut un client pour parler avec le websocket. Il y a une version web du client que je n'ai pas réussi à faire marcher.

En revanche, en clonant le dépôt et en utilisant le client local, ça fonctionne.

Sur mon PC :

```bash
git clone https://github.com/micropython/webrepl
```

Je lance ensuite le fichier html, je peux me connecter avec l'IP de mon Blinky (connecté en WIFI) et un mot de passe.

![](/2023/06/webrepl.png)

J'ai donc un 3ème shell sur le Blinky (c'est cool), mais je ne suis toujours pas plus avancé :-p. Je referme donc ce chapitre (je ne dirais pas que c'est un échec, je dirais que ça n'a pas marché).

## Tu es l'élu, Néo (Pixel)

Retour sur notre shell, avec les infos que j'ai. Dans ce que `help(app)` m'a remonté, il y a cet objet qui m'intrigue :

```python
NEO_PIXEL -- <NeoPixel object at 3ffe8300>
```

Une rapide recherche avec le terme NEOPIXEL me sort ce site [gcworks.fr/tutoriel/esp/LEDNeoPixel](https://gcworks.fr/tutoriel/esp/LEDNeoPixel.html)

> Les NeoPixel sont des LEDS RVB intelligentes ultra lumineuses.
> Exemple : ce petit module sous la forme d'un stick, est équipé de 8 NeoPixels.

Ca sent très très bon cette histoire ! Mon blinky c'est quand même un peu un ruban de LED rond ! Le site donne même du code d'exemple pour tester :

```python
import machine
import neopixel      # import de la bibliothèque NeoPixel
np = neopixel.NeoPixel(http://machine.Pin(26), 8)  # 8 LEDS connectées broche 26 (D2 shiel base 1)
np[0] = (255, 0, 0)
np.write()
```

Petit retour en arrière, quand j'avais démonté le blinky, voilà à quoi ça ressemblait :

![](/2023/06/leds.jpeg)

Si on regarde plus en détail, on remarque qu'il y a 13 LEDs sur notre Blinky. Une au milieu (**led_status**) et 12 autres en cercle.

Il est donc probable que mon tableau neopixel fasse une taille de 13 cases. Cependant, difficile de deviner sur quel PIN le ruban est connecté avec cette photo...

Je suis donc parti du principe que c'était bien le pin 26 et j'ai testé le code d'exemple... sans succès...

```python
>>> np = neopixel.NeoPixel(app.Pin(26),12)
>>> np[1] = (255, 255, 0)
>>> np.write()
>>> np[2] = (255, 255, 0)
>>> np.write()
>>> np[3] = (255, 255, 0)
>>> np.write()
```

Et puis, j'ai réfléchis et je ne suis dis... "pourquoi je m'embête à déclarer un objet NeoPixel, puisque j'en ai déjà un en mémoire 🤔 ???"

```
>>> app.NEO_PIXEL
<NeoPixel object at 3ffe8300>
>>> app.NEO_PIXEL[0]
(0, 0, 255)
>>> app.NEO_PIXEL[1]
(0, 0, 0)
>>> app.NEO_PIXEL[2]
(0, 0, 0)
>>> app.NEO_PIXEL[12]
(0, 0, 0)
```

A l'état initial du Blinky, toutes les leds sont bien positionnées sur "(0, 0, 0)" (éteint), et la **led_status** à "(0, 0, 255)" (bleu). On est pas mals là !

```
>>> app.NEO_PIXEL[13]
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "neopixel.py", line 1, in __getitem__
  File "neopixel.py", line 1, in <genexpr>
IndexError: bytearray index out of range
```

Il n'y a pas de case 13, comme j'avais deviné (de 0 à 12).

Et si je change une couleur sur une LED...

```
>>> app.NEO_PIXEL[1]=(255, 0, 0)
>>> app.NEO_PIXEL.write()
```

![](/2023/06/noepixel.jpeg)

BINGO !

## Et maintenant... que vais-je fai-re ?

Bon, on a toujours pas trouvé ce fichu code source et je commence à manquer d'idées... Mais on a du réseau et on a pas encore été graté du côté du MQTT (il y a des choses qui sont configurées)... On va probablement regarder de ce côté là dans le prochain épisode !

## Bonus, faire des trucs rigolos avec mes LEDs

En bonus, je vous met quelques bouts de codes que je me suis amusés à écrire et qui font des trucs jolis / mignons avec le blinky :

J'ai découvert sur le tard qu'on pouvait copier coller de large morceaux de codes indentés avec [CTRL-E], puis [CTRL-D] pour valider.

<div id=video><video controls="controls" height="300" src="/2023/06/blinky1.mp4"></video></div>
<div id=video><video controls="controls" height="300" src="/2023/06/blinky2.mp4"></video></div>
<div id=video><video controls="controls" height="300" src="/2023/06/blinky3.mp4"></video></div>

```
[CTRL-E]

from time import *
from random import randint

def full_random():
    while True:
        r = randint(0, 100)
        g = randint(0, 100)
        b = randint(0, 100)
        for led in range(1, 12):
            app.NEO_PIXEL[led] = (r, g, b)
        app.NEO_PIXEL.write()
        sleep_ms(100)

def full_random_rotation():
    while True:
        for led in range(1, 12):
            r = randint(0, 100)
            g = randint(0, 100)
            b = randint(0, 100)
            app.NEO_PIXEL[led] = (r, g, b)
            app.NEO_PIXEL.write()
            sleep_ms(50)

def blue_rotation():
    while True:
        for led in range(1, 12):
            for i in range(1,12):
                app.NEO_PIXEL[i] = (0, 0, 0)
            app.NEO_PIXEL[led] = (0, 0, 255)
            app.NEO_PIXEL.write()
            sleep_ms(100)

def kitt():
    # Set all leds to black
    for i in range(0, 12):
        app.NEO_PIXEL[i] = (0, 0, 0)
    while True:
        # Forward loop from 2 to 6 (7 excluded)
        for led in range(2, 7):
            app.NEO_PIXEL[led] = (150, 0, 0)
            app.NEO_PIXEL.write()
            sleep_ms(100)
            app.NEO_PIXEL[led] = (0, 0, 0)
        
        # Backward loop from 5 to 3 (2 excluded)
        for led in range(5, 2, -1):
            app.NEO_PIXEL[led] = (150, 0, 0)
            app.NEO_PIXEL.write()
            sleep_ms(100)
            app.NEO_PIXEL[led] = (0, 0, 0)
[CTRL-D]
```
