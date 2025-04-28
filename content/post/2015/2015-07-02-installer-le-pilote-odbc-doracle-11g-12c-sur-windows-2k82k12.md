---
title: 'Installer le pilote ODBC d’Oracle 11g 12c sur Windows 2k8/2k12'
authors:
  - zwindler
type: post
date: 2015-07-02T10:45:02+00:00
url: /2015/07/02/installer-le-pilote-odbc-doracle-11g-12c-sur-windows-2k82k12/
image: /2015/07/oracle-microsoft.png
categories:
  - Logiciel
  - Système
tags:
  - 11g
  - 12c
  - basic
  - client
  - instant
  - odbc
  - odbcad32
  - Oracle
  - pilote
  - PowerShell
  - runtime
  - Windows 2008
  - Windows 2012
  - Windows 7
  - Windows 8

---
Lorsqu’un progiciel installé sur un serveur Windows nécessite une connexion à une base Oracle, il n’est pas toujours nécessaire d’installer un client Oracle (même Runtime). Des fois, c’est simplement le pilote ODBC qui est nécessaire.

Seulement, pour ceux qui comme moi ne sont ni à l’aise avec Windows 2012, ni à l’aise avec ce genre de considérations, j’ai trouvé que c’était un peu nébuleux.

Voici la page où on peut télécharger tous les bouts de clients Oracle pour Windows qu’on veut [ici](http://www.oracle.com/technetwork/topics/winx64soft-089540.html).

Quoi faire avec? A vous de le savoir (ou alors, il faut trouver la bonne doc, ce qui n’a pas été mon cas pour l’instant) ! [Edit]En fait c’est écrit touuuuuut en bas de la page, après la longue liste de téléchargements[/Edit]

Il ne faut pas se contenter de télécharger l’archive, qui est insuffisante en soit, il faut aussi récupérer l’archive « basic », qui contient grosso modo le cœur du pilote ODBC. Dans mon cas il me fallait un pilote en version Oracle 11.2, mais le principe reste le même pour d’autres versions.

  * instantclient-basic-windows.x64-11.2.0.4.0.zip
  * instantclient-odbc-windows.x64-11.2.0.4.0.zip

Dézipppez dans le MÊME dossier les deux archives. Dans mon cas, je les ai mis dans **C:\Program Files\instantclient\_11\_2**

Enfin, lancez un shell PowerShell en tant qu’administrateur, puis, dans le dossier en question, exécutez la commande odbc_install (.exe).

![](/2015/07/01_odbc.png)


Pour finir, avant que le pilote soit totalement opérationnel, il faut aussi modifier la variable d’environnement globale de Windows « Path » pour y ajouter le chemin vers le pilote ODBC.

![](/2015/07/02_odbc.png)



Une fois toutes ces opérations réalisées, le pilote ODBC devrait être visible dans l’administrateur de sources de données, via le binaire « _C:\Windows\SysWOW64\odbcad32.exe_ »

![](/2015/07/03_odbc.png)


Quelques infos trouvées sur les sites suivants :

  * [www.oracle.com/technetwork/topics/winx64soft-089540.html](http://www.oracle.com/technetwork/topics/winx64soft-089540.html)
  * [itkbs.wordpress.com/2014/07/28/how-to-install-odbc-driver-for-oracle-in-windows-7](https://itkbs.wordpress.com/2014/07/28/how-to-install-odbc-driver-for-oracle-in-windows-7)
