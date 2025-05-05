---
title: 'Plus d’accès à mes disques iSCSI après un reboot de mon serveur Windows 2012 (iscsicli)'
authors:
  - zwindler
type: post
date: 2016-05-12T12:00:40+00:00
url: /2016/05/12/reboot-sur-un-serveur-windows-2012-plus-avoir-acces-a-mes-disques-iscsi/
image: /2016/02/57UKydQS.png
categories:
  - Stockage
  - systeme
tags:
  - Cible
  - Initiateur
  - iSCSI
  - iscsicli
  - Windows 2012

---
Dans cet article je vais vous parler d’un petit utilitaire sympa quand vous utilisez des disques iSCSI sous Windows : iscsicli.exe.

Je plante le décors : après un reboot sur un serveur Windows 2012 (suite à une mise à jour forcée que je n’ai pas pu annuler, voir mon [article de la semaine dernière](/2016/05/05/windows-2012-reboot-force-des-serveurs-sans-que-vous-ne-puissiez-rien-ny-faire/
)) ayant accès à des LUNs iSCSI, je me suis retrouvé avec des disques iSCSI qui ne voulaient plus se reconnecter.

Ayant l’habitude des disques qui ne remontent pas automatiquement au reboot (malgré la présence des disques dans les _cibles préférés_, l’option normalement faite pour), je suis aller les reconnecter à la main avec l’utilitaire **Initiateur iSCSI** de Microsoft.

Sauf que les disques étaient bloqués sur « Reconnexion... ».

## Le cas simple/standard

Si vous tombez sur ce problème (comme [cet utilisateur de serverfault](http://serverfault.com/questions/737093/iscsi-target-stuck-reconnecting-after-server-reboots) pour ne citer que lui), dans la plupart des cas, il s’agit simplement d’une mauvaise coupure de la connexion iSCSI lors de la coupure du serveur.

Les ID de connexions des sessions iSCSI ne sont plus valides et le système n’arrive pas à s’en sortir seul. Dans la plupart des cas donc, une simple déconnexion/reconnexion des sessions devraient suffire.

![](/2016/01/iscsi_windows.png)

## Non ce n’est pas ça :-(

Cependant dans mon cas, rien n’y faisait. Impossible de connecter la session, Windows me renvoyait un message d’erreur.

Pas mieux pour la déconnexion, l’utilitaire m’informe avec un laconique :

```
Id de session incorrecte.
```


Et bien figurez vous qu’une fois de plus, on ne peut pas faire confiance aux interfaces graphiques !

Dans le doute, j’ai voulu essayer de voir si je pouvais faire mieux en ligne de commande, ce qui m’a permis de découvrir **iscsicli.exe**, l’utilitaire Windows à tout faire lorsqu’il s’agit d’iSCSI. Voici quelques commandes bien utiles lorsqu’on veut dépatouiller des problèmes iSCSI :

```
iscsicli ListTargets #liste les cibles (serveur dans la terminologie iSCSI) enregistrées sur le serveur Windows initiateur (client dans la terminologie iSCSI)
iscsicli SessionList #liste les sessions ouvertes par l'initiateur Windows
iscsicli ListPersistentTargets #liste les cibles qui doivent normalement se reconnecter après reboot de l'initiateur Windows
iscsicli QLoginTarget [ID de session] #Connecter une session vers une cible pré-enregistrée
iscsicli LogoutTarget [ID de session] #Déconnecter une session via son ID
```


Dans mon cas, le **iscsicli SessionList** me donnait 4 sessions

```
PS C:\Users\admin> iscsicli SessionList
Initiateur iSCSI Microsoft version 6.3 numéro 9600

Total de 4 sessions

ID de session : ffffe11113210020-4000011110000001
Nom de nœud de l'initiateur : iqn.1991-05.com.microsoft:aaa.aaa.aaa
Nom de nœud de la cible : (null)
Nom de la cible : aaa.aaa.aaa:bbb:432:ds-aaa-aaa
ISID : 40 00 01 37 00 01
TSID : 00 00
Nombre de connexions : 0
[...]
L’opération a réussi.
```


Normalement, on devrait pouvoir se déconnecter de la cible avec la commande suivante :

```
PS C:\Users\zwindler> iscsicli.exe LogoutTarget ffffe11113210020-4000011110000001
Initiateur iSCSI Microsoft version 6.3 numéro 9600

Id de session incorrecte.
```


La session répondant côté Windows au doux nom de ffffe11113210020-4000011110000001 n’existe tout simplement pas côté serveur (target/cible iSCSI).

La seule solution que j’ai trouvé a été de dés-assigner de l’ensemble des disques iSCSI le serveur Windows, redémarrer le démon iSCSI sur ce dernier (c’est le service **Initiateur iSCSI** dans le **Gestionnaire de services**/**services.msc**).  
Après un peu de temps, le démon a fini par réussir à redémarrer et les connexions fantômes n’étaient plus visibles. J’ai pu réassigner correctement les disques iSCSI, actualiser côté Windows et reconnecter les cibles.

Et ben purée...

