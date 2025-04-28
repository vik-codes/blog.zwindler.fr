---
title: 'Mon NAS en 2024 - Jonsbo N2 × Intel N100 - software'
authors:
  - zwindler
type: post
date: 2024-05-19T12:00:00+02:00
url: /2024/05/19/mon-nas-en-2024-jonsbo-n100-part2/
image: /2024/05/truenas_installed.jpeg
categories:
  - Autohébergement
  - Matériel
tags:
  - Jonsbo N2
  - OpenMediaVault
  - OMV
  - TrueNAS
  - TrueNAS SCALE
  - TrueNAS Core
  - FreeNAS
  - FreeBSD
  - ZFS
  - zpool

---

Cet article fait partie d’une série dans laquelle je parle de mon nouveau NAS que j’ai construit moi-même :

* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - hardware](/2024/05/03/mon-nas-en-2024-jonsbo-n100-part1/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - software](/2024/05/19/mon-nas-en-2024-jonsbo-n100-part2/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - stress tests et conclusion](/2024/07/04/mon-nas-en-2024-jonsbo-n100-part3/)
* [Bonus - Installer plex sur TrueNAS (SCALE)](/2024/05/10/installer-plex-sur-truenas-scale/)

## Les critères software

Dans la partie précédente, j'avais listé mes critères hardware (et un à mi-chemin hard/soft, le fait de pouvoir faire des VMs). Ici, passons donc aux critères software :

- Mon critère principal est de pouvoir utiliser ZFS. Je suis fan inconditionnel de ce système de stockage qui sait tout faire. Je ferai peut-être un article rien que pour en parler d'ailleurs (et j'ai déjà plusieurs articles dont c'est le sujet secondaire).
- Le second critère est la possibilité d'avoir une interface pour gérer facilement les fonctions principales du NAS. J'ai géré mon NAS avec un OS linux et tout géré "à la main" pendant des années
- Dans les must have, il y a évidemment la possibilité de faire tout ce qu'on fait habituellement avec un NAS, à savoir la possibilité de faire du NFS, du Samba, du iSCSI, un serveur rsync, gérer des droits d'accès, monter des tunnels VPN…, Mais est-ce vraiment un critère ? N'importe quel OS linux peut le faire. Je note quand même 😉.
- La possibilité de lancer des apps, pour étendre les fonctions de base, de façon simple (comme un serveur Plex par exemple)
- La possibilité de lancer des containers ET des machines virtuelles

## Aparté sur ZFS et les prérequis en termes de RAM

J'en ai ma claque de lire sur le net ou sur Twitter que ZFS n'est pas adapté pour les petits besoins / petites machines. 

Je lisais encore hier un article qui disait qu'il ne fallait pas choisir un OS qui ne gère que ZFS car ZFS serait hyper gourmand , en particulier en RAM, et que cela empêcherait de l'utiliser sur des machines avec moins de 32 Go de RAM, et ECC en plus ! 😒

Il y a une extrêmement mauvaise compréhension des fonctionnalités de ZFS.

Oui, ZFS nécessite effectivement 1 Go de RAM (et vous avez réellement intérêt à ce que ce soit de l'ECC) par To d'espace disque... **SEULEMENT SI VOUS ACTIVEZ LA DÉDUPLICATION !**. Et autant dire que ce n'est recommandé que si vous savez ce que vous faites et les risques que cela implique. Je ne rentre pas dans les détails ici, on en reparlera dans l'article sur ZFS.

Et deuxième erreur, effectivement aussi, par défaut, ZFS réserve pour son cache la moitié de la RAM. Sauf que ce paramètre est... un paramètre ! S'il est déconseillé de le mettre à 0, ça fonctionne extrêmement bien, même si vous le réduisez fortement.

```bash
#Limiter la taille du cache RAM de ZFS à 4 Go
echo 4294967296 |sudo tee -a /sys/module/zfs/parameters/zfs_arc_max
cat /proc/spl/kstat/zfs/arcstats|grep -e "^size"
size                            4    4119613272
```

Je l'ai mis à 512 Mo sur des serveurs Proxmox VE qui n'ont que 4 Go de RAM, par exemple, et je sais qu'on peut encore descendre.

> The minimum amount of memory needed to install a Solaris system is 768 MB. However, for good ZFS performance, use at least one GB or more of memory.
> [ZFS Hardware and Software Requirements and Recommendations](https://docs.oracle.com/cd/E18752_01/html/819-5461/gbgxg.html)

La philosophie derrière ce choix et que de la RAM inutilisée est de la RAM gâchée, et en tant qu'ingénieur, je recherche l'efficience. L'apparente gourmandise de ZFS pour la RAM n'est pas un bug, c'est une feature.

## Choisir l'OS

Avec de rapides recherches, on trouve les usual suspects des NAS maison :

- [OpenMediaVault](https://www.openmediavault.org/)
- [TrueNAS](https://www.truenas.com/) (anciennement FreeNAS), historiquement basé sur FreeBSD (Core), mais qui dispose maintenant d'une version Linux (SCALE)
- Depuis quelques années, on parle aussi pas mal de UnRAID, un OS orienté NAS sous Linux. Le produit est payant.

En plus confidentiel, il y a aussi :
- [XigmaNAS](https://xigmanas.com/xnaswp/) (ex NAS4Free, un fork de FreeNAS)
- [RockStor](https://rockstor.com/) (base CentOS + btrfs)
- [Xpenology](https://xpenology.org/), un projet qui récupère le DSM de Synology, dont j'ai un gros doute sur la légalité 
- ou même, l'OS QNAP qu'on peut installer sur n'importe quel matériel moyennant un coût mensuel 

## La tribu réunifiée a décidé de vous éliminer

Mes critères éliminent directement Windows (ce n'est pas vraiment comme si ça avait été un candidat sérieux 🤣). Quoique, j'avais fait brièvement du Windows Media Server à l'époque où ça existait encore, et aujourd'hui avec [ReFS](https://learn.microsoft.com/fr-fr/windows-server/storage/refs/refs-overview), on aurait presque (presque ?) un candidat pour un NAS de hobbyist.

J'élimine aussi Xpenology, projet que je connais depuis très longtemps, et dans lequel je n'ai strictement aucune confiance. Et je pars de l'écosystème QNAP en partie à cause de son OS, donc ce n'est pas pour y retourner 😅

RockStor est trop confidentiel à mon goût, et je suis pas fan de btrfs qui a été trop instable pendant de nombreuses années.

XigmaNAS (ex NAS4Free) a sûrement des arguments, mais c'est TrueNAS qui a tiré son épingle du jeu et raffle le gros de la communauté.

UnRAID m'intéresse, mais le côté payant du projet est un problème. La version d'essai est très courte, et je n'avais pas spécialement le temps pour le tester de fond en comble au point de pouvoir décider si j'étais prêt à lâcher 49$ par an (tout de même !).

![](/2024/05/unraid.png)

## Le choix final

OpenMediaVault et TrueNAS (Core et SCALE) sont les alternatives les plus crédibles par rapport à mes critères.

TrueNAS Core (sous FreeBSD) était mon premier choix, pour son support naturel du ZFS et aussi le fait que je voulais apprendre à utiliser l'univers BSD que je n'ai jamais exploré.

C'était d'ailleurs FreeNAS que j'avais voulu choisir à l'époque (pour les mêmes raisons) de mon NAS de 2011, mais j'avais finalement choisi Ubuntu, car cette machine me servait aussi de mediacenter. TrueNAS dispose bien d'une interface web, de containers et de VMs (pour les deux versions).

Cependant, plusieurs personnes m'ont alerté sur la possibilité que la version TrueNAS Core disparaisse à terme au profit de la version Linux (SCALE). Et le critère "gestion facile d'apps" n'est pas disponible sur Core (ce sont des charts helm, et Core n'a pas la fonction Kubernetes qu'à SCALE)

Restait donc TrueNAS SCALE et OpenMediaVault, qui sont très similaires en termes de fonctionnalités et qui cochent toutes les cases. Et même si OpenMediaVault supporte ZFS, le fait que ce ne soit pas l'option par défaut **m'a fait opter TrueNAS SCALE** (mais ça aurait très bien pu être OMV).

## Installation

Rien d'incroyable ici, il suffit d'installer l'OS comme n'importe quel autre linux.

[On suit la doc](https://www.truenas.com/docs/scale/gettingstarted/install/installingscale/) : on récupère l'ISO sur le site, on l'écrit sur une clé USB bootable et on suit ensuite le processus d'installation.

![](/2024/05/SCALEInstallMainScreen.png)

TrueNAS SCALE demande 8 Go de RAM ou mieux. A mon avis, c'est surestimé (pour être large) et on doit pouvoir lancer SCALE dans de bonnes conditions avec moins, mais je suis content d'avoir pris 16 Go.

> TrueNAS SCALE is very flexible and can run on any x86_64 compatible (Intel or AMD) processor. SCALE requires at least 8GB of RAM (more is better) and a 20GB Boot Device.

"Bêtement", j'ai acheté un NVMe avec pas mal de patate de 512 Go, sauf que TrueNAS utilise tout l'espace par défaut. J'ai donc un NVMe quasiment inutile... Un peu rageant.

Une fois installé, on redémarre la machine et on peut se connecter sur l'UI :

![](/2024/05/truenas_installed.jpeg)

Le dashboard principal est customisable : on peut modifier les tuiles qu'on veut afficher. Sur la gauche, les menus avec toutes les opérations courantes à réaliser sur le NAS apparaissent.

## Conclusion 

Je m'arrête là-dessus, on créera notre pool et les premiers partages lors des tests de performance dans le prochain article.

D'ici là, have fun !
