---
title: 'Changer la politique d’erreur (ErrorPolicy) sur un imprimante dans CUPS'
authors:
  - zwindler
type: post
date: 2015-08-15T10:30:51+00:00
url: /2015/08/15/changer-la-politique-derreur-errorpolicy-sur-un-imprimante-dans-cups/
image: /2015/07/cce_cups.jpg
categories:
  - systeme
tags:
  - accepting tasks
  - CUPS
  - ErrorPolicy
  - Linux
  - printer stopped
  - retry-job
  - RHEL
  - stop-printer
  - Unix

---
Lorsque l’imprimante a une erreur « physique » (comprenez « Paper jam », coupure réseau, ouverture du capot, etc), CUPS la met automatiquement en erreur sur les versions récentes. En fait, par défaut le paramètre **ErrorPolicy** est positionné à **stop-printer**.

Du coup, toutes les impressions qui suivent se retrouvent bloquées alors que l’utilisateur a peut être résolu le problème (ou qu’il s’est résolu de lui même... si si, ça arrive). On peut modifier ce comportement par défaut soit au niveau de l’imprimante elle même, soit de manière globale.

# Par imprimante, via une ligne de commande

En temps que root ou un utilisateur privilégié, lancez la commande suivante :

```
/usr/sbin/lpadmin -p [nom_imprimante] -o printer-error-policy=retry-job
```


# Par imprimante, dans le printers.conf

Ouvrez le fichier **printers.conf** qui contient toutes les imprimantes de CUPS ainsi que leur configuration

```
vi /etc/cups/printers.conf
    <Printer "PrinterName">
```


Modifier la valeur de **ErrorPolicy** à **retry-job** puis rechargez CUPS (je préfère le reload plutôt que le restart, mais à votre convenance)

```
service cups reload
```


# Globalement dans la configuration de CUPS

On peut modifier ce paramètre d’un coup pour toutes les imprimantes.

```
vi /etc/cups/cupsd.conf
    [...]
    ErrorPolicy retry-job
```


Attention : ça fonctionnera **si** (et seulement si) il n’est pas déjà défini dans le fichier printers.conf. Et par défaut, les imprimantes déclarées dans CUPS disposent de cette ligne, qu’il faudra donc supprimer.

Sauvegarder le fichier et recharger CUPS

```
service cups reload
```


# Quelques paramètres supplémentaires

Mais attention ! Quelque soit la méthode que vous aurez choisi, n’oubliez pas que la méthode retry-job implique, comme son nom l’indique, une politique de « retry » ! Et donc potentiellement un échec si au bout de X retry espacés de Y secondes.

Soyez donc prudent et sachez bien ce que vous faites si vous modifiez cette politique.

Pour vous donner un peu plus de flexibilité sur le nombre de retry et la durée entre chaque, voici les paramètres qu’il faut modifier respectivement :

  * JobRetryInterval seconds #par défaut 30 selon le man ?
  * JobRetryLimit count # par défaut 5

Pour encore plus d’infos, vous pouvez toujours aller sur la page man de cupsd.conf, aussi disponible [ici][1].

 [1]: https://www.cups.org/doc/man-cupsd.conf.html
