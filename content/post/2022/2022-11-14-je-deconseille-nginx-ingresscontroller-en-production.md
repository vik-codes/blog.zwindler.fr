---
title: Je déconseille nginx en tant qu'ingressController en production
authors:
  - zwindler
type: post
date: 2022-11-14T06:30:00+02:00
excerpt: "Régulièrement, j'indique que je ne considère pas l'ingressController 'officiel' de Kubernetes à base de nginx comme production ready. J'explique pourquoi dans cet article"
url: /2022/11/14/je-deconseille-nginx-ingresscontroller-en-production/
image: /2017/06/kubernetes2.png
categories:
  - Système
  - Virtualisation
tags:
  - nginx
  - kubernetes
  - docker
  - ingress
  - ingressController

---
## Disclaimer

Je n'utilise plus nginx comme **IngressController** Kubernetes depuis 2020 (même si j'ai écris quelques articles dessus, notamment [Exposer des applications containerisées Kubernetes (nginx Ingress Controller)](/2018/03/06/exposer-des-applications-kubernetes-en-dehors-des-cloud-providers-nginx-ingress-controller/)). Aussi, il se peut que les informations contenues ici soient périmées.

Cependant, des issues récentes faisant état du même problème que le miens sont régulièrement ouvertes donc je pense que c'est toujours le cas.

• [github.com/kubernetes/ingress-nginx/issues/2461](https://github.com/kubernetes/ingress-nginx/issues/2461)
• [github.com/kubernetes/ingress-nginx/issues/7115](https://github.com/kubernetes/ingress-nginx/issues/7115)

## Contexte

Pour qu'on mette tout de suite d'accord sur ce dont on parle, je ne déconseille évidemment pas l'usage de nginx en production. nginx est un soft robuste qui a fait ses preuves pendant des années et que j'utilise encore dans certains contextes pros et perso.

Cependant, quand j'ai commencé à travailler avec Kubernetes, j'ai (comme beaucoup) lu la documentation.

Et à l'époque, pour ce qui est de l'utilisation des Ingress, la documentation officielle mettait en avant l'implémentation de l'IngressController nginx disponible sur le Github de Kubernetes [github.com/kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx).

Point intéressant, il existe un autre dépôt mis à disposition par la société nginx inc, que je n'ai jamais utilisé [github.com/nginxinc/kubernetes-ingress.](https://github.com/nginxinc/kubernetes-ingress) qui n'est peut être pas affecté. Cependant quand on parle de "l'IngressController nginx" la plupart des gens parle du repo sur le Github de Kubernetes (source : moi, tkt)

## Et donc quel est le problème ?

Maintenant qu'on est bien d'accord que ce dont on parle, je peux vous raconter une petite histoire.

A l'époque je travaillais pour une entreprise industrielle qui hébergeait "dans le cloud" un logiciel vendu en SaaS. 

Chaque client avait sa propre instance, hébergée sur un Kubernetes hébergé sur Azure.

Au début nous avions peu de clients, tout allait bien. Mais au fur et à mesure que le nombre de clients grossissait, on commençait à avoir des retours de la part des équipes métiers et support comme quoi, de temps en temps, l'application perdait temporairement la connexion au serveur.

En bon sysadmin et après avoir vérifié l'absence d'alertes de notre côté, on a d'abord blâmé l'utilisateur, le réseau et l'application elle même (dans cet ordre). **#Trollface**

Blague à part, la réalité, c'est que nous ne savions pas trop par où prendre le problème car nous n'avions aucun log, aucun incident et le coupures étaient au début très rares et surtout aléatoires en apparence.

## Jusqu'au jour où...

Jusqu'au jour où, pour des histoires de CVEs à patcher, nous avons redéployé un très grand nombre d'applications dans un créneau horaire assez court.

A ce moment là, le nombre de plaintes a fortement augmenté et nous a permis de valider que le problème n'était pas aléatoire et était bien de notre côté.

Nous avons deviné qu'il y avait une corrélation entre le déploiement d'applications dans Kubernetes et la coupure des connexions (websockets) côté client.

## On est pas seul

Une fois qu'on savait ça, on a trouvé le coupable assez vite. Une rapide recherche Google nous a permis de tomber sur plusieurs issues sur le repository de l'IngressController, décrivant les mêmes symptômes.

En creusant un peu, on a également trouvé un article très complet qui détaille bien mieux que ce que j'aurais pu faire le problème.

* [DanielFM - pain(less) NGINX Ingress](https://danielfm.me/post/painless-nginx-ingress/)

## C'est quoi le problème ???

TL;DR tel que l'IngressController est implémenté par défaut, la configuration de nginx est rechargée à chaque fois qu'une modification a lieu sur les backends des Services Kubernetes.

Pour ceux qui ne sont pas encore bien familier avec ces concepts, à chaque fois qu'un Pod (votre app containerisée) est créé ou détruit, nginx est rechargé.

Théoriquement, ça se fait à chaud car nginx supporte les rechargements de configuration à chaud. Sauf que, tel que l'IngressController est implémenté, les Websockets ouvertes doivent être coupées...

Pour limiter la casse, à chaque rechargement de configuration, un processus nginx avec la nouvelle configuration est généré en parallèle de l'ancien qui est gardé au maximum 10 secondes pour donner une chance à toutes les connexions en cours de se fermer proprement.

## Solutions ?

Dans son post, Daniel fait le tour des workarounds à votre disposition pour limiter la casse.

La première chose qu'on peut faire et qui marche bien est d'ajouter l'option `--enable-dynamic-configuration` qui fait que la configuration n'est plus rechargée à chaque changement de backends sur les services (événements hyper fréquent) mais uniquement lors des créations/suppression de services (le déploiement d'une nouvelle app).

Ça limite drastiquement le nombre de reloads mais n'est évidemment pas une solution.

Le deuxième levier mis en avant par Daniel est d'augmenter le timeout de 10s (`--worker-shutdown-timeout`) et de mettre quelque chose de très grand. Cependant, il met en garde contre cette solution car on se retrouve vite avec un duplication des processus nginx avec X versions de la conf, ce qui peut faire saturer la RAM de votre ingressController ou votre node...

Dernière idée, pour limiter la disruption causée par un changement, nous avions envisagé de segmenter en ayant un ingressController par namespaces. Ainsi en cas de redéploiement, seul les applications du namespace en cours de déploiement seraient concernées par la coupure (des « workarounds » plutôt) :

* Limiter les reloads (pénible)
* Augmenter sensiblement (24h ?) les timeout sur les connexions actives 
* Segmenter les namespaces (1 Ingress Controller par namespace, on limite l'impact d'un redéploiement à un client)

## Mais alors on fait quoi ?

Comme il n'y a pas vraiment de solution à date, le plus simple reste de ne tout simplement pas utiliser l'IngressController nginx de Kubernetes 😉 et de lui préférer une implémentation gérant ce genre de cas à chaud.

Même si je n'ai pas retravaillé avec depuis un moment, nous avions eu à l'époque de bons résultats avec [Traefik](https://traefik.io/solutions/kubernetes-ingress/).

Et si vous en connaissez d'autres qui gèrent bien ce genre de cas, n'hésitez pas à me l'indiquer :).

