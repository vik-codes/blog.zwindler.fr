---
title: 'Un mois sous Mac, manuel de survie d’un linuxien'
authors:
  - zwindler
type: post
date: 2024-10-09T16:00:00+02:00
excerpt: Retour d'expérience d'un Linuxien plutôt habitué qui a du passer, pour le travail, sur MacOS (sinon c'était Windows)
url: /2024/10/09/un-mois-sous-mac-manuel-survie-linuxien/
image: /2024/10/trash.png
categories:
  - Divers
tags:
  - MacOS
  - Docker
  - Podman
  - AltTab
  - Raccourcis

---

Cela fait un mois que j’utilise un Mac pour la première fois, après des années passées exclusivement sur Linux (hors JVs pénibles à installer sous Linux). Et en plus, dans un contexte pro, où j'ai envie d'être un minimum efficace...

Passer d’un système à l’autre, je ne vais pas mentir c'était une de mes grandes craintes. 

Mais l'alternative, c'était un PC de travail sous Windows et après des années de galères avec [Minikube](https://blog.zwindler.fr/recherche/?keyword=minikube), [WSL](https://blog.zwindler.fr/recherche/?keyword=WSL), [Hyper-V](https://blog.zwindler.fr/recherche/?keyword=hyper-v), c'était HORS DE QUESTION. J'ai quelques articles de blog qui trainent sur le sujet, c'est encore douloureux, je n'ose pas les ouvrir...

Bref, voici un petit résumé de mon expérience, mes galères et mes bonnes surprises.

**Note :** encore une fois je note qu'il est impossible de faire la moindre critique sur MacOS sans voir une horde sanguinaire débouler. Au cas où c'était nécessaire (visiblement oui), je donne ici mon ressenti de novice (et non pas d'expert) à chaud. Il y a certainement des points d'amélioration possible pour rendre ma vie sur MacOS meilleure et je remercie ceux qui l'ont fait de manière bienveillante. Les autres, pardon d'avoir provoqué votre ire (mais vraiment elle ne sort de nulle part).

## Ce qui m'a perturbé (ou carrément frustré)

**MAIS OÙ EST LE CLIC DROIT B%*£EL de M*%£E ???** (pas la peine de me le dire, je sais faire une recherche sur DDG). J'ai préféré brancher une vraie souris (en attendant d'apprendre et de m'habituer aux "gestures").

**Le gestionnaire de fenêtres** : deuxième vrai prise de tête. Les fenêtres se baladent comme bon leur semble (peut-être que je suis psychorigide, je ne sais pas... mais mettez-vous en ordre, bon sang !!). 

La barre de menu tout en haut, c'est vraiment la fausse bonne idée... Quand on a un écran large (21:9 de 34 pouces par exemple) et qu'on a un éditeur de texte à droite, il faut se dévisser le cou pour aller ouvrir le menu "Fichier", tout en haut à gauche. 

Dernier "rant" sur le fenêtrage, le raccourci Cmd+Tab ne fait défiler que les icônes des apps ouvertes, indépendamment du nombre qui ont été ouvertes. Pas de "preview" de ces fenêtres, quel manque incompréhensible par rapport au Alt+Tab sous Windows / Linux...

Note : on peut corriger une partie de ces frustrations avec des apps (spoilers pour plus tard).

**Le Finder** : incompréhensible pour le moment. Naviguer dans l’arborescence, au-delà des favoris, c’est l’angoisse. Ça viendra sûrement avec le temps, mais je ne m’y fais pas.

**Installer les applications** : dernier point, mais je suis plus incrédule que vraiment gêné. Pourquoi les installeurs me demandent de drag'n'drop ???? Vous aussi, vous avez cette sensation de résoudre un Captcha quand on vous demande de glisser l'icône d’une app dans le dossier Applications ?

Non mais... vraiment ! Il y a des Captchas qui sont exactement identiques à ça, hein ?!

![](/2024/10/macapps.png)

Bon... quand j'ai osé dire ça, je me suis pris la commu MacOS sur le dos sur Twitter, c'était rigolo. Peut-être que c'est évident en terme d'UX pour certains (voire la majorité ?). Moi, j'ai attendu quelques secondes en me demandant ce qui se passait, avant de comprendre qu'on attendait de moi de déplacer l'icône...

Je le saurai la prochaine fois, vous êtes susceptibles 😂.

## Les bonnes surprises

Au-delà des frustrations, il y a quand même de très bonnes surprises.

Le terminal : MacOS vient avec zsh par défaut, et tout mon environnement de travail habituel est là. J’utilise Visual Studio Code, et tout tourne comme sur Linux. RAS.

Rosetta : clairement, je suis obligé de dire que je suis impressionné. J’ai un MacBook Pro avec un M3 (processeur ARM64 donc), et Rosetta gère parfaitement les binaires x86, a minima dans mon contexte de travail. Parfois, je me trompe et je télécharge des versions x86_64 d’apps, et ça fonctionne directement. 

Exemple la CLI pour bitwarden, qui est normalement uniquement disponible pour mac arm via npm (donc, `nvm install node`, puis `npm install -g @bitwarden/cli`, relou), fonctionne parfaitement en prenant la version x86_64.

## À apprendre d'urgence par cœur

Ça fait partie de l'apprentissage de la nouvelle plateforme, je l'accepte, mais les premiers jours, j'ai vraiment été super frustré de ne pas savoir faire une partie des caractères les plus basiques.

Ma petite liste d'indispensables sur un clavier MacOS (azerty)

```
Curly Braces { ➜ [option] (
Curly Braces } ➜ [option] )
Braces [ ➜ [shift] [option] (
Braces ] ➜ [shift] [option] )
Back slash \ ➜ [shift] [option] :
Pipe | ➜ [shift] [option] L
Euro € ➜ [option] $
tilde ~ ➜ [option] n
Point médian · ➜ [shift] [option] F (attention ça ne marche pas dans VScode, il veut lancer un formatter)
PageUp ➜ [fn] [flèche haut]
PageDwn ➜ [fn] [flèche bas]
Début ➜ [fn] [flèche gauche]
Fin ➜ [fn] [flèche droite]
```

Et les actions MacOS (sur clavier azerty)

```
Copier ➜ [command] c
Coller ➜ [command] v
Couper ➜ [command] x
Annuler ➜ [command] z
Capture d'écran simple ➜ shift [command] ' (le 4)
Mettre à la corbeille ➜ [command] backspace
```

Dans les trucs cools quand même avec le clavier MacOS quand on dev / fait de l'infra, c'est d'avoir le @, = et ` (back tick) à portée de main, sans combinaisons à la noix. Et ça, c'est cool :\). D'ailleurs, c'est en partie pour ça que je ne branche pas forcément de clavier (contrairement à la souris, l'horreur sinon).

## Quelques apps bien utiles

Je remercie Raph pour deux découvertes qui sauvent la vie :

* Rectangle : pour aligner les fenêtres sur demi-écran, comme sur Windows ou Linux.
* AltTab : pour retrouver avec [option] + [tab] la previsualisation des différentes fenêtres et pouvoir switcher des unes aux autres.

Ne pas avoir mon docker daemon en local comme sous Linux est un peu ennuyeux. La solution avec Docker Desktop pour Mac (qui ne jouit pas d'une super bonne presse de ce que j'ai pu lire) nécessite une licence que je n'ai pas. J'ai réussi à émuler le manque avec Podman desktop, mais j'ai encore quelques bugs relous (authentification à docker.io pas persistante au reboot). Quand j'aurai trouvé la cause, ça ira mieux.

```zsh
sudo ln -s /opt/podman/bin/podman /usr/local/bin/docker
alias docker=podman
```

Et pour installer tout le reste : pour l'instant j'utilise [Homebrew](https://brew.sh/). Oui, je sais, c'est lourd, il y a surement plein de bonnes raisons de ne pas l'utiliser. Mais ça "juste marche", comme gestionnaire de paquets, alors pourquoi m'embêter ? Je verrai quand j'arriverai aux limites.

## Le passage régulier entre MacOS et Linux

C’était ma grande crainte, mais honnêtement, ça se passe mieux que prévu. 

À part confondre Alt+C/Alt+V sur Linux pour copier-coller, ou rater mes Ctrl+H sur MacOS (qui minimise une fenêtre au lieu de remplacer du texte), je retrouve vite mes repères. 

Au final, le passage entre ces deux mondes de manière régulière se fait plutôt bien.

## Conclusion : plutôt content

Ce premier mois dans ce nouveau contexte pro (j'aurais l'occasion d'en reparler) a été riche en apprentissages. Le passage sous MacOS en faisait partie (heureusement ou malheureusement, je ne sais pas encore xD).

Je sens bien que je reste plus à l'aise sous PC, ne serait ce que pour le clavier, le fenêtrage et toutes les petites galères dont j'ai parlé au début. Je ne pense pas passer sous Mac en perso, par exemple.

Clairement, c'est une très bonne machine. J'ai volontairement évité de parler du côté hardware, évidemment difficilement égalable, mais pour le prix heureusement. Ça a été évoqué de manière unanime par tout le monde, inutile d'en rajouter. Mais côté usage et expérience globale, c'est plutôt agréable à utiliser dans un contexte pro.