---
title: '« la Connexion Bureau à Distance ne peut pas vérifier l’identité » depuis un Mac/OSX vers Windows 2008+'
authors:
  - zwindler
type: post
date: 2015-06-05T13:36:49+00:00
url: /2015/06/05/la-connexion-bureau-a-distance-ne-peut-pas-verifier-lidentite-depuis-un-macosx-vers-windows-2008/
image: /2015/06/mac01.png
categories:
  - Système
tags:
  - authentification
  - certificat
  - échec
  - Mac
  - OSX
  - RDP
  - "vérifier l'identité"
  - Windows 2008
  - Windows 2012
  - Windows 7
  - Windows 8

---
On ne peut pas dire que je sois un grand partisan d’Apple, mais il arrive parfois que des VIPs souhaitent se connecter sur les serveurs Windows en bureau à distance (RDP). Et quand on n’y connait rien car on n’en utilise pas, c’est parfois un peu déroutant.

Ici, le mac refusait de se connecter au serveur Windows 2008, qui autorisait pourtant les connexions RDP. En fait, le souci se situait au niveau de l’acceptation du certificat délivré par le serveur 2008r2 (qui venait d’être migré depuis un 2003, qui ne dispose pas de cette sécurité).

## Symptôme

Le message d’erreur suivant apparait suite à l’authentification sur la mire d’un serveur Windows 2008 ou plus sur un Mac. Le serveur répond bien au ping (puisqu’on a la mire). On s’est assuré que le mot de passe entré est correct.

![](/2015/06/mac01.png)

## Résolution

Comme je l’ai dis en introduction, il s’agit ici d’un défaut du client RDP sur OSX qui gère mal les authentifications avancées de Windows 7 et 2008R2 et plus. Pour résoudre ce problème, il y a plusieurs manipulations à effectuer.

### Suppression des entrées dans le trousseau

La première chose à faire est d’abord de supprimer toutes les entrées correspondantes aux connexions RDP dans le trousseau de compte Mac

  * Ouvrir le finder
  * Aller dans Applications
  * Aller dans le dossier Utilitaires
  * Ouvrir trousseaux d’accès
  * Supprimer les lignes avec « remote desktop connection »

ATTENTION : faire un clic droit sur la ligne pour supprimer et ne pas utiliser le menu dans le haut. Sinon il y a risque de supprimer tous les enregistrements.

![](/2015/06/mac4.jpg)

Lors de la prochaine connexion, **ne pas cocher** d’ajouter les informations au trousseau.

![](/2015/06/mac5-1.jpg)

### Modification du .rdp

Si le problème persiste, il est probable que les informations de connexion soient contenues dans le RDP. Lorsque l’authentification échoue, ouvrir les préférences du fichier RDP en cliquant sur **CBD** en haut à gauche, puis sur **Préférences**

![](/2015/06/mac2.png)

Dans l’onglet **Session**, vider la case **Domaine** et décocher les cases

![](/2015/06/mac6-1.png)

Dans l’onglet **Sécurité**, cocher la case **Toujours se connecter**

![](/2015/06/mac3.png)

Quitter les préférences et enregistrer quand le Mac le demande pour mettre à jour le .rdp
