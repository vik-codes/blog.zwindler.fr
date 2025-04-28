---
title: Problème de pointeur souris sur la console dans OracleVM 3.4
authors:
  - zwindler
type: post
date: 2017-02-09T13:00:44+00:00
url: /2017/02/09/probleme-de-pointeur-souris-sur-la-console-dans-oraclevm-3-4/
image: /2017/02/SimpleMouse.gif
categories:
  - Système
  - Virtualisation
tags:
  - décalage
  - mouse
  - Oracle VM
  - Oracle VM for x86
  - pointer
  - Redhat
  - RedHat 7
  - souris
  - Windows
  - Windows 2003
  - Windows 2008
  - Windows 2012

---
## OracleVM, quelques faiblesses sur la console, comme les autres...

Dans la série des articles sur OracleVM avant que je n’en reparle plus (le PoC est ~~terminé~~ enterré chez nous), voici un petit retour sur un des problèmes que j’ai pu rencontrer.

Comme beaucoup de technologies de visualisation d’écrans consoles pas totalement maîtrisées (ça vaut pour les vieux ILO en Java ou autres : que de bons souvenirs), le pointeur de la souris fait littéralement n’importe quoi. Généralement c’est décalé mais pas de manière linéaire sur tout l’écran pour bien qu’on se marre.

![](/2017/02/SimpleMouse.gif)

> Crédits : GameDev.net

Le problème vient du client web VNC proposé par Oracle VM Manager et est un problème archi-connu mais pour autant pas totalement résolu.

## Accéder directement au flux VNC

Comme je l’explique juste avant, il arrive couramment que les technologies de virtualisations intégrées vers l’écran (virtuel) de la machine virtuelle soient mal calibrées. Mais c’est encore plus courant lorsque ce déport d’écran est réalisé avec un connexion VNC elle même affichée dans une console HTTP.

Un moyen de contourner le problème de ce type de clients VNC web (et ça vaut pour d’autres outils qui utilisent les mêmes techniques) est de simplement se « brancher » sur le flux VNC sans passer par la console web. A priori sur les versions précédentes de OVMM, il était possible de se brancher directement sur le flux VNC, tout simplement parce que le serveur VNC était en écoute sur l’interface LAN.

Au delà du fait que ce soit du bidouillage, cette technique n’est aujourd’hui plus permise depuis OVMM 3 et il faut donc ... bidouiller encore plus ! Voici ce que propose le support d’Oracle :

> You can redirect the remote port to local using the ssh(1) command. For example, the VM guest vnc port is 5900 on Oracle VM Server and listening on localhost:
> 
> \# xm list -l 2|grep 59  
> (location 127.0.0.1:5900)
> 
> Then you can run this to redirect the port to your desktop:
> 
> $ ssh -L 12345:localhost:5900 root@OVS
> 
> The « 5900 » port will be redirected to « 12345 » of your local desktop, so that you can run the following command to connect the guest console:
> 
> $ vncviewer localhost:12345

En gros, ce qu’il faut en comprendre, c’est que le serveur VNC n’est maintenant plus disponible depuis autre part que localhost et qu’on peut contourner la limitation en faisant un tunnel SSH. Rien de bien sorcier, mais est ce qu’il n’y a pas un peu plus simple ?

## La vraie solution

En fait si.

Au début, je n’ai même pas cherché à appliquer cette solution car elle ne s’applique normalement que pour les machines virtuelles Windows.

Si vous avez un problème du type de celui que je décris sur une VM Windows, on vous conseille chez Oracle d’ajouter un paramètre à la machine virtuelle qui permet de mieux suivre les mouvements de la souris.

> Add below your config to force the device model to use absolute (tablet) coordinates:
> 
> usbdevice=’tablet’

Mais sur le papier, la solution est bien indiquée « For Windows virtual machines (guests) ». Mon problème moi, c’était sur les machines virtuelles CentOS, indiquées comme pas impactées par ce genre de problèmes.

## Bon j’ai bien compris ou tu veux en venir. Comment on modifie ce paramètre ?

En fait, c’est TRES mal indiqué dans la documentation. Il s’agit de la configuration de la machine virtuelle, **VM éteinte**, mais où faire la modification ? Ahah ! Mystère !

La documentation fait elle état d’un fichier de configuration de la machine virtuelle mais je n’ai pas su trouver ce fichier. Cependant, et **ce n’était pas dit dans la documentation** on peut modifier ce paramètre directement depuis la GUI de Oracle VM Manager !

Dans les paramètres de la machine virtuelle, dans l’onglet Configuration, on trouve le paramètre **Mouse Device Type**. Sur les machines Windows, comme le problème est connu, il me semble d’ailleurs que le paramètre est passé à « tablet » par défaut.

![](/2016/10/oraclevm45.png)

Une fois validé, on peut vérifier que cette configuration a effectivement été modifiée en affichant ce fameux **VM Config File** que je ne sais pas où trouver :

![](/2016/10/oraclevm46.png)

![](/2016/10/oraclevm47.png)

A partir de là, la souris ne devrait plus vous faire de blagues. Même si avec Oracle VM, on ne sait jamais trop ;-) #Troll

## Source

  * [How To Access Guest Console In OVM 3 Using VNC Without Using OVM Manager](https://support.oracle.com/rs?type=doc&id=1548825.1)
  * [Mouse Pointer Fails to Track Cursor on a VNC / Oracle VM Manager Window](https://support.oracle.com/rs?type=doc&id=466379.1)
