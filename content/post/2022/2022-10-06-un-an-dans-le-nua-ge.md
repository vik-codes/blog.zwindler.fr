---
title: 'Un an dans le nua.ge'
authors:
  - zwindler
type: post
date: 2022-10-06T22:00:00+02:00
excerpt: "Retour d'expérience sur presque un an d'utilisation de l'hébergeur nua.ge"
url: /2022/10/06/un-an-dans-le-nua-ge
image: /2022/10/box.jpeg
categories:
  - Cloud
tags:
  - nua.ge
  - nuage
  - cloud
  - hébergement
  - REX

---

## C'est l'histoire d'un cloud

Vous vous en souvenez peut-être ?

L'an dernier, en novembre, un certain nombre de comptes techs twitter recevaient une box contenant des codes pour tester un tout nouveau fournisseur cloud, fièrement Français, du nom de [nua.ge](https://nua.ge).

J'avais été un peu surpris de recevoir, quelques mois plus tôt, un message de la part d'Iris, pour me demander si je voulais bien tester avec quelques autres "happy few" ce tout nouveau service cloud.

Pour la petite histoire, c'était la toute première fois qu'on me proposait ce genre de choses. C'était aussi la toute première fois où je me suis fait qualifier "d'influenceuse tech". Amusant.

J'ai attendu un peu (1 an) avant de faire un retour.

## Buzz, ou bad buzz ?

Pourquoi attendre pour ce retour ?

D'abord, parce que beaucoup d'autres ont dégainé plus tôt. Je vous ai mis les liens, en fin d'article, de tous les articles de mes pairs que j'ai retrouvés sur le sujet.

Ensuite parce que je voulais voir dans quelle direction le service allait aller.

Beaucoup ont reproché à nua.ge (à l'époque) d'être un peu "pauvre" en fonctionnalités, surtout par rapport à son positionnement tarifaire. A priori ce n'est pas forcément vrai, nuage se situe plutôt dans la moyenne (cf [l'étude de coud Mercato](https://projector.cloud-mercato.com/projects/state-of-the-art-of-european-iaas-compute-q2-2022)).

La société qui opère nua.ge Oxeva avait répondu à cette critique en disant qu'une roadmap était en cours d'élaboration et que les points les plus bloquants seraient rapidement adressés.

## Premiers pas avec l'interface

La première chose que j'ai remarqué est que l'interface était effectivement assez simple. Le site web vante d'ailleurs un service "simple mais pas simpliste".

L'onboarding était hyper efficace (un des meilleurs que j'ai vu). La page de création d'une nouvelle VM aussi.

![Vue du menu principal de nua.ge](/2022/10/menu-principal.png)

On a globalement cinq menus:
* un menu "espace de travail" dans lequel on a les machines du projet courant
* un pour gérer ces fameux projets (en créer un nouveau, le supprimer)
* un pour créer des utilisateurs (nouveau)
* un pour le suivi de la consommation
* un pour la facturation

Les deux derniers auraient pu être fusionnés je pense, je me trompe toujours et je les inverse...

A quelques détails près, c'est tout.

## Alors qu'en est il, 11 mois après ?

Je vais être franc, j'ai eu à ma disposition 10000€ de crédit. 

De quoi tester allègrement toutes les fonctionnalités et même héberger pas mal de trucs pendant un bon moment.

Au niveau de la stabilité du service, je n'ai rien à redire. 

Au cours des 12 derniers mois, le service a subi de brèves coupures réseau (et encore, c'est surtout les autres utilisateurs qui l'ont remonté). Mon monitoring externe n'a pas repéré grand-chose. 

Au niveau infrastructure, ça semble donc être du solide. 

Cependant, au niveau fonctionnalités, je vais être obligé d'être d'accord avec mes pairs. Même 11 mois après, on a vite fait le tour... On a des VMs, des projets... et c'est tout.

## Des défauts corrigés

La [roadmap publique](https://roadmap.nua.ge/) a été mise en ligne et il est possible de voter pour des fonctionnalités.

Ca avait été promis quasiment depuis le lancement : l'API publique et documentée a rapidement été mise en ligne et est [disponible ici](https://api.nua.ge/docs).

Au fil des mois, l'interface a elle aussi été améliorée. Possibilité de transférer des IPs publiques d'une machine à l'autre, ajout de disques plus gros pour les machines (500 Go si nécessaire au lieu de 100 par défaut).

Il est également possible d'avoir une gestion des utilisateurs avec une gestion des droits basique par projet que j'utilise beaucoup.

La gestion des groupes de sécurité (firewalling / flux réseau) ont été grandement améliorés. Au début on avait le choix qu'avec traffic web et traffic SSH, il y a maintenant plus d'options.

## Mais d'autres toujours bien présents

Certains des points remontés dès le début sont malheureusement toujours absents. Stéphane Bortzmeyer avait reproché à nua.ge son **absence d'IPv6**, c'est toujours le cas. Je l'avais également remonté via le "chat".

Le **provider terraform** (ou tout autre outil d'infrastructure as code) se fait toujours attendre. On [a l'API](https://docs.nua.ge/fr/article/apercu-des-possibilites-dautomatisation-avec-lapi-nuage-1mqkvux/) mais c'est très "manuel".

[Edit]Il existe un provider non officiel [github.com/MKCG/terraform-provider-nuage](https://github.com/MKCG/terraform-provider-nuage). Son créateur m'a contacté pour me l'indiquer, ainsi que le fait qu'il n'avait pas l'intention de le maintenir. Cependant, comme il est open source, n'importe qui pourrait potentiellement le faire.

Plus grave, l'interface a plein de petites limitations très agaçantes (rarement, on peut les contourner par l'API). 

## Les projets

Il ne semble **pas possible de modifier un projet** existant. On doit le supprimer (et tout ce qu'il y a dedans) et en refaire un nouveau. 

Toujours en parlant des projets, ils ont des quotas, fixés par défaut à 40 coeurs, 256 Go de RAM, 2 To de stockage et 20 IP publiques. 

![vue de création de projet pour nua.ge](/2022/10/projets.png)

Je trouve cette fonctionnalité très utile ! Cependant, quel intérêt de les afficher dans l'UI au moment de la création du projet, s'il n'est possible de les modifier ? Les **quotas sont donc immuables**, à la hausse (admettons) comme à la baisse !

## Les VMs

Encore plus grave, il n'est pas possible de modifier une machine virtuelle. 

Dans l'interface, les seules actions possibles sont : allumer, éteindre, redémarrer. **Impossible de changer sa taille** en cours de route, même éteinte. Il faut la détruire et en refaire une autre. Vous avez intérêt à bien prévoir votre capacity planning...

J'ai dû réinstaller entièrement des serveurs elasticsearch trop gros à cause de ça et j'ai bien ragé. Je suis toujours en colère, je crois.

On aurait pu contourner le problème en ré-attachant les disques, sauf qu'**ils ne sont pas détachables**. Un disque appartient à une VM, point. Il est créé avec, détruit avec. 

Cerise sur le gâteau, ça veut dire que ça compliquera aussi la réversibilité (pourtant un point capital dans le cloud...).

Enfin, c'est plus une problématique de poweruser / bidouilleur, mais il n'est **pas possible de donner un nom "long" à une machine** (mavm.example.org). C'est gênant, parce que la VM est ensuite déployée à l'aide de templates *cloud-init* et il est non trivial de changer le hostname en FQDN de manière pérenne.

En partie à cause de ça, j'ai été incapable d'installer Proxmox VE au dessus d'une installation Debian 11 fraîche (alors que j'avais réussi sur le IaaS de Scaleway).

## Conclusion

Ca fonctionne et j'en ai abondamment profité. 

J'utilise nua.ge depuis quasiment 1 an pour héberger des serveurs pour plusieurs associations auxquelles je participe, et je ne peux pas dire que je suis insatisfait du service rendu pour ces besoins basiques.

Oui, une bonne partie des promesses initiales sont là : l'interface est hyper simple, le billing est limpide, l'infra semble solide. 

Cependant, si je n'avais pas mes crédits gratuits, est ce que j'aurais choisi [nua.ge](https://nua.ge) pour héberger ces associations ?

> Car une fois l'enthousiasme des milliers d'euros de coupons et du parrainage retombés, il ne restera plus que les clients payant leurs factures.

Cette punchline de [David Legrand](https://www.nextinpact.com/article/68480/a-decouverte-nua-ge-cloud-simple-mais-pas-simpliste-groupe-la-poste) résonne toujours...

## Sources additionnelles

  * [nextinpact.com - À la découverte de Nua.ge, le cloud « simple mais pas simpliste » du groupe La Poste](https://www.nextinpact.com/article/68480/a-decouverte-nua-ge-cloud-simple-mais-pas-simpliste-groupe-la-poste)
  * [bortzmeyer.org - L'offre d'hébergement nua.ge](https://www.bortzmeyer.org/nuage.html)
  * [damyr.fr - Nuage, une Nième offre cloud souverain ?](https://www.damyr.fr/posts/nuage-yet-a-new-cloud-souverain/)
  * [Cloud Mercato - State of the art of European IaaS Compute - Q2 2022](https://projector.cloud-mercato.com/projects/state-of-the-art-of-european-iaas-compute-q2-2022)
