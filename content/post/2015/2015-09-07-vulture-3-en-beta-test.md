---
title: Vulture 3 en bêta test
authors:
  - zwindler
type: post
date: 2015-09-07T20:59:58+00:00
url: /2015/09/07/vulture-3-en-beta-test/
image: /2014/12/logo2-white1.png
categories:
  - Autohébergement
  - DIY
tags:
  - Advens
  - bêta test
  - vulture
  - Vulture 2.0.8
  - Vulture 3
  - Vulture WebSSO

---
## Rappel

Pour rappel pour ceux qui n’auraient pas suivis, Vulture WebSSO est un WAF (non pas pour [Wife Acceptance Factor][1] mais Web Application Firewall) que je suis avec intérêt depuis la version 1.98 car il m’a permis pendant un certain temps de gérer dans une même console web l’ensemble de mes applications auto-hébergées.

Il permet également de gérer l’authentification, le SSO, un portail, la réécriture d’URL et de contenu ... le tout à l’aide d’Apache, de modules et de  code Perl maison.

## Vulture 2.0.X

Ce n’est pas très frais comme news, mais la version 2.0.8 de Vulture WebSSO marque la fin de la « branche » 2.Y.X.

On sait depuis le 30 septembre dernier que la V3 est en cours de développement.

## Les prémisses de Vulture 3.0

Depuis, les choix techniques ont été présentés sur le [blog du projet][2], avec depuis des mentions de support de [SPDY][3] et de [HTTP/2][4]. Entre ça et le portage de **mod_spdy** sous FreeBSD et Apache 2.4, autant dire qu’Advens laisse du temps libre aux développeurs de Vulture ;-).

Et depuis aout, vous avez la possibilité de vous manifester pour bêta-tester Vulture 3 en envoyant un mail à [beta-test@vultureproject.org](mailto:beta-test@vultureproject.org)

Avis aux amateurs donc, si vous voulez gouter au futur du projet Vulture et donner un coup de main, c’est maintenant ou jamais !

## Bonus track

Advens met gentiment sur son blog une explication de HTTP/2 (lien mort, Internet Archive ne l'a pas). Merci à eux

 [1]: https://fr.wikipedia.org/wiki/Facteur_d'acceptation_f%C3%A9minine
 [2]: https://www.vultureproject.org/les-technos-derriere-vulture-3/
 [3]: https://developers.google.com/speed/spdy/
 [4]: https://http2.github.io/
