---
title: 'OpenSSH : Écouter sur des ports différents en fonction de l’interface'
authors:
  - zwindler
type: post
date: 2018-06-19T11:45:55+00:00
url: /2018/06/19/openssh-ecouter-sur-des-ports-differents-en-fonction-de-linterface/
image: /2018/06/openssh.png
categories:
  - Système
tags:
  - OpenSSH
  - port
  - SSH

---

## Pour quelle raison je pourrais vouloir écouter mon serveur OpenSSH sur des ports différents en fonction de l’interface ?

Tout simplement, pour éviter de se faire spammer par tous les bots et les scripts kiddies qui polluent l’Internet et vos logs de connexion OpenSSH.
  
Idéalement il faudrait n’autoriser la connexion que depuis un réseau local ou un VPN [comme le propose M4vr0x dans ses tutos pour Proxmox VE](/recherche/?keyword=m4vr0x/).
  
Mais dans une certaine mesure, bien que ça ne soit pas une mesure de sécurité, on peut s’économiser beaucoup de « bruit de fond » dans les logs de sécurité en changeant simplement le port d’OpenSSH.
  
L’inconvénient de ce changement, c’est que dans ce cas là, les outils qui reposent sur le port par défaut devront être reconfigurés [voire ne marcheront plus comme le clustering de Proxmox, qui demande explicitement une connexion sur le port 22](/recherche/?keyword=m4vr0x/).
  

## 2 méthodes

Dans les deux cas, la modification est risquée. Rien de dramatique mais une fausse manipulation et vous pourriez vous couper la patte. Comme je n’en suis pas à mon premier utilisateur du blog mécontent, je préfère le redire ;-)

### Méthode 1, configurer OpenSSH

La première méthode, que personnellement je préfère, consiste à configurer OpenSSH pour le faire, car c’est prévu pour !
  
Voici le bout de configuration qu’il faut modifier, dans le fichier <b>ssh_config</b> (souvent situé dans <b>/etc/ssh</b>)

```
# /etc/ssh/sshd_config
Port 7022
ListenAddress 0.0.0.0
ListenAddress [@IP_interne]:22
```


Cette méthode permet de ne pas ouvrir le 22 sur Internet. Seul le 7022 sera accessible et le nombre de connexions par jour sera bien plus limité.

Attention, la prise en compte nécessite un redémarrage. Cependant si vous avez fait une bêtise, il vous reste toujours une chance de vous en sortir => OpenSSH est bien conçu et même un redémarrage ne coupe pas les connexions en cours (comme le ferait Apache ou le redémarrage des cartes réseaux).

Le corollaire de cette information et que, la connexion fonctionnant toujours, vous pourriez penser que tout fonctionne alors que dès que vous fermerez la connexion active, vous ne pourrez plus jamais vous connecter.

Assurez vous donc TOUJOURS de pouvoir ouvrir une nouvelle connexion avant de fermer la précédente (1ère chose que j’ai apprise en SSII).

### Méthode 2, IPtables


OK, c’est obvious, cette méthode ne fonctionne que si vous utilisez IPtables sur votre OS (ahahah).

Toute la puissance d’IPtables est qu’il peut servir à un très grand nombre de choses qui vont au delà du simple firewalling, comme la redirection de trafic avec des pré/post traitement.

Ici, on se contente simplement de rediriger le trafic entrant sur le port 7022 depuis l’interface externe vers le 22 en interne. Ensuite, on indique à OpenSSH de n’écouter QUE sur l’interface réseau locale.

```
# /etc/ssh/sshd_config
Port 22
ListenAddress [@IP_interne_uniquement]
```


On ajoute la règle et (si ça marche !) on la persiste au démarrage d’IPtables :

```
/sbin/iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 7022 -j DNAT --to [@IP_interne_uniquement]:22

iptables-save > /etc/iptables/rules.v4 #Debian/Ubuntu
#ou
iptables-save > /etc/sysconfig/iptables #RHEL/CentOS
```

Cependant, si vous avez un souci sur IPtables ou vos règles pour une raison ou pour une autre, vous ne pourrez plus accéder votre serveur.

Or, connaissant la complexité (et la richesse) d’IPtables, il me parait plus simple de faire une erreur sur IPtables que sur la configuration d’OpenSSH.

Mais c’est à vous de voir ;)

## Sources

  * [Le site de Fatphil [EN]][1]


 [1]: http://fatphil.org/linux/ssh_ports.html
