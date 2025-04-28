---
title: '[Tutoriel] Installer VultureOS (Vulture 3) et configurer sa première application'
authors:
  - zwindler
type: post
date: 2016-07-07T10:30:27+00:00
url: /2016/07/07/installer-vultureos-websso-3-configurer-premiere-application/
image: /2014/12/logo2-white1.png
categories:
  - Logiciel
tags:
  - FreeBSD
  - tutoriel
  - Vulture 3
  - Vulture WebSSO
  - VultureOS

---
## Installer pas à pas VultureOS et faire une configuration minimale

Une fois n’est pas coutume, même si je suis habituellement assez peu « tutoriel pas à pas avec des screenshots dans tous les sens », je vous propose aujourd’hui de plonger dans l’installation du VultureOS de Vulture WebSSO 3 qui vient de sortir (1er juin) jusqu’à la redirection de votre première application.

## Prérequis

Pour ceux qui ne le savent pas, je vous propose de relire mon article où [je rappelle brièvement ce qu’est Vulture 3](/2016/06/16/sortie-de-vulture-3/).

Voici les prérequis de VultureOS pour fonctionner dans de bonnes conditions :

  * VultureOS doit être installé sur une machine virtuelle ou un serveur physique ayant 2 Go de RAM et 30 Go d’espace disque
  * avoir une ou plusieurs adresses IP pour recevoir des connexions Web
  * pouvoir contacter les applications Web qu’il protège sur leurs ports habituels (80 et 443 en général)
  * disposer d’une résolution de noms fonctionnelle (soit par serveur DNS soit via /etc/hosts sur l’OS Vulture) et avoir accès à un serveur NTP
  * **avoir un accès HTTPS vers dl.vultureproject.org** pour s’enregistrer et télécharger les mises à jour

## Démarrage de l’installation

Comme je l’ai déjà dis, Vulture s’appuie maintenant sur une distribution FreeBSD modifiée et est donc livré clé en main. Pour peu que vous ayez accès à Internet et respecté les prérequis énoncé juste au dessus, tout s’installe donc tout seul.

> Next next next

![](/2016/06/vultureOS1-1.png)

> Classiquement, le disque dur va être formaté par le bootstraping de FreeBSD

![](/2016/06/vultureOS2.png)

> Lors du test de la keymap, je n’ai pas trouvé de clavier FR correspondant. Peut être un bug entre FreeBSD et KVM ?

J’ai volontairement sauté toute la partie configuration du hostname et des cartes réseaux car cela dépend fortement de vous mais rappelez vous surtout que l’aspect DNS doit être particulièrement soigné pour que VultureOS fonctionne correctement !

![](/2016/06/vultureOS3.png)

![](/2016/06/VultureOS_1.png)

> Attention, contrairement à la bêta où nous étions « prompté » pour un mot de passe, le mot de passe de vlt-adm pour l’accès SSH est ici prégénéré (peut être pour éviter les erreurs de saisies clavier?)

Une fois le bootstraping FreeBSD terminé et les prérequis installés, l’OS reboote et vous affiche le message suivant

![](/2016/03/vultureOS8_bootstraping.png)

Connectez vous en SSH avec le login vlt-adm (ou en console, peu importe) et exécuter la commande demandée ci dessus et gentiment recopiée à la main ci dessous pour vos copier coller ;-) :

```
sudo /home/vlt-gui/env/bin/python2.7 /var/bootstrap/bootstrap.py
```


![](/2016/06/VultureOS_3.png)

> yes !

L’installation de Vulture (en tant qu’application) commence réellement. On vous demande ensuite si vous voulez joindre un cluster existant ou en créer un puis de renseigner un email pour recevoir la clé d’activation de votre Vulture WebSSO.

![](/2016/06/vultureOS11.png)

Une fois la clé reçue, on l’applique (attention aux spams, gmail ne me l’a pas flaggé en bêta pas pour la V1 si).

![](/2016/06/VultureOS_4.png)

![](/2016/06/vultureOS12.png)

> Le processus de génération de certificat est maintenant inclus dans l’installation.

Une fois terminé, un login/mdp sera demandé pour la connexion à la GUI et les services de WebSSO seront démarrés.

![](/2016/06/vultureOS14.png)

## Ouverture de l’interface graphique

A partir de là on peut donc se connecter en HTTP sur l’URL fournie.

![](/2016/06/vultureOS15.png)

Une fois la mire passée, on arrive sur un Dashboard avec quelques métriques sympathiques sur l’état de la machine.

![](/2016/06/VultureOS_5.png)

Le menu est accessible sur la gauche en haut, au niveau des 3 tirets horizontaux

![](/2016/06/VultureOS_6.png)

> On y retrouve, bien que dans un ordre un peu modifié, les menus que l’on connaît des précédentes versions.

La gestion des interfaces réseaux se fait dans **Network/Listeners**. La gestion de l’HTTPS se fait dans **Configuration Profiles/TLS**.

![](/2016/06/VultureOS_7.png)

> Entre la bêta et la version 1, le menu a été renommé de de SSL profiles à TLS, mais on voit encore SSL Profile en titre dans cette capture.

[La documentation de Vulture](https://www.vultureproject.org/docs-v3/reseau-profil-tls/) donne des indications complémentaires pour la configuration TLS dans des cas où l’on souhaite être compatible HTTP/2.

Des menus qui vous intéresserons sûrement assez rapidement :

  * **Vulture Management/PKI** si vous voulez importer de nouveaux certificats
  * **Configuration Profiles/Logs** pour gérer vos logs comme vous l’entendez

## Configuration de votre première application

Ouvrez le menu **Applications/Applications**, puis cliquez sur **ADD AN ENTRY**.

![](/2016/06/vultureOS20.png)

> Voici maintenant la liste des champs que nous avons maintenant pour habitude de remplir dans Vulture. Un nom « friendly name » ; « public FQDN » l’URL publique pour accéder à l’application ; « Private URI » l’URL interne que doit utiliser Vulture pour accéder au serveur web qu’il doit protéger.

![](/2016/06/vultureOS19.png)

![](/2016/06/vultureOS22.png)

> Ajouter un listener (une interface réseau)

![](/2016/06/vultureOS24.png)

> Il est également obligatoirement ajouter un format de log.

Une fois le tout validé, l’application apparaîtra dans la liste. Il faudra recharger la configuration en cliquant sur les flèches en rond (clignotantes) puis sur le triangle pour démarrer l’application.

![](/2016/06/VultureOS_8.png)

![](/2016/06/VultureOS_9.png)

![](/2016/06/VultureOS_10.png)

Et voilà. Pour ceux qui ont des problèmes pour ajouter des applications dans Vulture, les principes restent les mêmes que dans les versions précédentes [et que j’ai déjà pas mal traité dans ces articles](/recherche/?keyword=vulture)

Happy SSOing ;)
