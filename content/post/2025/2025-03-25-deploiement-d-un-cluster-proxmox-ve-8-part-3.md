---
title: Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (3/4)
authors:
  - zwindler
type: post
date: 2025-03-25T12:30:00+02:00
excerpt: "Tutoriel de déploiement d'un clusters d'hyperviseurs Proxmox VE 8 - partie 3"
url: /2025/03/25/deploiement-d-un-cluster-proxmox-ve-8-part-3/
image: /2025/03/sdn2.png
categories:
  - autohebergement
  - Cluster
  - systeme
  - Virtualisation
tags:
  - kimsufi
  - KVM
  - Proxmox
  - Proxmox VE
  - serveur dédié
  - virtualisation

---

Note - cet article fait partie d'une suite d'articles :

* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (1/4)](/2025/01/27/deploiement-d-un-cluster-proxmox-ve-8-part-1)
* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (2/4)](/2025/02/17/deploiement-d-un-cluster-proxmox-ve-8-part-2/)
* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (3/4)](/2025/03/25/deploiement-d-un-cluster-proxmox-ve-8-part-3/)
* [Hors série - SDN en mode VXLAN avec des machines sur Internet](https://blog.zwindler.fr/2025/03/30/tutoriel-sdn-vxlan-proxmoxve-8/)
* Et *au moins* un autre à suivre

## On reprend de là où on en était : premiers pas dans l'UI

Dans le tutoriel précédent (que je vous invite à lire, si ça n'a pas été fait, sinon ça ne sera pas clair), on a configuré le stockage, le réseau et on a déployé notre première machine virtuelle pour nous assurer que tout fonctionne. Mais il reste encore pas mal de choses à explorer, notamment la mise en cluster, le SDN de proxmox VE, le firewall intégré, les sauvegardes, le monitoring...

On reprend donc de là où on en était, et on va installer un autre serveur (difficile de faire un cluster avec une seule machine). 

Ce serveur a été réinstallé avec les mêmes procédures que le serveur dont je vous parle dans les parties 1 et 2, à ceci près que nous n'avons pas besoin de créer le bridge (vmbr0) car nous allons utiliser le SDN !!

Idéalement, il faut que toutes les machines du cluster aient les mêmes pools de storage puisque je le rappelle, cette configuration est censée être commune à tous les serveurs, car gérée au niveau "Datacenter" de notre cluster (même si on peut configurer des exceptions).

## Création du cluster

La mise en cluster de machines Proxmox VE est un sujet que j'ai abondamment traité sur le blog, au point qu'il est d'ailleurs surtout connu de certains d'entre vous surtout pour ces articles ;-\) :

* [Un cluster Proxmox VE en 5 minutes avec Ansible](/2019/07/22/proxmox-en-5-min-ansible-tinc/)
* [Cluster Proxmox VE, v6 cette fois-ci !](/2019/08/20/cluster-proxmox-ve-v6-cette-fois-ci/)
* [Un cluster Proxmox VE avec seulement 2 machines !](/2019/10/11/un-cluster-proxmox-ve-avec-seulement-2-machines/)
* [[Tutoriel] Démonter proprement un cluster Proxmox VE](/2017/09/19/tutoriel-demonter-proprement-cluster-proxmox-ve/)

Je ne vais donc pas y passer trop de temps. Sachez juste que :

* c'est plus facile à faire depuis la version 6 parce qu'il n'y a plus besoin de monter un VPN entre les serveurs (corosync v3)
* ça peut se faire en ligne de commande
* dans tous les cas, il faut se loguer en root **avec mot de passe** lors de la mise en cluster

Très brièvement donc, on va sur le premier serveur, dans la **Server View** en haut à gauche, on sélectionne notre **Datacenter**, puis dans le menu **Cluster**.

![](/2025/02/create-cluster-1.png)

On clique sur le bouton **Create Cluster**.

![](/2025/02/create-cluster-2.png)

Note : ici, c'est simple, je n'ai que ma carte réseau, donc il n'y a pas de doute sur l'interface à utiliser. Cependant, dans le cas d'un serveur avec plus d'interfaces et plus de bridges (ou des VPNs comme on a dû le faire jusqu'en PVE 6), il faut bien choisir quelle interface sert au clustering.

On valide le formulaire :

![](/2025/02/create-cluster-3.png)

À partir de ce moment-là, le serveur n'est plus en "standalone" et dispose de services systemd supplémentaires.

On a notamment un dossier /etc/pve qui est synchronisé entre tous les nodes (el famoso [Proxmox Cluster File System](https://pve.proxmox.com/wiki/Proxmox_Cluster_File_System_(pmxcfs))) avec la configuration de chaque node et les fichiers de configuration des machines virtuelles. On a aussi le logiciel corosync, qui va régulièrement contacter tous les nodes du cluster pour s'assurer que tout le monde est bien vivant / accessible.

## Rejoindre le cluster

Si on retourne voir le menu "Cluster", on a maintenant des informations qui s'affichent sur notre cluster, à savoir son nombre de nœuds (ici un seul, normal). Cliquer sur le bouton **Join information**.

Une popup s'ouvre avec plusieurs informations à copier-coller qui nous seront demandées dans le menu de l'autre serveur, celui qui va rejoindre le cluster :

![](/2025/02/create-cluster-4.png)

On se connecte donc sur l'interface graphique de notre second serveur Proxmox VE (mon Atom dans l'exemple), on va dans le même menu, mais au lieu de créer un nouveau cluster, on clique sur le bouton **Join Cluster** :

![](/2025/03/join-cluster.png)

Petit coup de flip normalement, une fois que le node va rejoindre le cluster, vous allez perdre la main sur l'interface web et avoir un message d'erreur "401". C'est "normal", quand le serveur rentre dans le cluster, des services sont redémarrés et on passe d'un mode standalone à un mode clusterisé...

![](/2025/03/join-cluster2.png)

Pas de panique, un F5 devrait résoudre l'affaire (ou alors, connectez-vous au "premier" serveur du cluster).

On a maintenant un beau cluster :\)

![](/2025/03/pve-cluster.png)

## Split brain

Notez par contre que dans mon exemple, on n'a que 2 nodes, ce qui est plus que déconseillé quand on fait un cluster Linux (en vrai, un cluster en général). Si jamais le lien réseau tombe entre nos deux machines, elles n'auront aucun moyen de savoir si c'est un problème réseau (*que se apelerio split brain*) ou une panne d'un des nodes.

Pour éviter de tout péter en redémarrant des VMs des deux côtés (le cas le plus catastrophique dans un split brain), lorsque le quorum ne sera plus atteint, Proxmox VE passe les nodes qui n'ont pas de majorité en (quasi) "lecture seule".

Et au cas où ce n'est pas clair, le quorum c'est la moitié des nodes +1, donc ici : 2/2+1 = 2... donc dès qu'on a plus un des deux nodes, on a plus le quorum.

> Simple, basique.

Du coup, si jamais on coupe un node ou la communication entre les deux, vos VMs encore actives continueront à fonctionner (j'ai débattu de ça sur LinkedIn il y a quelques jours).

**Par contre**, il sera impossible de modifier la configuration du cluster, démarrer ou créer des VMs, etc.

La seule chose qu'on peut éventuellement faire qui ne soit pas "read only", c'est arrêter des VMs, car ça n'induit aucun risque pour la cohérence des données. Mais vous ne pourrez pas les rallumer, vous êtes prévenus...

Pour la petite histoire, le débat sur LinkedIn, c'était "est-ce que ProxmoxVE coupe toutes les VMs en cas de split brain" et la réponse est évidemment **non**. Par contre, la plupart des actions sont bien bloquées.

![](/2025/03/quorum-ko1.png)

![](/2025/03/quorum-ko2.png)

**Dans tous les cas**, pour éviter ça, le mieux est d'avoir un nombre impair de nodes pour que le split brain ne puisse jamais arriver, ou éventuellement d'ajouter un vote complémentaire à l'aide d'une instance servant juste d'arbitre comme c'est expliqué dans mon vieil article de 2019 ou dans la doc officielle :

* [Un cluster Proxmox VE avec seulement 2 machines !](https://blog.zwindler.fr/2019/10/11/un-cluster-proxmox-ve-avec-seulement-2-machines/)
* [Proxmox Wiki - Corosync External Vote Support](https://pve.proxmox.com/wiki/Cluster_Manager#_corosync_external_vote_support)

## Configuration du SDN

Bon, c'est cool, on a un cluster de deux machines. Mais dans la configuration actuelle, la VM qu'on a créée dans la partie précédente ne peut pas migrer facilement d'un serveur à l'autre. En effet, on l'a attachée sur un bridge Linux (vmbr0) qui a son propre plan d'adressage réseau.

En cas de migration, il faudrait potentiellement démarrer la machine, changer l'adresse IP, revoir les iptables / règles de firewalling. C'est ce que je faisais jusqu'à présent, et dans le cas d'un PRA pour une infra de lab et un blog perso, c'est "OK".

Une grosse nouveauté de la version 8.1, est l'activation d'un module "SDN" (Software Defined Network) qui est présent en test par les développeurs et quelques early adopters depuis la version 6.X, qui va nous permettre de gérer ça de manière centralisée depuis l'interface. Si vous voulez aller bouquiner la doc officielle, c'est ici :

* [pve.proxmox.com/pve-docs/chapter-pvesdn.html](https://pve.proxmox.com/pve-docs/chapter-pvesdn.html)

Le seul prérequis qui va nous manquer est dnsmasq pour le DHCP, et la doc nous dit de lancer les commandes suivantes sur nos machines :

```bash
apt update
apt install dnsmasq
# disable default instance
systemctl disable --now dnsmasq
```

Et dans le fichier /etc/network/interfaces, il est aussi nécessaire d'ajouter en fin de fichier la ligne (suivi d'un petit `systemctl restart networking`)

```
source /etc/network/interfaces.d/*
```

Dans le menu Datacenter, ouvrir le sous menu SDN. On remarque qu'il existe déjà des SDNs de déclarés, mais il s'agit en fait des réseaux par défaut qu'on a déclaré dans les articles précédents :

![](/2025/03/sdn1.png)

Dans le menu SDN/Zones, ajouter une zone de type "Simple". Il existe des zones plus complexes qui seront utiles dans des contextes de production avec des LANs non triviaux (VLAN, VXLan) mais dans notre cas, la Simple est suffisante. 

Note : ne pas oublier de cocher la case **advanced** pour pouvoir activer le DHCP. **OUI on va enfin avoir du DHCP pour nos machines virtuelles et nos containers**.

![](/2025/03/sdn2.png)

Une fois que vous avez validé, allez dans le sous menu SDN/VNets, cliquez sur le bouton "Create" pour créer un réseau virtuel, puis le sélectionner une fois créé pour créer un sous réseau.

![](/2025/03/sdn3.png)

![](/2025/03/sdn4.png)

Une fois de plus, n'oubliez d'aller voir la partie DHCP, pour déclarer le range pour notre futur DHCP.

![](/2025/03/sdn5.png)

Une fois qu'on a bien tout validé, on voit qu'à côté de toutes ces nouvelles choses qu'on vient de créer, il y a une icône avec deux flèches jaunes et un statut à "New".

![](/2025/03/sdn6.png)

Pour déployer ces modifications, on doit retourner dans le menu SDN du début, et cliquer sur Apply. Deux lignes "sdn1" (une pour chaque serveur, en vrai) devraient apparaitre.

![](/2025/03/sdn7.png)

Fait rigolo, le SDN de Proxmox VE va rajouter des règles iptables qui devraient vous dire quelque chose si vous avez déroulé les précédents articles :

```
#version:5

auto vnet1
iface vnet1
        address 10.10.20.1/24
        post-up iptables -t nat -A POSTROUTING -s '10.10.20.0/24' -o vmbr0 -j SNAT --to-source 203.0.113.1
        post-down iptables -t nat -D POSTROUTING -s '10.10.20.0/24' -o vmbr0 -j SNAT --to-source 203.0.113.1
        post-up iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1
        post-down iptables -t raw -D PREROUTING -i fwbr+ -j CT --zone 1
        bridge_ports none
        bridge_stp off
        bridge_fd 0
        ip-forward on
```

Et si maintenant, je recrée une autre machine virtuelle, mais que cette fois-ci au lieu de **vmbr0**, je choisis **vnet1**, je n'ai pas besoin de saisir l'adresse IP (puisque j'ai le SDN qui sert le DHCP) et elle a accès à Internet sans configuration supplémentaire.

![](/2025/03/sdn8.png)

![](/2025/03/sdn9.png)

Avec cette configuration cependant (SDN en mode **Simple Zone**), il ne sera toujours pas possible de faire communiquer les machines virtuelles entre elles. Ça sera possible avec des configurations plus complexes :

> You can, for example, create a VXLAN overlay network on top of public internet, appearing to the VMs as if they share the same local Layer 2 network

* [VXLan Zones](https://pve.proxmox.com/pve-docs/chapter-pvesdn.html#pvesdn_zone_plugin_vxlan)
* [EVPN Zones](https://pve.proxmox.com/pve-docs/chapter-pvesdn.html#pvesdn_zone_plugin_evpn)

Note : j'ai exploré les VXLAN depuis, et [j'ai écrit un article complémentaire ici](/2025/03/30/tutoriel-sdn-vxlan-proxmoxve-8).

## Conclusion

Je n'ai toujours pas terminé cette série, car j'ai encore des choses à dire sur la réplication SDN et le firewalling de Proxmox VE, les sauvegardes, le monitoring, mais une fois de plus, je dépasse déjà les 12000 signes. Il est donc temps de publier l'article et de commencer à écrire le suivant.

Et en attendant, have fun :)
