---
title: Installation de Jitsi Meet (videoconférence web open source)
authors:
  - zwindler
type: post
date: 2016-11-22T13:00:51+00:00
url: /2016/11/22/jitsi-meet-installation-videoconference-web-open-source/
image: /2016/11/jitsi_meet.png
categories:
  - autohebergement
tags:
  - CentOS 7
  - Chrome
  - Chromium
  - Degooglisons Internet
  - Firefox
  - Framasoft
  - Framatalk
  - Jidesha
  - Jitsi
  - Jitsi Meet
  - Jitsi Videobridge
  - Openfire
  - Ubuntu

---
**Note : cet article n’est plus à jour, [j’en ai écris un plus récent ici (Mars 2020)](/2020/03/17/ta-visio-open-source-comme-un-pro-avec-jitsi/)**.

* * *

## Pourquoi Jitsi Meet ?

Dans le contexte IT, le besoin de visio/vidéoconférence est un des basiques. Outre les couteux systèmes de visioconférence clé en main, il n’est pas rare dans une société comme celle pour laquelle je travaille d’entendre les employés dire au détour d’un couloir : « attend je ne peux pas réserver la visio, on a qu’à se faire un webex ». Alors quand j’ai découvert que Framasoft avait ajouté un service de vidéoconférence (Framatalk) à son arsenal open source pour « Dégoogliser l’Internet », j’ai vraiment voulu savoir de quoi il s’agissait ! C’est comme ça que j’ai découvert [Jitsi Meet][2], une plateforme pour créer des visioconférences ad-hoc depuis un site web.

Pour ceux qui ne connaissent pas [Framasoft][3] et l’initiative [Degooglisons Internet][4], il s’agit respectivement d’une association de promotion du logiciel libre et d’une campagne prouvant que se passer des grands noms de l’Internet est possible. Pour chaque types de services qu’on peut trouver grands sites de l’Internet 2.0 (GAFAM et autres), une solution alternative et libre ou open source est mise à disposition.

**A noter**, il s’agit bien des services mis à disposition pour tester les alternatives open source. Les services mis à disposition des internautes n’ont pas pour but d’être utilisés en production.

> Il s’agit bien de montrer les outils, et non de les fournir _ad vitam æternama_ aux masses. « _Au bout d’un moment, on réussit à démontrer que les outils sont viables. Par exemple sur Framadrive, on a 5 000 comptes. On pourrait ajouter du disque, des ressources, mais notre but n’est que de faire de la démonstration_ » détaille Didry, qui affirme tout de même que les services ne seront tout de même pas fermés sur un coup de tête.
> 
> [Interview de Luc Didry sur NextInpact][5]

## Installation sur Ubuntu

Une fois n’est pas coutume, j’ai installé et testé Jitsi Meet et Jitsi Videobridge sur  un Ubuntu 16.04.1 fraichement installée. En réalité, sur Debian ou Ubuntu, [l’installation en elle même du produit est grandement simplifié][6] car une grosse partie de la configuration du serveur Web est faite via un « .deb » sur un repository APT dédié.

```

sudo apt-get update
sudo apt-get upgrade #Système up-to-date

sudo vi /etc/apt/sources.list.d/jitsi-stable.list #ajout du repository APT
     deb https://download.jitsi.org stable/
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -

sudo apt-get update
sudo apt-get -y install jitsi-meet #installation de jitsi meet
```

La procédure pour Linux est [disponible sur le Github de Jitsi Meet](https://jitsi.github.io/handbook/docs/category/deployment).


A partir de là, vous disposez d’un serveur Web accessible à l’URL du type `https://@IP_jitsi` et vous arriverez sur un portail qui vous permettra de créer une nouvelle vidéoconférence.

![](/2016/11/jitsimeet1.png)

Et voilà ce que vous devriez voir en vous connectant sur un visio créée de cette manière :

![](/2016/11/jitsimeet2.png)

Cependant, par défaut, seul la partie vidéo+audio fonctionnera par défaut. Si vous souhaitez également faire du partage d’écran (possible avec Jitsi Meet), il sera nécessaire d’activer une extension sur votre navigateur Chrome ou Firefox.

![](/2016/11/jitsimeet3.png)

![](/2016/11/jitsimeet4.png)

## Compilation du plugin pour Chrome et pour Firefox


  Et c’est là que ça se complique !

  A priori pour des raisons de sécurité, les plugins ne peuvent pas être distribués directement sur le magasin de plugins Chrome par les développeurs de Jitsi. Il est nécessaire pour Chrome d’insérer le FQDN de votre plateforme dans le plugin au moment de sa compilation.

Cela rend toute distribution impossible. Seuls les plugins pour la plateforme de démo [meet.jit.si](https://meet.jit.si/) sont disponibles sur Internet et ils ne fonctionneront pas sur votre installation locale.

Cependant, en contournement, on peut compiler nous même les extensions pour Firefox et Chrome à partir du code disponible sur le [Github officiel jidesha](https://github.com/jitsi/jidesha).


### Firefox


  Récupérer les sources du projet depuis Github (contenant à la fois le plugin Chrome et le plugin Firefox).


```
sudo apt-get install git
git clone https://github.com/jitsi/jidesha
cd jidesha/firefox
```

  Editez le fichier make.sh. Les variables à adapter à votre contexte sont DOMAINS qui doit correspondre à votre domaine et EXT_ID qui doit correspondre au hostname de votre machine et à son domaine séparé par un @. Dans le cas d’une machine jitsi.zwindler.fr, ça donnerait le fichier suivant :


```

vi make.sh
  DOMAINS="zwindler.fr"
  EXT_ID="jitsi@blog.zwindler.fr"

./make.sh
  adding: bootstrap.js (deflated 66%)
  adding: chrome.manifest (deflated 13%)
  adding: content/ (stored 0%)
  adding: content/zwindler.fr.png (deflated 26%)
  adding: install.rdf (deflated 50%)
```

  Vous pouvez ensuite récupérer jidesha.xpi généré. Cependant, il reste encore à le signer, et je suis pour l’instant coincé à cette étape...

### Chrome


  Pour Chrome ou Chromium, la procédure est similaire, à ceci près que j’ai réussi à aller jusqu’au bout ! A partir des mêmes sources, exécuter les commandes suivantes :

```

cd ../chrome
vi manifest.json
  "externally_connectable": {
    "matches": [
      "*://jitsi.zwindler.fr/*"
    ]
  }
```

Contrairement à Firefox où le XPI était compilé directement depuis le code, l’extension Chrome est à compiler directement ... depuis Chrome ! Si vous êtes curieux, le tutoriel pour le faire est [disponible à l’adresse suivante](https://developer.chrome.com/extensions/packaging).

  Dans notre cas, je vais ai fais de petites captures d’écrans pour vous faciliter la tâche ;-).

  Dans « chrome://extensions », cliquez sur « Developer Mode » puis « Pack extension » (« Mode développeur » et « Empaqueter l’extension » en Français)

![](/2016/11/jitsi_extension1.png)

![](/2016/11/jitsi_extension2.png)

![](/2016/11/jitsi_extension3-1.png)

On peut en profiter pour ajouter une clé privée (ou simplement récupérer le certificat autosigné généré lors de l’installation de Jitsi Meet et situé par défaut dans /etc/prosody/certs).

![](/2016/11/jitsi_extension4-1.png)

  Installer l’extension sur le poste client (tous les postes clients), toujours dans _chrome://extensions_ puis faire un « Drag n drop » du fichier chrome.crx.

![](/2016/11/jitsi_extension5.png)

Ajouter l’extension, puis récupérer l’ID de l’extension. Ici c’est hocnaigakjinajjppkpacmkipjlhkmfa.

![](/2016/11/jitsi_extension6.png)

Une fois installée, l’extension est activée. Pour terminer, sur le serveur jitsi meet, éditez le fichier suivant pour y ajouter l’ID du CRX qu’on vient de compiler


```bash
vi /etc/jitsi/meet/jitsi.zwindler.fr-config.js
  […]
  // The ID of the jidesha extension for Chrome.
  desktopSharingChromeExtId: ' hocnaigakjinajjppkpacmkipjlhkmfa ',
```

Pour faciliter l’installation et le déploiement de l’extension sur les postes clients, vous pouvez déposer le fichier sur le serveur jitsi meet dans le dossier /usr/share/jitsi-meet. Les utilisateurs pourront le récupérer en tapant l’URL suivante : `https://@IPjitsi/chrome.crx`

## Mot de la fin

  Vous disposez maintenant d’une plateforme libre qui vous permettra d’héberger des vidéoconférences ad-hoc de manière très simple. Pour autant, il reste deux points à améliorer.

  Premièrement, je n’ai pas encore pris le temps de compiler correctement la version Firefox de l’extension Jitsi de partage d’écran. Ce n’est pas grand chose, mais c’est quand même dommage de ne pas tirer parti de la compatibilité avec les deux navigateurs.

  Deuxièmement, dans un contexte professionnel, la plateforme n’est probablement pas suffisante. En utilisation en entreprise, l’Ops que je suis aura nécessairement envie de pouvoir :

* administrer les connexions en cours
* fixer la bande passante par connexion
* gérer une authentification préalable de type LDAP

Mais ça, c’est pour la prochaine fois ! (Teasing : openfire)
  
 [2]: https://jitsi.org/jitsi-meet/
 [3]: https://framasoft.org/
 [4]: https://degooglisons-internet.org/liste
 [5]: http://www.nextinpact.com/news/101536-degooglisation-dinternet-on-fait-point-avec-luc-didry-administrateur-systeme-de-framasoft.htm
 [6]: https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
