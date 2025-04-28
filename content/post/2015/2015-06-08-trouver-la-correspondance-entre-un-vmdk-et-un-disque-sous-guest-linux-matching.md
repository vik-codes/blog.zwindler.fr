---
title: Trouver la correspondance entre un VMDK et un disque sous guest Linux (matching)
authors:
  - zwindler
type: post
date: 2015-06-08T21:11:16+00:00
url: /2015/06/08/trouver-la-correspondance-entre-un-vmdk-et-un-disque-sous-guest-linux-matching/
image: /2015/06/00_match_vmdk.png
categories:
  - Stockage
  - Système
  - Virtualisation
tags:
  - CentOS
  - Linux
  - lsscsi
  - match
  - RHEL
  - uudi
  - VMDK
  - VMware

---
Si vous avez déjà eu à supprimer un disque sur une machine virtuelle de production, vous vous êtes certainement demandé comment être **sûr** que vous ne supprimiez pas le mauvais disque (!).  
Idéalement, j’aurai voulu récupérer l’UUID du disque, mais je n’ai pas trouvé comment faire « matcher » l’UUID du disque obtenu dans Linux (dans /dev/disk/by-uuid par exemple) avec les valeurs disponibles dans dans les fichiers .vmdk.

A priori, Linux numérote par défaut les disques en fonction de l’ordre dans lequel sont les contrôleurs SCSI et les disques sur ces contrôleurs. Mais bon... ça ne me parait pas suffisant.

En fait, on peut corréler cette information avec les informations fournies par le soft lsscsi.

```
yum install lsscsi
Loaded plugins: katello, product-id, security, subscription-manager
Updating certificate-based repositories.
Unable to read consumer identity
Setting up Install Process
Resolving Dependencies
--> Running transaction check
---> Package lsscsi.x86_64 0:0.17-3.el5 set to be updated
--> Finished Dependency Resolution

Dependencies Resolved

===========================================================================================================================
Package                 Arch                    Version                       Repository                       Size
===========================================================================================================================
Installing:
lsscsi                  x86_64                  0.17-3.el5                    zwindler_repo_el5                27 k
Transaction Summary
===========================================================================================================================
Install       1 Package(s)
Upgrade       0 Package(s)

Total download size: 27 k
Is this ok [y/N]: y
Downloading Packages:
lsscsi-0.17-3.el5.x86_64.rpm                                                                                                          |  27 kB     00:00

Installed:
lsscsi.x86_64 0:0.17-3.el5
```


Ici, le souhaite supprimer le disque /dev/sdc qui n’est plus utilisé par l’OS.

```
[root@srs1rc-vmsgbd02 by-uuid]# lsscsi
[0:0:0:0]    disk    VMware   Virtual disk     1.0   /dev/sda
[0:0:1:0]    disk    VMware   Virtual disk     1.0   /dev/sdb
[0:0:2:0]    disk    VMware   Virtual disk     1.0   /dev/sdc
[0:0:3:0]    disk    VMware   Virtual disk     1.0   /dev/sdd
[0:0:4:0]    disk    VMware   Virtual disk     1.0   /dev/sde
[0:0:5:0]    disk    VMware   Virtual disk     1.0   /dev/sdf
```


Ici, /dec/sdc est bien le disques sur le contrôleur 0, et sur le numéro du disque 2

![](/2015/06/00_match_vmdk.png)

On peut donc se rassurer et supprimer le disque qui correspond à l'emplacement virtuel SCSI 0:2. OUF!

Quelques liens pour aller plus loin - pour changer ;-) - :

* [serverfault.com/questions/220889/how-does-linux-determine-the-scsi-address-of-a-disk](http://serverfault.com/questions/220889/how-does-linux-determine-the-scsi-address-of-a-disk)
* [communities.vmware.com/thread/476311](https://communities.vmware.com/thread/476311)
