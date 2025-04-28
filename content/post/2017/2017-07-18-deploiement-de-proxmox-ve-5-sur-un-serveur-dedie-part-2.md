---
title: Déploiement de Proxmox VE 5 sur un serveur dédié – part 2
authors:
  - m4vr0x
type: post
date: 2017-07-18T12:00:32+00:00
url: /2017/07/18/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-2/
image: /2017/07/proxmox-install_thumbnail.png
categories:
  - Système
  - Virtualisation
tags:
  - iptables
  - kimsufi
  - KVM
  - labs
  - oneprovider
  - OVH
  - pfsense
  - Proxmox
  - serveur dédié
  - virtualisation

---

> Note : Cette suite d’articles de 2016 écrite par M4vr0x a été remis à jour par Charles et moi. Je vous conseille d’aller lire celui ci plutôt, qui sera plus en phase avec les versions actuelles. [Proxmox VE 6 + pfsense sur un serveur dédié (1/2)](/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie/">)

Cet article fait partie d’une suite de 3 articles sur la mise en place de Proxmox VE et sa sécurisation et dont voici les adresses :

* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 1](/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/)
* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 2](/2017/07/18/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-2/)
* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 3](/2017/07/25/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-3/)

Après avoir déployé Proxmox, nous allons poursuivre la mise en œuvre de notre infrastructure de Labs sur notre serveur dédié, en procédant aux étapes suivantes :

* Sécuriser l’OS
* Paramétrer les interfaces via la WebUI de Proxmox
* Installer la VM PFSense
* Utiliser l’iptables de l’hyperviseur pour router et sécuriser les flux

# Basic hardening

Je vous conseille TRÈS VIVEMENT (non en fait c’est obligatoire) d’appliquer les bonnes pratiques élémentaires en matière de sécurisation listées dans [ce très bon article rédigé par OVH][4] et qui détaille tous les points ci-dessous.

Si vous voulez creuser un peu plus, regardez également du coté des outils d’audit du genre de [Lynis][5] (ex rkhunter), c’est simple à utiliser et ça vous donnera plein de pistes sur des vulnérabilités potentielles : [Doc d’installation officielle][6]

Voilà, pour ma part, ce que j’ai mis en place :

##### Changement du mot de passe root

Si vous avez utilisé un mot de passe simple pour éviter les risques d’erreurs lors de la configuration (comme évoqué dans la part 1), on se connecte via SSH et on paramètre un VRAI password.

##### Mise à jour du système

Toujours une bonne habitude à prendre avant de commencer, même si à l’heure où j’écris ces lignes la version 5 de Proxmox est sortie depuis seulement quelques jours. Rien de compliqué, on est sur une Debian :

```
apt-get update; apt-get upgrade
```


##### Création d’utilisateur

La création d’un utilisateur « lambda », autre que root, est fortement recommandée. Par défaut l’authentification du portail de Proxmox se base sur PAM donc vous pourrez vous loguer avec, après l’avoir ajouté dans la WebUI.

##### Configuration du serveur SSH

Désactivez l’accès root et privilégiez le recours au user évoqué ci-dessus puis utilisez une élévation de privilège de type su ou sudo.

##### Installation de Fail2ban

Là aussi indispensable, il s’installe en une commande, il est déjà configuré avec un grand nombre de règles par défaut qui parsent vos différents log et bannissent toutes les @IP concernées. D’ailleurs, si vous n’êtes pas convaincu de son utilité, je vous mets un (petit) extrait de mon auth.log juste avant son installation :

![](/2017/07/proxmox-install_auth-log.png)

Voilà, voilà ... contrairement à [notre ami de Nanjing][8] qui a effectué 161 tentatives en 32h avec des logins plus ou moins improbables ... nous on se marre moins tout de suite !!

Au passage, voilà [un article sur la configuration de Fail2ban][9] de l’hébergeur Digital Ocean (Ils en font d’ailleurs beaucoup d’intéressants je vous encourage à écumer leurs tutos)

##### Changement du port d’écoute du serveur SSH

Alors là attention, aucun doute sur la pertinence de la mesure, cela vous permettra d’éviter la grande majorité des tentatives d’accès non autorisées car la plupart des bots se contentent de scanner les ports par défauts des principaux services. Par contre si vous faites ça, vous allez devoir adapter le port SSH dans le script iptables que je vous fournis pas la suite et les tentatives d’intrusion sur le port 22 seront redirigés directement sur le PFSense, ce qui n’est pas forcément mieux. Bref à vous de voir, pour ma part je reste sur le port par défaut mais avec un Fail2ban bien configuré.

# Configuration du réseau

Voici le plan réseau de l’infrastructure que nous allons mettre en place (cliquez pour agrandir) :

![](/2017/07/proxmox-install_full-infra-diag.jpg)

Le but est de rediriger la totalité du trafic entrant sur l’adresse IP public du serveur vers l’interface WAN du PFSense. Cela permet de gérer la sécurisation et le routage des flux simplement, directement depuis PFSense et surtout en évitant d’avoir à doubler chaque règles de filtrage sur l’iptables.

## Paramétrage des interfaces virtuels

Cela peut se faire directement via la WebUI de Proxmox, Les réglages seront simplement automatiquement retranscrits dans le fichier « _/etc/network/interfaces_« .

* Se connecter à l’interface d’administration

Via un navigateur, on se rend en HTTPS sur l’IP public via le port 8006 (https://@IP_PUBLIC_IP:8006). Si vous souhaitez signer vos certificats pour éviter le genre de message que vous allez rencontrer, n’hésitez pas à lire [ce superbe article de Zwindler](/2017/05/02/proxmox-lets-encrypt/)

* Sélectionner votre node dans la colonne de gauche, puis naviguer dans System > Network

![](/2017/07/proxmox-install_network-new.png)

Vous devriez avoir deux interfaces, en01 et en02 (ou eth0 et eth1 chez Kimsufi), qui correspondent aux deux ports physiques de la carte réseau ainsi qu’une interface virtuel, **vmbr0** bridgé sur **eno1** qui est l’interface active.

On peut d’ailleurs voir à quoi cela correspond en affichant notre fichier de configuration :

```
cat /etc/network/interfaces
```


Qui devrait contenir ceci :

```
auto lo
iface lo inet loopback

iface eno1 inet manual
iface eno2 inet manual

auto vmbr0
iface vmbr0 inet static
 address xx.xx.xx.xx
 netmask 255.255.255.0
 gateway xx.xx.xx.xx
 bridge_ports eno1
 bridge_stp off
 bridge_fd 0
```


On voit que l’interface eno1 est configuré en « manual », sans adresse IP puisque elle est « portée » par **vmbr0**, et qu’eno2 n’est pas utilisée.

## Création des bridges Linux

On reprend en configurant conformément au schéma ci-dessus :

* Cliquer sur « _Create_ » et sélectionner « _Linux Bridge_« 

![](/2017/07/proxmox-install_create-bridge.png)

Le réseau « VmWanNET » (10.0.0.0/30) sera donc volontairement choisit pour limiter à deux le nombre d’adresses atribuables, celle-ci et le **WAN** du PFSense. Ici pas de bridge sur une interface réelle pour la vmbr1 puisque « **WAN** » n’existe pas au niveau de l’hyperviseur, mais cela facilitera la correspondance lors du paramétrage de PFSense.

* Cliquer (à nouveau) sur « _Create_ » et sélectionner (encore) « _Linux Bridge_« 

Cette fois on configure l’interface vmbr2 qui fera parti du réseau « PrivNET » (192.168.9.0/24), et qui sera utilisée plus tard par l’interface « **LAN** » du PFSense  :

```
IP address : 192.168.9.1
Subnet mask : 255.255.255.0
Bridges Ports : LAN
```

Une fois terminé, cela donne :

![](/2017/07/proxmox-install_network-ok.png)

* Rebooter l’hyperviseur

Il suffit de cliquer sur « Restart » en haut à droite. C’est impératif pour prendre en compte proprement les modifications, c’est pas moi qui le dis, c’est marqué au dessus de l’encadré affichant le log : « _Pending changes (Please reboot to activate changes)_ » ... allez promis c’est la seule fois où ce sera nécessaire.

Après le redémarrage, vous pouvez vérifier le contenu du fichier « interfaces » :

```
auto lo
 iface lo inet loopback

iface eno1 inet manual

iface eno2 inet manual

auto vmbr0
 iface vmbr0 inet static
 address xx.xx.xx.xx
 netmask 255.255.255.0
 gateway xx.xx.xx.xx
 bridge_ports eno1
 bridge_stp off
 bridge_fd 0

auto vmbr1
 iface vmbr1 inet static
 address 10.0.0.1
 netmask 255.255.255.252
 bridge_ports WAN
 bridge_stp off
 bridge_fd 0

auto vmbr2
 iface vmbr2 inet static
 address 192.168.9.1
 netmask 255.255.255.0
 bridge_ports LAN
 bridge_stp off
 bridge_fd 0
 ```

Je vous conseille de le conserver quelques part puisque en cas de réinstallation, un simple copier/coller suivi d’un reboot vous permettra de tout reconfigurer rapidement. Nous poursuivrons le paramétrage et la sécurisation par la suite.

# Déploiement de PFSense

## Création de la VM

* Télécharger l’ISO de PFSense

Rendez-vous sur [le site officiel][15] pour récupérer la dernière version stable de la Community Edition, de type « _install_« , au format ISO et pour archi AMD64 (64bits). On sélectionne ensuite le volume de stockage souhaité, ici « _local_« , puis on clique sur Content > Upload

![](/2017/07/proxmox-install_pfsense-vm-upload-iso.png)

Mais on peut également, surtout si votre débit d’upload est poussif, la télécharger directement depuis le serveur dans le répertoire des ISOs :

```
cd /var/lib/vz/template/iso
wget [lien mort, aller sur https://pfsense.org/]
gunzip pfSense-CE-2.3.4-RELEASE-amd64.iso.gz
```


* Créer la VM pour PFSense

Voilà les paramètres que j’utilise, ceux qui n’y figure pas sont laissés par défaut :

**OS** 

- Linux/Other OS types : Other OS types

**CD/DVD** 

Use CD/DVD disc image file (iso)
- Storage : local
- ISO image : pfSense-CE-2.3.4-RELEASE-amd64.iso

**Hard Disk**

- Bus/Device : VirtIO / 0
- Storage : local
- Size : 8 GB
- Format : QEMU (qcow2)

**CPU**

- Sockets : 1
- Cores : 2
- Type : Défaut (kvm64)

**Memory**

Mémoire fixe avec ballooning activé
 - Taille : 2048 MB

**Network**

Bridged mode (Accès par pont)
- Bridge : vmbr1
- Model Intel E1000

/!\ Pour la carte réseau SURTOUT pas de VirtIO sans installer le driver requis /!\  
Pour plus détails [ici](https://forum.pfsense.org/index.php?topic=72907.0)

* Créer la seconde interface réseau

Assurez-vous d’être dans la « Server View » dans le menu en haut à gauche, puis sélectionnez votre VM PFSense nouvellement crée. Enfin, cliquez sur Hardaware > Add > Network Device

![](/2017/07/proxmox-install_pfsense-vm-network-device.png)

La configuration est la même que pour la première mais pontée sur **vmbr2**.

## Installation de l’OS

* Démarrer la VM via le bouton « Start »
* Ouvrir une console VNC avec le bouton « Console »

Laisser le boot se terminer, si ce n’est pas encore fait, jusqu’à voir s’afficher le premier écran de l’installeur :

![](/2017/07/proxmox-install_pfsense-vm-install-screen-1.png)

Libre à vous de choisir les réglages qui vous conviennent, valider avec le dernier choix du menu.

* Choisir « Quick/easy Install »

![](/2017/07/proxmox-install_pfsense-vm-install-screen-2.png)

* Valider à nouveau et l’installation se lance
* Sélectionner le choix par défaut « _Standard Kernel_« 
* Autoriser le reboot

Vérifiez le boot order de la VM pour bien démarrer sur le disque local, vous pouvez également éjecter l’ISO.

## Configuration des interfaces

Une fois la VM redémarrée, vous arrivez sur le menu principal de la console de PFSense :

![](/2017/07/proxmox-install_pfsense-vm-config-screen.png)

* Taper « 1 » (pas trop fort) pour assigner les interfaces, puis configurer comme suit :

```
 - Paramétrage des VLANs : No (n)
 - WAN interface name : em0
 - LAN interface name : em1
 - Optional 1 interface name : Aucun (appuyer sur entrée)
 - Valider (avec y) si :
 WAN -> em0
 LAN -> em1
```


* De retour dans menu général  taper « 2 » pour configurer les @IP des interfaces

```
Taper "1" pour le WAN (em0 - static)
 - DHCP : No (n)
 - @IP : 10.0.0.2
 - Masque : 30
 - Gateway : 10.0.0.1
 - DHCP6 : No (n)
 - WAN IPv6 address : Aucune (appuyer sur entrée)
 - HTTP revert : No (n)
 - Valider (avec entrée) si :
IPv4 WAN address => 10.0.0.2/30
```

* A nouveau  « 2 » pour configurer les @IP des interfaces

```
Taper "2" pour le LAN (em1 - static)
 - @IP : 192.168.9.254
 - Masque : 24
 - Gateway : Aucune (appuyer sur entrée)
 - @IPv6 : Aucune (appuyer sur entrée)
 - DHCP server : No (n)
 - HTTP revert : No (n)
 - Valider (avec entrée) si :
IPv4 LAN address => 192.168.9.254/24
```


* Rebooter la VM en tapant « 5 » puis « y »
* A l’issue, taper « 7 » pour tester le ping vers 10.0.0.1 (l’adresse de **vmbr1**) et ainsi vérifier la connectivité au sein du **VmWanNET**

## Finalisation via la WebUI

* Se connecter à la WebUI via un navigateur à l’adresse https://192.168.9.254 ...

> ... Quoi ? ... Ça ne marche pas ? ... Sûr ? ... C’est con ...

Bon pour ceux qui suivent encore, félicitations ! Pour les autres, l’interface **LAN** de PFSense n’est pour l’instant pas accessible depuis l’extérieur ... et c’est tant mieux car le password et le login sont toujours ceux par défaut. La solution la plus simple est donc de créer une VM avec n’importe quel OS, du moment qu’il possède une interface graphique et un navigateur web (et que ce n’est pas un Windows). Une Ubuntu Desktop, à télécharger sur [le site officiel][21], fera parfaitement l’affaire.

Je ne vais pas revenir sur la création de la VM, sachez juste que 5 Go de disque et 512 Mo de RAM suffisent. N’oubliez pas de bridger la carte réseau sur **vmbr2** pour accéder au réseau **LAN**. Vous pouvez également, une fois la VM crée, modifier le paramètre Hardware > Display en « VMWare compatible » c’est qui vous permettra de disposer d’autres résolutions plus confortable que le minuscule 800×600.

Une fois l’OS installé, il faut tout de même paramétrer le réseau manuellement puisque nous n’avons pas (encore) de serveur DHCP fonctionnel :

```
- IP : 192.168.9.10 (Peu importe tant qu'on reste dans 192.168.9.0/24)
- Netmask : 255.255.255.0
- Gateway : 192.168.9.254
- DNS : 8.8.8.8
```

* Se connecter à la WebUI via un navigateur à l’adresse https://192.168.9.254 (non mais vraiment cette fois)

```
Username : admin
Password : pfsense
```

### Suivez le (White) Wizard

Rapport à ma VM PFsense qui se nomme Olorin ... pertinent pour un pare-feu ...

« You Shall Not Pass ! » ... ok si vous l’avez toujours pas j’abandonne.

* Choisir un hostname (non pas celui-là, c’est le mien) et le(s) serveur(s) DNS souhaité(s)
* Valider ou modifier le FQDN du serveur NTP

Pour la suite rien à modifier en principe puisque nous avons fait les réglages via la console précédemment.

* Vérifier la configuration de l’interface **WAN**

```
IP Address : 10.0.0.2
Subnet Mask : 30
Upstream Gateway : 10.0.0.1
```


* Vérifier la configuration de l’interface LAN

LAN IP Address : 192.168.9.254  
Subnet Mask : 24

* Changer le mot de passe administrateur
* Recharger la configuration et l’accueil du dashboard s’affiche

![](/2017/07/proxmox-install_pfsense-main-screen.png)

# Configuration du réseau (suite)

## Routage et NAT

Particulièrement pour cette partie, je vous encourage à garder le plan réseau à portée de vue.

Pour l’instant, le **WAN** du PFSense communique bien avec le vmbr1 ,normal me direz vous, ils sont sur le même segment réseau et **WAN** est ponté sur vmbr1 dans Proxmox. Maintenant nous allons faire le nécessaire pour pouvoir sortir sur internet depuis la patte WAN du PFSense et donc également depuis le LAN par la suite.

* Pour cela, créer un petit script sur le serveur Proxmox

```
vi /root/kvm-networking-up.sh
```

* Coller les lignes suivantes :

```
#!/bin/sh

## IP forwarding activation
echo 1 &amp;amp;amp;gt; /proc/sys/net/ipv4/ip_forward

# Point PFSense WAN as route to VMs
ip route change 192.168.9.0/24 via 10.0.0.2 dev vmbr1

# Point PFSense WAN as route to VPN
ip route add 10.2.2.0/24 via 10.0.0.2 dev vmbr1
```

Comme indiqué dans les commentaires :

* La première ligne active le routage
* La deuxième indique au serveur de sortir par vmbr1 puis de passer par le **WAN** du PFSense pour communiquer avec les VMs. Cela permet d’isoler **vmbr2** du reste de « PrivNET », cette sécurité sera renforcée, lors de la configuration d’iptables par un blocage complet des flux sur **vmbr2**.
* Même chose pour la dernière mais pour communiquer avec le(s) client(s) du VPN que nous configurerons dans la suite de l’article.

Puis pour qu’il soit lancé automatiquement au boot, lors du démarrage de vmbr1 :

* Lui permettre de s’exécuter

```
chmod +x /root/kvm-networking-up.sh
```


* Paramétrer son appel dans le fichier « interfaces »

```
vi /etc/network/interfaces
```


Ajouter la ligne en gras à la fin du bloc de configuration du bridge vmbr2 :

```
[...]
auto vmbr1
 iface vmbr1 inet static
 address 10.0.0.1
[...]

auto vmbr2
 iface vmbr2 inet static
[...]
 bridge_fd 0
```


 **post-up /root/kvm-networking-up.sh**

Comme je vous ai promis qu’on ne rebooterait plus au début de cette article, on va simplement l’exécuter manuellement pour cette fois :

```
/root/kvm-networking-up.sh
```


[Edit zwindler]M4vr0x a oublié qu’il a déplacé une règle IPtable pour rediriger le traffic de l’IP externe vers le pfsense... La ligne suivante ne marche pas encore, mais à l’étape d’après[/Edit]

* Relancer la console VNC du PFSense et taper « 7 » pour vérifier le ping vers l’internet (genre 8.8.8.8)

## Sécurisation de l’hyperviseur via iptables

Voilà on a presque terminé mais pendant qu’on s’amusait, et malgré les mesures prises au début de ce tuto, une armée de bots (et pas que des chinois), des hordes de BlackHat ainsi que l’intégralité de la NSA, du GCHQ et de ... l’ANSSI ? ... se tirent la bourre pour essayer de pénétrer sur votre petit serveur sans défense.

Je n’aurais donc que trois choses à dire :

  1. Si vous ne savez pas ce qu’est le GCHQ, il faut absolument lire [ce magnifique article](/2015/10/07/test_espionnage_citoyen_gchq/) !
  2. Si vous ne savez pas ce qu’est la NSA ... là je ne peux plus rien pour vous
  3. Nous n’allons pas mourir sans combattre et nous allons au moins ... essayer de les ralentir !

![](/2017/07/proxmox-install_this-is-spartha.jpg)

### Création des règles

Nous allons créer un script pour exécuter toutes les commandes iptables requises. Je vous encourage à ne pas automatiser son lancement au boot avant d’être totalement sûr que tout fonctionne bien.

Pour ceux qui ont pris iptables en deuxième langue au collège, je vous donne directement le contenu du script (à copier sur le serveur Proxmox) :


Pour les autres, je vous conseille de bien lire (et comprendre tant qu’à faire) ce qui suit jusqu’à la fin avant de vous lancer. J’ai commenté quasiment chaque ligne mon script le plus explicitement possible, donc je vais simplement vous expliquer le rôle de chacune des parties :

_VARIABLES _: On commence par la variabilisation des noms de bridges, des @IP et des réseaux. Cela vous permettra de l’adapter rapidement à votre configuration si elle diffère. Quoi qu’il en soit, il faut absolument définir la variable « _PublicIP_ » avec celle de votre serveur.

_CLEAN ALL & DROP IPV6_ : Ensuite on supprime toutes les règles existantes.

Petit point d’attention, le script, légèrement bourrin, flush toutes les tables et supprime toutes les chaines personnalisées vides à chaque exécution. Si vous voulez éviter ça, pour garder votre/vos chaines Fail2ban existantes par exemple, je vous conseille de plutôt spécifier les tables et chaines à nettoyer.

_DEFAULT POLICY_ : On positionne les polices par défaut à DROP : tout ce qui ne sera pas explicitement autorisé sera interdit (comme à l’armée ... \o/ ça faisait longtemps).

**_CHAINS_** : On crée des chaines personnalisées pour éviter la répétition des options.

_**GLOBAL RULES**_ : Elles permettent les communications from/to l’interface locale, préservent les connections déjà actives et autorisent la réponse au ping.

_RULES FOR PrxPubVBR _: On passe à la configuration des flux pour l’interface bridge vmbr0, c’est ici que tout se joue.

L’idée est simple, on ne va autoriser que les services du Proxmox auxquels on souhaite pouvoir accéder depuis internet via l’IP public (donc le moins possible). **TOUS** les autres flux seront redirigés sur l’interface **WAN** du PFSense ce qui nous permettra, comme expliqué au début, d’éviter une pénible gestion de deux firewall chaînés. Une fois que le VPN sera configuré on pourra d’ailleurs désactiver l’accès externe à la WebUI. Pour le SSH on pourra garder un accès de secours en cas de problème avec le futur VPN.

**_RULES FOR PrxVmWanVBR _**: Pour vmbr1, c’est très simple, on autorise seulement les connexions, en provenance du LAN des VMs et du/des client(s) VPN,  à sshd et l’interface web de Proxmox.

_**RULES FOR PrxVmPrivVBR**_ : Pour vmbr2, encore mieux, on laisse tout fermé !

De plus, comme paramétré précédemment, aucune route ne passe par ce bridge. C’est un moyen simple et assez efficace d’isoler au maximum cette interface du réseau auquel elle appartient. Le mieux aurait été d’utiliser une configuration similaire au mode « _promiscuous_ » des Vswitchs d’ESX mais je n’ai pas trouvé d’équivalent pour KVM. Une autre solution utilisant la seconde interface physique du serveur est à l’étude par mon expert en sécurité et fera peut être l’objet d’un article spécifique ou d’une MAJ future. D’ailleurs j’en profite :

> Merci Nico, Merci Zwindler !
> 
> La clusterisation de nos cerveaux (non ce n’est pas sale) m’a fait gagner beaucoup de temps :-D

Et voilà ! (avec l’accent américain) Vous avez bien bossé et vous disposez d’une infra totalement fonctionnelle et relativement bien sécurisé, GG !

Il nous restera bien sûr à configurer les règles adéquates sur PFSense pour les services de vos futures VMs auxquels vous souhaiterez accéder depuis l’extérieur et configurer un serveur VPN afin d’y accéder directement au chaud depuis votre nouveau **LAN.**

Nous allons voir tout ça dans [la troisième et dernière partie de cette article par ici](/2017/07/25/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-3/).

 [4]: https://docs.ovh.com/x/iIQUAQ
 [5]: https://cisofy.com/lynis/
 [6]: https://packages.cisofy.com/community/
 [8]: http://www.infosniper.net/index.php?ip_address=222.190.105.10&map_source=1&overview_map=1&lang=1&map_type=1&zoom_level=7
 [9]: https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-14-04
 [15]: https://www.pfsense.org/download/
 [21]: https://www.ubuntu.com/download/desktop
