---
title: Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (2/3)
authors:
  - zwindler
type: post
date: 2025-02-17T10:30:00+02:00
excerpt: "Tutoriel de déploiement d'un clusters d'hyperviseurs Proxmox VE 8 - partie 2"
url: /2025/02/17/deploiement-d-un-cluster-proxmox-ve-8-part-2/
image: /2025/02/proxmox8.png
categories:
  - autohebergement
  - Cluster
  - systeme
  - Virtualisation
tags:
  - kimsufi
  - KVM
  - Proxmox
  - Proxmox VE
  - serveur dédié
  - virtualisation

---

Note - cet article fait partie d'une suite d'articles :

* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (1/4)](/2025/01/27/deploiement-d-un-cluster-proxmox-ve-8-part-1)
* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (2/4)](/2025/02/17/deploiement-d-un-cluster-proxmox-ve-8-part-2/)
* [Déploiement d'un cluster Proxmox VE 8 sur des serveurs dédiés (3/4)](/2025/03/25/deploiement-d-un-cluster-proxmox-ve-8-part-3/)
* [Hors série - SDN en mode VXLAN avec des machines sur Internet](https://blog.zwindler.fr/2025/03/30/tutoriel-sdn-vxlan-proxmoxve-8/)
* Et *au moins* un autre à suivre

## On reprend de là où on en était : premiers pas dans l'UI

Dans le tutoriel précédent (que je vous invite à lire, si ça n'a pas été fait, sinon ça ne sera pas clair), on a choisi un serveur physique dédié chez un provider type OVHCloud ou Hetzner. On a ensuite installé Proxmox VE dans la dernière version (8.x), configuré quelques options de sécurité de base, ajouté des utilisateurs et des groupes.

On peut maintenant essayer de se connecter à l'UI. La première chose qui devrait vous frapper (💥 aïe !) c'est que la page d'administration est en HTTPS avec un certificat autosigné. On va commencer par régler ça.

Un truc assez frustrant avec Proxmox VE (mais c'est probablement pour des "bonnes raisons" que j'ignore) c'est que certaines opérations ne sont pas possibles à réaliser dans l'UI si vous vous connectez avec le compte admin zwindler@pve que nous avons créé dans le blogpost précédent.

C'est typiquement vrai pour les mises à jour, la mise en cluster et la configuration et... pour **la configuration des certificats** (liste non exhaustive). Ici, on va donc devoir pour l'instant se connecter en root@pam et non pas en zwindler@pve...

![](/2025/02/auth-pam.png)

Notez bien qu'il y a (pour l'instant) 2 "realms", Linux PAM (pour root) et Proxmox VE Auth (pour l'admin).

![](/2025/02/auth-pve.png)

Dans la barre de droite, on retrouve notre serveur, qui est pour l'instant tout seul dans son datacenter (on y reviendra plus tard). Il y a plusieurs vues dans l'UI de Proxmox VE, certaines choses sont dures à trouver quand on n'a pas ça en tête. Ici, je suis dans la "server view", probablement la plus classique si vous venez du monde VMware. Dans ce menu, vous trouverez vos hyperviseurs et on pourra interagir avec chacun d'entre eux, comment ils sont configurés.

![](/2025/02/pve-first-login.png)

Une fois notre serveur sélectionné, on a donc le menu principal qui affiche de nombreux menus. Sélectionner **System / Certificates**.

![](/2025/02/pve-certs-01.png)

On a de la chance, Proxmox VE est livré avec un module pour commander tout seul des certificats [Let's encrypt](https://letsencrypt.org/fr/). Si vous avez votre propre certificat ça fonctionne aussi (bouton **Upload Custom Certificate**), bien entendu, mais je vais partir du principe que vous n'en avez pas, comme moi.

Dans la partie ACME, cliquer sur **Add ACME Account** pour enregistrer votre email et accepter les Terms Of Service (TOS) de Let's Encrypt.

![](/2025/02/pve-certs-02.png)

À partir de là, ajouter le FQDN de notre serveur en cliquant sur le bouton **Add** sous ACME. Le bouton était grisé tant que nous n'avions pas ajouté de compte.

![](/2025/02/pve-certs-03.png)

Maintenant, on peut enfin commander le certificat en cliquant sur **Order Certificates Now**. Si tout se passe bien, le certificat sera correctement livré par Let's Encrypt, et le serveur pve-proxy (qui sert le frontend de l'UI de Proxmox VE) devrait redémarrer, et votre page web se rafraîchir, avec un bon certificat cette fois-ci :).

![](/2025/02/pve-certs-04.png)

## Stockage / ZFS

Si vous lisez souvent mon blog et que je vous dis que je suis un fan inconditionnel de ZFS, vous ne serez pas surpris.

Et si vous avez bien lu l'article précédent, vous vous rappellerez que nous avons réduit la partition par défaut du template OVHcloud en LVM pour pouvoir faire une belle partition ZFS. Sauf que si on va dans la vue stockage, elle n'est malheureusement pas visible.

![](/2025/02/hulk_sad.gif)

Petite subtilité de l'UI, le menu pour ajouter du stockage se retrouve au niveau du Datacenter et non de la configuration du serveur lui-même. En théorie, la gestion du stockage doit être identique sur tous les serveurs d'un même DC dans Proxmox VE, même si on peut passer outre ce principe et mettre en place des exceptions depuis de nombreuses versions déjà.

Dans **Datacenter / Storage**, cliquez sur **Add**, puis ZFS dans le menu déroulant qui s'affiche :

![](/2025/02/storage-01.png)

![](/2025/02/storage-02.png)

Sur les stockages de type ZFS, on ne peut stocker que les "Disk images" et les "Containers", ce qui ne va pas nous arranger si nous voulons aussi stocker des ISOs, des templates ou des backups. 

On pourra se contenter de les stocker sur le stockage par défaut "local".

Mais on peut aussi "tricher" en se connectant sur le serveur en SSH, et en créant un dossier (/tank/data dans mon exemple), puis en créant un nouveau stockage de type Directory qui n'a pas de restriction sur les types de données.

![](/2025/02/storage-03.png)

## Parlons un peu de ZFS

Je me suis pris la tête un nombre incalculable de fois avec des gens qui persistent raconter n'importe quoi sur ZFS, même après leur avoir expliqué.

> C'est faux. Et archifaux. Euh...

* non, il n'y a pas besoin d'avoir de la RAM ECC pour stocker des choses sur ZFS. D'abord, c'est une préconisation (un peu zélée probablement) faites par des gens qui ont conçu un filesystem extrêmement robuste. De très nombreuses prods fonctionnent avec ZFS sans RAM ECC. Ensuite, c'est surtout vrai si vous faites de la déduplication, car la perte d'un bloc pour avoir des conséquences catastrophiques dans ce genre de cas...

* non, ZFS ne nécessite pas 1 Go de RAM par To de disque, là encore, c'est uniquement si vous activez la déduplication (pour stocker les tables de correspondance entre les hash et les blocs).

En revanche, ce qui est exact, c'est que par défaut, ZFS va essayer d'utiliser 50% de la RAM disponible sur votre serveur et de s'en servir de cache. Dans beaucoup de logiciels d'administration, y compris Proxmox VE, cette valeur va être beaucoup trop haut pour nous, car la RAM est une ressource précieuse sur un hyperviseur.

Ça ne veut pas dire que cette fonctionnalité est inutile. Avoir du cache quand on a de la RAM qui ne sert à rien, c'est toujours bien. Donc, on va aller réduire cette valeur pour éviter des conflits de ressources entre l'optimisation des perfs de notre stockage et la quantité de VMs qu'on peut héberger.

```bash
#Restrict to 512MB
echo 536870912 |sudo tee -a /sys/module/zfs/parameters/zfs_arc_max

#Restrict to 4GB
echo 4294967296 |sudo tee -a /sys/module/zfs/parameters/zfs_arc_max
```

Note : cette commande sera à persister d'une manière ou d'une autre

## Du réseau

Bon... j'ai essayé de repousser au maximum le moment où on arrive au réseau (parce que je déteste ça) mais à un moment, il va bien falloir s'y mettre...

Par défaut, notre serveur Proxmox VE est installé avec un bridge Linux qui va nous permettre de partager du réseau entre l'interface physique de notre serveur et nos machines virtuelles.

Ce setup fonctionne bien sur votre réseau local avec un DHCP et votre propre LAN IPv4 local ou si vous disposez d'un range d'IP (que ce soit v6 ou v4) et de quoi les affecter aux machines virtuelles.

Malheureusement dans mon cas, je n'ai qu'une IPv4 (je pourrais activer l'IPv6 mais j'aurais d'autres problématiques et je préfère rester simple ici). Si je crée des VMs et que je les affecte sur le bridge, elles ne récupèreront pas d'IP et n'auront pas accès à Internet.

Il existe plusieurs façons de connecter les machines virtuelles au réseau extérieur. Si vous avez du temps, je vous conseille de lire avec attention le Wiki de Proxmox VE qui a une très bonne page qui liste les différentes possibilités.

* [pve.proxmox.com/wiki/Network_Configuration](https://pve.proxmox.com/wiki/Network_Configuration)

Dans les précédents articles sur [Proxmox VE 5](/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1) puis [Proxmox VE 6](/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie/), on avait fait des trucs compliqués à base de plusieurs bridges, de DMZ, de firewalling PFsense, et d'un script IPtables de l'enfer.

![](/2017/07/proxmox-install_simple-infra-map.jpg)

Rien que d'y penser, je suis déjà épuisé.

Heureusement, il existe depuis plusieurs versions déjà un firewall intégré à Proxmox VE, ainsi qu'un SDN que je n'ai jamais pris le temps de découvrir et je pense que c'est le bon tuto pour le faire :).

On va donc se référer à la documentation officielle, et choisir le mode "Masquerading (NAT) with iptables", mais avec un setup plus simple par rapport à précédemment.

## Danger zone

La configuration de l'interface réseau peut en théorie se faire directement depuis l'UI plutôt qu'en allant modifier les fichiers de configuration (/etc/network/interfaces). Dans la vue du serveur, allez dans le menu **System / Network** :

![](/2025/02/pve-network-1.png)

Ici, on voit que je ne vous ai pas raconté de carabistouilles, et qu'on a bien un bridge avec notre interface physique (ici enp1s0). 

(On a même un range IPv6, ohlala 🙈 je n'ai aucune excuse... BREEEF, on va faire comme si on n'avait pas vu.)

On arrive maintenant au moment rigolo où on peut se couper la chique assez facilement. Je l'ai fait assez souvent et de passer en rescue... 

> fun fun fun fun

L'idée ici, c'est donc retirer l'interface du bridge, de configurer le réseau directement dessus, et de donner un réseau local pour nos VMs sur le bridge, tout en ajoutant les règles iptables pour faire le masquerading.

![](/2025/02/pve-network-2.png)

![](/2025/02/pve-network-3.png)

Tant qu'on ne cliquera pas sur le bouton **Apply Configuration**, on ne "risque" rien.

Le problème de l'UI est que nous n'allons pouvoir modifier QUE les IPs, les gateway et les interfaces sur le bridge ou non. Sauf que pour réaliser le masquerading et que nos machines virtuelles accèdent à Internet, nous devons ajouter les fameuses règles IPtables dont je vous parle juste avant et on ne peut pas le faire depuis l'UI.

Il va falloir rajouter les cinq dernières lignes dans la configuration du vmbr0...

```bash
cat /etc/network/interfaces
[...]
auto vmbr0
iface vmbr0 inet static
        address 10.10.10.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0

        # à ajouter pour que le masquerading fonctionne
        post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o enp1s0 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '10.10.10.0/24' -o enp1s0 -j MASQUERADE
        post-up   iptables -t raw -I PREROUTING -i fwbr+ -j CT --zone 1
        post-down iptables -t raw -D PREROUTING -i fwbr+ -j CT --zone 1
```

**Attention** : le point le plus important est de bien vérifier que l'interface de sortie (-o) a bien le bon nom. Ici, mon interface physique connectée à Internet est **enp1s0**, mais si la vôtre à un autre nom, il faut adapter.

De mon point de vue, l'UI n'est tout de même pas complètement inutile, car elle nous permet de faire le changement le plus touchy (échange des IPs) avec le diff visuel et le bouton "apply config". Les scripts post-up ont peu de chances de nous couper l'accès.

![](/2025/02/pve-network-4.png)

## Premier test

On est loin d'avoir fini (ça ne rentrera pas dans cet article, de toute façon, donc autant brûler les étapes...). Mais je suis sûr que vous êtes impatients de lancer une VM et on devrait avoir quelque chose de fonctionnel, bien qu'incomplet.

On va donc faire un petit test rapide de notre setup pour vérifier qu'on a bien un hyperviseur fonctionnel *a minima* (c'est-à-dire sans clustering, sans SDN, sans firewall, sans monitoring, sans sauvegarde... sans rien, en fait).

J'ai commencé à faire joujou avec [Talos Linux](https://blog.zwindler.fr/recherche/?keyword=talos) comme distribution Linux pour Kubernetes. Pour faire simple, je vais donc lancer l'install d'un Node Talos. Si elle arrive à s'enrôler dans l'interface Omni, ça veut dire que j'ai un hyperviseur fonctionnel, réseau inclus.

Une fois l'ISO généré sur le site de mon Omni (le control plane SaaS de Sidero Labs, l'éditeur de Talos Linux), on peut le pousser sur notre Proxmox VE. 

Pour le faire, depuis notre serveur (donc pas au niveau Datacenter), on sélectionne un pool de stockage qui accepte les images ISO (si vous vous souvenez bien, notre pool ZFS ne le supporte pas par défaut), on choisit **ISO Images**, et on clique sur **Upload** pour téléverser l'ISO (comme on dit en bon français).

![](/2025/02/iso.png)

Une fois uploadé, on peut maintenant cliquer sur le bouton bleu en haut à droite **Create VM**.

![](/2025/02/proxmox-create-01.png)

À partir de là, le wizard de création de VM devrait vous prendre la main. Ça va être un peu verbeux, mais tous les menus sont utiles, quand on commence à bien connaitre Proxmox VE. Je vous donne quand même le minimum :

Dans le premier menu, on ne va pas choisir sur quel node on installe la VM puisque pour l'instant, on en a qu'un... En revanche, on va devoir lui donner un ID (100 par défaut) unique pour tout le cluster. Idéalement, on lui donne aussi un petit nom. Moi, j'ai opté pour talos02 (car j'ai déjà un talos01 sur un autre serveur, vous avez vu comme je suis original ?).

Enfin, j'ai coché la case "Start at boot", c'est le genre de truc relou quand on a oublié de le mettre et que hyperviseur redémarre (ça arrive)...

On peut donner des tags à nos VMs, elles auront de jolies pastilles de couleurs pour les distinguer :)

![](/2025/02/create-vm-1.png)

Dans le second menu (OS), doit indiquer deux choses. D'abord, qu'on veut utiliser l'ISO qu'on vient de récupérer / uploader pour booter notre machine (il faut choisir le bon pool de stockage, par défaut, c'est "local" qui est sélectionné). On doit aussi donner le type d'OS pour des histoires de compatibilité de pilotes pour les périphériques virtuels. Ça fait belle lurette qu'on n'a plus trop besoin de ça, "6.X - 2.6" fonctionne pour tous les Linux récents (la sortie du kernel 2.6, c'est 2003 !). 

![](/2025/02/create-vm-2.png)

Je saute System, dans Disks, on ajoute un disque sur le bon pool (donc pas local, mais bien celui en ZFS). Pour ma VM Talos 32 Go, c'est largement suffisant... À noter qu'il existe beaucoup d'options importantes ici pour tout ce qui est "optimisation" des lectures / écritures, mais on est largement au-delà du scope de cet article.

![](/2025/02/create-vm-3.png)

Je saute CPU et memory, l'important, c'est de surtout lui donner au moins 2 cores et 2 Go de RAM (au moins). On peut là aussi optimiser les perfs CPU en activant les bons flags, mais là encore, on est plus dans le but de l'article donc je n'insiste pas.

Dans la partie network, on s'assure juste qu'on est bien branché sur le bon bridge (normalement si vous avez suivi l'article, on en a qu'un, **vmbr0**, donc on ne peut pas se tromper).

![](/2025/02/create-vm-4.png)

Et on vérifie que tout est OK. Protip, pour gagner cinq secondes dans votre vie, cliquez sur "Start after created", ce qui permettra de démarrer la VM au plus vite après sa création.

![](/2025/02/create-vm-5.png)

## It's alive?

À ce stade, la VM devrait automatiquement booter sur le CD Talos et l'OS devrait s'installer sur le disque. Une fois prête, la machine va essayer de s'enrôler sur mon control plane Omni.

*Et là, c'est le drame...*

Car oui, je n'ai pas configuré de DHCP ni de SDN. Il faut donc aller configurer à la main la carte réseau virtuelle (ce qui n'est pas foufou), en appuyant sur F3 dans la console.

(Et en subissant un peu de QWERTY, mais c'est à ça qu'on reconnait un bon sysadmin normalement : il sait faire du QWERTY dans les consoles)

![](/2025/02/talos02-config.png)

Une fois le réseau configuré, la machine devrait quasiment instantanément commencer à se configurer...

![](/2025/02/talos02-booted.png)

... et à s'enrôler dans omni :

![](/2025/02/omni.png)

Victoire !!

## Enfin bon...

Enfin bon... oui, on a une VM fonctionnelle. Mais j'ambitionne qu'on aille quand même un peu plus loin avant de vraiment crier victoire.

Comme je l'ai dit plus haut, on a dû configurer le réseau de notre VM à la main, et on a encore ni clustering, ni firewalling, ni SDN, ni monitoring, ni sauvegarde... Mais on chatouille allègrement les 16000 signes pour ce blogpost, il est donc temps de raccrocher pour se dire "à la prochaine fois".

Et en attendant, have fun :)