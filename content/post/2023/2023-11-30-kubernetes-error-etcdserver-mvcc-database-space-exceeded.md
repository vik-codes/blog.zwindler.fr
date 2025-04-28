---
title: 'Kubernetes - Error from server: etcdserver: mvcc: database space exceeded'
authors:
  - zwindler
type: post
date: 2023-11-30T12:00:00+02:00
url: /2023/11/30/kubernetes-error-etcdserver-mvcc-database-space-exceeded/
image: /2023/11/bear-metal-kubernetes.jpeg
categories:
  - Virtualisation
tags:
  - Kubernetes
  - kubeadm
  - kubeadmcfg
  - etcd
  - mvcc

---

## Petite panique en prod !

Ca ne sera une surprise pour personne, j'administre des clusters Kubernetes en production (et aussi pour le fun, oui je suis bizarre). Et des fois, quand on a des workloads un peu inhabituels, on a des petites surprises rigolotes.

Pour vous situer un peu le contexte, j'ai un cluster "on-prem" d'une grosse soixantaine de nodes physiques baremetal, sur lesquels je fais tourner (entre autres) des jobs éphémères très courts.

Ca génère beaucoup de trafic sur la base de données etcd (beaucoup d'événement de création / destruction de pods) et ça nous a déjà posé des problèmes dans le passé (notamment pour tout ce qui est collecte de métriques, on effondre prometheus même avec beaucoup de RAM).

Mais ça tenait.

## Et là, c'est le drame...

Depuis peu, j'ai aussi commencé à ajouter plein de nouvelles "policies" sur Kyverno (pour ceux qui ne connaissent pas j'ai fait [un article sur le sujet](/2022/08/01/vos-politiques-de-conformite-sur-kubernetes-avec-kyverno/)). 

Et j'ai découvert un peu à mes dépens que Kyverno ajoute BEAUCOUP de pression sur etcd, en créant énormément d'événements (évaluation des policies pour chaque objet Kubernetes, et comme j'en ai beaucoup...).

A un tel point, qu'à un moment donnée, toutes les opérations d'écriture sur l'API server renvoyaient l'erreur suivante :

```
Error: etcdserver: mvcc: database space exceeded
```

![](/2023/11/ah.png)

Ca pue la DB pleine 😬😬😬. Pourtant, aucune alerte sur mes espaces disques !? Bizarre.

De toute façon, pour ne rien arranger, les pods etcd n'étant plus *healthy* puisque la base est supposément pleine, l'API server crashe au bout d'un moment et je n'avais plus la main sur rien pour debug.

PANIK!

## Remettre les gaz

Petite "astuce du pro" quand votre control plane Kubernetes est dans le mal, à un moment plus rien ne marche car les pods etcd / apiserver se mettent en `crashloop backoff`, étant alternativement down et pas relancé à cause du "backoff".

Un bon moyen de contourner ça, quand vous avez la main sur le control plane (donc pas sur du managé, mais de toute façon c'est pas votre problème), c'est de restart le `kubelet` sur tous les nodes du control plane en même temps.

Pourquoi ? Parce que le restart du `kubelet` remet à 0 tous les compteurs et que vos pods ne sont donc pas dans la phase de "backoff" trop longtemps, ce qui évite les problématiques de "pas assez de membres etcd sont on, donc je me saborde" et ainsi de suite.

![](/2023/11/crashloop_backoff_robusta.png)

[Source du diagramme : Substack de Natan Yellin pour robusta.dev](https://whyk8s.substack.com/p/why-crashloopbackoff-is-a-good-thing)

## Nettoyer la base etcd

Maintenant que c'est fait, j'avais suffisamment de pods etcd vivants (à défaut d'être opérationnel).

Un petit coup d'oeil sur mes graphes dans Grafana me montrent qu'il s'est effectivement "passé un truc" quand j'ai activé les nouvelles policies Kyverno.

![](/2023/11/etcd_stats.png)

Et "CÔM PAR HASAR", ça marche plus quand la taille de 2 des 3 bases de données etcd atteint 2 Gio

![](/2023/11/etcd_full.png)

Une rapide recherche sur Internet me confirme que ma base est pleine, et que la solution à mon problème est de compacter puis défragmenter ma base.

Comme tout est un peu cassé, on trouve des commandes bash à envoyer pour récupérer la dernière révision, compacter puis défragmenter la base :

```bash
# get latest revision
REVISION=$(ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*')

# compact
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt         --key=/etc/kubernetes/pki/etcd/peer.key compact ${REVISION}

# defrag
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key defrag

# SUPER MEGA IMPORTANT
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key alarm disarm
```

J'ai rajouté *SUPER MEGA IMPORTANT* sur la dernière instruction parce que, comme je suis un peu neuneu, je ne l'avais initialement pas lancée. 

Bah oui. L'idée de désarmer une alarme me paraissait complètement incongrue. L'alarme, je veux la garder. Non ?

Mais en fait, **c'est le comportement normal**. Le cluster etcd est prévu pour se bloquer, et **ne plus rien faire**, tant que l'alarme n'a pas été désarmé, même si le souci d'espace est résolu... 

Ok, je saurais la prochaine fois

> What does "mvcc: database space exceeded" mean and how do I fix it?
> The multi-version concurrency control data model in etcd keeps an exact history of the keyspace. Without periodically compacting this history (e.g., by setting --auto-compaction), etcd will eventually exhaust its storage space. If etcd runs low on storage space, it raises a space quota alarm to protect the cluster from further writes. So long as the alarm is raised, etcd responds to write requests with the error mvcc: database space exceeded.
>
> To recover from the low space quota alarm:
>
> - Compact etcd's history.
> - Defragment every etcd endpoint.
> **- Disarm the alarm.**

```console
memberID:11111111111111111111111 alarm:NOSPACE
```

Note : comme etcd ne revenait pas à la vie, j'ai balancé 50 fois la commande de compaction et ça me renvoyait une erreur qui me laissait penser qu'il y avait un autre problème. Et non, c'est bien que la compaction a été correctement faite ;-).

```console
error: code = OutOfRange desc = etcdserver: mvcc: required revision has been compacted"}
Error: etcdserver: mvcc: required revision has been compacted
```

## Éviter que ça se reproduise

OK, maintenant que la DB est restaurée, comment on s'assure que ça ne se reproduise pas ?

En réalité, les paramètres par défaut de la base etcd (locale) de `kubeadm` ne sont pas terribles.

D'abord, on voit que j'ai tapé la limite des 2 Gio, limite par défaut dans etcd, alors que je n'ai que 60-70 nodes et quelques milliers de pods (ok, j'en crée des centaines de milliers par jour, but still).

La documentation de Rancher conseille de monter cette limite à 5 Go ([Tuning etcd for Large Installations](https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/tune-etcd-for-large-installs)).

On va donc modifier la valeur `quota-backend-bytes`.

Ensuite, il faut activer la compaction automatique pour notre etcd. Comme j'utilise kubeadm et un fichier kubeadmcfg, je dois rajouter une section dans mon fichier pour tuner les paramètres

```yaml
etcd:
  local:
    extraArgs:
      quota-backend-bytes: "5368709120"
      auto-compaction-retention: "1"
      auto-compaction-mode: periodic
```

Puis régénérer les manifests sur tous mes nodes de control plane (malheureusement, ça ne se fait pas tout seul, cf [la documentation officielle de Kubernetes - Reflecting ClusterConfiguration changes on control plane nodes](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-reconfigure/#reflecting-clusterconfiguration-changes-on-control-plane-nodes))

```bash
kubeadm init phase etcd local --config kubeadmcfg.yaml
```

Note: attention, les arguments attendus sont des strings, donc entourez bien toutes les valeurs numériques entre quotes :

```console
json: cannot unmarshal number into Go struct field LocalEtcd.etcd.local.extraArgs of type string
```

Dernier point, s'il est possible de dire à etcd de réaliser la compaction tout seul comme un grand, a priori le defrag n'est pas automatique.

La plupart du temps ça n'est peut-être pas gênant mais comme je suis extrêmement bourrin avec la création / destruction de pods, j'ai dû automatiser aussi cette partie "defrag".

En attendant de trouver mieux, j'ai donc rajouté un cron

```cron
00 */3 * * * /usr/bin/etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/peer.crt --key=/etc/kubernetes/pki/etcd/peer.key --endpoints https://@IP:2379 defrag --cluster
```

Bon, c'était pas l'opération la plus fun de l'année, mais maintenant ça remarche 😂.

## Sources complémentaires

* [etcd blog - How to debug large db size issue?](https://etcd.io/blog/2023/how_to_debug_large_db_size_issue/)
* [etcd documentation - History compaction: v3 API Key-Value Database](https://etcd.io/docs/v3.5/op-guide/maintenance/#auto-compaction)
* [Kubernetes Community forums - Etcdserver: mvcc: database space exceeded](https://discuss.kubernetes.io/t/etcdserver-mvcc-database-space-exceeded/22806/3)
* [grosser.it - ETCD db size based compaction](https://grosser.it/2020/11/14/etcd-db-size-based-compaction/)
* [gist grosser.it - script pour compaction / defrag automatique (un peu bourrin)](https://gist.github.com/grosser/11d5d18c7aab8226788d190bb68479dc)
* [Platform9 KB - Cluster Operations Fail With Error - etcdserver: mvcc: database space exceeded ](https://platform9.com/kb/kubernetes/cluster-op-fail-etcdserver-mvcc-database-space-exceed)
