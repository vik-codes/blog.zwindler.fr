---
title: 'Un cluster Kubernetes gratuit pour vos labs persos ! - part 1'
authors:
  - zwindler
type: post
date: 2023-04-24T06:00:00+02:00
url: /2023/04/24/cluster-kubernetes-gratuit-part1/
image: /2023/04/kubernetes_banknote.png
categories:
  - DIY
  - Virtualisation
tags:
  - Homelab
  - Kubernetes
  - Oracle Cloud

---

Cet article fait partie d'une suite d'articles sur l'installation d'un cluster Kubernetes sur le free tier d'Oracle Cloud Infrastructure :

* [Un cluster Kubernetes gratuit pour vos labs persos ! - part 1](/2023/04/24/cluster-kubernetes-gratuit-part1/)
* [Un cluster Kubernetes gratuit pour vos labs persos ! - part 2](/2023/05/23/cluster-kubernetes-gratuit-part2/)

L'avantage principal de ce tuto est qu'il est gratuit. L'inconvénient est que l'installation est relativement longue...

## Le titre le plus clickbait du blog

Je me suis bien marré en écrivant ce titre "accrocheur" (pour rester poli). Pour autant, il n'est pas vraiment faux. 

Évidemment, dans la vie capitaliste dans laquelle nous vivons, rien n'est jamais vraiment gratuit. Là en l'occurrence, je vais vous guider pour créer un cluster Kubernetes qui ne vous coutera rien *personnellement*, il sera juste payé avec nos audits Oracle(*).

**En revanche, ça va nous demander pas mal de taf**. On va utiliser plusieurs services d'Oracle Cloud Infrastructure, `k3s`, `traefik`, on va jouer avec le kubeconfig, ... Bref, ya du boulot, et c'est même trop long pour un seul article ! 

(*) Pour ceux qui n'ont pas la vanne, Oracle est historiquement connue pour sa politique tarifaire assassine (vive le vendor lock !), pour sa propension à changer les règles de licensing tous les ans, et le tout associé à des audits forcés (relativement scandaleux) chez les clients pour leur soutirer toujours un peu plus de thunes. Aaaah, c'était la bonne époque.

## En route vers le "free tier" de chez Oracle Cloud Infrastructure

Si je vous parle de cloud providers mondiaux américains, je suis sûr que vous allez penser AWS, Azure ou GCP. Les plus old school d'entre vous penseront peut-être à des providers comme IBM Cloud, les plus internationaux d'entre vous penseront peut-être à Alibaba cloud.

Mais qui a déjà testé Oracle Cloud Infrastructure (OCI) ? Car oui, Oracle fait du cloud, pas seulement des bases de données et des audits chez leurs clients.

C'est même un gros provider, très souvent cité dans la liste des "top 5 cloud providers".

Note : je n'ai pas du tout été vérifié les parts de marchés, peut être qu'Alibaba fait beaucoup plus, je parle juste en termes de résultats sur un moteur de recherche.

Ca fait des années que j'hésite à tester OCI car ils ont un free tier qui jusqu'à présent était plutôt correct et qu'ils ont *a priori* un rapport performance/prix bien meilleur que les 4 autres "gros" cloud providers.

Depuis quelques années, ils ont aussi décidé de miser une pièce (comme d'autres) sur l'ARM... J'en dis pas plus pour l'instant.

## On se crée un compte d'essai

Comme la plupart des clouds providers, on appâte le chaland avec un essai gratuit en plus de free tier. Chez OCI, c'est 300$ pour 30 jours d'essai (c'est un peu court mais il n'y a que GCP à ma connaissance qui donne plus).

![](/2023/04/oci_free_tier.png)

En échange de cet essai gratuit, il va falloir rentrer des informations personnelles et une carte de crédit valide (comme chez tous les autres). 

Oracle "garanti" cependant que tant que vous resterez sur le compte d'essai (que vous ne faites pas l'action de "mettre à niveau" votre compte), vous resterez sur un compte gratuit et vous ne serez jamais débité. Faites quand même un peu gaffe...

* [Lien d'inscription Oracle Cloud](https://signup.cloud.oracle.com/)
* [FAQ Oracle Cloud](https://www.oracle.com/cloud/free/faq/)

## Une fois le compte créé

La création du compte elle-même prend un peu de temps. On peut s'y connecter au bout de quelques minutes mais tout n'est pas encore finalisé. Dans mon cas tout était vraiment opérationnel au bout d'une demi-heure environ, soyez donc un peu patients...

Petite subtilité, on vous demandera de créer un **tenant** aussi appelé parfois **Cloud Account Name** (*zwindlercorp* par exemple) puis de vous connecter avec un email. C'est la manière pour Oracle de gérer le multi-utilisateurs sur leur plateforme.

Une fois connecté à la console, on peut commencer à faire joujou. La première chose qu'on va devoir faire est de se placer dans un "Compartment". Je n'ai pas creusé en détail cette fonctionnalité, pour faire simple on va se placer à la racine de notre "tenant".

![](/2023/04/tenant.png)

Puis, on va créer un **VCN** pour Virtual Cloud Networks, qui va être notre gros réseau privé virtuel dans tout notre tenant Oracle Cloud.

* [cloud.oracle.com/networking/vcns](https://cloud.oracle.com/networking/vcns?region=eu-paris-1)

J'ai utilisé le **VNC Wizard**, j'ai cliqué sur "Create VCN with Internet Connectivity" (l'option par défaut) et j'ai juste donné un nom "vcn1".

Une fois que c'est terminé, on peut commencer à créer nos machines...

## Ampere

Je le disais en introduction, Oracle Cloud Infrastructure a misé en partie sur des infrastructures ARM. Et pour nous donner envie de tester, à mis en place un *free tier* plus qu'alléchant pour un lab perso :

> Each tenancy gets the first 3,000 OCPU hours and 18,000 GB hours per month for free to create Ampere A1 Compute instances using the VM.Standard.A1.Flex shape (equivalent to 4 OCPUs and 24 GB of memory). Each tenancy also gets two VM.Standard.E2.1.Micro instances for free.

Je passe sur les 2 instances E2.1.Micro (qui sont des VMs 1 cpu / 1 Go de RAM en x86 classique) pour parler plus en détail de la partie Ampere.

Oui, vous avez bien lu, on a le droit d'utiliser **4 OCPUs et 24 Go de RAM gratuitement**. Et le mieux dans tout ça, c'est qu'on peut le répartir entre plusieurs machines (par tranches de 1 OCPU / 6 Go de RAM) !

Je ne sais pas vous, mais moi j'ai eu des labs avec bien moins de ressources que ça !

## Compute

On va donc créer pour notre cluster Kubernetes 2 machines Ampere de 2 OCPUs et 12 Go de RAM. L'une sera notre control plane, l'autre notre worker.

Note : rien ne vous oblige à faire le même setup. Vous pouvez faire 4 machines de 1 OCPU / 6 Go de RAM, une de 1/6 et une de 3/18, etc.
Note 2 : pour la petite histoire, c'est sur ce type de machine que j'ai fait la démo dans mon talk ["Démystifions le comportement interne de Kubernetes" à DevoxxFR 2023](https://blog.zwindler.fr/2023/04/14/devoxx-2023-recap-jour-2/) et ça a très bien marché ;-P.

* [cloud.oracle.com/compute/images](https://cloud.oracle.com/compute/images?region=eu-paris-1)

On prendra soin de changer l'OS (j'utilise une Ubuntu 22.04 classique, mais en vrai vous pouvez en utiliser d'autres) et la "shape" :

![](/2023/04/ampere.png)

Dans la partie Networking, il va falloir cliquer sur "Edit" sinon la machine ne pourra pas se créer. On va affecter la machine à notre VCN qu'on vient de créer plus haut juste en cliquant sur "Edit" (les valeurs se remplissent par défaut).

![](/2023/04/machine_vcn.png)

Pour terminer, n'oubliez pas d'ajouter une clé SSH sans quoi vous ne pourrez pas vous connecter sur vos machines...

Je crée donc 2 machines avec ces informations, une qui s'appelle **controlplane** et l'autre qui s'appelle **worker**. Au bout de quelques minutes, les machines sont accessibles.

![](/2023/04/instances.png)

Récupérez et mettez de côté les IPs privées / publiques de chaques machines.

## Ouverture des ports internes

Contrairement à d'autres cloud providers, les firewalls sont configurés (plutôt bien d'ailleurs) par défaut sur toutes les images OCI disponibles.

Si vous essayez d'installer Kubernetes sur une de ces machines, il est probable que l'installation échouera car les flux (même internes) seront bloqués.

On va devoir se connecter sur nos machines pour autoriser explicitement certains flux. Pour voir comment c'est configuré par défaut, vous pouvez aller voir le contenu du fichier rules.v4 :

```bash
cat /etc/iptables/rules.v4
# CLOUD_IMG: This file was created/modified by the Cloud Image build process
# iptables configuration for Oracle Cloud Infrastructure
[...]
```

Voici la liste des choses qu'on va devoir ouvrir :
* l'accès pour 10.42.0.0/16 (CIDR des pods) et 10.43.0.1/16 (CIDR des services)
* l'accès au control plane  / port 6443 sur tout le LAN privé

Sur le control plane, lancez les commandes suivantes (remplacez YOUR.OWN.IP.ADDRESS par les bonnes valeurs) :

```bash
# allow flannel traffic from/to 10.42.0.0/16 (pods) and 10.43.0.0/16 (services)
sudo iptables -I INPUT -s 10.42.0.0/15 -j ACCEPT
sudo iptables -I FORWARD -o cni0 -j ACCEPT
sudo iptables -I FORWARD -o flannel.1 -j ACCEPT
sudo iptables -I FORWARD -i flannel.1 -j ACCEPT
sudo iptables -I OUTPUT -o cni0 -j ACCEPT
sudo iptables -I OUTPUT -o flannel.1 -j ACCEPT
sudo iptables -I OUTPUT -d 10.42.0.0/15 -j ACCEPT

# Allow api access to private lan
sudo iptables -I INPUT -p tcp -s 10.0.0.0/24 --dport 6443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# save rules
sudo netfilter-persistent save
```

Sur le worker, lancez les mêmes commandes mais dans la partie "Allow api access to private lan".

## Ouverture des ports côté VCN

En plus de devoir configurer les firewalls côté OS, on va aussi devoir autoriser les flux internes sur le VCN. Dans la liste des VCN, cliquez sur le subnet "public", puis sur "Default Security List for vcn1" tout en bas.

![](/2023/04/default_security_list.png)

On tombe sur un tableau de tous les flux autorisés sur ce VCN (Ingress et Egress). Cliquez sur "Add Ingress Rules" pour en ajouter une nouvelle.

![](/2023/04/add_ingress_rule.png)

On va d'abord devoir explicitement ajouter des règles pour permettre à nos machines de se parler entre elles. Pour faire simple dans ce tutoriel, j'ai autorisé tout le traffic sur le lan **10.0.0.0/16**. 

Pour un lab, c'est largement suffisant. Dans un contexte de production, on voudra par contre explicitement autoriser les flux un à un. Vous pouvez trouver une liste des flux à ouvrir via [la page de documentation de k3s](https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-server-nodes).

## Installation de Kubernetes

Pour aller plus vite dans ce tuto, je voulais utiliser l'outil [k3sup d'Alex Ellis](https://github.com/alexellis/k3sup) (aussi founder d'OpenFaaS), mais j'ai eu du mal à faire comprendre à l'outil que je voulais utiliser les IP publiques pour me connecter en SSH, et les IP privées pour les connexions vers l'API server.

Je vais donc utiliser `k3s` directement, en me connectant en SSH sur les machines directement.

Sur le node controlplane :

```bash
curl -sfL https://get.k3s.io | sh -
```

`k3s` devrait s'installer en quelques secondes. Récupérez le contenu du fichier `/var/lib/rancher/k3s/server/node-token` qui contient le token pour ajouter des nodes.

On installe ensuite le node worker :

```
CONTROLPLANE_PRIVATE_IP=x.x.x.x
curl -sfL https://get.k3s.io | K3S_URL=https://${CONTROLPLANE_PRIVATE_IP}:6443 K3S_TOKEN=valeur-du-fichier-node-token sh -
```

Au bout de quelques minutes (une seule devrait suffire, en vrai), vous devriez pouvoir commencer à accéder à votre cluster depuis le serveur controlplane

```bash
root@controlplane:~# kubectl get nodes
NAME           STATUS   ROLES                  AGE   VERSION
worker         Ready    <none>                 35m   v1.26.3+k3s1
controlplane   Ready    control-plane,master   39m   v1.26.3+k3s1
```

Tadaaaaa 🎉🎉

## Is this the end?

En vrai, il reste encore pas mal de taf (récupérer le kubeconfig pour notre poste, ouvrir les flux pour traefik, ...) pour que notre cluster soit vraiment opérationnel et l'article est déjà assez long (11000 signes)...

Ca va mériter une "part2" ultérieure ;-P.

Edit : [la suite est ici](/2023/05/23/cluster-kubernetes-gratuit-part2/)
