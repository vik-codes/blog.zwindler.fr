#Ce script permet de sauvegarder la base de vCenter
#Il permet en plus de ne garder que certaines versions
#de la base, pour ne pas gaspiller trop d'espace disque

#Le script sera lancé chaque jour (tâche plannifiée)
#La politique du script est de garder la dernière 
#backup, plus celles des deux derniers "1er du mois"

$CompleteDate = Get-Date
$CurrentDateString = Get-Date -uformat "%d-%m-%Y"
$CurrentDate = Get-Date $CurrentDateString

$BackupFolder = "CHEMIN_VERS_REPERTOIRE_DE_BACKUP"
$BackupFileName = "AutomatedBackup.$CurrentDateString.bak"
$BackupFilePath = "$BackupFolder\$BackupFileName"
$BackupLogPath = "Backup.log"

Out-File -append $BackupLogPath -inputobject "--- $CompleteDate ---"

#Ligne de commande pour lancer la backup
$BackupProgramPath = "C:\Program Files\Microsoft SQL Server\90\Tools\Binn\sqlcmd.exe"
$Success = & $BackupProgramPath -S NOM_ORDINATEUR\NOM_SERVEUR_BDD -Q "BACKUP DATABASE NOM_BDD TO DISK = '$BackupFilePath' WITH INIT, NAME = 'Sauvegarde automatique de la base de données', STATS = 1" | Select-String -pattern "BACKUP DATABASE"

#Controle du succès de l'execution, on vérifie que le 
#fichier backup existe
Get-ChildItem -path $BackupFilePath > $null

If ($Error.count -ne 0){
	$ErrorMessage = "Erreur : " + $Error[0]
	Write-Host $ErrorMessage
	Out-File -append -filepath $BackupLogPath -inputobject $ErrorMessage 
	$Error.clear()
}
Else{
	Out-File -append -filepath $BackupLogPath -inputobject "$BackupFileName a été créé
    =>$Success"
	
	#Nettoyage de précédentes backups après la nouvelle
	#Récuperation de la liste des fichiers backup
	#Puis leur date de création associée
	$list = Get-ChildItem $BackupFolder -name -Include AutomatedBackup.*.bak
	For($i=0; $i -lt $list.count;$i++)
	{
		$FileName = $list[$i]
		$FileDate = $FileName.split(".")[1] -as [Datetime]
		If($CurrentDate.Day -eq 1){
		#Si on est le premier du mois, on doit supprimer 
		#les sauvegarde de la veille et celle datant 
		#d'il y a plus de 2 mois
			If(($FileDate.addDays(1) -eq $CurrentDate) -or ($FileDate.addMonths(2) -lt $CurrentDate)){
				Remove-Item "$BackupFolder\$FileName"
				Out-File -append -filepath $BackupLogPath -inputobject "$FileName a été supprimé"
			}
		}
		ElseIf($CurrentDate.Day -ne 2){
		#Ici on ne supprime que le fichier de la veille
			If($FileDate.addDays(1) -eq $CurrentDate){
				Remove-Item "$BackupFolder\$FileName"
				Out-File -append -filepath $BackupLogPath -inputobject "$FileName a été supprimé"
			}
		}
		#Sinon, on ne fait rien, car il ne faut pas 
		#supprimer celui de la veille
	}
}
Out-File -append -filepath $BackupLogPath -inputobject " "