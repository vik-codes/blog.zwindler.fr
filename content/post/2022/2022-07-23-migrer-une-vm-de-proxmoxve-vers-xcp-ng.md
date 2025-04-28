---
title: 'Migrer une VM de Proxmox VE vers XCP NG'
authors:
  - zwindler
type: post
date: 2022-07-24T12:00:00+00:00
excerpt: "Tutoriel pour migrer une VM QEMU de Proxmox VE vers XCP-NG"
url: /2022/07/24/migrer-une-vm-de-proxmoxve-vers-xcp-ng
image: /2022/07/pve-to-xcpng.jpg
categories:
  - Virtualisation
tags:
  - LXC
  - QEMU
  - online
  - Proxmox
  - pve
  - XCP-NG
  - Xen
  - XenServer
---

## Retour de la virtualisation

Ca fait quelques mois que je n'ai pas parlé de virtualisation donc forcément, ça me démange un peu ;). 

Si vous suivez ce blog depuis quelque temps, vous savez [pourtant que j'ai pas mal roulé ma bosse avec Proxmox VE](https://blog.zwindler.fr/recherche/?keyword=proxmox), un OS clé en main de virtualisation KVM (mais aussi de containerisation LXC, on en parle tellement peu). Sans aller jusqu'à dire que j'en ai fait le tour (a-t-on jamais fait le tour d'une techno ?), je commence à manquer de choses à tester avec mon lab perso.

L'an dernier, j'ai discuté avec les équipes de [Vates SAS](https://vates.fr/) à [OSXP 2021](/2021/11/10/open-source-experience-2021-recap/), une boite qui publie une autre distribution open source dédiée à la virtualisation : [XCP-NG](https://xcp-ng.org/) (mais basée sur XenServer).

J'en avais déjà entendu parler sur Twitter (coucou Cécile) donc j'étais un peu curieux. Mais j'étais aussi un peu sceptique, [ma dernière expérience de XenServer datant de 2011](/2011/02/15/creation-dun-template-centos-5-5-pour-xenserver-5-6/).

![Cécile (Ataxya Network) tweetant en 2021 qu'elle testait XCP NG](/2022/07/ataxya_xcp-ng.png)

Dans cet article, je ne vais pas rentrer dans une comparaison des fonctionnalités ni des avantages et inconvénients de XCP-NG par rapport à Proxmox VE. Je n'ai pas encore assez testé pour me faire une idée pertinente (ça viendra). 

En revanche, je peux vous donner un premier avant goût de la solution via un petit tuto pour vous aider à migrer des VMs de l'un à l'autre, si jamais l'envie vous prend de tester.

## Prérequis

Dans ce tutoriel, je pars du principe que vous avez :
* d'un côté, une machine virtuelle QEMU, hébergée par un Proxmox VE, à copier/migrer
* de l'autre, un serveur sous XCP-NG, dans le même LAN, gérée par [XenOrchestra](https://xen-orchestra.com/?gclid=Cj0KCQjwuO6WBhDLARIsAIdeyDJ5Bd1q445B3W7jxWuy_culllyw-WqnU5yu7BhAD9KgOeXoykv_o4gaArRqEALw_wcB#!/xo-home) (l'équivalent du [vCenter](https://blog.zwindler.fr/recherche/?keyword=vcenter) de VMware, pour ceux à qui ça parle)

Note: sauf erreur de ma part, on a pas de solution clé en main pour migrer un container LXC vers XCP-NG (même si XenServer gère les containers Xen, aussi appelé virtualisation PV). Trouver comment migrer ces workloads LXC sera peut-être l'objet d'un prochain article.

![](2022/07/lxc-to-xcpng.png)

Pour le reste du tutoriel, on va grosso modo suivre [la documentation officielle disponible ici](https://xcp-ng.org/docs/migratetoxcpng.html#from-kvm-libvirt), mais avec quelques modifs et surtout un peu plus de détails.

## Option ZFS

**Note:** J'installe mes serveurs Proxmox VE avec ZFS comme stockage. Ca a plein d'avantages, notamment celui de me donner la possibilité de faire, à peu de frais, un PRA avec une réplication asynchrone des machines virtuelles de mon cluster. Cela induit par contre une petite difficulté complémentaire (vous allez voir c'est léger). **Vous pouvez sauter cette étape si vous n'utilisez pas ZFS.**

Pour rappel (je ferai aussi un article dédié à ça), avec ZFS j'ai 2 types de disques.

```console
# zfs list
NAME                      USED  AVAIL     REFER  MOUNTPOINT
rpool                     213G  15.9G      112K  /rpool
rpool/ROOT               6.32G  15.9G       96K  /rpool/ROOT
rpool/ROOT/pve-1         6.32G  15.9G     6.32G  /
rpool/data               2.84G  15.9G     2.84G  /rpool/data
rpool/subvol-201-disk-0  3.43G  4.57G     3.43G  /rpool/subvol-201-disk-0
rpool/subvol-301-disk-0   604M  15.9G      604M  /rpool/subvol-301-disk-0
rpool/vm-100-disk-0      3.79G  15.9G     3.79G  -
rpool/vm-213-disk-0       184G   148G     38.2G  -
```

Des disques de type "Filesystem" qui sont directement montés à la racine de mon espace de stockage ZFS (chez moi /rpool, mais on a aussi `/tank` comme convention chez les aficionados de ZFS) pour les containers LXC.

```console
# zfs get type rpool/subvol-301-disk-0
NAME                     PROPERTY  VALUE       SOURCE
rpool/subvol-301-disk-0  type      filesystem  -
# zfs get mountpoint rpool/subvol-301-disk-0
NAME                     PROPERTY    VALUE                     SOURCE
rpool/subvol-301-disk-0  mountpoint  /rpool/subvol-301-disk-0  default

```

Pour les VMs KVM/QEMU en revanche, je ne peux pas directement trouver un fichier toto.raw ou toto.qcow2 dans l'arborescence `/rpool`. Côté ZFS, ces volumes sont des volumes de type "volume" (lol). 

Mais c'est un détail, car c'est presque encore plus facile puisqu'on peut aller directement dans `/dev/zvol/rpool` et les retrouver en tant que "special file" dans /dev.

```console
ls -l /dev/zvol/rpool/vm-100*
lrwxrwxrwx 1 root root 10 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0 -> ../../zd16
lrwxrwxrwx 1 root root 12 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0-part1 -> ../../zd16p1
lrwxrwxrwx 1 root root 12 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0-part2 -> ../../zd16p2
lrwxrwxrwx 1 root root 12 Jul 23 02:00 /dev/zvol/rpool/vm-100-disk-0-part5 -> ../../zd16p5
```

Dans l'étape suivante, `/dev/zvol/rpool/vm-100-disk-0` remplacera donc notre image disque "input" (*toto.img*).

## Générer un VHD

Souvent sous Proxmox, vous allez avoir des disques au format RAW ou au format QCOW2.

Dans les deux cas, XCP-NG n'accepte pas ces formats. Heureusement, l'utilitaire `qemu-img`, inclus dans notre distribution de Proxmox VE sait faire les conversions.

Dans le cas d'un disque RAW :

```console
qemu-img convert -f raw toto.img -O vpc toto.vhd
```

Dans le cas d'un disque QCOW2 :

```console
qemu-img convert -f qcow2 toto.qcow2 -O vpc toto.vhd
```

## Avant d'importer le VHD dans XCP-NG

La partie un peu moins "fun" de la procédure est qu'on doit faire une partie des actions en GUI (si on suit la doc, mais je *teaserai* qu'on peut faire mieux en fin d'article).

La première chose qu'on va devoir faire, c'est aller dans la WebUI Xen Orchestra pour retrouver notre espace de stockage et créer manuellement un disque.

Il faut aller retrouver la liste de nos espaces de stockages (le plus simple, c'est de passer par "home"), puis, dans cet espace, créer un nouveau disque. Prenez garde à le créer de la bonne taille, en faisant attention à la différence Go/Gio. La documentation officielle conseille d'ajouter 1 Go de marge pour éviter ce genre de problématiques, mais je n'en ai pas eu besoin lors de mes tests.

![](/2022/07/xo_storage.png)
![](/2022/07/xoa_create_disk.png)

Note: chaque disque et chaque "datastore" a son propre UUID. Ici, j'ai souligné en rouge celui du datastore "Local", il nous servira plus tard (quand on passe la souris dessus, XOA nous propose de le copier dans le presse-papier).

Une fois le disque créé à la bonne taille, on récupère son UUID aussi.

## VHD vers XCP-NG

Maintenant qu'on a d'un côté un VHD valide, et de l'autre un disque dur virtuel vide prêt à accueillir les données, on peut se lancer !

On envoie le VHD sur le serveur XCP-NG (via `scp` ou un montage NFS, par exemple) et on se connecte dessus en SSH.

Si on est pas confiant, on peut tester que le VHD est valide sur XCP-NG grâce à l'utilitaire suivant :

```console
# vhd-util check -n /nfs/toto.vhd 
    /nfs/toto.vhd is valid
```

Ensuite, on utilise le binaire `xe` qui permet d'interagir en CLI avec XCP-NG pour lancer l'import :

```console
# xe vdi-import filename=/nfs/toto.vhd format=vhd --progress uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
    [|] ######################################################> (100% ETA 00:00:00)
```

On aura évidemment remplacé le paramètre *uuid=aaaa* par l'UUID du disque virtuel, que je vous ai demandé de récupérer plus tôt !

## Créer la VM

Normalement, à l'issue de l'opération, on a un disque tout beau tout propre. La dernière étape est de créer une VM et à lui attacher ce disque.

Là encore, on peut repartir de "Home" puis aller dans le menu VM.

![](/2022/07/xoa_create_vm1.png)
![](/2022/07/xoa_create_vm2.png)

Note: pour passer le menu de création de VM, il faut impérativement choisir soit ISO/DVD ou PXE dans **Install settings**, sinon CREATE est grisé. J'ai également supprimé le disque par défaut proposé par le wizard (puisqu'on va lui en attacher un) et dans **Advanced**, j'ai décoché **Boot VM after creation** puisque de toute façon je dois lui attacher le disque avant de booter.

Une fois créé, on clique sur la VM pour lui attacher le disque qu'on a importé.

![](/2022/07/xoa_attach_disk.png)

On peut maintenant booter la VM !

Lors du redémarrage, la seule chose que j'ai eu à changer était la configuration réseau, un peu différente entre mon cluster Proxmox VE et mon lab XCP-NG, ainsi que le nom d'interface qui était différent suite au passage à Xen (ens18 => eth0).

J'ai également ajouté le "Management agent" pour bénéficier d'infos dans l'UI (et probablement d'autres trucs chouettes que je n'ai pas encore exploré).

## Conclusion

Voilà pour ces premiers pas avec XCP-NG. Comme vous avez pu le constater, l'opération nécessite plusieurs étapes, dont certaines peuvent être améliorées (notamment l'automatisation de certaines tâches côté XCP-NG grâce à l'API, on en reparlera, car j'ai déjà quelques résultats).

Cependant, ça permet déjà de se faire une première impression et de se familiariser avec les menus. 

Dans les semaines qui viennent, je vais continuer de jouer avec, histoire de me faire une opinion un peu plus construite de XCP-NG (notamment par rapport à ce que je fais avec Proxmox). S'il y a des points que vous voulez que je creuse en particulier, n'hésitez pas à me "ping" sur les divers réseaux sociaux pour m'en parler.

D'ici là, have fun :)
