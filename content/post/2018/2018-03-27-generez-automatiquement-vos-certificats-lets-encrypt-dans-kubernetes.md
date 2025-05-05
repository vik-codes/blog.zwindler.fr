---
title: 'Générez automatiquement vos certificats Let’s Encrypt dans Kubernetes'
authors:
  - zwindler
type: post
date: 2018-03-27T11:45:52+00:00
url: /2018/03/27/generez-automatiquement-vos-certificats-lets-encrypt-dans-kubernetes/
image: /2018/03/kubernetes_le.png
categories:
  - Cluster
  - DIY
  - systeme
  - Virtualisation

---
## Pourquoi faire à la main ce qu’on peut faire avec cert-manager ?

On a vu [dans l’article précédent comment utiliser les Ingress](/2018/03/06/exposer-des-applications-kubernetes-en-dehors-des-cloud-providers-nginx-ingress-controller/) permet de simplifier l’accès depuis l’extérieur vers nos applications hébergées dans Kubernetes. Cependant, il manque encore une petite pierre à l’édifice : l’accès en HTTPS et les certificats TLS.

## On en est où déjà ?

Maintenant qu’on a notre cluster Kubernetes et nos premier **Ingress**, quand on appelle l’URL http://blobiblob.example.org on tombe sur notre application.

Petit rappel, voilà à quoi ressemble notre **Ingress** :

```
cat nginx-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: nginx-ingress
spec:
  rules:
  - host: blobiblob.zwindler.fr
    http:
      paths:
        - path: /
          backend:
            serviceName: blobiblob-app-svc
            servicePort: 8080
```


> So far, so good.

Maintenant, si on veut rajouter du HTTPS, on peut le faire pratiquement sans modification directement avec nos **Ingress**. En effet, l’**Ingress Controller** nginx va par défaut utiliser le certificat autosigné généré par Kubernetes. Il suffit de modifier l’**Ingress** et d’appliquer les modifications suivantes :

```
cat nginx-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: nginx-ingress
spec:
  tls:
  - hosts:
   - blobiblob.zwindler.fr
  rules:
  - host: blobiblob.zwindler.fr
    http:
      paths:
        - path: /
          backend:
            serviceName: blobiblob-app-svc
            servicePort: 8080
```


_On remarque que la syntaxe est un poil différente, avec l’ajout d’une section « tls » contenant une liste d’hôtes et indiquant à notre Ingress qu’il s’agit de backend à exposer en HTTPS._

En revanche, même si dans l’absolu ça fonctionnera, on aura quand même une erreur de certificat, ce qui n’est pas forcément agréable et qui peut surtout vous pénaliser en terme de visites, notamment à cause des messages d’erreur bien anxiogènes de nos navigateurs web.

![](/2018/03/chrome_tls_invalide.png)

A titre d’exemple, j’ai perdu au minimum entre 20% et 30% de mon trafic quotidien le jour où j’ai _oublié_ (en vrai c’était plus compliqué) de renouveler le certificat de ce blog (oups). Donc en gros, ne le faites pas...

## Générer des certificats

Pour faire du HTTPS, il va donc falloir générer des certificats valides et surtout certifiées par une autorité de certification présente sur le poste client. Si on reste sur le cas de l’**Ingress Controller** Nginx, [il existe une page de documentation dédiée à ce sujet][3].

Mais bon, ça serait quand même bien mieux si on pouvait faire ça _automagiquement_, quand même, nan ?

## Let’s Encrypt + Kubernetes = <3

Je ne vais pas vous faire l’affront de vous expliquer ce qu’est [Let’s Encrypt][4], d’autant qu’en plus, [j’ai déjà écris quelques articles sur le sujet](/2017/05/02/proxmox-lets-encrypt/) (Proxmox).

Vous avez peut être vu une section à ce sujet : il _existait_ un projet [kube-lego][6] qui avait été désigné comme le moyen de générer des certificats et de les intégrer au processus de livraison d’applications dans K8s.

Cependant, pas de bol :

> The latest Kubernetes release that kube-lego officially supports is 1.8. The officially endorsed successor is cert-manager.

## cert-manager

La plupart des tutos que j’ai pu trouver sur le net citent justement **kube-lego**, mais pas son successeur, **cert-manager**. C’est d’autant plus dommage que la documentation n’est pas toujours hyper claire ;-).

Quelques liens utiles pour bien démarrer :

  * [Page principale du projet](https://github.com/cert-manager/cert-manager)
  * [Le guide de déploiement de cert-manager][9]
  * Et surtout, le schéma qui explique comment **cert-manager** fonctionne

![](/2018/03/high-level-overview.png)

> Source : https://github.com/jetstack/cert-manager/blob/master/docs/high-level-overview.png

## Helm !

Cette fois ci ([contrairement à l’article précédent][1]), on a de la chance, le **Chart** fonctionne même « on premise » ! On ne se gène donc pas et on le déploie avec Helm fissa :

```
helm install --name cert-manager --namespace kube-system stable/cert-manager --set ingressShim.extraArgs='{--default-issuer-name=letsencrypt-issuer,--default-issuer-kind=ClusterIssuer}'
  NAME: cert-manager
  LAST DEPLOYED: Sun Feb 25 18:27:44 2018
  NAMESPACE: kube-system
  STATUS: DEPLOYED
  [...]
  NOTES:
    cert-manager has been deployed successfully!
```

Et voilà, vous avez installé cert-manager.

Note: si vous n’avez pas encore installé Helm et Tiller, [je vous conseille d’aller lire cet article sur le sujet](/2018/02/06/se-simplifier-kubernetes-helm-charts/).

##  Création d’un ClusterIssuer

Mais qu’est ce que c’est qu’un **ClusterIssuer** ?

Eh bien en fait, **cert-manager** étend les concepts de Kubernetes (oui c’est vrai il n’y en avait pas beaucoup) et ajoute ce nouvel objet/concept qui correspond à un fournisseur de certificats. La documentation donne l’exemple de l’API Let’s Encrypt « staging ».

```
cat certmanager/letsencrypt-staging-cluster-issuer.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging-cluster-issuer
spec:
  acme:
    server: https://acme-staging.api.letsencrypt.org/directory
    email: mon_email_admin@zwindler.fr
    privateKeySecretRef:
      name: letsencrypt-staging
    http01: {}

kubectl apply -f certmanager/letsencrypt-staging-cluster-issuer.yaml
```


On comprend donc bien que cette nouvelle couche d’abstraction sera particulièrement utile dans le cas où de nouveaux types de **ClusterIssuers** font leur apparition dans le futur.

## Faire un test

Si vous êtes pressés de tester, on va commencer par faire le test avec le **ClusterIssuer** [« staging » de Let’s Encrypt][12], qui permet de réaliser des tests sans risquer de se faire bloquer (car il faut savoir qu’en cas de demandes répétés, Let’s encrypt bloque les demandeurs de certificats).

Maintenant qu’on a notre **ClusterIssuer**, on peut créer un **Certificate** (second objet introduit par **cert-manager**). Le **Certificate** a un nom, pointe vers un **Secret** et est lié à notre **ClusterIssuer**. Il sera demandé pour le sous domaine _blobiblob.zwindler.fr_, notre application web qui a besoin d’un certificat Let’s Encrypt.

```
cat certmanager/certmanager-blobiblob.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: blobiblob.zwindler.fr
  namespace: default
spec:
  secretName: blobiblob.zwindler.fr-tls
  issuerRef:
    name: letsencrypt-staging-cluster-issuer
    kind: ClusterIssuer
  commonName: blobiblob.zwindler.fr
  acme:
    config:
    - http01: {}
      domains:
      - blobiblob.zwindler.fr

kubectl apply -f certmanager/certmanager-blobiblob.yaml
```


Et dernier point, nous devons mettre à jour notre **Ingress** pour qu’il tire parti de notre secret et indiquer qu’il utilise _tls-acme_ :

```
cat ingress/ingress-blobiblob.zwindler.fr.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/tls-acme: "true"
    kubernetes.io/ingress.class: nginx
  name: ingress-blobiblob.zwindler.fr
spec:
  tls:
  - hosts:
    - blobiblob.zwindler.fr
    secretName: blobiblob.zwindler.fr-tls
  rules:
  - host: blobiblob.zwindler.fr
    http:
      paths:
        - path: /
          backend:
            serviceName: blobiblob-app-svc
            servicePort: 8080

kubectl apply -f certmanager/certmanager-blobiblob.yaml
```


## Youpi, ça marche !

Hum non, pas tout à fait. Le certificat a bien été généré, mais si vous avez suivi, depuis quelque temps je parle de l’environnement « staging » de Let’s Encrypt. Ce service est très pratique car il est beaucoup moins sévère que le service Let’s Encrypt de production dans le blocage des utilisateurs abusifs.

```
kubectl get certificate
NAME                AGE
blobiblob.zwindler.fr   2d
```


Cependant, le certificat généré n’est pas vraiment plus utilisable dans l’état que le certificat autosigné de Kubernetes. Et pour cause, il s’agit d’un certificat de Test « Fake LE Intermediate X1 »

## IRL

Maintenant qu’on a validé que tout marchait et qu’on allait pas se faire bloquer par LE, on on remplace donc « staging » par « prod » (et on met la bonne URL dans l’attribut « server »)

```
cat certmanager/letsencrypt-prod-cluster-issuer.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod-cluster-issuer
spec:
  acme:
    server: https://acme-v01.api.letsencrypt.org/directory
    email: mon_email_admin@zwindler.fr
    privateKeySecretRef:
      name: letsencrypt-prod
    http01: {}
```


On met à jour notre **Certificate** pour qu’il utilie ce nouveau **ClusterIssuer** :

```
cat certmanager/certmanager-blobiblob.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: blobiblob.zwindler.fr
  namespace: default
spec:
  secretName: blobiblob.zwindler.fr-tls
  issuerRef:
    name: letsencrypt-prod-cluster-issuer
    kind: ClusterIssuer
  commonName: blobiblob.zwindler.fr
  acme:
    config:
    - http01: {}
      domains:
      - blobiblob.zwindler.fr
```


On se débarrasse du certificat « Fake » qu’on vient de générer :

```
kubectl delete certificate blobiblob.zwindler.fr
certificate "blobiblob.zwindler.fr" deleted
```


Et enfin on en régénère un nouveau, réel cette fois ci (puis on l’applique dans l’**Ingress**) :

```
kubectl apply -f certmanager/certmanager-blobiblob.yaml
kubectl apply -f ingress/nginx-ingress.yaml
```


A partir de là, vous devriez avoir maintenant une application web en HTTPS avec un certificat let’s Encrypt valide et surtout généré automatiquement :)

![](/2018/03/blobiblob.zwindler.fr_.png)

> Victoire sans failles !

## Sources

  * https://letsencrypt.org/docs/staging-environment/
  * https://letsencrypt.org/docs/rate-limits/
  * https://letsencrypt.org/docs/acme-protocol-updates/
  * https://letsencrypt.org/2017/06/14/acme-v2-api.html

 [3]: https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/tls.md
 [4]: https://letsencrypt.org/
 [6]: https://github.com/jetstack/kube-lego
 [9]: https://cert-manager.io/docs/installation/
 [12]: https://letsencrypt.org/docs/staging-environment/
