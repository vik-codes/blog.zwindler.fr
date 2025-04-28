---
title: '[Tutoriel] Migrer facilement son blog de WordPress.com vers un hébergement mutualisé OVH'
authors:
  - zwindler
type: post
date: 2015-04-11T21:23:20+00:00
url: /2015/04/11/tutoriel-migrer-facilement-son-blog-de-wordpress-com-vers-un-hebergement-mutualise-ovh/
image: /2015/04/10_manager.png
categories:
  - Autohébergement
  - DIY
  - Logiciel
tags:
  - 1 click
  - akismet
  - export
  - gratuit
  - import
  - importer
  - kimsufi
  - Manager OVH
  - migration
  - MySQL
  - Nouveau Manager OVH
  - OVH
  - PostgreSQL
  - sécurité
  - VPS OVH
  - wordpress
  - wordpress.com
  - wp-admin
  - XML

---
Petit aparté avant le début de ce tutoriel, je rédige le premier article de mon blog géré par moi même (hébergé sur OVH). Ce matin même, j’étais encore hébergé en tant que blog gratuit chez WordPress.com. J’ai décidé de sauter le pas cars je trouvais le compte wordpress.com trop bridé, notamment au niveau de la limite pour les médias et l’impossibilité d’ajouter de plugins ou de toucher au CSS sans devoir mettre la main au porte monnaie.

Et puis bon... cela fait plus sens de gérer moi même mon blog sachant que je passe mon temps à bidouiller sur mes OS et que j’administre tout à la maison ;-)

Ce n’est pas pour faire de la pub pour OVH, mais il faut reconnaître que leurs offres « premier prix » sont vraiment bon marché. Entre 2 et 5€ par mois, on peut avoir un hébergement « web » en mutualisé, un VPS, voire même un serveur physique dédié (kimsufi en Atom, mais quand même!). Imbattable (enfin, allez quand même vérifier, hein?).

Si vous êtes sur ce tuto, c’est probablement que vous voulez que la migration se passe le plus simplement possible. Du coup, même si les trois options que je cite sont toutes viable, la plus simple est quand même à mon avis est d’ouvrir un compte pour de l’hébergement mutualisé, qui bénéficie chez OVH d’un module « 1-clic » dédié à WordPress.

En réalité, il y a un peu plus d’un clic pour réussir votre migration. Je vais vous guider.

## Création de l’instance de base de données pour WordPress

La première chose à faire est de se connecter sur votre Manager OVH, de sélectionner votre nouvel hébergement mutualisé.

![](/2015/04/01_manager.png)

La partie hébergement mutualisé se gère dans la partie « Plateforme » sous les noms de domaine.

![](/2015/04/02_manager.png)

OVH a beau proposer des module « 1-click » pour installer WordPress, en réalité il faut quand même d’abord commencer par créer l’instance de base de données pour stocker le tout.

![](/2015/04/03_manager.png)

Dans l’offre d’éhbergement la moins chère d’OVH, on dispose d’une instance de 200 Mo, avec au choix MySQL ou PostgreSQL. C’est largmeent suffisant pour un blog, même avec beaucoup d’articles, car les médias (photos, vidéos) ne sont pas stockées en base.  
Professionnellement parlant, je préfère PostgreSQL, mais pour pouvoir utiliser le module 1-click de votre hébergement, il faut donc **absolument** créer une instance de type **MySQL**.

![](/2015/04/04_manager.png)

![](/2015/04/05_manager1.png)

Une fois la création de la base de données validée, le message suivant s’affiche.

![](/2015/04/06_manager.png)

On doit également avoir la ligne suivante dans les Tâches en cours.

![](/2015/04/07_manager.png)

Comme toutes les opérations chez OVH, ce n’est pas immédiatement opérationnel, il faut attendre quelques secondes voire quelques minutes selon l’opération. Une fois que c’est terminé, on peut procéder à l’installation de WordPress à proprement parler.

![](/2015/04/08_manager1.png)

## Déploiement du nouveau WordPress

Ouvrir l’onglet « Modules en 1 clic » et cliquer sur Ajouter

![](/2015/04/09_manager.png)

Le processus d’installation est relativement simple à suivre

![](/2015/04/10_manager.png)

Dans le cas où la base de données à été mal créée ou n’est pas encore opérationnelle, vous obtiendrez le message suivant en étape 2

![](/2015/04/11_manager.png)

A l’inverse, si tout est bien paramétré, vous pourrez rentrer les informations de connexion à la base de données de votre compte OVH.

![](/2015/04/13_manager1.png)

Et voilà le message qui indique que tout s’est bien passé

![](/2015/04/14_manager.png) 

Une fois l'email reçu, vous pouvez vous connecter sur votre nouveau WordPress, qui sera vite (mis à par l’utilisateur d’administration et quelques pages d’exemple).

## Export des données existantes

Pendant que le WordPress est installé par OVH, on peut se connecter sur l’ancien blog et récupérer les données existantes.

Ce n’est pas la première migration que je fais. J’avais débuté ce blog sur une page perso Free (pendant très peu de temps, encore plus bridé que wordpress à l’époque) et j’avais migré rapidement vers wordpress.com. A l’époque, il faut savoir qu’il n’était pas possible de réaliser la bascule inverse. Quand vous étiez chez WordPress.com, vous étiez ferrés (sauf probablement si vous étiez prêt à payer, j’imagine). Mais aujourd’hui c’est possible et même très simple. Il suffit d’ouvrir les outils dans la partie wp-admin.

![](/2015/04/15_manager.png)

Une fois le menu ouvert, laisser les options par défaut et sauvegarder le fichier XML généré.

![](/2015/04/16_manager.png)

![](/2015/04/17_manager.png)

## Prise en main du nouveau blog, mise à jour et création d’un nouvel utilisateur

Le temps qu’on réalise cette opération, le site web est probablement installé et vous avez du recevoir l'email d’OVH pour vous dire que tout est prêt. Connectez vous sur votre nouveau site.

La première chose qui saute aux yeux lorsqu’on se connecte pour la première fois, c’st WordPress qui nous indique que la mise à jour vers la dernière version a été faite, mais qu’il reste les extensions à mettre à jour. C’est un bon conseil ;-)

![](/2015/04/20_maj.png)

Par souci de sécurité là encore, je préfère toujours séparer le compte d’administration (déjà créé lors de l’installation) du compte que j’utilise tous les jours.

Ainsi, ce n’est pas le même compte que j’utilise pour administrer le site (et il n’est pas « visible » car il ne poste jamais) et le compte moins privilégié qui lui poste les articles.

Je vous conseille de le faire également.

## Import des données dans le nouveau WordPress

Ça y est, le plus urgent a été fait! On peut maintenant réutiliser le fichier XML pour réimporter les pages, les posts, les commentaires.

Tout ce qui est « média » n’est pas présent dans le fichier XML, mais on pourra tout de même le récupérer grâce à une option lors de l’import. Pratique !

![](/2015/04/22_import.png)

Lorsqu’on tente d’importer, WordPress nous redirige vers le module permettant de le faire. Il faut l’installer et l’activer avant de pouvoir importer notre XML.

![](/2015/04/23_import.png)

![](/2015/04/24_import.png)

Ce message indique de l’installation s’est bien passée. **N’oubliez pas** de cliquer sur « Activer l’extension & lancer l’importateur » !

![](/2015/04/25_import.png)

Récupérer le fichier XML, cocher l’option « Download and import file attachments » si vous voulez récupérer les fichiers « Média » présents sur vos pas (typiquement, toutes les photos, images, vidéos, ... que vous avez importé et intégré à votre blog sur WordPress.com).

![](/2015/04/26_import.png)

Dernière astuce, dans cette même page vous pouvez également indiquer à WordPress de changer l’auteur des posts au moment de l’import. Même si c’est modifiable après coup, c’est très pratique si vous ne voulez pas que l’auteur de TOUS les posts soit signés comme provenant de l’utilisateur « admin » que vous avez utilisé pour réaliser l’import.
