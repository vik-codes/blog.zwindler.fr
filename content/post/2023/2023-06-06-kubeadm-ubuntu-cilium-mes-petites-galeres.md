---
title: 'Kubeadm, Ubuntu 22.04 et cilium - mes petites galères récentes'
authors:
  - zwindler
type: post
date: 2023-06-06T12:00:00+02:00
url: /2023/06/06/kubeadm-ubuntu-cilium-mes-petites-galeres/
image: /2017/06/kubernetes2.png
categories:
  - DIY
  - Virtualisation
tags:
  - Homelab
  - Kubernetes
  - Ubuntu
  - Cilium

---

## Kubernetes, le retour de la vengeance

J'ai été pas mal pris ces derniers temps, autant côté pro que côté perso, et j'ai un peu délaissé mes clusters Kubernetes (qui vivent leur vie).

Aussi, quand j'ai eu le temps de m'y remettre, j'ai perdu pas mal de temps sur plusieurs "petites" bêtises liés, la plupart du temps à des modifications introduites dans les composants de ma stacks.

Une preuve (si c'était nécessaire) qu'il est important de se maintenir à la page, à jour et surtout de bien lire les changelogs.

Voici donc la liste des soucis que j'ai rencontrés et de comment on les corrige / contourne.

## cilium et kernel Ubuntu Minimal

L'an dernier, j'ai décidé de concevoir un nouveau talk inspiré de "dessine moi un cluster" de Jérôme Petazzoni. Dans ce talk dont j'ai déjà parlé ici, je construis en live coding un "cluster" Kubernetes brique par brique, binaire par binaire.

Et pour le CNI, j'avais choisi Cilium que j'utilise par ailleurs et que j'aime bien.

Sauf que 2 jours avant de monter sur scène, j'ai changé d'hébergeur un peu en urgence (problème de disponibilité) et patatra, le talk ne marchait plus. Cilium avait l'air de s'installer correctement mais les pods finissaient par crasher, rendant toute communication avec les Pods / Services de mon cluster impossible...

En creusant un peu, je suis tombé sur ces logs dans le container de l'agent cilium sur mon node :

```log
level=warning msg="+ tc qdisc replace dev cilium_vxlan clsact" subsys=datapath-loader
level=warning msg="RTNETLINK answers: Operation not supported" subsys=datapath-loader
level=warning msg="+ true" subsys=datapath-loader
level=warning msg="++ grep -v 'pref 1 bpf chain 0 $\\|pref 1 bpf chain 0 handle 0x1'" subsys=datapath-loader
level=warning msg="++ tc filter show dev cilium_vxlan ingress" subsys=datapath-loader
level=warning msg="RTNETLINK answers: Operation not supported" subsys=datapath-loader
level=warning msg="Dump terminated" subsys=datapath-loader
level=warning msg="+ '[' -z '' ']'" subsys=datapath-loader
level=warning msg="+ cilium bpf migrate-maps -s bpf_overlay.o" subsys=datapath-loader
level=warning msg="+ tc filter replace dev cilium_vxlan ingress prio 1 handle 1 bpf da obj bpf_overlay.o sec from-overlay" subsys=datapath-loader
level=warning msg="RTNETLINK answers: Operation not supported" subsys=datapath-loader
level=warning msg="We have an error talking to the kernel" subsys=datapath-loader
level=warning msg="+ cilium bpf migrate-maps -e bpf_overlay.o -r 1" subsys=datapath-loader
level=warning msg="+ return 1" subsys=datapath-loader
level=fatal msg="Error while creating daemon" error="error while initializing daemon: failed while reinitializing datapath: exit status 1" subsys=daemon
```

Et le message important là dedans, c'est `RTNETLINK answers: Operation not supported`, qui m'a permis de trouver [cette issue sur le dépôt github de cilium](https://github.com/cilium/cilium/issues/20858#issuecomment-1212024027).

Lorsque j'avais changé d'hébergeur, je n'avais pas fait attention mais les machines Ubuntu livrées l'étaient avec une install "minimal" sur laquelle il manque des capabilities, en particulier `CONFIG_NET_CLS_ACT=y` qui est un des prérequis de cilium.

Cependant, l'installation échoue silencieusement (ou alors c'est discret). Un gros warning aurait été le bienvenu...

L'erreur disparaît quand on change de kernel ou d'image de base.

## containerd et cgroups systemd

En essayant de créer un nouveau cluster Kubernetes avec `kubeadm` sur des machines Ubuntu 22.04, je me suis retrouvé assez vite avec un problème bizarre et très vite bloquant : les noeuds de mon cluster etcd tombaient les uns à la suite des autres, provoquant on crash du cluster.

Alors que tout semble ok, le container s'arrête avec un laconique `received signal; shutting down` :

```json
2022-02-05T00:46:42.582666628Z stderr F {"level":"info","ts":"2022-02-05T00:46:42.582Z","caller":"embed/serve.go:188","msg":"serving client traffic securely","address":"172.31.58.179:2379"}
2022-02-05T00:46:42.582757689Z stderr F {"level":"info","ts":"2022-02-05T00:46:42.582Z","caller":"etcdmain/main.go:47","msg":"notifying init daemon"}
2022-02-05T00:46:42.58276643Z stderr F {"level":"info","ts":"2022-02-05T00:46:42.582Z","caller":"etcdmain/main.go:53","msg":"successfully notified init daemon"}
2022-02-05T00:46:42.582906352Z stderr F {"level":"info","ts":"2022-02-05T00:46:42.582Z","caller":"embed/serve.go:188","msg":"serving client traffic securely","address":"127.0.0.1:2379"}
2022-02-05T00:56:02.302978572Z stderr F {"level":"info","ts":"2022-02-05T00:56:02.302Z","caller":"osutil/interrupt_unix.go:64","msg":"received signal; shutting down","signal":"terminated"}
```

En réalité, il s'agit d'une modification d'un paramètre de `containerd` que je n'avais jamais eu besoin de modifier lors de mes installations précédentes mais qui semble nécessaire maintenant.

En effet, quand on génère la configuration par défaut de container avec la commande `containerd config default`, la valeur SystemdCgroup est à **false**.

J'ai perdu un peu de temps mais heureusement je suis assez vite tombé sur [cette issue](https://github.com/etcd-io/etcd/issues/13670#issuecomment-1337727102), ainsi que sur [la documentation officielle qui indique bien la bonne configuration à faire](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd).

## `kubeadm` et plusieurs interfaces

Jusqu'à présent, je n'avais travaillé qu'avec des nodes qui n'avaient qu'une seule IP principale. Récemment, j'ai dû configurer `kubeadm` sur des machines avec plusieurs IPs/VLAN.

Lorsque j'ai commencé à essayer de configurer kubeadm pour qu'il en tienne compte, je me suis emmêlé les pinceaux

J'avais bien remarqué la présence d'un flag `--api-advertise` dans la commande `kubeadm init` mais je ne pouvais pas utiliser ce flag car j'utilise des fichiers de configuration *kubeadmcfg* de manière à pouvoir customiser de manière plus poussée mes clusters, et l'usage de flags conjointement avec le `--config` n'est pas supporté

Mon erreur avait été d'insérer un le bloc **localAPIEndpoint** (l'équivalent du `--api-advertise` mais dans la config) dans la **ClusterConfiguration** alors qu'il faut créer un autre manifest dans le même fichier avec pour kind **InitConfiguration**. 

```yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.0.0.4
  bindPort: 6443
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
controlPlaneEndpoint: 10.10.10.10
[...]
```

Cette valeur qui a priori semble ne concerner que l'API server override en fait tous les composants dans votre control plane (etcd, scheduler, controller manager) donc pas besoin de les configurer en plus.

A noter, pour tout ce qui est utilisation d'une Virtual IP qui *loadbalancerait* les requêtes vers vos APIservers, c'est bien **controlPlaneEndpoint** qu'il faut utiliser.

## Et alors, `kubelet` et plusieurs interfaces ?

Si jamais vous voulez modifier les IPs des composants du control plane, il est probable que vous voudrez aussi modifier celle du `kubelet`.

Pour modifier l'*InternalIP* de vos nodes, il est nécessaire de modifier les paramètres dans le `kubelet.conf`.

A partir de là, vous avez deux possibilités. La plus simple si vous avez plusieurs hostnames pour chaque IP, est d'utiliser le paramètre `--hostname-override` qui va permettre d'à la fois changer le hostname par défaut de la machine quand elle s'enregistre dans Kubernetes, mais aussi L'InternalIP.

Dans mon cas, ça ne m'aidait pas car l'IP qui m'intéressait n'avait pas de résolution DNS et je ne voulais pas modifier le hostname tel qu'il était.

Pour modifier l'interface sur laquelle `kubelet` écoute et l'InternalIP, il est nécessaire de modifier 2 paramètres : `--address` (pour l'interface d'écoute) et `--node-ip` (modifier l'InternalIP)

```bash
kubectl get nodes -o wide
NAME          STATUS   ROLES           AGE   VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
zwindler-01   Ready    control-plane   28m   v1.24.14   10.0.0.4   <none>        Ubuntu 22.04.2 LTS   5.19.0-42-generic   containerd://1.6.21
zwindler-02   Ready    control-plane   28m   v1.24.14   10.0.0.5   <none>        Ubuntu 22.04.2 LTS   5.19.0-42-generic   containerd://1.6.21
zwindler-03   Ready    control-plane   27m   v1.24.14   10.0.0.6   <none>        Ubuntu 22.04.2 LTS   5.19.0-42-generic   containerd://1.6.21
zwindler-04   Ready    node            27m   v1.24.14   10.0.0.7   <none>        Ubuntu 22.04.2 LTS   5.19.0-42-generic   containerd://1.6.21
zwindler-05   Ready    node            27m   v1.24.14   10.0.0.8   <none>        Ubuntu 22.04.2 LTS   5.19.0-42-generic   containerd://1.6.21
```

## Ubuntu 22.04 et ManageForeignRoutes

Je ne me suis pas le seul à s'être mangé de plein fouet cette modification de systemd sur les Ubuntu récents, puisque cette modification est la "rootcause" de l'incident global de mars de Datadog (vous pouvez aller [lire le postmortem ici](https://www.datadoghq.com/blog/engineering/2023-03-08-deep-dive-into-platform-level-impact/))

Quand j'installais cilium sur des serveurs Ubuntu 22.04, instantanément, il n'était plus possible de ping et/ou contacter les IPs locale de la machine, mais aucun problème pour contacter le reste du monde.

```
$ ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
^C
--- 10.0.0.1 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4076ms

$ ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=63 time=0.285 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=63 time=0.233 ms
64 bytes from 10.0.0.2: icmp_seq=3 ttl=63 time=0.248 ms

$ traceroute 10.0.0.1
traceroute to 10.0.0.1 (10.0.0.1), 30 hops max, 60 byte packets
 1  * * *
 2  zwindler-01 (10.0.0.1)  0.084 ms  0.079 ms  0.060 ms
 3  * * *
 4  zwindler-01 (10.0.0.1)  0.075 ms  0.097 ms  0.081 ms
 5  * * *
 6  zwindler-01 (10.0.0.1)  0.121 ms  0.137 ms  0.145 ms
 7  * * *
 [...]
```

Je montre avec ping, mais c'était pareil avec tous les ports. Et donc, toutes les liveness des composants du control plane crashaient puisque je ne pouvais plus contacter les IPs locales !

En réalité, si on creuse les [system requirements de cilium](https://docs.cilium.io/en/v1.13/operations/system_requirements/#systemd-based-distributions), c'est écrit !

![](/2023/06/systemd-networkd.png)

Par défaut, systemd-networkd supprime toutes les routes qu'il ne connaît pas et rentre en conflit direct avec cilium, d'où les problématiques de routage cheloues.

Et c'est exactement le même problème qu'a rencontré Datadog, puisqu'ils utilisent eux aussi Ubuntu 22.04 et cilium. Quand les updates sont passées, ils se sont retrouvés avec tous leurs clusters (worldwide) en vrac.

> on start-up of v248, systemd-networkd flushes all IP rules it does not know about. Five months after this initial change, an additional commit introduced in v249 made it possible to opt out of this behavior using a new `ManageForeignRoutingPolicyRules` setting. Both these changes were backported to systemd v248 and v247.
