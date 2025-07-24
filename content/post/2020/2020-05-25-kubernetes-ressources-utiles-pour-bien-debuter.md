---
title: Kubernetes – Ressources utiles pour bien débuter
authors:
  - zwindler
type: post
date: 2020-05-25T06:45:00+00:00
excerpt: Ressources utiles sur Internet pour apprendre Kubernetes quand on débute
url: /2020/05/25/kubernetes-ressources-utiles-pour-bien-debuter/
image: /2019/07/concerning_kubernetes.jpg
categories:
  - systeme
  - Virtualisation
tags:
  - Kubernetes
  - padok
  - sketchnote
  - veille
  - youtube

---
## Kubernetes, ce n’est pas difficile

J’en parlais en partie dans mon article sur le « Kubernetes bashing ». Kubernetes, c’est « modérément » compliqué. Je dis modérément, car de mon point de vue, beaucoup de la **difficulté perçue** de Kubernetes vient des architectures microservices, qui demandent de changer un peu ses habitudes de développement et d’administration.

* [Concerning Kubernetes : « combien de problèmes ces stacks ont générés ? »](/2019/09/03/concerning-kubernetes-combien-de-problemes-ces-stacks-ont-generes/)

Pour autant, entendre à longueur de journée « Kubernetes c’est compliqué », induit forcément pour les néophytes une petite anxiété. Et parmi la masse d’information qu’on peut trouver sur le sujet, il n’est parfois pas facile de s’y retrouver.

Si j’essaye de rendre mes articles les plus accessibles possible, je traite parfois de sujets un peu pointus. Pas idéal non plus pour débuter.

Heureusement, **plusieurs facilitateurs, notamment Français**, mettent à disposition des ressources pour tous les niveaux. Je voudrais mettre à l’honneur aujourd’hui leur travail de pédagogie sur le sujet.

## Une image vaut mille mots

On vous a peut-être rabâché cet adage, mais dans beaucoup de domaines techniques, un schéma c’est plus simple pour débuter.

Et d’ailleurs, c’est un des principes du **sketchnoting** (littéralement « prise de notes visuelle »). Pour ceux qui ne connaissent pas, c’est une technique de facilitation graphique qui permet de « [favoriser la créativité, faciliter la mémorisation, produire et relire des notes de manière plus plaisante](https://primabord.eduscol.education.fr/qu-est-ce-qu-un-sketchnote)« .

![](/2019/11/ane_naiz_sketchnote.jpeg)

* Mon amie Ane (@ane_naiz) avait pris le temps d’en faire un sur le [talk que j’avais donné en 2019 à BDX I/O](/2019/11/15/le-support-de-ma-conf-logiciel-libre-a-bdx-i-o-2019/)

Depuis un mois, Aurélie Vache s’est mise à faire une série de Sketchnotes sur Kubernetes. 

En plus d’être visuel et donc facile à appréhender, les sketchs sont vraiment hypers accessibles même pour les débutants, tant en brossant un tableau assez complet du sujet.

(lien mort)

* [Understanding Kubernetes: part 1 – Pods](https://dev.to/aurelievache/kubernetes-sketchnotes-pods-4ib0)

A l’heure où j’écris cet article, il y en a 26, hébergés sur [dev.to][1] (et Aurélie a commencé une autre série de [sketchs sur Istio][2]). Si vous débutez, je vous conseille vivement d’aller regarder ses Sketchs pour appréhender les concepts clés de Kube.

## Autodidactes sur Youtube

Ça aurait été impensable il y a quelques années, mais aujourd’hui énormément de monde apprend voire se forme sur Youtube. 

Revers de la médaille, les contenus sont pléthoriques. Il est difficile de faire le tri entre les amateurs pas très pédagogues, les entreprises qui en fait vous vendent un produit...

Si vous voulez apprendre sur Youtube, il y a un passionné qui a publié **énormément** de contenu pour apprendre de manière sérieuse et accessible aux débutants sur tous les sujets « DevOps ». Il s’agit de Xavier Pestel.

La chaine [xavki][4] contient plusieurs centaines de vidéos assez courtes (10 minutes environ) pour traiter de chaque sujet par petits bouts, de manière incrémentale. Ça ne se limite pas à Kubernetes, Xavier a également fait de nombreuses vidéos sur la CI/CD, la sécurité, Ansible, etc.

Pour vous aider à vous y retrouver, vous pouvez utiliser les playlists ([il y a 66 vidéos sur Kubernetes](https://www.youtube.com/watch?v=37VLg7mlHu8&list=PLn6POgpklwWqfzaosSgX2XEKpse5VY2v5) par exemple) ce qui vous permettra de commencer un sujet donné et d’avancer à votre rythme.

![](/2020/05/xavki.png) 

## Master course

Petit ajout, on m’a remonté à plusieurs reprises beaucoup de bien des Master Courses de Redhat sur Kubernetes (Beginner et Elementary), animée en français par Sébastien Blanc. Il a déjà donné ce master class il y a un mois je crois, et vous avez de la chance, c’est replannifié :).

Si vous voulez vous inscrire, c’est sur un créneau d’une heure à chaque fois, respectivement le 1er et le 3 juin. 

Les inscriptions [se passent ici](https://developers.redhat.com/devnation/master-course/) et il y a aussi des sessions en anglais, en espagnol et en portugais (si jamais vous préférez).

![](/2020/05/devnation.png)

* [developers.redhat.com/devnation/master-course/](https://developers.redhat.com/devnation/master-course/)

## Des blogs

Mon support préféré ;-) mais pas toujours le plus simple.

Dans mon réseau, j’ai découvert le [blog de Thomas Rannou](http://thomasrannou.azurewebsites.net) (architecte logiciel qui parle plutôt d’Azure et a fait quelques articles très sympa sur AKS mais pas que) ainsi que [Thibault Le Reste](https://thibault-lereste.fr/) qui vient tout juste d’ouvrir un blog tech avec quelques articles sur Kubernetes également et à qui je souhaite de continuer sur cette lancée ;-).

Dans une autre catégorie, certaines sociétés de conseil éditent un blog avec des posts techniques pour, entre autres, se faire connaitre. Sans avoir aucun avis sur la partie consulting et/ou formation de leurs activités, les blogs sont eux souvent de bonne qualité.

_Note : pour un souci de transparence, je tiens à vous informer que je n’ai aucun intérêt à mettre en avant ces deux entreprises avec lesquelles je n’ai eu aucun contact._

Dans les ressources que je consulte TRÈS régulièrement, il y a le Twitter @learnk8s (avec [le blog qui va avec](https://learnkube.com/blog)) dans lequel je trouve souvent des tips and tricks intéressantes ainsi qu’une veille technique de qualité sur Kubernetes.

![](/2020/05/learnk8s.png) 

Un autre blog sympa, tenu par des Français cette fois-ci, c’est le [blog de Padok](https://www.padok.fr/blog/tag/kubernetes), qui a publié [quelques bons articles généraux sur Kubernetes][6] (mais pas que).

![](/2020/05/padok.png)

## Le mot de la fin

J’oublie **forcément** des gens qui font du contenu de qualité pour aider les débutants (et plus) à apprendre Kubernetes. Pour autant, je pense que c’est déjà une bonne base.

Néanmoins, si vous avez d’autres idées de sites, blogs, chaines intéressantes sur le sujet, n’hésitez pas à les citer dans les commentaires pour aider les copains :)

 [1]: https://dev.to/aurelievache/kubernetes-sketchnotes-pods-4ib0
 [2]: https://dev.to/aurelievache/understanding-istio-part-1-istio-components-4ik5
 [4]: https://www.youtube.com/channel/UCs_AZuYXi6NA9tkdbhjItHQ
 [6]: https://www.padok.fr/blog/tag/kubernetes
