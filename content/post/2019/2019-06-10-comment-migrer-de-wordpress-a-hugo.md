---
title: Comment migrer de WordPress à Hugo
authors:
  - zwindler
type: post
date: 2019-06-10T11:35:20+00:00
url: /2019/06/10/comment-migrer-de-wordpress-a-hugo/
image: /2019/06/wordpress_vers_hugo.png
classic-editor-remember:
  - block-editor
categories:
  - Autohébergement
tags:
  - git
  - wordpress

---

## Mais c’est qui ce Hugo ?

Dans la rétrospective des [9 ans / 250ème articles sur le blog](/2019/02/27/250eme-article-un-peu-plus-dun-an-de-10000-a-20000/), je vous ai parlé de mes futurs projets.

Une bonne partie des projets concernent le blog lui-même, en particulier abandonner WordPress et passer à un blog statique.
  
Car les reproches que je fais à WordPress sont nombreux :

* Une techno d’un autre âge, d’une lenteur infernale dès qu’on commence à avoir un peu de contenu
* Besoin de nombreux plugins pour avoir un rendu correct pour un blog tech, pour le partage, les stats, l’antispam, les protections/firewall, des jolies balises pour les bouts de code, ...
* Des sauvegardes BDD + plugins + média à paramétrer (et complexes à tester)
* Des caches à mettre partout pour éviter que la moindre page avec quelques images mette 5 secondes à charger...
* Gutenberg, le nouvel éditeur qui par défaut vous fait écrire sur 550 px de large (1/5ème de mon écran, à peine plus large qu’une carte de visite)    

![](/2021/tweet_mieuxavant.png)

## Bref, j’en ai marre

Alors je le suis dis : pourquoi j’ai un bousin infâme qui fait le café (franchement ça fait tout et n’importe quoi WordPress, du e-commerce au CV interactif) alors que moi, j’ai juste besoin d’un bidule où je peux écrire mes bêtises, que ça soit lisible sans avoir besoin de mettre un cache en frontal et _éventuellement_ qu’on puisse me laisser un commentaire pour me remonter une coquille (ou juste discuter) ?

En gros, un site web statique avec un bon éditeur de texte quoi...
  
## Les sites statiques, c’est fantastique
  
Alors c’est sûr, on peut aussi écrire le HTML/CSS soit même. Mais bon, avoir une application pour nous mâcher le travail et n’avoir que le contenu à gérer, c’est quand même plus sympa.

Quand j’ai commencé à m’y intéresser, un nom revenait souvent : Jekyll (et Ghost encore avant). Mais je n’ai jamais sauté le pas. Mais depuis, un petit nouveau fait parler de lui. Et comme d’autres, j’ai voulu tester Hugo pour remplacer WordPress. Hugo est un moteur de blog statique écrit en Go. Il a plutôt le vent en poupe et est assez simple à prendre en main.

![](/2019/06/hugo-logo.png)

C’est open source donc je peux l’auto-héberger de façon pérenne (coucou les gens qui postent une vie de travail sur Medium). Mais bien plus encore que ca, le contenu, c’est juste du Markdown. On a donc un site entièrement réversible au cas où Hugo viendrait à disparaître.

La syntaxe utilisée (Markdown, je viens de le dire) est archi connue et relativement simple à prendre en main. D’ailleurs, on peut très bien utiliser des blocs Markdown avec Jetpack dans WordPress pour écrire ses articles.

## Tu te moques pas un peu de nous ?

Depuis le début, je vous dis que WordPress c’est tout moisi et que Hugo ça a l’air trop cool. Mais ce site... est encore sous WordPress !

Pour être honnête, c’était plus difficile à migrer que je le pensais, d’où cet article. ~~A date, j’ai une copie du blog en ligne sous Hugo (EDIT : Down maintenant), qui fonctionne, mais pas totalement isopérimètre en terme de fonctionnalités. Je vais donc laisser vivre en parallèle les deux versions, le temps que je fixe tout ce qui manque.~~
  
Mais en attendant, je vous propose de me suivre pour cette merveilleuse aventure : Migrer de WordPress vers Hugo.
  
## Installation

A en croire le site, c’est hyper simple !
  
C’est comme toutes les docs d’installs en page principale d’un site pour un logiciel open source, c’est simple mais en fait ça marche jamais (du premier coup). Fou cette coïncidence ! ;-P

* [gohugo.io/getting-started/installing/](https://gohugo.io/getting-started/installing/)

### Prérequis

Les prérequis sont en effet plutôt simples. Sous Debian/Ubuntu :

```
apt-get update
apt-get upgrade
apt-get install git python-pip

pip install Pygments
```

On va ensuite chercher le numéro de la dernière release sur le site [github.com/gohugoio/hugo/releases](https://github.com/gohugoio/hugo/releases) puis on la wget + dpkg -i comme des cochons :

```
export VER="0.54"
wget https://github.com/gohugoio/hugo/releases/download/v${VER}.0/hugo_${VER}.0_Linux-64bit.deb
dpkg -i ./hugo_0.54.0_Linux-64bit.deb
```

## Initialiser le site

Ok, pour l’instant, ils ne nous ont pas trop menti. Ça a l’air simple. On peut initialiser un nouveau site simplement avec la commande hugo new site. Puis ensuite, on peut versionner / sauvegarder blog et tout son contenu avec un dépôt git :

```
mkdir hugo && cd hugo
hugo new site blog.zwindler.fr
git init
```

## Trouver un thème

Un des soucis que j’ai avec Hugo (mais avec WordPress aussi alors je suis peut-être juste quelqu’un de pénible ?), c’est de trouver un thème.

Je veux un thème de blog (mais qu’est ce que vous avez tous à faire du e-commerce avec des moteurs de blog!!!), avec une colonne centrale assez large pour que les bouts de codes/lignes de commandes soient lisibles, avec la possibilité de mettre une image en avant sur la page d’accueil.
  
[themes.gohugo.io/](https://themes.gohugo.io/)

Personnellement, le thème qui se rapproche le plus de ce que j’ai aujourd’hui, c’est le thème aether, auquel j’ai apporté quelques modifications. Pour ajouter un thème, le plus propre est d’utiliser la encore git, via la fonctionnalité des submodules.

Je vous donne mes modifs personnelles sur ce thème (colonne centrale plus large, modification de la taille des images sur la page d’accueil) mais cette étape n’est absolument pas nécessaire.

```
diff ./themes/aether/assets/css/style.css.ori ./themes/aether/assets/css/style.css
25c25
< max-width: 50rem;
---
> max-width: 60rem;
165c165
< max-width: 49rem;
---
> max-width: 59rem;
419,420c419,421
< height: 100%;
< width: 15em;
---
> height: 83%;
> padding: 1.5em 0em;
> width: 20em;
```

## Configurer le site
  
Maintenant qu’on a initialisé le site et choisi un thème, on peut commencer à configurer le site et le thème. En effet, de nombreux paramètres dépendent du thème que vous aurez choisi et des fonctionnalités qu’il intègre. Je ne peux donc que vous donner un exemple :

Dans le fichier _config.toml_ à la racine du site, voici ce qui a été paramétré

```
baseURL = "https://blog.example.org/"
languageCode = "fr-fr"
title = "Zwindler's Reflection"
theme = "aether"
disqusShortname = "zwindler"
[params]
brand = "Zwindler's Reflection"
description = "Ma vie parmi les lol-cats || Je mine des bitcoins dans mon garage"
homeimg = "./wp-content/uploads/2019/05/servers.jpg"
```

De plus, pour ajouter la coloration syntaxique sur les partions de code, il faut ajouter dans la conf les deux paramètres suivants :

```
pygmentsCodefences = true
pygmentsStyle = "pygments"
```

Puis lancer la commande suivante :

```
hugo gen chromastyles --style=monokai > themes/aether/assets/css/syntax.css
```

## Extraire les données de WordPress
  
OK ! Notre site est paramétré. Si vous êtes sur cet article simplement pour découvrir Hugo, vous avez déjà un blog fonctionnel. Il ne reste plus qu’à écrire du contenu et générer le code statique.

cependant, dans mon cas, j’ai parlé depuis le début de migrer depuis WordPress. Je pars donc du principe que, comme moi, vous avez de nombreux articles (et éventuellement commentaires) que vous souhaitez conserver. Il serait dommage de devoir repartir de 0.

Heureusement, il est possible de récupérer les données existantes d’un WordPress pour les réimporter dans Hugo. Le [site officiel liste les options possibles](https://gohugo.io/tools/migrations/) et notamment un plugin qui converti les articles (et éventuellement les commentaires sous les articles) en Markdown.

Tout simplement (enfin... n’exagérons rien).

## wordpress-to-hugo-exporter
  
Je suis donc parti sur le projet [wordpress-to-hugo-exporter](https://github.com/SchumacherFM/wordpress-to-hugo-exporter), qui est une extension native à WordPress permettant de réaliser cet export "en un clic".

La première chose à faire pour installer cette extension est de vérifier que votre serveur qui héberge le WordPress dispose bien de l’extension PHP zip.so.
  
Si c’est bien le cas, on peut cloner le projet git directement dans le dossier plugin de WordPress

```
cat /etc/php.d/40-zip.ini
; Enable ZIP extension module
extension=zip.so

cd /var/www/html/wp-content/plugins/
git clone https://github.com/SchumacherFM/wordpress-to-hugo-exporter
```

## Il nous faut plus de ~~ziggourats~~ RAM
  
Ça arrive tout le temps... Il n’est pas rare que les processus de ce genre (export/import/package de sauvegarde) nécessitent une grande quantité de RAM. [J’avais déjà eu le souci avec Xwiki](/2016/04/30/resoudre-erreurs-de-fichiers-gros-lors-imports-xwiki/), je savais à quoi m’attendre ici.

Si vous aussi vous avez comme moi pas mal de contenu (250 articles, 500 Mo de media), sachez que vous devrez probablement augmenter les tailles mémoires autorisées par WordPress dans le fichier wp-config.php.

```
// Set initial default constants including WP_MEMORY_LIMIT, WP_MAX_MEMORY_LIMIT, WP_DEBUG, SCRIPT_DEBUG, WP_CONTENT_DIR and WP_CACHE.
wp_initial_constants();
define( 'WP_MEMORY_LIMIT', '2048M' );
define( 'WP_MAX_MEMORY_LIMIT', '2048M' );
```

De même, le temps que le processus d’export arrive à son terme, votre page web sera peut être partie en timeout. Deux possibilités dans ce cas.

Soit vous exécutez l’export depuis la ligne de commande

```
cd wp-content/plugins/wordpress-to-hugo-exporter/

This is your file!
/tmp/wp-hugo.zip

php hugo-export-cli.php
#ou pour s'affranchir des limites RAM en même temps
php hugo-export-cli.php memory_limit=-1
```

Dans tous les cas, vous devriez finir par obtenir un ZIP, contenant tous vos articles et toutes vos pages, au format Markdown. Le contenu de ce ZIP est à déposer dans le sous dossier content de votre arborescence de blog Hugo :

```
unzip wp-hugo.zip
cd hugo-export
cp -r posts wp-content ~/hugo/blog.zwindler.fr/content/
```

## Nettoyage du markdown
  
> Ca y est ? On peut générer le site statique maintenant ?

Et bien non... pas encore. En fait, le processus d’export de WordPress vers Markdown n’est pas parfait.
  
J’ai du "nettoyer" le code Markdown pour que le résultat soit enfin acceptable.

La première chose, difficilement compréhensible, est que s’il y a bien les données correspondant à l’image "mise en avant" pour chacun de nos article, le nom de la variable est image alors qu’Hugo attend le nom image.

On peut régler ça avec un bête "sed"

```
find . -name "*.md" -exec sed -i "s/featuredImage/image/g" {} \;
```

Par défaut, toutes les images de wordpress sont réduites dans plusieurs tailles, pour optimiser les temps de chargement. Cependant, dans l’export, on se retrouver avec des vignettes très petites, difficilement lisibles.
  
Pour me simplifier la vie, j’ai utilisé cette commande pour remettre les images en taille complète. Attention cependant, cela peut avoir un impact important sur les temps de chargement des pages si vous avez de très grandes images...

```
find . -name "*.md" -exec sed -i 's/-220x162//g' {} \;
```

Un des problèmes que j’ai avec l’éditeur de WordPress, c’est justement qu’il réencode tous les caractères spéciaux avec leurs codes HTML. D’un point de vue lecture de texte simple, ça ne pose souvent pas de problème. Cependant pour tout ce qui est scripts et bouts de code, ça génère très souvent des erreurs.
  
Voici une liste des caractères que j’ai remplacés dans mon Markdown. Attention cependant, il pourrait que cela remplace des caractères spéciaux que vous auriez légitimement (pour une raison qui m’échappe) encodé en HTML


```
find . -name "*.md" -exec sed -i "s/>/>/g" {} \;
find . -name "*.md" -exec sed -i "s/</</g" {} \;
find . -name "*.md" -exec sed -i "s/&/&/g" {} \;
find . -name "*.md" -exec sed -ie "s/ /\n/g" {} \;
find . -name "*.md" -exec sed -i "s/–/–/g" {} \;
find . -name "*.md" -exec sed -i "s/—/—/g" {} \;
find . -name "*.md" -exec sed -i "s/…/…/g" {} \;
find . -name "*.md" -exec sed -i "s/″/″/g" {} \;
find . -name "*.md" -exec sed -i "s/′/″/g" {} \;
find . -name "*.md" -exec sed -i "s/«/«/g" {} \;
find . -name "*.md" -exec sed -i "s/»/»/g" {} \;
find . -name "*.md" -exec sed -i "s/’/’/g" {} \;
find . -name "*.md" -exec sed -i "s/‘/‘/g" {} \;
```


J’ai aussi trouvé les caractères suivants, que je n’ai pas osé réencoder de peur de casser des URLs :
  
* &#038
* &#039
* &quot;
* '
  
Et pour finir, dans WordPress, j’utilisais dans WordPress un plugin qui entourait mes bouts de code de balises HTML _pre_ pour afficher du code avec la coloration syntaxique.

Dans Hugo, les balises sont celle de markdown. Voici donc la commande pour convertir les balises pre en balise de code Markdown

```
find . -name "*.md" -exec sed -ie "s/<pre.*>/\n\`\`\`\n/g" {} \;
find . -name "*.md" -exec sed -ie "s/<\/pre>/\n\`\`\`\n/g" {} \;
```

## Tester le blog
  
Voila !!! Vous pouvez enfin tester votre blog, avec votre contenu Markdown. Hugo propose un serveur web que vous pouvez utiliser localement pour vous assurer que tout vas bien avant d’uploader votre site statique.
  
Il n’est évidement pas question d’utiliser ce mode en production. Il s’agit seulement d’un mode "preview".

```
$ hugo server
Start building sites … 
hugo v0.88.1-5BC54738+extended linux/amd64 BuildDate=2021-09-04T09:39:19Z VendorInfo=gohugoio

                   |  FR   
-------------------+-------
  Pages            | 3234  
  Paginator pages  |  354  
  Non-page files   |    0  
  Static files     |    0  
  Processed images |    1  
  Aliases          | 1439  
  Sitemaps         |    1  
  Cleaned          |    0  


Built in 4895 ms
Watching for changes in /home/zwindler/sources/hugo/blog.zwindler.fr/{assets,content,data,layouts,static,themes}
Watching for config changes in /home/zwindler/sources/hugo/blog.zwindler.fr/config.yaml, /home/zwindler/sources/hugo/blog.zwindler.fr/themes/hugo-theme-stack/config.yaml
Environment: "development"
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop

```

## Sauvegarder/générer/déployer le site

Si après vérification, votre blog vous convient, vous n’avez alors plus qu’à "sauvegarder" votre site via git.
  
Vous pouvez ensuite générer le site statique en invoquant simplement la commande hugo


```
$ hugo

                   |  EN    
+------------------+-------+
  Pages            |  2634  
  Paginator pages  |   231  
  Non-page files   | 10951  
  Static files     |    73  
  Processed images |     0  
  Aliases          |  1187  
  Sitemaps         |     1  
  Cleaned          |     0  

Total in 5555 ms
```

Les pages statiques seront générées et sauvegardées dans le sous dossier public. Vous pourrez enfin simplement copier ce dossier sur n’importe quel serveur web (voire même des blobs sur un cloud provider) et vous aurez votre site statique !!!

Enjoy !
