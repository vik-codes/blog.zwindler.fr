---
title: Sauvegardez vos ESXi 6.5 sans licence avec GhettoVCB
authors:
  - zwindler
type: post
date: 2018-01-09T12:45:37+00:00
url: /2018/01/09/sauvegardez-vos-esxi-6-5-licence-ghettovcb/
image: /2017/12/Consolidation_Backup.png
categories:
  - DIY
  - Stockage
  - systeme
  - Virtualisation
tags:
  - GhettoVCB
  - github
  - restauration
  - sauvegarde
  - virtuallyGhetto
  - VMware

---
## GhettoVCB, depuis VMware Infrastructure 3, toujours compatible !

En 2010, [un de mes tout premiers articles sur ce blog parlait d’un script s’appelant GhettoVCB][1]. Il permettait de réaliser des sauvegardes à chaud sur des ESXi, SANS vCenter. Et c’est là toute la nuance, car si toutes les solutions de sauvegardes d’entreprises savent aujourd’hui sauvegarder des machines virtuelles VMware, elles se basent toutes sur un API (historiquement **VCB** pour VMware Consolidated Backup).

Or, [l’usage l’API de sauvegarde][2] (VCB, puis VADP et maintenant VMware vSphere Storage APIs – Data Protection) est conditionnée à la présence d’une licence ! Impossible d’utiliser ces outils avec un ESXi « gratuit » (free).

> What licensing is required to use VMware vSphere Storage APIs – Data Protection?  
> Data Protection APIs are included with all licensed vSphere editions.

Ce script ([mis en ligne depuis 2008 !][3]) se base directement sur les binaires présents sur l’OS, sans passer par l’API VCB. Il fait donc pratiquement la même chose, mais gratuitement. Inutile de vous dire que ce script est très populaire parmi les bidouilleurs au budget limités et souhaitant quand même faire des sauvegardes.

Je vous met aussi [le lien vers le post historique][3].

## Installation

Historiquement, en guise « d’installation », il fallait simplement copier le script dans le répertoire de son choix. Aujourd’hui, c’est un peu plus « propre » puisque l’auteur a mis à disposition un VIB qui permet d’installer sur l’ESXi via un package. Les sources ont été hébergées [sur Github][4].

Télécharger le fichier depuis le Github (lien mort), puis le copier en SSH/SCP/SFTP dans **/tmp**. Se connecter en SSH et installer la VIB :

```
esxcli software vib install -v /tmp/ -f
```

Note : maintenant il faut le build soi même cf https://github.com/lamw/ghettoVCB/blob/master/build/README.md


Pas besoin de rebooter avec cette VIB (simple copie du script). E-Z.

## Mise en place de la sauvegarde

La documentation n’a pas été reportée sur le Github malheureusement, mais elle est toujours disponible sur [le site historique de la communauté VMware][3].

Dans l’exemple suivant, on va, configurer le datastore **VMFS_BCK** comme destination de notre sauvegarde, sélectionner les VMs qu’on souhaite sauvegarder, et planifier (enfin... crontab quoi) nos sauvegardes. Youhou !

Sauf erreur de ma part, la documentation n’indique pas les chemins des fichiers scripts et de configuration. Avant c’était plus simple, vous téléchargiez tout et vous le mettiez dans le dossier que vous vouliez. Maintenant, la VIB dépose le fichier de configuration principal, un template de sauvegarde et un autre de restauration dans **/etc/ghettovcb/**. Les scripts sont quant à eux installés dans **/opt/ghettovcb/bin/**.

Se connecter en SSH sur le serveur VMware concerné. Voici un exemple de configuration de sauvegarde :

```
cd /etc/ghettovcb/
vi ghettoVCB.conf
  VM_BACKUP_VOLUME=/vmfs/volumes/VMFS_BCK/backup
  DISK_BACKUP_FORMAT=thin
  VM_BACKUP_ROTATION_COUNT=3
  POWER_VM_DOWN_BEFORE_BACKUP=0
  ENABLE_HARD_POWER_OFF=0
  ITER_TO_WAIT_SHUTDOWN=3
  POWER_DOWN_TIMEOUT=5
  ENABLE_COMPRESSION=0
  VM_SNAPSHOT_MEMORY=0
  VM_SNAPSHOT_QUIESCE=0
  ALLOW_VMS_WITH_SNAPSHOTS_TO_BE_BACKEDUP=0
  SNAPSHOT_TIMEOUT=15
  EMAIL_ALERT=0
  EMAIL_LOG=0
  EMAIL_SERVER=[@IP]
  EMAIL_SERVER_PORT=25
  EMAIL_DELAY_INTERVAL=1
  EMAIL_TO=ghettovcb@zwindler.fr
  EMAIL_ERRORS_TO=
  EMAIL_FROM=alert_ghettoVCB@zwindler.fr
  WORKDIR_DEBUG=0
  VM_SHUTDOWN_ORDER=
  VM_STARTUP_ORDER=
```


Ce fichier va nous permettre de configurer toutes les valeurs « par défaut » lors de nos sauvegardes.

Pour éviter tout souci, vérifiez qu’il y a bien de l’espace disponible sur le datastore choisi et que le chemin existe ;-).

```
ls /vmfs/volumes/VMFS_BCK/backup
```


Chacune des valeurs contenues dans la configuration peuvent être surchargées par le fichier de sauvegarde que nous allons créer. Dans cet exemple je ne modifie rien mais là c’est à vous de voir ! Ici, j’ajoute simplement la VM à une liste des machines virtuelles à sauvegarder :

```
vi /etc/ghettovcb/vm_backup_list
  ma_vm_a_sauvegarder
```


On commence par lancer le script à la main pour voir en live si ça fonctionne :

```
/opt/ghettovcb/bin/ghettoVCB.sh -f /etc/ghettovcb/vm_backup_list -g /etc/ghettovcb/ghettoVCB.conf
```


Une fois que le script rend la main, vérifier dans le dossier de destination que la sauvegarde s’est bien réalisée. Il devrait contenir un dossier daté du jour et tous les fichiers de la VM.

```
cd /vmfs/volumes/VMFS_BCK/backup
```


Pour faire simple, vous pouvez commencer par une sauvegarde toutes les semaines (dimanche minuit) :

```
crontab -e
	#Sauvegarde hebdo des VMs critiques
	00 0 * * 0 /opt/ghettovcb/bin/ghettoVCB.sh -f /etc/ghettovcb/vm_backup_list -g /etc/ghettovcb/ghettoVCB.conf
```


## Restauration

Nous allons jouer ici le scénario d’une restauration (**ma\_vm\_a_restaurer**) située sur le datastore **/vmfs/volumes/VMFS**. Il faut donc :

  * Mettre de côté la machine HS
  * Trouver la sauvegarde que l’on souhaite restaurer
  * La restaurer à l'emplacement initial de la VM

### Retirer la VM à restaurer de l’inventaire et garder une copie au cas où

```
vmware-cmd -s unregister ma_vm_a_restaurer
mv /vmfs/volumes/VMFS/ma_vm_a_restaurer /vmfs/volumes/VMFS/ma_vm_a_restaurer.ko
```


### Retrouver la sauvegarde qu’on souhaite restaurer

```
cd /vmfs/volumes/VMFS_BCK/backup/ma_vm_a_restaurer
ls -l
	drwxr-xr-x 1 root root 840 Sep  3 14:12 ma_vm_a_restaurer-2032-09-03_00-00-00
```


### Réaliser la restauration en elle même

Ici, on fait une copie du template de restauration et on y modifie les variables comme le chemin souhaité et le datastore cible. On termine l’opération en exécutant le script **ghettoVCB-restore.sh**

```
cd /etc/ghettovcb/
cp ghettoVCB-restore_vm_restore_configuration_template ghettoVCB-restore_ma_vm_a_sauvegarder
vi ghettoVCB-restore_ma_vm_a_restaurer
  /vmfs/volumes/VMFS_BCK/backup/ma_vm_a_restaurer/ma_vm_a_restaurer-2032-09-03_00-00-00;/vmfs/volumes/VMFS;3
/opt/ghettovcb/bin/ghettoVCB-restore.sh -c /etc/ghettovcb/ghettoVCB-restore_ma_vm_a_restaurer
```


### Finaliser la restauration

Une fois la recopie de la sauvegarde terminée, la VM devrait réapparaitre (automatiquement) dans l’inventaire de votre serveur VMware (le script effectue le _register_vm_).

Démarrer la VM. Si tout a fonctionné, la VM devrait rester bloquée et c’est « normal ».

VMware va détecter qu’il y a eu une opération et vous posera la question pour savoir si c’est une copie ou déplacement. Même si dans la majorité des cas ça ne devrait pas avoir d’impact, il est préférable de répondre « I moved it »/ »Je l’ai déplacé ».

Dans le cas contraire, VMware modifiera une partie de la VM, notamment son adresse MAC, ce qui n’est pas forcément souhaitable dans le cadre d’une restauration. « I moved it » permet de garder la VM telle quelle.

Enjoy !

 [1]: /2010/06/09/sauvegarder-automatiquement-et-proprement-ses-vms-sur-esxi/
 [2]: https://kb.vmware.com/s/article/1021175
 [3]: https://communities.vmware.com/docs/DOC-8760
 [4]: https://github.com/lamw/ghettoVCB