---
title: Déploiement de Proxmox VE 5 sur un serveur dédié – part 3
authors:
  - m4vr0x
type: post
date: 2017-07-25T11:55:18+00:00
url: /2017/07/25/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-3/
image: /2017/07/proxmox-install_thumbnail.png
categories:
  - Système
  - Virtualisation
tags:
  - iptables
  - kimsufi
  - KVM
  - labs
  - oneprovider
  - openvpn
  - OVH
  - pfsense
  - Proxmox
  - serveur dédié

---

> Note : Cette suite d’articles de 2016 écrite par M4vr0x a été remis à jour par Charles et moi. Je vous conseille d’aller lire celui ci plutôt, qui sera plus en phase avec les versions actuelles. [Proxmox VE 6 + pfsense sur un serveur dédié (1/2)](/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie/">)

Cet article fait partie d’une suite de 3 articles sur la mise en place de Proxmox VE et sa sécurisation et dont voici les adresses :

* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 1](/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/)
* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 2](/2017/07/18/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-2/)
* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 3](/2017/07/25/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-3/)

Nous avons donc à présent une belle infrastructure à disposition avec une VM PFSense en frontal et un niveau de sécurité relativement correct. Nous allons donc terminer par :

  * La configuration d’un accès distant sécurisé grâce à OpenVPN
  * L’adaptation des règles de filtrage pour que cela fonctionne

Mais avant cela, je vais juste faire un léger aparté pour vous montrer comment autoriser l’accès extérieur à un service d’une machine virtuelle.

Comme pour les parties précédentes, si des paramètres ne sont pas explicités, ils sont à laisser à leur valeur par défaut.

## Publication de services sur l’internet du web

Imaginons que vous ayez quelques VMs qui vous fournissent des services de « Prod », et que pour des raisons qui vous sont propres, vous souhaitiez pouvoir y accéder sans passer par votre futur VPN ... « Comment faire ? » me demanderiez-vous. « Et bien, vous répondrais-je ... C’est très simple mon cher ami, grâce à notre magnifique infrastructure, l’ajout d’UNE SEULE règle suffira ! » (mouahaha)

Donc prenons le cas d’un serveur PLEX , au hasard, hébergé sur un NAS Synology virtualisé ... son @IP est 192.168.9.10 et son port d’écoute est, par défaut, le TCP:32400.

  * Se rendre dans le menu Firewall > NAT puis cliquer sur « _ADD_ »

**Interface** : WAN
**Protocol** : TCP  
**Destination** : Any  
**Destination Port Range (From)** : Other - 32400  
**Redirect target IP** : 192.168.9.10  
**Redirect target port** : Other - 32400  
**Description** : Choisir un nom pour la règle (ex: Synology - Plex)

  * Valider avec « _Save_ » puis « _Apply Changes_ » pour recharger la configuration

![](/2017/07/proxmox-install_pfsense-nat-rule.png)

> Voilà, c’est tout !

Vous avez crée une règle de NAT qui renvoie toutes les requêtes arrivant sur le port TCP:32400 de votre interface WAN vers le port TCP:32400 de votre Plex ! Cerise sur le gâteau, vu que PFSense est bien conçu (et que vous n’avez pas modifié le paramètre « Filter rule association ») il vous a généré une règle de FW associée pour autoriser le flux de votre règle NAT.

Comme tous les services publiés sur votre IP public constituent des vecteurs potentiels d’attaque on va y allez « molo sur la mayo » (... vous connaissez cette expression ? Je crois que je viens de l’inventer ... truc de fou ... une fulgurance ... Non sérieux quelqu’un connaît ? ... Euh oui pardon ... ). Je disais donc que nous privilégierons évidemment un accès via le VPN que nous allons mettre en place .... genre maintenant, tout de suite.

## Configuration d’accès distant sécurisé via OpenVPN

Je ne vais pas vous détailler l’action de chaque option, et je ne les connais pas toutes d’ailleurs, par contre si vous êtes intéressé, je vous encourage fortement à vous référer à ces sources :

  * [Documentation officielle d’OpenVPN][5]
  * [Article « OpenVPN Remote Access Server » du Wiki de PFSense][6]
  * [Un très bon tuto francophone][7] qui détaille bien les options ... lui ;-)

### Création de l’autorité de certification

  * Naviguer jusqu’à la liste des « CAs » via le menu System > Cert Manager :

![](/2017/07/proxmox-install_pfsense-ca-creation.png)

Celle-ci est vide, nous allons donc créer une nouvelle entrée.

  * Cliquer sur le bouton « ADD » en bas à droite, puis renseigner comme suit :

**Descriptive name** : Nom choisi pour la CA  
**Method** : Create an internal Certificate Authority

Une fois la méthode sélectionnée, l’encadré inférieur va changé

**Key length** : 2048 (longueur de la clé de chiffrement)  
**Digest Algorithm** : SHA256 (méthode de hachage)  
**Lifetime** : 3650 (durée de validité en jours)  
**Country Code** : FR (Code ISO du pays d’émission du CA)

Les autres champs sont libres et à titre indicatif, évitez toutefois les infos trop personnelles/confidentielles. Choisissez simplement un « Common Name » un peu explicite pour pouvoir l’identifier facilement.

  * Cliquer sur « _Save_ » et contempler le résultat :

![](/2017/07/proxmox-install_pfsense-ca-exemple.png)

### Création du certificat serveur

  * Cliquer à présent sur l’onglet rouge « _Certificates_ » où un certificat utilisé par la WebUI existe déjà, puis cliquer sur le bouton « _ADD_ » pour en créer un nouveau :

**Method** : Create an internal Certificate Authority

Et là grosse surprise ! ... Une fois la méthode sélectionnée, l’encadré inférieur va changé

**Descriptive name** : Nom choisi pour la certificat serveur  
**Certificate authority**:  Sélectionner la CA crée juste avant (la seule normalement)  
**Key length** : 2048  
**Digest Algorithm** : SHA256  
**Certificate Type** : Server Certificat (Qui a dit pourquoi ? ... Toi => [] ... tu sors)  
**Lifetime** : 3650 (10 ans ça devrait suffire)

Les champs suivants sont normalement pré-remplis donc conservez les même valeurs que précédemment sauf pour « _Common Name_ » bien sûr (Pourquoi ? ... t’étais pas sorti toi ??!)

  * Valider avec le bouton « _Save_ »

### Création du certificat client

Alors là c’est tricky ... attention ... il va falloir relire le paragraphe précédent (oui y compris les vannes bidons) et refaire la même manip en changeant simplement :

**Certificate Type** : Client Certificat ... \o/

![](/2017/07/proxmox-install_pfsense-cert-exemples.png)

### Création du serveur VPN

  * Se rendre dans le menu VPN > OpenVPN, puis cliquer sur « _ADD_ »

#### _General Information_

**Server Mode** : Remote Access (SSL/TLS + User Auth)

Avec ce mode vous aurez besoin des certificats sur le client mais devrez également saisir le login/password du user crée ci-dessus à chaque connexion du tunnel VPN. C’est une sécurité supplémentaire que vous pouvez désactiver en choisissant « Remote Access (SSL/TLS) »

**Local Port** : 2294

Rien d’obligatoire ici mais pour les même raison expliquées dans la 2e partie de l’article ça limite drastiquement l’efficacité de nombreux bots qui utilisent les ports standards.

#### **_Cryptographic Settings_**

**TLS Authentication** : Laisser coché

La TLS est une couche supplémentaire d’authentification/chiffrement qui permet d’ajouter une seconde ligne de défense à SLL et à priori l’impact n’est pas significatif au niveau des performances. Libre à vous de lire la doc et de l’enlever en toute connaissance de cause si vous le souhaitez.

**Description** : Choisir un nom pour le serveur OpenVPN  
**Certificate authority** : Sélectionner la CA créée juste avant (toujours la seule normalement)  
**Server Certificate** : Choisir le certificat serveur créé précédemment

#### _Tunnel Settings_

**IPv4 Tunnel Network** : 10.2.2.0/24

Conformément à notre schéma réseau, visible dans la [2e partie de l’article][2]. Là aussi, libre à vous de choisir votre segment réseau, du moment que vous adaptez la suite à votre plan d’adressage.

**Redirect Gateway** : Cocher la case

Ce paramètre permet de forcer le client à utiliser le VPN en tant que passerelle par défaut dès qu’il est activé. Ce qui peut faire office de proxy sécurisé pour l’ensemble de votre trafic quand vous vous connectez depuis un Wifi Public par exemple. Si vous utilisez un client qui le permet (ex: TunnelBlick), vous pouvez laisser cette options décochée et l’activer au besoin coté client, en revanche l’ajout d’une option « push « route 192.168.9.0 255.255.255.0 » sera obligatoire.

**Concurrent connections** : 3

Facultatif, permet de limiter le nombre de client connectés en même temps.

**Inter-client communication** : Cocher la case

Si vous souhaitez que vos client puissent communiquer entre eux.

**Disable IPv6** : Cocher la case

#### _Client Settings_

**Dynamic IP** : Cocher la case

  * Valider avec le bouton « _Save_ » 

### Création de l'(unique) utilisateur

  * Se rendre dans le menu System > User Manager, puis cliquer sur « _ADD_ » 

**Disabled** : A cocher pour empêcher le user d’avoir le droit de se loguer sur la WebUI

En effet, le but est d’avoir un utilisateur dédié sans accès à l’interface. Ensuite choisissez un login, un password, un nom long (facultatif), une date d’expiration (si vous cherchez des ennuis, vu que vous vous demanderez dans quelques mois pourquoi ça ne fonctionne plus). Une fois le user crée, nous allons lui attribuer le certificat client que nous avons généré précédemment :

  * Cliquer sur le bouton « _Edit user_ » (mais si, le petit crayon bleu à droite ... l’autre droite)

  * Dans le cadre  « _User Certificates_  , cliquer sur « _Add_ » 

**Method** : Choose an existing certificate

**Existing Certificates** : Sélectionner votre certificat client qui doit être le seul non encore utilisé

Il ne vous reste plus qu’à sauvegarder la modification. L’idée est de créer un couple user/certificat client par personne (logique) voir par machine cliente, ça permet notamment pouvoir les révoquer individuellement au besoin. Enfin si vous avez besoin de plusieurs utilisateurs, créez leur un groupe dédié pour les ranger (c’est plus propre, on est pas des sauvages).

### Configuration du/des client(s)

Afin de pouvoir accéder à notre tunnel, il faut maintenant récupérer :

  * La clé privé du certificat client crée précédemment
  * La clé publique de ce même certificat
  * Un modèle de configuration client d’OpenVPN et l’adapter

Je suis donc censé vous décliner la marche à suivre pour préparer des « kits » de configuration,  en fonction des options sélectionnées pour notre serveur, des spécificités de mise en forme de certificats pour les différents types de clients (Linux, MacOS, iOS, Android ... voir Windows) et également pour chaque ... ah ouai ... mais non en fait.

Nous allons plutôt utiliser un des (nombreux) avantages de PFSense, à savoir son gestionnaire de paquets !

En effet, il existe plus d’une cinquantaine de packages (en release 2.3.4) qui permettent d’ajouter des fonctionnalités à notre Firewall. Pour ne rien gâcher, ils sont installables en un clic depuis l’interface Web et leurs paramètres sont sauvegardés automatique par le mécanisme de backup intégré de PFSense qui est un simple fichier XML.

Enfin, comble du bonheur, il en existe un qui fait exactement tout ce qui nous intéresse : openvpn-client-export !

![](/2017/07/proxmox-install_wonderful-world.jpg)

  * Se rendre dans le menu System > Package Manager, puis cliquer sur l’onglet « _Available Packages_ » 
  * Taper « export » dans le champ de recherche, puis installer le paquet via le bouton « _Install_ »

Vous pouvez aussi profiter d’une recherche manuelle pour parcourir les différents paquets disponibles.

![](/2017/07/proxmox-install_pfsense-export-pkg.png)

[Lien vers la documentation du package OpenVPN Client Export][11]

  * Naviguer vers le menu VPN > OpenVPN, puis cliquer sur le nouvel onglet _« Client Export »_

**Remote Access Server** : Sélectionner le serveur VPN souhaité (le seul à priori)  
**Host Name Resolution** : Other

Le choix par défaut « _Interface IP Address_ » va renseigner l’@IP locale de votre interface **WAN** (10.0.0.2) dans le fichier de configuration du client et quand vous essaierez de vous y connecter depuis internet ça marchera beaucoup moins bien. Le mieux est de sélectionner « _Other_ » et de saisir directement votre IP publique ou votre nom de domaine (en cas d’utilisation de DynHost par exemple).

**Use Random Local Port :** Cocher la case (obligatoire si vous prévoyez plusieurs client en simultanés)

Scroller à présent vers le bas jusqu’au cadre OpenVPN Clients :

![](/2017/07/proxmox-install_clients-export.png)

Il ne reste plus qu’à télécharger les configs qui vous intéresse !

Pour les utilisateurs de MacOS, je vous conseille le client VPN [Tunnelblick][13]. Une fois installé, télécharger la « _Standard Configuration_ » au format « _Archive_ » . Dézipper l’archive, ajouter le suffixe « .tblk » pour transformer le dossier en configuration pour Tunnelblick et enfin l’ouvrir pour la charger automatiquement dans l’application.

Une fois la/les configuration(s) installé(s) sur votre/vos client(s), il ne reste plus qu’à paramétrer les règles PFSense requises.

### Configuration des flux

#### Autoriser l’accès du client au serveur VPN depuis internet

  * Naviguer vers le menu Firewall > Rules
  * Sélectionner l’onglet WAN puis ajouter une nouvelle règle avec « _ADD_ »

**Action** : Pass  
**Interface** : WAN  
**Protocol** : UDP  
**Source** : Any  
**Destination** : WAN address  
**Destination Port Range (From)** : 2294 (ou le port d’écoute choisi pour votre serveur)  
**Description** : Renseigner le nom qui s’affichera pour la règle (ex: OpenVPN nomad access)

#### Autoriser l’accès du client en provenance du tunnel VPN aux LAN & WAN

  * Sélectionner l’onglet OpenVPN puis ajouter à nouveau une règle avec « _ADD_ »

**Action** : Pass  
**Interface** : OpenVPN  
**Protocol** : Any  
**Source** : Network - 10.2.2.0/24  
**Destination** : any

Ici on peut limiter l’accès des clients au seul LAN mais il faudra désactiver l’option « _Redirect Gateway_ » du serveur et le VPN ne pourra plus être utilisé en tant que proxy Web.

**Destination Port Range (From)** : 2294 (ou le port d’écoute choisi pour votre serveur)  
**Description** : Renseigner un nom pour la règle

  * Valider les changements via le bouton « _Apply Changes_ »

Vous n’avez plus qu’à démarrer votre client VPN, renseigner votre login/pass et c’est parti !

## THE END !

Voilà n’hésitez pas à commenter, poser des questions, faire une donation via PayPal si vous voulez supporter le blog avec les quelques euros qui traînent sur votre compte et surtout abonnez-vous à NoLife ... ah non c’est pas ça je m’égare ... allez see u guys.

 [5]: https://openvpn.net/index.php/open-source/documentation/howto.html
 [6]: https://docs.netgate.com/pfsense/en/latest/recipes/openvpn-ra.html
 [7]: http://www.provya.net/index.php?d=2016/04/18/11/00/31-pfsense-securisez-lacces-distant-de-vos-collaborateurs-nomades-avec-openvpn
 [11]: https://docs.netgate.com/pfsense/en/latest/packages/openvpn-client-export.html
 [13]: https://tunnelblick.net/downloads.html
