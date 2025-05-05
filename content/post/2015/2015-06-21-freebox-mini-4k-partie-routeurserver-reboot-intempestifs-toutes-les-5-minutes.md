---
title: Freebox Mini 4K – partie routeur/server, reboot intempestifs toutes les 5 minutes
authors:
  - zwindler
type: post
date: 2015-06-21T08:47:49+00:00
url: /2015/06/21/freebox-mini-4k-partie-routeurserver-reboot-intempestifs-toutes-les-5-minutes/
image: /2015/06/fetch.php_.jpg
categories:
  - materiel
tags:
  - 3.1.2
  - 3.1.3
  - bug
  - bugtracker
  - Cell
  - Femto
  - FreeBox
  - Mini 4K
  - server
  - v6

---
## Quand le FemtoCell fait des siennes

**[MAJ3] Le problème du FemtoCell est réellement résolu sur la Mini 4k [/MAJ3]**

**[MAJ2 du 22/07]** Contrairement à ce qui a été annoncé, je confirme que ce n’est toujours pas réglé, malgré la 3.1.3. C’est au moins mon cas **[/MAJ2]**

**[MAJ du 24/06]** A en croire les retours sur le bugtracker, le souci est corrigé. Vous pouvez rebrancher/rallumer le FemTo Cell si vous en avez l’utilité. Et puis si vous n’en avez pas l’utilité, ne l’activez pas : d’expérience ça chauffe beaucoup. Et même si je ne suis pas un fervent croyant des ondes qui seraient mauvaises, je ne pense pas qu’il soit nécessaire de bombarder plus que nécessaire... **[/MAJ]**

A priori le tout dernier firmware (3.1.2) de la partie server pour la FreeBox Mini 4K (et la V6 aussi) provoque un reboot très régulièrement lorsque le FemTo Cell est activé. Personnellement je venais juste de l’installer alors je ne sais pas comment c’était avant mais à priori ce n’était pas le cas ;-)

(Image avec un lien mort)

* [dev.freebox.fr/bugs/task/17642](http://dev.freebox.fr/bugs/task/17642#)

La solution la plus simple consiste à éteindre le FemTo Cell. Ceci ne peut se faire qu’en façade à priori (je n’ai pas trouvé dans l’interface web) : **Femtocell** > **Arrêter** > **OK**.
