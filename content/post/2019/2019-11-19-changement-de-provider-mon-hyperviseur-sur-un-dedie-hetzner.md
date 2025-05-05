---
title: Changement de provider, mon hyperviseur sur un dédié Hetzner
authors:
  - zwindler
type: post
date: 2019-11-19T07:30:00+00:00
excerpt: "Suite à des soucis avec le support de OneProvider, j'ai décidé de migrer une partie de mes serveurs vers le provider Hetzner"
url: /2019/11/19/changement-de-provider-mon-hyperviseur-sur-un-dedie-hetzner/
image: /2019/11/Hetzner_DCP_Luftbild.jpg
categories:
  - autohebergement
  - Cluster
  - systeme
  - Virtualisation
tags:
  - Cluster
  - hetzner
  - oneprovider
  - provider
  - Proxmox
  - Proxmox VE
  - Proxmox VE 6
  - RPN
  - tinc
  - VPN
  - vRack

---

## Au revoir OneProvider, bonjour Hetzner
  
  
Certains d’entre vous m’ont peut être vu me plaindre de OneProvider et plus particulièrement le support avec qui j’ai eu plusieurs accrochages (Spoiler, j’ai migré vers Hetzner).

![](/2021/tweet_op.png)


Sans rentrer dans les détails (j’ai échangé avec certains d’entre vous sur le sujet), après cette déconvenue, j’ai donc cherché une alternative pour héberger mes machines.
  
Les prérequis étaient d’avoir :

* une machine physique
* avec suffisamment de RAM (minimum 8 Go, 16 c’est mieux)
* idéalement, une gestion des réseaux virtuels entre machines du provider (type RPN ou vRack)
* si possible pas un ATOM en CPU (le souci de l’ATOM, c’est que c’est tellement faiblard que ça pénalise les IO)
* si possible du VT-x (je n’en ai pas besoin d’en l’absolu, je vais surtout du LXC, mais ça peut dépanner)
* si possible du SSD parce que c’est quand même cool
* si possible 2 disques pour avoir du RAID ou que je puisse me faire un équivalent (ZFS/ZRAID)
* un prix pas trop élevé (genre pas OVH) car j’ai été mal habitué avec les prix agressifs de OneProvider (oui je sais, je l’ai payé avec le support)

## L’état du marché
  
  
Chez OneProvider, j’avais tout ça pour environ 20-25 euros / mois, à l’exception du réseaux privé virtuel entre machine.

  
Autant dire qu’on est très loin du premier prix de chez OVH (>60€/mois TTC). Si on descend en gamme chez OVH, on perd le réseau privé virtuel entre machines (vRack) en passant chez SoYouStart et pourtant on est toujours à plus de 42€ / mois TTC. Toujours 2 fois plus cher que OneProvider :-/.

  
Il faut descendre encore de gamme et passer chez Kimsufi pour trouver des prix comparables dans mes critères (et toujours pas de réseau privé virtuel), avec de vieux CPU et surtout un réseau bridé au 100 Mbps (ce qui est pénible pour les transferts de gros fichiers, les réplications de VMs et les sauvegardes).

  
J’avais aussi jeté un œil côté Online.net, qui eux proposent sur certaines machines identiques à celles que j’avais avec EN PLUS le graal, un réseau privé virtuel entre dédiés (RPN).



![](/2019/11/online.net_.png) 


Ces deux configs me disaient vraiment quelque chose... et pour cause ! OneProvider les revends en marque blanche.

  
Donc c’est exactement les mêmes machines que celle que j’ai pu avoir dans le passé, mais avec le RPN en plus, et un peu plus cher (beaucoup plus cher même).

  
Ce qui est dommage ici, c’est que le RPN ne soit pas disponible sur les machines un peu plus petites (mon PRA n’est pas aussi gros, juste de quoi faire tourner le blog en cas de gros crash).

  
## Vient alors Hetzner
  
  
Ça fait pas mal de fois que je voyais circuler le nom. Des bloggeurs et d’autres confrères en disaient beaucoup de bien, et j’ai voulu aller voir. La première chose intéressante est que Hetzner, comme OVH et Online, [propose bien un service de type réseau privé virtuel entre vos serveurs](https://wiki.hetzner.de/index.php/Vswitch/en) !

![](/2019/11/hetzner_vswitch.png) 


## Plus de puissance chez Hetzner !
  
  
Par contre, quand j’ai vu les machines... au début je me suis dis que ça allait pas le faire...

  
Voilà leur machine "bas de gamme" :



![](/2019/11/hetzner.png) 


Pour à peine plus que le moins cher des SoYouStart (un vieux Xeon E3 v2 4c/4t avec 16Go de RAM et 2 HDD), vous avez un tout nouveau Ryzen 5 6c/12t, 64 Go de RAM et un RAID de 2 SSD NVMe de 512 Go.



Bon clairement on était hors budget mais ils avaient piqué ma curiosité avec leurs config fofolles.

  
Et je suis donc tombé en fouillant un peu sur leur "server auction", qui est ni plus ni moins que les serveurs de leurs anciennes gammes qu’ils louent à nouveau. Et là c’était déjà plus proche de mon besoin.

  
Pour un peu plus de 30€/mois soit 50% plus que mon serveur précédent, mais comparable au prix Online, j’ai un i7-4770, 32 Go de RAM et 2 disques "Entreprise". Soit beaucoup mieux que la machine chez Online.

  
Quitte à changer, j’ai donc tenté Hetzner et commandé un serveur.

  
## C’est puissant mais... qu’est ce que c’est moche
  
  
Bon, l’UI n’est pas follement attrayante. C’est... spartiate.



![](/2019/11/hetzner0-1.png) 


Dans le menu "Servers", vous avez une bête liste de vos serveurs avec le numéro de commande, un hostname (une fois que vous l’aurez setté) et un ID (peu parlant). Bof pratique, surtout au début ou si vous en avez beaucoup.

  
Et quand on sélectionne un serveur, ce n’est malheureusement guère mieux. Les informations importantes éclatées dans un nombre incalculable de menus.



![](/2019/11/hetzner_rescue.png) 


Bref, côté expérience utilisateur, on repassera. Cependant, tout ce qu’il faut pour bien administrer son serveur est là. On finira par s’y retrouver avec un peu d’habitude...

  
## Installation de l’hyperviseur
  
  
Pour installer notre serveur, on peut utiliser l’interface web pour installer un Debian, ou passer par l’image de rescue.

  
J’ai préféré utiliser la 2ème solution, car elle est immédiatement disponible à la livraison du serveur, avec votre clé SSH.



![](/2019/11/hetzner1-1.png) 


On arrive sur un login on ne peut plus classique, avec un résumé des caractéristiques de vos serveurs.

  
Point intéressant, il existe un binaire _installimage_ sur l’OS rescue de Hetzner. Il permet, comme son nom l’indique, d’installer une image.

  
Comme j’utilise Proxmox VE comme hyperviseur, j’ai donc installé une Debian 10 :



![](/2019/11/hetzner_installimage1.png)


Une fois l’image de base choisie, vous allez arriver à un éditeur de texte. Il va vous permettre de configurer de manière plus fine votre installation. Je trouve cette méthode assez originale. Ça change des interfaces webs pas toujours stables vous demandant la taille de vos partitions pour finalement planter dès que vous demandez un truc non standard.

  
Ici tout a très bien marché, j’ai configuré le hostname, ainsi qu’un RAID soft et un partitionnement LVM.



![](/2019/11/hetzner_installimage3-1.png)


Là encore, je suis navré qu’on tombe dans le cliché, mais si ce n’est pas "joli" ni "user friendly", au moins c’est efficace.

## Passer de Debian 10 à Proxmox VE 6
  
  
Une fois validé, l’image Debian 10 a été copié extrêmement rapidement (une ou deux minutes). Forcément, c’est une "minimal". Mais bon c’est quand même agréable d’avoir son serveur "up and running" en moins d’une demie heure entre la commande et la fin de l’installation.

  
Reste donc à installer PVE 6 sur notre dédié Hetzner. Sans trop de surprise, j’ai réutilisé mon playbook Ansible qui configure de A à Z la Debian pour en faire un Proxmox. Pour ceux qui l’ont loupé, [c’est par ici que ça se passe](/2019/08/20/cluster-proxmox-ve-v6-cette-fois-ci/).

  
J’ai juste eu _un_ petit souci lors de l’installation. La debian étant minimale, je n’avais même pas python d’installé. C’est gênant quand on fait du Ansible !


```
cat inventory_hetzner.yml
all:
  children:
    proxmoxve:
      hosts:
        <fqdn_hyperviser>:

ansible proxmoxve -i inventory_hetzner.yml -u root -m ping
<fqdn_hyperviser> | FAILED! => {
    "changed": false,
    "module_stderr": "Shared connection to <fqdn_hyperviser> closed.\r\n",
    "module_stdout": "/bin/sh: 1: /usr/bin/python: not found\r\n",
    "msg": "MODULE FAILURE",
    "rc": 127
}
```



Heureusement j’avais déjà eu le souci dans un autre contexte. J’ai donc écris un playbook supplémentaire (dispo sur le Github) pour installer les prérequis manquants.


```
ansible-playbook -i inventory_hetzner.yml -u root proxmox_python_firstinstall.yml
ansible-playbook -i inventory_hetzner.yml -u root proxmox_prerequisites.yml
```



Et en quelques minutes, mon Proxmox VE était opérationnel sur Hetzner !
