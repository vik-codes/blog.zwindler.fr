---
title: Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (1/2)
authors:
  - zwindler
type: post
date: 2025-01-27T20:00:00+00:00
excerpt: "Tutoriel de déploiement d'un clusters d'hyperviseurs Proxmox VE 8 - partie 1"
url: /2025/01/27/deploiement-d-un-cluster-proxmox-ve-8-part-1/
image: /2025/02/proxmox8.png
categories:
  - Autohébergement
  - Cluster
  - Système
  - Virtualisation
tags:
  - kimsufi
  - KVM
  - Proxmox
  - Proxmox VE
  - serveur dédié
  - virtualisation

---

Note - cet article fait partie d'une suite d'articles :

* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (1/4)](/2025/01/27/deploiement-d-un-cluster-proxmox-ve-8-part-1)
* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (2/4)](/2025/02/17/deploiement-d-un-cluster-proxmox-ve-8-part-2/)
* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (3/4)](/2025/03/25/deploiement-d-un-cluster-proxmox-ve-8-part-3/)
* [Hors série - SDN en mode VXLAN avec des machines sur Internet](https://blog.zwindler.fr/2025/03/30/tutoriel-sdn-vxlan-proxmoxve-8/)
* Et *au moins* un autre à suivre

## Introduction

Ce qui suivent un peu le "lore" de ce blog savent que je suis un peu connu dans la communauté des bidouilleurs du dimanche pour avoir rédigé (ou co-rédigé) plusieurs tutos sur Proxmox VE. Je pense en particulier deux suites d'articles sur [Proxmox VE 5](https://blog.zwindler.fr/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/), puis [Proxmox VE 6](https://blog.zwindler.fr/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie/), pour créer de zéro un cluster de virtualisation avec Proxmox VE (et PFSense à l'époque).

C'est une nouvelle itération de ces tutos, basée cette fois-ci sur Proxmox VE 8, avec pas mal de choses qui changent et de nouvelles approches.

Le but ultime de cette suite d'articles est de disposer d'une plateforme de virtualisation avec Proxmox VE. Cette plateforme sera composée de plusieurs machines (idéalement 3, mais 2 ça fonctionne aussi), sécurisée, supervisée, hautement disponible, sauvegardée.

Il faudra suivre plusieurs articles pour y parvenir.

## Postulats de départ

**1-** Je pars du principe que vous n'avez pas de machines pour le faire à la maison et que vous n'avez pas envie ou les moyens d'investir dans un homelab ([même si ça peut être très rigolo, ça demande de l'investissement](/recherche/?keyword=homelab)). Cependant, si vous avez des machines à la maison, une grande partie de l'article reste valide, une fois les machines installées.

**2-** Comme Proxmox VE est une plateforme de virtualisation, je pars aussi du principe que vous voulez disposer de machines **dédiées** (physique) et pas de machines virtuelles, pour justement pouvoir virtualiser des OS entiers sans trop de problèmes (même si on a toujours l'option "nested virt", c'est moins glop).

Note : si vous n'avez pas besoin de virtualisation (exemple : pas de Windows ou d'OS un peu particulier), Proxmox VE est une super plateforme de containérisation, notamment grâce à LXC, qui permet de créer des containers Linux avec un OS entier, que vous pourrez gérer exactement comme une VM mais avec des performances bien meilleures (et quelques limitations dues au partage de kernel, mais c'est souvent suffisant). Vous pouvez aller lire [mes articles sur LXC](/recherche/?keyword=lxc) si ça vous intéresse.

**3-** J'aimerais attirer votre attention sur le fait que de nombreuses actions auraient pu dûu ?) être scriptées ou gérées via de "l'infrastructure as code". C'est plus dans l'air du temps, car plus robuste et plus fiable. Cependant, l'intérêt de cet article est de faire "à la main" pour comprendre ce qu'on fait, pas à pas, pas juste vous fournir une infrastructure "clé en main" que vous ne saurez pas gérer au premier pépin.

Si vous cherchez des méthodes plus industrielles pour déployer des clusters de virtualisation, vous en trouverez surement plein sur Internet, de la part d'autres blogueurs (certains français, certains sont même des copains). 

J'ai d'ailleurs moi-même plusieurs fois fait l'exercice avec Ansible ou [Rudder](/recherche/?keyword=rudder) par le passé, par exemple ici (note : ce code est obsolète) :

* [Un cluster Proxmox VE en 5 minutes avec Ansible](/2019/07/22/proxmox-en-5-min-ansible-tinc/)
* [github.com/zwindler/ansible-proxmoxve](https://github.com/zwindler/ansible-proxmoxve/tree/master)

Maintenant que l'objectif et le contexte est clair pour tout le monde, on peut commencer :\)

## Choix des machines

Comme on a dit qu'on n'auto-héberge pas, il faut trouver un hébergeur qui propose des machines physiques. Idéalement, quelque chose de pas trop cher, ça serait bien pour commencer. 

On va donc plutôt viser à trouver des machines peu onéreuses MAIS avec le support des instructions VT-x / AMD-v, ce qui est à peu près tous les CPUs qui fonctionnent encore aujourd'hui SAUF les Atom et les machines ARM type Raspberry.

Grosso modo, ça nous laisse les Kimsufi chez OVHCloud, les dédibox chez Scaleway et les machines chez Hetzner.

Chez Hetzner pour 45€, vous avez un i5 gen13, 64 Go de RAM et 2 SSD NVMe.

![](/2025/02/hetzner.png)

Chez OVHcloud, avec un peu de chance, vous pourrez tomber sur des machines autour des 15 - 20€ par mois avec du matériel plus ancien, mais largement suffisant pour ce qu'on va en faire.

![](/2025/02/ovhcloud.png)

Chez Scaleway, l'offre d'entrée de gamme est centrée sur les Atom Avoton ou de très vieux Xeon. L'Avoton C2750 reste une option valable, car c'est un octo-cores qui supporte le VT-x (contrairement au C2350, attention !). Mais bon, c'est du matoss de 2013 💀...

![](/2025/02/scaleway.png)

Pour les besoins de cet article, j'ai optimisé les coûts et je suis parti sur le serveur OVHcloud que je présente juste au-dessus (KS-GAME-LE), malheureusement uniquement disponible au Canada :\(. Mais 8 threads et 16 Go de RAM pour 12€ TTC par mois, ce n'est vraiment pas cher payé. 

Deux points noirs : 

* le stockage ridiculement petit pour de la virtualisation (seulement 240 Go, un seul disque)
* la latence - presque 100 ms depuis chez moi, contre 11 ms pour mon autre machine chez Scaleway

```
64 bytes from proxmox.example.org (203.0.113.78): icmp_seq=1 ttl=53 time=98.0 ms
64 bytes from proxmox.example.org (203.0.113.78): icmp_seq=2 ttl=53 time=97.5 ms
64 bytes from proxmox.example.org (203.0.113.78): icmp_seq=3 ttl=53 time=97.6 ms
64 bytes from proxmox.example.org (203.0.113.78): icmp_seq=4 ttl=53 time=97.7 ms
64 bytes from proxmox.example.org (203.0.113.78): icmp_seq=5 ttl=53 time=97.7 ms
```

## Installation de l'OS

Une fois commandé, le serveur est relativement rapidement disponible dans votre "manager OVH". On a un menu relativement intuitif pour installer directement Proxmox VE 8, quasiment à jour (les images fournies sont rebuildés très régulièrement avec toutes les mises à jour).

Pour lancer l'installation, on clique sur les "..." dans la partie Système d'exploitation (OS), puis on sélectionne l'install depuis un template OVH

![](/2025/02/install01.png)

![](/2025/02/install02.png)

On déroule la liste des types d'OS, on sélectionne Virtualisation, puis proxmox VE 8 (tant qu'à faire). J'ai aussi coché la case "Personnaliser la configuration des partitions", parce que par défaut, l'installation d'OVH utilise du stockage de type "LVM thick" pour la majorité de l'espace disque, alors qu'on va utiliser les fonctionnalités avancées de ZFS pour la suite :

![](/2025/02/install03.png)

![](/2025/02/install04.png)

Avant de valider l'installation, n'oubliez pas de modifier son nom (Custom hostname) pour éviter d'avoir besoin de le faire post install, puis d'ajouter une clé publique SSH :

![](/2025/02/install05.png)

![](/2025/02/install06.png)

## Première tâches post installation : upgrade et reboot

Il y a toute une petite série de trucs à faire quand on vient d'installer une machine, en particulier sur Proxmox VE, et on va essayer de se réfréner de "vite vite" se connecter à l'interface graphique.

De toute façon, on ne pourra pas s'y connecter, à l'interface graphique de Proxmox VE...

> Ah bon ???

Oui, car si on peut normalement se connecter avec l'utilisateur `root` de notre Linux, on ne va pas pouvoir dans le cas d'OVHcloud, tout simplement parce qu'on n'a PAS le mot de passe root. Heureusement qu'on a mis une clé SSH ;-)

On y reviendra plus tard, on a plus urgent à faire.

La première chose que moi, j'ai fait, c'est d'ajouter tout de suite un record DNS de type A pour que l'IP de ma machine corresponds à un FQDN. Pour cet article, j'y ferais référence de la manière suivante :

* hostname: myPVEhost
* FQDN: proxmox.example.org
* IP: 203.0.113.159

![](/2025/02/dns_ovh.png)

On se connecte donc sur l'IP de notre machine fraichement installée en SSH (root@IPmachine) et on va en profiter pour faire un peu de ménage.

La première chose à faire est de mettre à jour le serveur, idéalement suivi d'un reboot :

```bash
apt update && apt upgrade -y && reboot
```

Une fois le serveur revenu à la vie, on se reconnecte et active d'une manière ou d'une autre un système de mise à jour automatiques. Le plus simple c'est d'utiliser `unattended-upgrades` s'il n'est pas installé par défaut (il est possible qu'il y soit déjà) mais il existe des outils plus perfectionnés.

```bash
apt install unattended-upgrades
```

## C'est pour la sécurité

Une fois que c'est fait, je vous conseille de tout de suite CrowdSec. Ici, je me suis simplement basé sur la documentation officielle de crowdsec, pour ajouter le moteur de détection, le composant de remédiation (ici via `iptables`) :

* [CrowdSec.net - Installation Linux](https://doc.crowdsec.net/u/getting_started/installation/linux)

```bash
curl -s https://install.crowdsec.net | sudo sh
apt install crowdsec

# vérifier que le service crowdsec fonctionne
systemctl status crowdsec
● crowdsec.service - Crowdsec agent
     Loaded: loaded (/lib/systemd/system/crowdsec.service; enabled; preset: enabled)
     Active: active (running) since Sun 2025-01-26 21:04:26 UTC; 1min 56s ago
    Process: 73830 ExecStartPre=/usr/bin/crowdsec -c /etc/crowdsec/config.yaml -t -error (code=exited, status=0/SUCCESS)
   Main PID: 73862 (crowdsec)
      Tasks: 13 (limit: 19059)
     Memory: 33.1M
        CPU: 2.571s
     CGroup: /system.slice/crowdsec.service
             ├─73862 /usr/bin/crowdsec -c /etc/crowdsec/config.yaml
             └─73877 journalctl --follow -n 0 _SYSTEMD_UNIT=ssh.service

Jan 26 21:04:23 myPVEhost systemd[1]: Starting crowdsec.service - Crowdsec agent...
Jan 26 21:04:26 myPVEhost systemd[1]: Started crowdsec.service - Crowdsec agent.

# installer le moteur de remédiation
apt install crowdsec-firewall-bouncer
```

Une fois que Crowdsec est opérationnel, on peut lui ajouter la collection "fulljackz/proxmox", qu'il va falloir modifier (merci le super article de Julien Louis sur son blog slash-root.fr), qui va écouter les logs de la webUI pour détecter tout bruteforce et ban ceux qui tenteraient de le faire :

* https://app.crowdsec.net/hub/author/fulljackz/collections/proxmox
* [slash-root.fr - CrowdSec : Protéger l’authentification Proxmox](https://slash-root.fr/crowdsec-proteger-lauthentification-proxmox/)

```bash
cscli collections install fulljackz/proxmox
[...]
INFO Enabled fulljackz/proxmox                    
INFO Run 'sudo systemctl reload crowdsec' for the new configuration to be effective. 
```

Le pattern écouté par la parser proxmox n'est pas/plus bon avec les nouvelles versions

```console
Jan 26 21:23:14 myPVEhost pvedaemon[1250]: authentication failure; rhost=::ffff:203.0.113.159.78 user=coucou@pve msg=no such user ('coucou@pve')
```

On voit ici que Julien a rajouté le préfixe "::ffff:" dans la variable **PVE_AUTH_FAIL** du fichier `/etc/crowdsec/parsers/s01-parse/proxmox-logs.yaml`, mais quand je vois les cas de tests prévus dans la collection, j'ai l'impression que ce n'est pas nécessaire...

Dans tous les cas, on va créer un fichier `/etc/crowdsec/acquis.d/proxmox.yaml` pour que CrowdSec puisse commencer à analyser nos logs :

```bash
mkdir -p /etc/crowdsec/acquis.d/
cat > /etc/crowdsec/acquis.d/proxmox.yaml <<EOF
journalctl_filter:
  - _SYSTEMD_UNIT=pvedaemon.service
labels:
  type: syslog
EOF
```

On termine par recharger crowdsec et on regarde ~~le monde brûler~~ les scripts kiddies se faire bloquer.

```bash
systemctl reload crowdsec

cscli alerts list
╭────┬────────────────────┬───────────────────────────┬─────────┬──────────────────────────────────────────────────────────────┬───────────┬─────────────────────────────────────────╮
│ ID │        value       │           reason          │ country │                              as                              │ decisions │                created_at               │
├────┼────────────────────┼───────────────────────────┼─────────┼──────────────────────────────────────────────────────────────┼───────────┼─────────────────────────────────────────┤
│ 2  │ Ip:203.0.113.222 │ crowdsecurity/ssh-slow-bf │ IR      │ 202468 Gloubi Bo ulgua Co. ( Private Joint Stock)            │ ban:1     │ 2025-01-26 22:31:15.366187524 +0000 UTC │
╰────┴────────────────────┴───────────────────────────┴─────────┴──────────────────────────────────────────────────────────────┴───────────┴─────────────────────────────────────────╯
```

## Nagging popup

Dans la liste des petits trucs pénibles livrés de base avec Proxmox VE, il y avait avant le fait que Proxmox VE avait les dépôts apt entreprise sur toutes les installations, et il était nécessaire de préalablement les désactiver à la main avant de pouvoir faire les mises à jour.

C'était super pénible et les développeurs de Proxmox VE ont entendu (un peu) leur communauté et retiré cette obligation... pour la remplacer par une popup.

![](/2025/02/nagging_popup.png)

Alors, une popup, je veux bien ! C'est important de récompenser le travail des développeurs et de les soutenir. Mais est-ce que c'est vraiment nécessaire de le faire **à chaque login** ET **à chaque fois qu'on rafraîchit la liste des packages à mettre à jour** ?

C'est bien entendu une question rhétorique.

Évidement, de nombreuses personnes ont trouvé plusieurs méthodes pour désactiver le code JS responsable. Big up à [fabio](https://blog.zwindler.fr/authors/fabio/) pour sa version qui fonctionne bien.

```bash
sed -Ezi.bak "s/(function\(orig_cmd\) \{)/\1\n\torig_cmd\(\);\n\treturn;/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
```

Note : si comme moi vous vous êtes déjà connecté une fois, il faudra aussi nettoyer le cache sinon la popup restera...

## Création de groupes et d'utilisateurs pour l'interface graphique

> Ok ok, on a fait plein de trucs, est-ce qu'on peut se connecter maintenant ???

Mais ouiiii, on peut. De toute façon, j'en suis déjà à presque 15000 signes, cet article est beaucoup trop long, il faut abréger.

Dernière étape dans cet article, on va créer un administrateur pour se connecter à l'UI et un utilisateur qui nous servira plus tard pour le monitoring.

```bash
# vous n'êtes pas **vraiment** obligé d'appeler l'admin "zwindler" vous savez ?
pveum group add admin -comment "System Administrators"
pveum acl modify / -group admin -role Administrator
pveum useradd zwindler@pve
pveum usermod zwindler@pve -group admin
pveum passwd zwindler@pve

# notre utilisateur de monitoring
pveum groupadd monitoring -comment 'Monitoring group'
pveum aclmod / -group monitoring -role PVEAuditor
pveum useradd pve_exporter@pve
pveum usermod pve_exporter@pve -group monitoring
pveum passwd pve_exporter@pve
```

Allez, c'est bon, vous avez assez patienté, vous pouvez vous connecter à votre Proxmox VE ! Rendez-vous sur :

* https://@IPmachine:8006
ou
* https://proxmox.example.org:8006

Note : pour l'instant, le certificat est autosigné et le navigateur va nous remonter une erreur. On peut accepter d'ignorer le problème pour l'instant.

![](/2025/02/pve_login.png)

N'oubliez pas de changer le "realm" de PAM (les utilisateurs unix, qu'on n'utilise pas ici) à "Proxmox" pour pouvoir utiliser l'administrateur qu'on vient de créer.

![](/2025/02/proxmox8.png)

À bientôt pour la suite. Et en attendant, have fun!