---
title: Automatiser son site Hugo sans Github Action ou Vercel
authors:
  - zwindler
type: post
date: 2023-08-01T06:00:00+02:00
url: /2023/08/01/automatiser-hugo-sans-github-action
image: /2021/11/wordpress-to-hugo.png
categories:
  - Autohébergement
tags:
  - git
  - hugo
  - go
  - github
  - webhook

---

## Contexte

Fin 2021, après plus de 10 ans à écrire des articles de blog tech sur Wordpress, je prenais la décision radicale d'arrêter de maintenir cette bouse infâme (je mâche mes mots) et de partir sur des articles rédigés en markdown et un site statique avec Hugo.

Au tout début, je gérais le blog moi-même mais assez vite j'en ai eu assez de devoir aller rebuild le blog à chaque modification. J'ai rapidement mis un cron qui faisait des `git pull` régulièrement, mais on ne va pas se mentir, c'est assez crado...

Finalement, on m'a rapidement pointé que je devrais arrêter de m'embêter et utiliser [Netlify](https://www.netlify.com/) ou [Vercel](https://vercel.com/).

J'étais pas super chaud, car ça allait à l'encontre de ma volonté d'auto héberger mon contenu et de limiter l'impact sur la vie privée de mes lecteurs, mais finalement, l'expérience utilisateur sur Vercel était tellement bonne que j'avais craqué. Je ferai peut-être un article là-dessus d'ailleurs, c'est la première fois que j'ai compris (ressenti) l'intérêt d'un PaaS.

Mais aujourd'hui, je reviens sur cette décision et j'essaye de voir ce qu'il est nécessaire de mettre en place pour disposer soi-même d'un site hugo qui se refresh tout seul dès qu'un commit arrive sur le dépôt git, sans utiliser de plateforme type Vercel ni d'outils types Github action+pages.

## Prérequis

Je pars du principe que vous avez déjà un site statique généré avec Hugo. Si ce n'est pas le cas je vous invite à aller lire mes articles précédents sur le sujet ([premiers pas](/2019/06/10/comment-migrer-de-wordpress-a-hugo/), [stats avec matomo](/2019/06/18/mes-stats-de-visites-hugo-sans-google-analytics-avec-matomo/),  [migration wordpress vers hugo](/2021/11/22/jai-enfin-migre-de-wordpress-a-hugo-partie-1/)).

Vous avez donc un serveur Linux sur lequel vous avez la main pour installer des choses et un dépôt git (sous Github dans mon cas, mais on peut probablement adapter l'article pour autre chose).

Hugo étant d'abord un générateur de site statique, je vais utiliser nginx en frontal pour servir les fichiers qu'on va générer. Jusqu'à il y a peu, l'usage du mode "server" de hugo n'était d'ailleurs pas conseillé en production (mais ça ne semble plus être le cas, je n'ai pas vu de warning dernièrement ?).

```bash
apt install nginx git
```

## Déposer les sources sur le serveur

Dans mon cas, les sources de mon blog ne sont pas disponibles publiquement (parce que j'ai pas envie, c'est comme ça ¯\\\_(ツ)\_/¯).

Il faut donc préalablement se loguer en SSH avec git avant de pouvoir *pull* le code. Et comme je n'ai pas envie de laisser ma clé privée sur le serveur qui va héberger mon blog, il faut que j'utilise une autre clé.

Dans mon cas, Github, qui héberge le code markdown de mon blog, a une notion de "deploy keys", qui servent justement pour ça :

* [docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys)

Je vais donc créer une clé sur le serveur qui héberge le blog :

```bash
ssh-keygen -t ed25519 -C "xxx@xxx.tld"
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/toto/.ssh/id_ed25519): 
[...]
```

Et je la copie dans le dossier de *www-data* (l'utilisateur nginx sous Ubuntu)

```bash
chmod 600 /root/.ssh/id_ed25519
sudo mkdir /var/www/.ssh/
sudo cp ~/.ssh/id_ed25519* /var/www/.ssh/
chown www-data: /var/www/.ssh/*
```

Une fois la clé créée, on doit l'ajouter dans Github.com. Je ne lui donne que les droits "read only" puisque le but c'est seulement de récupérer le code et générer le site statique, pas qu'on puisse éditer le code (*cé pour la sécuritay*).

![](/2023/07/github-deploy-keys2.png)

Je retourne ensuite sur mon serveur et j'essaye de télécharger les sources et le thème:

```bash
cd /usr/share/nginx/html
GIT_SSH_COMMAND='ssh -i /var/www/.ssh/id_ed25519 -o IdentitiesOnly=yes' git clone git@github.com:zwindler/blog.example.org.git
cd blog.example.org/themes
git submodule add -f https://github.com/CaiJimmy/hugo-theme-stack.git
chown -R www-data: /usr/share/nginx/html/blog.example.org
```

## Webhook

Pour réagir à l'arrivée d'un nouveau commit sur notre dépôt source, on va utiliser 2 choses : 
* un projet qui s'appelle sobrement "Webhook". 
* configurer un webhook dans github, qui va envoyer l'info que quelque chose est arrivé sur le dépôt (mais on verra ça plus tard)

Revenons à "Webhook" dans un premier temps :

> webhook is a lightweight configurable tool written in Go, that allows you to easily create HTTP endpoints (hooks) on your server, which you can use to execute configured commands. You can also pass data from the HTTP request (such as headers, payload or query variables) to your commands. webhook also allows you to specify rules which have to be satisfied in order for the hook to be triggered.

On récupère la dernière release et déposer le binaire sur notre serveur :

* [github.com/adnanh/webhook/releases/tag/2.8.1](https://github.com/adnanh/webhook/releases/tag/2.8.1)

```bash
export VERSION="2.8.1"
wget https://github.com/adnanh/webhook/releases/download/${VERSION}/webhook-linux-amd64.tar.gz

tar -xvf webhook*.tar.gz

sudo mv webhook-linux-amd64/webhook /usr/local/bin
rm -rf webhook-linux-amd64*

webhook --version
```

Une fois que c'est fait, on va générer une chaîne aléatoire qui va nous servir de "secret" qui sera partagé entre le binaire *webhook* qui tourne sur notre serveur et un *webhook* sur Github.com :

```bash
WHSECRET=`uuidgen | base64`
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa==
```

On crée un fichier de configuration `hook.json` pour déclarer nos webhooks

```json
mkdir /etc/webhook
cat > /etc/webhook/hook.json << EOF
[
    {
        "id": "redeploy",
        "execute-command": "/usr/share/nginx/html/blog.example.org/blog_refresh.sh",
        "command-working-directory": "/usr/share/nginx/html/blog.example.org",
        "trigger-rule":
        {
            "match":
            {
                "type": "payload-hmac-sha1",
                "secret": "$WHSECRET",
                "parameter":
                {
                    "source": "header",
                    "name": "X-Hub-Signature"
                }
            }
        }
    }
]
EOF
```

Ici, quand le serveur va recevoir l'url /hooks/redeploy, on va lancer le script `/usr/share/nginx/html/blog.example.org/blog_refresh.sh` depuis le répertoire /usr/share/nginx/html/blog.example.org.

Charge à nous de créer un script qui va soit :
* récupérer les sources (git pull)
* relancer un build

Voilà à quoi pourrait ressembler le script `blog_refresh.sh` :

```bash
#!/bin/bash
cd /usr/share/nginx/html/blog.example.org

#pull latest version
GIT_SSH_COMMAND='ssh -i /var/www/.ssh/id_ed25519 -o IdentitiesOnly=yes' git clone git@github.com:zwindler/blog.example.org.git

#refresh theme submodule
git submodule init
git submodule update

#rebuild (fire and forget)
hugo --minify --gc &
```

On va ensuite créer un service systemd qui va lancer le binaire *webhook* en tâche de fond

```bash
cat > /etc/systemd/system/webhook.service << EOF
[Unit]
Description=Simple Golang webhook server
ConditionPathExists=/usr/local/bin/webhook
After=network.target

[Service]
User=www-data
Group=www-data
Type=simple
WorkingDirectory=/usr/share/nginx/html/blog.example.org
ExecStart=/usr/local/bin/webhook -ip 127.0.0.1 -hooks /etc/webhook/hook.json -verbose
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl enable webhook
systemctl start webhook
```

Côté Github.com, on crée le webhook qui va contacter le serveur webhook de la façon suivante :

![](/2023/07/github-webhook.png)

On a maintenant un serveur web qui est en attente de certains événements webhooks et qui va lancer un script si jamais l'URL de webhook est appelée par Github.com.

## Configuration nginx

Il reste maintenant toute la configuration de notre nginx en frontal à faire. En partant du principe qu'on vient juste de faire l'installation du package, on commence par supprimer le fichier `/etc/nginx/sites-enabled/default`, et on en crée un nouveau :

```bash
rm /etc/nginx/sites-enabled/default

cat > /etc/nginx/sites-available/blog.example.org.conf << EOF
# Root configuration
server {
  listen 80;
  server_name blog.example.org;

  location /hooks/ {
    proxy_pass http://127.0.0.1:9000/hooks/;
  }

  error_page 404 /404.html;

  location / {
    root /usr/share/nginx/html/blog.example.org/public;
    index index.html;
  }
}
EOF
ln -s /etc/nginx/sites-{available,enabled}/blog.example.org.conf
```

On vérifie que la configuration est valide et si oui on redémarre nginx

```bash
nginx -t
systemctl reload nginx
```

A partir de maintenant, toutes les URLs qui arriveront jusqu'à votre serveur en /hooks seront redirigées sur le logiciel "webhook" et le reste ira sur votre site statique (/usr/share/nginx/html/blog.example.org/public).

```console
curl https://blog.example.org/hooks/redeploy -L
Hook rules were not satisfied.% 
```

Ici le hook renvoie une erreur, car on a pas envoyé le token secret mais c'est probable que ça fonctionne. Toutes les autres pages renvoient bien une page du blog :

```console
curl https://blog.example.org/
<!DOCTYPE html>
<html lang="fr-fr" dir="ltr">
    <head>
	<meta name="generator" content="Hugo 0.115.1"><meta charset='utf-8'>
[...]
```

On peut maintenant envoyer des commits et voir si ça déclenche des rebuilds de notre blog. Ou alors, on peut récupérer un push précédent et cliquer sur "Redeliver" si on veut trigger un rebuild du blog.

![](/2023/07/github-redelivery.png)

```console
root@hugo:~# systemctl status webhook
* webhook.service - Simple Golang webhook server
     Loaded: loaded (/etc/systemd/system/webhook.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2023-07-31 07:34:35 UTC; 33s ago
   Main PID: 900109 (webhook)
      Tasks: 15 (limit: 4574)
     Memory: 240.4M
        CPU: 45.504s
     CGroup: /system.slice/webhook.service
             |-900109 /usr/local/bin/webhook -ip 127.0.0.1 -hooks /etc/webhook/hook.json -verbose
             `-900161 hugo --minify --gc

Jul 31 07:34:35 hugo webhook[900109]: [webhook] 2023/07/31 07:34:35 attempting to load hooks from /etc/webhook/hook.json
Jul 31 07:34:35 hugo webhook[900109]: [webhook] 2023/07/31 07:34:35 found 1 hook(s) in file
Jul 31 07:34:35 hugo webhook[900109]: [webhook] 2023/07/31 07:34:35         loaded: redeploy
Jul 31 07:34:35 hugo webhook[900109]: [webhook] 2023/07/31 07:34:35 serving hooks on http://127.0.0.1:9000/hooks/{id}
Jul 31 07:34:35 hugo webhook[900109]: [webhook] 2023/07/31 07:34:35 os signal watcher ready
Jul 31 07:34:41 hugo webhook[900109]: [webhook] 2023/07/31 07:34:41 [f089a0] incoming HTTP POST request from 127.0.0.1:43258
Jul 31 07:34:41 hugo webhook[900109]: [webhook] 2023/07/31 07:34:41 [f089a0] redeploy got matched
Jul 31 07:34:41 hugo webhook[900109]: [webhook] 2023/07/31 07:34:41 [f089a0] redeploy hook triggered successfully
Jul 31 07:34:41 hugo webhook[900109]: [webhook] 2023/07/31 07:34:41 [f089a0] 200 | 0 B | 1.151688ms | 127.0.0.1:9000 | POST /hooks/redeploy
Jul 31 07:34:41 hugo webhook[900109]: [webhook] 2023/07/31 07:34:41 [f089a0] executing /usr/share/nginx/html/blog.example.org/blog_refresh.sh
[...]
Jul 31 07:37:28 hugo webhook[900109]:   Pages            | 3572
Jul 31 07:37:28 hugo webhook[900109]:   Paginator pages  |  516
Jul 31 07:37:28 hugo webhook[900109]:   Non-page files   |   14
Jul 31 07:37:28 hugo webhook[900109]:   Static files     | 2282
Jul 31 07:37:28 hugo webhook[900109]:   Processed images |    2
Jul 31 07:37:28 hugo webhook[900109]:   Aliases          | 1563
Jul 31 07:37:28 hugo webhook[900109]:   Sitemaps         |    1
Jul 31 07:37:28 hugo webhook[900109]:   Cleaned          |    0
Jul 31 07:37:28 hugo webhook[900109]: Total in 166131 ms
Jul 31 07:37:28 hugo webhook[900109]: [webhook] 2023/07/31 07:37:28 [f089a0] finished handling redeploy
```

## Conclusion

Si vous êtes à l'aise avec Linux et nginx, ces quelques manipulations sont assez rapides à faire, il n'y a rien de vraiment complexe. 

Cependant, ça demande à l'usage un peu d'administration et de vouloir mettre les mains dans le cambouis (avoir une VM à gérer). Je ne peux reprocher à personne de préférer l'utilisation de Github/Gitlab pages, couplé à de Github actions/Gitlab runners, voire de tout déléguer à Vercel/Netlify...

Mais j'avais envie de reprendre la main sur le hosting de mon blog (avec tous les inconvénients que ça va avoir en termes de maintien en condition opérationnelle), notamment pour disposer à nouveau de l'IPv6 (perdue lors du passage à Vercel) et une navigation sur mon blog plus respectueuse de votre vie privée (pas que j'aie pas confiance en Vercel, mais bon...).

Et c'est en revanche beaucoup plus simple que d'héberger son propre serveur Gitlab + Gitlab runners + Gitlab pages ;-\).

Donc, pour mon usage, ça fait le taf :\)

## Ressources additionnelles

* [ansonvandoren.com/posts/deploy-hugo-from-github/](https://ansonvandoren.com/posts/deploy-hugo-from-github/)
* [magefan.com/blog/configure-webhooks-in-github](https://magefan.com/blog/configure-webhooks-in-github)
