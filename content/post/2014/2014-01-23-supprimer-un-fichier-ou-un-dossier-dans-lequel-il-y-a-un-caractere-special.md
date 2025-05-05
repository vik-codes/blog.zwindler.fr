---
title: '[En bref] Supprimer un fichier/dossier nommé avec un caractère spécial'
authors:
  - zwindler
type: post
date: 2014-01-23T08:49:15+00:00
url: /2014/01/23/supprimer-un-fichier-ou-un-dossier-dans-lequel-il-y-a-un-caractere-special/
image: /2014/01/unix-plate.jpg
categories:
  - systeme
tags:
  - Linux
  - rm
  - rmdir
  - special caracter
  - Unix

---
## Un caractère spécial, et c’est le drame

Combien de fois avez vous tapé trop vite une commande créant un fichier ou un dossier avec un caractère spécial dans son nom. Et bien sûr vous avez oublié comment le supprimer !  
C’est de moins en moins vrai aujourd’hui. Les shells vous aident avec l’auto-complétion et les binaires récents vous proposent une solution lorsque vous tapez la commande « rm ».

```
[root@lol01 ~]# touch '#fichieravecuncaracterebienmarrant'
[root@lol01 ~]# rm #fichieravecuncaracterebienmarrant
rm: opérande manquant

[root@lol01 ~]# touch '\-rires'
[root@lol01 ~]# cat \-rires
cat : option invalide -- 'r'
Saisissez "cat --help" pour plus d'informations.
```


Mais dans le cas où vous seriez sur un système qui date un peu, voici un petit reminder écrit par UnixTutorial pour s’en sortir ;-)

* [Unix Tutorials (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20160315110117/https://www.unixtutorial.org/2008/09/remove-files-and-directories-with-special-characters/)

C’était pas plus compliqué que ça ;-)

Je recommande d’ailleurs chaudement unixtutorial. Il fait partie de ces sites sur lesquels vous tombez souvent quand vous cherchez quelque chose sur Linux/Unix et que vous ne vous en souvenez plus.

Je pense que je vais faire une page spéciale avec une liste de ces lectures...
