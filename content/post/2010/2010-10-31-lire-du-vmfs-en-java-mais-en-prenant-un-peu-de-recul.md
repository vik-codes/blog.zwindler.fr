---
title: Lire du VMFS en Java, mais en prenant un peu de recul
authors:
  - zwindler
type: post
date: 2010-10-31T18:14:33+00:00
url: /2010/10/31/lire-du-vmfs-en-java-mais-en-prenant-un-peu-de-recul/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - ESX(i)
  - Java
  - VMFS

---
Dans mon précédent article, j’ai parlé de la possibilité de lire des partitions VMFS depuis n’importe quel OS capable de faire fonctionner du java un peu récent, à l’aide d’un driver libre pour le VMFS (v3).

Pour introduire l’utilisation de ce driver, j’avais parlé de mon cas personnel. Pour rappel, je dispose d’un vieux disque encore partitionné en VMFS, mais je n’ai plus le serveur ESX(i) pour le lire. Je m’étais extasié devant la possibilité de brancher un disque dur sur un port USB de n’importe quelle machine Linux/Windows, et de pouvoir explorer le contenu de mon disque dur, ce qui serait bien utile dans mon cas.

Cependant, je m’étais ensuite posé la question quant à l’utilité d’un tel driver pour les professionnels. Contrairement à mon disque tout simple, les pros disposent souvent de stockages montés en RAID pour héberger leurs disques en VMFS. Le fait que l’on ne puisse pas de façon simple/pratique pour brancher sur USB une grappe RAID sortant d’un serveur ou d’une baie SAN qui vient de cramer m’avait un peu refroidi. Mais ce n’est que parce que j’avais mal lu...

Et bien en relisant d’un peu plus près les possibilités offertes par l’outil, j’ai réussi à trouver l’information qui me manquait pour justifier l’utilité d’un tel projet (il est quand même un peu conséquent, en termes de travail). Non seulement le driver est capable de lire n’importe quel volume qui a été monté sur votre système, mais il semblerait bien qu’il soit également capable de lire (nous parlons bien **lecture seule**) les volumes VMFS accessibles via SSH.

Et là forcément, l’outil prend tout son sens. Un article (sur [vmforensics.org](https://web.archive.org/web/20101025211315/http://www.vmforensics.org:80/2010/06/) qui n'a malheureusement jamais été sauvegardé par Internet Archive) parlant de tout cela beaucoup mieux que je ne pourrais le faire (n’ayant plus de serveur ESXi sous la main pour le moment).

Enfin, pour les gourmands (ou les fous furieux?), voici comme promis le hotfix du jar de fluidops, avec l’ajout d’une fonctionnalité dans la CLI qui permet de copier le contenu complet d’un dossier, l’équivalent d’un `cp -r` ([ici](misc/fvmfs_r95_modified_by_zwindler.zip)). Cela pourrait être pratique pour des personnes qui voudraient copier en une seule commande l’ensemble des fichiers d’une machine virtuelle (et sans utiliser le serveur WebDAV).

Attention tout de même! **Cette version n’est pas une version officielle**. J’ai modifié moi-même les sources (r95) sur [code.google.com/p/vmfs/](http://code.google.com/p/vmfs/), et j’y ai ajouté la fonction **recursefilecopy**. Même mise en garde que d’habitude : je ne suis pas responsable de problèmes qui résulteraient de l’utilisation/la mauvaise utilisation de ce jar. Ceci étant dit : « Chez moi, ça marche », comme dirait l’autre...
