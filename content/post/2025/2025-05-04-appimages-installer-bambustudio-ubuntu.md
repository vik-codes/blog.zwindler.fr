---
title: 'AppImages sous Ubuntu, exemple avec Bambu Studio'
authors:
  - zwindler
type: post
date: 2025-05-04T12:00:00+02:00
url: /2025/05/04/appimages-installer-bambustudio-ubuntu/
image: /2025/05/desktop.png
categories:
  - DIY
tags:
  - Impression 3D
  - Bambu Studio
  - bambustudio

---

## Bambu Studio et l'impression 3d sous Linux

Depuis quelques mois, vous le savez, je me suis lancé dans l'impression 3D. Et si au début, j'ai commencé sous Klipper (pour l'imprimante 3D) et [Slic3r](https://slic3r.org/) (ou plutôt son fork, Artillery Slicer) pour slicer, je suis depuis janvier passé sur une imprimante Bambu Labs dont je suis très content (ça devrait faire râler LinuxFR, ce commentaire).

Bien entendu, quand j'ai acheté l'imprimante, j'ai regardé s'il y avait un slicer compatible Linux, car Windows, c'est bien pour jouer (encore que) mais si je peux m'en passer pour l'impression 3D, c'est aussi bien.

## Oui, mais...

Alors, oui, c'est "supporté" (notez les guillemets) mais ce n'est pas aussi trivial que pour Windows et MacOS où on clique bouton.

Un petit tour sur le site de téléchargement de l'outil permettra de se rendre compte qu'on est bien, nous linuxiens, des nerds de seconde zone pour BambuLab.

![](/2025/05/téléchargement.png)

On voit en tout petit que pour Linux, il va falloir se contenter de releases sous Github.

Bon, l'idée de ne pas m'embêter et de passer par de l'émulation Wine m'a éfleuré l'esprit, mais je me suis dit que j'allais tenter la méthode officielle.

## AppImage

Il y en a deux. La première, via des AppImages est celle qui est mise en avant mais n'est probablement pas la plus "pratique". 

En réalité, j'ai découvert un peu après qu'il y a en fait un flatpak disponible via le dépôt flathub. Le seul "inconvénient" est que ça nécessite d'avoir yet another package manager, mais il n'est pas impossible que vous l'ayez déjà...

Donc, je vais rester dans cet article sur la méthode que moi, j'ai utilisé, à savoir les AppImages, parce que ça va nous permettre de jouer avec les .desktop d'Ubuntu et ça fait 2 tutos en un (et ça, c'est rigolo).

## Téléchargement et lancement

Cette partie est la plus simple. On va donc simplement sur les releases github de BambuStudio :

* [github.com/bambulab/BambuStudio/releases](https://github.com/bambulab/BambuStudio/releases)

On prend la dernière, on la télécharge :

![](/2025/05/releases.png)

À noter, les AppImages ne sont disponibles que pour Ubuntu 22.04 et 24.04 (et Fedora). Quelques versions plus tôt, c'était 20.04 et 24.04. Comme l'AppImage est liée à des libs (gtk) présentes sur l'OS, si vous lancez l'image Ubuntu avec la mauvaise version, il ne va pas trouver la version de la lib c'est très casse-pied.

On peut tricher en *linkant* les versions pour qu'il retrouve la lib mais c'est probablement assez casse-gueule comme workaround...

```
sudo ln -sf /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.1.so.0  /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37
```

Une fois l'archive téléchargée et décompressée, on va se retrouver avec un dossier contant l'AppImage directement.

Si vous double-cliquez dessus, ça devrait fonctionner, vous aurez Bambu Studio qui se lancera.

## Victoire ?

Oui ok, ça fonctionne, mais c'est quand même pas super pratique d'aller dans le dossier Téléchargement, cliquer sur l'AppImage. 

On peut évidemment déplacer l'AppImage dans un dossier dans notre PATH (`/usr/local/bin`) et l'appeler via une terminal, mais c'est pas ouf non plus en terme d'expérience utilisateur (je ne suis pas le seul à faire de l'impression 3D à la maison).

Arrivent alors les `.desktop`. Il s'agit d'un fichier texte qui va nous permettre d'ajouter l'appImage dans la liste des applications d'Ubuntu et ça c'est pas mal parce que c'est user friendly.

On va déplacer l'AppImage dans un dossier du PATH, et créer un lien symbolique :

```bash
cd /home/zwindler/.local/bin
mv Téléchargements/BambuStudio_ubuntu-24.04_PR-6688/Bambu_Studio_ubuntu-24.04_PR-6688.AppImage .
ln -s Bambu_Studio_ubuntu-24.04_PR-6688.AppImage bambustudio
```

Pourquoi je fais un lien symbolique ? 2 raisons.

La première, c'est que si je veux quand même lancer Bambu Studio depuis mon terminal (en cas de souci au lancement, je veux pouvoir voir les logs), je peux le faire en lançant simplement la commande `bambustudio` et pas `Bambu_Studio_ubuntu-24.04_PR-6688.AppImage`. 

La deuxième, c'est qu'à la prochaine mise à jour, j'aurais "juste" à modifier le lien symbolique pour qu'il pointe vers la nouvelle appImage plutôt que de devoir refaire toutes les étapes qui vont suivre.

Par défaut, toutes les applications de la liste sont dans votre dossier `.local/share/applications/` :

```bash
zwindler@normandy:~$ ls .local/share/applications/
appimagekit-openshot-qt.desktop
Bambu_Studio.desktop
chrome-hmjkmjkepdijhoojdojkdfohbdgmmhki-Default.desktop
mimeapps.list
mimeinfo.cache
userapp-Firefox-V48P02.desktop
```

Voici à quoi notre fichier `Bambu_Studio.desktop` doit ressembler :

```toml
[Desktop Entry]
Name=Bambu Studio
GenericName=Bambu Studio
Comment=Bambu Studio
Exec=/home/zwindler/.local/bin/bambustudio %F
Icon=/home/zwindler/.local/share/icons/bambustudio.png
Terminal=false
Type=Application
```

Rien de bien extravagant, ici, on donne surtout le nom de l'application, un Type et un chemin d'exécution (et quelques paramètres complémentaires).

Les plus attentifs d'entre vous auront remarqué qu'on peut aussi ajouter une icône, c'est vrai que c'est quand même plus mignon d'ajouter le logo de Bambu Lab que l'icône par défaut...

![](/2025/05/icon1.png)

J'ai récupéré le logo de Bambu Lab sur leur Github et je l'ai déposé dans le dossier `/home/zwindler/.local/share/icons/` :

* [avatars.githubusercontent.com/u/96461528?s=200&v=4](https://avatars.githubusercontent.com/u/96461528?s=200&v=4)

Et voilà le résultat :\)

![](/2025/05/desktop.png)
