---
title: '[Tutoriel] Installation d’Oracle VM for x86 – partie 2'
authors:
  - zwindler
type: post
date: 2016-10-18T12:00:57+00:00
url: /2016/10/18/tutoriel-installation-doracle-vm-for-x86-part-2/
image: /2016/10/oracle-vm.png
categories:
  - Virtualisation
tags:
  - machine virtuelle
  - Oracle VM
  - Oracle VM Manager
  - OVMM
  - RHEL
  - Windows

---
Cet article fait suite à l’article [**Installation d’Oracle VM for x86 - partie 1**](/2016/10/11/tutoriel-installation-doracle-vm-for-x86-part-1/) dans lequel j’ai introduis Oracle VM et installé la console de management Oracle VM Manager. Je vous conseille de commencer par là ;-).

## Connexion du serveur Oracle VM avec la console OVMM

Maintenant que la console OVMM est opérationnelle et qu’on a pu s’y connecter, on remarque que les menus sont assez intuitifs bien qu’un peu austères !

Un onglet Health donne l’état général de la plateforme, puis les autres onglets permettent de configurer les différents aspects attendus d’une console d’administration de virtualisation x86.

La première étape pour nous est donc bien entendu d’ajouter dans OVMM le serveur Oracle VM préalablement installé, au même titre qu’on pourrait le faire avec un ESXi dans un vCenter.

![](/2016/10/oraclevm1.png)

Hormis les icônes pas forcément très parlantes, le menu de « découverte » de nouveaux serveurs est très simple. On a juste besoin de l’IP et du compte OVM Agent créé lors du déploiement de l’ISO d’installation.

![](/2016/10/oraclevm2-1.png)

En bas de l’écran, un bandeau vous donne l’état des dernières opérations déclenchées sur le cluster.

![](/2016/10/oraclevm3-1.png)

![](/2016/10/oraclevm4-1.png)

Un bref coup d’œil permet de voir que le serveur est bien ajouté. Des informations sur sa configuration s’affichent.

## Créer un groupe de serveurs « server pool »

Vous aurez peut être remarqué que votre serveur de virtualisation a été ajouté dans le groupe de serveurs « Unassigned ». Intellectuellement ça me gène, et j’ai donc voulu créer un groupe de serveurs, pour « faire propre ».

Au delà de ça, c’est notamment via la création de ces groupes (clusters dans VMware) que l’on peut gérer la haute disponibilité et les clusters de machines. C’est donc plutôt important ;-).

![](/2016/10/oraclevm4-1.png)

Ce groupe peut se créer via l’icône située juste à droite de celle sur laquelle nous avons cliqué pour « découvrir » le serveur Oracle VM.

![](/2016/10/oraclevm20.png)

![](/2016/10/oraclevm21.png)

![](/2016/10/oraclevm22.png)

![](/2016/10/oraclevm23.png)

Cependant, lorsque j’ai tenté de créer mon groupe de serveurs, j’ai reçu l’erreur suivante :

```
OVMAPI_4010E Attempt to send command: create_server_pool to server: lab01 failed. 
OVMAPI_4004E Sync command failed on server: x.x.x.32. 
Command: create_server_pool, Server error: org.apache.xmlrpc.XmlRpcException: <type 'exceptions.Exception'>:
Invalid hostname resolution: lab01 -> 127.0.0.1 [Wed Jul 20 16:30:40 CEST 2016]
```


Lors de l’installation automatique de l’ISO Oracle VM, le hostname lab01 a été ajouté par défaut dans le fichier **/etc/hosts**. Or, ceci pose problème.

Connectez vous en SSH sur le serveur et retirez le hostname (ici lab01) du fichier **/etc/hosts** :

```
vi /etc/hosts
127.0.0.1 lab01 localhost localhost.localdomain localhost4 localhost4.localdomain4
```


## Création de pools de stockage

La seconde opération consiste à ajouter du stockage au cluster.

Avec Oracle VM, on peut utiliser du stockage local via des disques inutilisés. La procédure est détaillée à [l’adresse suivante](https://docs.oracle.com/cd/E26996_01/E18549/html/CHDIGACB.html).

On peut également découvrir des cibles iSCSI ou éventuellement utiliser l’espace disponible sur le filesystem local. Pour ce dernier choix, l’espace ne sera cependant bien entendu uniquement visible depuis le serveur local uniquement.

Pour l’exemple, j’ai créé un disque de test de 200 Go sur un NAS Windows.

La procédure est la suivante. On commence par ouvrir l’onglet « Storage ». Dans SAN Servers, il n’y a encore aucun serveur déclaré. Au même titre que pour le serveur de virtualisation, il y a un bouton « Discover SAN Server ».

![](/2016/10/oraclevm5.png)

![](/2016/10/oraclevm6.png)

![](/2016/10/oraclevm7.png)

On peut déclarer un ou plusieurs hôtes, avec ou non de l’authentification. J’ai rarement vu des contextes où l’authentification CHAP (côté client ou serveur) était activée, mais je trouve ça bien en production. Pour autant, dans le cas du PoC je n’en ai pas mis.

![](/2016/10/oraclevm8.png)

Editer les access groups

![](/2016/10/oraclevm12.png)

![](/2016/10/oraclevm11.png)

Et enfin, on ajoute les serveurs qui peuvent avoir accès aux périphériques de stockage. Ici lab01.

![](/2016/10/oraclevm9.png)

Cliquer sur Finish pour valider.

Dans mon cas, juste avec la configuration de cet article, je suis tombé sur l’erreur suivante. A l’écran d’avant j’avais loupé la modification des access groups et en particulier l’onglet storage initiators. Si vous avez une erreur, c’est surement le même problème.

![](/2016/10/oraclevm10.png)

Le stockage nouvellement intégré apparait maintenant avec les volumes disponibles

![](/2016/10/oraclevm13.png)

![](/2016/10/oraclevm15.png)

![](/2016/10/oraclevm14.png)

## Créer des repositories pour stocker des images

Une fois les périphériques de stockage déclarés auprès de vos serveurs de virtualisation, on peut maintenant créer des pools appelés repositories.

L’ensemble des opérations qui suivent sont a effectuer dans l’onglet Repositories. Ces pools logiques de stockage vous permettent de stocker vos fichiers ISO, mais aussi vos templates et vos disques durs virtuels pour vos machines virtuelles. Sur VMware on parlerait de **Datastores**.

### Avec le disque local

Comme indiqué précédemment, ce type de stockage aura l’inconvénient de n’être accessible que d’une seule machine. Cependant c’est le plus simple à utiliser.

Cliquer sur le logo « + » pour créer un nouveau repository.

![](/2016/10/oraclevm24.png)

On doit d’abord renseigner quelques informations descriptives et d’appartenance.

![](/2016/10/oraclevm26.png)

Enfin, on sélectionne le disque (Physical Disk) sur lequel placer le repository.

![](/2016/10/oraclevm25.png)

La dernière étape consiste à ajouter les serveurs qui verront ce stockage. Dans ce cas précis, seul lab01 pourra le voir.

![](/2016/10/oraclevm27.png)

Après validation, le nouveau repository apparait dans la liste des repositories.

![](/2016/10/oraclevm28.png)

### Avec le disque SAN

Le principe est le même pour les disques SAN, à ceci près que celui ci pourra bien être partagé entre plusieurs serveurs d’un même cluster (pour peu que les serveurs concernés aient bien été autorisés à voir ce stockage lors de l’étape précédente).

![](/2016/10/oraclevm29.png)

![](/2016/10/oraclevm30.png)

## Gestion du réseau

Vous l’aurez deviné, pour la gestion du réseau, tout se passe dans l’onglet « Network » de la console OVMM.

Petite subtilité, par défaut, le réseau de management ne peut pas être utilisé par les VMs. Vous ne pourrez donc pas affecter de réseaux virtuels aux machines virtuelles en l’état actuel des choses.

![](/2016/10/oraclevm16.png)

Dans mon cas (PoC), je ne souhaite pas créer un nouveau réseau pour me simplifier la vie, et j’ai donc ajouté « Virtual Machine » au réseau de _management_ créé par défaut lors de l’installation du serveur OracleVM.

![](/2016/10/oraclevm17.png)

![](/2016/10/oraclevm18.png)

Dans un contexte de production, on préfèrera en ajouter un nouveau et lui affecter des interfaces réseaux et des VLANs (comme on le ferait sur VMware ou RHEV).

![](/2016/10/oraclevm19.png)

## Créer une nouvelle VM

Maintenant que les aspects stockage et réseau ont été réglés, on peut enfin créer une machine virtuelle. La documentation officielle donne [quelques informations utiles sur le sujet](https://docs.oracle.com/cd/E27300_01/E27309/html/vmusg-vm-create.html).

Le début de la création de machine virtuelle est similaire à n’importe quel outil de virtualisation.

![](/2016/10/oraclevm31.png)

![](/2016/10/oraclevm32.png)

![](/2016/10/oraclevm33.png)

### HVM, HVM + PV, PVM

Cependant, par rapport aux autres hyperviseurs (full virtualisation vs paravirtualisation, [différences que j’aborde dans cet article](/2016/08/25/when-should-we-have-containers/)), Xen et donc OracleVM apporte une subtilité dans la méthode de virtualiser : la paravirtualisation (PVM). On a le choix entre HVM, HVM + PV et PVM.

En réalité il s’agit de :

  * **Xen HVM:** Hardware virtualization, or fully virtualized
  * **Xen HVM, PV Drivers:** Identical to Xen HVM, but with additional paravirtualized drivers for improved performance
  * **Xen PVM:** Paravirtualized

En théorie, vous aurez donc de meilleures performances lorsque vous disposerez d’un OS capable d’être paravirtualisé (mode Xen PVM) que lorsque vous aurez une HVM.

Ça c’est la théorie. En fait en pratique, certains OS, même Linux, seront plus performants en HVM + PV selon Oracle. Pour plus d’informations, voir la page de [documentation officielle qui traite du sujet](https://support.oracle.com/epmos/faces/DocumentDisplay?id=757719.1#aref18)

La liste des OS supporté pour chaque mode est disponible dans [les release notes](http://www.oracle.com/technetwork/documentation/vm-096300.html).

### Créer des interfaces virtuelles

La seconde étape du wizard permet de configurer les interfaces virtuelles et les réseaux qui y sont associés.

![](/2016/10/oraclevm34.png)

### Ajouter des disques virtuels

L’étape d’après permet de configurer les différents périphériques qui sont associés à la VM. Dans le cas du disque dur virtuel, il faut le créer ou en réutiliser un existant.

![](/2016/10/oraclevm35.png)

Lorsqu’on clique sur le « + », on peut créer un nouveau disque virtuel qui sera stocké sur le repository choisi.

![](/2016/10/oraclevm36.png)

Enfin, on peut affecter ou non les différents périphériques éligibles à la séquence de boot et les ordonner.

![](/2016/10/oraclevm37.png)

Une fois la VM créée, on peut la démarrer et ouvrir sa console.

![](/2016/10/oraclevm38.png)

## Boot

Dans l’état actuel des choses, la VM démarre mais n’a aucun disque bootable (CD ou HDD). En effet, il faut monter un ISO sur la VM, mais pour ça on doit l’uploader dans un premier temps sur un des repositories précédemment créés.

![](/2016/10/oraclevm39.png)

![](/2016/10/oraclevm40.png)

A priori, dans le menu d’import du repository, on ne peut uploader **que** des ISO **depuis un partage web HTTP**. Une solution alternative probable est que l’on peut simplement aller déposer le fichier en SSH mais je trouve que clairement il manque une fonctionnalité à la console d’upload en directe depuis un navigateur !

Une fois qu’on dispose d’un ISO pour booter notre VM, on peut éditer la machine virtuelle et y ajouter l’ISO.

![](/2016/10/oraclevm41.png)

![](/2016/10/oraclevm42.png)

![](/2016/10/oraclevm43.png)

On redémarre la machine virtuelle qui boote sur l’ISO comme souhaité.

![](/2016/10/oraclevm44-2.png)

## Sources

* [docs.oracle.com/cd/E64076_01/](http://docs.oracle.com/cd/E64076_01/)
* [www.oracle.com/technetwork/server-storage/vm/downloads/index.html](http://www.oracle.com/technetwork/server-storage/vm/downloads/index.html)
* [docs.oracle.com/cd/E64076_01/E64078/html/index.html](http://docs.oracle.com/cd/E64076_01/E64078/html/index.html)
* [docs.oracle.com/cd/E64076_01/E64078/html/vmiug-server-installation.html](http://docs.oracle.com/cd/E64076_01/E64078/html/vmiug-server-installation.html)
