---
title: 'Je réessaye les sites statiques chez Clever Cloud'
authors:
  - zwindler
type: post
date: 2025-06-29T18:00:00+02:00
draft: true
excerpt: "Retour d'expérience sur les nouvelles apps statiques de Clever Cloud après avoir abandonné leur offre précédente"
url: /2025/06/29/je-reessaye-les-sites-statiques-chez-clever/
image: /2025/06/clever-cloud-static.png
categories:
  - autohebergement
  - Divers
tags:
  - Clever Cloud
  - Hugo
  - Site statique
  - Hébergement
  - Bloggrify

---

## Introduction

Pour celles et ceux qui suivent mes péripéties d'hébergement de blog, vous savez que j'ai une relation compliquée avec [Clever Cloud](https://www.clever-cloud.com/fr/). J'ai déjà écrit à ce sujet dans deux articles précédents :

* [Migration du blog sur Clever Cloud](/2023/12/30/its-migration-day-again/)
* [Planifier les posts avec Clever Cloud](/2024/01/29/planifier-les-posts-clever-cloud/)

Pour finalement abandonner Clever Cloud et revenir sur une VM IONOS que je gère moi-même (voir [Ça bouge encore sur le blog](/2025/01/15/ca-bouge-encore-sur-le-blog/)).

Mais depuis, Clever Cloud a ajouté les **apps statiques** à son catalogue. Plus besoin de passer par un runtime Apache + PHP, ce qui était effectivement un peu overkill pour un site Hugo statique (et pas compatible avec l'offre Pico, donc fallait prendre au minimum Nano à ~7€ par mois).

Du coup, je me suis dit : pourquoi ne pas retenter l'expérience ?

Pour ce test, j'ai choisi d'utiliser un autre site que celui-ci : **50ndk.zwindler.fr**, qui me sert pour faire la promotion de mon livre. Il est actuellement hébergé sur GitHub Pages et utilise le moteur [Bloggrify](https://bloggrify.io/) (un des projets d'[Hugo Lassiège](https://eventuallycoding.com/), quelqu'un que j'apprécie énormément dans l'écosystème tech français).

Note : Julien Wittouck m'a devancé de 3 semaines et à fait un article sur l'hébergement de site statiques avec Hugo via ce nouveau type d'app chez clever cloud, [vous pouvez aller lire son post ici](https://codeka.io/2025/06/05/d%C3%A9ployer-des-applications-statiques-sur-clever-cloud/). Dans ce post, je vais essayer de montrer les petites différences entre la méthode de 2023 et aujourd'hui (il y en a quelques unes).

## Création de l'app

On pourrait aller créer l'application dans l'UI. Pour l'instant, la "tuile" Static et VLang ne sont pas encore disponibles pour tout le monde. J'ai un petit accès anticipé (merci David). Mais grosso modo c'est comme les autres type d'Apps chez clever, vous ne serez pas perdu.

![](/2025/06/cleverl-nouvelles-tuiles.png)

Bon, en WebUI c'est bien mais c'est plus rigolo de le faire en CLI.

```
clever login
Opening https://console.clever-cloud.com/cli-oauth?cli_version=3.0.2&cli_token=xxxxxxxxxxxxx in your browser to log you in…
Login successful as Denis GERMAIN <zwindl3r@protonmail.com>
```

![](/2025/06/clever-login.png)

eeeeuh, je vois 3.0.2 dans l'URL ??? Je ne suis pas à jour là. Visiblement j'avais installé la CLI clever avec npm (je m'en souviens pas). Plus simple, il y a aussi des dépôts .deb (ou autre selon votre distrib).

```
clever version
3.0.2
   ╭─────────────────────────────────────────╮
   │                                         │
   │    Update available 3.0.2 → 3.13.1      │
   │   Run npm i -g clever-tools to update   │
   │                                         │
   ╰─────────────────────────────────────────╯
```

Un petit `npm i -g clever-tools` et ça va mieux :)

```
$ clever version
3.13.1
```
