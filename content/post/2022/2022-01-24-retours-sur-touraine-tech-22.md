---
title: 'Retours sur Touraine Tech 2022'
authors:
  - zwindler
type: post
date: 2022-01-24T06:30:00+00:00
url: /2022/01/24/retours-sur-touraine-tech-22/
image: /2022/01/ada2.jpg
categories:
  - Cloud
  - conference

---

## TNT 22, IRL

Vendredi j'étais à Touraine Tech !

Malgré le contexte sanitaire encore plus compliqué qu'en fin d'année dernière (...), cette édition a pu se dérouler en présentiel, au Polytech Tours, quasi normalement. 

![](/2022/01/tnt2.jpg)

Bon... en vrai, côté orga, ça a du être bien galère, mais côté speakers / participants, tout était tellement *smooth* qu'on a rien vu. Bravo :)

TNT était l'occasion pour moi de faire mon talk "Dis papa ? C'est quoi un SRE ?" autrement qu'en visio et aussi de rencontrer pas mal de speakers (il y avait beaucoup de talks très sympas, je vous met [le programme ici](https://touraine.tech/#schedule)).

## Keynote d'ouverture

La Keynote d'ouverture, présentée par **Camille Justeau**, a été consacrée à une réflexion sur l'écologie et la lowtech.

La conférence commence par relayer l'information que nous avons atteint une 5eme des 9 limites planétaires, selon [un groupe de chercheurs](https://www.stockholmresilience.org/).

En partant du principe qu'améliorer l'efficience des composants électroniques ne suffira pas à minimiser notre impact sur l'environnement, beaucoup des éléments nécessaires aux smartphones, serveurs informatiques, etc risquent de ne plus être disponibles. Il devient donc urgent de consommer mieux (à défaut de consommer moins).

C'est le principe de la lowtech, qui consiste à amener une réflexion sur ce dont on a vraiment besoin pour nos services numériques du quotidien.

Au delà de l'aspect purement écologique, il y a des réflexions intéressantes sur l'aspect "choix des équipements". En effet, mettre en avant des composants durables, réparables, aux sources ouvertes, permet de pérenniser les matériels et donc limiter le gaspillage.

> - Utile
> - Durable
> - Accessible 

## Dis Père castor, raconte nous une histoire d'Ops

Slides de son talk (lien cassé)

Ce talk de **David Aparicio**, est une collection de postmortems et d'incidents de prod. Chaque exemple est raconté puis décortiqué par David, qui donne des clés pour éviter que cela vous arrive, ou a minima en réduire l'impact.

Pele mêle, je citerai :
- faire des blameless postmortems
- imposer de faire de meilleures docs, plus de runbooks, jouer des wheels of misfortune
- mettre en place de workarounds quand le produit a vocation à disparaître très prochainement
- rendre explicite les messages d'erreur
- mettre en place de circuit breaker pour éviter les bootstorms

# Dis papa ! C'est quoi un SRE ?

C'est mon talk ;-)

En attendant que la vidéo soit disponible je vous remet [le lien vers l'article qui en parle](/2022/01/12/touraine-tech-22-dis-papa-cest-quoi-un-sre/)

![Un photo avec tous les retours, merci les orgas :-D](/2022/01/dis_papa_cest_quoi_un_SRE.jpg)

[Edit]La vidéo est [ici](https://www.youtube.com/watch?v=l8W8XGK3gSo)[/Edit]

## Would like to learn how manage your passwords like your code?

Dans cette session de 15 minutes, **Sébastien** nous a montré comment, chez OVHcloud, une partie des mots de passe sont générés, stockés et mis à jour de manière sécurisée à l'aide de [passwordstore](https://www.passwordstore.org/) (ou `pass`).

Ce logiciel utilise GPG et est suffisamment simple et automatisable pour fiabiliser la gestion des secrets. 

L'outil dispose d'un submodule dans Ansible ainsi que d'un operator dans Kube pour faciliter son usage.

Personnellement j'utilise plutôt Hashicorp Vault (mais c'est plus compliqué à utiliser) ou bien `ansible-playbook`.

## Observabilité Zero to OpenTelemetry

[Démo disponibles ici](https://github.com/foxlegend/observablity-from-zero-to-opentelemetry)

**Charles-Marie Ambrosetti** et **David Pequegnot** nous ont fait un talk très sympathique d'introduction à l'observabilité, notamment grâce à [OpenTelemetry](https://opentelemetry.io/).

Pas besoin d'un APM coûteux, toutes les briques open source sont à disposition ;-p.

Ils nous ont montrés qu'en injectant quelques libs mises à disposition par le produit, on était capable d'instrumenter le code et récupérer des traces, corrélables avec des logs et des métriques.

Le premier gros avantage d'OpenTelemetry est le nombre très important d'outils qu'il peut accepter, à la fois en entrée et en sortie.

Le second avantage est qu'il n'est pas nécessaire de réécrire du code (même si c'est possible). Pour certains langage il suffit d'ajouter une lib au démarrage (java) ou de changer de binaire (python).

On va donc pouvoir corréler sans effort grâce aux services déjà présent dans nos infras.

La démo a été faites avec le code de démo Spring "[petclinic](https://github.com/spring-projects/spring-petclinic)", un serveur Prometheus et un serveur grafana avec Loki (pour visualiser les logs) et tempo (pour visualiser les traces).

## Petit guide pratique pour commencer un design system

Par curiosité, je suis allé voir le talk de **Cécile Freyd-Foucault** sur les *design systems*.

N'ayant jamais travaillé avec des designers, je ne savais pas du tout à quoi m'attendre. 

Elle a commencé par nous rappeler que nous utilisons souvent le "material design" de Google parce qu'il est disponible par défaut, mais qu'il est tout à fait possible de gérer son propre design system, moyennant quelques précautions.

Globalement, je n'ai pas compris tous les arguments (faire son propre design system permet de limiter le bus Factor ???), mais j'ai retrouvé beaucoup de similitudes avec mon métier et beaucoup de bonnes pratiques que je rabâche à longueur de journée.

Embarquez l'équipe dans les choix, soyez pédagogues, écrivez de la Doc, ne le faites pas pour la hype, pensez aux utilisateurs, directs et indirects, commencez par un seul élément (le plus utilisé pour avoir l'effet waouw), etc.

Bref, j'ai trouvé ça logique car je travaille comme ça moi aussi ;-)

## GitPod : IDE as a service, ou comment ne pas acheter un MacBook Pro à 6000 € et être heureux avec une petite machine

MA GROSSE surprise de cette journée. Même si en vrai, en fait c'était prévisible, ce talk tourne dans toutes les confs et a de supers retours. 

Mais même comme ça, j'étais pas prêt pour toutes les possibilités que cela allait m'ouvrir.

Grosso modo, **Horacio** et **Philippe** nous ont parlé de divers usecases dans lesquels ils avaient besoin d'environnements de développement plus ou moins complexes qui marchent "à tous les coups" et comment [GitPod](https://www.gitpod.io/) rempli parfaitement ce besoin.

Depuis un dépôt de code hébergé sur Github ou Gitlab (en ligne ou on-prem), on peut obtenir un environnement de développement complet ainsi qu'un IDE VScode (avec toutes les extensions et les fonctionnalité de prévisualisation), accessible depuis n'importe quel device depuis un navigateur web.

Et pour avoir vu les démos, c'est bluffant.

Il est possible de customiser les binaires/services disponibles dans la machine derrière l'IDE, voire même en lancer plusieurs via un `docker compose` et ainsi reproduire un environnement de développement complet depuis un navigateur.

Les possibilités ouvertes sont nombreuses et Horatio et Philippe nous donnent quelques exemples :
- Faire des labs virtuels
- Préparer rapidement des environnements de développement pour onboarder des nouveaux arrivants
- Assister les contributeurs nouveaux à un projet open source en leur donnant un environnement prêt à utiliser
- Avoir plusieurs onglets pour faciliter le travail sur plusieurs branches en simultanée

Je me vois déjà écrire le blog dessus avec Hugo, ou mes supports de conf avec marp, et je ne parle pas des cas d'usages pro que je lui réserve... [Edit]Je viens de faire mes premières modifs depuis Gitpod \o/[/Edit]

Vraiment une super découverte.

## Keynote de fin

La keynote de fermeture a été réalisé par **Damien** de WeLoveDevs.

Damien nous a présenté, de manière humoristique, les résultats de son enquête annuelle ["Ce que veulent les devs"](https://welovedevs.com/fr/resultats-enquete-salaire-bonheur-au-travail-developpeurs/).

C'était intéressant de voir ces chiffres (même si je commence à bien les connaître à force de consulter TOUTES les études qui sortent), et aussi un peu les messages qu'il a voulu faire passer (notamment sur le fait que beaucoup de gens qui se reconvertissent dans l'informatique ne trouvent pas de travail, malgré la pénurie).

Au delà des chiffres, Damien nous a partagé quelques livres à lire si on veut mieux comprendre l'entreprise.

J'ai aussi retenu les références suivantes (sur le savoir être) :
- [Les mots sont des fenêtres](https://livre.fnac.com/a9518132/Marshall-B-Rosenberg-Les-mots-sont-des-fenetres-ou-bien-ce-sont-des-murs)
- [Radical candor](https://livre.fnac.com/mp35619200/Radical-Candor)

Encore merci aux orgas, c'était vraiment parfait.
