---
title: 'SQL Server 2005 : PowerShell > Batch – Episode 2'
authors:
  - zwindler
type: post
date: 2010-04-27T13:09:43+00:00
url: /2010/04/27/sql-server-2005-powershell-batch-episode-2/
image: /2010/04/4846.logo-powershell.png
categories:
  - Script
tags:
  - Batch
  - MS SQL Server 2005
  - PowerShell
  - vCenter

---
A quoi ça sert de faire du PowerShell si on continue à utiliser de vieux exécutables tout pourris ?

Dans le précédent article, je vous ai donné un script  home-made qui permet de faire une backup automatisée d’une base de données SQL Server 2005, en me basant sur l’appel du mécanisme de backup par l’interpréteur de T-SQL (beurk!) SQLCMD.EXE. Ceci est un bon exemple des dangers d’être autodidacte. Si seulement j’avais gratté un peu plus avant de foncer tête baissée, j’aurai découvert (ce que je viens de faire par hasard) qu’il existe des objets pour ça : SMO!

SMO?

> La collection d’objets SMO (SQL Server Management Objects) est conçue pour la programmation de tous les aspects de la gestion de Microsoft SQL Server. La collection d’objets RMO (SQL Server Replication Management Objects) encapsule la gestion de la réplication SQL Server.

En fouillant un peu sur cette piste, je suis tombé sur [cet article de Database journal (lien mort, j'utilise Internet archive)](https://web.archive.org/web/20110415102629/http://www.databasejournal.com/features/mssql/article.php/10894_3681061_2/Microsoft-Windows-PowerShell-and-SQL-Server-2005-SMO--Part-I.htm). Il nous explique cordialement que toute cette ligne de commande moche que j’utilisais pour enclencher la backup peut être évité en utilisant des objets manipulables dans PowerShell. « Cool, me dis-je, je vais pouvoir proprifier mon script. C’est dommage de ne pas avoir trouvé ça dès le début! »

En fouillant un peu plus, je suis tombé sur [le dernier article (lien mort, j'utilise Internet archive)](https://web.archive.org/web/20211207075523/https://www.databasejournal.com/features/mssql/article.php/3693606/Microsoft-Windows-PowerShell-and-SQL-Server-2005-SMO-150-Part-6.htm). En gros, tout l’article explique pas à pas comment faire pour faire mieux en moins de lignes (backups incrémentales for dummies).

Pour garder la tête haute, je vais quand même héberger une nouvelle version du script, qui proposera de faire des backups incrémentales ou non, en m’inspirant fortement du code disponible sur databasejournal pour améliorer le mien.

Zwindler 0 - Internet 1

