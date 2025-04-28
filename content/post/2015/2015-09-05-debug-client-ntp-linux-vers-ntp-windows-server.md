---
title: 'Debug : Client NTP Linux vers NTP Windows Server'
authors:
  - zwindler
type: post
date: 2015-09-05T10:30:12+00:00
url: /2015/09/05/debug-client-ntp-linux-vers-ntp-windows-server/
image: /2015/09/ntp.png
categories:
  - Système
tags:
  - debug
  - dispersion
  - driftfile
  - flash
  - iburst
  - maxdist
  - NTP
  - regedit
  - SNTP
  - tos
  - w32time
  - Windows
  - Windows Server

---
Si vous travaillez comme moi dans un contexte mixant les serveurs Linux et des serveurs Windows, vous avez probablement un serveur Active Directory pour gérer votre annuaire d’entreprise (ou au moins gérer vos serveurs Windows dans un ensemble cohérent).

Et comme les serveurs Windows dans un domaine Active Directory sont tous automatiquement synchronisés sur le temps du serveur maitre de l’AD, vous vous êtes probablement dit que ça serait une bonne idée de synchroniser tout le monde sur le même serveur.

Ou alors, vous avez un vieux serveur Windows connecté à une horloge hertzienne (ou autre, GPS, etc) et vous voudriez qu’il serve de source de temps fiable.

> Mais rien n’y fait, ces fichus linux refusent de se mettre à jour ! Pourquoi ?

## Configurer notre NTP Windows

### w32time est il un serveur NTP ?

D’abord, avant de vous lancer, il faut que vous sachiez que Microsoft n’a pas fait un boulot terrible avec w32time. On ne peut pas vraiment qu’il s’agit d’un « vrai » serveur NTP. En fait, il s’agit plutôt d’une adaptation du service du temps w32time pour servir de serveur aux éventuels clients assez fous pour demander l’heure.

A ma connaissance, w32time n’a même pas de « driftfile » : si la source de temps n’est pas disponible et que l’horloge interne du serveur dérive, le serveur sera incapable de se corriger de lui même et votre heure se décalera de plus en plus.

Pour en terminer avec ce démontage en règle, c’est tellement du bidouillage qu’une des méthodes les plus répandues pour configurer le « serveur de temps » Windows consiste à modifier des clés de registre. Moi je vous donne la version « lignes de commandes », mais bon, tout est dit...

### Méthode ligne de commandes

Si le serveur Windows en question est un serveur Active Directory, vous pouvez passez à l’étape « Linux » de l’article, car le serveur w32time est déjà configuré

Toutes les commandes sont à entrer dans un prompt « administrateur »

  * Couper le temps windows

```
net stop w32time
```


  * Synchroniser le serveur par rapport à une source de temps (soit un autre serveur NTP, soit l’horloge locale)

```
w32tm /config /syncfromflags:manual /manualpeerlist:[hostname] #si on souhaite connecter ce serveur à un autre serveur (sur Internet ou local)
```


ou

```
w32tm /config /syncfromflags:manual #s'il n'y a pas de "père" et qu'on veut prendre la "local clock" comme source de temps
```


<p style="padding-left: 30px;">
  Pour information, on peut spécifier plusieurs serveurs dans [hostname], il faut juste les séparer par des virgules
</p>

  * Définir le serveur en tant que source de temps fiable

```
w32tm /config /reliable:yes
```


  * Relancer le temps windows

```
net start w32time
```


  * Afficher la configuration

```
w32tm /query /configuration
```


  * Resynchronisation (dans le cas où vous avez spécifié un serveur dans manualpeerlist)

```
w32tm /resync /rediscover
```


### Et la méthode regedit alors ?

Les clés de registre à modifier se situent dans le noeud de registre HKEY\_LOCAL\_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config\. Principalement, vous devrez modifier AnnounceFlags et NTPServer pour indiquer que vous êtes serveur NTP

Vous trouverez les valeurs des clés de registre sur la page officiel du support à l’adresse suivante :

* [support.microsoft.com/fr-fr/kb/223184](https://support.microsoft.com/fr-fr/kb/223184)

## Mais rien n’y fait, ces fichus Linux refusent de se mettre à jour ! Pourquoi ?

Je ne vais pas couvrir ici comment installer le client NTP sur les serveurs Linux, il y a suffisamment de documentations et de blogs qui traitent du sujet. Ce qu’ils expliquent plus rarement en revanche, c’est comment ça se fait que les clients NTP Linux refusent le temps provenant d’un serveur Windows.

Assurez vous déjà de ne pas avoir laissé plus de « restrict » que nécessaire. En effet, pas sécurité, les clients NTP sont souvent paramétrés de manière très sécurisée, ce qui est bien mais génère souvent des erreurs.

Voici un exemple de fichier de configuration minimaliste pour un client NTP sur un serveur RedHat Entreprise Linux

```
cat /etc/ntp.conf
 server ntp1.mondomaine.fr iburst #enlever iburst hors debugging
 server mondomaine.fr
 server serveurntp.de.linternet.fr

 driftfile /var/lib/ntp/drift
```


Et c’est tout. Dans la plupart des contexte, vous n’aurez pas besoin de plus. Et comme le mieux est l’ennemi du bien ...

### Je n’ai pas de restrict, et ça ne fonctionne toujours pas !

Tout à l’air correct, votre client Linux est paramétré pour se connecter sur les serveurs Windows, le démon tourne, mais ça ne fonctionne pas.

C’est la que le « fun » commence vraiment : on va débuguer NTP.

Pour ça, je vous propose d’utiliser la commande **ntpq** et ses nombreuses fonctions, qui soyons honnête, n’est pratiquement jamais utile, à part dans des cas comme ça !

```
# ntpq
ntpq> peers
      remote           refid      st t when poll reach   delay   offset  jitter
 ==============================================================================
  ntp1.mondom 111.0.111.151    4 u   34   64  377    0.272  -184.31   9.019
```


Ici, j’affiche les serveurs NTP avec la fonction **peers**. Je n’ai paramétré que le serveur Windows ntp1.mondomaine.com pour simplifier le diagnostic.

Normalement, tout à gauche, juste avant le nom, je devrais avoir un symbole * qui indique que le client s’est connecté à ce serveur, ou éventuellement + pour annoncé que le serveur est utilisable (si vous avez plusieurs serveurs).

Ici ce n’est pas le cas. Avec la fonction **as**, on peut obtenir plus d’informations.

```
ntpq> as
 ind assID status  conf reach auth condition  last_event cnt
 ===========================================================
   1  8950  9014   yes   yes  none    reject   reachable  1
```


Mon serveur ntp1 avec l’ID assID=8950 est en condition **reject**, malgré qu’il soit **reachable**. Ce n’est donc pas un souci réseau ou pare-feu. Pour avoir plus de détails, on peut utiliser la fonction **rv**, qui prend en argument l’assID du serveur

```
ntpq> rv 8950
 assID=8950 status=9014 reach, conf, 1 event, event_reach,
 srcadr=ntp1.mondomaine.com, srcport=123, dstadr=111.0.111.130,
 dstport=123, leap=00, stratum=4, precision=-6, rootdelay=93.750,
 rootdispersion=10329.788, refid=111.0.111.151, reach=377, unreach=0,
 hmode=3, pmode=4, hpoll=6, ppoll=6, flash=400 peer_dist, keyid=0, ttl=0,
 offset=-184.319, delay=0.272, dispersion=17.890, jitter=7.364,
 reftime=d58e6c8b.deb41e80  Mon, Jul 15 2013 14:41:47.869,
 org=d58e6cf5.7eb41e80  Mon, Jul 15 2013 14:43:33.494,
 rec=d58e6cf5.adb21a64  Mon, Jul 15 2013 14:43:33.678,
 xmt=d58e6cf5.ad9d86ac  Mon, Jul 15 2013 14:43:33.678,
 filtdelay=     0.31    0.30    0.29    0.27    0.36    0.35    6.65    1.05,
 filtoffset= -183.41 -183.41 -183.98 -184.32 -185.32 -192.70 -173.01 -170.95,
 filtdisp=     15.63   16.57   17.56   18.51   19.45   20.40   21.37   22.33
```


### Qu’est ce qu’il faut comprendre là dedans ?

Ce qui va vraiment nous aider à comprendre le souci ici, c’est le code flash, qui peut d’ailleurs vous servir si vous avez d’autres problème de NTP complexes à débuguer :

```
The flash status word is displayed by the ntpq program rv command. It consists of a number of bits coded in hexadecimal as follows:
Code 	Tag 	Message 	Description
0001 	TEST1 	pkt_dup 	duplicate packet
0002 	TEST2 	pkt_bogus 	bogus packet
0004 	TEST3 	pkt_unsync 	server not synchronized
0008 	TEST4 	pkt_denied 	access denied
0010 	TEST5 	pkt_auth 	authentication failure
0020 	TEST6 	pkt_stratum 	invalid leap or stratum
0040 	TEST7 	pkt_header 	header distance exceeded
0080 	TEST8 	pkt_autokey 	Autokey sequence error
0100 	TEST9 	pkt_crypto 	Autokey protocol error
0200 	TEST10 	peer_stratum 	invalid header or stratum
0400 	TEST11 	peer_dist 	distance threshold exceeded
0800 	TEST12 	peer_loop 	synchronization loop
1000 	TEST13 	peer_unreach 	unreachable or nonselect
```


Ici, **400 peer_dist** signifie que le « distance threshold » du serveur Windows (un paramètre à priori arbitraire puisqu’on peut le changer comme on le souhaite) est considéré comme trop important par le client NTP. Il y a donc deux méthodes pour résoudre ce problème :

## Les solutions

### Côté Linux

Dans votre configuration NTP, vous pouvez ajouter la ligne suivante, puis redémarrer le client NTP.

```
cat /etc/ntp.conf
 [...]
 tos maxdist 20 #utile pour les serveurs windows qui par défaut on un localclockdisp à 10 secondes par défaut
                #sinon le débuging NTP loguera un condition reject sans plus de détails
                #Ce paramètre windows est d'ailleurs modifiable avec un w32tm /config /localclockdisp X
```


Au bout de quelques secondes il devrait se synchroniser (vous pouvez vérifier avec ntpq -p ou ntpstat)

```
watch "ntpq -p"
```


```
ntpstat ntp2.mondomaine.com
 synchronised to NTP server (111.0.111.13) at stratum 2
    time correct to within 10100 ms
    polling server every 64 s
```


### Côté Windows

A l’inverse, vous pouvez tout à fait décider d’abaisser la dispersion au maximum (sous 3 secondes, je crois que ça fonctionne) sur le serveur Windows.

```
w32tm /config /localclockdispersion:3 /update
w32tm /resync /rediscover
```


Le client Linux devrait alors se montrer plus coopératif

```
ntpstat
synchronised to NTP server (111.0.111.147) at stratum 2
  time correct to within 3046 ms
  polling server every 64 s
```


## Ressources utiles

Pour en arriver à écrire cet article, je peux vous dire que j’ai passé pas mal de temps à fouiller Internet. Voici l’ensemble des ressources qui m’ont aidé à trouver la solution :

NTP 4 pour Windows

* [www.eecis.udel.edu/~mills/ntp/html/hints/winnt.html (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20240119043605/https://www.eecis.udel.edu/~mills/ntp/html/hints/winnt.html)

Debuguer NTP

* [rags.wordpress.com/2011/10/17/how-to-debug-ntp-issues/](http://rags.wordpress.com/2011/10/17/how-to-debug-ntp-issues/)
* [www.eecis.udel.edu/~mills/ntp/html/debug.html (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20240918132045/https://www.eecis.udel.edu/~mills/ntp/html/debug.html)

Wiki du support NTP officiel

* [support.ntp.org/bin/view/Support/ConfiguringNTP](http://support.ntp.org/bin/view/Support/ConfiguringNTP)
NTP serveur pour Windows (interaction avec Linux)

* [yadhutony.blogspot.fr/2012/10/ntp-time-server-configuration-in.html](http://yadhutony.blogspot.fr/2012/10/ntp-time-server-configuration-in.html)
* [blog.galsungen.net/?tag=ntp](http://blog.galsungen.net/?tag=ntp)
* [inf0blog.canalblog.com/archives/2010/07/27/18679194.html](http://inf0blog.canalblog.com/archives/2010/07/27/18679194.html)

Codes NTP

* [www.eecis.udel.edu/~mills/ntp/html/decode.html#flash (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150225052251/https://www.eecis.udel.edu/~mills/ntp/html/decode.html#flash)