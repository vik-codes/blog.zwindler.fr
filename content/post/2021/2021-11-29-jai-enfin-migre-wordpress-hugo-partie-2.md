---
title: J'ai enfin migré de Wordpress vers Hugo - partie 2
authors:
  - zwindler
type: post
date: 2021-11-29T08:00:00+00:00
url: /2021/11/29/jai-enfin-migre-de-wordpress-a-hugo-partie-2/
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

## Extraire les données de WordPress

Normalement [si vous avez lu la première partie](/2021/11/22/jai-enfin-migre-de-wordpress-a-hugo-partie-1/), vous savez qu'on a un Hugo fonctionnel (mais vide). Et que dans mon cas, l'objectif était de migrer 12 ans d'historique (350 articles tout de même) de Wordpress vers notre Hugo.

Vous vous en doutez, le but n'est pas de reprendre les articles uns par uns (sauf si vous n'en avez qu'une dizaine, ça doit se faire) mais bien de trouver une méthode pour exporter le contenu existant en markdown pour repartir comme si de rien n'était.

[La documentation officielle de Hugo donne plusieurs pistes](https://gohugo.io/tools/migrations/#wordpress) pour migrer depuis Wordpress et c'est la première que j'avais utilisé en 2019 (la première fois que j'avais tenté de migrer, sans succès). J'ai re-installé l'extension `wordpress-to-hugo-exporter` (je vous invite quand même à regarder les alternatives car il n'est pas impossible que ça ait évolué depuis).

## wordpress-to-hugo-exporter

La première chose à faire pour installer cette extension est de vérifier que votre serveur qui héberge le WordPress dispose bien de l’extension PHP `zip.so`.

```
cat /etc/php.d/40-zip.ini
; Enable ZIP extension module
extension=zip.so
```

On peut ensuite cloner le projet git du plugin directement dans le dossier plugin de WordPress

```
cd PATH_TO_WORDPRESS/wp-content/plugins/
git clone https://github.com/SchumacherFM/wordpress-to-hugo-exporter
```

A partir de là, il est possible de démarrer un export soit depuis l'interface, soit via un script en PHP lancé depuis le serveur en ligne de commandes. Évidemment, dans ce genre de procédures, on arrive toujours à un moment où on se tape un timeout quelque part. Dans mon cas, les données exportées (articles + medias, environ ~1.5 Go) prenaient 500 Mo de RAM et 20 minutes d'exécution.

On oublie donc le clic dans l'interface (sauf à tuner votre nginx pour autoriser des requêtes clients avec un timeout > 60s) et on lance depuis la ligne de commande. Et bien entendu, on augmente toutes les limites possibles et imaginables, notamment celle de wordpress via le fichier wp-config.php.

```PHP
// Set initial default constants including WP_MEMORY_LIMIT, WP_MAX_MEMORY_LIMIT, WP_DEBUG, SCRIPT_DEBUG, WP_CONTENT_DIR and WP_CACHE.
wp_initial_constants();
define( 'WP_MEMORY_LIMIT', '2048M' );
define( 'WP_MAX_MEMORY_LIMIT', '2048M' );
```

```bash
cd PATH_TO_WORDPRESS/wp-content/plugins/wordpress-to-hugo-exporter/
php hugo-export-cli.php memory_limit=-1
```

Qui devrait se terminer, si tout se passe bien, par un :

```bash
This is your file!
/tmp/wp-hugo.zip
```

*Note: on peut également exporter les commentaires, il faut modifier manuellement une ligne dans le fichier `hugo-export.php` (voir la doc)*

A partir de là, on a une archive qui contient vos posts, vos pages et vos médias importés (grosso modo tout wp-content).

L'archive a l'arborescence suivante :
* un dossier **posts** qui contient tous les articles (*posts* dans la terminologie wordpress) dans un mélange de markdown + html brut (ce qui n'aura pas été correctement converti, on y reviendra)
* un dossier **wp-content** qui contient tous les médias
* des dossiers pour chacune de vos "*pages* ("à propos", "mentions légales", etc).

## Importer dans Hugo

L'arborescence de Hugo est elle un peu différente. De base, tout ce qui est markdown doit être dans **content**, avec des sous dossiers en fonction du type de page (*post* ou *page*).

La première petite "blaguounette" est que les *posts* doivent être déposés dans le sous-dossier **content/post** (sans S à la fin !!!).

Chaque post commence par des métadonnées encadrées par des triples tirets "---" avant et après. Ca donne quelque chose comme ça :

```yaml
---
title: 'ESXi 4.0 : Explorons l&rsquo;Hidden Console Part 1'
authors:
  - zwindler
type: post
date: 2010-04-28T08:32:20+00:00
url: /2010/04/28/esxi-4-0-explorons-lhidden-console-part-1/
featured_image: https://blog.example.org/wp-content/uploads/2014/10/vmware-220x162.jpg
categories:
  - Virtualisation
tags:
  - ESX(i)
  - Hidden Console
  - SSH
---

[L'article lui même...]
```

Ca peut différer un peu selon les thèmes je pense, mais grosso modo les markdown des *pages* iront eux dans **content/page**.

Enfin, tout ce qui est media (dossier wp-media) va dans un dossier **static**. On peut garder la même arborescence que wordpress (/année/mois/) mais rien ne nous y oblige.

> So far, so good

## Emile et Images

Enfin... *so good*, c'est vite dit...

Et oui parce que l'exporter n'exporte pas hyper bien un certain nombre de choses, à commencer par l'image de garde de chaque article :

```yaml
featured_image: https://blog.example.org/wp-content/uploads/2014/10/vmware-220x162.jpg
```

On peut remarquer plusieurs soucis avec cette variable. D'abord, la variable utilisée pour indiquer le chemin de l'image dans les métadonnées générées est `featured_image` alors qu'Hugo attend `image`. Petit `sed` sur vos md pour corriger ça :

```bash
sed -i "s/featured_image/image/g" fichier.md
```

Mais bien sûr, ce n'est pas fini ;-)

Ensuite, on remarque qu'on a un chemin est une URL complète et non pas relative. Si vous gardez les média dans le chemin **static/wp-content/uploads/YYYY/MM** ça marchera, mais je trouve ça moche.

2 solutions :

* on supprime **/wp-content/uploads** avec un bête `sed -i "s!/wp-content/uploads!!g fichier.md`
* on passe en relatif en supprimant carrément toute la première partie de l'URL **https://yourblog.example.org/wp-content/uploads**

Si vous choisissez la 2ème solution (mon choix), faites quand même bien attention. En fonction de *comment* vous rédigez votre expression régulière, ça pourrait affecter aussi toutes les autres images que vous auriez en lien dans vos articles. Ce n'est pas forcément une mauvaise chose (moi j'aime mieux les liens relatifs car c'est plus flexible) mais ça demande un travail supplémentaire.

## Images intermédiaires

Toujours dans les images, vous remarquerez aussi que l'image "mise en avant" (dans les métadonnées) possède un suffixe de type `-111x222` juste avant l'extension. En fait, chaque fois que vous importez une image dans wordpress, celui ci la convertie en plusieurs tailles pour accélérer le chargement des pages.

Sauf que le **wordpress-to-hugo-exporter** choisi une des plus petites résolution pour l'image en tête de l'article. Ca sera souvent hyper moche...

Là encore, j'ai donc passé un gros `sed` pour virer tous les suffixes `-111x222` avant l'extension, puis je n'ai copié QUE les images originales dans le dossier **static** (regex non triviale) :

```bash
cd PATH_TO_EXPORT/wp-content/uploads
for i in `seq 2010 1 2021`; do
  find $i -mindepth 1 -type f -regextype posix-egrep -not -iregex ".*/.*-[0-9]{1,4}x[0-9]{1,4}.*\..*" -exec cp {} PATH_TO_HUGO/static/{} \;; 
done
```

## Nettoyer les caractères spéciaux HTML

Si vous avez bien lu l'exemple de métadonnées exportées que j'ai donné, vous aurez peut être remarqué la présence d'un caractère spécial encodé `&rsquo;` dans le titre.

Dans une page HTML, ce n'est pas grave, mais Hugo lui, ne les interprète pas comme tel dans le markdown. Il faut donc leur faire la chasse et tous les convertir 🤦. Et encore, il faut faire attention, car certains de ces caractères pourraient être légitimement écris en HTML (si vous faite un tuto sur HTML, ce n'est pas impossible par exemple)...

J'ai pour ma part lancé un gros `sed` (une fois de plus) sur tous mes articles mais prudence !

```bash
sed -i "s/&rsquo;/’/g" $1
sed -i "s/&#8211;/--/g" $1
sed -i "s/&#8230;/.../g" $1
sed -i "s/&gt;/>/g" $1
sed -i "s/&lt;/</g" $1
sed -i "s/&#8212;/-/g" $1
sed -i "s/&#8217;/'/g" $1
sed -i "s/&#215;/×/g" $1
```

Je n'ai pas osé modifier les caractères suivants, très souvent présents dans les URLs :

```
&#038
&#039
&quot;
```

Mais c'est quand même une bonne idée de faire une grosse recherche avec votre éditeur de texte favori pour voir s'il ne reste pas des `&#` qui traînent dans votre contenu.

## HTML désactivé

Au delà des caractères spéciaux, il arrive aussi que l'exporter est un peu de mal avec les différents types d'éditeurs que Wordpress a pu avoir au fil du temps.

Typiquement, beaucoup du contenu "non texte" que j'ai ajouté au fil des années s'est retrouvé non converti par  ce que j'ai rédigé s'est retrouvé exporté tel quel, en HTML brut inséré dans mon markdown.

C'est hyper traître car Hugo ne renvoie aucune erreur. Il manque "juste" des bouts ! On peut les retrouver en allant voir le code source de la page, qui affiche alors les commentaires HTML suivants :

```HTML
<!-- raw HTML omitted -->
```

En attendant de nettoyer tout ça à grand coup de `sed`, on peut résoudre une partie des problèmes en "réactivant le support du code HTML dans le markdown dans votre `config.yaml`.

```yaml
markup:
    goldmark:
        renderer:
            ## Set to true if you have HTML content inside Markdown
            unsafe: true
```

Ca permet de sauver les meubles mais ce n'est pas suffisant...

## Markdown hates HTML

Même comme ça, on grosse partie du HTML sera HS... Tous les tableaux (table/tr/td) et listes (ul/li) HTML sont pétés car l'exporter laisse des sauts de lignes entre les blocs, que le markdown interprète mal. Il faudra supprimer tous les sauts de lignes en trop (ou réécrire en markdown)

```
<table class="Content" border="0" width="750">
  <tr>
    <td class="LargeBold">
      SEND_CUSTOM_SVC_NOTIFICATION
    </td>
  </tr>

  <tr>
    <td class="MediumBold">
      Command Format:
    </td>
  </tr>
```

Sachez également que toutes les "videos embedded" Youtube disparaîtront purement et simplement, et que pour les tweets, vous aurez une version très moche du tweet, sans l'image...

```HTML
<blockquote class="twitter-tweet" data-width="550" data-lang="en" data-dnt="true" data-partner="jetpack">
  <p lang="fr" dir="ltr">
    [[#SAPHANA](ht tps://tw itter.com/hashtag/SAPHANA?src=hash&ref_src=twsrc%5Etfw)] Finies les mises à jour incompatibles avec votre plateforme, optez pour la simplicité et la tranquillité, chez SAP : on collecte, on connecte, ça marche : [t.co/2AdCCEQ97L](https://t.c o/2AdCCEQ97L) [pic.twi tter.com/yy7moMnZmC](ht tps://t.c o/yy7moMnZmC)
- SAP France (@SAPFrance) 

  [October 8, 2018](ht tps://twiter.com/SAPFrance/status/1049286253533962241?ref_src=twsrc%5Etfw)
</blockquote>
```

J'en avais peu heureusement, j'ai donc pris des captures d'écran et ajouté des liens.

## Balises de code, pre, etc.

Une autre grosse catégorie de code "mal exporté" est le "code". Je donne souvent des bouts de scripts ou de code ou tout simplement des commandes à passer sur des serveurs. Et au fil des années, j'ai (& wordpress) changé plusieurs fois la façon d'afficher du code dans mes articles. 

D'abord avec des balises HTML `<pre></pre>`, puis des balises `<code></code>`, puis via des extensions (pour avoir la coloration syntaxique), puis via du markdown via Jetpack, puis de nouveau via les extensions...

Autant dire que le HTML généré par Wordpress ne ressemble à rien...

Il a fallut faire un gros gros boulot pour détecter toutes les balises de code ouvrantes et fermantes pour les convertir en \`\`\` de markdown...

Quelques exemples que j'ai rencontré :

```HTML
<pre>

<pre class="brush: plain; title: ; notranslate" title="">
<pre class="brush: perl; collapse: false; title: ; wrap-lines: false; notranslate" title="">

<pre class="EnlighterJSRAW" data-enlighter-language="null">
<pre class="EnlighterJSRAW" data-enlighter-language="generic">
<pre class="EnlighterJSRAW" data-enlighter-language="generic" data-enlighter-theme="" >
... et bien d'autres encore
```

## Final words

Je m'arrête là car l'article est déjà très long, mais il y a eu d'autres petits problèmes du même style, plus sporadiques... 

Vous voyez donc qu'exporter le blog sur Hugo n'aura pas été de tout repos, dans mon cas. Et encore ! Je n'ai pas exporté les commentaires historiques (plus de 1600) !

Cependant, si vous avez un blog plus petit que celui ci, vous devriez avoir moins de mal et les conseils que je donne ici devraient vous permettre de régler rapidement 90% des problèmes.

Enjoy !
