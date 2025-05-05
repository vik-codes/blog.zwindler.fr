---
title: 'Création d’un cluster de virtualisation Proxmox VE 5.2.x'
authors:
  - zwindler
type: post
date: 2018-06-05T11:45:33+00:00
url: /2018/06/05/creation-dun-cluster-de-virtualisation-proxmox-ve-5-2-x/
image: /2017/08/proxmox_logo.png
categories:
  - autohebergement
  - systeme
  - Virtualisation
tags:
  - Cluster
  - debian
  - Proxmox
  - Proxmox VE
  - route

---
## Proxmox, le retour

[Proxmox VE 5.2 est sorti le mois dernier !](/2018/05/22/sortie-de-proxmox-ve-5-2-1-les-nouveautes/)

Si vous avez lu un des récaps récents que j’ai pu publier ces derniers mois, vous savez peut être que sur le blog les articles qui parlent de Proxmox sont ceux qui sont le plus lus sur le blog ([en particulier ceux de M4vr0x que je remercie](/recherche/?keyword=Proxmox)).

Après avoir hésité à tout migrer sur [Kubernetes](/recherche/?keyword=Kubernetes) pendant quelques semaines (qui m’aurait facilité le déploiement d’applications hautement disponibles), j’ai décidé finalement de rester sur Proxmox.

Mais (il y a toujours un mais) comme je ne pouvais pas me satisfaire du _status quo_ pour l’autohébergement du blog (à savoir un seul serveur physique, donc un bon gros SPOF), j’ai voulu passer à l’étape supérieure et monter un vrai cluster Proxmox VE, à 2 machines (pour l’instant ; voir le dernier paragraphe).

J’avais déjà rédigé [un article à ce sujet il y a quelques mois](/2017/08/29/faire-un-petit-cluster-proxmox-avec-2-machines-kimsufi/), mais l’article datait de la version 4 de Proxmox VE. Les modifications entre la v4 et la v5 sont significatives, notamment sur les fonctionnalités qui sont apparues depuis et quelques commandes qui ont du changer avec Debian 9 (Proxmox VE 5.2).

## Le pitch

**Vous voulez créer un cluster de machines sous Proxmox pour pas cher.**

Pour ça vous avec donc besoin d’un hébergeur capable de fournir des machines physiques (pour le support de la virtualisation). Ça élimine déjà tous les vendeurs de VPS (le gros des providers sur le marché Français).

Il vous reste quand même des grands noms comme OVH/SYS/Kimsufi, Online ou Ikoula. Personnellement, j’ai opté, dans le cadre de ce cluster, pour des machines chez **OneProvider.com**, qui a de nombreux avantages par rapport à **Kimsufi** tout en étant moins cher pour les configs capable de faire de la virtualisation (CPU avec VTx ou AMDv). J’aurai l’occasion de faire un article là dessus, je pense.

Cependant, quelque soit la solution retenue, il y a un problème qui va vous bloquer tout de suite si vous voulez faire un cluster chez un hébergeur => c’est le multicast, qui est bloqué.

## Multicast ?

Je ne vais pas vous faire un cours de réseaux, mais pour communiquer entre eux, les technologies des clusters Linux (en particulier **corosync**, utilisé par Proxmox) utilisent souvent une plage d’adresses réservées pour les flux multicast. L’ensemble des serveurs d’un même cluster s’abonnent à une IP et communiquent sur le même canal et à tous les membres en même temps.

Le tutoriel de Proxmox VE part du principe que les clusters que vous créez sont dans un seul et même LAN (que vous maîtrisez). Chez un hébergeur, ce n’est évidemment pas le cas. Si on avait pris nos serveurs chez OVH, là encore, on pourrait tirer partie d’un service qu’ils fournissent (vRack), qui virtualise le réseau entre vos machines pour leur faire croire qu’elles sont dans un LAN (alors que pas du tout).

J’ai donc rédigé un tutoriel pas à pas pour vous montrer qu’on peut créer rapidement un petit cluster sous Proxmox avec deux petites machines chez un hébergeur, **multicast bloqué** et sans que les machines soient dans le même sous réseau IP.

## Pourquoi un tutoriel pour les clusters Proxmox ?

Voici les prérequis issus de [la documentation officielle(en anglais)][5]

  * Deux serveurs physiques (strict minimum, mais en réalité supporté à partir de 3)
  * Port 22 accessible au moins dans un premier temps pour configurer le cluster
  * Que la latence d’un serveur à l’autre soit inférieure à 2ms
  * Que les deux serveurs soient capables de communiquer en multicast

## Bidouille & compagnie, et les risques encourus

Ok, donc là clairement, il n’y a pas photo : vous entrez dans un territoire DANGEREUX (comprenez « at your own risk »).

On va contourner ce souci de multicast bloqué en montant un VPN entre les deux serveurs Proxmox.

Ce composant deviendra crucial à votre infra. S’il est en panne, vous n’aurez plus de cluster. Inutile de demander de l’aide à moi ou chez Proxmox en cas de pépin en production, ce n’est pas fait pour.

### Toujours là ?

Visiblement vous continuez à lire et vous n’avez donc pas encore fermé l’onglet Firefox. Vous vous sentez la curiosité de monter quand même un cluster sur vos machines bon marché.

La deuxième chose à savoir c’est que Proxmox a la fâcheuse manie de réinitialiser toute la configuration.

**ATTENTION !!!**  
Oui, vous avez bien lu.

_Ça veut bien dire que vous ne verrez plus ni vos VMs existantes, ni le stockage que vous avez précédemment configuré..._  
_Les VMs continuent d’exister et sont accessibles **tant que vous ne rebootez pas**. Idem pour vos périphériques de stockage. Tout va disparaitre de la console._

Si vous vous dites que j’insiste lourdement, sachez qu’un lecteur en a fait l’amère expérience, malgré mes avertissements ;-)

## Mise en réseau

Maintenant que vous savez ce que vous risquez, on va donc configurer tout ça à la main, directement en SSH sur les machines Proxmox.

### Sur le serveur 1 (uniquement)

La première chose à faire est simplement d’installer **openvpn**, ainsi qu’un utilitaire qui s’appelle **easy-rsa** qui va nous faciliter la tâche de configuration.

```
apt-get update
apt-get upgrade
apt-get install openvpn easy-rsa
```


Une fois que c’est fait, on copie les templates de config et les scripts de **easy-rsa** et on modifie les valeurs par défaut par nos propres valeurs.

```
cp -ai /usr/share/easy-rsa/ /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa/
vi vars
[...]
# These are the default values for fields
# which will be placed in the certificate.
# Don't leave any of these fields blank.
export KEY_COUNTRY="FR"
export KEY_PROVINCE="Nouvelle Aquitaine"
export KEY_CITY="Bordeaux"
export KEY_ORG="mondomaine.tld"
export KEY_EMAIL="key@mondomaine.tld"
export KEY_OU="key"
```


Sourcez le fichier nouvellement rempli :

```
. ./vars
```


Nettoyez les clés provenant d’anciennes itérations de l’outil (pas nécessaire si c’est la première fois, mais si vous n’en êtes pas au premier coup, ça peut éviter des erreurs bêtes) :

```
./clean-all
```


Et enfin, générez l’ensemble des clés dont vous aurez besoin (les CA, les clés serveurs, les clés clientes et la **diffie helmann**) :

```
./build-ca
./build-key-server serveur1.mondomaine.tld
./build-key serveur2.mondomaine.tld
./build-dh
```


Normalement tout devrait se passer sans encombre et vous devriez avoir plusieurs certificats tout neufs. On va copier les certificats du serveur OpenVPN dans le dossier **/etc/openvpn**, puis envoyer les certificats du client par SCP :

```
cp keys/ca.* keys/serveur1.mondomaine.tld.* keys/dh2048.pem /etc/openvpn/

scp keys/ca.crt keys/serveur2.mondomaine.tld.crt keys/serveur2.mondomaine.tld.key serveur2.mondomaine.tld:/etc/openvpn/
```


Maintenant qu’on a tout, on peut créer le fichier de configuration. Ici rien de bien compliqué à comprendre :

  * On créé un fichier **server.conf** qui va monter un VPN sur le port 1194 en UDP via un **device** de type TAP (voir le bonus à la fin) et on force le réseau en 10.1.0.0/24
  * On donne le chemin vers tous les certificats qu’on vient de créer
  * On ajoute un script « up » et un script « down », avec l’option **script-security** à « 2 » sinon ça ne fonctionnera pas

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
 server 10.1.0.0 255.255.255.0
 ifconfig-pool-persist ipp.txt
 keepalive 10 120
 comp-lzo
 persist-key
 persist-tun
 status openvpn-status.log
 verb 3
 script-security 2
 up /etc/openvpn/add_multicast_route
 down /etc/openvpn/remove_multicast_route
EOF
```


Bon, et pourquoi on a besoin de script « up » et « down » déjà ?

Parce que même si par défaut, OpenVPN va ajouter les routes pour que le trafic à destination du VPN passe par le VPN (logique), ce n’est pas le cas de l’ensemble de notre trafic réseau. Le but de ce VPN étant de router les flux multicast sur le VPN, il faut donc ajouter manuellement une route à l’initialisation du VPN.

_**Première différence**_ avec mon article sur les clusters Proxmox en version 4, le binaire « **route** » existait toujours. Or, depuis les dernières versions, ce n’est plus le cas !

```
route
-bash: route: command not found
```


Il a fallu que je le remplace par **ip**, la référence maintenant pour ce genre de manipulations (voir [www.cyberciti.biz/tips/configuring-static-routes-in-debian-or-red-hat-linux-systems.html](https://www.cyberciti.biz/tips/configuring-static-routes-in-debian-or-red-hat-linux-systems.html)).

```
cat /etc/openvpn/add_multicast_route
  #!/bin/bash
  # Add a route to force multicast through VPN
  /sbin/ip route add 224.0.0.0/4 via 10.1.0.1 dev $1
chmod +x /etc/openvpn/add_multicast_route

cat /etc/openvpn/remove_multicast_route
  #!/bin/bash
  # Remove the multicast route
  /sbin/ip route del 224.0.0.0/4
chmod +x /etc/openvpn/remove_multicast_route
```


_**Deuxième problème**_ que j’ai eu avec la version 5.2 de Proxmox VE, un bug sur **systemd** dans Debian qui provoquait une erreur sur mon interface **tap** créée par OpenVPN

```
May 16 22:43:11 serveur1 ovpn-server[24557]: /sbin/ip link set dev tap0 up mtu 1500
May 16 22:43:11 serveur1 systemd-udevd[24558]: Could not generate persistent MAC address for tap0: No such file or directory
```


Heureusement, l’issue est ouverte sur Github ([ici](https://github.com/systemd/systemd/issues/3374)) et des _commenters_ ont proposés un _workaround_

```
cat /etc/systemd/network/99-default.link
 [Link]
 NamePolicy=kernel database onboard slot path
 MACAddressPolicy=none
```


On termine par démarrer (et activer au démarrage) le serveur OpenVPN :

```
systemctl enable openvpn
systemctl start openvpn
```


Dans ce cas là, comme on est pas en réel mode **client/serveur**, l’ensemble du trafic client est routé sur le serveur et on a pas besoin de modifier le paramètre kernel « ip_forward » ([comme on a pu le faire avec les tutos de M4vr0x](/recherche/?keyword=m4vr0x)) :

```
sysctl net.ipv4.ip_forward
 net.ipv4.ip_forward = 0
```


On pourra s’assurer que le trafic sur 224.0.0.0/4 est bien routé sur notre interface VPN avec **ip** :

```
ip route
default via X.X.X.1 dev vmbr0 onlink
10.1.0.0/24 dev tap0 proto kernel scope link src 10.1.0.1
X.X.X.0/24 dev vmbr0 proto kernel scope link src X.X.X.X
224.0.0.0/4 via 10.1.0.1 dev tap0
```


### Sur le serveur 2

Maintenant que le serveur est configuré, au tour du client. Même topo, à ceci près qu’on ne va pas générer de certificats (c’est déjà fait). N’oubliez pas de remplacer `@IP_publique_du_serveur1` et « serveur2.mondomaine.tld. » par les bonnes valeurs ;-)

```
apt-get update
apt-get upgrade
apt-get install openvpn
```


La configuration :

```
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
 down /etc/openvpn/remove_multicast_route
EOF 
```


Et encore nos scripts pour le multicast :

```
cat /etc/openvpn/add_multicast_route
  #!/bin/bash
  # Add a route to force multicast through VPN
  /sbin/ip route add 224.0.0.0/4 via 10.1.0.1 dev $1
chmod +x /etc/openvpn/add_multicast_route

cat /etc/openvpn/remove_multicast_route
  #!/bin/bash
  # Remove the multicast route
  /sbin/ip route del 224.0.0.0/4
chmod +x /etc/openvpn/remove_multicast_route
```

On démarre OpenVPN

```
systemctl enable openvpn
systemctl start openvpn
```

Facile, hein ? (lol)

### Sur tous les nœuds

Pour s’assurer que tout fonctionne comme ça devrait (ou pour déboguer), vous pouvez autoriser temporairement la réponse à l’ICMP sur multicast (normalement désactivé). Un simple ping permettra de s’assurer que les deux serveurs se voient bien :

```
sysctl net.ipv4.icmp_echo_ignore_broadcasts=0

root@serveur1:/etc/pve# ping 224.0.0.1
PING 224.0.0.1 (224.0.0.1) 56(84) bytes of data.
64 bytes from 10.1.0.1: icmp_seq=1 ttl=64 time=0.019 ms
64 bytes from 10.1.0.2: icmp_seq=1 ttl=64 time=1.07 ms (DUP!)
64 bytes from 10.1.0.1: icmp_seq=2 ttl=64 time=0.020 ms
64 bytes from 10.1.0.2: icmp_seq=2 ttl=64 time=0.672 ms (DUP!)
64 bytes from 10.1.0.1: icmp_seq=3 ttl=64 time=0.020 ms
64 bytes from 10.1.0.2: icmp_seq=3 ttl=64 time=0.619 ms (DUP!)
```


Que se passe t’il ? Ici, quand je pingue l’adresse multicast 224.0.0.1, les deux serveurs répondent aux pings depuis l’interface du VPN, on est bons !

_(Corolaire : ça veut aussi dire que si ça ne marche pas, c’est que vous avez loupé quelque chose)_

Du coup vous pouvez re-désactiver la réponse aux broadcasts avec la commande suivante :

```
sysctl net.ipv4.icmp_echo_ignore_broadcasts=1
```

### Sur tous les nœuds

_**Troisième problème**_ : une erreur que j’avais faite dans l’article précédent, était de ne pas modifier le fichier **/etc/hosts**.

Pour permettre la résolution de noms lors des opérations dans le cluster, il **faut** forcer la résolution du nom « monserveurproxmox » vers l’IP VPN (je l’avais mis comme quelque chose d’optionnel).

Sur serveur1, retirez donc serveur1 de la ligne « X.X.X.X serveur1.domaine.tld serveur1 » ...

```
vi /etc/hosts 

127.0.0.1 localhost.localdomain localhost
X.X.X.X serveur1.domaine.tld serveur1
```

... pour que cela ressemble à cela

```
vi /etc/hosts

127.0.0.1 localhost.localdomain localhost 
X.X.X.X serveur1.domaine.tld
10.1.0.1        serveur1 serveur1.vpn
10.1.0.2        serveur2 serveur2.vpn
```

Faire la même chose sur serveur2

**Redémarrer les deux nœuds pour prise en compte.**

## Création du cluster

### Sur le nœud 1

En théorie, si on lit la documentation il suffit simplement de faire **pvecm create mycluster** et le tour est joué.

**STOOOOP !**

Si pour une raison ou pour une autre, Proxmox  décide que serveur1 est résolu par l’IP publique, ça ne fonctionnera pas (et vous pourrez [vous en sortir avec cet article](/2017/09/19/tutoriel-demonter-proprement-cluster-proxmox-ve/)).

Voilà la bonne commande à taper pour être **sûr** qu’on passe par l’interface VPN :

```
pvecm create mycluster -bindnet0_addr 10.1.0.1 -ring0_addr serveur1.vpn
    Corosync Cluster Engine Authentication key generator.
    Gathering 1024 bits for key from /dev/urandom.
    Writing corosync key to /etc/corosync/authkey.
```

### Sur le noeud 2

En théorie, là aussi c’est très facile. Il suffit de faire **pvecm add serveur1.vpn** pour que l’hôte serveur2.mondomaine.tld rejoigne le cluster créé sur le nœud serveur1.mondomaine.tld.

Voilà ce qui va se passer si vous le faites :

```
pvecm add serveur1.vpn
    The authenticity of host 'serveur1.vpn (10.1.0.1)' can't be established.
    ECDSA key fingerprint is SHA256:VOIH2X7kTzWLUEzRPCl4431hlYnc3HCsDmzXYEs3V+g.
    Are you sure you want to continue connecting (yes/no)? yes
    root@serveur1.vpn's password:
    copy corosync auth key
    stopping pve-cluster service
    backup old database
    Job for corosync.service failed because the control process exited with error code.
    See "systemctl status corosync.service" and "journalctl -xe" for details.
    waiting for quorum...
```


Même principe ici. Si l’adresse **ring0_addr** n’est pas spécifiée explicitement, **corosync** va tenter de s’abonner sur une IP multicast sur l’IP de l’interface Ethernet principale. Elle ne passera donc pas pas notre VPN et le cluster ne communiquera pas en multicast !

Vous pouvez [en lire plus là dessus sur ce lien][8].

Sur le noeud serveur2, on ajoute donc forcer l’adresse IP (et donc l’interface) que corosync devra emprunter pour communiquer avec **serveur1.vpn** (via le VPN donc).

```
pvecm add serveur1.vpn -ring0_addr 10.1.0.2
    The authenticity of host 'serveur1.vpn (10.1.0.1)' can't be established.
    ECDSA key fingerprint is SHA256:oKkuOYY1pbEa1RrM0y9fWVJfnQabhUvG7la+6fZUnQ4.
    Are you sure you want to continue connecting (yes/no)? yes
    root@serveur2.vpn's password:
    copy corosync auth key
    stopping pve-cluster service
    backup old database
    waiting for quorum...OK
    generating node certificates
    merge known_hosts file
    restart services
    successfully added node 'serveur2' to cluster.
```

A partir de là, tout devrait marcher. Vous devriez avoir sur la même interface vos deux serveurs, et avoir perdu toutes vos VMs si vous n’avez pas bien lu mon avertissement ;-)

![](/2018/05/proxmox_cluster52.png)

## Bonus : les limites d’OpenVPN

On a maintenant un cluster de 2 machines Proxmox. Pour autant, ce n’est pas idéal et ça ne suffira pas pour passer en production, notamment en cas de coupure réseau entre les deux machines (split brain). On va vite vouloir en rajouter au moins une, sinon plus. Et paf ! Encore bloqués !

La limite de cette méthode est que la configuration d’OpenVPN est en mode client-serveur => si vous avez plus de 2 machines, vous vous rendrez vite compte que vous pouvez communiquer entre les clients et le serveurs, mais pas « entre clients ».

En gros, le 3ème noeud ne rejoindra pas le cluster car il ne peut pas joindre l’ensemble des membres et il se mettra en defaut.

Pour bien faire en conservant ce mécanisme, il va falloir soit monter un service VPN externe aux serveurs Proxmox, qui seront tous clients de ce service (attention au SPOF), ou alors se créer un réseau de type full mesh, par exemple avec de l’IPSec si vous êtes un maitre en Réseau/Telco.

Autant dire qu’il vaut mieux passer par un hébergeur qui permet le multicast ou qui fourni un service VPN. Ca ira plus vite...

## Bonus : tun vs tap

Les plus aguerris d’entre vous auront remarqués que j’ai volontairement choisi de ne pas utiliser une interface virtuelle de type **tun** (par défaut dans OpenVPN) mais une interface de type **tap**.  
Historiquement, ce type d’interface est connu pour ne pas fonctionner correctement en multicast, ce qui est ici notre but principal.

A priori c’est censé être résolu depuis longtemps, mais chez moi ça n’a pas marché alors que dès que j’ai switché sur **tap** ça a fonctionné directement. Je vous engage à regarder si ça vous intéresse. J’ai mis un lien vers une discussion à ce sujet sur le forum d’OpenVPN à la suite.

## Sources et sujets connexes

  * [Un autre tuto qui ne me semble pas 100% exact, notamment la partie création et « join » du cluster][10]
  * [Sending multicast over a openvpn tunnel][11]
  * [La documentation officielle pour les clusters sur des sous réseaux distincts][12]
  * [Un topic intéressant sur les limites d’OpenVPN et les réseaux full mesh][13]

 [5]: https://pve.proxmox.com/wiki/Proxmox_VE_4.x_Cluster
 [8]: https://pve.proxmox.com/wiki/Separate_Cluster_Network#quorum.expected_votes_must_be_configured
 [10]: http://developers-club.com/posts/251541/
 [11]: https://forums.openvpn.net/viewtopic.php?t=8036
 [12]: https://pve.proxmox.com/wiki/Separate_Cluster_Network
 [13]: http://www.linuxquestions.org/questions/linux-networking-3/openvpn-full-mesh-ubuntu-4175588844/
