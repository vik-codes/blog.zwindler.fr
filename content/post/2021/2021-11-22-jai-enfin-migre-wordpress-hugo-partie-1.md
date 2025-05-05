---
title: J'ai enfin migré de Wordpress vers Hugo - partie 1
authors:
  - zwindler
type: post
date: 2021-11-22T08:00:00+00:00
url: /2021/11/22/jai-enfin-migre-de-wordpress-a-hugo-partie-1/
image: /2021/11/wordpress-to-hugo.png
categories:
  - autohebergement
tags:
  - git
  - wordpress
  - hugo
  - go
  - go-template
  - markdown
  - migration

---

Cette article fait partie d'une suite d'articles :
* [J'ai enfin migré de Wordpress vers Hugo - partie 1](/2021/11/22/jai-enfin-migre-de-wordpress-a-hugo-partie-1/)
* [J'ai enfin migré de Wordpress vers Hugo - partie 2](/2021/11/29/jai-enfin-migre-de-wordpress-a-hugo-partie-2/)


## Plus de 2 ans et demi

Ca fait plus de 2 ans et demi que je râle que j'en ai ma claque de Wordpress.

Stack LEMP à maintenir, perfs bof (j'ai du mettre un cache pour passer sous la seconde, wtf...), plugins aux MAJs hasardeuses, failles de sécu, pas de support propre du markdown, éditeur à ch*** (Gutenberg, je te hais), ... you name it.

![](/2021/tweet_mieuxavant.png)

Après 12 ans de blogging, il était temps de faire l'effort et de quitter Wordpress pour quelque chose qui me convient mieux : un moteur de blog statique (rien de dynamique dans ce que je poste) en markdown (parce que de toute façon c'est comme ça que j'écris mes articles à la base). Le tout dans git pour historiser tout ça.

Et j'ai choisi Hugo pour des raisons que [je détaille dans l'article 2019 "Comment migrer de Wordpress à Hugo" si ça vous intéresse](/2019/06/10/comment-migrer-de-wordpress-a-hugo/).

## Forcément, c'est pas si facile

J'en parlais déjà dans l'article de 2019 : migrer de Wordpress à Hugo, forcément ce n'est pas si facile. D'ailleurs, j'avais même abandonné l'idée devant l'ampleur da tâche !

Ce n'est pas tant la partie technique (installation de Hugo, export du blog existant) le problème. En quelques minutes, on a un blog fonctionnel, l'export prend guère plus de temps. Rajouter l'outillage pour automatiser certaines tâches prend un peu de temps mais rien d'incroyable.

Mon problème était plutôt que je voulais obtenir au moins aussi bien que ce que j'avais avant, existant inclus. 

Et c'est là que le bat blesse : wordpress, avec mes 12 ans (350 articles) d'historique, c'est au fil des années 15 façons différentes d'afficher du HTML... que le plugin d'export gère comme il peut ! Nous y reviendrons.

Je vais donc vous guider un peu sur la partie technique, puis j'aborderai ensuite les points pénibles du nettoyage du markdown, qui m'a pris un bonne partie de mes vacances (plusieurs journées à ~2-3 heures par jour). Il y aura aussi, plus tard, des articles sur l'outillage à mettre en place pour se faciliter la vie au quotidien.

## Installation

L'installation en elle même est triviale. On a un binaire compilé en go packagé dans un **.deb** (ou les sources si vous voulez le builder vous même) disponible sur github. Fin.

```bash
sudo apt update
sudo apt upgrade

export VER="0.88.1"
wget https://github.com/gohugoio/hugo/releases/download/v${VER}/hugo_${VER}_Linux-64bit.deb
# ou https://github.com/gohugoio/hugo/releases/download/v${VER}/hugo_extended_${VER}_Linux-64bit.deb
sudo apt install ./hugo*_0.88.1_Linux-64bit.deb 
```

A noter que dans mon cas, je n'ai pas téléchargé la version ci dessus, mais la version "extended", nécessaire pour le thème que j'ai choisi, mais le principe est le même.

## Initialisation du site et du dépôt git

Hugo est maintenant disponible sur votre machine.

A partir de là, je vous invite fortement à versionner tout ce que vous allez faire avec votre blog. C'est bien entendu optionnel mais pourquoi se priver de toute la puissance du couple markdown + git ?

On commence par créer un dossier puis on génère un squelette de site vierge avec `hugo new site` :

```
mkdir hugo && cd hugo
hugo new site toto
Congratulations! Your new Hugo site is created in toto.

Just a few more steps and you're ready to go:

1. Download a theme into the same-named folder.
   Choose a theme from https://themes.gohugo.io/ or
   create your own with the "hugo new theme <THEMENAME>" command.
2. Perhaps you want to add some content. You can add single files
   with "hugo new <SECTIONNAME>/<FILENAME>.<FORMAT>".
3. Start the built-in live server via "hugo server".

Visit https://gohugo.io/ for quickstart guide and full documentation.
```

A partir de là, on va pouvoir initialiser notre dépôt git

```bash
cd toto
git init
```

Bon, si jamais vous lancez la génération du blog avec simplement la commande de preview `hugo server`, vous allez être assez déçus, ça donne une page blanche. Mais, ça marche !

```bash
hugo server
Start building sites … 
hugo v0.88.1-5BC54738+extended linux/amd64 BuildDate=2021-09-04T09:39:19Z VendorInfo=gohugoio
WARN 2021/11/14 06:57:47 found no layout file for "HTML" for kind "taxonomy": You should create a template file which matches Hugo Layouts Lookup Rules for this combination.
WARN 2021/11/14 06:57:47 found no layout file for "HTML" for kind "home": You should create a template file which matches Hugo Layouts Lookup Rules for this combination.
WARN 2021/11/14 06:57:47 found no layout file for "HTML" for kind "taxonomy": You should create a template file which matches Hugo Layouts Lookup Rules for this combination.

                   | EN  
-------------------+-----
  Pages            |  3  
  Paginator pages  |  0  
  Non-page files   |  0  
  Static files     |  0  
  Processed images |  0  
  Aliases          |  0  
  Sitemaps         |  1  
  Cleaned          |  0  

Built in 1 ms
Watching for changes in /toto/{archetypes,content,data,layouts,static}
Watching for config changes in /toto/config.toml
Environment: "development"
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

## Ajout d'un thème

Avant même de commencer à ajouter du contenu, il est probable que vous allez vouloir choisir un thème. Il existe une liste de thèmes, plus fournie qu'en 2019, [disponible ici](https://themes.gohugo.io/).

Une fois le thème choisi, on va l'ajouter au site à l'aide de la (très utile) commande git `git submodule` qui va nous permettre de gérer notre thème et ses mises à jour avec git sans pour autant commiter tous les fichiers.

Dans mon cas j'ai choisi le thème "stack" mais le principe est grosso modo le même pour tous (à quelques détails d'implémentation près) :


```bash
cd themes/
git submodule add https://github.com/CaiJimmy/hugo-theme-stack.git
cd ..
```

## Avant le premier article !

Si on veut bosser un peu proprement, on va vouloir éviter de commiter n'importe quoi. Comme hugo est un générateur de blog statique, on va bien entendu éviter de commiter le code statique généré par la commande `hugo`.

On utilise simplement un fichier **.gitignore** à la racine du projet pour ignorer tout ce qui est technique ou qui n'est pas du code :

```bash
cat > .gitignore << EOF
themes
resources/_gen
assets/jsconfig.json
public
EOF
```

On va aussi vouloir paramétrer a minima notre site. Vous aurez peut être remarqué qu'il existe un fichier `config.toml` généré par défaut par la commande `hugo new site`. Il s'agit de "l'ancienne" manière de faire de la configuration Hugo, mais surtout d'un fichier agnostique du thème utilisée. Généralement, il vaut mieux le supprimer et repartir du fichier d'exemple inclus avec votre thème.

Dans mon cas, il s'agit du fichier **theme/hugo-theme-stack/config.yaml** que j'ai donc copié à la racine du projet et modifié pour correspondre à mon site et mes besoins.

```yaml
baseurl: https://blog.zwindler.fr
languageCode: fr-fr
theme: hugo-theme-stack
title: "Zwindler's Reflection"
[...]
```

## Le premier commit

C'est un petit moment agréable dans n'importe quel projet informatique. Le premier commit. 

Bon moi, comme j'ai hébergé le dépôt sur Github et qu'ils ont décidé de renommer **master** en **main** dans le nom de la branche par défaut on a un peu de gymnastique à faire, mais pourquoi pas.

```bash
git add .
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:zwindler/example.org.git
git push -u origin main
```

Le "code" de notre (absence de) blog est publié Internet :)

## Et en prod ?

Vous pouvez donc commencer à écrire (dans **content/post**), tester votre blog en local, puis pousser le code sur git. Mais si jamais vous voulez héberger votre site ailleurs que sur votre laptop (et je parie que c'est le cas) ?

Et bien c'est là où c'est chouette d'utiliser git et un dépôt accessible depuis Internet. Vous n'avez qu'à reproduire l'installation de hugo, ajouter votre dépôt, initialiser les submodules (notre thème) et le tour est joué !

```bash
export VER="0.88.1"
wget https://github.com/gohugoio/hugo/releases/download/v${VER}/hugo_${VER}_Linux-64bit.deb
# ou https://github.com/gohugoio/hugo/releases/download/v${VER}/hugo_extended_${VER}_Linux-64bit.deb
sudo apt install ./hugo*_0.88.1_Linux-64bit.deb 

git clone https://github.com/zwindler/toto.git
git submodule init
git submodule update

hugo
```

Normalement, le site devrait se générer, comme en local. Si vous n'avez pas d'historique à migrer, comme moi, vous êtes donc l'heureux propriétaire d'un blog statique fonctionnel :-). La classe !

Sinon, dans le prochain article, j'aborderai un plus gros morceau, à savoir l'export et le nettoyage du markdown depuis un Wordpress existant.
