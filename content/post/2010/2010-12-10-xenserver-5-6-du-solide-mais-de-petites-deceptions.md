---
title: '[Test] XenServer 5.6, du solide mais de petites déceptions'
authors:
  - zwindler
type: post
date: 2010-12-10T17:05:42+00:00
url: /2010/12/10/xenserver-5-6-du-solide-mais-de-petites-deceptions/
image: /2011/02/citirx-xenserver11.jpg
categories:
  - Virtualisation
tags:
  - XenCenter
  - XenServer

---
Dans l’article précédent relatant [la théorie et l’installation de XenServer](/2010/10/06/premiers-pas-sous-xenserver-5-6-la-theorie-et-ce-que-jen-attendais/), j’avais fais deux constats :

- XenServer ce n’est pas Xen (on est pas loin d’un ESXi pour toute la couche de présentation, l’OS qui sert d’hyperviseur, et l’architecture de type Serveurs d’un côté, console de gestion unifiée de l’autre)

- XenServer ça s’installe TRES vite et TRES simplement.

N’allez pas croire que je sous-entend que c’est vraiment un avantage par rapport aux concurrents. On s’en sort très bien pour installer un ESX(i) ou un Hyper-V sans aucune difficulté (il faut avoir une culture « Systèmes », quand même!) et en peu de temps, mais bon, j’ai quand même été bluffé.

Contrairement à d’autre blogs spécialisés de gens qui peuvent se permettre de présenter en détails toutes les fonctionnalités des licences payantes, je me contenterai de présenter ce que je peux voir, avec ma pauvre petite licence Express.

A partir de maintenant, on entre dans le vif du sujet, l’utilisation jour après jour des serveurs, piloté par l’intermédiaire du XenCenter.

Première chose à faire une fois le XenServer installé sur le serveur, et XenCenter sur la machine d’administration, c’est de lier le serveur au XenCenter. Ceci se fait de manière assez triviale en cliquant sur les boutons qui vont bien (Add New Server »).

De la même manière, la gestion des fermes de serveurs (on appèle ça des Pools chez Citrix) peut se faire assez facilement, en créant une ferme et en y affectant des serveurs. Attention cependant, j’ai cru comprendre qu’il fallait des serveurs identiques au sein d’une même ferme pour que cela fonctionne bien (même versions, ça c’est sûr, même hardware, je n’en suis plus certain mais ça me parait prudent).

Pour chaque serveur ou Pool, il vous est donc possible en très peu de clics de créer des VMs, mais aussi des Storages. Ce qui est plutôt chouette selon moi c’est qu’au dela des divers moyens de stocker des disques virtuels sur le réseaux (NFS, iSCSI, HBA, Advanced StorageLink), il est possible de monter des partages contenant vos isos en NFS et en CIFS (contre juste NFS pour VMware, aux dernières nouvelles). Même s’il n’est pas bien compliqué de monter un partage NFS pour un admin système, il peut être pratique d’avoir juste à créer un partage Windows depuis la machine d’administration (pour les archi de type maquette par exemple) et soyons honnête, ça ne coute pas cher à ajouter comme fonctionnalité!

![](/2011/01/xenserver-home.png)

L’affichage des VMs présentent sur le serveur se fait d’une manière assez classique : Un bandeau menu avec toutes les fonctionnalités disponibles, un volet de gauche qui liste les serveurs et leurs VM et un volet central qui se découpe enonglets permettant de gérer de façon plus spécifique l’élément sélectionné.

Par exemple quand on sélectionne une serveur ou un pool, on dispose d’une liste des VMs hébergées que l’on peut trier par nom, usage CPU, usage mémoire, moyenne d’accès disque ou réseau, adresse IP, uptime... Simple mais efficace. Chaque élément dispose d’un onglet Performance, qui retrace l’évolution de la métrologie dans le temps (temps relativement court dans la version Express). Un onglet Users permet de joindre un domaine AD pour accorder des droits sur les VMs, et un onglet Log permet de tracer les opérations du serveur.

![](/2011/01/xenserver-perf1.png)

Dans l’ensemble, tout ce qui est nécessaire au bon fonctionnement d’un serveur bien dimensionné et dans des conditions normale d’utilisation me semble vraiment bien ficelé. Pour tout vous dire, ma machine ainsi que ses VMs tournent depuis plusieurs mois sans problèmes, et je l’ai mise à jour, j’ai supprimé des VMs, j’en ai créé d’autre, ... (oui, je n’écris l’article que maintenant)

Mais comme je l’ai dis dans le titre, tout n’est malheureusement pas rose. XenServer est clairement un produit très aboutis et qui propose gratuitement certaines fonctionnalités bien utiles (voire vitales? La gestion de serveurs en ferme et le LiveMotion gratuit, c’est vrai que ça fait envie) que VMware ne propose qu’avec un vCenter (et la licence qui va bien), et des caractéristiques techniques de même niveau sur de nombreux points (pour un avis un peu moins partial que les sites des éditeurs, voir la comparaison de [VMGuru (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20120106002430/https://www.vmguru.nl/wordpress/wp-content/uploads/2010/08/Hypervisor-comparison.pdf)). En grattant un peu, on voit bien que certains points sont plus aboutis chez VMware.

La liste des systèmes d’exploitation invités supportés, par exemple. Là où j’ai eu très peu de difficultés à créer des VMs avec des OS peu courants sous ESXi, on sent bien que XenServer est plus réticent. La liste des OS supportés et vraiment faible actuellement (v5.6), proposant Windows, du Debian et du RedHat (et autres dérivés artificiels pratiquement identiques).Et encore, certaines versions uniquement (il arrive que les noyaux 'de base' de certaines versions récentes supportent mal XenServer)!

Autre déconvenue, quand on clique sur l’onglet Memory d’un serveur, on se retrouve malheureusement face à un message du type « Upgrade XenServer to enable Dynamic Memory Control ». Oui, la mémoire n’est pas attribuée dynamiquement. Il est donc très important de bien gérer sa RAM. J’ai très vite atteint mes 8 Go sur ma machine de test!

![](/2011/01/xenserver-memory.png)

De la même façon, le Thin Provisionning pour l’espace disque semble ne pas être aisé à mettre en place avec la version 5.6 (et pas possible sur la 5.5 sauf tour de passe passe de sioux), qui devra être attribué avec parcimonie et justesse (la taille des disques peut être modifiée une fois les VMs éteintes, mais attention à ce que les OS le supportent!). Cependant il semblerait que le FP1 de la 5.6 corrigera bientôt ce problème (A l’installation... je pense que c’est trop tard une fois installé).

Et enfin, peut être un problème mineur la plupart du temps, mais l’utilitaire de customisation de la machine virtuelle est beaucoup plus complet sous ESX(i). Sous XenServer, c’est même minimaliste. On peut modifier les composants vitaux (CPU, HDD, RAM, cartes réseaux), mais guère plus. C’est rare, mais pourtant des fois c’est utile de pouvoir définir rapidement le nombre de ports COM de la machine virtuelle...

Voilà donc un petit tour d’horizon de mon ressenti...