---
title: Sortie de Proxmox VE 5.2.1, les nouveautés
authors:
  - zwindler
type: post
date: 2018-05-22T14:45:57+00:00
url: /2018/05/22/sortie-de-proxmox-ve-5-2-1-les-nouveautes/
image: /2017/08/proxmox_logo.png
categories:
  - Stockage
  - Système
  - Virtualisation
tags:
  - Ceph
  - Cluster
  - hyperviseur
  - "Let's Encrypt"
  - Luminous
  - noVNC
  - Proxmox
  - Proxmox VE
  - Proxmox VE 5.2
  - SPICE
  - Storage vMotion
  - VMware
  - xterm.js
  - ZFS

---
## Proxmox VE 5.2.1

La semaine dernière, _Proxmox Server Solutions GmbH_, l’équipe derrière **Proxmox VE** a sortie la version 5.2 de son hyperviseur libre & clé en main.

J’ai déjà écris [de nombreux articles sur cette distribution](/recherche/?keyword=proxmox) car c’est un très beau projet, à mon sens une des seuls distributions clés en main pour faire de la virtualisation aussi bien pour des besoins perso que des besoins pros. Pour ceux qui ne connaissent pas, je vous conseille de commencer par les tutos de M4vr0x sur Proxmox VE 5.x [(part1)](/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/) [(part2)](/2017/07/18/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-2/) [(part3)](/2017/07/25/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-3/).

## Dans le rétroviseur, Proxmox VE 5.0 et Proxmox VE 5.1

Sortie l’été dernier, le changement de la branche 4 vers la branche 5 de Proxmox VE a surtout marqué une évolution de l’OS à la base de Proxmox VE (Debian 8 vers Debian 9), même si quelques features sympa avaient quand même été ajoutées.

Dans les points marquants, il y avait tout de même eu :

  * le renforcement de l’intégration avec Ceph, via l’intégration de la version Luminous (Ceph 12.1, preview) et des améliorations dans le Dashboard Ceph dans l’UI (apparue en 4.4)
  * l’introduction de la fonctionnalité de [Storage Replication][5], basée sur des mécanismes built-in de ZFS
  * la migration à chaud de VMs, même s’il s’agit de stockages locaux
  * un effort particulier pour [importer des VMs provenant d’autres hyperviseurs][6]

Clairement, l’équipe de Proxmox a fait un focus sur le stockage, dans le but de rattraper les « grands » hyperviseurs sur ces aspects (_i.e. des alternatives à VSAN, vSphere Replication et storage vMotion_). Voir ce genre de features dans un hyperviseur (qui peut être) gratuit et sans pour autant être une usine à gaz comme RHEV/oVirt est très appréciable.

Sortie fin Octobre, la version 5.1 était passée relativement inaperçue (au moins de moi) puisqu’elle apporte surtout un passage à l’état « production ready » du stockage Ceph (v12.2) dans PVE ainsi qu’une mise à jour de ZFS apportant des gains de performance (en plus des mises à jour de kernel/packages habituelles).

## Et Proxmox VE 5.2 alors ?

Là, en revanche, ya du lourd !

Déjà, on est passé sur une Debian 9.4, avec un kernel 4.15.17 (assez récent puisqu’on est en est au 4.16). LXC passe de la 2.0.0 à la 3.0.0, la LTS sortie en mars du **container runtime** disponible dans PVE. Ceph passe en Luminous LTS stable, ce qui rassurera les plus frileux qui attendaient avant de tester Ceph sous Proxmox VE.

Voilà pour les mises à jour de packages. Maintenant, les features que j’ai hâte de tester =>

  * Support de Cloudinit dans la GUI. Pour ceux qui ne connaissent pas, c’est un mécanisme universel sous Linux permettant de configurer votre VM dès son instanciation ([voir doc officielle][7])
  * La possibilité de gérer les nœuds des clusters Proxmox VE
  * **Gestion des certificats Let’s encrypt directement depuis la GUI**; ce point va faire l’objet d’un petit article très vite ;-)
  * Ajout des partages SMB/CIFS comme support de stockage officiel (backups, images, templates, iso et containers)
  * Affichage de l’adresse IP de la VM dans l’UI (première intégration de l’agent **qemu-guest-agent**, on peut espérer plus de fonctionnalités à l’avenir)
  * Possibilité de limiter la bande passante lors des opérations de restauration des backups
  * Intégration de xterm.js comme console en plus de noVNC et SPICE

Il y en a d’autre mais qui m’intéressent moins. Vous pouvez néanmoins consulter la liste complète sur le [changelog de la version][8].

## Concrètement ça donne quoi ?

Je suis assez enthousiaste quant à cette nouvelle version, qui apporte plein de bonnes choses. Je ne souhaite pas en dire plus pour le moment, car je vais (en cours d’écriture) publier des articles dans les jours qui viennent sur ces nouvelles fonctionnalités. Un petit teasing tout de même :

![](/2018/05/proxmox_cloud_init.png)

> cloud-init dans l’UI de PVE

![](/2018/05/proxmox_letsencrypt_tease.png)

> Génération d’un certificat Let’s Encrypt pour un nœud PVE

![](/2018/05/prxmox_xterm.js.png)

> L’ajout de xterm.js dans l’UI

![](/2018/05/proxmox_cluster.png)

> La gestion des clusters dans l’UI de PVE

![](/2018/05/proxmox_io_limit_bandwidth.png)

> Limites en MiB/s lors d’une restauration

 [5]: https://pve.proxmox.com/wiki/Storage_Replication "Storage Replication"
 [6]: https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines#_importing_virtual_machines_from_foreign_hypervisors "Qemu/KVM Virtual Machines"
 [7]: https://cloud-init.io/
 [8]: https://pve.proxmox.com/wiki/Downloads#Proxmox_Virtual_Environment_5.2_.28ISO_Image.29
