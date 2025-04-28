---
title: 'Configurer DataProtector pour l’envoi de rapports via SMTP'
authors:
  - zwindler
type: post
date: 2015-07-11T12:00:07+00:00
url: /2015/07/11/configurer-dataprotector-pour-lenvoi-de-rapports-via-smtp/
image: /2015/06/HP_Data_Protector.png
categories:
  - Logiciel
  - Système
tags:
  - ASCII
  - DataProtector
  - email
  - global
  - HP
  - rapport
  - SMTP

---
Une des fonctionnalités vitales d’un système de sauvegarde est sa capacité à présenter de manière claire et concise des informations sur l’état des sauvegardes et de l’utilisation de l’outil en général. Même si c’est peut être un peu « old school », j’ai croisé de nombreux contextes professionnels dans lesquels le « team leader » reçoit quotidiennement les alertes de la veille sur les sauvegardes, sous forme d’indicateurs simples (ce que DataProtector sait bien entendu faire).

## Le reporting chez DataProtector

DataProtector propose cette fonctionnalité depuis des années via le menu sobrement nommé « rapports » du Manager. De la même manière que les spécifications de sauvegarde, les groupes de rapports peuvent être ordonnancés pour s’exécuter à horaire fixé ou bien lancés à la main.

Il existe un certain nombre de rapports fournissant ce que je qualifierai du minimum syndical en terme de reporting pour un outil de sauvegarde, et leur nombre et leurs fonctionnalités n’a guère évolué depuis la v6.x.

![](/2015/07/00_cell_manager_smtp.png)

Ces rapports ainsi que les autres outils de reporting qu’a rajouté HP en périphérie pour enrichir la relative pauvreté des indicateurs existant feront peut être l’objet d’articles futurs.

## Le vif du sujet, configurer un SMTP dans DP

Ici, je vous présenterai simplement comment configurer DP pour que les mails des rapports puissent arriver à bon port.

Depuis la v8 (il me semble), il est possible d’éditer les paramètres Globaux de DP directement depuis la GUI, au lieu de passer par le fichier « global » comme auparavant.

Cependant pour y arriver, le cheminement n’est pas forcément intuitif ;-). En effet, il faut ouvrir le menu « Base de données interne », puis aller dans « Option Globale ».

Sincèrement, je n’aurai pas cherché ce dossier dans « Base de données interne », sachant que c’est là où toutes les informations des sessions ainsi que le contenu des médias sont stockés (dans un base de données, justement).

Au contraire, les options globales sont définies « de tout temps » dans un fichier de configuration, à part. Mais bon ...

![](/2015/07/01_cell_manager_smtp.png)

Il faut quand même louer les efforts d’HP sur ce coup là. L’interface, bien que mal rangée, est assez intuitive. Les différents paramètres sont clairement classés par type, avec une description et une valeur par défaut annoncée.

Les valeurs à modifier sont donc Cell Manager : SMTPServer et Cell Manager : SMTPSenderAddress

![](/2015/07/02_cell_manager_smtp.png)

A chaque modification, il faut cliquer sur « Save » qui passe la ligne en rouge pour indiquer qu’une modification est en cours.

![](/2015/07/03_cell_manager_smtp.png)

Attention elle n’est cependant pas totalement prise en compte :-/ Il faut remonter tout en haut pour valider la sauvegarde une fois pour toute. Dommage HP ! Bel effort... mais ce n’est pas encore ça comme UI intuitive.

![](/2015/07/04_cell_manager_smtp.png)

Un bandeau vert s’affiche pour nous demander de redémarrer les services de DP pour prise en compte (lesquels?).

![](/2015/07/05_cell_manager_smtp.png)

Une fois que c’est fait, l’ensemble des rapports utilisera ces valeurs pour envoyer les rapports sous forme d'email.
