---
title: 'Installer 3 plugins Nagios dans EON 1.2, coupé d’Internet, level 1'
authors:
  - zwindler
type: post
date: 2010-09-03T12:47:18+00:00
url: /2010/09/03/installer-3-plugins-nagios-dans-eon-1-2-coupe-dinternet-level-1/
image: /2010/09/icone_EON.png
categories:
  - Monitoring
  - Virtualisation
tags:
  - check_esxi_wbem.py
  - ESX(i)
  - EyesOfNetwork
  - Nagios
  - Python
  - snmp

---
J’aimerai vous faire partager certains de mes déboires pour installer 3 malheureux plugins Nagios sur mes deux [EyesOfNetwork](http://www.eyesofnetwork.com/?page_id=48&lang=fr) en production. Évidemment, dans un environnement bien maitrisé, connecté à Internet, ce serait risible d’écrire un article pour si peu. Malheureusement, EyesOfNetwork, surtout dans sa version 1.2, impose certaines limitations, et le fait d’être coupé d’Internet en impose encore plus.

Bon alors, c’est sûr, cet article ne va pas toucher beaucoup de monde. Le nombre d’utilisateurs d’EyesOfNetwork 1.2 (2.15 FTW!) dans un environnement offline ne doit pas atteindre des sommets, et la plupart de ces personnes-là sont probablement capables de se débrouiller seules. Mais bon, qui sait...

Comme vous le savez très certainement si vous avez décidé de lire la suite de cet article, Nagios, ou plutôt son cœur, a pour but d’ordonnancer une série de vérifications à effectuer sur votre matériel et les services qui en dépendent. Ces vérifications sont faites, non pas par Nagios lui-même, mais par une foultitude de petits scripts et autres outils (sondes, ou plugins).

Et c’est là toute la force de Nagios : Si un équipement ou un service un peu exotique n’a pas son plugin pré-installé avec Nagios, qu’à cela ne tienne! Un utilisateur de la communauté a probablement écrit un plugin lui correspondant. Et au pire, vous pouvez toujours en modifier un similaire si vos besoins ne sont pas satisfait, ou même en écrire un autre (en utilisant SNMP, une api spécifique au produit...).

Pour mes besoins personnels, j’ai voulu ajouter les trois sondes suivantes :

  * [check_esxi_wbem.py (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20131212160532/https://communities.vmware.com/docs/DOC-7170)) (vérification du hardware d’un serveur VMware ESXi)
  * [check_esx3 (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20110529065507/http://git.op5.org/git/?p=nagios/op5plugins.git;a=blob_plain;f=check_esx3.pl;hb=HEAD) (outils très complet pour superviser plusieurs variables tels que la charge CPU, mémoire, réseau, pour toutes les VMs, Serveurs, Fermes VMware)
  * [check_mssql_health (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20241008021558/https://labs.consol.de/nagios/check_mssql_health/) (sonde de vérifications diverses pour les bases de données Microsoft SQL Server 2000 ou mieux, utile pour la base MSSQL Express d’un petit vCenter, par exemple)

Dans ce premier article, le vais commencer simple, avec **check\_esxi\_wbem.py**, histoire de se mettre en jambe. Déjà, il peut être intéressant de savoir à quoi sert de plugin. Vous l’aurez surement remarqué si jamais vous disposez d’un serveur VMware, il existe un onglet dans le client vSphere (ou VI Client pour Infrastructure) qui permet de superviser en temps réel une série de paramètres hardware de votre serveur. Habituellement, on irait chercher ses paramètres en discutant aimablement avec le serveur en SNMP de l’hyperviseur (comme pour ESX, par exemple).

Cependant, (je ne sais pas si c’est une limitation complète ou juste pour la version gratuite), VMware à simplement désactivé le support de SNMP dans ESXi. Je dis bien « désactivé », car pour ceux qui connaissent un peu ou qui ont lu mes précédents articles, ESXi n’est en fait qu’une distrib Linux minimaliste (Busybox modifié), mais pas minimaliste au point de ne pas supporter SNMP ! Je n’ai pas essayé, mais les premiers liens dans Google pour la recherche « activer snmp esxi » vous indiqueront très certainement comment faire.

Bon... SNMP est désactivé, mais vSphere client arrive bien à avoir des informations, lui!?! Comment fait il ? Tout simplement comme tout le reste de ce qu’il fait : en utilisant l’API VMware pour donner des ordres aux hyperviseurs (création de VM, allumage/extinctions de VMs, du serveur, ajout d’un disque virtuel...).

Dans votre pseudo-console de configuration de ESXi (si si, l’espèce de mocheté, jaune et grise, après l’install!), vous aurez probablement déjà vu la ligne « Restart Management Agents ». **Management agents** fait référence à un démon (au sens Unix du terme, hein...) appelé **hostd**. En fait, ce n’est ni plus ni moins qu’un serveur web un peu spécial. Il est utilisé par le client vSphere pour commander le serveur ESXi via des requêtes HTTPS sur le port 8333. Mais là où ça nous intéresse, c’est que les outils vCLI et PowerCLI utilisent le démon, avec le même protocole. En théorie, il est donc possible de faire tout ce qu’on peut faire dans le client vSphere (dont le monitoring du hardware du serveur) en ligne de commandes.

Je vois déjà les yeux de tous les « scripteurs fous » s’allumer de désir. Calmez vos ardeurs, gens du monde du libre, la version non licenciée de ESXi (comprendre « gratuite ») est bridée aux actions en lecture seule pour tout ce qui est scripting. Oui, c’est très frustrant!

Relativisons cependant, pour lire l’état d’un serveur, « Lecture Seule » reste suffisant. En partant de ce principe, la communauté nous a pondu un script en python, qui nous permet de superviser le hardware nos ESXi! Cependant, pour fonctionner, ce script nécessite l’installation d’un module python complémentaire, que nous allons devoir télécharger depuis un autre réseau, puisque nous sommes offline sur notre EON 1.2! Le module à télécharger s’appelle [pywbem](http://sourceforge.net/projects/pywbem/files/). Une fois copié sur votre EON, l’installation est plutôt simple (d’où le level 1, il n’y a jamais de challenge au level 1).

```
# tar xvzf pywbem-[version].tar.gz
# cd pywbem-version
# python setup.py build
# python setyp.py install
```

Une fois ce module installé, le script peut être utilisé. Pour ceux qui débutent avec EON, l’ensemble des outils sont installés dans le répertoire **/srv/eyesofnetwork/**, ce qui n’est pas du tout un dossier d’installation « standard » pour la plupart des outils que nous voudront installer plus tard, d’où d’éventuels micmacs lors des installations. Le script check\_esxi\_wbem.py est donc à placer dans le dossier **/srv/eyesofnetwork/nagios-[version]/plugins/**.

Certaines personnes préfèrent séparer les plugins officiels (ceux fournit lors de l’install de Nagios) des plugins additionnels, et préfèrent les installer dans le dossier **/srv/eyesofnetwork/nagios/libexec**. A vous de décider une fois pour toutes, dès le début, puis de s’y tenir après. C’est vrai que c’est plus « propre », mais est-ce vraiment utile ?

Maintenant, vous pouvez admirer le résultat (il est préférable de tester le script avec l’utilisateur **nagios**, pour éviter les bêtes problèmes de droits) :

```
# su nagios
$ ./check_esxi_wbem.py [@IP_serveur_ESXi] [login_ESXi] [password_ESXi] [dell | hp]
```


Le dernier paramètre doit impérativement être dell ou hp, car le script ne gère que ces deux constructeurs (à l’heure actuelle), et va chercher des informations qui sont spécifiques au constructeur choisit.

Une fois que le retour de la sonde est correct

```
$ exit
```

Bon... pourquoi je râle ? Après tout, ce n’était pas si dur, juste un petit module de rien du tout à installer ! Rigolez si vous voulez, le prochain level ne sera pas aussi marrant...

Ah oui, pour finir, j'aimerais rappeler le petit tuyau d’Huggy :

> Pour profiter de TOUTES les informations sur le hardware de votre serveur, votre ESXi (dans sa version 4, je ne suis pas trop sûr que ça soit encore exact) doit avoir être été installé avec la version de l’iso d’ESXi spécifique à votre constructeur.  
> Ainsi, pour un serveur HP, si vous avez la version « normale » d’ESXi 4.0 ou 4.0 U1, vous n’aurez par exemple pas l’état des disques du RAID, ce qui est dommage, vous en conviendrez.
