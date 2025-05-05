---
title: Vos politiques de conformité sur Kubernetes avec OPA et Gatekeeper
authors:
  - zwindler
type: post
date: 2020-07-20T06:35:00+00:00
excerpt: "Tutoriel pour imposer des politiques de conformité et de sécurité sur vos déploiement Kubernetes à l'aide d'Open Policy Agent et Gatekeeper"
url: /2020/07/20/vos-politiques-de-conformite-sur-kubernetes-avec-opa-et-gatekeeper/
image: /2020/05/gatekeeper.png
categories:
  - systeme
  - Virtualisation
tags:
  - Docker
  - Gatekeeper
  - Kubernetes
  - OPA
  - Open Policy Agent
  - politique
  - sécurité

---

## Introduction
  
  
Un des problèmes que j’ai rencontré en administrant des clusters Kubernetes mutualisés entre plusieurs équipes était que les manifests qui étaient déployés n’étaient pas toujours parfaitement maîtrisés.

Dans certains cas, les manifests étaient copiés/collés d’autres équipes, provoquant parfois de petites surprises (pas de label pour indiquer l’équipe responsable de l’appli, mauvaises infos pour les Ingress...). Une des solutions trouvée a été de maintenir à jour un Chart Helm le plus générique possible, avec seulement des values à rentrer pour les développeurs. Ce Chart est maintenu conjointement par les Ops et les techleads.

Cependant, maintenir ce template est complexe et certaines applis s’éloignent trop du cadre général pour s’y conformer, même en forkant et en modifiant une partie des infos. Et certains problèmes comme la vérification des images ou des registries tournant sur la plateforme n’étaient pas traités par cette solution.

## Open Policy Agent / Gatekeeper

![](/2020/07/opa.png)

> https://www.thingiverse.com/thing:1236133


Plutôt que de vouloir unifier à tout prix la façon dont sont déployées les applications dans le cluster (et devoir gérer les exceptions), une autre façon de voir les choses est d’ajouter un outil qui permettrait de vérifier, au moment où on déploie, que ce qui est déployé respecte les bonnes pratiques de l’entreprise en termes de sécurité et de configuration.

Vous l’avez deviné, l’outil pour faire ça, c’est Open Policy Agent (ou OPA). Il s’agit d’un moteur de politiques générique open source (projet CNCF au stade Incubating).

Comme c’est un moteur générique, il existe également un autre projet,[Gatekeeper](https://github.com/open-policy-agent/gatekeeper), qui lui permet de gérer l’interaction entre OPA et Kubernetes.

## Prérequis
  
  
> To use Gatekeeper, you should have a minimum Kubernetes version of 1.14, which adds webhook timeouts.
  
Si vous êtes dans une version antérieure, ça se complique. Il existe un bug, fixé en 1.14, qui pourra faire planter votre OPA/Gatekeeper. Pour cette raison, si vous n’êtes pas en 1.14 (et que vous ne pouvez pas mettre à jour votre plateforme), il faudra se passer de Gatekeeper (via K8s Policy Controller par exemple). C’est un peu plus touchy et hors du scope de ce tutoriel.



![](/2020/05/k8spolicycontroller.png) 

> La « V2 », sans Gatekeeper, avec Kube-Mgmt et OPA 

Bien évidemment, il faut également avoir les droits d’accès admin sur le cluster. Gatekeeper propose de tester que vous avez des droits adéquats simplement en essayant de vous attribuer à vous-même les droits admins.

![](/2020/05/inception.gif)

> wait for it

```
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole cluster-admin \
    --user [votre user]
```


Petite astuce, si vous ne connaissez pas le nom du compte d’accès que vous utilisez actuellement, vous pouvez lancer cette commande :

```
kubectl config view --template='{{ range .contexts }}{{ if eq .name "'$(kubectl config current-context)'" }}Current user: {{ .context.user }}{{ end }}{{ end }}'
Current user: clusterUser_zwindlerk8s_rg_zwindlerk8s
```


## Installation

Je me suis donc créé pour l’occasion un petit cluster sur AKS en version 1.14 et j’ai déployé la version prépackagée de Gatekeeper.

```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
```



Tadam ! Et hop, Gatekeeper est installé dans votre cluster.
Note : La documentation officielle donne les étapes pour [construire vous-même votre image](https://github.com/open-policy-agent/gatekeeper#deploying-head-using-make).

## Ya quoi dans mon cluster ?
  
  
En se penchant de plus près sur ce que fait le _manifest_, voici ce que vous déployez lorsque vous lancez la commande ci-dessus :
  
* un Namespace `gatekeeper-system`
* un ServiceAccount `gatekeeper-admin`, associé à un Role et un ClusterRole `gatekeeper-manager-role` via (respectivement) un RoleBinding et ClusterRoleBinding `gatekeeper-manager-rolebinding`
* un Deployment `gatekeeper-controller-manager` et `gatekeeper-audit`
* un Service `gatekeeper-webhook-service`
* un Secret `gatekeeper-webhook-server-cert` qui contient un certificat
      
  
Jusque-là rien d’exceptionnel. Là où ça commence à devenir intéressant c’est :
  
* deux CRD (Custom Resource Definition) `configs.config.gatekeeper.sh` et `constrainttemplates.templates.gatekeeper.sh`
* un validating webhook configuration `gatekeeper-validating-webhook-configuration`
      
  
## Validating Webhook
  
  
Le validation webhook d’abord. La première fois que j’ai entendu parler de validating webhooks, c’était lors du talk [101 Ways to “Break and Recover” Kubernetes Cluster](https://www.youtube.com/watch?v=likHm-KHGWQ) à la Kubecon 2018.

Les problèmes de ces employés de Oath (ex-Yahoo) étaient identiques aux miens. Certaines équipes, en récupérant (aka copiant/collant) des manifests provenant d’autres équipes, oubliaient de changer les URL des Ingress. On se retrouvait ainsi avec des requêtes d’utilisateurs qui se retrouvaient distribuées de manière aléatoires vers 2 services totalement différents.

La solution proposée à cette conf était d’utiliser des Validating/Mutating Admission Webhooks de Kubernetes (à peu près stable depuis la 1.11).

En 2018, en creusant le sujet, j’ai trouvé assez peu de documentation là-dessus, au-delà de la doc officielle (j’en ai trouvé un peu plus depuis). Autre problème, les Admissions webhooks nécessitent de développer son propre Controller, ce qui n’était pas très accessible (cf les liens en fin d’article).

Heureusement pour nous, Gatekeeper et OPA vont s’occuper de ça pour nous.

## Custom Resource Definition
  
  
Pour ceux qui ne connaissent pas les CRD, il s’agit pour faire simple des extensions de l’API de Kubernetes. Le gros avantage des CRDs est que ces objets sont un moyen pour les éditeurs tiers d’ajouter de la logique qui leur est propre _dans_ Kubernetes.
J’ai déjà un peu parlé de CRD dans cet article sur [Rook](/2019/09/10/du-ceph-dans-mon-kubernetes/) qui permet de gérer de manière automatisée des clusters Ceph (et pas que !) via le CRD CephCluster. Toutes les tâches d’administration courantes sont intégrées à Kubernetes (alors que de base Kube n’en a aucune connaissance), gérées par un Controller inclus dans Rook et configurées via des CRDs.

Gatekeeper va donc ajouter 3 composants à notre Kubernetes :
  
* un objet Config
* un objet ConstraintTemplate
* un objet Constraint
      
  
## Config
  
  
Le principe de Gatekeeper, comme on le voit dans le schéma suivant, est qu’il se branche sur l’API server de votre Kubernetes et qu’il "synchronise" les événements de création de nouveaux objets, à la recherche d’objets qui ne respecteraient pas vos politiques de conformité.



![](/2020/05/gatekeeper_v3.png) 

> Source : [kubernetes.io/blog][1] 


Par défaut, si vous ne lui dites rien, Gatekeeper n’écoute les événements d’aucuns objets Kubernetes... il ne fera donc... rien du tout !

On change ça tout de suite en disant à Gatekeeper d’écouter tous les événements sur les Ingress :

```
cat gatekeeper/demo/basic/sync.yaml
apiVersion: config.gatekeeper.sh/v1alpha1
kind: Config
metadata:
  name: config
  namespace: "gatekeeper-system"
spec:
  sync:
    syncOnly:
      - group: "extensions"
        version: "v1beta1"
        kind: "Ingress"
      - group: "networking.k8s.io"
        version: "v1beta1"
        kind: "Ingress"
```



## ConstraintTemplate
  
  
> Before you can define a constraint, you must first define a ConstraintTemplate, which describes both the Rego that enforces the constraint and the schema of the constraint.
  
L’idée ici, c’est qu’avant de commencer à créer des contraintes sur le cluster, il va falloir créer des templates de contraintes. Il faut voir ces templates comme l’objet qui va relier d’un côté la fonction (le code en rego d’OPA) d’un côté et des paramètres de l’autre.

Cette étape supplémentaire nous permettra éventuellement de réutiliser le même template pour plusieurs contraintes différentes.

## Votre premier template
  
  
Pour la première fois, on peut se contenter d’utiliser les templates fournis en exemple sur le Github de OPA/Gatekeeper et qui permet d’imposer la présence d’un label dans un type d’objet Kube donné, car il est plus simple ([k8srequiredlabels_template.yaml](https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/basic/templates/k8srequiredlabels_template.yaml))

Cependant, depuis tout à l’heure, je vous parle d'empêcher les équipes d’utiliser le même FQDN dans des Ingress pour plusieurs services. Car si ça venait à arriver, je le rappelle, on aurait un genre de loadbalancer chelou qui redirigerait la moitié des requêtes des utilisateurs sur une application ou sur l’autre pour une même URL.

Et ça tombe bien, ce [template](https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/dryrun/k8suniqueingresshost_template.yaml) va nous permettre de nous en assurer !


```
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8suniqueingresshost
spec:
  crd:
    spec:
      names:
        kind: K8sUniqueIngressHost
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8suniqueingresshost
       
        identical(obj, review) {
          obj.metadata.namespace == review.object.metadata.namespace
          obj.metadata.name == review.object.metadata.name
        }

        violation[{"msg": msg}] {
          input.review.kind.kind == "Ingress"
          re_match("^(extensions|networking.k8s.io)$", input.review.kind.group)
          host := input.review.object.spec.rules[_].host
          other := data.inventory.namespace[ns][otherapiversion]["Ingress"][name]
          re_match("^(extensions|networking.k8s.io)/.+$", otherapiversion)
          other.spec.rules[_].host == host
          not identical(other, input.review)
          msg := sprintf("ingress host conflicts with an existing ingress <%v>", [host])
        }
```



Au premier abord, c’est quand même assez touffu. Bon après, j’ai pas pris l’exemple le plus simple non plus, et si vous re-regardez la vidéo [Kubecon 2019 | Intro: Open Policy Agent - Rita Zhang, Microsoft & Max Smythe, Google](https://www.youtube.com/watch?v=Yup1FUc2Qn0&feature=youtu.be), c’est en fait assez simple à comprendre.


```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/dryrun/k8suniqueingresshost_template.yaml
constrainttemplate.templates.gatekeeper.sh/k8suniqueingresshost created

kubectl get constrainttemplate
NAME                       AGE
k8suniqueingresshost       23m
```



## Et une Constraint
  
  
Maintenant qu’on a notre template, on peut donc simplement l’instancier avec les variables qui nous intéressent.

Pour rester dans l’exemple en démo, on s’assure que dans tout le cluster, il n’existe pas 2 fois la même URL pour 2 Ingress différents en instanciant cette contrainte :


```
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sUniqueIngressHost 
metadata:
  name: unique-ingress-host
spec:
  enforcementAction: dryrun
  match:
    kinds:
      - apiGroups: ["extensions", "networking.k8s.io"]
        kinds: ["Ingress"]
```



Je vais un tout petit peu modifier cette Contrainte car comme vous pouvez le voir, elle définie une enforcementAction: `dryrun`, qui n’a pas d’effet immédiat (ça logue juste une erreur pour un audit futur). C’est une super feature qui permet de monter en compétence sur OPA, mais pour ma démo c’est moins fun...

Donc j’applique le fichier et je modifie l’enforcementAction


```
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/dryrun/unique-ingress-host.yaml
kubectl patch K8sUniqueIngressHost.constraints.gatekeeper.sh unique-ingress-host -p '{"spec":{"enforcementAction":"deny"}}' --type=merge
```



## Et enfin, on essaye
  
  
Normalement on a tout maintenant. Gatekeeper écoute sur l’API server tous les événements des objets de type Ingress (via la Config). On a un ContraintTemplate avec du code `rego` qui va vérifier qu’on a pas déjà une autre URL identique dans les Ingress existant et une Constraint qui définie ce qu’on doit faire (dryrun) et sur quels objets (Ingress).

On peut donc dérouler la démo :D


```
# Creation du namespace qui contiendra les objets de la demo
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/bad_resources/namespace.yaml
namespace/production created
# Creation d'un Ingress avec une URL qui n'existe pas encore
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/dryrun/existing_resources/example.yaml
ingress.extensions/ingress-host created
# Creation d'un second Ingress avec la MEME URL
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/dryrun/bad_resource/duplicate_ing.yaml
```



Et paf !

> [denied by unique-ingress-host] ingress host conflicts with an existing ingress <example-host.example.org>
  

![](/2020/05/chocapic.jpg)


## Conclusion
  
  
Je l’expliquais en introduction, ajouter des politiques de conformités et des contraintes sur un cluster Kubernetes n’était pas trivial.

Sans aller jusqu’à dire que ça devient simple, OPA et Gatekeeper facilitent le travail (plus besoin de développer puis d’héberger soi-même un microservice pour chaque Admission/validation Webhook). Il reste est nécessaire de s’approprier un nouveau langage (rego) pour commencer à faire des choses sympa, mais pour autant, rien qu’avec les templates par défaut, il y a déjà de quoi faire.

Un autre point vraiment intéressant avec OPA, c’est la possibilité de loguer et d’auditer toutes les erreurs de conformités avec le mode `dryrun` à la place du `deny`, sans bloquer.


```
kubectl get K8sUniqueIngressHost.constraints.gatekeeper.sh unique-ingress-host -o yaml
[...]
  - enforcementAction: dryrun
    kind: Ingress
    message: ingress host conflicts with an existing ingress <example-host.example.org>
    name: ingress-host2
    namespace: default
```

## Sources
  
  
  
* [Kubernetes.io | OPA Gatekeeper: Policy and Governance for Kubernetes](https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/)
* [Kubecon 2019 | Intro: Open Policy Agent - Rita Zhang, Microsoft & Max Smythe, Google](https://www.youtube.com/watch?v=Yup1FUc2Qn0&feature=youtu.be)
* [A Guide to Kubernetes Admission Controllers](https://kubernetes.io/blog/2019/03/21/a-guide-to-kubernetes-admission-controllers/)
* [Blog container-solutions | Some Admission Webhook Basics](https://blog.container-solutions.com/some-admission-webhook-basics)
* [IBM Cloud | Diving into Kubernetes MutatingAdmissionWebhook](https://medium.com/ibm-cloud/diving-into-kubernetes-mutatingadmissionwebhook-6ef3c5695f74)
      

 [1]: https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/
