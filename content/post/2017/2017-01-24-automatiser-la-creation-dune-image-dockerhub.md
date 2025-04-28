---
title: 'Automatiser la création d’une image Dockerhub'
authors:
  - zwindler
type: post
date: 2017-01-24T13:00:53+00:00
url: /2017/01/24/automatiser-la-creation-dune-image-dockerhub/
image: /2017/01/dockerhub.png
categories:
tags:
  - automated build
  - Docker
  - Dockerhub
  - git
  - github
  - webhooks

---
## Créer un automated build sur le Dockerhub

Ça fait quelques semaines maintenant que j’ai mis à disposition [sur le Dockerhub ma première image Docker](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/). Sans aller jusqu’à dire qu’elle a déplacé les foules, je suis assez content de voir que je ne suis pas le seul à l’utiliser avec une 100aine de « pull », même si sur le segment des images préconfigurées pour XWiki, les builds de Hellyna et Lavadiablo sont bien plus souvent téléchargées. Et c’était sans compter sur [l’image Docker officielle de XWiki](https://hub.docker.com/_/xwiki/) qui est sortie juste avant que je ne publie cet article !

Mais aussi auto-satisfait que je suis, je suis forcé de le reconnaître, cette image Docker pêche d’un défaut de jeunesse : la mise à disposition d’une nouvelle version nécessite :

  * Que je modifie (et éventuellement que je le push sur Github) mon code sur mon repository git
  * Que je la build moi même à partir du code

```
docker build -t zwindler/xwiki-tomcat8:latest . 
```


  * Et une fois l’image sur mon Docker registry local, que je lance la commande

```
docker push zwindler/xwiki-tomcat
```


Mais, vous l’aurez deviné, il y a mieux ;-)

Une fonctionnalité de Dockerhub vous permet de créer une image que vous poussez manuellement ou une image dont la création est **automatique**. On peut distinguer ces deux types d’images par la mention **automated build** sous le nom de celle ci.

![](/2017/01/dockerhub_automated_build.png)

## Comment en profiter ?

Tout commence d’abord par renseigner quelques informations dans votre profil. Dans les propriétés de votre compte, il y a un menu « Linked Accounts & Services ».

Ce menu vous permet de lier le Dockerhub avec un ou plusieurs comptes Github/Bitbucket via une autorisation de type OAuth.

![](/2017/01/dockerhub_profile_2.png)

Au delà de simplement lier les deux comptes, Dockerhub paramètre vos dépôts git et y ajoute des services (webhooks préconfigurés) permettant de prévenir automatiquement Dockerhub de la présence de code mise à jour sur GitHub.

![](/2017/01/dockerhub_profile_3.png)

![](/2017/01/dockerhub_profile_5.png)

> On autorise l’accès en lecture/écriture sur le compte. On peut le mettre en lecture seule mais il faudra paramétrer les webhooks à la main !

![](/2017/01/dockerhub12.png)

> Présence du service dans les paramètres du projet Github

## Créer son premier automated build

Maintenant que les permissions sont bien passées entre Github et Dockerhub, on peut créer son image automatique.

![](/2017/01/dockerhub_profile_6.png)

Ici j’ai sélectionné mon compte Github, puis le projet qui contient mon projet **xwiki-tomcat**.

![](/2017/01/dockerhub_profile_7.png)

La suite de la création de l’image est similaire à la création d’une image « non automatique ». On donne un nom à l’image ainsi qu’une petite description et on valide en cliquant sur **create**.

![](/2017/01/dockerhub_profile_8.png)

Dans mon cas, ça n’a pas fonctionné du premier coup et le _build_ a échoué car par défaut l’image cherchait le Dockerfile à la racine du projet Github. Sur mon dépôt git, le Dockerfile est situé dans un sous dossier, la racine contenant le README et un fichier docker-compose.

Dans ce cas précis, il faut donc aller dans le **build settings** et renseigner la variable « Dockerfile location ».

![](/2017/01/dockerhub_profile_9.png)

**A noter :** pour plus de clarté dans mes images, j’ai indiqué que la branche Master dans git correspondait au tag « latest » et ait ajouté une seconde ligne avec la branche Master taguée avec le numéro de version (actuellement 8.4.4).

Ainsi, les utilisateurs pourront soit récupérer la dernière version, soit spécifier la version 8.4.4 manuellement.

![](/2017/01/dockerhub_profile_11.png)

Et cerise sur le gâteau, j’ai également **ajouté une branche 7.4.5-lts** dans Github qui me permet de proposer de manière optionnelle une image préconfigurées avec la version LTS actuelle de XWiki.

## Conclusion

Il est très simple de créer un **automated build** dans Dockerhub et vous avez donc tout intérêt à arrêter de pusher manuellement vos images si vous déposer votre code Github.com.

![](/2017/01/dockerhub_automated_build_front.png)

Seul bémol, le manque d’intégration avec Git ou même Gitlab qui sera un vrai point noir si vous avez votre propre dépôt personnel ou d’entreprise en dehors des deux services en lignes proposés par Dockerhub.

## Sources

* [docs.docker.com/docker-hub/builds/](https://docs.docker.com/docker-hub/builds/)
