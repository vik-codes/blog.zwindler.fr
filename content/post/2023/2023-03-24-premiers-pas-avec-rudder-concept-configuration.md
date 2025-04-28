---
title: Premiers pas avec Rudder - concepts et configuration
authors:
  - zwindler
type: post
date: 2023-03-24T06:30:00+02:00
excerpt: Concepts et configuration de Rudder, le logiciel de gestion de configuration et de sécurité de l'entreprise Normation
url: /2023/03/24/premiers-pas-avec-rudder-concept-configuration/
aliases:
- /2023/03/27/premiers-pas-avec-rudder-concept-configuration/
image: /2023/03/rudder_logo.png
categories:
  - Système
tags:
  - gestion de configuration
  - rudder
  - normation
  - ansible
  - configuration management
  - gestion de la conformité

---

Cet article fait partie d'une suite d'articles sur Rudder. La version qui est testée ici sera la version open source (car je n'ai pas les moyens de me payer une licence pour mon infra perso 😛) :
* [Présentation, installation du serveur et des agents](/2023/03/19/premiers-pas-avec-rudder-installation/)
* [Concepts et configuration des groupes, des directives, des rules](/2023/03/27/premiers-pas-avec-rudder-concept-configuration/)
* [Astuces en vrac](/2023/04/20/rudder-astuces-en-vrac/)

*Note : une fois de plus, je tiens à préciser qu'il ne s'agit PAS d'un article sponsorisé. J'ai eu des contacts (techniques) avec la team Rudder, mais je n'ai été influencé d'aucune manière, en particulier dans la rédaction de cet article.*

## On reprend où on en était

Dans l'article précédent, je m'étais arrêté après l'installation du serveur Rudder sur une machine Ubuntu, ainsi que d'un agent.

Dans cet article, je pars du principe qu'on est un peu plus loin dans le temps. On a installé des agents à droite à gauche.

Dans mon cas, j'ai une dizaine de machines Debian et Ubuntu, provenant de VMs (chez nua.ge) et d'hyperviseurs/containers LXC (Proxmox VE).

![](/2023/03/rudder2_begin.png)

Pour le "fun", j'aurais pu faire l'effort d'installer des machines Windows mais je n'ai pas eu le courage. Peut-être une autre fois.

## Node Inventory

C'est cool d'avoir une flotte de machines dans notre Rudder, mais qu'est-ce qu'on peut faire avec ?

La première chose qu'on peut faire, c'est d'aller voir ce que l'agent remonte comme info au serveur. Un peu comme les "facts" d'Ansible. Ca nous sera utile par la suite.

On va donc choisir un de nos "nodes" dans la liste et regarder l'onglet Inventory pour voir ce qu'on peut faire avec.

![](/2023/03/rudder2_inventory.png)

Je n'ai pas creusé en détail pour savoir s'il y avait plus d'infos collectées que ce qui est affiché dans ce menu, mais on a déjà de quoi faire, en parcourant toutes les catégories.

Grosso modo on va utiliser ces infos-là pour définir des groupes, puis l'état souhaité de nos machines.

## Groups

Dans la terminologie Rudder, les serveurs sont des "nodes", on en a déjà parlé. On va ensuite regrouper nos nodes par "groups" (avec une relation n-to-n).

Il y a plusieurs catégories de groupes. On peut soit regrouper les nodes par groupes statiques (pas super efficace quand on passe à l'échelle), soit tirer parti des informations trouvées dans l'inventaire (cf section précédente) pour créer des groupes dynamiques.

Enfin, il existe une dernière catégorie de groupes, dits "system" qui des groupes spéciaux gérés par Rudder.

On retrouve ça dans l'interface de Rudder dans la partie **Node management / Groups**.

![](/2023/03/rudder2_groups_menu.png)

## Créer un groupe pour tous les serveurs Ubuntu

Comme j'ai beaucoup de serveurs Ubuntu, la première idée qui m'est venue à l'esprit a été de créer un groupe pour les regrouper.

Dans ce menu, il existe 2 choses qu'on peut créer. Des **Categories** et des **Groups**.

Je fais un mini aparté sur les **Categories**, concept qu'on pourra retrouver ailleurs dans l'interface. Il s'agit de subdivisions logiques (des "dossiers", en gros) qui permettent de faciliter le rangement de nos bidules. 

Comme j'aime bien que les choses soient bien rangées, j'ai commencé donc par créer une catégorie "By OS" pour regrouper tous mes groupes.

![](/2023/03/rudder2_groups_categories.png)

Une fois que c'est fait, on peut rentrer dans le dur et créer un groupe dynamique pour nos serveurs Ubuntu.

![](/2023/03/rudder2_group_byos_1.png)

Quand on clique sur *create*, on peut ensuite ajouter les conditions pour déterminer si un hôte est dans le groupe ou pas.

![](/2023/03/rudder2_group_byos_2.png)

Jusque-là, rien de bien foufou, on demande à Rudder de se baser sur les infos de l'inventaire et de matcher ou pas avec une regex.

Je note la petite feature de preview, qui permet de voir d'un coup d'œil si ça matche bien les bons hosts. C'est très sympa :\)

Autre remarque, le menu déroulant est assez pratique à utiliser et assez fourni (c'est les infos de l'inventaire, donc assez riche).

Un exemple de ce qu'on peut faire juste avec la partie "node summary" :

![](/2023/03/rudder2_group_byos_3.png)

Pour l'instant, rien de bien compliqué/original.

## Un peu de théorie

C'est là où ça se corse (un peu, pas beaucoup). Avant d'aller plus loin, il va falloir comprendre quelques concepts propres à Rudder.

Je pompe honteusement [le schéma de la doc officielle](https://docs.rudder.io/reference/7.2/usage/configuration_management.html) pour faire un support visuel, puis j'explique ensuite :

![](/2023/03/rudder2_concepts.png)

On a déjà parlé de notre relation *n-to-n* avec nos nodes et nos groups. Si on se concentre sur la partie gauche, on découvre 3 nouveaux concepts :
* les techniques
* les directives
* les rules

Les techniques, c'est les fonctionnalités que rudder va appliquer ou vérifier sur nos nodes. Les techniques sont configurables et c'est pour ça qu'on va créer des directives à partir de ces techniques (relation *1-to-n*).

Et pour finir, les rules sont ce qui va relier un certain nombre de groupes à un certain nombre de directives.

## Premier exemple de directive

Quand j'ai commencé à tester Rudder, une CVE (de plus) venait de sortir sur `sudo`. Je voulais voir si Rudder était capable de vérifier si mes binaires sur mes ubuntu étaient patchés ou pas.

![](/2023/03/rudder2_sudo.png) 

Je suis donc allé dans le menu **Directives**, cliqué dans la liste sur la technique **Packages** et j'ai créé ma directive à partie de cette technique.

![](/2023/03/rudder2_directive5.png)

Cette directive est relativement triviale, on fera des exemples plus complexes dans l'article suivant. Mais ça vous donne une idée du concept.

## Première rule

Une fois la directive sauvegardée, on va créer une *rule* qui va regrouper nos *groups* et notre *directive*.

![](/2023/03/rudder2_rule_directive.png)

![](/2023/03/rudder2_rule_group.png)

Comme vous pouvez le voir, c'est relativement trivial. Une fois que c'est validé, rudder passe sur tous nos nodes pour appliquer la nouvelle configuration.

On peut retrouver sur le Dashboard principal pour voir ce qu'il se passe de manière globale

![](/2023/03/rudder2_directive_applied.png)

Ou aller sur un node en détail et aller lire l'historique

![](/2023/03/rudder2_node_logs.png)

## Et si je ne veux pas appliquer ?

Par défaut, le "Policy mode" est positionné sur "Enforce", ce qui veut dire que Rudder va auditer nos systèmes, **puis** les corriger s'ils ne sont pas conformes.

Si on veut faire ça, il suffit de positionner la directive sur "Audit", et utiliser l'option "This specific version" plutôt que "Latest available version".

![](/2023/03/rudder2_audit.png)

Voici le résultat sur un node qui n'était pas à jour :

![](/2023/03/rudder2_non_compliant.png)

## Conclusion

Voilà pour une très brève introduction sur le système de configuration des nodes et des politiques de conformité avec Rudder.

J'ai pris un exemple très très basique, mais il permet de se faire une idée rapide de la facilité d'utilisation de Rudder.
