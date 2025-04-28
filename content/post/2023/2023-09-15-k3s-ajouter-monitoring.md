---
title: Ajoutons du monitoring à notre cluster k3s
authors:
  - zwindler
type: post
date: 2023-09-15T06:00:00+02:00
url: /2023/09/15/k3s-ajouter-monitoring
image: /2023/09/k3s_cilium.png
categories:
  - Cluster
  - Monitoring
tags:
  - k3s
  - tracing
  - tempo
  - loki
  - grafana

---

## Contexte

Je pars de l'article précédent ([k3s et cilium rapide et facile](/2023/09/01/k3s-et-cilium-rapide-et-facile)) comme base pour installer ma stack k3s + cilium (CNI + ingressController).

L'idée ici, ça va être de préparer le monitoring pour le cluster, en vue d'y ajouter une (des) application(s).

## Prometheus & friends

Pour la partie Prometheus, j'ai choisi d'utiliser la chart du projet **prometheus-community**, qui s'appuie elle-même sur plusieurs charts, dont grafana ainsi que le Prometheus Operator.

[prometheus-operator.dev/](https://prometheus-operator.dev/)

Cette chart est "énorme".

Elle propose une quantité folle d'options, notamment en termes de divers setups de déploiement, avec ou sans Thanos par exemple. On peut même créer des "sharded Prometheus", au cas où la charge devient ingérable par rapport à la taille de vos nodes.

Note: Ce n'est clairement pas la manière la plus simple de rentrer dans Prometheus, si vous débutez (j'ai écrit plusieurs articles là-dessus dans le passé, [ici](/2020/04/13/decouvrir-prometheus-et-grafana-par-lexemple/) et [là](/2019/11/12/tutoriel-installer-prometheus-grafana-sans-docker/)) 

L'operator ajoute tout un tas de CRDs qui vont nous permettre de gérer la configuration (au sens très large, aussi bien les aspects techniques que pure configuration) de notre instance de Prometheus "comme du code".

Le truc cool, c'est qu'on va pouvoir définir ce qu'on veut surveiller sur notre kubernetes sans avoir à aller éditer une *ConfigMap*. On peut ainsi donner le pouvoir aux devs de surveiller ce qu'ils veulent sans à aller toucher au namespace de monitoring.

Le truc un peu dommage par contre, c'est que par défaut, la chart est livrée avec des *Selectors* beaucoup trop restrictifs. Elle ne surveille que Prometheus lui même (release kube-prometheus)... On va enlever les restrictions (ex. `serviceMonitorSelector.matchLabels: {}`).

On va donc modifier les valeurs par défaut, et aussi ajouter un *Ingress* pour pouvoir accéder à grafana plus facilement depuis Internet :

```
cat > prometheus-values.yaml << EOF
nameOverride: prom
prometheusOperator:
  enabled: true
  admissionWebhooks:
    enabled: true

prometheus:
  enabled: true
  prometheusSpec:
    enableAdminAPI: true
    probeSelector: 
      matchLabels: {}
    podMonitorSelector:
      matchLabels: {}
    serviceMonitorSelector:
      matchLabels: {}
    ruleSelector:
      matchLabels: {}

grafana:
  ingress:
    enabled: true
    ingressClassName: cilium
    hosts:
      - grafana.example.org

cleanPrometheusOperatorObjectNames: true
EOF
```

On installe donc prometheus  via `helm` une fois qu'on a le fichier de values :

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
prometheus-community/prometheus
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack --namespace prometheus --create-namespace -f prometheus-values.yaml
```

On vérifie le contenu de la CRD "Prometheus" que la chart à installer ne contient pas/plus les *matchLabels.release* :

```bash
$ kubectl -n prometheus get Prometheus -o yaml
[...]
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector:
    matchLabels: {}
```

On se connecte ensuite à Grafana (accessible à l'URL http://grafana.example.org) pour vérifier que tout est fonctionnel. Ce qui est cool, c'est que les datasources vers prometheus et l'alertmanager sont déjà préconfigurées pour nous. Un truc de moins à faire !

![](/2023/09/datasources.png)

Note: le login/mdp est admin/prom-operator (vous auriez pu le trouver vous-même dans le Secret prometheus/kube-prometheus-grafana)

## ServiceMonitor

Une fois que c'est fait, on a notre plateforme de monitoring des métriques opérationnelle. Pour pouvoir surveiller notre *IngressController*, il va donc falloir activer le "ServiceMonitor".

Problème, on l'a pas déployé l'option lorsqu'on a installé cilium dans le tuto précédent (en vrai, c'était volontaire, car il faut déployer la CRD ServiceMonitor AVANT de les activer dans cilium sinon l'install échoue).

Je fais donc un upgrade de la release helm, avec beaucoup plus d'options (d'où le besoin de faire un fichier de values) :

```bash
cat > cilium-values.yaml << EOF
operator:
  prometheus:
    enabled: true
    serviceMonitor:
      enabled: true
hubble:
  relay:
    enabled: true
    prometheus:
      enabled: true
      serviceMonitor:
        enabled: true

  metrics:
    serviceMonitor:
      enabled: true
    enableOpenMetrics: true
    enabled:
      - dns
      - drop
      - tcp
      - icmp
      - "flow:sourceContext=workload-name|reserved-identity;destinationContext=workload-name|reserved-identity"
      - "kafka:labelsContext=source_namespace,source_workload,destination_namespace,destination_workload,traffic_direction;sourceContext=workload-name|reserved-identity;destinationContext=workload-name|reserved-identity"
      - "httpV2:exemplars=true;labelsContext=source_ip,source_namespace,source_workload,destination_ip,destination_namespace,destination_workload,traffic_direction;sourceContext=workload-name|reserved-identity;destinationContext=workload-name|reserved-identity"

prometheus:
  enabled: true
  serviceMonitor:
    enabled: true
EOF

CILIUM_VERSION="1.14.2"
helm upgrade --install cilium cilium/cilium --version=${CILIUM_VERSION} \
    --set global.tag="v${CILIUM_VERSION}" --set global.containerRuntime.integration="containerd" \
    --set global.containerRuntime.socketPath="/var/run/k3s/containerd/containerd.sock" \
    --set global.kubeProxyReplacement="strict" \
    --set global.bpf.masquerade="true" \
    --set ingressController.enabled=true \
    --set ingressController.default=true \
    -f cilium-values.yaml \
    --namespace cilium \
    --create-namespace
```

On peut se connecter sur Prometheus directement via un "port-forward" pour vérifier que cilium est bien dans nos "targets"

```bash
$ kubectl -n prometheus port-forward service/kube-prometheus-prometheus 9090       
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```

Dans Grafana, on peut également commencer à ajouter des dashboards pour voir si notre cilium va bien. Typiquement, Isovalent propose ces deux dashboards :
* [Grafana - cilium metrics 1.12](https://grafana.com/grafana/dashboards/16611-cilium-metrics/)
* [Grafana - hubble metrics 1.12](https://grafana.com/grafana/dashboards/16613-hubble/)

## Loki + promtail

Les métriques, c'est bien. Mais tant qu'à y être, j'aimerais aussi pouvoir lire les logs de mon cluster. Les fans d'observabilité et/ou de Grafana me voient venir avec mes gros sabots, je vais ajouter Loki au cluster, via la chart officielle :

```bash
helm repo add grafana https://grafana.github.io/helm-charts

cat > loki-values.yaml << EOF
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
singleBinary:
  replicas: 1
EOF

helm install loki --namespace loki grafana/loki --create-namespace -f loki-values.yaml
```

Par rapport aux valeurs par défaut, je vais brider loki en ne lui affectant qu'un seul replica. J'ai aussi retiré l'authentification. Ne faites évidemment pas ça en prod 😬.

On a de la chance, Loki a déjà sa définition *ServiceMonitor* par défaut :

```bash
$ kubectl -n loki get serviceMonitor loki -o yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  annotations:
    meta.helm.sh/release-name: loki
    meta.helm.sh/release-namespace: loki
[...]
```

Loki en lui-même ne va pas faire grand-chose d'intéressant. Pour récupérer les logs de nos pods, il va nous falloir ajouter l'agent "promtail", qui va faire l'auto-découverte et la collecte des logs de nos pods.

```bash
$ helm upgrade --install promtail grafana/promtail -n loki
```

On se connecte à Grafana, on ajoute la source de données pour Loki, puis on vérifie que tout fonctionne correctement avec la fonctionnalité "Explore" dans Grafana.

![](/2023/09/datasource_loki.png)

![](/2023/09/explore_loki.png)

## Et si on ajoutait des traces ???

Comme je l'ai dit plus haut, normalement, vous m'avez vu arriver. Il existe 3 piliers dans l'observabilité : les métriques, les logs, et les traces.

Les métriques et les logs, ça parle à tout le monde. Les traces, moins.

Pour faire très (trop?) simple : les traces, c'est une méthode d'observabilité permettant d'obtenir des informations de performances sur le parcours d'une requête de son entrée dans notre SI jusqu'au retour. Les informations remontées par les traces permettent ainsi de remonter la pelote entre (micro)services mais aussi obtenir des informations DANS les services eux-même. 

Note: c'est pour ça qu'on parle de "distributed tracing", cette technique est particulièrement efficace pour debugger des problématiques complexes de performance au sein d'architectures microservices.

Je vous incite à aller lire l'article de Mathieu Corbin : [Tracing avec Opentelemetry: pourquoi c'est le futur (et pourquoi ça remplacera les logs)](https://www.mcorbin.fr/posts/2023-08-20-traces/) pour mieux comprendre de quoi il s'agit.

## Tempo

Je n'ai pas choisi les outils de Grafana Labs par hasard. Il se trouve que Grafana Labs fourni la stack complète pour disposer d'une plateforme d'observabilité complète (j'aurai même pu remplacer Prometheus/Thanos par Grafana agent + Mimir).

Pour la partie tracing, je vais donc commencer par installer [Grafana Tempo](https://grafana.com/docs/tempo/latest/), comme datasource de tracing pour Grafana. Il existe plusieurs manières d'installer Tempo sur Kubernetes. Pour faire simple je vais déployer le composant dit "[monolithique](https://github.com/grafana/helm-charts/tree/main/charts/tempo)".

```bash
$ helm upgrade --install tempo grafana/tempo -n tempo --create-namespace
```

On ajoute ensuite la datasource dans Grafana comme pour Loki :

![](/2023/09/datasource_tempo.png)

Note: attention ici encore, les valeurs renseignées ne sont pas du tout des valeurs pour une production. Ici, j'ai juste ajouté Tempo, sans aucune haute disponibilité ni persistance (S3).

Maintenant que Tempo est installé, il faut qu'on indique à cilium d'envoyer des traces à Tempo. Pour ça, j'ai besoin d'ajouter opentelemetry, qui est le backend vers lequel les traces vont être envoyées (un peu comme pour loki et promtail).

```bash
helm repo add jetstack https://charts.jetstack.io
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.0 \
  --set installCRDs=true \
  --set admissionWebhooks.certManager.create=true

cat > opentelemetry-operator-values.yaml << EOF
manager:
  serviceMonitor:
    enabled: true
EOF

helm upgrade --install opentelemetry-operator open-telemetry/opentelemetry-operator \
  --namespace opentelemetry-operator --create-namespace \
  -f opentelemetry-operator-values.yaml

kubectl apply -n opentelemetry-operator -f manifests/otel-collector.yaml
```

Une fois l'OpenTelemetry operator déployé, on peut (comme pour Prometheus) gérer nos collecteurs comme du code. Je vais donc demander à Otel (le petit nom mignon d'OpenTelemetry) Operator de me créer un *DaemonSet* pointant sur Tempo :

```yaml
kubectl create ns opentelemetry

cat > opentelemetry-manifest.yaml << EOF
apiVersion: opentelemetry.io/v1alpha1
kind: OpenTelemetryCollector
metadata:
  name: otel
  namespace: opentelemetry
spec:
  mode: daemonset
  hostNetwork: true
  image: otel/opentelemetry-collector-contrib:0.60.0
  config: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    processors:
      memory_limiter:
        check_interval: 1s
        limit_percentage: 75
        spike_limit_percentage: 15
      batch:
        send_batch_size: 10000
        timeout: 10s

    exporters:
      logging:
        loglevel: info
      otlp:
        endpoint: tempo.tempo.svc.cluster.local:4317
        tls:
          insecure: true

    service:
      pipelines:
        traces:
          receivers: [otlp]
          processors: []
          exporters:
            - logging
            - otlp
EOF

kubectl apply -f opentelemetry-manifest.yaml
```

Une fois créé, des pods OpenTelemetry devraient se créer :

```bash
kubectl -n opentelemetry get pods       
NAME                   READY   STATUS    RESTARTS   AGE
otel-collector-5wk9s   1/1     Running   0          16s
otel-collector-mv24p   1/1     Running   0          16s
```

Les données de performances qui seront remontées par les pods sur otel seront visibles dans la datasource de Grafana.

## Conclusion

La plateforme d'observabilité est opérationnelle. J'avais prévenu, c'est assez dense :\D.

Et pour l'instant elle ne sert pas à grand-chose, puisque rien n'est déployé sur mon cluster xD !

Cependant, vous l'avez deviné, ceci est pour un prochain article... En attendant, have fun ;-P.

## Sources complémentaires 

* [Isovalent - Cilium Grafana Observability Demo](https://github.com/isovalent/cilium-grafana-observability-demo)
* [OpenTelemetry - README](https://github.com/open-telemetry/opentelemetry-operator)
* [OpenTelemetry - chart values](https://github.com/open-telemetry/opentelemetry-helm-charts/blob/main/charts/opentelemetry-operator/values.yaml)
