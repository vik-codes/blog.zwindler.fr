---
title: kubectl tips and tricks 3
authors:
  - zwindler
type: post
date: 2020-06-22T06:35:00+00:00
excerpt: Ensemble de tips and tricks rarement mis en avant pour améliorer votre productivité sur Kubernetes avec kubectl
url: /2020/06/22/kubectl-tips-and-tricks-3/
image: /2019/10/kubectl2.png
categories:
  - Cluster
tags:
  - explain
  - kubectl
  - tips
  - top
  - tricks

---

## Déjà le numéro 3 pour les _kubectl tips and tricks_ !
  
  
Vous le savez peut être car j’en parle abondamment, mais j’utilise Kubernetes quotidiennement, en particulier kubectl` ! Certes il y a des UI sympas pour améliorer l’expérience utilisateur de la ligne de commande avec Kubernetes, mais j’aime bien savoir exactement ce que je fais et souvent je préfère reste au plus proche de l’outil (c’est personnel). Je collecte donc de petites astuces qu’on ne trouve pas toujours quand on débute dans kube, que je vous partage ici.

Note: numéro 3 signifie bien entendu un n°1 et un n°2, que vous pourrez retrouver ici :

* [kubectl tips and tricks n°1](/2019/10/30/kubectl-tips-tricks-1/)
* [kubectl tips and tricks n°2](/2020/01/20/kubectl-tips-and-tricks-n2/)

Et aussi dans la même veine :
  
* [kubectx et kubens](/2018/08/28/utiliser-kubectx-kubens-pour-changer-facilement-de-context-et-de-namespace-dans-kubernetes/)
* [Supprimer un namespace bloqué à Terminating](/2020/03/23/supprimer-un-namespace-bloque-a-terminating/)

## Qu’est ce qui bouffe mes ressources !
  
  
Un inconditionnel lorsqu’on héberge des applications (et encore plus quand elles cohabitent) est savoir laquelle bouffe toutes les ressources et bloque les autres (ça marche aussi dans la vraie vie, en coloc) !

L’idéal est bien entendu de pouvoir compter sur une supervision complète (allez voir cet article sur [Prometheus et Grafana](/2020/04/13/decouvrir-prometheus-et-grafana-par-lexemple/) si vous voulez en savoir plus), mais des fois, pour aller vite (ou si votre cluster est vraiment par terre et que Prom répond plus, avoir des outils intégrés permet de gagner du temps dans l’analyse du problème.

Heureusement pour nous, kubectl` intègre une commande "top", qui, comme sa commande homonyme sous Linux, va nous permettre d’afficher les consommations de CPU et de RAM des objets dans notre cluster.

Il existe deux modes pour ce "top". Le premier permet de lister la consommation des nodes :


```
kubectl top node 
NAME                                                                         CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
zwindlerzzzz01-11111111-vmss000000     118m             3%        1274Mi                   10%       
zwindlerzzzz01-11111111-vmss000001     119m             3%        1777Mi                   14%       
zwindlerzzzz01-11111111-vmss000002     320m             8%        2611Mi                   20%       
zwindlermntr01-11111111-vmss000000     113m            2%        1653Mi                   6%        
zwindlerzone01-11111111-vmss000000     200m            5%        1559Mi                   12%       
zwindlerzone01-11111111-vmss000001     215m            5%        1510Mi                   11%     
```

On a à la fois les infos en terme de CPU (en cores ou millicores et en pourcentage total) ainsi que la consommation RAM (en Mio et en %age total de ce qu’il y a sur la machine).

Le second permet de lister les pods.

Un point d’attention cependant : contrairement aux nodes, qui sont des objets visibles dans tous les namespaces Kubernetes, les pods sont liés à un namespace particulier. Il sera donc nécessaire de spécifier le namespace qui vous intéresse ou alors d’ajouter un `--all-namespaces`.


```
kubectl top pod --all-namespaces
NAMESPACE     NAME                                      CPU(cores)    MEMORY(bytes)
default                 appli1-aaaaa                        1m                   36Mi
default                 appli2-aaaaa                        1m                   36Mi
default                 appli3-aaaaa                        1m                   36Mi
ingress                traefik-v2-aaaaa-aaaaa    3m                   17Mi
```



[Edit] Suite à une remarque de Thibault Le Reste, je me suis rappelé de 2 options dont je n’avais pas parlé initialement dans l’article `--sort-by=cpu` et `--sort-by=memory`.

A y repenser, je me suis souvenu pourquoi je n’en ai par parlé... c’est parce que cette option ne marchait pas quand j’ai écris l’article ;-)

En fait il y a un bug, fixé dans la version 1.18 de `kubectl` ([issue Github 81270](https://github.com/kubernetes/kubernetes/issues/81270)), donc si vous êtes à jour, vous pouvez utiliser ces deux options !

## Logs

Un autre must dans l’hébergement d’applications, c’est comprendre pourquoi une application plante. Et il peut y avoir tellement de causes (pas seulement liées à Kubernetes) qu’il est important de garder une vision complète de toutes les sources de debugging à votre portée.

D’abord, l’application est peut être juste mal configurée. On pourrait simplement se connecter dessus mais il y a fort à craindre que le pod se kill tout seul le temps que vous tentiez de vous connecter.

Heureusement pour nous, la plupart des images sont pensées de telle sorte que les logs importants sont envoyés sur la sortie standard, sortie que nous pouvons récupérer avec la commande "logs", que vous connaissez sûrement.


```
kubectl --namespace=monitoring logs thanos-query-7bc9986f59-c7njv 
level=info ts=2020-05-06T15:23:35.600327763Z caller=main.go:168 msg="Tracing will be disabled"
level=info ts=2020-05-06T15:23:35.656544832Z caller=main.go:288 component=query msg="disabled TLS, key and cert must be set to enable"
level=info ts=2020-05-06T15:23:35.656572032Z caller=query.go:460 msg="starting query node"
level=info ts=2020-05-06T15:23:35.956571601Z caller=query.go:430 msg="Listening for query and metrics" address=0.0.0.0:10902
```

Cependant, ce que vous ignorez peut être c’est qu’il existe plusieurs flags très utiles qui permettent de reproduire les fonctions indispensable de tout admin linux qui lit des logs.

Par exemple, on peut faire l’équivalent d’un "tail -500" pour lister les 500 dernières lignes de log uniquement (très pratique si vous en avez des tartines) en ajoutant simplement le flag `--tail=500`.

On peut aussi faire l’équivalent du "tail -f" (suivre les lignes qui vont apparaître a posteriori en temps réel) avec le flag `-f` (tout simplement)

```
kubectl --namespace=monitoring logs thanos-query-7bc9986f59-c7njv --tail=1 -f
level=info ts=2020-05-06T15:26:18.048901191Z caller=storeset.go:266 component=storeset msg="adding new store to query storeset" address=prom-thanos-sidecar-zwindlerk8s.monitoring.svc.cluster.local:10901
[et là le prompt attend jusqu'à ce qu'une nouvelle ligne apparaisse ou que vous Ctrl-C]
```

Dans le cas d’un plantage en boucle, il arrive qu’on ait pas eu le temps de voir la trace du conteneur précédent avant que Kube en lance un nouveau. Vous pouvez accéder aux logs du conteneur précédent avec le `-p` !


```
kubectl logs pod-qui-crashe-en-boucle -p
Content root path: /app
Now listening on: http://[::]:80
Application started. Press Ctrl+C to shut down.
Application is shutting down...
```

Dans le cas où vous avez besoin de voir rapidement la date a laquelle a été écrite une ligne de log et que vous n’avez pas l’information dans le log lui même, sachez qu’il existe un `--timestamps`.
Lorsque vous ajoutez ce flag, il va _preppend_ un timestamp devant chaque ligne.

```
kubectl --context=k8s11-euw-dev --namespace=cutting-room logs scanner-parameters-7bfd6b656d-cl2gl --timestamps
2020-06-23T08:00:08.578320749Z {"logType":"Debug","timestamp":"2020-06-23T08:00:08.575Z","level":"Info",[...]
```

Le mieux étant bien sûr d’externaliser toutes les lignes de log dans un système centralisé comme fluentd ou splunk pour faciliter les recherches, bien entendu...

Et enfin, un dernier flag très très cool : vous avez la possibilité de n’afficher que les messages les plus récents, mais sur un temps donné plutôt que sur un nombre de ligne de log. `--since=5m` vous affichera les logs des 5 dernières minutes uniquement !

## Events

Je pense qu’on a fait le tour pour ce qui était des logs applicatif avec kubectl. Cependant, il existe une autre catégorie de logs dans Kubernetes : les Events. Les Events, c’est un peu les logs interne de l’API server. Ca va vous donner tout un tas d’informations sur ce qui se passe sur vos objets. Un Pod est créé, un Pod meurt car il répond pas à la Liveness Probe, une Image est pull... la tuyauterie technique de kube en somme.

Les Events sont des objets Kubernetes à part entière, comme les Pods, les Nodes, etc. Ils sont liés à un namespace et on les liste avec un `kubectl get events`, on peut obtenir les informations complètes d’un Event avec un `kubectl describe events`, etc.


```
kubectl --namespace=kube-system get events
LAST SEEN   TYPE      REASON      OBJECT                             MESSAGE
40s         Warning   Unhealthy   pod/omsagent-rs-758cbf9987-fb5zf   Liveness probe failed:
30m         Normal    Killing     pod/omsagent-rs-758cbf9987-fb5zf   Container omsagent failed liveness probe, will be restarted
10m         Warning   BackOff     pod/omsagent-rs-758cbf9987-fb5zf   Back-off restarting failed container
9s          Warning   Unhealthy   pod/omsagent-v7w8w                 Liveness probe failed:
25m         Normal    Killing     pod/omsagent-v7w8w                 Container omsagent failed liveness probe, will be restarted
5m45s       Warning   BackOff     pod/omsagent-v7w8w                 Back-off restarting failed container
```



Mais... vous voyez pas un truc chelou ?

C’est trié N’IMPORTE COMMENT !!!


![](/2020/05/rage.gif)


Le mieux dans cette histoire, c’est que c’est "by design". Donc vous allez devoir garder cette astuce là sous le coude car je l’utilise à peu près tout le temps.

Pour modifier le comportement par défaut de kubectl get events pour que les événements soient triés par date de dernière occurrence (c’est souvent ce qu’on veut), retenez donc que vous allez devoir ajouter à chaque fois `--sort-by='{.lastTimestamp}'`


```
kubectl get events --sort-by='{.lastTimestamp}' 
LAST SEEN   TYPE      REASON      OBJECT                             MESSAGE
36m         Normal    Killing     pod/omsagent-rs-758cbf9987-fb5zf   Container omsagent failed liveness probe, will be restarted
16m         Warning   BackOff     pod/omsagent-rs-758cbf9987-fb5zf   Back-off restarting failed container
11m         Warning   BackOff     pod/omsagent-v7w8w                 Back-off restarting failed container
6m27s       Warning   Unhealthy   pod/omsagent-rs-758cbf9987-fb5zf   Liveness probe failed:
5m56s       Warning   Unhealthy   pod/omsagent-v7w8w                 Liveness probe failed:
85s         Normal    Pulled      pod/omsagent-rs-758cbf9987-fb5zf   Container image "mcr.microsoft.com/azuremonitor/containerinsights/ciprod:ciprod03022020" already present on machine
56s         Normal    Killing     pod/omsagent-v7w8w                 Container omsagent failed liveness probe, will be restarted
```

## Conclusion

Voilà, j’arrête ici car j’en ai plein d’autres mais ça commence à faire beaucoup. La prochaine fois je parlerai très certainement de la façon dont vous allez pouvoir customiser les colonnes que vous voulez voir afficher, ainsi que des filtres.

Mais en attendant, amusez vous bien avec ça ;-)
