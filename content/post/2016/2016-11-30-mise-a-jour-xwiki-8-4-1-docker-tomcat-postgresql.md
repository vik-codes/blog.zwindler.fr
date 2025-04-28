---
title: 'Mise à jour d’un XWiki en 8.4.1 avec Docker, Tomcat & PostgreSQL'
authors:
  - zwindler
type: post
date: 2016-11-30T17:30:49+00:00
url: /2016/11/30/mise-a-jour-xwiki-8-4-1-docker-tomcat-postgresql/
image: /2016/09/article_docker_xwiki.png
categories:
  - Virtualisation
tags:
  - Docker
  - docker compose
  - Java 8
  - LXC
  - PostgreSQL
  - Tomcat 8
  - Xwiki
  - xwiki 8.2.1
  - Xwiki 8.4.1

---
## XWiki + Docker

Ça fait plusieurs fois que [j’écris sur XWiki](/recherche/?keyword=xwiki) car j’ai remplacé tous mes Médiawiki (perso et pro) par XWiki ces derniers temps. J’ai même créé ma première image Docker, basée sur une image tomcat 8 officielle pour faciliter son installation !

Et j’ai même poussé le bouchon pour donner [un docker-compose permettant d’installer en 2 lignes de commandes une instance prête à l'emploi avec Tomcat et PostgreSQL](/2016/09/15/installer-xwiki-8-2-1-avec-docker-compose-en-2-lignes-de-commandes/) !

Mais ce qui devait arriver arriva. D’abord parti sur une 8.2.1, arrive le temps de mettre à jour le container !

La sortie de la 8.3 et la 8.4 ont apportés plusieurs améliorations (surtout [la 8.3][3] avec l’export de pages multiples via un seul et même XAR, un problème récurrent que j’ai depuis plusieurs mois, les extensions recommandées, ...).

## Sortie de la 8.4.1 avec quelques bugfixes

Avec [la sortie de la 8.4.1][4], j’ai donc décider de réaliser la première mise à jour de mon Dockerfile et de rebuilder une nouvelle version de mon container !

Pour rappel, les sources sont [disponibles sur Github][5] et l’image est elle [accessible sur Dockerhub][6] ou encore via une simple commande du type :

```
docker pull zwindler/xwiki-tomcat8 #ou docker run 
```


Si vous voulez un tutoriel plus complet, [je vous conseille cet article][2] ou tout simplement de suivre les instructions sur Dockerhub.

## Et maintenant, comment je met à jour ?

### D’abord, quelques précautions d’usage !

Par définition, un container LXC via Docker est non-persistant, sauf définition du contraire. Cela signifie qu’en cas de redémarrage d’extinction du container, tout est remis à zéro. C’est très pratique pour repartir à un état « stable » de l’application en cas de bug **et** lorsqu’elle ne stocke pas d’informations.

Cependant, dans ma version **zwindler/xwiki-tomcat**, j’ai paramétré le wiki pour qu’il stocke les pièces jointes [sur un le filesystem du serveur d’application java](/2016/04/30/resoudre-erreurs-de-fichiers-gros-lors-imports-xwiki/). Le comportement par défaut est dans la base de données.

C’est notamment utile lorsque vous souhaitez importer un XAR (export du wiki) assez important (dizaines de Mo) car la méthode classique (en base) consomme énormément de RAM. Cela provoquait chez moi des « Out of Memory » systématiques, même avec 2 Go de RAM (voire plus).

J’ai donc configuré le **xwiki.properties** et ajouté la directive suivante dans le **Dockerfile** qui permet de construire le container :

```
VOLUME /usr/local/tomcat/work/xwiki
```


Au déploiement, le filesystem est donc déporté sur le nœud hôte qui exécute le container et devient persistant. Vos pièces jointes seront donc à l’abri sur l’hôte qui exécute le container et resteront disponibles même si le container est éteint ou détruit.

Par acquis de conscience, je vous conseille tout de même de sauvegarder le répertoire **tomcat** avant de faire quoique ce soit...

```
mkdir svg_xwiki
docker cp xwki-tomcat:/usr/local/tomcat .
```


### Et ensuite ?

La vraie procédure peut commencer. D’abord, il va falloir retrouver le VOLUME qui contient vos pièces jointes pour que nous puissions le réutiliser. On pourrait se contenter de simplement copier les données de l’ancien volume vers le nouveau, mais c’est quand même moins propre ! Pour cela, on récupère le nom du container avec **docker ps** et le chemin vers le volume déporté avec **docker inspect**.

```
docker ps
CONTAINER ID        IMAGE                         COMMAND                  CREATED             STATUS              PORTS                    NAMES
d126a654135c        zwindler/xwki-tomcat:8.2.1   "/xwki-tomcat-entryp"   21 hours ago        Up 21 hours         0.0.0.0:8080->8080/tcp   xwiki-tomcat
710e60554c0e        postgres:9.5                  "/docker-entrypoint.s"   21 hours ago        Up 21 hours         5432/tcp                 xwiki-postgres

docker inspect xwiki-tomcat
[
{
"Id": "d126a654135cd06a531c0a59c13ec3708276185eeb4eed245e9b63a2be771d37",
[...]
        "Mounts": [
            {
                "Name": "3eb68c3b9692686beada8a0aedc5d1142874c8044b6d3d537d40cbab4dd75451",
                "Source": "/var/lib/docker/volumes/3eb68c3b9692686beada8a0aedc5d1142874c8044b6d3d537d40cbab4dd75451/_data",
                "Destination": "/usr/local/tomcat/work/xwik",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
[...]
```


On retrouve donc le volume dans le dossier _/var/lib/docker/volumes/3eb68c3b9692686beada8a0aedc5d1142874c8044b6d3d537d40cbab4dd75451/_data_.

On peut donc couper le container de la version précédente (8.2.1), puis le renommer et télécharger le nouveau.

```
docker stop xwiki-tomcat
docker rename xwiki-tomcat wiki.old.8.2.1
docker pull zwindler/xwiki-tomcat:latest
```


### Déploiement de la nouvelle version

A partir de là, on peut donc déployer le nouveau container en reprenant les valeurs user/mdp/instance de la base de données qui ont été fixés à l’installation initiale **et** en y ajoutant le volume du container précédent.

```
docker run --net=xwiki-nw -itd --name xwiki-tomcat -p 8080:8080 -e POSTGRES_INSTANCE=xwiki-postgres -e POSTGRES_USER=votreuserwiki -e POSTGRES_PASSWORD=votremdpwiki --volumes-from wiki.old.8.2.1 zwindler/xwiki-tomcat
```


En cas de doutes ou de problèmes, vous pourrez récupérer le fichier **hibernate.cfg.xm**l de la précédente instance (enfin, si vous avez copié les données avec le « docker cp » plus haut !)

Si tout s’est bien passé, votre wiki a été mis à jour sans efforts et le « Distribution Wizard » de déploiement du XWiki devrait se lancer !

![](/2016/11/xwiki_upgrade.png)

Et voilà comment nous avons simplifié les mises à jour de XWiki via l’utilisation de Docker !

 [3]: https://www.xwiki.org/xwiki/bin/view/ReleaseNotes/Data/XWiki/8.3/
 [4]: https://www.xwiki.org/xwiki/bin/view/ReleaseNotes/Data/XWiki/8.4.1
 [5]: https://github.com/zwindler/docker-xwiki
 [6]: https://hub.docker.com/r/zwindler/xwiki-tomcat8/
