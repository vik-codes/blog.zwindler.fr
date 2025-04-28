---
title: Kubernetes avec RancherOS et RKE – partie 1
authors:
  - zwindler
type: post
date: 2020-10-26T07:45:00+00:00
excerpt: "Présentation et Tutoriel pour installer RancherOS, l'OS minimaliste de Rancher qui permet d'avoir un OS sécurisé et automatiquement à jour pour Docker"
url: /2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/
image: /2020/10/rancheros_explained.png
categories:
  - Autohébergement
  - Cluster
tags:
  - container
  - Déploiement
  - Docker
  - Kubernetes
  - rancher
  - RancherOS
  - RKE

---

## RancherOS pour commencer
  
  
Pendant l’été, j’ai _encore_ changé d’infra, avec un passage à un cluster Proxmox VE à 3 nœuds. Je reviendrais la dessus, mais la finalité c’est que j’ai eu (encore) l’envie de m’installer un petit cluster Kubernetes dans mes hyperviseurs.

Ceux qui me suivent depuis un moment savent que j’en ai déjà déployé des tonnes depuis le temps ([k3s qui vient également de chez Rancher, mais aussi kubespray, kubeadm, aks, OVH, the hard way de kelsey hightower, ...](/recherche/?keyword=kubernetes)).

Du coup, plutôt que de gagner du temps et refaire quelque chose que je maîtrise déjà, je suis parti dans l’idée de tester quelque chose d’encore nouveau, deux produits de Rancher dont j’ai entendu parler : RancherOS + RKE !

L’idée dans cette première partie est de découvrir RancherOS, une des nombreuses solutions pour vos workload containerisés proposées par Rancher.

## Mais c’est quoi RancherOS ?
  
  
> RancherOS A lightweight, secure Linux distribution, built from containers to run containers well.
RancherOS est donc un OS minimaliste contenant juste ce qu’il faut pour faire du Docker, configuré à l’aide de cloud-init et dans lequel la plupart des opérations de maintenances sont simplifiées.
Quand je lis ça, je ne peux pas m'empêcher de repenser à CoreOS, qui faisait (fait) les mêmes promesses.
N’ayant qu’installé et utilisé pendant peu de temps CoreOS, je ne serai pas capable de faire une comparaison des deux produits entre eux, mais la finalité est vraiment la même.
Un point intéressant (je trouve) dans RancherOS est le fait que tous les services "techniques" nécessaires pour faire fonctionner correctement vos applications containerisés sont également des containers.
> RancherOS is the smallest, easiest way to run Docker in production. Every process in RancherOS is a container managed by Docker. This includes system services such as udev and syslog.

![](/2020/10/rancheros_explained.png) 

L’idée ici, c’est que tous ces services systèmes tournent dans un démon Docker séparé (pour plus de sécurité et éviter la suppression accidentelle).

## Comment le déployer ?
  
> Ça dépend. Et évidemment, ça dépend, ça dépasse.

Rancher a fait le choix (malin) de mettre le paquet pour faciliter le déploiement de leur RancherOS sur le plus de plateformes possibles.

Ainsi, vous retrouverez des processus de déploiement facilités pour la plupart des clouds providers public, mais aussi des images pour VMware, une image pour Rasberry Pi, Virtual Box ou Docker Machine. Il y a même de quoi booter en PXE pour ceux qui ont encore l’envie de faire ce genre de choses.

Dans mon cas, la seule solution à ma disposition pour KVM c’est d’[utiliser l’ISO](https://rancher.com/docs/os/v1.x/en/installation/workstation/boot-from-iso/).

## Première bonne nouvelle et première déconvenue
  
  
LA première bonne nouvelle, c’est qu’il existe un ISO tuné pour Proxmox VE, et ça c’est très cool.

Donc je DL l’ISO, créé une bête machine virtuelle sur mon cluster, dans lequel l’ISO est monté et roule ma poule ?

Ouais... presque !

> You must boot with enough memory which you can refer to [here](https://rancher.com/docs/os/v1.x/en/overview/#hardware-requirements).

Un point agaçant avec RancherOS est le _minimum requirement_ en termes de mémoire. 1.25 Go pour un OS Linux soi-disant minimaliste (passé à 1 Go depuis la 1.5), la pilule a du mal à passer. Ok, je pinaille peut-être un peu, mais 1 Go c’est énorme quand on a prévu de lancer juste quelques petits containers comme des petits nginx ou des petits bouts de code python.

Il faut dire que Rancher nous a mal habitué avec k3s, leur Kubernetes modifié qui tourne avec quasiment pas de RAM au point de permettre de Kubernetes sur des RPi 1 ou en _edge computing_. Et là, avec 2 fois plus de RAM en _requirement_, j’ai que le démon Docker, même pas le kube qui va avec...

Du coup, le "RancherOS is the smallest, easiest way to run Docker in production", bof...

* [Déployer en 5 minutes un cluster Kubernetes sur ARM avec k3s et Ansible](/2019/03/21/deployer-en-5-minutes-un-cluster-kubernetes-sur-arm-avec-k3s-et-ansible/)


Rancher essaye de se raccrocher aux branches en vous linkant une [doc permettant de construire soi-même une image custom nécessitant moins de RAM](https://rancher.com/docs/os/v1.x/en/installation/custom-builds/custom-rancheros-iso/#reduce-memory-requirements), mais bon... Le mal est fait, ils m’ont pas motivé à tester...

## Déployer RancherOS sur Proxmox VE

Ok, assez discuté, maintenant on peut rentrer dans le vif du sujet. Sur notre hyperviseur préféré, on récupère l’ISO.

```
cd /var/lib/vz/template/iso
wget https://releases.rancher.com/os/latest/proxmoxve/rancheros.iso
--2020-08-10 15:00:26--  https://releases.rancher.com/os/latest/proxmoxve/rancheros.iso
Resolving releases.rancher.com (releases.rancher.com)... 104.26.12.240, 172.67.69.133, 104.26.13.240, ...
Connecting to releases.rancher.com (releases.rancher.com)|104.26.12.240|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 160432128 (153M) [application/x-iso9660-image]
Saving to: ‘rancheros.iso’

rancheros.iso       100%[===================>] 153.00M  42.3MB/s    in 3.7s    

2020-08-10 15:00:36 (40.9 MB/s) - ‘rancheros.iso’ saved [160432128/160432128]
```

La procédure d’installation officielle est [disponible ici](https://rancher.com/docs/os/v1.x/en/installation/server/install-to-disk/).

Grosso modo, on boot la VM, qui va configurer le serveur au minimum et permettre de se connecter avec l’utilisateur rancher` sans mot de passe. L’idée est d’utiliser cet utilisateur pour finaliser l’installation avec ros install` une fois la VM configurée.

> The ros install` command orchestrates the installation from the rancher/os container. You will need to have already created a cloud-config file and found the target disk.

***STOOOOOP***

Si vous partez bille en tête comme moi et faites un ros install` sans lire la phrase en entier, vous vous retrouverez avec une VM sur laquelle vous ne pourrez pas vous loguer (voire sans réseau si vous n’avez pas de DHCP). C’est con.

> The easiest way to log in is to pass a cloud-config.yml file containing your public SSH keys.

## Cloud config

Ok, on va éviter de tous faire la même erreur. Voici maintenant le fameux prérequis, la documentation officielle qui parle de [configuration/#cloud-config](https://rancher.com/docs/os/v1.x/en/configuration/#cloud-config).

Si vous avez un doute sur certains paramètres, vous pouvez toujours utiliser la commande ros config` qui permet de récupérer les valeurs par défaut puis les setter.

On finalisera le tout en fusionnant la config actuelle avec un fichier YAML, ou alors on exportera la conf actuelle dans un autre fichier YAML.

Dans le cas d’un PoC, la plupart des valeurs qui vont nous intéresser sont simplement ce qui permet de setter l’IP et de configurer notre clé SSH pour pouvoir se connecter.

```
sudo ros config get rancher.network
dhcp_timeout: 0
dns:
  nameservers: []
  search: []
http_proxy: ""
https_proxy: ""
interfaces: {}
modem_networks: {}
no_proxy: ""
post_cmds: []
pre_cmds: []
wifi_networks: {}
```

Donc là, de base, bah ya rien.

Pourtant, si vous allez voir le fichier /var/lib/rancher/conf/cloud-config.yml, vous remarquerez qu’il y a pleeeeein de choses, plus ou moins utiles.

La page de doc qui nous intéressera donc dans ce cas est [networking](https://rancher.com/docs/os/v1.x/en/networking/). Voici un exemple de commandes pour configurer une IP fixe (à remplacer par des valeurs qui ont du sens dans votre réseau, of course).

```
sudo ros config set rancher.network.interfaces.eth0.address 192.168.1.10/24
sudo ros config set rancher.network.interfaces.eth0.gateway 192.168.1.1
sudo ros config set rancher.network.interfaces.eth0.mtu 1500
sudo ros config set rancher.network.interfaces.eth0.dhcp false
```

A partir de ce moment là, vous avez accès au réseau depuis votre machine RancherOS, mais les modifications ne seront pas permanentes. On va donc exporter tout ça.

```
sudo ros config export
rancher:
  environment:
    EXTRA_CMDLINE: /init
  network:
    interfaces:
      eth0:
        address: 192.168.1.10/24
        dhcp: false
        gateway: 192.168.1.10
        mtu: 1500
ssh_authorized_keys: []
```

Bon, et là vous voyez qu’il nous manque toujours la clé SSH.

## Bonus clavier qwerty

Vous connaissez la différence entre un admin systèmes français débutant et un admin système français senior ?
> If you call yourself a sysadmin and don’t know by heart the qwerty layout on an azerty keyboard, I just assume you are a junior.

(Pour ceux qui n’ont pas la blague, allez voir ce tweet de _oshell qui a bien backfired (lien mort) dans sa face)

Le senior, a force de bouffer des consoles à la con qui gèrent mal les différents layouts de claviers (parce que "hé, on s’en fout des gens qui ont pas de qwerty, on vient de la Silicon valley"), il connaît le qwerty par cœur.

Et ben là encore, ça n’a pas loupé. La console NoVNC de mon PVE, qui en plus n’avait le partage de presse-papier qui ne marchait pas.

Je veux bien être à l’aise en "blind qwerty sur azerty", mais faut pas déconner, je suis pas senior au point d’être capable de copier une clé publique dans un YAML #trollface.

Donc pour ceux qui ne connaissent pas l’astuce, il est possible d’affecter temporairement un terminal série à votre VM de la façon suivante (voir [doc Proxmox VE](https://pve.proxmox.com/wiki/Serial_Terminal))

```
# qm set 100 -serial0 socket
    update VM 100: -serial0 socket
```

A partir de là, vous devriez pouvoir accéder à un nouveau type de console dans Proxmox, qui devrait à la fois résoudre le problème de clavier qwerty ET le problème de presse-papier.

## Cloud-config, suite

On récupère ce qu’on vient d’exporter et on ajoute notre clé comme nous le demande Rancher dans sa doc. Et avant de lancer l’install, on vérifie que notre cloud-config est valide

```
sudo ros config validate -i cloud-config.yml
```

Si la commande ne renvoie rien, c’est que c’est OK (pas super explicite mais bon why not). On passe donc à l’install :

```
sudo ros install -c cloud-config.yml -d /dev/sda
INFO[0000] No install type specified...defaulting to generic
Installing from rancher/os:v0.5.0
Continue [y/N]:
[...]
Continue with reboot [y/N]: y
INFO[0013] Rebooting
```

A partir de là, on peut (et on doit) se connecter en SSH sur la machine RancherOS (l’accès console n’est plus possible)

```
ssh -J proxmoxve rancher@192.168.1.10
```

Et si tout s’est bien passé, vous devriez pouvoir vous connecter !

## Et maintenant, que vais-je fai-reuh ?

Ben déjà on peut regarder ce que RancherOS a activé comme "services" sur notre install Proxmox VE.

```
sudo ros service list
disabled amazon-ecs-agent
disabled container-cron
disabled open-iscsi
disabled zfs
disabled kernel-extras
disabled kernel-headers
disabled kernel-headers-system-docker
disabled open-vm-tools
disabled hyperv-vm-tools
enabled  qemu-guest-agent
disabled rancher-server
disabled rancher-server-stable
disabled amazon-metadata
disabled volume-cifs
disabled volume-efs
disabled volume-nfs
disabled modem-manager
disabled waagent
disabled virtualbox-tools
disabled pingan-amc
```

Globalement, pas grand chose. La seule chose activée est le qemu-guest-agent, ce qui est utile puisque nous avons une effectivement une VM QEMU dans ce cas précis.
Quant à vos containers Docker, vous pouvez vérifier qu’ils sont bien séparés des containers docker servant au fonctionnement de RancherOS avec les commandes suivantes :
  
* Les containers "systèmes"

```
[rancher@rancher ~]$ sudo system-docker ps
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS                          PORTS               NAMES
1e059e78c17e        rancher/os-docker:19.03.11           "ros user-docker"        12 minutes ago      Up 12 minutes                                       docker
ba43a0648227        rancher/os-qemuguestagent:v2.8.1-2   "/usr/bin/ros entr..."   12 minutes ago      Restarting (1) 34 seconds ago                       qemu-guest-agent
d9ad607221fa        rancher/os-console:v1.5.6            "/usr/bin/ros entr..."   12 minutes ago      Up 12 minutes                                       console
ad0197c79ff2        rancher/os-base:v1.5.6               "/usr/bin/ros entr..."   12 minutes ago      Up 12 minutes                                       ntp
538ccf5eb624        rancher/os-base:v1.5.6               "/usr/bin/ros entr..."   12 minutes ago      Up 12 minutes                                       network
f389c6b0b40e        rancher/os-base:v1.5.6               "/usr/bin/ros entr..."   12 minutes ago      Up 12 minutes                                       udev
b51deb379bf2        rancher/container-crontab:v0.4.0     "container-crontab"      12 minutes ago      Up 12 minutes                                       system-cron
59441adcc016        rancher/os-syslog:v1.5.6             "/usr/bin/entrypoi..."   13 minutes ago      Up 12 minutes                                       syslog
120df7cc2492        rancher/os-acpid:v1.5.6              "/usr/bin/ros entr..."   13 minutes ago      Up 12 minutes                                       acpid
```

Vos containers :

```
[rancher@rancher ~]$ docker container ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

Les containers "systèmes" sont bien distincts des containers docker "utilisateurs". La promesse d’isolation Docker infra vs Docker appli est bien tenue.

## Mon avis
  
A voir à l’usage, mais je ne suis pas hyper convaincu.

D’abord, en termes d’OS minimalistes, on a quand même vu mieux. Et d’ailleurs, [les gens chez Rancher le savent puisqu’ils se sentent obligés de s’en justifier](https://rancher.com/docs/os/v1.x/en/installation/custom-builds/custom-rancheros-iso/#reduce-memory-requirements)...

Plus grave, l’UX est quand même super bof. J’ai l’habitude d’installer des softs mais je me suis quand même pris la tête avec le cloud-config assez moyennement documenté, et en plus, à faire DANS une console (et la galère QWERTY/AZERTY associée).

"Et c’est pas fini", comme dis la pub.

Je vous l’ai dis, mon objectif est d’avoir un cluster Kubernetes installé par RKE. Or, il n’est pas trivial d’utiliser RancherOS comme OS pour hoster un Kubernetes déployé avec RKE. Vous verrez dans la partie 2 que ça n’a pas été une partie de plaisir...

Un comble pour 2 produits de la même boite censé vous simplifier l’administration de Docker/Kube...

Et plus grave encore, c’est que j’ai du mal à voir pour qui ce genre de distribs apporte de la valeur. C’est d’ailleurs pour cette même raison pour laquelle je n’avais pas poussé l’expérimentation très loin avec CoreOS. En tant qu’admin, je suis forcément frustré par un OS où je n’ai pas/peu la main.

J’aime bien ce qu’ils font chez Rancher. Mais je ne sais pas répondre à la question Pourquoi RancherOS ?
On pourrait se dire que pour une équipe de développeurs en mode startup qui doit sortir son MVP en peu de temps, ça peut être cool.

Mais même là, j’ai des doutes.

Si ces gens là veulent VRAIMENT s’abstraire d’Ops (voir mon avis sur la question dans [Au secours, le métier d’Ops va disparaître !](/2020/07/29/au-secours-le-metier-dops-va-disparaitre/)), ils partiront sur d’autres types de technos (Kubernetes managé, Serverless, No code ?).

Si vous voyez une raison que j’aurais loupé, n’hésitez pas à venir en parler en commentaire ou via les RS, car là je vois pas...

En attendant la partie sur RKE, have fun :)
