param(
	$PhysDiskNumber = 1,
	$DestDir = "C:\VMFSDump",
	$VMFSDriverPath = 'C:\Program Files\vmfs_driver\fvmfs.jar',
	$IncludedFiles = (".vmdk",".nvram",".vmsd",".vmx",".vmxf",".log")
)

#This command gets every directory and every file within the vmfs disk
$DirOutput = java -jar $VMFSDriverPath \\.\PhysicalDrive$PhysDiskNumber dirall /

#Now we get the directory in order to reconstruct the directory tree at destination
$DirLines = $DirOutput | select-string -pattern "dir"
#TODO!!!

#Files are copied
$Files = [regex]::split($DirOutput, " ") | select-string -pattern $IncludedFiles
foreach($File in $Files){
	$Temp = $File -replace "/", "\"
	$FileDestination = $DestDir+$Temp
	java -jar $VMFSDriverPath \\.\PhysicalDrive$PhysDiskNumber filecopy $File $FileDestination
}