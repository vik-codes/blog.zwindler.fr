---
title: 'Planifier les posts de mon blog Hugo sur Clever Cloud'
authors:
  - zwindler
type: post
date: 2024-01-29T06:00:00+02:00
url: /2024/01/29/planifier-les-posts-clever-cloud
image: /2022/05/clever-trott.jpg
categories:
  - Autohébergement
  - DIY
  - Logiciel
tags:
  - Clever Cloud
  - blog
  - hugo

---

## Suite de la migration

Fin décembre, [j'ai migré ce blog sur Clever Cloud](/2023/12/30/its-migration-day-again).

Cependant, David Legrand m'a fait remarquer que je n'avais plus de méthode pour planifier mes posts.

Depuis quelque temps, je poste à flux tendu donc ça ne m'a pas encore gêné (j'écris un post, je le rends public dans la foulée) mais c'est vrai qu'il me manque cette possibilité par rapport à précédent mon hébergement (une VM).

Cependant, il existe une solution sur Clever Cloud pour le faire. David en a d'ailleurs écrit un petit article sur son blog perso, adapté pour "Astro" son générateur de site statique.

Je vais donc faire pareil pour mon propre blog avec Hugo.

## Adaptations

Repartons donc d'où j'en étais au post précédent. Nous avons un blog avec Hugo qui se déploie quand on fait des `clever  deploy` (ou des commits sur le *git remote* de clever).

La première chose qu'on va devoir faire, c'est récupérer un token. En effet, c'est notre blog qui va déclencher de lui même les redéploiements, on va donc devoir lui donner de quoi s'authentifier.

Si vous n'avez pas de token sous la main, on peut en retrouver un en faisant `clever login` depuis un terminal, comme je l'expliquais dans l'article précédent.

![](/2023/12/clever-login.png)

Et on va rajouter le TOKEN dans la liste des variables d'environnement de notre app :

```bash
$ clever env set CC_SECRET "aaaaaaaaaaaaaaaaaaaaaaaaaa"
$ clever env set CC_TOKEN "aaaaaaaaaaaaaaaaaaaaaaaaaa"
```

A partir de là on va créer plusieurs fichiers. D'abord, un script qui va déclencher ce fameux redéploiement :

```bash
cat > clever_rebuild.sh << EOF
#!/bin/bash -l
clever link ${APP_ID}
clever restart --quiet --without-cache
EOF
chmod +x clever_rebuild.sh
```

Ensuite, je vais créer un fichier qui sera lu par clever-cloud et qui va déclencher ce redéploiement aux heures où je publie mes posts planifiés (le matin, un peu avant 9h) :

```bash
mkdir clevercloud
echo '["00 08 * * * $ROOT/clever_rebuild.sh"]' > clevercloud/cron.json
```

Attention aux petites blaguounettes de timezone. Comme tous sysadmins qui se respectent, les gens de clever utilisent le temps UTC sur leurs serveurs (moi aussi). Cependant, ça nécessite une petite gymnastique intellectuelle si jamais vous n'utilisez pas aussi le temps UTC dans votre tête pour planifier les posts ;-P.

Si tout se passe bien, vous verrez qu'il remarque qu'il y a un cron dans les logs :

```console
[...]
2024-01-25T14:05:21+01:00 Importing cronjobs
2024-01-25T14:05:21+01:00 Starting crons setup 
[...]
2024-01-25T14:06:05+01:00 (CRON) INFO (running with inotify support)
2024-01-25T14:06:05+01:00 (CRON) INFO (RANDOM_DELAY will be scaled with factor 89% if used.)
2024-01-25T14:06:05+01:00 (CRON) STARTUP (1.7.0) 
[...]
```

Tout dernier point que j'ai éludé jusqu'à présent, il est possible de redémarrer une application à partir d'un cache (pour que ça aille plus vite). Cependant, il est nécessaire d'indiquer à clever cloud quoi mettre dans ce cache. On va donc ajouter "/clevercloud/cron.json:/clever_rebuild.sh" à la variable existante :

```bash
# précédemment CC_OVERRIDE_BUILDCACHE "/public"
$ clever env set CC_OVERRIDE_BUILDCACHE "/public:/clevercloud/cron.json:/clever_rebuild.sh"
```

## (Fail to) hack the template

Si Hugo a bien un flag  pour permettre de "builder" les posts dont la date de sortie est postérieure à la date actuelle (`buildFuture`), mon thème "Stack" les affiche par défaut dans la liste des derniers posts ainsi que dans le flux RSS.

La solution la plus simple à ce problème est de laisser les paramètres par défaut, et d'attendre que la date de publication soit dépassée (idéalement juste avant le passage d'un cron) et le tour est joué.

Mais David a eu une autre approche qui m'a bien plu : ajouter une condition dans le template pour que le post ne soit pas visible dans la liste des posts, mais quand même publié.

Avantage : on peut consulter l'article à paraître, si on a le lien. Il se rajoute à la liste des articles de la homepage de lui-même lors du prochain rebuild, une fois la date dépassée.

Dans mon thème, la page d'accueil qui liste les posts [est définie ici dans le code](https://github.com/CaiJimmy/hugo-theme-stack/blob/master/layouts/index.html) :

```diff
 {{ define "main" }}
     {{ $pages := where .Site.RegularPages "Type" "in" .Site.Params.mainSections }}
     {{ $notHidden := where .Site.RegularPages "Params.hidden" "!=" true }}
+   {{ $notFuture := where .Site.RegularPages ".Date" "le" now }}
+   {{ $filtered := ($pages | intersect $notHidden | intersect $notFuture) }}
-    {{ $filtered := ($pages | intersect $notHidden) }}
     {{ $pag := .Paginate ($filtered) }} 

     <section class="article-list">
         {{ range $index, $element := $pag.Pages }}
             {{ partial "article-list/default" . }}
         {{ end }}
     </section>

     {{- partial "pagination.html" . -}}
     {{- partial "footer/footer" . -}}
 {{ end }}
[...]
```

En théorie, ça fonctionne. Sauf que je n'ai pas réussi à le faire marcher avec le thème "Stack" que j'utilise sur le site (j'ai réussi avec un thème "blank").

C'est peut-être lié à [un problème d'appel multiple à la fonction `.Paginate()`](https://github.com/gohugoio/hugo/issues/11916#issuecomment-1910462590), qui "cache" la pagination la première fois qu'elle est lancée.

> If you call .Paginator or .Paginate multiple times on the same page, you should ensure all the calls are identical. Once either .Paginator or .Paginate is called while generating a page, its result is cached, and any subsequent similar call will reuse the cached result. This means that any such calls which do not match the first one will not behave as written.
> 
> https://gohugo.io/templates/pagination/

Même en partant du principe que j'arrive à le faire marcher, reste encore la problématique du flux RSS, comme j'ai pu le remarquer avec Seboss666 ;-\)

![](/2024/01/seboss666.png)

J'ai donc laissé tomber cette idée. De toute façon, je n'avais jamais vraiment eu besoin jusqu'à présent puisque je n'y avais pas pensé ;-P.

J'ai donc, comme avant, mes posts "planifiés" qui sont visible le matin de leur publication et c'est déjà bien comme ça (pour l'instant).

Have fun !
