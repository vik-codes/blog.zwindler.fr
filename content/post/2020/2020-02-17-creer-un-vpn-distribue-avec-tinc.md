---
title: Créer un VPN distribué avec Tinc
authors:
  - zwindler
type: post
date: 2020-02-17T07:30:00+00:00
excerpt: Tutoriel pas à pas pour monter un VPN multipoint (full mesh) avec Tinc
url: /2020/02/17/creer-un-vpn-distribue-avec-tinc/
image: /2020/03/airwolf03.jpg
categories:
  - autohebergement
  - Cluster
  - systeme
tags:
  - openvpn
  - Proxmox VE
  - pve
  - tinc
  - Tinc VPN
  - tun
  - VPN

---

## Faire un VPN Tinc fullmesh sans monter un gros réseau IPSec
  
  
Un des gros problèmes que j’ai rapidement eu à régler lorsque j’ai voulu monter des clusters de serveurs Proxmox VE chez des providers de serveurs physiques, c’est la façon dont est gérée le clustering dans PVE.

  
Les concepteurs de PVE ne veulent pas que l’on monte des clusters sur Internet et mettent volontairement le plus de bâtons dans les roues pour vous empêcher de le faire. J’exagère à peine.

  
En version 5.x, PVE se basait sur la version 2 de corosync par multicast (bloqué par tous les providers) et qu’en v6.x, on nous bride en demandant explicitement un sous réseau LAN dédié, autant dire qu’on est pas aidé.

  
## OpenVPN vs Tinc
  
  
Une solution que j’ai expérimenté est de monter un serveur OpenVPN sur un des serveurs et de connecter les autres dessus. J’ai d’ailleurs [fait un tuto là dessus pour PVE](/2017/08/29/faire-un-petit-cluster-proxmox-avec-2-machines-kimsufi/).

  
Cette approche n’est pas optimale : si on a 2 machines, c’est bon, mais si on en a 3 ou plus, on se retrouve soit avec un SPOF, soit à devoir monter un maillage complexe de couples serveur-client. Au delà de 3, c’est pratiquement ingérable.

  
Au contraire, [Tinc](https://www.tinc-vpn.org/) est un logiciel libre (GPLv2) permettant de monter des VPNs multipoints (full mesh routing) entre des machines sur Internet. Tinc est _prévu_ pour notre cas d’usage !

![](/2020/02/tinclogo.png)

> le vrai logo de Tinc (la photo en haut du blog c’est Supercopter, of course)

## On sécurise
  
  
Comme tout service "ouvert" sur Internet, il est évidemment nécessaire de faire du firewalling pour bloquer le trafic malveillant. Pour information, Tinc utilise le port 655 en TCP et UDP, que vous devrez donc ouvrir dans les deux sens entre l’ensemble de vos serveurs, mais bloquer pour le reste d’Internet.

  
A noter, ce n’est pas confirmé mais [la page principale de Tinc](https://tinc-vpn.org/) indique qu’il est possible que ce logiciel (tout comme OpenVPN, Wireguard et IPSec) soit vulnérable à la [CVE-2019-14899](https://seclists.org/oss-sec/2019/q4/122).

  
## On l’installe et on le configure
  
  
On va devoir installer le package/binaire sur toutes les machines du VPN. Pas trop de soucis de ce côté, tinc est [multiplateforme (Windows aussi) et est packagé dans de nombreuses distrib Linux](https://www.tinc-vpn.org/download/). Sur les dépôts Debian, tinc est présent sans souci et j’imagine que ça sera le cas pour d’autres distribs aussi.


```
apt install tinc
```



Une fois installé, on peut créer notre VPN. Pour déclarer un VPN, il faut ajouter le nom de celui ci dans un fichier de configuration global :


```
echo "vpnzwindler" >> /etc/tinc/nets.boot
```



On créé ensuite un répertoire du même nom, contenant lui même un dossier _hosts_.


```
mkdir -p /etc/tinc/vpnzwindler/hosts
```



Dans ces dossiers, on va créer fichier de configuration, /etc/tinc/vpnzwindler/tinc.conf. Ce fichier va nous permettre de décrire le node courant et qui doit se connecter à qui.


```
Name = node01
AddressFamily = ipv4
Address = 1.1.1.1
Device = /dev/net/tun
Mode = switch
ConnectTo = node02
ConnectTo = node03
ConnectTo = node04
[...]
```



Dans les informations importantes, **Name** va être le nom (arbitraire) du node pour tout le VPN, **Address** représente l’adresse IP publique de votre node, et **ConnectTo**, la liste des autres **Names** des autres nodes.

  
A partir de là, on peut demander à tinc de nous générer des couples clé publique/clé privée pour tous nos serveurs. Sur tous les nodes du VPN, lancer :


```
echo -e '\n\n' | tincd -n vpnzwindler -K4096
```



Si tout se passe bien et que tous les fichiers de conf et dossiers ont été créés correctement, _tinc_ devrait créer un couple clé privée/clé publique, puis créer un fichier /etc/tinc/vpnzwindler/hosts/node01 (sur celui dont le Name est node01).

  
Envoyez (par scp par exemple) l’ensemble des fichiers dans le dossier hosts sur tous les serveurs. Maintenant, tous les VPNs sauront quelle IP publique contacter et avec quel clé authentifier le trafic.

## Autre méthode : tinc invite / tinc join
  
  
Une feature sympa de _tinc_, mais seulement en 1.1 (la dernière version), est la possibilité d’ajouter des nodes à un VPN existants via une simple commande tinc invite ([voir la doc](https://www.tinc-vpn.org/documentation-1.1/How-invitations-work.html#How-invitations-work)).

  
Je ne l’ai pas testée mais a priori tinc créé une URL qui permet d’inviter n’importe qui et de configurer son node avec un tinc join.

  
> The whole URL is around 80 characters long and looks like this: server.example.org:12345/cW1NhLHS-1WPFlcFio8ztYHvewTTKYZp8BjEKg3vbMtDz7w4



## Configuration du réseau de l’OS
  
  
Maintenant qu’on a tous les prérequis, on peut configurer l’aspect réseau de notre VPN. Ça dépend de votre distribution bien sûr (où dans le cas de PVE, si vous utilisez OpenVSwitch ou pas par exemple). Dans le cas d’une Debian récente, on va gérer tout ça avec ip.

  
Pour gérer cette partie, Tinc va vous demander de créer 2 scripts. Un tinc-up.sh et un tinc-down.sh, respectivement pour le démarrage et l’extinction de l’interface VPN.


```
cat /etc/tinc/vpnzwindler/tinc-up
#!/bin/bash
/sbin/ip link set vpnzwindler up
/sbin/ip addr add 10.0.0.1/24 dev vpnzwindler
/sbin/ip route add 10.0.0.0/24 dev vpnzwindler

cat /etc/tinc/vpnzwindler/tinc-down
#!/bin/bash
/sbin/ip link set vpnzwindler down

chmod +x tinc-*
```



Rien de bien compliqué ici, on demande au binaire ip de créer une interface vpnzwindler. Puis on lui affecte l’IP virtuelle 10.0.0.1 (notre node01). Enfin d’ajouter une route pour que tout le trafic du VPN passe par cette interface.



## On le démarre
  
  
Dernière étape, on va demander à systemd de nous démarrer le vpn qu’on vient de créer dès le démarrage de la machine.


```
systemctl daemon-reload
systemctl enable tinc@vpnzwindler
systemctl start tinc@vpnzwindler
```


Et voilà !!! Vous avez maintenant un VPN multipoint simple et efficace !

```
root@node01 ~ # ping node02
PING node02 (10.0.0.2) 56(84) bytes of data.
64 bytes from node02 (10.0.0.2): icmp_seq=1 ttl=64 time=17.1 ms
```
