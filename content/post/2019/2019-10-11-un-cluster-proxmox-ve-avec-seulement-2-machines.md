---
title: Un cluster Proxmox VE avec seulement 2 machines !
authors:
  - zwindler
type: post
date: 2019-10-11T06:40:55+00:00
excerpt: "Mise en place d'un vote externe au cluster PVE pour permettre d'éviter le psplit brain dans les cas où ce risque est plausible"
url: /2019/10/11/un-cluster-proxmox-ve-avec-seulement-2-machines/
image: /2019/10/proxmox.png
classic-editor-remember:
  - block-editor
categories:
  - Cluster
  - Système
  - Virtualisation
tags:
  - Cluster
  - CMAN
  - corosync
  - heartbeat
  - Proxmox
  - Proxmox VE
  - pve
  - Quorum
  - quorum device
  - rgmanager

---

Depuis le temps que je vous parle de clusters et de Proxmox (en gros, [depuis 2015](/recherche/?keyword=proxmox)), ou même de clusters tout court, j’ai pu vous en mettre des tartines sur le fait qu’il ne faut pas faire des clusters avec un nombre pair de machines (ou tout autre cas défavorable dans lequel deux moitiés d’un cluster peuvent se retrouver isolées l’une de l’autre). Le split brain, c’est pas bon pour votre Karma, croyez moi sur parole (ou [allez voir vous même](/recherche/?keyword=split)).

Ça me rappelle la fois où un """architecte""" de chez Datacore était venu nous expliquer que sa solution de stockage à 2 pattes ne POUVAIT PAS avoir de split brain (alors que si, les ingés du support ont du repasser par derrière pour nous dire que "oui désolé vous avez évidemment raison c’est un cas possible" #LOL).

Bref, et donc à force d’en parler, il fallait bien quand même que je donne un jour la solution pour le faire quand même, mais proprement. Sans trop de surprise, Corosync, la librairie qui gère les clusters Linux depuis qu’on a arrêté de faire des horreurs avec heartbeat (ou pire : [cman+rgmanager, achevez moi](/recherche/?keyword=redhat+cluster+suite)), gère évidemment les deux possibilités :

* Gérer soit même le membre prioritaire en cas de split brain avec un poids (ça on va pas en parler mais sachez que c’est possible)
* Ajouter un vote externe pour obtenir un quorum (comme tous les vrais logiciels qui font du clustering un peu sérieux quoi)

## Limitations du "Corosync External Vote" dans PVE

La petite déception du jour viendra surtout du fait que, si la documentation de Proxmox VE indique clairement que l’option est supportée, en réalité, le support se limite aux fonctions natives de corosync, et encore pas toutes.

Pas moyen de voir notre vote externe dans l’interface de Proxmox VE par exemple. A priori, le support des quorum disk n’est plus assuré non plus depuis la version 4 de PVE.

Ensuite, il faut aussi savoir que pour l’instant, seul l’utilisation d’une IP pour renseigner le quorum serveur est possible. On ne peut pas utiliser un FQDN, ce qui me parait dingue comme limitation en 2019, mais bon...

Ces deux points mis de côté, vous allez voir, ce n’est pas sorcier. La procédure est en bonne partie détaillée [dans la documentation](https://pve.proxmox.com/wiki/Cluster_Manager#_corosync_external_vote_support).

## Prérequis
  
Pour ce tutoriel, vous allez donc avoir besoin de 2 machines (a minima), déjà en cluster. Si vous ne les avez pas déjà, je vous invite à regarder [les moults tutoriels précédents](/recherche/?keyword=proxmox), en particulier celui sur [la mise en place d’un cluster Proxmox VE 6](/2019/08/20/cluster-proxmox-ve-v6-cette-fois-ci/) (le plus récent).
  
Vous allez aussi avoir besoin d’un serveur tiers (un bout de VM ou de container quelque part, en dehors de vos 2 (ou tout autres quantité de machines étant localisées dans 2 endroits distincts dont il existe un risque qu’ils puissent subitement "ne plus se voir", d’un point de vue réseau, induisant le fameux split brain tant redouté).

Fun fact, il y a [une page de wiki pour faire la même chose à la main avec un RPi](https://pve.proxmox.com/wiki/Raspberry_Pi_as_third_node).

Ce serveur tiers n’a pas besoin de faire fonctionner Proxmox (c’est même plutôt mieux d’ailleurs car PVE n’a aucune plus-value ici). Ça doit juste être une distrib linux capable d’installer un démon corosync qnetd. Ce serveur, nous l’appellerons "quorum", par abus de langage grossier ;-).

## Configuration

Sur le serveur quorum, installer corosync qnetd. Sur une Debian like, vous avez de la chance, il existe un package présent dans les dépôts par défaut, et il faut simplement faire un :

```
sudo apt install corosync-qnetd
```

Ensuite, sur tous les serveurs Proxmox VE de notre cluster, on va installer le package corosync-qdevice, qui va leur permettre d’interroger le quorum.

```
sudo apt install corosync-qdevice
```

Sur le serveur quorum de nouveau, ajouter la clé SSH d’un des serveurs PVE (un seul suffit). Une fois que c’est fait, connecter le cluster au quorum.

Cela va sans dire, mais faire la commande depuis le serveur dont on vient d’ajouter la clé, pas l’autre hein ;-p. Et remplacez <QDEVICE-IP> par l’IP du serveur quorum !

```
pvecm qdevice setup <QDEVICE-IP>
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
The authenticity of host 'x.x.x.x' can't be established.
ECDSA key fingerprint is SHA256:LPaaaaaaaaaaaaaaaaaPZjaIg.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: WARNING: All keys were skipped because they already exist on the remote system.
 (if you think this is a mistake, you may want to use -f option)
```

Je met volontairement une grosse partie de la trace car comme ça on peut parler de ce que fait la commande _pvecm qdevice setup x.x.x.x_.

Comme vous pouvez le constater, cette commande semble assez similaire à celle pour créer manuellement le cluster. A savoir, elle commence déjà par copier les clés SSH sur le serveur distant, histoire que tout le monde puisse discuter ensemble en SSH.

```
INFO: initializing qnetd server
Certificate database (/etc/corosync/qnetd/nssdb) already exists. Delete it to initialize new db
INFO: copying CA cert and initializing on all nodes
node 'pve01': Creating /etc/corosync/qdevice/net/nssdb
password file contains no data
node 'pve01': Creating new key and cert db
node 'pve01': Creating new noise file /etc/corosync/qdevice/net/nssdb/noise.txt
node 'pve01': Importing CA
[...]
```

Ensuite, on initialise, sur tous les nodes du cluster, le qdevice, qui va permet au node de communiquer avec le quorum. Là j’élude un peu car ça parle beaucoup de certificats et de clés qui sont échangées.

```
INFO: copy and import pk12 cert to all nodes<br>INFO: add QDevice to cluster configuration
INFO: start and enable corosync qdevice daemon on node 'pve01'...
Synchronizing state of corosync-qdevice.service with SysV service script with /lib/systemd/systemd-sysv-install.
```

Normalement, si tout se passe bien, vous devriez en arriver là, une fois que tout le monde s’est bien échangé ses certificats, clés et autres joyeusetés crytographiques.

Une petite commande pour vérifier l’état du bazar :

```
$ pvecm status
Quorum information
------------------
Date:             Mon Aug 26 14:49:14 2019
Quorum provider:  corosync_votequorum
Nodes:            2
Node ID:          0x00000002
Ring ID:          1/1271796
Quorate:          Yes

Votequorum information
----------------------
Expected votes:   3
Highest expected: 3
Total votes:      3
Quorum:           2  
Flags:            Quorate Qdevice 

Membership information
----------------------
    Nodeid      Votes    Qdevice Name
0x00000001          1    A,V,NMW 10.0.0.1
0x00000002          1    A,V,NMW 10.0.0.2 (local)
0x00000000          1            Qdevice
```

Ça, c’est le genre de choses que j’attends d’un logiciel de clustering digne de ce nom. D’une simple commande, on peut avoir

* le nombre de nodes
* l’ID du node courant
* le nombre de votes actuels, attendus, et minimum pour que le cluster soit "QUORATE"
* et enfin l’état de tout le cluster.

Ici, avec 2 nodes + le quorum, on a bien 3 votes. Tant qu’on a 2 votes, on a le quorum, CQFD.

Dans ce cas de figure, si on perd un nœud OU le quorum, on a toujours 2 votes et le cluster doit continuer à fonctionner "normalement".

Et c’est ce qu’on va vérifier !

## On casse un nœud, pour voir
  
Normalement, si on a pas le serveur quorum, tout devrait être brisé (comme dirait Medieval Ops).

![](/2021/tweet_medieval.png)

En gros les VMs doivent continuer à tourner, mais toute opération (démarrage de VM, modification quelconque) doit être bloquée (pour éviter de démarrer la même VM à 2 endroits et pleurer pour recoller les morceaux).

Or ici dès que l’hôte n’est plus joignable, le nœud survivant le détecte, et comme le quorum ne voit plus lui non plus qu’un seul nœud, indique au dernier qu’il peut continuer sa vie comme si de rien n’était (c’est glauque...).


```
$ pvecm status
Quorum information
------------------
Date:             Thu Aug 29 11:10:31 2019
Quorum provider:  corosync_votequorum
Nodes:            2
Node ID:          0x00000002
Ring ID:          1/1271820
Quorate:          Yes

Votequorum information
----------------------
Expected votes:   3
Highest expected: 3
Total votes:      2
Quorum:           2  
Flags:            Quorate Qdevice 

Membership information
----------------------
    Nodeid      Votes    Qdevice Name
0x00000002          1    A,V,NMW 10.0.0.2 (local)
0x00000000          1            Qdevice
```

Le nombre de vote passe bien à 2 (mais comme on est toujours égal à quorum c’est bon) et le node 1 a bien disparu :



![](/2019/08/pve_down_quorate.png) 

Et la petite déception, pas de visualisation en console du vote du quorum, malgré la mention "Quorate"

Mais bon, c’est quand même cool que ça marche, et en vrai c’est bien l’essentiel ;)

## Bonus : Erreur insserv: FATAL: service corosync has to be enabled

Si vous rencontrez l’erreur suivante :

```
insserv: FATAL: service corosync has to be enabled to use service corosync-qdevice
```

Allez supprimer le fichier d’init SysV corosync sur tous les hôtes

```
rm /etc/init.d/corosync-qdevice
systemctl enable corosync-qdevice
systemctl start corosync-qdevice
```

Source : https://forum.proxmox.com/threads/setting-up-qdevice-fails.56061/
