---
title: 'Marp : présentations rapides et jolies avec Markdown'
authors:
  - zwindler
type: post
date: 2021-09-13T06:05:00+00:00
excerpt: Mes présentations rapides à faire et jolies à voir avec Markdown et Marp
url: /2021/09/13/marp-presentations-rapides-et-jolies-avec-markdown/
image: /2021/09/marp-logo.png
categories:
  - Conférence
tags:
  - documentation
  - html5
  - markdown
  - marp
  - pdf
  - présentation
  - vscode

---
## J’ai remplacé Powerpoint par Marp en 2019

Pendant des années, j’ai rédigé mes présentations professionnelles avec Powerpoint. J’étais un utilisateur correct de la suite Office en général (pas un roxxor, mais à l’aise). 

Et là, c’est le drame, j’ai (enfin !) pu passer sous Linux sur ma machine pro. Ma vie est devenue tellement plus simple pour toutes mes tâches quotidiennes... SAUF... la rédaction de présentations.

J’ai vraiment pesté en passant à Libre Office. Je ne vais pas tacler ce dernier, beaucoup de la difficulté réside dans les formats ultras verrouillés de MS et le reverse engineering doit être horriblement complexe. J’ai donc commencé à chercher des alternatives.

## It’s time to Duel...

J’ai donc demandé à mes petits collègues et copains speakers autour de moi ce qu’ils utilisaient comme moteur pour leurs présentations.

Grosso modo, les nerds m’ont répondu qu’ils n’avaient jamais quitté [LaTeX](https://fr.wikipedia.org/wiki/LaTeX) et que pour les présentations ils utilisaient simplement [Beamer](https://fr.wikipedia.org/wiki/Beamer), et les autres m’ont répondu [Ascii doctor](https://asciidoctor.org/).

Pour la première, c’est une bonne alternative si vous n’êtes pas allergiques à la syntaxe de LaTeX (c’est mon cas). D’autant plus qu’on avait pas à l’époque d’aperçu en temps réel du code LaTeX (je ne sais pas si c’est toujours le cas) et qu’un néophyte passe beaucoup de temps à juste corriger les erreurs de syntaxe et de mise en page...

La seconde alternative est intéressante aussi. La syntaxe est plus digeste (je trouve) que LaTeX, il existe des éditeurs de texte capable de montrer un aperçu en temps réel du rendu final, et les formats d’export natifs incluent HTML 5, les manpages, les PDFs et ebooks,... bref, à peu près tout type de format récent qui peuvent intéresser un ingénieur en informatique qui partage quotidiennement sa connaissance. Sauf que la syntaxe d’AsciiDoctor est proche de celle de [Markdown](https://fr.wikipedia.org/wiki/Markdown) (au moins dans la philosophie) et pour avoir jonglé quelque temps entre les deux, il est facile de se prendre les pieds dans le tapis. 

Or, j’utilisais déjà Markdown pour la rédaction de documentations de projets hébergés sur gitlab et accessoirement, pour rédiger une partie des articles de ce blog. Pour éviter mon auto-confusion et capitaliser sur mon habitude de Markdown, j’ai donc cherché une alternative à AsciiDoctor pour les présentations, mais en Markdown !

## Entre alors Marp

Heureusement pour moi, j’ai trouvé très rapidement l’outil que je cherchais, et il s’appelle Marp. Pour être parfaitement précis, [Marp](https://marp.app/#get-started) est une collection d’outils open source (Marpit, Marp Core, Marp CLI, Marp for VSCode). 

Ce que vous avez besoin de retenir c’est qu’en tant qu’utilisateur, vous n’aurez besoin que de [Marp CLI](https://github.com/marp-team/marp-cli) si vous voulez générer vos decks de slides en ligne de commande. Un des gros intérêts de la CLI par rapport à une interface graphique est qu’elle va vous permettre d’automatiser la génération de vos decks de slide très facilement.

D’ailleurs, si ça vous intéresse, il se retrouve que Rémi Verchère a fait un article là-dessus il y a très peu de temps sur le compte Medium de [LinkByNet : Making slides from anywhere for anyone using Marp, GitLab Pages and Gitpod](https://medium.com/linkbynet/making-slides-from-anywhere-for-anyone-using-marp-gitlab-pages-and-gitpod-35001daf1c93).

Si en revanche vous préférez rédiger comme moi dans votre éditeur de texte et voir en live le support prendre forme, il existe donc aussi une extension [VSCode pour Marp](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode).

![](2021/09/marp_extension.png)

## Comment ça marche ?

Grosso modo, Marp vient étendre le Markdown classique pour y ajouter :

* La commande **_marp: true_** pour indiquer qu’il s’agit d’un document Marp et pas Markdown et une balise `---` pour indiquer les nouvelles slides
* des styles de slides et des thèmes customizables en CSS
* un logiciel pour transformer le code Markdown en PDF ou HTML

Si vous êtes déjà à l’aise avec Markdown, vous remarquez donc que la prise en main est extrêmement simple. Finalement, si vous avez déjà un document Markdown, vous pouvez juste le transformer en présentation en ajoutant régulièrement des `---` entre les paragraphes (j’exagère, mais vous voyez l’idée).

![](/2021/09/preview_marp.png)

Et ce que j’apprécie particulièrement avec la preview Markdown, c’est qu’on a un visuel en temps réel de notre future documentation/présentation à partir de notre code.

## Les styles

Out of the box, Marp propose 3 thèmes, qu’il est possible d’inverser (clair/sombre). La documentation sur ces thèmes [est disponible ici](https://github.com/marp-team/marp-core/tree/main/themes).

En début de document, on indique qu’il ne s’agit pas d’un simple fichier Markdown, mais d’une présentation Marp de la façon suivante :

```
---
marp: true
theme: gaia
markdown.marp.enableHtml: true
paginate: true
```

Dans cet exemple, j’ai donc utilisé le thème Gaia, autorisé l’injection de HTML « perso » au milieu du code Markdown (on en reparlera) et ajouté le petit chiffre en fin de chaque slide avec « paginate: true ».

Bon... par défaut, c’est assez vite limité et pas super joli...

![](/2021/09/marp_default_theme.png)

J’ai tout de suite voulu trouver d’autres thèmes (je n’en ai pas trouvé) et la documentation pour créer son propre thème est assez obscure.

Donc j’ai voulu customiser le mien, mais là aussi, la partie documentation sur la customisation/modification de thèmes existants est un peu légère, surtout si vous avez tout oublié en CSS comme moi. 

Note: La documentation peu claire, c’est quasiment le seul reproche que je fais au projet Marp, tant j’en suis content. D’ailleurs, les développeurs de Marp travaillent à refaire la doc.

Grosso modo, la partie thème est gérée dans la partie « framework Marpit » (donc la partie la plus bas niveau du projet Marp). Vous trouverez ici la partie « customisation » via CSS [Theme CSS (marp.app)](https://marpit.marp.app/theme-css?id=tweak-style-through-markdown).

## Ma personnalisation à moi

Je ne vais donc pas vous cacher mes petits secrets de speaker, je me suis donc fait un thème « par défaut » que j’utilise pour toutes mes conférences en tant que speaker et mes présentations internes (quand elles n’ont pas « besoin » du thème corporate).

En tout début de chaque deck, avant la première slide et après la partie Marp pure, j’ajoute ceci :

```
<style>

section {
  background-color: #fefefe;
  color: #333;
}

img[alt~="center"] {
  display: block;
  margin: 0 auto;
}
blockquote {
  background: #ffedcc;
  border-left: 10px solid #d1bf9d;
  margin: 1.5em 10px;
  padding: 0.5em 10px;
}
blockquote:before{
  content: unset;
}
blockquote:after{
  content: unset;
}
</style>
```


* Le premier bloc change la couleur du fond des slides.
* Le second me permet d’ajouter un paramètre « center » dans les images en Markdown pour la centrer (souvent très pratique quand on fait un peu de mise en page pour faire joli).
* Les derniers me permettent de customiser l’apparence des blocs de « quotes ».

## Ajouter des vidéos, du JS, etc

Si vous avez tout bien lu, vous vous souvenez peut-être que j’ai dit qu’on allait ajouter une option **_markdown.marp.enableHtml: true_** dans en début de fichier. 

Ça va nous permettre de rajouter des bidouilles en HTML pour étendre un peu le Markdown et réaliser les 2-3% qui ne sont pas couverts par le langage.

Je l’utilise notamment de temps en temps pour rajouter un sauf de ligne pour faciliter la lecture, mais aussi lorsque j’ai besoin d’intégrer une vidéo dans un support.

Dans ce cas-là, j’ajoute la balise HTML suivante :

```
<div id=video><video controls="controls" width="800" src="binaries/microsoft_dance.mp4"></video></div>
```

![](/2021/09/video_marp.png)

## Un exemple

Je ne vais pas continuer plus longtemps la liste des features de Marp, mais si vous voulez un exemple, j’ai mis à disposition le code Markdown ma conférence « Ciel ! Mon Kubernetes mine des Bitcoins ! »

* [Le dépôt git avec le code Markdown et les binaires](https://github.com/zwindler/cloudnord-2021-ciel-mon-kube-mine-bitcoins)
* [Le support généré en HTML5 par Marp](/talks/2022-ciel-kubernetes-mine-bitcoins/index.html)

Have fun !
