---
title: Proxmox - Tips and tricks
authors:
  - zwindler
type: post
date: 2022-08-22T06:30:00+02:00
excerpt: "Quelques tips sur Proxmox VE que j'ai accumulé au fil des ans"
url: /2022/10/22/proxmox-tips-tricks/
image: /2019/10/proxmox.png
categories:
  - Système
  - Virtualisation
tags:
  - ZFS
  - Proxmox VE
  - Let's Encrypt
  - tuning

---

## OK je reparle de Proxmox ;-)

Certains trolls velus (😘) m'ont reproché de trop parler de XenServer / XCP-ng / Xen Orchestra, ces derniers temps.

Pour leur faire plaisir (car que je suis quelqu'un de sympa, en vrai), voici donc un article qui parle de tous les petits trucs que je trouve cool dans Proxmox VE et qui ne sont (je pense) pas forcément connus des débutants.

Je ne parlerais donc pas des trucs de base comme le fait qu'on puisse piloter les upgrades depuis l'UI, que les backups sont intégrées (même s'il y a un backup server plus poussé aussi) ou le firewall depuis l'UI (que je n'ai pas utilisé en vrai), ou bien encore [la gestion des certificats Let's Encrypt pour l'UI](https://blog.zwindler.fr/2018/05/29/signez-la-console-proxmox-ve-avec-lets-encrypt-cest-encore-plus-trivial/).

![](/2022/08/backups.png)

C'est parti !

## Avoir un cluster de virtualisation open source

Un truc très fort avec Proxmox VE est quand même que vous disposez d'un OS open source, clé en main, disposant en plus d'un mécanisme de clustering "prod ready". Grand luxe !

Tout est géré par un cluster `corosync`. L'ajout des nodes se fait via l'interface graphique en quelques clics (ou via ligne de commande si vous êtes un foufou comme moi).

![](/2019/08/proxmox_ve_6_create_cluster.png)

Normalement, cette fonctionnalité est quand même réservée à un usage dans un LAN dédié. Mais j'ai quand même abondamment tordu la fonctionnalité pour la faire marcher, au fil des ans, chez des hébergeurs grand public, voire au travers d'Internet, dans des réseaux NATé, etc...

* [Cluster Proxmox VE, v6 cette fois ci !](https://blog.zwindler.fr/2019/08/20/cluster-proxmox-ve-v6-cette-fois-ci/)
* [Un cluster Proxmox VE en 5 minutes avec Ansible](https://blog.zwindler.fr/2019/07/22/proxmox-en-5-min-ansible-tinc/)
* [Un cluster Proxmox VE avec seulement 2 machines !](https://blog.zwindler.fr/2019/10/11/un-cluster-proxmox-ve-avec-seulement-2-machines/)

## Et avec un PRA !

Avec mon cluster Proxmox, j'ai aussi un plan de reprise d'activité (PRA). Les développeurs de Proxmox VE ont astucieusement tiré parti de la fonctionnalité de réplication asynchrone de ZFS pour périodiquement (par défaut toutes les 15 minutes) synchroniser des disques entre des machines distantes.

Note: [ZFS, j'en ai aussi beaucoup parlé](https://blog.zwindler.fr/recherche/?keyword=ZFS). 

Tout est prévu dans l'interface graphique, il n'y a rien à faire à part avoir un cluster Proxmox VE et du stockage ZFS, ça "juste marche".

![](/2022/08/zfs-replication.png)

## Les containers LXC

C'est littéralement LE TRUC que j'utilise le plus dans Proxmox VE. Je fais très peu de machines virtuelles KVM car je loue des machines très peu puissantes (et pas chères), pas capables de faire de la virtualisation (pas d'instructions VT-x sur les [Atom C2350](https://ark.intel.com/content/www/fr/fr/ark/products/77977/intel-atom-processor-c2350-1m-cache-1-70-ghz.html)).

Même si j'utilise tous les jours des containers de type "Docker" au travail, ce n'est pas ce que je cherche quand je monte des petites machines sur mon infra perso.

LXC est un bon compromis : j'ai le sentiment d'avoir une machine virtuelle (j'installe des OS, des packages, dépose mon application où je veux, ...) sans la lourdeur de la VM.

Les temps de boot sont quasiment instantanés, l'overhead CPU, surtout sur mes machines faiblardes, est très léger. Mais le plus important reste l'empreinte mémoire ridicule. J'ai plusieurs containers hébergeant des serveurs webs qui tournent avec moins de 128 Mo de RAM. Impossible avec une machine virtuelle KVM.

![](/2022/08/reverse.png)

> Exemple avec un reverse proxy nginx en frontal de plusieurs petits sites. Le container consomme quelques Mo.

En revanche, l'isolation est moins bonne (on partage un kernel donc forcément...). En termes de sécurité c'est moins bien, et on arrive parfois à des petits soucis comme j'ai pu en parler dans l'article [Jeedom dans un container LXC](https://blog.zwindler.fr/2021/10/04/jeedom-dans-un-container-lxc/).

Je ferai (un jour) un article dédié aux containers LXC tellement je trouve ça cool.

## Tuning ZFS

La croyance populaire veut que ZFS nécessite beaucoup de RAM pour fonctionner. C'est faux (sauf si vous activez la déduplication). 

Dans la documentation officielle de Solaris (les inventeurs de ZFS), on parle de 1 Go de RAM (dont 768 Mo pour le système).

> The minimum amount of memory needed to install a Solaris system is 768 MB. However, for good ZFS performance, use at least one GB or more of memory.
> - https://docs.oracle.com/cd/E18752_01/html/819-5461/gbgxg.html

Sauf que des fois, ZFS est un peu trop gourmand, par défaut. C'est typiquement le cas sur mes Atom qui n'ont que 4 Go de RAM, sur lesquels ZFS croque 50% de la RAM pour son cache ARC.

On tune ça avec une simple commande :

```bash
#Restrict to 512MB
echo 536870912 |sudo tee -a /sys/module/zfs/parameters/zfs_arc_max

#Restrict to 4GB
echo 4294967296 |sudo tee -a /sys/module/zfs/parameters/zfs_arc_max
```

Plus de tips sur le tuning de ZFS sont disponibles sur ce post de [admin magazine](https://www.admin-magazine.com/mobile/HPC/Articles/Tuning-ZFS-for-Speed-on-Linux).

## Monter des disques LXC/QEMU avec ZFS

Un truc un peu déstabilisant quand on passe sur ZFS comme gestionnaire de stockage pour son cluster Proxmox VE est qu'on ne voit plus les disques comme des fichiers (.qcow2) comme avant.

Rappelez-vous, ZFS est aussi un gestionnaire de stockage, pas juste un filesystem.

Pour accéder à vos disques de machines virtuelles, il faut aller chercher dans les fichiers spéciaux dans /dev. Par exemple pour la VM avec l'ID 100 :

```bash
ls -l /dev/zvol/rpool/vm-100*
lrwxrwxrwx 1 root root 10 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0 -> ../../zd16
lrwxrwxrwx 1 root root 12 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0-part1 -> ../../zd16p1
lrwxrwxrwx 1 root root 12 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0-part2 -> ../../zd16p2
lrwxrwxrwx 1 root root 12 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0-part5 -> ../../zd16p5
```

Note: on peut d'ailleurs directement monter les partitions dans notre hyperviseur avec un bête `mount`. Avouez que c'est plus pratique à monter qu'un disque qcow2 nan ?

Pour accéder à vos disques de containers LXC, c'est encore plus simple, ils sont à la racine de votre pool ZFS. Par exemple pour le container LXC avec l'ID 201 :

```bash
ls /rpool/subvol-201-disk-0/
bin   dev  home  lib64	     media  opt   root	sbin	 srv  tmp  var
boot  etc  lib	 lost+found  mnt    proc  run	selinux  sys  usr
```

## Télécharger les ISOs directement depuis l'UI

Là, c'est vraiment du "nice to have" mais j'aime bien ce genre de fonctionnalités pour aider l'admin: vous pouvez directement télécharger vos images ISO pour installer vos machines virtuelles directement depuis la console Web.

![](/2022/08/download-iso.png)

Et de la même manière, vous pouvez aussi télécharger les images de containers LXC depuis une URL ou depuis la base d'images déjà accessibles depuis Proxmox VE (la section "système" me semble être [une sous-sélection des images officielles disponibles sur le site de LXD](http://uk.lxd.images.canonical.com//meta/1.0/index-system)).

![](/2022/08/ct-download.png)

## Optimisation de perf pour les VMs

J'avais fait un article pour parler des optimisations que j'avais pu faire pour les machines virtuelles sous Proxmox VE. Le titre de l'article cite pfsense mais c'est applicable à tous les OS en réalité.

[Optimisation de PFsense dans Proxmox VE](https://blog.zwindler.fr/2020/07/06/optimisation-de-pfsense-dans-proxmox-ve/)

L'optim consistant à décocher "Use tablet for pointer" est vraiment hyper utile et marche très souvent si vous remarquez un usage CPU idle anormal sur vos VMs.

![](/2020/05/ubuntu_cpu_tablet.png)

## Automatisation

Si vous êtes fans d'infrastructure as code (as you should), sachez qu'il existe :
* [un module Ansible (community) pour gérer vos instances et créer des VMs](https://docs.ansible.com/ansible/latest/collections/community/general/proxmox_module.html)
* [des providers terraform pour gérer les VMs et les containers LXC](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)

J'utilise en prod les modules Ansible, ce qui me permet de générer à la fois une VM puis d'installer des choses dedans avec mes playbooks. Hyper utile.

Je ferai probablement un article pour le provider terraform car il me fait de l'oeil (mais du coup, dur de chaîner l'install des logiciels dans la VM après instanciation).

## Monitoring

Enfin, si vous avez déjà une infra Prometheus, sachez qu'il existe plusieurs exporters pour avoir de jolis graphes de vos Proxmox. Je les avais testés à l'occasion de cet article - [Proxmox VE + Prometheus = <3](https://blog.zwindler.fr/2020/01/06/proxmox-ve-prometheus/).

Sachez que vous pouvez aussi directement brancher depuis la console votre cluster sur des TSDB de type InfluxDB ou Graphite (pas encore testé mais pourquoi pas :D).

![](/2022/08/influx.png)

## Fin de cet article

A plus de 9000 signes, je pense qu'il faut que j'arrête là pour ce premier article sur les trucs que je trouve cool et les astuces que j'utilise souvent sur Proxmox VE.

Cependant, je ne m'interdis pas d'en écrire un autre plus tard, si jamais je retrouve assez de choses à dire.

En connaissez-vous d'autres que vous voudriez partager ? Est-ce que vous avez envie que je creuse un point en particulier ?
* InfluxDB comme metrics server ? 
* Le provider Terraform ? 
* LXC ?
