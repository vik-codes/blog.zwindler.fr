---
title: Tutoriel Proxmox VE 8 - SDN en mode VXLAN avec des machines sur Internet
authors:
  - zwindler
type: post
date: 2025-03-30T12:30:00+02:00
excerpt: "Tutoriel Proxmox VE 8 - SDN en mode VXLAN avec des machines sur Internet"
url: /2025/03/30/tutoriel-sdn-vxlan-proxmoxve-8
image: /2025/03/vxlan2.png
categories:
  - autohebergement
  - Cluster
  - Système
  - Virtualisation
tags:
  - kimsufi
  - KVM
  - Proxmox
  - Proxmox VE
  - serveur dédié
  - virtualisation
  - SDN
  - VXLAN

---

## Préambule

Ce tutoriel est un genre de *hors série* dans ma suite d'articles sur Proxmox VE 8.

Dans la [troisième partie qui est sortie il y a quelques jours](/2025/03/25/deploiement-d-un-cluster-proxmox-ve-8-part-3/), on s'est arrêté sur un cluster de machines distantes sur Internet.

Elles ne sont pas dans le même LAN, et pour tout dire, elles sont même distantes d'environ 100ms (et ça marche très bien). 

A la fin de l'article, ça fonctionne, on a bien un réseau unique sur nos deux machines, avec un IPAM et un DHCP fonctionnel des deux côtés. Mais pour autant, les machines virtuelles qui sont sur des hôtes différents ne peuvent pas se parler directement et c'est quand même un peu dommage de ne pas avoir été au bout de l'exercice.

Plutôt que de réécrire cette partie, j'ai décidé de faire un petit aparté où je termine le travaille et teste la fonction VXLAN du SDN de proxmox VE, parce que OUI, ça peut fonctionner jusqu'au bout.

## Prérequis

Je pars du principe que vous avez déjà deux (ou plus) machines au sein d'un même cluster Proxmox VE 8.

Si ce n'est pas le cas, vous êtes partis pour la lecture de ma suite d'articles (en cours d'écriture) sur le sujet (have fun!) :

* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (1/4)](/2025/01/27/deploiement-d-un-cluster-proxmox-ve-8-part-1)

Ces machines ne sont pas dans le même LAN (sinon pas forcément besoin de s'embêter avec du VXLAN, le [SDN Simple peut suffire, comme on a fait dans la partie 3](/2025/03/25/deploiement-d-un-cluster-proxmox-ve-8-part-3/))

## Problème

Ce qu'on veut faire, c'est créer un SDN qui passe par Internet, au point que les machines virtuelles croient être sur le même LAN.

On ne peut pas faire ça avec le SDN Simple, les VMs d'un hôte ne peuvent pas contacter les VMs d'un autre hôte distant sur Internet, même en étant dans le même SDN Simple et avec le même plan d'adressage.

Mais si on lit un peu plus loin dans la [doc de PVE sur le SDN](https://pve.proxmox.com/pve-docs/chapter-pvesdn.html), on voit que c'est précisément le usecase mis en avant pour l'utilisation des SDN de type VXLAN :

> The VXLAN plugin establishes a tunnel (overlay) on top of an existing network (underlay). This encapsulates layer 2 Ethernet frames within layer 4 UDP datagrams...
> [...]
> You can, for example, create a VXLAN overlay network on top of public internet, appearing to the VMs as if they share the same local Layer 2 network

Petit souci cependant, en vrai, il ne vaut mieux pas le faire, car les trames ne sont pas chiffrées, et sur Internet, ce n'est vraiment pas la meilleure idée du monde...

> Warning VXLAN on its own does does not provide any encryption. When joining multiple sites via VXLAN, make sure to establish a secure connection between the site, for example by using a site-to-site VPN.

En alternative, on aurait pu partir directement sur la version la plus complète / complexe du SDN de Proxmox VE : les **EVPN Zones**

> The EVPN zone creates a routable Layer 3 network, capable of spanning across multiple clusters. This is achieved by establishing a VPN and utilizing BGP as the routing protocol.

Mais je n'ai pas envie de tremper avec BGP ici et je veux rester sur un truc simple. Cependant, c'est probablement l'option la plus "propre" pour un setup de production.

## VXLAN donc, mais avec un VPN

Je ne vais pas me prendre la tête, on va monter un petit VPN avec wireguard à la mano. Il y a des tonnes d'outils de VPN sur le marché et des tonnes d'outils pour se faciliter la vie. Si vous voulez plus d'info sur Wireguard, je suis sûr que vous en trouverez plein, je mets juste ici le strict minimum pour que ça "juste marche".

Sur les deux serveurs, installez wireguard, qui devraient être dans les dépôts debian par défaut :

```bash
apt update && apt install -y wireguard
```

Générez un couple de clé **sur chaque machine** :

```bash
wg genkey | tee privatekey | wg pubkey > publickey
```

Petite gymnastique mentale, on va écrire un fichier de configuration avec pour chaque serveur, la clé privée du serveur (fichier `privatekey`) sur lequel on est, mais la clé publique (fichier `publickey`) **du serveur distant**. 

(Quand on y réfléchit, c'est évidement, mais je préfère insister)

Et il faut évidemment changer les adresses et les interfaces réseaux en fonction du serveur sur lequel on est de manière à ne pas avoir de conflit.

```
vi /etc/wireguard/wg0.conf
[Interface]
Address = 10.10.30.1/24
ListenPort = 51820
PrivateKey = <clé privée du serveur local>
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o <nom d'interface réseau> -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o <nom d'interface réseau> -j MASQUERADE

[Peer]
PublicKey = <clé publique du serveur distant>
Endpoint = <IP publique du serveur distant>:51820
AllowedIPs = 10.10.30.2/32
```

Note : vous pouvez aussi ajouter plus de nodes dans le VPN, il suffit d'ajouter plus de "Peer".

On termine en démarrant le VPN et en vérifiant que les nodes se parlent entre eux :

```bash
systemctl enable wg-quick@wg0 --now

ping 10.10.30.1
ping 10.10.30.2
```

## Configuration du SDN

Normalement, si vous avez suivi les articles précédents, vous avez déjà les prérequis, mais pour ceux qui ne l'auraient pas fait, je remets que dans le fichier /etc/network/interfaces, il est nécessaire d'ajouter en fin de fichier la ligne suivante (suivi d'un petit `systemctl restart networking`)

```
source /etc/network/interfaces.d/*
```

Ensuite, dans le menu Datacenter, ouvrir le sous menu SDN. 

![](/2025/03/sdn1.png)

Dans le menu SDN/Zones, ajouter une zone de type "VXLan". Deux points importants ici :

* on doit renseigner la liste de tous les "peers", ici les IPs de nos VPNs donc 10.10.30.1 et 10.10.30.2
* on va devoir adapter la MTU. Par défaut, une trame, c'est 1500. Sauf que wireguard pour son encapsulation a diminué la MTU à 1420 et que l'encapsulation VXLAN en prend 50. On doit donc mettre 1370 pour éviter au mieux de la fragmentation, au pire, des paquets dropés

![](/2025/03/vxlan2.png)

Si vous venez de lire l'article précédent, vous allez remarquer qu'ici, il n'y a pas de "coche" pour activer le DHCP sur la zone. C'est malheureusement parce que ce n'est pas disponible pour l'instant.

> Currently only Simple Zones have support for automatic DHCP

Source : [pve.proxmox.com/pve-docs/chapter-pvesdn.html#pvesdn_config_dhcp](https://pve.proxmox.com/pve-docs/chapter-pvesdn.html#pvesdn_config_dhcp)

![](/2025/02/hulk_sad.gif)

Une fois que vous avez validé, allez dans le sous menu SDN/VNets, cliquez sur le bouton "Create" pour créer un réseau virtuel, puis le sélectionner une fois créé pour créer un sous réseau.

![](/2025/03/vxlan4.png)

![](/2025/03/vxlan5.png)

Une fois de plus, n'oubliez d'aller voir la partie DHCP, pour déclarer le range pour notre futur DHCP.

![](/2025/03/vxlan6.png)

Une fois qu'on a bien tout validé, on voit qu'à côté de toutes ces nouvelles choses qu'on vient de créer, il y a une icône avec deux flèches jaunes et un statut à "New".

Pour déployer ces modifications, on doit retourner dans le menu SDN du début, et cliquer sur Apply. Deux lignes "vxlan1" (une pour chaque serveur, en vrai) devraient apparaitre.

![](/2025/03/vxlan7.png)

## C'est tout ?

Et oui, c'est tout, franchement, j'aurai vraiment dû insister un peu avant de poster mon article précédent...

Pour s'en convaincre, il suffit de pop deux containers LXC (sans DHCP 🥲), un sur chaque serveur, et de voir s'ils se pingent.

![](/2025/03/vxlan-test.png)

It works!

Bon, ben... il ne me reste plus qu'à migrer toutes mes machines existantes sur le vnet VXLAN pour avoir enfin un cluster où les VMs se voient entre elles !!