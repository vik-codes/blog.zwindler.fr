---
title: Migration mongoDB à chaud depuis une 3.4 vers une 4.0 (replicaSet)
authors:
  - zwindler
type: post
date: 2019-02-05T11:45:02+00:00
url: /2019/02/05/migration-mongodb-a-chaud-depuis-une-3-4-vers-une-4-0-replicaset/
image: /2019/01/mongo_upgrade-1.png
classic-editor-remember:
  - classic-editor
categories:
  - Cluster
  - Logiciel
tags:
  - ansible
  - mongodb
  - MongoDB 4.0
  - noSQL
  - replicaSet
  - Ubuntu
  - upgrade

---
## MongoDB

Depuis peu, j’administre des bases de données MongoDB !

Pour le fun (et ceux qui ne connaissent pas), la définition qu’en donne [Wikipedia][1] :

> **MongoDB** (de l’anglais _<span class="lang-en" lang="en">[humongous](https://fr.wiktionary.org/wiki/humongous)_ qui peut être traduit par « énorme ») est un [système de gestion de base de données][2] [orientée documents][3], [répartissable sur un nombre quelconque d’ordinateurs][4] et ne nécessitant pas de schéma prédéfini des données. Il est écrit en [C++][5]. Le serveur et les outils sont distribués sous [licence AGPL][6]{.new}, les pilotes sous [licence Apache][7] et la documentation sous [licence Creative Commons][8]<sup id="cite_ref-licensing_2-1" class="reference"></sup>. Il fait partie de la mouvance [NoSQL][9].

Comme dans la vie de tout projets, on installe un logiciel, et sur le moment ça nous suffit, on est contents.

Mais arrive le jour fatidique où le logiciel est obsolète et il faut mettre à jour la base. Sans aucun créneau de maintenance pour le faire bien entendu car elles sont évidemment utilisées en production ;-).

## Prérequis

Bon point pour moi, je n’ai pas fais l’erreur d’avoir une base de données mongoDB « standalone ». Je dispose de cluster de bases de données MongoDB (replicaSet, dans la terminologie mongo), que je vais donc pouvoir mettre à jour à chaud. Ça sera juste un peu plus long ;-).

## 3.4 => 4.0 = pas possible

Bon quand même, fallait bien que je tombe dans le piège.

La version majeure 3.4 (la dernière en date est la .19) ne peut pas directement être mise à jour vers une 4.0. Comme c’est une majeure, il faut passer d’abord par la majeure suivante, la 3.6 (c’est classique comme limitation).

## On passe en 3.6 alors

Pour me simplifier la vie, j’ai un mini playbook Ansible qui me permet d’ajouter les dépôts en fonction de la version que je veux.

```
- name: Prepare mongodb upgrade
  hosts: all
  vars:
    #mongo_repo : "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse"
    mongo_repo: "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse"
    #mongo_repo: "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse"
  tasks:
  - name: "Add mongodb repository key"
    apt_key:
      keyserver: keyserver.ubuntu.com
      id: "{{item}}"
      state: present
    loop:
      - 0C49F3730359A14518585931BC711F9BA15703C6
      - 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
      - 9DA31620334BD75D9DCB49F368818C72E52529D4
  - name: "Add mongodb repository"
    apt_repository:
      repo: "{{ mongo_repo }}"
      state: present
      update_cache: yes
```


Clairement, on peut faire plus propre. Ici, c’est du oneshot sur quelques machines Ubuntu, donc je n’ai pas automatisé plus que ça. Mais si vous avez plus de machines à faire que moi, je vous invite à le raffiner un peu, par exemple en ajoutant le repo et la clé en fonction de la version donnée en paramètre.

```
ansible-playbook -i inventory/prod/mongo-prod prepare_mongo_upgrade.yml -b
```


## Mise à jour des binaires vers la 3.6

Maintenant qu’on a bien les dépôts pour la version 3.6, on peut mettre à jour nos serveurs. Idéalement si on avait de nombreux clusters à migrer, il faudrait le faire avec un playbook Ansible (ou autre) qui passe sur les serveurs, uns par uns, les mets à jour et les redémarre.

Cependant, pour simplifier l’explication, je vais laisser la procédure telle quelle et tout faire à la main.

Sur les SECONDARY, **uns par uns**, mettre à jour manuellement le serveur, puis le redémarrer :

```
apt-get update
apt-get upgrade mongodb-org-server mongodb-org-shell
[...]
Unpacking mongodb-org-server (3.6.10) over (3.4.19) ...
[...]

systemctl restart mongod
```


Vérifier que tout fonctionne à nouveau après redémarrage

```
mongo
MongoDB shell version v3.6.10
connecting to: mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("17272d4e-ecd0-49c2-a672-8804227ab0e4") }
MongoDB server version: 3.6.10
rs:SECONDARY> 
```


Puis, se connecter sur le PRIMARY, et lui passer la commande suivante (qui va avoir pour effet de le rétrograder proprement et temporairement en tant que SECONDARY) :

```
$> mongo
rs:PRIMARY> use admin
switched to db admin
rs:PRIMARY> db.auth('myadmin', 'myawesomepassword')
1
rs:PRIMARY> rs.stepDown(180)
[...]
2019-01-25T15:23:02.520+0000 I NETWORK  [thread1] trying reconnect to 127.0.0.1:27017 (127.0.0.1) failed
2019-01-25T15:23:02.548+0000 I NETWORK  [thread1] reconnect 127.0.0.1:27017 (127.0.0.1) ok
rs:SECONDARY> 
```


Et enfin, mettre à jour manuellement le serveur de la même manière que les autres :

```
apt-get update
apt-get upgrade mongodb-org-server mongodb-org-shell
systemctl restart mongod
```


## Compatibilité 3.6

Ici, je viens de faire la migration de 3.4 vers 3.6. En réalité, ce n’est pas complètement terminé. L’ensemble des binaires ont beau être en version 3.6, la base elle, reste en « compatibilité » 3.4.

Pour s’en assurer, une connexion sur n’importe quel serveur permet de le vérifier :

```
$> mongo
rs:SECONDARY> db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )
{ "featureCompatibilityVersion" : { "version" : "3.4" }, "ok" : 1 }

```


On va donc aller sur le nœud PRIMARY pour passer la base en compatibilité 3.6 (le seul prérequis est qu’une majorité de serveurs aient leurs binaires mis à jour en 3.6 et redémarrés) :

```
$> mongo
MongoDB shell version v3.6.10
connecting to: mongodb://127.0.0.1:27017/?gssapiServiceName=mongodb
Implicit session: session { "id" : UUID("aaa-aaa-aaa-aaa-aaa") }
MongoDB server version: 3.6.10
rs:PRIMARY> db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )
{ "featureCompatibilityVersion" : { "version" : "3.4" }, "ok" : 1 }

rs:PRIMARY> use admin
switched to db admin
rs:PRIMARY> db.auth('myadmin', 'myawesomepassword')
1
rs:PRIMARY> db.adminCommand( { setFeatureCompatibilityVersion: "3.6" } )
{ "ok" : 1 }

rs:PRIMARY> db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )
{ "featureCompatibilityVersion" : { "version" : "3.6" }, "ok" : 1 }
```


OK ! on a fait la moitié du chemin...

## Mettre à jour le ReplicaSet dans la version 1

Différence notable entre la version 3.4 et la version 3.6, c’est la façon dont sont gérés les replicaSets. La version 3.6 introduit la version 1 du protocol des replicaSet, et empêche les précédents clusters déclarés de fonctionner.  
Il est donc nécessaire de mettre à jour le protocole **avant** de mettre à jour en 4.0.

Ouvrir un shell mongo sur le PRIMARY, et modifier la configuration du replicaset (rs) :

```
cfg = rs.conf();
cfg.protocolVersion=1;
rs.reconfig(cfg);
```

## Mise à jour des binaires vers la 4.0

Bon, je ne vais pas vous refaire l’affront de vous copier coller la procédure de mise à jour : maintenant qu’on a mis à jour la version du replicaSet, c’est la même.

Pour rappel :

* Relancer le playbook pour ajouter le dépôt de la version 4.0 (décommenter la ligne 4.0)
* Mise à jour des serveurs SECONDARY puis redémarrage du serveur
* Step down du PRIMARY   
* Mise à jour du PRIMARY devenu SECONDARY après le stepdown, puis redémarrage du serveur
* Mise à niveau de la compatibilité de la base en 4.0

```
rs:PRIMARY> db.adminCommand( { setFeatureCompatibilityVersion: "4.0" } )
{
  "ok" : 1,
[...]
}
rs:PRIMARY> db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )
{
  "featureCompatibilityVersion" : {
    "version" : "4.0"
  },
[...]
}
```

Et voilà, votre cluster est « up-to-date », après 2 upgrades de versions majeures et sans aucune interruption de service. Alors, comme on dit chez moi :

> Encore une victoire de Canard !

source : [player.ina.fr/player/embed/PUB417943064/1/1b0bd203fbcd702f9bc9b10ac3d0fc21](https://player.ina.fr/player/embed/PUB417943064/1/1b0bd203fbcd702f9bc9b10ac3d0fc21)

## Sources

  * [La documentation d’installation de MongoDB][11]
  * [La documentation officielle de mise à jour d’un replicaSet MongoDB vers 3.6(lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20220705195701/https://www.mongodb.com/docs/manual/release-notes/3.6-upgrade-replica-set/)
  * [La documentation officielle de mise à jour d’un replicaSet MongoDB vers 4.0 (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20230325023508/https://www.mongodb.com/docs/manual/release-notes/4.0-upgrade-replica-set/)
  * [La documentation officielle de la commande stepdown][14]

 [1]: https://fr.wikipedia.org/wiki/MongoDB
 [2]: https://fr.wikipedia.org/wiki/Syst%C3%A8me_de_gestion_de_base_de_donn%C3%A9es "Système de gestion de base de données"
 [3]: https://fr.wikipedia.org/wiki/Base_de_donn%C3%A9es_orient%C3%A9e_documents "Base de données orientée documents"
 [4]: https://fr.wikipedia.org/wiki/Scalability "Scalability"
 [5]: https://fr.wikipedia.org/wiki/C%2B%2B "C++"
 [6]: https://fr.wikipedia.org/w/index.php?title=Server_Side_Public_License_(SSPL)&action=edit&redlink=1 "Server Side Public License (SSPL) (page inexistante)"
 [7]: https://fr.wikipedia.org/wiki/Licence_Apache "Licence Apache"
 [8]: https://fr.wikipedia.org/wiki/Licence_Creative_Commons "Licence Creative Commons"
 [9]: https://fr.wikipedia.org/wiki/NoSQL "NoSQL"
 [10]: /2019/01/encore_une_victoire.png
 [11]: https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
 [14]: https://docs.mongodb.com/manual/reference/method/rs.stepDown/#rs.stepDown
