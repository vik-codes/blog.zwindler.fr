---
title: Jeedom dans un container LXC
authors:
  - zwindler
type: post
date: 2021-10-04T06:15:00+00:00
excerpt: tutoriel pas à pas pour installer un serveur domotique Jeedom dans un container LXC
url: /2021/10/04/jeedom-dans-un-container-lxc/
image: /2021/08/mijia.png
categories:
  - autohebergement
  - Virtualisation
tags:
  - bluetooth
  - domotique
  - hygromètre
  - Jeedom
  - LXC
  - thermomètre
  - Xiaomi

---
## Jeedom + bluetooth pour de la domotique accessible

_**Note : je vous spoil tout de suite la fin** : il n’est pas possible de faire fonctionner une clé USB bluetooth dans un container LXC. Du coup ma plateforme Jeedom ne peut pas fonctionner avec mon dongle bluetooth et j’ai du tout réinstaller dans une VM. Le tutoriel reste globalement applicable, si vous n’avez pas de dongle bluetooth ou si vous installez une VM_.

Il y a quelques mois, j’ai décidé de tenter de domotiser un peu ma maison. Comme j’aime bien grapher tout ce qui me passe sous la main, j’ai commencé par acheter un pack de 4 capteurs de température + hygrométrie Xiaomi dans les chambres et le salon.

L’avantage principal de ces petits thermomètres connectés est qu’ils sont très peu chers, majoritairement parce qu’il s’agit de thermomètres bluetooth, beaucoup plus répandu (et donc moins coûteux) que les équivalents zigbee, z-wave, etc.

![](/2021/08/mijia.png)

On peut donc aussi très facilement les appairer à un smartphone (Xiaomi fourni une application pour faciliter la tâche un peu plus) et aussi les intégrer à une plateforme domotique (Xiaomi propose une passerelle Bluetooth) quelconque. Mais l’application smartphone est très limitée et nécessite d’être à très courte portée (of course).

Depuis des années, je sais également que beaucoup de hobbyists de la domotique utilisent Jeedom comme solution de domotique gratuite... D’autant que les solutions d’installations proposées par Jeedom sont nombreuses ! Installation baremetal, sur raspberry pi (ARM), dans une VM, dans un container Docker, etc...

Mais je n’avais rien pour l’installer...

## Choix de l’installation

Heureusement, après quelques années en full hébergé, j’ai finalement repris un serveur auto-hébergé dans mon DC-buanderie &#8482;. L’occasion de pouvoir disposer d’un peu plus de puissance en local (aka chez moi) et aussi de relancer mes velléités de domotique auto-hébergée !

![](/2021/08/dc_buanderie.png)

J’aurai pu installer Jeedom sur une VM de mon Proxmox, comme tout le monde. Mais comme je suis un original, j’ai préféré l’installer à la mimine sur un container LXC de mon hyperviseur. 

(La vraie raison c’est que j’aime bien éviter l’overhead CPU et RAM des VMs en faisant plutôt des containers LXC...)

## Récupérer l’OS

Le guide d’installation Jeedom pour une VM n’est ni plus ni moins que l’[installation d’une VM Debian 9 (mais 10 ou 11 ça serait pareil)](https://doc.jeedom.com/fr_FR/installation/vm). On peut donc le reprendre tel quel, mais avec Proxmox et LXC.

Télécharger une image de container Debian 10 sur un des datastore du Proxmox

```
pveam update && pveam available --section system | grep debian
system          debian-10-standard_10.7-1_amd64.tar.gz
system          debian-11-standard_11.0-1_amd64.tar.gz
system          debian-9.0-standard_9.7-1_amd64.tar.gz

pveam download rpool-data debian-10-standard_10.7-1_amd64.tar.gz
downloading http://download.proxmox.com/images/system/debian-10-standard_10.7-1_amd64.tar.gz to /rpool/data/template/cache/debian-10-standard_10.7-1_amd64.tar.gz
[...]
```


![](/2021/08/download_lxc_debian10.png)

Ou si vous voulez frimer parce que vous êtes en Proxmox 7, vous pouvez le DL depuis l’interface graphique

A partir de là, on crée un container LXC (bouton CT) comme d’habitude. Niveau spécification du container, je n’ai pas mis grand-chose et ça a l’air bien suffisant. De toute façon, ça tourne sur des raspberry pi donc c’est peu gourmand.

  * 1 vCPU
  * 1024 Mo de RAM
  * 10 Go de disque

Une fois le CT booté, on se connecte, on le met à jour

```
sudo apt update
sudo apt dist-upgrade
```


Puis on récupère le script d’installation de la mort de Jeedom et on l’exécute les yeux fermés &#x1f648; (ne faites pas ça en prod). J’ai un peu de mal à croire que des gens sérieux osent proposer encore ce genre de méthode d’installation mais bon...

```
wget https://raw.githubusercontent.com/jeedom/core/master/install/install.sh
chmod +x install.sh
./install.sh
```


![](/2021/08/install_jeedom_1.png)

A partir de là, un gros script devrait finir par installer Jeedom et si tout s’est bien passé, celui-ci va lancer un serveur web Apache en écoute sur le port 80

```
root@jeedom:~# lsof -i ":80"
COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
apache2 39845 root 4u IPv6 36590854 0t0 TCP *:http (LISTEN)
apache2 39849 www-data 4u IPv6 36590854 0t0 TCP *:http (LISTEN)
```


So far, so good

## Reverse, mon beau reverse

Moi, le HTTP plain sur le port 80, ça me gave. Pas envie d’ouvrir ça aux 4 vents. J’ai donc un reverse proxy qui me permet de gérer de manière centralisée mes services web (ça a tout un tas d’avantages, notamment celui de n’ouvrir qu’un port, de faire de la rupture protocolaire, de gérer de manière centralisée et unifiée les certificats TLS, ...).

Parfois, il faut feinter un peu la conf ou réécrire certaines URL, mais dans le cas de Jeedom, une redirection basique semble fonctionner.

```
location / {
  proxy_pass http://192.168.5.6;
  proxy_set_header X-Forwarded-For $remote_addr;
  proxy_set_header Host $http_host;
}
```


J’ajoute ensuite un enregistrement pour jeedom dans mon DNS et hop, j’ai une plateforme de domotique accessible de manière sécurisée depuis partout !

## Configuration de Jeedom

On peut donc maintenant passer à la doc « [Premiers pas](https://doc.jeedom.com/fr_FR/premiers-pas/index) » de chez Jeedom !

Je ne vais pas paraphraser leur guide de démarrage, mais ce qu’il faut savoir c’est qu’il faut absolument s’enregistrer sur le « Market » pour pouvoir activer l’extension Bluetooth BLEA qui nous intéresse dans ce tuto. Et comme le compte est demandé lors de la première connexion, autant créer le compte d’abord.

Une fois que c’est fait, on peut se connecter sur notre Jeedom, avec un agréable login/mdp admin/admin qu’il faudra heureusement obligatoirement changer à la première connexion ;)

![](/2021/08/jeedom_login-1.png)

> WOW ! C’est hyper moche, j’étais pas prêt !

## Ajouter une clé USB sur un container LXC

Paradoxalement, permettre à un container LXC d’accéder à un device USB sur un container (donc on est dans le même OS, même kernel) est bien moins facile à faire que de faire de l’USB passthrough pour une VM (2 clics clics dans l’interface). 

Pourtant, il y a probablement toute sortes d’interfaces et d’émulations pour faire croire à la VM qu’elle a un port USB physique... La magie de l’automatisation ;-).

Je me suis globalement basé sur ces deux guides pour y arriver, et je ferai un article plus détaillé en français une autre fois :

* [medium.com/@konpat/usb-passthrough-to-an-lxc-proxmox-15482674f11d](https://medium.com/@konpat/usb-passthrough-to-an-lxc-proxmox-15482674f11d)
* gist.github.com/Yub0/518097e1a9d179dba19a787b462f7dd2 (lien mort)

Long story short, il y a plusieurs paramètres à récupérer et un fichier de conf à modifier et à la fin ça donne ça :

```
lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 003: ID 0a12:0001 Cambridge Silicon Radio, Ltd Bluetooth Dongle (HCI mode)
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```


## Ajouter le plugin Bluetooth BLEA

Normalement si vous avez une clé USB bluetooth correctement visible dans l’OS où est installé votre Jeedom, vous avez « juste » à activer le plugin **Bluetooth Advertisement** disponible sur le Market officiel Jeedom.

![](/2021/08/plugin_bluetooth_advertisment.png)

Une fois le plugin installé, on peut aller le configurer (menu Plugins / Gestion des plugins). Il faut aussi l’activer (Action « Activer »).

![](/2021/08/config_bluetooth_advertisment_01.png)

Et du coup, comme je vous l’avez spoilé : et là c’est le drame.

Dans la liste « dropdown » permettant de choisir le device Bluetooth USB, le dongle n’apparaît pas...

Cependant, en lisant les logs j’ai assez rapidement trouvé l’erreur et je suis tombé sur ce post sur le forum de Proxmox.

> Doing a « hciconfig » on the GUEST system returns:
>   Can’t open HCI socket.: Address family not supported by protocol

Et effectivement, j’ai la même erreur. A partir de là, j’ai pu [retrouver ce post](https://forum.proxmox.com/threads/assign-a-bluetooth-dongle-to-a-ct.67577/#post-303313) qui indique clairement qu’à cause d’une limitation dans les namespaces linux, le bluetooth ne peut pas fonctionner dans un container LXC...

> This was extensively discussed in our german forum ([link](https://forum.proxmox.com/threads/bt-passthrough-lxc-access-denied.61344/#post-289538)), here’s the gist of it:Bluetooth devices register themselves as a network interface, so passing through the USB /dev node is useless. Sadly, the BT network adapter is not namespaceable, meaning it can’t be assigned to a container the way regular network interfaces can.

J’en reviens donc à ma note du début d’article : si vous n’avez pas de périphérique bluetooth dans votre domotique, vous êtes maintenant probablement l’heureux propriétaire d’un jeedom fonctionnel dans un container LXC, plus léger qu’une VM.

Dans le cas contraire (comme moi) vous n’avez plus qu’à recommencer le processus, cette fois ci dans une VM, puisque là, le passthrough USB de qemu permet de bypasser la limitation du namespacing linux...

Bref, have fun ;-p

## Sources additionnelles

* Jeedom Premiers pas - [doc.jeedom.com/fr_FR/premiers-pas/index](https://doc.jeedom.com/fr_FR/premiers-pas/index)
* Jeedomiser - [jeedomiser.fr/article/dongle-usb-bluetooth-compatible-avec-jeedom/](https://jeedomiser.fr/article/dongle-usb-bluetooth-compatible-avec-jeedom/)
* Forum Proxmox - Bluetooth in LXC container : [forum.proxmox.com/threads/bluetooth-inside-lxc-container.33688/](https://forum.proxmox.com/threads/bluetooth-inside-lxc-container.33688/)
* LXD Github issue - github.com/lxc/lxd/issues/3265 (lien mort)
