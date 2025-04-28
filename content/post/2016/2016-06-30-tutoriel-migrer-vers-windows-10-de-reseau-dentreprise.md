---
title: '[Tutoriel] Migrer vers Windows 10 en dehors de votre réseau d’entreprise'
authors:
  - zwindler
type: post
date: 2016-06-30T11:00:38+00:00
url: /2016/06/30/tutoriel-migrer-vers-windows-10-de-reseau-dentreprise/
image: /2016/02/57UKydQS.png
categories:
  - Système
tags:
  - 8024402C
  - Ce PC est joint à un domaine
  - Code 8024402C
  - domaine
  - erreur
  - gratuit
  - payant
  - Professionnel
  - Windows 10
  - Windows Update

---
## Mise à jour Windows 10 pour les pro, ok, mais si je suis hors de mon réseau d’entreprise ?

Maintenant que vous savez maintenant que vous pouvez profiter de la mise à jour gratuite de Windows Home ou Professionnel même si vous êtes une entreprise, vous allez peut être prendre votre portable et le ramener à la maison pour faire la mise à jour.

> [Mise à jour Windows 10 pour les professionnels : gratuit ou payant ?](/2016/06/23/mise-a-jour-windows-10-professionnels-gratuit-payant/)


C’est d’ailleurs ce que j’ai fais. Cependant, ça n’a pas marché du premier coup. C’est pourquoi je me propose de vous guider avec ce petit tutoriel pas à pas.

## Première erreur : je tente de mettre à jour depuis la popup « Obtenir Windows 10 »

Mais si ! Vous savez ? Cette notification pour vous poussez à mettre à jour vers Windows 10 qui reste en bas de l’icône. Difficile (pas impossible) à bloquer. Bon bah ok, d’accord je met à jour, laisse moi tranquille maintenant...

![](/2016/06/windows10_KO1-1.png)

> OK, cool

![](/2016/06/windows10_KO1-3.png)

> Ça a l’air de marcher

![](/2016/06/windows10_KO1-4.png)

> Et hop, on vous renvoie vers Windows Update

![](/2016/06/windows10_KO1-5.png)

> Et là c’est le drame ... Code 8024402C m’voyez ?

Mais comme je suis hors de mon réseau d’entreprise, je ne peux pas passer les mises à jour car je ne peux pas contacter mon serveur WSUS...

## Seconde erreur : je vais cliquer sur « Mettre à niveau maintenant » sur le site de Microsoft

Qu’à cela ne tienne... Je vais sur le site de Microsoft et je télécharge le binaire de mise à jour ! Ahah !

![](/2016/06/windows10_1.png) 

![](/2016/06/windows10_KO1.png)

> So far, so good

![](/2016/06/windows10_KO2.png)

> Re-drame. Ce PC est joint à un domaine m’voyez ?

Microsoft a bloqué intentionnellement la mise à jour de Windows 10 depuis le poste de travail d’un utilisateur d’un PC intégré à un domaine Windows.

Dans la pratique, on peut « contourner » cette limitation en sortant la machine du domaine (nécessite que l’utilisateur soit administrateur du PC) et demande ensuite à sont administrateur préféré de réintégrer sa machine une fois la mise à jour passée. Mais il y a plus simple ;-)

## La bonne méthode : faire semblant de créer un média

Sur la même page web que celle où vous avez trouvé le binaire de mise à jour, il y a une deuxième section, dans laquelle on vous propose de télécharger l’outil de création de média.

![](/2016/06/windows10_2.png)

Et en fait, on peut feinter en utilisant cet outil pour réaliser la migration, sans pour autant réellement créer un média.

![](/2016/06/windows10_4.png)

![](/2016/06/windows10_5choix1.png)

Choisir « Mettre à niveau ce PC maintenant permettra » de sauter l’étape de création de média et mettre à jour votre machine. L’autre option permet de créer un média bootable qui vous permettra éventuellement de passer la mise à jour sur plusieurs machines.

![](/2016/06/windows10_6choix1.png)

> A partir de là, Windows télécharge l’image...

![](/2016/06/windows10_7choix1.png)

> ... et créé un média bootable

![](/2016/06/windows10_8.png)

![](/2016/06/windows10_9.png)

![](/2016/06/windows10_10.png)

> Dernier petit point de blocage potentiel !

Certaines applications (comme HP Client Security Manager, qui gère mes mots de passe et surtout mon lecteur d'empreintes pour l’authentification) peuvent ne pas être compatibles Windows 10. Il faudra les désinstaller (et potentiellement rebooter et tout recommencer car l’application devra RE-télécharger l’image) pour pouvoir continuer.

![](/2016/06/windows10_11.png)

> Et c’est partiiiiii !
