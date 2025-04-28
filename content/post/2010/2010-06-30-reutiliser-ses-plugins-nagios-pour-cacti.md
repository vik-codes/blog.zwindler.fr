---
title: Recyclage de plugins Nagios pour nourrir Cacti
authors:
  - zwindler
type: post
date: 2010-06-30T17:39:13+00:00
url: /2010/06/30/reutiliser-ses-plugins-nagios-pour-cacti/
image: /2010/06/Supervision-Metrologie.png
categories:
  - Monitoring
  - Virtualisation
tags:
  - Cacti
  - ESX(i)
  - EyesOfNetwork
  - Nagios
  - Perl
  - plugins
  - Regexp

---
Aujourd’hui j’aimerais revenir sur ce que j’aifaits, et ça va parler de Nagios et de Cacti. Je plante le décor...

Je suis censé finir la mise en place du monitoring des réseaux que j’administre. L’an dernier, mon prédécesseur avait fait une grosse partie de l’aspect c**ant dans le monitoring, créer les templates des équipements et des services qui vont bien, puis rentrer une à une toutes les machines. Pour ce faire, il a utilisé une distribution appelée EyesOfNetwork. En gros, il s’agit d’un frontend pour Nagios (principalement) qui se compose d’une distrib CentOS modifiée, d’un Lamp, d’un Mysql, d’un Nagios et d’un Cacti, le tout enrobé dans une interface graphique (plus ou moins pratique). Pour de plus amples informations je vous conseille d’aller jeter un œil [ici][1].

J’ai pas mal bossé sur les divers plugins qui étaient utilisés par la communauté pour monitorer VMWare, notamment les VM et les hosts. En voici deux que je conseille tout particulièrement, même si j’ai pas mal galéré pour installer la multitude de dépendances offline (et oui, je travaille coupé du monde) et que d’autres plugins sont probablement très bien aussi :

  * [check_esx3](http://www.op5.com/support/documentation/how-to/400-monitoring-vmware-esx-3x-esxi-vsphere-4-and-vcenter-server) pour avoir accès à tout ce qui est CPU, RAM, Disques, ...
  * [check_esxi_wbem.py (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20131212160532/https://communities.vmware.com/docs/DOC-7170) pour les checks hardware

J’en parlerai probablement un peu plus une autre fois...

Bon, mais une fois que j’ai intégré avec succès ces plugins à mon Nagios préféré, je me suis penché vers le Cacti d’EyesOfNetwork pour générer mes beaux graphiques. Une fois que j’ai réussi à comprendre l’interface graphique de Cacti (ça m’a pris un peu de temps, mais une fois qu’on est tombé [sur cette page de la documentation officielle (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20210117095431/https://docs.cacti.net/manual:087), et plus particulièrement sur la partie "data input methods", rien ne peut plus vous arrêter, plus d’excuses), j’ai compris que j’allais devoir trouver un moyen simple d’adapter mes bons vieux plugins Nagios. Mais comment faire?

Pour ceux qui n’auraient pas totalement percuté où je veux en venir, je vais tout de suite mettre le doigt là où ça fait mal. Prenons l’exemple d’une bête vérification que va chercher la charge CPU de votre ESXi préféré :

* Une sortie Nagios est de cette forme CHECK\_ESX3 OK cpu\_usage=33.33 % | cpu_usage=33.33%;80;90
* Une sortie compatible avec Cacti c’est... 33.33

Mais WTF me direz vous ! Bon j’exagère un peu. On peut spécifier plusieurs sorties comme ceci « cpu\_usage:33.33 mem\_usage:2311 ». Toujours est il que c’est très moche et que l’on va devoir sortir notre boite à outils.

Ma première idée a été `sed`. Pourquoi sed? Pourquoi pas. Sur le moment ça m’a paru une bonne idée de juste donner à manger à Cacti le path de mon script Nagios. Bon même si je ne suis pas forcément très à l’aise avec les regexp, un petit bruteforce des possibilités envisageables m’a permis de me remettre dans le bain et de produire un truc correct qui marche notamment pour le script check_esx3 dans le cadre d’un appel à un serveur ESX(i) pour obtenir le « cpu usage »...

```
/usr/bin/perl <path_cacti>/scripts/ln-s_to_nagios/plugins/check_esx3 -H xxx.xxx.xxx.xxx -u user -p pass -l cpu -s usage | sed 's/.*=([0-9]*.[0-9]*).*/1/'
```


Il est très possible que cette solution ne soit pas la meilleure que l’on puisse trouver, mais j’étais content de moi, car dans mon shell, ça marchait très bien. Les experts qui me lisent sont en train de se dire « qu’il est naïf ! ». Effectivement... ça ne marche pas du tout. Je ne sais pas si c’est le lien symbolique ou le pipe qui bloque, mais cacti ne trouve pas ce qu’il faut, et enregistre misérablement un **NaN** toutes les 5 minutes.

Du coup, je me suis tourné vers ma 2ème passion dans la vie, et j’ai écrit un mini script perl dont le but ultime était d’appeler le script check_esx3, puis de récupérer la sortie et d’y appliquer la même regexp. Alors si vous voulez faire comme moi et que vous ne vous êtes pas trop demandé comme Cacti fonctionne, je vais vous épargner un petit moment « débogage en aveugle ».

En fait, Cacti utilise le cron pour ordonnancer toutes les 5 minutes ses checks, et c’est bien normal si on y réfléchit un peu. Du coup, le cron exécute avec l’utilisateur cacti, mais dans un tout autre contexte que le contexte courant. Au début naïvement j’avais écrit un script du genre :

```
#!/usr/bin/perl
$res = `./check_esx3 blablabla`;
```


« Ça n’est pas du tout la bonne réponse ! » Il faut absolument mettre des chemins absolus, et ne pas utiliser de liens symboliques. Une fois que vous aurez respecté ces indications, vous devriez pouvoir adapter vos scripts préférés pour qu’ils soient compatibles Cacti.

Juste un p’ti lien vers un script qui marche pour l’exemple cité dans l’article [ici](misc/esx_host_cpu.pl).

Un dernier questionnement : est ce que le mieux ça ne serait pas d’utiliser le module PNP pour Nagios, plutôt que de multiplier inutilement vos checks (et d’adapter vos scripts)? A suivre.

 [1]: http://www.eyesofnetwork.com/?lang=fr
