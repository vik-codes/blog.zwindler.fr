---
title: Changer la langue du correcteur orthographique de Notepad++ sans Internet (offline)
authors:
  - zwindler
type: post
date: 2018-04-24T11:30:54+00:00
url: /2018/04/24/changer-la-langue-du-correcteur-orthographique-de-notepad-sans-internet-offline/
image: /2018/04/Notepadpp.png
categories:
  - Logiciel
tags:
  - dictionnaire
  - Internet
  - langue
  - multilingue
  - Notepad++
  - offline
  - Open Office

---
## Notepad++ et le correcteur orthographique

Aaaaah, ça faisait longtemps que je n’avais pas été embêté par un proxy d’entreprise ! Il y a peu, j’ai commencé à travailler pour une nouvelle société et j’ai donc installé tous les outils que j’utilise au quotidien pour faire mon travail. Notepad++ en fait partie (sous Windows).

Le souci, c’est que parmi tout ce que j’édite sous Notepad++ ([du python](/recherche/?keyword=python), [des playbooks Ansible](/recherche/?keyword=ansible), ...), il arrive qu’il y ait des bouts de docs que je rédige en Français. Et pas de bol, par défaut, même si vous installez l’installeur Français de Notepad++, la langue du correcteur orthographique => c’est l’anglais (hyper logique).

## La solution « normale »

Première chose quand j’ai un problème => chercher des gens qui ont eu le même. Je suis tombé en 2,5 secondes [sur ce post de SyntaxTerror sur OpenClassrooms qui fait le taff][3].

> Pour mettre le correcteur orthographique de Notepad++ en français (ou dans une autre langue) :
> 
>   * Redémarrer Notepad++ en tant qu’administrateur (clic droit sur le programme ou le raccourci, « Exécuter en tant qu’administrateur ») ;
>   * Aller dans le menu Compléments/DSpellCheck/Change current language/Download more languages ;
>   * Choisir la langue désirée dans la liste ;
>   * Aller dans le menu Compléments/DSpellCheck/Change current language ;
>   * Choisir la langue désirée dans la liste.
> 
> --SyntaxTerror

![](/2018/04/notepadpp_spellcheck01.png)

> Ça manquait d’une petite screenshot quand même... alors je vous en fait un

![](/2018/04/notepadpp_spellcheck02.png)

> Allez soyons fous, j’en met même une seconde petite quand on clique sur « Download more langages »


Sauf que voilà... vous ne le savez pas encore mais vous <del datetime="2018-04-19T21:19:51+00:00">êtes déjà morts~~ passez par du FTP pour télécharger cette nouvelle langue.

## La solution « alamano »

Et pas de bol, vous êtes dans une entreprise sérieuse qui a tout est bloqué à part l’HTTP et l’HTTPS. Rien d’autre ne sort ni ne rentre, impossible donc de passer par le FTP qui héberge le pack de langue FR (ou catalan) !

Ou même pire encore, vous travaillez chez des gens qui n’ont pas accès à Internet du tout (et vous faites du stackoverflow/serverfault en cachette sur votre smartphone quand vous êtes bloqués).

Qu’à cela ne tienne, je vais vous donner la procédure pour le faire à la main.

Dans la liste des miroirs disponibles pour les dictionnaires d’Open Office (car c’est de ça qu’il s’agit), j’ai pris un serveur au hasard et j’ai regardé le contenu du FTP. La requête est faite sur <ftp://ftp.snt.utwente.nl/pub/software/openoffice/contrib/dictionaries/>.

Pour contourner le blocage du FTP, je peux simplement changer de protocole pour du HTTP et miracle ça fonctionne :) :

* [ftp.snt.utwente.nl/pub/software/openoffice/contrib/dictionaries/ (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20190722053150/http://ftp.snt.utwente.nl/pub/software/openoffice/contrib/dictionaries/)

Dans le cas où vous n’auriez pas du tout Internet sur votre PC, il faudra le récupérer par un autre moyen (4G, pigeon voyageur...).

Dézippez le et récupérez l’archive fr_FR.zip.

![](/2018/04/fr_fr_zip01.png)

Dézippez la également, et il devrait finalement y avoir les fichiers que l’on recherche, à savoir :

  * fr_FR.aff
  * fr_FR.dic

Copiez ces deux fichiers dans **C:\Program Files (x86)\Notepad++\plugins\Config\Hunspell**, fermez Notepad++ et redémarrez le.

Retournez dans le menu **DSpellchecker** (voir plus haut), et reproduisez la procédure décrite plus haut.

**Compléments / DSpellchecker / Change Current Language / French** (ou **Multiple** si vous écrivez à la fois en Anglais et en Français).

Vous venez de triompher de l’absence d’Internet et pouvez maintenant écrire sans craindre la faute d’orthographe (ou pas ;p) !

 [3]: https://openclassrooms.com/forum/sujet/correcteur-orthographique-de-notepad
