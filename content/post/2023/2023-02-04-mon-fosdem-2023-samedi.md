---
title: 'Mon FOSDEM 2023 - Samedi'
authors:
  - zwindler
type: post
date: 2023-02-04T20:00:00+02:00
excerpt: Je suis pour la première fois de ma vie au FOSDEM et je fais un récapitulatif de cette première journée de conférence
url: /2023/02/04/mon-fosdem-2023-samedi/
image: /2023/02/ulb.jpg
categories:
  - conference
tags:
  - FOSDEM 2023
  - FOSDEM

---

## Premier FOSDEM ever

Note : vous pouvez aussi lire [l'article sur dimanche, il est ici](/2023/02/05/mon-fosdem-2023-dimanche/).

Si vous me suivez sur les réseaux sociaux, vous avez peut-être vu que j'étais cette année au FOSDEM (Free and Open Source Software Developers' European Meeting).

> Le FOSDEM est une conférence annuelle organisée à l'Université libre de Bruxelles depuis 2001. La rencontre a lieu chaque année en février avec plus de 5 000 participants
>
> https://fr.wikipedia.org/wiki/Free_and_open_source_software_developers%27_European_meeting

Ca fait une éternité que je veux venir (probablement 10 ans) et à chaque fois, ça n'avait pas pu se faire. Cette année, j'ai donc pris les devants, bloqué très (très) en avance mon agenda. Me voici donc, pour la première fois de ma vie en terre Belge.

Note : mon employeur a payé le voyage et l'hôtel, pour moi et 5 autres de mes collègues. Je l'en remercie.

## Keynote d'ouverture et swag

Pour commencer, j'ai voulu voir la keynote d'ouverture, histoire d'avoir l'expérience complète. C'était intéressant à voir et il y avait pas mal de conseils et d'explications pour les gens dont c'était le premier FOSDEM (comme moi donc).

Cependant, j'avais déjà reçu la plupart de ces conseils (et même plus) dans ce super article [How to survive FOSDEM de Marcin Juszkiewicz](https://marcin.juszkiewicz.com.pl/2019/10/15/how-to-survive-fosdem/).

Sans trop de surprise, la salle de la keynote (pourtant le plus gros amphi si j'ai bien compris) était archi pleine.

![](/2023/02/keynote.jpg)

Une fois la keynote finie, je suis évidemment allé faire la queue (j'étais pas seul) pour acheter mon sweat FOSDEM 2023 (qui sert surtout à financer à l'événement qui est gratuit pour les participants).

J'avais mal lu cette partie de l'article de Marcin, j'ai compris plus tard qu'on pouvait tout simplement faire un don. Je ferai plutôt ça, la prochaine fois.

> You can go to organizers’ desk and donate money to keep the event going. For 25€ you can get the official t-shirt.

## Drawing your Kubernetes cluster the right way

Je me suis ensuite dépêché d'aller à la devroom "container" où j'avais prévu de passer la majorité de la journée. Car arriver tard à une room peut être fatal ;-) (les vrai⋅es savent)

![](/2023/02/roomfull.jpg)

Le talk [Drawing your Kubernetes cluster the right way](https://fosdem.org/2023/schedule/event/container_kubernetes_cluster_right_way/) de Dmitriy Kostiuk était assez intéressant quoiqu'un peu généraliste.

![](/2023/02/draw_kubernetes.jpg)

Le postulat de départ était que la facilitation graphique permet d'aider les apprenants à comprendre des abstractions complexes, ce qui est utile dans le cas de Kubernetes. L'idée était de montrer les dos and don'ts pour les schémas (en particulier sur Kubernetes donc).

Les conseils sont très bons (utiliser des couleurs intelligemment, limiter les flèches, grouper/stacker) mais j'ai quand même été un peu déçu : j'aurais aimé qu'il montre des dessins et pas seulement des schémas, car le titre de la conférence était "drawing". 

J'aurais aussi aimé qu'il nous montre un exemple **à lui**, car, sauf erreur, il a surtout commenté des schémas d'autres personnes / entités qu'il a trouvé sur Internet.

## Send in the chown(2)s

Je n'avais pas spécialement retenu ce talk dans la liste de ceux que je voulais voir absolument, mais j'ai été agréablement surpris. 

[Ce talk Fraser Tweedale](https://fosdem.org/2023/schedule/event/container_send_in_chown/) était assez technique et a expliqué pourquoi et comment les user namespaces avaient été ajoutés par Redhat dans OpenShift (puis dans Kubernetes 1.25).

![](/2023/02/usernamespaces.jpg)

L'ajout de cette feature a, je pense, un grand intérêt en termes de sécurité et permet d'ajouter le support de choses qu'on pouvait difficile (voire pas du tout faire) avant.

J'avoue que j'avais vu passer l'info à la sortie de Kubernetes 1.25 mais que je ne m'y étais pas du tout penché. Je vais regarder ça avec intérêt en rentrant.

* [Github.com - KEP-127: Support User Namespaces](https://github.com/kubernetes/enhancements/blob/master/keps/sig-node/127-user-namespaces/README.md)

## Deploying Kubernetes across Hybrid and Multi-Cloud Environments Using OpenNebula

Après une petite pause gaufres, je suis retourné dans la devroom containers pour voir un talk sur le déploiement de [clusters Kubernetes avec OpenNebula](https://fosdem.org/2023/schedule/event/container_kubernetes_multi_cloud/).

![](/2023/02/opennebula.jpg)

J'ai été un poil moins emballé... j'ai trouvé le talk un peu "commercial" et la démo n'était pas du tout claire (vidéo enregistrée, impossible de comprendre / voir de loin).

J'essayerai peut-être d'y revenir avec mon lab, dans les semaines qui viennent, pour voir si je comprends mieux, même si je commence à bien connaître les composants internes de l'outil vu les tests que j'ai fait récemment (RKE2, longhorn, traefik, terraform, ansible) 😉.

## Touring the container developer tooling lanscape

Le talk suivant était [un talk de Phil Estes](https://fosdem.org/2023/schedule/event/container_developer_tooling/), qui faisait un tour d'horizon des outils existants pour gérer facilement Docker / Kubernetes sur les postes de développeurs, souvent "pas sous Linux".

Son constat est que, si Docker a grandement facilité l'expérience développeur, mais que cette techno est surtout accessible facilement sous Linux.

Il a listé les outils disponibles sur le marché et leurs avantages / inconvénients, avant de parler de la solution que lui-même développait.

Le talk ne s'adressait pas spécialement à moi mais le speaker était excellent.

## Exploring Database Containers

Après un repas digne des plus grands champions ("asian food" + trappist rochefort), je suis allé voir le talk d'[Edith Puclla de chez Percona - Exploring Database Containers](https://fosdem.org/2023/schedule/event/container_database_containers/).

Son talk était très orienté "débutant" donc là aussi je n'étais pas du tout le public cible. J'ai un peu peur que ça ait été aussi le cas d'une partie significative de la salle.

Cependant, le talk était très didactique, Edith et très pédagogue, avec de l'interaction avec le public, beaucoup de schémas...

![](/2023/02/database_containers.jpg)

## Cluster API - Operating Kubernetes with Kubernetes

[Le talk d'Alex Demicev sur la ClusterAPI de Kubernetes](https://fosdem.org/2023/schedule/event/container_kubernetes_cluster_api/) était en réalité une démo live de la gestion de cluster Kubernetes depuis leur création.

![](/2023/02/clusterapi.jpg)

Je ne vais pas décrire le talk plus que ça. Si cette API vous intéresse, le mieux est de voir la démo qui est assez simple à reproduire (les fichiers sont à disposition... quelque part ?).

## 7 years of cgroups v2 - the future of Linux resources control

J'ai terminé sur LE talk de ma journée. 

La lumière diminuant et l'appel de la bière belge se faisant entendre, on commençait à ne plus être très nombreux, mais clairement celui ci valait le coup d'attendre un peu !

Ce talk faisait suite à plusieurs autres talks sur l'introduction de cgroup v2 (annoncé à la QCon 2017), avec un focus sur la période COVID.

Pendant cette période, Chris a expliqué que les besoins en ressources chez Meta ont explosé alors même que l'approvisionnement en matériels (serveurs et en particulier RAM) était particulièrement compliqué (voire impossible).

Il a donc fallu faire plus avec moins et Chris a raconté avec brio comment ils ont tiré parti de fonctionnalité des cgroups et du kernel Linux pour gagner en efficience sur leur parc existant.

![](/2023/02/cgroups.jpg)

Chris a terminé son intervention par une petite phrase qui m'a beaucoup plu et je décide donc que ça sera la phrase de ma journée :)

> Peace, love and stay hydrated

Que ces paroles nous servent de guide pour ce soir ;)
