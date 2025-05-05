---
title: '[Tutoriel] A la recherche d’un équivalent à PhotoStation : Piwigo/CentOS 7'
authors:
  - zwindler
type: post
date: 2016-02-11T16:30:45+00:00
url: /2016/02/11/a-recherche-dun-equivalent-a-photostation-trovebox-openphoto/
image: /2016/02/9aPU595b.png
categories:
  - autohebergement
tags:
  - apache
  - autohebergement
  - CentOS 7
  - CozyCloud
  - Docker
  - Galerie Web
  - Libre
  - MariaDB
  - Open Source
  - OpenPhoto
  - OwnCloud
  - Photo Station
  - PhotoStation
  - Piwigo
  - Synology
  - Trovebox

---
## Je cherche un équivalent à PhotoStation des NAS Synology

Voilà encore un article que j’ai commencé à écrire il y a longtemps et je trouve enfin le temps de le terminer. Dans ma ~~recherche~~ quête d’un service équivalent à celui offert par Synology avec son PhotoStation, je suis tombé sur les sites de Korben et Nicolargo qui nous parlent tous deux de OpenPhoto.

Pour resituer, je cherche un logiciel _auto-hébergeable_ qui me permettrait de visualiser et partager certaines de mes photos à ma famille qui sont aujourd’hui sur mon NAS, sans avoir à recourir à un service en ligne tiers (certains sont payant, d’autres réduisent la qualité, sans parler de l’aspect protection de la vie privée).

* [korben.info/openphoto.html](http://korben.info/openphoto.html)

* [blog.nicolargo.com/2012/04/gerer-vos-photos-avec-openphoto-un-service-auto-heberge.html](http://blog.nicolargo.com/2012/04/gerer-vos-photos-avec-openphoto-un-service-auto-heberge.html)

Sur le papier, ça semblait correspondre.

Pourtant, j’avais du mal à trouver le site. Les rares informations que je trouvais renvoyaient vers des sites visiblement down.

## OpenPhoto ? Ah non...

Et pour cause :

* Le projet OpenPhoto a été créé en 2011
* Puis renommé en Trovebox en 2013 lorsque ses concepteurs ont tenté de créer une entreprise

* [github.com/photo/frontend](https://github.com/photo/frontend)

* Qui a fermé ses portes en mai 2015. Darn !

Bon du coup, ça n’en fait pas forcément un candidat idéal pour une mise en production même si _a priori_ les sources toujours disponibles sur github ont été données à la communauté. Plus d’informations sur le dépôt GitHub <a href=)

![](https://raw.githubusercontent.com/photo/frontend/master/files/creative/screenshots/web/gallery.jpg)

L’installation avait l’air assez simple et le look vraiment prometteur, le principe est identique à la galerie d’OwnCloud et de CozyCloud : on doit importer ses photos dans l’application.

Cela peut être une bonne solution pour les gens qui veulent mettre à disposition quelques photos triées sur le volet ou qui n’ont pas tout centralisé (voir mon article sur [CozyCloud][1]).

Au delà de ça, le fait que le projet soit terminé et qu’il n’y ait eu aucune activité (pas de reprise de la communauté) depuis un an est rédhibitoire pour moi. Dommage.

## Piwigo

En fouillant dans les commentaires de l’article de Korben cités plus haut, je suis tombé sur un commentaire d’un des développeurs de [Piwigo][2] (<cite class="fn">Pierrick LE GALL</cite>), un autre projet, **Français et libre,** visant à fournir un serveur de galerie web.

Et si le look est clairement moins léché, le projet est lui bien vivant, ce qui lui confère instantanément des points par rapport à Trovebox :-p.

![](/2016/02/piwigo.png)

En lisant la documentation, on remarque que le projet est clairement plus orienté vers un hébergement de l’application sur des sites mutualisés type OVH ou Gandi. Cependant rien ne vous empêche comme moi d’installer une base de données MariaDB et un serveur web sur un Debian/CentOS pour mettre à disposition mon service de galerie web.

### Installation rapide

Si vous utilisez Piwigo sur un hébergement mutualisé, il est probable que la procédure sera plus complexe. Je vous conseille de lire la [documentation officielle][3] dans ce cas.

A partir d’une base CentOS 7 de type Desktop, j’ai installé Piwigo de la façon suivante :

```
yum install mariadb-server mariadb #Installation de mariadb
systemctl start mariadb #Démarrage de mariadb
systemctl enable mariadb #Activation de mariadb au boot
mysql_secure_installation #Configuration de mariadb de manière sécurisée
systemctl restart mariadb
```


```
mysql -uroot -p
Enter password: #Connexion à la base pour création bdd et utilisateur piwigo
CREATE DATABASE piwigo;
CREATE USER 'piwigo'@'localhost' IDENTIFIED BY 'motdepassetressecure';
GRANT ALL PRIVILEGES ON piwigo.* TO 'piwigo'@'localhost';
FLUSH PRIVILEGES;
exit
```


```
yum install httpd php php-mysql php-gd ImageMagick #Installation du serveur Web apache, de PHP et des dépendances
vi /etc/php.ini #modifier la timezone si le serveur est sur l'heure de Paris
date.timezone = Europe/Paris
systemctl start httpd #Démarrage de httpd
systemctl enable httpd #Activation de httpd au boot
```


```
firewall-cmd --permanent --add-port=80/tcp #Ajout du port 80 dans les exceptions du firewall
#firewall-cmd --permanent --add-port=443/tcp #Pour l'instant pas nécessaire car on ne met pas de HTTPS dans ce tutoriel
firewall-cmd --reload #rechargement des règles de firewalling
```


```
cd /var/www/html
mkdir piwigo &amp;&amp; cd piwigo
chown -R apache:apache piwigo
wget -O piwigo-netinstall.php http://piwigo.org/download/dlcounter.php?code=netinstall #Récupération du code d'installation automatique
chown -R apache:apache /var/www/html/piwigo
```


A partir de là, on peut ouvrir la page d’installation **http://@IPpiwigo/piwigo/piwigo-netinstall.php** dans un navigateur web

![](/2016/02/piwigo_install-1.png)

![](/2016/02/piwigo_install2.png)

### Troubleshooting

  * Si vous avez une erreur de permission lors de l’installation, vérifiez bien entendu que l’utilisateur apache a bien les droits en écriture dans le répertoire. Cependant, cela peut également être un problème de SELinux (typiquement j’avais cette erreur dans **/var/log/messages**)

```
Feb  7 21:32:44 xxxx dbus[652]: [system] Activating service name='org.fedoraproject.Setroubleshootd' (using servicehelper)
Feb  7 21:32:44 xxxx dbus[652]: [system] Successfully activated service 'org.fedoraproject.Setroubleshootd'
Feb  7 21:32:44 xxxx setroubleshoot: Exception during AVC analysis: [Errno 32] Broken pipe
```


  * Lors d’un gros import de photos de grande taille, j’ai fais sauter la limite de php fixée par défaut à 128M. Je l’ai augmentée un peu en espérant que ce n’était pas une fuite de mémoire

```
vi /var/log/httpd/error_log
[Sun Feb 07 22:23:13.636911 2016] [:error] [pid 27999] [client 192.168.1.13:65337] PHP Fatal error: Allowed memory size of 134217728 bytes exhausted (tried to allocate 13824 bytes) in /var/www/html/piwigo/admin/include/image.class.php on line 738, referer: http://@IPpiwigo/piwigo/picture.php?/98/category/1

vi /etc/php.ini
memory_limit = 256M

systemctl restart httpd
```


### Premières impressions

A côté de Trovebox ou d’autres logiciels de galerie et/ou de service en ligne, Piwigo dans sa version de base fait un peu web 2.0.

_[Édit]J’ai eu une discussion Twitter avec <cite class="fn">Pierrick LE GALL</cite> qui m’a conseillé de jeter un œil au skin Modus. Voir **un peu de tuning** plus bas[/Édit]_

Je me suis très vite rendu compte que l’outil est très intuitif et très complet. L’absence d’une interface plus « moderne » a été très vite éclipsée par la puissance de l’outil de base, sans compte la base d’extension qui est très conséquente.

Outre les [fonction classiques sociales et de recherche du type commentaires/notes/tags][4] qu’on peut mettre sur les photos, Piwigo possède une gestion très poussée de la gestion des droits par utilisateur ou par groupes, ce qui est appréciable quand on veut stocker des photos et n’en montrer que certaines à la famille et/ou aux collègues et aux amis.

C’était mon besoin principal et **Piwigo rempli le contrat parfaitement**.

On retrouve en plus quelques fonctionnalités sympas qui vont au delà de la galerie perso comme la possibilité d’ajouter en mode « batch » des filigranes pour les photos des professionnels. Pratique ! De manière générale, la possibilité de pouvoir affecter un paramètre à plusieurs photos en même temps est un gros point positif.

Ce n’est bien entendu qu’un exemple puisque je n’ai pas terminé tous les tutoriels interactifs et que je n’ai même pas encore testé le magasin d’extension !

Une vraie bonne grosse surprise donc. Enjoy !

### Pour que ce soit parfait

Comme pour tous les autres produits que j’ai pu tester, je dois re-importer mes photos dans les fichiers internes du serveurs Web (comme avec CozyCloud).

Outre l’aspect fastidieux de la chose (j’ai déjà rangé toutes mes photos dans des dossiers sur mon NAS et j’en ai beaucoup), je n’aime pas l’idée de devoir dupliquer des fichiers (hors sauvegardes).

Je ne sais pas encore s’il est possible de tirer parti du stockage de mon NAS pour éviter cette étape d’import (en présentant mon dossier de photo en NFS par exemple). Je vérifierai car c’est le dernier point qui me gène encore un peu pour obtenir un réel équivalent de PhotoStation qui (si je ne m’abuse) s’appuie directement sur les photos locales du NAS.

_[Édit]J’ai également reçu un Tweet de @FloFian (décidément !) à ce sujet. Voir **un peu de tuning** plus bas[/Édit]_

### Un peu de tuning

Comme je l’ai dis un peu plus haut, en réaction à mon article, j’ai brièvement échangé avec les développeurs de Piwigo qui m’ont donnés des conseils pour résoudre les petits points de réserve que j’ai pu remonter suite à l’installation de Piwigo.

D’abord le skin **Modus** en remplacement du skin **elegant**. Et là effectivement c’est bien plus épuré et très similaire à OpenPhoto et bien plus moderne (question de goût) :

![](/2016/02/piwigo-modus-elegant.png)

Et la seule chose à faire pour passer sur ce rendu est d’aller dans l’écran d’administration, puis dans **Configuration/Thèmes** et d’aller dans l’onglet **Ajouter un thème**.

![](/2016/02/piwigo_install3.png)

Là où j’ai encore un peu de travail, c’est sur l’ajout de photos provenant d’un partage NFS sans les importer au préalable. @FloFian m’a conseillé de simplement faire un montage NFS  sur le serveur qui héberge Piwigo, puis de faire un lien symbolique dans le répertoire **/galleries** de l’arborescence de Piwigo (dans **/var/www/html/piwigo** pour mon exemple).

Pour autant, ça ne semble pas fonctionner pour l’instant. Mais je n’ai pas encore vraiment creusé et ça pourrait simplement être un loupé sur une option dans Apache (genre FollowSymlinks) ou autre. Je mettrais à jour l’article en conséquence.

### Bonus track

Pour les amateurs de Docker (j’en parlais pour [CozyCloud avec Docker dans cet article][5]), un contributeur à mis à disposition sur GitHub un « Docker compose » pour [automatiser le déploiement de Piwigo][6]. Là aussi je n’ai pas encore jeté un œil mais au cas où ça vous dit d’essayer ...

[1]: /2015/09/08/decouverte-de-cozy-cloud-personnel/
[2]: https://fr.piwigo.org/
[3]: https://fr.piwigo.org/doc/doku.php?id=utiliser:apprendre:install:installation&idx=utiliser:apprendre:install:installation
[4]: https://fr.piwigo.org/basics/features
[5]: /2015/09/19/comment-jai-enfin-trouve-une-excuse-pour-installer-docker-a-la-maison-cozy-cloud/
[6]: https://github.com/moritzheiber/piwigo-docker
