---
title: '[Tutoriel] Installation de deux clients NSClient++ sur le même serveur'
authors:
  - zwindler
type: post
date: 2015-10-17T10:30:00+00:00
url: /2015/10/17/tutoriel-installation-de-deux-clients-nsclient-sur-le-meme-serveur/
image: /2015/07/nsclient-logo.png
categories:
  - Monitoring
  - systeme
tags:
  - client
  - clients multiples
  - msi
  - NRPE
  - NSClient++
  - port
  - sources
  - Windows 2003
  - Windows 2008
  - Windows 2012

---
## Le problème

Je suis tombé sur un problème amusant l’autre jour. Un serveur sur lequel deux entités se partageaient l’administration voulaient toutes les deux superviser le serveur avec [NSClient++](http://www.nsclient.org), mais chacune avec leur propre configuration et leurs propres plugins.

En théorie, il n’est pas possible d’installer deux fois le client sur le même serveur Windows. En fait, si on relance l’installeur une seconde fois, il nous proposera simplement de modifier l’installation existante.

![Impossible d’installer un deuxième client dans un autre répertoire via l’installeur .msi](/2015/07/01_nsclient.png)

## Retour aux sources

Cependant, on peut s’en sortir avec les sources. Je pars du principe que le premier client a été installé simplement à partir du MSI. Et pour pouvoir installer le deuxième client, il faut récupérer une archive .zip sur le site (Source).

* [www.nsclient.org/download](http://www.nsclient.org/download/)

On peut ensuite le déposer dans **C:\\Program Files\\**, en prenant soin de lui donner un autre nom que celui du client installé via le fichier .msi (**C:\\Program Files\\NSclient++\\** par défaut).

Pour l’exemple, j’ai pris **C:\\Program Files\\NSClientNew\\.**

![Nos deux dossiers cohabitent](/2015/07/02_nsclient.png)

![Lancer le binaire à la main ne fonctionnera pas non plus](/2015/07/03_nsclient.png)

## Configurer le second NSClient

Modifiez ensuite le fichier de configuration **C:\\Program Files\\NSClientNew\\NSC.ini** pour que les ports ne soient pas identiques aux ports du premier client.

```
[NSClient]
port=12481
[NRPE]
port=56661
...
```


Dans un prompt administrateur, lancer la commande suivante pour créer un service Windows spécifique pour le second client.

```
PS C:\Program Files\NSClientNew> sc.exe create NSClientNew binPath= 'C:\Program Files\NSClientNew\NSClient++.exe' start=  auto DisplayName= 'NSClient++ New'
[SC] CreateService réussite(s)
```


NSClient++ devrait maintenant apparaître dans la liste

![On a bien 2 lignes NSClient++ et NSClient++New](/2015/07/05_nsclient.png)

Si tout se passe bien, on peut maintenant démarrer le service et les ports en écoute doivent apparaître. Le log **C:\\Program Files\\NSClientNew\\nsclient.log** doit afficher la ligne suivante

```
2015-07-16 15:51:26: message:modules\FileLogger\FileLogger.cpp:86: Starting to log for: NSClient++ - 0.3.9.330 2011-09-02
```

Si on a l’entrée suivante, c’est que les ports ont été mal configurés et qu’il y a conflit

```
2015-07-16 15:49:35: error:include\Socket.h:691: bind failed: 10048: Une seule utilisation de chaque adresse de socket (protocole/adresse réseau/port) est habituellement autorisée.
```


Une fois que c’est bon, vous pouvez tester vos deux clients depuis votre serveur Nagios via un `check_nrpe` sans arguments

```
[root@nagios libexec]# ./check_nrpe -H 192.168.20.10 -p 5666
I (0.3.9.328 2011-08-16) seem to be doing fine...
[root@nagios libexec]# ./check_nrpe -H 192.168.20.10 -p 56661
I (0.3.9.330 2011-09-02) seem to be doing fine...
```


## Bonus track : supprimer le service NSClientNew une fois qu’on en veut plus

Si jamais l’envie vous prend de supprimer ce que vous venez de faire, il faudra supprimer à la main le service de la façon suivante, puis supprimer le dossier. Exécutez la commande suivante dans un cmd/powershell en tant qu’administrateur

```
C:\Windows\system32>sc delete NSClientNew
[SC] DeleteService réussite(s)
```
