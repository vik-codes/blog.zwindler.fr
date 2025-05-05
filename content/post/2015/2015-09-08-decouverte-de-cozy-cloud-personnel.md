---
title: Découverte de Cozy (Cloud personnel)
authors:
  - zwindler
type: post
date: 2015-09-08T10:30:06+00:00
url: /2015/09/08/decouverte-de-cozy-cloud-personnel/
image: /2015/09/cozy_logo.png
categories:
  - autohebergement
  - DIY
tags:
  - Cloud
  - Cloud personnel
  - Cozy
  - debian
  - Docker
  - OpenVZ
  - Ubuntu

---
## Cloud Personnel

Aujourd’hui on va parler de Cloud personnel. Pourquoi aujourd’hui ? Parce que le Cloud personnel, ça n’a d’intérêt que lorsque vous avez un bon débit montant, et c’est maintenant mon cas grâce au VDSL2 (youhou!).

Quand on parle de Cloud personnel, on parle souvent d’OwnCloud. On trouve des dizaines (mon côté « Marseillais » brule d’envie de dire « des milliers!!!1!1! ») de tutoriels ou d’articles sur le web qui parlent d’OwnCloud. A tel point que pendant longtemps j’ai cru qu’il n’y avait QUE OwnCloud.

Alors je l’ai installé et j’ai essayé de mettre en ligne pour mes proches mes photos de vacances (comme l’autre fait très bien un Synology par exemple) et j’ai assez vite déchanté. Pour une raison que je n’ai jamais expliqué, OwnCloud est lent à afficher mes photos. Très lent. Et ce n’est pas une problématique réseau, car j’avais les mêmes soucis en local. Ce n’était pas une problématique de ressources non plus car je lui ai donné une machine virtuelle avec 4vCPU (sur un Core i7) et 8 Go de RAM, bien au delà de la configuration recommandée. J’ai mis à jour en version 6, puis en 7, puis en 8. Sur CentOS, sur Ubuntu.

Sans jamais résoudre le problème.

## Own... en fait non. Cozy Cloud

Alors aujourd’hui, j’ai envie de ne plus parler de OwnCloud, mais de Cozy Cloud. Parce qu’en fait Cozy, ça existe depuis quelques temps déjà et ça fait tout aussi bien qu’OwnCloud (au moins dans les grandes fonctionnalités) :

  * Synchronisation de fichiers
  * Agenda
  * Contacts
  * Il y a même un magasin d’applications pour étendre les possibilités à votre convenance.

Au même titre qu’OwnCloud, il s’agit d’un logiciel libre et des gens engagés y participent (entre [autre][1]). Le [site web][2] m’a tout de suite donné envie d’essayer : simple, clair, efficace.

Vous n’êtes toujours pas convaincus ? Allez voir [la démo][3] ! C’est un avis personnel, mais niveau ergonomie on est bien loin de l’interface vieille école d’Owncloud, il n’y a pas photos... Jugez par vous même !

![](/2015/09/cozy_comp_01.png)

> Owncloud à gauche, Cozy à droite. Je sais lequel des deux je choisi !

## Installation

Quant à la documentation d’installation, elle est assez clair et on a le choix entre plusieurs options relativement populaires (qui a dit « Hype » ?) comme des conteneurs OpenVZ, Docker, ... au côté des classiques Debian et Ubuntu (j’aurai aimé une CentOS... #mébon).

![](/2015/09/cozy02.png)

> Docker ... Raspberry ... Debian ? Mon cœur balance

Je ne vais pas faire un copier coller de la documentation officielle, mais c’est relativement simple.

Seul petit point d’accrochage (totalement de mon fait), avec une Debian 8.2 vierge, je n’ai pas réussi à installer une des dépendances qui m’a bloqué pour l’installation de Cozy.

```
apt-get install ca-certificates apt-transport-https

Lecture des listes de paquets... Fait
Construction de l'arbre des dépendances
Lecture des informations d'état... Fait
E: Impossible de trouver le paquet apt-transport-https
```


Manquant d’habitudes sur Debian, comme le package [apt-transport-https (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20151123111640/https://packages.debian.org/fr/jessie/apt-transport-https) est dans « main » je pensais pouvoir le télécharger par défaut. Or, par défaut (par sécurité) seules les mises à jour de sécurités et les médias qui ont servis à l’installation sont configurées dans les sources apt après une installation vierge de Debian. Il ne faut pas oublier d’ajouter les « normales » (3ème lien deb) et probablement de retirer le média comme source apt.

```
vi /etc/apt/sources.list
deb http://security.debian.org/ jessie/updates main contrib
deb-src http://security.debian.org/ jessie/updates main contrib
deb http://ftp.de.debian.org/debian jessie main
```


Cozy a la gentillesse de vous prévenir que pour importer des calendriers provenant d’une source avec un certificat autosigné nécessite une manipulation. J’en parlerai plus quand on y sera.

![](/2015/09/cozy03.png)

## Bémols

Alors tout n’est pas non plus parfait et ce n’est pas aujourd’hui que je suis tombé sur l’application de mes rêves.

### l’usage familial

Question de philosophie, Cozy n’est pas multi-utilisateur. Et ça n’a pas l’air prêt de changer si on en croit ce post sur le forum (lien mort, pas trouvé sur Internet archive).

Mais du coup, pour un usage collaboratif familial, ce n’est pas l’idéal, car il n’y a pas de moyen simple de créer une instance par personne si vous n’avez qu’un Raspberry sous la main.

Une solution de contournement proposée par l’équipe de développement consiste à déployer un Cozy pour chaque membre de la famille, par exemple à l’aide de conteneurs Docker (ou plusieurs VMs mais bon c’est probablement overkill).

Bonus points pour le SysAdmin bien Geek que je suis : je cherchais une excuse pour installer Docker à la maison, elle est toute trouvée. Mais pour les autres, il faut reconnaître qu’il y a plus simple...

### Les photos de vacances

Autre problème car c’est quand même le cas d’usage qui m’a fait abandonner OwnCloud (ça et **l’absence d’ergonomie** !!!). Comme tout fonctionne en WebDAV, à priori il n’est pas possible de donner à Cozy l’accès à mes photos déjà stockées sur mon NAS. Si je veux montrer mes photos aux membres de ma famille, il faut donc que je les uploade au préalable sur Cozy, ce qui n’est ni pratique ni efficace. On perd donc ([pour l’instant (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150316170407/https://forum.cozy.io/t/synchro-cozy-cloud-systeme-de-fichiers/317)) également cet usage qui me plairait pourtant bien.

## Ma conclusion

Maintenant que ma première instance fonctionne, j’ai hâte de tester en long/large/travers dans les jours qui viennent. En quelques clics, l’ensemble de mon agenda Google et mes contacts étaient importés et j’avais installé plusieurs applications supplémentaires provenant du « Cozy Store ». C’est vraiment bien fait, très ergonomique et très fluide.

![](/2015/09/cozy041.png)

La configuration « post installation » est extrêmement simple. Vous rentrez un nom, un mail de secours, une timezone. Ensuite, Cozy vous propose un « pont » automatique vers un compte gmail. Vous vous authentifié et tout Gmail est importé dans Cozy.

Même si a priori pour l’instant ça ne répond pas à tous mes problèmes, je ferai d’autres articles sur Cozy (notamment sur ses « applications », peut être un tutoriel?) car :

  * Le Cozy Market a plusieurs applications qui me sont utiles et qui sont aujourd’hui hébergées sur des machines virtuelles dédiées
  * Owncloud, ce n’est pas intuitif et c’est lent (au moins pour moi)/Cozy c’est intuitif et c’est fluide
  * Cocorico (oui, c’est un projet Français et libre)
  * Ça me donne une bonne raison d’installer Docker (at last!)

 [1]: http://standblog.org/blog/post/2015/03/11/Je-rejoins-Cozy-Cloud
 [2]: https://cozy.io/fr/
 [3]: https://demo.cozycloud.cc/
