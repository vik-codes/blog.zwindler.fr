---
title: 'Recompile Mimir’s "MetaMonitoring" Grafana Dashboards for Kubernetes'
authors:
  - zwindler
type: post
date: 2024-12-12T18:00:00+02:00
excerpt: In this article I’ll why you may need to recompile official grafana dashboards for mimir and explain the steps to do so
url: /2024/12/12/recompile-mimir-distributed-grafana-dashboards/
image: /2020/01/20200102_084825-2.jpg
categories:
  - grafana
  - Système
tags:
  - Grafana
  - Kubernetes
  - API
  - Job
  - CronJob

---

Note : une fois de temps en temps, j'écris un article en anglais. Parfois c'est pour le fun, ici c'est parce que le sujet est très (très) niche et je veux qu'il touche potentiellement un peu plus de gens. Désolé pour les non-anglophones ;-)

## Context

When working on observability, there is a tool that always comes in mind first : Grafana.

[Grafana](https://grafana.com/) is an open source visualization tool developed by Grafana Labs, and I'm sure you all know it (and I also [wrote about it in French quite a few times](https://blog.zwindler.fr/recherche/?keyword=grafana)). But aside from this, they also develop a lot of other useful tools in the observability landscape, to the point that you can in theory build you whole o11y stack with only Grafana Labs Tools.

To answer Prometheus lack of long term storage and lack of high availability features (I have NEVER understood why the Prometheus team refuse working on this), Grafana Labs forked Cortex a few years back and renamed it Mimir.

I won't cover the installation of Mimir here, there are plenty of tutorial on the Internet and an official documentation for this. 

Instead, I'll talk about an issue that I have with the official Mimir helm chart, and more precisely with the built-in Grafana dashboards that come along with it.

## Dashboards, you say?

Mimir is shipped with a lot of useful Grafana dashboards to help ensure that the components are running fine. 

![](/2024/12/mimir-dashboard.png)

These dashboards are compatible with the various deployment modes of Mimir. In Kubernetes, if you use the [mimir-distributed official helm chart](https://github.com/grafana/mimir/blob/main/operations/helm/charts/mimir-distributed/values.yaml) this can be enabled by a simple value:

```yaml
metaMonitoring:
    dashboards:
        enabled: true
```

**But**, by default, all dashboards installed using the `metaMonitoring` value in the mimir helm charts are precompiled JSON manifests using **jsonnet/mixin**.

For example, here is the precompiled version of the "Mimir / Overview dashboard":

* [github.com/grafana/mimir/blob/2640b8f72127548e9e3da281a763476b03fb4aae/operations/mimir-mixin-compiled/dashboards/mimir-overview.json](https://github.com/grafana/mimir/blob/2640b8f72127548e9e3da281a763476b03fb4aae/operations/mimir-mixin-compiled/dashboards/mimir-overview.json)

By design, **you can't change things like the prefix name of the mimir pods**, which makes these precompiled dashboards useless in a helm-like environment where release name (mimir-) is a prefix of the pod. 

```bash
kubectl -n monitoring get pods
NAME                                                      READY   STATUS    RESTARTS      AGE
mimir-alertmanager-0                                      1/1     Running   0             24h
mimir-alertmanager-1                                      1/1     Running   0             24h
mimir-compactor-0                                         1/1     Running   0             24h
mimir-distributor-5d668b479f-ksltr                        1/1     Running   1 (24h ago)   6d1h
...
```

In this case, all dashboards will be broken, all showing "no data" in Grafana because data will be incorrectly filtered. For example, the "Write requests / sec" panel in "Mimir / Overview dashboard", has a label `job=~"($namespace)/((distributor...`, but our pod is `mimir-distributor`, not `distributor`:

```
sum by (status) (
  label_replace(label_replace(rate(cortex_request_duration_seconds_count{cluster=~"$cluster", job=~"($namespace)/((distributor.*|cortex|mimir|mimir-write.*))", route=~"/distributor.Distributor/Push|/httpgrpc.*|api_(v1|prom)_push|otlp_v1_metrics"}[$__rate_interval]),
  "status", "${1}xx", "status_code", "([0-9]).."),
  "status", "${1}", "status_code", "([a-zA-Z]+)"))
```

The solution is to **disable the metaMonitoring flag** from the chart, and build / ship the dashboards separately. 

## Procedure

Get the Mimir sources:

```bash
git clone https://github.com/grafana/mimir.git
```

Hopefully, the jsonnet/mixin files include a `job_prefix` variable that will help us fix this:

```bash
sed -i.bak "s/job_prefix: '(\$namespace)\/',/job_prefix: '(\$namespace)\/mimir-',/" operations/mimir-mixin/config.libsonnet 
```

Rebuild the dashboards

```bash
make build-mixin

podman image inspect grafana/mimir-build-image:pr9491-80f5778956 >/dev/null 2>&1 || podman pull grafana/mimir-build-image:pr9491-80f5778956
podman tag grafana/mimir-build-image:pr9491-80f5778956 grafana/mimir-build-image:latest
[...]
make: Leaving directory '/go/src/github.com/grafana/mimir'
       10,10 real         0,02 user         0,01 sys
```

Note: If you don't have `docker` on your machine (I use podman), the `make` command will fail because it can't find docker and the `docker` binary is hardcoded in the make commands. Modify the Makefile to replace `docker` by `podman`.

The json files in operations/mimir-mixin-compiled/dashboards are now built with the correct pod names.

Create a grafana-dashboards helm chart (called **yourDashboardsChart** here). 

```bash
helm create yourDashboardsChart
```

In this chart, create a `src/dashboards/mimir` directory (for json dashboard sources) alongside the classic `templates` directory containing the actual go-templated YAML manifests. We will create the gotemplate helm files just after:

```bash
cp operations/mimir-mixin-compiled/dashboards/* ../yourDashboardsChart/src/dashboards/mimir 
```

Now, for each json file generated by jsonnet, we are going to create a helm gotemplated yaml file, which in turn will create a ConfigMap for each dashboard in our Kubernetes cluster. They will look like this:

```yaml
---
# Source: mimir-distributed/templates/metamonitoring/grafana-dashboards.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mimir-alertmanager-dashboard
  namespace: '{{ $.Release.Namespace }}'
  labels:
    grafana_dashboard: "1"
  annotations:
    k8s-sidecar-target-directory: /tmp/dashboards/Mimir Dashboards
data:
  mimir-alertmanager.json: |-
    {{ $.Files.Get "src/dashboards/mimir/mimir-alertmanager.json" | fromJson | toJson }}
```

To speed up the process, you can reuse the `helm template` and a few bash commands to generate all the helm gotemplate files for you:

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

mkdir -p mimir

helm -n monitoring template mimir grafana/mimir-distributed --set metaMonitoring.dashboards.enabled=true > helm-output.yaml

# Count the number of document separators
doc_count=$(grep -c '^---$' helm-output.yaml)

# Split the YAML file into separate files for each document
csplit -f mimir/helm-output- helm-output.yaml '/---/' "{$((doc_count - 2))}" >/dev/null

# Some triming/cleaning
for file in mimir/helm-output-*; do
  if grep -q 'kind: ConfigMap' "$file" && grep -q 'dashboard' "$file"; then
    name=$(yq eval '.metadata.name' "$file")
    yq eval -i 'del(.metadata.labels."helm.sh/chart", .metadata.labels."app.kubernetes.io/name", .metadata.labels."app.kubernetes.io/instance", .metadata.labels."app.kubernetes.io/version", .metadata.labels."app.kubernetes.io/managed-by")' "$file"
    yq eval -i '.metadata.namespace = "{{ $.Release.Namespace }}"' "$file"
    yq eval -i '.data |= with_entries(.value = "{{ $.Files.Get \"src/dashboards/mimir/" + .key + "\" | fromJson | toJson }}")' "$file"
    mv "$file" "mimir/${name}.yaml"
  else
    rm "$file"
  fi
done

mv mimir/* ../yourDashboardsChart/templates/mimir
```

Now, you should have all the files to re-generate the grafana dashboard in your Kubernetes cluster, with the correct prefix.

Enjoy!

## Source

* https://grafana.com/docs/mimir/latest/manage/monitor-grafana-mimir/requirements/
* https://grafana.com/docs/mimir/latest/manage/monitor-grafana-mimir/installing-dashboards-and-alerts/
