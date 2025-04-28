---
title: Migration CentOS + KVM vers Proxmox VE
authors:
  - zwindler
type: post
date: 2015-11-21T11:30:53+00:00
url: /2015/11/21/migration-centos-kvm-vers-proxmox/
image: /2015/10/Logo-ProxmoxVE.png
categories:
  - Système
  - Virtualisation
tags:
  - debian
  - KVM
  - LXC
  - mdadm
  - migration
  - OpenVZ
  - Proxmox VE
  - QCOW2
  - QEMU
  - raw
  - VMDK
  - ZFS

---
Juste après avoir sorti un article qui traite de la migration de KVM/Ubuntu vers KVM/RHEL, voilà que je migre ENCORE pour ProxMox !?! Mais c’est parce qu’en fait j’avais juste beaucoup de retard sur ces précédents articles ;-).

## Présentation de la solution

Cette fois ci, il s’agit donc de vous donner les clés pour migrer sans stress votre serveur sous KVM (Ubuntu, Debian, RHEL, Whatever ...) vers Proxmox VE.

Pour ceux qui ne connaissent pas Proxmox VE, il s’agit d’une distribution Debian adaptée pour faire de la virtualisation full (qemu/KVM) et par conteneur (anciennement via openVZ, maintenant via LXC). LE gros plus de la solution, c’est l’interface graphique et l’installation clé en main d’un hyperviseur disposant de fonctionnalités qu’on retrouve chez les grands du marché.

Pour être honnête, j’étais très content de mon KVM pour ce qui est des performances et de la consommation de ressources (point faible d’un ESXi à la maison), mais pas du tout satisfait des manières que j’avais pour l’administrer. J’ai testé plusieurs interfaces graphiques (web ou pas) sans jamais en trouver une à ma convenance (même les usines à gaz comme oVirt, la base de RedHat Entreprise Virtualisation).

## Installation

Comme beaucoup d’hyperviseur clés en main, l’étape d’installation est particulièrement soignée pour être simple et rapide. On récupère un ISO, [on le copie sur une clé USB](https://pve.proxmox.com/wiki/Install_from_USB_Stick), on boot dessus. Quelques écrans et moins de 5 minutes plus tard le serveur reboot et on nous invite à nous connecter à la console web.

Ah ! Ça fait du bien !

![L’interface Web, bien qu’un peu austère, est relativement intuitive. On ne trouve pas tous les menus du premiers coup, mais on s’habitue vite](/2015/10/02_proxmox_kvm.png)

La première chose à faire est de créer des pools de stockages (un _local_ est créé par défaut). On peut choisir s’il s’agit d’un pool dédié aux VMs, à la sauvegarde, aux fichiers ISOs. C’est assez pratique.

## RAID logiciel MDADM

Sous ProxMox, le RAID logiciel via MDADM Linux **n’est pas supporté** (voir [wiki officiel](https://pve.proxmox.com/wiki/Software_RAID)). Seuls les RAID Hardware sont supportés.

Dans l’interface, vous ne pourrez donc pas le configurer (ni même pendant la phase d’installation). Depuis la version 3.4, vous pouvez cependant installer ProxMox sur un espace ZFS, avec notamment tous les niveaux de RAID/RAIDZ que vous souhaitez. Mais mon petit doigt me dit qu’il s’agit probablement de [ZFSonLinux](/recherche/?keyword=zfsonlinux) et j’ai déjà donné ;-).

Cette absence de RAID logiciel est une des raisons pour lesquels j’étais initialement réfractaire à ProxMox par rapport à un linux classique avec qemu. Cependant, ce n’est pas parce ce n’est pas supporté que vous ne pouvez pas le faire ! Après tout, il s’agit d’une Debian customisée donc il n’y a rien qui vous retient.

Voici deux articles que j’ai sélectionnés qui vous guideront pas à pas pour le faire (à vos risques et périls, comme d’habitude).

* [www.mbardot.com/installation-de-proxmox-ve-en-raid1-logiciel/](http://www.mbardot.com/installation-de-proxmox-ve-en-raid1-logiciel/)
* [kbdone.com/proxmox-ve-3-2-software-raid/](http://kbdone.com/proxmox-ve-3-2-software-raid/)

[Edit]

**Attention** : la partie amorçage ne fonctionnera pas si vous avez un boot EFI (Proxmox 4+). Il faudra trouver une autre technique. Vous pouvez lire cet article qui explique comment  faire en général sur Debian :

* [www.debian-fr.org/t/raid-logiciel-linux-et-amorcage-en-uefi/64655](https://www.debian-fr.org/t/raid-logiciel-linux-et-amorcage-en-uefi/64655)

La partie du tutoriel traitant de lvm pour ProxMox (3ème partition) contenant le / et les données importantes peut par contre bien être suivie. C’est vraiment uniquement le boot EFI qui va nous enquiquiner.

[/Edit]

## Migrer ses VM existantes

Nous voici maintenant dans le vif du sujet. Selon la [documentation officielle](https://pve.proxmox.com/wiki/Migration_of_servers_to_Proxmox_VE#KVM_to_Proxmox_VE_.28KVM.29), voici ce qu’on doit faire pour migrer une machine KVM dans ProxMox.

![Ouais, d’accord... mais un peu plus de détails ? Non ?](/2015/10/01_proxmox_kvm.png)


D’abord, on nous dit de créer une nouvelle machine virtuelle. Jusque là tout va bien. On lui affecte les options par défaut et pas de CD-ROM dans le lecteur.

![](/2015/10/03_proxmox_kvm.png)


![](/2015/10/04_proxmox_kvm.png)

Ensuite ça se gâte. En effet, on veut supprimer le disque dur par défaut puis ajouter notre disque importé de l’ancien système KVM. On va donc dans les propriétés de la machine virtuelle nouvellement créée.

![](/2015/10/06_proxmox_kvm.png)

![Mais... Mais... Il est où le bouton « Parcourir »?](/2015/10/07_proxmox_kvm.png)

Et là, blague... Pas de bouton « Parcourir » pour aller chercher notre disque virtuel à importer !

On peut trouver la solution assez vite sur les forums, mais c’est quand même assez frustrant, surtout quand on voit la malheureuse ligne donnée dans le wiki en guise de procédure...

Dans [ce thread](http://forum.proxmox.com/threads/4227-How-to-add-existing-disk) et [ce thread](http://serverfault.com/questions/441310/proxmox-uploading-disk-image), on apprend que pour chaque banque de données, chaque VM dispose d’un dossier dans lequel il faut déposer le disque. Dans **le bon** dossier ! Par exemple :

* pour le stockage local, la VM avec l’id _100_ a un dossier **/var/lib/vz/images/100/**
* pour le stockage NFS nommé de manière originale **NFS_VM**, il y a un dossier **/mnt/pve/NFS_VM/images** avec des sous dossiers pour chaque VM qui dispose d’un disque sur ce partage NFS.

A partir de là, on copie donc nos fichiers dans les bons dossiers en fonction de ce qu’on veut faire. Dans le cas présent je copie les fichiers sur le stockage local, dans un premier temps.

```
cp MaVM.qcow2 /var/lib/vz/images/100/
```


Une fois que c’est fait, les disques apparaissent dans la page spécifique de la banque de données.

![](/2015/10/08_proxmox_kvm.png)

Mais le disque virtuel n’apparaît toujours pas dans la machine virtuelle. Il faut aller éditer à la main le fichier de configuration de la VM, situé dans **/etc/pve/nodes/xxx/qemu-server/[VMID].conf**.

```
vi /etc/pve/nodes/xxx/qemu-server/100.conf
bootdisk: ide0;
cores: 2
ide2: none,media=cdrom
memory: 1024
name: bck-xxx-xxx
net0: e1000=7A:FA:D6:DC:06:70,bridge=vmbr0
numa: 0
ostype: l26
smbios1: uuid=ae5d66d6-724f-46cd-a85b-24eda7b9ecec
sockets: 1
ide0: local:100/xxx-xxx-flat.vmdk
ide1: local:100/xxx-xxx_1-flat.vmdk
unused0: local:100/vm-100-disk-1.vmdk
unused1: local:100/vm-100-disk-2.qcow2,size=32G
```


A partir de là, les disques apparaissent dans la VM au niveau de ide0 et ide1 dans mon cas. On progresse.

### Cas des disques QCOW2

Dans le cas des disques QCOW2 (et les QCOW2 uniquement, pas les RAW), il sera nécessaire d’ajouter également un argument « taille » du disque, sans quoi la VM peut ne pas démarrer. Il faudra rajouter **en fin de ligne** la taille du disque (**xxx,size=yyG**).

Astuce : si vous ne la connaissez pas, supprimez le disque de la VM (qui passera en inutilisé), puis éditer le (edit) pour l’ajouter à nouveau. Le fichier de configuration devrait se recréer avec les bonnes options automatiquement.

![](/2015/10/09_proxmox_kvm.png)

### Cas des disques RAW

A l’inverse, la taille du disque en argument dans la configuration d’une VM pour une image RAW ne semble pas nécessaire.

Par contre, pour les disques raw, il faut savoir qu’il faut ABSOLUMENT les nommer en « .raw » pour qu’ils soient visibles dans la liste des disques (mes disques provenant de KVM étaient nommés par défaut en « .img »).

![](/2015/10/local.png)

Si vous ne les renommez pas, les disques seront présents dans la VM, mais elle refusera de démarrer avec l’erreur suivante :

> unable to parse volume filename

Il faudra prendre soin de tous les renommer, puis de modifier la configuration de la machine virtuelle en tenant compte de cette modification.
