---
title: 'Geekerie du week end : installer Docker sur un Raspberry Pi'
authors:
  - zwindler
type: post
date: 2016-09-05T07:15:28+00:00
url: /2016/09/05/geekerie-du-week-end-installer-docker-sur-un-raspberry-pi/
image: /2016/09/20160904_111047.jpg
categories:
  - autohebergement
  - DIY
tags:
  - Do it yourself
  - Docker
  - Raspberry Pi
  - Raspbian
  - win32imager

---
## Docker & Raspberry, le « home project » presque parfait

En attendant que mon porridge soit prêt, je parcourrais mon fil Twitter et je suis (rerere)tombé sur une info (RT par Docker) et qui tourne beaucoup en ce moment :

> Installez Docker sur votre Raspberry Pi en une ligne de commande !

Après avoir un peu fouillé l’Internet je me suis rendu compte qu’il n’y avait pas grand chose de nouveau sous le soleil. Il existe déjà des distributions qui proposent Docker sur Raspberry Pi depuis longtemps. On trouve pas mal de ressources sur **Hypriot OS** et il a été pas mal montré à la DockerCon que Docker sur Raspberry Pi, ça fonctionne.

Et après tout ce n’est pas vraiment une surprise ! Docker tourne sous Linux, la seule difficulté consiste à le porter sur Raspberry Pi et donc de compiler les sources avec le support du processeur ARM.

## Alors quoi de nouveau ?

Ce qui est nouveau, c’est que Docker a mis à disposition un script sur son site web qui permet d’installer Docker sur un Raspberry Pi sans passer par une distribution spécialisée. Et ils se sont même permis d’en faire un « one-liner » pour le plus grand plaisir des geeks.

Mais ça sous-entend bien sûr que vous l’avez déjà installé cette distribution ce qui n’est pas mon cas.

## Pour les petits nouveaux, le matériel

![Du matériel informatique sur la table à manger dans le sejour... pas certain que ce soit bon pour mon karma ça ?](/2016/09/20160904_095535.jpg)

Au risque d’enfoncer des portes ouvertes, voici ce dont vous aurez besoin pour réaliser ce « home project ».

### **Un Raspberry Pi**

Idéalement [la version 3](https://www.amazon.fr/gp/product/B01CCOXV34) mais le premier du nom ira très bien, au détail près que j’ai pris le modèle B avec un port **Ethernet**.

### **Un combo clavier souris USB compatible Linux**

Les ports sont rares sur le Raspberry, en particulier le premier. Toutes les astuces sont donc bonnes à prendre pour s’économiser un port USB. Le [Logitech K400 Plus](https://www.amazon.fr/gp/product/B00Y0PP7B8) est un peu une référence quand on parle mini-pc et médiacenter. Que ce soit sur Linux, Windows, mes serveurs, il fonctionne à merveille en combo clavier souris, tout en restant « utilisable » contrairement à des modèles plus petits encore comme le [Mini Clavier iClever](https://www.amazon.fr/gp/product/B008JBSTUA) (avis personnel).

### **Un écran avec un port RCA ou HDMI**

Ça peut paraître évident, mais au moins jusqu’à ce que vous ayez terminé l’installation, configuré une adresse IP et activé SSH, l’écran sera obligatoire. Vous avez plusieurs solutions, toutes valables en fonction de votre contexte :

* l’écran pour Raspberry Pi via connectique raspberry => L’écran [Officiel Raspberry Pi 7"](https://www.amazon.fr/gp/product/B0153406SS) est un peu cher mais fait 7" (comme son nom l’indique) et est tactile. Vous trouvez plein de copies bien meilleur marché sur Amazon (mais attention aux mauvaises surprises). L’avantage est que ces écrans tirent partie de la connectique du raspberry, l’inconvénient et qu’ils sont donc compatibles uniquement avec lui.
  * un écran d’ordinateur classique ou un téléviseur => suffisant si vous ne souhaitez pas faire de modifications régulières sur votre raspberry
  * un mini écran 7" de voiture => les écrans pour voiture étaient historiquement vendu pour ceux qui réalisaient des modifications sur leur véhicule tel que l’ajout d’une caméra de recul. Avec l’arrivée du Raspberry Pi, ces nombreux kits ont été détournés de cet usage pour servir de [mini écrans pour le raspberry](https://www.amazon.fr/gp/product/B00BUL0MQK) (avant que l’écran officiel ne sorte). Personnellement j’en ai acquis un tout simplement parce que cet écran dispose _également _de sorties VGA et HDMI, ce qui me permet de le brancher à mes serveurs en plus du Raspberry Pi dans mon [Datacenter personnel](/2014/03/10/construction-dun-helmer-like-pour-mon-infra-perso-part-3-lassemblage-et-lamenagement-interieur/). J’ai choisi celui ci pour le pied et la possibilité de le fixer mais il existe aussi des versions [plus simples.](https://www.amazon.fr/gp/product/B015E8EDYQ).

### **Une carte SD**

Si possible classe 10, le format dépend de votre Raspberry. Sur le premier du nom, il s’agit d’une carte SD, pour les plus récent il me semble que c’est une microSD.

### **Un PC avec un lecteur de carte SD**

Pour copier le fichier IMG de l’OS sur la carte SD. Si je ne m’abuse elle doit être au format Fat32 à la base.

## Ok, on s’y met !

La première étape est donc de télécharger une version de l’OS Debian et de l’installer sur Raspberry Pi. En fait installer est un peu un abus de langage puisqu’on va copier bloc à bloc un fichier « img » sur une carte SD.

Télécharger [le fichier « img » sur le site raspberrypi.org](https://www.raspberrypi.com/software/) et le décompresser une fois téléchargé. Par principe d’économie, j’ai pris la version lite, qui marchera parfaitement mais qui est livrée dans interface graphique (tout en ligne de commandes). Pour autant vous n’êtes pas obligé de le faire, Raspbian (renommé Raspberry Pi Os depuis) sera plus convivial en version complète.

Si vous voulez plus de détails, vous trouverez également sur ce même site [les instructions d’installation](https://www.raspberrypi.com/documentation/computers/getting-started.html).

Télécharger un utilitaire pour copier « bloc à bloc » le fichier .img sur la carte SD. Pour Linux, un simple **dd** aurait fait l’affaire mais mon laptop est sous Windows donc on utilise [win32diskimager disponible sur sourceforge](https://sourceforge.net/projects/win32diskimager/).

L’utilitaire est très simple d’utilisation. Vous sélectionné un fichier img, puis un disque sur lequel écrire bloc à bloc. Je ne vais pas le dire, hein, mais ... _ne vous trompez pas de disque !_

![](/2016/09/win32imager1-1.png)

Une fois tout sélectionné correctement, cliquez sur **Write**.

Une fois que c’est terminé (Write Sucessful) vous pouvez déconnecter la carte SD, puis l’insérer dans votre Raspberry et booter (_aka_ brancher la prise électrique du Raspberry).

## Installation et configuration de base

Après un reboot à la première exécution et un cycle de boot normal, vous devriez voir ceci :

![](/2016/09/20160904_111047.jpg)

Sur cette distribution, les logins password par défaut sont :

  * Login : pi
  * Mot de passe : raspberry

Si vous avez branché votre raspberry en Ethernet et que vous disposez d’un DHCP, vous devriez disposer d’une adresse IP à l’écran.

![](/2016/09/20160904_112444.jpg)

Vous pouvez donc vous y connecter en SSH (via un putty sous Windows). Si vous n’avez pas de DHCP, il faudra se connecter un première fois en local et là petit blague, par défaut votre installation Raspbian est en QWERTY. Petite conversion AZERTY => QWERTY pour ceux qui ne connaissent pas leur clavier QWERTY par cœur :

login : pi  
mot de passe : r**q**spberry

A partir de la les personnalisations qui suivent sont optionnelles, mais j’aime bien disposer d’un IP fixe et d’un nom d’hôte personnalisé.

### Changer le nom d’hôte

Se connecter en SSH via l’adresse IP récupérée préalablement et modifier les fichiers suivants :

```
sudo sed -i "s/raspberrypi/votrenouveaunom/g" /etc/hosts
sudo sed -i "s/raspberrypi/votrenouveaunom/g" /etc/hostname
hostname votrenouveaunom
```

ou à la main si vous voulez être sûrs de ce que vous modifiez :

```
sudo vi /etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
127.0.1.1       votrenouveaunom

sudo vi /etc/hostname
votrenouveaunom

hostname votrenouveaunom
```

Pour prise en compte des paramètres, fermez la session et rouvrez en une nouvelle (pas besoin de rebooter).

### Réseau : IP fixe

Sur les **Raspbian Jessie**, il ne faut plus utiliser le fichier /etc/network/interfaces comme on peut le voir sur de très nombreux tutos sur Internet. La modification se fait via **dhcpcd** (à ajouter en fin de fichier) :

```
sudo vi /etc/dhcpcd.conf
interface eth0
static ip_address=192.168.10.200/24
static routers=192.168.10.1
static domain_name_servers=192.168.10.1
```

Pour prise en compte :

```
sudo systemctl daemon-reload
sudo systemctl restart dhcpcd
```

Pas besoin de rebooter !!!

Pour les **versions précédentes**, la solution que l’on voit habituellement est alors valide : éditer le fichier /etc/network/interfaces et remplacer la ligne

```
iface eth0 inet dhcp #ou manual
```

par :

```
iface eth0 inet static
    address 192.168.10.200
    netmask 255.255.255.0
    network 192.168.10.0
    broadcast 192.168.10.255
    gateway 192.168.10.1
```

(Bien entendu les IPs données ici ne le sont qu’à titre d’exemple. A adapter à votre contexte)

Pour prise en compte, lancez la commande suivante (pas besoin de rebooter mais ça risque de couper)

```
sudo /etc/init.d/networking restart
```

### Changer le mot de passe par défaut

Il est par défaut. Cela signifie donc que tout le monde le connait. Et comme en plus le compte « pi » dispose des droits sudo (et même NOPASSWD), je vous conseille fortement d’y mettre un mot de passe complexe et de vous authentifier sur votre raspberry via un certificat sur votre PC.

```
pi@votreraspberrypi:~ $ passwd
Changing password for pi.
(current) UNIX password:
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
```

### Mettre à jour votre OS

Il est plus que conseillé de mettre régulièrement à jour votre Raspberry Pi comme vous le feriez pour n’importe quel autre système. Voire plus si vous envisagez de déployer des conteneurs à tour de bras avec Docker ;-).

```
sudo aptitude update -y && sudo aptitude upgrade -y
```

### Humeur

Beaucoup de tutoriels sur Internet vous diront de rebooter votre OS pour prise en compte de ces changements. C’est une ânerie. Contrairement à Windows, il y a très peu de cas où un reboot complet de la machine est nécessaire pour prise en compte d’un nouveau paramètre. Le seul exemple que j’ai en tête est la mise à jour du kernel, ce qui n’est même plus vrai depuis la version 4 du noyau Linux qui se patche à chaud !

Que ce soit des mises à jour, des prises en compte de paramètres, des changements d’IP, ... tout peut se faire à chaud. Il faut juste être conscient des implications (même si la mise à jour se fait à chaud, les applications doivent être redémarrées pour tirer parti des composants mis à jour par exemple) et c’est pour ça que la solution de facilité c’est le reboot... Mais sachez juste que ce n’est pas obligatoire.

## Docker !

Ça y est ! On peut enfin lancer cette fameuse ligne de commande dont tout le monde nous parle !

```
curl -sSL get.docker.com | sh
```

Vous pouvez maintenant exécuter l’ensemble des commandes Docker (y compris Swarm pour la mise en cluster) et pourquoi jeter un œil [aux articles que j’ai écris sur Docker](/recherche/?keyword=Docker) (d’autre vont bientôt suivre, c’est dans la pile :-p ).

Il ne me reste plus qu’à vous souhaiter un bon week end, et aller manger mon porridge (qui est froid maintenant).
