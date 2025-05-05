---
title: 'Bug : unable to execute QEMU command &lsquo;cont’ sous KVM et RHEL/CentOS'
authors:
  - zwindler
type: post
date: 2015-10-10T10:30:00+00:00
url: /2015/10/10/bug-unable-to-execute-qemu-command-cont-sous-kvm-et-rhelcentos/
image: /2015/10/kvm.png
categories:
  - systeme
  - Virtualisation
tags:
  - 2.6.32
  - 3.11
  - CentOS
  - cont
  - dbus-uuidgen
  - kernel
  - KVM
  - QEMU
  - Redhat
  - unable to execute QEMU command
  - virt-manager
  - Windows 2008
  - Windows 7

---
Cet article est encore un vieil article que je n’ai jamais pris le temps de sortir. Voilà maintenant c’est fait ;-)

## Bug unable to execute QEMU command &lsquo;cont’

Aussi rare que cela soit, après ma migration de KVM sur Ubuntu a KVM sur CentOS, je suis tombé sur un bug du Kernel Linux qui affectait directement ma capacité à faire fonctionner des machines virtuelles sous Windows 7 ou Windows 2008 ! Mais toutes les autres fonctionnaient normalement.

### Symptôme

Lorsqu’on démarre la VM ou qu’elle démarre seule au boot, elle se met en pause. Si on essaye de la sortir du mode pause on reçoit l’erreur suivante.

```
Error unpausing domain: internal error unable to execute QEMU command ‘cont’: Resetting the Virtual Machine is required<
```


L’erreur en elle même n’est pas très explicite. Dans le log de la machine virtuelle en question, on a un message plus long mais guère plus évocateur :

```
/var/log/libvirt/qemu/[maVM]
  kvm: unhandled exit 80000021
  kvm_run returned -22
  
  If you’re running a guest on an Intel machine without unrestricted mode
  support, the failure can be most likely due to the guest entering an invalid
  state for Intel VT. For example, the guest maybe running in big real mode
  which is not supported on less recent Intel processors.
```


Bien évidemment, toutes les autres VMs sous Linux fonctionnent parfaitement donc on ne peut pas accuser Qemu de ne pas fonctionner correctement.

### Solution

En théorie, j’ai lu à plusieurs endroits que le bug était censé être corrigés sur des patchs des kernels de CentOS 5 ou 6 (toujours présent en 2.6.32-431.3.1.el6.x86_64 par exemple) et même pour Ubuntu.  
Dans la pratique, même en mettant l’OS CentOS à jour, impossible de faire fonctionner cette VM.  
La seule vrai solution que j’avais trouvé à l’époque était de forcer le passage à un kernel plus récent, à savoir au moins 3.+.

Pour ceux qui se sentiraient un peu perdu, le plus simple est de changer de version de CentOS ou d’Ubuntu. Sur les dernière version le bug n’est plus présent.

Cependant, si vous avez un système en place et qu’une migration n’est pas à l’ordre du jour, voici la marche à suivre pour installer un kernel plus récent. Voici la procédure que j’ai utilisée pour installer un 3.13 sur lequel la VM fonctionne à nouveau (3.11 fonctionne aussi, je ne sais pas avant).

```
yum install gcc ncurses ncurses-devel
yum update
wget https://www.kernel.org/pub/linux/kernel/v3.0/linux-3.13.1.tar.gz
tar xzf linux-3.13.1.tar.gz -C /usr/src/
cd /usr/src/linux-3.13.1/
make menuconfig
make
make modules_install install
```


N’oubliez pas de vérifier que votre kernel est bien choisi en premier dans le boot loader, ce qui n’est souvent pas le cas par défaut (modifier la valeur **default** dans le **grub.conf** pour correspondre à la bonne entrée) sinon le problème ne sera pas résolu au reboot.

```
vi /etc/grub.conf
default=X
[...]
        root (hd0,0)
        kernel /vmlinuz-3.13.1 ro root=/dev/mapper/vg_root-lv_root rd_LVM_LV=vg_root/lv_root rd_NO_LUKS LANG=en_US.UTF-8 rd_MD_UUID=8f43b4fe:e72ed9aa:2da568b5:5f43b223 SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=fr-latin9 rd_LVM_LV=vg_endeavour/lv_swap rd_NO_DM rhgb quiet
        initrd /initramfs-3.13.1.img
```


Et vous pouvez vérifier que vous êtes sur le bon kernel avec un uname.

```
reboot
uname -r
```


## Erreur/bug Error starting virt-manager

En bonus track, je voudrais aussi ajouter un petit bug de plus pour la route, sur l’utilisation de l’interface graphique virt-manager cette fois ci.

Pour une raison obscure, lorsque je voulais lancer ma GUI virt-manager, il m’est arrivé une ou deux fois de suivre la procédure décrite sur [le blog de nutanix][1] lorsque je recevais l’erreur suivante :

> Error starting virt-manager

```
dbus-uuidgen --get
cat /var/lib/dbus/machine-id
dbus-uuidgen > /var/lib/dbus/machine-id
```


 [1]: http://nutanix.blogspot.fr/2013/06/kvm-virt-manager-startup-failure.html
