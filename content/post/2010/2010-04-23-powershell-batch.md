---
title: 'SQL Server 2005 : PowerShell > Batch'
authors:
  - zwindler
type: post
date: 2010-04-23T17:38:58+00:00
url: /2010/04/23/powershell-batch/
image: /2010/04/4846.logo-powershell.png
categories:
  - Script
tags:
  - Batch
  - MS SQL Server 2005
  - PowerShell
  - VBScript
  - vCenter

---
Il y a quelques jours, j’ai commencé la rénovation de notre vCenter (il tournait en machine virtuelle avec très peu de RAM sur un vieux VMWare server 2.0, lui même hébergé par un PC toussotant).

Outre les opérations de migration, je me suis penché sur les conséquences de la perte de ce vCenter, et donc les moyens à mettre en œuvre pour s’assurer de vite pouvoir remettre le système en marche. Si on met de côté le débat machine physique/machine virtuelle pour héberger le vCenter, la communauté semblait unanime sur le fait que pour le vCenter, les 2 choses importantes à sauvegarder sont les fichiers de licences et la base de données.

Dans notre cas, la base de données est simplement un Microsoft SQL Server 2005 (configuration des plus classiques). La version complète du SQL Server Management Studio permet en quelques clics de programmer une sauvegarde. N’étant pas capable de mettre la main sur les fichier d’installation de la version complète du Manager, j’ai cherché une solution alternative.

J’ai trouvé assez facilement un script batch qui utilise sqlcmd.exe, un programme fournit dans toutes les versions de SQL Server 2005 (même la version Express) et qui est en fait un interpréteur de requête T-SQL (si j’ai bien compris). La solution pour automatiser la sauvegarde de la base de données du vCenter (où de n’importe quelle autre base SQL Server d’ailleurs) consiste simplement à créer une tâche planifiée qui lance ce script aussi souvent que vous le souhaitez.

J’aurai pu m’arrêter là, mais pour plusieurs raisons, j’ai préféré réécrire ce script :

  * D’abord, batch, ça commence à dater un peu, il serait temps de passer à autre chose!
  * Ensuite, je ne suis pas du tout à l’aise avec les scripts batch. Comme je voulais améliorer ce script, cela impliquait que je m’y mette sérieusement, et je n’avais pas vraiment envie :-p
  * Enfin, certaines actions relativement complexe en batch sont grandement simplifiées par les usines à gaz que sont VBScript et PowerShell.

Les deux problèmes majeurs de ce script batch sont le gaspillage d’espace disque et l’absence de contrôle sur ce qui est fait. Certes, on vérifie certaines choses pour éviter des erreurs bêtes lors de l’exécution, mais bon, j’en attendais un peu plus.

J’ai donc sorti mon interpréteur PowerShell, un papier et un crayon, et je me suis créé un petit script qui permet de sauvegarder une base de données MS SQL exactement de la même manière, mais également qui ne garde que les fichiers backups de la veille et des 2 derniers « 1er jour du mois », qui vérifie que le fichier a bien été copié, et qui journalise le tout.

Ainsi, pas de gaspillage avec 200 versions pratiquement similaires de la base de données (le vCenter n’en a pas besoin, et on pourrait même se contenter d’une seule backup du mois dernier), et un contrôle un peu plus « propre » de ce qui se passe lors de l’exécution de la tâche planifiée.

Alors forcément, c’est sûr que c’est loin d’être aussi bien qu’une sauvegarde incrémentale planifiée par un outil tiers ou par le SQL Server Management Studio (je ne sais pas si il le fait, mais j’ai du mal à imaginer que non). C’est sûr aussi qu’on pourrait contrôler de façon encore plus complète tout ce qui se passe lors de l’exécution du script (plutôt que simplement vérifier que le fichier existe), notamment en traitant les éventuelles erreurs renvoyées par SQLCMD (qui ne sont pas vraiment prises en compte).

J’ai voulu écrire rapidement un petit script, et je n’ai pas besoin de plus que ce que j’ai déjà fais. On ne peut pas tout gérer non plus...

* [le lien vers le batch](/misc/MSSQLBackup.bat)
* [le lien vers le script powershell](/misc/MSSQLBackup.ps1)
