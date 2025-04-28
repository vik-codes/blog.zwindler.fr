---
title: Sortie de Proxmox VE 6.0, les nouveautés
authors:
  - zwindler
type: post
date: 2019-07-16T16:00:23+00:00
url: /2019/07/16/sortie-de-proxmox-ve-6-0-les-nouveautes/
image: /2017/08/cropped-proxmox_logo.png
classic-editor-remember:
  - block-editor
categories:
  - Cluster
  - Virtualisation
tags:
  - LXC
  - Proxmox
  - Proxmox VE
  - Proxmox VE 6.0
  - QEMU
  - virtualisation

---

## Proxmox VE 6.0

Ce n’est pas la première fois que j’écris un article sur les mises à jour de Proxmox VE, une distribution Linux pour faire de la virtualisation qui me tient pas mal à cœur car très simple et très efficace. Aujourd’hui, Proxmox VE 6.0 vient de sortir !

Pour info, le blog ainsi que d’autres services fonctionnent depuis des années sur un hyperviseur Proxmox, ce qui pour moi est un exemple de stabilité et de simplicité, même dans des usecases très simples (sinon je serai passé à autre chose). [M4vr0x et moi avons beaucoup écrit sur le sujet](/recherche/?keyword=proxmox).

## Mais avant ça ?
  
La dernière fois que j’avais écris un article sur [une release de Proxmox c’était la 5.2](/2018/05/22/sortie-de-proxmox-ve-5-2-1-les-nouveautes/) il y a un an, qui avait sorti pas mal de choses sympas.

Depuis, je ne vous ai pas parlé de la 5.3 et de la 5.4, quelques modifs sympas (mais que je n’ai personnellement pas utilisé).

* Ceph Luminous LTS installable depuis la GUI (5.4)
* Ajout d’un QDevice pour gérer le quorum dans un cluster à 2 hyperviseurs (5.4)
* U2F dans l’interface web (5.4)
* Nesting (faire des containers dans des containers) de containers privilégiés ou pas (5.3)
* Emulation de VMs ARM sur hyperviseur x86_64 (5.3)

## Et Proxmox VE 6.0 ???

Comme toute majeure, il faut s’attendre à pas mal de modifs.
  
La liste des modifications est longue comme le bras, et les ajouts sont à la fois amenés par la mise à jours des composants principaux et par des améliorations sur les composants internes.

## Les composants tiers
  
D’abord, Proxmox VE 6.0 se base sur la toute nouvelle Debian 10.0 (aka Buster). C’est logique pour l’équipe de Proxmox de partir sur le tout dernier OS, puisque la branche 6.x va durer quelques années.
  
On tire donc un kernel Linux plus récent que celui PVE 5 (c’était le 4.15) et on passe sur un 5.0. De quoi tirer profit des dernières améliorations du Kernel, notamment pour le stockage (on y reviendra) et le réseau.
  
Ensuite, les gros composants. Proxmox VE étant une plateforme de virtualisation VM + containers, on va évidemment s’intéresser aux 2 composants qui fournissent ça, à savoir qemu et lxc ont bien évidemment droit à une mise à jour (respectivement 4.0.0 et 3.1). Pour LXC (les containers) je n’ai pas su trouver les améliorations. Pour qemu 4.0.0, on a droit à une majeure mais qui ajoute surtout la compatibilité vers de nouveaux matériels et de nouveaux flags CPU (pour des usecases bien précis).
  
Une plus grosse modif vient peut être de corosync, le composant qui permet de gérer une grosse partie du clustering, qui passe en version 3 avec _Kronosnet_. Ça, c’est très impactant. J’ai écris plusieurs articles sur le clustering de serveurs Proxmox avec des machines dédiées chez des cloud providers et j’étais souvent gêné par le fait que corosync utilise du multicast, systématiquement bloqué par les providers. Kronosnet utilise de l’unicast ce qui devrait énormément simplifier les futurs setups de clusters (AKA, plus obligatoirement besoin d’un VPN) !!!
  
Côté stockage, on passe de Ceph 12 vers Ceph 14 et de ZFS (on Linux) en 0.8.1 (encryption des pools + trim, support de ZFS dans l’UEFI)
  
## Les modifs internes
  
Voilà pour les mises à jour de packages. Maintenant, les features que j’ai hâte de tester. La plupart sont des améliorations de la GUI :

* Migration des VMs à chaud depuis l’interface, même si on est sur du local storage. On retrouve une promesse déjà présente en 5.x, qui marchait partiellement en ligne de commande, mais qui devrait être ENFIN disponible dans la GUI ([cf ce post sur le forum](https://forum.proxmox.com/threads/pve-5-4-live-migration-issue.55382/)).
* Améliorations au niveau du Wizard pour créer des clusters. On peut maintenant sélectionner plus facilement quelle(s) interface(s) doit être utilisée pour la communication Corosync. Une amélioration légère par rapport à ce qu’on pouvait faire en 5.4 avec tinc (article qui n’est jamais sorti car je ne l’avais pas terminé... oups). Dans tous les cas, c’est beaucoup plus simple que ce que [j’avais pu montrer en 5.2](/2018/06/05/creation-dun-cluster-de-virtualisation-proxmox-ve-5-2-x/) ou [en 5.0](/2017/08/29/faire-un-petit-cluster-proxmox-avec-2-machines-kimsufi/).
* Encore des améliorations pour gérer Ceph dans la GUI. Je ne peux pas trop en parler car je n’avais pas de machines suffisamment proches et puissantes pour monter un cluster Ceph sur mes machines Proxmox VE. Cependant, je pense tester dans les jours qui viennent, profitant du fait que les clusters sont plus simple à créer (donc à tester sur des machines temporaires chez Kimsufi par exemple).
* Possibilité de configurer les backups non plus par VM/container mais par pool entier (nice to have)
  
## Tu nous montres ?

Une fois de plus, je suis assez enthousiaste quant à cette nouvelle version, qui apporte plein de bonnes choses. Je vais très probablement faire des articles dans les semaines qui viennent sur le sujet, en premier lieu la migration de la 5.4 (sur laquelle je suis actuellement) vers la 6.0.

Wait and see !!
  
## Sources

* [La note d’annonce de la 6.0](https://forum.proxmox.com/threads/proxmox-ve-6-0-released.56000/)
* [La release note de la 6.0](https://pve.proxmox.com/wiki/Roadmap#Proxmox_VE_6.0)
* [Le changelog de qemu 4.0.0](https://wiki.qemu.org/ChangeLog/4.0)
* [L’article sur la sortie de proxmox 5.2](/2018/05/22/sortie-de-proxmox-ve-5-2-1-les-nouveautes/)
* [L’article sur la création d’un cluster sur PVE 5.2, 2 nodes seulement](/2019/10/11/un-cluster-proxmox-ve-avec-seulement-2-machines/)
* [L’article sur la création d’un cluster sur PVE 5.0, 2 nodes seulement](/2017/08/29/faire-un-petit-cluster-proxmox-avec-2-machines-kimsufi/)
