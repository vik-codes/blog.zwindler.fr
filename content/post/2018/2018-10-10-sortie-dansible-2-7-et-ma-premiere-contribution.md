---
title: 'Sortie d’Ansible 2.7 et ma première contribution'
authors:
  - zwindler
type: post
date: 2018-10-10T12:15:12+00:00
url: /2018/10/10/sortie-dansible-2-7-et-ma-premiere-contribution/
image: /2018/10/ansible_logo.png
categories:
  - Script
  - systeme
tags:
  - ansible
  - Ansible 2.7
  - azure
  - contribution
  - Docker
  - easyfix
  - GCP
  - github
  - Kubernetes
  - OSS
  - pull request
  - Xwiki

---
## Sortie d’Ansible 2.7

Hier soir, la dernière version d’Ansible (2.7) est sortie. Cette release s’est concentrée sur une amélioration de la performance et de la stabilité, même si de très nombreux modules ont fait leur apparition, comme à chaque nouvelle version.

### Python

Le support de Python 2.6 est abandonné, au profit de Python 2.7. Cela signifie que l’hôte qui exécutera le playbook devra disposer de Python 2.7 au minimum (même si Python 2.6 est toujours supporté sur la machine cible).

### Écritures concurrentes

Un problème auquel j’ai déjà eu affaire est la gestion des écritures concurrentes sur un même fichier (par exemple si plusieurs hôtes écrivent sur un même fichier distant ou alors un delegate_to). A priori il existe maintenant un « lock » pour éviter d’écraser les modifications. Il faudra que je teste pour voir si ça marche bien.

### Performances accrues, généralisation du SSH pipelining ?

La plus grosse modification, qui va nécessiter des tests approfondis, est la modification de la manière dont sont déclenchées les actions/modules sur les serveurs distants. Précédemment, les tasks nécessitaient 2 commandes SSH au lieu d’une maintenant. Effectivement, le temps d’exécution de playbooks contenant des actions simple mais très nombreuses pouvait être très long.

> Ansible-2.7 changes the Ansiballz strategy for running modules remotely so that invoking a module only needs to invoke python once per module on the remote machine instead of twice.

Un gain de performance dans ce genre de cas où on passe plus de temps à lancer des commandes que les exécuter est forcément une bonne nouvelle. Je me demande si ce n’est pas simplement une activation « par défaut » de la variable d’environnement ANSIBLE\_SSH\_PIPELINING=1 (que j’utilise déjà dans ce genre de cas).

A priori non [si j’en crois cette issue][1], mais pour l’instant je n’ai pas remarqué de différence significative sur mes playbooks les plus gourmands en temps d’exécution.

### Module reboot

A noter, la plupart des gens remontent l’arrivée d’un module « reboot » (et son équivalent « win_reboot ») qui redémarre une machine et ré-initie une connexion une fois que la machine a refait surface. Personnellement je n’utilise pas ce genre de fonctionnalité mais j’imagine que c’est une feature « nice to have » plutôt que d’utiliser le module « pause » ou la fonctionnalité « retry » en attendant que l’hôte refasse surface.

## Les nouveaux modules

Je ne vais pas en faire la liste complète (disponible [dans le changelog][2]), mais cette version a visiblement été l’occasion pour les équipes de plusieurs cloud providers de se mettre en avant.

On peut noter les équipes de Google Cloud comme grands vainqueurs avec 39 nouveaux modules. Ils sont suivi par Azure (+21, avec l’apport des bases de données et des webapps), Vultr (13), et 8 pour Scaleway.

Tout ça m’intéresse beaucoup car, notamment pour Scaleway, de nombreux objets étaient encore indisponibles et il a fallut que j’écrive des scripts à la main pour curler l’API, ne serait ce que pour [récupérer les IDs des templates de VMs][3] que je voulais utiliser (impossible à lister autrement).

Avant :

```
curl -X GET -H "X-Auth-Token: $SCW_API_KEY" -H 'Content-Type: application/json' https://cp-par1.scaleway.com/images | jq -r '.images[] | select(.name|contains("CentOS")) | .id,.name,.arch,.modification_date'
37832f54-c18f-4338-a552-113e4302a236
CentOS 7.4
x86_64
2018-09-06T10:40:08.145552+00:00
[...]
```

Maintenant, je peux sois l’exécuter à la main directement depuis Ansible, soit requêter le serveur Scaleway pour avoir une liste des images disponible directement dans mes playbooks :

```
ansible localhost -m scaleway_image_facts -a region=par1
 [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

localhost | SUCCESS => {
    "ansible_facts": {
        "scaleway_image_facts": [
            {
                "arch": "x86_64",
                "creation_date": "2018-09-14T10:01:24.268850+00:00",
                "default_bootscript": {
                    "architecture": "x86_64",
                    "bootcmdargs": "LINUX_COMMON scaleway boot=local nbd.max_part=16",
                    "default": false,
                    "dtb": "",
                    "id": "15fbd2f7-a0f9-412b-8502-6a44da8d98b8",
[...]

- name: Gather Scaleway images facts 
  scaleway_image_facts: 
    region: par1
  register: images_facts
```


Et tant qu’on est dans le genre module qui vient remplacer des trucs que je faisais à la mimine, on peut aussi citer [docker_swarm][4] + [docker\_swarm\_service][5] pour gérer un cluster docker Swarm (comme son nom l’indique), ou [k8s_facts][6] pour récupérer des objets dans Kubernetes.

## Et ma première contribution !

Même si j’ai déjà contribué sur plusieurs projets open source (traductions du site de Shinken, petites contributions à plusieurs plugins Nagios et à XWiki, ouverture d’issues dans de nombreux projects open source), j’ai également résolu ma première issue sur un gros projet grâce à Ansible et l’équipe d’Azure.

Il y a peu, Microsoft a mis à disposition sur Azure de machine virtuelle disposant gratuitement d’interface physique dédiées (non virtualisées donc) à 30 Gbps et avec une latence moindre (plus d’info sur [la documentation officielle][7]).

Comme il s’agissait d’un simple flag à ajouter dans l’API et que [l’issue avait été taguée en « easy fix » par les maintainer][8], j’ai sauté sur l’occasion et j’ai pris l’issue à mon compte.

![](/2018/10/accelerated_network_ansible1.png)

Au final, sur les 70 lignes de mon commit, il n’y a que 10 lignes de codes (le reste étant des tests et de la documentation, obligatoires pour toute soumission), mais je suis quand même content car ça marche bien ;)

![](/2018/10/accelerated_network_ansible2.png)

> Champomy !!

 [1]: https://github.com/ansible/ansible/issues/36275
 [2]: https://github.com/ansible/ansible/tree/stable-2.7/changelogs
 [3]: https://docs.ansible.com/ansible/2.7/modules/scaleway_image_facts_module.html#scaleway-image-facts-module
 [4]: https://docs.ansible.com/ansible/2.7/modules/docker_swarm_module.html#docker-swarm-module
 [5]: https://docs.ansible.com/ansible/2.7/modules/docker_swarm_service_module.html#docker-swarm-service-module
 [6]: https://docs.ansible.com/ansible/2.7/modules/k8s_facts_module.html#k8s-facts-module
 [7]: https://docs.microsoft.com/fr-fr/azure/virtual-network/create-vm-accelerated-networking-cli
 [8]: https://github.com/ansible/ansible/issues/41218
