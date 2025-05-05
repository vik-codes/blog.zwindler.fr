---
title: Proxmox VE 6 + pfsense sur un serveur dédié (1/2)
authors:
  - CharlesBordet
  - zwindler
type: post
date: 2020-03-02T07:35:00+00:00
excerpt: "Tutoriel de déploiement d'un serveur Proxmox VE 6 sécurisé par un serveur PFsense"
url: /2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie/
image: /2020/03/article_logo_pfsense_proxmox.png
categories:
  - autohebergement
  - Cluster
  - Système
  - Virtualisation
tags:
  - iptables
  - kimsufi
  - KVM
  - pfsense
  - Proxmox
  - serveur dédié
  - virtualisation

---

> Note de zwindler : cet article a été co-écrit par [Charles Bordet](https://www.charlesbordet.com/), et se veut être une version à jour de [cette suite d’articles écrits sur ce blog](/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/) (mais avec des versions obsolètes de Proxmox et de PFSense). Merci à lui !

<hr />
  
## Introduction
  


Je me présente rapidement : je m’appelle [Charles](https://www.charlesbordet.com), je suis data scientist, et j’utilise le serveur dont je vais vous décrire l’installation pour mes analyses de données et mes outils professionnels. Mais avant de commencer, retournons un peu en arrière.

**Note de zwindler** : vous pouvez [sauter l’intro et passer directement à l’architecture](#archi) si vous voulez).

Il y a un peu plus d’un an, je souscrivais pour la première fois à un VPS. Mon objectif ? Sortir de l’écosystème Google en auto-hébergeant mes propres services.

J’avais déjà eu l’occasion d’utiliser des serveurs sur EC2, mais de manière très ponctuelle et plutôt limitée. J’avais besoin d’une grosse machine pour faire des calculs et 2 jours plus tard je coupais tout. Rien à voir avec l’hébergement continu, performant et sécurisé de services comme un Nextcloud, un Gitlab, et autres applis web que je voulais m’auto-fournir. C’était avant tout un test pour moi.

Est-ce que j’allais trouver dans le monde de l’open source suffisamment de bonnes alternatives, et est-ce que j’allais réussir à les héberger ?

Bilan au bout d’un an : J’en suis plutôt content. J’ai beaucoup appris et j’ai remplacé quasi tous les services Google.

Sauf que... Mes services sont répartis sur plusieurs VPS, et c’est un peu le bordel. Et puis j’ai pas de backups, à part ceux proposés par Hetzner. Mes bases de données ne sont pas répliquées. Et puis.. niveau sécurité, y’avait rien.

C’est à ce moment-là que je suis retourné sur le blog qui tout au début m’avait permis de démarrer (un certain Dryusdan), et j’ai trouvé cet article : [Installer un cluster hyperconvergé avec Proxmox, Ceph, Tinc, OpenVSwitch](https://www.dryusdan.fr/installer-un-cluster-proxmox-ceph-tinc-openvswitch/). C’est marrant parce que je ne comprenais rien à ce titre, mais il m’a servi de nouveau point de départ. De fil en aiguille, je suis tombé sur l’article de m4vr0x : [Déploiement de Proxmox VE 5 sur un serveur dédié – part 1](/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/).

Et là, j’ai compris. Proxmox allait me servir à démarrer/arrêter mes propres VPS de manière complètement flexible, et en plus m4vr0x me présentait un tuto détaillé étape par étape pour avoir une infrastructure robuste et sécurisée.

Top !

J’ai commencé le tutoriel, et puis je me suis rapidement aperçu que ce que j’avais à l’écran n’était pas strictement identique aux étapes décrites par m4vr0x. Mon plus gros problème, c’est que je ne comprenais rien à ce que je faisais. C’est quoi une gateway ? Un routeur ? iptables ? Une masquerade ?

Si c’est votre cas aussi, j’ai pris un [cours de réseau sur OpenClassrooms](https://openclassrooms.com/fr/courses/857447-apprenez-le-fonctionnement-des-reseaux-tcp-ip) que je vous conseille très fortement si vous aussi vous avez l’impression d’avoir loupé un trimestre à la fac et que iptables n’était même pas parmi les langues étrangères proposées.



![](/2020/02/apprennez_tcp_ip.png) 


Et deux mois plus tard... ça y est : j’ai mis en place mon serveur dédié avec l’hyperviseur Proxmox, sécurisé par PFSense. Certains services sont accessibles sur Internet, et d’autres seulement via le VPN privé, selon l’usage. Et mon objectif du jour, c’est de reprendre le tutoriel de m4vr0x, le remettre au goût du jour de 2020, et aussi de détailler les étapes où je me suis retrouvé bloqué, afin que vous ne le soyez pas.

Mon gros problème quand j’ai commencé à rentrer dans ce monde de l’administration système, c’était le langage. Imaginez lire le code des impôts. Vous comprenez rien. Par contre, quand vous allez sur service-public.fr, on vous explique la loi avec des termes plus simples de tous les jours. Cet article, je l’adresse aussi à mon moi d’il y a deux mois qui ne comprenait rien à ces termes.

Prêt ? C’est parti !

## L’architecture
  
Sans surprise, je vais reprendre l’architecture proposée par m4vr0x et son magnifique schéma : 

![](/2017/07/proxmox-install_simple-infra-map.jpg)

Ça c’est notre objectif final qu’on détaillera un peu plus tard.

### Proxmox VE

![](/2020/02/proxmox_logo.png)

Proxmox, c’est une solution d’hyperviseur, de virtualisation, qui s’installe sur un serveur dédié. À la place d’avoir une Debian classique, vous avez une Debian légèrement modifiée qui vous donne Proxmox. Donc Proxmox, c’est avant tout un OS.

C’est opensource et gratuit.

Ce que j’aurais aimé qu’on me dise dès le début, c’est que Proxmox, c’est un peu comme VMware ou VirtualBox. On l’installe, et ensuite on peut créer des machines virtuelles dont on configure les composants comme on veut.

### PFSense
  


![](/2020/02/pfsense.png) 


PFSense, c’est aussi un OS complet, cette fois-ci basé sur FreeBSD, qui va nous servir de pare-feu, de routeur, et aussi de VPN. Je suis sûr qu’il y a plein d’autres choses qu’on peut faire avec PFSense.

Au début, je me demandais pourquoi utiliser PFSense alors que jusqu’ici j’utilisais toujours `ufw` qui était pas mal. En plus, Proxmox propose lui aussi des fonctionnalités de pare-feu.

Déjà un intérêt c’est que PFSense filtre les paquets avant qu’ils arrivent sur la VM. Alors que `ufw` (ou iptables, c’est pareil) regarde les paquets une fois qu’ils sont sur la VM. Subtile différence.

Ensuite, c’est une solution complète avec une belle interface qui va faire plus qu’un firewall basique.
  
* La PFSense permet d’isoler le réseau local (LAN) qui va contenir toutes les VMs d’Internet.
* La PFSense a une belle interface qui permet d’aller voir les logs, extraire les paquets (très utile pour débugger !), et paramétrer tout ce qui a besoin de l’être.
* La PFSense est remplie d’outils utiles : Routeur, serveur DHCP, VPN, DNS, et sûrement d’autres que je ne comprends pas mais qui seront utiles plus tard pendant la vie d’adulte.
      
  
### Le hardware
  
  
Pas de comparaison de différents providers ici.

Pour ma part, j’utilise Hetzner depuis le début, et c’est eux que j’ai choisi pour mon serveur dédié, notamment via le [Server Auction](https://www.hetzner.com/sb).

J’ai pris une grosse machine avec :
  
* un Intel Xeon E5-1650V3
* 2 HDD de 4 To
* 256 Go de RAM
* 1 IP publique (pas de failover pour le moment mais ça ne change strictement rien à ce tuto)
      
  
Tout ça pour environ 85€/mois. Bon plan ? Mauvais plan ? En vrai j’en sais trop rien. Je tenais à avoir beaucoup beaucoup de RAM parce que j’en ai régulièrement besoin pour mes analyses de données.

Le seul hic c’est que comme le serveur est hébergé en Allemagne, quand je me connecte au VPN tout l’internet passe en allemand.

### L’installation
  
  
Hetzner ne propose pas [directement d’image Proxmox](https://wiki.hetzner.de/index.php/Standardimages/en), ce qui est un peu dommage. [Les pages d’aide](https://community.hetzner.com/tutorials/install-and-configure-proxmox_ve) proposent de partir d’une Debian et d’upgrader vers Proxmox tout à la main. Franchement pas évident.

Heureusement, il existe une image _non officielle_ que j’ai utilisée et avec laquelle tout s’est très bien passé.

Pour ça, il suffit de démarrer le serveur en mode _Rescue_ (on peut l’activer à tout moment dans l’interface).

Une fois connecté en SSH, on accède aux images avec l’utilitaire `installimage`. Dans la liste des OS proposés, choisissez « Other (!!NO SUPPORT!!) ». Oui hein c’est pas très rassurant tous ces points d’exclamation. Mais faites-moi confiance.

C’est là que les images Proxmox apparaissent. J’en ai 3 pour Jessie, Strech, et Buster, qui correspondent respectivement à Debian 8, 9, et 10. Évidemment on va prendre Buster.

Ensuite, un éditeur va s’ouvrir pour choisir la configuration du Proxmox.

HARD DISK DRIVE(S)

Ici je ne touche à rien, je monte mes deux HDDs :

```
DRIVE1 /dev/sda
DRIVE2 /dev/sdb
```



SOFTWARE RAID

Ici je laisse les valeurs par défaut aussi, ce qui me donne un Software RAID 1 :

```
SWRAID 1
SWRAIDLEVEL 1
```



HOSTNAME

Ici, on demande spécifiquement un FQDN. Par exemple : `proxmox.example.org`. Vous pouvez d’ailleurs dès maintenant paramétrer vos DNS pour qu’ils redirigent vers ce FQDN.

PARTITIONS

Et finalement, la partie la plus marrante, on crée les partitions.

L’idée c’est d’avoir une partition pour le boot, et une partie pour LVM (Logical Volume Management). Moi ce que je comprends c’est que LVM est un système de partitionnement qui est plus flexible que la méthode traditionnelle et donc plus adaptée pour ce qu’on veut faire.

Ensuite, dans la partie LVM, je mets une partition swap et tout le reste pour mon utilisation future.

Au final, ça donne :


```
PART /boot ext3 512M
PART lvm vg0 all
LV vg0 swap swap swap 2G
LV vg0 root / ext4 all
```



OPERATING SYSTEM IMAGE

Là on change rien. Hetzner a déjà pré-rempli avec l’image Proxmox qu’on souhaite utiliser.

Pour sortir de ce fichier, on peut faire F10. Bon ça marche pas chez moi, à la place j’ai le menu « File » de ma console qui se déroule. Du coup je fais deux fois _Échap_ et ça marche aussi. On enregistre évidemment.

Et l’installation va se faire toute seule.

Si vous avez fait une bêtise, pas d’inquiétude. Redémarrez le serveur en mode _Rescue_ et placez-vous sur la case départ (vous ne toucherez rien du tout par contre).
Une fois l’installation terminée, redémarrez, puis vous aurez accès à l’interface de Proxmox à l’adresse https://proxmox.example.org:8006 (changez avec votre FQDN bien entendu !).

## Première ligne de sécurité
  
  
### Le serveur SSH
  
  
Votre serveur est up et déjà des petits malins frappent à la porte. S’il y a un truc que j’ai appris ces deux derniers mois, c’est qu’il y a des tonnes de bots dont le seul objectif est de parcourir toutes les IPv4 (ça se fait en quelques heures) et de toquer à la plupart des ports _classiques_.

Maintenant imaginez qu’un bot tombe sur un prompt où on lui demande un mot de passe. Que va-t-il faire ? Bruteforcer le mot de passe bien sûr !

J’ai redémarré mon serveur à 06:39:35, et à 06:40:09 je recevais ma première attaque.



![](/2020/02/ssh_bot_scan.png) 


La première chose que je fais, c’est sécuriser le serveur SSH :
  
* Je crée un nouvel utilisateur principal avec un accès sudo
* J’interdis de se connecter directement à root en SSH
* J’interdis de se connecter avec un mot de passe en SSH
* Je change le port du SSH. Prenez un port aléatoire après 1000 (en général je regarde l’heure qu’il est et ça me donne un numéro de port)
      
  
Pour la dernière règle (changer le port), c’est optionnel car ce n’est pas de la sécurité en soit (ça n’arrêtera pas un attaquant), mais ça va drastiquement réduire le « bruit de fond », la plupart des bots ne cherchant que les ports par défaut.

Voici les commandes :


```
# adduser tomtom
# usermod -aG sudo tomtom
# su - tomtom
# mkdir ~/.ssh
# chmod 700 ~/.ssh
# vim ~/.ssh/authorized_keys # là j'ajoute ma clé SSH
# chmod 600 ~/.ssh/authorized_keys
```



Puis je modifie le fichier `/etc/ssh/sshd_config` avec les options suivantes :


```
Port 21153
PermitRootLogin no
PasswordAuthentication no
```



Et puis on redémarre le serveur SSH : `/etc/init.d/ssh restart`.

Pro tip : Assurez-vous bien de pouvoir vous connecter avec l’utilisateur que vous venez de créer. Sinon, vous êtes bon pour reprendre de zéro :D

Juste avec ça, vous devriez voir le nombre d’attaques dans `/var/log/auth.log` drastiquement se réduire.

Mais ça ne suffit pas et ça ne protège pas d’une attaque bruteforce. Pour ça, il va falloir installer `fail2ban`. Cet outil va lire les logs, identifier un attaquant (quelqu’un qui essaie de forcer la porte d’entrée) et bannir son IP. On peut le configurer pour le SSH mais aussi pour plein d’autres outils !

On l’installe avec `apt install fail2ban`. Puis on crée un nouveau fichier `/etc/fail2ban/jail.local` avec la configuration suivante :


```
[DEFAULT]

bantime = 84600
findtime = 600
maxretry = 3

destemail = tomtom@example.org
sendername = Fail2ban

action = %(action_mwl)s

[sshd]
enabled = true
port = 21153
```



En fait c’est surtout la dernière partie qui est obligatoire. Il faut activer l’outil pour le SSH, et spécifier le port que vous avez modifié précédemment. Et n’oubliez pas de redémarrer le service : `systemctl restart fail2ban`.

Testez alors si ça marche en essayant de vous connecter depuis une autre IP que la votre. Bah oui, sinon vous allez vous bannir vous-même. Donc utilisez un VPN ou bien connectez-vous en premier sur un serveur distant, et depuis ce serveur distant, essayez de vous faire bannir.

Comment voir si ça marche ? Regardez les logs `/var/log/auth.log` et `/var/log/fail2ban.log`.

### Configurer votre serveur SMTP
  
  
Normalement vous devriez recevoir des emails de la part de `fail2ban` (avec la configuration ci-dessus).. si vous avez configuré `postfix`, qui vient de base avec Proxmox.

Si vous avez suivi jusque là, il y a de bonnes chances pour que vous n’y ayez pas encore touché. Là on le fait pour `fail2ban`, mais Proxmox peut aussi vous notifier de certains événements importants, donc c’est une étape importante, pas seulement pour `fail2ban`.

Lancez donc un `dpkg-reconfigure postfix` et choisissez les options suivantes :
  
* Internet Site.
* System mail name = `proxmox.example.org`.
* Postmaster mail recipient = `tomtom`.
* Other destinations to accept mail from : Laissez les valeurs par défaut, c’est-à-dire : `proxmox, proxmox.example.org, proxmox.example.org, localhost.example.org, localhost`.
* Force synchronous updates on mail queue? Non.
* Local networks = On laisse par défaut.
* Mailbox size limit = 0
* Local address extension character = +
* Internet Protocols = all
      
  
La console va vous parler, puis redémarrez le service avec `systemctl restart postfix`.

### L’interface Proxmox
  
  
Ensuite j’aime bien créer encore un autre utilisateur, qui lui n’aura pas d’accès `sudo`, et qui sera réservé à Proxmox.

Après avoir tapé `adduser proxmox`, il faudra vous connecter en root sur l’interface Proxmox et ajouter l’utilisateur dans Datacenter / Permissions / Users.
Pour lui donner des accès, vous pouvez taper les commandes suivantes (tirées de la documentation : [User Management](https://pve.proxmox.com/wiki/User_Management#_real_world_examples)) :


```
pveum groupadd admin -comment "System Administrators"
pveum aclmod / -group admin -role Administrator
pveum usermod proxmox@pam -group admin
```



Vous pouvez restreindre ces accès à tout moment.

Pendant que vous êtes connectés avec **root**, vous pouvez aussi en profiter pour placer un certificat Let’s Encrypt et éviter d’avoir l’avertissement du navigateur pour le HTTPS. Plus de détails ici : [Signez l’UI de Proxmox VE avec Let’s Encrypt, c’est (encore plus) trivial](/2018/05/29/signez-la-console-proxmox-ve-avec-lets-encrypt-cest-encore-plus-trivial/)

Voilà.

Maintenant, on n’aura plus besoin de **root**. On peut se déconnecter et tout faire avec le nouvel utilisateur.

Et voilà ! Maintenant, on a une belle interface, ouverte à l’internet entier, avec un petit écran de logi... hein quoi ? Eh ouais, on peut se faire bruteforce le Proxmox là ! D’ailleurs c’est peut-être en train d’arriver en ce moment même !

### Retour sur fail2ban  
  
Cette étape est un peu optionnelle dans le sens où dans le futur, on pourra bloquer l’ouverture de Proxmox sur le monde réel et ne pouvoir y accéder que depuis le VPN.

Mais j’ai tendance à penser qu’on n’est jamais trop prudent...

Retournez dans le fichier `/etc/fail2ban/jail.local` et ajoutez la configuration suivante :


```
[proxmox]
enabled = true
port = https,http,8006
filter = proxmox
logpath = /var/log/daemon.log
maxretry = 3
# 1 hour
bantime = 3600
```



Et on ajoute la partie suivante dans le fichier `/etc/fail2ban/filter.d/proxmox.conf` (voir la [doc officielle](https://pve.proxmox.com/wiki/Fail2ban)) :


```
[Definition]
failregex = pvedaemon\[.*authentication failure; rhost=<HOST> user=.* msg=.*
ignoreregex =
```

Cette deuxième partie, elle sert justement à repérer les messages d’erreurs causés par les méchants qui essaient de se connecter.

Et on oublie pas de redémarrer fail2ban.

Là pour tester c’est un peu plus compliqué que pour le SSH, mais par exemple vous pouvez essayer de le faire depuis votre téléphone (pas sur la connexion wifi hein !).

Bon. On a bien avancé. Mais on n’a pas fait grand chose non plus.

## Configuration du réseau
  
  
Dans cette partie, mon objectif est vraiment de reprendre exactement le schéma de m4vr0x :

![](/2017/07/proxmox-install_full-infra-diag.jpg)

Le truc de base à garder en tête, c’est qu’en frontal, on a l’hyperviseur. C’est incontournable.

On doit forcément passer par l’hyperviseur pour atteindre une VM.

Du coup, si notre pare-feu EST une VM, ben... ça casse un peu tout le délire. C’est un peu comme si le gardien du château était au fond du jardin.

C’est pour ça que notre objectif, ça va être de router automatiquement TOUT le trafic vers la VM pare-feu. Donc vers la PFSense.

En temps normal, on devrait avoir la PFSense en frontal, et derrière elle on aurait le réseau local.

C’est pourquoi la PFSense est connectée à deux réseaux :
  
* Le WAN, aka Internet
* Le LAN, tout le réseau local avec les VMs qui sont derrières PFSense
      
  
Entre les deux, il y a la PFSense.

En routant la totalité du trafic de l’hyperviseur vers la PFSense, c’est un peu comme si la PFSense était en frontal (alors qu’en vrai c’est proxmox le frontal sur Internet). Et ce petit _router tout le trafic automatiquement_ se traduira en une LONGUE série d’instructions iptables. 
    
### Paramétrage des interfaces virtuelles

Déjà, on crée les réseaux WAN et LAN. Connectez-vous sur votre interface Proxmox https://proxmox.example.org:8006 (avec votre utilisateur spécial, pas le root !), cliquez sur votre node, puis System > Network :
![](/2017/07/proxmox-install_network-new.png)



Sur son tuto, m4vr0x avait 2 interfaces (2 NIC on dit). Moi avec Hetzner j’en ai qu’une. Au début j’ai cru que c’était game over pour moi. En fait non, 1 seule suffit. C’est comme pour lotus.


Juste un petit conseil. On fait un petit backup des interfaces comme elles ont été configurées par le provider d’abord : `cp /etc/network/interfaces /etc/network/interfaces.bak`.


On crée un premier bridge en cliquant sur Create/Linux Bridge et on remplit comme suit :

* Name : vmbr0
* IPv4/CIDR : Choisissez l’IP qui était auparavant sur votre interface NIC. En gros c’est votre IP publique. Il faut aussi ajouter le CIDR.
* Gateway (IPv6) : Idem, choisissez la Gateway qui était sur l’interface NIC.
* IPv6/CIDR : Idem que pour l’IPv4. J’ai pris le choix d’en mettre une, comme Hetzner m’en a fourni une. Je me dis qu’en 2020 y’a plus d’IPv4 disponible, donc y’a un moment va falloir s’y mettre.
* Gateway (IPv6) : Idem.
* Autostart : On coche.
* VLAN aware : On laisse décoché.
* Bridge ports : Là vous mettez le nom de votre première interface. Celle dont vous avez extrait l’IP et la Gateway.
* Comment : Internet.


Si jamais vous ne savez pas ce que c’est que le CIDR ou la Gateway, c’est là que je vous recommande très chaudement le cours d’OpenClassrooms que je citais au début. Franchement, vous n’en ressortirez que plus compétent sur les réseaux et ce sont quelques heures investies qui vous en feront gagner beaucoup d’autres plus tard.


Je remets discrètement le lien ici : [Apprenez le fonctionnement des réseaux TCP/IP ](https://openclassrooms.com/fr/courses/857447-apprenez-le-fonctionnement-des-reseaux-tcp-ip)


Et si vous avez juste oublié comment calculer le CIDR à partir de votre masque, vous pouvez utiliser cette [table de correspondance](https://docs.netgate.com/pfsense/en/latest/book/network/understanding-cidr-subnet-mask-notation.html).


Là, si vous validez, vous aller avoir un message d’erreur. Il faut au préalable supprimer les infos IP/Gateway de l’interface du NIC. En plus si vous laissez l’IP sur le NIC et le bridge, vous allez avoir des problème (j’en sais quelque chose).


Pour être 100% honnête, je ne suis pas sûr que ce bridge soit indispensable. Je ne vois pas trop ce qu’il apporte de plus par rapport à directement utiliser l’interface NIC. Là c’est un peu comme si on mettait une double porte pour rentrer chez soi.


Ensuite, un deuxième bridge. Celui-ci sera un bridge « virtuel », ça veut dire qu’il ne sera connecté sur aucune réelle interface NIC. On va avoir un premier bridge virtuel qui donnera sur le réseau WAN, et un deuxième bridge virtuel qui donnera sur le réseau LAN. C’est une manière de créer des réseaux privés distincts.


Imaginez qu’on crée une première porte virtuelle qui mène vers le monde de WAN, et une deuxième porte virtuelle qui mène vers le monde de ~~Jumanji~~ LAN.


Pour ce deuxième bridge, on rentre :

* Name : vmbr1
* IPv4/CIDR : 10.0.0.1/30.
* Comment : WAN
          
    
m4vr0x rentrait la valeur « WAN » dans bridge port. Mais en fait 1) je crois que ça n’était pas utile, et 2) Proxmox 6 vous empêche d’assigner une interface qui n’existe pas. Si vous tenez vraiment à le faire, il faudra éditer à la main le fichier `/etc/network/interfaces`.


Je le mets quand même dans _Comment_ parce que c’est utile pour s’en rappeler.


Pour l’IP, on utilise un CIDR = 30 pour être sûr de n’avoir que 2 IPs de disponible. Oui, on évite de se donner une plage avec des millions d’IPs si on n’en a pas besoin. Là, si jamais un brigan arrive à se relier je-ne-sais-comment au réseau WAN, eh bien il ne pourra pas avoir d’IP.


Et finalement le dernier bridge :



* Name : vmbr2
* IPv4/CIDR : 192.168.9.1/24.
* Comment : LAN


Ici c’est un peu pareil, mais on se laisse la possibilité d’avoir 256 IPs, puisqu’on ne sait pas combien de machines virtuelles on va avoir exactement.


~~Allez, on valide en cliquant sur Reboot tout en haut de l’interface.~~


Bonne nouvelle, il n’est maintenant plus forcément nécessaire de redémarrer entièrement l’hôte en cas de modification des interfaces réseaux. Si vous installez le package `ifupdown2` (via un petit `apt install`), vous pourrez cliquer sur la case Apply Configuration dans le menu Network pour prise en compte à chaud des modifications !

![](/2020/04/pending.png)


C’est peut-être le moment de vous montrer une petite astuce si jamais vous vous êtes planté. En fait, quand j’ai suivi le tuto de m4vr0x, j’ai réussi à m’enfermer dehors de mon serveur une bonne dizaine de fois.


La solution, pour Hetzner, c’est de passer en mode _Rescue_, puis de monter le volume LVM en suivant les instructions de [cette page d’aide](https://wiki.hetzner.de/index.php/Hetzner_Rescue-System/en#Mounting_LVM_Volumes). Par exemple, l’idée ça pourrait être de remettre le fichier `/etc/network/interfaces` dans son état initial.


L’idée, c’est que même si j’ai l’impression que mon tutorial est _fail-proof_, je suis sûr qu’il ne l’est pas. C’est probablement impossible de l’être. Par contre, on peut apprendre les outils pour réparer nos conneries. Et ça nous rend confiant pour essayer des trucs.


Bon allez. On vérifie son contenu de `/etc/network/interfaces` et on passe à la suite :
    
    
```
auto lo
iface lo inet loopback

iface lo inet6 loopback

auto enp4s0
iface enp4s0 inet manual
    up route add -net xx.xx.xx.xx netmask 255.255.255.224 gw xx.xx.xx.xx dev enp4s0

auto vmbr0
iface vmbr0 inet static
    address  xx.xx.xx.xx
    netmask  27
    gateway  xx.xx.xx.xx
    bridge-ports enp4s0
    bridge-stp off
    bridge-fd 0
#Internet

iface vmbr0 inet6 static
    address  xx:xx:xx::xx
    netmask  64
    gateway  fe80::1

auto vmbr1
iface vmbr1 inet static
    address  10.0.0.1
    netmask  30
    bridge-ports none
    bridge-stp off
    bridge-fd 0
#WAN

auto vmbr2
iface vmbr2 inet static
    address  192.168.9.1
    netmask  24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
#LAN
```

Notez que j’ai une règle de routage au début avec la ligne qui commence par `up route add`. Cette ligne était déjà là avant, alors je n’y ai pas touché.

## Déploiement de PFSense
      
      
On va télécharger la dernière version sur le site : [PFSense](https://www.pfsense.org/download/). Moi j’ai pris une architecture AMD64 et l’ISO.


Évidemment on vérifie le checksum. Ça sert à rien de passer des heures sur la sécurité si on télécharge un fichier trafiqué. Je suis sympa je vous donne même la commande : `openssl dgst -sha256 Downloads/pfSense-CE-2.4.4-RELEASE-p3-amd64.iso.gz`.


Puis on l’upload dans le volume de stockage _local_ sur l’interface de Proxmox.


Si comme moi vous avez une connexion un peu pourrite, on peut aussi le télécharger directement sur le serveur :
    
    
    
```
cd /var/lib/vz/template/iso
wget https://frafiles.pfsense.org/mirror/downloads/pfSense-CE-2.4.5-RELEASE-amd64.iso.gz
openssl dgst -sha256 pfSense-CE-2.4.5-RELEASE-amd64.iso.gz
gunzip pfSense-CE-2.4.5-RELEASE-amd64.iso.gz 
```

    
    
Et pouf l’ISO va apparaître dans votre interface.
    
![](/2020/04/pfsense_iso.png)
    
    
Maintenant on lance une VM (et pas un CT).
    
      
**General**
    
      

* Node : Choisissez votre node.
* VM ID : On peut laisser la valeur par défaut (100 normalement).
* Name : PFSense.
              

**OS**
    
      
      
* Use CD/DVD disc image file (iso) : Storage = local et ISO image est le fichier qu’on vient d’uploader.
* Guest OS = Other
              
      
**System**
    
      
      
* Graphic card : ~~VMware compatible~~ Default
* SCSI Controller : VirtIO SCSI
              
      
**Hard Disk**
    
      
      
* Bus/Device : VirtIO Block / 0.
* Storage : local.
* Disk size : 8 GB.
* Format : QEMU
              
      
**CPU**
    
      
      
* Sockets : 1
* Cores : 2
              
      
Note de zwindler : Charles conseillait une carte graphique « VMware compatible », mais à l’usage, je trouve que celle par défaut offre un meilleur rendu


Si vous voulez vous pouvez mettre plus de cœurs. Je ne pense pas que ça change grand chose étant donné que la VM ne va pas être gourmande du tout.
    
      
**Memory**
    
      
      
* Memory : 512.
              

Idem, vous pouvez mettre plus, mais pour commencer vous pouvez très bien mettre cette valeur et l’augmenter plus tard si le besoin s’en fait ressentir.


**Network**

      
      
* Bridge : vmbr1
* Model : Intel E1000 ou VirtIO
              
      
Pour ce dernier point, ça dépend si vous aimez les problèmes ou non. Intel E1000 semble fonctionner. VirtIO aussi mais sous certaines conditions. En fait, je me suis retrouvé avec des VM qui pouvaient pinger Internet mais les requêtes tcp/udp ne passaient pas. Ça m’a rendu fou.


On y reviendra. Moi j’ai pris VirtIO.


Pour l’instant, on valide.


La PFSense a besoin d’être connectée à 2 interfaces réseau : Le WAN et le LAN. Bah oui puisque c’est justement elle qui va faire le lien entre les deux interfaces. Pour l’instant, elle n’est connectée que à vmbr1, qui correspond au WAN.

![](/2020/04/pfsense_vmbr2.png)


Cliquez sur la VM, puis Hardware, et « Add/Network Device ». Choisissez vmbr2 et le même modèle que vous aviez choisi pour vmbr1.


Maintenant on peut démarrer la VM.
    
      
### Installation de PFSense


En allant sur _Console_, vous allez pouvoir afficher l’écran de la machine.


Choisissez Install pfSense.

![](/2020/02/pfsense_screen.png)


Ensuite, on vous demande votre disposition clavier. Vous pouvez sélectionner ce que vous voulez, de toute façon après il vous remet en qwerty (sympa).


Pour le partitionnement, choisissez Auto: Guided Disk Setup, sauf si vous savez ce que vous faites. Les choses vont alors se faire toutes seules, jusqu’à :

![](/2020/02/pfsense_screen2.png)


Dites-lui non, puis rebootez. Après le reboot, choisissez de ne pas configurer de VLAN :

![](/2020/02/pfsense_screen3.png)


Pour la WAN interface, choisissez l’interface `vtnet0`, qui est l’équivalent de vmbr1. Pour la LAN interface, choisissez l’interface `vtnet1`, qui est l’équivalent de vmbr2.

![](/2020/02/pfsense_screen4.png)


On arrive alors sur le menu principal de la PFSense. Ce menu bien moche, c’est l’écran d’accueil. Oui oui. Rassurez-vous, plus tard on aura une interface web bien plus jolie. Pour l’instant, tapez 2 pour assigner des adresses IP à vos interfaces :

![](/2020/02/pfsense_screen5.png)


Pour le WAN, on va lui donner :


      
* DHCP : no
* IPv4 : 10.0.0.2
* Subnet bit count : 30
* Upstream gateway address : 10.0.0.1
* DHCP6 : no
* IPv6 : Rien (appuyez sur Entrée)
* Do you want to revert HTTP as the webConfigurator protocol? no
              
      
        L’écran principal va réapparaître. De nouveau on tape 2, et cette fois-ci on configure le LAN :
    
      
      
* IPv4 : 192.168.9.254
* Subnet bit count : 24
* Upstream gateway address : Rien (appuyez sur Entrée)
* IPv6 : Rien (appuyez sur Entrée)
* Activer le serveur DHCP : No
* Do you want to revert HTTP as the webConfigurator protocol? no
              
      
Finalement, on nous annonce que le webConfigurator est disponible à l’adresse https://192.168.9.254. On va donc s’y connecter pour continuer la configuration.
    
      
> … Quoi ? … Ça ne marche pas ? … Sûr ? … C’est con …
    

Oui je reprends les blagues de m4vr0x, et alors :D ?


Bon l’idée c’est juste qu’on a un réseau local ici, donc non on ne peut pas y accéder depuis Internet. Il faut être dans le LAN pour y accéder. Les machines qui sont dans le LAN sont l’hyperviseur et la PFSense. Et les deux.. n’ont pas d’interface graphique.



_Petit debugging tip_. Normalement, là où vous en êtes, vous devriez être capable de pinger l’hyperviseur depuis la PFSense. À partir du menu principal, tapez 7 puis l’IP de l’hyperviseur (10.0.0.1). Le ping devrait fonctionner.


Par contre, si vous essayez de pinger la PFSense, ça ne va pas marcher. En effet, par défaut, la PFSense est inaccessible depuis le WAN. Parce que le WAN, c’est Internet, c’est le monde dangereux. Dans notre cas particulier, le WAN c’est seulement l’hyperviseur pour l’instant, mais plus tard, tout le trafic d’Internet viendra de l’interface du WAN.


Donc quand on ping depuis la PFSense, ça marche parce que c’est la PFSense qui initie la connexion, donc en face on sait qu’on a un copain, donc on accepte sa réponse de ping.


Mais quand on ping vers la PFSense, ça ne marche pas parce qu’elle ne vous connaît pas et elle ne parle pas aux inconnus.


J’ai mis des semaines à comprendre ça, et de nombreuses personnes s’en plaignaient dans les commentaires, donc ça me semblait important de faire cette parenthèse.



## Accéder à la console de PFsense


Du coup, comment on va accéder à cette interface web ?


A partir de là, vous avez plusieurs solution. La plus simple est, en attendant qu’on ait un accès direct au réseau local des VM via un VPN par exemple, on peut simplement faire un tunnel SSH.


Pour se faire, lancez la commande suivante depuis votre PC :

    
    
```
ssh tomtom@IP_PUB_PROXMOX -L 8443:192.168.9.254:443
```

    

Une fois la commande lancée, l’UI de PFsense sera accessible à l’URL https://localhost:8443 tant que le tunnel sera opérationnel. Ça peut suffire. Sous Windows, vous pouvez faire la même chose avec Putty (ou n’importe quel autre client SSH un peu évolué).



La deuxième option est de créer une machine virtuelle dans le réseau LAN qui disposera d’une interface graphique. Par exemple, une simple Ubuntu Desktop, qui nous servira de poste de rebond. Téléchargeons-la directement depuis le serveur :
    
    
    
```
cd /var/lib/vz/template/iso
wget http://releases.ubuntu.com/18.04.4/ubuntu-18.04.4-desktop-amd64.iso
```

    

Puis, on crée une nouvelle VM avec le paramétrage suivant.


**General**
    
      
      
* Node : Choisissez votre node.
* VM ID : On peut laisser la valeur par défaut (101 normalement).
* Name : UbuntuDesktop.
              
      
**OS**
    
      
      
* Use CD/DVD disc image file (iso) : Storage = local et ISO image est le fichier qu’on vient d’uploader.
* Guest OS = Linux 5.x
              
      
**System**
    
      
      
* Graphic card : ~~VMware compatible~~
* SCSI Controller : VirtIO SCSI
              
      
**Hard Disk**
    
      
      
* Bus/Device : VirtIO Block / 0.
* Storage : local.
* Disk size : 25 GB.
* Format : QEMU
              

Note de zwindler : Charles conseillait une carte graphique « VMware compatible », mais à l’usage, je trouve que celle par défaut offre un meilleur rendu


On peut mettre moins de _storage_ mais il faut garder à l’idée que c’est une VM temporaire de toute façon. Une fois que tout sera en place, on pourra la détruire.


**CPU**


      
* Sockets : 1
* Cores : 4
              
      
**Memory**
    
      
      
* Memory : 4096.
              

Pareil, on peut mettre moins de mémoire RAM.


**Network**
    
      
      
* Bridge : vmbr2
* Model : Intel E1000 ou VirtIO
              

Là évidemment on se plante pas ! La VM et toutes les autres VM qu’on créera seront toujours sur le vmbr2, donc le LAN ! Et là vous êtes content d’avoir écrit WAN ou LAN en commentaires du bridge puisque ça vous évite de vous perdre.


De toute façon, si vous vous branchez sur le WAN, il n’y aura pas d’IP disponible.


Je passe sur les détails de l’installation de Ubuntu, elle n’est vraiment pas compliquée.


Ce qui est important, c’est de vous paramétrer une IP, étant donné qu’il n’y a pas de serveur DHCP pour vous en assigner une automatiquement.


Allez dans les Paramètres puis choisissez Réseau. Activez la connexion, et dans les paramètres, l’onglet IPv4, rentrez les paramètres suivants :



* IPv4 Method = manuel
* Address = 192.168.9.10
* Netmask = 255.255.255.0
* Gateway = 192.168.9.254
* DNS = 1.1.1.1
              

Et là, c’est bon !


Comment ça l’accès internet ne marche pas ?!


Évidemment qu’il ne marche pas ! Suivez un peu. On a une VM qui est connectée au réseau LAN seulement. Le réseau LAN est-il relié à Internet ? Seulement à travers la PFSense. Et comme la PFSense bloque tout, on n’a pas accès.


Par contre, vous devriez être capable de pinger l’hyperviseur et la PFSense avec `ping 192.168.9.1` et `ping 192.168.9.254`.


Et finalement, vous allez même pouvoir vous connecter à l’interface web de la PFSense en ouvrant une page web et en tapant `https://192.168.9.254/`.


## Accéder à la console de PFsense
      

Cette interface n’est pour le moment accessible que depuis le réseau local (ou depuis votre tunnel si vous avez choisi cette voie). Et heureusement, parce que par défaut, les identifiants sont :

      
      
* Username = admin
* Password = pfsense
              

Au démarrage, l’appli vous propose un _wizard_ de configuration. Suivez simplement les consignes.

      
      
* Hostname : Correspond à la partie avant le domaine. Par exemple, dans `proxmox.example.org`, l’hostname c’est proxmox.
* Domain : Et le domaine, c’est l’autre partie restante.
* DNS : 1.1.1.1
              

Le reste peut être laissé par défaut, jusqu’à l’étape 4 sur l’interface WAN. Normalement tout est bien pré-rempli. Toutefois, détail important, il faut désactiver la case Block RFC1918 Private Networks.


Cette option permet de bloquer les paquets qui parviennent d’un réseau privé d’entrer par l’interface WAN. Un réseau privé, c’est un réseau dont l’IP commence par 10, 172.16, ou 192.168. Et comme notre WAN est justement sur un réseau privé, eh bien cette option bloque tout.


![](/2020/03/pfsense_block.png)

En temps normal, le WAN correspond à Internet. Dans notre cas spécifique, ce n’est pas le cas, et on doit donc décocher cette case.


Continuez puis finissez par changer le mot de passe de l’admin. À la fin, on vous propose de vérifier si une mise à jour. Vous pouvez essayer...


... sauf que vous n’avez toujours pas accès à l’internet sur votre VM ! (suivez un peu)


Il reste maintenant la partie la plus fun : Envoyer tout le trafic sur la PFSense, configurer PFSense et déployer une application.


Et vous l’aurez dans dans le prochain épisode !

* [Proxmox VE 6 + pfsense sur un serveur dédié (2/2)](/2020/03/09/proxmox-ve-6-pfsense-sur-un-serveur-dedie-2-3/)