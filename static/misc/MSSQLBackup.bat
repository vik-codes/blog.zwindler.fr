SET J=%date:~-10,2% 
SET A=%date:~-4% 
SET M=%date:~-7,2% 
SET H=%time:~0,2% 
SET MN=%time:~3,2% 
SET S=%time:~-5,2% 

IF "%time:~0,1%"==" " SET H=0%HEURE:~1,1% 

SET REPERTOIRE=CHEMIN_VERS_REPERTOIRE_DE_BACKUP

SET FICHIER=%REPERTOIRE%\NOM_BDD_%J%_%M%_%A%_A_%H%_%MN%_%S%.bak 

IF NOT exist "%REPERTOIRE%" md "%REPERTOIRE%" 

cd C:\Program Files\Microsoft SQL Server\90\Tools\Binn 

sqlcmd -S NOM_ORDINATEUR\NOM_SERVEUR_BDD -Q "BACKUP DATABASE NOM_BDD TO DISK = N'%FICHIER%' WITH INIT, NAME = N'Sauvegarde automatique de la base de données', STATS = 1" 

pause