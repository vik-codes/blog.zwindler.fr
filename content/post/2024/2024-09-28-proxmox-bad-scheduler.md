---
title: 'Proxmox 8.2.5 : bad scheduler ! Bad !'
authors:
  - fabio
type: post
date: 2024-09-28T12:45:00+00:00
url: /2024/09/28/proxmox-bad-scheduler/
image: /2024/09/bad_scheduler.jpg
categories:
  - Stockage
  - systeme
  - Virtualisation
tags:
  - Proxmox VE
  - PVE
  - Scheduler
  - Backup

---

> Note : cet article n’est pas écrit par moi (zwindler) mais par mon ami et ancien collègue Fabio, que j’héberge avec grand plaisir sur le blog, comme je le fais parfois pour les copain·es qui n'ont pas de blog :-)

**<u>Note </u>**: TL;DR à la fin de la page, mais attention, vous allez faire pleurer un bébé dauphin. Vous êtes prévenus.

On est dimanche, l'odeur du café et des croissants plane encore dans le séjour, c'est donc un moment parfait pour ...

<img title="" src="/2024/09//2024-09-28-10-32-54-image.png" alt="" width="369" data-align="center">

(comment ça, "ah bon" ?)

J'en profite pour mettre à jour mon instance Proxmox en PVE 8.2.5.

La semaine passe, je reçois mes mails de backup des VM et je ne vois pas d'erreurs.

Au bout d'un moment, quelque chose me met la puce à l'oreille : je n'en reçois qu'un sur les 3 jobs (celui de 4h00) : 

![](/2024/09/2024-09-28-12-38-30-image.png)

## Début de l'enquête

En me connectant sur mon instance, j'observe le journal des tâches qui va m'aider beaucoup : 

![](/2024/09/2024-09-28-12-40-09-image.png)

<img title="" src="/2024/09//2024-09-28-10-53-59-image.png" alt="" width="243" data-align="center">

Je vois donc que les jobs ne se lancent même pas. Tentons donc d'en lancer un à la main avec le bouton "Run now" :

![](/2024/09/2024-09-28-12-40-27-image.png)

NOM DE ZEUS, le job fonctionne. J'ai bien la notification par mail, tout s'est bien passé. 

Le stockage de backup est un peu ric-rac, 93% d'utilisation, mais si le backup passe manuellement, y'a pas de raisons que ce soit ça (enfin, ça pourrait, mais je n'ai rien qui tourne la nuit en même temps que ces opérations).

Ce n'est pas non plus la notification par mail du backup, j'aurais des erreurs dans `/var/log/mail.log` et il y'aurait une ligne dans le journal des tâches en erreur. 

Donc : le job se lance manuellement, mais n'est pas lancé de manière périodique.

## Fin du mystère

Je commence à m'intéresser au pve-scheduler. En regardant ses logs (`journalctl -eu pve-scheduler.service` au besoin), j'observe quelque chose d'intéressant :

```log
400 Parameter verification failed.
job-id: invalid format - invalid configuration ID '1e66440f10abf0aeae5d19f5d0905235c69d811d:1'
', but neither allow_blessed, convert_blessed nor allow_tags settings are enabled (or TO_JSON/FREEZE method missing) at /usr/share/perl5/PVE/Jobs.pm line 228.
```

Je vois que la nomenclature des jobs problématiques est effectivement de type `1e66440f10abf0aeae5d19f5d0905235c69d811d:1` alors que le job de backup encore fonctionnel est `backup-684086d5-2e43`.

DING DING, WE GOT A WINNER ! Je tombe sur Google sur le thread du forum communautaire Proxmox parlant de ce problème : https://forum.proxmox.com/threads/scheduled-backups-didnt-run-after-8-2-5-upgrade.154686/

```log
pve-manager (8.2.6) bookworm; urgency=medium

* fix #5731: vzdump jobs: fix execution of converted jobs

-- Proxmox Support Team <support@proxmox.com>  Fri, 20 Sep 2024 17:47:17 +0200
```

Et effectivement, une upgrade est disponible :

```log
  --> apt list --upgradable
En train de lister... Fait
libpve-common-perl/stable 8.2.3 all [pouvant être mis à jour depuis : 8.2.2]
libpve-http-server-perl/stable 5.1.1 all [pouvant être mis à jour depuis : 5.1.0]
libpve-storage-perl/stable 8.2.5 all [pouvant être mis à jour depuis : 8.2.4]
pve-manager/stable 8.2.7 amd64 [pouvant être mis à jour depuis : 8.2.5]
```

Un coup d'apt upgrade plus tard, mes backups programmés refonctionnent \o/

**<u>TL;DR </u>**: Si vos jobs de backup ne se lancent pas après une mise à jour en 8.2.5 de votre instance Proxmox... Remettez à jour vos paquets, un fix est disponible :)
