---
title: '[Tutoriel] Faire un petit cluster Proxmox chez Kimsufi avec OpenVPN'
authors:
  - zwindler
type: post
date: 2017-08-29T11:40:23+00:00
url: /2017/08/29/faire-un-petit-cluster-proxmox-avec-2-machines-kimsufi/
image: /2017/08/proxmox_logo.png
categories:
  - systeme
  - Virtualisation
tags:
  - Cluster
  - corosync
  - easy-rsa
  - openvpn
  - Proxmox
  - pve
  - réseau
  - virtualisation
  - VPN

---
## C’est la rentrée, vous reprendrez bien un petit article sur Proxmox !

Ou plutôt, c’est bientôt la rentrée et il est grand temps que je solde les articles qui trainent dans mes tiroirs car je moi pars bientôt en vacances.

> « Et tout le monde s’en fout »

J’ai donc rédigé un tutoriel pas à pas pour vous montrer qu’on peut créer rapidement un petit cluster sous Proxmox avec deux petites machines chez un hébergeur pas cher type Kimsufi (j’avais justement deux machines car j’ai profité d’une promo chez eux), sans que les machines soient dans le même sous réseau IP.

![](/2017/08/kimsufi01.png)

Si vous ne connaissez pas Proxmox, je vous renvoie vers [les articles que M4vr0x ou moi avons écris sur le sujet](/recherche/?keyword=Proxmox).

## Pourquoi un tutoriel pour les clusters Proxmox ?

Vous allez me dire, pourquoi un énième article sur le sujet ? [La documentation officielle, même si elle est en anglais][3], est assez claire et il existe plusieurs tutoriels en Français pour le faire.

Ah ah oui... mais la distinction c’est « faire un cluster de machines Proxmox, **sans que les machines soient dans le même sous réseau IP** » !

Et à moins que vous ayez une chance de ouf’, il est peu probable que vos deux Kimsufi le soient.

## Petit rappel des prérequis pour faire un cluster Proxmox

  * Deux serveurs physiques (au minimum)
  * Port 22 accessible au moins dans un premier temps pour configurer le cluster
  * Que la latence d’un serveur à l’autre soit inférieure à 2ms
  * Que les deux serveurs soient capables de communiquer en multicast

> Et là, c’est le drame !

Jusqu’à ce qu’on arrive à la dernière ligne, nous étions sereins.

Si jamais vous avez deux serveurs chez Kimsufi (ou autre) et que vous essayez de les faire communiquer en multicast, vous allez vite vous rendre compte que le multicast est bloqué !

Impossible donc de faire fonctionner correctement votre cluster Proxmox (basé sur **corosync**) sans cela. Vous pouvez mettre tous les autres tutos à la poubelle ;-).

## Bidouille & compagnie, et les risques encourus

Si vous vous sentez la curiosité de monter quand même un cluster sur votre Kimsufi, on va contourner le problème en montant un VPN entre les deux machines. [M4vr0x a déjà détaillé l’utilisation d’OpenVPN avec pfSense sur Proxmox](/2017/07/25/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-3/), mais on n’était pas dans le même contexte.

On ne peut pas se baser là dessus dans le cas présent car Proxmox a la fâcheuse manie de **réinitialiser toute la configuration lorsqu’on démarre le mode « cluster »** .

**ATTENTION !!!**  
Oui, ça veut bien dire que vous ne verrez plus ni vos VMs existantes, ni le stockage que vous avez précédemment configuré...  
Les VMs continuent d’exister et sont accessibles tant que vous ne rebootez pas. Le stockage aussi. Ce n’est juste plus visible.


Vous l’avez deviné, c’est du vécu : j’ai flingué ma configuration existante lorsque j’ai initialisé le cluster.

## Mise en réseau

Maintenant que vous savez ce que vous risquez, on va donc configurer tout ça à la main, directement en SSH sur les machines Proxmox :

### Sur le serveur 1

La première chose à faire est simplement d’installer **openvpn**, ainsi qu’un utilitaire qui s’appelle **easy-rsa** qui va nous faciliter la tâche de configuration.

```
apt-get update
apt-get upgrade
apt-get install openvpn easy-rsa
```


Une fois que c’est fait, on copie les templates de config et les scripts de easy-rsa et on modifie les valeurs par défaut par nos propres valeurs.

```
cp -ai /usr/share/easy-rsa/ /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa/
vi vars
[...]
# These are the default values for fields
# which will be placed in the certificate.
# Don't leave any of these fields blank.
export KEY_COUNTRY="FR"
export KEY_PROVINCE="Aquitaine"
export KEY_CITY="Bordeaux"
export KEY_ORG="mondomaine.tld"
export KEY_EMAIL="key@mondomaine.tld"
export KEY_OU="key"
```


Sourcez le fichier nouvellement rempli :

```
. ./vars
```


Nettoyez les clés provenant d’anciennes itérations de l’outil (pas nécessaire si c’est la première fois mais si vous n’en êtes pas au premier coup, ça peut éviter des erreurs bêtes) :

```
./clean-all
```


Et enfin, on génère l’ensemble des clés dont vous aurez besoin (les CA, les clés serveurs, les clés clientes et la diffie helmann) :

```
./build-ca
./build-key-server serveur1.mondomaine.tld
./build-key serveur2.mondomaine.tld
./build-dh
```


Normalement tout devrait se passer sans encombre et vous devriez avoir plusieurs certificats nouvellement créés. On va copier les certificats du serveur OpenVPN dans le dossier /etc/openvpn, puis envoyer les certificats du client par SCP :

```
cp keys/ca.* keys/serveur1.mondomaine.tld.* keys/dh2048.pem /etc/openvpn/

scp keys/ca.crt keys/serveur2.mondomaine.tld.crt keys/serveur2.mondomaine.tld.key serveur2.mondomaine.tld:/etc/openvpn/
```


Maintenant qu’on a tout, on peut créer le fichier de configuration. Ici rien de bien compliqué à comprendre :

  * On créé un fichier server.conf qui va monter un VPN sur le port 1194 en UDP via un device de type TAP (j’y reviendrai) et on force le réseau en 10.9.0.0/24
  * On donne le chemin vers tous les certificats qu’on vient de créer
  * On ajoute un script « up » et un script « down », avec l’option script-security à « 2 » sinon ça ne fonctionnera pas

```
cat > /etc/openvpn/server.conf << EOF
    # [server.conf]
    port 1194
    proto udp
    #dev tun
    dev tap
    ca /etc/openvpn/ca.crt
    cert /etc/openvpn/serveur1.mondomaine.tld.crt
    key /etc/openvpn/serveur1.mondomaine.tld.key
    dh /etc/openvpn/dh2048.pem
    server 10.9.0.0 255.255.255.0
    ifconfig-pool-persist ipp.txt
    keepalive 10 120
    comp-lzo
    persist-key
    persist-tun
    status openvpn-status.log
    verb 3
    script-security 2
    up /etc/openvpn/add_multicast_route
    down /etc/openvpn/add_multicast_route
EOF
```


Bon et qu’est ce qu’il contient ce fameux script ? Et bien pour l’instant il se contente simplement d’ajouter et de supprimer une route sur les serveurs qui va router « à la main » tout le traffic multicast non par vers la gateway, mais vers le VPN ! Et c’est comme ça qu’on va contourner le blocage des flux multicast entre nos deux Kimsufi !

```
vi /etc/openvpn/add_multicast_route
    #!/bin/bash
    #
    # Add a route to force multicast through VPN
    
    [ "$script_type" ] || exit 0
    
    case "$script_type" in
      up)
            route add -net 224.0.0.0 netmask 240.0.0.0 dev $1
            ;;
      down)
            route del -net 224.0.0.0 netmask 240.0.0.0 dev $1
            ;;
    esac
chmod +x /etc/openvpn/add_multicast_route
```


On termine par démarrer (et activer au démarrage) le serveur OpenVPN :

```
systemctl enable openvpn
systemctl start openvpn
```


Dans ce cas là, comme on est pas en réel mode client serveur ou l’ensemble du traffic client est routé sur le serveur on a pas besoin de modifier le paramètre kernel « ip_forward » :

```
sysctl net.ipv4.ip_forward
   net.ipv4.ip_forward = 0
```


### Aparté tun vs tap

Les plus aguerris d’entre vous auront remarqués que j’ai volontairement choisi de ne pas utiliser une interface virtuelle de type **tun** (par défaut dans OpenVPN) mais une interface de type **tap**.  
Historiquement, ce type d’interface est connu pour ne pas fonctionner correctement en multicast, ce qui est ici notre but principal.

A priori c’est censé être résolu depuis longtemps, mais chez moi ça n’a pas marché alors que dès que j’ai switché sur **tap** ça a fonctionné directement. Je vous engage à regarder si ça vous intéresse. J’ai mis un lien vers une discussion à ce sujet sur le forum d’OpenVPN en fin d’article.

### Sur le serveur 2

Maintenant que le serveur est configuré, au tour du client. Même topo, à ceci près qu’on ne va pas générer de certificats (c’est déjà fait).

```
apt-get update
apt-get upgrade
apt-get install openvpn

cat > /etc/openvpn/client.conf << EOF
 # [client.conf]
 client 
 #dev tun
 dev tap
 proto udp
 remote @IP_publique_du_serveur1 1194
 resolv-retry infinite
 nobind
 persist-key
 persist-tun
 mute-replay-warnings
 ca /etc/openvpn/ca.crt
 cert /etc/openvpn/serveur2.mondomaine.tld.crt
 key /etc/openvpn/serveur2.mondomaine.tld.key
 ns-cert-type server
 comp-lzo 
 verb 3 
 script-security 2 
 up /etc/openvpn/add_multicast_route 
 down /etc/openvpn/add_multicast_route
EOF 
```


```
vi /etc/openvpn/add_multicast_route
    #!/bin/bash
    #
    # Add a route to force multicast through VPN
    
    [ "$script_type" ] || exit 0
    
    case "$script_type" in
      up)
            route add -net 224.0.0.0 netmask 240.0.0.0 dev $1
            ;;
      down)
            route del -net 224.0.0.0 netmask 240.0.0.0 dev $1
            ;;
    esac

chmod +x /etc/openvpn/add_multicast_route
systemctl enable openvpn
systemctl start openvpn
```


Facile, hein ?

### Sur tous les nœuds

Pour s'assurer que tout fonctionne comme ça devrait (ou pour déboguer), vous pouvez autoriser temporairement la réponse à l'ICMP sur multicast. Un simple ping permettra de s'assurer que les deux serveurs se voient bien :

```
sysctl net.ipv4.icmp_echo_ignore_broadcasts=0

root@serveur1:/etc/pve# ping 224.0.0.1
PING 224.0.0.1 (224.0.0.1) 56(84) bytes of data.
64 bytes from 10.9.0.1: icmp_seq=1 ttl=64 time=0.019 ms
64 bytes from 10.9.0.2: icmp_seq=1 ttl=64 time=1.07 ms (DUP!)
64 bytes from 10.9.0.1: icmp_seq=2 ttl=64 time=0.020 ms
64 bytes from 10.9.0.2: icmp_seq=2 ttl=64 time=0.672 ms (DUP!)
64 bytes from 10.9.0.1: icmp_seq=3 ttl=64 time=0.020 ms
64 bytes from 10.9.0.2: icmp_seq=3 ttl=64 time=0.619 ms (DUP!)
```


Les deux serveurs répondent aux pings depuis l'interface du VPN, on est bons ! Du coup vous pouvez re-désactiver la réponse aux broadcasts avec la commande suivante :

```
sysctl net.ipv4.icmp_echo_ignore_broadcasts=1
```


Pour faciliter la résolution de noms dans le cluster, vous pouvez ajouter les IPs VPN des serveurs dans le fichier /etc/hosts.

```
vi /etc/hosts
[...]
10.9.0.1        serveur1-vpn
10.9.0.2        serveur2-vpn
```


## Création du cluster

### Sur le nœud 1

En théorie, si on lit la documentation il suffit simplement de faire "pvecm create mycluster" et le tour est joué.

**STOOOOP !**

Si vous le faite, ça ne fonctionnera pas (et vous pourrez [vous en sortir avec cet article](/2017/09/19/tutoriel-demonter-proprement-cluster-proxmox-ve/)). Pourtant tout est correct au niveau des prérequis : les nœuds fonctionnent bien et que le multicast est correctement routé via le VPN. Un coup d’œil au fichier de configuration de corosync nous en apprendra plus :

```
cat /etc/pve/corosync.conf
logging {
  debug: off
  to_syslog: yes
}

nodelist {
  node {
    name: serveur2
    nodeid: 2
    quorum_votes: 1
    ring0_addr: serveur2
  }

  node {
    name: serveur1
    nodeid: 1
    quorum_votes: 1
    ring0_addr: serveur1
  }

}

quorum {
  provider: corosync_votequorum
}

totem {
  cluster_name: mycluster
  config_version: 4
  ip_version: ipv4
  secauth: on
  version: 2
  interface {
    bindnetaddr: @IP_publique_du_serveur1
    ringnumber: 0
  }

}
```


En fait le problème ici, c'est que l'adresse bindée **bindnetaddr:** n'est pas bonne. Si vous n'avez pas lu mon gros "STOOOOP", il faut tout réinitialiser car il est assez compliqué de modifier un cluster existant sous Proxmox (a priori pas possible proprement mais je vous donnerai la tips dans un prochain article).

Voilà la bonne commande à taper :

```
pvecm create mycluster -bindnet0_addr 10.9.0.1 -ring0_addr serveur1-vpn
    Corosync Cluster Engine Authentication key generator.
    Gathering 1024 bits for key from /dev/urandom.
    Writing corosync key to /etc/corosync/authkey.
```


### Sur le noeud 2

En théorie, là aussi c'est très facile. Il suffit de faire "pvecm add serveur2-vpn" pour que l'hôte serveur2.mondomaine.tld rejoigne le cluster créé sur le noeud serveur1.mondomaine.tld.

Voilà ce qui va se passer si vous le faites :

```
pvecm add serveur1-vpn
    The authenticity of host 'serveur1-vpn (10.9.0.1)' can't be established.
    ECDSA key fingerprint is SHA256:VOIH2X7kTzWLUEzRPCl4431hlYnc3HCsDmzXYEs3V+g.
    Are you sure you want to continue connecting (yes/no)? yes
    root@serveur1-vpn's password:
    copy corosync auth key
    stopping pve-cluster service
    backup old database
    Job for corosync.service failed because the control process exited with error code.
    See "systemctl status corosync.service" and "journalctl -xe" for details.
    waiting for quorum...
```


Même principe ici. Si l'adresse **ring0_addr** n'est pas spécifiée explicitement, corosync va tenter de s'abonner sur une IP multicast sur l'IP de l'interface Ethernet principale. Elle ne passera donc pas pas notre VPN et le cluster ne communiquera pas en multicast !

Vous pouvez [en lire plus là dessus sur ce lien][6].

Sur le noeud serveur2, on ajoute donc l'adresse IP (et donc l'interface) que corosync devra emprunter pour communiquer avec serveur1-vpn (via le VPN donc).

```
pvecm add serveur1-vpn -ring0_addr 10.9.0.2
    The authenticity of host 'serveur1-vpn (10.9.0.1)' can't be established.
    ECDSA key fingerprint is SHA256:oKkuOYY1pbEa1RrM0y9fWVJfnQabhUvG7la+6fZUnQ4.
    Are you sure you want to continue connecting (yes/no)? yes
    root@serveur2-vpn's password:
    copy corosync auth key
    stopping pve-cluster service
    backup old database
    waiting for quorum...OK
    generating node certificates
    merge known_hosts file
    restart services
    successfully added node 'serveur2' to cluster.
```


A partir de là, tout devrait marcher. Vous devriez avoir sur la même interface vos deux serveurs, et avoir perdu toutes vos VMs si vous n'avez pas bien lu mon avertissement ;-)

![](/2017/08/pve_cluster_1.png)

A noter : chose qui n'était pas possible entre la version 3 et la version 4 (car les deux composants n'utilisaient pas le même logiciel pour le clustering), il est possible de faire un cluster ProxMox mixant version 4 et version 5 comme le montre cette capture d'écran :

![](/2017/08/pve_cluster_2.png)

## Aller plus loin : les limites d'OpenVPN

On a maintenant un cluster de 2 machines Proxmox. Pour autant, ce n'est pas idéal et ça ne suffira pas pour passer en production, notamment en cas de coupure réseau entre les deux machines (split brain). On va vite vouloir en rajouter au moins une, sinon plus.

Cependant, on sera bloqués. Les limites de cette méthode est que la configuration d'OpenVPN est en mode client-serveur. Si vous avez plus de 2 machines, vous vous rendrez vite compte que vous pouvez communiquer entre les clients et le serveurs, mais pas entre clients.

Et en gros ça ne marche pas, le 3ème noeud ne rejoindra pas le cluster car il ne peut pas joindre l'ensemble des membres et il se mettra en defaut.

Pour bien faire en conservant ce mécanisme, il va falloir monter un service VPN externe aux serveurs Proxmox, qui seront tous clients de ce service, ou alors se créer un réseau de type full mesh, par exemple avec de l'IPSec si vous êtes un maitre en Réseau/Telco.

Autant dire qu'il vaut mieux passer par un hébergeur qui permet le multicast ou qui fourni un service VPN. Ca ira plus vite...

## Sources et sujets connexes

  * [Un autre tuto qui ne me semble pas 100% exact, notamment la partie création et "join" du cluster][9]
  * [Sending multicast over a openvpn tunnel][10]
  * [La documentation officielle pour les clusters sur des sous réseaux distincts][11]
  * [Un topic intéressant sur les limites d'OpenVPN et les réseaux full mesh][12]

 [3]: https://pve.proxmox.com/wiki/Proxmox_VE_4.x_Cluster
 [6]: https://pve.proxmox.com/wiki/Separate_Cluster_Network#quorum.expected_votes_must_be_configured
 [9]: http://developers-club.com/posts/251541/
 [10]: https://forums.openvpn.net/viewtopic.php?t=8036
 [11]: https://pve.proxmox.com/wiki/Separate_Cluster_Network
 [12]: http://www.linuxquestions.org/questions/linux-networking-3/openvpn-full-mesh-ubuntu-4175588844/
