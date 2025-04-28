---
title: 'Les erreurs que j’ai rencontré en bidouillant mon ProxMox'
authors:
  - zwindler
type: post
date: 2015-12-05T11:30:50+00:00
url: /2015/12/05/erreurs-rencontrees-bidouillage-proxmox/
image: /2015/10/Logo-ProxmoxVE.png
categories:
  - Stockage
  - Virtualisation
tags:
  - 'command failed: exit code 1'
  - convert
  - log
  - Proxmox VE
  - QCOW2
  - qemu-img
  - raw
  - VMDK

---
Pelle mêle, quelques erreurs que j’ai rencontrés lorsque j’ai importés mes machines virtuelles KVM (elles même importées de VMware ESXi) vers Proxmox VE, puis quand j’ai bidouiller pour avoir mon RAID logiciel, et enfin quelques « protips » dénichées sur le net.

## Erreur « start failed: command [...] failed: exit code 1 »

Lorsqu’on migre un système, on se précipite un peu des fois. Dans mon cas, j’ai migré des disques virtuels de KVM vers ProxMoxVE et j’ai rencontré des erreurs bêtes (droits, mauvais format, ...).

Cependant, on ne peut pas dire que ProxMox m’ait beaucoup aidé dans la résolution de ces bêtes erreurs d’inattention.

```
Oct 5 00:40:38 mypveserver pvedaemon[10645]: start failed: command '/usr/bin/systemd-run --scope --slice qemu --unit 100 -p 'CPUShares=1000' /usr/bin/kvm -id 100 -chardev 'socket,id=qmp,path=/var/run/qemu-server/100.qmp,server,nowait' -mon 'chardev=qmp,mode=control' -vnc unix:/var/run/qemu-server/100.vnc,x509,password -pidfile /var/run/qemu-server/100.pid -daemonize -smbios 'type=1,uuid=ae5d66d6-724f-46cd-a85b-24eda7b9ecec' -name myvm100 -smp '2,sockets=1,cores=2,maxcpus=2' -nodefaults -boot 'menu=on,strict=on,reboot-timeout=1000' -vga cirrus -cpu kvm64,+lahf_lm,+sep,+kvm_pv_unhalt,+kvm_pv_eoi,enforce -m 1024 -k fr -device 'pci-bridge,id=pci.2,chassis_nr=2,bus=pci.0,addr=0x1f' -device 'pci-bridge,id=pci.1,chassis_nr=1,bus=pci.0,addr=0x1e' -device 'piix3-usb-uhci,id=uhci,bus=pci.0,addr=0x1.0x2' -device 'usb-tablet,id=tablet,bus=uhci.0,port=1' -device 'virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x3' -iscsi '&amp;amp;lt;a href="http://initiator-name=iqn.1993-08.org.debian:01:24f499f0efa%27" target="_blank" rel="nofollow"&amp;amp;gt;initiator-name=iqn.1993-08.org.debian:01:24f499f0efa'&amp;amp;lt;/a&amp;amp;gt; -drive 'if=none,id=drive-ide2,media=cdrom,aio=threads' -device 'ide-cd,bus=ide.1,unit=0,drive=drive-ide2,id=ide2,bootindex=200' -drive 'file=/var/lib/vz/images/100/myvm100-flat.vmdk,if=none,id=drive-ide0,format=vmdk,cache=none,aio=native,detect-zeroes=on' -device 'ide-hd,bus=ide.0,unit=0,drive=drive-ide0,id=ide0,bootindex=100' -netdev 'type=tap,id=net0,ifname=tap100i0,script=/var/lib/qemu-server/pve-bridge,downscript=/var/lib/qemu-server/pve-bridgedown' -device 'e1000,mac=7A:FA:D6:DC:06:70,netdev=net0,bus=pci.0,addr=0x12,id=net0,bootindex=300'' failed: exit code 1
```


Ah oui ok... Cool. J’ai la commande qui plante complète, mais pas la raison de l’échec. Le seul truc intéressant en fait.

La première chose que tout le monde de vous dis sur les forums c’est de vérifier que KVM fonctionne bien correctement. Et pour le faire on vous propose de lire le contenu du dmesg. Soit.

```
dmesg |grep kvm
[ 7007.511690] kvm: zapping shadow pages for mmio generation wraparound
[ 7007.512070] kvm: zapping shadow pages for mmio generation wraparound
```


Voici un exemple de ce que vous pourrez voir si vous avez oublié d’activer la virtualisation

```
dmesg | grep kvm
[    5.079366] kvm: disabled by bios
[    5.112223] kvm: disabled by bios
[    5.148210] kvm: disabled by bios
[    5.172292] kvm: disabled by bios
```


En fait, la solution la plus simple pour avoir plus de détails, ce n’est pas les logs, ce n’est pas le message d’erreur de 3km qu’on retrouve dans l’interface réseau. Le plus simple, c’est de démarrer la VM en ligne de commande.

```
qm start 100
```


Vous retrouverez la même erreur, mais aussi le VRAI message contenant la vraie erreur qui vous a fait. Dans mon cas, j’avais des erreurs de permissions et des erreurs de type de disque (RAW vs QCOW2). Merci Proxmox VE.

## **Lignes de commandes qemu-img**

Si vous hésitez entre vmdk, vdi, qcow2 ou raw, ou ne savez pas la taille réelle du fichier, la commande _qemu-img info fichier.xxx_ vous permettra d’obtenir des informations sur tous les disques virtuels dans les principaux formats qui existent sur le marché.

```
qemu-img info /var/lib/vz/images/100/xxx-xxx.yyy
image: /var/lib/vz/images/100/xxx-xxx.yyy
file format: raw
virtual size: 16G (17179869184 bytes)
disk size: 8.7G
```


Si c’est un VMDK, vous pouvez le convertir dans un format compatible avec KVM avec la commande suivante :

```
qemu-img convert -f vmdk image_vmware.vmdk -O raw fichier_sortie.raw 
#ou
qemu-img convert -f vmdk image_vmware.vmdk -O qcow2 fichier_sortie.qcow2
```


## Récupérer la configuration d’un serveur HS (mais pas son disque)

En fait le serveur n’était pas vraiment HS mais ça marchera aussi si c’est votre cas.

Disons que moi, c’est plutôt que j’ai flingué la zone de boot EFI en essayant de créer mon RAID1 MDADM.

Le serveur ne voulait plus booter et comme j’ai déjà perdu beaucoup de temps avec l’UEFI en général (surtout avec Windows 8) j’ai préféré réinstaller l’OS sur un autre disque et n’avoir en RAID1 que mes VMs (disques virtuels). Tant pis pour le boot.

Sauf que lorsque j’ai remonté le serveur, je comptais aussi récupérer la configuration du serveur en même temps. Je savais que les fichiers se trouvaient sur **/etc/pve/[nodename]/**.J’ai donc remonté le LV « root » de la précédent installation dans /oldroot.

Et là, **damned** ! Rien de rien. Répertoire vide.

```
root@[nodename]:/oldroot/etc/pve# ls
root@[nodename]:/oldroot/etc/pve#
```


En fait c’est « normal ». Pour se simplifier la conception du cluster de plusieurs machines ProxMox, les développeurs ont imaginé _**pmxcfs**_, un mélange de cluster corosync, de base de données SQLite et de montage fuse en RAM pour stocker la configuration des serveurs. Malin !

* [Proxmox Cluster File System (pmxcfs)](https://pve.proxmox.com/wiki/Proxmox_Cluster_File_System_(pmxcfs))

Sauf que du coup, difficile de lire le contenu de la base SQLite pour en extraire la configuration de nos VMs. On pourrait requêter le moteur mais bon... c’est fatiguant.

Heureusement, dans le cas d’un serveur que l’on réinstaller, on peut (de manière certes un peu barbare) écrabouiller la base SQLite de notre nouvelle installation et la remplacer par l’ancienne base. On retrouve ainsi l’ensemble des éléments de configuration du serveur avant incident.

La solution est décrite sur [solaris-cookbook.eu][2], probablement à l’aide des informations filtrées par le site de ProxMox (cité juste avant).

```
root@[nodename]:/etc/pve/nodes/[nodename]/qemu-server# service pve-cluster stop #on coupe le cluster pour pouvoir manipuler la base sans accès concurrents
root@[nodename]:/etc/pve/nodes/[nodename]/qemu-server# locate config.db
/oldroot/var/lib/pve-cluster/config.db
/var/lib/pve-cluster/config.db
root@[nodename]:/etc/pve/nodes/[nodename]/qemu-server# mv /var/lib/pve-cluster/config.db /var/lib/pve-cluster/config.db.new #on garde la nouvelle base au cas où
root@[nodename]:/etc/pve/nodes/[nodename]/qemu-server# cp /oldroot/var/lib/pve-cluster/config.db /var/lib/pve-cluster/config.db
root@[nodename]:/etc/pve/nodes/[nodename]/qemu-server# service pve-cluster start #on redémarre et on voit si ça a marché
root@[nodename]:/etc/pve/nodes/[nodename]/qemu-server# service pve-cluster status
â pve-cluster.service - The Proxmox VE cluster filesystem
Loaded: loaded (/lib/systemd/system/pve-cluster.service; enabled)
Active: active (running) since Fri 2015-11-13 00:30:53 CET; 3s ago
Process: 2727 ExecStartPost=/usr/bin/pvecm updatecerts --silent (code=exited, status=0/SUCCESS)
Process: 2723 ExecStart=/usr/bin/pmxcfs $DAEMON_OPTS (code=exited, status=0/SUCCESS)
Main PID: 2725 (pmxcfs)
CGroup: /system.slice/pve-cluster.service
ââ2725 /usr/bin/pmxcfs
```


## Quorum bloqué

J’ai fais un article dédié pour ce problème particulier :  
[[Tutoriel] Démonter proprement un cluster Proxmox VE][3]

 [1]: https://pve.proxmox.com/wiki/Proxmox_Cluster_file_system_%28pmxcfs%29
 [2]: http://www.solaris-cookbook.eu/linux/linux-ubuntu/proxmox-3-x-debian-7-0-backup-and-restore-recover-proxmox-server-configuration/
 [3]: /2017/09/19/tutoriel-demonter-proprement-cluster-proxmox-ve/
