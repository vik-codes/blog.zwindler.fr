---
title: Ta visio Open Source comme un pro avec Jitsi
authors:
  - zwindler
type: post
date: 2020-03-17T07:55:00+00:00
excerpt: "Tutoriel d'installation de la solution de visio conférence Jitsi Meet, qui permet de créer des conférences à la volée sans création d'utilisateur préalable"
url: /2020/03/17/ta-visio-open-source-comme-un-pro-avec-jitsi/
image: /2020/03/jitsi_front.jpg
categories:
  - autohebergement
tags:
  - Jitsi
  - Jitsi Meet
  - Jitsi Videobridge
  - Open Source
  - partage
  - video
  - visio

---

## Jitsi Meet au secours de la France qui télétravaille
  
  
COVID-19 oblige, j’ai un peu modifié l’ordonnancement de mes articles pour reparler d’un sujet que j’avais traité il y a 3-4 ans : la visioconf avec Jitsi Meet. Pourquoi ce sujet ? D’abord parce que pas plus tard qu’il y a 5 jours, NextInpact (mon journal préféré) a relayé les [mésaventures de Framasoft suite à l’épidémie](https://www.nextinpact.com/brief/le-teletravail-de-plus-en-plus-populaire--framasoft-en-fait-les-frais-11557.htm).

En effet, [Framasoft (que vous connaissez forcément)](https://framasoft.org/fr/) propose de longue date des outils/services en ligne gratuit. Le souci, c’est que le but est ici d’éduquer les gens et leur montrer qu’on peut autohéberger de nombreux services habituellement payants chez de gros éditeurs (ou gratuits en échange de vos données personnelles).

Mais, pris par la panique de devoir passer tout un tas de gens à l’arrache sur un mode massivement télétravail, beaucoup de gens se sont tournées vers des solutions toutes prêtes, surchargeant au moins de manière temporaire les serveurs de Framasoft.

Mais vous l’avez bien compris, le but, c’est d’apprendre à faire soit-même, comme le fait Framasoft, avec Jitsi Meet :).

## Notes additionnelles
  
  
Si jamais vous cherchez des solutions toutes faites, sachez que de nombreuses entreprises de la tech mettent à disposition ce genre de solutions de manière temporairement gratuite pour soulager les équipes IT et "faire leur part" pour lutter contre la propagation du virus. Les derniers en date sont [OVH](https://www.ovh.com/conferences/) qui propose un service de téléconférence gratuit jusqu’à 24h et 50 participants, mais j’ai aussi entendu parlé de discord pour de la visio à 50 et d’autres services qui font sauter leurs limites habituelles dans le contexte Coronavirus.

Parallèlement à cet article sur Jitsi, sachez que NextCloud propose une alternative libre (NextCloud Talk) dans la dernière version. Je ne l’ai pas encore testée, mais la communauté NextCloud FR est très active je suis sûr qu’ils ont du faire des tutos (Genma ?).

## Et Jitsi dans tout ça ?
  
  
C’est quoi exactement Jitsi ?
> Multi-platform open-source video conferencing
> * Share your desktop, presentations, and more
> * Invite users to a conference via a simple, custom URL
> * Edit documents together using Etherpad
> * Pick fun meeting URLs for every meeting
> * Trade messages and emojis while you video conference, with > integrated chat.
  
C’est donc une plateforme relativement complète de visio, a priori plutôt scalable (possibilité de faire des confs à plus de 100), qui permet de partager son écran et de chatter.

Le gros avantage c’est que c’est dans un navigateur et que c’est très simple d’utilisation. On ouvre la page web, on rentre un nom de salle dans une barre de texte, et voilà.

![](/2020/03/jitsi2.png)

## Installation
  
  
Avant de commencer, je me suis posé la question du sizing. Nécessairement ça va dépendre fortement de la charge que vous attendez, mais sachez qu’au minimum il vous faudra une machine avec 1 vCPU et 1Go de RAM. Le double serait le mieux, car Jitsi se compose de plusieurs applications Java (c’est donc un peu gourmand même sans charge).

![](/2020/03/jitsi-network.png)

> https://jitsi.github.io/handbook/docs/devops-guide/

En soit, l’installation de Jitsi est assez triviale, en particulier sur une Debian ou une Ubuntu récente.


![](/2020/03/jitsi.png)

> Instruction d’installation disponibles sur https://jitsi.org/downloads/ubuntu-debian-installations-instructions/

Ici, voilà les commandes que j’ai tapé pour installer Jitsi sur une Ubuntu 18.04 vierge :


```
sudo apt upgrade 
sudo apt install gnupg2

wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -

sudo sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"

sudo apt update
sudo apt install jitsi-meet
```


Lors de l’installation, le terminal nous promptera pour le nom d’hôte public sur lequel le service sera disponible et si on souhaite générer un certificat ou en fournir un soit même.



Cependant, comme souvent avec les sites qui disent "regardez c’est trop simple d’installer notre soft, c’est juste `apt install monsoftgenial`, en vrai il manque des bouts ;)


## Firewall
  
  
A moins d’avoir une machine chez un cloud provider pas trop regardant et sur laquelle vous installez le soft sans se poser de question, vous allez probablement avoir mis (ou vouloir mettre) du filtrage de port devant vos serveurs.
Comme vous vous en doutez, il va falloir ouvrir des ports pour que ça fonctionne correctement. On trouve l’info des ports utilisés par Jitsi dans [la documentation d’installation](https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md) (un peu plus complète) disponible sur Github.
Grosso modo, si tous les composants de jitsi sont installés sur la même machine, vous avez les ports suivants à ouvrir sur Internet (ou en LAN si vous ne souhaitez utiliser Jitsi que sur votre réseau Interne) :
  
* 443/TCP pour le serveur web de la page d’accueil
* 4443/TCP (jitsi-meet videostream)
* 10000 => 20000 en TCP et en UDP
      
  
La dernière plage de 10000 port est très probablement bien trop grande dans une grande majorité des cas et peut normalement être configurée dans Jitsi (mais je n’ai pas les commandes exactes).

## Jitsi dans un réseau NATé
  
  
Je n’allais pas commander une nouvelle machine juste pour mes tests Jitsi. J’ai donc installé une VM sur mes hyperviseurs persos, dans lequel le réseau virtuel est NATé.

Et manque de bol, dans ce cas là, il faut ajouter deux lignes dans un fichier de configuration (deux lignes que j’ai mis du temps à trouver mais [qui sont là aussi, dans la doc](https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md)... Passons).

~~Dans la machine sur laquelle vous avez installé Jitsi, ouvrez le fichier suivant et ajoutez y les deux lignes qui suivent (en remplaçant bien entendu les parties entre crochets par les vraies IPs).~~

[Edit]La configuration a maintenant changé, vous n’avez plus besoin de renseigner les IPs publiques/privées. Il suffit de supprimer les lignes avec les IPs et de mettre les deux autres à la place (ce qui a l’immense avantage de permettre les IPs dynamiques).


```
vi /etc/jitsi/videobridge/sip-communicator.properties
#org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS=[IP_MACHINE_LAN]
#org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=[IP_PUBLIQUE_SERVICE]
org.ice4j.ice.harvest.DISABLE_AWS_HARVESTER=true
org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443
```



## Premier test
  
  
Maintenant qu’on a configuré le firewall et la configuration spécifique pour le NAT, on essaye de faire sa première conf et ... voilà ce que ça donne :



![](/2020/03/20200316_153634.jpg) 


Comme vous pouvez le voir sur ce superbe cliché, j’ai connecté 3 devices, dont un smartphone, depuis mon wifi vers mon serveur chez Hetzner.
J’ai testé avec Chrome et Firefox, les deux fonctionnent mais il arrive que Jitsi conseille plutôt d’utiliser Chrome. Historiquement, c’était bien mieux supporté, en tout cas.
Pour le smartphone, il existe une application sur l’Android Store et sur F-Droid qui m’a paru assez complète.



## Partage d’écran
  
  
C’était une des déceptions que j’avais eu il y a 3 ans lorsque j’avais essayé l’outil. On teste et on se dit : "Cool, la vidéo fonctionne... Mais qu’en est-il ?"
Et là c’est (c’était) le drame. A l’époque, j’avais surtout fais le tuto pour cette partie, car il était nécessaire de compiler soit même une extension pour chaque navigateur (et je n’avais réussi à faire fonctionner que celle de Chrome ([cf mon précédent article](/2016/11/22/jitsi-meet-installation-videoconference-web-open-source/)).
Heureusement, aujourd’hui, ça fonctionne _out of the box_ !
Avec quelques limitations tout de même. Si sur Chrome, j’ai pu partager n’importe quelle de mes fenêtres ouvertes, je n’ai réussi à partager que mon navigateur avec Firefox. Je ne sais pas si c’est un souci de mon côté ou une limitation de l’outil.



## Quelques features sympa
  
  
Dans les fonctionnalités "nice to have", il existe comme dans un autre outil propriétaire qui en fait massivement la pub à la télé, la possibilité de flouter le fond pour qu’on ne voit pas le bazar que c’est chez vous par exemple. Ça marche assez bien mais ça consomme énormément de CPU (surtout si vous avez un portable avec un CPU un peu faiblard) et ça rajoute quand même un peu de latence.

On peut espérer que cette fonctionnalité encore en bêta finira par s’améliorer.



![](/2020/03/20200316_154230.jpg) 

> Ma tête n’est pas floutée, c’est l’essentiel... 


Le chat fonctionne bien mais la gestion des emoji se limite à une 15aine de signe. Quand on est habitué à Slack et aux émoji personnalisés, c’est vraiment pauvre...

Il existe bien entendu une fonction pour demander la parole (et ainsi éviter que ça soit le bazar quand on est nombreux), ainsi que des fonctions pour se mute ou couper sa caméra.

On peut également choisir sa qualité vidéo et voir la bande passante sur le poste local.



## Mais quelques manques
  
  
Je n’ai pas eu le temps de jouer extensivement avec l’outil, mais il me semble qu’une partie de mes remarques d’il y a 3 ans sont cependant toujours d’actualité.

L’outil se veut simple : pas d’inscription nécessaire et réunion simple à créer. Le corollaire est que l’outil est parfois simpliste. Pas d’interface d’administration pour vérifier (voire limiter) les consommations de bande passante au niveau global sur le serveur, qui est connecté et quand, etc.

De même, n’importe qui, de base peut créer une conférence. Si on est un peu parano on peut s’imaginer plein de choses... (A noter, on peut protéger l’accès à une conférence par un mot de passe une fois qu’on l’a créée).

Bref, quelques points encore à améliorer pour avoir une solution 100% équivalente aux acteurs payants. Ces mêmes points qu’il y a 3 ans et qui avaient des solutions de contournement mais non triviales (notamment Openfire). Donc à voir si c’est toujours le cas aujourd’hui.

Mais en attendant que je me penche là dessus, enjoy :)

## Sources et bonus

* [Test de perf "aux limites"](https://jitsi.org/jitsi-videobridge-performance-evaluation/)
* [Un fil de discussion a propos du Firewalling](https://community.jitsi.org/t/jitsi-users-corporate-firewall-settings-to-use-jitsi-client-and-webapp-meet-jit-si/10220/2)
