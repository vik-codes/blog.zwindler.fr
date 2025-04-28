---
title: 'Cryptpad : le cloud zero knowledge'
authors:
  - zwindler
type: post
date: 2020-06-29T06:35:00+00:00
excerpt: "Présentation et procédure d'installation de Cryptpad, le cloud collaboratif zero knowledge développé par les équipes de XWiki"
url: /2020/06/29/cryptpad-le-cloud-zero-knowledge/
image: /2020/06/cryptpad-logo.png
categories:
  - Autohébergement
tags:
  - anonyme
  - cryptpad
  - nodeJS
  - privacy
  - travail collaboratif
  - Xwiki
  - zero knowledge

---

Je vous ai déjà beaucoup parlé d’un projet que j’aime beaucoup, [XWiki](/recherche/?keyword=xwiki) (si vous n’êtes pas encore gavé que j’en parle tout le temps, allez jeter un œil, c’est vraiment cool ce qu’ils font). Eh bien, il y a quelques années, des membres de l’équipe se sont lancé dans un projet en parallèle nommé [CryptPad](https://github.com/xwiki-labs/cryptpad).

![](/2020/06/cryptpad1.png)


Et plutôt que mal décrire ce que ça fait, voilà comment eux présentent leur projet :

> CryptPad est une alternative respectant la vie privée aux outils office et aux services cloud populaires. Tout le contenu stocké dans CryptPad est chiffré avant d’être envoyé, ce qui signifie que personne ne peut accéder à vos données à moins que vous ne leur donniez les clés (même pas nous).

Grosso modo, l’idée est de fournir une liste d’outils en ligne, collaboratifs :
  
* Traitement de texte
* Éditeur de code (texte avec coloration syntaxique)
* Présentation (slides)
* Tableur
* Sondage en ligne
* Kanban
* Whiteboard
      
  
C’est très similaire à ce qu’on pourrait le faire avec un [Nextcloud](/2020/04/27/ma-plateforme-de-travail-collaboratif-nextcloud-en-5-minutes/), mais avec deux différences majeures :
  
* tout est chiffré, même l’admin n’y a pas accès.
* l’outil est prévu pour être utilisé avec inscription, mais sans inscription (et les pads "anonymes" peuvent être a posteriori rattachés à un compte)
      


## Dans quel cas c’est intéressant
  
  
On pourrait se dire que finalement le projet est concurrent des solutions collaboratives comme Nextcloud que je cite juste avant. Cependant je pense que la cible n’est pas la même.

Dans le cas où j’héberge moi-même mes données et celle de ma famille, je n’ai pas forcément besoin que les données soient chiffrées (encore que ça se discute, surtout si je les héberge sur un serveur que je loue). Il y a un lien de confiance implicite (enfin j’espère que c’est le cas pour vous). Et je n’ai pas non plus besoin de pads anonymes. Je suis logué en permanence sur ma plateforme.

En revanche, dans le cas où j’utilise/loue un service d’outils collaboratifs administré par quelqu’un d’autre (tout le monde n’a pas envie d’héberger soit-même ses services, comme moi), le stockage chiffré non accessible de l’admin prend tout son sens. Que ce soit pour un usage pro ou un usage perso d’ailleurs, je ne le connais pas forcément, j’ai donc du mal à faire confiance.

Pour un hébergement de ce genre de services reposant sur le respect de la vie privée, on peut se diriger vers les [CHATONS](https://chatons.org/).

En théorie, la charte des [CHATONS](https://chatons.org/charte) impose aux fournisseurs de contenus de respecter les libertés des utilisateurs et notamment de ne pas exploiter leurs données. Mais je serai quand même vachement plus rassuré en sachant que même l’admin du CHATONS n’a pas accès à mes données, car moi seul en détient la clé.


![](https://www.chatons.org/sites/default/files/uploads/logo_chatons.png)

* [](https://chatons.org/)

Je pense donc que CryptPad est un super outil pour les gens qui veulent fournir un service de type cloud éthique (comme les CHATONS) tout en garantissant un certaine confiance sur la sûreté des données stockée sur le cloud en question.

## Assez bavassé

Vous êtes convaincu ? Vous voulez jeter un œil ?

Si vous voulez faire un test de l’outil, sachez qu’il existe une instance officielle portée par le projet lui-même. L’inscription est ouverte à tous et vous obtiendrez un Cryptpad disposant de toutes les fonctionnalités, limité à un stockage de 50 Mo (1 Go pendant la période COVID, en geste de soutien à tous ceux qui ont dû trouver des solutions alternatives et vertueuses pendant le confinement). Ça se passe sur [cryptpad.fr](https://cryptpad.fr/).

## Et si je veux l’installer ?
  
  
Vous vous doutez bien que je n’allais pas faire un article sur Cryptpad sans vous donner la procédure d’installation du biniou ;)

Pour cette procédure, je me suis basé sur la documentation officielle, [disponible ici](https://github.com/xwiki-labs/cryptpad/wiki/Installation-guide), et que j’ai adapté à mon cas (à savoir une VM avec Ubuntu 18.04).

On commence bien évidemment par mettre à jour le système... Et on installe quelques prérequis.


```
sudo apt update
sudo apt upgrade
sudo apt install git curl
```



## Configuration préalable
  
  
Pour éviter de donner les droits root à CryptPad, j’ai créé un utilisateur cryptpad` (hyper original).


```
sudo useradd -m -d /opt/cryptpad -s /bin/bash cryptpad
```



Du coup, si vous n’avez pas les droits root, ça marchera quand même (avec l’utilisateur non-root que vous avez).

Cryptpad repose sur un serveur NodeJS. Sauf que la version par défaut disponible sur les répos Ubuntu est antédiluvienne. C’est pour cette raison que la documentation officielle conseille d’utiliser NVM pour installer une version à jour de NodeJS.

Pour ceux qui comme moi, n’y connaissent rien à NodeJS, voilà la doc pour [installer nvm](https://github.com/nvm-sh/nvm/blob/master/README.md#installing-and-updating).


```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
```



Bon... faire confiance à un curl | bash trouvé sur Internet... ça craint du boudin en termes de sécu, il faudra que je regarde comment faire plus propre :/.

Une fois installé, vous pouvez tester la commande nvm` de la façon suivante, et elle doit renvoyer "nvm" :


```
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

command -v nvm
#renvoie "nvm" si tout fonctionne correctement
```



## Installation
  
  
OK. Maintenant on a tous nos prérequis, on peut récupérer les sources de Cryptpad, et commencer à installer le tout.


```
git clone https://github.com/xwiki-labs/cryptpad.git cryptpad && cd cryptpad
nvm install node
npm install -g bower
npm install 
bower install
```



A partir de là, on a un NodeJS à jour dans le dossier de nos sources, avec les dépendances (npm install).

## Configuration
  
  
Les gens de Cryptpad ont été assez sympa pour fournir des exemples de fichiers de configuration si votre Cryptpad n’est pas directement accessible sur Internet (c’est probablement mieux ;-p). Par exemple, voilà [celui pour nginx](https://github.com/xwiki-labs/cryptpad/blob/master/docs/example.nginx.conf).

> In a production instance this should be available ONLY over HTTPS using the default port for HTTPS (443) ie. https://cryptpad.fr. In such a case this should be handled by NGINX, as documented in cryptpad/docs/example.nginx.conf (see the $main_domain variable)

Dans mon cas, j’ai justement un nginx qui me sert de reverse proxy et qui est sur une autre machine. Si comme moi, votre reverse proxy n’est pas sur la même machine, vous voudrez probablement changer l’adresse d’écoute (par défaut localhost uniquement) dans la configuration de Cryptpad. Vous trouverez plus de détails là dessus sur [cette page de la documentation](https://github.com/xwiki-labs/cryptpad/wiki/Reverse-proxy).

Une fois votre reverse configuré, vous pouvez maintenat vous attaquer à la configuration de Cryptpad. Ici c’est relativement trivial, ça marche en changeant assez peu de valeurs.


```
cd config
cp config.example.js config.js
vi config.js
[...]
  httpSafeOrigin: "https://cryptpad.example.org", //décommenter la ligne httpSafeOrigin et mettre l URL finale
  httpAddress: '192.168.1.100',//décommenter et changer la httpAddress si votre reverse proxy n est pas sur la même machine
  adminEmail: 'admin@example.org', //changer l email de l admin
```



## Démarrer Cryptpad
  
  
Je suis presque triste, c’est DÉJÀ fini. C’est pour ça que pour une fois, je n’ai pas pris le temps de créer un playbook Ansible => c’est beaucoup trop simple, ahaha ;-).

[Edit]Heureusement que je n’ai pas fais de playbook, il y en a déjà un [ici](https://github.com/systemli/ansible-role-cryptpad), c’est écrit en gros dans la doc officielle de Cryptpad ;)

On démarre le serveur simplement avec un node server` dans le dossier des sources.


```
cd ..
node server &
```



Une fois le serveur démarré pour la première fois, il faudra s’y connecter, créer un compte, puis mettre à jour la configuration avec le paramètre adminKeys dans config.js`


```
vi config.js
[...]
adminKeys: [
        //"https://my.example.org/user/#/1/cryptpad-user1/YZgXQxKR0Rcb6r6CmxHPdAGLVludrAF2lEnkbx1vVOo=",
    ],
```



Une fois fait, redémarrer une dernière fois nodejs.

> And voilà

![](/2020/06/cryptpad.png)

> Un exemple de service, ici la mire pour la création d’un tableau blanc


## Démarrage automatique
  
  
Si vous avez un accès root à la machine qui héberge Cryptpad, vous allez sûrement vouloir créer un service pour démarrer/arrêter facilement (et automatiquement) votre Cryptpad.

Pour ce faire, on commence par récupérer le path de node qui va bien (càd, celle installée par nvm)


```
cryptpad@crypt:~$ which node
/opt/cryptpad/.nvm/versions/node/v13.11.0/bin/node
```



Et on crée le petit fichier systemd` qui va bien (n’oubliez pas de mettre le bon path dans NODEPATH):


```
# NODEPATH=/opt/cryptpad/.nvm/versions/node/v13.11.0/bin/node
# cat > /etc/systemd/system/cryptpad.service << EOF
[Unit]
Description=CryptPad

[Service]
ExecStart=$NODEPATH server
WorkingDirectory=/opt/cryptpad/cryptpad
Restart=always
RestartSec=10
# Output to syslog
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=cryptpad
User=cryptpad
Group=cryptpad
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# systemctl start cryptpad
# systemctl status cryptpad.service
* cryptpad.service - CryptPad
   Loaded: loaded (/etc/systemd/system/cryptpad.service; disabled; vendor preset: enabled)
   Active: active (running) since Thu 2020-06-25 13:08:29 UTC; 2s ago
 Main PID: 1248 (node)
    Tasks: 11 (limit: 4915)
   CGroup: /system.slice/cryptpad.service
           `-1248 /opt/cryptpad/.nvm/versions/node/v13.11.0/bin/node server

Jun 25 13:08:29 crypt systemd[1]: Started CryptPad.
Jun 25 13:08:30 crypt cryptpad[1248]: FRESH MODE ENABLED
Jun 25 13:08:30 crypt cryptpad[1248]: Cryptpad is customizable, see customize.dist/readme.md for details
Jun 25 13:08:30 crypt cryptpad[1248]: [2020-06-25T13:08:30.826Z] server available http://192.168.10.209:3000

# systemctl enable cryptpad
Created symlink /etc/systemd/system/multi-user.target.wants/cryptpad.service -> /etc/systemd/system/cryptpad.service.
```

## Administrer le serveur
  
  
Une fois le service systemd` configuré, vous aurez donc une instance fonctionnelle. Dans l’hypothèse où vous auriez besoin de débuguer un problème, les logs sont collectés par syslog, et donc visibles dans /var/log/syslog dans Ubuntu.


```
Jun 25 13:08:30 crypt cryptpad[1248]: FRESH MODE ENABLED
Jun 25 13:08:30 crypt cryptpad[1248]: Cryptpad is customizable, see customize.dist/readme.md for details
Jun 25 13:08:30 crypt cryptpad[1248]: [2020-06-25T13:08:30.826Z] server available http://192.168.10.209:3000
```



Et en cas de maintenance (backup, restauration, migration), sachez que le stockage persistant est contenu par défaut dans le sous dossier datastore de votre installation de cryptpad.

Vous pouvez changer cette valeur, présente dans votre config/config.js (filePath pour le datastore, archivePath pour les archives temporaires après suppression)


```
filePath: './datastore/',
    /*  CryptPad offers the ability to archive data for a configurable period before deleting it, allowing a means of recovering data in the event that it was deleted accidentally. µ/
    archivePath: './data/archive',
```

## Le mot de la fin
  
Si le projet vous intéresse, je vous encourage à aller voir le site officiel de [CryptPad](https://cryptpad.fr/) et à tester sans compte ou en créant un compte gratuit.

Si vous pouvez les soutenir, n’hésitez pas à faire souscrire à une offre premium chez eux, ou à faire un don au projet si vous installé votre propre instance.
