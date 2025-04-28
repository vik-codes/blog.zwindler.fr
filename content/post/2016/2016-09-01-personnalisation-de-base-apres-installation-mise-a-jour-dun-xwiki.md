---
title: 'Personnalisation et paramétrage après installation d’un Xwiki'
authors:
  - zwindler
type: post
date: 2016-09-01T17:30:14+00:00
url: /2016/09/01/personnalisation-de-base-apres-installation-mise-a-jour-dun-xwiki/
image: /2015/11/1434473398.png
categories:
  - Logiciel
tags:
  - administration
  - color
  - couleur
  - logo
  - menu
  - personnalisation
  - skin
  - WYSIWYG
  - Xwiki

---
Lorsque vous aurez installé un XWiki pour la première fois,la première chose que vous souhaiterez probablement faire sera de le personnaliser. Voici quelques petites étapes qui vous permettront de le faire.

L’ensemble des modifications qui suivent sont à réaliser dans le menu d’administration.

## Changer la langue du XWiki

Par défaut, le XWiki est en anglais. Pour le passer en Français, aller dans

  * Administer Wiki
  * Configuration
  * Localization

![](/2016/08/lang01.png)

Positionner les deux paramètres « en » à « fr » et enregistrer (Save). La langue devrait changer automatiquement (sans redémarrage).

![](/2016/08/lang02.png)

A priori il existe aussi une fonctionnalité « multilingue » qui permet de gérer plusieurs langue. J’imagine que le wiki détecte alors la langue de l’utilisateur à l’aide de la langue du navigateur mais je ne l’utilise pas donc je ne peux pas vous faire de retours sur son fonctionnement.

## Changer l’apparence du XWiki par défaut

L’apparence du XWiki peut être changé dans le menu

  * Administrer Wiki
  * Apparence (anciennement « Look and Feel »)
  * Présentation

![](/2016/08/xwiki_skin.png)

Il existe plusieurs niveaux de personnalisation dans XWiki. Le skin avec le placement des éléments et les feuilles de styles, le thème de couleur et le thème des icônes. Personnellement j’utilise le thème de couleur Spacelab qui est sobre et clair. Vous pouvez bien sûr tout personnaliser vous même à partir de l’existant.

## Ajouter un logo

Sur les précédentes versions de XWiki, l’image devait faire 220 pixels de large et 80 pixels de haut et avoir comme nom « logo.png ». Ces limitations n’ont plus lieu d’être et vous pouvez uploader les images que vous souhaitez pour peu qu’elles soient dans un format accepté.

  * Administrer Wiki
  * Apparence (anciennement « Look and Feel »)
  * Présentation
  * Au niveau du skin, cliquer sur « Personnaliser »

![](/2016/08/logo.png)

  * Logo
  * Choisissez une pièce jointe
  * Sauver et visualiser

## Ajouter la couleur dans la barre d’outils de l’éditeur WYSIWYG

Par défaut, l’éditeur visuel (WYSIWYG) n’active pas le module de couleur (couleur du texte et surlignage). Pour autant, il peut facilement être ajouté car il s’agit d’un module intégré par défaut _mais désactivé_.

Pour l’activer :

  * Administrer Wiki
  * Applications
  * Éditeur WYSIWYG

![](/2016/08/wysiwyg01.png)

  * Dans la section plugins, ajouter **color** et cliquer sur le symbole « + » pour valider l’ajout du module à l’éditeur.
  * Dans la section barre d’outils, ajouter **forecolor** et **backcolor** pour ajouter respectivement les fonctionnalités _couleur de texte_ et _couleur de surlignage_.

![](/2016/08/wysiwyg02.png)

Les items peuvent être réordonnés comme souhaités et apparaîtront dans l’éditeur WYSIWYG dans l’ordre dans lequel ils sont placés dans cette section.

![](/2016/08/wysiwyg03.png)

## Et après ?

Il existe bien entendu plein d’autres paramètres pour personnaliser votre wiki comme par exemple désactiver les commentaires ou bloquer les utilisateurs anonymes. Je mettrai à jour cette page lorsque j’en trouverai des suffisamment utiles/importantes pour intéresser le plus grand monde.
