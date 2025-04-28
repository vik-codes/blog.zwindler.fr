---
title: 'Premiers pas avec XCP NG'
authors:
  - zwindler
type: post
date: 2022-10-10T06:00:00+02:00
excerpt: "Premiers pas avec XCP-NG"
url: /2022/07/24/premiers-pas-xcp-ng
image: /2022/07/pve-to-xcpng.jpg
categories:
  - Virtualisation
tags:
  - XCP-NG
  - Xen
  - XenServer
---

## Introduction

Si vous suivez ce blog, vous savez peut-être qu'après des années de Proxmox VE, j'ai commencé à regarder pour voir ce qui se faisait d'autre sur le marché des hyperviseurs open source.

J'ai rencontré les équipes de [Vates](https://vates.fr/) et ils m'ont donné l'envie de tester le couple XCP-NG / Xen Orchestra. Ca et aussi le fait que Cécile et Nidouille en ont dit beaucoup de bien.

En particulier, [Nidouille a fait plusieurs séries de benchs](https://github.com/Nidouille/benchmarks) que je vous conseille et qui montreny de très belles perfs de XCP-ng.

Vous pouvez retrouver les deux articles que j'avais écrits à ce sujet :
* [Migrer une VM de Proxmox VE vers XCP NG](https://blog.zwindler.fr/2022/07/24/migrer-une-vm-de-proxmoxve-vers-xcp-ng/)
* [Mieux migrer ses VM de Proxmox VE vers XCP NG (part 2)](https://blog.zwindler.fr/2022/08/08/migrer-une-vm-de-proxmoxve-vers-xcp-ng/)

Dans cet article, je vais vraiment me limiter aux tout premiers pas. On ira plus loin dans un article ultérieur, notamment pour passer outre les quelques limitations qu'on va rencontrer.

## C'est quoi XCP-NG / Xen Orchestra ?

XCP-NG est une distribution clé en main de virtualisation [open source](https://github.com/xcp-ng/xcp), basée sur XenServer (lui-même basé sur Xen). Historiquement Xen était surtout connu en tant que paravirtualiseur (un Dom0 qui partage le même kernel avec les DomU) mais depuis bien longtemps, Xen a fait un gros virage et fourni de la virtualisation complète comme les autres.

> XCP-ng is a virtualization platform based on Xen Source and Citrix® Hypervisor (formerly XenServer). XCP-ng stands for Xen Cloud Platform - New Generation and is a tribute to the old Open Source project XCP, which was abandoned when XenServer was open-sourced in 2013.

Xen Orchestra est une webUI [open source](https://github.com/vatesfr/xen-orchestra), permettant d'ajouter des fonctionnalités supplémentaires au-dessus de clusters XenServer et/ou XCP-NG, telles que la gestion de flottes de serveurs, les statistiques, la sauvegarde /restauration de machines...

Si je voulais donner une comparaison simple avec l'écosystème VMware, je dirais que XCP-ng est l'ESXi et que Xen Orchestra est le vCenter.

## Choix du lab

A la base, je voulais installer XCP-ng sur des machines peu chères que j'aurais pu louer un mois ou deux. Cependant, contrairement à Proxmox VE qu'il est possible d'installer au-dessus d'un Debian 11, il n'est pas simple d'installer l'hyperviseur d'XCP-ng au-dessus d'une machine existante.

De plus, peu de providers de machines baremetal disposent de templates pour XCP-ng à l'heure actuelle (à priori Ikoula). Rien chez OVH, Scaleway, oneProvider...

J'ai donc changé mon fusil d'épaule et investi pour mon lab dans deux petits Dell micro d'occasion, un 7040 (merci Bosco) et un 3050. 

Ce sont deux machines très compactes, qui ne consomment rien (~10w chaque) et qui sont quand même suffisamment puissantes pour pouvoir tester des trucs (i5-6500T + 8 Go de DDR4, extensible).

J'envisage d'ailleurs de me séparer [de mon "gros" serveur E3-1220v5 et de son imposant node 304 de Fractal design à terme](https://blog.zwindler.fr/2017/04/04/installation-dun-serveur-compact-a-la-maison/).

## Installation du lab

L'installation est relativement sans surprise. Sur le site de XCP-ng, on a un [ISO](https://mirrors.xcp-ng.org/isos/8.2/xcp-ng-8.2.1.iso?https=1) et on le copie sur une clé USB

```bash
wget https://mirrors.xcp-ng.org/isos/8.2/xcp-ng-8.2.1.iso?https=1
dd if=xcp-ng-8.2.1.iso of=/dev/sdX bs=8M oflag=direct 
```

On branche la clé sur le serveur à installer et on boot. Le processus d'installation est un processus classique avec une TUI bleue comme vous en avez surement vu des milliers dans votre vie de vieux sysadmins. C'est un peu oldschool mais ça fonctionne. 

Note: il est également possible d'automatiser l'install en PXE/iPXE sur des providers comme Equinix Metal (mais c'est hors budget pour moi).

Une fois l'installation terminée, on reboot et on se retrouve avec une interface que j'ai là aussi vu des dizaines de fois : le menu de XenServer :

![](/2022/07/pve-to-xcpng.jpg)

## Dans le ventre

De la bouche des devs de XCP-ng, on ne devrait pas avoir à se connecter sur les hyperviseurs. J'ai quand même été voir ce qu'ils avaient dans le ventre :-p.

Une fois connecté, on se rend vite compte qu'il s'agit d'une base RHEL, Centos pour être plus précis. Ca n'est pas vraiment une grande surprise, sachant que c'est la même base que XenServer que j'avais testé il y a 12 ans ([j'en avais parlé ici](https://blog.zwindler.fr/recherche/?keyword=xenserver))...

Première surprise, l'OS basé sur CentOS... en version 7... 😬

Ca commence à dater un peu, la sortie du premier CentOS 7 date de 2014, et la toute dernière version mineure (7.9) est sortie en 2020.

Surtout quand on connaît les dramas qui ont eu lieu autour de centOS / RHEL, j'aurais pas choisi cette OS.

> On 8 December 2020, the CentOS Project announced that the distribution would be discontinued at the end of 2021 in order to focus on CentOS Stream. The community's response to this announcement was overwhelmingly negative.
> https://en.wikipedia.org/wiki/CentOS

[Vates justifie ce choix technique dans ce billet de blog](https://xcp-ng.org/blog/2020/12/17/centos-and-xcpng-future/).

> Nous n'utilisons CentOS que pour les paquets "user land". Xen et le noyau Linux sont des builds custom avec certains patches. Concernant le drama CentOS nous sommes peu/pas affecté justement pour ces raisons

Niveau kernel, c'est pas fou non plus. 

```bash
uname -a
Linux xxx.zwindler.fr 4.19.0+1 #1 SMP Thu Jan 13 12:55:45 CET 2022 x86_64 x86_64 x86_64 GNU/Linux
```

Le 4.19 est le dernier LTS de la branche 4, avec certes un support jusqu'en 2024 mais on se prive quand même de pas mal d'améliorations de perfs de la branche 5, notamment pour le matoss récent... Dommage. 

Enfin bon c'est toujours mieux que le kernel shippé avec CentOS 7 (3.10, LOL), mais à côté de ça, Proxmox VE 7.2 tourne en Bullseye avec un kernel custom en 5.15.

## Xen Orchestra

C'est là où ça devient un peu moins naturel. Si vous allez sur le site pour installer Xen Orchestra [xen-orchestra.com/#!/xoa](https://xen-orchestra.com/#!/xoa) (que je vais abrévier XOA), on va vous demander de rentrer une IP, un login (root) et un mot de passe.

Eeeeeuh, what?

![](/2022/10/xo_install.png)

Heureusement, la petite mention juste en dessous nous explique que tout sera fait en local et qu'il n'y a rien qui partira chez Vates 😏. En réalité, la page se connecte directement à votre host et déploie une VM appliance contenant Xen Orchestra prêt à l'emploi.

Bon... j'ai vérifié les trames envoyées sans rentrer mon vrai mot de passe et ça a l'air safe... Mais j'ai quand même préféré [déployer la VM XOA via un script ou l'import d'un XVA 😏](https://xen-orchestra.com/docs/xoa.html#alternative-install) :

![](/2022/10/xoa_script.png)

Note: 8.8.8.8 en DNS par défaut... bof bof.

A l'issue de l'opération, vous avez donc déployé sur un de vos hosts XCP-ng une appliance XOA qui va vous permettre de piloter votre cluster.

~~Note: XOA est une appliance Debian 9 😬😬😬~~ Après vérification, je ne sais pas pourquoi j'avais écris ça dans mes notes. C'est du Debian 11 donc RAS.

## Premiers pas dans XOA

Voilà à quoi ressemble le menu principal une fois loggué. On arrive sur une page avec la liste de nos VMs :

![](/2022/10/xoa_home.png)

Un peu perturbant, par défaut un filtre est appliqué et n'affiche QUE les VMs allumées. Personnellement j'aurais préféré voir aussi celles qui ne le sont pas et je le désactive tout le temps.

Niveau UI, le style tranche avec celui de Proxmox VE. Certains reprochent à XOA d'avoir un style "UI playskool" et je comprends un peu où ils veulent en venir...

![](/2022/10/xoa_ui.png)

Les tailles des polices sont différentes d'un menu à l'autre, sans réelle cohérence, les boutons sont colorés, ya des tableaux jamais pareil d'un menu à l'autre ... C'est très déstabilisant de premier abord et donne une impression pas très "pro", à l'opposé des capacités de l'outil.

Heureusement, une version plus léchée devrait faire son arrivée dans les mois qui viennent (cf [le blog de XOA](https://xen-orchestra.com/blog/ux-ui-design-for-xo-and-xolite/)). J'ai vraiment hâte de voir ce que ça donne car ça fait beaucoup plus sérieux sur les captures.

![](/2022/10/XO-Blog---UX-UI-Design-for-XO-and-XOLite.jpg)

## Version gratuite limitée ?

Un autre point déstabilisant de Xen Orchestra est que quand on navigue dans les menus, une petite moitié des menus et des fonctionnalités sont réservés à la version payante de l'outil. Certains menus ne manquent pas forcément pour un démarrage. Mais d'autres, c'est carrément problématique. 

Typiquement, l'UI pour mettre à jour les serveurs n'est pas accessible sans licence. On a un panneau rouge pour nous informer qu'un serveur doit être MAJ, mais on ne peut pas le faire...

![](/2022/10/xcpng_upgrade.png)

J'ai failli arrêter mon test, la première fois que j'ai vu ça... Un hyperviseur que je ne peux pas mettre à jour via l'UI, c'est no-go.

Je trouve ce point hyper frustrant, car en réalité on peut contourner cette limitation, puisque l'outil est entièrement open source. C'est même volontaire et assumé de la part des devs de XOA/XCP-ng (lien cassé, Nicolas n'est plus sur Twitter) : il faut "juste" le builder soit même.

![](/2022/10/xoa_limitations.png)

Sauf qu'en attendant, beaucoup d'admins qui auront rapidement testé l'outil auront eu l'impression d'un freeware hyper bridé alors que ce n'est pas vraiment le cas. Je trouve qu'il y a un vrai manque au niveau communication et de clarté de ce côté.

## Conclusion

Voilà pour ces premières impressions avec XCP-NG. Je m'arrête ici alors que je n'ai fait une présentation rapide de mon lab et des premiers menus, car on dépasse déjà les 11000 signes.

Globalement, l'UI/UX a vraiment besoin d'être retravaillée et ça tombe bien que Vates soit en train de travailler là-dessus car l'impression que donne l'outil n'est pas en phase avec ses capacités.

Au-delà de l'aspect visuel, les fonctionnalités semblent présentes, mais sont cachées par la mise en avant du support pro. Pour des gens comme moi qui cherchent une solution de lab perso ou de gens qui ne chercheraient pas à comprendre quelles sont les alternatives à la version payante, ça peut être repoussant.

~~Dernier point, certains choix techniques me paraissent très bizarres (CentOS 7, Debian 9) et il faudra que j'en reparle avec l'équipe de Vates...~~

Dans les prochains articles, je m'attaquerai à la partie utilisation (par exemple les sauvegardes ou la réplication, une création de VM puis migration à chaud) et probablement aussi au test de XOA non bridé.

Dites-moi ce qui vous intéresse en premier, histoire que je mette l'accent là-dessus tout de suite

En attendant, have fun !

## Bonus

Pour automatiser les mises à jour, en attendant d'avoir débridé XOA, j'ai ajouté l'utilitaire `yum-cron`

```bash
yum -y install yum-cron
systemctl start yum-cron systemctl enable yum-cron
cd /etc/yum/ vim yum-cron.conf
cd /var/log/ cat cron | grep yum-daily
```

## Sources

* [Site de XCP-ng](https://xcp-ng.org/)
* [Site de Xen Orchestra](https://xen-orchestra.com)
* [Benchs de Nidouille](https://github.com/Nidouille/benchmarks)
