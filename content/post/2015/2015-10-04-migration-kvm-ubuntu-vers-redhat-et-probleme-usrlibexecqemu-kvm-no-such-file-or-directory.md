---
title: 'Migration KVM Ubuntu vers Redhat et problème /usr/libexec/qemu-kvm: No such file or directory'
authors:
  - zwindler
type: post
date: 2015-10-04T19:20:58+00:00
url: /2015/10/04/migration-kvm-ubuntu-vers-redhat-et-probleme-usrlibexecqemu-kvm-no-such-file-or-directory/
image: /2015/10/kvm.png
categories:
  - systeme
  - Virtualisation
tags:
  - '/usr/libexec/qemu-kvm: No such file or directory'
  - CentOS
  - export
  - import
  - KVM
  - migration
  - QEMU
  - RHEL
  - Ubuntu
  - virsh

---
Je suis en train de migrer de KVM vers ProxMox. Et du coup, je ressors de mes tiroirs tous les articles que je n’ai pas ~~eu~~ pris le temps d’écrire à propos des problèmes que j’ai pu rencontrer, notamment lors de ma migration VMware ESXi vers KVM/Uubuntu puis KVM/Ubuntu vers KVM/CentOS.

## Processsu de migration (à froid)

On pourrait penser que migrer une machine virtuelle KVM Ubuntu vers une machine virtuelle KVM sous RHEL/CentOS ne pose pas de problème particulier puisqu’il s’agit d’une même technologie : qemu. Et pourtant !

Lorsque j’ai voulu passer sous CentOS pour des questions d’habitude d’administration (et aussi parce que la philosophie RHEL me plait plus que celle d’Ubuntu), je me suis rendu compte que ça n’est pas tout à fait vrai.

Voici la procédure que j’ai suivi pour migrer :

  * copie de mes machines virtuelle sur un volume séparé, ainsi que dump de leur fichiers de configuration
  * réinstallation _from scratch_ de l’OS de l’hyperviseur, j’en ai profité pour passer sur un OS installé en RAID1 pour plus de sécurité
  * récupération des machines virtuelles et réimport de leur configuration

Pour ceux qui ne sont pas familier avec l’import/export de configuration de machines virtuelles via virsh, voici un petit aparté sur la marche à suivre :

```
virsh list #affiche la liste des machines virtuelles actives sur le serveur
virsh list --all #affiche toutes les VMs enregistrés sur l'hôte, même celles inactives
virsh dumpxml GuestID > guest.xml #dump XML du fichier de configuration pour sauvegarde ou import futur
virsh define guest.xml #réimporter le fichier de configuration XML (sans démarrer la VM à la suite)
```


## En cas d’erreur _No such file or directory_ lors de l’import

Lors qu’on importe la machine virtuelle, on peut avoir l’erreur suivante :

```
virsh define MaVM.xml
error: Failed to define domain from MaVM.xml
error: Cannot find QEMU binary /usr/bin/kvm: No such file or directory
```


La première chose à vérifier bien entendu est que tous les packages sont bien installés mais dans mon cas c’était bien le cas (le package qemu contenant l’émulateur KVM était bien installé).

Sur Ubuntu, l’émulateur est stocké dans le binaire **/usr/bin/kvm**. A l’inverse, sur RHEL ou CentOS, il n’est pas situé dans le même dossier, et ne s’appelle même pas **kvm** mais **/usr/libexec/qemu-kvm** !

On doit donc passer sur chaque fichier XML de configuration de machine virtuelle pour modifier le chemin vers le binaire. On en profitera également pour mettre à jour le chemin vers le disque dur virtuel si jamais l’arborescence de stockage n’est pas la même entre les deux serveurs.

```
vim MaVM.xml
    <emulator>/usr/bin/kvm</emulator>
```


A partir de là, vous pouvez importer correctement vos VMs et les démarrer !

## Pour aller plus loin

A noter, par défaut sous RHEL/CentOS les fichiers sont répartis de la façon suivante :

  * /etc/libvirt/qemu/ pour tous les fichiers de configuration VM, storage, etc.
  * /var/log/libvirt/qemu/ pour les fichiers journaux des machines virtuelles
  * /var/run/libvirt/qemu/ contient les fichiers de fonctionnement de la machine, à avoir le .pid pour stocker le PID du process maitre de ma VM, ainsi qu’un fichier XML contenant une copie de la configuration de la VM en fonctionnement
  * /var/lib/libvirt/qemu/ contient des fichiers permettant de suivre les performances de la VM, de stocker les éventuels dump/snapshots/sauvegardes

Un peu de documentation clairement expliquée sur l’utilisation de virsh sur la communauté Ubuntu : [Virsh](https://help.ubuntu.com/community/KVM/Virsh)

Et pour aller plus loin dans le Troubleshooting, voici [un guide de RedHat listant les erreurs courantes avec Qemu/KVM](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Virtualization_Deployment_and_Administration_Guide/sect-Troubleshooting-Common_libvirt_errors_and_troubleshooting.html).
