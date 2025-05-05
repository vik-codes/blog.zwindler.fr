---
title: 'Migration du blog sur Clever Cloud'
authors:
  - zwindler
type: post
date: 2023-12-30T16:00:00+02:00
url: /2023/12/30/its-migration-day-again
image: /2022/05/clever-trott.jpg
categories:
  - autohebergement
  - DIY
  - Logiciel
tags:
  - Clever Cloud
  - blog
  - hugo
  - vercel
  - froggit

---

## It’s ~~groundhog~~ migration day, again

Tous les 6 mois environ, une mouche me pique.

Après avoir migré un nombre incalculable de fois mon blog wordpress à droite / à gauche, puis [migré sur Hugo](/2019/06/10/comment-migrer-de-wordpress-a-hugo/), autohébergé, utilisé du managé chez [vercel](https://vercel.com/), chez [froggit](https://froggit.fr/), autohébergé encore...

J'ai décidé (un peu sur un coup de tête) de migrer le blog chez les copain⋅es de chez Clever Cloud.

Et je vous montre comment j'ai fait.

## Prérequis

Je pars du principe que vous avez comme moi un dépôt git / site hugo déjà fonctionnel. Et je ne vais pas non plus détailler la procédure pour activer un compte chez [Clever Cloud](https://www.clever-cloud.com/).

Je commence par installer la CLI, les "clever tools". Pour les installer, il nous faut `npm`. J'utilise rarement `npm`, mais quand je le fais, j'utilise un autre tool, `volta` ([volta.sh](https://volta.sh/)), qui va me permettre de choisir la version dont j'ai besoin

![](/2023/12/idontalways.jpg)

```
$ curl https://get.volta.sh | bash
```

Une fois installé, je peux télécharger la version qui m'intéresse de npm (18 par exemple, la version minimum pour installer les clever tools)

```
$ volta install node@20            
success: installed and set node@20.10.0 (with npm@10.2.3) as default
```

Je peux donc maintenant installer les clever tools :

```
npm i -g clever-tools
```

Puis me loguer depuis mon terminal

```
$ clever login
Opening https://console.clever-cloud.com/cli-oauth?cli_version=3.0.2&cli_token=xxxxxxxxxxxxxxxxx in your browser to log you in…
Login successful as [unspecified name] <xxx.yyy@example.org>
```

![](/2023/12/clever-login.png)

Si jamais comme indiqué sur l'écran de login, vous avez besoin d'un token + secret (pour de la CI par exemple), sachez qu'ils sont stockés dans un fichier `~/.config/clever-cloud/clever-tools.json`

![](/2024/01/clever-token.png)

Denier prérequis, je vais ajouter une [clé SSH dans ma console clever](https://console.clever-cloud.com/users/me/ssh-keys)

![](/2023/12/add-ssh.png)

## Création de l'application

A partir de maintenant, je suis capable d’interagir avec clever cloud en CLI. Je vais commencer par créer l'application qui va héberger mon site statique :

```
$ clever create -t static-apache blog-zwindler
Your application has been successfully created!
```

Clever Cloud offre la possibilité de dissocier la taille des instances pour la partie run et la partie build. Je vais donc créer l'instance la plus petite possible pour le run (une nano), et une plus pêchue (une M) pour le build, histoire d'être plus réactif sur les commits de modifications :

```
$ clever scale --build-flavor M
App rescaled successfully

$ clever scale --flavor nano
App rescaled successfully
```

Je peux ensuite configurer quelques variables d'environnement (trouvées sur la doc de clever cloud) pour générer mon site statique avec l'image **static-apache** de clever.

```bash
$ clever env set CC_WEBROOT "/public"
$ clever env set CC_OVERRIDE_BUILDCACHE "/public"
$ clever env set CC_PRE_BUILD_HOOK "bash setup_hugo.sh"
$ clever env set CC_POST_BUILD_HOOK "hugo --minify --gc"
```

Pour finir, on crée le script `setup_hugo.sh` à la racine de notre site statique Hugo :

```bash
cat > setup_hugo.sh << EOF
HUGO_VERSION="0.121.1"
HUGO_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
DEST_BIN="${HOME}/.local/bin"
FILENAME="hugo.tar.gz"

# Download Hugo Extended and place it in a folder in the $PATH
curl --create-dirs -s -L -o ${DEST_BIN}/${FILENAME} ${HUGO_URL}
cd ${DEST_BIN}
tar xvf ${FILENAME} -C ${DEST_BIN}
rm ${FILENAME}
EOF
```

On commit les fichiers créés : 

```
git add .
git commit -m "Add clever"
```

## Déployer notre code

A partir de là, on a notre instance qui est prête à démarrer, dès qu'elle aura reçu du code. 

![](/2023/12/app-created.png)

Ici, clever cloud attend un push sur un dépôt git.

![](/2023/12/blog-zwindler-clever.png)

La méthode la plus "simple" pour pousser du code sur clever à ce moment-là est donc de créer un dépôt distance (remote) :

```
git remote add clever git+ssh://git@push-n3-par-clevercloud-customers.services.clever-cloud.com/app_xxxxxxxxxxxxxxxxxxxx.git
git push clever master
```

Le "problème" dans mon cas est que (pour l'instant), le nom de la branche n'est pas configurable et est forcément "master", ce qui ne m'arrange pas puisque je bosse habituellement sur "main".

```
remote: Error: You tried to push to a custom branch. This is not allowed.
remote: error: hook declined to update refs/heads/main
To git+ssh://push-n3-par-clevercloud-customers.services.clever-cloud.com/app_xxxxxxxxxxxxxxxxxxxx.git
 ! [remote rejected] main -> main (hook declined)
error: impossible de pousser des références vers 'git+ssh://push-n3-par-clevercloud-customers.services.clever-cloud.com/app_xxxxxxxxxxxxxxxxxxxx.git'
```

2 manières de contourner ce problème :
* soit je force la branche master sur le remote clever dans git
* soit j'utilise la CLI `clever deploy`

Dans un premier temps, je me contente de feinter git :

```
git push clever main:master
Énumération des objets: 30, fait.
Décompte des objets: 100% (24/24), fait.
Compression par delta en utilisant jusqu'à 16 fils d'exécution
Compression des objets: 100% (16/16), fait.
Écriture des objets: 100% (16/16), 287.70 Kio | 31.97 Mio/s, fait.
Total 16 (delta 8), réutilisés 0 (delta 0), réutilisés du pack 0
remote: [SUCCESS] The application has successfully been queued for redeploy.
To git+ssh://push-n3-par-clevercloud-customers.services.clever-cloud.com/app_xxxxxxxxxxxxxxxxxxxx.git
   54ff42f..960ce62  main -> master
```

On termine par la configuration du nom de domaine :

```
$ clever domain add blog.zwindler.fr
Your domain has been successfully saved
```

Il ne nous reste plus qu'à mettre à jour le CNAME dans notre DNS (*domain.par.clever-cloud.com.* dans mon cas, mais la bonne configuration est visible dans l'onglet **Domain names** de l'application)

![](/2023/12/dns.png)

## Et avec `clever deploy` ?

Eh bien en fait, c'est "encore plus simple". Il me suffit juste de faire une modif, de commit

```
git add .
git commit -m "test clever deploy"
```

Puis de simplement lancer la commande `clever deploy`. 

```
$ clever deploy
Remote git head commit   is c4e3c283585cafff44f07c7d78d860065318cd68
Current deployed commit  is c4e3c283585cafff44f07c7d78d860065318cd68
New local commit to push is 0b3536a9f1d61178a99f6238831ccb4197989ddf (from refs/heads/main)
Pushing source code to Clever Cloud…
Your source code has been pushed to Clever Cloud.
Waiting for deployment to start…
Deployment started (deployment_b5f841ff-a233-4bb4-8a16-f618ee69ef28)
Waiting for application logs…
[...]
```

Quelle est donc cette diablerie ?

En réalité, les informations nécessaires pour pousser le code sont en réalité simplement dans un fichier `.clever.json` qui a été créé à la racine lorsqu'on a lancé la commande `clever create -t static-apache blog-zwindler` au tout début du tuto.

```json
{
  "apps": [
    {
      "app_id": "app_xxxxxxxxxxxxxxxxxxx",
      "org_id": "user_yyyyyyyyyyyyyyyyyyyyy",
      "deploy_url": "https://push-n3-par-clevercloud-customers.services.clever-cloud.com/xxxxxxxxxxxxxxxxxxxx.git",
      "name": "blog-zwindler",
      "alias": "blog-zwindler"
    }
  ]
}
```

Évidemment, je ne vais pas m'amuser à faire un `clever login` / `clever deploy` à chaque fois que je veux pousser une modif sur mon blog. Et c'est là où nos CLEVER_TOKEN / CLEVER_SECRET seront utiles !

## Conclusion

Après quelques heures d'usage, je peux dire que **dans le cadre de l'hébergement de mon blog**, j'aime bien utiliser Clever Cloud.

Qu'on soit bien clair, c'est pour mon cas d'usage et comparé à :

* Vercel : l'expérience utilisateur est incroyable sur Vercel, mais j'ai toujours été un peu gêné par le côté "boite noire" (on a pas accès à beaucoup plus que des variables d'environnement). Et je ne parle pas des problématiques de privacy...
* Deux serveurs physiques avec Proxmox VE en cluster étendu chez One-provider : à l'inverse héberger moi-même mon blog sur une machine (en vrai, 2) louée résout les problèmes de privacy et j'ai la main sur toute la stack, mais ça me demande de la maintenance pour des perfs minables. Ok, c'est pas cher, mais j'ai 2 à 3 minutes de rebuild avec le CPU à 100% sur mon Atom de 2010 chez Online...
* Froggit : c'était du Gitlab + Gitlab pages et c'était très cool car c'est plus flexible que Vercel, mais j'avais dû passer un peu de temps à configurer la pipeline et leur faire pousser les murs pour que mon site rentre (les 400 Mo de médias n'étaient pas supportés au début et les transferts Gitlab => Gitlab pages étaient un peu longs).

Avec Clever, mes 450 articles (3600 pages générées, 400 Mo de média) sont très rapidement générés, transférés, et enfin mis à disposition (< 1 minute tout compris, plus rapide que les 3 solutions précédentes). 

Le tout avec une disponibilité/fiabilité sans aucun doute bien meilleure que ce que j'aurais pu faire moi-même en auto hébergé avec un coût similaire, et en très peu de temps.

J'ai passé beaucoup plus de temps à écrire cet article qu'à migrer le blog, puisque la doc est bien écrite, le site est intuitif, et je n'ai été bloqué à aucun moment.

Il me reste encore à optimiser l'étape de déploiement, pour qu'un commit/push sur mon dépôt git déclenche automatiquement un déploiement côté clever. Objectivement, ça ne devrait pas prendre trop longtemps (github action / gitlab CI)...

Et par contre, ça manque d'IPv6 natif, screugneugneu !
