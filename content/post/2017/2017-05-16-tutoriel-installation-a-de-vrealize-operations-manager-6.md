---
title: '[Tutoriel] Installation pas à pas de vRealize Operations Manager 6'
authors:
  - zwindler
type: post
date: 2017-05-16T12:00:44+00:00
url: /2017/05/16/tutoriel-installation-a-de-vrealize-operations-manager-6/
image: /2017/05/vrom_logo.png
categories:
  - Monitoring
  - systeme
  - Virtualisation
tags:
  - vRealize Operations Manager
  - vROM

---
## vRealize Operations Manager, c’est quoi ?

Une fois n’est pas coutume ! Cet article déroule pas à pas toute l’installation et la configuration de base d’un serveur **vRealize Operations Manager**.

Pour ceux qui ne connaissent pas le produit, il s’agit d’un logiciel d’outillage de VMware qui permet notamment d’avoir une vue d’ensemble de son infrastructure VMware, avec une vue consolidée des alertes, mais surtout d’avoir une analyse de la capacité actuelle, de projections sur les besoins futurs, avec un focus en mode _drill down_ sur tous les composants du datacenter.

![](/2017/05/vrops28.png)

Je vous invite à consulter la documentation officielle (lien mort, comme tout chez VMware) pour plus d’informations.

## Prérequis

### Ressources

D’abord, il faut savoir que comme la plupart des produits VMware, vRealize Operations Manager consomme une quantité non négligeable de ressources, surtout pour un lab (avec peu de RAM). La consommation de votre vROM dépendra de la taille de votre infrastructure. Heureusement, VMware fourni des guides pour chaque versions :

  * lien vers tous les guides (lien mort, comme tout chez VMware)
  * guide de la 6.0 (lien mort, comme tout chez VMware)
  * guide de la 6.5 (lien mort, comme tout chez VMware)

Dans mon lab, je me suis donc contenté du minimum, à savoir 2 vCPU et 8 Go de RAM.

### Installation

Il est facile pour les non-experts de se perdre parmi les nombreux d’outils complémentaires proposés par VMware et dans les procédures pour les installer et le exploiter.

Heureusement, un des points forts de VMware sont leurs gros efforts en termes de documentation et de simplification d’installation de leurs outils. C’est notamment le cas lorsque vous utilisez les appliances de types OVF/OVA qui vous permettent une installation simplifiée. On peut rapidement tester un outil et s’assurer qu’il répond bien au besoin.

La première chose à faire ici est donc de télécharger le fichier OVA de l’appliance virtuelle, qui nous permettra de faire nos premiers tests avec l’outil vRealize Operations Manager.

![](/2017/05/vrops_dl.png)

## Déploiement de l’appliance

Le déploiement de l’appliance en elle même étant rapide (beaucoup de <suivant>/<suivant>/<suivant>), on commence le tutoriel après son déploiement et le premier boot :

![](/2017/05/vrops1.png)

L’installation automatique s’est bien passée, on peut donc se connecter sur l’interface web avec l’URL indiquée dans la console (ou le nom d’hôte de la machine si vous l’avez configuré avec votre DNS).

![](/2017/05/vrops2.png)

Dès le démarrage, un utilitaire de type wizard vous guide pour la configuration de votre outil

![](/2017/03/vrops3.png)

Les premiers écrans sont assez triviaux (login admin, sélection d’un certificat si vous en avez un pour cette machine, etc)

![](/2017/03/vrops4.png)

![](/2017/03/vrops5.png)

D’expérience, et particulièrement depuis la version 6, il faut faire très attention avec l’aspect résolution de nom pour les appliances virtuelles. C’est vrai aussi pour le [vCenter (virtual appliance)](/recherche/?keyword=vcenter) ou [vSphere Replication](/2016/01/02/installation-et-configuration-de-vmware-vsphere-replication-6-1-0/).

N’allez pas donc au delà de cette étape sans que les DNS soient correctement configurés et que votre nom d’hôte soit bien « résolvable ».

![](/2017/05/vrops6.png)

## Configuration du cluster vROM

A partir de là, la plateforme n’est pas encore totalement opérationnelle. Seul l’OS et les composants logiciels sont installés et configurés à un bas niveau. Pour autant, l’application en elle même n’est pas démarrée et je ne parle même pas de configurer les connexions vers les hôtes VMware.

![](/2017/05/vrops7.png)

On commence déjà par démarrer le cluster vRealize Operations Manager (ici une seule machine) actuellement éteint.

![](/2017/05/vrops8.png)

Dès qu’on clique, un nouveau « wizard » nous informe que si nous souhaitons ajouter des nœuds vROM supplémentaires avant de démarrer. Je ne connais pas l’impact de démarrer sur une seule machine puis d’en ajouter une autre par la suite. Naïvement je ne vois pas le problème. Cependant le fait que le système commence par nous prévenir d’ajouter les nœuds supplémentaires AVANT de démarrer l’outil est un point de vigilance qui méritera d’être étudié.

![](/2017/05/vrops9.png)

Une fois que nous avons validé que nous voulons bien démarrer le cluster, l’utilisateur administrateur est déconnecté et nous sommes renvoyés sur la mire de connexion. Un message nous informe que l’installation de vROM est un succès.

![](/2017/03/vrops10.png)

Une fois re-logué, nous pouvons une nouvelle fois suivre un wizard supplémentaire ! La première chose à indiquer est si le cluster est nouvellement créé (notre cas ici) où si on repart d’un existant, à importer.

![](/2017/03/vrops11.png)

Après avoir accepté le contrat de licence, on nous demande une clé produit. Si vous testez l’outil comme moi, vous pouvez laisser l’option « Evaluation du produit » qui vous permet de tester pendant 60 jours. Passé ce délai en revanche, vous serez coincés et il faudra vous rapprocher de votre contact chez VMware.

![](/2017/03/vrops12.png)

## Ajouter un cluster VMware

ENFIN ! On peut configurer notre premier cluster vSphere à surveiller !

Il existe par défaut deux types d’adaptateurs (bête traduction de l’anglais « adapter » qui peut aussi se comprendre comme « connecteur ») :

  * Un connecteur vers vCenter
  * Un connecteur Python vers vCenter (probablement via le module python [**pyvmomi**][22])

Je ne suis pas bien certain de comprendre quel est l’intérêt de nous donner accès à ces deux connecteurs. Le premier fonctionne parfaitement.

On se contente de renseigner un nom d’affichage, un nom d’hôte pour se connecter au vCenter, puis on ajoute les informations d’identification. Comme c’est votre premier passage sur cet écran, il est probable que vous n’ayez encore rien renseigné et vous ne pourrez pas remplir cette partie.

![](/2017/05/vrops13.png)

Heureusement, il est possible d’en ajouter une en cliquant sur « **+** » sans pour autant quitter le menu en cours.

![](/2017/05/vrops14.png)

Petit aparté : je vous conseille de créer un utilisateur disposant d’une connexion de type _lecture seule_ dans vCenter sur l’ensemble du cluster.

C’est suffisant pour l’outil et le fait de créer un utilisateur dédié (au delà des bonnes pratiques _sécurité_) vous permettra également de restreindre finement l’accès de vROM à certaines parties de l’infrastructure.

En effet, sauf erreur de ma part, il n’est pas possible d’exclure certains objets (certains datastores par exemple) à vROM, qui prendra par défaut tous les objets qu’il a en visibilité !

Une fois la connexion créée, vous pouvez tester qu’elle fonctionne (avec le bouton _Tester la connexion_), puis valider. Un écran vous demandera de valider le certificat (s’il est autosigné).

![](/2017/05/vrops15.png)

Une fois l’étape de connexion aux vCenters validée, il reste encore un peu de configuration à faire. La première fois, vROM vous demandera dans dans les grandes lignes comment vous voulez gérer votre infrastructure.

![](/2017/03/vrops17.png)

![](/2017/03/vrops18.png)

Ces informations pourront être modifiées par la suite mais de manière peu évidente. En effet, cette première étape génère la politique par défaut sur laquelle se basera vROM pour surveiller votre infrastructure.

![](/2017/05/vrops22.png)

A partir de maintenant, la collecte est active. Dans un premier temps, seules les alertes sur l’état de santé remonteront (informations immédiates). Pour les alertes sur la capacités restantes et les analyses plus poussées (tendances, temps restant avant pénurie de ressources, ressources inutilisées), il faudra attendre jusqu’à quelques heures.

![](/2017/05/vrops19.png)

![](/2017/03/vrops20.png)

## So far, so good

De ce que j’ai pu tester, vRealize Operation Manager est un très bon outil. Il a répondu a certains de nos problèmes de _capacity planning_ et nous a donné des pistes d’optimisation pour libérer des ressources consommées inutilement :

![](/2017/05/vrops24.png)

Cependant, il n’a pas répondu non plus à toutes nos attentes :

  * Il est presque _trop_ complet : sur une infrastructure avec beaucoup de vécu, la mise en place de l’outil a révélé un nombre extrêmement important d’alertes et de suggestions d’amélioration. Difficile de faire le tri dans la masse, entre les vrais alertes, les vrais gains potentiels, et les faux positifs ;
  * La navigation/l’UI pêche un peu par sa complexité. Le mode _drill down_ est certes extrêmement puissant, mais au premier abord on s’y perd un peu. Sur certaines vues, vROM indique une alerte sur le capacity planning, alors qu’en descendant d’un cran (ou en remontant), l’information n’est plus indiquée et le capteur est au vert ;
  * La modification des politiques est assez complexe. La modification est (trop) riche, trouver un indicateur pour le modifier est peu accessible pour les néophytes.

### Un retour rapide sur le dernier point cité : les politiques

Pour le dernier point, pour vous donner un exemple rapide, je cherchais comment modifier le ratio pCPU/vCPU, la surallocation de RAM et les tampons alloués pour la haute disponibilité au sein du cluster, au delà des simples cases cochées avec le wizard précédent.

![](/2017/05/vrops23.png)

Pour le ratio pCPU/vCPU, cette valeur peut se retrouver lorsqu’on édite la politique appliquée dans vROM, mais on ne peut pas changer la valeur depuis ce menu (paramètres d’analyse) !

![](/2017/05/vrops25.png)

![](/2017/05/vrops26.png)

Il faut trouver la bonne valeur dans le menu suivant, mais trouver le paramètre sera ... compliqué !

![](/2017/05/vrops27.png)

 [22]: https://github.com/vmware/pyvmomi
