---
title: Récap du troisième et dernier jour de Kubecon Europe 2022 - Vendredi
authors:
  - zwindler
type: post
date: 2022-05-22T12:00:00+00:00
excerpt: "Récap' du troisième et dernier jour (vendredi) de la KubeCon + CloudNativeCon Europe 2022"
url: /2022/05/22/kubecon-eu-2022-jour-3-vendredi
image: /2022/05/PXL_20220520_070037429.MP.jpg
categories:
  - Conférence
tags:
  - Kubecon
  - Kubecon Europe
  - Kubecon Europe 2022
  - Conférence
  - Kubernetes
  - CloudNative

---

Cet article fait partie d'une suite de 3 posts :
* [Récap du premier jour de Kubecon Europe 2022 - Mercredi](/2022/05/19/kubecon-eu-2022-jour-1-mercredi)
* [Récap du deuxième jour de Kubecon Europe 2022 - Jeudi](/2022/05/20/kubecon-eu-2022-jour-2-jeudi)
* Récap du troisième et dernier jour de Kubecon Europe 2022 - Vendredi

## This is the end. Hold your breath and count to ten.

Ce matin je suis arrivé un peu tard. Juste à temps pour entendre Bryan Che, Chief Strategy Officer chez Huawei nous parler de multicloud, et après ça, d'apprendre que Apple avait gagné cette année le "End User Awards". Cette dernière keynote a été hyper courte, c'était un peu déstabilisant.

Les keynotes ayant donc fini plus tôt que prévu, j'ai eu le temps de faire un autre petit tour des sponsors.

L'occasion d'aller voir Civo ([dont j'ai parlé l'an dernier](/2021/07/16/civo-du-kubernetes-manage-a-partir-de-4-mois-vraiment)), Gitlab (coucou Philippe :D) et [Gitpod](https://gitpod.io/) (que j'adore, pour mes besoins persos)

<img src="/2022/05/PXL_20220520_083003596.jpg" heigth="450"/>

## A Treasure Map of Hacking (and Defending) Kubernetes

J'avais très envie d'aller voir ce talk de Andrew Martin (ControlPlane, aussi co-auteur de [Hacking Kubernetes](https://www.oreilly.com/library/view/hacking-kubernetes/9781492081722/)), vu que j'ai fait plusieurs conférences en tant que speaker sur la sécurité dans Kubernetes.

![](/2022/05/PXL_20220520_085720513.MP.jpg)

Après avoir rappelé quelques principes de sécurité et rappelé qu'il faut essayer de comprendre l'adversaire de manière à se défendre correctement.

> Attackers think graphs, Defenders think lists

Malgré quelques petits problèmes de demo et de laptop qui freeze, Andrew a fait ensuite plusieurs démos de comment on peut prendre le contrôle d'un cluster Kubernetes. 

C'était quand même très cool de voir un scenario d'attaque complet, quoiqu'un peu dur à suivre.

A voir aussi : [Kubernetes threat modelling a lightspeed introduction](https://kccnceu2022.sched.com/event/ytqj/threat-modelling-kubernetes-a-lightspeed-introduction-lewis-denham-parry-control-plane?iframe=no)

## What Anime Taught Me About K8s Development & Tech Careers

Après 3 jours de Kubecon + soirées, j'étais clairement rinçé. Je me suis dit qu'un sujet "détente" ne me ferait pas de mal.

Annie Talvasto (Camunda) a voulu tirer des parallèles entre Kubernetes et les animes.

Bon... contrairement au talk précédent, ici c'était vraiment très très (très) 101 (contrairement à la session précédente, soi-disant 101 aussi).

![](/2022/05/PXL_20220520_100532867.MP.jpg)

C'était amusant, mais un peu tiré par les cheveux parfois. La bonne humeur d'Annie a rendu l'expérience fun.

## Better Bandwidth Management with eBPF

Nécessairement, avec les vols retours, il y a moins de talks l'après-midi. Encore pire, dans mon cas, je n'avais le temps que pour un talk après déjeuner et je ne regrette VRAIMENT pas d'y être allé.

Je le mets dans mon top 3 de cette Kubecon sans hésitation.

Daniel Borkmann & Christopher M. Luciano, de chez Isovalent, nous ont parlé de gestion de la bande passante dans les clusters Kubernetes.

![](/2022/05/PXL_20220520_120037972.jpg)

Le constat initial est que les nodes Kube commencent à devenir plus gros, et le corolaire de ça qu'on augmente la densité de pod par node, et donc la compétition sur les ressources, notamment réseau.

Or, contrairement au CPU et à la RAM (et aussi dans une certaine mesure aux disques locaux avec ephemeral-storage), la consommation réseau n'est pas du tout pilotable dans Kubernetes aujourd'hui. Il existe aujourd'hui un support expérimental de "bandwidth enforcement" à base de TBF (token backend filter) mais les perfs sont mauvaises.

Long story short, c'est insuffisant, et on peut faire mieux avec eBPF, cilium et certaines fonctionnalités sorties dans le kernel 5.18. 

Si vous voulez en savoir plus sur EDT (Earliest Departure Time), BBR et la gestion des timestamps des trames TCP dans un network namespace, ce talk est clairement à (re)voir !

## C'est déjà fini

Cette Kubecon était (comme d'habitude) super intense. J'ai croisé IRL des gens avec qui j'avais échangé sur Internet (Pascal Martin), eu des conversations enrichissantes avec des sponsors (LaunchDarkly, HAproxy, Timescale, Honeycomb, solo.io, env0), revu des copains de confs (coucou la team OVHcloud).

J'ai discuté avec des inconnus venant de partout dans le monde mais aussi quelques Français, croisés au hasard (coucou Smaïne), longuement échangé avec mon collègue Christian sur ce qu'on venait de voir, qu'on pourrait améliorer.

J'ai découvert une ville très chouette et j'ai baraguouiné quelques mots d'espagnol 😅.

![](/2022/05/PXL_20220520_062541942.jpg)
![](/2022/05/PXL_20220520_064643062.jpg)

Au revoir, Valencia.

![](/2022/05/PXL_20220520_171031416.jpg)

## Talks que j'aurais aimé voir

* Observing Fastly’s Network at Scale Thanks to K8s and the Strimzi Operator - Fernando Crespo & Daniel Caballero, Fastly
* Logs Told Us It Was DNS, It Felt Like DNS, It Had To Be DNS, It Wasn’t DNS - Laurent Bernaille & Elijah Andrews, Datadog
* "My CNI Plugin Did… What?!": Debugging CNI with Style and Aplomb - Douglas Smith & Daniel Mellado Area, Red Hat
* Kubernetes Everywhere: Lessons Learned From Going Multi-Cloud - Niko Smeds, Grafana Labs
* Distributing PromQL for Fast and Efficient Kubernetes Fleet Monitoring - Moad Zardab, Red Hat & Filip Petkovski, Shopify
* Komrade: an Open-Source Security Chaos Engineering (SCE) Tool for K8s - Aaron Rinehart, Verica.io & Matas Kulkovas, Cast.ai
