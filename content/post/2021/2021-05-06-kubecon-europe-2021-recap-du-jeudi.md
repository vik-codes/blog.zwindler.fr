---
title: 'Kubecon Europe 2021 – Récap’ du jeudi'
authors:
  - zwindler
type: post
date: 2021-05-06T17:00:00+00:00
excerpt: Résumé de la deuxième journée de la KubeCon + CloudNativeCon Europe 2021
url: /2021/05/06/kubecon-europe-2021-recap-du-jeudi/
image: /2021/05/old.jpg
categories:
  - conference
tags:
  - cilium
  - eBPF
  - Kubecon
  - KubeCon Europe
  - kubecon europe 2021
  - Kubernetes

---
## **Deuxième jour de Kubecon**

Hier, je vous faisais un [petit résumé de la première journée de Kubecon !](/2021/05/05/kubecon-europe-2021-recap-du-mercredi/)

Si vous ne l’avez pas lu, je vous conseille de commencer par là, car je ne vais pas refaire la petite intro avec le contexte.

Aujourd’hui, les talks ont été très condensés et j’ai fait un gros focus réseau / sécu, comme vous pourrez le voir dans la suite de l’article :)

## Keynotes

Aujourd’hui, c’était moins dense en termes de nombre de keynotes.

La première keynote a été réalisée par Stephen Augustus, Co-Chair & Head of Open Source chez Cisco. Il a donné quelques nouvelles sur le projet Kubernetes. Le plus gros morceau est le fait qu’il ait été acté que la release cycle allait passer à 15 semaines, ce qui fait 3 releases par an maintenant au lieu de 4. Il a également parlé du fait que les SIGs doivent opt-in les modifications qu’ils veulent inclure dans chaque release et a aussi acté le retour des [community meetings](https://github.com/kubernetes/community/blob/master/events/community-meeting.md).

Les deux talks qui ont suivi étaient sans intérêt, avec un talk sponsorisé de Veeam très très basique sur la sécurité et un talk sur Linkerd qui sauve le monde du COVID-19, que j’ai trouvé plus que déplacé. Je ne me suis pas privé pour le dire sur Twitter d’ailleurs (lol).

![](/2021/05/old.jpg)

Le talk suivant (sponsorisé aussi) rattrapait un peu le niveau, avec un focus sur [Knative](https://knative.dev/) réalisé par Brenda Chan de chez VMware. Je n’ai pas encore regardé en détail ce qu’on pouvait faire avec knative et ce talk m’a donné envie de creuser le sujet.

La dernière keynote était assez intéressante, avec un REX sur l’intégration des projets cloud native par les équipes de Deutsche Telekom. Après avoir présenté les problèmes auxquels ses équipes ont du faire face, Vuk Gojnic a présenté [Das schiff](https://github.com/telekom/das-schiff), la solution qu’ils ont implémenté pour déployer des clusters Kubernetes distribués (as a service).

## **What Do You Mean K8s Doesn’t Have Users? How Do I Manage User Access Then?**

* [Page de la session](https://kccnceu2021.sched.com/event/iE4h/what-do-you-mean-k8s-doesnt-have-users-how-do-i-manage-user-access-then-jussi-nummelin-mirantis-inc)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/2a/KubeConEU2021_UserMgmt.pdf)

La journée a commencé plutôt soft avec un talk assez généraliste sur l’AuthN/AuthZ pr Jussi Nummelin de chez Mirantis. Il a pointé du doigt un vrai problème dans Kubernetes : il n’y a pas de gestion des utilisateurs humains a proprement parlé.

C’est d’ailleurs écrit noir sur blanc dans la documentation officielle de Kubernetes !

> It is assumed that a cluster-independent service manages normal users
> --[kubernetes.io/docs/reference/access-authn-authz/authentication/](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

Tout ce qui est authentification dans Kubernetes passe soit par certificat x509, soit par des tokens de service account soit par des webhook. Tout ceci est donc plutôt réservé aux pods, comptes de services et pas du tout adapté pour des personnes en chair et en os.

Je ne parlerai même pas de l’authentification &lsquo;static token file’ qui est un réel scandale qui ne devrait même pas être utilisée en lab.

La seule option viable est donc bien l’implémentation d’une authentification tierce via un connecter OIDC comme Dex, par exemple.

![](/2021/05/dex-horizontal-color.png)

* [github.com/dexidp/dex](https://github.com/dexidp/dex)

## **FalcOMG That’s AWESOME - New Things, Fixed Things, and YOU Panel**

* [Page de la session](https://kccnceu2021.sched.com/event/iE69/falcomg-thats-awesome-new-things-fixed-things-and-you-panel-leo-didonato-leonardo-grasso-sysdig-rajakavitha-kodhandapani-linode-thomas-labarussias-qonto?iframe=no)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/a1/FalcOMG That)

Cette session avait pour but de présenter tout un tas de choses à propos du [projet Falco](https://falco.org/). Pour rappel, Falco est un cloud-native security runtime, initié par Sysdig en 2016. Il utilise eBPF (encore lui) pour détecter voire empêcher les workloads suspects sur vos machines Linux (pas que Kubernetes donc). Les dernières parties qui manquaient ont été données par sysdig en février 2021 (kernel modules + ebpf probe + runtime security).

Après une longue introduction du projet (donné à la CNCF en 2018, accepté en tant qu’Incubating en 2020), deux mainteneurs (Leonardo Grasso et Leonardo Di Donato) ont présentés le processus de release ainsi que la façon dont les artefacts (cf falco open infra) sont générés automatiquement ([plus de 3500](https://download.falco.org/?prefix=driver/ae104eb20ff0198a5dcb0c91cc36c86e7c3f25c7/)).

L’équipe de falco est également très impliquée dans l’accès à cette technologie pour tous et recherche activement des traducteurs pour traduire le site et la documentation de falco dans le plus de langues possible. Le processus d’internationalisation a été présenté par Radhika Puthiyetath, technical writer chez sysdig. C’était assez intéressant de voir que le processus mis en place était assez simple et donc accessible au plus grand nombre.

Enfin, l’outil [falco sidekick](https://github.com/falcosecurity/falcosidekick) a été présenté par Thomas Labarussias, SRE chez Qonto. Il s’agit d’un démon permettant de collecter l’ensemble des événements transmis par falco (présent sur tous vos nodes kube par exemple) et de les forwarder à une 30aines d’outputs différents en fonction de certaines règles.

![](/2021/05/falcosidekick_color.png)

On peut ainsi mettre en place de l’alerting ou loguer les événements dans des SIEM ou des moteurs de recherche (Elasticsearch) pour traitements ultérieurs par exemple.

## **Uncovering a Sophisticated Kubernetes Attack in Real-Time**

* [Page de la session](https://kccnceu2021.sched.com/event/iE2u/uncovering-a-sophisticated-kubernetes-attack-in-real-time-jed-salazar-natalia-reka-ivanko-isovalent?iframe=no)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/3e/UncoveringASophisticatedAttackInRealTime_JedSalazar_NataliaRekaIvanko_06052021.pdf)

Troisième talk de la journée sur la sécurité !!! Natália Réka Ivánkó (Security Engineer chez Isovalent) et Jed Salazar (Manager, Platform Security chez Tesla) nous on présenté un panel assez large de risques de sécurité et de vecteurs d’attaques accessibles depuis un cluster Kubernetes.

Après avoir balayé très rapidement les solutions classiques pour réduire les risques (Distroless base images, OPA, pas de shells pour réduire la surface d’attaques, analyse statique des images et analyse au runtime), ils ont cherché à comprendre ce qu’on pouvait faire de plus.

On peut aussi appliquer à la sécurité le mindset « devops » (on parle parfois de devsecops) en considérant que ce qu’on a mis en place en termes de sécurité doit être (1) testé et (2) observé.

![](/2021/05/trust_but_verify.png)

Et selon eux, le meilleur outil pour le faire, c’est eBPF. Ils nous ont donc ensuite présenté plusieurs scenarii d’attaques dans lesquels [Cilium](https://cilium.io/) (eBPF-based Networking, Observability, and Security) était utilisé pour connecter, surveiller et sécuriser les événements sur le réseau de kubernetes.

Le talk était riche et dense et il est extrêmement dur pour moi de le résumer ici. Je serais probablement amené à en reparler sur le blog tant le sujet est pléthorique.

## **How to Break your Kubernetes Cluster with Networking**

* [Page de la session](https://kccnceu2021.sched.com/event/iE5i/how-to-break-your-kubernetes-cluster-with-networking-thomas-graf-isovalent?iframe=no)

* [Slides](https://static.sched.com/hosted_files/kccnceu2021/d0/Kubecon%20EU%2021%20-%20Breaking%20Kubernetes%20with%20Networking.pdf)

J’ai vraiment adoré le talk précédent mais alors celui là c’est le meilleur que j’ai vu depuis le début de cet Kubecon. Thomas Graf, en plus d’être un excellent pédagogue est un excellent speaker. C’est le CTO d’Isovalent (tiens tiens tiens, encore eux !) et il est core member du projet Cilium (encore lui !).

Là aussi, le talk était extrêmement dense et Thomas Graf s’est employé à brosser toutes les façons de casser son cluster Kubernetes avec le réseau. Cela va de bête erreurs DNS à l’utilisation de kube-proxy + iptables en passant par des CRD watchers qui DDoS votre API server et en finissant par des histoires d’horreur de changement de CNI (ou double run) qui cassent tout le réseau du cluster (kids, don’t do this at home).

Une fois de plus, le talk était tellement dense qu’il est difficile de le résumer. Ce qu’on peut en retenir simplement, c’est que le mieux est encore de rester le plus simple possible dans la limite de vos besoins et de ne pas ajouter trop de couches juste parce qu’elles sont « shiny ». (Et je suis évidemment à 100% d’accord).

> Oooooooh! Shiny ones!


## **Les talks que j’aurai voulu voir**

Je l’ai déjà dit hier, choisir c’est renoncer. 

Si j’avais pu, je serai également allé voir **BuildKit CLI for kubectl: A New Way to Build Container Images** par curiosité pour l’outil, que je ne connais pas. Mais les dieux du scheduling en ont voulu autrement (c’était pendant la présentation sur Falco).

## **Fin de la journée**

Si on peut appeler ça la fin de la journée puisque le dernier talk a fini vers 15h ;-) mais en vrai c’était tellement intense il y avait pas mal à débriefer.

Maintenant qu’on est au 2/3 de la Kubecon, je vois 2 sujets prioritaires qu’il va falloir que j’investigue sérieusement :

  * la partie eBPF, avec un vrai choix technique côté CNI (test de Cilium à faire absolument) et évaluation des outils de sécus basés sur des programmes BPF
  * la partie CI/CD avec flux, flagger, litmus (mais plutôt réservée pour mes copains ingés CI/CD, je ne ferai que suivre le mouvement)

On verra si la journée de demain changera un peu ces priorité ou pas (probablement que non).

Et en attendant, have fun :)
