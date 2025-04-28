---
title: 'NAS/MediaCenter : Do It (the software part) Yourself!'
authors:
  - zwindler
type: post
date: 2011-08-04T21:02:24+00:00
url: /2011/08/04/nasmediacenter-do-it-the-software-part-yourself/
image: /2011/06/dscn1178.jpg
categories:
  - Stockage
tags:
  - FreeBSD
  - FreeNAS
  - kFreeBSD
  - OpenSolaris
  - Ubuntu
  - XBMC
  - ZFS
  - ZFS on FUSE

---
## NAS + Mediacenter : Vous voulez toujours le faire vous même ?

[EDIT]Depuis que j’ai écris cet article, de l’eau a coulé sous les ponts (plus pour la partie NAS que Mediacenter). Maintenant à l’aide de ZFSonLinux il est possible de faire du ZFS sous Linux sans passer par le portage en userland qu’est ZFS Fuse, alors qu’il manque toujours d’importants composants dans Btrfs.[/EDIT]

[Si vous avez lu le dernier article](/2011/06/29/nasmediacenter-do-it-yourself-or-not/), vous aurez remarqué que j’avais découpé mon article en deux parties : le hardware vs le software. Voici donc la partie software tant attendue (ou pas vu la fréquence à laquelle j’écris... On n’a qu’à dire que c’est pour faire mûrir la réflexion!)

Ça y est! Tout est monté! Le premier choix crucial est évidemment celui de l’OS, mais celui ci est dicté par les fonctionnalités qu’on attend de l’OS en question...

Car aujourd’hui, si tout le monde essaye de copier les fonctionnalités des autres pour prouver à quel point tel OS fait tourner le plus de choses, tout le monde fait aussi de son mieux pour se démarquer avec telle ou telle FEATURE INEDITE...

Ce que j’attendais de la bécane était relativement simple, mais les implications ont rendues le choix plutôt compliqué...

  * Un espace de stockage, avec des données redondées, si possible pas tout car je n’ai que deux disques et ne voudrait pas gaspiller de l’espace
  * Un mediacenter connecté à ma télé, si possible qui puisse être contrôlé depuis mon canapé

### Le Media Center

S’il avait juste s’agit de choisir un MediaCenter, le choix était tout trouvé : Ubuntu avec XBMC est l’un des MediaCenter les plus plébicités, avec une foultitude de fonctionnalités et une large communauté. Il propose par exemple :

  * une interface fluide, totalement customisable à l’aide de nombreux thèmes/scripts
  * une gestion de périphériques comme la **wiimote** ou les **smartphone** pour faire office de télécommande dans son canapé
  * la lecture de la plupart des formats images/audio/vidéo (avec sous titres)
  * la gestion de fichiers médias déportés sur le réseau (partage SMB, UPnP et truc de MACeux aussi si j’ai bien lu)
  * une « distrib » toute faite basée sur un Ubuntu, pour ceux qui n’auraient même pas envie de s'embêter à installer un linux puis installer un paquet tout fait... Dur la vie!

Ce Media Center s’est même imposé comme la condition _sine qua non_ dans le choix de l’OS et donc du FS.

### Le STOCKAGE

S’il avait juste s’agit de faire du stockage, un boitier plus grand m’aurait permis de faire du RAID5 logiciel, et ainsi disposer de perfs correctes sans utiliser trop d’espace disque pour la tolérance aux pannes. Ce n’est pas le cas, je n’avais la place que pour 3 disques si jamais je souhaitais conserver l'emplacement DVD, bien utile pour tout ce qui est installation de distrib et lecture de films...

Quand j’ai commencé à faire mes recherches par rapport au stockage à la maison, je suis tombé sur plusieurs articles alarmistes qui m’ont dissuadé d’utiliser du RAID5, qui souffrirait, couplé à des FS actuels à des risques de **corruption silencieuse** pouvant entraîner la perte de toute les données malgré la présence d’un disque de parité (google « silent corruption » ou des articles comme http://www.zdnet.com/blog/storage/50-ways-to-lose-your-data/168). Même si il faut faire la part des choses avec ce que disent ces **Cassandres du stockage** et la réalité, je me suis donc tourné vers des solutions réputées plus sures.

Aujourd’hui, la plupart des filesystems utilisent des journaux des opérations et des checksum permettant de vérifier que les données n’ont pas été corrompues par les ondes électromagnétiques générées par le battement d’ailes d’un papillon ou que sais-je encore! Malheureusement, cela ne suffit pas toujours et il est possible qu’un hardware défaillant pourrisse l’intégralité de vos données sans que personne ne s’en aperçoive.

> Heureusement, des filesystems NextGen nous promettent monts et merveilles!!!

### Le FILESYSTEM

A l’époque, BTRFS n’était pas encore vraiment « standard » (encore moins qu’aujourd’hui en fait...). La seule « solution » fonctionnelle  à ma connaissance était ZFS.

J’ai probablement autant été convaincu par le nombre de FEATURE INÉDITES de ce filesystem que par la description un peu loufoque de ses limites :

  * ZFS est un système de fichiers 128 bits, ce qui signifie qu’il peut fournir 16 milliards de milliard de fois ce que fournissent les systèmes de fichiers 64 bits actuels.
  * Les limitations de ZFS sont tellement inaccessibles qu’il n’y aura jamais d’opérations pratiques qui puissent les atteindre. Selon Bonwick

> _Remplir un système de fichiers 128 bits dépasserait les limites quantiques de stockage de données. Vous ne pourriez pas remplir un espace de données 128 bits sans faire bouillir les océans._

Voilà qui laisse rêveur... Pour le calcul ayant permis de parvenir à cette conclusion je vous laisse aller feuilleter la page de wikipedia dédiée.

Ce qui est vraiment intéressant à savoir c’est que ZFS propose actuellement :

  * Du « copy on write ». Les données ne sont réellement modifiées qu’une fois que tout a bien été écrit sur le disque. Pas de risque de se retrouver avec des blocs corrompus suite à un reboot intempestif.
  * Un FS où chaque bloc possède un checksum 256bits, et ou les checksums possèdent eux mêmes des checksums (et ainsi de suite), au cas où les données ET les checksums seraient corrompus.
  * Un FS qui se répare de lui même en vérifiant les blocs lus avec les checksums de toute la chaîne.
  * Gestion de « snapshots » permettant des retours arrière de façon quasi instantanée.
  * Compression, déduplication, partages NFS/CIFS/iSCSI, quotas activables en une commande
  * Une gestion facilité des volumes pour l’administrateur système
  * RAIDZ, un RAID logiciel particulièrement optimisé pour être à la fois plus efficace et plus sûr qu’un RAID classique
  * Une capacité risible comme on l’a vu plus haut
  * ...

(Ceux qui auront suivi BTRFS auront remarqué des promesses similaires, même si tout n’est pas encore terminé, côté développement)

> Mes données en sont tombées amoureuses :-)

### l’OS

J’ai donc du trouver une solution pour pouvoir **concilier ZFS et XBMC**. Et ça n’a pas été **guimauve**...

Pour des raisons de guéguerre de licence (ZFS est en CDDL), ZFS ne peut pas être intégré au noyau Linux. ZFS a été porté sur :

  * Solaris 10 et OpenSolaris
  * Les BSD (notamment FreeBSD)
  * Les MAC
  * En **userspace** sous Linux avec zfs-on-fuse (hors du kernel et donc dégradé niveau performances)

Après quelques tentatives échouées d’installer FreeBSD (désolé, mais on est loin des installs Debian/Redhat... Je ne demande pas un Ubuntu, mais y a des limites quand même!) correctement, je me suis résolu à utiliser zfs-on-fuse, pour voir. Bon ok, j’ai aussi fais quelques boulettes...

> Quand le port de gnome ne marche pas, n’essayez de le compiler vous même, surtout sur un Atom dual core. J’ai du abandonner au bout du 3ème jour de compilation...

Je me suis donc rabattu sur un bon vieux Ubuntu : Linux je connais mieux, je fais moins de conneries. La bonne nouvelle, c’est que ZFS-on-fuse, ça fonctionne très bien! Les fonctionnalités sont pour la plupart au rendez vous, et c’est très agréables à utiliser. Pour les données, j’ai créé deux partitions sur chacun de mes deux disques dédiés aux données, de manière à créer

  1. un zpool « safe » en miroir (2*300 Go = 300 Go)
  2. un zpool « normal » non redondé (2*700 Go = 1400 Go)

Je ne « perd » l’espace du miroir que sur une partie de mon espace total de stockage.

La déception est arrivée après quelques benchs... Loin des résultats catastrophiques que j’avais pu trouver sur le net qui commençaient à dater (des vitesses de 3-4 Mo/secondes!), je n’ai pas pu faire beaucoup mieux que 16-17 Mo/s, aussi bien sur le pool mirroré que sur le pool simple. J’aurai attendu un peu mieux de mes disques, surtout la partie mirrorée en lecture.

### Conclusion

Si vous souhaitez faire un NAS également capable de supporter un MediaCenter, le hardware et le software que j’ai choisi sont tout à fait à même de remplir la tâche.

Sans ventilation, j’arrive à lire des films 720/1080p, et l’interface de XBMC est magique... et avoir une télécommande pour son mediacenter, c’est juste indispensable...

Mes données sont bien plus à l’abris de la corruption silencieuse qu’avec un FS classique en ext3 voire même en ext4, et même si les performances ne sont pas mirobolantes, c’est tout à fait raisonnable pour toute personne qui souhaite disposer d’un NAS à la maison.

Cependant, si c’était à refaire, je ne sais pas si je resterai sur l’architecture MediaCenter/Nas combiné, et si je devais rester sur cette idée, j’essayerai peut être de voir comment se comporte Btrfs, maintenant intégré à tous les Linux.
