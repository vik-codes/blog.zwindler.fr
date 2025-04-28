---
title: 'Mieux migrer ses VM de Proxmox VE vers XCP NG (part 2)'
authors:
  - zwindler
type: post
date: 2022-08-08T06:00:00+02:00
excerpt: "Mise à jour de l'article pour migrer ses VMs de Proxmox VE vers XCP NG"
url: /2022/08/08/migrer-une-vm-de-proxmoxve-vers-xcp-ng
image: /2022/07/pve-to-xcpng.jpg
categories:
  - Virtualisation
tags:
  - QEMU
  - Proxmox
  - pve
  - XCP-NG
  - Xen
  - XenServer
  - API
  - cURL
---

## Résumé des épisodes précédents

Dans l'article d'il y a 2 semaines ([Migrer une VM de Proxmox VE vers XCP NG](/2022/07/24/migrer-une-vm-de-proxmoxve-vers-xcp-ng)), j'ai introduit très brièvement de XCP-NG (un OS clé en main pour faire de la virtualisation, sur une base de Xen / XenServer) et déroulé un tuto pour récupérer une VM sur Proxmox VE et l'importer dans XCP-NG.

Pour faire court, les étapes étaient les suivantes :
- Récupération du disque virtuel sur Proxmox VE
- Transformer le disque virtuel en VHD
- Le transférer sur le serveur XCP-NG
- Créer un disque dans XenOrchestra (l'UI de XCP-NG, pour faire simple)
- Importer le contenu du VHD dans le disque vide qu'on a créé dans l'UI
- Créer une VM dans l'UI et lui affecter le disque

## Faire mieux

Dans le cadre d'un PoC avec une poignée de VMs, ça me parait totalement acceptable comme méthodologie (même si c'est un peu fastidieux) mais dans le cadre d'une migration, c'est difficilement scalable.

**Note :** Vates (l'entreprise qui édite XCP-NG) accompagne ses clients pro dans cette étape. A ma connaissance,  ils travaillent également sur de l'outillage pour faciliter les transferts, mais Proxmox VE ne sera probablement pas la première "plateforme source" qui sera supportés par ce genre d'outils.

Dans cet article, je vais donc vous parler d'une méthode alternative qui m'a été conseillée par les gens de chez Vates pour faciliter cette migration, et plus particulièrement les étapes suivantes :
- Le transférer sur le serveur XCP-NG
- Créer un disque dans XenOrchestra (l'UI de XCP-NG, pour faire simple)
- Importer le contenu du VHD dans le disque vide qu'on a créé dans l'UI

## Because I'm API 🎶

> Clap along if you feel like that's what you wanna do

Vous l'avez deviné, on va passer par l'API de Xen Orchestra pour se faciliter la tâche. En effet, on va pouvoir rassembler les 3 actions ci dessus en seul appel via cURL ! 

Même s'il y a un petit prérequis (à faire une fois), ça sera quand même beaucoup plus scalable pour bouger plusieurs VMs.

## You token to me?

[EDIT] Depuis la version 5.72 de Xen Orchestra, il est possible de récupérer un token directement dans la Web UI (cf [ce post](https://xen-orchestra.com/blog/xen-orchestra-5-72/#%F0%9F%93%A1-rest-api-token-generation))

En lisant [la documentation de la REST API (paragraphe authentication)](https://xen-orchestra.com/docs/restapi.html#authentication), on apprend, sans surprise, que la première chose à faire est de récupérer un token permettant d'authentifier nos futures requêtes. 

On comprend ensuite que pour faire ça, on va avoir besoin d'un tool qui s'appelle [xo-cli](https://xen-orchestra.com/blog/xen-orchestra-from-the-cli/).

Si on suit la doc, il "suffit" d'installer ce module via `npm`.

```
npm install xo-cli
```

Bon... moi j'ai pas envie d'installer `npm` sur mon poste donc j'ai fais une image Docker cracra pour ça ;-).

```Dockerfile
FROM node

WORKDIR /app

RUN npm install --global xo-cli

ENTRYPOINT ["xo-cli"]
```

Le [Dockerfile est disponible ici](https://github.com/zwindler/docker-xo-cli) et l'[image docker buildée est disponible là](https://hub.docker.com/repository/docker/zwindler/xo-cli).

Depuis son poste (en remplaçant évidemment @IP.Xen.Orchestra par l'IP de votre serveur XenOrchestra, admin@admin.net par votre login)

```console
docker run -it xo-cli --createToken --allowUnauthorized @IP.Xen.Orchestra admin@admin.net Password: ************ 
Successfully logged with admin@admin.net
Authentication token created xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Si tout s'est bien passé, on récupère un token qu'on garde précieusement pour nos futures requêtes.

## champion de cURLing

De retour sur [la documentation de l'API REST (paragraphe VDI import)](https://xen-orchestra.com/docs/restapi.html#vdi-import), on trouve tout ce qu'il nous faut pour "crafter" notre requête cURL.

A minima, on va avoir besoin de UUID de notre storage. Pour rappel, vous pouvez trouver ça dans l'UI.

Si vous avez la flemme, vous pouvez aussi utilisez l'API REST pour récupérer les IDs des storages avec la requête suivante :

```console
curl \
    -k -b authenticationToken=xxxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxx \
    https://@IP.Xen.Orchestra/rest/v0/srs\?fields=name_label 
[
  ...
  {
    "name_label": "Local storage",
    "href": "/rest/v0/srs/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
  }
]
```

Depuis votre machine Proxmox VE (ou tout autre machine ayant directement accès au disque à exporter/importer), vous pouvez donc maintenant directement lancer la commande suivante :

```console
~# curl -X POST -k -b authenticationToken=xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -T toto.vhd 'https://@IP.Xen.Orchestra/rest/v0/srs/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/vdis?name_label=testexport.vhd' | cat
```

A l'issue de l'opération, vous allez récupérer l'UUID du disque sur XCP-NG, déjà disponible pour la construction de la VM côté Xen Orchestra.

## Conclusion

Avec cette méthode, une fois qu'on a un token, l'opération d'export/import Proxmox VE => XCP-NG devient donc suivante :

- Récupération du disque virtuel sur Proxmox VE (en gros retrouver le disque)
- Transformer le disque virtuel en VHD
- Importer et créer le disque dans XCP-NG via un cURL
- Créer une VM dans l'UI et lui affecter le disque

C'est déjà beaucoup plus sympa si vous avez plusieurs VMs à bouger. L'axe d'amélioration suivant est, à mon avis, de créer directement la VM avec le bon disque. 

A date, ce n'est pas possible avec l'API REST (vu avec Vates), mais ça serait possible avec l'API JSON-RPC (sur laquelle se base l'UI de XenOrchestra et xo-cli). Ca sera donc mes prochaines investigations ;).

D'ici là, have fun :)

## Bonus - Importer des RAW directement

Depuis la toute dernière version de Xen Orchestra, il est aussi possible d'importer directement des disques au format RAW (en rajouter le paramètre "raw" dans l'appel à l'API). 

Dans mon cas, c'est mon format de disques puisque tout est stocké en RAW sur mon storage ZFS Proxmox VE, donc en théorie on peut sauter une étape de plus, à savoir :
- Transformer le disque virtuel en VHD

Avec la requête suivante :

```console
curl -X POST -k -b authenticationToken=xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -T toto.img 'https://@IP.Xen.Orchestra/rest/v0/srs/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb/vdis?raw&name_label=testexport.raw' | cat
```

Attention aux limitations, cependant :

> Après le soucis du raw c'est que tu vas pas pouvoir profiter du copy on write, donc exit les snapshots (en l'état actuelle de la stack de storage, smapiv1)
