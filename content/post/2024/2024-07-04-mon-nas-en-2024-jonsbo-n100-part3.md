---
title: 'Mon NAS en 2024 - Jonsbo N2 × Intel N100 - stress tests et conclusion'
authors:
  - zwindler
type: post
date: 2024-07-04T12:00:00+02:00
url: /2024/07/04/mon-nas-en-2024-jonsbo-n100-part3/
image: /2024/07/cpu-stress-2.jpeg
categories:
  - Autohébergement
  - Matériel
tags:
  - Jonsbo N2
  - OpenMediaVault
  - OMV
  - TrueNAS
  - TrueNAS SCALE
  - TrueNAS Core
  - FreeNAS
  - FreeBSD
  - ZFS
  - zpool

---

Cet article fait partie d’une série dans laquelle je parle de mon nouveau NAS que j’ai construit moi-même :

* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - hardware](/2024/05/03/mon-nas-en-2024-jonsbo-n100-part1/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - software](/2024/05/19/mon-nas-en-2024-jonsbo-n100-part2/)
* [Mon NAS en 2024 - Jonsbo N2 × Intel N100 - stress tests et conclusion](/2024/07/04/mon-nas-en-2024-jonsbo-n100-part3/)
* [Bonus - Installer plex sur TrueNAS (SCALE)](/2024/05/10/installer-plex-sur-truenas-scale/)

## On le teste, ce NAS ?

Après 1 mois et demi de confs et aussi de préparation de ma fin d'emploi (lien mort, je ne suis plus sur Twitter), je reprends ma plume numérique pour finir le dernier article de cette série, que certain⋅es attendent avec impatience (à minima, un australien :-P)

On s'était arrêté dans l'article précédent à l'installation de notre NAS sous TrueNAS SCALE (la version Linux) et nous nous étions juste logué sur l'interface d'administration.

![](/2024/05/truenas_installed.jpeg)

La première opération que vous voudrez faire, c'est très certainement de créer un pool de disques et un volume.

Dans mon cas, après avoir testé un premier pool avec 4 disques que j'avais en spare, ZFS m'a très rapidement prévenu que quelque chose n'allait pas avec mes disques. Après un SMART approfondi, je me suis retrouvé avec 2 disques HS... J'en ai acheté un de plus et créé un pool avec "seulement" 3 disques (au lieu des 4 prévus initialement).

![](/2024/07/rpool.png)

Une fois le pool créé, on peut commencer à créer des volumes et à ajouter différents types de partages. J'ai créé un share NFS à part, car il me servira pour la virtualisation et mon homelab, et un share CIFS pour tout ce qui est partage de fichiers.

![](/2024/07/tank.png)

## Température

Le premier test que j'ai voulu faire, avant de commencer quoique ce soit, c'était un test de température.

Un des problèmes que j'avais avec les NAS maison, c'est que les CPUs grand public (hors Atom) sont souvent surdimensionnés pour les besoins d'un NAS. On se retrouve avec un CPU soit bruyant, soit un ventirad volumineux. Ou alors dans le cas de l'Atom, un CPU totalement bridé par le throttling et les perfs déjà pas terribles, comme mon tout premier NAS maison de 2011 (voir [NAS/MediaCenter : Do It (the hardware part) Yourself!](/2011/06/29/nasmediacenter-do-it-yourself-or-not/)).

Ce qui m'a fait craquer pour le Intel N100 c'est que, sur le papier, il a la consommation et la dissipation thermique d'un Atom mais les fonctionnalités d'un CPU classique, tout en gardant des perfs acceptables. Et on a le support de la virtualisation, 4 cores, etc.

Un des points noirs d'une des cartes mères "siglée NAS" sur Aliexpress, significativement moins chère que celle que j'ai achetée, mais dont les retours étaient unanimes pour dire que le ventilateur était clairement audible (et très aigu). Le NAS étant à côté de mon bureau (où je télétravaille) c'était évidemment hors de question.

![](/2024/07/bruit.png)

Pour rappel, j'avais opté pour un ventirad jonsbo low profile, qui s'avère à l'usage plutôt silencieux, d'autant que je lui ai rajouté un réducteur de vitesse (en gros un fil avec une résistance) que j'avais en stock d'un build précédent.

![](/2024/05/montage-fini.jpg)

## VM de stress test pour faire chauffer tout ça

La philosophie de TrueNAS c'est de t'empêcher de faire des trucs dans ton coin histoire de limiter les erreurs de débutant. Donc même s'il existe un shell pour aller faire des trucs en lignes de commandes, il est très limité et on n'a pas de gestionnaire de paquets pour installer des choses.

Pour faire mes tests, ça va être pénible. J'ai donc commencé par créer une VM (puisque je peux le faire, autant en profiter). Première boulette, créer une VM Ubuntu avec 512 Mo de RAM (la valeur par défaut dans ). Avec un environnement graphique, ça plante dès l'installation... Mais ça se corrige vite.

![](/2024/07/vm1.png)

Deuxième coup d'arrêt, les droits... libvirt n'a pas le droit d'accéder à l'ISO. C'est dommage...

![](/2024/07/share1.png)

Toute la gestion des partages et notamment des droits sur les fichiers et assez peu "user friendly" sur TrueNAS. C'est vraiment une déception personnelle de ce côté là, j'ai dû bidouiller pas mal pour que les utilisateurs **ET** les apps puissent accéder correctement à mon stockage. J'ai même dû corriger quelques permissions à la main à coup de `chmod`. Bref.

![](/2024/07/share2.png)

Une fois installée, j'installe `stress-ng` et je lui demandé de me saturer les 4 CPUs histoire de faire monter la température.

Pour que les tests soient les plus représentatifs possibles, j'ai laissé tourner 45 minutes le temps que ça se stabilise :

![](/2024/07/cpu-stress-1.jpeg)

Ici, on voit que ça se stabilise autour de 46°C avec un air ambiant à 23°C, ce qui me parait parfait (les conditions de stress tests avec tous les CPUs à 100% pendant plusieurs dizaines de minutes sont déjà peu réalistes).

Côté disques, même sur des longues phases d'écritures pendant plusieurs heures, on est sous les 50°C (40 en idle)

![](/2024/07/disk-temp1.jpeg)

On est bon pour la température.

## Bonus fanless

Note : il est possible d'acheter des minis PC format NUC totalement fanless avec des N100 (avec des performances parfois erratiques).

On m'a donc mis au défi (sur Twitter) de tester sans ventilateur pour le CPU. Après tout pourquoi pas, j'avais bien mon premier NAS vendu avec une carte mère avec un Atom et une carte graphique NVidia fanless (mais les perfs étaient catastrophiques).

Après quelques tests, oui, *ça fonctionne*, mais c'est pas dingue. On tape les 90° et très probablement un throttling assez intense (pas vérifié).

![](/2024/07/cpu-stress-2.jpeg)

C'est pas complètement un échec, puisque ça marcherait surement mieux avec un radiateur plus gros et que ce test n'est pas représentatif d'une charge réellement.

Mais retirer le ventilateur du CPU ne rend pas le NAS beaucoup plus silencieux (il reste les disques et le ventilateur des disques). J'ai donc remis le ventilateur et c'est très bien comme ça :-P.

## Consommation électrique

Deuxième point important quand on choisit un NAS, la consommation électrique. C'est un point que vous êtes nombreux⋅ses à attendre aussi ;-).

Clairement, il est impossible de faire aussi bien que mon QNAP avec du matériel généraliste de particulier. La carte mère et le CPU sont certainement gourmands, l'alimentation n'est que "bronze plus" (et donc induit des pertes). Le but de jeu, ça va être de voir à quel point je vais moins bien.

J'ai donc pris des mesures sans disques, avec 3 disques idle et avec 3 disques en charges [sur mon NAS QNAP](/2018/01/23/stockage-pour-un-admin-geek-qnap-ts431p2-ou-synology-ds418j/) que je remplace, puis je fais les mêmes mesures sur mon NAS.

| Modèle      | Sans disques      | 3 disques idle      | 3 disques en charge      |
| ------------- | ------------- | ------------- | ------------- |
| QNAP | 9w* | 23w | 36w |
| Jonsbo × N100 | 19w | 33w | 42w |

\* sans disques, le QNAP est inutilisable car on doit installer l'OS sur les HDD !

Grosso modo, je me prends entre 6 et 10w de plus dans la vue. 10w, surtout sur une machine qui reste allumée toute l'année, c'est significatif. Mensuellement, ça représente 7,31 kWh (~ 1,17 €) de consommation en plus par rapport à l'ancien modèle.

Je sais déjà qu'une partie de la Twittosphère techs / bidouilleurs barbus va me tomber dessus (c'est déjà fait). Mais si on y réfléchit un peu, ce n'est pas très étonnant, car les deux machines ne sont pas du tout comparables. **Je ne peux pas faire les mêmes choses avec le QNAP qu'avec ce build**.

Ce "Jonsbo × N100" me donne la possibilité d'avoir jusqu'à 6 disques (5 hotswap) là où j'étais limité à 4 avec le QNAP, avec l'OS et la data séparée proprement. J'ai la possibilité de faire des machines virtuelles si je le souhaite (pas le cas avec le QNAP) et j'ai le support de Chart helm pour installer des applications containerisées (là où QNAP ne supporte que Docker et plus LXC, [cf l'article pour contourner le problème](/2022/06/13/qnap-debranche-lxc-workaround/)).

Et j'ai surtout bien plus de puissance, entre les débits et le réseau en 2.5 Gbps (on y reviendra sur les tests de transferts). Donc je ne me mets pas martel en tête et je vais continuer à cordialement ignorer les commentaires négatifs que j'ai pu avoir sur ce choix.

## Tests de réseau

L'achat de ce NAS a été l'occasion pour moi de passer sur du 2.5 Gbps sur mon réseau éthernet (achat d'un switch 2.5 et d'une carte pcie pour mon PC).

J'ai donc fait des tests avec [iperf3](https://iperf.fr/) (et aussi [speedtest cli](https://www.speedtest.net/apps/cli))

```
admin@truenas[~]$ iperf3 -c 192.168.aaa.pc
Connecting to host 192.168.aaa.pc, port 5201
[  5] local 192.168.aaa.nas port 57256 connected to 192.168.aaa.pc port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   284 MBytes  2.38 Gbits/sec    0    814 KBytes       
[  5]   1.00-2.00   sec   280 MBytes  2.35 Gbits/sec    0    814 KBytes       
[  5]   2.00-3.00   sec   281 MBytes  2.36 Gbits/sec    0    854 KBytes       
[  5]   3.00-4.00   sec   280 MBytes  2.35 Gbits/sec    0    854 KBytes       
[  5]   4.00-5.00   sec   281 MBytes  2.36 Gbits/sec    0    854 KBytes       
[  5]   5.00-6.00   sec   280 MBytes  2.35 Gbits/sec    0    854 KBytes       
[  5]   6.00-7.00   sec   280 MBytes  2.35 Gbits/sec    0    854 KBytes       
[  5]   7.00-8.00   sec   281 MBytes  2.36 Gbits/sec    0    854 KBytes       
[  5]   8.00-9.00   sec   280 MBytes  2.35 Gbits/sec    0    854 KBytes       
[  5]   9.00-10.00  sec   281 MBytes  2.36 Gbits/sec    0    854 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  2.74 GBytes  2.36 Gbits/sec    0             sender
[  5]   0.00-10.04  sec  2.74 GBytes  2.34 Gbits/sec                  receiver
```

Fun fact : c'est aussi la première fois que j'ai pu tester la vitesse de ma fibre free 5 gbps au delà du gigabit (mais je peux toujours pas aller jusqu'aux 5 gbps théoriques de la ligne).

![](/2024/07/iperf1.png)

![](/2024/07/speedtest-cli.png)

Là aussi, tout est OK. Côté réseau, la promesse du NAS maison est tenue !

## Test des disques

Le test le plus trivial à faire quand on veut tester un stockage, c'est d'écrire dessus et de voir ce que ça donne. C'est pas toujours très représentatif mais ça donne une base de départ.

```
root@truenas[/mnt/rpool]# dd if=/dev/urandom of=test1g bs=1M count=1024
1024+0 records in
1024+0 records out
1073741824 bytes (1.1 GB, 1.0 GiB) copied, 3.07779 s, 349 MB/s

root@truenas[/mnt/rpool]# dd if=/dev/urandom of=test10g bs=1M count=10240
10240+0 records in
10240+0 records out
10737418240 bytes (11 GB, 10 GiB) copied, 41.9781 s, 256 MB/s

root@truenas[/mnt/rpool]# dd if=/dev/urandom of=test40g bs=1M count=40960
40960+0 records in
40960+0 records out
42949672960 bytes (43 GB, 40 GiB) copied, 204.116 s, 210 MB/s

root@truenas[/mnt/rpool]# dd if=/dev/zero of=test10gzero bs=1M count=10240 
10240+0 records in
10240+0 records out
10737418240 bytes (11 GB, 10 GiB) copied, 3.37509 s, 3.2 GB/s
```

Ici, j'ai essayé de copier des données aléatoires sur le pool avec mes 3 disques. Tant qu'on est sur des fichiers de 1 Go, il reste le risque que tout soit mis en cache RAM (rappel : sauf indication contraire, ZFS utilise par défaut la moitié de votre RAM). Au-delà de 10 Go, on voit une dégradation de perfs. Quoiqu'on fasse, on ne fera pas mieux que cette base-là (baseline).

Des copies de fichiers en local (depuis le disque NVMe du système vers le pool ZFS) donnent des résultats similaires.

Note : on voit aussi que je dépasse très largement la vitesse physique de mes disques sur la copie de /dev/zero. 3.2 Go/s est évidemment impossible avec 3 HDDs. Ce sont les optimisations de ZFS (cache + compression) qui permettent ça et ça sera utile pour les fichiers contenant beaucoup de zéro (comme certains disques de machines virtuelles, par exemple).

## Tests de transferts NFS/CIFS

Pour ces tests là, je ne suis pas hyper satisfait. Quand j'utilise les outils du marché permettant de désactiver les caches, les performances sont très en deça (< 50 Mo/s) des performances en utilisation réelle.

voici une petite liste des outils que j'ai testés :
* [fio](https://fio.readthedocs.io/en/latest/fio_doc.html) (depuis un client linux sur CIFS)
* [diskpd](https://github.com/microsoft/diskspd) (depuis un client Windows sur CIFS)
* Copie de fichiers depuis un client Linux en NFS en ligne de commande
* Copie de fichiers depuis un client Ubuntu dans Nautilus en CIFS [via gvfsd (Gnome virtual file system)]
* Copie de fichiers depuis un client Windows en CIFS

Ce qu'il est ressort, c'est que le NAS est suffisamment puissant pour saturer un port Ethernet gigabit mais galère un peu plus pour le 2.5Gbps (les fluctuations sont dues au cache qui se vide pas assez vite sur les disques). Sous windows, on peut tirer au moins 150 Mo/s en écriture sur de gros fichiers sans problèmes avec des pics à 280 Mo/s.

![](/2024/07/copiecifs.png)

La copie NFS et CIFS sous Ubuntu affichait des chiffres étonnants (70 Mo/s en lecture mais 120 en écriture !?). Il faudra que je fasse des tests depuis une autre machine Linux.

![](/2024/07/gvfs.png)

Les performances sans caches avec `fio` sont très en deça (40-50 Mo/s) mais comme je l'ai expliqué juste avant, ces tests ne sont pas représentatifs des performances que j'obtiens en conditions réelles (plutôt autour du gigabit), même sur des copies très longues (>3 To).

Sous Windows, les performances trouvées avec `diskspd` sont plus proches de la réalité, avec 80 Mo/s en écriture (mais il écrit d'abord des données aléatoires beaucoup plus rapidement sur le NAS et lit dedans) et 280 Mo/s en lecture.

![](/2024/07/diskspd-lecture.png)

![](/2024/07/diskspd-ecriture.png)

![](/2024/07/network.png)

Je n'ai pas encore fait de tests en iSCSI.

## Conclusion

Le but était d'avoir un NAS silencieux et qui ne consomme pas trop, plus puissant que mon NAS précédent (QNAP), avec un support du 2.5 Gbps, du ZFS, des containers, des apps et des machines virtuelles.

Avec cette suite d'articles, je pense avoir coché toutes les cases. Je suis donc content de mon investissement. Pour rappel, j'en ai eu pour environ 500€, upgrade de la maison en 2.5 Gbps inclu.

En termes de boitiers, le Jonsbo N2 est vraiment LE boitier qui me fallait. Il est bien conçu, bien fini, pratique. 

Côté carte mère, on sent que le N100 est suffisant mais est quand même aux limites de ce que je lui demande. Une partie des "bottlenecks" que j'ai rencontré viennent très probablement du CPU, les autres venant du pool de 3 vieux disques "red" peu performants.

Côté consommation et chauffe, c'est un peu moins bien que ce que j'avais avant mais rien de catastrophique. C'est en tout cas largement mieux que ce que j'aurais pu faire avec un CPU grand public.

Le plus gros point noir serait peut-être TrueNAS, un peu trop rigide sans pour autant être user friendly. Fonctionnellement, tout y est, c'est juste "pas super agréable" à utiliser.

Pour l'usage que j'en fais et les objectifs que j'avais, c'est un réel succès, si on met de côté l'OS. Je n'ai pas forcément envie de retourner sur un OS Linux nu avec lequel je fais tout moi-même...

Il faudra peut-être explorer des alternatives à TrueNAS, ou m'en contenter ?

## Bonus : quelques commandes utilisées pour mes tests

`diskspd`

```
# Tests en lecture / écriture sur des blocs de 4 Ko
.\DiskSpd\amd64\diskspd.exe -c10G -d30 -b4k -h -o32 -t4 -r -w0 \\192.168.aaa.nas\tank\test
.\DiskSpd\amd64\diskspd.exe -c10G -d30 -b4k -h -o32 -t4 -r -w100 \\192.168.aaa.nas\tank\test

# Tests en lecture / écriture sur des blocs de 4 Mo
.\DiskSpd\amd64\diskspd.exe -c10G -d30 -b4M -h -o32 -t4 -r -w0 \\192.168.aaa.nas\tank\test
.\DiskSpd\amd64\diskspd.exe -c10G -d30 -b4M -h -o32 -t4 -r -w100 \\192.168.aaa.nas\tank\test
```

`fio`

```
cat > seq_rw_test.fio <<EOF
[global]
ioengine=libaio
direct=1
sync=1
size=10G

[sequential_read]
filename=/mnt/rpool/nfs/seqreadwrite
rw=read
bs=4M

[sequential_write]
filename=/mnt/rpool/nfs/seqreadwrite
rw=write
bs=4M
EOF

fio seq_rw_test.fio
```
