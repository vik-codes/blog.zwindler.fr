---
title: 'Premiers pas avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical'
authors:
  - zwindler
type: post
date: 2023-12-21T14:00:00+02:00
url: /2023/12/21/premiers-pas-avec-maas-baremetal-canonical
image: /2023/12/pxe_tftp2.jpg
categories:
  - DIY
  - Virtualisation
tags:
  - Homelab
  - Baremetal
  - Ubuntu
  - MAAS
  - Metal as a Service

---

Cet article fait partie d'une série d'articles dédiés à la découverte de MAAS, un outil de déploiement d'OS sur un parc de serveurs (souvent baremetal mais pas que) :
* [Premiers pas avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical](/2023/12/21/premiers-pas-avec-maas-baremetal-canonical)
* [Un peu plus loin avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical](/2024/01/04/un-peu-plus-loin-avec-maas-canonical)
* [Déployer un hyperviseur VMware ESXi avec MAAS](/2024/01/08/maas-canonical-esxi)

## Introduction

Il y a quelques mois, après plusieurs discussions avec mon collègue (et ami!) Julien, j'ai voulu tester MAAS (Metal As A Service) sur mon homelab.

Pour ceux qui ne connaissent pas cet outil, c'est un logiciel qui va permettre de déployer des machines baremetal de manière automatique.

En théorie, l'outil est plutôt prévu pour faciliter le déploiement de serveurs de manière flexible en datacenters, mais il existe plusieurs exemples de personnes qui ont réussi à l'utiliser sur des NUCs ou des machines desktop.

C'est donc un parfait premier cas d'usage pour mon homelab, composé de [3 dell micro et d'un raspberry pi](/2023/03/16/lab-2023-dell-micro-occasion).

![](/2023/03/dell_lab.jpg)

J'avais deux possibilités en termes d'architecture et j'ai d'ailleurs testé les deux. La première était de créer le lab dans mon LAN. Ca nécessite de bidouiller un peu le DHCP de ma box Bouygues pour que MAAS puisse gérer les IPs des machines ainsi que de configurer le DHCP pour propager le PXE.

A priori c'est faisable, mais j'ai trouvé ça pénible dans l'idée et potentiellement disruptif pour mon LAN perso, alors j'ai décidé de mettre le homelab dans un LAN à part, dont le RPi serait le routeur. J'ai ajouté une interface réseau à l'aide d'un adaptateur ethernet USB et roule ma poule.

![](/2023/12/maas.png)

A l'époque (en juin), ça n'avait pas marché (peut être à cause d'un bug ?), les machines étaient bien déployables, mais je ne pouvais pas réaliser l'action "Deploy".

```
Node has no address family in common with the server
```

Cependant, cette fois-ci, ça a marché ! Voici donc un premier article sur le sujet !

## Préparer le RPI

Avant de toucher aux Dell micro, j'ai donc commencé par configurer le Raspberry Pi, avec Rpi Imager.

https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#1-overview

![](/2023/12/rpi1.png)

![](/2023/12/rpi2.png)

Une fois la carte préparée, sur la partition system-boot, éditer le fichier `config.txt` pour configurer l'écran portable (ou `/boot/firmware/config.txt` une fois booté). Ici, ça sert juste pour mon petit écran portable 7 pouces (peut être que ça peut aider dans d'autres cas) mais je vous le mets quand même, pour info.

```
[all]
max_usb_current=1
hdmi_force_hotplug=1
config_hdmi_boost=10
hdmi_group=2
hdmi_mode=87
hdmi_cvt 1024 600 60 6 0 0 0
```

On boot le pi, on se connecte en ssh, on update/upgrade tous les packages et on reboot, histoire de commencer sur des bases saines.

## Installer MAAS sur le RPI

* [maas.io/docs/how-to-do-a-fresh-install-of-maas](https://maas.io/docs/how-to-do-a-fresh-install-of-maas)

En prérequis MAAS demande de désactiver le client ntp existant pour éviter des conflits

```bash
sudo systemctl disable --now systemd-timesyncd
```

Et comme j'ai décidé que mes machines seraient dans un LAN à part (cf schéma ci-dessus) et que le RPi serait le "routeur" entre les deux, il faut bien sûr autoriser le routage :

```bash
sudo vi /etc/sysctl.conf
  net.ipv4.ip_forward = 1 
  net.ipv6.conf.all.forwarding=1

sudo sysctl -p /etc/sysctl.conf
```

Et pour finir, je vais configurer mon resolver DNS dans `/etc/resolv.conf` sur ma Box internet

```bash
sudo vi /etc/resolv.conf
[...]
  nameserver @IP
[...]
```


Addendum : histoire d'éviter des soucis de changement d'adresse IP à cause de mon DHCP pourri, on fixe les IPs via une configuration netplan. Ici, mon interface ethernet du RPi est eth0 (celle reliée à mon LAN) et celle (USB) reliée à mon lab et aux 3 dell micros est enxa0cec80428b7.

```yaml
vi /etc/netplan/50-cloud-init.yaml
network:
    ethernets:
        eth0:
            dhcp4: false
            addresses: [192.168.x.y/24]
            gateway4: 192.168.x.z
            nameservers:
              addresses: [9.9.9.9,192.168.x.z]
        enxa0cec80428b7:
            dhcp4: false
            addresses: [10.10.0.1/16]
    version: 2
```

Et on valide avec 

```bash
netplan apply
```

Si vous suivez la doc bêtement comme je le fais moi, MAAS propose de s'installer en tant que snap. Si c'est le cas, il ne pourra accéder qu'à /home et /media (cf [ce post sur le discourse de maas.io](https://discourse.maas.io/t/maas-boot-resources-create-fails-with-no-such-file-or-directory/3627)). Il existe aussi une version .deb de MAAS mais pour le test je me suis contenté de ça.


```bash
zwindler@maas:~$ sudo snap install --channel=3.4/beta maas
maas (3.4/beta) 3.4.0-14319-g.3ab76533f from Canonical✓ installed
```

Note : point important, l'expérience utilisateur entre la version 3.3 et la version 3.4 est significativement différente. Au delà de l'UI qui change d'un menu horizontal à un menu vertical, certaines opérations semblent ne pas être totalement identiques. Il est possible que ce tuto ne marche pas en 3.3.

Plutôt qu'installer une base PostgreSQL pour stocker les données de MAAS, je vais également simplement utiliser le snap `maas-test-db`, qui comme son nom l'indique, est une base de données postgres préconfigurée pour faire des tests avec MAAS (donc pas production ready !).

```bash
zwindler@maas:~$ sudo snap install maas-test-db
maas-test-db (3.3/stable) 14.2-29-g.ed8d7f2 from Canonical✓ installed
```

A partir de là, mon Raspberry Pi 4 modèle 2 Go (oui j'ai été radin) est à l'agonie. Heureusement, un petit reboot suffit à lui donner un second souffle.

## Configurer MAAS

Une fois que c'est fait, on peut initialiser notre MAAS en mode "region+rack". Ca va nous permettre d'avoir la totalité des fonctionnalités sur le serveur MAAS du RPi.

```bash
zwindler@maas:~$ sudo maas init region+rack --database-uri maas-test-db:///
MAAS URL [default=http://@IP:5240/MAAS]: (valider avec entrée)
[/] Performing database migrations
MAAS has been set up.             

If you want to configure external authentication or use
MAAS with Canonical RBAC, please run

  sudo maas configauth

To create admins when not using external authentication, run

  sudo maas createadmin

To enable TLS for secured communication, please run

  sudo maas config-tls enable
```

Pour faire simple, je ne vais pas configurer une authentification externe et me contenter (là encore) de simplement créer un utilisateur local d'administration :

```bash
zwindler@maas:~$ sudo maas createadmin
Username: zwindler
Password: 
Again: 
Email: blog@zwindler.fr
Import SSH keys [] (lp:user-id or gh:user-id): 
```

On peut donc ouvrir la page d'admin (http://@IP:5240/MAAS/r/) et rentrer le login/mdp qu'on vient de créer.

La première chose qu'on va nous demander c'est de finir le setup via un wizard. On va créer notre première région, ajouter nos premières images, ajouter une clé SSH

![](/2023/12/wizard1.png)

![](/2023/12/wizard2.png)

![](/2023/12/wizard3.png)

![](/2023/12/wizard4.png)

## Configurer un subnet

Une fois le wizard terminé, on va avoir l'auto-découverte de ce qui se passe sur notre LAN. Le truc, c'est que dans mon cas précis, ce n'est pas ce qui est sur mon LAN (de ma box) qui m'intéresse, mais ce qui va être sur le LAN de MAAS, via mon autre interface Ethernet (USB).

Je vais donc créer un réseau interne 10.10.0.0/16 (cf la doc [maas.io/docs/about-networking](https://maas.io/docs/about-networking))

![](/2023/12/network1.png)

Une fois créé, je l'édite pour ajouter des infos

![](/2023/12/network2.png)

![](/2023/12/network3.png)

De retour sur la fabric, on va sur le VLAN par défaut et on configure le DHCP

![](/2023/12/vlan1.png)

![](/2023/12/vlan2.png)

Une fois que c'est fait, on va pouvoir commencer à booter des machines en PXE pour les enroller dans MAAS !!

## Enroller des machines

A partir de là en vrai, il n'y a plus grand-chose à faire. J'ai configuré le BIOS de mes dell micro pour qu'il boot d'abord sur le PXE. Le serveur DHCP / PXE de MAAS sur le RPi a pris le relai, et a fait booter la machine sur une image d'enrôlement.

![](/2023/12/pxe_tftp1.jpg)

![](/2023/12/pxe_tftp2.jpg)

![](/2023/12/pxe_tftp3.jpg)

Au bout de plusieurs minutes, dans l'onglet Machines, on voit mon Dell micro arriver. On peut la tester :

![](/2023/12/test.png)

Et là, patatra, **error** !

En vrai, c'est parce qu'il me manque une étape. J'ai oublié d'indiquer à MAAS comment démarrer la machine.

Dans mon cas, il ne s'agit pas de matériel de type "serveur". Je ne peux donc pas piloter l'allumage de la machine à distance avec un ILO / iDRAC. De même, je n'ai pas pris de multiprise manageable (je vais y réfléchir cela dit). Je dois donc configurer la "power source" de la machine et indiquer comme "Power type" la valeur "Manual".

![](/2023/12/power1.png)

Une fois que c'est fait, je fais un "Commission" (et j'appuie moi même si le bouton "On").

![](/2023/12/commission1.png)

![](/2023/12/commission2.png)

Et si tous les tests sont bien passés, on doit se retrouver avec une machine à l'état "Ready". A partir de là, je peux la "Deploy" (et il faut encore que j'appuie sur le bouton "On").

![](/2023/12/deploy.png)

Et cette fois-ci, c'est une victoire ;-)

![](/2023/12/enrolled.jpg)

![](/2023/12/deployed.png)

```bash
➜  ~ ssh -J zwindler@@IP ubuntu@10.10.0.2
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-169-generic x86_64)
[...]
ubuntu@daring-tomcat:~$ 
```

## Liens en vrac

* [Tutoriels MAAS+JUJU éparpillés un peu partout sur le net (insights.ubuntu.com) - part 1](https://insights.ubuntu.com/2016/01/21/introduction-deploying-openstack-on-maas-1-9-with-juju/)
* [Tutoriels MAAS+JUJU éparpillés un peu partout sur le net (ubuntu.com/blog) - part 2](https://ubuntu.com/blog/hardware-setup-deploying-openstack-on-maas-1-9-with-juju)
* [Tutoriels MAAS+JUJU éparpillés un peu partout sur le net (blog.naydenov.net) - part 3](https://blog.naydenov.net/2016/01/maas-setup-deploying-openstack-on-maas-1-9-with-juju/)
* [Tutoriels MAAS+JUJU éparpillés un peu partout sur le net (maas.io) - part 4](https://maas.io/blog/nodes-networking-deploying-openstack-on-maas-1-9-with-juju)

* [Cluster de RPi](https://maas.io/tutorials/build-your-own-bare-metal-cloud-using-a-raspberry-pi-cluster-with-maas#1-overview)

* [Sur une machine (laptop)](https://maas.io/tutorials/build-a-maas-and-lxd-environment-in-30-minutes-with-multipass-on-ubuntu#7-verify-and-explore-your-maas-and-lxd-installation)

* [Avec des minis Pc comme les miens](https://www.reddit.com/r/homelab/comments/12qd446/got_6_mini_pcs_working_with_maas/)
