---
title: Configurer le Thomson 789vn en VDSL2 sur ligne Free dégroupée
authors:
  - zwindler
type: post
date: 2013-11-17T15:20:04+00:00
url: /2013/11/17/configurer-le-thomson-789vn-en-vdsl2-sur-ligne-free-degroupee/
image: /2014/09/Download-195m.png
categories:
  - Matériel
tags:
  - 789vn
  - ADSL2+
  - dégroupage
  - DIY
  - Free
  - Freebox V5
  - Freebox V6
  - NRA
  - Thomson
  - VDLS2

---

Imaginons.

Imaginons que vous avez entendu parlé du VDSL2, que vous êtes sur un NRA compatible et que vous avez envie de voir ce que donnerai votre ligne si vous passiez sur le modem compatible de votre opérateur (Free pour moi) sans pour autant sauter le pas.

Imaginons que vous ayez à votre disposition un superbe Thomson 789vn, modem compatible ADSL2+ et VDSL2 (tiens, le même que ceux que fournit OVH ! Mais c’est un pur hasard). Vous allez vite vous rendre compte qu’on est parti pour une bonne partie de rigolade...

[Spoiler Alert] Si comme moi vous êtes encore sur la V5 et que vous voulez voir ce que donne le VDSL2... **dommage ce n’est pas possible...** 
Seules les lignes disposant d’un abonnement Révolution peuvent bénéficier du VDSL2. Du pur marketing...

Cependant, j’imagine que cela doit fonctionner pour ceux qui ont une V6 en panne ou qui veulent un routeur en frontal (Si si ça existe) [/Spoiler Alert]

Free (ce n’est pas le cas de tous les opérateurs), vous autorise à utiliser un autre modem que la Freebox. C’est particulièrement utile en cas de panne de Freebox, justement, mais pas que. Les informations de connexion sont [disponibles ici](http://www.free.fr/assistance/2252.html)

Je l’avais appliqué sur un modem `Belkin surf n300`, cela fonctionnait très bien. Cependant, en me connectant à l’interface, j’ai vite compris que ça allait être galère. Pourquoi? **Tout simplement parce qu’on ne PEUT PAS ajouter une IP fixe dans la configuration « Bridged/routed IP over ATM » depuis le wizard**.

La solution : exporter la configuration du modem, modifier le fichier.ini récupéré, et la réinjecter. J’ai pu m’en sortir à l’aide d’un article pour un autre modem, le SpeedTouch 716v5 W qui m’a servi de base et que j’ai adapté à mon cas. [Merci aux auteurs donc, sans quoi je n’y serai peut-être pas arrivé (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20160807230846/http://www.tranquille-informatique.fr/informatique/modems-et-routeurs/speedtouch/speedtouch-716v5-wl-sur-ligne-free-degroupee.html).

Étape 1 : se connecter à l’interface web du 789vn, lancer le wizard pour obtenir une configuration la plus proche possible des spécification de Free

```
Bridged/routed IP over ATM
VC MUX (VPI/VCI) : 8/36
```

Étape 2 : trouver la page de sauvegarde/restauration de la configuration. Vous pouvez télécharger le fichier user.ini qui va nous servir de base de travail. L’idéal est quand même d’en garder une copie, au cas où on casserait tout ;-)

Étape 3 : Éditer le fichier. Ce qu’il faut savoir, c’est que dans le modem, il y a plusieurs interfaces que nous allons devoir configurer dans plusieurs bloc de configuration, en fonction de vos informations personnelles :

* pvc_Internet
* atm_Internet
* RtIPoA_ip
* LocalNetwork

Les blocs intéressants sont les suivants :

* XDSL.INI : Voici un bloc en plus par rapport à l’article de Tranquille. Ici, on voit bien que le modem cherche s’il peut faire du VDSL2 ou pas. A priori pas de modifs à faire ici

```
[ xdsl.ini ]
debug traceconfig level=0
config adslmultimode=adsl2plus vdslmultimode=vdsl2 detect-lop=enabled syslog=disabled
```

* ATM.INI : Ici c’est la configuration de atm\_internet, dont la destination est pvc\_internet et qui discute via VCMUX vers pvc_Internet. Pas de modifs là non plus, si on l’a définit correctement dans le wizard

```
[ atm.ini ]
ifadd intf=atm_Internet
ifconfig intf=atm_Internet dest=pvc_Internet encaps=vcmux
ifattach intf=atm_Internet
```

* PPP.INI : It’s a trap ! Si vous avez bien lu l’étape 1, on fait du Bridged/routed IP over ATM car on est en zone dégroupée, pas de PPP. Cette section est donc vide ;-)

```
[ ppp.ini ]
```

* IP.INI : Là c’est autrement plus compliqué. Ici, on va définir les adresses IP de chaque interfaces. C’est là le point important de la configuration, puisque c’est cette partie qu’on ne pouvait pas configurer dans l’interface web. On remarque le réseau local en 192.168.1.0 (qu’on peut changer si on veut) et la définition de la sortie vers Internet RtIPoA\_ip => atm\_Internet

```
[ ip.ini ]
ifadd intf=RtIPoA_ip dest=atm_Internet
ifadd intf=LocalNetwork dest=bridge
ifconfig intf=RtIPoA_ip mtu=1500 group=wan linksensing=enabled
ifconfig intf=loop mtu=4096 linksensing=disabled group=local symmetric=enabled curhoplimit=64 dadtransmits=0 retranstimer=1000 acceptra=disabled autoconf=disabled
ifconfig intf=LocalNetwork mtu=1500 linksensing=disabled group=lan acceptredir=disabled rpfilter=enabled ipv4=enabled primary=enabled ipv6=enabled curhoplimit=64 dadtransmits=1 retranstimer=1000 basereachabletime=30000 gctimer=600000 acceptra=disabled autoconf=disabled
ifattach intf=RtIPoA_ip
ifattach intf=LocalNetwork
config forwarding=enabled redirects=enabled netbroadcasts=disabled randomdatagramids=disabled ttl=64 fraglimit=64 defragmode=enabled addrcheck=dynamic mssclamping=enabled
config checkoptions=enabled
config natloopback=enabled
config arpclass=12
config arpcachetimeout=900
ipadd intf=LocalNetwork addr=192.168.1.254/24 addroute=enabled
ipadd intf=RtIPoA_ip addr=[[[votre_@IP]]]/32 pointopoint=255.255.255.0 addroute=enabled
ipconfig addr=192.168.1.254 preferred=enabled primary=enabled
ipconfig addr=[[[votre_@IP]]] preferred=enabled
rtadd dst=255.255.255.255/32 gateway=127.0.0.1
rtadd dst=0.0.0.0/0 gateway=[[[votre_@gateway]]] intf=RtIPoA_ip
```

* DNSS.INI : Fichier permettant de configurer les DNS Free (212.27.40.240 et 241)

```
[ dnss.ini ]
config domain=lan timeout=15 suppress=0 state=enabled trace=disabled syslog=disabled WANDownSpoofing=disabled WDSpoofedIP=198.18.1.0 filter=enabled
host add name=dsldevice addr=0.0.0.0 ttl=1200
route add dns=212.27.40.241 src=0.0.0.0/0 domain='' metric=0
route add dns=212.27.40.240 src=0.0.0.0/0 domain='' metric=0
```

* NAT.INI : Définition des règles de NATage. « Véri véri importante »

```
[ nat.ini ]
ifconfig intf=RtIPoA_ip translation=enabled
mapadd intf=RtIPoA_ip outside_addr=[[[votre_@IP]]] weight=10
ifconfig intf=LocalNetwork translation=transparent
config
```

Étape 4 : Le réinjecter dans notre routeur la config modifiée. 2 possibilités :

- soit vous avez bien tout configuré et vous devriez avoir accès à Internet, à minima en ADSL2+

![](/2013/11/atm.png)

> Visiblement, on est en ADSL2+, pas en VDSL2...

- soit vous vous êtes trompés dans les noms d’interfaces et vous ne pouvez peut être même plus vous reconnecter au routeur. Si si, je le sais, je me suis moi même trompé, notamment car les noms d’interface peuvent différer d’un appareil à l’autre et que je me suis un peu trop appuyé sur la configuration du speedtouch de Tranquille ;-).

Dans ce cas, pas de panique, il y a un bouton _reset_ sur le côté. Appuyer avec une mine de crayon jusqu’à ce que les leds passent de vert à rouge (environ 10 secondes) et la configuration par défaut sera rétabli. Vous n’aurez plus qu’à corriger votre erreur et réinjecter à nouveau la configuration modifiée.

Have fun!
