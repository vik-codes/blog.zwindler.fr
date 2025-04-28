---
title: 'Devoxx France 2022 - Récap du jour 1'
authors:
  - zwindler
type: post
date: 2022-04-20T20:00:00+00:00
excerpt: Je suis à Devoxx France 2022 et je fais un récapitulatif de cette première journée de conférence
url: /2022/04/20/devoxx-2022-recap-jour-1/
image: /2022/04/devoxx2.jpg
categories:
  - Conférence
tags:
  - Devoxx 2022
  - Devoxx 

---

## Mon premier Devoxx, directement pour celui des 10 ans !

Les résumés des 3 jours de DevoxxFR 2022

* [Mercredi](https://blog.zwindler.fr/2022/04/20/devoxx-2022-recap-jour-1/)
* [Jeudi](https://blog.zwindler.fr/2022/04/21/devoxx-2022-recap-jour-1/)
* [Vendredi](https://blog.zwindler.fr/2022/04/22/devoxx-2022-recap-jour-3/)

Je ne vais pas [présenter à nouveau Devoxx](https://blog.zwindler.fr/2022/04/18/retrouvez-moi-a-devoxx-2022/), mais comme je suis à fond, je vais faire au mieux pour faire un compte rendu au fur et à mesure des conférences que je vois.

Pour me faciliter la vie cette année, j'ai suivi [le conseil de Thomas SCHWENDER sur le blog de Devoxx](https://www.devoxx.fr/2022/03/14/comment-bien-preparer-sa-participation-a-devoxx-france/) et je me suis fait un fichier en Markdown avec à la fois mon agenda ainsi qu'une aide à la prise de note.

Première impression en arrivant : YA DU MONDE ! 

![](/2022/04/devoxx3.jpeg)

Et encore... le mercredi il n'y a pas tous les participants : cette première journée est surtout consacrée aux Universités dans un premier temps (des conférences ou labs de 3 heures) et aux Tools in Action. Beaucoup viennent à partir de demain, si j'ai bien compris.

3 heures, c'est un peu long quand on a pas (plus) l'habitude 😅. Heureusement, c'est Devoxx, les speakers sont tops :p

## La révolution (wasm) est incroyable parce que vraie

**Speaker(s) :**
- Philippe CHARRIÈRE
- Laurent DOGUIN

![](/2022/04/wasm.jpeg)

A vrai dire, je suis allé à cette université uniquement par curiosité. J'avais envie de découvrir WASM dont parle tout le temps Philippe CHARRIÈRE sur Twitter ;-). Je n'ai absolument pas le background de développeur, encore moins d'applications JS et/ou web.

Heureusement, j'ai été vite rassuré de voir qu'on pouvait faire du WASM avec Go (que j'ai commencé à apprendre grâce à mon maitre Jedi et voisin). Ouf !

Je vais éviter de paraphraser ce qui s'est dit pendant la conférence (car je vais dire des con***ies) mais voilà ce que j'en ai retenu, dans les grandes lignes :
- Webassembly a été conçu pour régler certaines limitations de JS suite aux disparitions de ActiveX, Flash, etc
- Il permet de faire des binaires portables, de petite taille, compilés
- on peut en faire avec plusieurs langages (dont Rust, Go, C++) et grosso modo on a quelque chose de similaire à un container, mais en plus petit, sans l'OS et donc plus sécurisé
- Un standard WASI est en cours d'écriture
- il existe des runtimes tel que [wasmer](https://wasmer.io/), [wasmedge](https://wasmedge.org/), [wasmtime](https://github.com/bytecodealliance/wasmtime) qui permettent de faire plus de choses que juste du web
- il y a encore pas mal de limitations dans WASM notamment très peu de types, un debug complexe, gestion d'erreur pas ouf, mais beaucoup de choses restent à venir
- certaines entreprises open-sourcent des outils (comme [reactr](https://github.com/suborbital/reactr), [Atmo](https://github.com/suborbital/atmo), [sat](https://github.com/suborbital/sat)), permettant de contourner ces limitations et faciliter l'utilisation de WASM, notamment dans l'IoT

J'espère ne pas avoir dit trop de bêtises dans cette liste, je n'ai peut-être pas bien saisi toutes les subtilités ;-).

D'un point de vue extérieur à cet univers, j'ai l'impression que c'est pas totalement userfriendly pour l'instant, voire parfois pas totalement sec. Cependant, ça n'empêche pas qu'il y ait déjà des exemples d'utilisations de la techno :
- [web.autocad.com](https://web.autocad.com)
- [Unity fait du webassembly (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20231208002232/https://blog.unity.com/technology/webassembly-is-here)
- WASM fonctionne très bien pour faire de l'OCR dans un navigateur et en local
- ...

Si vous souhaitez refaire les démos réalisées pendant l'université, toutes sont disponibles ici : [gitlab.com/wasmuniversity](https://gitlab.com/wasmuniversity)

## Déployer Vault et Consul dans Kubernetes

**Speaker(s) :**
- Vincent SEVEL
- Ludovic BERTIN
- Erik DE LAMARTER

Ici cette Université était un Lab. J'ai forké le dépôt Git (disponible [ici](https://github.com/zwindler/vault_consul_devoxx_fr_2022))

J'ai décidé d'aller faire ce lab, car nous utilisons [Vault](https://www.vaultproject.io/), [Consul](https://www.consul.io/) et Kubernetes en production, mais que je sais que l'écosystème a beaucoup évolué et j'avais besoin de me remettre à jour.

La première partie était malheureusement forcément un peu orienté "débutant" pour Kubernetes (création de manifests YAML, déploiement helm), ce qui collait mal avec mes attentes.

Heureusement, les 2 derniers labs étaient plus concrets (utilisation de Vault via un token récupéré par le ServiceAccount d'une app).

On a aussi parlé en off un peu du Vault Agent et du CSI Vault, qui sont les deux options que je souhaite (re)découvrir ([j'en ai déjà parlé sur ce blog](https://blog.zwindler.fr/2020/08/31/gerez-vos-secrets-kubernetes-dans-vault/)). 

Enfin, c'était une occasion sympa de discuter avec des pairs qui font des choix techniques similaires (ou pas).

Et j'ai croisé Idriss NEUMANN :-)

## Exposants

Pendant les pauses, j'ai aussi fait le tour et j'ai pu discuter 5 minutes avec François TONIC du stand Technosaures (on a parlé de mon clone d'Apple 2 que je dois restaurer).

![](/2022/04/technosaure.png)

J'ai croisé David LEGRAND, qui m'a parlé plus en détail de son nouveau boulot chez [Clever Cloud](https://www.clever-cloud.com/).

![](/2022/04/clever.jpeg)

## Du Chaos Engineering avec Litmus et Jenkins

Après les universités, c'est au tour des Tools in Action ! Des sessions de 30 minutes pour... voir un tool in action 😅.

Akram RIAHI nous a fait un REX sur la mise en place de [Litmus Chaos](https://litmuschaos.io/) (Framework opensource pour pratiquer le chaos engineering de manière cloud native), orchestré par Jenkins, chez un de ses clients. Après une très brève introduction sur ce qu'est le Chaos Engineering, Akram nous a expliqué que le Chaos allait devenir simple grâce à Litmus. 

On va voir ;-).

Le but du jeu est de créer un pipeline qui passe d'abord les knows (tests QA) puis passe aux unknowns (le chaos) avant de déterminer si la nouvelle version de notre application peut passer en prod ou pas.

![](/2022/04/litmus.jpeg)

Litmus ajoute à Kubernetes des ChaosExperiment (CRD), qu'on peut écrire soi-même, ou que l'on peut piocher dans une registry ChaosHub (bibliothèque de scénarios)

Il existe également une UI (ChaosCenter), même si Akram conseille plutôt de tout faire "as code".

Le temps a un peu manqué pour qu'on ait le temps de voir la démo complète.

Le code de la démo est [disponible ici](https://github.com/akria18/litmus-chaosworkflows)

## Rendez l'agilité aux développeur(se)s !

Ce talk de Fanny KLAUK est un ensemble de saynètes sur une équipe de dev "agile".

Il a visiblement été inspiré par des faits réels provenant de son expérience, mis en scène à la mode d'un livre dont on est le héros (j'étais fan, ado !).

Je ne vais pas spoiler le talk, il faut vraiment aller le voir. On sent le vécu, c'est plein d'humour et de bon sens (et pourtant !) sur comment améliorer la vie d'une équipe de dev.

Quelques mots clés : vision commune, amélioration continue, confiance, engagement, "prendre le temps".

![](/2022/04/agilite.jpeg)

## Créer & distribuer un plugin pour Kubernetes en quelques minutes ? Easy ! 🙂

**Speaker(s) :** 
- Aurélie VACHE
- Gaëlle ACAS

En 25 minutes, Gaëlle ACAS et Aurélie VACHE nous ont montré qu'il était possible de créer un plugin pour `kubectl` et le mettre à disposition du MOooOode entier ;-).

Globalement, la CLI de kubernetes est pensée, comme le reste des composants de kube, comme extensible. Un simple binaire exécutable respectant le nom de `kubectl-LENOMDEMONPLUGIN` suffit.

Elles nous ont donc fait la démo avec un simple script bash qui ajoute des émojis devant les noms des pods, en fonction de la saison.

Une fois que c'était fait, la deuxième partie de ce dernier tool in action de la journée était la présentation de `krew`, (lui-même un plugin pour `kubectl`), qui permet de faciliter la recherche, l'installation et la gestion d'extensions pour `kubectl`.

![](/2022/04/krew.jpeg)

Gaëlle a terminé le talk en nous présentant les plugins qu'elle utilise au quotidien. J'ai retenu en particulier "neat", très utile pour nettoyer les champs rarement utiles pour les humains.

## Soirée speakers

La journée a fini en apothéose avec un super cocktail entre orgas et speakers. L'occasion de rencontrer **en vrai** tous ces gens rencontrés sur les Internets, parler avec d'autres au gré des discussions ou revoir de vieux copains, avec entre autres Olivier PONCET, Cécile MORANGE, Aurélie VACHE, Gaëlle ACAS, Fanny KLAUK, David APARICIO, Gérôme EGRON, ...

Mais je n'ai pas encore réussi à voir tout le monde que je voulais voir ;) 

La suite jeudi !
