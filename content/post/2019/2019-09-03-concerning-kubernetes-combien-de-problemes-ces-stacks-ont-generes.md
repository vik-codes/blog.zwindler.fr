---
title: 'Concerning Kubernetes : « combien de problèmes ces stacks ont générés ? »'
authors:
  - zwindler
type: post
date: 2019-09-03T06:30:16+00:00
excerpt: "Billet d'humeur pour parler de tout ces gens qui considèrent que Kubernetes apporte plus de problèmes qu'il n'en résout"
url: /2019/09/03/concerning-kubernetes-combien-de-problemes-ces-stacks-ont-generes/
image: /2019/07/cropped-concerning_kubernetes.jpg
classic-editor-remember:
  - block-editor
categories:
  - Cluster
  - Virtualisation
tags:
  - hobbits
  - humeur
  - k8s
  - Kubernetes
  - stack

---
 


## La hype, c’est de dire que Kubernetes c’est nul (parce que c’est hype ?)
  
  
Youpi ! Encore un billet d’humeur cette année ;-)

  
J’espère que comme moi, quand vous lisez dans votre tête "Concerning Kubernetes", vous avez l’air de "Concerning Hobbits" de Howard Shore dans la tête :)

  
Aujourd’hui je vais parler de Kubernetes mais rien de technique, seulement un question que je me pose :


> Pourquoi c’est devenu à la mode de dire que Kubernetes c’est pas bien ?

</blockquote>


Alors forcément, en "full disclosure", pour ceux qui ne me connaissent pas, je suis obligé d’indiquer que j’utilise Kubernetes dans mon travail d’Ops depuis environ 2 ans (++). J’en ai d’ailleurs [abondamment parlé ces deux dernières années](/recherche/?keyword=kubernetes).

  
J’ai également utilisé Kubernetes à titre personnel pendant 6 mois, notamment pour héberger mon blog. L’objectif était uniquement d’apprendre Kubernetes par l’usage et je n’ai à aucun moment considéré que ce mode d’hébergement convenait à mes besoins (d’ailleurs, je ne l’utilise plus à titre personnel, maintenant que je sais comment ça marche).

  
## Car oui, Kubernetes c’est un outil

Et comme tout outil, il faut :

* l’utiliser idéalement dans les cas qui correspondent à son usage
* savoir l’utiliser
      


![](/2019/07/Sledgehammer_fly.jpg) 

> File source: https://commons.wikimedia.org/wiki/File:Sledgehammer_(3586724830).jpg 


## Et donc, le cœur du sujet ?
  
  
Donc je l’ai déjà dis, mais ça fait quelques semaines que je vois de nombreuses attaques de personnes différentes qui expliquent que Kubernetes, c’est naze.

  
J’ai classé ces personnes en 4 types d’intervenants sur le sujet.

  
## 1, des Ops
  
  
D’abord, des confrères. La plupart du temps, il s’agit de gens qui n’ont pas utilisé l’outil, ne travaillent pas dans des environnements où Kubernetes pourrait rapidement leur apporter des gains, ou qui n’ont juste pas envie de changer leurs habitudes.

  
Oui, Kubernetes c’est (modérément) complexe. Même Kelsey Hightower, évangeliste Kubernetes niveau super Rockstar de chez GCP (Google) et auteur du guide "Kubernetes the hard way" le clame haut et fort :

![](/2021/tweet_hightower.png)


Utiliser Kubernetes impose d’assimiler un certain nombre de concepts techniques, pour une part inhérents aux architectures microservices containerisées, pour l’autre part spécifiques à Kubernetes lui-même. De même, il faut composer avec un certain nombre de limitations et accepter de travailler différemment (on ne gère pas un serveur web de la même façon dans une VM et dans un container sur un orchestrateur managé).

  
Autant dire que quand un confrère Ops me parle de passer directement d’un environnement bien massif de type IBM AIX et ERP propriétaire vers l’installation d’un Openshift, la première chose que je lui dis c’est "Tu es sûr ? Tu ne veux pas plutôt tester un peu les containers Docker d’abord ?".

  
Dans des cas comme ça, échouer puis reprocher à Kubernetes d’être complexe est un peu malhonnête. Car quand on passe directement d’un mainframe à Kubernetes, on a loupé plusieurs changements dans la façon de travailler dans l’IT de ces 10 dernières années (++).

  
## 2, des hobbyists
  
  
Quasiment à chaque fois que j’écris un article sur Kubernetes, même quand il s’agit d’un truc aussi simple à déployer que [l’offre Kubernetes as a Service d’OVH](/2019/07/09/jai-teste-pour-vous-loffre-kubernetes-as-a-service-dovh/), je me retrouve avec un commentaire du style



![](/2019/07/usineagaz.png) 

Alors, déjà merci, parce que ça me fait toujours sourire ce genre de commentaires sur le blog ;-)

Ensuite : mais par rapport à quoi ?

* A héberger tes photos de vacances sur ton NAS Synology ? Certainement !
* A gérer une plateforme de domotique sur ton raspberry pi ? Sans aucun doute.
* A publier tes 3 billets de blog sur Medium ?
  
Là c’est déjà un peu plus contestable, sachant que tu ne sais pas comment Medium fait pour obtenir un site web utilisé par un grand nombre d’auteurs et de lecteurs, résilient, accessible worldwide et sans plage de maintenance.

  
## Le bon outil
  
  
Vous vous souvenez, au début de l’article, la métaphore de la mouche et du sledgehammer ? Bah on est en plein dedans là.

  
Bien sûr, utiliser Kubernetes pour toutes ces choses n’a pas de sens (publier 3 posts persos lu par 1000 personnes par jour et gérer ta domotique), en tant que particulier.

  
Ça me rappelle beaucoup le débat qu’il y avait eu lorsqu’un transformateur RTE avait brûlé en juillet 2018 et que la gare Montparnasse avait été dans le noir pendant des heures.

  
Tout le monde a hurlé au scandale ("pourquoi vous n’avez pas redondé le truc ???") et des types sont venus nous dire sur Twitter "nianiania arrêtez de dire que c’est pas normal de pas redonder. Est ce que vous avez 2 frigos chez vous, au cas où l’un d’entre eux tombe en panne ?"

  
Je pense que n’importe qui d’un peu honnête peut convenir que des outils d’entreprises comme Kubernetes répondent à des problématiques qu’on ne va pas avoir à gérer quand on est un particulier... Au même titre qu’on peut se permettre de n’avoir qu’un seul réfrigérateur chez soit.

  
Note : pour ceux qui n’ont pas suivi, dans le cas précis de Montparnasse en 2018, [c’était la faute de RTE qui avait garanti à la SNCF que les 3 entrées électriques provenaient de 3 sources différentes, alors que c’était faux](https://www.liberation.fr/france/2018/07/29/montparnasse-le-ton-monte-entre-la-sncf-et-rte_1669534).



## La 3ème catégorie
  
  
Ça fait titre de SF ce sous titre, non ? Ok, je sors => []

  
Dans les gens qui bashent le plus Kubernetes, on retrouve sans trop de surprise les gens dont le business est en concurrence plus ou moins directe avec Kubernetes. Et naturellement, ce sont eux qui font le plus de bruits (relayés par les autres).

  
Attention, je ne nie pas le fait que ces gens brillants (s’ils ont réussi, ce n’est pas pour rien) et que leur analyse est pertinente sur certains points.

  
Pour autant, on peut généralement trouver sans trop de difficultés une certaine mauvaise foi quand ils parlent de Kubernetes (que ce soit conscient ou pas)...

  
[Quand Ian Eyberg écrit "Kubernetes is in Hospice" sur LinkedIn, on peut se demander s’il ne devrait pas demander à quelqu’un de le relire avant d’appuyer sur la touche entrée...](https://www.linkedin.com/pulse/kubernetes-hospice-ian-eyberg/)

  
Je vous passe la grossièreté ("crap", etc), le mépris gratuit pour les "développeurs lambda qui font du JS parce que c’est plus simple"... Un type charmant, comme vous pouvez le voir.


> k8s est juste une tentative de Google pour faire venir les gens sur Google Cloud

  
Tu la sens venir la théorie du complot reptilien ?

  
> Facebook n’utilise pas Kubernetes car ça ne scale pas assez bien pour eux. Votre startup de 20 personnes ne devrait pas l’utiliser non plus.

  
Comparer les besoins de Facebook avec les besoins d’une startup de 20 personnes est une choix intéressant, en terme d’argumentaire je trouve. Et entre la startup et les GAFA, il n’y a rien d’autre ?

> La sécurité dans les containers est un échec total

  
Parce que bien sûr la sécurité dans l’IT non containerisée est totalement maîtrisée. Il n’y a pas du tout d’exploits pour sortir d’une VM, les OS sont toujours à jour chez tout le monde, l’IOT c’est Fort Knox.

  
(Vous me connaissez, je vous ai forcément gardé le meilleur pour la fin )

  
> Le site https://k8s.af est une collection d’histoires d’horreur sur la façon dont des sociétés ont échoué avec kubernetes. Ce n’est pas quelque chose qu’il faut applaudir ou dont il faut apprendre; c’est quelque chose à éviter. Vous ne pouvez pas dire que vous être ingénieur en génie civil et construire un pont qui risque de s’effondrer. Il y a des vies en jeu !!!!1!1!111

  
Est ce qu’on peut expliquer à ce monsieur que des fois des ponts s’écroulent et que JUSTEMENT, c’est parce qu’on essaye d’éviter que ça se reproduise qu’on apprend de nos erreurs et qu’on évite de les réitérer ?



![](/2019/07/1272382b-5ef5-4ec9-8872-4b67df82ad06-original.png) 

> Une réponse de l’auteur de k8s.af à ce genre de personnes 


Bon, une fois qu’on a lu tout ça, on prend une grande inspiration, on regarde l’entreprise que dirige Ian Eyberg et on voit qu’il est PDG de ... NanoVMs.

  
Et au cas où vous doutiez encore un peu, NanoVMs est une société qui se positionne ouvertement comme une alternative à Docker.

  
> Business is business.

  
## Et les fournisseurs de service ?

Dans le même genre, je me suis pris la tête avec Quentin ADAM (CEO de Clever Cloud). Le titre de l'article est en fait un tweet qui vient de lui (je n'ai pas retrouvé le thread).

Je n'ai aucun problème avec Clever Cloud. J'admire même la façon dont ils imaginent et font de l'infra, avec beaucoup de rigueur et pas de compromissions.

Mais forcément, quand des gens qui font de l'infra sans aucun compromis sur les principes d'ingénierie ont un avis négatif sur une techno, l'avis est tranché. Sauf qu'on ne vit malheureusement pas tous dans le monde merveilleux de Clever Cloud (j'adorerais).

C'est ce que j'ai essayé de lui faire comprendre : ce que lui fait chez Clever demande énormément d'énergie à quiconque veut faire pareil dans d'autres contextes. A un moment donné, on doit tous utiliser des outils (que ce soit Kubernetes ou autre) pour abstraire la gestion de l'infra de manière flexible, rapide et "relativement" simple à comprendre pour les non "Ops".

Exactement ce que lui fait avec Clever : c'est probablement plus propre de son côté, mais au final on automatise **tous** des hyperviseurs, des bases de données et des loadbalancers, ...

A l'issue d'un dialogue de sourds sur Twitter (j'en suis le premier responsable), on s'est quitté sur un :

> RIEN A VOIR

![](2019/09/rien_a_voir.png)

Dommage qu'on ait pas pu se comprendre (mais Twitter n'est pas un canal idéal pour ce genre de discussions).

## 4, des devs
  
  
Et là, on tombe sur la catégorie de personnes dont les réactions négatives m’attristent le plus.

  
J’ai l’impression que ces gens là ne se rendent pas trop compte de l’effort qu’il faudrait déployer pour obtenir la même chose, sans Kubernetes.

  
En fait, c’est comme si, en rendant le service aussi résilient qu’il l’est devenu, les Devs pensent que c’est simple d’avoir aussi bien, sans ~~Kubernetes~~ (remplacez Kubernetes par tout autre outil permettant d’automatiser la gestion d’une infrastructure complexe et hétérogène).

  
## Un peu plus de détails
  
  
Dans mon travail, nous hébergeons plusieurs plateformes Kubernetes. Ces plateformes sont à destinations des développeurs, pour leur fournir de l’infrastructure de manière "masquée", managée par nous.

  
Pour vous donner un ordre de grandeur, on parle d’une demi douzaine de clusters, avec entre 50 et 100 machines virtuelles, qui font tourner de manière résiliente plusieurs centaines d’applications chacun.

  
Ces applications (types microservices) sont hautement hétérogènes. On y dénombre pas moins de 5 ou 6 langages de programmation différents, deux ou trois fois plus de frameworks, des messages bus, des bases de données externes, ...

  
Avec Kubernetes, nous ne leur demandons pas de gérer l’infra, ni même de nous _demander_ de l’infra. Nous leur fournissons, au travers d’une chaîne d’intégration continue (IC), un self service pour consommer cette infrastructure. Les seules choses qu’on leur demande pour consommer cette infrastructure, c’est :

  
  
* de créer leur propre image (aka "image Docker")
* de rédiger les spécifications de leur application, interprétables par Kubernetes (via Helm, le langage de templating le plus répandu pour déployer sur Kubernetes)
      


![](/2019/08/bitcoind_chart.png) 

> Un extrait d’un chart Helm (https://github.com/helm/charts/blob/master/stable/bitcoind/templates/deployment.yaml) 


Pour ces choses, ils peuvent se baser sur des exemples de projets existants et/ou demander de l’aide à mes collègues Ops ou mes collègues de l’intégration continue.

  
Hashtag DevOps.

  
Ces deux choses qu’on leur demande sont donc ni plus ni moins que de la configuration et un genre de "code" simpliste, au même titre qu’ils renseignent déjà un _pom.xml_ ou autre _packages.json_. Pour un développeur, on peut s’attendre à ce que ça ne soit pas un souci.

  
## Et que gagnent ils en échange de ce travail ?
  
  
### De l’autonomie, du temps
  
  
Surtout de l’autonomie sur le déploiement de nouvelles applications, au sens large du terme.

  
D’abord, pas besoin d’avoir un Ops pour aider et manipuler des problématiques complexes de configuration de serveurs, la redondance/haute disponibilité, répartition de charge, ...

  
Tout ce qu’ils ont besoin de faire, c’est remplir un fichier texte YAML (certes très verbeux) avec les caractéristiques qu’ils souhaitent pour leur application (donne moi 3 instances identiques de telle container, avec tant de CPU/RAM). De base, l’application est alors déployée de manière reproductible, résiliente, se régule d’elle même en cas d’incident, ...

  
Pas besoin de demander aux OPS une nouvelle paire de serveurs webs à la moindre modif et surtout... pas besoin d’attendre pour l’avoir !!

  
### "Le futur et toutes les raisons d’y croire"
  
  
Pour illustrer, je peux vous parler d’un exemple personnel. Dans une autre vie pas si lointaine, j’ai été OPS pour un grand opérateur. Pour chaque nouveau projet, je recevais des demandes (aka. un ticket) de la part des Dev pour configurer des serveurs web. Mes collègues et moi avions 3 semaines pour traiter ces demandes.

  
TROIS... SEMAINES...

  
Autant dire que j’ai eu un paquet de fois à tout refaire car entre temps, un nouveau modèle (master) avec la mise à jour de l’application était sorti le temps que la demande d’environnement soit traitée.

  
Avec Kubernetes, en quelques secondes (5 minutes max si on compte toute la chaîne d’intégration continue), c’est livré.

  
### Des Ops plus disponibles
  
  
De même, pour gérer ces plateformes, il faut X fois moins de gens pour les administrer que si on devait déployer ces serveurs à la main, à la demande, sur des VMs par exemple. A l’heure actuelle, côté Ops, 2 personnes suffiraient pour maintenir l’ensemble de ces clusters.

  
Je dis "suffiraient" car nous gérons beaucoup d’autres plateformes en plus de Kubernetes. En terme de "charge homme", 2 ETP auraient encore pas mal de marge pour absorber de nombreux projets (aka applications déployées) en plus. Les autres membres de l’équipe ont le temps de gérer d’autres plateformes.

  
Je n’ose pas imaginer le nombre d’Ops qu’il faudrait pour maintenir un équivalent "VM" contenant 250 applications hétérogènes, les loadbalancers, etc. 5 ? 10 ? 15 ? Bien plus que 2, c’est sûr...

  
Et ce temps que l’équipe Ops a de disponible, c’est du temps qui peut servir à améliorer l’infrastructure pour coller le mieux aux besoins des développeurs, maintenir les bonnes pratiques sur l’ensemble du périmètre, les assister en cas de bug, ...

  
Faire du DevOps, en somme.

  
### Moins d’incidents
  
  
Là, c’est LA partie qui devrait leur tenir le plus à cœur normalement.

  
J’ai travaillé sur tous types d’infrastructures. Des bons gros Mainframe, des infrastructures virtualisés, convergées, HYPERconvergées, des SAN, des NAS et depuis 2 ans, sur Kubernetes.

  
Et bien, laissez moi vous dire qu’il n’y a pas photo. Mais genre, pas du tout.

  
Le fait de travailler en microservices containerisés, en s’astreignant à suivre quelques bonnes pratiques, permet réellement d’obtenir un service de qualité. 95% des incidents, qu’ils viennent de plantages imprévus de l’application ou de problèmes sur l’infrastructure, se résolvent d’eux même en quelques secondes, la plupart du temps sans notification à l’astreinte lorsque ça n’est pas nécessaire (ce qui n'empêche de débugger _a posteriori_, juste pas en pleine nuit).

  
C’est extrêmement impressionnant.

  
Mes 6 derniers mois d’astreinte se résument quasiment exclusivement à des incidents sur la partie legacy et/ou non containerisée. La partie Kubernetes se gère toute seule, j’ai très rarement eu à intervenir, que ce soit sur la plateforme elle-même, ou sur les applications hébergées dessus.

  
_Au final, les premiers fans de Kubernetes, ce sont les membres de ma famille, que je ne réveille plus la nuit pour redémarrer un serveur web ou basculer un cluster qui s’est mal déclenché._

  
## Donc les devs sont contents ?
  
  
Et ben non...

  
Je ne compte plus le nombre de gens brillants qui m’ont dit :

> nan mais attend ton truc, c’est super compliqué
  
> le go template/YAML c’est incompréhensible
> c’est pas mon job de faire ça

Et là, je suis hyper déçu.

Venant de gens qui sont capables de m’expliquer avec force de détails pendant 30 minutes ce qu’est une Monad, qu’un Monoid ce n’est du tout la même chose, je trouve ça culotté de venir m’expliquer qu’un bout de GOtemplate, c’est le summum de la complexité.
  
Je réitère une dernière fois... Oui, Kubernetes, c’est modérément complexe. Non, c’est pas _trop_ complexe. Bien moins que tous les autres concepts que ces gens là manipules tous les jours. C’est juste que le DevOps, au fond, ça ne les intéressent pas vraiment.
  
Ça se résume d’ailleurs assez bien dans le "c’est pas mon job de faire ça".
  
C’est le job de qui alors ? De savoir ce que fait l’application, comment elle interagit avec les autres, de quelles ressources elle a besoin ?
  
Moi je dirais que c’est celui qui l’a développée, EN ÉQUIPE avec celui qui maintient l’infrastructure.

Et je conclurai mon propos par un petit tweet de @bitfield qui a fait pas mal sauter des Devs de leur chaise il y a 3 ans et qui n’a malheureusement pas pris une ride.

![](/2021/tweet_bitfield.png)

`¯\_(ツ)_/¯`
