---
title: 'Le blog en IPv6 : ça aurait du être simple et pourtant…'
authors:
  - zwindler
type: post
date: 2021-03-01T07:15:00+00:00
excerpt: "Petit récit et tuto pas à pas pour expliquer comment j'ai ajouté IPv6 sur une VM LXC dans mon Proxmox hébergé chez Oneprovider"
url: /2021/03/01/le-blog-en-ipv6-ca-aurait-du-etre-simple-et-pourtant/
image: /2021/02/ipv6-ready.png
categories:
  - Autohébergement
tags:
  - blog
  - dedibox
  - IPv4
  - IPv6
  - oneprovider
  - online
  - proxmoxve
  - scaleway
  - slaac

---
## C’est l’histoire d’un collègue de boulot

C’est l’histoire d’un collègue de boulot, qui me dit :

> Dis donc zwindler, avec toute la veille que tu fais sur ton blog, comment se fait-il qu’il ne soit toujours pas accessible en IPv6 !?

Damned... Il a raison le bougre !

Mauvaise réponse : par flemme.

Encore plus mauvaise réponse : parce que ce n’est pas aussi trivial à implémenter que ça devrait l’être... 

Allez, je vous embarque !

## D’abord mon infra...

J’vais sauter tout de suite le topo comme quoi IPv6 c’est important et surtout là depuis quasiment 25 ans, que IPv4 est dead depuis un an ou deux, qu’IPv6 c’est pas compliqué en vrai (la partie théorique j’entends ; la pratique on va en parler). De toute façon, les tweets récents de @davlgd me laissent à penser qu’un article sur [NextInpact ](https://www.nextinpact.com/)devrait sortir à ce sujet dans peu de temps ;-).

J’ai changé une énième fois d’infra pour mes besoins persos et me retrouve maintenant avec un serveur hébergé à la maison pour le gros de mes besoins perso, ainsi que deux machines plus modestes (des Atom 2 cœurs, 4 Go) que je loue pour une bouchée de pain pour avoir un cluster Proxmox VE et des réplications ZFS.

(Oui je ferai un article pour en parler... promis... un jour... peut être).

On commence déjà pas super bien : mon opérateur Internet ne me propose pas d’IPv6. Impossible donc de proposer mon blog en IPv6 si je l’héberge depuis chez moi.

Ça tombe bien (sort of), j’ai préféré le laisser sur une des deux machines Atom que je loue, qui suffisent vu le peu de charge que représente le blog. Je pars du principe que les hébergeurs ont de meilleurs taux de dispos que ma maison bourrée de SPOF. L’histoire ne me donne pas forcément raison, mais passons.

## OneProvider

Est-ce que ces machines peuvent être en IPv6 ?

Je me suis pris la tête avec le support de OneProvider à plusieurs reprises, mais punaise, ils sont tellement peu chers... J’avais dit « plus jamais ! », mais des Atom à 6€ / mois pour 4 Go de RAM et un stockage correct... C’est quasiment impossible de trouver mieux.

Si on se contente de regarder ce qu’on a pour ce prix là, « la question elle est vite répondue ». Il n’y a pas d’IPv6 dans l’interface et on ne peut pas en commander. On est cuit...

![](/2021/02/op-net.png)

## Plot twist

Bon ben voilà, pas de solution, fin de l’article.

...

... Mais non !

Car quand on connait un peu les machines à Paris et à Amsterdam de OneProvider, on sait que ce sont en fait des serveurs de chez Online (Scaleway), vendus en marque blanche.

Et là l’espoir renait car Online ne le met pas en avant sur son site directement, mais dans le wiki il est dit que 

> La totalité des réseaux Online/Dedibox est compatible IPv6, et les futurs déploiements auront également de l’IPv6 par défaut.
> https://documentation.online.net/fr/dedicated-server/network/ipv6/start</a>

![](/2021/02/ah.gif)

## Un petit mail au support

Je prends mon courage à deux mains et j’écris au support, en espérant que ça ne finisse pas comme les fois précédentes à les engueuler comme du poisson pourri, car ils m’ont dit que « oui oui c’est possible » et finalement me la mette à l’envers avec des options payantes qui ne me servent à rien et qu’on ne peut pas annuler...

Bonne surprise, cette fois-ci :


![](/2021/02/op-support.png)

OK. On peut donc avoir un bloc en IPv6 (un /64 alors que c’est un /56 chez Online, mais on ne va pas faire les fines bouches) tout en gardant l’IPv4 (j’ai préféré leur demander confirmation, connaissant les zozos).

Les seules difficultés sont donc que l’IP doit être assignée avec un client DHCP (mkay) et qu’on ne peut pas faire de rDNS. Dans mon cas, juste pour que le blog soit en IPv6, c’est suffisant.

Une fois que j’ai indiqué que c’était bon pour moi, le support m’a rapidement envoyé un /64 ainsi qu’un DUID pour le DHCP.

## La configuration du DHCP

A partir de là, le « fun » a pu commencer.

D’abord, il a fallu trouver comment configurer **dhclient** pour chopper correctement mon IPv6. Heureusement on trouve assez vite de l’aide sur le net, notamment sur le wiki d’Online (et ça tombe bien vu que je suis chez eux).

* [documentation.online.net/en/dedicated-server/network/ipv6/prefix](https://documentation.online.net/en/dedicated-server/network/ipv6/prefix)

Long story short; sur des distribs récentes (notamment Proxmox), le plus « simple » est de créer un service systemd qui se lancera au démarrage juste après le réseau

```
cat > /etc/systemd/system/dhclient.service << EOF
[Unit]
Description=dhclient for sending DUID IPv6
After=network-online.target
Wants=network-online.target

[Service]
Restart=always
RestartSec=10
Type=forking
ExecStart=/sbin/dhclient -cf /etc/dhcp/dhclient6.conf -6 -P -v vmbr0
ExecStop=/sbin/dhclient -x -pf /var/run/dhclient6.pid

[Install]
WantedBy=network.target
EOF


cat /etc/dhcp/dhclient6.conf
interface "vmbr0" {
   send dhcp6.client-id VOTRE:DUID;
   request;
}
```


Vous remarquerez peut-être que, contrairement à l’article du wiki d’Online, je n’utilise pas l’interface réseau physique (**enp0s20** dans mon cas) mais un bridge (**vmbr0**). En fait, on a pas trop le choix (sauf si j’ai mal compris), car on va « brancher » nos VMs sur un bridge pour leur affecter des IPv6 et je n’ai pas réussi à faire marcher ça lorsque l’interface qui porte le /64 _n’était pas aussi le bridge_. Si vous avez mieux, je prend les suggestions.

La « blague » dans l’histoire, c’est que je n’utilise pas du tout cette configuration réseau dans laquelle l’IP de l’hyperviseur est portée par un bridge pour la partie IPv4 ([moi j’utilise ça](https://pve.proxmox.com/wiki/Network_Configuration#_masquerading_nat_with_tt_span_class_monospaced_iptables_span_tt)).

Deuxième blague, impossible de faire marcher ça avec un bridge open-vswich ce qui est pourtant vachement plus fun, notamment pour la possibilité d’ajouter des liens GRE entre nodes et ainsi avoir un LAN virtuel unifié dans tout le cluster.

J’ai donc dû REFAIRE tout mon fichier **/etc/network/interfaces**…

## Le réseau, du coup

J’ai suivi sans succès plusieurs tutos (dont [celui-ci](https://www.reddit.com/r/ipv6/comments/fos6f3/ipv6_proxmox_56_block_dhcpv6_vm_and_ct/), [celui-là](https://www.kiloroot.com/proxmox-kimsufi-ovh-soyoustart-ipv6-host-multiple-containers-and-virtual-machines-on-a-single-kimsufi-server-using-ipv6-and-proxmox/) et [celui-là](https://howto.zw3b.fr/linux/reseaux/howto-ipv6-proxmox-online-net)). Le dernier était pourtant particulièrement prometteur puisque utilisant à la fois Online et Proxmox... mais rien n’y a fait. Je me suis coupé la patte un nombre incalculable de fois...

![](/2021/02/oneprovider_liveres.png)

> trolololololo lololo lololooooo<

```
cat /etc/network/interfaces
auto lo
iface lo inet loopback

auto enp0s20
iface enp0s20 inet manual

auto vmbr0
iface vmbr0 inet static
        address VOTRE.IP.V.4/24
        gateway GATEWAY.IP.V.4
        bridge-ports enp0s20
        bridge-stp off
        bridge-fd 0
iface vmbr0 inet6 static
        address VOTRE:IP:V:6::1/64
        #ONLINE.NET specific throttling
        post-up  ip6tables -A OUTPUT -p udp --dport 547 -m limit --limit 10/min --limit-burst 5 -j ACCEPT
        post-up  ip6tables -A OUTPUT -p udp --dport 547 -j DROP

allow-ovs vmbr1
iface vmbr1 inet static
        ... blablabla
        #La partie masquerading sur un Open vSwitch comme indiquée dans https://pve.proxmox.com/wiki/Network_Configuration#_masquerading_nat_with_tt_span_class_monospaced_iptables_span_tt
```


On se retrouve avec un genre de monstre de Frankenstein avec une carte enp0s20 attaché à un bridge (vmbr0) qui sert aussi de bridge pour nos containers IPv6, et d’un bridge (vmbr1) open vswitch pour ce qui reste en v4 et les communications inter-nodes.

> Gavé bien !

Notez les iptables v6 en « post-up » dans la partie v6 du vmbr0.

```
#ONLINE.NET specific throttling
        post-up  ip6tables -A OUTPUT -p udp --dport 547 -m limit --limit 10/min --limit-burst 5 -j ACCEPT
        post-up  ip6tables -A OUTPUT -p udp --dport 547 -j DROP
```


D’expérience, ça ne sert à rien. Mais [c’est conseillé par Online dans son wiki sur IPv6](https://documentation.online.net/en/dedicated-server/network/ipv6/prefix#traffic_limitation_of_your_client). Personnellement je n’ai vu aucun impact positif en ajoutant ces lignes.

## Et ça marche maintenant ?

Ben non, bien sûr. Il va falloir modifier quelques options dans sysctl (notamment le forwarding pour IPv6)

```
vi /etc/sysctl.conf

net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.proxy_ndp = 1
net.ipv6.conf.default.proxy_ndp = 1

```


Sur les recommandations du [wiki d’Online (IPv6 SLAAC)](https://documentation.online.net/en/dedicated-server/network/ipv6/slaac), j’ai rajouté les paramètres suivants :

```
#Online specific (SLAAC)
net.ipv6.conf.vmbr0.autoconf = 0
net.ipv6.conf.vmbr0.accept_ra = 2
```


Pas sûr que ce soit très efficace, j’ai vu d’autres procédures mettre **accept_ra** à 1. Je vous laisse tester les deux.

Mais ça ne suffit pas, parce que quelqu’un (pas trop sûr de qui) a décidé de rajouter des paramètres par défaut qui bloquent l’IPv6 sur ces serveurs. Malin !

J’ai été sauvé par ce [Gist de DonSYS91](https://gist.github.com/DonSYS91/03623c2b8270fd05a76a436c55b95c50) (MERCI !) qui indique une partie des pièces manquantes à mon puzzle.

D’abord dans **/etc/modprobe.d/local.conf**, il y a une ligne ipv6 disable à 1, qu’il faut passer à 0... Si vous ne changez pas cette valeur, **peu importe ce que vous mettrez dans votre sysctl.conf, IPv6 sera systématiquement désactivé au boot !**

```
cat /etc/modprobe.d/local.conf
# Local module settings
# Created by the Debian installer
options ipv6 disable=0
```


Après reboot, tout fonctionne. Je ping bien (avec **ping6**) des serveurs IPv6 only et j’ai pu affecter des IPv6 à mes containers LXC.

## **CA M’A PAS DU TOUT DÉTENDU CETTE HISTOIRE D’IPV6 !**

Et encore, j’ai même pas de DNS IPv6 car OVH ne sait pas le faire sur leurs DNS !

Ni du fait que dans certains cas, 90% des requêtes sont perdues, mais uniquement sur les DC2/DC3 d’Online à Paris, ce que confirment a priori plusieurs personnes qui font aussi de l’IPv6 sur des machines hostées chez Online...

![](/2021/02/statuscake.png)

> And that’s what we call « flapping »

**Mais je m’en fous, le blog est accessible en IPv6.**


![](/2021/02/ipv6-ready-1.png)
