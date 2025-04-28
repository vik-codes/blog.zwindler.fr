---
title: 'Un peu plus loin avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical'
authors:
  - zwindler
type: post
date: 2024-01-04T06:00:00+02:00
url: /2024/01/04/un-peu-plus-loin-avec-maas-canonical
image: /2024/01/bearmetal.jpeg
categories:
  - DIY
  - Virtualisation
tags:
  - Homelab
  - Baremetal
  - Ubuntu
  - MAAS
  - Metal as a Service
  - Kubernetes

---

Cet article fait partie d'une série d'articles dédiés à la découverte de MAAS, un outil de déploiement d'OS sur un parc de serveurs (souvent baremetal mais pas que) :
* [Premiers pas avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical](/2023/12/21/premiers-pas-avec-maas-baremetal-canonical)
* [Un peu plus loin avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical](/2024/01/04/un-peu-plus-loin-avec-maas-canonical)
* [Déployer un hyperviseur VMware ESXi avec MAAS](/2024/01/08/maas-canonical-esxi)

## Introduction

Dans la première partie, nous nous étions arrêté au moment où MAAS était installé sur un Raspberry Pi, routeur entre mon LAN et mon lab. Nous avions également déployé un OS (Ubuntu 20.04 par défaut) pour valider que l'installation fonctionnait

![](/2023/12/maas.png)

Dans cette partie, on va essayer d'aller un peu plus loin et de faire des trucs plus funs pour déployer des OS différents, et pourquoi pas des hyperviseurs !

## Modifier l'OS par défaut

Il est possible de modifier l'OS installé par défaut sur nos machines lors des phases "Commissioning" et "Deploying"

Comme j'avais déjà récupéré les ISO pour Ubuntu 22.04, j'ai donc essayé de modifier toutes les étapes en Ubuntu 22.04.

La procédure est assez simple, on peut même changer le kernel par défaut (pratique pour profiter des dernières avancées eBPF, notamment si vous voulez faire du Kubernetes! )

![](/2024/01/default_commissioning_os.png)

![](/2024/01/default_deploy_os.png)

Rappel : la phase commissioning sert à faire une première installation d'un hôte minimal pour l'enrôler dans notre pool de serveurs disponibles avec MAAS, en vue d'une future installation. Si on veut modifier l'OS installé par défaut quand on déploie une machine, c'est bien le menu de la phase "Deploying" qu'il faut modifier.

## Déployer un hôte "KVM"

Par défaut, il est également possible de déployer des hôtes qui vont gérer des machines virtuelles directement depuis MAAS.

![](/2024/01/deploy_libvirt.png)

![](/2024/01/deploy_lxd.png)

Même si j'avais le doute au début, les machines LXD sont bien de vraies machines virtuelles (pas de containers LXC), comme l'explique la documentation officielle [LXD vs libvirt - maas.io/docs/virtual-machines (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20231204160638/https://maas.io/docs/virtual-machines#heading--lxd-vs-libvirt)

> Both libvirt KVMs and LXD VMs are based on QEMU, but LXD VMs offer more advantages such as enhanced security and a robust API. Unlike libvirt KVMs, LXD VMs can be managed remotely without requiring SSH access.

A noter, les machines *libvirt* sont aujourd'hui considérées comme "legacy" et il n'est pas possible d'en ajouter provenant de l'extérieur dans l'UI 3.4.0 beta que j'ai installé, contrairement aux machines LXD qui peuvent être ajoutées à MAAS même si elles ne sont pas sur des serveurs gérés par MAAS.

![](/2024/01/virsh_host.png)

![](/2024/01/lxd_host.png)

On peut ensuite aller dans virsh/LXD (selon ce qu'on a choisi) et poper des VMs depuis l'interface de MAAS. 

![](/2024/01/compose_vm.png)

Et ce qui est rigolo, c'est qu'on peut ensuite installer des trucs sur ces machines, qui se retrouvent dans notre liste :

![](/2024/01/NewLXDMachine.png)

> Machines making machines! How perverse.
>
> -- C3PO - Star Wars Episode 2

Et on peut déployer des trucs dessus bien sûr ;-)

![](/2024/01/AwesomeVM1_deploying.png)

![](/2024/01/AwesomeVM1_deployed.png)

Bon, ce n'est par contre pas spécialement user friendly (mais ça marche). L'idée est probablement un peu plus utile avec Juju (que je ne testerai pas ici).

> VM hosts offer unique benefits when integrated with Juju, including dynamic VM allocation with custom interface constraints.

## Customiser son OS avec cloud-init

Avouez que déployer des OS nus (juste l'OS, rien d'autre) avec MAAS, c'est cool, mais c'est quand même un poil limité en prod. Pour aller plus loin, MAAS nous donne accès à plusieurs mécanismes pour customiser notre OS.

Pour faire simple et parce que c'est devenu un des standards du marché, je vais tester l'utilisation de cloud-init avec MAAS pour customiser mon OS.

Et parce que j'aime Kubernetes, je vais poper un "cluster" de test avec microk8s. En l'état celà ne servira pas à grand-chose en utilisation réelle, mais ça vous donne une idée de ce qu'on peut faire avec.

![](/2024/01/maas-cloud-init.png)

```
#cloud-config
runcmd:
 - |
   # install and start microk8s
   snap install microk8s --classic
   microk8s start
   usermod -a -G microk8s ubuntu
   mkdir /home/ubuntu/.kube
   chown -R ubuntu ~/.kube

apt_update: true
apt_upgrade: true
package_update: true
package_upgrade: true
package_reboot_if_required: false
```

Au bout de quelques minutes, la machine est déployée, et l'OS est correctement customisé :

```bash
ssh -J 192.168.x.y ubuntu@10.10.0.4

microk8s kubectl get pods
No resources found in default namespace.
```

Note : Ici j'utilise le RPi comme "JumpHost" car je n'ai pas d'accès direct aux machines depuis mon LAN.

## Aller plus loin - déployer ses propres images sur ses machines

Ici, je tease un peu le(s) prochain(s) article(s). Ne vous attendez pas à lire la solution ici, il faudra attendre un peu ;-).

Par défaut, les OS disponibles sur MAAS proviennent d'images qui sont stockées sur maas.io. On y retrouve toutes les LTS d'Ubuntu jusqu'à la 12.04 (!?!) ainsi que les non-LTS de la 20.10 à la 23.10, et pour plusieurs architectures.

Dans la section "Other Images", il n'y a malheureusement que CentOS 7 et 8.

![](/2024/01/images-sync.png)

Pour utiliser d'autres images, on va pouvoir utiliser des *registry customs* depuis l'interface ou créer nos propres builds qu'on poussera sur l'interface.

Si vous êtes trop curieux, je vous laisse quand même quelques liens qui devraient vous donner une bonne idée de ce qu'on va faire la prochaine fois.

* [Documentation de Canonical MAAS - How to customise images](https://maas.io/docs/customising-images-for-specific-needs)
* [Discourse de Canonical MAAS - How to build MAAS images](https://discourse.maas.io/t/how-to-build-maas-images/5100)

En attendant, have fun !
