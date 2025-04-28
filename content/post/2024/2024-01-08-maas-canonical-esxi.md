---
title: 'Déployer un hyperviseur VMware ESXi avec MAAS'
authors:
  - zwindler
type: post
date: 2024-01-08T18:00:00+02:00
url: /2024/01/08/maas-canonical-esxi
image: /2024/01/bearmetal2.jpeg
categories:
  - DIY
  - Virtualisation
tags:
  - Homelab
  - Baremetal
  - Ubuntu
  - MAAS
  - Metal as a Service
  - VMware
  - ESXi

---

Cet article fait partie d'une série d'articles dédiés à la découverte de MAAS, un outil de déploiement d'OS sur un parc de serveurs (souvent baremetal mais pas que) :
* [Premiers pas avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical](/2023/12/21/premiers-pas-avec-maas-baremetal-canonical)
* [Un peu plus loin avec MAAS - Metal as a Service, l’outil de déploiement de machines baremetal de Canonical](/2024/01/04/un-peu-plus-loin-avec-maas-canonical)
* [Déployer un hyperviseur VMware ESXi avec MAAS](/2024/01/08/maas-canonical-esxi)

## Résumé des épisodes précédents

Dans les deux derniers épisodes, on a vu comment déployer MAAS sur un lab perso, comment déployer ensuite nos premiers OS sur des machines baremetal de manière automatisée, comment les customiser en changeant de version d'Ubuntu ou avec cloud-init.

Mais dans les promesses de MAAS, il y a plus que ça. En théorie, on doit pouvoir démarrer "out of the box" (ouais pas tout à fait, mais je ne spoil pas plus) des serveurs d'autres OS, comme Windows (beurk) ou des hyperviseurs VMware ESXi. Et même plus (mais ça n'est pas le but de cet article pour l'instant).

![](/2024/01/deploy-any.png)

## ESXi ?

Vous l'avez compris, point de Windows Server dans ce tutoriel, cependant sachez qu'avec les deux liens que j'ai déjà donnés dans l'article précédent, vous devriez pouvoir vous en sortir :

* [Documentation de Canonical MAAS - How to customise images](https://maas.io/docs/customising-images-for-specific-needs)
* [Discourse de Canonical MAAS - How to build MAAS images](https://discourse.maas.io/t/how-to-build-maas-images/5100)

Même si c'est un hyperviseur propriétaire, j'ai quand même passé pas mal de temps à travailler avec VMware et j'ai toujours été relativement content d'ESXi (no comment sur le reste de la "suite" par contre).

Note : vous pouvez d'ailleurs retrouver tous [les articles qui parlent de VMware](https://blog.zwindler.fr/recherche/?keyword=vmware) sur ce blog, ça date un peu, mais il reste peut-être des trucs utiles.

On va donc voir si c'est si facile que ça...

## Ubuntu Pro ?

La première chose qu'on apprend dans la doc, c'est qu'il existe 2 manières de customiser des OS non Ubuntu pour les faire marcher dans MAAS : 
* [Packer MAAS](https://github.com/canonical/packer-maas)
* MAAS Image Builder

MAAS Image Builder nécessitant une souscription Ubuntu Pro, je vais évidemment me rabattre uniquement sur Packer MAAS...

Heureusement, le projet est relativement bien fourni, avec des CentOS (8 ou 9 stream), des Debian jusqu'à la 12, et donc... VMware ESXi, de la 6 à la 8.

Pour cet article, je me suis d'abord basé sur le [tutoriel officiel](https://maas.io/tutorials/maas-esxi-quickstart#1-overview), mais il est sévèrement "pas à jour" (on a un petit doute dès la première étape qui demande d'utiliser Ubuntu 18.04) et pointe vers des versions obsolètes...

## Installer Packer

Comme son nom le laisse deviner, on va avoir besoin de Packer, un tool de mes copain⋅es de chez [Hashicorp](https://blog.zwindler.fr/recherche/?keyword=hashicorp). Pour l'instant personne n'a forké Packer, donc :

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer
```

On vérifie que ça a bien marché

```bash
packer --version
    Packer v1.10.0
```

## Récupérer un ISO chez VMware

Alors, là, c'est la partie pénible. Si on n'est pas client VMware, il n'est pas possible de télécharger d'ISO de VMware ESXi sans :
* se créer un compte
* demander un trial sur une version (idéalement la dernière) d'ESXi

C'est pénible, ça demande plein d'infos personnelles et ça pourri les BAL, mais bon... c'est ça aussi, d'utiliser des logiciels privateurs. Avant, l'usage de l'ESXi était gratuit, mais visiblement, c'est de l'histoire ancienne...

![](/2024/01/download-trial.png)

Pas de bol, j'avais fait mes premiers tests sur VMware ESXi 8.0u1, et j'ai voulu récupérer la u2, mais voici ce que me dit VMware

> Your evaluation has expired on August 29, 2023

Pour paraphraser un certain Linus T., **F... YOU VMware!** Tant pis, je vais donc faire avec l'ISO que j'ai...

* VMware-VMvisor-Installer-8.0U1a-21813344.x86_64.iso

## Récupérer packer-maas

Si vous suivez le tuto que je vous ai donné en début d'article, il y a un moment où on va vous demander un Nom/Prénom/Email pour avoir le droit de télécharger un script pour transformer notre ISO VMware en image MAAS.

* [maas.io/vmware-images](https://maas.io/vmware-images)

Sauf que :

1. l'archive que vous allez télécharger est obsolète et ne fonctionnera pas
2. les sources et les releases sont dispos et à jour sur le [github du projet](https://github.com/canonical/packer-maas/tree/main)

Rant: Je suis éventuellement OK pour donner mes informations personnelles en échange de l'outil, mais s'il vous plait, gardez vos tutos à jour !?!

On va donc plutôt télécharger directement la dernière version de packer-maas qui supporte les Debian et des variantes de RHEL supplémentaires :\) et est disponible ici ([page de la release](https://github.com/canonical/packer-maas/releases/tag/v1.1.0) / [archive tgz](https://github.com/canonical/packer-maas/archive/refs/tags/v1.1.0.tar.gz))

```bash
wget https://github.com/canonical/packer-maas/archive/refs/tags/v1.1.0.tar.gz
tar xzf v1.1.0.tar.gz
cd packer-maas-1.1.0/vmware-esxi/
```

## Construire l'image VMware ESXi pour MAAS

On commence par charger le driver `nbd`. Si comme moi, vous ne savez pas ce que c'est, sachez que c'est [Network Block Devices](https://en.wikipedia.org/wiki/Network_block_device).

```bash
sudo modprobe nbd
# si ça ne renvoie rien, c'est bon
```

Ensuite, on lance Packer avec les arguments suivants :

```bash
sudo packer init .
sudo PACKER_LOG=1 packer build -var 'vmware_esxi_iso_path=../../VMware-VMvisor-Installer-8.0U1a-21813344.x86_64.iso' .
```

Note: packer-maas fourni aussi un Makefile pour vous simplifier encore plus la vie... Vous pouvez juste lancer `make ISO=/path/to/VMware-VMvisor-Installer.iso`

À ce moment-là, les scripts de packer-maas vont booter une VM avec notre ISO et réaliser des actions pour "l'installer" en envoyant des caractères dans une session VNC !

![](/2024/01/esxi-qemu-install.png)

Quand on y réfléchit, c'est à la fois un peu bourrin et *awesome* à la fois.

Si tout se passe bien, vous devriez vous retrouver avec un fichier `vmware-esxi.dd.gz` au bout de quelques minutes.

## ESXi dans MAAS

Maintenant qu'on a notre image, on va l'envoyer dans MAAS !

Sur l'UI, récupérer une clé pour API (sinon on ne pourra pas pousser l'image) sur votre utilisateur (il doit être avec des privilèges **admin**) :

![](/2024/01/apikey.png)

Je n'ai pas trouvé de menu dans la GUI pour le faire, mais on peut loguer notre terminal avec la commande suivante (en n'oubliant pas de renseigner l'API key) :

```bash
maas login admin http://192.168.x.y:5240/MAAS/
API key (leave empty for anonymous access): 
```

Puis envoyer l'image en CLI

```bash
maas admin boot-resources create name='esxi/8.0u1' title='VMware ESXi 8.0u1' architecture='amd64/generic' filetype='ddgz' content@=vmware-esxi.dd.gz
```

Note 1 : ne faites pas de Packer sur une partition Windows montée sous Linux (fuse + packer = KK)
Note 2 : si vous avez installé MAAS en tant que snap sur votre poste, vous ne pouvez accéder aux fichiers que dans votre /home (vous vous prendrez un "no such file or directory")

À partir de là, elle devrait apparaitre dans la liste des "Images" disponibles !

![](/2024/01/esxi-image.png)

Let's go la déployer sur une machine du lab... Et au bout de quelques minutes...

![](/2024/01/esxi_booted.jpg)

![](/2024/01/esxi-connected.png)

Victoire !
