---
title: Sauvegarder automatiquement et proprement ses VMs sur ESXi via Ghetto VCB
authors:
  - zwindler
type: post
date: 2010-06-09T08:28:27+00:00
url: /2010/06/09/sauvegarder-automatiquement-et-proprement-ses-vms-sur-esxi/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - Consolidated Backup
  - ESX(i)
  - Ghetto
  - GhettoVCB
  - Snapshot
  - vCenter

---
## Comment je suis tombé sur Ghetto VCB

Alors bien sûr j’entends par proprement autre chose que les snapshots. Je rappelle que snapshoter ses VMs n’est pas vraiment un moyen de sauvegarde. Ce n’est pas du tout conseillé par VMware en tant que backup, car en réalité ça n’en est pas vraiment une.

> En [informatique][1], la **sauvegarde** (_backup_ en anglais) est l’opération qui consiste à dupliquer et à mettre en sécurité les données contenues dans un [système informatique][2]{.mw-redirect}.
> 
> Définition de la sauvegarde de Wikipedia

Alors bien sûr, on peut imaginer faire régulièrement des snapshots pour restaurer la VM en cas de soucis. Mais en cas de crash sur l’ESXi ?

Du coup, on pourrait imaginer aussi utiliser Veeam FastSCP pour transférer les fichiers des VMs depuis le datastore vers votre destination.

Beaucoup de gens font ça, soit parce que ça leur suffit, soit parce qu’ils n’ont pas osé chercher mieux. Et pourtant, il y a (mais ce n’est que mon avis) BEAUCOUP mieux.

## Une vraie sauvegarde

Quand on parle d’ESXi, c’est quand même assez souvent un choix par rapport à une problématique de coûts. Ce n’est bien évidemment pas la seule raison qu’on peut invoquer mais c’est probablement le plus significatif.

Du coup, on imagine ne pas avoir de vCenter pour piloter les ESXi, ne pas avoir de licences pour pouvoir utiliser l’utilitaire « fait pour » de VMware (VMware Consolidated Backup). Et enfin, on n’a pas très envie de payer pour pouvoir profiter d’un moyen sûr et automatisé de sauvegarder ses VMs, comme par exemple en s’achetant:

* Trilead VMX [(lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20160307033207/http://www.trilead.com/)

ou bien encore

* [Veeam Backup & Replication](http://www.veeam.com/vmware-esx-backup.html)

[Edit]D’autant plus que ce que je n’avais pas compris au début, c’est que ces outils ne peuvent pas marcher si vous n’avez pas la licence pour VCB (ce qui est logique, finalement). Ces produits ne font qu’apporter des fonctionnalités supplémentaires au-dessus des fonctionnalités VCB fournie par VMware[/Edit]

Sans avoir pu les essayer vraiment, j’imagine que ces deux produits fonctionnent à merveille. Revenons un peu sur l’outil VMware Consolidated Backup, intégré aux licences Foundation, Enterprise, et Standard. Il faut se tourner vers la version anglaise de la [datasheet (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20120318081342/http://www.vmware.com/pdf/vi3_consolidated_backup.pdf) pour avoir plus de détails.

## VMware Consolidated Backup ?

Vous avez peut être déjà essayé de copier un disque d’une machine virtuelle sur un VMware Server 2.0, par exemple. Le système d’exploitation vous annonce froidement que vous ne pouvez pas car le fichier contenant le disque est protégé en lecture (oui oui, en lecture)! Quand on y réfléchit, c’est bien normal. Ce disque en fonctionnement est donc constamment en train d’être modifié par le système d’exploitation virtuel, même quand on ne fait rien sur la machine. Alors comment copier ce fichu disque, sans être obligé d’éteindre la machine virtuelle (ce qui marche parfaitement, soit dit en passant)?

Et c’est là toute la **trick** de VMware : passer par une snapshot temporaire. Au moment où vous voulez backuper, VCB créé une snapshot de la machine, ce qui est très rapide. Sur notre infra ESX, c’est fait en moins d’une seconde, et sous ESXin à peine plus. On voit beaucoup mieux ce qui se passe sur un VMware Server 2, par exemple, où l’opération est beaucoup plus longue. Je ne suis pas certain à 100% que ça se passe toujours de la même façon, mais pour ce produit, le serveur met la VM en pause, créé une snapshot très rapidement, puis rallume la machine. Du point de vue de l’utilisateur, ça donne probablement un petit lag durant le processus, mais pour ce qui est du fonctionnement de la VM, c’est parfaitement transparent.

Une fois cette snapshot créée, il ne reste plus à VCB qu’à créer une backup pérenne de la machine virtuelle. L’étape finale consiste à supprimer la backup temporaire une fois terminé.

Une fois qu’on a compris comment ça marche, on peut se réjouir d’apprendre que quelqu’un a utilisé les fonctionnalités internes des ESX/ESXi pour reproduire les mêmes fonctionnalités. Je ne rentrerai pas dans les détails techniques de l’installation vu que tout est déjà très bien présenté.

## Et donc Ghetto VCB ?

Behold! Voici la bibliothèque [Ghetto VCB (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20160825165143/http://communities.vmware.com/docs/DOC-11965) et probablement le script le plus connu de cette bibliothèque : [GhettoVCB.sh (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150209104011/http://communities.vmware.com/docs/DOC-8760).

Update 2024 : j'ai retrouvé [un repo contenant les scripts sur Github.com](https://github.com/lamw/ghettoVCB).

Ghetto VCB fait la même chose que VCB, mais sans avoir besoin de payer une licence à VMware. En fait, il se base sur le serveur lui-même, ce qui permet de contourner les fonctionnalités manquantes (par exemple, l’écriture à distance sur les disques des VM est bloqué si vous n’avez pas une licence).À partirr de là, il ne reste plus qu’à envoyer le script sur votre ESXi. Par SSH par exemple, [nous savons le faire maintenant ;-)][3]. Enfin, il faudra reconfigurer le script en fonction de votre ESXi et suivre les instructions pour rentrer le script dans le cron.

Juste magique...

 [1]: https://fr.wikipedia.org/wiki/Informatique "Informatique"
 [2]: https://fr.wikipedia.org/wiki/Syst%C3%A8me_informatique "Système informatique"
 [3]: /2010/04/30/esxi-4-0-explorons-lhidden-console-part-2/
