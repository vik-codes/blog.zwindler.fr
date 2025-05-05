---
title: Un cluster Proxmox VE en 5 minutes avec Ansible
authors:
  - zwindler
type: post
date: 2019-07-22T11:45:34+00:00
excerpt: Tutoriel aidé de playbooks Ansible pour générer des VMs sur Scaleway et démarrer un cluster Proxmox VE
url: /2019/07/22/proxmox-en-5-min-ansible-tinc/
image: /2017/08/cropped-proxmox_logo-1.png
classic-editor-remember:
  - block-editor
categories:
  - autohebergement
  - Cluster
  - Virtualisation
tags:
  - KVM
  - LXC
  - openvpn
  - Proxmox
  - Proxmox VE
  - QEMU
  - tinc
  - VPN

---

## Cool on va (encore) déployer du Proxmox VE !!!
  
  
Petit tuto aujourd’hui, massivement facilité par l’usage d’Ansible : on va déployer un cluster de machines Proxmox VE via le cloud provider Scaleway.

A noter : Si jamais vous ne voulez pas utiliser Scaleway, les playbooks ont été découpés de manière à ce que la partie d’installation de Proxmox ainsi que l’installation de tinc et la mise en cluster puissent être réalisés à part. Vous pouvez donc tout à faire partir de machines sous Debian 9 via ces playbooks.

Pourquoi Scaleway me direz vous ? Tout simplement parce qu’ils ont, contrairement à d’autres, une très bonne API, qui a permis à un de leurs employés de faire de très bons modules Ansible, notamment un module permettant de gérer l’inventaire dynamique (pas besoin de renseigner un fichier hosts pour Ansible, c’est directement l’API qui nous liste les VMs).

J’ai d’ailleurs utilisé ce provider à plusieurs reprises pour cette raison (voir mon article sur [k3s et Ansible](/2019/03/21/deployer-en-5-minutes-un-cluster-kubernetes-sur-arm-avec-k3s-et-ansible/) ou mon talk à BDX I/O [Ami développeur, deviens un ops sans effort avec Ansible](https://www.youtube.com/watch?v=WPRE1_f0pyg)).

## Proxmox VE 5.4 ? Pourquoi pas 6.0 ?

La deuxième question, tout aussi légitime, repose donc sur "pourquoi diantre monter un cluster Proxmox VE 5.4 alors que tu viens de nous faire un article qui vante [les bienfaits de la version 6.0](/2019/07/16/sortie-de-proxmox-ve-6-0-les-nouveautes/) qui vient de sortir ?"

Et là j’ai deux raisons (une bonne et une mauvaise). La mauvaise, c’est simplement que l’article trainait dans mes brouillons et que je n’ai pas cliqué sur "Poster"... La "bonne" raison, c’est que la version 10 de Debian, qui est la base de Proxmox VE 6, n’est pas encore disponible sur Scaleway, ce qui complique un peu l’installation.

Lorsqu’elle le sera, je ne manquerais pas de faire un petit refresh de l’article ainsi que des playbooks Ansible ;)

## Déployer les VMs avec Ansible
  
  
Je l’ai dis juste avant, le gros avantage de Scaleway, c’est de pouvoir spawner des VMs à la volées avec Ansible et surtout d’avoir l’inventaire dynamique.

Petite (grosse?) limitation : comme il s’agit de VMs, il ne sera évidemment pas possible de faire tourner des VMs de type KVM/qemu sur ces machines (sauf moyennant un hack de type nesting de VM dans une VM).

Cependant, depuis quelques temps, je n’utilise plus du tout les VMs (je n’ai pas de workload Windows) et j’utilise plutôt des containers LXC.

C’est vraiment plus léger en terme d'empreinte mémoire (je n’ai jamais été embêté côté CPU mais côté RAM, chaque Mo compte) et ça se gère (install, gestion, sauvegarde) de la même façon qu’une VM, contrairement à Docker qui nécessite une gymnastique mentale complémentaire.

## Bon, on fait ça comment ?
  
  
Maintenant que j’ai posé le décor, on peut commencer le tuto. L’idée va être de :

* Créer des VMs
* Récupérer leurs informations (IP publique, surtout)
* Installer les prérequis de Proxmox VE (puis les rebooter pour passer sur le kernel PVE)
* Installer les prérequis et configurer tinc, le VPN qui va nous permettre d’initier le cluster et de laisser passer les trames multicast, nécessaires au clustering   
  
A l’issue de ces étapes, on arrêtera là l’automatisation et on passera sur quelques (rapides) étapes manuelles.

Ok, j’avoue que c’est dommage que tout ne soit pas automatisé. Mais le gros du boulot, c’est vraiment les étapes précédentes. Pour s’en convaincre, vous pouvez lire l’article que j’avais écris [pour la version 5.2 (mais avec OpenVPN)](/2018/06/05/creation-dun-cluster-de-virtualisation-proxmox-ve-5-2-x/) ou tout simplement lire le contenu des playbooks.

## Prérequis
  
  
Et oui, il y a quand même quelques prérequis à ce tuto. Il faudra :

* Avoir un compte sur Scaleway
* Avoir une clé SSH, avoir la clé publique à la racine du projet, et l’appeler admin.pub
* Installer les package pip


```
pip install jinja2 PyYAML paramiko cryptography packaging
```

* Installer Ansible depuis les sources (>= 2.8)
* Installer `jq`

J’aurai pu faire aussi un playbook pour ça, mais comme c’est très dépendant de votre distribution Linux (ou Windows ahaha), ...

## You token to me ?
  
  
Créez un token sur le site de Scaleway pour les accès distants et le stocker dans un fichier scaleway_token sur votre machine avec Ansible :


```
export SCW_API_KEY='aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
```


Puis sourcez le fichier :


```
source scaleway_token
```

A partir de maintenant, vous avez le pouvoir tout puissant du cloud au bout de vos doigts (et de votre CB) !

## Générer les machines
  

Là, on tire totalement parti du travail de [Rémy Léone sur https://github.com/scaleway/ansible et des modules Ansible pour Scaleway, intégrés au repo officiel](https://github.com/scaleway/ansible).

On va donc utiliser le playbook create_proxmox_vms.yaml pour :

* récupérer l’ID d’organisation du compte Scaleway (votre identifiant unique)
* récupérer un ID d’une image disque compatible debian Stretch (de la bonne taille)
* ajouter si nécessaire la clé SSH de l’admin dans le portail Scaleway, qui sera injectée dans vos VMs à leur création
* créer autant de machines que nécessaire


```
ansible-playbook create_proxmox_vms.yml
```


Bon, je vous ai pas menti, c’est quand même hyper simple non ?

A noter, actuellement le script traite les demandes de création de machines séquentiellement. Pour 3 VMs, comptez environ 3 minutes.

Cependant, si vous avez un gros besoin, sachez qu’il est possible de modifier le script pour les lancer en parallèle (déjà fait dans mon repo [ansible-deploy-azure](https://github.com/zwindler/ansible-deploy-azure/issues/2) sur Github) via la fonction async d’Ansible.

## Mise en place de l’inventaire dynamique
  
  
J’arrête pas de vous en parler depuis tout à l’heure, normalement dans Ansible, maintenant que nos VMs sont créées, pour pouvoir nous y connecter, on devrait créer un fichier texte "inventory" contenant la liste des hôtes et de leur IP (a minima). C’est fastidieux, surtout si vous avez beaucoup de VMs.

Et là, on a juste un fichier inventory.yml, contenant le nom du plugin, la région utilisée (Paris dans mon script) et le tag des machines générées :


```
plugin: scaleway
regions:
  - par1
tags:
  - proxmoxve
  ```

A partir de là, on peut vérifier le retour de la commande ansible-inventory


```
ansible-inventory --list -i inventory.yml
{
    "_meta": {
        "hostvars": {
            "x.x.x.x": {
                "arch": "x86_64",
                "commercial_type": "DEV1-S",
                "hostname": "test3",
[...]
    "proxmoxve": {
        "hosts": [
            "x.x.x.x",
            "y.y.y.y",
            "z.z.z.z"
        ]
    }
```

Petite hack SSH : comme Ansible se connecte en SSH aux hôtes distants, à la première connexion on va bloquer sur l’acceptation de la fingerprint.

Un moyen de bypasser ça en une ligne de commande est d’utiliser la commande ssh-keyscan et de coller tout ça dans votre known_hosts. On peut le faire avec ce petit oneliner :


```
ansible-inventory --list -i inventory.yml | jq -r '.proxmoxve.hosts | .[]' | xargs ssh-keyscan >> ~/.ssh/known_hosts
```

Ce n’est évidemment pas recommandé en production !!! Mais dans le cadre d’un test temporaire, vous me pardonnerez cette liberté.

Ajoutez votre clé SSH dans l’agent, puis vérifiez que vous pouvez vous connecter à tous les serveurs :

```
eval `ssh-agent`
ssh-add myprivate.key
```


```
ansible proxmoxve -i inventory.yml -u root -m ping
x.x.x.x | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
y.y.y.y | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
z.z.z.z | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```


## Préparation du serveur
  
  
Ok ! Maintenant, on a 3 (ou plus) VMs Debian 9. A partir de là, j’ai créé un playbook Ansible qui suit [la doc d’installation officielle de Proxmox sur un Debian Stretch](https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_Stretch).


```
ansible-playbook -i inventory.yml -u root proxmox_prerequisites.yml
```

A l’issue de l’installation, il est nécessaire de rebooter les serveurs (manuellement ou via ansible), pour passer sur le kernel de PVE.

## Installation et configuration de tinc

> C’est piou-piou.
  
Une fois que vos serveurs sont revenus à la vie, vous avez installé Proxmox. Pas mal hein ?

Cependant, chez Scaleway (et tous les autres providers que je connais), le multicast est coupé entre vos VMs. Et ça c’est la loose car tout notre clustering va passer par des trames multicast.

Pour bypasser ce souci de taille, le plus simple est de passer par un VPN, de créer un réseau privé virtuel entre toutes nos instances, qui lui ne filtrera rien.

Dans les articles précédents, [j’avais utilisé OpenVPN](/2018/06/05/creation-dun-cluster-de-virtualisation-proxmox-ve-5-2-x/) (parce que c’est ce que je connais le mieux). Le souci d’OpenVPN c’est qu’il fonctionne sur un base client-serveur. Or, dès qu’on dépasse les 3 serveurs, on se retrouve avec 1 serveur maitre et 2 (ou plus clients), et donc un SPOF...

L’avantage avec tinc, c’est qu’on a pas cette notion de client/serveur. Tous les tincs sont connectés à tous les tincs, dans un genre de gros maillage qui nous évite donc tout SPOF.

L’installation de tinc n’est en soit pas follement complexe (cf le [playbook](https://github.com/zwindler/ansible-proxmoxve/blob/master/tinc_installation.yml)), mais là encore, l’automatiser c’est toujours sympa.


```
ansible-playbook -i inventory.yml -u root tinc_installation.yml
```

## Etapes additionnelles manuelles
  
  
Une fois que vous en êtes là, on arrive dans les tâches non triviales à automatiser.

Actuellement, il n’est pas possible de créer un cluster Proxmox VE sans avoir un mot de passe root. Or, lors de la création des VMs, Scaleway utilise notre clé SSH (ce qui est beaucoup mieux). Nous allons donc devoir nous connecter sur l’ensemble des machines et réinitialiser le mot de passe du compte root.


```
root@test1:~# passwd
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
```


## Créer un cluster
  
  
Cette partie aurait pu être automatisée. Dans le tutoriel précédent, je le faisais en ligne de commandes, à cause d’une limitation dans le wizard de création de cluster. En effet, dans les précédentes versions de Proxmox, on ne pouvait pas sélectionner sur quelle interface réseau on souhaitait utiliser, et donc mon cluster ne passait pas par le VPN et les trames multicast ne passaient jamais.

Pour autant, maintenant on peut profiter du beau wizard tout neuf et le faire via la GUI :

* Se connecter à l’UI de Proxmox avec un des noeuds (le premier, au hasard)
* Dans Datacenter (à gauche), sélectionner Cluster puis cliquer sur "Create Cluster"
* Donner un nom au cluster, mais surtout, donner comme adresse ring0 l’adresse VPN (10.10.10.1 si on est sur le noeud 1)
* Une fois l’opération terminée, cliquer sur "Join Information", dans le même menu, et copier les informations en cliquant sur "Copy Information"




![](/2019/07/create.png)

## Joindre le cluster


* Se connecter sur l’UI de la 2ème machine
* Dans Datacenter, sélectionner Cluster puis cliquer sur "Join Cluster"
* Dans le champ "Information", coller les données récupérée lors de l’étape précédente. Les informations de connexion devraient automatiquement être remplies, **SAUF le Corosync ring0, qu’il faut positionner à 10.10.10.2"**, et le mot de passe root du noeud 1. Cliquer sur "Join".
* Si l’opération réussie, un message doit s’afficher pour dire de recharger la page

Répéter l’opération pour les noeuds suivants (3, voire ++)



![](/2019/07/clusterupandrunning.png) 

Et en attendant la même chose avec la v6, amusez vous bien :)
