---
title: Migration facile de Mediawiki vers XWiki
authors:
  - zwindler
type: post
date: 2016-12-16T08:30:00+00:00
url: /2016/12/16/migration-mediawiki-vers-xwiki/
image: /2020/02/mediawiki_to_xwiki_logo.png
categories:
  - Logiciel
tags:
  - conversion
  - export
  - extension
  - import
  - mediawiki
  - XML
  - xsd
  - Xwiki

---
## Convertir simplement des pages d’un Mediawiki vers une instance XWiki

Une fois de plus, encore un article sur XWiki ! J’ai déjà pas mal profité de cet outil de gestion de la connaissance [pour m’initier à Docker](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/) et même [gérer le cycle de vie de l’application avec des containers](/2016/11/30/mise-a-jour-xwiki-8-4-1-docker-tomcat-postgresql/). Mais il reste au moins un sujet pourtant récurrent que je n’avais pas encore traité. Comment réaliser simplement la migration des pages qui me restaient (150 !) de mon Mediawiki vers le XWiki pour que je puisse définitivement le désactiver ?

## Les méthodes trouvées sur Internet

Et le moins que l’on puisse dire, c’est que cet épineux problème comporte de nombreuses solutions. Rien que sur le [site des extensions][3] XWiki :

  * un [script groovy pour convertir la syntaxe Mediawiki en syntaxe XWiki][4], mais peu documenté et datant de 2007 et dont la version date de 2013
  * le [Migration Toolkit][5] qui détaille comment réaliser la migration. A priori bien documenté mais la migration a vraiment l’air complexe

![](https://extensions.xwiki.org/xwiki/bin/download/Extension/Mediawiki+To+XWiki+Migration+Toolkit/howitworksparser.png)

En écumant la dev-list je suis également tombé sur des sites externes ou des méthodes alternatives mais rien qui ne m’ait donné envie de sauter le pas. Je vais néanmoins citer cet article qui détaille [une méthode qui marche a priori (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20100606003605/http://encodo.com/en/blogs.php?entry_id=73), mais ce n’est pas encore simplissime.

Une autre méthode également mise en avant par Vincent Massol de XWiki est aussi de faire appel à [leurs services pour assurer la migration][7]. Dans le cas d’un wiki d’entreprise très complexe et avec un fort enjeux business, cela mérite probablement considération.

## Et la solution ?

Courant de l’été, j’avais un peu mis le problème de côté. Puis j’ai lu dans la dev-list qu’une nouvelle méthode avait été mise au point, à tester. J’ai mis un peu de temps à me décider, mais j’ai fais le test.

Cette nouvelle extension dispose d’une page sur le magasin des extensions XWiki, disponible à l’adresse suivante :

* [extensions.xwiki.org/xwiki/bin/view/Extension/MediaWiki/MediaWiki+XML](https://extensions.xwiki.org/xwiki/bin/view/Extension/MediaWiki/MediaWiki+XML)

Il y a deux composants en jeux en réalité. Le convertisseur en lui même [Filter Streams Converter Application](https://extensions.xwiki.org/xwiki/bin/view/Extension/Filter+Application) qui est le composant générique qui fait le travail et [MediaWiki XML][8] le composant spécifique à la syntaxe Mediawiki pour ce module.

Tout ceci peut s’installer en téléchargeant les packages sur le site ou directement (et c’est même plutôt conseillé) depuis le magasin d’extension **dans** l’administration de votre XWiki :

![](/2016/12/xwiki_to_mediawiki15.png)

![](/2016/12/xwiki_to_mediawiki14.png)

![](/2016/12/xwiki_to_mediawiki11.png)

A noter, l’extension **Filter Streams Converter Application** semble être intégrée par défaut au cœur de XWiki. Et comme c’est un dépendance de l’extension **MediaWiki XML**, je n’ai initialement pas pu l’installer car l’application **Filter Streams Converter Application** était en version 8.4.1 alors que la 8.4.2 était nécessaire !

J’ai donc du mettre à jour le XWiki de 8.4.1 vers 8.4.2 avant de pouvoir installer **MediaWiki XML**.

Note : Dans le cas où vous ne pourriez pas mettre à jour votre XWiki, vous pouvez toujours installer temporairement un XWiki à jour à la dernière version ([avec Docker par exemple?](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/)), réaliser la conversion, faire un export XAR que vous pourrez réimporter dans votre XWiki de production.

## Export

Maintenant que nous avons récupéré les extensions, nous allons pouvoir procéder à l’export du Mediawiki. [Cette partie est très bien outillée et documentée côté Mediawiki](https://www.mediawiki.org/wiki/Help:Export#Export_format). Il existe de nombreuses extensions permettant d’extraire la totalité du mediawiki mais vous pouvez également vous contenter des fonctionnalités par défaut avec un peu d’astuce. L’important est d’avoir à la fin un export XML contenant toutes vos pages au format Mediawiki.

Pour ma part j’ai utilisé la méthode « manuelle ». Dans Mediawiki il existe des pages spéciales, que vous connaissez certainement. J’en ai utilisé 2 :

* La première est la page « Toutes\_les\_pages » que l’on peut accéder avec une URL du type `http://@IP_mon_wiki/mediawiki/index.php?title=Sp%C3%A9cial:Toutes_les_pages` et qui comme son nom l’indique nous liste toutes les pages du wiki. Un simple copier coller avec un peu de remise en forme nous donner une liste de toutes les pages.

![](/2016/12/xwiki_to_mediawiki3.png)

* La seconde est tout simplement là aussi la page spéciale d’export de pages, que l’on accède via un lien du type `https://@IP_mon_wiki/mediawiki/index.php?title=Sp%C3%A9cial:Exporter`. Après un petit copier/coller de la liste de pages qu’on vient de récupérer, un obtient un fichier XML avec toutes nos pages.

![](/2016/12/xwiki_to_mediawiki4.png)

Si vous êtes curieux, voilà à quoi ressemble en vrai une de vos pages mediawiki (en ouvrant le XML) :

![](/2016/12/xwiki_to_mediawiki5.png)

## Import

### Paramétrage

Si l’installation des modules s’est bien passée, vous devriez avoir une nouvelle application installée dans la liste des applications en haut à gauche de votre xwiki :

![](/2016/12/xwiki_to_mediawiki6.png)

**Attention :** Un avertissement nous rappelle que l’application **Filter Streams** est encore jeune et qu’il y a des risques à l’utiliser.

Comme vous pouvez le voir, cette application à de nombreuses options. La première option à renseigner est le type de de l’entrée. Ici nous avons un fichier XML Mediawiki, il faut donc renseigner _MediaWiki XML input stream (mediawiki+xml)_. Si vous ne voyez pas cette ligne, c’est que vous n’avez pas correctement installé l’extension **MediaWiki XML**.

![](/2016/12/xwiki_to_mediawiki7.png)

On doit ensuite descendre un peu et renseigner la source (ici notre export XML). Vous pouvez soit le déposer sur le serveur et utilise « file:<chemin>.xml » pour accéder au fichier, mais j’ai trouvé plus simple d’y accéder à l’aide d’un serveur HTTP et d’une URL.

![](/2016/12/xwiki_to_mediawiki8.png)

Pour la partie Output, si vous n’avez peur de rien, vous pouvez copier les pages XWiki converties directement dans votre XWiki avec _XWiki instance output stream (xwiki+instance)_. C’est l’option que j’ai utilisé mais rien ne vous empêche d’être prudent et de générer un XAR en sélectionnant l’option _XAR ouput stream_.

![](/2016/12/xwiki_to_mediawiki9.png)

Par défaut, toutes les pages de mon Mediawiki étaient au même niveau hiérarchique (contrairement à mon XWiki où les pages sont organisées selon une arborescence). Ces pages sont copiées directement à la racine du XWiki. J’ai donc préféré les placer en dessous d’une page que j’ai appelé _Import_.

Attention : cette option est située plus haut car l’ajout d’un parent est réalisé lors de l’import. On retrouve l’option juste au dessus de là où on configure la source.

![](/2016/12/xwiki_to_mediawiki10.png)

Vous pouvez aussi les copier dans un sous-wiki si vous le souhaitez.

### Avant de cliquer

2 options par défaut sur lesquelles je vous invite à réfléchir :

* Par défaut _Delete existing document_ est à _true_ => les documents existants sont écrasés !  
  Personnellement je l’ai passé à _false_ !
* Par défaut _Stop when document save fail_ est à _true_ => s’il y a une erreur dans le XML, l’import s’arrêtera.  
Je l’ai laissé tel quel par sécurité, mais j’ai du recommencer le processus d’export en excluant les pages concernées et en recommençant le processus. C’est assez fastidieux surtout si vous avez beaucoup d’erreurs. Dans ce cas, on pourra tenter de passer le Booléen à false, pour voir.

### Conversion !!!

Maintenant que tout est prêt, on peut valider en cliquant sur _Convert_ ! Vous pouvez voir en temps réel la conversion et l’import en haut de la page.

Personnellement, sur 150 pages importées, je n’ai eu que 4 pages qui n’ont pas pu être importées et qui ont causés une exception Java :

```console
Exception thrown during job execution
class org.xwiki.filter.FilterException: Failed to parse XML
at org.xwiki.filter.mediawiki.xml.internal.input.MediaWikiInputFilterStream.read(MediaWikiInputFilterStream.java:255)
at org.xwiki.filter.mediawiki.xml.internal.input.MediaWikiInputFilterStream.read(MediaWikiInputFilterStream.java:81)
[...]
at java.lang.Thread.run(Thread.java:745)
Caused by: class java.lang.NullPointerException: null
at org.xwiki.filter.mediawiki.xml.internal.input.MediaWikiInputFilterStream.getFile(MediaWikiInputFilterStream.java:612)
at org.xwiki.filter.mediawiki.xml.internal.input.MediaWikiInputFilterStream.sendAttachment(MediaWikiInputFilterStream.java:581)
[...]
at java.lang.Thread.run(Thread.java:745)
Finished job of type [filter.converter] with identifier [filter/converter/mediawiki+xml/xwiki+instance]
```


Mais la très grande majorité de mon mediawiki a été converti. L’ensemble des pages ont bien été déplacée dans un page Import, et la syntaxe est correctement convertie.

## En conclusion

On a vu à de multiples reprises que l’outil est jeune et qu’il y a quelques risques pour votre xwiki du fait du manque de retours sur l’outil.

Mais si vous prenez vos précautions (import dans un xwiki temporaire, un sous-wiki ou en XAR), vous avez maintenant à votre disposition un outil simple pour migrer vos volumineux mediawiki de manière automatisées vers xwiki : A vos conversions !

## Notes complémentaire, un nouveau parser

A priori depuis l’été, il existe également une extension [MediaWiki Syntax](https://extensions.xwiki.org/xwiki/bin/view/Extension/MediaWiki/MediaWiki+Syntax/) qui ajoute un parser compatible avec la syntaxe Mediawiki. Je ne l’utilise pas puisque j’ai réussi à migrer toutes mes pages, mais pour la copie de pages longues et complexes, cela peut éventuellement être une solution alternative.

![](/2016/12/xwiki_to_mediawiki12.png)

![](/2016/12/xwiki_to_mediawiki13.png)

 [3]: https://extensions.xwiki.org/xwiki/bin/view/Extension/MediaWiki/MediaWiki+XML
 [4]: https://extensions.xwiki.org/xwiki/bin/view/Extension/Import+MediaWiki+To+XWiki
 [5]: https://extensions.xwiki.org/xwiki/bin/view/Extension/Mediawiki+To+XWiki+Migration+Toolkit
 [7]: http://www.xwiki.com/fr/services/
 [8]: https://extensions.xwiki.org/xwiki/bin/view/Extension/MediaWiki/MediaWiki+XML/
