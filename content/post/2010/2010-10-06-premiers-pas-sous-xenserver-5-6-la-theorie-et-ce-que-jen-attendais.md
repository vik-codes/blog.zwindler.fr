---
title: '[Test] Premiers pas sous XenServer & co : la théorie et ce que j’en attendais'
authors:
  - zwindler
type: post
date: 2010-10-06T17:32:33+00:00
url: /2010/10/06/premiers-pas-sous-xenserver-5-6-la-theorie-et-ce-que-jen-attendais/
image: /2011/02/citirx-xenserver11.jpg
categories:
  - Virtualisation
tags:
  - ESX(i)
  - XenCenter
  - XenDesktop
  - XenServer

---
Et oui, je fais des infidélités à VMware. Je ne vous l’avais pas dis, mais ça fait un moment déjà que j’ai arrêté de jouer sous ESXi. Je me suis lassé de devoir bidouiller pour pouvoir faire fonctionner ESXi sur du matériel non supporté, de devoir bidouiller pour trouver des workaround pour éviter les limitations de la version gratuite.

Pour être parfaitement honnête, la goûte d’eau a été le fait que ma carte réseau fonctionnait très mal (à cause du fait que j’utilisais un pilote équivalent à première vue, mais pas adapté en réalité). Sous Windows, certaines cartes virtuelles (E1000 et Flexible) ne fonctionnaient pas, et sous FreeNAS, c’était carrément impossible de faire fonctionner le réseau. Après avoir tenté d’autres OEM modifiés avec d’autres pilotes réseau, j’ai fini par abandonner (temporairement? le temps d’acheter du matériel plus pro, peut être?).

Après avoir passé pas mal de temps à étudier les concurrents, je me suis mis en tête d’installer XenServer, en espérant que mon matériel soit mieux supporté. Et je n’ai pas été déçu...

Commençons par le commencement, un peu de théorie. J’ai connu XenServer en faisant des recherches sur Xen, le **paravirtualiseur** libre. Depuis quelques temps, XenSource a été vendu à Citrix, qui est parti de cette base pour faire sa propre solution de virtualisation.

Les architectures de ce type fonctionnent de la façon suivante : Les diverses machines virtuelles fonctionnent au DIRECTEMENT au dessus du matériel (domU dans la terminologie Xen). Cependant, comme un seul OS peut avoir le droit d’utiliser le matériel, les ressources disponibles sont distribués à l’essemble de VMs par un OS un peu spécial, à mis chemin entre une machine virtuelle et un OS hôte (le dom0). Il s’agit souvent un noyau linux modifié, installé sur l’OS hôte initial de la machine.

La GROSSE différence entre les hyperviseurs qui font de la « virtualisation complète » (VMware) et la paravirtualisation tient du fait que dans ces derniers, les machines virtuelle non privilégiées sont « conscientes » d’être des machines virtuelles, et font donc appel au chef d’orchestre dès qu’elles ont besoin d’une ressource.

Pour éclaircir un peu mes propos, je vous propose un graphique de wikipedia, tiré de l’article parlant de Xen ([ici](http://fr.wikipedia.org/wiki/Xen)).

![](/2010/10/xen1.png)

Mais ce fonctionnement n’est pas aussi idéal qu’on pourrait le penser. Les noyaux de ces VMs doit être modifiés pour permettre cette « conscience ». Du coup, avec Xen, c’est surtout les noyaux linux qui fonctionnaient le plus souvent avec Xen, les sources de Windows (ou autres) étant beaucoup moins accessibles (Même si des versions récentes de Xen n’ont plus ces limitations, mais pour ne pas vous embrouiller, je n’en parlerai pas).

A l’opposé, VMware est (historiquement) plutôt partisan d’une autre approche de la virtualisation : la **virtualisation complète**, et plus récemment avec un **hyperviseur**. Contrairement à la paravirtualisation, les machines virtuelles ne sont pas directement au-dessus du matériel, elles sont séparées de celui-ci par une fine couche logicielle (l’hyperviseur) qui se charge de distribuer les ressources. L’avantage de cette technique est que les machines virtuelles n’ont alors pas besoin d’être consciente de leur virtualisation, et donc n’ont pas besoin d’un noyau modifié. L’inconvénient est que théoriquement, les performances sont un peu moindres, à cause de « l'empilage ». De ce que j’en ai compris, ce choix technique est surtout poussé par les premières versions des serveurs VMware, qui ressemblait pas mal à des émulateurs, à installer au-dessus d’un serveur Windows (VMware GSX & VMware Server 2).

Mais assez de théorie, passons à du tangible!

Pour découvrir XenServer, j’ai bêtement cliqué sur un lien nous vantant les mérites de XenDesktop (lien mort). Parce que OUI, pour tenter de prendre des parts de marché à VMware, Citrix est prêt à vous donner gratuitement :

* Le serveur lui-même (XenServer, en version 5.5, même si j’utilise la 5.6, après l’avoir mis à jour)
* Le poste de pilotage (XenCenter)
* Les ISOs contenant les programmes nécessaires pour monter un VDI (XenDesktop), c'est-à-dire la distribution de postes de travail comme un service (jusqu’à 10 utilisateurs, avec la plupart des fonctionnalités, dont les plus utiles).

La première chose qu’on peut dire, c’est qu’on n'est pas vraiment perdu. Citrix propose une infrastructure proche de celle de VMware, avec des serveurs pilotés conjointement par un vCenter, contrairement à Xen qui se pilotait directement depuis le serveur, sans passer par l’intermédiaire d’un poste de pilotage. Vous aurez peut-être remarqué que les noms sont également très proches, par pure coïncidence certainement ;-).

Après avoir rempli quelques informations sur moi-même sur le site de Citrix, j’ai pu télécharger l’archive contenant le tout, puis commencer l’installation. Pour rappel, je dispose d’un PC de bureau qui fonctionne avec un I7 et 8Go de RAM pour la partie serveur, et un portable qui me sert de XenCenter.

Pour ce qui a été de l’installation du serveur en elle-même j’ai trouvé tout ça très intuitif. A force d’installer des distrib Linux, on finit par être habitué au beau menu texte tout bleu! Pour ceux qui voudraient plus de précision, voici un walkthrough des plus complets [ici](http://vpourchet.wordpress.com/2010/06/18/installation-de-xenserver-5-6-0/). En quelques minutes, XenServer était installé, configuré, prêt à l'emploi.

Mais ce qui choque le plus, une fois que notre XenServer a passé le boot, c’est la console de configuration...

![](/2010/10/xenserver1.png)

Remplacez le bleu par du jaune, et le noir par du gris... Ça ne vous rappelle rien? Et oui, vous aurez bien sûr reconnu l’interface de configuration de VMware ESXi... Enfin bon, du coup ce n’est pas dur de s’y retrouver. D’autant plus qu’il n’y a pas vraiment de différences d’utilisation entre cette console et celle de ESXi (un peu plus fournie pour XenServer), car elle ne vous servira qu’à configurer le strict minimum, puisque le gros de l’utilisation se fera depuis le XenCenter.

Léger avantage, peut être, XenServer propose un accès à la console direct, et non pas camouflé comme VMware. J’ose donc en déduire que l’accès à la console est « autorisé », même si probablement pas supporté, au même titre que la Technical Console de VMware (l’ex « hidden console »). Vous pouvez aussi avoir un aperçu de la charge utilisée par vos VMs, mais bon, tout ça est un peu superflux une fois qu’on a ajouté l’hôte au sein du poste de commande, je trouve.

Ce qui est intéressant, ce n’est pas l’interface graphique, mais bien ce qu’il y a dessous. Et bien justement, en dessous, on est très proche d’un ESX ou d’un ESXi... Quand on explore la console, on se rend compte qu’on a affaire à un Redhat modifié pour être le plus léger possible. Alors « OUI », il s’agit ici d’un dom0, au sens OS privilégié du terme chez XenSource, mais bon, au final, on se rend compte que ce que notre XenServer fait, c’est surtout de la virtualisation complète, comme ESX(i), le Redhat ultra léger de XenServer servant d’hyperviseur « bare metal » au dessous des VMs...

Au final, en cherchant à trouver les différences techniques entre XenServer et ESXi, j’ai surtout trouvé des similitudes. Le gros point fort pour moi, c’est que ça marche parfaitement sur ma machine de test. Cependant, ce n’est pas vraiment un critère utile pour la plupart des gens qui peuvent se permettre (dans un contexte plus professionnel) d’acquérir du matériel supporté par VMware. Comme ça commence à faire un peu long comme article, j’aborderai mes impressions sur XenServer dans sa réelle utilisation (via une administration XenCenter) dans un prochain article.

 [1]: /2010/10/xen1.png
 [2]: /2010/10/xenserver1.png
