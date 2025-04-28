---
title: Résoudre les erreurs de fichiers trop gros lors des imports XWiki, XAR notamment
authors:
  - zwindler
type: post
date: 2016-04-30T13:30:41+00:00
url: /2016/04/30/resoudre-erreurs-de-fichiers-gros-lors-imports-xwiki/
image: /2015/11/1434473398.png
categories:
  - Logiciel
tags:
  - Attachment
  - erreur
  - MySQL
  - pièce jointe
  - taille
  - XAR
  - Xwiki

---
## Pourquoi je n’arrive pas à uploader mon gros XAR

Cet article fait suite à [mon précédent article indiquant comment corriger les erreurs lors d’imports de fichiers XAR](/2016/03/12/parametres-caches-de-xwiki-taille/) dans XWiki. J’avais un bon gros export au format XWiki (XAR donc) et j’avais plusieurs erreurs lors de l’import qui me bloquait.

A la suite de l’article, j’ai reçu une réponse de Ludovic DUBOST, CEO et fondateur de XWiki SAS qui m’a donné une piste supplémentaire pour régler le problème.

> Cette limite de taille du fait de la consommation mémoire est réglé dans le mode « File System Attachment » de XWiki. Il y a déjà eu des discussions pour que ce soit la configuration par défaut. Nous allons la réactiver.
> 
> Pour plus d’infos sur le mode FS:  
> platform.xwiki.org/xwiki/bin/view/AdminGuide/Attachments#HFilesystemAttachmentStore (lien mort, pas dispo sur Internet Archive)

## Filesystem attachment store

Et oui, des fois dans la vie, il suffit de lire la documentation entière et ne pas se contenter du premier paragraphe.

Dans la documentation à propos des attachements, si on va au delà de la première partie, on peut lire :

> The directory in which the attachments are stored in the filesystem is defined with the parameter <span class="monospace">environment.permanentDirectory in the <span class="monospace">xwiki.properties file. By default it’s defined to be <span class="monospace">data, which is a directory relative to where the Java Servlet Container was started. It’s recommend to modify this value to be absolute sure that you can start the Servlet Container from any directory and still have XWiki find the attachments located in this work directory.
> 
> environment.permanentDirectory=/opt/tomcat6/data

En gros, plutôt que de fonctionner dans le mode classique avec l’ensemble des objets (pièces jointes) et donc les imports XAR en base de données, il est possible de stocker sur le filesystem local les fichiers dans une arborescence standard de type /opt/tomcatX/data.

(Lien image mort)

Sur le papier, cette méthode permet de s’affranchir des tailles maximales des objets envoyés en base (entre autre un pb de stream avec MySQL selon Ludovic DUBOST?). Elle apporte cependant son lot de considérations supplémentaires :

  1. Il ne faut évidemment pas manipuler les fichiers en dehors du wiki (i.e. aller virer des fichiers directement dans le FS côté OS pour faire un peu de place. Ne faites pas les innocents, je sais que vous y pensiez)
  2. Sauvegarder la base de données ne suffira plus puisque les objets ne sont plus en base. Il faudra ajouter à votre script de sauvegarde un petit bout de script pour zipper les fichiers uploadés contenus dans le fameux dossier
  3. Basculer d’un mode à l’autre n’est pas une opération à prendre à la légère : si vous avez déjà des objets en base, il faut les récupérer pour les redéposer sur le FS.

Pour la première, on va dire que je vais vous faire confiance ;). Pour la seconde aussi, vous êtes sérieux.

### Pour ceux qui sont dans l’ancien mode de fonctionnement

Et pour la dernière, l’équipe de XWiki met gentiment à disposition une extension pour passer automatiquement d’un mode à l’autre : [Filesystem Attachment Porter](https://snippets.xwiki.org/xwiki/bin/view/Extension/Filesystem%20Attachment%20Porter) ! Ca tombe bien, je n’avais pas envie de le faire à la main ;-).

La procédure est assez bien documentée et détaille même ce dont je viens de parler un peu plus haut (sauvegarde des répertoires, bascule dans le nouveau mode de stockage des PJ).

### Pour les nouveaux utilisateurs

Le problème ne se pose pas vraiment. Si le wiki vient d’être créé il n’y a pas encore d’objets en base. Vous pouvez simplement basculer dans le mode « Filesystem attachment » en modifiant quelques options dans le fichier **xwiki.cfg**

```
xwiki.store.attachment.hint = file
xwiki.store.attachment.versioning.hint = file
xwiki.store.attachment.recyclebin.hint = file
```

## Au delà de ça

N’ayant pas suivi l’ensemble des discussions à propos des choix de garder le mode par défaut avec tout en base, je ne peux pas savoir ce qui a conduit à ne pas basculer dans le mode Filesystem attachment « par défaut ». Cependant, je pense qu’effectivement cela pourrait être une bonne idée de le faire, à minima pour éviter que d’autres utilisateurs continuent de poser la question sur la devlist.

### FAQ

Également, vous auriez pu tomber sur la solution via une FAQ qui a été rédigée début 2016, probablement suite au nombre de personnes qui ont eu ce problème et qui le remontent dans la devlist (premiers résultats jusqu’à il y a peu quand on tappe le message d’erreur dans Google) :  
* [www.xwiki.org/xwiki/bin/view/FAQ/How+to+import+a+XAR+larger+than+100MB](https://www.xwiki.org/xwiki/bin/view/FAQ/How+to+import+a+XAR+larger+than+100MB)
