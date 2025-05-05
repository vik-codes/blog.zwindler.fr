---
title: '[Tutoriel] Démonter proprement un cluster Proxmox VE'
authors:
  - zwindler
type: post
date: 2017-09-19T11:30:18+00:00
url: /2017/09/19/tutoriel-demonter-proprement-cluster-proxmox-ve/
image: /2017/08/proxmox_logo.png
categories:
  - autohebergement
  - Cluster
  - Système
  - Virtualisation
tags:
  - corosync
  - Proxmox
  - Proxmox VE

---
## Faire et défaire des clusters Proxmox VE, c’est toujours travailler

Si vous avez lu et appliqué à la lettre [mon article précédent sur les clusters Proxmox VE quand on a pas de multicast](/2017/08/29/faire-un-petit-cluster-proxmox-avec-2-machines-kimsufi/) (ou autre si vous n’êtes pas bridé sur le multicast), vous devriez être l’heureux propriétaire d’un cluster Proxmox VE fonctionnel.

> Mille bravo !

Mais personne n’est parfait et n’est à l’abris d’une faute de frappe, d’un oubli ou d’une erreur, et je me suis retrouvé devant un cluster en vrac, complètement bloqué, avec une partie des nœuds fonctionnels et l’autre marqués « failed ».

OK... J’avoue. Je suis un bourrin quand je bidouille. Ça m’est arrivé... plusieurs fois...

Dans cet article, je vais donc vous donner la marche à suivre pour supprimer complètement toute trace des configurations du cluster et ainsi repartir à zéro pour recommencer (sans avoir à tout réinstaller car ça marche aussi mais bon...)

[Aparté]Une fois encore, si vous ne connaissez pas Proxmox VE je vous invite à [consulter les articles que M4vr0x et moi avons écris à ce sujet][2], il commence à y en avoir pas mal[/Aparté]

## Sous le capot

D’abord, je voudrais rapidement rappeler que Proxmox VE est un logiciel de virtualisation qui est majoritairement déployé via un ISO contenant une Debian modifiée. Le cœur du clustering dans ProxMox se base sur Corosync (depuis la version 4+), avec l’ajout d’un filesystem distribué maison pour ce qui est gestion de configuration cohérent sur tous les nœuds ([**pmxcfs**][3]).

On peut récupérer beaucoup d’informations sur le cluster simplement en allant consulter les fichiers de configuration présents dans les dossiers de **corosync**. C’est d’ailleurs comme ça que je m’en suis sorti [quand j’avais tout cassé dans mon article précédent][1].

## Sortir proprement un nœud

La documentation officielle donne la marche à suivre dans le cas où [vous souhaitez juste sortir un nœud de votre cluster][4]. Si ce n’est pas vraiment notre but ici, ça peut quand même vous servir et surtout, c’est une des étapes dont nous aurons besoin pour la suite.

**ATTENTION ! Si je n’ai peut être pas été assez clair (cf les commentaires), je vais écrire en gras** maintenant pour qu’il n’y ait plus de doute. Couper les services pve-* ne devrait pas impacter vos VMs (qui continuent à tourner), mais supprimer un nœud du cluster SI (elles tournent toujours, mais ont disparues de l’interface) !

> **Read carefully the procedure before proceeding, as it could not be what you want or need.**
> 
> Move all virtual machines from the node, just use the [Central Web-based Management][5] to migrate or delete all VM´s. Make sure you have no local backups you want to keep, or save them accordingly.

**Et c’est bien normal : au même titre que Proxmox a réinitialisé la configuration de votre nœud lors de la création du cluster, la même opération est réalisée fait lors de sa sortie. Donc, s’il vous plait, ne jouez pas avec les clusters si vous avez des VMs qui tournent sur vos machines...**

Pour la suite de l’article, je vais appeler nœud **srv1** le serveur que nous allons garder jusqu’à la fin, et **srv2**, **srv3**, etc... tous les autres serveurs du cluster.

### Sur le nœud srv1

La première chose à faire est de réduire le nombre de nœuds _expected_ par le cluster **corosync**. L’idée étant qu’à un moment donné, **corosync** s’attend à avoir au minimum X nœuds, X étant le nombre de serveurs du cluster. S’il en a moins, le cluster se bloque pour empêcher toute modification dans le cas où on serait en « mode dégradé ». On va donc réduire ce nombre de 1 pour que le cluster ne soit pas trop surpris par la suppression d’un nœud.

Dans mon exemple je n’ai que deux serveurs. Cependant, si on a plus de nœuds, il faudra reproduire la procédure jusqu’à ce qu’il ne reste plus qu’un nœud.

```
pvecm expected 1

pvecm delnode srv2 
    Killing node 2
```


### Sur le nœud à supprimer

A partir de maintenant, pour tout le reste du cluster, le nœud srv2 (ou tout autre à supprimer) n’en fait plus parti. Cependant, la procédure n’agit pas (ou pas entièrement) sur le nœud 2 en lui même : il reste quand même du ménage à faire. Et si on ne le fait pas, et qu’on essaye de le réintégrer dans le cluster, il y aura des restes et l’intégration risque d’échouer à nouveau.

Assurez vous que rien de critique ne tourne sur ce nœud avant retrait du cluster.

```
systemctl stop pvestatd.service 
systemctl stop pvedaemon.service 
systemctl stop pve-cluster.service 
systemctl stop corosync
```

A noter que dans Proxmox VE, au delà du simple fichier texte présent sur le filesystem, la configuration est également stockée dans une base **sqlite**. Si on se contente de supprimer la configuration dans les fichiers, elle sera régénérée dès qu’on redémarrera les services. On va donc devoir la vider à la main :

```
sqlite3 /var/lib/pve-cluster/config.db
SQLite version 3.8.7.1 2014-10-29 13:59:56 
Enter ".help" for usage hints. 

sqlite> select * from tree where name = 'corosync.conf'; 
2|0|3|0|1500655311|8|corosync.conf|logging { 
debug: off 
to_syslog: yes 
} 

nodelist { 
node { 
name: srv1 
nodeid: 1 
quorum_votes: 1 
ring0_addr: 10.9.0.1 
} 
node { 
name: srv2 
nodeid: 2 
quorum_votes: 1 
ring0_addr: 10.9.0.2 
} 
} 

quorum { provider: corosync_votequorum } 
totem { 
cluster_name: kimsufi 
config_version: 5 
ip_version: ipv4 
secauth: on 
version: 2 
interface { 
bindnetaddr: 10.9.0.2 
ringnumber: 0 
} 
} 

sqlite> delete from tree where name = 'corosync.conf'; 
sqlite> select * from tree where name = 'corosync.conf'; 
sqlite> .quit
```

Maintenant qu’on a supprimé la configuration de **corosync** de la base **sqlite**, on peut supprimer la configuration définitivement (ou juste en faire un copie, si on est prudent) :

```
mv /var/lib/corosync/ /var/lib/corosync.$(date +%y%m%d%H%M)
mkdir /var/lib/corosync
mv /var/lib/pve-cluster/ /var/lib/pve-cluster.$(date +%y%m%d%H%M)
mv /etc/corosync /etc/corosync.$(date +%y%m%d%H%M)
```

Et enfin redémarrer les services :

```
systemctl start pvestatd.service
systemctl start pvedaemon.service
systemctl start pve-cluster.service
```

On a donc un serveur qui a retrouvé son état initial (à savoir un serveur hors d’un cluster) sans avoir à le réinstaller complètement.

Pour la suite, je le rappelle : L’idée ici est donc d’appliquer cette procédure sur tous les nœuds sauf un (le dernier, srv1).

## Détruire le cluster entier

Nous avons maintenant un cluster contenant une seule machine : srv1. Nous pouvons reproduire la même procédure que précédemment, à un détail près : pas besoin de réduire le nombre de votes _expected_, déjà descendu à 1.

Et on peut recommencer à jouer en redémarrer les services suivants sur srv1 :

```
systemctl start pvestatd.service
systemctl start pvedaemon.service
systemctl start pve-cluster.service
systemctl start corosync
```

TADAM !!!! Vous pouvez re-tout casser ;-)

## Source

* [forum.proxmox.com/threads/removing-deleting-a-created-cluster.18887/](https://forum.proxmox.com/threads/removing-deleting-a-created-cluster.18887/)

 [2]: /recherche/?keyword=proxmox
 [3]: https://pve.proxmox.com/wiki/Proxmox_Cluster_File_System_(pmxcfs)
 [4]: https://pve.proxmox.com/wiki/Proxmox_VE_4.x_Cluster#Remove_a_cluster_node
 [5]: https://pve.proxmox.com/wiki/Central_Web-based_Management "Central Web-based Management"
