---
title: 'XenServer, Debian, disque iSCSI : confiture et déconfiture'
authors:
  - zwindler
type: post
date: 2011-01-17T20:37:53+00:00
url: /2011/01/17/xenserver-debian-disque-iscsi-confiture-et-deconfiture/
image: /2011/02/citirx-xenserver11.jpg
categories:
  - Virtualisation

---
Depuis mon installation de XenServer, j’ai testé et retesté par mal de choses, et je n’ai pas pris le temps de mettre en forme ce que j’ai appris sur ce blog. Ce n’est pas bien :-p

Par rapport à ce que j’ai appris depuis l’article précédent, je vais rajouter deux choses :

- Une grosse déconvenue, l’affichage des rares Linux supportés par XenServer

- La mise en place d’une VM dont le disque est exporté via iSCSI

Tout a commencé quand je me suis mis en tête de faire fonctionner une VM dans un environnement qui se rapproche plus de la virtualisation en production, plutôt que dans un bête environnement de test. En effet, jusqu’à présent je n’avais que testé des VMs Windows et des CentOS via console, le tout en **stockage local**.

Je me suis donc lancé dans la création d’une simple VM linux dédiée à de la bureautique, mais avec **le disque virtuel sur un filer** plutôt que sur les disques locaux du serveur. Rien de bien gourmand donc, mais deux contraintes tout de même, des temps de réponses acceptables dans le lancement des logiciels, ainsi qu’un affichage relativement réactif (proche des temps de réponse d’une machine de bureautique standard).

J’ai donc commencé par mettre en place sur mon NAS perso une target iSCSI, que j’ai configuré sur mon XenServer. Bonne nouvelle, c’est TRES simple à mettre en place. XenCenter propose une interface qui permet de rechercher les targets disponibles sur votre stockage en quelques clics.

![](/2011/01/xenserver-iscsi.png)

Une fois créé, le stockage s’est comporté exactement que les stockages locaux que j’avais pu utilisé lors de mes premières VMs. J’étais très content. Cependant, les ennuis sont vite arrivés...

Comme nous n’avons pas beaucoup le choix pour ce qui est du Linux, j’ai lancé l’installation d’un Debian Lenny via un liveCD pour le lancement, puis via le FTP pour avoir tous les paquets à jour. C’est vraiment très pratique à installer quand on est pas allergiques aux interfaces graphiques bleues :-P.

Jusqu’à présent, j’avais remarqué que l’affichage des VMs était gérés de deux façons :

- Un protocole de déport d’affichage naif « Made In Citrix » très lent, généralement utilisé lors des installations et de la mise en place de la VM, puis une fois installé pour le démarrage de la VM par exemple.

- Un mode d’affichage basé sur du bureau à distance.

Sous Windows donc, cela fonctionne à merveille sans rien avoir à faire d’autre qu’installer les « guest additions » (XenServer Tools).Dès que l’OS est chargé, XenCenter propose de « Switch to Remote Desktop », ce qui offre une fluidité très correcte dans l’utilisation de la VM.

Mais sous linux, ça se gâte drôlement.Le protocole naif ne gère qu’une partie « console », et encore, il arrive que cela soit lent à répondre sur un réseau un peu saturé.

J’étais étonné de ne pas être capable de lancer un mode graphique, alors que j’avais bien sélectionné « Gnome Desktop » lors de l’installation de mon Debian, je n’arrivais pas à lancer d’interface graphique utilisateur. Un peu dommage pour un poste de bureautique me direz vous!

Après de brèves investigations sur la toile, je suis tombé sur [ce blog](http://tssisaison4.forumsactifs.com/t68-xenserver-interface-graphique-via-vnc), qui m’a expliqué que ce que je cherchais à faire n’était simplement pas possible avec XenServer. En gros, il nous donne pas à pas la procédure à suivre pour obtenir un bureau à distance VNC intégré à XenCenter.

Oui, il faut définir VNC comme façon d’afficher l’écran par défaut pour pouvoir profiter d’une interface graphique Linux. Un peu dommage, je trouve, j’étais un peu frustré.

Une fois mon déport VNC configuré comme affichage par défaut, j’ai tout de même pu m’extasier devant mon Débian

![](/2011/01/xenserver-text.png)

![](/2011/01/xenserver-vnc.png)

Après quelques minutes d’utilisation, j’ai pu remarquer deux choses.

Premièrement, malgré le fait que mon réseau soit catastrophique (c’est à dire un joyeux mélange de XenCenter en wifi saturé, switches 100 Mbits et de CPL bruités) j’arrive à avoir un usage fluide. Les menus sont très réactifs, la bureautique réagis au quart de tour, et j’ai même pu lancer Eclipse (et l’utiliser) dans des temps qui m’ont paru du même ordre de grandeur qu’un Eclipse sur une machine physique (c’est tellement long, de toute façon...).

L’analyse des graphes de performances à différents endroits (VM, Serveur, Filer, Poste client) ont confirmés mon ressenti. Le réseau est utilisé mais pas à outrance, les délais de transfert de données du filer vers la VM sont relativement courts, ce qui explique que les délais de lancement des différents programmes ne soient pas catastrophiques.

![](/2011/01/xenserver-perf-filer.png)

Deuxièmement, VNC, j’ai vraiment l’impression que c’est « has been ». Peut être que ce n’est tout simplement pas fait pour? Sans parler dans l’éternel débat des performances (guéguerre sans fin RDP/VNC), à chaque fois que j’ai été confronté à VNC, je me suis heurté à des performances graphiques bien moindre, un affichage mal retransmis et un environnement moins stable.

XenServer n’a pas échappé à ce constat. J’ai constamment des messages d’erreurs de gnome n’indiquant des problèmes, de gros soucis d’affichage (notamment certains menus du bureau), et j’en suis même arrivé à un point où la session se killait à chaque nouveau lancement de l’interface d’Eclise, sans explication aucune.

Je ne sais pas si c’est le client VNC XenCenter, le serveur VNC de la VM, ou moi qui ne suis juste pas doué (probablement la dernière hypothèse, surtout pour le côté VNC que je connais très mal), mais j’ai vraiment des problèmes que je considère comme bloquants pour l’utilisation de Linux en mode graphique sous XenServer.

J’espère que des versions futures et/ou une meilleure documentation me permettront d’avancer de ce côté là... parce que j’ai été bluffé par la fluidité de la solution, même sur une infrastructure Serveur/Filer/Client aussi peu adaptée que la mienne.
