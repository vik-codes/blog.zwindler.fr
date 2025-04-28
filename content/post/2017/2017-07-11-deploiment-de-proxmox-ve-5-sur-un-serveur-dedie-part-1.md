---
title: Déploiement de Proxmox VE 5 sur un serveur dédié – part 1
authors:
  - m4vr0x
type: post
date: 2017-07-11T11:30:47+00:00
url: /2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/
image: /2017/07/proxmox-install_thumbnail.png
categories:
  - Système
  - Virtualisation
tags:
  - kimsufi
  - KVM
  - labs
  - oneprovider
  - OVH
  - pfsense
  - Proxmox
  - serveur dédié
  - virtualisation

---

> Note : Cette suite d’articles de 2016 écrite par M4vr0x a été remis à jour par Charles et moi. Je vous conseille d’aller lire celui ci plutôt, qui sera plus en phase avec les versions actuelles : [Proxmox VE 6 + pfsense sur un serveur dédié (1/2)](/2020/03/02/deploiement-de-proxmox-ve-6-pfsense-sur-un-serveur-dedie)

Cet article fait partie d’une suite de 3 articles sur la mise en place de Proxmox VE et sa sécurisation et dont voici les adresses :

* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 1](/2017/07/11/deploiment-de-proxmox-ve-5-sur-un-serveur-dedie-part-1/)
* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 2](/2017/07/18/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-2/)
* [Déploiement de Proxmox VE 5 sur un serveur dédié - part 3](/2017/07/25/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-3/)

Comme c’est mon tout premier article, je vais commencer par donner le ton en édictant une vérité universelle qui n’engage que moi :

> **Tout bon SysAdmin qui se respecte se doit de posséder un environnement de Labs  
>** 

Une fois cet état de fait accepté, se pose la question du choix entre l’achat d’un serveur hébergé « at home » et la location d’un serveur dédié. Pendant plus de cinq ans, j’ai opté pour la première solution pour les raisons suivantes :

  * **Parce que le coup est moindre sur le long terme** : un petit serveur d’entrée de gamme ou « home made » d’une valeur de 500€ se verra rentabilisé au bout d’environ deux ans en comparaison d’une location à 20€/mois pour un hardware équivalent.
  * **Parce que j’ai un accès fibre à domicile** : tout le monde n’a évidemment pas cette chance mais lorsque c’est le cas, le confort est largement supérieur à beaucoup d’offre de providers (par ex Kimsufi d’OVH) qui sont limitées à du 100 Mb/s ce qui représente environ 12 Mo/s utile. Cela permet de télécharger des ISOs de distributions Linux gratuites très rapidement ... elle marche encore cette vanne ? ...
  * **Parce que je garde le contrôle total de mes données** : Il est évident qu’en confiant ses données à un fournisseur externe, il faut partir du principe que celui-ci à potentiellement accès à vos données. On peut réduire voir éliminer ce risque en ne déposant que des données non personnelles ou en basculant par exemple en mode « zero-knowledge » et en procédant à un chiffrement ACID SHA-256 de tous ses précieux ISOs Linux (les psychopathes concernés se reconnaîtront).
  * **Parce que je suis un barbu** : ce qui au passage est un état d’esprit et pas forcément un syndrome d’hypertrichose (ouai, on apprend des mots aussi). Et donc, en tant que tel, j’aime avoir un accès physique à mes machines au besoin.

![](/2017/07/proxmox-install_sysadmin-beard.jpg)

Donc tout ça c’est bien sympa sauf que vous pourriez me contredire en m’opposant au moins autant de bons arguments en faveur d’une location ... C’était bien la peine ! (... et arrêtez de me contredire).

## Identifier l’objectif

### Le problème

Je vais donc couper court à toute rébellion, arrêter de digresser et vous expliquer que comme je pars à l’autre bout du monde, j’ai dû complètement adapter mon point vue, mes habitudes ainsi que la totalité de mon infra.

> **Pour résumer, je dois passer d’un mode « Barbu sédentaire » à « Nerd nomade »**

Le but est donc de migrer mes services, du mieux possible, pour faire rentrer ça :

* Un desktop en dual boot MacOS Sierra/Win10 avec I5, 3xSSD, GTX 970 et double écran 24";
* Un petit hyperviseur en dual core sous Proxmox VE
* Un NAS « home made » sous XPEnology avec ~8 To de stockage utile en Raid 5
* Un firewall physique sous PFSense
* Un Rasberry Pi sous Raspbian faisant office de contrôleur de domaine via samba 4
* Un accès fibre 500 Mb/s

dans ça :

* Un laptop Dell XPS 13 en triple boot (ElCapitan/Win10/Kali)
* Un serveur dédié regroupant l’hyperviseur, le NAS, le firewall
* Un accès Wifi ou Tethering 4G

... Et oui, ça pique ... mais j’ai décidé de prendre ça comme un challenge avec plein de nouvelles choses à tester, à comparer et à mettre en œuvre ! Le but étant de garder un maximum de performance et de confort d’utilisation pour un prix (relativement) raisonnable. Par contre, faut pas rêver, je fais une croix sur GTA 5 et The Witcher 3.

Je vais vous épargner toutes les différentes solutions que j’ai pu envisager et tester ces derniers mois. Je suis passé en vrac par du [DigitalOcean][5], du [Kimsufi][6], du [SeedHost][7], ~~du OneProvider~~ pour les serveurs, du [pCloud][8], du [Amazon Cloud Drive][9], du [Google Drive (via GSuite)][10] pour le stockage et par une bonne dizaines d’architectures et de tarifs différents.

Je ne garde pas un œil permanent sur tous les hébergeurs qui existent. Sachez qu’il existe des comparateurs d’offres d’hébergement (par exemple, [ce comparatif des serveurs dédiés de tophebergeur][11] qui possède un comparatif actualisé régulièrement).

[Edit]Suite à des soucis avec OneProvider et notamment le support, je déconseille maintenant ce provider[/Edit]

### La solution choisie

Il existe donc plusieurs possibilités pour répondre au besoin, mais pour mettre fin au suspens insoutenable, voilà un schéma simplifié de l’architecture que j’ai validé et qui est en « pré-production » depuis 6 mois maintenant (cliquer pour agrandir) :

![](/2017/07/proxmox-install_simple-infra-map.jpg)

Je reviendrais plus en détail dans la seconde partie de l’article sur les choix concernant l’adressage, les bridges/interfaces virtuels et les flux.

## Choisir l’armement

### La solution de virtualisation Proxmox VE

Proxmox VE est une solution d’hyperviseur Bare-Metal totalement gratuite et OpenSource basée sur Debian. L’éditeur propose également un système de souscription payante pour les entreprises souhaitant bénéficier d’un support personnalisé. Elle utilise KVM le moteur de virtualisation natif de Linux et le format de conteneur LXC qui remplace OpenVZ depuis la version 4. C’est robuste, peu consommateur en ressource et ne nécessite pas d’être installer sur une machine de guerre. Il est toutefois évident que plus le serveur sera costaud plus il pourra faire tourner de VMs en simultané. Pour ne rien gâcher la Webui est belle et ergonomique. Proxmox VE possède toutes les fonctionnalités que l’on peut attendre d’une solution de virtualisation d’entreprise. Il est à noter qu’elle propose la création simplifiée de cluster de stockage CEPH directement depuis son interface Web.

La liste exhaustive des fonctionnalités est disponible sur [cette page du site officiel][13] de Proxmox.

### Le firewall PFSense

Là encore, une solution gratuite OpenSource, robuste (basée sur du FreeBSD 10.3 pour PFSense 2.3), légère,  avec une interface belle et ergonomique. Bref vous avez compris l’idée et tous les détails sont disponibles sur [le site officiel][14] de PFSense.

### Le hardware

Les choix sont multiples, je vais donc me limiter à deux modèles de serveur dédié, un proposé par Kimsufi et l’autre par OneProvider. Les deux proposent l’installation simplifiée de Proxmox VE 5 directement depuis l’interface d’administration.

#### La solution Kimsufi

Vous savez probablement que Kimsufi est une marque d’OVH dont le catalogue est composé de serveurs Bare-Metal dédiés reposant sur configurations standards non modifiables et un peu datées, ce qui permet de proposer des prix très intéressants.

Comme je n’ai rien trouvé d’exhaustif sur le site officiel ou sur Google, voilà une liste des modèles proposés au 17 mars 2017 :

![](/2017/07/proxmox-install_kimsufi-severs-list.png)

J’ai donc sélectionné le KS-6 à 29,99 HT offrant :

* Deux CPU Intel Xeon E5530 de 2,4 GHz pour un total de 8c/16t
* 24 Go de RAM
* 1 HDD de 2 To
* Une interface 100 Mb/s et une (seule) @IP public associée
* Hébergé en France

#### ~~La solution OneProvider~~

~~C’est celle que j’utilise actuellement avec un serveur dédié « Storage Series ». Néanmoins je souhaitais présenter les deux possibilités car le KS-6 de Kimsufi est une alternative totalement viable, 50% moins chère et qui peux largement suffire pour ceux qui n’ont pas besoin d’autant de volumétrie, de stockage et de bande passante que moi.~~

~~J’utilise donc un modèle à 69 € HT avec les caractéristiques suivantes :~~

* ~~Un cpu Intel Xeon E3-1230v2 (4c/8t) de 3,2 GHz~~
* ~~16 Go de RAM~~
* ~~4 x 3To HDD en Raid5~~
* ~~Une interface 1 Gb/s et une @IP public associée avec possibilité d’en ajouter via option payante~~
* ~~Une accès à l’iLO via IPMI~~
* ~~Hébergé en France~~

~~Donc certes le prix est plus élevé mais c’est un excellent rapport stockage/puissance/prix. Je n’ai pas trouvé mieux surtout avec 9 To de stockage utile en Raid 5 et l’accès console qui est vraiment utile comme on le verra par la suite.~~

## Percevoir les munitions

### Pour Kimsufi

Voilà quelques détails pratiques utiles à connaitre afin d’obtenir assez simplement le modèle de son choix :

  * Tout d’abord, les meilleurs configurations (et les plus grosses) partent vite, très vite ... j’ai donc eu recours au site [Kimi Checker][16] afin d’être prévenu des disponibilités des différentes « pizza box ». C’est gratuit, ça fonctionne bien et pas de compte à créer : on sélectionne les modèles à surveiller, on rentre une @ email et c’est bon.
  * Pour éviter de perdre de temps lors de la souscription ... ah voilà trop tard ! ... il peut s’avérer pertinent de créer son compte Kimsufi et de paramétrer son moyen de paiement en avance de phase. Je précise également que les comptes clients OVH ne sont pas utilisables.
  * Une fois en possession du précieux, prenez 2 min bien méritées pour apprécier l’instant puis connectez-vous à [votre interface de gestion][17] pour passer aux choses sérieuses.

## Sauter sur la zone

> **On y est ! Vous vous êtes entrainé toute votre vie pour ce moment ... (ou pas), on serre les dents et on passe la porte de l’avion !**

### Chez Kimsufi, pas un souffle de vent => R.A.S.

Sur la page d’accueil, il suffit de choisir « _VPS Proxmox VE 5 (64 bits)_ » dans la liste des « Gabarits » disponibles. Ensuite il faut sélectionner la langue voulue pour l’installation de l’OS et surtout, ne pas oublier de cocher « _installation personnalisée_ » afin notamment de pouvoir configurer la répartition de la volumétrie. .

Voilà le schéma de partitionnement que j’ai utilisé : ![](/2017/07/proxmox-install_kimsufi-partitioning.png)

Il ne reste plus qu’à valider et attendre quelques minutes le temps que Proxmox s’installe.

### ~~Chez OneProvider, 10 m/s => on percute la planète mais on se relève~~

~~On sélectionne son serveur via le bouton « _Server List_ » dans le menu de gauche et on clique sur « _Manage_« . Il suffit ensuite de cliquer sur « _Reinstall_ » et de sélectionner Proxmox dans la liste des « _Virtualisation distributions_« .~~

![](/2017/07/proxmox-install_oneprovider-os-selection.jpg)

> Attends ... ? WTF ? Non c’est pas ... ... ben si ... NON !! Ah les bât@&#x1f480;&#x1f52a;&#x1f4a3; !

Donc trêves de plaisanteries sérieuses, OneProvider nous appâte avec Proxmox sur leur site et au final la distribution n’est pas encore disponible en déploiement automatique.

J’ai donc ouvert un ticket pour avoir plus de renseignements. Le retour fut rapide et clair :

_« Nous serons en mesure de faire l’installation de Proxmox de notre côté si vous le désirez. Par contre, je vous invite à noter qu’un utilisateur doit être spécifié et que nous ne sommes pas en mesure de modifier le partitionnement par défaut. Si vous préférez faire l’installation vous-même depuis l’IPMI, vous serez en mesure de procéder directement depuis le portail »_

Je vais donc en profiter pour vous montrer une installation classique depuis un ISO sur un Bare-Metal comme si vous aviez un accès physique à la machine grâce à l’IPMI.

  * Télécharger l’ISO de Proxmox VE 5

Toutes les versions sont disponibles sur [cette page][20].

#### L’iLO en renfort

Pour obtenir un accès à l’IPMI chez OneProvider, il suffit de cliquer sur le bouton « IPMI Session » dans la section « Manage » de son serveur. On met un petit commentaire pour expliquer et on attends le retour du ticket. Une fois la session activée, on se connecte à l’@IP et on s’authentifie avec les credentials qui sont désormais visibles toujours dans la section « Manage ». Après ça, je vous rassure, plus besoin de créer de ticket, il suffira d’utiliser le bouton « Create Session » pour créer une session temporaire.

  * Se connecter à l’adresse IP de l’iLO fournie par OneProvider

Ici rien de particulier, une fois sur la page de login, on saisit le login et le password là aussi fourni et on arrive sur l’interface d’administration.

  * Créer une connexion à distance

Dans la section « Remote Console » du menu du même nom, cliquer sur « Web Start » :

![](/2017/07/proxmox-install_ilo-remote-connection.png)

Après avoir validé les (au moins) 62 messages de sécurités liés à Java, une dernière fenêtre de navigateur s’ouvre avec normalement un écran noir puisque aucun OS n’est installé.

  * Monter l’ISO de Proxmox VE

Via le menu « _Virtual Drive_« , sélectionner « _Image File CD/DVD-ROM_ » :

![](/2017/07/proxmox-install_remote-console-image-file.png)

Une nouvelle fenêtre s’ouvre pour sélectionner l'emplacement de l’ISO sur votre disque dur. Il ne reste ensuite plus redémarrer le serveur en utilisant « _Reset_ » dans le menu « _Power Switch_« .

Lors du redémarrage (plus ou moins long), vous devriez voir s’afficher les étapes du POST puis l’interface d’installation de Proxmox.

![](/2017/07/proxmox-install_ilo-reboot.png)

Si ce n’est pas le cas, vérifier que le lecteur de CD est bien avant le disque local dans la liste des périphérique de démarrage du menu « Virtual Media » > « Boot Order ».

#### L’installation de Proxmox ... enfin

  * Sélectionner le premier choix « _Install Proxmox VE_ » :

![](/2017/07/proxmox-install_remote-console-iso-screen-1.png)

  * Lire (ou pas) et accepter les termes de la license GNU Affero

Pour information et car on aime apprendre (ou réviser) en s’amusant :

> [**GNU Affero General Public License**][25], abrégée **AGPL**, est une [licence libre][26] [copyleft][27], ayant pour but d’obliger les services accessibles par le réseau de publier leur code source. Basée sur la [licence GPL][28], elle répond à un besoin du projet Affero, qui souhaite que tout opérateur d’un service Web utilisant leur logiciel et l’améliorant publie ces modifications.

  * Configurer les disques

Une fois sur l’écran suivant, on va configurer la répartition de la volumétrie sur les différents « Logical Volumes » crées par l’installeur. Sélectionner le disque cible voulu, si vous en disposez de plusieurs, puis cliquer sur « _Options_« . Voilà, à titre d’exemple, les valeurs que j’utilise :

![](/2017/07/proxmox-install_remote-console-iso-screen-3.png)

Comme je suis sympa voilà une explication (traduction) des différents paramètres issus du site officiel :

Sur le disque sélectionné ci-dessus va être crée un PV rattaché à un VG appelé « pve » puis au sein de ce VG, 3 LVs : « root », « data » et « swap ».

* _hdsize :_ Spécifie la taille qui va être allouée au VG « pve ». Elle correspond à la totalité de la volumétrie du disque (ou de la partition) choisie mais on peut la réduire si on souhaite conserver de l’espace.
* _swapsize :_ Ici rien de compliqué, c’est la taille du volume utilisé pour le swap. Sachant que par défaut elle est équivalente à la taille de la mémoire physique avec un maximum 8 Go.
* _maxroot :_ Désigne la taille maximum du LV « root » qui sera monté sur / dans la limite du quart de la valeur de _hdsize_ (Ok .. un peu capilotracté mais ça se comprend)_._
  

* _maxvz :_ (Là en revanche, faut être attentif !) C’est la taille maximum du LV « data » calculé comme suit : _datasize_ = _hdsize_ - _rootsize_ - _swapsize_ - _minfree_ ... prenez un peu de temps, je vous laisse méditer si besoin  ...

* _minfree :_ C’est l’espace libre qui doit être conservé dans le VG « pve ». Sa valeur sera de 16 Go si la taille du VG (_hdsize_ pour ceux qui n’ont pas décroché) est supérieure à 128 Go ou de _hdsize_ /8 si _hdsize_ < 128 Go.

Voilà j’ai essayé d’être le plus clair mais n’hésitez pas à consulter le paragraphe « Advanced LVM Configuration Options » de [la page source][30] si besoin. Allez on continue ...

  * Paramétrer le pays, le fuseau horaire et l’agencement du clavier, puis valider

![](/2017/07/proxmox-install_remote-console-iso-screen-4.png)

  * Renseigner le mot de passe et le contact mail de l’admin

Pour ceux qui ont l’habitude des console IPMI, rien de spécial, pour les autres, sachez que le mappage clavier est en QWERTY ! Je vous conseille donc d’utiliser un mot de passe simple (qu’on se dépêchera de changer par la suite) pour éviter de devoir faire la correspondance entre ce que vous pensiez avoir écrit en AZERTY et ce que vous avez réellement écrit en QWERTY. Ça parait surement très bête mais imaginez si vous devez faire l’exercice sur un mot de passe complexe de 20 caractères ... (on rigole moins tout de suite). On peut aussi utiliser le champ en clair de l'email puis faire un copier/coller via le menu « _Keyboard_ » de la console. Personnellement j’évite cette méthode car l’@ peut être très compliqué à retrouver si vous l’effacez.

  * Configurer le réseau

Si vous êtes sur un réseau bénéficiant d’un serveur DHCP, ce qui est le cas chez OneProvider et à priori tous les hébergeurs, vous n’avez rien à faire, les champs seront renseignés automatiquement par les données du bail obtenu. Vous pouvez en revanche spécifier un nom d’hôte personnalisé (au format FQDN) si vous disposez d’un nom de domaine. Profitez-en également pour noter votre @IP publique si ce n’est pas déjà fait pour pouvoir accéder à votre serveur en SSH et via la WebUI ... ce sera utile pour la suite.

  * S’auto-congratuler

![](/2017/07/proxmox-install_remote-console-iso-screen-7.png)

## Rejoindre la ZR

> **Voilà le parachute est plié (bourré en vrac) dans sa housse et vous avez rejoint la zone de rassemblement au pas de course avec vos 60 kilos sur le dos ... la vrai mission va commencer ...**

En effet vous disposez à présent d’une belle installation toute propre de votre serveur ... totalement vulnérable avec son mot de simple à six caractères et son iptables en mode ACCEPT ALL. Il va donc  falloir se dépêcher de le sécuriser car pour l’instant il est à la merci de tous les « scripts kiddies » qui écument « l’internet du web ».

Mais ne vous inquiétez pas, on va s’occuper de tout ça dans [la deuxième partie de cette article](/2017/07/18/deploiement-de-proxmox-ve-5-sur-un-serveur-dedie-part-2/) ... (c’est bien foutu quand même) ... et promis j’arrête les pseudo-analogies militaires !

 [5]: https://www.digitalocean.com/
 [6]: https://www.kimsufi.com/fr/
 [7]: https://www.seedhost.eu
 [8]: https://my.pcloud.com/
 [9]: https://www.amazon.fr/b?node=12935596031
 [10]: https://gsuite.google.fr/intl/fr/pricing.html
 [11]: https://www.tophebergeur.com/hebergement/serveur+dedie/
 [13]: https://www.proxmox.com/en/products/proxmox-virtual-environment/features
 [14]: https://www.pfsense.org/getting-started/
 [16]: http://kimi.nwwebsites.co.uk/
 [17]: https://www.kimsufi.com/fr/manager
 [20]: https://pve.proxmox.com/wiki/Downloads
 [25]: https://fr.wikipedia.org/wiki/GNU_Affero_General_Public_License
 [26]: https://fr.wikipedia.org/wiki/Licence_libre "Licence libre"
 [27]: https://fr.wikipedia.org/wiki/Copyleft "Copyleft"
 [28]: https://fr.wikipedia.org/wiki/Licence_publique_g%C3%A9n%C3%A9rale_GNU "Licence publique générale GNU"
 [30]: https://pve.proxmox.com/wiki/Installation
