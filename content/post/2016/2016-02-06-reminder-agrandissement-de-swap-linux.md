---
title: '[En bref] Agrandissement de swap sous Linux'
authors:
  - zwindler
type: post
date: 2016-02-06T11:30:44+00:00
url: /2016/02/06/reminder-agrandissement-de-swap-linux/
image: /2016/02/RedHatLogo.png
categories:
  - Système
tags:
  - Free
  - Linux
  - mémoire
  - RAM
  - RHEL
  - swap
  - swapoff
  - swapon

---
## Agrandir la swap, pourquoi faire ?

Avec la montée en puissance de l’extension à chaud de RAM sur les machines virtuelles et l’explosion des tailles de JVM délirantes (20 Go pour un outil de gestion de projet pour 100 personnes. Allo...) il est de plus en plus simple de se dire :

> Tiens, le vent souffle aujourd’hui, j’vais rajouter un peu de RAM à mes VMs.

Sauf qu’il arrive d’oublier les bonnes pratiques en vigueur dans votre propre contexte professionnel : 1 fois la RAM, 1,5 fois la RAM, 2 fois la RAM, 0,5 fois la RAM si on a plus de 8Go, 2Go quoiqu’il arrive (rayez les mentions inutiles).

Ça et les templates, pour qui on ne différencie pas toujours les gros des petits serveurs, par flemme.

Du coup, je me retrouve régulièrement à nettoyer des serveurs pour qui on a oublié d’agrandir la RAM après une extension. Et du coup, j’aime bien avoir sous la main la procédure pour le faire rapidement.

## Les commandes pour le faire sous Linux (RHEL 6 en l’occurrence)

Afficher des informations sur la swap

```
swapon -s
```


Récupérer/retrouver le device qui porte la swap dans la fstab

```
grep swap /etc/fstab 
     /dev/VolGroup00/LogVol01   swap   swap   defaults   0 0
```


Vérifier que la swap n’est pas utilisée, ou à défaut, **que toutes les pages swapées peuvent être stockées en mémoire** sinon ...!

```
free -m
```


Désactivation de la swap

```
swapoff -a
```


Agrandir le LV (si on a fait du LVM, sinon il faut agrandir ou créer une nouvelle partition ce qui peut être un peu plus casse pied) puis recréer le volume de swap à la nouvelle taille :

```
lvextend -L +4G /dev/VolGroup00/LogVol01
mkswap /dev/VolGroup00/LogVol01
```


Réactiver la swap

```
swapon -a
```


Vérifier la prise en compte

```
swapon -s
cat /proc/swaps #affiche la même chose mais j'aime bien
```


## Bonus : techniques barbares pour faire le ménage

Je me rend le plus souvent compte que les serveurs n’ont pas les bonnes tailles de swap lorsque j’ai une alerte dans ma supervision.

### Cycle en V : recherche des coupables

Souvent, les gros systèmes taillés au plus juste swappent un peu, quelques centaines de Mo de temps en temps, lorsqu’un gros traitement se déclenche et qu’on dépasse la quantité de mémoire totale prévue. Mais parfois cela peut assi être un processus qui perd la boule et qui se met à consommer un max de mémoire (avec la réduction drastique des performances qui vont avec en cas de swap).

Pour déterminer quel processus consomme le plus de swap sous Linux, on peut utiliser les commandes suivantes :

```
free -m  
------total        used        free        shared        buffers        cached  
Mem:           3948      3186         761                 0                 17             1593  
-/+ buffers/cache:      1575      2372  
Swap:           4000              0      4000
```

  * 3948 la quantité totale de RAM du système
  * 3186 et 761 représentent respectivement les quantités de RAM utilisée et disponible, sans tenir compte de ce qui est utilisable en cache/buffer
  * 2372 représente la quantité réelle de mémoire disponible (soit pas du tout utilisée, soit dans un cache qui pourra être libéré si nécessaire)
  * 1575 représente la quantité réellement utilisée par les processus

Si votre système est récent (procps-ng) l’affichage sera un peu différent car les buffers et le cache ont été regroupés dans une même colonne, sur la même ligne que la mémoire. Et c’est tant mieux car c’est plus clair comme ça, je trouve :

```
free -m  
------total        used        free      shared  buff/cache   available  
Mem:               993         353       329              37              309           447
Swap:            2079             0       2079
```

  * 993 la quantité totale de RAM du système
  * 353 représente la quantité réellement utilisée par les processus
  * 329 représente la quantité de mémoire pas du tout utilisée (ni par des processus, ni par des caches)
  * 447 représente une estimation de la quantité réelle de mémoire disponible pour d’autres processus avant que le système ne se mette à swaper (soit pas du tout utilisée, soit dans un cache qui pourra être libéré si nécessaire)

Dans certaines versions de top, il est possible d’obtenir un tri par processus de l’utilisation de la swap, notamment avec RHEL/CentOS, jusqu’à version 6 qui utilise **procps** :

```
top
 O #o majuscule
 p #p minucule
 [touche entrée]
```


La commande top devrait alors lister les processus en fonction de leur utilisation de SWAP

```
PID USER      PR  VIRT  NI  SHR SWAP S %CPU %MEM    TIME+   RES COMMAND
  4390 root      18 2449m   0 2276 2.0g S    0  9.3 185:11.98 367m mrmonitord
  4316 root      34 1566m  19 1976 1.1g S    0 10.7   4:15.62 423m yum-updatesd
  4385 root      18 1141m   0 1476 1.1g S    0  0.6 423:19.03  23m java
 22009 apache    15  385m   0 4708 360m S    0  0.6   0:20.40  25m httpd
```


Cependant, cet affichage n’est pas totalement exact et c’est pour cela que cette fonction n’existe pas toujours dans top. C’est notamment vrai pour les dernières versions de Debian/Ubuntu et de RHEL 7 qui utilisent procps**-ng**.  
Personnellement je trouve que ça donne un bon aperçu des processus qui sont en train de swapper en cas de recherche d’un coupable. Si vous voulez plus d’information là dessus, je vous conseille de lire la partie « A note about top command » de [cet article][1].

### Faire un peu de ménage

Certains d’entre vous trouveront peut être plus simple de le relancer (quand cela est possible). Ceci pourrait rendre de la mémoire au serveur qui se mettra à arrêter de swapper. Pour autant, la mémoire swappée ne sera pas forcément rendue, et l’alerte en supervision restera présente même si l’incident est terminé...

Du coup, voici quelques tips supplémentaires pour faire du ménage dans les caches pour libérer la mémoire réservée mais pas forcément nécessaire :

  * Libération du pagecache

```
echo 1 > /proc/sys/vm/drop_caches
```


  * Libération des dentries et des inodes

```
echo 2 > /proc/sys/vm/drop_caches
```


  * Tout libérer d’un coup

```
echo 3 > /proc/sys/vm/drop_caches
```


### Tout péter

Si vous vous sentez d’humeur guerrière et que vous pensez que tout ce qui est dans la swap peut re-rentrer en RAM, vous pouvez toujours désactiver la swap. Ceci aura pour effet de vider complètement la swap et donc de tout rappatrier en RAM. Il va sans dire que si vous vous êtes trompé, le système se bloquera et vous pourrez appuyer longuement sur le bouton « Power ».

```
swapoff -a #extinction de la swap 
swapon -a #relance de la swap
```


Vous voilà prévenus ;)

 [1]: https://www.cyberciti.biz/faq/linux-which-process-is-using-swap/
