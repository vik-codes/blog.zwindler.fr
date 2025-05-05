---
title: k3os, le reboot de RancherOS à la sauce k3s
authors:
  - zwindler
type: post
date: 2020-12-08T07:45:00+00:00
excerpt: Découverte et installation de k3os, la distribution minimaliste de Rancher qui embarque k3s
url: /2020/12/08/k3os-le-reboot-de-rancheros-a-la-sauce-k3s/
image: /2020/12/k3s.png
categories:
  - Cluster
  - DIY
  - systeme
  - Virtualisation
tags:
  - CentOS
  - debian
  - k3OS
  - k3s
  - k8s
  - Kubernetes
  - rancher
  - RancherOS
  - RKE
  - Ubuntu

---
## k3os, encore un produit Rancher ?

Oui, k3os. Je vais donc ENCORE parler d’un produit de Rancher aujourd’hui, et la raison principale est que cet article est plus ou moins la suite logique des deux précédents sur RancherOS et RKE

Dans [Kubernetes avec RancherOS et RKE partie 1](/2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/), je vous expliquais que j’avais ENCORE changé d’infra et que pour le fun, j’avais souhaité essayer d’installer [RancherOS](/2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/) puis [RKE](/2020/11/30/kubernetes-avec-rancheros-et-rke-partie-2/), respectivement comme distrib pour mes nodes Kubernetes et comme méthode d’installation de Kubernetes lui même.

Bon, alors d’abord j’ai pas été super convaincu par RancherOS (pas seulement pour mon usage perso, mais aussi plus globalement) et en plus, j’ai découvert grâce aux commentaires que RancherOS était en fait abandonné.

Bummer...

## k3s pour mon usecase c’est quand même mieux

Bon en vrai ce n’était pas bien grave, car le but était de tester ces produits dont j’entendais parler depuis un moment. Mais du coup, je n’ai toujours pas de Kubernetes viable pour mes geekeries...

Un des outils qui correspond le mieux à mon usecase, là encore chez Rancher, c’est **[k3s][1]**. Un Kubernetes minimaliste qui prend très peu de ressources et qui est simple à installer.

J’avais d’ailleurs fait quelques articles dessus, notamment pour parler d’un playbook Ansible qui permettait de déployer k3s sur des instances ARM dans le cloud de Scaleway (la bonne époque où ils en proposaient, en tout cas...). 

Le code est toujours dispo et **n’était pas spécifique à ARM ni à Scaleway**, si ça vous intéresse.

* [Le code sur Github](https://github.com/zwindler/ansible-scaleway-k3s)
* [L’article pour en parler](/2019/03/21/deployer-en-5-minutes-un-cluster-kubernetes-sur-arm-avec-k3s-et-ansible/)

## Et k3os dans tout ça ?

La méthode d’installation de Kubernetes est donc choisie. Mais ça ne répond pas à la seconde question, à savoir, sur quelle distribution je l’installe.

Je peux l’installer sur n’importe quel OS Linux généraliste (Debian, Ubuntu, CentOS, ... you name it), mais le but, c’est quand même d’installer un Kubernetes le plus léger possible (car je suis radin sur les serveurs que je loue et ils sont peu puissants).

Qu’à cela ne tienne, me dis-je ! Pourquoi ne pas retenter l’expérience CoreOS et RancherOS avec k3os ?

Et c’est vraiment une bonne question...

## k3OS donc

> k3OS is a Linux distribution designed to remove as much OS maintenance as possible in a Kubernetes cluster. It is specifically designed to only have what is needed to run [k3s](https://github.com/rancher/k3s). Additionally the OS is designed to be managed by kubectl once a cluster is bootstrapped. Nodes only need to join a cluster and then all aspects of the OS can be managed from Kubernetes. Both k3OS and k3s upgrades are handled by the k3OS operator.
> [github.com/rancher/k3os](https://github.com/rancher/k3os)

k3os est donc une distribution optimisée par Rancher pour fonctionner avec k3s et consommer le moins de ressources possibles.

Les avantages mis en avant sont que dès que l’OS est installé, on a un Kubernetes fonctionnel puisque k3s est préinstallé et configuré à l’install de l’OS.

L’autre avantage mis en avant est que tout la gestion du cycle de vie de l’OS est piloté à l’aide d’un operateur dans Kubernetes (k3OS operator) qui va nous permettre de gérer l’OS depuis Kubernetes directement.

Mkay, pourquoi pas.

## Et c’est reparti pour un tour

Même procédure que pour l’article sur RancherOS, les principes sont très similaires. On va télécharger une image iso, créer une VM et se connecter dessus en liveCD pour installer l’OS sur le disque.

La page des releases est ici : [github.com/rancher/k3os/releases](https://github.com/rancher/k3os/releases)

```
cd /var/lib/vz/template/iso
wget https://github.com/rancher/k3os/releases/download/v0.11.1/k3os-amd64.iso
```

> To copy k3OS to local disk, after logging in as rancher run sudo k3os install. Then remove the ISO from the virtual machine and reboot.




![](/2020/12/k3os-0.11.1.png) 

**STOOOOOP**

Exactement comme dans l’install de RancherOS, si vous partez bille en tête vous risquez de tomber sur un OS (ahah).

[Dans l’article précédent](/2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/), j’avais fait l’andouille et lancé la commande, pour me rendre compte qu’une fois installé, je n’avais ni réseau, ni clé SSH pour me connecter sur l’utilisateur rancher post install.

En vrai, tout doit se faire via cloud-config...

Bon, pour être honnête, cette fois-ci, ils ont quand même un peu plus prévu le coup. Si vous ne fournissez pas de cloud-config, cette fois-ci k3os vous propose de rentrer un mot de passe pour votre rancher.

Mais vous n’aurez pas plus de réseau si comme moi vous n’avez pas mis de DHCP sur votre LAN (cf aparté pour les bolosses qui n’ont pas de DHCP plus tard dans l’article).

## cloud-config

Partons donc pour l’instant du principe que vous avez un DHCP et que vous aurez donc, une fois k3OS installé, accès réseau à votre machine.

Proxmox a la bonne idée de permettre la création de volume cloud-init directement depuis l’UI. 

![](/2020/12/k3os_cloud-init.png)

![](/2020/12/k3os_cloudinit_2.png)

Cependant, j’ai bien l’impression que le format du cloud-init de Proxmox ne correspond pas au format attendu par k3OS... 

OK, je suis pas fâché.

On va donc devoir le faire à la mimine et ça tombe bien, car on a ENCORE le souci du clavier Qwerty/Azerty... ([cf Bonus Qwerty](/2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/)), ce qui est parfait pour copier à la main une clé SSH, c’est bien connu.

Vous l’aurez compris, on va s’en sortir une fois de plus avec un port série et la console de type xterm.js...

Grosso modo, mon cloud config s’est limité à ça.

```
cat > config.yml << EOF
k3os:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQAaaaaaaaaaaaaaaaaaaaaaaaaaaaOF0lZiHOjIZ/27aaHmNTq27Vws2dhzJ9 rancher
EOF
```


Tout ça pour ça me direz-vous ? Oui...

Mais bon, une fois qu’on a ça, on peut passer à l’install elle-même, qui est en fait un mini installeur qui vous pose quelques questions un peu triviales comme « rôle du node », « token », « chemin de la clé SSH ».

```
k3os-15121 [~]$ sudo k3os install

Running k3OS configuration
Choose operation
1. Install to disk
2. Configure server or agent
Select Number [1]: 
Config system with cloud-init file? [y/N]: y
cloud-init file location (file path or http URL): config.yml
[...]
```


Ces valeurs peuvent d’ailleurs être ajoutées au cloud-config pour vous permettre d’automatiser la totalité de l’opération.

A l’issue de l’opération... magie ! vous aurez un Kubernetes tout neuf et tout léger :)

## Aparté pour les bolosses qui n’ont pas de DHCP (aka. moi)

Ça aurait été plus simple de monter un petit serveur DHCP vite fait mais je suis têtu comme pas deux.

La blague avec k3OS est que, contrairement à RancherOS, il n’est tout simplement pas possible d’installer l’OS en lui spécifiant l’adresse réseau physique qu’il devra avoir post install.

En fait au début, j’avais copié ce que j’avais fait pour RancherOS. L’installeur de k3OS ne râle pas, mais il ignore simplement le code en trop.

Et vous ne pourrez plus vous connecter...

Mais comme je suis têtu (je me répète), j’ai cherché à tout prix la solution.

L’idée ici est de feinter l’installeur en ne lui donnant PAS de cloud config. On garde ainsi la possibilité de se loguer à l’utilisateur rancher avec un mot de passe (pas bien ça...).

Une fois k3OS installé, on se connecte une nouvelle fois en console (oui, on risque pas de le faire en SSH...) et on configure la carte réseau.

k3OS est un dérivé d’Alpine (pour les binaires userspace) avec le kernel d’Ubuntu 20.04 (oh...kay ?).

Pour setter le réseau, vous pouvez donc faire :

```
sudo connmanctl services
*AR Wired                ethernet_c6eb50d8c655_cable
```


Cette commande vous renvoie le nom de la carte réseau virtuelle. Vous pouvez maintenant regarder la configuration par défaut

```
sudo connmanctl services ethernet_c6eb50d8c655_cable
/net/connman/service/ethernet_c6eb50d8c655_cable
  Type = ethernet
  Security = [  ]
  State = ready
  Favorite = True
  Immutable = False
  AutoConnect = True
  Name = Wired
  Ethernet = [ Method=auto, Interface=eth0, Address=C6:EB:50:D8:C6:55, MTU=1500 ]
  IPv4 = [ Method=auto, Address=169.254.126.16, Netmask=255.255.0.0 ]
  IPv4.Configuration = [ Method=auto ]
  IPv6 = [  ]
  IPv6.Configuration = [ Method=auto, Privacy=disabled ]
  Nameservers = [ 8.8.8.8 ]
  Nameservers.Configuration = [  ]
  Timeservers = [  ]
  Timeservers.Configuration = [  ]
  Domains = [  ]
  Domains.Configuration = [  ]
  Proxy = [ Method=direct ]
  Proxy.Configuration = [  ]
  mDNS = False
  mDNS.Configuration = False
  Provider = [  ]
```


Grande classe. 8.8.8.8 en DNS... No comment.

Et setter votre carte réseau post installation avec cette dernière commande (à remplacer par vos valeurs à vous, hein) :

```
sudo connmanctl config ethernet_d2416991aa5b_cable --ipv4 manual 192.168.1.15 255.255.255.0 192.168.1.1 --nameservers 192.168.1.1
```


## Conclusion

Bon je crois qu’il est temps d’arrêter de se faire du mal...

Oui clairement, je me suis mis dans un exemple un peu foireux. Tout le monde de normalement constitué dispose d’un DHCP de nos jours. Surtout que k3OS cible les usages de k3s, à savoir le edge et l’IoT.

Mais du coup, j’ai l’impression qu’on est vraiment dans le marché de niche de la niche : un OS optimisé pour l’IoT ou l’edge uniquement. Je ne suis clairement pas ciblé par k3OS.

Ça ne m’a pas vraiment donné envie de regarder plus en détails la partie k3OS operator, qui permet de gérer les mises à jours de l’OS depuis Kube.

La documentation sur le sujet est disponible ici et ça a l’air d’avoir beaucoup bougé entre la v0.9, la v0.10 et la v0.11, puisqu’il y a des exceptions dans tous les sens...

* [github.com/rancher/k3os#upgrade-and-maintenance](https://github.com/rancher/k3os#upgrade-and-maintenance)

Bref... il est temps que je m’installe un bête OS généraliste...

 [1]: https://k3s.io/
