---
title: Vos politiques de conformité sur Kubernetes avec Kyverno
authors:
  - zwindler
type: post
date: 2022-08-01T06:00:00+00:00
excerpt: "Tutoriel pour imposer des politiques de conformité et de sécurité sur vos déploiements Kubernetes à l'aide de Kyverno"
url: /2022/08/01/vos-politiques-de-conformite-sur-kubernetes-avec-kyverno/
image: /2022/07/Kyverno_Horizontal.png
categories:
  - systeme
  - Virtualisation
tags:
  - Docker
  - Kyverno
  - Kubernetes
  - politique
  - sécurité

---

## Introduction

Si le titre de cet article vous dit quelque chose, c'est peut-être parce que je l'ai déjà utilisé il y a 2 ans tout pile pour parler d'un autre logiciel de gestion de politiques de conformité : [Open Policy Agent (OPA) et de son pendant dans Kubernetes, Gatekeeper](/2020/07/20/vos-politiques-de-conformite-sur-kubernetes-avec-opa-et-gatekeeper/).

Et je ne vais pas mentir, je n'ai pas beaucoup refait de l'OPA depuis cet article de 2020...

La première raison est que j'ai changé d'entreprise pile à ce moment-là et que j'avais d'autres priorités dans la nouvelle entreprise qui m'emploie. 

La seconde, certainement plus vraie mais peut être aussi moins avouable, c'est qu'OPA c'est quand même pas super user friendly. Notamment à cause du **rego**,  le langage des politiques de conformités.

Depuis, j'ai découvert [Kyverno](https://kyverno.io/), un petit nouveau dans le "cloud native" game (promu au niveau de "sandbox CNCF" depuis peu) et qui propose des politiques de conformité pour Kubernetes uniquement (contrairement à OPA + rego qui sont généralistes), écrites en YAML.

> With Kyverno, policies are managed as Kubernetes resources and no new language is required to write policies.

Prends toi ça, **rego** ;-)

**Note :** Cet article va rester relativement simple, c'est une introduction. On ira plus loin dans les articles suivants (coder sa propre politique, l'UI, etc).

Je ne vais pas beaucoup innover par rapport à l'article sur OPA et repartir du même cas d'usage : interdire à deux développeurs d'utiliser la même URL pour leur app web déployée dans Kubernetes (car on a vu que c'était assez nul quand ça arrive). 

Et vous allez voir que la première marche d'apprentissage est BEAAAAUCOUP plus accessible avec Kyverno que OPA (même si ça va faire râler la moitié de mon Twitter que je parle encore de YAML 🤣).

## Prérequis

Même topo que pour OPA / Gatekeeper, il faut la 1.14 de Kube pour utiliser Kyverno. La 1.14 était déjà pas la plus récente en 2020, c'est carrément la préhistoire maintenant ;-).

> Your Kubernetes cluster version must be above v1.14 which adds webhook timeouts.

Bien évidemment, il faut également avoir les droits d’accès admin sur le cluster, car on va devoir créer des *Validating Admission Webhooks* et des *CRDs*. Là encore, je vous renvoie [au précédent article](/2020/07/20/vos-politiques-de-conformite-sur-kubernetes-avec-opa-et-gatekeeper/) et à la doc officielle si ça ne vous parle pas.

Pour faire bref, on va s'insérer dans le processus de déploiement de Kubernetes pour interdire aux gens de faire des choses qui ne respectent pas vos bonnes pratiques (avec les webhooks) et on va ajouter des APIs supplémentaires pour étendre Kubernetes (les CRDs), de manière à pouvoir décrire qu'est ce qui n'est pas autorisé.

## Déploiement

Niveau installation, on reste sur du simple et efficace. 

Kyverno propose plusieurs Charts helm :
* une pour **Kyverno** même
* une pour **Policy Reporter**
* une contenant un "pack" de règles par défaut, configurées comme "non bloquantes" (en vrai, l'équivalent de ce qu'on pouvait faire avec les Pods Security policies)

Dans le cadre de cet article, je ne m'intéresse qu'à Kyverno même. Mais comme je l'ai dis plus haut, on reparlera des 2 suivantes dans un prochain numéro.

On commence donc par ajouter Kyverno lui-même :

```console
$ helm repo add kyverno https://kyverno.github.io/kyverno/
$ helm repo update
$ helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
  NAME: kyverno
  LAST DEPLOYED: Mon Jul 25 21:55:11 2022
  NAMESPACE: kyverno
  STATUS: deployed
  REVISION: 1
  NOTES:
  Chart version: v2.5.2
  Kyverno version: v1.7.2

  Thank you for installing kyverno! Your release is named kyverno.
  ⚠️  WARNING: Setting replicas count below 3 means Kyverno is not running in high availability mode.

  💡 Note: There is a trade-off when deciding which approach to take regarding Namespace exclusions. Please see the documentation at https://kyverno.io/docs/installation/#security-vs-operability to understand the risks.
```

**Note :** vous remarquerez le **WARNING** à l'install. Par défaut, Kyverno est déployé avec un seul replica. S'il crashe, vous ne pouvez plus rien déployer ou modifier sur votre cluster (ça m'est arrivé). La solution pour s'en sortir est de supprimer les **webhooks** de Kyverno pour débloquer la situation. Et bien sûr, de lui donner plus d'air (de plus grandes limites, surtout niveau RAM) et surtout 3 réplicas (ou plus)...

**Note 2 :** Il est probablement préférable d'exclure certains namespaces (kube-system, kyverno, ...) du scope de Kyverno pour éviter de mauvaises surprises. Le blogpost *Thibault Lengagne* de chez Padok en parle aussi (lien en bas de l'article).

## Qu'est-ce qu'on a déployé ?

A première vue, pas grande chose. Si on fait un `kubectl -n kyverno get all`, on trouve juste un *Pod* (+*ReplicaSet* +*Deplopyment*) et deux *Services*.

Mais en coulisse, on a déployé bien plus que ça ;)

Si on cherche des CRDs, on voit qu'on a pas mal de nouveaux objets à notre disposition.

```console
$ kubectl api-resources --api-group=kyverno.io
  NAME                          SHORTNAMES   APIVERSION            NAMESPACED   KIND
  clusterpolicies               cpol         kyverno.io/v1         false        ClusterPolicy
  clusterreportchangerequests   crcr         kyverno.io/v1alpha2   false        ClusterReportChangeRequest
  generaterequests              gr           kyverno.io/v1         true         GenerateRequest
  policies                      pol          kyverno.io/v1         true         Policy
  reportchangerequests          rcr          kyverno.io/v1alpha2   true         ReportChangeRequest
  updaterequests                ur           kyverno.io/v1beta1    true         UpdateRequest
```

De même, on a également des nouveaux webhooks

```console
$ kubectl get validatingwebhookconfigurations.admissionregistration.k8s.io
  NAME                                      WEBHOOKS   AGE
  kyverno-policy-validating-webhook-cfg     1          8m48s
  kyverno-resource-validating-webhook-cfg   2          8m48s

$ kubectl get mutatingwebhookconfigurations.admissionregistration.k8s.io
  NAME                                    WEBHOOKS   AGE
  kyverno-policy-mutating-webhook-cfg     1          11m
  kyverno-resource-mutating-webhook-cfg   2          11m
  kyverno-verify-mutating-webhook-cfg     1          11m
```

> A quoi ça sert ? Comment ça marche ?

Pour simplifier, on va décrire ce qu'on ne veut pas autoriser dans notre cluster à l'aide de la CRD *ClusterPolicy*.

En fonction des règles qu'on aura écrites dedans, les **webhooks** vont s'insérer dans le processus normal de déploiement de ressources de Kubernetes pour les autoriser ou pas.

![](/2022/07/admission-controller-phases.png)

> [Kubernetes Blog - A Guide to Kubernetes Admission Controllers](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/)

## Exemple des Ingress avec la même URL

Assez de théorie, le plus simple c'est que je vous montre. Je vous l'ai dit au début de l'article, de manière à comparer les deux produits, je vais repartir du même cas d'usage.

Dans mes clusters Kubernetes, je veux interdire à deux applications de créer un *Ingress* avec la même URL, car dans mon cas personnel, ce n'est pas autorisé. C'est le signe d'une erreur de copié-collé d'une Chart Helm vers une autre (ou tout autre erreur humaine). 

La conséquence de cette erreur est un conflit dans le routage des requêtes HTTP entrantes et on se retrouve avec *un genre de round robin chelou* où la moitié des requêtes tapent le mauvais backend. En prod, ça la fout mal, et on risque de se retrouver avec des clients qui râlent sur Twitter que l'application est down ;-).

Au même titre qu'OPA propose de régler ce problème dans les politiques mises à disposition par la communauté, [il existe la même avec Kyverno](https://kyverno.io/policies/other/unique-ingress-paths/unique-ingress-paths/).

On verra plus en détails dans l'article suivant comment sont construites ces règles. Dans un premier temps, on va juste déployer cette règle en mode "audit" et voir si ça fonctionne.

> spec:
>   validationFailureAction: audit

```console
$ kubectl apply -f https://raw.githubusercontent.com/kyverno/policies/main/other/unique-ingress-paths/unique-ingress-paths.yaml
  clusterpolicy.kyverno.io/unique-ingress-host created
```

Si vous avez un cluster kubernetes sous la main, je vous propose donc d'appliquer ces deux *Ingress*, configurés pour récupérer du trafic depuis la même URL (toto.example.org) :

```console
$ for counter in 1 2; do
cat > ingress${counter}.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress${counter}
spec:
  rules:
  - host: toto.example.org
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: service${counter}
            port:
              number: 4200
EOF
done

$ kubectl apply -f ingress1.yaml
  ingress.networking.k8s.io/ingress1 created
$ kubectl apply -f ingress2.yaml
  ingress.networking.k8s.io/ingress2 created
```

Normalement, rien ne se passe. Kyverno ne vous empêche pas de créer ces deux *Ingress* puisqu'on est en mode "validationFailureAction: audit" (même si les backends n'existent pas derrière, ça n'a pas d'importance).

```console
$ kubectl get ingress                                
  NAME       CLASS    HOSTS             ADDRESS   PORTS   AGE
  ingress1   <none>   toto.example.org             80      90s
  ingress2   <none>   toto.example.org             80      87s
```

En revanche, en allant lire les **Events**, vous allez trouver des **PolicyViolation** :

```console
$ kubectl get events --field-selector=reason=PolicyViolation
LAST SEEN   TYPE      REASON            OBJECT                              MESSAGE
118s        Warning   PolicyViolation   ingress/ingress1                    policy unique-ingress-host/check-single-host fail: The Ingress host name must be unique.
118s        Warning   PolicyViolation   ingress/ingress1                    policy unique-ingress-host/check-single-host fail: The Ingress host name must be unique.
118s        Warning   PolicyViolation   clusterpolicy/unique-ingress-host   Ingress default/ingress1: [check-single-host] fail
115s        Warning   PolicyViolation   clusterpolicy/unique-ingress-host   Ingress default/ingress2: [check-single-host] fail
```

Le fait qu'on ait 2 *Ingress* pointant sur la même URL est bien détecté et est remonté dans les *Events* Kubernetes. Chouette :)

En beaucoup plus verbeux, on pourra également récupérer les *PolicyReports*, qui disent la même chose en (encore ?) moins lisible.

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

On nettoie pour la suite :

```console
$ kubectl delete ingress ingress1 ingress2
```

## "La loi, c'est moi"

Imaginons que vous avez maintenant bien testé vos politiques, que vos devs ne génèrent plus de manifests ne correspondant pas à vos bonnes pratiques (ex. pas de containers en root, des labels obligatoires présents, limits/requests correctes, etc). Votre cluster est propre !

Vous pouvez passer vos politiques de conformités en mode "enforcing". Contrairement au mode "audit", ce mode est bloquant et les manifests qui ne respectent pas les politiques en questions seront refusés par Kubernetes.

```console
$ kubectl patch clusterpolicies.kyverno.io unique-ingress-host --patch '{"spec":{"validationFailureAction":"enforce"}}' --type merge
```

> Oui, je fais un "patch" plutôt qu'un "edit" pour me la péter ;-)

Et on teste à nouveau :

```console
$ kubectl apply -f ingress1.yaml 
  ingress.networking.k8s.io/ingress1 created
```

So far, so good

```console
$ kubectl apply -f ingress2.yaml
Error from server: error when creating "ingress2.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Ingress/default/ingress2.yaml was blocked due to the following policies

unique-ingress-host:
  check-single-host: The Ingress host name must be unique.
```

ET PAF 💥🍫!

![](/2020/05/chocapic.jpg)

## Conclusion

Dans cet exemple basique (mais réellement utile), on arrive aussi facilement qu'avec OPA à empêcher les utilisateurs de créer des *Ingress* ayant la même URL.

On peut alors se demander "pourquoi préférer Kyverno ?". Au-delà d'autres trucs sympas que nous verrons dans les billets suivants, ma réponse va tenir en une seule image.

![](/2022/07/rego_vs_kyverno.png)

Mon point de vue (très personnel), c'est que le **rego**, c'est illisible et verbeux, et donc pas maintenable. Là encore, c'est personnel, mais je n'ai jamais réussi à m'y mettre. 

Sans aller jusqu'à idéaliser le langage de Kyverno\*, je trouve que c'est quand même clairement **beaucoup plus simple** à écrire, mais surtout, à lire. Dans le cas où vous devriez modifier/écrire/maintenir vos propres politiques, cela sera très utile.

(*Oui, il y a un langage, notamment pour le pattern matching... et point irritant, ce n'est **pas** jsonpath comme pour `kubectl`, mais [JMESPath](https://kyverno.io/docs/writing-policies/variables/), similaire mais pas identique...)

## Ressources complémentaires

* ["Catalogue" des Politiques officielles de Kyverno](https://kyverno.io/policies/)
* [Blog de Padok - Kyverno : Sécuriser vos environnements Kubernetes](https://www.padok.fr/blog/securite-kubernetes-kyverno)
* [Aurélie Vache - Understanding Kubernetes: part 44 – Tools - Kyverno ](https://dev.to/aurelievache/understanding-kubernetes-part-44-tools-kyverno-52mc)
* [Kubernetes Blog - A Guide to Kubernetes Admission Controllers](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/)
