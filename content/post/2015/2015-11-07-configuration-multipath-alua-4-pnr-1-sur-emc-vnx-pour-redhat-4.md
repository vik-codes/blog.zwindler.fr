---
title: Configuration multipath ALUA 4 / PNR 1 sur EMC VNX pour RedHat 4
authors:
  - zwindler
type: post
date: 2015-11-07T11:30:18+00:00
url: /2015/11/07/configuration-multipath-alua-4-pnr-1-sur-emc-vnx-pour-redhat-4/
image: /2015/10/vnx5300.jpg
categories:
  - Stockage
  - Système
tags:
  - EMC²
  - friendly name
  - hwhandler
  - mpath
  - multipath
  - Path not correctly configured for failover
  - RHEL 4
  - VNX
  - VNX5200

---
Suite à une migration de baies HP EVA vers des EMC² VNX, une partie de mes vieux serveurs Linux m’ont générés quelques incidents, suite à la modification de la configuration multipath consécutive à cette migration.

Lors d’une coupure d’un chemin (notamment lors de la mise à jour d’un _Service Processor_ par exemple), les E/S sur les disques SAN se bloquaient sur certains serveurs Linux, induisant un empilement des traitements (et donc du load average) jusqu’à bloquer l’accès au serveur et planter les procédures en cours.

Les causes de ces dysfonctionnements étaient multiples. Voilà ce que j’ai repéré sur les serveurs lors de mes investigations.

## Symptômes

### Doublons dans les friendly_names

Lorsque la migration a été faite, nous nous sommes appuyés sur le fait que nos volumes étaient répartis sur des miroirs LVM pour rendre la migration transparente. Les données ont été copiées sur un 3ème membre de miroir sur la nouvelle baie, puis un membre a été retiré sur l’ancienne baie. Et ainsi de suite jusqu’à ce que le miroir ne soit plus que sur les nouvelles baies.

Cependant, lorsque cette opération a été réalisée, l’OS s’est mélangé les pinceaux. Pour lui, il y avait eu plusieurs devices mpath bien distincts qui ont pourtant le même friendly_name.

Lors de la découverte des chemins multipaths à l’aide de la commande suivante, des messages d’erreur faisant état de doublons dans les noms mpathX s’affichaient :

```
# multipath -v2
remove: mpath9 (dup of mpath1)
mpath9: map in use
remove: mpath13 (dup of mpath2)
mpath13: map in use
```


### Mode ALUA 4 / PNR 1 pour les LUNs

Plus grave, lorsque le mode de détail supérieur est utilisé pour afficher les chemins (multipath -ll), de nombreux messages d’erreurs s’affichent !

```
multipath -ll
Path not correctly configured for failoverPath not correctly configured for failoverPath not correctly configured for failoverPath not correctly configured for failovermpath9 (36006016067302f00e4588d06345ee111)
[size=100 GB][features="1 queue_if_no_path"][hwhandler="1 emc"]
\_ round-robin 0 [active]
  \_ 0:0:5:3 sdd 8:48 [active][faulty]
  \_ 1:0:5:3 sdh 8:112 [active][faulty]
\_ round-robin 0 [enabled]
  \_ 0:0:4:3 sdc 8:32 [active][faulty]
  \_ 1:0:4:3 sdg 8:96 [active][faulty]
```


On remarque les erreurs en début de commande _Path not correctly configured for failover_ et surtout le fait que le chemin soit _\[active\]\[faulty\]_.

Après consultation de ressources en lignes et du « [EMC Host Connectivity Guide for Linux](https://web.archive.org/web/20190806192128/https://www.emc.com/collateral/TechnicalDocument/docu5128.pdf) » (lien mort, j'utilise Internet Archive), il semblerait que le mode « ALUA 4 actif actif» ne soit pas (totalement) supporté sur les serveurs Redhat Entreprise Linux 4, ce qui est exactement la version de mes serveurs Linux.

Il faut utiliser le mode « PNR 1 actif passif» qui lui est bien certifié.

![](/2015/10/02_Correction_Configuration_Multipath.png)


Après vérification, c’est pourtant bien ce mode « ALUA 4 » qui a été déclaré dans la baie EMC pour les chemins vers l’hôte au niveau du _Failover Mode_. On a là la première cause du dysfonctionnement.

### Démon multipathd

Les chemins étaient bien déclarés, visibles et fonctionnels, les modules multipath étaient bien chargés dans le kernel :

```
# multipath -l
mpath9 (36006016067302xxxx4588d06345ee111)
[size=100 GB][features="1 queue_if_no_path"][hwhandler="1 emc"]
_ round-robin 0 [active]
_ 0:0:5:3 sdd 8:48 [active]
_ 1:0:5:3 sdh 8:112 [active]
_ round-robin 0 [enabled]
_ 0:0:4:3 sdc 8:32 [active]
_ 1:0:4:3 sdg 8:96 [active]
[...]

# lsmod |grep dm
dm_mirror             32585 0
dm_round_robin         5185 1
dm_emc                7745 1
dm_multipath           22865 3 dm_round_robin,dm_emc
dm_mod                 76585 7 dm_mirror,dm_multipath
```


Cependant, le démon **multipathd** qui permet de gérer les bascules de chemins était lui hors service, ce qui est la seconde cause du non fonctionnement des bascules.

```
# service multipathd status
multipathd est arrêté
```


## Modification de la configuration pour correction

Idéalement pour toutes ces corrections, le serveur doit être non sollicités, les applications arrêtées. Les modifications qui sont effectuées peuvent très probablement avoir un impact sur les traitements en cours.

### Doublons dans les friendly_names

Pour résoudre le problème des doublons dans les friendly_names, il faut commencer récupérer les WWID de chaque disques, puis supprimer tous les chemins avec les commandes suivante :

```
multipath -l #affiche les chemins et leurs informations
multipath -F #flush de tous les chemins enregistrés
```


Une fois les chemins supprimés, il faut modifier le fichier de configuration **/etc/multipath.conf** pour y ajouter en fin de fichier la déclaration des WWID à associer à des friendly_names fixes :

```
multipaths {
  multipath {
    wwid "360060160da302fxxxxd388be2f5ee111"
    alias mpath0
  }
  multipath {
    wwid "36006016067302fxxxx588d06345ee111"
    alias mpath1
  }
}
```


Réenregistrer les chemins à l’aide de la commande :

```
# multipath -v2
```


### Mode ALUA pour les LUNs

Pour modifier le mode de configuration des LUNs, il faut se connecter sur la console Unisphere des baies de disques.

Une fois connecté, il faut ouvrir choisir une des baies, ouvrir le menu « Hosts » puis « Host List »

Sélectionner le serveur concerné dans la liste, puis ouvrir l’onglet « Initiators » en bas de page.

![](/2015/10/03_Correction_Configuration_Multipath.png)

Sélectionner un port, puis cliquer sur « Edit », et reconfigurer les 4 chemins.
 
![](/2015/10/04_Correction_Configuration_Multipath.png)

Valider, et recommencer l’opération sur l’autre baie de disques.

### Démon multipathd

ATTENTION : Le démarrage du démon multipath peut éventuellement provoquer une coupure des chemins, ce qui va planter le serveur et les traitements en cours s’il y en a. Il faut donc bien prendre garde que le serveur n’est plus utilisé lors de son activation.

```
chkconfig multipathd on
chkconfig --add multipathd
reboot #éventuellement
```


A partir de là, tout devrait revenir à la normale. En cas de coupure d’un chemin, multipathd se chargera de basculer sur un autre chemin (passif) et cela fonctionnera car nous sommes en mode PNR 1, qui est supporté sous RHEL 4.

## Retour arrière

Si pour une raison ou pour une autre la correction des anomalies ne se passaient pas comme elle le devrait, je vous laisse également quelques instructions provenant de mon plan de retour arrière.

### Doublons dans les friendly_names

Pas de procédure de retour arrière à proprement parlé. Une fois que les chemins ont été détruits puis reconfigurés, il ne devrait pas y avoir de problèmes.

On peut néanmoins revenir sur le fichier de configuration ne prenant pas en compte les nouveaux **friendly_names** déclarés

### Mode ALUA pour les LUNs

Retourner sur les baies de disques, et repasser l’ensemble des chemins en mode « ALUA 4 » avec la même procédure que plus haut.

### Démon multipathd

Dans le cas où un retour arrière est nécessaire, il suffit de passer les commandes suivantes pour désactiver multipathd :

```
chkconfig multipathd off
chkconfig --del multipathd
```
