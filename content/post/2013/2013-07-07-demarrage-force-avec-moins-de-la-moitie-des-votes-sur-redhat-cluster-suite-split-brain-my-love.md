---
title: Démarrage forcé avec moins de la moitié des votes sur Redhat Cluster Suite (split brain my love)
authors:
  - zwindler
type: post
date: 2013-07-07T21:01:27+00:00
url: /2013/07/07/demarrage-force-avec-moins-de-la-moitie-des-votes-sur-redhat-cluster-suite-split-brain-my-love/
image: /2014/03/lbvm1.png
categories:
  - Cluster
  - Système
tags:
  - demarrage forcé
  - force start
  - Quorum
  - Quorum disk
  - Redhat Cluster Suite
  - RHCS
  - Split brain
  - vote

---
Dans le cas où vous avez mis en place un cluster Redhat Cluster Suite sur votre infrastructure et que vous avez plusieurs salles distantes, vous êtes certainement tombé sur l’expression « split brain » (cf [Split Brain sur Wikipedia](http://fr.wikipedia.org/wiki/Split-brain)). Généralement, il est intéressant de pouvoir empêcher deux serveurs en clusters qui ne se voient plus de fonctionner en même temps, c’est pourquoi avec RHCS il est possible sur des clusters 2 nœuds d’ajouter un disque SAN appelé Quorum Disk qui sert d’arbitre.

Cependant, il arrive des fois où les protections du cluster vous empêche de redémarrer, typiquement lorsque vous n’avez qu’une seule salle serveur disponible!

Revenons en arrière et imaginons que comme moi, vous disposez de :

* une salle primaire composée d’un nœud du cluster et d’un SAN avec une moitié de miroir et un quorum disk
* une salle secondaire composée d’un nœud du cluster et d’un SAN avec une moitié de miroir

Cela vous fait donc 3 votes (2 nœuds, 1 quorum sur le SAN), vous êtes relativement contents. Si l’interconnexion tombe totalement (SAN + LAN), les deux salles seront isolées l’une de l’autre, et la salle secondaire n’ayant pas accès au quorum sera donc coupée par le cluster par manque de votes. La salle primaire fonctionnera toujours avec sa partie du miroir. Si c’est uniquement un des deux serveurs qui tombe en panne, le second et le quorum feront toujours 2 votes, ce qui sera là aussi suffisant.

Imaginons maintenant que la salle primaire a été victime d’une attaque à la batte de baseball (risque relativement courant dans les salles serveurs), il est fort à parier que votre boss sera en train de vous crier dessus pour vous motiver à redémarrer votre infrastructure dans les plus brefs délais sur la salle secondaire.

Pourtant, en l’absence d’un second vote (on se rappelle, le quorum a été ratatiné par une batte), le cluster refusera de démarrer. Et pas la peine d’essayer de tricher en modifier le poids du nœud restant, la commande « **ccs_tool update** » refusera de mettre à jour un cluster qui a été dissolu et pas proprement reformé (ce qui s’annonce difficile).

La commande suivante vous sauvera la vie en vous permettant de modifier arbitrairement la quantités de votes « attendus » (comprenez **nécessaires**) par le cluster pour accepter de démarrer. Vous pourrez repartir sur votre salle secondaire. Elle est pas belle la vie ;-) ?

```
cman_tool expected -e 1
```

**Attention tout de même, si jamais vous veniez à reconstruire le cluster (rétablissement de la liaison entre les deux salles) et que les deux salles ont toutes les deux été actives sur le SAN, votre miroir sera bien évidemment bon à jeter à la poubelle. A utiliser avec parcimonie et connaissance de cause...**

Plus d’infos sur cman_tool sur la page man (ou sur le net)

```
man cman_tool
```

[Édit]La dernière fois que je l’ai utilisée j’ai du redémarrer d’abord le clusters via lucide PUIS lancer la commande pendant l’initialisation. A ce moment là, il cherche pendant un moment le reste du clusters puis abandonne, ce qui empêche rgmanager de fonctionner correctement. [/Édit]
