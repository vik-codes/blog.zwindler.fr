---
title: Proxmox VE 6 + pfsense sur un serveur dédié (2/2)
authors:
  - CharlesBordet
  - zwindler
type: post
date: 2020-03-09T11:49:55+00:00
excerpt: "Tutoriel de déploiement d'un serveur Proxmox VE 6 sécurisé par un serveur PFsense"
url: /2020/03/09/proxmox-ve-6-pfsense-sur-un-serveur-dedie-2-3/
image: /2020/03/article_logo_pfsense_proxmox.png
categories:
  - autohebergement
  - Cluster
  - systeme
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
  
Dans l’article précédent, nous avons mis en place notre serveur Proxmox, l’avons sécurisé, puis avons téléchargé puis installé une machine virtuelle PFSense qui va nous faire office de point d’entrée unique.

* [Proxmox VE 6 + pfsense sur un serveur dédié (1/2)](/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie/)

### Routage du trafic vers la PFSense
  
  
Comme nous l’avons déjà évoqué, l’hyperviseur est en première ligne. Et la PFSense est en 2e ligne et nos VMs, bien au chaud derrière.

L’objectif, c’est d’avoir la PFSense en 1e ligne. D’un point de vue purement réseau, l’hyperviseur va s’effacer en ne devenant rien de plus qu’un routeur.

La première chose à corriger, c’est qu’actuellement, il existe un raccourci qui permet de passer directement de l’hyperviseur aux VMs puisqu’ils sont tous sur le réseau LAN. Dans notre schéma mental, on ne veut pas que ce soit possible puisque tout doit passer par pfsense.

Essayez par exemple de pinger 192.168.9.10 depuis l’hyperviseur, ou de pinger 192.168.9.1 depuis la VM.


![](/2020/02/ping_1.png) 


Sur l’hyperviseur, on va ajouter une _route_ qui dit : Tous les paquets vers le LAN doivent passer par l’interface WAN de la PFSense. C’est cette règle qui nous permet de forcer tout le trafic à passer par la PFSense, comme si la PFSense était en frontal, avant d’arriver dans le LAN.

On crée un fichier /root/pfsense-route.sh` avec la commande suivante.


```
cat > /root/pfsense-route.sh << EOF
#!/bin/sh

## IP forwarding activation
echo 1 > /proc/sys/net/ipv4/ip_forward

## Rediriger les paquets destinés au LAN pour l'interface WAN de la PFSense
ip route change 192.168.9.0/24 via 10.0.0.2 dev vmbr1
EOF
```

Pour que ce fichier se lance automatiquement dès qu’on boot, on lance la commande `chmod +x /root/pfsense-route.sh` et on ajoutera à la fin du fichier `/etc/network/interfaces` la ligne `post-up /root/pfsense-route.sh` à la fin du bloc de configuration de vmbr2, juste avant le commentaire `#LAN` :

```
[...]
auto vmbr2
iface vmbr2 inet static
        address 192.168.9.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        post-up /root/pfsense-route.sh
#LAN
```

Si vous exécutez ce fichier `/root/pfsense-route.sh`, et que vous essayez de nouveau de ping l’hyperviseur depuis la VM, ou l’inverse, ça ne devrait plus aboutir. Cela signifie que le petit paquet essaye bien de passer par PFSense, et comme on lui a rien dit, PFsense drop sans mot dire.

![](/2020/04/pfsense_drop.png)


Note: Ça veut aussi dire que notre beau tunnel SSH ne fonctionnera plus à terme (si vous avez choisi cette solution plutôt que la "VM rebond")...

Si jamais, pour débugger, vous avez besoin de laisser passer le ping, on peut le réactiver de manière sélective dans PFSense.

Dans l’interface de la PFSense, on va commencer par aller dans Status / System Logs. Puis cliquez sur l’onglet Firewall. Le but ici c’est de vous montrer un moyen de débugger au cas où vous auriez des problèmes.

Sur cette page, vous verrez toutes les connexions bloquées par le pare-feu.

Si vous descendez dans la page, vous allez voir les pings qui ont été bloqués.

![](/2020/02/ping_block_pfsense.png)


Cette vue est utile car elle vus permet de voir tout ce qui a été récemment bloqué. Les petits (-) et les petits (+) vont vous permettre d’ajouter rapidement des règles, respectivement pour dropper ou autoriser des connexions similaires que PFSense rencontrerait à l’avenir.

Si vous voulez tout faire vous même (car vous souhaitez comprendre et maitriser ce que vous faites), allez plutôt dans Firewall/Rules. Cliquez sur Add puis entrez les paramètres suivants :
  
* Action : Pass
* Interface : WAN
* Address Family : IPv4
* Protocol : ICMP
* Source : Any
* Destination : Any
      
  
Cette règle assez permissive permet d’autoriser tous les paquets en protocole ICMP. Une fois ajoutée, n’oubliez pas d’appliquer les changements. Puis réessayez de faire pinger vos machines. Le ping est de retour ! Mais il passe par la PFSense cette fois-ci.

### Port forwarding de la PFSense
  
  
Maintenant que la base de notre script fonctionne, on va continuer à ajouter des règles iptables. Comme il est assez long, je vais vous l’expliquer et on va le remplir au fur et à mesure. Pour ceux qui veulent la version complète du fichier immédiatement, elle est disponible [ici](/2020/05/proxmox6_pfsense.txt).

Note : Le gros souci avec iptables` et les règles de firewalling en général, c’est que même quand on est expert, si jamais vous vous êtes planté (ou que pour une raison ou pour une autre, les commandes que je donne ne sont pas 100% compatibles dans votre contexte il y a une petite subtilité) vous risquez de vous couper l’accès.

Un bon moyen de limiter ce genre de risque est de suivre la procédure suivante à chaque fois que vous faites une modification :
  
* faire une copie datée des fichiers `/etc/network/interfaces`, `/root/pfsense-route.sh` et `/root/iptables.sh` avant toute modif
* désactiver/supprimer les lignes avec le `post-up /root/pfsense-route.sh` et/ou `/root/pfsense-route.sh` dans `/etc/network/interfaces`, ce qui vous permettra de retrouver la main après une reboot
* exécuter le script à la main une première fois, puis ne rebooter seulement que _SI TOUT fonctionne_ (en testant de nouvelles connexions)

Si jamais vous vous êtes scié la jambe (ou la branche, ou tiré une balle dans le pied), un reboot et une restauration du fichier initial vous tirera d’affaire.
  
Note bis Ne lancez pas non plus ces instructions une par une. En effet, la première chose qu’on fait, par convention, c’est de TOUT dropper, pour re-autoriser ensuite au compte goûte. Donc si vous avez de grande chance de vous bloquer vous même.

### 1/6 Variables
  
  
Avant de commencer quoique ce soit, récupérez l’adresse IP publique de votre machine. On en aura besoin dans le script. Vous pouvez la trouver dans l’interface de votre Proxmox si elle est visible depuis votre hyperviseur, ou a minima dans l’interface de votre provider.

Ensuite, on l’exporte dans le bash pour qu’elle soit intégrée de manière transparente dans le futur script iptables.sh


```
export PUBIP=xx.xx.xx.xx
```

Faite ensuite la même chose pour le port que vous avez choisi dans le tuto précédent pour SSH (22 par défaut, mais le tuto précédent donne un port arbitraire, 22153)

```
export SSHPORT=22153
```

Puis créez la première partie du script en copiant collant simplement cette commande en entier dans un terminal (le cat` va copier proprement les lignes dans un fichier texte)


```
cat > /root/iptables.sh << EOF
#!/bin/sh

    # ---------
    # VARIABLES
    # ---------

## Proxmox bridge holding Public IP
PrxPubVBR="vmbr0"
## Proxmox bridge on VmWanNET (PFSense WAN side) 
PrxVmWanVBR="vmbr1"
## Proxmox bridge on PrivNET (PFSense LAN side) 
PrxVmPrivVBR="vmbr2"

## Network/Mask of VmWanNET
VmWanNET="10.0.0.0/30"
## Network/Mmask of PrivNET
PrivNET="192.168.9.0/24"
## Network/Mmask of VpnNET
VpnNET="10.2.2.0/24"

## Public IP => Your own public IP address
PublicIP="${PUBIP}"
## Proxmox IP on the same network than PFSense WAN (VmWanNET)
ProxVmWanIP="10.0.0.1"
## Proxmox IP on the same network than VMs
ProxVmPrivIP="192.168.9.1"
## PFSense IP used by the firewall (inside VM)
PfsVmWanIP="10.0.0.2"
EOF
```



Cette première partie est inoffensive, on définit les variables. Ça permet d’éviter de ré-écrire des milliers de fois les mêmes adresses IPs et de rendre le script un peu plus lisible.

Point très important, vérifiez bien que le fichier contient bien votre adresse IP publique à la ligne qui commence par `PublicIP=`

### 2/6 DROP & start again !
  
  
Par contre, à partir de maintenant ça se gâte. Par défaut, on spécifie qu’on interdit tout. Tous les paquets sont droppés.


```
cat >> /root/iptables.sh << EOF

    # ---------------------
    # CLEAN ALL & DROP IPV6
    # ---------------------

### Delete all existing rules.
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
### This policy does not handle IPv6 traffic except to drop it.
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
    
    # --------------
    # DEFAULT POLICY
    # --------------

### Block ALL !
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

    # ------
    # CHAINS
    # ------

### Creating chains
iptables -N TCP
iptables -N UDP

# UDP = ACCEPT / SEND TO THIS CHAIN
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
# TCP = ACCEPT / SEND TO THIS CHAIN
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP

    # ------------
    # GLOBAL RULES
    # ------------

# Allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Don't break the current/active connections
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Allow Ping - Comment this to return timeout to ping request
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
EOF
```



Ensuite, on crée des chaînes qui vont capturer toutes les nouvelles connexions TCP et UDP, respectivement.
Et enfin, on ajoute des règles un peu de base :
  
* On accepte les connexions localhost
* On ne stoppe pas les connexions existantes. Comme votre connexion SSH par exemple.
* On autorise les pings. Parce que c’est pratique pour débugger.
      
  
Si vous vous demandez ce qui se passerait si vous lanciez le script maintenant, il ne se passerait rien, tant que vous n’essayeriez pas d’ouvrir une nouvelle connexion (SSH par exemple), car on accepte les connexions déjà ouvertes. En revanches, toutes les nouvelles échoueraient...

Pas terrible, donc on continue...

### 3/6 INPUT
  
```
cat >> /root/iptables.sh << EOF

    # --------------------
    # RULES FOR PrxPubVBR
    # --------------------

### INPUT RULES
# ---------------

# Allow SSH server
iptables -A TCP -i \$PrxPubVBR -d \$PublicIP -p tcp --dport ${SSHPORT} -j ACCEPT
# Allow Proxmox WebUI
iptables -A TCP -i \$PrxPubVBR -d \$PublicIP -p tcp --dport 8006 -j ACCEPT
EOF
```



Ces règles sont à propos de l’interface vmbr0, celle qui nous relie à Internet. On ajoute deux règles :
  
* On autorise les nouvelles connexions sur le port SSH qui passent par vmbr0 et dont la destination est notre IP publique.
* On autorise les nouvelles connexions sur le port 8006 qui passent par vmbr0 et dont la destination est notre IP publique.
      
  
Ça c’est seulement pour les paquets entrant, donc les personnes qui veulent initier une connexion avec nous.

Note : vérifiez bien que la ligne juste en dessous de `# Allow SSH server` contient bien le port que vous utilisez pour SSH (et qu’on a exporté dans la variable SSHPORT) !

Plus tard, on pourra même supprimer ces règles. À la place, on se connectera au VPN, et à partir de là on aura accès au SSH ou au Proxmox.

### 4/6 OUTPUT
  
  
Ensuite, on ajoute les paquets sortants :

```
cat >> /root/iptables.sh << EOF

### OUTPUT RULES
# ---------------

# Allow ping out
iptables -A OUTPUT -p icmp -j ACCEPT

### Proxmox Host as CLIENT
# Allow HTTP/HTTPS
iptables -A OUTPUT -o \$PrxPubVBR -s \$PublicIP -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -o \$PrxPubVBR -s \$PublicIP -p tcp --dport 443 -j ACCEPT
# Allow DNS
iptables -A OUTPUT -o \$PrxPubVBR -s \$PublicIP -p udp --dport 53 -j ACCEPT

### Proxmox Host as SERVER
# Allow SSH 
iptables -A OUTPUT -o \$PrxPubVBR -s \$PublicIP -p tcp --sport ${SSHPORT} -j ACCEPT
# Allow PROXMOX WebUI 
iptables -A OUTPUT -o \$PrxPubVBR -s \$PublicIP -p tcp --sport 8006 -j ACCEPT
EOF
```

D’abord, on autorise les pings à sortir. Cette règle est redondante avec une autre précédente où on autorisait les pings dans tous les sens.

L’idée, c’est que la règle précédente est très permissive pour pouvoir debugger. Mais elle est pas censée rester pour toute la vie.

Par contre, autoriser un ping sortant, ça peut toujours servir à l’occasion, et ça pose zéro problème de sécurité.

Puis j’autorise les paquets HTTP et HTTPS à sortir. Ça c’est ce qui va nous donner accès à l’internet. D’ailleurs vous pouvez essayer. Envoyez un ping vers 1.1.1.1 avant d’entrer ces nouvelles règles, ça devrait être bloqué, puis ré-essayez après avoir entré ces nouvelles règles, et ça devrait marcher !

Cette règle vous servira par exemple à télécharger des images ISO ou à mettre à jour le serveur. Ce n’est pas cette règle qui sert à donner accès à l’internet au VM par contre.

Et c’est tout pour les règles output. Vous noterez que m4vr0x en avait ajouté pas mal plus. Je vous conseille d’en rajouter seulement si vous en avez besoin. De base, on est parcimonieux.

Par exemple les règles output pour le port SSH et le port 8006 ne sont pas nécessaires. En effet, on les accepte déjà dans INPUT, ce qui permet à votre ordinateur local d’initier une connexion avec le serveur. Une fois la connexion initiée, tous les paquets sont autorisés (c’est la règle qu’on avait ajouté dans les GLOBAL RULES). La plupart des règles concernent les nouvelles connexions.

### 5/6 FORWARD
  
  
Finalement, il ne reste plus qu’à dire qu’on route tout le trafic vers la PFSense :


```
cat >> /root/iptables.sh << EOF

### FORWARD RULES
# ----------------

### Redirect (NAT) traffic from internet 
# All tcp to PFSense WAN except ${SSHPORT}, 8006
iptables -A PREROUTING -t nat -i \$PrxPubVBR -p tcp --match multiport ! --dports ${SSHPORT},8006 -j DNAT --to \$PfsVmWanIP
# All udp to PFSense WAN
iptables -A PREROUTING -t nat -i \$PrxPubVBR -p udp -j DNAT --to \$PfsVmWanIP

# Allow request forwarding to PFSense WAN interface
iptables -A FORWARD -i \$PrxPubVBR -d \$PfsVmWanIP -o \$PrxVmWanVBR -p tcp -j ACCEPT
iptables -A FORWARD -i \$PrxPubVBR -d \$PfsVmWanIP -o \$PrxVmWanVBR -p udp -j ACCEPT

# Allow request forwarding from LAN
iptables -A FORWARD -i \$PrxVmWanVBR -s \$VmWanNET -j ACCEPT
EOF
```



Le début est une règle de PREROUTING. Ça veut dire que l’action s’exécute sur le paquet avant toute autre chose. Par exemple, si José essaie de se connecter sur le port 3812 de votre Nextcloud, on veut pas forcément le dropper. Ce genre de décision sera le futur boulot de la PFSense. Sans la règle de pré-routing, le paquet serait droppé par défaut.

Donc à la place, on l’envoie... vers la PFSense.

Notez que cette règle s’applique SAUF pour les ports SSH et 8006, qui ont un traitement un peu particulier. De nouveau, plus tard, quand vous aurez mis le VPN, on pourra aussi supprimer ces règles.

Le paragraphe suivant va de pair avec ce qu’on vient de faire. En gros ça dit : Si un paquet est en transfert d’Internet vers la PFSense, alors on l’autorise. Et ça tombe bien, puisqu’on vient juste de dire que tous les paquets qui viennent d’Internet sont automatiquement transférés vers la PFSense.

Finalement, on fait aussi l’inverse. Tous les paquets qui sont en transfert depuis la PFSense (et donc qui se dirigent de toute vraisemblance vers Internet) sont acceptés aussi. La communication, ça va dans les deux sens.

Donc là, je résume : Un paquet vient d’Internet. On le pré-route vers la PFSense. On accepte ce transfert. La PFSense le reçoit. La PFSense va prendre une décision, par exemple l’envoyer vers une VM, recevoir une réponse, puis renvoyer ce paquet vers Internet. On accepte ce transfert de nouveau.

On a tout ce qu’il faut pour que les VMs aient accès à Internet.

### 6/6 MASQUERADE
  
  
SAUF ! Le port forwarding. La petite astuce en gros qui permet à une machine d’un réseau local à accéder à Internet sans avoir d’IP publique :


```
cat >> /root/iptables.sh << EOF
### MASQUERADE MANDATORY
# Allow WAN network (PFSense) to use vmbr0 public adress to go out
iptables -t nat -A POSTROUTING -s \$VmWanNET -o \$PrxPubVBR -j MASQUERADE
EOF
```



A partir de là, le script est prêt. Tentez de l’exécutez et si vous ne vous jetez pas dehors bravo vous avez gagné !


```
chmod +x /root/iptables.sh
/root/iptables.sh
```

Là maintenant votre LAN est raccordé à Internet.

## Spécificité VirtIO
  
  
Sauf si... vous aviez choisi VirtIO comme modèle de carte réseau dans le tuto précédent.

Si vous pingez 1.1.1.1 depuis votre VM Ubuntu, vous allez réussir à joindre Internet. C’est un signe que les règles que nous avons mises fonctionnent bien. Mais... pourtant, l’accès à Internet ne va pas forcément marcher.

C’est un problème qui m’a cassé la tête pendant longtemps. Jusqu’à ce que je tombe sur ce thread au titre évocateur : "Quelqu’un a-t-il réussi à *** un *** de PFSense avec Proxmox (lien mort)"

En fait, la solution est documentée sur le [site officiel de pfsense (lien mort, j'utilise Internet Archive)](https://docs.netgate.com/pfsense/en/latest/recipes/virtualize-proxmox.html)

La solution est donc d’aller dans System / Advanced / Networking au niveau des paramètres PFSense et de cocher la case Disable hardware checksum offload.

Et pouf, ça marche.

## On est pas mal là ?
  
A partir de maintenant, vous pouvez vous amuser à regarder les logs du firewall de la PFSense et vous verrez toutes les gentilles personnes qui se font refouler.

On a bien avancé, mais il reste encore quelques petits détails à voir :
  
* On doit toujours passer par une VM Ubuntu Desktop pour paramétrer la PFSense. Pas pratique.
* Le Proxmox est accessible depuis Internet. Pas optimal niveau sécurité.
* On ne sait pas comment servir un service depuis une VM qui soit accessible depuis Internet (un serveur nginx par exemple).
* Et aussi comment servir un service pour des besoins internes (un serveur SSH par exemple).
      
  
On va voir comment résoudre tout ça dans la prochaine partie. Et puis après on verra comment mettre un VPN en place pour que ce soit bien sécurisé.

## Hébergement de services
  
  
Mais je suis sûr que vous avez hâte d’utiliser le potentiel de votre hyperviseur dès maintenant ! En tout cas, moi j’avais hâte :D

Donc faisons-le, mais promettez-moi qu’après vous ferez les étapes pour mettre le VPN ;-p

### Un serveur nginx sur Internet
  
  
Pour l’exemple ici, on va utiliser notre VM UbuntuDesktop. C’est vraiment pour l’exemple, parce que je pense que c’est mieux d’isoler les services. 1 VM = 1 service.

On va donc aller sur la VM, et dans le terminal on install nginx: `sudo apt install nginx` (faites un update d’abord).

Une fois l’installation faite, vérifiez que le serveur fonctionne bien en allant sur `http://localhost` à partir de la VM. Vous devriez voir l’écran de bienvenue de nginx.


![](/2020/02/welcome_to_nginx.png) 


Maintenant, on veut arriver à accéder à cette page depuis Internet. Depuis chez nous quoi. Pour ça, on va aller dans la configuration de la PFSense, et cliquer sur Firewall/NAT, puis ajouter :
  
* Interface : WAN
* Protocol : TCP
* Destination : Any
* Destination Port Range : 8001
* Redirect target IP : 192.168.9.10
* Redirect target port : 80
* Description : Serveur nginx
      
  
Ici il faut bien avoir en tête qu’on se met du point de vue de la VM dans le LAN. Donc destination signifie la destination du paquet qui part de la VM. On veut qu’il arrive d’Internet, sur le port 8001. Ce choix de port est complètement libre.

Le Redirect target IP, c’est l’IP de la VM, ainsi que le port initial du serveur nginx. Là on n’a pas le choix par contre.

On valide et on applique les changements.

Vous remarquerez qu’une règle a automatiquement été ajoutée dans Firewall/Rules. Oui parce que c’est bien de mettre un NAT en place, mais si le port 80 n’est pas ouvert au niveau de la PFSense, les paquets ne passeront pas.

On attend une petite minute, et on essaie d’accéder : `http://proxmox.example.org:8001`.



![](/2020/02/welcome_to_nginx2.png) 


Gagné !

### Un serveur SSH sur l’internet privé  
  
Bon, maintenant supposons qu’on veuille mettre en place un serveur SSH.

Oui parce que la console via l’interface de Proxmox, c’est ok, mais bon, autant utiliser le terminal dont on a l’habitude.

C’est différent du serveur nginx parce que cette fois-ci, on n’a pas besoin de le déployer publiquement. Moi je dis que si un service est réservé à un usage privé, il faut le laisser privé. Sinon on multiplie les angles d’attaque pour les méchants.

Donc là l’objectif c’est de pouvoir se connecter en SSH sur notre machine UbuntuDesktop à partir de l’hyperviseur. Donc oui, il faut d’abord SSH dans l’hyperviseur, et à partir de là, on SSH dans la VM. Trop d’étapes ? Plus tard, avec le VPN, vous pourrez directement SSH dans la machine sans cette étape intermédiaire.

Premièrement, installons le serveur SSH sur la VM Ubuntu : `sudo apt install openssh-server`. De base, il va écouter sur le port 22, et on va laisser ça comme ça.

Vous l’avez compris, il va falloir ouvrir le port sur la PFSense. Pas de NAT cette fois-ci, juste une ouverture de port. Donc dans Firewall/Rules :
  
* Action : Pass
* Interface : WAN
* Address Family : IPv4
* Protocol : TCP
* Source : Single host = 10.0.0.1
* Destination : LAN net (on pourrait se limiter à notre VM, mais on va probablement vouloir se connecter en SSH systématiquement à toutes les VMs)
* Destination port Range : 22
* Description : SSH pour les VMs
      
  
On valide, on applique les changements, on attend une petite minute, et on essaie depuis l’hyperviseur : `ssh charles@192.168.9.10`.

Timeout.

![](/2020/02/ah.png)

> Ah !

Pourquoi ?

C’est là que je vous annonce que tout à la fin de ce tutorial, vous trouverez une section Comment débugger qui vous apprendra comment écouter des paquets et comprendre ce qui se passe sur vos machines. Voici un petit récap en attendant.

Un moyen de comprendre les flux de paquets, pourquoi ils sont bloqués, où est-ce qu’ils sont bloqués, etc., c’est d’utiliser la commande `tcpdump` qui permet de sniffer le trafic sur votre machine. Cette commande m’a énormément aider pour suivre le tuto de m4vr0x, donc je vous donne l’astuce aussi.

Un `tcpdump -i vmbr1 -p tcp` permet d’écouter sur l’interface WAN. Outre le bruit des méchants qui tapent à votre porte, on s’attend à voir des paquets SSH aller de 10.0.0.1 vers 192.168.9.10. Il n’en est rien. Ça veut dire quoi ? Ça veut dire que les paquets ne partent même pas de la machine. Pourquoi ?
...

Les iptables ! Mais oui. On n’a jamais dit qu’on acceptait de faire sortir des paquets sur le port 22.

Une autre astuce de tonton : Dans le fichier iptables qu’on avait créé, vous pouvez rajouter l’instruction suivante : `iptables -A OUTPUT -p tcp -o vmbr1 -j LOG`. 

Placez-la avant les instructions qui bloquent tout (donc vers le début du fichier). Ça vous permettra d’enregistrer tout le trafic qui correspond à l’instruction (en l’occurrence, ici, les paquets sortants en TCP sur l’interface vmbr1), et donc de voir ce qui est bloqué et ce qui ne l’est pas. Les logs s’enregistrent dans `/var/log/syslog`.

Ici, tout simplement, on va dire qu’on autorise les paquets à sortir sur l’interface vmbr1. Rajoutez à la fin du fichier iptables ces quelques lignes :

```
cat >> /root/iptables.sh << EOF
    # --------------------
    # RULES FOR PrxVmWanVBR
    # --------------------

### Allow being a client for the VMs
iptables -A OUTPUT -o \$PrxVmWanVBR -s \$ProxVmWanIP -p tcp -j ACCEPT
EOF
```

(Promis, on y touche plus)

Ici, vous avez peut-être deux questions qui vous viennent à l’esprit.

On avait pas _déjà_ l’ensemble du trafic qui était autorisé de l’hyperviseur vers la PFSense ?! Alors, oui, mais seulement en FORWARD. On avait mis une règle qui acceptait tous les paquets qui provenaient d’Internet et qui étaient transférés vers la PFSense. Là, dans ce cas, on accepte tous les paquets en provenance de l’hyperviseur vers la PFSense.

Pourquoi on ne limite pas au port 22 ? C’est un peu brutal cette ouverture générale non ? C’est vrai. L’idée, c’est de ne pas avoir à toucher à ce fichier dès qu’on veut rajouter un service. On sous-traite la gestion des autorisations à la PFSense. Et comme c’est seulement les connexions qui sont issues de l’hyperviseur, donc les communications internes, ce n’est pas gênant.

De nouveau, le VPN résoudra ce genre de problèmes.

À présent, essayez de vous connecter en SSH depuis l’hyperviseur vers la VM, et ça marche !

### Accéder à la PFSense depuis Internet
  
  
Dernier petit point important avant de passer au VPN : Comment accéder à la PFSense depuis votre laptop sans utiliser cette VM qui lag du cul ? (Oui bon désolé mais là j’écris ce tutorial en étant en Asie et ma VM est en Allemagne, c’est horrible le lag !)

~~C’est très simple. On va juste ouvrir le port HTTPS sur la PFsense. Ajoutons la règle suivante :~~
  
* ~~Action : Pass~~
* ~~Interface : WAN~~
* ~~Address Family : IPv4~~
* ~~Protocol : TCP~~
* ~~Source : Any~~
* ~~Destination : This firewall (self)~~
* ~~Destination Port Range : HTTPS~~
* ~~Description : Accès à la PFSense depuis Internet~~

~~À présent, si vous vous connectez sur https://example.org, vous pourrez accéder à la PFSense.~~

**Note de zwindler** : On préférera plutôt ajouter une règle similaire à la précédente qui autorise `10.0.0.1` à accéder à 192.168.9.254 sur le port 443. Ceci nous permettra de refaire marcher notre tunnel SSH (qui ne marche plus depuis qu’on a ajouté la route en tout début de ce 2ème article) pour avoir la console pfsense en local sur votre machine Linux ou Windows.


![](/2020/05/pfsense_tunnel.png) 


## Sécuriser les services privés avec un VPN
  
  
Bon, c’est bien tout ça. On est presque au bout.

Mais il reste des problèmes :
  
* J’aime pas trop avoir cette PFSense accessible par n’importe qui (zwindler: "moi non plus"). Y’a que moi qui en ai besoin après tout.
* Pareil pour l’hyperviseur Proxmox, que ce soit au niveau de l’accès SSH ou de l’interface web.
* Et puis c’est chiant pour SSH dans une VM. Il faut faire 2 étapes. C’est long 2 étapes !
      
  
Woh woh.. calmos ! Le VPN va résoudre tous ces problèmes.

L’idée c’est qu’on va créer un nouveau réseau virtuel : 10.2.2.0/24. La PFSense sera dans ce réseau virtuel. Et on va pouvoir se connecter dans ce réseau virtuel, de telle sorte que notre laptop aura une IP privée du type 10.2.2.2 (le 10.2.2.1 sera réservé à la PFSense).

À partir de là, modulo 2-3 changements, on pourra accéder au LAN à travers la PFSense. Et évidemment, il n’y a que nous qu’on aura le droit de se connecter au VPN.
Et le truc super cool, c’est que la PFSense rend cette création de VPN su-per-sim-ple. Allez, c’est parti ! Déjà, il faut créer des certificats.

### Création de l’autorité de certification
  
  
Dans la PFSense, on clique sur System/Cert. Manager. puis Ajouter :
  
* Descriptive Name : L’autorité de Certification
* Method : Create an internal Certificate Authority
* Key length : 2048 (note de zwindler: MINIMUM, n’hésitez pas à mettre 4096)
* Digest Algorithm : sha256
* Lifetime : 3650
* Common Name : example.org (changez pour le nom de votre autorité)
* Country Code : FR
      
  
### Création du certificat pour le serveur
  
  
Maintenant on clique sur l’onglet « Certificates », puis Ajouter :
  
* Method : Create an internal Certificate
* Descriptive Name : Le serveur VPN
* Certificate authority : Choisissez votre autorité de certification nouvellement créée
* Key length : 2048 (note de zwindler: MINIMUM, n’hésitez pas à mettre 4096)
* Digest Algorithm : sha256
* Lifetime : 3650
* Common Name : vpn.example.org (changez pour le nom du serveur VPN)
* Certificate Type : Server Certificates
      
  
### Création du certificat pour le client
  
  
On recrée un nouveau certificat, mais changer le type à la fin :
  
* Method : Create an internal Certificate
* Descriptive Name : Le client VPN
* Certificate authority : Choisissez votre autorité de certification nouvellement créée
* Key length : 2048 (note de zwindler: MINIMUM, n’hésitez pas à mettre 4096)
* Digest Algorithm : sha256
* Lifetime : 3650
* Common Name : vpn-client.example.org (changez pour le nom du client VPN)
* Certificate Type : User Certificates
      
  
C’est fini pour la création de certificats !



![](/2020/02/certificats.png) 

### Création du serveur VPN
  
  
On va dans VPN/OpenVPN et Ajouter :
  
* Server mode : Remote Access (TLS + User Auth)
* Protocol : UDP
* Interface : WAN
* Local Port : 18223 : De nouveau, on change le port par défaut.
* Description : Mon VPN
* TLS Configuration : Activé
* Peer Certificate Authority : Choisissez votre autorité de certification
* Server Certificate : Choisissez le certificat pour le serveur
* DH Parameter Length : Note de zwindler - n’hésitez pas à passer à 4096
* Encryption Algorithm : N’hésitez pas à choisir un peu plus que le choix par défaut AES-128
* IPv4 Tunnel Network : 10.2.2.0/24
* Redirect IPv4 Gateway : Activé. Cette case vous permettra d’accéder à l’internet à travers le VPN. Sinon, vous pouvez spécifier le réseau local auquel vous souhaitez accéder avec le VPN (192.168.9.0/24 dans notre cas).
* Concurrent connections : 3. Une pour l’ordi, une pour le téléphone, et une pour un attaquant. Non je déconne :D Mettez 2. Ou en tout cas, mettez le nombre correspondant au nombre d’appareils que vous connecterez simultanément.
* Compression : Disable Compression. Conseillé pour ne pas être sensible aux attaques VORACLE.
* Push Compression : Cochez la case. Ne pas cocher cette case m'empêchait de me connecter via mon laptop sous linux. Mais ça marchait avec Android. Cocher juste la case et épargnez-vous le mal de crâne.
* Dynamic IP : Cochez la case.
      
  
Et voilà !
Maintenant il nous faut un utilisateur et on pourra se connecter.

### Création de l’utilisateur pour le VPN
  
Dans System/User manager, cliquez sur Ajouter.
  
* Disabled : On ne coche pas la case.
* Username : charles
* Password : xxx

Enregistrer. Puis retournez éditer l’utilisateur et ajoutez-lui le certificat client que nous avons créé plus tôt. Dans User Certificates, cliquez sur Ajouter, puis :
  
* Method : Choose an existing certificate
* Existing Certificate : Le Client VPN

On enregistre.

### Configuration du client

On est bon !
On peut facilement exporter un fichier de configuration pour automatiquement configurer votre client VPN, que ce soit sous Windows, Mac, Linux, Android, ou votre machine à café intelligente. Oui oui, il est conseillé de connecter vos _objects connectés_ à un VPN si vous souhaitez y accéder à distance. Ce sont de vraies passoires de sécurité.

On va dans System/Package Manager, puis Available Packages, et on cherche _export_.



![](/2020/02/openvpn-client.png) 


Puis on install openvpn-client-export.
On retourne dans VPN/OpenVPN, et on trouve le nouvel onglet Client Export.
  
* Remote Access Server : Mon VPN
* Host Name Resolution : *Other* puis on renseigne l’IP publique de notre serveur.
* Use Random Local Port : On coche la case.      
  
On enregistre et on scrolle jusqu’en bas.


![](/2020/02/openvpn-client2.png) 


Ici on a plein de possibilités d’exports.

Moi je prends le Most Clients parce que ça marche chez moi.

Voilà voilà.

Ensuite, sur mon ordinateur local, qui est un Ubuntu, je vais dans la configuration Réseau, et je clique sur le petit + à côté de VPN. Je choisis "Import from file..." et j’importe le fichier que je viens juste de télécharger. Il vous faudra peut-être installer le client openvpn d’abord, si vous n’avez pas l’option.

Normalement, tout est déjà pré-rempli, sauf, le username et le password. Entrez ceux de l’utilisateur qu’on a créé plus tôt.


![](/2020/02/openvpn-client3.png) 

Et voili voiloù !

Ça marche chez vous ?

Parce que chez moi, pas encore...

Ah oui. Toujours ces histoires de pare-feu. C’est ennuyant à la fin.

### Ouverture des chakras
  
Il y a deux modifications à faire.

Imaginez un paquet du VPN. Il arrive sur votre serveur. Il demande son chemin pour aller vers son réseau, c’est-à-dire 10.2.2.0/24. Que lui dit la table de routage ?


```
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         xx.xx.xx.xx     0.0.0.0         UG        0 0          0 vmbr0
10.0.0.0        0.0.0.0         255.255.255.252 U         0 0          0 vmbr1
xx.xx.xx.xx     0.0.0.0         255.255.255.224 U         0 0          0 vmbr0
192.168.9.0     10.0.0.2        255.255.255.0   UG        0 0          0 vmbr1
```

En gros : retourne chez toi.

On va rajouter une route pour le VPN. Retournez dans le fichier /root/pfsense-route.sh` et rajoutez cette ligne :


```
## Rediriger les paquets destinés au VPN pour l'interface WAN de la PFsense
ip route add 10.2.2.0/24 via 10.0.0.2 dev vmbr1
```

Ensuite, exécuter le fichier. Assurez-vous que la route est bien correcte avec `netstat -r -n`.

Là on dit aux paquets destinés au réseau VPN d’aller vers la PFSense. Elle saura bien quoi en faire. Est-ce qu’on doit modifier les iptables ? Non, les paquets en transfert qui viennent d’Internet sont déjà acceptés.

Alors c’est bon ?

Non.

Il faut que la PFSense accepte ces paquets aussi. Dans l’interface, on rajoute deux règles. La première dit d’accepter les paquets en UDP qui sont à destination de la PFSense sur le port du VPN :
  
* Action : Pass
* Interface : WAN
* Address Family : IPv4
* Protocol : UDP
* Source : Any
* Destination : WAN net
* Destination port range : 18223 (mettez le port du VPN)
* Description : Accès au VPN depuis Internet
      
  
Maintenant, vous pouvez tester le VPN. Vous devriez pouvoir vous connecter et aussi accès à Internet en étant connecté. Oubliez pas d’activer les changements après avoir créé la règle, ça m’arrive tout le temps.

Ah oui en fait non, vous n’allez pas avoir accès à Internet. On n’a pas autorisé les paquets qui proviennent du VPN. On ajoute cette nouvelle règle :
  
* Action : Pass
* Interface : OpenVPN
* Address Family : IPv4
* Protocol : Any
* Source : Network - 10.2.2.0/24
* Destination : Any
* Description : Accès à Internet depuis le VPN
      
  
Et voilà !
À présent, depuis le VPN, vous avez accès à :
  
* Internet
* Les services du WAN, c’est-à-dire la PFSense et le Proxmox (et le SSH vers Proxmox)
* Le réseau LAN. Tapez par exemple 192.168.9.10 dans votre navigateur, et vous tomberez sur le serveur nginx qu’on a déployé plus tôt.
      
  
C’est pas beau ça ?

Bravo ! C’est un solide travail que vous avez fait pour en arriver là.

## Le VPN vous sauvera
  
  
On pourrait s’arrêter là.. Sauf que. J’ai pas arrêté de vous dire tout le long du tuto que « Tel truc sera résolu quand on aura le VPN ». Eh bien il est temps de résoudre ces problèmes.

### Protéger la PFSense
  
Déjà, la PFSense. À l’heure actuelle, elle est disponible sur les internets mondiaux. Si vous allez voir les logs, vous verrez plein d’individus qui s’y heurtent. C’est pas forcément très rassurant.

Et puis, est-ce qu’on a vraiment besoin d’avoir l’interface disponible à la vue de tout le monde ? Bien sûr que non.

Alors supprimez-moi cette règle qu’on avait ajouté :



![](/2020/02/supr_regle_fw_pfsense.png) 


Dans le doute, vous pouvez _seulement_ désactiver la règle en cliquant sur le ✓. Ça vous évitera de la recréer complètement si vous vous êtes planté quelque part.

Vous n’aurez plus accès en tapant `https://example.org` mais plutôt l’IP du LAN : `https://192.168.9.254`. Pour changer le domaine, il faudra mettre en place un serveur DNS interne.

Si vous retournez dans les logs, vous n’en verrez pas moins. Vous en verrez encore plus même ! Puisqu’à présent, vous verrez le blocage du port 443.

### Protéger l’interface web du Proxmox
  
  
Là, on va faire pareil, mais un peu différent. À l’heure actuelle, on accède à l’interface web de Proxmox sans passer par la PFSense.

À la place, on va :

* Rediriger le port 8006 vers la PFSense (en supprimant l’exception dans les iptables). Ceci annulera l’accès depuis Internet.
* Autoriser d’accéder au port 8006 du serveur proxmox depuis la PFSense. Ceci activera l’accès depuis le VPN.
  
Dans le fichier des iptables, on va éditer la ligne suivante :


```
iptables -A PREROUTING -t nat -i $PrxPubVBR -p tcp --match multiport ! --dports 21153,8006 -j DNAT --to $PfsVmWanIP
```


On supprime tout simplement le 8006. Et on exécute le fichier. À présent, vous n’avez plus accès à l’interface web Proxmox du tout !
Oh, et on peut aussi supprimer ces lignes là : la règle qui accepte les paquets sur 8006 aussi, cette ligne-là :

```
iptables -A TCP -i $PrxPubVBR -d $PublicIP -p tcp --dport 8006 -j ACCEPT
iptables -A OUTPUT -o $PrxVmWanVBR -s $ProxVmWanIP -p tcp -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT
```

Autrement dit :
  
* On arrête d’accepter les pings dans tous les sens
* On arrête d’accepter les paquets entrant sur 8006
* On arrête d’accepter les paquets sortant sur le port SSH
      
  
Rappelez-vous que le serveur Proxmox n’est pas une VM ordinaire. C’est une VM avec un fichier iptables ! Il faut juste qu’on lui dise d’accepter les paquets qui viennent de la PFSense. Par où ? Par vmbr1. Rappelez-vous qu’on a condamné l’accès vmbr2. Voici la règle à rajouter dans les iptables :

```
iptables -A TCP -i $PrxVmWanVBR -d $ProxVmWanIP -p tcp --dport 8006 -j ACCEPT
```

Exécutez le fichier. À présent, vous pouvez accéder à `https://10.0.0.1:8006`.

Est-ce qu’on a besoin d’ajouter une règle dans PFSense ? Non ! On a déjà une règle qui dit : Depuis le VPN, on a accès à tout.

### Protéger le SSH du Proxmox
  
  
Bon. Là, on pourrait faire exactement la même opération pour protéger le SSH du Proxmox. De telle sorte qu’il ne soit accessible que depuis le VPN.

Mais ça devient un peu dangereux... Qu’est-ce qui se passe si vous perdez accès au VPN ? Genre vous supprimez la config par erreur. Ou votre ordi meurt et vous n’avez pas backup la config ?

Vous allez passer un sale dimanche.

Alors il est toujours possible de résoudre le problème si votre provider vous donne un accès à la console. Je sais que chez Hetzner, c’est possible gratuitement pendant 3 heures. Mais il faut prendre rendez-vous, c’est un peu galère.

C’est pourquoi mon choix est de garder l’accès SSH sur Internet. Par contre, il faut être bien sûr d’avoir activé fail2ban.

Ah ? On me dit dans l’oreillette que le script iptables efface toutes les règles de fail2ban. Oops.

À la fin du script des iptables, on rajoute l’instruction suivante : `service fail2ban restart`.

Dernière petite chose : Le script iptables ne se lance pas automatiquement au boot. Donc si le Proxmox redémarre, pouf on perd toutes nos règles. C’est beta.

Pour résoudre ça, on va lancer apt install iptables-persistent`. Suivez les consignes, et à présent les règles persisteront après un reboot.

Par contre, si jamais vous _changez_ le fichier des iptables, alors lancez l’instruction `iptables-save > /etc/iptables/rules.v4`.


### Nettoyage des règles superflues

Maintenant qu’on a le VPN, on peut supprimer quelques règles dans la PFSense.
  
* Autoriser les pings ? Finis les pings ! On supprime.
* NATer le serveur nginx ? Oui bon ça ok on garde.
* Autoriser le SSH pour les VMs ? Plus besoin ! Le VPN a accès à tout automatiquement.
* Accès au VPN depuis Internet ? Euuh oui ça on garde !
      
  
Au final, voici mes règles (en gris clair celles qui sont désactivées) :


![](/2020/02/pfsense_rules.png) 


Petite checklist pour vérifier que tout marche bien :

Depuis le VPN :
  
* On a accès à la PFSense sur https://192.168.9.254
* On a accès au Proxmox sur https://10.0.0.1:8006
* On a accès au serveur web nginx sur http://192.168.9.10
* On a accès au serveur web nginx sur l’IP publique et port 8001.
* On peut se connecter en SSH à `charles@192.168.9.10`
      
  
Hors du VPN :
  
* Pas d’accès à la PFSense sur https://example.org
* Pas d’accès au Proxmox sur https://example.org:8006
* On a accès au serveur web nginx sur l’IP publique et port 8001.
* On ne peut pas se connecter en SSH à `charles@192.168.9.10`
      
  
Checks ? Checks !

## Comment débugger
  
  
Je ne m’attends pas forcément à ce que TOUT marche dans ce tutorial.

Ça marche pour moi.

Mais vous avez une machine différente, vous êtes dans le turfu, vous avez un provider différent, vous êtes peut-être même gaucher, qui sait ! Ça me paraît plus important de vous apprendre à vous débrouiller par vous-même que vous donner une liste d’instructions à copier/coller, et puis que quand ça ne marche pas vous soyez coincé.

Je présente donc dans cette section les outils que j’ai appris et que j’ai trouvé très utiles pour débugger.

### Sniffer vos paquets
  
  
Quand vous essayez de pinger un serveur, ou juste de vous y connecter, et que ça ne marche pas, c’est frustrant.

Le pointeur clignote, il se passe rien, et vous savez qu’il ne va rien se passer. Juste si vous attendez 1 minute ou 2, vous allez voir un joli "Timeout".

Ça peut être parce que le paquet s’est perdu, parce qu’il a été mangé par un pare-feu, ou même parce que le service auquel vous tentez d’accéder est hors ligne. Pour comprendre le cheminement d’un paquet, on peut utiliser `tcpdump`.

L’option `-i` permet de spécifier l’interface sur laquelle vous écoutez. Par exemple : `tcpdump -i vmbr0`.

L’option `-p` permet de spécifier le protocole que vous écoutez. Par exemple : `tcpdump -p udp`.

Et l’option `port` permet de spécifier le port. Par exemple : `tcpdump port 22`.

Vous allez voir, ou non, si un paquet sort ou entre de chez vous ou non. S’il ne sort pas, il est en toute vraisemblance bloqué par iptables ou le pare-feu de la machine sur laquelle vous êtes.

Vous pouvez utiliser cette instruction sur l’hyperviseur, sur une VM, et aussi sur la PFSense.

### Loggez les iptables
  
  
Est-ce que le script iptable est en train de dropper les paquets que vous envoyez ?

Rajouter une instruction dans votre script avant l’instruction qui potentiellement droppe votre paquet. Par exemple, ajoutez :

`iptables -A OUTPUT -o vmbr1 -s 10.0.0.1 -p tcp -j LOG`

En gros l’idée c’est de remplacer la fin (ACCEPT) par LOG. Et ensuite les logs s’afficheront dans `/var/log/syslog`.

### Utilisez les logs de PFSense
  
Dans l’interface de la PFsense, vous pouvez aller dans Status / System Logs, puis Firewall, pour voir toutes les connexions bloquées. La vôtre apparaît ? Il faudrait peut-être créer une règle. La vôtre n’apparaît pas ? Alors soit elle est passée, soit elle n’est même pas arrivée sur la PFSense.

Au passage, en cliquant sur le petit +, vous pouvez facilement ajouter une règle qui concerne spécifiquement la connexion qui a été bloquée.

Si vous suspectez qu’elle est passée, alors regardez par où elle est partie en sniffant les paquets de la machine. Soit avec `tcpdump`, soit en allant dans Diagnostics/Packet Capture.

Ah oui, et si vous venez juste de mettre à jour les règles du pare-feu.. donnez-lui quelques minutes. Ça m’est arrivé de me casser la tête sur un problème, de décider d’y revenir plus tard, et quand je suis revenu, le problème était résolu comme par magie. Il fallait juste attendre un peu.

Un problème avec le VPN ? Les logs sont dans Status / System Logs, puis OpenVPN.
