---
title: 'SQL Server 2005 : PowerShell > Batch – Episode 3'
authors:
  - zwindler
type: post
date: 2010-04-28T16:52:16+00:00
url: /2010/04/28/sql-server-2005-powershell-batch-episode-3/
image: /2010/04/4846.logo-powershell.png
categories:
  - Script
tags:
  - MS SQL Server 2005
  - PowerShell
  - vCenter

---
Dernier article là-dessus et on en parle plus (jusqu’à ce que je change d’avis). Dans l’article précédent, je vous indiquais mon désespoir quand j’ai découvert que je faisais tout mal [(lien mort, j'utilise Internet archive)](https://web.archive.org/web/20211207075523/https://www.databasejournal.com/features/mssql/article.php/3693606/Microsoft-Windows-PowerShell-and-SQL-Server-2005-SMO-150-Part-6.htm). En regardant de plus près, je me suis aperçu que ça ne marchait pas vraiment comme il le disait, surtout pour ce qui est des sauvegardes incrémentales, et je me suis empressé d’écrire une nouvelle version de mon script pour qu’il soit plus beau, plus fort, plus efficace...



Une petite note aussi, les problèmes que j’ai eu avec le script du monsieur de databasejournal est peut-être dû au fait que j’ai une version Express et non pas complète comme je le pensais au début.

En fait, quand vous faites un backup complète, un fichier .bak est créé, et celui ci est autosuffisant et peut être restauré facilement. Cependant, pour pouvoir utiliser les sauvegardes incrémentales, il faut que la sauvegarde soit faite dans le même fichier, qui est concaténé (en quelque sorte). Or, le script donné à la fin de l’article créé des backups .diff qui sont séparées de leur backup complète, que je n’ai pas réussi à réimporter avec MS SQL Server 2005 Express.

Pour ceux d’entre nous qui ont les mêmes problèmes que j’ai eus avec les « differential backups », voici un 
[nouveau script](misc/MSSQLBackup2.ps1) qui permet de faire proprement ce que je voulais faire depuis le début, c'est-à-dire:

* disposer d’un script qui automatise la sauvegarde de la base de donnée de mon vCenter (mais aussi de n’importe quelle autre base de données compatible MS SQL Server 2005)
* avoir la possibilité de faire des backups complètes, datées pour pouvoir être différenciées
* avoir la possibilité de faire des backups incrémentales
* toutes les opérations et éventuelles erreurs sont journalisées (ça se dit?)

Pour ce qui est des contrôles du script:

* dans le cas où une backup complète n’est pas trouvée, le script fait une backup complète plutôt qu’une incrémentale
* dans le cas où plusieurs backup complètes existent, la backup incrémentale se greffe sur la backup complète la plus récente (ça m’a paru assez logique comme façon de faire, mais vous n’êtes pas obligés d’être d’accord)

Il s’utilise de la façon suivante :

```
powershell.exe C:\Scripts\MSSQLBackup2.ps1 HOMESQLSERVER MyDB \\SERVER\BackupFolder FULL
powershell.exe C:\Scripts\MSSQLBackup2.ps1 HOMESQLSERVER MyDB C:\Backup DIFF
```


La première ligne exécute le script pour une backup complète de MyDB depuis l’ordinateur HOME (en local svp, je n'ai pas testé à distance, mais il doit y avoir des problèmes d’authentification) qui dispose d’un serveur SQLSERVER vers un dossier partagé BackupFolder sur le réseau par l’ordinateur SERVER. La seconde ligne fait plus ou moins là même chose (sauvegardé localement et pas dans un dossier partagé) mais avec une sauvegarde incrémentale.

Je suis vengé :-D

Internet 1 - Zwindler 1
