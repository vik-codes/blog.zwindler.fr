---
title: 'Erreur dans l’ordre des épisodes dans Plex (Aired vs DVD order)'
authors:
  - zwindler
type: post
date: 2017-08-01T11:30:42+00:00
url: /2017/08/01/changer-lordre-dune-serie-dans-plex-aired-vs-dvd-order/
image: /2017/06/powerpuff6.png
categories:
  - DIY
tags:
  - Aired order
  - DVD
  - DVD order
  - épisode
  - ordre
  - Plex
  - Plex Server
  - Powerpuff Girls
  - Série TV

---
## « J’ai un problèèèèèmeuh »

J’ai un problème (dramatique) sous Plex Media Server (PMS) avec la séries The Powerpuff girls (Les Super Nanas). En réalité, j’en ai même deux...

![](/2017/06/powerpuff1.png)

### 1er problème : l’ordre des premiers épisodes ne colle pas

Lorsque je me suis mis à re-regarder les Powerpuff Girls, j’ai remarqué que le premier épisode n’avait aucun rapport avec le titre de l’épisode affiché dans Plex.

Le premier épisode que j’ai lancé aurait du contenir, selon Plex, « Monkey See, Doggie Do ». Or, après lecture, je me suis rendu compte qu’il s’agissait d’en fait un double épisode contenant « Insect Inside » et « Powerpuff Bluff ». Rien à voir.

En gros :

  * Selon Plex, on a S01E01 « Monkey See, Doggie Do » et S01E02 « Mommy Fearest »
  * En réalité, ces deux épisodes sont contenus dans le S01E**02**, tandis que le **VRAI** S01E01 contient « Insect Inside » et « Powerpuff Bluff ».

Le problème vient visiblement de ma série source, dont l’ordre ne correspond pas avec le référentiel de Plex. 

Je me suis rappelé que la source de Plex vient pour mes séries du site TheTVDB.com. Voilà ce qu’on voit quand on affiche la page des Powerpuff Girls :

![](/2017/06/powerpuff3.png)

> Jusque là c’est logique, les épisodes sont bien identiques à ce que m’affiche Plex.

Mais ça n’explique pas pourquoi ma série n’a pas le même ordre que TheTVDB !

### 2ème problème : Un fichier = 2 épisodes

J’ai déjà un peu abordé le 2ème dans le paragraphe précédent. Vous l’aurez surement compris, la série Powerpuff Girls est une série dont les épisodes sont doubles. Un même fichier (par ex. S02E03) contient donc 2 sous épisodes, chacun ayant son propre titre et son propre résumé.

Or, malheureusement, Plex ne semble pas comprendre qu’un seul fichier peut contenir plus d’un épisode, ce qui induit un décalage (au delà de l’ordre qui est mauvais, cf le premier problème).

## **1er contournement (pour le 2ème problème)** 

Ça ne règle pas le premier problème, mais dans Plex il est possible d’indiquer qu’un fichier contient 2 épisodes : renommer en maserie_s01e01-e02 (ou s01e01-s01e02, la syntaxe est floue et les retours sont parfois erratiques selon le forum de Plex).

Après rescan de la bibliothèque, les deux épisodes apparaissent bien dans Plex.

Cependant cette technique est tout sauf optimale ! Les deux épisodes sont bien visibles mais ne sont pas « liés ». Bien qu’il n’y ait qu’un seul fichier contenant 2 épisodes, Plex traite ce fichier comme 2 fichiers !

Quand vous aurez fini de voir le premier, Plex vous proposera de lancer le second (qu’il considérera comme « Non vu ») et relancera le même fichier... Pas top.

![](/2017/06/powerpuff5.png)

## « DVD order » versus « Aired date order »

En réalité ce problème est connu. Il apparaît souvent dans des séries de type dessins animés (à quelques exceptions notables comme Firefly, a priori).

Un petit retour sur TVDB permet de se rendre compte qu’il existe parfois, pour une même série, des ordres et des découpages différents entre ce qui a été diffusé à la TV et le DVD de la série !

![](/2017/06/powerpuff4.png)

Ces deux ordres sont renseignés dans TVDB sous l’appellation « Aired Order » et « DVD Order ». Malheureusement, le plugin TVDB officiel de Plex ne semble pas prendre en compte le DVD Order et cela explique les divergences qu’on retrouve dans notre bibliothèque.

## Installation de l’agent

Comme le problème est connu depuis longtemps, un personne a modifié le plugin officiel de Plex pour TVDB et [l’a adapté pour proposer à la main de modifier une séries pour qu’elle prenne en compte le « DVD order »][5].

Malheureusement, l’auteur du script ne semble plus le maintenir et ça ne fonctionne plus « out of the box ».

### Récupérer la dernière version

La dernière version est cachée au milieu des commentaires. Vous pouvez la télécharger directement sur ce lien qui pointe vers le bon commentaire :

* [forums.plex.tv/discussion/comment/652345/#Comment_652345](https://forums.plex.tv/discussion/comment/652345/#Comment_652345)

### Installer le module

Personnellement, je n’avais aucune idée de comment installer un module (Plex App) dans PMS. C’est quelque chose qu’on ne fait jamais car l’appli se suffit à elle même (je trouve), contrairement à Kodi qui lui met en avant un magasin d’extension par exemple.

Comme je suis sympa je vous donne les commandes que j’ai tapé sur la machine qui héberge mon PMS :

```
cd '/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/'
sudo wget https://us.v-cdn.net/6025034/uploads/ipb/monthly_05_2014/DVD%20Order%20Agent.bundle.zip
sudo unzip DVD\ Order\ Agent.bundle.zip
sudo mv DVD\ Order\ Agent.bundle DVDorder.bundle
sudo chown -R plex:plex DVDorder.bundle/
/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins$ ll
    total 16
    drwxr-xr-x 4 plex plex 4096 juin 4 14:32 ./
    drwxr-xr-x 12 plex plex 4096 juin 4 14:34 ../
    drwxr-xr-x 3 plex plex 4096 déc. 16 2010 DVDorder.bundle/
    drwxr-xr-x 3 plex plex 4096 mai 7 17:51 Services.bundle/
sudo systemctl restart plexmediaserver.service
```


Voici les sujets que j’ai consultés pour trouver la solution à ce problème (car un bon ENSEIRBien cite toujours ses sources).

* [forums.plex.tv/discussion/79243/how-to-manually-install-the-plex-app](https://forums.plex.tv/discussion/79243/how-to-manually-install-the-plex-app)
* [support.plex.tv/articles/201106098-how-do-i-find-the-plug-ins-folder/](https://support.plex.tv/articles/201106098-how-do-i-find-the-plug-ins-folder/)

Une fois que c’est fait, il faut ensuite se connecter sur Plex depuis un navigateur avec le compte lié au serveur Plex, pour configurer (activer) le module.

![](/2017/06/plex1.png)

## Activer le DVD Order ?

A partir de là, j’étais assez content de moi et je me suis dis : « Chouette, ça va marcher maintenant. » Et ben non...

Voici ce que j’ai tenté :

  * Sur la vignette des Powerpuff Girls, [petit crayon]

![](/2017/06/plex2.png)

  * Sur la ligne « Episode ordering », passer à « DVD order »

![](/2017/06/plex3.png)

## Ça ne marche pas !

Même après modification, enregistrement, rescan de la librairie... rien n’y fait. L’ordre de mes épisodes n’a pas changé.

Du coup, je me suis dis que c’était peut être un conflit entre sources. Habituellement, lorsqu’un film ou une série est mal détectée par Plex (et que ce n’est pas de la faute d’un mauvais nommage du fichier), on peut forcer l’association pour imposer la bonne version.

Typiquement, j’ai eu l’exemple avec « Kung Fu Panda (2008) » qui était par erreur (j’ignore pourquoi) détecté comme le 3ème opus.

![](/2017/06/kungfu3.png)

![](/2017/06/kungfu1.png)

![](/2017/06/kungfu2.png)

Pour en revenir à mon cas, j’ai donc tenté de forcer l’association en utilisant l’agent **TheTVDBdvdorder**.

![](/2017/06/plex7.png)

Et c’est comme ça que j’ai trouvé mon erreur. L’agent ne trouve aucune information, et l’association automatique bascule donc sur l’Aired Order !

![](/2017/06/plex8.png)

## Le fix de la mort

A partir de cette erreur, j’ai rapidement pu trouver des gens qui ont débugué le plugin.

![](/2017/06/plex6.png)

> https://forums.plex.tv/discussion/21141/dvd-order-agent/p18

Il faut modifier le code source du fichier **\_\_init\_\_.py** pour commenter deux vieilles URL qui ne répondent plus, et les remplacer par trois autres.

```
cd "/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/DVDorder.bundle/Contents/Code"

cp __init__.py __init__.py.ori
vi __init__.py

#TVDB_GUID_SEARCH = freebase.plexapp.com/tv/guid/
#TVDB_QUICK_SEARCH = freebase.plexapp.com/tv/names/
TVDB_GUID_SEARCH = http://meta.plex.tv/tv/guid/
TVDB_QUICK_SEARCH = http://meta.plex.tv/tv/names/
TVDB_TITLE_SEARCH = http://meta.plex.tv/tv/titles/

sudo systemctl restart plexmediaserver.service
```


**Taaaadaaaa** : Après redémarrage, les 2 problèmes ont été résolus d’un seul coup !!!

![](/2017/06/powerpuff6.png)

## Bonus : On a perdu la musique de générique

Bon, bien sûr ça ne pouvait pas fonctionner à 100%...

Par défaut, PMS lance un extrait de la musique de générique d’une série quand on arrive sur la page de cette série. C’est vraiment très sympa (même si ça peut paraître gadget dit comme ça).

Et oui... en ajoutant le TVDBdvdorder nous avons cassé un autre plugin et nous devons donc continuer notre petite séance de hacking !

Dans son post, [jooniloh parle d’un plugin PlexThemeMusic][16].

> Nevermind! Figured it out. Did not see the bit about editing PlxThemeMusic.bundle’s **\_\_init\_\_.py** earlier.  
> - jooniloh

Cependant ce plugin, comme le dit l’auteur, n’en est plus un. C’est maintenant une fonction intégrée qu’il faut donc aller chercher dans les ressources de PMS (ici 995fidead est ma version, la dernière à l’heure où j’écris ces lignes) et non plus dans le dossier **Plex Media Server/Plug-ins**.

Vous pouvez retrouver ce dossier de la façon suivante :

```
locate PlexThemeMusic.bundle
/usr/lib/plexmediaserver/Resources/Plug-ins-995f1dead/PlexThemeMusic.bundle
```


On garde une copie du fichier source pour plus de sécurité

```
cd '/usr/lib/plexmediaserver/Resources/Plug-ins-995f1dead/PlexThemeMusic.bundle/Contents/Code'
sudo cp __init__.py __init__.py.ori
```


On créé un patch et on l’applique

```
sudo echo "41,42c41,42
<   def update(self, metadata, media, lang, force=False):
<     if force or THEME_URL % metadata.id not in metadata.themes: --- >   def update(self, metadata, media, lang):
>     if THEME_URL % metadata.id not in metadata.themes:" > __init__.py.patch

patch __init__.py __init__.py.patch
    patching file __init__.py

sudo systemctl restart plexmediaserver.service
```

Si vous voyez où je me suis trompé, je suis preneur !

 [5]: https://forums.plex.tv/discussion/21141/dvd-order-agent
 [16]: https://forums.plex.tv/discussion/comment/933131/#Comment_933131
