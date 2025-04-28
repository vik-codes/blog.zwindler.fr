---
title: 'Mon PeerTube sur Ubuntu 20.04'
authors:
  - zwindler
type: post
date: 2021-12-06T06:00:00+00:00
excerpt: "Installation de mon instance PeerTube sur une VM Ubuntu 20.04 en moins d'une heure tout compris"
url: /2021/12/06/mon-peertube-sur-ubuntu-20-04
image: /2021/12/peertube.png
categories:
  - Autohébergement
tags:
  - PeerTube
  - ubuntu
  - peer-to-peer

---

## Pourquoi Peertube ?

Il y a plus de 15 ans (autour de 2003-2004), je m'adonnais abondamment à ma passion du moment : l'écriture, le tournage et le montage de vidéos humoristiques. J'ai fais, avec des copains, une grosse dizaine de sketch pendant une très courte période. Un genre de "Youtubeur" avant l'heure, on dira.

A l'époque, quand on voulait partager en ligne des vidéos et surtout diffuser du contenu, il n'y avait pas 50 choix. On pouvait héberger soit même les vidéos sur un serveur HTTP ou FTP, mais je n'avais (du haut de mes 16 ans) pas encore l'infrastructure nécessaire pour le faire (et encore moins la ligne télécom). Du coup, je gravais mes productions sur DVDs et les projetais à un peu tout le monde dès que j'en avais l'occasion. Pas super pratique...

C'est à peu près à ce moment là que Youtube et Dailymotion ont été créés (début 2005) et j'ai sauté sur l'occasion pour utiliser ces services qui me permettaient de diffuser à toutes mes connaissances ces vidéos sans effort. 

Je n'ai malheureusement plus le temps de faire le clown comme je le faisais avant (en vrai ça m'arrive encore mais 🤫) donc pendant longtemps je me suis contenté de ces services. Cependant, je ne suis pas insensible à l'hégémonie de Google sur les services en ligne. C'est pour ça qu'en tant qu'ancien utilisateur de ce type de solutions, j'ai vu d'un très bon oeil le [crowfunding en 2018 de Framasoft](https://www.kisskissbankbank.com/fr/projects/peertube-a-free-and-federated-video-platform) dans le but de créer un logiciel permettant d'héberger soit même des plateformes de streaming vidéo.

> PeerTube, proposé par Framasoft, est l'alternative libre et décentralisée aux plateformes vidéos, qui vous donne accès à plus de 400 000 vidéos proposées par 60 000 utilisateur⋅ices et visionnées plus de 15 millions de fois

Je ne me suis jamais trop plus intéressé que ça, n'en ayant plus vraiment l'usage. Jusqu'à ce que je décide de rapatrier au même endroit toutes les vidéos enregistrées de tous mes talks, sur un coup de tête, un lundi soir.

## Fonctionnalités

Ce que je trouve bien avec Framasoft (ainsi que d'autres outils / projets) c'est qu'ils ont bien compris qu'ils ne battraient pas les big techs en proposant un clone libre ou open source des outils du marché. Il faut proposer aux utilisateurs un logiciel avec les fonctionnalités minimales similaires certes, MAIS, aussi proposé autre chose (en plus, ou différent).

C'est totalement ce qui est fait avec PeerTube. Au delà d'une simple plateforme de streaming qu'on peut auto-héberger (et donc permettre de contribuer à un web décentralisé), c'est surtout une plateforme de streaming de vidéos en mode peer-to-peer.

Un des challenges quand on fait du streaming en ligne, a fortiori quand il s'agit de vidéo, c'est qu'il est nécessaire de disposer d'une bande passante colossale pour permettre à des centaines, milliers, voire plus, d'utilisateurs de regarder plusieurs vidéos en non synchrone en même temps (pas en multicast comme l'IPTV). C'est d'ailleurs un des terrains sur lesquels se battent les ISP contre Youtube et maintenant Netflix : un portion très significative de la bande passante totale d'Internet est consommée par ces services.

La solution "maline" est donc de permettre aux instances PeerTube de se fédérer entre elles afficher du contenu de plusieurs plateformes sur une seule, mais aussi aux clients connectés eux même de participer à l'envoie des "chunks" de vidéos à d'autres utilisateurs (en peer-to-peer). On peut ainsi héberger PeerTube sur des machines assez modestes et que ça marche quand même.

Au delà de ça, les avantages de ce type de solutions par rapport à un hébergeur central sont :
* le code open source de la solution
* l'absence de traçage publicitaire
* l'absence de mécanismes de censure automatisée des vidéos 

Qu'est ce que je rigole quand je vois certains vidéastes, open source bashers notoires, cracher sur PeerTube et vénérer le sacro-saint Youtube, qui les châtie autant qu'il les nourri...
## Installer PeerTube

Bref, je venais de télécharger l'ensemble des replays de mes confs, j'avais installé une VM Ubuntu 20.04 vierge avec 2 vCPU, 4 Go de RAM et 100 Go de stockage plutôt véloce. En théorie, c'est suffisant si j'en crois cette [page dédiée sizing](https://joinpeertube.org/faq#should-i-have-a-big-server-to-run-PeerTube) de la doc officielle.

La documentation d'installation est elle disponible sur le site [docs.joinpeertube.org](https://docs.joinpeertube.org/install-any-os). Au fil des années, j'en ai vu des docs d'install. C'est d'ailleurs une des raisons d'être du blog, certains softs étant très déficitaires de ce côté et nécessitant des explications complémentaires pour le profane.

Ce n'est pas du tout le cas ici. C'est sans aucun doute une des docs les plus claires, propres, détaillées que j'aie été amené de voir au fil des ans. D'autant qu'elle est rédigée en français et en anglais, et se paie le luxe d'être proposée pour une large gamme d'OS. Un grand BRAVO.

Bon... Elle est claire, que j'ai sauté un peu vite l'introduction 🤦‍♂️. J'ai donc évidemment commencé par louper l'encart **Dependencies** (oups) qui pointe vers tout ce qu'on doit installer AVANT de commencer la doc d'installation elle même...

Tout ce qui est dépendances/prérequis est donc [détaillé ici](https://docs.joinpeertube.org/dependencies).

Je vous conseille plutôt de suivre la doc d'installation plutôt que ce billet si vous voulez installer un PeerTube. Mais pour montrer que c'est **vraiment** simple, je vous "dump" les commandes que moi j'ai lancées, dans mon contexte personnel.

```bash
apt update
apt upgrade

apt-get install curl sudo unzip vim
apt install python3-dev python-is-python3
apt install certbot nginx ffmpeg postgresql postgresql-contrib openssl g++ make redis-server git cron wget
```

Une fois tout ce beau petit monde installé, on démarre redis (pas encore bien compris à quoi il servait) et postgresql.

```bash
sudo systemctl start redis postgresql
```

Pour l'installation de la version 14 de `nodeJS`, la documentation nous laisse un peu nous débrouiller, mais grosso modo on trouve [tout ce qu'il faut ici](https://github.com/nodesource/distributions/blob/master/README.md#deb).

```bash
curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs
```

> Grrrr, un `curl | sudo bash` en 2021...

Ensuite, rebelote pour `yarn`, il faut aller chercher la [dernière version disponible sur Github](https://github.com/yarnpkg/yarn/releases/tag/v1.22.17) et pas celle installable avec `apt` sinon ça ne fonctionnera pas (car il existe 2 versions majeures avec 2 CLI totalement différentes).

```bash
wget https://github.com/yarnpkg/yarn/releases/download/v1.22.17/yarn_1.22.17_all.deb
apt install ./yarn_1.22.17_all.deb
```

## Préparation de PeerTube

Maintenant qu'on a installé tous les prérequis, il faut paramétrer l'utilisateur unix PeerTube :

```bash
mkdir /var/www/peertube -p
useradd -m -d /var/www/peertube -s /bin/bash -p peertube peertube
chown peertube: /var/www/peertube
passwd peertube
sudo -u peertube mkdir config storage versions
sudo -u peertube chmod 750 config/
```

Puis celui de la base de données postgresql :

```bash
pg_ctlcluster 12 main start

cd /var/www/peertube
sudo -u postgres createuser -P peertube
sudo -u postgres psql -c "CREATE EXTENSION pg_trgm;" peertube_prod
sudo -u postgres psql -c "CREATE EXTENSION unaccent;" peertube_prod
```

## Installation de PeerTube lui même

Enfin, on peut télécharger PeerTube lui même et l'installer

```bash
VERSION=$(curl -s https://api.github.com/repos/chocobozzz/peertube/releases/latest | grep tag_name | cut -d '"' -f 4) && echo "Latest Peertube version is $VERSION"
sudo -u peertube wget -q "https://github.com/Chocobozzz/PeerTube/releases/download/${VERSION}/peertube-${VERSION}.zip"
sudo -u peertube unzip -q peertube-${VERSION}.zip && sudo -u peertube rm peertube-${VERSION}.zip
sudo -u peertube ln -s versions/peertube-${VERSION} ./peertube-latest
cd ./peertube-latest && sudo -H -u peertube yarn install --production --pure-lockfile
```

Puis configurer le service

```bash
sudo -u peertube cp peertube-latest/config/default.yaml config/default.yaml
sudo -u peertube cp peertube-latest/config/production.yaml.example config/production.yaml
```

Les variables permettant de définir les informations de votre DB (mot de passe notamment), hostname, etc, sont à modifier dans le fichier `config/production.yaml`.

Et enfin, on peut tout démarrer :

```
sudo cp /var/www/peertube/peertube-latest/support/systemd/peertube.service /etc/systemd/system/
sudo systemctl enable peertube
sudo systemctl start peertube
```

A partir de là, vous avez une instance PeerTube disponible en local uniquement sur le port 9000. Je ne vais pas détailler cette partie, vous avez compris le principe ; on va copier le fichier de configuration nginx d'exemple fourni par PeerTube et utiliser nginx+certbot comme point d'entrée / reverse proxy HTTPS de notre instance.

Vous voyez, j'ai pas menti quand je dis qu'on peut installer un PeerTube en moins d'une heure. Franchement, je pense qu'en 10 minutes, c'est jouable. D'autant qu'il existe des gens qui ont écrit des roles ansible sur galaxy pour l'automatiser ([ici](https://github.com/wiseflat/ansible-peertube) et là (github.com/kotovalexarian/ansible-role-peertube, lien mort, pas testé).

Une fois tout correctement configuré, vous pourrez vous connecter en tant qu'admin et créer vos premiers utilisateurs.

## Et ça ressemble à quoi ?

Si vous voulez voir mon instance (et pourquoi pas regarder un de mes replays), elle est [disponible ici](https://peertube.zwindler.fr).

L'interface est hyper agréable et très intuitive (encore BRAVO). On est pas perdus, l'ajout des utilisateurs est simple à réaliser.

![](/2021/12/peertube_admin_1.png)

On peut ensuite les configurer, comme leur ajouter des quotas par exemple.

![](/2021/12/peertube_admin_2.png)

Une fois connecté avec l'utilisateur (il n'est pas recommandé d'utiliser l'utilisateur d'admin pour publier des vidéos), on se connecte avec et on peut commencer à créer des "chaînes", configurer des valeurs par défaut pour nos vidéos, etc.

![](/2021/12/peertube_admin_3.png)

L'interface d'upload est elle aussi hyper intuitive, on sélectionne le fichier, on configure la description et les catégorie et hop, ça upload. 

![](/2021/12/peertube_upload.png)

Une fois la vidéo publiée, elle est ajoutée dans une file de transcodage pour être adaptée au streaming (ça prend environ 1 CPU). Même en envoyant 9 vidéos d'un coup, je n'ai pas mis à genou le serveur (c'est bien géré).

Ensuite, une fois la vidéo transcodée, elle devient visible et tout un chacun peu la lire, s'abonner à votre flux, etc.

![](/2021/12/peertube_video.png)

Quant au player, que ce soit sur un navigateur ou depuis un smartphone, tout est bien intégré et fonctionne de manière fluide.

![](/2021/12/peertube_player.png)

## Et demain ?

C'est amusant que j'aie décidé de travailler sur PeerTube 3.4 pile cette semaine, car entre le moment où j'ai installé l'instance et le moment où j'ai rédigé l'article, Framasoft a publié un billet de blog pour annoncer la disponibilité de la prochaine majeure (version 4 rc1) de Peertube.

Le [billet en question est ici](https://framablog.org/2021/11/30/peertube-v4-prenez-le-pouvoir-pour-presenter-vos-videos/). Grosso modo, après de gros ajouts de features techniques (les lives dispos en 3.0), les features que la v4 inclue sont surtout à destination des vidéastes, pour faciliter l'administration des chaines disposant d'un grand nombre de vidéos.

Ca ne m'intéresse pas forcément mais ça montre la vigueur du projet qui ajoute des fonctionnalités au fur et à mesure.

Pour moi c'est un carton plein, ce projet est une grande réussite de la part de Framasoft (et Chocobozzz), le logiciel est abouti dans tous les domaines. 

J'ai envie de soutenir ce genre de projets, même si je ne suis pas sûr de vraiment l'utiliser au quotidien et j'ai donc fais un don (certes symbolique) à Framasoft pour que ce genre d'initiatives perdurent. Si vous trouvez vous aussi ce projet utile et que vous en avez les moyens, [je vous invite à faire de même](https://soutenir.framasoft.org/fr/).
## Sources additionnelles

  * [Site officiel de PeerTube](https://joinpeertube.org/)
  * [Github du projet](https://github.com/Chocobozzz/PeerTube)
  * [Soutenir Framasoft](https://framasoft.org/fr/#soutenir)
  * [FAQ Sizing](https://joinpeertube.org/faq#should-i-have-a-big-server-to-run-peertube)
  * [Mon instance PeerTube personnelle](https://peertube.zwindler.fr)
