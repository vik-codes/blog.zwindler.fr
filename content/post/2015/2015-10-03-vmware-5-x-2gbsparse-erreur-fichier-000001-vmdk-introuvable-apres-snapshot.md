---
title: 'VMware 5.X + 2GBSparse : Erreur fichier …000001.vmdk introuvable après snapshot'
authors:
  - zwindler
type: post
date: 2015-10-03T10:30:52+00:00
url: /2015/10/03/vmware-5-x-2gbsparse-erreur-fichier-000001-vmdk-introuvable-apres-snapshot/
image: /2015/09/vmware.png
categories:
  - Virtualisation
tags:
  - -000001.vmdk
  - 2GB Sparse
  - clone
  - consolider
  - ESXi 5.X
  - ESXi 6.X
  - fichier introuvable
  - msg.disklib.FILENOTFOUND
  - Snapshot
  - vCenter
  - VMware

---
## Problème ?

Récemment je me suis fais une petite frayeur alors que j’effectuais une opération de maintenance en apparence banale : cloner une machine virtuelle.

Lors d’un clone de machine virtuelle à chaud, le serveur vCenter déclenche un snapshot temporaire pour pouvoir disposer d’un état au repos du disque dur à cloner. Et c’est pendant cette étape que j’ai reçu une erreur qui a non seulement fait planter mon clone, mais m’a aussi bloqué ma machine virtuelle.

> Une erreur s’est produite lors de la consolidation des disques : msg.disklib.FILENOTFOUND.

![](/2015/09/sparse.png)

Pire, impossible de relancer la machine virtuelle qui fonctionnait pourtant bien jusqu’à présent.

![](/2015/09/sparse2.png)

Le client m’indique de consolider les disques durs, mais quand j’ai essayé de consolider les disques durs, j’ai reçu l’erreur suivante :

![](/2015/09/sparse3.png)

On se mord la queue, là !

A partir de ce moment là, plus aucune opération sur la machine virtuelle ne fonctionnait (clone, snapshot, démarrage, consolidation, etc) et un vMotion ou storage vMotion n’avait aucun effet, éliminant les problèmes sur le matériel physique.

## Cause

Ce n’est pas la première fois que je « râle » contre le niveau de détail, l’imprécision et la non-pertinence des erreurs remontées par VMware. Et visiblement ce ne sera pas la dernière !

Car en fait, il ne s’agit pas d’un bug à proprement parler. En fait c’est normal, mais vous ne le savez pas.

La machine virtuelle ne peut pas être clonée car les disques VMDK sont au format **2Gb Sparse qui ne sont plus supportés depuis la version 5.0**. Tout simplement.

Dans mon cas, cette machine provient d’un prestataire qui nous l’a livrée avec des paramètres historiques, notamment ce format de VMDK non supporté.

Cependant, lors de l’import sur notre Infrastructure, à aucun moment VMware ne nous a prévenu que ce type de VMDK n’était plus supporté.  
Pire, la machine virtuelle a fonctionné correctement pendant plusieurs jours, puis s’est bloquée sans prévenir pendant une banale opération de routine.

Et donc avec un message d’erreur trompeur puisqu’il ne s’agit pas d’un fichier manquant, juste d’un disque plus supporté !

## Solution !

Heureusement le KB VMware apporte la solution et on peut régler le problème sans trop de difficultés.

* kb.vmware.com (lien mort comme tous les KB de VMware)

On vérifie d’abord qu’il s’agit bien d’un problème lié à ce type de disque (voir **createType**)

```
/vmfs/volumes/502c61d6-jibber-jabber-uuid/maVM # cat maVM-2gbsparse.vmdk
# Disk DescriptorFile
version=1
CID=d20eb8ad
parentCID=ffffffff
isNativeSnapshot="no"
createType="twoGbMaxExtentSparse"

# Extent description
RW 207618048 SPARSE "maVM-s001.vmdk"

# The Disk Data Base
#DDB

ddb.adapterType = "ide"
ddb.encoding = "UTF-8"
ddb.geometry.cylinders = "12924"
ddb.geometry.heads = "255"
ddb.geometry.sectors = "63"
ddb.longContentID = "c81d0031d071fb58a1bb6317d20eb8ad"
```


![](/2015/09/sparse4.png)

La manipulation consiste alors à transformer via la commande **vmkfstools** directement sur l’ESXi le disque au format 2GBSpare vers un format autorisé (_Thin provisioning_ dans mon exemple)

```
vmkfstools -i maVM-2gbsparse.vmdk ../maVM/maVM-thin.vmdk -d thin
```


Une fois que c’est fait, on peut supprimer le disque présent dans la configuration de la machine virtuelle et le remplacer par notre nouveau disque _maVM-thin.vmdk_.

A partir de là, elle devrait redémarrer correctement et peut être clonée/snapshotée/... Merci VMware.

#OuPas
