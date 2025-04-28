---
title: Best Practices pour Quorum Redhat Cluster Suite
authors:
  - zwindler
type: post
date: 2014-03-31T13:51:11+00:00
url: /2014/03/31/best-practices-pour-quorum-redhat-cluster-suite/
image: /2014/03/lbvm1.png
categories:
  - Cluster
  - Système
tags:
  - best practices
  - CMAN
  - heuristic
  - multipath
  - powerpath
  - qdisk
  - Quorum
  - Quorum disk
  - Redhat Cluster Suite
  - RHCS
  - timeout
  - Totem
  - Totem Token

---

Si vous avez déjà installé un cluster RHCS, vous saurez sûrement qu’il y a un certain nombre de paramètres qui semblent un peu arbitraires, et qui sont surtout assez mal définis chez Redhat. Je parle du totem token, du **quorum\_dev\_poll** et surtout de comment ils dépendent les uns avec les autres. Ces différentes valeurs correspondent à des durées de timeout sur les différents composants qui régissent le cluster.

C’est pourtant d’autant plus important à comprendre que, si vous laissez les valeurs initiales, vous pourrez avoir de vilaines surprises en cas de bascule **multipath** d’un chemin.

Personnellement, j’ai eu le cas sur un cluster hébergé chez un prestataire. Celui ci a réalisé des opérations sur son SAN, normalement transparentes, qui ont eu la fâcheuse conséquence de mettre en carafe toute l’infrastructure.

Ce qui s’est réellement passé, c’est que le timeout de **multipath** étant autour des 45 secondes en dur, les valeurs par défaut de perte du quorum était trop courte et le serveur se sabordait, pensant avoir perdu la cohérence du cluster.

Pour s’y retrouver, Redhat a publié un papier qui, à défaut d’expliquer ce à quoi correspond exactement chaque variable, détaille les best practices pour les fixer.

Les règles définies ci-dessous permettent de positionner les différentes variables qui réglementent les différents timeout d’un cluster Redhat Cluster Suite. Ces règles sont tirées du pdf du support Redhat « rhel\_cluster\_qdisk.pdf »

## Règles à respecter

Les valeurs mises en gras sont celles qui sont dépendantes les unes des autres

### Variable token du composant Totem

La variable _token_ du composant _totem_ doit respecter la formule suivante

```
<totem token > 2 * quorumd tko * interval
```

Donc pour la configuration du _quorumd_ suivante (_interval_ en secondes)

```
<quorumd label="myQDisk" interval="1" tko="10" min_score="1" votes="1">
```

On devra avoir _totem token_ (en millisecondes) à

```
<totem token="21000"/>
```

### Variable quorum\_dev\_poll de CMAN

La variable _quorum\_dev\_poll_ de _CMAN_ doit être égale à la variable _totem token_

```
cman quorum_dev_poll = totem token
```

Dans une configuration de base on aura

```
<cman expected_votes="3" quorum_dev_poll="21000"/>
[…]
<totem token="21000"/>
```

### Variables tko et interval des heuristiques

Le produit de l’_interval_ et du _tko_ d’une _heuristique_ doit être inférieur ou égal au produit de l’_interval_ et du _tko-1_ du _quorumd_.

```
heuristics tko*interval <= quorumd interval*(tko-1)
```

Dans une configuration de base on aura

```
<quorumd label="myQDisk" interval="1" tko="10" min_score="1" votes="1">
[…]
<heuristic program="ping -c1 -w1 192.168.2.1" score="1" interval="2" tko="4" />
```

De plus, une heuristique doit avoir un `tko > 1`

### Variables expected_votes de CMAN

La variable expected_votes de CMAN doit être égale à la formule suivante

```
Nombre de nœuds du cluster * 2 - 1
```

Quand on a 2 nœuds, c’est donc 3 votes, quand on a 3 nœuds c’est 5, etc.

### Variable votes de quorumd

La valeur de la variable _votes_ du _quorumd_ doit être égale à la formule suivante

```
Nombre de nœuds du cluster - 1
```

Quand on a 2 nœuds, c’est donc 1 votes, quand on a 3 nœuds c’est 2, etc.

### Règle sur les nœuds

Tous les nœuds du cluster doivent avoir un vote

```
<clusternode name="node1.example.org" votes="1" nodeid="1">
[…]
```

### Variable two_node de CMAN

Seul cas de doute pour moi, il existe une variable two_nodes de CMAN. Je ne sais pas dire si la Best Practices indique que cette valeur doit valoir 0 ou ne pas être présente...

## Configurations fonctionnelles IRL

### Exemple de la configuration d’origine pour un cluster à 2 nœuds

```
<clusternode name="node1.example.org" votes="1" nodeid="1">
[…]
<clusternode name="node2.example.org" votes="1" nodeid="2">
[…]
<quorumd label="myQDisk" interval="1" tko="10" min_score="1" votes="1">
[…]
<heuristic program="ping -c1 -w1 192.168.2.1" score="1" interval="2" tko="4" />
<cman expected_votes="3" quorum_dev_poll="21000"/>
[…]
<totem token="21000"/>
```

### Configuration modifiée pour PowerPath sur un cluster à 2 nœuds

Lorsqu’on utilise du multipathing ou powerpath pour réduire le nombre de SPOF du cluster, il est nécessaire de s’assurer que la perte et le basculement d’un lien se fait plus rapidement que le temps fixé par le cluster pour déterminer un échec.

Le produit des attributs _interval * tko_ de _quorumd_ doit donc être supérieur au temps nécessaire pour une bascule complète du lien multipath.

Les autres valeurs doivent être ensuite calculées _à partir de ces deux attributs et des règles définies plus haut_. A priori, on trouve sur les sites de la communauté d’EMC que les chemins peuvent prendre 45 secondes pour basculer. Ces valeurs se vérifient sur mes clusters en production.

Il Je préfère donc donner 50 secondes de battement au quorum disk avant de considérer le quorum comme perdu!

```
<clusternode name="node1.example.org" votes="1" nodeid="1">
[…]
<clusternode name="node2.example.org" votes="1" nodeid="2">
[…]
<cman expected_votes="3" quorum_dev_poll="101000"/>
[…]
<totem consensus="4800" join="60" token="101000" token_retransmits_before_loss_const="20"/>
<quorumd label="myQDisk" interval="5" tko="10" min_score="1" votes="1">
<heuristic program="ping -c1 -w1 192.168.2.1" score="1" interval="5" tko="9" />
<quorumd>
```
