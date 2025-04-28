---
title: Pourquoi Helm 2 doit disparaître
authors:
  - zwindler
type: post
date: 2021-04-19T07:59:14+00:00
excerpt: Pourquoi déployer avec helm 2 est un enfer et que vous devriez passer sur Helm 3 (voir dégager complètement Helm)
url: /2021/04/19/pourquoi-helm-2-doit-disparaitre/
image: /2021/04/Rage.jpg
categories:
  - Cluster
  - Virtualisation
tags:
  - CI
  - Déploiement
  - Helm
  - helm 2
  - helm 3
  - Kubernetes

---

## Deployer sur Kubernetes avec Helm, c’est vraiment se faire du mal



Je ne sais plus qui parmi vous écrivait il y a peu « Avec Kubernetes, c’est un peu une love/hate relationship ». J’adore Kubernetes, particulièrement dans les contextes où il résout des « million-dollar problems ». Mais alors... QU’EST CE QUE JE DETESTE HELM.



Je rage / shitpost régulièrement sur Helm, mais malheureusement il n’y a pas tant d’alternatives pour déployer facilement dans Kubernetes (oui je sais qu’il y en a, ce n’est pas le but du post).



## Mais attend, tu parles de Helm 2 dans ton titre ?

Ça fait des années que j’ai ce brouillon en attente sur le blog (encore un, me direz-vous). Je commençais à me dire que ce n’avait plus vraiment d’intérêt de le poster maintenant que [Helm 2 est officiellement déprécié et remplacé par Helm 3 depuis quasiment 1 an.](https://helm.sh/blog/helm-v2-deprecation-timeline/)


Mais j’ai lu un [chouette article de serveur410](https://serveur410.com/ton-coin-de-web-tattends/) il y a quelques jours qui m’a décomplexé de poster des articles anachroniques (et je vous invite à aller lire cet article, que vous ayez un blog ou non).



Donc oui, je vais parler d’une techno dépréciée depuis plus d’un an et dont le remplaçant qui est censé magiquement régler tous les problèmes est apparu en 2019.



Pour autant, ce n’est pas parce que cet article va parler de Helm 2, de ses bugs que j’ai rencontrés et de comment on se sort de chaque situation pourrie. Le plus simple étant de passer à Helm 3, même sil est pété lui aussi (on en reparlera sûrement).



## Déployer avec Helm2, quel enfer !



Mais revenons à Helm 2. En 2018/2019, je déploie en production des applications dans un Kubernetes managé qu’on manage nous-même (trop long à expliquer ;-p).



On avait la « flemme » de migrer de Helm 2 à Helm 3 et franchement on a vraiment eu tort. Je vais vous faire une petite histoire vraie de ce qui s’est passé lorsque j’ai essayé de redéployer un prometheus.



## La genèse



Pour une raison qui m’échappe (car le brouillon est beaucoup trop vieux), j’ai commencé par supprimer la release helm plutôt que d’_upgrade_ mon déploiement (la release devait être dans un état foireux, et [comme Helm 2 ne supporte pas le 3-way merge...](https://helm.sh/docs/faq/#improved-upgrade-strategy-3-way-strategic-merge-patches)).



Je supprime donc ma release.



```
zwindler$ helm delete prometheus
release "prometheus" deleted
```




Je ne peux donc plus « upgrade » ma release puisqu’elle n’existe plus.



```
zwindler$ helm upgrade prometheus stable/prometheus
Error: UPGRADE FAILED: "prometheus" has no deployed releases
```




## So far, so good



J’essaye donc de la réinstaller



```
zwindler$ helm install prometheus stable/prometheus
Error: This command needs 1 argument: chart name
```




Ah ! Et oui, la commande est différente selon qu’on _upgrade_ ou qu’on _install_ une release. Pratique.



Vous allez me dire « bah, pourquoi tu ne fais pas un _upgrade --install_, comme ça la commande est la même que tu upgrade ou que tu installes ?



Tout simplement car cette commande ne marchait PLUS pendant longtemps (genre 2 ans), comme le témoigne cette issue sur Github et ce tweet rageur d’un certain zwindler

![](/2021/tweet_helm.png)


Enfin bon...



```
zwindler$ helm install --name prometheus stable/prometheus
Error: a release named prometheus already exists.
```




Là, par contre, on est d’accord que Helm se fiche vraiment de moi ?



Donc, dans ce genre de souci, vous pouvez sortir l’artillerie lourde avec le « --purge », qui fini par devenir la norme (en gros, je le mettais à chaque fois).



```
zwindler$ helm delete prometheus --purge
release "prometheus" deleted
```




Et là on peut réinstaller sa release...



```
zwindler$ helm install --name prometheus stable/prometheus -f prom-values-with-thanos.yaml
NAME:   prometheus
LAST DEPLOYED: Thu Oct 10 15:12:39 2019
NAMESPACE: monitoring
STATUS: DEPLOYED
```




Bon... et la prochaine fois que vous voudrez mettre à jour les valeurs de votre déploiement, n’oubliez pas de refaire des « upgrade » et pas « install », sinon il va vous conseiller de la delete ;)



```
zwindler$ helm install --name prometheus stable/prometheus -f prom-values-with-thanos.yaml
Error: a release named prometheus already exists.
Run: helm ls --all prometheus; to check the status of the release
Or run: helm del --purge prometheus; to delete it
```




![](/2021/04/Rage.jpg)

## Et c’est pas fini !



Dans les bugs rigolos de Helm 2, on a aussi le flag DEBUG, souvent utilisé dans les Charts pour activer le mode debug du logiciel que vous essayez de déployer, qui est AUSSI utilisé par Helm pour passer en debug et qui vous crache du caca dans votre CI.



```
Client: &amp;version.Version{SemVer:"v2.4.1", GitCommit:"46d9ea82e2c925186e1fc620a8320ce1314cbb02", GitTreeState:"clean"}
2017/05/06 16:11:47 (0xc42088e210) (0xc4204be000) Create stream
2017/05/06 16:11:47 (0xc42088e210) (0xc4204be000) Stream added, broadcasting: 1
2017/05/06 16:11:47 (0xc42088e210) Reply frame received for 1
2017/05/06 16:11:47 (0xc4204be000) (1) Writing data frame
2017/05/06 16:11:47 (0xc42088e210) (0xc4204be140) Create stream
2017/05/06 16:11:47 (0xc42088e210) (0xc4204be140) Stream added, broadcasting: 3
...
```




* [github.com/helm/helm/issues/2401](https://github.com/helm/helm/issues/2401)



> Ah oui tient, c’est marrant ça, on devrait peut être changer DEBUG en HELM_DEBUG ?No shit, sherlock

Ou bien les ConfigMap trop grandes (lol) qui font planter tiller



```
[storage] 2020/01/14 15:00:16 getting release history for "airflow"
[storage/driver] 2020/01/14 15:00:16 create: failed to create: ConfigMap "airflow.v1" is invalid: []: Too long: must have at most 1048576 characters
[tiller] 2020/01/14 15:00:16 warning: Failed to record release airflow: ConfigMap "airflow.v1" is invalid: []: Too long: must have at most 1048576 characters
[kube] 2020/01/14 15:00:16 building resources from manifest
[kube] 2020/01/14 15:00:16 creating 21 resource(s)
[kube] 2020/01/14 15:00:18 beginning wait for 21 resources with timeout of 5m0s
[kube] 2020/01/14 15:00:20 Pod is not ready: airflow/airflow-worker-0
[kube] 2020/01/14 15:00:38 Pod is not ready: airflow/airflow-worker-0
[kube] 2020/01/14 15:00:40 Pod is not ready: airflow/airflow-worker-1
[kube] 2020/01/14 15:00:42 Pod is not ready: airflow/airflow-worker-1
[kube] 2020/01/14 15:00:44 Pod is not ready: airflow/airflow-worker-1
[kube] 2020/01/14 15:00:46 Pod is not ready: airflow/airflow-worker-1
[tiller] 2020/01/14 15:01:40 executing 0 post-install hooks for airflow
[tiller] 2020/01/14 15:01:40 hooks complete for post-install airflow
[storage] 2020/01/14 15:01:40 updating release "airflow.v1"
[storage/driver] 2020/01/14 15:01:40 update: failed to update: configmaps "airflow.v1" not found
[tiller] 2020/01/14 15:01:40 warning: Failed to update release airflow: configmaps "airflow.v1" not found
```

* [github.com/helm/helm/issues/1413](https://github.com/helm/helm/issues/1413)



Ou enfin, les timeouts de tiller quand vous avez trop déployé (lol) et que du coup les commandes « helm list » timeout... ce qui nous avait obligé à installer un tiller par namespace et modifier notre CI pour gérer tout ce bazar.



Non, vraiment, Helm 2 est vraiment un chouette logiciel !
