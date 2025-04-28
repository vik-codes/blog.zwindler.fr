---
title: '[En bref] Désactiver IPv6 sur les Windows Server'
authors:
  - zwindler
type: post
date: 2015-11-14T11:30:12+00:00
url: /2015/11/14/reminder-desactiver-ipv6-sur-les-windows-server/
image: /2015/11/wikipedia_slash8.png
categories:
  - Système
tags:
  - configuration
  - désactiver
  - IPv4
  - IPv6
  - Microsoft
  - One Click
  - regedit
  - Support

---
IPv6, c’est un standard qui devrait être correctement supporté aujourd’hui, et par tout le monde. On devrait même aller jusqu’à dire qu’on devrait [arrêter d’utiliser IPv4 aujourd’hui][1].

Mais franchement, il faut le reconnaitre, attribuer des adresses sur 128 bits (donc 32 caractères héxa), c’est une vraie tannée pour les administrateurs systèmes (même si il y a des astuces pour réduire la taille des adresses) !

Alors c’est vrai, c’est mal (car non pérenne), mais certains sont donc tentés de ne pas utiliser IPv6, voire même désactiver complément la fonctionnalité. **_[Edit] Ça peut surtout bloquer certains composants et/ou provoquer des effets de bords difficilement décelables... Autant vous le dire tout de suite, Microsoft n’approuve pas.[/Edit]_**

## Le cas Windows Server

Même si vous n’utiliser pas IPv6, les serveurs ont souvent sur leur carte le double adressage. Ce n’est pas gênant tant que vous ne l’utilisez pas ... sauf pour les Windows Server en domaine Active Directory.

Pour simplifier l’administration des DNS, les serveurs Windows dans un domaine sont automatiquement enregistrés dans le DNS fournit par les serveurs DC. Même les adresses IPv6. et des fois, ça provoque des effets de bord quand l’IPv6 répond en premier.

## Comme le  désactiver ?

On peut donc honteusement vouloir désactiver IPv6, pour se simplifier la vie et éviter de polluer son DNS Active Directory. Mais ... décocher la case dans l’interface d’administration des connexions réseau ... ne sert à rien !

La seule façon de le faire, c’est de modifier le registre avec regedit (en tant qu’administrateur bien entendu).

Naviguer dans HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\services\TCPIP6\Parameters

Avec un [clic droit], ajouter une nouvelle clé **DisabledComponents** en type **DWORD (32-bit)** et lui donner la valeur ~~0xFFFFFFFF (voir commentaires)~~ 0xFF.

[MAJ du 25/01]Ou alors vous pouvez créer un fichier « .reg » à exécuter sur la machine :

```
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters]
"DisabledComponents"=dword:000000ff
```


[/MAJ]

Au reboot, IPv6 sera totalement désactivé sur le serveur.

## Aller plus loin

Si vous ne voulez pas le faire à la mimine, que vous avez un accès simple vers Internet et que vous n’avez pas peur de faire confiance aveuglément à Microsoft, le [KB de Microsoft sur le sujet][2] donne des boutons de paramétrages « one click » pour désactiver ou réactiver simplement IPv4 et/ou IPv6.

 [1]: https://fr.wikipedia.org/wiki/%C3%89puisement_des_adresses_IPv4
 [2]: https://support.microsoft.com/fr-fr/kb/929852
