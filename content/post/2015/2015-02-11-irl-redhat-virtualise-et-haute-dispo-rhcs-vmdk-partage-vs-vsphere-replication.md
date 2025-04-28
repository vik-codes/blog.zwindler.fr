---
title: '[IRL] RedHat virtualisé et haute dispo, RHCS+VMDK partagés vs vSphere Replication'
authors:
  - zwindler
type: post
date: 2015-02-11T14:58:49+00:00
url: /2015/02/11/irl-redhat-virtualise-et-haute-dispo-rhcs-vmdk-partage-vs-vsphere-replication/
image: /2015/02/rhcs.png
categories:
  - Cluster
  - Stockage
  - Système
  - Virtualisation
tags:
  - DRBD
  - EMC²
  - ESX(i)
  - LVM
  - mdadm
  - mirroring LVM
  - PRA
  - qdisk
  - RAID
  - RedHat High Availability
  - RHCS
  - RTO/RPO
  - VMDK
  - VMDK partagé
  - VNX5200
  - vSphere 5.0
  - vSphere 5.1
  - vSphere 5.5
  - vSphere Replication

---
## Contexte

Dans un contexte professionnel, il arrive que des décisions soient prises et qu’il faille s’y tenir coute que coute. Même si on se rend compte plus tard que ce n’était pas forcément le chemin le plus facile. La facilité, c’est le côté obscur, on le sait bien ;-).

Pour un client, on m’a donc demandé de concevoir une plateforme RedHat 5.X virtualisée hautement disponible, avec une durée d’interruption de service maximale de 30 minutes en toute circonstance (jusque là tout va bien), **ET** la possibilité de restaurer les disques des OS virtuels avec plusieurs points de restaurations par palliers de 30 minutes (RPO/RTO). _Aie!_

Tel le Mac Giver des temps modernes, je dispose des outils suivants pour y parvenir :

  * 1 licence vSphere Essential Plus
  * 2 serveurs physiques, installés en ESXi 5.5 et reliés en SAN
  * 2 baies de disques EMC² VNX5200
  * 2 souscriptions RedHat Datacenter - pour disposer d’autant de VMs RHEL qu’on le souhaite sur nos deux nœuds physiques
  * 2 souscriptions RedHat High Availability (anciennement RedHat Cluster Suite) en mode Datacenter - pour disposer d’autant de clusters RedHat qu’on le souhaite sur nos deux nœuds physiques

## Clusters RHCS et VMDK partagés ou RDM

Comme vous pouvez le deviner avec la dernière ligne, on m’a demandé d’utiliser les licences qui avaient été achetées. Donc de déployer du cluster RHCS à tour de bras, pour faire des paires de VMs et simuler ce que l’on fait habituellement sur des paires de machines physiques.

Sauf qu’à tenter de faire des clusters RHCS sur des machines virtuelles VMware, on trouve vite toute sortes de petits désagréments.

_**Note** : Je vous demanderai de bien vouloir faire abstraction du fait que c’est vraiment « bourrin » de doubler des VMs lorsqu’on dispose d’un cluster vSphere. En fait, si j’en suis arrivé là, c’est parce qu’un simple cluster VMware HA ne répond pas à l’ensemble des besoins énoncés plus haut. C’est possible, bien sûr, mais il faut aller creuser peu plus loin (cf la fin de l’article)._

### Prérequis

VMware et RedHat supportent l’utilisation de cluster RHCS dans sur des machines virtuelles avec les obligations suivantes :

  * Support de vSphere 5.1 uniquement à partir de RHEL 5u9 ou 6u4
  * Support de vSphere 5.5 uniquement à partir de RHEL 5u11, 6u6 ou 7
  * Support du partage de disques via RDM à partir RHEL 5u7
  * Support du partage de VMDK à partir de RHEL 5u9

(Voir [ici pour plus d’infos](https://access.redhat.com/articles/29440))

Idéalement, il faut donc disposer de machines virtuelles RHEL 5u11 et de vSphere en version 5.5 (version la plus à jour si on met de côté la 6 qui va sortir), mais on peut se « contenter » d’une version RHEL 5u9 en installant une version plus ancienne de vSphere (5.1).

Le cas le plus défavorable est l’utilisation de vSphere 5.0 avec un RHEL 5u7 ou 5u8. Dans ce cas, seul le partage de disques via RDM est possible et un bug connu dans la version 5.0 de vSphere empêche le fonctionnement opérationnel du cluster (au niveau du fencing).

Au-delà, ce n’est pas supporté.

### Architecture

![](/2015/02/rhcs.png)

### Cas de panneS

Les disques OS sont installés en RAID 1 MDADM avec 2 VMDKs situés sur les deux baies.

Si ce n’est pas le cas, en cas de la perte de la baie de disques hébergeant l’OS du nœud maitre, le serveur deviendra instable mais ne pourra pas se saborder d’elle-même correctement, plantant le cluster et l’application.

Pire, s’il s’agit de la baie de disques qui héberge le **quorum disk**, le cluster ne disposera plus d’assez de votes pour fonctionner et le redémarrage devra être forcé à la main.

En cas de corruption du disque OS du nœud actif, les packages basculeront sur l’autre VM.

En cas de panne de l’ESXi, les packages actifs pourront basculer sur le nœud présent sur l’autre serveur.

En cas de perte de la baie de disques, les données seront toujours accessibles par les deux VMs grâce à l’autre membre du miroir.

Même si la baie hébergeant le quorum tombe en panne, on disposera toujours de deux votes (les deux nœuds du cluster).

### Limitations et problématiques de la solution

#### VMware et Contrôleur Physique

Pour partager des disques durs virtuels (RDM ou VMDK), il faut ajouter à la machine virtuelle un « contrôleur de disques SCSI » en « compatibilité physique ». Ceci a pour conséquence de limiter les fonctionnalités disponibles dans VMware :

  * Pas de live vMotion (bascule de VM à chaud)
  * Pas de snapshots
  * Pas de sauvegarde via l’API VMware (sauvegarde des VMs via l’ESXi « clientless » et sauvegarde granulaire)

#### RHCS et nombre de votes

La salle primaire héberge le quorum disk qui permet de favoriser la salle primaire en cas de « split brain » (voir mon article sur [le démarrage forcé sous RHCS](/2013/07/07/demarrage-force-avec-moins-de-la-moitie-des-votes-sur-redhat-cluster-suite-split-brain-my-love/)). Ce mécanisme de sécurité permet d’empêcher d’avoir 2 salles autonomes en même temps ce qui aura pour conséquence de corrompre les données du SI.

Le cas défavorable de la perte de la salle primaire complète induit un problème important qui ne peut pas être adressé simplement. Dans ce cas de figure, il n’y a plus assez de votes pour que le cluster fonctionne, et l’application s’éteint.

Il est donc nécessaire de redémarrer manuellement les clusters. Dans l’absolu, ce n’est qu’une commande à passer, mais dans mon cas, j’ai un nombre important de clusters à gérer. La personne d’astreinte ne pourra jamais tenir les SLA de 30 minutes d’indisponibilité.

Il me parait impossible d’automatiser proprement cette relance du cluster, car c’est un mécanisme trop sensible et les risques de corruption de données sont trop important.

#### LVM vs MDADM

Dans la structure pour laquelle je travaille, l’utilisation du mirroring LVM est un choix technique historique héritée de nos clusters MCSG sous HP-UX.

Sous RHEL 5.X, la gestion des miroirs LVM est complexe et peu adaptée :

  * l’agrandissement des volumes nécessite une suppression du miroir, rendant les données temporairement non redondée et réduisant les performances.
  * la perte de l’interconnexion - même temporaire - a des effets de bords qui nécessitent également de tout reconstruire et de tout resynchroniser entièrement (membres de miroirs perdus mais pas tous remontés comme tels).

A l’inverse, l’agrandissement d’un disque via MDADM peut se faire à chaud (on agrandi un VMDK, puis l’autre), et la perte temporaire d’un membre ne nécessite pas de le reconstruire complètement.

Une dernière option - idéale techniquement - est l’utilisation de la réplication de « blocs devices » par [DRBD (société LinBIT)](http://drbd.linbit.com/). Elle a été rejetée pour cause d’absence de support de la part de RedHat mais permet de faire exactement ce que l’on souhaite : répliquer des disques au niveau bloc entre deux VMs.

## Réplication des VMDK via vSphere Replication

Et voilà la solution que j’aurai aimé étudier. La facilité. **Le côté obscur donc**.

### Prérequis

Pour utiliser la fonctionnalité vSphere Réplication, il faut disposer d’une licence vSphere Essential Plus (ou mieux), d’un vCenter et de deux datastores distincts.

### Architecture

![](/2015/02/vsphere_replication.png)

### Réplication du disque OS de la VM

Avec la licence vSphere Essential Plus, il est possible de réaliser un « pseudo PRA » à l’aide de la fonctionnalité vSphere Replication.

La machine virtuelle n’est pas doublée comme dans l’architecture précédente. Ici VMware réplique son VMDK en fil de l’eau vers un Datastore secondaire.

En cas de panne quelconque sur la salle primaire, on bascule la VM sur le serveur ESXi secondaire et on la redémarre sur le disque répliqué (opération manuelle).

En cas de corruption des filesystems sur le disque OS, on dispose de plusieurs points de restauration dans le temps nous permettant de revenir à un état précédent fonctionnel.

### Limitations et problématiques de la solution

Malheureusement je n’ai pas eu l’occasion de le tester, la solution choisie n’étant pas cette solution. Cependant, au vu des besoins énoncés et des ressources à ma disposition, cette solution me parait être celle qui répond à tous les besoins et toutes les problématiques.
