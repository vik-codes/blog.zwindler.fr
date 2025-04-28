---
title: Client web pour version ESXi hors vCenter, le VMware Host Client
authors:
  - zwindler
type: post
date: 2016-05-26T11:55:27+00:00
url: /2016/05/26/client-web-pour-version-esxi-gratuite/
image: /2014/10/vmware.jpg
categories:
  - Virtualisation
tags:
  - client
  - ESX(i)
  - html5
  - javascript
  - vCenter
  - vSphere 6.X
  - Web

---
## VMware Host Client : Le Half Life 3 des clients d’administration des hyperviseurs

> Oui alors on a bien une version gratuite, pas de souci. Mais ... vous ne pourrez plus utiliser le client lourd. Du coup il vaudrait mieux que vous vous payez un vCenter pour l’administrer, non ?

Cela fait un moment que VMware nous a annoncé que le client lourd (Java) ne serait plus mis à jour avec les nouvelles fonctionnalités. Et il faut dire que ce n’était pas forcément simple car il fallait installer le client de **chaque** version mineure (par exemple 5.0, 5.1, 5.5) pour pouvoir vous connecter à toutes vos versions, pas simplement la plus récente. Mais il avait le mérite de plutôt bien marcher et restait une référence correcte.

![](/2016/05/vsphere.png)

Pour autant, on ne peut pas dire que l’alternative proposée par VMware ait été particulièrement crédible. Le vSphere Web Client, censé corriger tous les défauts de la version _client lourd_ avait quand même encore quelques gros défaut (mais certains étaient nouveaux alors c’est pas grave, non ?).

Pour avoir le vSphere Web Client, pas d’alternative, il vous faut vous payer un vCenter ! A quoi bon proposer un hyperviseur gratuit si c’est pour faire payer le client d’administration ? Ceci a longtemps été une vaste blague de la part de VMware avec aucune réponse officielle.

Pour autant votre client lourd reste vital pour certaines opération, comme l’accès direct aux ESXi sans passer par le vCenter. Le vCenter est down ? Dommage ! Vous pouvez ressortir le client lourd et tout refaire comme avant. Sauf ce que vous ne pouvez plus faire parce que réservé à la version **web client**.

Le vSphere Web Client nécessite l’installation de Flash sur le navigateur du poste d’administration, ainsi que plusieurs plugins à télécharger et à autoriser dans le navigateur pour pouvoir fonctionner à pleine capacité. Autant dire que l’avantage « c’est du web, donc 0 installation » vient instantanément de disparaitre...

Au delà de ces points rédhibitoires, le client web dans sa version actuelle est très lent et le serveur est assez gourmand en ressources (côté vCenter).

Bref on ne peut pas dire que je sois un grand fan. D’ailleurs, j’ai longtemps résisté à l’appel de la migration du hardware virtuel en v9, 10, et 11 car je savais que je ne pourrais plus modifier les paramètres (!!!) sur le client lourd une fois que ça aurait été fait (si le client web ne fonctionne plus, on fait quoi ? Oups...). Et oui, pas de mises à jour sur le client lourd ;-).

## ENFIN !

Et bien CA Y EST !

Introduit avec la v6 en « test », VMware a créé un composant VIB (composant pour ESXi, à installer sur le serveur directement pour ceux qui ne connaissent pas) qui fourni un serveur web avec les fonctionnalités de base pour piloter l’ESXi et les VMs. Attention le but n’est pas de remplacer le vCenter mais bien de combler le vide d’un serveur pour piloter votre ESXi directement, sans vCenter et sans utiliser le client lourd.

Voici la liste des opérations qui peuvent être réalisées depuis ce **Host Client :**

* Opérations basiques sur la machine virtuelle (démarrer, arrêter, etc)
* Afficher la console de la machine virtuelle
* Création d’une nouvelle machine virtuelle & déploiement d’un OVF/OVA
* Afficher les informations sur l’état de de l’hyperviseur
* Configuration du serveur ESXi et des ses composants comme vous le feriez avec le client lourd
* Opérations basiques sur l’ESXi comme le rebooter

Initialement, pour l’installer il fallait installer soit même le fichier VIB sur l’ESXi et le rebooter. Cependant le composant étant passé en version 1, il est directement intégré à la toute nouvelle version d’ESXi 6.0 Update 2.

## Les erreurs du passé

Et pour ne rien gâcher, même si l’interface web ressemble comme 2 gouttes d’eau au vSphere Web Client, il semblerait que VMware n’ait pas reproduit les erreurs du passé avec ce **VMware Host Client**, entièrement en HTLM5 et Javascript. Pas de Flash et de plugins navigateurs à installer, simplement le Javascript a autoriser sur les URLs de vos serveurs.

Dommage pour VMware que, faute d’une solution sans vCenter crédible, j’ai migré mon lab personnel sur KVM... ;-)

## Sources

* pubs.vmware.com/Release_Notes/en/vsphere/60/vmware-host-client-10-release-notes.html (lien mort comme tout chez VMware)
* [www.vladan.fr/esxi-free-web-client-interface/](http://www.vladan.fr/esxi-free-web-client-interface/)
