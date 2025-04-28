---
title: Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 01
authors:
  - zwindler
type: post
date: 2022-02-21T06:30:00+00:00
url: /2022/02/21/webui-tui-gui-pour-kubernetes-episode-01/
image: /2021/07/octant1.png
categories:
  - Cluster
  - Virtualisation
tags:
  - cli
  - gui
  - k8s
  - Kubernetes
  - tui
  - webui

---

Note: Cet article fait partie d'une série de 3 articles dans lesquels je fais une **liste exhaustive** des WebUIs, TUIs et GUIs pour utiliser Kubernetes :
* WebUI - [Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 01](/2022/02/21/webui-tui-gui-pour-kubernetes-episode-01/)
* TUI - [Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 02](/2022/10/13/webui-tui-gui-pour-kubernetes-episode-02/)
* GUI - [Les WebUIs, TUIs, GUIs pour Kubernetes – Episode 03](/2022/10/24/webui-tui-gui-pour-kubernetes-episode-03/)

## Kubernetes, c’est dur 😭

Voilà quelque chose qu’on entend à longueur de journée. [J’en ai déjà parlé, Kubernetes est un outil « modérément » ](/2019/09/03/concerning-kubernetes-combien-de-problemes-ces-stacks-ont-generes/)complexe. Oui, c’est un outil **complet** (et pas complexe) avec une terminologie riche qui lui est propre. 

Au delà de la fausse promesse que certains lui attribue (permettre aux Dev de s’émanciper totalement des Ops, j’en parle dans l’article « [au secours, le métier d’Ops va disparaître](/2020/07/29/au-secours-le-metier-dops-va-disparaitre/)« ), il y a un vrai problème de vocabulaire et de concepts qui ne sont pas évidents pour les débutants.

Pour faciliter l’adoption, j’ai remarqué que beaucoup de gens qui débutent dans kube s’aident d’environnement (souvent graphiques, mais pas forcément) permettant d’interagir avec les objets logiques de Kubernetes de manière « simple ».

Car, _bizarrement_, tout le monde n’aime pas écrire des tonnes de lignes de commandes (ou pire des calls d’API) et des tartines de YAML à longueur de journée... J’comprend pas.

![](/2021/04/memenetes.png)

Comme je suis quelqu’un de sympa, j’ai donc **testé pour vous tous les outils**, graphiques ou non, que j’ai pu trouver, pour vous faire un petit guide et vous donner mes impressions.

Vous êtes prêts ? 

Alors c’est parti ! 

Dans ce premier épisode (qui en comportera 3, je vous laisse deviner les deux autres), je me suis concentré sur les WebUI.

## Kubernetes UI (officielle)

![](https://d33wubrfki0l68.cloudfront.net/349824f68836152722dab89465835e604719caea/6e0b7/images/docs/ui-dashboard.png)

* **Site** : [kubernetes.io/fr/docs/tasks/access-application-cluster/web-ui-dashboard/](https://kubernetes.io/fr/docs/tasks/access-application-cluster/web-ui-dashboard/)  
* **Sources** : [github.com/kubernetes/dashboard](https://github.com/kubernetes/dashboard)

Franchement au début je voulais prendre le parti de NE PAS parler de la WebUI officielle. Je ne l’aime pas, depuis longtemps. 

Je la trouvais limitée, au début elle était buguée, les messages d’erreur étaient tout sauf explicites, ... Les CRDs n’étaient pas du tout gérées et même les objets officiels de l’API de Kubernetes n’étaient pas tous représentés, rendant tout diagnostic poussé impossible. 

Si c’est pour faire du **kubectl** de toute façon, autant ne pas perdre de temps à m’authentifier sur la WebUI.

Elle était souvent déployée un peu par défaut dans les débuts de Kubernetes et souvent mal sécurisée (par les utilisateurs) ce qui a conduit à de nombreux piratages. Les cloud providers ne l’activent plus par défaut pour cette raison (voire même, certains le déconseillent).

Cependant, j’ai réessayé la V2 et il faut reconnaître que les choses se sont améliorées. Les CRDs sont correctement prise en charge, notamment.

## Octant (VMware)

* **Site** : [octant.dev](https://octant.dev)  
* **Sources** : [github.com/vmware-tanzu/octant](https://github.com/vmware-tanzu/octant)

Un projet qui me tient à cœur est la solution de WebUI de VMware. 

Je dis WebUI, mais uniquement parce que l’UI est lancée dans un navigateur. Mais ce n’est pas un serveur web à exposer h24 comme l’UI officielle. C’est d’ailleurs pour ça que c’est « plus sécure ». L’UI n’est lancée que localement sur le poste de l’utilisateur, à la demande, avec les privilèges de l’utilisateur (et rien de plus).

Elle sert d’UI pour [Tanzu (le Kubernetes à la sauce VMware)](https://tanzu.vmware.com/fr/tanzu) mais pas que, ce qui explique je pense l’effort qu’ils y mettent (il faut bien se différencier). 

Pour l’avoir pas mal utilisée, c’est fiable et pratique. C’est aussi assez simple à installer, VMware mettant à disposition sur Github des archives et des packages systèmes :

![](/2021/04/octant_install-1.png)

Et voilà à quoi l’UI ressemble. On retrouve des menus où sont regroupés les différentes vues sur la gauche, puis on navigue de ressource en ressource via les liens hypertexte. On peut faire des recherches par filtres, ...

![](/2021/07/octant1-2.png)

Dans les plus que j’y vois, c’est assez intuitif, on est pas perdu. Le principe est relativement similaire à l’UI officielle, même si l’organisation des menus est différentes. Un point noir, le texte est par défaut très petit, et des menus très riches (beaucoup de cadres, beaucoup de texte).

L’UI offre des fonctionnalités supplémentaires par rapport à l’UI officielle, comme l’affichage des **logs streamés**, le **port-forward d’un pod via un click**, qui vous lance votre application dans un nouvel onglet de navigateur (hyper pratique). Tout est **filtrable**, notamment par labels.

Les **CRDs sont correctement gérées** depuis longtemps (mais c’est aussi le cas dans l’UI officielle maintenant).

Le produit met également en avant son côté extensible avec plusieurs modules complémentaires permettant d’étendre les fonctionnalités de base. Je n’ai pas essayé cette possibilité.

## Headlamp

[Edit] J'ajoute aussi Headlamp que je viens de découvrir grâce au seul et unique Seb Moreno :)

* **Site** : [Blog de Kinvolk pour présenter headlamp](https://kinvolk.io/blog/2020/11/shining-a-light-on-the-kubernetes-user-experience-with-headlamp/)
* **Sources** : [github.com/kinvolk/headlamp](https://github.com/kinvolk/headlamp)

Développée par kinvolk (a priori rachetée récemment par Microsoft en 2021) cette nouvelle WebUI se veut simple d'utilisation et multi cluster.

Elle peut être déployée directement dans un cluster, en tant qu'application sur votre laptop/PC/whatever.

Je ne vois pas bien ce qu'elle apporte de plus que les autres à part peut être un look minimaliste qui peut plaire (ou pas).

![](/2022/10/cluster_chooser.png)

Ce n'est ni un avis positif, ni un avis négatif, elle n'a juste IMO pas grand chose de vraiment différenciant mais elle a l'air tout à fait acceptable.

## Skooner (ex-K8dash) (Indeed)

Développée pour les besoins internes de Indeed, cette WebUI se veut plus simple dans son look que la WebUI officielle.

* **Site** : [Blog post sur le tech blog de Indeed Engineering](https://engineering.indeedblog.com/blog/2020/11/k8dash-indeeds-open-source-kubernetes-dashboard/)  
* **Sources** : [github.com/indeedeng/k8dash](https://github.com/indeedeng/k8dash) / [github.com/skooner-k8s/skooner](https://github.com/skooner-k8s/skooner)  
* Vidéo démo : [www.youtube.com/watch?v=u-1jGAhAHAM](https://www.youtube.com/watch?v=u-1jGAhAHAM)

Les fonctionnalités mises en avant sont une installation simple (ça se déploie dans Kubernetes, effectivement c’est pas super complexe), une UI **mise à jour en temps réel** (pas de reload de la page web) et une **authentification OIDC intégrée**. Les objets sont **filtrables**.

![](/2021/07/K8dash.png)

Au delà de l’installation simple et de l’intérêt réel pour l’ajout de l’OIDC out of the box, je ne vois pas bien ce qu’elle apporte... Oui, le look est plus léché et il y a un gouvernail qui tourne (youpi). Oui ça se reload tout seul en temps réel. 

Mais bon... question de goût, j’imagine ?

## Et plus si affinité...

Bon là, niveau WebUI on est déjà bien. 

Si jamais vous n’avez toujours pas trouvé votre bonheur, le mieux, c’est certainement d’attendre le prochain épisode (car après les WebUI, on a vraiment du lourd qui arrive pour les prochains épisodes :-p).

Et en attendant, have fun :\)
