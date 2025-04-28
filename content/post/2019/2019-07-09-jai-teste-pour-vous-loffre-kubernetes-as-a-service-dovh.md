---
title: 'J’ai testé pour vous : l’offre Kubernetes as a service d’OVH'
authors:
  - zwindler
type: post
date: 2019-07-09T11:30:50+00:00
excerpt: Test de l"offre Kubernetes as a Service d"OVH
url: /2019/07/09/jai-teste-pour-vous-loffre-kubernetes-as-a-service-dovh/
image: /2019/07/cropped-ovh_kubernetes.png
classic-editor-remember:
  - block-editor
categories:
  - Cluster
tags:
  - AKS
  - azure
  - Cloud
  - k8s
  - KaaS
  - Kubernetes
  - OVH

---

## OVH sort son offre Kubernetes managée

Vous avez peut être vu passer l’actualité début février, OVH a lancé (comme d’autres cloud providers) [son offre Kubernetes as a service (KaaS)](https://www.ovh.com/fr/public-cloud/kubernetes/).

![](/2019/06/kas.jpg)

> Cette blague hilarante vous est offerte par zwindler !

Comme beaucoup de techno non triviales, une offre managée, c’est un bon moyen de mettre le pied à l’étrier si vous ne connaissez pas encore Kubernetes. C’est aussi un bon moyen pour OVH pour ne pas trop se laisser distancer par les géants américains.

En avril dernier, j’ai pu participer à un meetup dans les locaux d’OVH et de rencontrer les personnes qui avaient mis en place cette technologie. Du coup, je vous propose un petit article dans lequel on va voir ensemble à quoi ça ressemble.

## Côté tarif

C’est le nerf de la guerre. Comme tous les autres (à l’exception notable d’EKS d’Amazon), vous ne payez que pour les workers, pas pour les masters (le control plane donc). Niveau tarif pour les workers, c’est simple, ce sont les tarifs applicables sur l’offre cloud public d’OVH.

La plus petite machine que vous pouvez sélectionner est un machine Linux de type B2-7, avec 2 vCPUs, 7 Go de RAM et 50 Go de SSD local.

C’est suffisant pour faire des tests, mais en production on en voudra au minimum 3, ce qui à 22€HT/mois pièce vous fera quand même environ 75€ / mois.

Au final, on est objectivement moins cher que ce que [j’avais pu tester sur AKS](/2018/12/18/jai-teste-pour-vous-aks-la-plateforme-kubernetes-managee-dazure/). Car pour rappel, j’avais monté un cluster de machines de type B2ms avec 2 vCPU et 8 Go de RAM pour 30€ / mois, donc identique. SAUF que ces machines sont des machines dites "burstable" (vous n’avez qu’une portion d’un vCPU, que vous ne pouvez dépasser que pour une durée réduite avant de subir un throttling). Des machines équivalentes reviendraient sur Azure à utiliser des D2, pour un tarif de 83€TTC / mois... par machine !!!

Le fait que le control plane (les masters) ne soient pas payant est à la fois un avantage et un inconvénient. Pour OVH, je n’ai pas encore la réponse, mais lorsque j’avais testé AKS d’Azure, j’avais demandé au commercial ce qui se passait si mon control plane était HS (vu que c’est eux qui gèrent, je ne peux pas prendre la main pour le fixer). Il m’avait répondu texto : "comme c’est un produit gratuit, on ne s’engage sur aucune SLA (seulement un SLO de 2h)". De quoi refroidir quand on est habitué à avoir la main sur son cluster Kubernetes.

## Et si on testait ?
  
Assez parlé ! Dans mon manager d’OVH, j’ai créé un nouveau projet, que j’ai nommé de manière originale "Kubernetes Project". Puis, j’ai créé un cluster Kubernetes en cliquant sur "Créer un cluster Kubernetes"



![](/2019/06/ovh_manager1.png) 

Actuellement, seul le DC "Graveline 5" semble capable d’accueillir l’offre KaaS d’OVH. Un point qu’il faudra améliorer dans le futur pour pouvoir se construire une infrastructure réellement résiliente.

Edit: Une deuxième région sera disponible dans le mois (cf Maxime Hurtrel, PM K8s chez OVH)



![](/2019/06/creer_kubernetes1-1.png) 


Niveau version de Kubernetes, bonne nouvelle, OVH s’est donné les moyens de proposer des versions très à jour de Kubernetes. Toutes les versions depuis la 1.11 jusqu’à la version 1.14 sont disponibles. La 1.14, qui n’a que quelques mois, est devenue dispo chez OVH assez rapidement. On peut imaginer que la 1.15 de Kubernetes qui vient tout juste de sortir (mi juin) sera probablement assez vite disponible aussi.

A titre de comparaison, chez Azure, ils sont assez bons dans ce domaine, et pourtant ils n’ont la 1.14 qu’en preview. Le mauvais élève Amazon est à la traîne avec seulement la 1.12 (pourtant sortie en septembre 2018).

## "Ca va trop vite"
  
Cette partie là est relativement impressionnante. La création d’un nouveau cluster est extrêmement rapide.



![](/2019/06/kube1.4-1.png) 


Au total, l’instanciation d’un cluster met moins d’une minute, là où AKS en nécessite une 20aine (en comptant les workers certes, mais bon la moitié du temps le portal ou l’appel à l’API plante !).

Ceci est du à la façon dont le control plane a été créé et conçu par les équipes d’OVH (j’y reviendrais juste après) et est clairement une réussite. Pour avoir déployé à la main Kubernetes un paquet de fois et avec de nombreuses méthodes différentes ([cf mes divers articles sur le sujet](/recherche/?keyword=kubernetes)), c’est la méthode la plus rapide d’installer Kubernetes, et de loin.

## L’architecture du control plane

Un des trucs sympas avec OVH, c’est qu’ils n’hésitent pas à communiquer sur les détails techniques. Certes, ils ne sont pas les seuls, mais c’est toujours agréables.

Lors du [CNCF Meetup, Kevin Georges, Pierre Peronnet et Sébastien Jardin](https://www.meetup.com/fr-FR/Cloud-Native-Computing-Bordeaux/events/259991418/) nous ont donc présenté les entrailles de leur Kubernetes as a service.

L’idée principale est que le _control plane_ doit être le plus léger possible, pour coûter le moins cher possible à OVH (vu que c’est gratuit), tout en restant résilient.

La solution qui a été retenue pour arriver à une solution acceptable a été de déployer les services nécessaires au control plane de Kubernetes (control malanger, api server, scheduler) dans ... un Kubernetes ! La seule brique non containerisée est etcd, et il s’agit ici d’un cluster dédié sur des machines physiques (ce qui explique probablement la limitation au DC Graveline).

Dans tous les cas, ça explique probablement aussi la vitesse de démarrage d’un nouveau cluster : il faut juste lancer 3 containers et zou, un nouveau cluster.

![](/2019/07/1-pFziI2YQgKEYx2qLWP68ww.png)

> Source : OVH https://www.ovh.com/fr/blog/kubinception-using-kubernetes-to-run-kubernetes/

L’article technique détaillant tout ça est dispo [sur le site d’OVH](https://www.ovh.com/fr/blog/kubinception-using-kubernetes-to-run-kubernetes/), je n’en dis pas plus, ils l’expliquent mieux que moi.

## Les workers

Pour la partie Workers, plutôt que de développer sa propre API et l’intégrer comme module du projet Kubernetes (comme les autres gros cloud providers, [qui ont leur code embarqué dans celui de Kubernetes](https://github.com/kubernetes/kubernetes/tree/7f23a743e8c23ac6489340bbb34fa6f1d392db9d/pkg/cloudprovider/providers)), la team chez OVH en charge du projet s’est appuyée sur de l’existant : leurs propres services OpenStack fournissent déjà l’ensemble des briques dont ils ont besoin pour créer des VMs à la volées et les intégrer à des clusters Kubernetes.

Quand j’ai demandé au Meetup combien de temps il fallait pour "poper" un nouveau worker, un des trois speakers m’a dit, tout désolé "on ne fait pas de miracles, il faut quelques minutes". Il n’a pas compris le pauvre quand j’ai éclaté de rire (parce que sur Azure, ça prend des plombes).

## Ajouter des workers
  
  
La procédure est assez simple, mais se fait au travers de l’interface (comme la création du cluster). Je suis quasiment certain que tout doit pouvoir se piloter par API (je vois mal pourquoi ils auraient fait autrement pour un service tout neuf), pour autant, je n’en ai pas trouvé de trace dans la [documentation officielle (pas à jour avec la nouvelle interface et encore un peu light)](https://docs.ovh.com/gb/en/kubernetes/)



![](/2019/06/add_nodes_ovh2.png) 


Bon, alors je suis peut être mal tombé, mais quand j’ai cliqué dans l’interface pour ajouter des nodes, ça a quand même pris énormément de temps (facile 20-30 minutes). Du coup j’étais un peu (très) déçu...

Après investigation, en fait... c’est l’interface qui déconne ! En réalité, mon nœud était UP depuis longtemps déjà.

Je m’en suis rendu compte en faisant un petit kubectl get nodes et j’ai vu que mon node "Ready" depuis 28 minutes était encore marqué "En cours d’installation" ...

```
kubectl get nodes -o wide
NAME STATUS ROLES AGE VERSION INTERNAL-IP EXTERNAL-IP OS-IMAGE KERNEL-VERSION CONTAINER-RUNTIME
vm1.12-1 Ready <none> 28m v1.12.7 51.77.204.236 <none> Container Linux by CoreOS 2135.4.0 (Rhyolite) 4.19.50-coreos-r1 docker://18.6.3
```



## Se connecter au cluster
  
  
D’ailleurs, comment on s’y connecte ? Pas de souci de ce côté, OVH vous simplifie la vie en vous proposant de télécharger directement votre fichier kubeconfig préconfiguré, prêt à utiliser.

Si vous en avez plusieurs, pour rappel, vous pouvez utiliser le flag "--kubeconfig=kubeconfig.yml"

![](/2019/07/kubeconfig.png)

## En vrai, un node ne met que 3 minutes à poper
  
  
Du coup, j’ai voulu retester le démarrage d’une nouvelle VM, en sachant que le temps indiqué sur l’interface web n’est pas bon.

Après quelques tests, en 3 minutes, le node apparait en "Not Ready", puis passe "Ready" au bout de quelques secondes. On est donc très proche de ce dont j’avais pu parler avec les gens d’OVH du coup, c’est très bon comme temps de boot.

Ouf, on est rassurés !

## Mise à jour
  
  
Un point sympa que permettent les solutions de type KaaS est la gestion des mises à jour depuis votre interface de gestion. Mettre à jour Kubernetes, c’est pénible. La moitié du temps, on a peur de tout casser.

Alors je ne dis pas que rien ne va casser avec le Kubernetes d’OVH, mais comme l’infra est cadrée et gérée par eux, j’imagine que c’est suffisamment bien testé dans des conditions similaires aux vôtres pour être un peu plus serein le jour où ça arrive.

A noter, contrairement à AKS, vous n’avez que peu la main sur les mises à jour. Cela se limite à ça, et je n’ai pas trouver comment monter de la 1.12 à la 1.13 par exemple...



![](/2019/07/politique_secu_ovh_kubernetes.png) 


_Edit: Toujours selon Maxime Hurtrel, ça devrait arriver bientôt_

## Conclusion : au delà du compute, l’UI

Dans les points qui déchirent : OVH sait fournir un control plane à une vitesse à faire pâlir d’envie tous les concurrents.

Cependant, cela se fait sur un cluster Kubernetes mono DC (DC5 Graveline), avec la partie etcd externalisée à part, sur un cluster mutualisé. Je ne fais pas de jugement de valeur car, contrairement à OVH qui est transparent, je n’ai pas d’info technique sur les versions proposées par la concurrence.

En revanche, je peux comparer avec un cluster que j’installe moi même, et là clairement, je suis un cran en dessous en terme de ce qui peut être fait en terme de sécurisation de mon cluster.

Pour ce qui est de l’interface, elle souffre un peu de sa jeunesse. Il n’y a rien de plus que les onglets pour créer un cluster et pour ajouter ou supprimer des nœuds (et encore, pas plus d’info sur ces nœuds que leur nom et leur taille !).

Un dernier onglet existe pour "visualiser" ses containers et ses services, mais il est pour l’instant vide et sera de toute façon probablement moins utile que le dashboard ou tout autre outil existant (sauf à fournir un énorme effort de dev sur ce point).



![](/2019/07/kube_dashboard.png) 


Encore un exemple de la jeunesse de la solution et particulièrement de son interface : OVH pope des VMs (workers) très vite, ce qui devrait être super cool et soulever les foules... mais si on teste la solution rapidement, comme l’interface ne l’indique pas, on pourrait penser que ce n’est pas le cas ! Dommage !

_Edit: Le problème est connu et en cours de fix_

[Le tweet n'est plus disponible]
  
Et pour ce qui est des mises à jour, c’est le flou total. On vous explique que tout est maintenu à jour, mais les montées de versions majeurs sur un cluster ne semble pas disponible pour l’instant.

Dans les points pas glop : aucune trace dans la doc d’API pour créer des clusters à la volée ou les gérer de manière automatisée via Ansible ou autre...

Edit: [l’API est là](https://api.ovh.com/console/#/cloud/project/%7BserviceName%7D/kube#GET)

[Le tweet n'est plus disponible]
  
Bref, vous l’aurez compris, techniquement c’est une réussite. Chez OVH, ils savent gérer des VMs et des containers et ça se voit. Mais l’offre KaaS d’OVH manque peut être encore d’un petit coup de polish pour qu’on se sente bien chez soi, et pleinement en confiance. Et c’est d’autant plus rageant que la solution a plein de bons points, que le travail abattu (en peu de temps) est colossal.

Je voudrais donc tenter de terminer sur une note positive, car c’est mon ressenti au global. Pour avoir rencontré des membres de l’équipes (de vrais passionnés), j’ai envie de croire que ce produit est amené à grandir, et ses petits défauts de jeunesse à disparaître.

A suivre donc !

## Bonus GPU

Dans les petits "trucs" qui m’ont fait sourire, j’ai vu passer un tweet indiquant qu’OVH se lançait également (en alpha par contre pour l’instant) dans Kubernetes managé avec des instances baremetal avec GPU.

Je n’ai pas forcément de workload en tête, mais pour ceux qui veulent lancer des containers avec des calculs GPU, c’est une option qui peut faire sens.

Si vous voulez en savoir plus, c’est par ici :

* [Labs OVH GPU baremetal k8s nodes](https://labs.ovh.com/gpu-baremetal-kubernetes-nodes)
      
