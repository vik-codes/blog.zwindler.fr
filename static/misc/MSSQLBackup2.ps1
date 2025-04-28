param (
  [string] $ServerName,
  [string] $DatabaseName,
  [string] $BackupFolder,
  [string] $BackupType
)

#Au cas où il reste une erreur dans $Error
$Error.clear()

$BackupLogPath = $DatabaseName+"-AutomatedBackup.log"
$CurrentDate = Get-Date -uformat "%d-%m-%Y"

#Création du dossier au cas où celui ci n'existe pas
#[System.IO.Directory]::CreateDirectory($BackupFolder) | out-null

#Déclaration des objets SMO
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | out-null
$ServerObject = New-Object "Microsoft.SqlServer.Management.Smo.Server" "$ServerName" 
$BackupObject = New-Object "Microsoft.SqlServer.Management.Smo.Backup"
$FileObject = New-Object "Microsoft.SqlServer.Management.Smo.BackupDeviceItem"

#Fonction de journalisation
Function PrintToLog([string] $message){
	$message | Out-file -append -filepath $BackupLogpath
}

PrintToLog "--- $CurrentDate ---"

#Paramétrage en fonction du type de backup demandé en argument
If($BackupType -eq "DIFF"){
	$BackupFiles = Get-ChildItem $BackupFolder -Include "$DatabaseName.*.bak"
	If(!$BackupFiles){
		#Il n'existe pas de fichier de Backup
		#On log l'évenement, et on passe en mode Full backup
		PrintToLog "Aucune sauvegarde complète trouvé, création d'une sauvegarde complète"			
		$BackupObject.Action = 'Database' 
		$LogBackupType="Sauvegarde complète"
		$BackupFileName = $DatabaseName+ "." + $CurrentDate + ".bak"
	}
	Else{
		$BackupObject.Incremental = 1
		$LogBackupType="Sauvegarde incrémentale"
		
		#Boucle de recherche de la backup la plus récente
		$LatestDate = "01/01/1601" -as [Datetime]
		Foreach($File in $BackupFiles){
			$FileDate = $File.name.split(".")[1] -as [Datetime]
			If($FileDate -gt $LatestDate){
				$LatestBackup = $File
			}
		}
		$BackupFileName = $LatestBackup.Name
	}
}
Else{
	#Full Backup par défaut
	$BackupObject.Action = 'Database' 
	$LogBackupType="Sauvegarde complète"
	$BackupFileName = $DatabaseName+ "." + $CurrentDate + ".bak"
}

$BackupFilePath = [System.IO.Path]::Combine($BackupFolder, $BackupFileName)

#Commande pour lancer la backup
$FileObject.DeviceType='File'
$FileObject.Name=$BackupFilePath
$BackupObject.Devices.Add($FileObject)
$BackupObject.Database=$DatabaseName
$BackupObject.SqlBackup($ServerObject)

#Dans le cas où ce n'est pas une backup incrémentale, on créer un fichier,
#donc on doit vérifier qu'il à bien été créé
If($BackupObject.Incremental -ne 1){
	If(Test-Path $BackupFilePath){
		PrintToLog "[Succès] $BackupFileName a été créé"	
	}
	Else{
		$ErrorMsg = "[Echec] $BackupFileName n'a pas pu être créé"
		Write-Host $ErrorMsg 
		PrintToLog $ErrorMsg 
	}	
}

#Vérification et journalisation des éventuelles erreur lors de l'exécution
If ($Error.count -ne 0){
	$ErrorMessage = "[Erreur] " + $Error[0]
	Write-Host $ErrorMessage
	PrintToLog $ErrorMessage 
	$Error.clear()
}
Else{
	PrintToLog("$LogBackupType dans le fichier $BackupFileName")
}

PrintToLog " "