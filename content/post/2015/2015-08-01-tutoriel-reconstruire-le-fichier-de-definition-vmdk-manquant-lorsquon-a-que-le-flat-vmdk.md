---
title: '[Tutoriel] Reconstruire le fichier de définition « .vmdk » manquant lorsqu’on a que le « -flat.vmdk »'
authors:
  - zwindler
type: post
date: 2015-08-01T10:30:48+00:00
url: /2015/08/01/tutoriel-reconstruire-le-fichier-de-definition-vmdk-manquant-lorsquon-a-que-le-flat-vmdk/
image: /2015/07/vmware2.png
categories:
  - Stockage
  - systeme
tags:
  - ESX
  - ESX(i)
  - lsi
  - SCSI
  - Thin provisioning
  - tutoriel
  - virtualdev
  - VMDK
  - vmkfstools
  - VMware
  - vmx

---
## Introduction de principe sur les disques durs virtuels par VMware

Quite à enfoncer des portes ouvertes, les disques virtuels chez VMware ont l’extension **.vdmk**. Mais en vrai, il y a deux types de fichiers VMDK et chaque disque dur virtuel VMware dispose **des deux** fichiers pour fonctionner :

  * le fichier contenant les données brutes, avec comme nom **mavm_X-flat.vmdk**
  * un fichier de configuration en mode texte avec des informations sur l'emplacement des données, le contrôleur à utiliser, la taille, ... et nommé **mavm_X.vmdk**

_Généralement_, les fichiers VMDK sont nommés comme leur VM et un indice (X) apparaît quand il y en a plusieurs. Cependant, ces fichiers peuvent être renommés pour placés dans d’autres dossiers et fausser la numérotation donc ne prenez pas les informations fournies par le nom du fichier pour argent comptant.

## Récupérer les informations nécessaires

Au même titre que perdre le fichier **-flat** qui contient les données serait problématique pour le fonctionnement de votre VM, la perte du fichier de définition est assez fâcheux. Le disque n’est tout simplement pas utilisable car l’ESXi ne sait pas interpréter le fichier **-flat** seul.

Cependant, on peut le reconstruire. Ouf !

D’ailleurs, on peut reconstruire le fichier **-flat.vmdk** aussi, mais sans les données bien entendu. Du coup je trouve que c’est quand même nettement moins intéressant que le contraire. Je ferai peut être quand même un article là dessus.

La première chose à faire est de déterminer le type de contrôleur virtuel que la machine virtuelle utilise pour se connecter au disque.

C’est très important et il peut parfois y en avoir plusieurs sur une même VM. On trouve ces informations dans le fichier de définition de la VM (**.vmx**) ou directement depuis la console VMware.

En règle générale, ce paramètre est souvent laissé par défaut et dans mon cas, la VM utilisait un **lsilogic** en position **0** (scsi0). Le disque était lui branché sur l'emplacement **0** du contrôleur, aussi visible dans la console comme **0:0**.

```
scsi0.present = "true"
scsi0.sharedBus = "virtual"
scsi0.virtualDev = "lsilogic"
```

L’étape d’après consiste à savoir quelle est la taille du disque virtuel. En se connectant en SSH sur l’ESXi qui a accès au datastore, vous pouvez retrouver simplement cette information via un _ls -l_ qui vous donnera la taille totale que peut avoir le disque.

```
# ls -l mavm-flat.vmdk
-rw------- 1 root root 1036160860160 Dec 11 12:30 mavm-flat.vmdk
```


Maintenant qu’on dispose de toutes les informations nécessaires, on va recréer un disque virtuel vierge temporaire. On récupérera et adaptera son fichier **.vmdk** pour pouvoir réutiliser notre fichier **-flat.vmdk**.

```
# vmkfstools -c 1036160860160 -a lsilogic -d thin temp.vmdk
```

La commande devrait créer deux fichiers temp.vmdk et temp-flat.vmdk. Pour plus d’options concernant la commande, je vous invite à lire le kb suivant : kb.vmware.com (lien mort)

## Thin provisioning ou pas ?

Vous avez peut être noté le _-d thin_ dans la commande un peu plus haut. Tous mes disques sont en Thin Provisioning car ça permet de ne consommer que l’espace réellement nécessaire. VMware a prouvé que les performances étaient similaire à l’allocation normale du disque à sa création et dans la majorité des cas c’est donc 100% gagnant.

Cependant, dans le cas où votre disque n’est pas en Thin provisioning, il y a quand même intérêt -pour le disque temporaire- à le créer avec l’option _-d thin_. Comme nous n’allons réutiliser que le fichier de définition **.vmdk**, le fichier **temp-flat.vmdk** aurait mis du temps à se construire, et aurait consommé de l’espace disque pour rien. J’indiquerai comment corrigé le tir dans la partie suivante.

## Paramétrage du fichier reconstruit

On peut supprimer le fichier **temp-flat.vmdk** (le fichier de données donc) qui n’est plus nécessaire, et renommer le fichier **temp.vmdk** avec le nom correspondant au fichier manquant.

```
# rm -i temp-flat.vmdk
# mv -i temp.vmdk mavm.vmdk
```

A l’aide d’un éditeur de texte (soit via **vi** si vous êtes directement sur l’ESXi soit vous le récupérez pour l’éditer sur votre poste), on va modifier les sections qui ne correspondent pas encore à notre disque **-flat** :

  * vérifiez que la taille annoncée (en nombre de blocs de 512 octets, donc multiplier par 2 le nombre obtenu plus haut) sous #_Extent Description_
  * modifiez le nom du fichier après VMFS pour qu’il corresponde au fichier **-flat**
  * adaptez si besoin le contrôleur (si vous n’avez pas rentré le bon lors du lancement de la commande plus haut)
  * supprimez la ligne _ddb.thinProvisioned = « 1 »_ si le fichier **-flat.vmdk** n’était pas en thin provisioning initialement.

```
[...]
# Extent description
RW 2072321720320 VMFS "mavm-flat.vmdk"
[...]
ddb.adapterType = "lsilogic"
ddb.thinProvisioned = "1"
```

Vous devriez avoir un disque virtuel de nouveau fonctionnel.

## Bonus track : vérifier l’intégrité du « disk chain »

Vous pouvez vérifier que le fichier .vmdk correspond au fichier -flat avec les commandes suivantes :

Pour ESXi 3.5/4.x:

```
# vmkfstools -q mavm.vmdk
  mavm.vmdk is not an rdm
```


Pour ESXi 5.x et 6.x :

```
# vmkfstools -e mavm.vmdk
  Disk chain is consistent
```
