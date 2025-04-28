---
title: 'Comment j’ai enfin trouvé une excuse pour installer Docker à la maison (Cozy Cloud)'
authors:
  - zwindler
type: post
date: 2015-09-19T10:30:30+00:00
url: /2015/09/19/comment-jai-enfin-trouve-une-excuse-pour-installer-docker-a-la-maison-cozy-cloud/
image: /2015/09/docker.png
categories:
  - Autohébergement
  - Logiciel
tags:
  - container
  - conteneur
  - Cozy
  - debian
  - Docker
  - lsb core
  - multiuser
  - No LSB modules are available
  - Ubuntu

---
## Docker c’est « hype »

Ok, j’ai probablement 2 ans de retard sur le fait que Docker soit « hype » dans la communauté IT.

Les conteneurs sont donc à la mode.

Surtout chez ceux qui oublient que les conteneurs, c’est une techno archi-ancienne, remise au gout du jour avec « le cloud computing » (lui même un concept remis au gout du jour : comme tout ce qui est _hype_ ;-)).

Mais ce n’est pas parce que c’est « à la mode » que je vais décider de ne pas tester. Car après tout, Docker a quand même de gros point forts.

Il me fallait juste que je me trouve une excuse et me convaincre d’allouer du temps pour tester Docker. Et je l’ai trouvée : Cozy Cloud (voir [mon article précédent](/2015/09/08/decouverte-de-cozy-cloud-personnel/)).

## La simplicité

Enfonçons des portes ouvertes. La grande force des outils comme Docker aujourd’hui, c’est la simplicité de mise en place et d’utilisation. Sincèrement je ne m’attendais pas à ce que ce soit simple à ce point là.

Je suis parti de la machine que j’avais déjà utilisée pour installer ma première instance de Cozy Cloud, donc un Debian 8 from scratch ou quasiment.

La première chose à faire pour l’installer sur Debian 8 est d’activer dans les dépôts le « backports ». A priori Docker n’a pas été accepté dans Debian 8 pour des raisons de sécurités non résolues au moment de la sortie ? Vous aurez plus de détails dans la documentation officielle pour Debian : [Docker Debian](https://docs.docker.com/engine/install/debian/)

```
sudo vi /etc/apt/sources.list #ajouter la ligne pour activer les backports
   deb http://http.debian.net/debian jessie-backports main

sudo apt-get update
sudo apt-get install docker.io
```


Et c’est tout. Pas de configuration post installation : ça fonctionne. Si.

Pour s’en convaincre, on peut télécharger le conteneur hello-world, qui vous imprimera à l’écran un petit message de diagnostic et quelques pistes pour aller plus loin.

```
sudo docker run --rm hello-world
```


## Application à Cozy

Cool, Docker fonctionne. Mais appliquons le maintenant à un cas d’usage utile.

Cozy, c’est aussi cool que Docker. Aux détails près que :

  * Une instance Cozy est mono utilisateur, impossible de l’utiliser pour une même famille par exemple.
  * Tout ce qui est stocké (notamment les fichiers et les photos) est stocké dans Cozy... impossible pour l’instant de pointer sur un espace partagé (type NFS/SMB) de votre NAS par exemple.

Les deux problèmes ont été remontés plusieurs fois et on peut régler le premier avec Docker ; [voir ici (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20161008090232/https://forum.cozy.io/t/more-than-one-user/97).

En regardant la documentation d’installation de Cozy Cloud via Docker, on se rend compte de la puissance de Docker en terme de simplification. Déployer Cozy Cloud, ce n’est guère plus compliqué qu’une ligne de commande.

```
sudo docker pull cozy/full
```


Voilà comment s’économiser les quelques lignes de l’installation classique, déjà relativement simple, pour installer une instance cozy dans un conteneur Docker. Reste à jouer un peu avec les arguments pour que nos instances écoutent sur des ports différents ([voir la documentation officielle][3])

Mais ça ne résout pas encore totalement le problème du déploiement simplifié lorsqu’on a plusieurs utilisateurs pour une même machine. 

C’est pourquoi un développeur de Cozy a mis en ligne un script qui automatise le déploiement multiple d’instances Cozy sur un même serveur Docker :

* [forum.cozy.io/t/cozy-deploy-a-tool-to-deploy-and-manage-multiple-cozy-instances/516 (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20161008082323/https://forum.cozy.io/t/cozy-deploy-a-tool-to-deploy-and-manage-multiple-cozy-instances/516)

Pour vous éviter une lecture de tout le post, le script en question est disponible sur Github à [cette adresse][4].

### Installation du script

```
wget -qO- https://raw.github.com/cozy-labs/cozy-deploy/master/install.sh | sudo bash #Installation
```


Si comme moi vous obtenez l’erreur suivant, c’est qu’il vous manque le package lsb-core. Installez le et relancez le script.

```
No LSB modules are available. 

sudo apt-get install lsb-core
wget -qO- https://raw.github.com/cozy-labs/cozy-deploy/master/install.sh | sudo bash
```


### Déploiement des instances et administration

```
cozy-deploy deploy cozy1.example.org #déploiement d'un premier conteneur
cozy-deploy deploy cozy2.example.org #et de deux !
cozy-deploy list #affichage de tous les conteneurs déployés
                              DOMAIN    RUNNING      PORT
                   cozy2.example.org       true     49003
                   cozy1.example.org       true     49002
cozy-deploy status
  cozy2.example.org
    postfix:  up
    couch:  up
    controller:  up
    data-system:  up
    home:  up
    proxy:  up
    index:  up

  cozy1.example.org
    postfix:  up
    couch:  up
    controller:  up
    data-system:  up
    home:  up
    proxy:  up
    index:  up
```


Vous disposez d’instances distinctes en écoute sur des ports distincts mais accessibles via leur nom complet à l’aide de **nginx** (qui sert ici uniquement de proxy pour rediriger les requêtes vers le bon port et donc le bon conteneur).

Le tout sans effort : Problem solved.

Il ne reste plus que cette histoire de stockage partagé (encore un petit effort, Cozy!).

 [3]: https://docs.cozy.io/en/howTos/dev/runCozyDocker/
 [4]: https://github.com/cozy-labs/cozy-deploy
