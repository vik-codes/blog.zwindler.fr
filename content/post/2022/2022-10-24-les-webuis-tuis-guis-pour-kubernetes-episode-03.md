---
title: Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 03
authors:
  - zwindler
type: post
date: 2022-10-24T06:00:00+02:00
url: /2022/10/24/webui-tui-gui-pour-kubernetes-episode-03/
image: /2022/10/looking-kubernetes-app.png
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

## Kubernetes, c’est dur 😭, fin ?

Dans les deux premiers épisodes, j'ai donc présenté les *WebUIs* puis les *Terminal User Interfaces*.

Reste maintenant un gros morceau : les *Graphical User Interfaces* !

Et vous allez voir qu'on a pas mal d'options, de ce côté là (pour l'instant j'en ai 5).

## Mirantis Lens (ex-Kontena Lens)

* **Site** : [k8slens.dev](https://k8slens.dev/)
* **Sources** : [github.com/lensapp/lens](https://github.com/lensapp/lens)

Impossible de parler des GUI pour Kubernetes sans parler de Lens... Après k9s qu'on a vu dans l'article précédent, c'est indubitablement l'outil le plus connu.

Bien que parfois un peu lourde, je pense aussi que c'est l'outil le plus complet et le plus simple pour démarrer dans Kubernetes.

L'outil gère bien entendu les CRDs, permet de naviguer rapidement d'un cluster à l'autre grace à des onglets sur la gauche.

![](/2022/10/lens-1.png)

On peut drill down dans les objets en cliquant dessus (Deployment, Pods, etc) et faire des actions spécifiques comme consulter les logs en temps réel, s'attacher sur un container ou faire un port forward en un clic.

L'installation se fait via des packages ou via les snap par exemple 

```bash
sudo snap install kontena-lens
```

Alors quel est le hic me demanderez-vous ?

Et bien depuis la version 6, Mirantis impose la création d'un compte sur la plateforme pour pouvoir utiliser l'outil, et depuis peu, a introduit un modèle payant dans l'outil (gratuit pour les individus, payant pour les entreprises, en gros).

Vous ne pouvez donc théoriquement plus l'utiliser dans un contexte pro sans passer à la caisse. Je ne dis pas que c'est mal, mais il faut en être conscient.

## OpenLens

Comme le code de Lens est opensource, il est toujours disponible et continue d'évoluer sur leur Github.

En théorie, il suffit juste ("yaka") de le compiler pour disposer toujours d'une app Lens sans licence.

Un utilisateur de Lens a créé un projet OpenLens ([cf cet article plus complet à ce sujet](https://blog.devgenius.io/is-it-time-to-migrate-from-lens-to-openlens-75496e5758d8)) mettant à disposition des binaires précompilés :

* [github.com/MuhammedKalkan/OpenLens](https://github.com/MuhammedKalkan/OpenLens)

Si vous avez la flemme de compiler Lens vous-même et que vous faites confiance à **MuhammedKalkan**, vous avez donc cette alternative...

## Kubenav

* **Site** : [kubenav.io](https://kubenav.io/)
* **Sources** : [github.com/kubenav/kubenav](https://github.com/kubenav/kubenav)

Dans les GUIs pour Kube, je dirais que ce qui différencie Kubenav des autres est le fait qu'il y ait une application iOS et Android (en plus de la version desktop).

> What could go wrong?

L'UI est plutôt clean même si je ne suis pas fan des grosses icônes mais c'est acceptable.

![](/2022/10/kubenav.png)

## Kubevious

* **Site** : [kubevious.io](https://kubevious.io/)
* **Sources**: [github.com/kubevious/kubevious](https://github.com/kubevious/kubevious)

![](/2022/10/kubevious.png)

Pas du tout fan de l'UI, très très bizarre je trouve avec des grosses tuiles et plein de couleurs. Mais bon, chacun ses gouts, j'imagine.

A priori, là aussi le modèle éco semble avoir changé récemment... cf [kubevious.io/pricing](https://kubevious.io/pricing). 

Bref... pas convaincu.

## aptakube

![](/2022/10/aptakube-logo.png)

* **Site** : [aptakube.com](https://aptakube.com/)

> A modern and lightweight Kubernetes desktop client to help you operate workloads on multiple clusters.

J'ai hésité à la mettre dans la liste car j'avais vraiment fait un focus sur les outils **open source** alors qu'**aptakube** ne l'est pas (c'est une *free public preview*).

Cependant, je trouve l'outil assez propre, et aussi le fait qu'il y ait des binaires de "petite taille" pour tous les OS et que ce soit une énième application electron.

Ca se sent d'ailleurs dans la réactivité, l'outil est hyper rapide et fluide, c'est très confortable. C'est bien rangé, on peut sélectionner plusieurs clusters à la fois (et on voit les pods de tous nos clusters d'un coup par exemple).

![](/2022/10/aptakube-1.png)
![](/2022/10/aptakube-2.png)

J'ai juste pas envie d'investir trop de temps dessus si l'outil devient au final payant (surtout si c'est **cher**). Attention donc.

## This is the end 🎶

En fait pas vraiment. A la base j'avais prévu de ne parler que des trois catégories qu'on a vues jusqu'à présent, mais j'ai encore une voire deux idées d'articles pour les interfaces pour Kubernetes.

On verra quand j'aurais le temps de rédiger tout ça.

Et en attendant, have fun ;).
