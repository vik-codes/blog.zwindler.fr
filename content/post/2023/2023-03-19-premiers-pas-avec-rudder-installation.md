---
title: Premiers pas avec Rudder - Installation
authors:
  - zwindler
type: post
date: 2023-03-19T14:30:00+02:00
excerpt: Découverte et installation de Rudder, le logiciel de gestion de configuration et de sécurité de l'entreprise Normation
url: /2023/03/19/premiers-pas-avec-rudder-installation/
image: /2023/03/rudder_logo.png
categories:
  - Système
  - 
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

## Mais d'abord, c'est quoi Rudder ?

[Rudder est un logiciel open-source de gestion de configuration et d'automatisation des systèmes](https://www.rudder.io/fr/), qui permet aux administrateurs système de contrôler et de gérer leurs infrastructures de manière industrialisée. Il est en grande majorité édité par la société Normation, qui vend du support et des fonctionnalités complémentaires (plugins).

Pendant longtemps, j'ai un peu mis de côté Rudder, pensant que ce n'était pas pour moi, surtout que j'avais investi beaucoup de temps dans Ansible (vous trouverez mes [nombreux articles sur le sujet ici](/recherche/?keyword=ansible)).

Cependant, ce qui fait à la fois la force et la faiblesse d'Ansible, c'est le fait qu'il soit *agentless*. On peut lancer nos playbooks depuis n'importe quelle machine, mais ça veut aussi dire qu'il n'y a pas a priori de machine privilégiée pour garder notre infra conforme dans la durée.

Alors oui, je sais qu'on va me rétorquer qu'il existe Tower/AWX, mais je n'ai pas du tout apprécié l'expérience le peu que je l'ai testé, au point de ne pas vouloir l'utiliser ni au travail, ni en perso. En particulier en perso, je trouve l'outil lourd et pas adapté pour mon objectif : garantir la conformité de mes quelques machines.

Parallèlement à ça, Rudder fonctionne avec un agent, et il y a un serveur centralisé qui contrôle les serveurs enregistrés. On peut consulter le tout dans une interface web et on voit en un clin d'oeil si les serveurs sont conformes ou pas.

Sans juger de l'expérience avec des centaines voire des milliers de serveurs, ça me parait adapté pour mon besoin perso (gérer une flotte de quelques machines voire dizaines de machines).

## Installation du serveur

Je vais essayer de ne pas passer trop de temps sur cette partie. Elle a déjà été détaillée récemment par [Stéphane Robert sur son blog](https://blog.stephane-robert.info/post/introduction-rudder/) et par [Nidouille en stream](https://www.youtube.com/watch?v=NRb0Irk7OO8) la semaine dernière.

Grosso modo, j'ai popé une VM chez nua.ge en Ubuntu 22.04 avec 2 CPU et 2 Go de RAM, [suivi la documentation officielle d'installation](https://docs.rudder.io/reference/7.2/installation/quick_install.html) et basta.

```
sudo apt update
sudo apt upgrade

sudo wget --quiet -O /etc/apt/trusted.gpg.d/rudder_apt_key.gpg "https://repository.rudder.io/apt/rudder_apt_key.gpg"
echo "deb http://repository.rudder.io/apt/7.2/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/rudder.list
(output) deb http://repository.rudder.io/apt/7.2/ jammy main

sudo apt update
```

*Note : j'étais assez content de voir [dans la doc officielle](https://docs.rudder.io/reference/7.2/installation/requirements.html) que pour quelques nodes, 2 CPU / 2 Go de RAM suffisent (surtout qu'il y a une JVM, donc la conso RAM aurait pu être bien plus importante).*

On nous conseille évidemment de vérifier que la clé correspond à celle indiquée dans la documentation officielle, puis on l'ajoute (affichée au moment de l'apt update) et on installe le package contenant le serveur.

```
apt install rudder-server
```

Une fois installé, la première chose à faire est de créer un utilisateur admin, puis on peut se connecter sur l'IP du serveur en HTTPS/443 (certificat autosigné par contre, faudra que je regarde comment ajouter du let's encrypt).

```
ubuntu@rudder:~$ sudo rudder server create-user -u toto
New password: 
Re-type new password: 
User 'toto' added, restarting the Rudder server
```

Côté sécurité réseau, il va falloir ouvrir les ports 443 (obviously) mais aussi le 5309 pour que ça marche bien ( pour la partie "Fetch policy", je vous [laisse aller lire la doc](https://docs.rudder.io/reference/7.2/installation/requirements.html#configure-the-network)).

![](/2023/03/rudder_login.png)

## Installation des agents

Même topo pour les agents, j'ai [suivi la doc](https://docs.rudder.io/reference/7.2/installation/agent/debian.html).

On peut donc installer simplement un agent sur nos serveurs en ajoutant la clé + le repo de rudder, puis en lançant la commande

```
sudo wget --quiet -O /etc/apt/trusted.gpg.d/rudder_apt_key.gpg "https://repository.rudder.io/apt/rudder_apt_key.gpg"
echo "deb http://repository.rudder.io/apt/7.2/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/rudder.list
sudo apt update && sudo apt install rudder-agent
```

A partir de là, l'agent ne sait pas où il doit s'enregistrer. On ajoute l'agent au serveur Rudder :

```
sudo rudder agent policy-server <IP.Du.Rudder.Server>
```

Petite subtilité, je n'ai pas eu besoin de faire cette étape dans un premier temps, car il se trouve que par défaut, les agents cherchent sur le LAN une machine s'appelant "rudder". J'étais donc un poil surpris de ne pas voir cette info dans la doc (il faut que je fasse une PR pour corriger ça).

![](/2023/03/rudder_tweet.png) 

On vérifie ensuite que tout fonctionne :

```
sudo rudder agent inventory
Rudder agent 7.2.4
Node uuid: 72577f55-46b0-47e2-acd0-2eeb45353122
M| State         Technique                 Component                 Key                Message
E| compliant     Common                    Compute inventory splay                      Scheduling rudder_run_inventory was correct
E| compliant     Inventory                 Inventory                                    The inventory has been successfully sent
info     Rudder agent was run on a subset of policies - not all policies were checked

## Summary #####################################################################
2 components verified in 3 directives
   => 2 components in Enforce mode
      -> 2 compliant
Execution time: 10.67s
################################################################################
```

*Note : On prendra évidemment garde à ne pas ouvrir les ports des serveur/agents Rudder sur Internet et à utiliser des IPs locales et/ou des firewalls pour filtrer proprement tout ça. On pourra aussi utiliser un VPN, mais il ne faudra pas oublier d'autoriser les IPs des machines distantes dans Rudder (on en reparlera).*

## Accepter les machines dans notre inventaire

Un point qui n'était pas super clair pour moi dans la doc de **Quickstart d'installation des agents**, est qu'une fois que les agents étaient installés, il faut **les autoriser** côté serveur. C'est logique (on ne veut pas autoriser n'importe qui) mais la doc méritera une petite suggestion de ma part je pense.

Ce point est détaillé dans une autre partie de la documentation [Node management / Accept new nodes](https://docs.rudder.io/reference/7.2/usage/node_management.html#accept-new-nodes), mais même cette partie de la documentation ne semble pas à jour, car je n'ai pas vu de menu "Navigate to Node Management → Accept new Nodes."

On a en revanche un menu "Pending nodes" où on retrouve une liste de tous les agents fraichement installés en attente.

![](/2023/03/rudder_pending_nodes.png)

## La suite ?

A partir de là, on a installé tout ce qu'on avait besoin d'installer pour commencer à jouer avec Rudder.

Cependant, on est déjà à 8000 signes et entamer la partie configuration dans cet article me parait lourd.

Je vais arrêter ici pour aujourd'hui et publier dans un prochain article (semaine prochaine surement) comment créer des groupes, ce que sont les rules et les directives en un seul et même bloc (ça sera plus cohérent).

En attendant, have fun !
