---
title: 'Changer le clavier par défaut : qwerty (de l’appliance vCenter vCSA 5.X)'
authors:
  - zwindler
type: post
date: 2015-04-08T15:07:24+00:00
url: /2015/04/08/changer-le-clavier-qwerty-par-defaut-de-lappliance-vcenter-vcsa-de-5-0-a-5-5/
image: /2015/07/vCSA.jpg
categories:
  - Logiciel
  - Système
  - Virtualisation
tags:
  - azerty
  - fr-latin9
  - keytable
  - layout
  - qwerty
  - vCenter
  - vCenter Appliance
  - vma
  - vMA 4
  - vMA 5.0
  - vma 5.1
  - vMA 5.5

---
Depuis vSphere 5.0, il est possible d’installer un vCenter sur une appliance virtuelle Linux et ainsi s’affranchir du cout d’une licence Windows, parfois utilisé exclusivement pour ce besoin.

Ça vous oblige à trancher par défaut la question du vCenter physique ou virtuel (voir </2010/06/01/vcenter-ou-quand-comment/>) et à vous accommoder de certaines limitations assez agaçantes (pas compatible avec les modules vCenter tiers + vSphere Update Manager doit quand même être installé sur Windows ? « Allo quoi! » comme dirait l’autre), mais s’affranchir de Windows, ça n’a pas de prix ;-)

Plus sérieusement, la vCSA (vCenter Server Appliance) a pas mal évolué depuis la version 5.0 pour arriver jusqu’à une 5.5 en Suse Entreprise Linux Server (1 licence SLES incluse avec votre licence vCenter !!! Youhou!), mais tout n’est pas encore parfait.

Un des **gros problèmes** est que, encore aujourd’hui, la console sur le vCenter est en **qwerty**.

AAAAAAAAAH !

Si vous avez une IP à changer ou un fichier de conf à modifier (par exemple  </2013/05/07/reduire-la-ram-consommee-par-la-vmware-vcenter-appliance-5-1/>), vous allez devoir connaitre votre correspondance azerty/qwerty par cœur.

C’est un bon exercice cela dit, mais je suis sympa, je vais vous donner un coup de main ;-)



Pour changer le layout par défaut, le fichier à modifier est le suivant

```
vi /etc/sysconfig/keyboard
```


Dans ce fichier, la variable à modifier est la variable KEYTABLE. Cette variable doit avoir pour valeur le nom d’un fichier de layout avec le suffixe .**kmap.gz** et présents sur la machine à l'emplacement suivant :

  * vMA4 : _/usr/lib/kbd/keymaps/i386_
  * vMA5 : _/usr/share/kbd/keymaps/i386_

Pour faire simple, dans notre cas nous les Français/Azerty, il faut remplacer la partie **us** de cette variable (_KEYTABLE=us.map.gz_) par **fr-latin9**. Donc sur un clavier azerty, il faut taper les caractères **fr)lqtinç**

Rappels pour ceux qui n’aiment pas « vi », pour enregistrer il faut taper :wq hors du mode édition, et donc **Mza** sur votre azerty ;-)

Il ne reste plus qu’à sortir de la session courante avec exit, et se reloguer pour que la modification soit prise en compte.

Et voilà!

Pour aller plus loin, la source : [ici (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20120825025014/http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1007551)
