---
title: Optimisation de PFsense dans Proxmox VE
authors:
  - zwindler
type: post
date: 2020-07-06T06:40:00+00:00
excerpt: Optimisation de machines virtuelles PFsense dans Proxmox VE
url: /2020/07/06/optimisation-de-pfsense-dans-proxmox-ve/
image: /2020/03/article_logo_pfsense_proxmox.png
categories:
  - systeme
tags:
  - kernel
  - KVM
  - optimisation
  - pfsense
  - Proxmox VE

---

## PFsense + Proxmox VE = <3
  
Si vous suivez ce blog, vous savez que je parle régulièrement de [Proxmox VE](/recherche/?keyword=proxmox). En particulier, j’ai travaillé avec 2 autres personnes ([M4vr0x](/recherche/?keyword=m4vr0x) et [Charles BORDET](/recherche/?keyword=charlesbordet) pour écrire 2 suites de plusieurs articles sur Proxmox et PFsense.

Dans ces deux suites d’articles, à chaque fois l’angle était le même. Débuter avec Proxmox en montant, de 0, un serveur Proxmox VE, mais sans non plus prendre trop de risques et en le sécurisant un maximum avant d’installer quoique ce soit dessus.

* [Proxmox VE 6 + pfsense sur un serveur dédié (1/2)](/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie)

Sauf que, dans les deux cas, j’ai trouvé que les perfs des machines virtuelles avec PFsense étaient assez... molles.

Heureusement, après quelques années de déterrage de posts sur les forums de Proxmox VE, on finit par chopper des tips and tricks que je vous partage aujourd’hui.

## Sur les vielles versions de Proxmox VE

La première chose qui m’a gêné lorsque j’ai déployé la consommation CPU de PFsense alors que je n’avais encore rien commencé à faire avec.

![](/2017/05/optimisation_proxmox_pfsense2.png) 

Autour de 7-8% en idle, alors que je ne lui envoie pour l’instant aucun trafic. Juste faire tourner l’OS dans le vide.

Pour ceux qui ne le savent pas, PFSense est un firewall basé sur l’OS FreeBSD. J’ai donc commencé à chercher des tips pour améliorer les perfs des VMs sous FreeBSD dans KVM.

Je suis tombé [là dessus](https://forum.proxmox.com/threads/high-cpu-idle-usage-with-pfsense-openbsd.19695/).

Sur les plus vieux Proxmox (<6 en tout cas), un gain significatif en terme de CPU peut être trouvé en modifiant 2 paramètres dans le fichier /boot/loader.conf`

```
hint.apic.0.clock=0
kern.hz=100
```

Là où la manœuvre est un peu "tricky" comme on peut dire, c’est que normalement, si vous êtes comme moi, même en ayant paramétré lors de l’installation le clavier Azerty, dans la console PFsense, vous allez être en Qwerty...
Bref, avec un layout de clavier qwerty sous les yeux vous devriez vous en sortir (des consoles KVM, iLO, iDRAC qui déconnent, j’ai l’habitude au bout de 10 ans), mais la vraie solution est de corriger le layout de la façon suivante :

```
cd /usr/share/syscons/keymaps
kbdcontrol -l fr.iso.kbd
#ou en qwerty virtue sur votre clavier azerty physique
cd !usr!shqre!syscons!key,qps
kbdcontrol )l fr:iso
```

YOUHOU ! Enfin en azerty dans cette fichue console !

![](/2017/05/optimisation_proxmox_pfsense3.png) 


Après reboot`, effectivement, sur un vieux Proxmox, j’ai gagné entre 3 et 4%. Pour d’autres personnes, les gains étaient bien plus significatifs, car ça dépend du CPU a priori.

En revanche, sur mon Proxmox VE 6, pas de gain. C’est même le contraire, je suis passé de 2,5% en moyenne à 4% ! Argh...

## Deuxième optim, qui marche presque à tous les coups

Là par contre, celle ci à de la valeur même sur PVE6. Proxmox VE ajoute systématiquement sur les VMs une option : "Use tablet for pointer".

Je n’ai pas trouvé beaucoup de documentation à ce sujet, il semblerait que cela serve à améliorer la précision du pointeur de la souris dans la console. Autant dire que pour PFsense, on s’en cogne !

Dans le menu de la VM, dans Options, cherchez Use tablet for pointer puis désactivez l’option :

![](/2020/05/pfsense_use_tablet.png)

> Vous devriez avoir ce message qui s’affiche dans la console 

Et là, les gains sont significatifs ! On passe de 2,5% à moins de 1%.

![](/2020/05/cpu_pfsense_pointer.png)

Ce qui est cool avec cette tips, c’est que ce conseil vaut aussi pour toutes les VMs que vous utilisez sans environnement graphique (et ça vaut aussi le coup de tester pour les envs graphiques).

Voilà ce que ça donne sur un serveur Ubuntu 18.04 avec environnement graphique, qui fonctionne aussi bien avant qu’après.

![](/2020/05/ubuntu_cpu_tablet.png) 

> Encore plus significatif ! 

## VirtIO

Depuis FreeBSD 9, les pilotes pour le [matériel virtuel de type VirtIO](https://www.linux-kvm.org/page/Virtio) sont directement intégrés. L’avantage de VirtIO par rapport à du matériel virtuel classique c’est que les pilotes sont "paravirtualisés". Un gros mot pour dire que le pilote est "au courant" qu’il s’agit de matériel virtuel, permettant de bien meilleure performance.

On a de la chance, la dernière version de PFsense (la 2.4.5) est basée sur FreeBSD 11 :-)

Si vous avez le choix donc, c’est VirtIO en priorité !

## Hardware offloading, c’est non !

Maintenant que j’ai dis ça... il faut quand même que je vous parle du pilote réseau VirtIO avec PFsense.

Si jamais vous l’installez tel quel et que vous ne faites rien de plus, vous allez avoir des surprises... Perfs pourries, NAT impossible, etc...

![](/2020/05/optim_reseau_pfsense_virtio_offloading.png) 

En fait, il est nécessaire de cocher plusieurs cases dans l’interface de PFsense.

Dans System / Advanced / Networking, il faut cocher les cases suivantes :

* Hardware TCP Segmentation Offloading
* Hardware Large Receive Offloading

![](/2020/05/pfsense_system_network.png) 

Et tout de suite, ça ira beaucoup mieux :)

## Sources et documentations

* [Forum Proxmox - High CPU idle usage with pfsense](https://forum.proxmox.com/threads/high-cpu-idle-usage-with-pfsense-openbsd.19695/)
* [Forum Proxmox - High load on idle KVM host](https://forum.proxmox.com/threads/high-cpu-load-on-idle-kvm-host.28287/)
* [Blog magiksys - pfsense configure keymap (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20190514223831/http://blog.magiksys.net/pfsense-configure-keymap)
* [Doc officielle Proxmox - Performance Tweaks](https://pve.proxmox.com/wiki/Performance_Tweaks)
* [Doc officielle Proxmox - KVM Virtual machines](https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines)
* [Doc officielle Netgate - virtualizing PFsense (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20201203112627/https://docs.netgate.com/pfsense/en/latest/recipes/virtualize-proxmox.html)
      
