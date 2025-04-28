---
title: 'Paramètre caché XWiki pour résoudre l’erreur « fichier trop gros » lors de l’import d’un XAR'
authors:
  - zwindler
type: post
date: 2016-03-12T11:30:04+00:00
url: /2016/03/12/parametres-caches-de-xwiki-taille/
image: /2015/11/1434473398.png
categories:
  - Logiciel
tags:
  - edit
  - fichier trop gros
  - import
  - java.io.FileInputStream
  - OOM
  - OutOfMemoryError
  - sauvegarde
  - XAR
  - Xwiki

---
[Edit]

Ludovic DUBOST, CEO et fondateur de XWiki SAS m’a répondu (voir les commentaires). Le bug est connu mais _a priori_ on doit utiliser les attachements de type _Filesystem Attachment_ (pas le choix par défaut qui est le _Database Attachment_).

On trouve plus d’informations sur l’article suivant

* [www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Attachments](https://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Attachments)

> The Filesystem attachment store saves your attachments in files in a directory tree. This means you will have one more thing to do when you back up your data but it also means you can save larger (over one gigabyte) files.

[/Edit]

Lorsque j’ai voulu importer une sauvegarde XAR un peu importante sous XWiki, je me suis retrouvé bloqué par la taille maximale des fichiers XAR que je pouvais importer. En effet par défaut, on est limité à 32 MB ce qui peut arriver rapidement avec des images/captures d’écran.

Et comme on ne peut pas faire un XAR avec uniquement une partie d’un wiki, il n’y a pas trop de solutions pour réduire la taille du XAR (vous pouviez quand même jouer sur la présence de l’historique des révisions ou pas, je ne sais pas si c’est toujours le cas).

[Edit]On peut faire des imports/exports plus précis avec des extensions comme LargeXARImport ou ImportExport, etc. [/Edit]

![](/2015/11/016_xwiki.png) 

Pour autant, modifier cette limite purement logicielle (et arbitraire), il faut passer par des pages d’administration cachées.

## La solution

Pour une raison que j’ignore, on ne peut ni accéder à ce paramètre dans les pages d’administration classique du wiki ni modifier une valeur dans les fichiers de configuration.

Il faut ouvrir une URL directement en mode « édition » sur les préférence du type :

> http://@IPwiki:8080/xwiki-enterprise-web-7.2/bin/**edit/XWiki/XWikiPreferences?editor=object**

Si vous êtes au bon endroit, cela devrait ressembler à ça :

![](/2015/11/017_xwiki.png)

Cliquez sur la liste « XWikiPreferences 0 » **juste en dessous **de la ligne « XWiki.XWikiPreferences (1) ». Pas évident évident...

![](/2016/03/xwiki_uploadpng.png)

On y retrouve également des valeurs comme le serveur SMTP ou le serveur LDAP qu’on a paramétré côté xwiki.cfg, bizarrement ?

![](/2015/11/018_xwiki.png)

Modifiez le paramètres à la hausse pour correspondre à votre taille de fichier XAR, puis cliquez sur « Enregistrer et Fermer » pour valider.

Dans mon cas (PostgreSQL), ça marche, pas besoin de modifications supplémentaires, juste un redémarrage de tomcat.

![](/2015/11/019_xwiki.png)

## Et la base de données ?

Pour autant, vous pourriez quand même avoir des ennuis si jamais votre base de données n’accepte pas les fichiers trop gros elle aussi, comme par exemple MySQL/MariaDB. Vous trouverez plus d’informations sur le sujet dans ce [topic de la mailing list (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20211129081936/http://lists.xwiki.org/pipermail/users/2012-February/022047.html) :

> Pay also attention that your DB configuration could prevent you from uploading such a package. For exemple, with Mysql, you have to fix the value of max\_allowed\_packet in my.cnf file. If you want to upload a package of 35 MB for example, you need the value max\_allowed\_packet to be at least « 75M ».

Je ne suis pas certain de comprendre pourquoi il faut mettre max\_allowed\_packet à 75M pour un fichier de 35 MB. Visiblement il y a un coefficient x2 ?

## Mais ça ne marche toujours pas

C’est fini ? Et bien non. Malheureusement, l’import de fichiers .XAR de XWiki est _a priori_ une fonctionnalité très gourmande en mémoire et plante parfois juste après la fin de la barre de transfert :

![](/2016/03/erreur_xwiki_import.png)

Dans le fichier de log on pourra trouver une erreur de ce gout là :

```
Nov 12 17:02:23 @IPxwiki server: 2015-11-12 17:02:23,152 [http://@IPxwiki:8080/xwiki-enterprise-web-7.2/bin/upload/XWiki/XWikiPreferences] WARN c.x.x.w.UploadAction - Saving uploaded file failed
Nov 12 17:02:23 @IPxwiki server: Caused by: java.lang.OutOfMemoryError: Java heap space
```


Bon il semblerait que ce soit un problème connu depuis au moins 2008, si on en crois [ce post (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20160904053532/http://xwiki.475771.n2.nabble.com/Java-Heap-Space-Out-of-memory-exception-td1613958.html) et la réponse de Sergiu Dumitriu :

> This is a major design flaw of the current attachment storage model. As stated in a previous mail, handling attachment consumes about **27 time the size of the attachment**, so 90M * 27 ~= 2.5G. This needs to be fixed ASAP. In the meantime, you can either increase the heap size to more than 2.5G, or request an sql dump from the myxwiki farm admins.

**27 FOIS**

Effectivement, lorsque j’importe des XAR d’environ 60-70 Mo dans mon instance tomcat sizée à environ 2 Go, ça fonctionne, mais pas pour les fichiers de 80 Mo. La règle semble correspondre.

J’écrirais un autre article pour expliquer ce qu’on peut y faire dès que j’aurai un peu plus de matière.

## Source

* [www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Attachments](https://www.xwiki.org/xwiki/bin/view/Documentation/AdminGuide/Attachments)
