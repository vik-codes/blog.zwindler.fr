---
title: 'Je réessaye les sites statiques (Bloggrify) chez Clever Cloud'
authors:
  - zwindler
type: post
date: 2025-07-07T09:00:00+02:00
excerpt: "Retour d'expérience sur les nouvelles apps statiques de Clever Cloud après avoir essayé puis abandonné"
url: /2025/07/07/je-reessaye-les-sites-statiques-chez-clever/
image: /2025/07/9zdbra.jpg
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

Pour celles et ceux qui suivent mes péripéties d'hébergement de blog, vous savez que j'ai une relation compliquée (le fameux "it's complicated" sur Facebook) avec [Clever Cloud](https://www.clever-cloud.com/fr/). J'ai déjà écrit à ce sujet dans deux articles précédents :

* [Migration du blog sur Clever Cloud](/2023/12/30/its-migration-day-again/)
* [Planifier les posts avec Clever Cloud](/2024/01/29/planifier-les-posts-clever-cloud/)

Pour finalement abandonner Clever Cloud et revenir sur une VM IONOS que je gère moi-même (voir [Ça bouge encore sur le blog](/2025/01/15/ca-bouge-encore-sur-le-blog/)).

Mais depuis, Clever Cloud a ajouté les **apps statiques** à son catalogue. Plus besoin de passer par un runtime Apache + PHP, ce qui était effectivement un peu overkill pour un site Hugo statique (et pas compatible avec l'offre Pico, donc fallait prendre au minimum Nano à ~7€ par mois).

Du coup, je me suis dit : pourquoi ne pas retenter l'expérience ?

Comme Julien Wittouck m'a devancé de 3 semaines et a fait un article sur l'hébergement de sites statiques avec Hugo via ce nouveau type d'app chez Clever Cloud, [vous pouvez aller lire son post ici](https://codeka.io/2025/06/05/d%C3%A9ployer-des-applications-statiques-sur-clever-cloud/), je n'ai pas envie de faire la même chose.

Pour ce test, j'ai choisi d'utiliser un autre site que celui-ci : **50ndk.zwindler.fr**, qui me sert pour faire la promotion de mon livre.

Il est actuellement hébergé sur GitHub Pages et utilise le moteur [Bloggrify](https://bloggrify.io/) (un des projets d'[Hugo Lassiège](https://eventuallycoding.com/), quelqu'un que j'apprécie énormément dans l'écosystème tech français). 

Le principe est globalement le même qu'avec Hugo, à quelques petites différences près. C'est un site statique généré tout pareil, mais c'est Nuxt sous le capot et ça va nous être utile. Il y a quelques petites différences aussi depuis mon dernier test de 2023 que je ne manquerai pas de souligner.

Les sources du site sont disponibles ici si vous êtes curieux / curieuse :

* https://github.com/zwindler/50ndk

## Prérequis

On pourrait aller créer l'application dans l'UI. Normalement, les "tuiles" Static, Linux et VLang sont disponibles à tout le monde depuis le 4 juillet. J'ai un petit accès anticipé (merci David) mais je n'en ai pas beaucoup profité 🙃 (occupé avec le livre). Grosso modo c'est comme les autres types d'Apps chez Clever, vous ne serez pas perdus.

![](/2025/06/cleverl-nouvelles-tuiles.png)

Bon, en WebUI c'est bien mais c'est plus rigolo de le faire en CLI.

```
clever login
Opening https://console.clever-cloud.com/cli-oauth?cli_version=3.0.2&cli_token=xxxxxxxxxxxxx in your browser to log you in…
Login successful as Denis GERMAIN <denis@domain.org>
```

![](/2025/06/clever-login.png)

Euh, je vois 3.0.2 dans l'URL ??? Je ne suis pas à jour. Visiblement j'avais installé la CLI clever avec npm (je ne m'en souviens pas). Plus simple, [il y a aussi des dépôts .deb (ou brew, autre selon votre distribution)](https://www.clever-cloud.com/developers/doc/cli/install/).

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

## Configuration de l'app

Un petit `clever create` avec le type de l'app et c'est parti !

```
denis@coucou % clever create --type static                
✓ Application 50ndk successfully created!

  Type    ⬢ Static
  ID      app_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  Org ID  user_yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy
  Name    50ndk
  Zone    par

  Next steps:
  ! Commit your changes first:
    $ git add .
    $ git commit -m "My changes"

  → Run clever deploy to deploy your application
  → Manage your application at: https://console.clever-cloud.com/goto/app_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Note : si votre app est hébergée sur GitHub, vous pouvez rajouter aussi `--github OWNER/REPO` à la ligne de commande précédente. J'en parle plus tard, mais lisez tout avant de le faire.

Comme fin 2023, je vais avoir besoin de 2 machines différentes. Une qui va construire mon site statique, une qui va le servir. Et du coup, là comme je n'ai pas Apache, je peux avoir accès à une pico et économiser quelques euros à la fin de l'année :

```
$ clever scale --build-flavor M
App rescaled successfully

$ clever scale --flavor pico
App rescaled successfully
```

Dans mon test précédent avec Hugo+Clever, j'avais besoin de spécifier dans quel dossier le contenu statique doit être servi (et aussi quel dossier la machine qui construit doit partager avec la machine qui sert).

Dans le cas de Bloggrify, tout est dans .output/public. MAIS comme c'est du Nuxt, David m'a dit que je n'en avais pas besoin parce que Clever détecte automatiquement que c'est du Nuxt grâce au fichier `nuxt.config.ts` à la racine du projet.

Inutile donc de spécifier les variables CC_WEBROOT, CC_OVERRIDE_BUILDCACHE (pour pointer sur `.output/public`) CC_PRE_BUILD_HOOK et CC_BUILD_COMMAND (les commandes `npm`). 

Plutôt une bonne surprise :\).

## Déploiement de l'application

À partir de là, on peut essayer de faire un premier déploiement à la main. Pour rappel, soit on envoie un commit sur le remote spécial créé par Clever (cf le message lors de la commande `clever create`), mais je vais préférer utiliser la commande `clever deploy`, déjà disponible en 2023 lors de mon premier test, car je l'utiliserai pour automatiser le workflow plus tard.

```bash
dgermain@dgermain-mac 50ndk % clever deploy
🚀 Deploying 50ndk
   Application ID  app_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   Org ID          user_yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy

🔀 Git information
   ! App is brand new, no commits on remote yet
   Local commit    aaaaaa [will be deployed]
```

La première partie du processus va donc lancer une machine de taille M dans le but d'accélérer un peu le temps de construction :

```bash
🔄 Deployment progress
   → Pushing source code to Clever Cloud…
   ✓ Code pushed to Clever Cloud
   → Waiting for deployment to start…
   ✓ Deployment started (deployment_zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz)
   → Waiting for application logs…
   ...
```

Clever va détecter tout seul que j'ai du Nuxt, lancer un `npm install` pour installer les prérequis pour Bloggrify, puis le `npm run generate` pour générer le code HTML statique.

```bash
[...]
2025-07-07T10:23:47.847Z Deploying commit ID defc0be02d44ace246127e11a17d4f359262ccfb
2025-07-07T10:23:47.847Z Nuxt.js configuration file detected
2025-07-07T10:23:47.847Z Running build command: npm i && npm run generate && mv .output/public cc_static_autobuilt
[...]
2025-07-07T10:24:48.809Z [nitro] ℹ Initializing prerenderer
2025-07-07T10:24:52.533Z [nitro] ℹ Prerendering 8 initial routes with crawler
2025-07-07T10:24:52.598Z [nitro]   ├─ /robots.txt (17ms)
2025-07-07T10:24:52.841Z [nitro]   ├─ /200.html (296ms)
2025-07-07T10:24:52.842Z [nitro]   ├─ /404.html (297ms)
2025-07-07T10:24:52.964Z [nitro]   ├─ /api/search (415ms)
2025-07-07T10:24:52.965Z [nitro]   ├─ /sitemap.xml (417ms)
2025-07-07T10:24:52.965Z [nitro]   ├─ /rss.xml (416ms)
2025-07-07T10:24:53.105Z [nitro]   ├─ / (564ms)
[...]
```

Une fois le generate terminé, la machine de construction génère un artefact contenant notre site, et passe la main à la machine qui va servir le trafic :

```bash
2025-07-07T10:24:55.843Z ✔ You can now deploy .output/public to any static hosting!
2025-07-07T10:24:56.137Z Creating build cache archive…
2025-07-07T10:24:56.197Z build cache archive successfully created
2025-07-07T10:24:56.197Z No cron to setup
2025-07-07T10:24:56.213Z Uploading application build cache archive… file is 21M before compression.
2025-07-07T10:24:56.899Z 2025-07-07T10:24:56.899385Z  INFO multipart_upload_lib::uploader: Uploaded part=1
2025-07-07T10:24:57.041Z 2025-07-07T10:24:57.041879Z  INFO multipart_upload_lib::uploader: Completed the multipart upload
2025-07-07T10:24:57.350Z Done uploading build cache archive
2025-07-07T10:24:57.350Z Build succeeded in 1 minute and 14 seconds
```

11 secondes plus tard, le site de promotion de mon livre est déployé sur Clever Cloud

```bash
2025-07-07T10:25:28.425Z Serving static website from /cc_static_autobuilt
2025-07-07T10:25:28.425Z Launching 'static-web-server' on port 8080
2025-07-07T10:25:28.425Z No cron to setup
2025-07-07T10:25:28.425Z Successfully deployed in 0 minutes and 10 seconds

✓ Access your application: https://app-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.cleverapps.io
→ Manage your application: https://console.clever-cloud.com/goto/app_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

![](/2025/07/preview.png)

## Ajouter un domaine

Comme chez tous les PaaS, il est évidemment possible d'ajouter un domaine de manière à ce que les requêtes entrantes n'aient pas besoin de se faire sur l'URL en cleverapps.io

```
% clever domain add 50ndk.zwindler.fr
Your domain has been successfully saved
```

Une fois le FQDN associé, il est possible d'ajouter un CNAME chez votre gestionnaire de nom de domaine :

![](/2025/07/cname.png)

## Automatiser le `clever deploy`

Imaginons que je sois un fainéant ou que je n'aie pas envie d'installer clever CLI sur tous les postes où je travaille. Admettons que j'aie envie qu'une nouvelle version de mon site soit automatiquement déployée dès que je pousse un commit sur GitHub.

### deploy-to-clever-cloud

Dans l'article [Planifier les posts de mon blog Hugo sur Clever Cloud](/2024/01/29/planifier-les-posts-clever-cloud), j'avais exploré la piste d'un Cron pour redéployer régulièrement mon site, notamment pour que les posts publiés dans le futur soient postés "au bon moment".

J'avais aussi trouvé une GitHub Action tierce de quelqu'un ([47ng](https://github.com/47ng)) qui a l'air très bien mais que je ne connais pas : 

* https://github.com/marketplace/actions/deploy-to-clever-cloud

J'ai testé, elle fonctionne, mais j'étais moyen chaud à l'époque de déléguer mes creds à Github (les fameuses variables CLEVER_TOKEN et CLEVER_SECRET affichées lors du `clever login`), qui en retour les aurait injecté à cette "action".

Et ben ça tombe bien parce qu'il y a deux nouvelles pour répondre à ces problématiques.

### preview par PR

La première, c'est qu'il existe plusieurs façons d'automatiser les déploiements avec Clever Cloud. Je ne sais pas si elle existait à l'époque, mais en tout cas je l'ai trouvée aujourd'hui ;-P.

On peut faire des environnements de preview par PR (depuis 2024) :

* https://www.clever-cloud.com/developers/doc/ci-cd/github/
* https://github.com/marketplace/actions/clever-cloud-review-app-on-prs

Je ne vais pas dans cet article aborder cette action qui permet de déployer des apps en préview **par PR** car je n'en ai pas du tout le besoin pour ce site secondaire. Cela dit, si jamais j'ai une grosse mise à jour avec breaking changes, ça pourra valoir le coup de jeter un œil.

### Créer des tokens de CI

La seconde, c'est qu'il est possible de créer des tokens (là encore, je ne sais plus si c'était possible en 2023), qu'il sera possible de révoquer en cas de leak.

* https://www.clever-cloud.com/developers/api/howto/#request-the-api

Et avec ces tokens, on peut se faire sa propre CI  :

* https://www.clever-cloud.com/developers/doc/ci-cd/custom-scripts/

Note : j'ai cependant l'impression qu'il n'y a pas encore de scope sur le token. Donc en termes de sécu, c'est mieux car je peux les révoquer, mais s'il y a un leak, on a accès à tout mon compte, pour l'instant (sauf si j'ai mal compris).

### Déploiements depuis GitHub (ou GitLab)

Mais le plus simple ici, c'est d'utiliser une fonctionnalité de Clever qui existe depuis "toujours" mais dont j'ignorais l'existance : les déploiements via Github.

Si vous voulez utiliser cette fonctionnalité, il faudra par contre autoriser Clever Cloud à lister vos dépôts préalablement (ce qui peut être un problème pour vous), et vous ne pourrez plus pousser des commits avec `clever deploy` ou `git push` sur le git remote de clever (vous prendrez une erreur 401).

> Clever Cloud provides a GitHub integration to deploy any repository hosted on GitHub to Clever Cloud

On configure ça grâce au `--github` de tout à l'heure ! 

A partir du moment où c'est fait, il n'y a rien à faire... le rebuild sera déclenché dès que je pousserai un nouveau commit sur ma branche Github :)

```
commit 788465fb980c09e597872a3b510ac44fdaa27d48 (HEAD -> main, origin/main, origin/HEAD)
Author: Denis GERMAIN <dt.germain@gmail.com>
Date:   Fri Jul 4 16:31:11 2025 +0200

    test commit
```

![](/2025/07/test-commit.png)

![](/2025/07/link.png)

![](/2025/07/authorize.png)

Note : on peut spécifier quelle branche on veut envoyer en prod dans les paramètres de l'application :

![](/2025/07/github-main.png)

## Conclusion

Clever Cloud a énormément bougé ces derniers mois, avec beaucoup de nouvelles apps, de nouvelles fonctionnalités (la plus grosse étant Materia, ainsi que tout le travail autour de l'IA).

Les static apps (et Linux, et V) pourraient presque paraître anecdotiques, mais couplées aux autres améliorations (tokens, Grafana managé avec les stats), ce n'est pas le même produit qu'en 2023. 

C'est cool à voir :\)