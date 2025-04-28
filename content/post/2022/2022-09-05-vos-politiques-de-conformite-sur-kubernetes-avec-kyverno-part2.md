---
title: Vos politiques de conformité sur Kubernetes avec Kyverno - part 2
authors:
  - zwindler
type: post
date: 2022-09-05T06:00:00+02:00
excerpt: "Suite de mon tutoriel pour imposer des politiques de conformité et de sécurité sur vos déploiements Kubernetes à l'aide de Kyverno"
url: /2022/09/05/vos-politiques-de-conformite-sur-kubernetes-avec-kyverno-part2/
image: /2022/07/Kyverno_Horizontal.png
categories:
  - Système
  - Virtualisation
tags:
  - Docker
  - Kyverno
  - Kubernetes
  - politique
  - sécurité

---

## Récap' de la partie 1

Dans le [précédent article](https://blog.zwindler.fr/2022/08/01/vos-politiques-de-conformite-sur-kubernetes-avec-kyverno), j'ai introduit [Kyverno](https://kyverno.io/), un outil "cloud native" pour gérer des politiques de conformité sur Kubernetes.

Pour illustrer les capacités de l'outil, j'avais pris un exemple : empêcher deux Ingress d'utiliser la même URL d'entrée. J'avais fait le même exercice avec OPA dans un article précédent ([Open Policy Agent (OPA) et de son pendant dans Kubernetes, Gatekeeper](/2020/07/20/vos-politiques-de-conformite-sur-kubernetes-avec-opa-et-gatekeeper/)) et j'avais comparé à la fin les deux syntaxes (Kyverno vs rego).

![](/2022/07/rego_vs_kyverno.png)

J'ai une nette préférence pour la syntaxe de Kyverno, même si OPA est là depuis plus longtemps et n'est pas limité à Kubernetes (Kyverno c'est uniquement pour Kube).

## Aller un peu plus loin

Au-delà de mon exemple, j'ai indiqué que Kyverno mettait à disposition un très grand nombre de politiques déjà écrites pour vous (191 au moment où j'écris l'article).

[kyverno.io/policies](https://kyverno.io/policies/)

Par défaut, la plupart des politiques disponibles sont positionnées en mode "audit" dans un premier temps. N'oubliez pas de la passer en mode "enforce" quand vous serez assez mature sur votre cluster.

Évidemment, quand on débute on ne sait pas trop par quoi commencer. Le plus simple dans ce cas-là est de déployer la chart Helm `kyverno/kyverno-policies`, qui contient l'équivalent des Kyverno des "Pod Security Standards" (les PSP étant officiellement obsolètes depuis la 1.21 je crois, et plus utilisables en 1.25).

```bash
helm install kyverno-policies kyverno/kyverno-policies -n kyverno
[...]
Thank you for installing kyverno-policies v2.5.2 😀

We have installed the "baseline" profile of Pod Security Standards and set them in audit mode.

Visit https://kyverno.io/policies/ to find more sample policies.
```

Voilà ce que ça nous a déployé (la dernière étant déjà là à cause de l'article précédent)

```bash
kubectl get clusterpolicy
NAME                             BACKGROUND   ACTION    READY
disallow-capabilities            true         audit     true
disallow-host-namespaces         true         audit     true
disallow-host-path               true         audit     true
disallow-host-ports              true         audit     true
disallow-host-process            true         audit     true
disallow-privileged-containers   true         audit     true
disallow-proc-mount              true         audit     true
disallow-selinux                 true         audit     true
restrict-apparmor-profiles       true         audit     true
restrict-seccomp                 true         audit     true
restrict-sysctls                 true         audit     true
unique-ingress-host              false        enforce   true
```

Avec ça, on va déjà avoir pas mal de pain sur la planche pour éduquer nos utilisateurs (les développeurs) à produire des déploiements Kubernetes sécurisés.

## User experience

Un des points ennuyeux de ces deux outils, c'est que de base, ils ne sont pas très user friendly. Moi, faire une commande `kubectl get events` (voire `kubectl get events --field-selector=reason=PolicyViolation` dans le cas de Kyverno) pour savoir pourquoi un déploiement a échoué, ça ne m'ennuie pas trop (ça m'amuse, presque).

Mais pour certaines personnes, c'est un peu rebutant et je peux l'entendre. 

Mon but c'est de rendre l'infrastructure plus simple à des gens dont qui ce n'est pas le métier et imposer ma façon de travailler n'est pas forcément la meilleure méthode.

Souvent, pour aider à adopter un nouvel outil / usage, le plus simple c'est de lui fournir une interface graphique.

Et ça tombe bien, Kyverno dispose d'un outil pour faire ça.

## Kyverno policy reporter

En réalité, l'outil ne sert pas tout à fait à ça, à la base. Mais vous allez voir que c'est même encore mieux.

Historiquement, l'outil s'appelle policy reporter, car les développeurs avaient besoin d'un outil permettant d'exporter facilement et rapidement les *PolicyReports* dont je parle dans l'article précédent :

```console
kubectl describe policyreport polr-ns-default 
Name:         polr-ns-default
Namespace:    default
Labels:       managed-by=kyverno
Annotations:  <none>
API Version:  wgpolicyk8s.io/v1alpha2
Kind:         PolicyReport
[...]
Results:
  Category:  Sample
  Message:   The Ingress host name must be unique.
  Policy:    unique-ingress-host
  Resources:
    API Version:  networking.k8s.io/v1
    Kind:         Ingress
    Name:         ingress2
[...]
Summary:
  Error:  0
  Fail:   2
  Pass:   0
  Skip:   2
  Warn:   0
```

Le policy reporter a donc pour rôle d'exporter les PolicyReports vers plusieurs sources externes pour les traiter plus facilement :
* Grafana Loki
* Elasticsearch
* Slack
* Discord
* MS Teams
* Policy Reporter UI
* S3

Je vais vous en parler de 2 : **slack** et **Policy Reporter UI**

## Policy Reporter UI

Je commence par l'UI, car c'est le plus simple à configurer. Il suffit juste de déployer la Chart helm de Policy Reporter en oubliant pas de spécifier qu'on veut l'UI :

```bash
helm repo add policy-reporter https://kyverno.github.io/policy-reporter
helm repo update
helm install -n kyverno policy-reporter policy-reporter/policy-reporter --set kyvernoPlugin.enabled=true --set ui.enabled=true --set ui.plugins.kyverno=true
```

```bash
kubectl -n kyverno get pods
NAME                                              READY   STATUS    RESTARTS      AGE
kyverno-5f8bfd6fc5-xp6bm                          1/1     Running   1 (59m ago)   33d
policy-reporter-74cc9bf4b9-9ggwh                  1/1     Running   0             18s
policy-reporter-kyverno-plugin-6b48c4bc5f-5rwfb   1/1     Running   0             18s
policy-reporter-ui-5c9449d58-f9fwf                1/1     Running   0             18s
```

On peut évidemment ajouter un Ingress mais si on est fénéant comme moi dans cette démo un simple port-forward suffit 🙃.

```
kubectl port-forward service/policy-reporter-ui 8082:8080 -n kyverno
```

L'UI en elle-même est assez intuitive. On a notamment :
* un Dashboard avec un gros indicateur global pour savoir combien on a de violation de politiques
* une page avec nos "policy reports", dans lequel on peut filtrer par namespace ou par politique
* la liste de nos politiques
* ...

![](/2022/09/kyverno-policy-reporter-ui.png)

![](/2022/09/kyverno-policy-reporter-ui-2.png)

## Slack

On voit tout de suite l'intérêt d'alerter les administrateurs dans Slack (ou Teams 😭) si jamais une violation de la politique arrive.

On voit que la configuration est assez triviale, on a juste à ajouter un webhook dans Slack et un petit bout de configuration dans Kyverno

```yaml
kyvernoPlugin:
  enabled: true
ui:
  enabled: true
  plugins:
    kyverno: true
target:
  slack:
    webhook: "https://hooks.slack.com/services/T0xxxxxxxx"
    minimumPriority: "medium"
    skipExistingOnStartup: true
    sources:
    - kyverno
```

Et on re-applique tout ça à notre release helm

```bash
helm upgrade -n kyverno policy-reporter policy-reporter/policy-reporter -f kyverno-values.yaml
```

Note: Si vous ne savez pas comment faire, il faut être admin du workspace Slack, créer une application dans https://api.slack.com/apps, activer les `Incoming Webhooks` et en créer un en lui donnant les droits sur un channel.

![](/2022/09/slack-create-app.png)

![](/2022/09/slack-create-app-2.png)

![](/2022/09/slack-app-webhooks.png)

![](/2022/09/slack-app-webhooks-2.png)

## Et si on faisait une violation de politique, pour voir ?

Pour faire simple, je suis reparti de l'exemple de l'article précédent. Je repasse ma politique **unique-ingress-host** en mode **audit** et je recréé l'ingress problématique :

```bash
kubectl edit clusterpolicy unique-ingress-host
kubectl apply -f ingress2.yaml
```

Instantanément, j'ai bien 2 échecs qui apparaissent dans l'UI de Kyverno, ainsi que des messages dans Slack

![](/2022/09/kyverno-fail.png)
![](/2022/09/kyverno-slack.png)

Victoire :)

## Ressources complémentaires

* ["Catalogue" des Politiques officielles de Kyverno](https://kyverno.io/policies/)
* [Aurélie Vache - Understanding Kubernetes: part 44 – Tools - Kyverno ](https://dev.to/aurelievache/understanding-kubernetes-part-44-tools-kyverno-52mc)
