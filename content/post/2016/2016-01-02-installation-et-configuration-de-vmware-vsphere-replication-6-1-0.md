---
title: '[Tutoriel] Installation et configuration de VMware vSphere Replication 6.1.0'
authors:
  - zwindler
type: post
date: 2016-01-02T09:00:34+00:00
url: /2016/01/02/installation-et-configuration-de-vmware-vsphere-replication-6-1-0/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - Entreprise Plus
  - Essential Plus
  - 'Invalid URI : The format of the URI could not be determined'
  - NIOC
  - PRA
  - RPO
  - vSphere 5.X
  - vSphere 6.X
  - vSphere Replication

---
## Présentation de VMware vSphere Replication

Une fonctionnalité sympathique (au moins sur le papier) lorsqu’on achète une licence VMware à partir de la très agressive Essential Plus est la possibilité de se créer un PRA automatisé via l’appliance VMware vSphere Replication.

L’idée est simple. Vous déployez l’appliance sur un ou plusieurs vCenter, puis vous sélectionnez les machines virtuelles que vous souhaitez synchroniser entre vos sites (ou sur un même site, cela créera une copie de sauvegarde) et régulièrement votre cluster VMware se charge d’en avoir une copie complète (mais en envoyant que le delta) à moins de X minutes de retard (Recovery Point Objective).

En réalité, le produit n’est ni plus ni moins qu’un équivalent de ce que font vos produits de sauvegarde de VM et qui tirent eux même partie des API de sauvegarde à chaud de VM mis à disposition par VMware (sauvegarde via snapshot, change block tracking, ...). Je pense que ce produit se positionne comme concurrent des produits des grands éditeurs de la sauvegarde de VM (VEEAM pour n’en citer qu’un) et qui proposent pratiquement tous cette fonctionnalité.

## Déploiement

Les captures d’écrans proviennent en partie d’un déploiement de vSphere Replication 5.8.1 mais il faut savoir que la procédure est strictement identique pour vSphere Replication 6.1.0. Je n’ai remonté aucune différence notable entre les deux outre le fait que l’une est pour un vCenter en version 5.X lorsque l’autre fonctionne avec un vCenter 6.X.

Récupérez le fichier zip contenant les sources de l’OVF de l’appliance vSphere Replication sur le site de VMware.

Pour la version 5.8.1 (vSphere 5.X)

* VMware-vSphere_Replication-5.8.1.10254-2915556.zip (lien mort)
* Administration de vSphere Replication 5.8 (lien mort, comme tout chez VMware)

Pour la version 6.1.0 (vSphere 6.X)

* VMware-vSphere_Replication-6.1.0.10819-3051487.zip (lien mort)
* Administration de vSphere Replication 6.1 (lien mort, comme tout chez VMware)

Connectez vous ensuite sur la console (client lourd ou web) et déployez l’OVF.

![](/2015/12/01.png)

![](/2015/12/02.png)

Pendant la phase de déploiement, renseignez le DNS, la passerelle, le netmask, puis l’adresse IP et le mot de passe root.

![](/2015/12/03.6.png)

![](/2015/12/03.1.png)

/!\ ACHTUNG : **Avant** de démarrer la VM, renseignez le hostname de la machine dans votre DNS et assurez vous bien que la machine y accède. C’est particulièrement vrai à partir de vSphere 6 où le problème s’est clairement amplifié et où aucuns de vos produits ne marcheront si votre DNS n’est pas correctement configuré (vCenter, Update Manager, vSphere Replication).

Bootez la machine virtuelle une fois que le déploiement est terminé. S’il y a eu une autre appliance précédemment enregistrée sur le vCenter, vous devrez valider en arrivant sur l’écran suivant :

![](/2015/12/04.1.png)

Si tout se passe bien, on doit obtenir  ceci dans la console.

![](/2015/12/04.6.png)

Ouvrez un navigateur web pour finaliser la configuration de l’appliance via l’URL indiquée dans la console `https://@IP_configurée:5480/`

![](/2015/12/05.1.png)

Vérifiez que les paramètres sont bons sur la console (les paramètres sont basiques).

![](/2015/12/06.11.png)

Il faut ensuite vérifier que le serveur de réplication est bien connecté au serveur vCenter dans l’onglet VR/Configuration. Si ce n’est pas le cas, renseignez les logins/mdp du vCenter pour que l’appairage se fasse, puis cliquez sur « Save and Restart Service ».

Si tout fonctionne, la console doit afficher « VRM Service is running ».

![](/2015/12/06.5.png)

De même, sur le client web vSphere, un nouveau module « vSphere Replication » apparait sur la page d’accueil.

![](/2015/12/07.png)

Si vous souhaitez simplement disposer de la réplication sur un seul et même site, vous pouvez vous contenter de cette appliance.

Par contre, dans le cas où vous voudriez plutôt exporter les machines virtuelles sur un site de secours piloté par un autre vCenter, il faudra déployer une seconde appliance sur le deuxième site en suivant la même procédure.

**Attention :** les deux appliances doivent avoir la même version sinon elles ne communiqueront pas correctement. Et c’est donc potentiellement un problème car pour un vCenter 6.X, il vous faut une appliance vSphere Replication 6.1, et pour un vCenter 5.X une vSphere Replication 5.8. On en déduit donc que vos deux clusters doivent être de même version (5.X ou 6.X).

## Configurer la réplication

Ouvrez maintenant la liste des machines virtuelles « Hôtes et clusters », puis faites un [clic droit] sur une machine virtuelle à répliquer.

![](/2015/12/08.png)

Sélectionnez « Répliquer vers un système vCenter Server » dans tous les cas (c’est à dire, que le vCenter soit distinct sur un site de secours ou que vous souhaitiez rester au sein du même cluster).

![](/2015/12/09.png)

Vous aurez donc le choix du site cible. Soit vous sélectionnez le vCenter local, soit vous ajoutez un site (vCenter) distant.

![](/2015/12/10.png)


La première fois, seul le vCenter local apparaît. Si vous voulez en ajouter un autre, cliquez sur « Ajouter un site distant ». Remplissez les informations de connexion et un nouveau vCenter devrait apparaître dans la liste.

![](/2015/12/11-1.png)

Cet écran est particulièrement intéressant puisqu’il nous permet de régler le RPO (Perte de données maximale admissible) ce qui aura bien entendu un impact sur la quantité de données qu’on va perdre en cas de bascule sur le PRA mais aussi la fréquence à laquelle les données entre sites seront synchronisées.

![](/2016/01/12.png)

Une fois que c’est terminé, on peut observer l’état de santé de la réplication dans la page « Surveiller » du vCenter.

![](/2015/12/13.png)

Et pour finir, les paramètres de la réplication peuvent être modifiés en ouvrant la page « Gérer » du vCenter.

![](/2015/12/15.png)

## Troubleshooting

La plupart des erreurs que vous pouvez avoir lors du déploiement des appliances VMware (que ce soit le vCenter VCSA ou le vSphere Replication) sont liés à des problèmes de résolution DNS. Comme les déploiements sont relativement longs donc je vous conseille vivement de bien vérifier que vos DNS sont bien à jour et que toutes les machines résolvent bien tous les noms, sinon vous devrez probablement tout recommencer.

> Erreur « Invalid URI : The format of the URI could not be determined ».

Dans mon cas, le hostname du vCenter ne correspondait pas avec l’entrée dans le DNS et l’appliance de réplication n’arrivait pas à résoudre le vCenter.

L’icône refusait d’apparaître dans la console vCenter. Quand j’essayais d’ajouter manuellement le plugin à la main dans la console vSphere Client, le message suivant pouvait être lu dans le log de débug.

![](/2015/12/14.png)

Heureusement que nous avons toujours le client lourd, car aucune erreur n’était visible dans le client web !

```
[       :startup :W: 1] 2015-11-26 16:03:05.159 Log for vSphere Client Launcher, pid=8744, version=6.0.0, build=build-3016447, option=release
[       :Failed t:P: 3] 2015-11-26 16:03:31.993 System.Net.WebException: Le nom distant n'a pas pu être résolu: 'vcenter'
```


Voir le KB de VMware (lien mort comme tout chez VMware) pour plus d’informations.

## Limitations

### Rétrocompatibilité

La première limitation que j’ai rencontré au produit est l’absence de rétro compatibilité entre les instances de vSphere Replication. Et donc comme on doit installer la version qui correspond à la version de son vCenter, cela vous oblige à avoir des clusters à des niveau de vSphere identiques, ce qui n’est pas toujours facile à réaliser selon les contextes.

Dans le fond, on ne peut pas trop leur en vouloir, c’est leur outil après tout. Ce qui est plus agaçant et qui est assez courant chez VMware, c’est l’absence de garde fou ou même de message d’erreur. Pour vous donner une idée, j’ai essayé de le faire lorsque je ne savais pas encore que les appliances 5.8 et 6.1 n’étaient pas compatibles. Que j’essaye d’initier la connexion depuis l’une ou l’autre, un message d’erreur pas du tout explicite s’affichait dans un sens, et il ne se passait rien du tout dans l’autre.

Il aurait été tellement simplement pourtant d’ajouter une petite vérification pour dire « Ah non ça ce n’est pas possible, pas la bonne version ! ». Mais bon ;-).

### Bande passante

Le deuxième point est assumé par VMware et je ne comprend vraiment pas leur position.

Lorsque vous faite du vSphere Replication, il faut que les deux clusters aient entre eux un **lien dédié à cela**, que vous devrez estimer vous même en fonction de la taille estimée du delta à faire passer dans ce lien en fonction du RPO défini (voir le KB VMware (lien mort comme tout chez VMware)).

Pourquoi ? Tout simplement parce que lorsque vous allez lancer la synchronisation, votre liaison inter-site sera totalement saturée par vSphere Replication.

> ### Does the vSphere Replication feature incorporate WAN bandwidth management?
> 
> No. vSphere Replication does not incorporate WAN bandwidth management. Use WAN optimizers to throttle and prioritize vSphere Replication traffic. To make it easier, vSphere Replication separates the initial replication from the ongoing replication using different ports so that you can assign different traffic shaping rules to the initial replication and ongoing replication.

Pas de gestion type QOS/traffic shaping pour restreindre la bande passante. A vous de le gérer vous même, soit via des équipements réseaux capable de gérer du trafic sur les ports utilisés par vSphere Replication, soit via des distributed vSwitchs et leur fonctionnalité Network IO Control (NIOC), disponibles si vous avez la version ... Enterprise Plus (!!!).

Alors d’accord, une partie du problème peut être contourné en envoyant un disque dur avec les VMDK des machines à synchroniser sur le second site. Vous pouvez ainsi vous économiser l’envoi d’une grosse quantité d’information pour la première synchronisation et c’est seulement les deltas qui transiteront périodiquement sur votre réseau.

Pour autant, pour peu que vous ayez de grosses écritures sur les machines virtuelles que vous synchronisez, le problème reste entier. Le delta important entre deux synchronisations provoquera une saturation du réseau entre les deux sites.

**En résumé, de la façon dont je vois les choses :** vSphere Replication vers un site distant, disponible pour pratiquement tous les professionnels car accessible à partir de la très peu coûteuse Essential Plus, est donc totalement inutilisable sauf si :

  * Vous pouvez faire du traffic shaping sur votre infrastructure réseau
  * Vous disposez d’une liaison dédiée à cela (ou vous vous fichez de saturer votre réseau)
  * Vous avez la licence vSphere Entreprise Plus

Merci VMware. Trop sympa.

## Documentation diverse

* La documentation officielle sur le site de VMware (lien mort, comme tout chez VMware)
* FAQ avec plusieurs points techniques intéressants sur vSphere Replication (lien mort, comme tout chez VMware)
* [La page wikipedia sur les PRA, relativement claire et permet d’appréhender les concepts](https://fr.wikipedia.org/wiki/Plan_de_reprise_d%27activit%C3%A9)
* [Le tutoriel de Yellow-Bricks pour la version 5.1 en mode réplication locale](http://www.yellow-bricks.com/2012/09/17/back-to-basics-install-configure-and-use-vsphere-replication/)
* [La solution de VM Guy en utilisant le NIOC des VDS (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20200222011302/http://www.vmguy.com/wordpress/throttle-vsphere-replication-with-network-io-control)

