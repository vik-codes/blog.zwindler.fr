---
title: '[En bref] Ajouter une route supplémentaire sur un serveur VMware ESXi'
authors:
  - zwindler
type: post
date: 2015-12-12T11:30:52+00:00
url: /2015/12/12/reminder-ajouter-une-route-supplementaire-sur-un-serveur-vmware-esxi/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - add
  - ESX(i)
  - esxcli
  - route
  - VMware
  - vSphere 4.X
  - vSphere 5.X
  - vSphere 6.X

---
## Présentation du contexte

Dans certains cas où les ESXi sont placés sur plusieurs plans d’adressages différents, il peut être utile de pouvoir spécifier des routes autres que celle par défaut.

Typiquement, j’en ai eu besoin dans le cas de la migration d’un ancien cœur de réseau vers un nouveau (et surtout, dans un nouveau plan d’adressage).

Pour ne pas impacter la production, la gateway par défaut est restée la même. Le serveur ESXi a été connecté sur le nouveau cœur de réseau (encore ... dans le nouveau plan d’adressage), et un nouveau vswitch a été créé sur l’ESXi.

L’ensemble des machines virtuelles ont été connectées au nouveau réseau, facilitant la migration le jour de la bascule.

Cependant, pour que la connectivité soit complète, l’ensemble des requêtes en direction du nouveau réseau devaient bien entendue être routée ... vers le nouveau réseau.

Le [KB de VMware (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20190316182702/https://kb.vmware.com/s/article/2001426) suivant donne toutes les infos nécessaires sur le sujet.

## ESXi 4.x et 5.0

Dans un shell ESXi ou via SSH, exécuter la commande suivante

```
esxcfg-route -a target_network_IP netmask default_gateway
```


Par exemple dans le cas cité plus haut

```
esxcfg-route -a 200.140.0.0/16 200.140.84.2
```


Point d’attention supplémentaire pour ESXi 5.0, les routes ne survivants pas au reboot pour cette version en particulier, il faut ajouter la commande dans le fichier \*\*/etc/rc.local\*\*.

## ESXi 5.1, ESXi 5.5, ESXi 6.0

Dans un shell ESXi ou via SSH, exécuter la commande suivante

```
esxcli network ip route ipv4/ipv6 add --gateway IPv4_address_of_router --network IPv4_address
```


Par exemple dans le cas cité plus haut

```
esxcli network ip route ipv4 add --gateway 200.140.84.2 --network 200.140.0.0/16
```


Pour afficher la table de routage résultante, exécuter la commande

```
esxcfg-route -l
```