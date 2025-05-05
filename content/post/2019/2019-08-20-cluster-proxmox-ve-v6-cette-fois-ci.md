---
title: Cluster Proxmox VE, v6 cette fois ci !
authors:
  - zwindler
type: post
date: 2019-08-20T11:45:00+00:00
excerpt: Tutoriel pas à pas (aidé de playbooks Ansible) pour déployer des clusters Proxmox VE 6 depuis des machines Debian Buster
url: /2019/08/20/cluster-proxmox-ve-v6-cette-fois-ci/
image: /2019/08/cropped-proxmox_ansible.png
classic-editor-remember:
  - block-editor
categories:
  - autohebergement
  - Cluster
  - Divers
  - Système
  - Virtualisation
tags:
  - Cluster
  - corosync
  - openvpn
  - Proxmox
  - Proxmox VE
  - Proxmox VE 6.0
  - tinc
  - virtualisation
  - VPN

---

## Proxmox VE

Et oui, avec [la sortie de Proxmox VE 6](/2019/07/16/sortie-de-proxmox-ve-6-0-les-nouveautes/), je vous avais prévenu : il va y avoir pas mal d’articles là dessus, même si quelques articles sur Kubernetes sont en cours d’écriture aussi ;-).

Fin juillet, j’avais écris [un article sur des playbooks Ansible que j’ai écris pour faciliter le déploiement de cluster Proxmox VE](/2019/07/22/proxmox-en-5-min-ansible-tinc/). Malheureusement, comme cet article traînait dans mes brouillons, les playbooks ne géraient pas la version 6 (qui venait de sortir) de PVE.

C’est aujourd’hui de l’histoire ancienne puisque, pour tester la v6, j’ai forcément du adapter les playbooks ;-).

Point important, je vais partir du principe que vous n’avez pas la possibilité d’installer Proxmox VE directement avec l’ISO. C’est souvent le cas souvent avec les hébergeurs de serveurs dédiés pas chers (OneProvider par exemple) ou de VMs (OVH, Scaleway, etc).

Car si vous avez la main, le plus simple est bien sûr d’installer l’ISO directement ! Cependant, ce tuto reste utile pour toute la partie mise en VPN et configuration du cluster.

## Les prérequis

Dans l’article précédent, pour gagner du temps pour ceux qui veulent juste tester, j’avais mis à disposition un playbook permettant de générer des VMs chez le cloud provider Scaleway (et notamment tirer parti de l’inventaire dynamique proposé par le module développé par Scaleway pour Ansible).

Ici, je met volontairement de côté cette partie qui n’apporterait rien de plus. Si vous voulez voir comment ça fonctionne je vous invite à [(re)lire l’article précédent](/2019/07/22/proxmox-en-5-min-ansible-tinc/), la procédure est la même.

Le seul prérequis pour ce tutoriel sont donc d’avoir idéalement 3 machines* (ou plus) sous Debian 10 (la raison pour laquelle je n’avais pas pu le faire avec Scaleway qui ne propose pas encore Debian Buster) accessibles en depuis votre station de travail.

*Mais si vous voulez juste installer Proxmox, une seule suffit mais vous n’aurez évidemment pas un cluster. A partir de 2, on peut faire un cluster mais il sera instable dès que vous perdrez une seule des 2 machines (ce qui est dommage) à moins d’ajouter un device pour permettre d’avoir le quorum (ce que nous verrons dans un autre article).

## Installer Ansible et récupérer les playbooks

Des fois que n’auriez pas Ansible, installez le (pour git, c’est juste plus simple de cloner le dépôt mais vous pouvez le télécharger autrement si vous ne voulez pas installer git)

```
apt-get install git ansible
git clone https://github.com/zwindler/ansible-proxmoxve
cd
```

Ensuite, on créé un fichier d’inventaire pour Ansible (ce qui n’étais pas nécessaire avec Scaleway puisque, je le rappelle, il y a un module d’inventaire dynamique). Ici on se contente juste de lister les serveurs qui nous intéressent.

```
cat pve_inventory.yml
all:
  children:
    proxmoxve:
      hosts:
        proxmox1.myexample.org:
        proxmox2.myexample.org:
        proxmox3.myexample.org:
```

Vous ne reconnaissez peut être pas le format de cet inventaire Ansible. En effet, l’inventaire est ici stocké au format YAML et non au format plat. Très peu de gens utilisent ce format (qui existait au début, puis a été retiré pour être de nouveau supporté depuis la 2.4 je crois).

Étant habitué aux inventaires parfois un peu hétéroclites, je préfère largement ce format YAML, qui permet de rajouter de manière beaucoup plus lisibles des variables à des groupes ou mêmes des hôtes directement (sans passer par une arborescence complète avec groups_vars et hosts_vars). De plus, je trouve les dépendances entre groupes plus claires que lorsque nous avions à déclarer les :children du groupe père (mais c’est subjectif).

Notez par contre qu’il faut :

* que mes hôtes soient résolvables par DNS (sinon il faut ajouter une variable ansible_host avec l’IP pour chacun)
* que vous n’oubliez surtout par le ":" à la fin de chaque hostname, sans quoi vous aurez une erreur de syntaxe.

## Lancer le playbook d’installation de Proxmox VE 6

Nous y voilà. Normalement vous pouvez accéder en SSH à l’ensemble de vos machines. Pour installer Proxmox VE 6 sur une debian 10, il faut donc simplement lancer la commande suivante :

```
ansible-playbook -i pve_inventory.yml proxmox_prerequisites.yml -u root
```

Normalement, le playbook vous promptera pour répondre à quelques questions basiques (votre domaine, est ce que les machines commencent par test plutôt que proxmox dans le hostname, ...) et à l’issue, un reboot sera effectué (pour basculer sur le noyau Linux de PVE et pas celui de debian Buster).

## Mise en réseau privé virtuel avec Tinc

Cette étape n’est pas forcément nécessaire. Si vous travaillez sur des machines qui sont dans un même réseau local, il vaut mieux s’en passer.

En revanche, dans le cas où comme moi vous louez des serveurs chez un provider et qu’il ne vous met pas à disposition un moyen de simuler un réseau privé (RPN chez Online, Rack quelque chose chez OVH je crois), il sera préférable de monter un VPN entre les différentes machines du cluster.

Je dis préférable et pas nécessaire, [car jusqu’à la version 6 de Proxmox (et Corosync v3), il était nécessaire également de faire passer du multicast](/2019/07/16/sortie-de-proxmox-ve-6-0-les-nouveautes/) entre les machines pour faire fonctionner le cluster. Ce n’est aujourd’hui plus le cas et on peut donc très bien imaginer un cluster Proxmox avec des machines sur des LAN distincts. Cependant, pour activer des fonctionnalités comme Ceph (et probablement d’autre), il est toujours nécessaire d’avoir un LAN.

Pour se faire, j’utilise Tinc plutôt qu’OpenVPN, qui a l’avantage d’être simple à configurer et surtout multipoint (pas de notion de serveur maitre et de clients connectés dessus). Ce n’est pas le cas avec OpenVPN, dont la structure client/serveur complexifie beaucoup l’implémentation si on veut éviter un SPOF (en gros il faut un serveur sur toutes les machines, et que l’ensemble des serveurs soient tous clients les uns des autres, en toile d’araignée). Vous pouvez [quand même jeter un oeil sur mes premières tentatives ici](/2017/08/29/faire-un-petit-cluster-proxmox-avec-2-machines-kimsufi/), si ça vous intéresse.

Comme j’automatise tout avec Ansible, j’ai donc aussi créé un playbook qui permet d’installer et configurer Tinc sur toutes nos machines et de les mettre en réseau sur un VPN dédié.


```
ansible-playbook -i pve_inventory.yml tinc_installation.yml -u root
```

A partir de là, vous avez donc 3 machines Proxmox VE 6, connectés ensembles sur un VPN avec l’adresse 10.10.10.0/24

## Le réseau c’est compliqué ?

Un point pas forcément évident avec Proxmox est que la configuration du réseau dépend beaucoup de comment vos machines sont connectées en réseau.

Les différentes configurations conseillées sont détaillées [dans un article dédié sur le wiki de Proxmox](https://pve.proxmox.com/wiki/Network_Configuration). J’aurais vraiment aimé connaître cette page lorsque M4vr0x et moi avons fait nos premières expériences avec PVE car nous avons beaucoup tâtonné...

Dans mon cas précis, j’ai des machines hostées par un provider. Je n’ai donc aucunement la main sur le réseau et je ne souhaite pas acheter d’IP supplémentaires.

Dans ce cas là, le plus simple est donc de créer un bridge Linux, qui portera un réseau virtuel interne à chaque serveur et dont le trafic externe sera routé.

L’inconvénient de cette solution est qu’on ne peut pas utiliser l’interface graphique pour faire ces modifications, et aussi qu’en cas d’erreur, vous n’aurez plus accès à votre serveur...

## Configuration réseau pour des machines dédiées chez un Provider type OneProvider

Nous voilà donc dans les premières bidouilles manuelles. Connectez vous en SSH à votre (vos) serveurs, et modifier le fichier /etc/network/interfaces.

Je me suis basé sur la section ["Masquerading (NAT) with iptables"](https://pve.proxmox.com/wiki/Network_Configuration#_masquerading_nat_with_tt_span_class_monospaced_iptables_span_tt)

Le mien ressemble à ça :

```
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
#real IP address
iface eth0 inet static
        address  x.x.x.x
        netmask  24
        gateway  x.x x.1

auto vmbr0
iface vmbr0 inet static
        address 192.168.0.1
        netmask 255.255.255.0
	bridge-ports none
	bridge-stp off
	bridge-fd 0

        post-up  echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '192.168.0.0/24' -o eth0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '192.168.0.0/24' -o eth0 -j MASQUERADE
```

Le plus important ici pour que tout fonctionne est que vous ne vous trompiez pas sur le nom de l’interface réseau (eth0 dans mon exemple).

Ensuite, une fois que les modifications sont faites, redémarrez le réseau (_systemctl restart networking_) ou carrément le serveur (c’est ce que Proxmox conseille, même si je ne vois pas bien l’intérêt).

Ici, la configuration est beaucoup plus simple que ce que nous avions imaginé [avec M4vr0x dans la série d’articles détaillés sur PVE 5](/2017/07/18/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-2/). Et c’est tant mieux car ça suffira amplement à la plupart d’entre vous ;-).

## Configuration du cluster Proxmox VE
  
  
Ok ! Maintenant tous les prérequis sont en place, on peut donc construire le cluster. Le wizard de la GUI a assez peu évolué depuis la V5 (même s’il y a quelques petites améliorations)

* Vous vous connectez sur une des machines
* Dans la vue Datacenter, vous sélectionnez Create Cluster, puis vous copiez les informations de connexion pour les autres serveurs.
* Sur les autres serveurs, vous rejoignez le cluster en collant les informations des
 
(Plus de détails dans l’article précédent)

![](/2019/08/proxmox_ve_6_create_cluster.png)
