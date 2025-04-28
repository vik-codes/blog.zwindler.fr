---
title: Hacker un calendrier javascript (datepicker) avec un scraper python
authors:
  - zwindler
type: post
date: 2017-05-09T12:00:26+00:00
url: /2017/05/09/hacker-calendrier-datepicker-scraper-python/
image: /2017/05/maitre-gims-scrape-comme-jamais2.jpg
categories:
  - DIY
  - Script
tags:
  - CentOS
  - check
  - curl
  - datepicker
  - dryscrape
  - F5
  - Firefox
  - hack
  - javascript
  - minimal
  - Nagios
  - phantomJS
  - Python
  - scaper

---
## Mais quel rapport entre un datepicker javascript et un scraper python ?

Si vous ne savez ni ce qu’est un _datepicker_ en Javascript ou un _scraper python_, je vous ai probablement déjà perdu. Pourtant, dans cet article ultra fun (ok, je suis bizarre), je vous montrerai comme j’ai automatisé via un scraper développé en python la recherche de dates libres dans un calendrier Javascript sur une page web :

  * en scriptant la génération de cette page via une ligne de commande
  * en simulant un clic pour passer au mois suivant
  * et enfin en récupérant les bonnes valeurs (pour me les envoyer par email par exemple)

## Commençons donc par un peu de storytelling

Depuis quelques mois, je vais régulièrement sur un site web un peu artisanal sur lequel je fais des réservations. Pour se faire, ce site web propose une page web simple dans lequel a été intégré un composant calendrier :

![](/2017/05/calendrier1.png)

Rien de particulièrement extraordinaire jusque là.

Mais (car bien sûr il y a un mais), ce site à l’inconvénient d’être victime de son succès. Pour vous donner une idée, c’est le genre de site web qui tombe 30 secondes après l’ouverture des réservations à 19h00. Et que dès que l’administrateur système le relance entre 20 et 50 minutes plus tard, les réservations sont complètes en quelques minutes.

## Méthode 1 : F5

La première méthode, probablement plébiscité par la plupart des utilisateurs, est à base de refresh frénétique du site web, jusqu’à ce qu’il devienne inopérant... Une fois que le site est down, on peut continuer à appuyer sur F5 en espérant être le premier quand il reviendra.

![](/2017/05/F5.gif)

Le souci de cette méthode, c’est que je manque cruellement de patience et que je lâche l’affaire assez vite. Et donc tous les mois, les plus hargneux (ou les plus chanceux) me passent toujours devant car j’ai loupé le moment où le site redevient accessible.

## Méthode 2 : cURL

En bon administrateur système que je suis, je ne pouvais pas me résoudre à en rester là. Mon problème principal étant d’être prévenu lorsque le site devenait à nouveau opérationnel, j’ai sorti ma boîte à outils habituelle : cURL !

**cURL** (abréviation de _client URL request library_), est un outil à tout faire quand on veut jouer avec des URL sur un serveur Linux. C’est simple et efficace.

Dans le cas où le site est tombé suite à la connexion massive des internautes avides de réservations, j’ai donc créé un petit script basé sur ce _oneliner_

```
curl http://@IP_ou_FQDN/le_chemin_de_la_page/ -I 2>/dev/null | head -n 1
HTTP/1.1 200 OK
```


Dès que le code retour passe de 503 à 200, c’est que le site web est de nouveau accessible et je peux me remettre à faire F5 en espérant que les réservations ouvrent.

## Méthode 2bis : aller plus loin avec cURL

Bon... La méthode précédente fonctionne... mais ce n’est pas encore ça !

Typiquement, il arrive que l’ouverture des dates soit reportée au lendemain, quand le site est vraiment trop longtemps dans les choux. Du coup le site répond (et mon test me revoie que le site est opérationnel), mais les dates ne sont pas disponibles pour autant...

Un rapide coup d’œil aux sources me donne l’info que je cherche. Il n’y a plus qu’à automatiser ça.

![](/2017/05/calendrier2.png)

Mais évidemment ça n’est pas si simple...

Firefox interprète le Javascript, mais pas cURL, qui ne sait pas [interpréter le Javascript (cf ce post de Stack Overflow)][4]. Le retour de ma commande contient donc le code source HTML avec le Javascript brut, mais pas les données que je recherche...

## Méthode 3 : Un scraper ?

Je dois écrire un _scraper_ qui va aller simuler l’action de l’humain qui va ouvrir la page dans un navigateur. Le post de Stack Overflow cite [PhantomJS][5] qui est probablement une bonne solution.

> PhantomJS is a headless WebKit scriptable with a JavaScript API. It has **fast** and **native** support for various web standards: DOM handling, CSS selector, JSON, Canvas, and SVG.

Cependant je ne connais pas bien JS (ça fait longtemps on va dire) et je préfère capitaliser sur Python. J’ai donc cherché un module Python pour régler mon problème, et j’en ai trouvé 2 : un module python **selenium** et un plus simple appelé **dryscrape**.

J’ai installé dryscrape sur un de mes serveurs (un CentOS 7 minimal, sans environnement graphique). La documentation de dryscrape [est disponible ici][6] et [ici (stable, documentation plus fournie)][7].

```
yum install -y qt5-qtwebkit-devel gcc-c++
sed -i 's/PATH=$PATH:$HOME\/bin/PATH=$PATH:$HOME\/bin:\/usr\/lib64\/qt5\/bin/' .bash_profile
source .bash_profile
pip install dryscrape
```


Et j’ai tout de suite voulu tester un bout de code sans trop chercher à comprendre.

```
cat << EOF > test.py
import dryscrape
session = dryscrape.Session()
session.visit('http://@IP_ou_FQDN/le_chemin_de_la_page/')
response = session.body()
print response
EOF
```


... je me suis donc pris un bon gros Traceback :

```
Traceback (most recent call last):
File "test.py", line 3, in <module>;
session = dryscrape.Session()
[...]raise NoX11Error("Could not connect to X server. "
webkit_server.NoX11Error: Could not connect to X server. Try calling dryscrape.start_xvfb() before creating a session.
```


Ahhhhh oui... ça !

> xvfb_ (necessary only if no other X server is available)

En fait il suffit d’ajouter un test pour exécuter dans xvfb si nécessaire.

### Un premier exemple

Le bout de code suivant ne fait que récupérer le code source de la page et l’afficher à l’écran.

```
cat << EOF > simple_scraper.py
#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import dryscrape
if 'linux' in sys.platform:
# start xvfb in case no X is running. Make sure xvfb
# is installed, otherwise this won't work!
  dryscrape.start_xvfb()
session = dryscrape.Session()
session.visit('http://@IP_ou_FQDN/le_chemin_de_la_page/')
response = session.body()
print response
EOF
```


Mais la grosse différence avec le cURL précédent, c’est que dans le cas présent, **ici le Javascript est interprété**. Cette fois ci dans le code source retourné, je retrouve bien mon calendrier

![](/2017/05/datepicky.png)

A partir de là, il ne me reste donc en théorie qu’à terminer d’écrire un petit bout de script pour extraire les informations qui m’intéressent et à me notifier quand des places sont libres ! On progresse !

## Méthode 3 : Scraper comme jamais

![](/2017/05/maitre-gims-scrape-comme-jamais2.jpg)

>Ce montage pourri d’un clip de Maître Gimms avec des logos dans la main vous est offert par Zwindler

Mais je n’étais pas encore satisfait. Mon but est d’être prévenu lorsque des places sont disponibles. Or, les places s’ouvrent le 1er du mois, **pour le mois suivant**. En revanche, le composant Javascript datepicker a la mauvaise idée de donner les disponibilités **pour le mois en cours**. Mon script **simple_scraper.py** ne récupère donc pas les bonnes dates...

Pour contourner le problème, il faut aller encore un peu plus loin dans l’automatisation des actions. Il faut simuler le clic de l’utilisateur sur la flèche vers la droite, qui passe au mois suivant.

C’est possible avec **dryscrape**, qui propose notamment une fonction pour sélectionner des nodes XPATH et interagir avec. Pour ceux qui ne connaissent pas XPATH, vous pouvez aller sur la doc de dryscrape qui donne quelques exemples, et aussi sur [le tutoriel de la W3School][10].

Comme j’ai examiné le code HTML retourné par le datepicker, je sais quoi chercher :

![](/2017/05/datepicker3.png)

Pour changer de mois en cours, dans un premier temps j’ai essayé d’utiliser le label « » » mais le module dryscrape ne supporte pas les caractères non ASCII ! Une solution qui fonctionne est de cliquer sur le lien qui contient _javascript:void(0)_ contenu dans le div de classe _datepick-next_ :

```
cat << EOF > datepick_scraper.py
#!/usr/bin/python
# -*- coding: iso-8859-15 -*-
import sys
import dryscrape
if 'linux' in sys.platform:
  # start xvfb in case no X is running. Make sure xvfb 
  # is installed, otherwise this won't work!
  dryscrape.start_xvfb()
session = dryscrape.Session()
session.visit('http://@IP_ou_FQDN/le_chemin_de_la_page/')

datepicknext = session.at_xpath('//*[@class="datepick-next"]/a')
datepicknext.click()

response = session.body()
print response
EOF
```


Après vérification, cette version du script renvoie bien le tableau avec les date de Juin (quand on est en Mai) !

## Le mot de la fin

A partir du moment où vous en êtes là, il n’y a plus vraiment de limites à ce que vous êtes capable de faire. Dans mon exemple, j’aurai pu aller encore plus loin, extraire les dates disponibles, et même pourquoi pas aller jusqu’à remplir automatiquement le formulaire pour réserver automatiquement une date prédéfinie (voire même toutes les dates disponibles).

![](/2017/05/datepickx.png)

Ce n’est pas mon but : je vais me contenter de m’envoyer un email dès qu’une date se libère. Mais c’est possible !

Si vous voulez explorer les possibilité de dryscrape, la documentation officielle donne quelques exemples, et notamment celui de l’envoi d’un email depuis Gmail, entièrement automatisé comme si c’était un humain (!)

De quoi donner des idées, pour _**scraper comme jamais**_ !


 [4]: http://stackoverflow.com/questions/20554113/how-to-get-webcontent-that-is-loaded-by-javascript-using-curl
 [5]: http://phantomjs.org/
 [6]: http://dryscrape.readthedocs.io/en/latest/installation.html
 [7]: https://dryscrape.readthedocs.io/en/stable/usage.html
 [10]: https://www.w3schools.com/xml/xpath_intro.asp
