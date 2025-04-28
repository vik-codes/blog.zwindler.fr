---
title: 'Au secours, le métier d’Ops va disparaître !'
authors:
  - zwindler
type: post
date: 2020-07-29T08:00:00+00:00
excerpt: "Billet d'humeur pour démonter l'idée que le métier d'Ops est voué à disparaitre, comme certains voudraient nous le faire croire"
url: /2020/07/29/au-secours-le-metier-dops-va-disparaitre/
image: /2020/07/charlie.jpeg
categories:
  - Divers
tags:
  - dev
  - devops
  - humeur
  - noops
  - ops

---

## Echo au post d’Olivier Poncet, version Ops
  
  
Il y a une semaine, Olivier Poncet a posté un long article intitulé [Je fais partie d’une espèce menacée d’extinction](https://www.emaxilde.net/posts/2020/07/18/je-fais-partie-d-une-espece-menacee-d-extinction.html), dans lequel il raconte, entre autres choses, qu’il ne reconnaît plus son métier.

Je vous conseille d’aller le lire, il y parle de beaucoup de choses qui sont vraies pour tous les métiers de l’IT.

Un des sujets qu’Olivier aborde est l’arrivée des magiciels, du cloud et du NoCode. Vous savez, tous ces bidules magiques qui vous promettent de pouvoir faire un business dans l’IT sans en faire (de l’IT).



> En filigrane, les développeurs sont nuls et le nocode permet de copier Airbnb en 1 week end

N’étant pas développeur (je bidouille du Python pour le fun), l’article a pour autant réveillé en moi un article similaire que je rumine depuis des années. Ce brouillon avec ses premières phrases traîne depuis 2016 si on en croit la date dans WordPress...

On va rentrer tout de suite dans le vif du sujet : ça fait des années qu’on nous prédit la fin du métier d’Ops (ou tout autre variante, Sysadmin, NetOps, DBA, ...). C’est vraiment pas de bol que j’en ai fais mon métier (passion).

TL;DR. je ne crois pas une seule seconde que le métier d’Ops va disparaître.

## The end is nigh!
  
  
Retour en arrière.

On est en 2013. Je commence tout juste à être un admin correct, à savoir _à peu près_ de quoi je parle et être pertinent sur 2-3 sujets niches ([Vulture](/recherche/?keyword=vulture), [Shinken](/recherche/?keyword=shinken), ...). Je me décide à créer un compte Twitter pour pouvoir en discuter avec mes pairs.

Et là, c’est le drame. Un des premiers tweets que je lis, que je n’ai malheureusement pas su retrouver, qui disait :

> Sysadmins, you should learn how to code quickly. With cloud adoption, you will soon be out of a job.
  
  
Et c’est drôle, car c’est littéralement le pitch de l’article d’Olivier Poncet, qui a l’impression que l’industrie lui explique qu’il appartient à une espèce en voie d’extinction.

> STEVEN SPIELBERG: « You’re out of a job »

## Back to my tweet
  
  
En lisant le tweet de 2013 qui me prédisait une fin proche et douloureuse, sur le moment, je me suis dit : "comment quelqu’un qui travaille dans l’IT peut écrire un truc aussi stupide ?" (En bien moins poli).

Et pourtant, les années passant, il faut se rendre à l’évidence. Même dans un monde où on prône* le DevOps depuis plus de 10 ans, cette croyance est finalement assez bien ancrée dans une partie de la communauté.

*Une des premières personnes que j’ai _follow_ sur Twitter, @bitfield en parle depuis 2009 et je suis sûr que d’autres en parlent depuis bien plus longtemps...

Les Ops, ces techosses chevelus confinés au sous-sol, à la IT crowd, sont voués à disparaître.


![](/2020/07/it_crowd.jpeg)


> Hello IT. Have you tried turning it off and on again?
  
  
## Avant-hier, l’automatisation
  
  
D’abord, on nous a promis que les Ops allaient disparaître à cause de l’automatisation de l’infrastructure.

> Chef, Puppet, Ansible, ... plus besoin d’être un Ops pour faire de l’Ops. Je peux installer/mettre à jour des softs en quelques lignes de YAML !

Dans l’absolu, ouais... D’ailleurs, j’ai même donné une conf à BDX.IO là-dessus, avec comme titre "[Ami développeur, deviens un ops sans effort avec Ansible](/2018/11/09/bdx-i-o-2018-ami-developpeur-deviens-un-ops-sans-effort-avec-ansible/)".

Mais c’était plus pour avoir un titre accrocheur qu’autre chose, car une fois installé, qui va gérer l’infra en cas de problème ?

Même pour régler un problème aussi trivial qu’un filesystem rempli par des logs, il va falloir que quelqu’un fasse de l’opérationnel : vider les logs, le temps de corriger la verbosité de l’appli... Et on est bien d’accord que dans la vraie vie ça sera pas aussi simple tous les jours.

C’est la raison pour laquelle je ne conseille pas Ansible lorsqu’un Ops junior me demande s’il peut commencer à apprendre le métier comme ça. Ansible, que j’utilise tous les jours, nécessite a minima de comprendre comment ça marche, sous le capot.

C’est comme un mécanicien qui apprendrait uniquement à se servir de la valise et pas comment marche un moteur ou le circuit de refroidissement (attention, semi-troll).

Sans cette compréhension, propre à quelqu’un qui a déjà fait une fois à la main, le temps gagné lors du déploiement sera perdu 10 fois (100 fois ?) quand il y aura un bon gros plantage.

## Hier le cloud
  
  
Quand on parle de la fin des Ops, le suspect n°1 qui revient le plus souvent est sans aucun doute le Cloud.

> Mais c’est quoi, le Cloud ?

Je vous passe la vision des non techniciens, à qui on a vendu que le cloud, c’était le stockage de leurs photos de vacances sur leur iPhone partout dans le monde. Ce n’est pas de leur faute, c’est BFMTV qui leur a dit.

Mais même dans le monde IT, pour beaucoup d’experts (autoproclamés ?), le cloud, ça se limite à une idée floue, à mi-chemin entre le SaaS et le IaaS, qu’il existe une solution magique pour tous les workloads, prête à l'emploi et à payer à l’usage.

Dans ces conditions-là, c’est vrai, les Ops ne servent plus à grand-chose...

J’exagère ? Il y a même une personne, de passage sur un de mes articles, qui a pris le temps de chercher l'email du blog, pour venir m’écrire :

> De nos jours, avec la montée en puissance du cloud, comment un architecte système comme toi s’en sort, alors qu’il suffit d’un clic pour obtenir une instance système ?
  
  
Il faut dire aussi que les gros cloud providers n’hésitent pas à entretenir cette idée (ça les arrange !), comme par exemple dans ce Manga (officiel) édité par Microsoft Azure :

![](/2020/07/azure_static_web_apps.png)

Prend moi pour une buse, Azure

![](/2020/07/azure2.png)

I have no idea what it means

* [github.com/msdevjp/AzureStaticWebApps-ComicBook/blob/master/AzureStaticWebApps_Fullver.pdf](https://github.com/msdevjp/AzureStaticWebApps-ComicBook/blob/master/AzureStaticWebApps_Fullver.pdf) 

## Day 2 operations

Le truc, c’est que, une fois que vous l’avez, cette "instance système" (notez le terme ultra flou), ou cette webapp vous en faites quoi ?

> La question, elle est vite répondue
 
  
Désolé de casser vos rêves, _jeunes entrepreneurs_. Cette solution magique fantasmée, elle n’existe pas.
Au mieux, ce qu’on appelle vulgairement "le cloud", c’est une collection hétéroclite de services, qui, mis bout à bout, vous permettent de faire tourner votre appli. Soit.
Mais :

* Personne ne va les mettre "bout à bout" pour vous.
* Personne ne va s’assurer que tout fonctionne parfaitement, h24...

Je ne vais pas vous détailler la complexité de mon métier (maintenir en ligne des services accessibles dans le monde entier). Pour que vous puissiez appréhender le problème, il me suffit de citer cet excellent article sur la panne en cours depuis jeudi dernier chez Garmin.


* [www.nakan.ch/wp/2020/07/24/indisponibilite-de-garmin-connect-chronique-dune-catastrophe/](https://www.nakan.ch/wp/2020/07/24/indisponibilite-de-garmin-connect-chronique-dune-catastrophe/)


Il n’y a qu’à voir la complexité qu’une entreprise mondiale a pour remettre en ligne Garmin Connect pour comprendre que sans une armée d’Ops, ça ne peut pas marcher, même dans le cloud.

## Il y a carrément des pans entiers de nos métiers qui auront disparu en 2024
  
  
Bon... venant de _so-called expert_ sur LinkedIn ou d’un visiteur sur mon blog,... Admettons.

Mais même Gartner (entreprise de conseil dans les domaines techniques) s’y met !

* [Stockage : les analystes urgent les ingénieurs de changer de carrière](https://www.lemagit.fr/actualites/252476156/Stockage-les-analystes-urgent-les-ingenieurs-de-changer-de-carriere)

> Le cloud et l’hyperconvergence ont à ce point réduit la demande pour des spécialistes du stockage que, d’ici à cinq ans, il sera tout simplement impossible de trouver un tel profil sur le marché de l’emploi. - Operations & Cloud Strategies de Gartner, fin 2019.
  
Carrément. "tout simplement impossible"

Gartner, nous explique, droit dans les yeux, que dans 4 ans il n’y aura plus dans le monde de baies de stockage opérées par des humains.

Mais alors, ils vont devenir quoi les "ingé sto" ?

> Plus personne n’a vocation à devenir administrateur ou ingénieur en stockage. Les nouvelles générations préfèrent désormais s’orienter vers des carrières de développeurs.
  
Aaah voilà. On y est ! Les Ops c’est _has been_, il faut devenir Dev maintenant monsieur. On en revient au tweet du début de l’article, la boucle est bouclée, je suis moi aussi membre d’une espèce en voie d’extinction.

Dans son article [Kubernetes présent partout, visible nulle part](https://www.linkedin.com/pulse/kubernetes-pr%25C3%25A9sent-partout-visible-nulle-part-didier-girard/)), Didier Girard le VP Engineering de SFEIR nous dit :

> L’infrastructure est le domaine en voie de disparition. Il existe actuellement des racks d’ordinateurs dans des pièces fermées à clé, avec des lumières clignotantes et mystérieuses et beaucoup de ventilateurs qui vibrent.
  
On retrouve le champ lexical de l’espèce menacée, les clichés à la IT Crowd (blip, blip... double blip),...

Si vous lisez l’article, vous verrez que c’est un peu plus nuancé que cette phrase, sortie de son contexte. Mais l’image, elle, est bien présente et selon moi elle alimente dans l’inconscient collectif l’idée que les Ops vont disparaître.

## Incrédulité

Je ne comprends pas que des pros (Gartner) puissent écrire des choses pareilles...

Comment peut-on imaginer les équipes d’infra vont disparaître au profit du tout sur le cloud, dans un monde où il existe encore un nombre incalculable d’entreprises (banques inclues) fonctionnent encore avec ce type de systèmes informatiques avec des interfaces vert/noir 640×480 :

![https://fr.wikipedia.org/wiki/System_i#/media/Fichier:IBM_AS400.JPG](/2020/07/1280px-IBM_AS400.jpg)

Si jamais il y a une transition, n’imaginez pas que ça ait lieu avant 20-30 ans (de manière progressive).

## Et c’est pas fini !
  
  
Et quand on pense que ça peut pas être pire, il y a toujours un esprit malin pour venir inventer autre chose...

_Roulement de tambour_

Maintenant on nous vend du serverless ! Plus besoin de serveurs pour faire marcher votre code, vous l’uploadez sur Internet et à vous les millions ! Enfin débarrassé des Ops...

Hum... vraiment ?

En vrai, on est d’accord qu’il y a bien un serveur pour faire tourner votre code, hein ? Vous n’avez juste plus la main sur la façon dont il est lancé : ce serveur, il est géré par votre fournisseur de service.
  
* Êtes vraiment sûr que cette personne vous aidera quand vous aurez un gros problème de perf, a mi-chemin entre le code (vous) et la plateforme (eux) ?
* Avez-vous vraiment confiance dans le fait que l’opérateur n’analysera pas votre trafic ou les données que vous traitez ?
* Êtes-vous certains que vous n’aurez jamais besoin de modifier un paramètre système ou applicatif, géré par votre hébergeur (qui pourra vous répondre : "non j’ai pas envie") ?
      
  
On pourrait continuer longtemps... Si le serverless, comme n’importe quel outil, a des usecases qui lui sont particulièrement favorables, les usecases où il ne vaut mieux pas en faire sont pour l’instant encore nombreux...

## Toujours plus...
  
  
Et dans la courbe de la hype, on peut monter plus haut.

Depuis quelque temps je vois aussi tourner des articles sur le NoOps. Si vous ne voyez pas de quoi il s’agit ce n’est pas grave, personne ne s’accorde vraiment sur ce que c’est. Moi je le vois comme l’évolution dystopique du DevOps dans laquelle les Devs ne parlent même plus avec les Ops puisqu’il n’y en a plus :-p.

Pas encore assez hype ?

Pas de souci, je vous ajoute de l’IA et vous avez maintenant de l’AIOps...

> Artificial intelligence for IT operations (AIOps) refers to the automation of IT operations tasks through artificial intelligence (AI). AIOps platforms free ITOps and drive better business outcomes, by ingesting operations data to identify and resolve issues automatically.
  
Il ne manque plus que la blockchain et on peut crier Bingo !

Je vais même pas argumenter, je pense que c’est du même niveau que le no-code dont nous parle Olivier Poncet.

## Pourquoi tant de haine ?
  
  
Derrière ces formules chocs qui m’annoncent la fin de mon métier, se cache, je pense, une part de méconnaissance de celui-ci et une part de gloubiboulga marketing.

Ça ne se limite pas au métier d’administrateur système, je pense que tous les métiers avec une "fonction support" (RH, juridique, etc) ont tendances à être vus négativement par les "utilisateurs" qui les sollicitent.

Et ça s’explique.

Les "utilisateurs" ne se préoccupent de l’infrastructure (ou autre) que quand il y a un problème. Ça génère forcément de l’agacement de tous les côtés. Les utilisateurs qui veulent qu’on les dépanne d’un côté, les admins qui doivent gérer le stress qu’on leur transmet tout en résolvant les problèmes vite mais sans empirer la situation de l’autre.

Mais il y a aussi les directions, qui considèrent parfois que ces fonctions "support" n’apportent pas de valeur à l’entreprise (contrairement au dev, qui développe de nouvelles features, monnayables).

Je le redis, ce dénigrement n’est pas limité aux admins. Tout métier "support" vit ce genre de situation, parfois injuste. Combien de fois j’ai entendu dire :

> Les gens ne viennent que pour se plaindre, jamais nous remercier quand ça fonctionne...

## On ne communique pas super bien non plus...
  
  
Bon, une fois que c’est dit, faut pas se voiler la face non plus.

Si on est incompris, c’est peut être un peu dû au fait que la réputation des admins barbus et peu amènes n’est pas toujours injustifiée ;-).

On manque très probablement aussi de bons communicants pour expliquer notre métier, ainsi que pourquoi tout ce que je vous ai cité plus tôt, c’est _pour l’instant_ du bullshit en barre.

Pour avoir passé pas mal de temps en conf, mon opinion, c’est qu’il y a trop peu d’Ops en conf de Dev. Et pour ne rien arranger, il y a peu de conférences Ops (en France) du niveau de qualité et de diversité des sujets traités que dans les conférences de Dev.

Exception faite des conférences de libristes et/ou sécurité qui elles sont souvent très bien, les conférences "connues" d’Ops, c’est au mieux des retours d’expériences, au pire, l’événement d’un constructeur/éditeur (VMware, Microsoft, whatever). Dans ces dernières, on ne parle de rien d’autre que des nouveaux produits géniaux dudit constructeur/éditeur (SAP 29, Exchange 730)...

Pas de quoi intéresser un développeur, encore moins un manager.

## J’ai rien prévu pour demain, mais... c’est déjà bien d’y penser.
  
  
Je vais pas me la jouer prédicateur... Quand je regarde comment l’informatique a changé depuis 2010, difficile de deviner ce que sera le métier en 2030. Pour autant, je suis quand même optimiste.

Il y a 10 ans, on m’a promis la fin du métier d’Ops. Force est de constater qu’aujourd’hui, c’est loin d’être vrai. Je dirais même que c’est le contraire, je pense qu’on n’a jamais autant eu besoin des Ops.

Oui, c’est maintenant trivial de déployer un serveur. Du coup, beaucoup de projets informatiques qui n’auraient pas pu se lancer (ou beaucoup moins vite), faute d’Ops pour bootstraper l’infra, se lancent. Toutes les tâches "sans valeur ajoutée" disparaissent peu à peu.

Mais pour autant, dès qu’un projet prend de l’ampleur, la réalité revient au galop : déployer, c’est facile ; maintenir, c’est une autre paire de manche ! Le fameux "Day 2 operations" que je vous ai cité un peu plus haut.

Pire ! Pour palier à la pénurie d’Ops, on a tendance à mettre en place des systèmes de plus en plus complexes (loadbalancers, clusters, virtualisation, multicloud, Kubernetes pour les plus foufous). Et plus les systèmes sont complexes, plus on se rend compte qu’il faut d’Ops pour les maintenir.

## Roald Dahl à la rescousse
  
  
J’ai lu quelque part une comparaison qui m’a fait sourire car ça m’a rappelé mon enfance quand je lisais du Roald Dahl.

Au début du film de Tim Bruton Charlie à la chocolaterie, adapté du livre de Roald Dahl, le père de Charlie perd son travail à l’usine, remplacé par une machine (je sais plus si cette scène existe aussi dans le livre, sorry).

Le _cloud_ et _l’infrastructure as code_ sont 2 moteurs qui font évoluer de manière rapide le métier d’administrateur systèmes. Une partie toujours plus importante des tâches d’hier sont en train de disparaître (doucement) : le plus simple, le plus automatisable. D’où le fantasme que le métier va disparaître.

Mais en réalité, c’est que cela ne va pas nous conduire à _moins_ de systèmes à maintenir, mais des _systèmes plus complexes_.

A la fin du film, le père de Charlie retrouve un emploi à l’usine, en tant que réparateur de la machine qui l’a remplacé.


![](/2020/07/charlie_2.png)

Je le concède volontiers, cette comparaison est un peu triviale, mais je pense qu’il y a du vrai dans cette image, car c’est ce que je vis depuis 10 ans.

Cette transition vers moins de tâches à faible valeur ajoutée va nous permettre de dégager le temps des admins pour se concentrer sur tout ce qui a vraiment de la valeur ajoutée : l’architecture, l’amélioration continue, l’expertise lors de crises.

Alors, en attendant la fin du métier d’Ops, have fun ;)
