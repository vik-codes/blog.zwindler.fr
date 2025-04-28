---
title: Ajouter une clé USB à un container LXC
authors:
  - zwindler
type: post
date: 2021-10-25T06:25:00+00:00
excerpt: "Tutoriel pas à pas pour ajouter une clé USB physiquement branchée à l'hôte"
url: /2021/10/25/ajouter-une-cle-usb-a-un-container-lxc/
image: /2016/02/233_800.jpg
categories:
  - Virtualisation
tags:
  - bluetooth
  - LXC
  - passthrough
  - Proxmox

---
Il arrive souvent, quand on fait de la virtualisation, qu’on ait besoin de « passer » un device physique, notamment des clés USB, à une VM et essayer de lui faire croire qu’on lui a branché physiquement (alors que c’est l’hôte qui l’a).

Quand il s’agit de virtualisation complète, c’est, paradoxalement, relativement simple. Comme l’OS invité est totalement isolé de l’OS hôte, il est nécessaire d’ajouter un programme pour faire passer dans un tunnel les commandes envoyées/reçus par le device et d’ajouter une couche d’émulation dans la VM pour lui faire croire qu’elle a le device connecté.

Il est souvent très facile de faire ce genre d’opération dans les hyperviseurs du marché depuis très longtemps. J’avais par exemple fait [une série d’articles en 2016 (!!!) sur la façon de le faire dans VMware](/2016/03/26/modem-gsm-rs232-convertisseur-usb-vm-vmware/).

Cependant, dans le cas de container LXC sur mon Proxmox (mais la logique sera la même pour LXD ou même un LXC nu), c’est bizarrement plus compliqué. Je vais vous montrer comment faire dans cet article.

## Récupérer les informations

Sur l’hôte, utiliser l’utilitaire **lsusb** pour lister les devices connectés. Récupérer les nombres Bus et Device (ici 001 et 003) pour en déduire le chemin vers le fichier spécial du device.

```
root@host01:~# lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 003: ID 0a12:0001 Cambridge Silicon Radio, Ltd Bluetooth Dongle (HCI mode)
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

Récupérer le major number et le minor number du fichier spécial **/dev/bus/usb/{{Bus}}/{{Device}}** (ici 189 pour le major et 2 pour le minor)

```
ls -al /dev/bus/usb/001/003
crw-rw-r-- 1 root root 189, 2 Jul 24 09:46 /dev/bus/usb/001/003
```

## Configurer le container LXC

Maintenant qu’on a les 4 nombres, éditer le fichier de configuration du container 101. Le major+minor sert pour autoriser le container à manipuler le device et le chemin vers le fichier spécial doit être monté exactement au même endroit dans le container LXC

```
vi /etc/pve/nodes/host01/lxc/101.conf
lxc.cgroup.devices.allow: c 189:2 rwm
lxc.mount.entry: /dev/bus/usb/001/003 dev/bus/usb/001/003 none bind,optional,create=file
```

Rebooter le container. Normalement le device USB est bien présent.

Pour vérifier, on peut installer **usbutils** dans le container pour vérifier que la clé est bien disponible avec **lsusb**.

```
apt install usbutils

lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 003: ID 0a12:0001 Cambridge Silicon Radio, Ltd Bluetooth Dongle (HCI mode)
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```
