---
title: 'Signez l’UI de Proxmox VE avec Let’s Encrypt, c’est (encore plus) trivial'
authors:
  - zwindler
type: post
date: 2018-05-29T11:45:37+00:00
url: /2018/05/29/signez-la-console-proxmox-ve-avec-lets-encrypt-cest-encore-plus-trivial/
image: /2017/04/proxmox_letsencrypt.png
categories:
  - Système
  - Virtualisation
tags:
  - certificat
  - "Let's Encrypt"
  - Proxmox
  - TLS

---
## Signez votre console web Proxmox avec Let’s Encrypt, c’est trivial !


Voilà comment je titrais [cet article de blog que j’ai écris il y a à peine un an](/2017/05/02/proxmox-lets-encrypt/). A l’époque, la génération de certificats **Let’s Encrypt** pour signer la console se faisait en exécutant une dizaine de lignes vraiment très simple qui récupérait un script sur un dépôt git, l’exécutait, et le mettait en _crontab_.

![](/2018/05/proxmox_lets000.png)

> Extrait de l’article en question. Franchement c’était extra-simple

## Mais ça, c’était avant

![](/2018/05/ob_f080d1_jawad01.jpg)

> « Mais ça, c’était avant » (petit détournement Krys, pour ceux qui ne l’ont pas)

Parce que maintenant c’est **ENCORE** plus simple d’avoir son petit cadenas vert quand on se connecte sur son interface Proxmox ! J’en ai parlé dans [l’article sur la sortie de Proxmox 5.2](/2018/05/22/sortie-de-proxmox-ve-5-2-1-les-nouveautes/), il est maintenant possible de tout faire depuis l’interface de management.

Dans un premier temps, on se connecte donc normalement sur l’interface, puis on navigue vers un de nos serveurs, dans le menu **Système / Certificates**.

A partir de là, on peut cliquer sur le bouton **Edit Domains** pour ajouter le nom complet de notre serveur (`monserveurproxmox.mondomaine.tld`).

![](/2018/05/proxmox_certificate1-1.png)

Une fois validé, on peut enregistrer un compte. Il s’agit de l'email qui sera renseigné chez _Let’s Encrypt_ pour qu’ils vous préviennent de l’expiration proche du certificat si jamais par malheur le mécanisme de renouvellement venait à ne pas fonctionner.

![](/2018/05/proxmox_certificate2.png)

Une fois un email enregistré, vous pouvez maintenant commander votre certificat en cliquant sur le bouton **Order Certificate** (tout simplement)

![](/2018/05/proxmox_letsencrypt_last-1.png)


Proxmox va installer le certificat puis redémarrer le serveur **pve-proxy** (le démon qui gère la console de management) pour prise en compte. Le cadenas vert devrait apparaitre et les avertissements de sécurité disparaitre.

![](/2018/05/proxmox_letsencrypt_6-1.png)

> TADAAAA !

Et le tour est joué !

## A noter

Si jamais pour une raison ou pour une autre la génération du certificat ne fonctionne pas, n’insistez pas. Il faut savoir que **Let’s Encrypt** bloque les demandes de certificats au bout d’un certain nombre de tentatives ratées.

Si ce nombre a été augmenté suite aux plaintes d’utilisateurs un peu têtus/bourrins, faites quand même attention de ne pas vous retrouver bloqués et devoir attendre la fin du blocage...
