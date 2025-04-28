---
title: Écrans noirs sur la Freebox mini 4K (boitier TV)
authors:
  - zwindler
type: post
date: 2015-08-28T11:48:51+00:00
url: /2015/08/28/ecran-noirfige-sur-la-freebox-mini-4k-boitier-tv/
image: /2015/06/fetch.php_.jpg
categories:
  - Matériel
tags:
  - bugtracker
  - débrancher
  - écran figé
  - écran noir
  - Free
  - FreeBox
  - Mini 4K
  - reboot
  - rebrancher
  - tracker Free

---
[Après les reboot intempestifs de la partie « Server »][1], je m’attaque maintenant à l’autre bug casse pied depuis que j’ai ma nouvelle mini 4K. Cette fois ci, il s’agit de la box TV qui se fige avec écran noir régulièrement. Ça peut être en lecture VOD, lors de la visualisation d’une chaine, ou lorsque la Mini 4K sort de la veille. Certains ont installés des applications complémentaires et d’autres ont le problème depuis le début (mon cas).

A moins qu’il ne s’agissant de problèmes avec des causes différentes mais aux symptômes identiques, il ne semble donc pas y avoir de facteur commun simple à déceler.

Ça peut aller de quelques minutes de visualisation pour certains (5-40 minutes) à une fois par jour environ (mon cas).

La télécommande fonctionne (voyant rouge normal), le téléviseur aussi (les autres sources fonctionne, le câble HDMI n’est pas en cause), et la Freebox Mini 4K est toujours alimentée (LED Ethernet qui clignote, ventilateur qui fonctionne normalement). Elle ne répond juste plus à la télécommande et n’affiche plus rien.

Le seul contournement semble être d’aller débrancher/rebrancher le boitier TV et d’attendre le reboot.

Certains conseillent de brancher la box en Ethernet direct plutôt que via CPL ou Wifi (c’est déjà le cas pour moi), de changer les câbles Ethernet (testé sans succès), de réinitialiser complètement le boitier TV, ...Certains utilisateurs (moi compris) continuent pourtant de subir les coupures après toutes ces manipulations.

Et pas de nouvelles côté tracker ou au 3244. A priori les techniciens Free ne savent pas de quoi il s’agit, voire n’ont jamais entendu parlé de ce problème qui serait « un cas isolé » selon certains témoignages (ah bon?). Quelques exemples, juste sur le tracker pourtant :

* [18588](http://dev.freebox.fr/bugs/task/18588)
* [17511](http://dev.freebox.fr/bugs/task/17511)
* [17667](http://dev.freebox.fr/bugs/task/17667)
* [17718](http://dev.freebox.fr/bugs/task/17718)

Et il doit y en avoir d’autre.

Je mettrais à jour le sujet si j’arrive à avoir plus de détails de la part de Free.

 [1]: /2015/06/21/freebox-mini-4k-partie-routeurserver-reboot-intempestifs-toutes-les-5-minutes/
