---
title: Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 02
authors:
  - zwindler
type: post
date: 2022-10-13T06:00:00+02:00
url: /2022/10/13/webui-tui-gui-pour-kubernetes-episode-02/
image: /2022/10/wholetthedogsout.png
categories:
  - Cluster
  - Virtualisation
tags:
  - cli
  - gui
  - k8s
  - Kubernetes
  - tui
  - webui

---

Note: Cet article fait partie d'une série de 3 articles dans lesquels je fais une **liste exhaustive** des WebUIs, TUIs et GUIs pour utiliser Kubernetes :
* WebUI - [Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 01](/2022/02/21/webui-tui-gui-pour-kubernetes-episode-01/)
* TUI - [Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 02](/2022/10/13/webui-tui-gui-pour-kubernetes-episode-02/)
* GUI - [Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 03](/2022/10/24/webui-tui-gui-pour-kubernetes-episode-03/)

## Kubernetes, c’est dur 😭, suite

Dans l'article précédent (en février dernier, mdr), je vous avais présenté les Web UI qu'on pouvait utiliser avec Kubernetes. Vous aviez probablement deviné, aujourd’hui on va parler des TUI, aka les *Terminal User Interfaces* ou interface pour terminaux en bon français.

Alors on pourrait penser que l'article ne se résume qu'à un seul nom tant il est connu. Car la vraie star des UI dans Kubernetes, c'est bien évidemment **k9s**. 

Mais j'ai réussi à en dégoter une autre, active et utilisée (+2k stars sur Github et une place à part entière dans le [repo kubernetes SIG](https://github.com/kubernetes-sigs)), dont je parlerai après.

## k9s 🐶

> Who let the Pods out?
>
> WHO?! WHO?! WHO WHO?!

> Vous aussi vous avez Baha men dans la tête ?
>
> (Vous êtes vieux/vieilles)

![](/2022/10/k9s.png)

* **Site**: [k9scli.io](https://k9scli.io/)
* **Sources**: [github.com/derailed/k9s](https://github.com/derailed/k9s)

Je me répète un peu mais impossible de faire des articles sur les UI dans Kubernetes sans citer k9s (à prononcer k-nine-s, d'où le chien pour ceux qui ne l'avaient pas).

C'est très probablement le tool le plus riche que vous pourrez trouver pour gérer vos clusters Kubernetes, mais aussi celui qui demande un petit apprentissage, notamment parce que 90% de la puissance de l'outil réside dans les raccourcis.

Je ne vais pas mentir, au risque d'en décevoir plus d'un, je ne l'utilise d'ailleurs pas au quotidien, pour cette raison... 

J'ai toujours eu la flemme d'apprendre les raccourcis et je préfère "m'embêter" à faire les commandes en CLI, via la WebUI officielle, ou entre via une autre UI dont on parlera dans le prochain article 😏...

Cependant, si vous avez la patience d'apprendre ces fameux raccourcis, c'est sans aucun doute l'outil le plus puissant pour utiliser Kubernetes au quotidien. On peut facilement "drill down" dans notre cluster, filtrer les pods, faire du port-forward facilement, visualiser les CRDs, ...

![](/2022/10/k9s_debug_pod.png)

![](/2022/10/k9s_help.png)

L'outil s'installe grâce à des gestionnaires de paquets (type homebrew, linuxbrew, pacman, chocolatey, ...) ou directement en compilant les sources (c'est du go, c'est assez trivial) :

```bash
git clone https://github.com/derailed/k9s
make build
```

A noter, on peut lancer directement d'autres outils depuis k9s comme [popeye (un tool pour aider à nettoyer son cluster du même auteur)](https://popeyecli.io/) (avec `:popeye`).

## KUI

> KUI KUI KUI 🐦

* **Site**: [kui.tools](https://kui.tools/#installation)
* **Sources**: [github.com/kubernetes-sigs/kui](https://github.com/kubernetes-sigs/kui)

Deuxième TUI de cet article (et probablement la seule autre), j'ai nommé KUI.

Je l'avais testée en 2018 ou 2019, avant que le projet ne soit déplacé dans le *kubernetes-sigs*, quand cette UI était encore développée par IBM.

Kui est vraiment une app chelou, hybride entre la CLI, une TUI et une GUI (en fait, c'est une app electron). 

Récupérer une release https://github.com/kubernetes-sigs/kui/releases/tag/v13.1.4

```
unzip kui.zip
export PATH=$PWD/Kui-linux-x64/Kui.app/Contents/Resources:$PATH
kubectl kui get pods
```

Historiquement, je me souviens l'avoir lancée depuis mon terminal, mais il semblerait que maintenant ce soit lancé dans une fenêtre à part entière...

Toujours est-il qu'une fois lancée, on se retrouve avec un "terminal" permettant de lancer des commandes `kubectl` soit en les écrivant, soit en cliquant dessus.

![](/2022/10/kui.png)

Ce que j'avais trouvé intéressant à l'époque avec cette UI (je sais pas trop comment la catégoriser), c'est que toutes les modifs qu'on fait affichent la commande avec `kubectl` correspondante, et qu'on peut switcher de l'un à l'autre. C'est à la fois terminal **et** graphique.

J'aime beaucoup cette idée qu'on devrait avoir littéralement dans TOUS les outils qui proposent des CLIs (Google le fait sur certains menus il me semble).

Cependant, c'est un peu bourrin et pas super efficace à l'usage. Mais ça valait je pense quand même le coup d'en parler, au moins pour la culture et les quelques bonnes idées.

## Et plus si affinité...

Clairement, cet article n'est pas le plus fourni des 3 de cette série. J'espère rapidement revenir pour le 3ème et dernier épisode, pour parler des interfaces graphiques (les GUIs).

J'espère ne pas mettre 8 mois pour le sortir, cette fois ci ;)

En attendant, have fun !
