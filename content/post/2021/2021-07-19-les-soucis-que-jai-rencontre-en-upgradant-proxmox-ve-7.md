---
title: 'Les soucis que j’ai rencontrés en upgradant Proxmox VE 7'
authors:
  - zwindler
type: post
date: 2021-07-19T06:55:00+00:00
excerpt: "Toutes les erreurs que j'ai pu rencontrer lors de l'upgrade de Proxmox VE 6 à 7"
url: /2021/07/19/les-soucis-que-jai-rencontre-en-upgradant-proxmox-ve-7/
image: /2021/07/pve7-1.png
categories:
  - Virtualisation
tags:
  - bullseye
  - cgroups
  - debian
  - LXC
  - OIDC
  - online
  - Proxmox
  - Proxmox VE 6
  - Proxmox VE 7.0
  - pve
  - sso

---
## TL;DR - Lisez encore plus attentivement que d’habitude la release note de Proxmox VE 7

La version 7 de mon hyperviseur préférée vient de sortir ! Comme je n’ai rien d’important qui tourne dessus, je me suis dis que c’était une bonne idée de tester la mise à jour day 1 sans préparation.

Ça n’est évidemment pas une bonne idée ;-p.

![](/2021/07/pve7.png)

Au delà de la valse d’upgrades habituelle ainsi quelques features très sympas (SSO surtout), une modification importante est le **passage à Debian 11**, Bullseye, qui n’est d’ailleurs pas totalement officiellement sortie (même si on est depuis le 17 en Full freeze...), mais aussi les cgroups v2 et leur configuration, ainsi que OpenZFS.

Lisez donc bien :

* [La release note](https://pve.proxmox.com/wiki/Roadmap#Proxmox_VE_7.0)
* [La documentation d’upgrade](https://pve.proxmox.com/wiki/Upgrade_from_6.x_to_7.0)

## pve6to7 OK

Si vous avez déjà fait quelques upgrade de Proxmox VE, vous savez qu’à la dernière mineure de chaque version, un binaire pveXtoY est mis à disposition pour vérifier que la machine (ou éventuellement le cluster) est prêt à être mis à jour.

Dans mon cas, pas de soucis, à part un warning sur le fait que mes VMs actives devraient être migrées (mais comme je n’ai pas de stockage partagé, j’accepte ce downtime).

[](/2021/07/pve6to7.png)

## /boot plein

Cette « erreur » ne m’est pas arrivée mais c’est un grand classique de Proxmox VE. Il n’est pas rare que les /boot soient taillés un peu juste lors de l’installation, et que les kernel (ceux de debian + ceux de proxmox qui a le sien, plus récent) prennent toute la place dans le /boot.

Avant de lancer l’upgrade, vérifiez bien que vous avez de la place pour un kernel dans /boot et nettoyez ce qui dépasse

```
sudo apt autoremove
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be REMOVED:
  pve-kernel-5.4.101-1-pve pve-kernel-5.4.106-1-pve pve-kernel-5.4.73-1-pve pve-kernel-5.4.78-2-pve
0 upgraded, 0 newly installed, 4 to remove and 0 not upgraded.
```


## Dépôts bullseye pas présents chez votre provider

Une partie de mes machines sont hébergées par Online. Je ne sais pas si c’est toujours le cas, mais au moment où j’ai fais l’upgrade, les miroirs n’existaient pas chez eux.

La commande permettant de mettre à jour les fichiers de configuration d’apt n’est donc pas utilisable en l’état si c’est toujours le cas.

![](/2021/07/apt_configuration_pve7.png)

Dans mon cas, j’ai donc du aller modifier les dépôts ciblés pour aller chercher un autre miroir FR

```
cat /etc/apt/sources.list
# deb http://mirrors.online.net/debian bullseye main

#deb http://mirrors.online.net/debian bullseye main non-free contrib
#deb-src http://mirrors.online.net/debian bullseye main non-free contrib
deb http://ftp2.fr.debian.org/debian/ bullseye main contrib non-free
deb-src http://ftp2.fr.debian.org/debian/ bullseye main contrib non-free

deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free
```


## **hwaddress** pour les bridges

Ça c’est LE « piège à c%% » de cette version de Proxmox. C’était d’ailleurs écrit (mais pas hyper clairement) dans la section [Known upgrade issues du guide d’Upgrade](https://pve.proxmox.com/wiki/Upgrade_from_6.x_to_7.0#Known_upgrade_issues). 

Mais comme ce n’était pas clair ils ont rajouté un gros pavé qui explique un peu mieux le problème :

![](/2021/07/known_issue_1.png)

Jusqu’à présent, il n’était pas nécessaire de donner une adresse MAC à un bridge et ma config réseau n’en avait pas du coup. En lisant, ce message, j’ai (bêtement) pensé « peu importe si Debian en donner une autre après l’upgrade ».

Grave erreur. Comme pas mal de monde, je me suis coupé la chique après reboot. Comme je suis loin d’être le seul, les équipes de Proxmox ont rajouté a posteriori un paragraphe pour expliquer POURQUOI c’est un souci et pourquoi il faut setter soit même la MAC.

![](/2021/07/image.png)

TL;DR, récupérez la MAC de vos interfaces réseau branchées sur un bridge avec **ip -c link** et ajouter la mac address dans votre bridge avant upgrade.

## old systemd (< v232) detected, container won’t run in a pure cgroupv2 environment

Là encore, petite surprise due à une mauvaise lecture de ma part. Proxmox VE 6 utilisait déjà les cgroups v2 pour les containers LXC, mais avec une configuration hybride. J’ai donc pensé qu’il n’y avait pas de changement de ce côté.

Grave erreur. Après upgrade, 2 de mes containers LXC en CentOS ont arrêté de fonctionner. Les machines étaient vue « UP » dans l’interface mais impossible de s’y connecter ni de lancer la console. Pas de message d’erreur particulier.

Heureusement, quand on relance les containers, j’ai réussi à voir dans la console l’erreur suivante :

> WARN: old systemd (< v232) detected, container won’t run in a pure cgroupv2 environment! Please see documentation -> container -> cgroup version.TASK WARNINGS: 1
 
Un retour rapide sur les **[Known upgrade issues](https://pve.proxmox.com/wiki/Upgrade_from_6.x_to_7.0#Known_upgrade_issues)** permet de trouver le problème assez vite

![](/2021/07/image-1.png)

Grosso modo, Proxmox VE 7 ne supporte plus les CentOS 7 en mode container LXC (sauf à [bidouiller des paramètres](https://pve.proxmox.com/pve-docs/chapter-pct.html#pct_cgroup_compat) pour revenir dans l’ancien mode, ce que je n’ai pas fait). Et là, c’était pas fun du tout...

## Replication ZFS HS pendant l’upgrade

Petit point d’attention, j’ai eu mes réplications asynchrones de mes VMs via ZFS qui étaient HS entre les nodes de différentes versions (6 vers 6 ok, 7 vers 7 ok, 6 vers 7 KO).

Je n’ai malheureusement pas copié le message d’erreur mais il s’agit d’un bête changement d’arguments dans la ligne de commande entre OpenZFS dans la version de PVE 6 et OpenZFS 2 (PVE 7).

Là, il n’y a pas grand chose à part ne pas trop trainer pour mettre à jour tous vos nodes (ou faire les synchro à la main, peut être ?).

## ovs qui ne s’instancie pas, ovs-vsctl show n’affiche rien

Je n’ai pas dig particulièrement, mais j’ai eu un souci assez pénible avec mes bridges OpenvSwitch, qui étaient correctement déclarés dans le fichier **/etc/network/interfaces** mais qui n’apparaissaient jamais.

Un restart du service n’y faisait rien, pas plus qu’essayer d’ajouter un nouveau bridge en ligne de commandes.

Finalement, ça a fini par « tomber en marche » en ajoutant un bridge OVS depuis la console (et pas en ligne de commandes comme j’avais testé initialement). 

Weird. Peut être un coup de « pas de chance ».

## Conclusion

Si vous voulez mettre à jour vos Proxmox VE pour bénéficier des nouvelles fonctionnalités (le SSO OpenIDConnect me fait rêver), faites donc _bien bien_ attention de ne pas avoir de containers LXC trop anciens et de bien setter vos mac address dans le fichier **/etc/network/interfaces**.

Au delà de ça, ça devrait aller maintenant.
