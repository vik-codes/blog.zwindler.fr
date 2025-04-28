---
title: '[Tutoriel] Récupérer l’espace non réclamé via l’API VAAI de VMware et l’instruction UNMAP'
authors:
  - zwindler
type: post
date: 2016-03-19T11:30:55+00:00
url: /2016/03/19/1811/
image: /2016/02/VAAI_1.png
categories:
  - Stockage
  - Système
tags:
  - Datacore
  - datastore
  - EMC²
  - Synology
  - UNMAP
  - VAAI
  - VMFS
  - VMware

---
## Contexte

La plupart des solutions de stockages estampillés Entreprise sont certifiés pour fonctionner de manière optimisée avec VMware, via l’API VAAI (baies EMC², HP, etc, mais aussi des solutions logicielles comme Datacore et même certains NAS Synology/QNAP/...).

Cette API permet entre autre d’accélérer les performances de certaines opérations d’exploitation, comme par exemple la copie de machines virtuelles ou le déploiement de templates. Elle permet également à VMware d’indiquer au stockage (à la baie de disques par exemple) qu’un Datastore (un ou plusieurs LUN) dispose de blocs qui ont été libérés.

Ceci est particulièrement utile dans le cas où le LUN est en Thin Provisioning, car dans ce cas là, de l’espace précédemment consommé peut être libéré côté baie via l’instruction UNMAP.

## Exemple

On dispose d’un LUN de 500 Go en Thin Provisioning, présenté à un serveur VMware. On a créé un Datastore dessus et ajouté un VMDK qui prend 100 Go. Comme le LUN est en Thin provisioning, seul 100 Go (environ) est réellement utilisé sur la baie de disques.

![](/2016/02/VAAI_1.png)

Imaginons maintenant que le VMDK est supprimé du Datastore. Côté VMware, le Datastore sera bien vu comme vide car le VMDK a été détruit. Par contre côté baie de disques, le LUN fait toujours 100 Go car la baie de disques n’est pas « au courant » de la libération de l’espace pris par le VMDK.

![](/2016/02/VAAI_2.png)

On peut se connecter sur le serveur VMware pour réclamer cet espace disque en envoyant à la baie de disques une commande VAAI UNMAP.

![](/2016/02/VAAI_3.png)

## Procédure de réclamation de l’espace disque

Pour une baie EMC de type VNX 5X00 et un LUN de 1500 Go. Le LUN fait 1460 Go sur la baie, pourtant beaucoup d’espace a été libéré sur le Datastore.

![](/2016/02/vmware_unmap1-1.png)

![](/2016/02/vmware_unmap2-1.png)

En se connectant en SSH sur un VMware, on lance la commande suivante :

```
esxcli storage vmfs unmap -l MONDATASTOREANETTOYER
```


Au bout que quelques minutes (peut durer longtemps si il y a beaucoup d’espace à réclamer), l’espace commence à se libérer :

![](/2016/02/vmware_unmap3-1.png)

## Plus d’information sur le site de VMware

* kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2057513 (lien mort, comme tout chez VMware)
* kb.vmware.com/selfservice/search.do?cmd=displayKC&docType=kc&docTypeID=DT\_KB\_1_1&externalId=2014849 (lien mort, comme tout chez VMware)
* kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2057513 (lien mort, comme tout chez VMware)
* [lien mort, j'utilise Internet Archive](https://web.archive.org/web/20160629041847/http://blog.ganser.com/539)

