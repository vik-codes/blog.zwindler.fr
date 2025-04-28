---
title: 'ClusterConfiguration : introduction aux APIs de kubeadm pour installer vos clusters'
authors:
  - zwindler
type: post
date: 2023-12-17T12:00:00+02:00
url: /2023/12/17/kubeadmcfg-introduction-api-kubeadm
image: /2023/12/bare-metal-kuberetes-2.jpeg
categories:
  - Virtualisation
tags:
  - Kubernetes
  - kubeadm
  - kubeadmcfg

---

## Créer des clusters Kubernetes avec `kubeadm`, mais sans CLI à rallonge

Un des premiers articles que j'ai écrits sur [Kubernetes était l'installation d'un cluster avec `kubeadm`](/2017/06/07/installer-cluster-kubernetes-vm-centos/). A l'époque, j'avais testé avec les options de bases et ça marchait très très bien déjà.

Mais quand on commence à avoir des clusters un peu plus proches de la production, on se retrouve rapidement à rajouter plein d'options dans la CLI. 

Pire, à un certain niveau de complexité, certaines options ne fonctionnent pas ensemble !

Note: c'est ce qui m'est arrivé quand j'ai essayé d'automatiser l'installation de `kubeadm` avec Ansible. On pourra débattre de l'intérêt d'automatiser une install kubeadm avec Ansible alors que Kubespray existe, [cf cet autre article que j'ai écrit en 2017](/2017/12/05/installer-kubernetes-kubespray-ansible/) mais c'est au-delà du scope de cet article...

## Pour faire propre, arrêtez de passer la terre entière en arguments

Clairement, à partir de 5 ou 6 options, c'est le moment de se demander s'il ne serait pas préférable d'utiliser un fichier de configuration pour gérer nos clusters.

Et ça tombe bien, kubeadm dispose d'une API (plusieurs en fait), on va donc pouvoir écrire du YAML **avant** même d'avoir notre cluster Kubernetes opérationnel. YAY ! (font les YAML engineers)

## Concrètement comment ça se présente ?

Plutôt que de passer tous nos arguments dans notre commande `kubeadm`, on va remplir un fichier `kubeadmcfg.yaml` qui va nous servir de configuration. En vrai, on va même en avoir plusieurs, puisque les nodes n'ont pas tous le même rôle dans notre workflow de création de cluster.

Le premier fichier sera un fichier qui contiendra la **ClusterConfiguration** (cf [doc officielle](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/control-plane-flags/#customizing-the-control-plane-with-flags-in-clusterconfiguration))

A noter, vous pouvez récupérer le fichier des valeurs par défaut avec la commande :

```yaml
$ kubeadm config print init-defaults
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
localAPIEndpoint:
  advertiseAddress: @IP
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: node
  taints: null
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 4m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.k8s.io
kubernetesVersion: 1.28.0
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
scheduler: {}
```

A partir de là, on va pouvoir customiser notre control plane, via des sections correspondant à chaque composant du control plane :
* apiServer
* controllerManager
* scheduler
* etcd

## A quoi ça peut bien servir ?

Forcément les possibilités sont très nombreuses et je ne vais pas toutes les lister. Mais je vais vous donner quelques exemples.

L'exemple le plus parlant est évidemment l'ajout d'arguments aux différents composants. Ici, j'ajoute l'authentification OIDC au cluster et mes feature gates pour activer les APIs alpha :

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
[...]
apiServer:
  extraArgs:
    feature-gates: {{ kube_feature_gates }}
    oidc-issuer-url: {{ kube_oidc_issuer_url }}
    oidc-client-id: {{kube_oidc_client_id }}
    oidc-username-claim: email
    oidc-groups-claim: groups
[...]
```

Si vous avez plusieurs virtual IPs qui permettent de vous connecter à votre cluster Kubernetes, il sera probablement nécessaire de supporter plusieurs certSANs pour la partie TLS :

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
[...]
apiServer:
  certSANs:
  - "{{ control_plane_endpoint_ip }}"
  - "{{ control_plane_endpoint_ip_for_humans }}"
[...]
```

Dans le cas où vos machines ont plusieurs IPs, il pourra être nécessaire d'indiquer au cluster les bonnes IPs pour le contacter. Petit piège, il faut modifier dans une autre API que j'ai omis pour l'instant : **InitConfiguration** !

```yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
[...]
localAPIEndpoint:
  advertiseAddress: {{ app_ip }}
  bindPort: 6443
[...]
```

Si vous avez suivi [mon précédent article sur mon petit souci de prod avec etcd qui était spammé par Kyverno](/2023/11/30/kubernetes-error-etcdserver-mvcc-database-space-exceeded/), vous saurez qu'il faut tuner la base etcd. Comme ceci par exemple :

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
[...]
etcd:
  local:
    extraArgs:
      quota-backend-bytes: "5368709120"
      auto-compaction-retention: "1"
      auto-compaction-mode: periodic
[...]
```

Et de mon côté, j'ai besoin de changer le nom de domaine des services Kubernetes. Je le fais comme ceci :

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
[...]
networking:
  dnsDomain: {{ kube_dns_domain }}
[...]
```

Une fois que c'est bien configuré comme on en a envie :

```
/usr/bin/kubeadm init --config=/etc/kubernetes/kubeadmcfg.yaml --upload-certs --skip-certificate-key-print
```

## Et ensuite ?

La **ClusterConfiguration**, c'est cool, mais il existe d'autres API utiles avec kubeadm, je le disais plus haut.

Lorsqu'on va ajouter des nodes au control plane, on ne va pas pouvoir réutiliser la **ClusterConfiguration** et l'**InitConfiguration**, car elles servent pour TOUT le cluster et sont unique. On les a déjà configurées quand on a fait l'init du premier node de control plane.

On va donc utiliser la **JoinConfiguration**, qui nous permet là aussi de définir des trucs importants comme :
* localAPIEndpoint.advertiseAddress si on a plusieurs IPs sur la machine (exemple ci dessus).
* discovery.bootstrapToken.token (et caCertHashes) qui va permettre de faciliter l'automatisation du join des nodes

```yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: {{ control_plane_endpoint }}
    token: {{ kubeadm_token }}
    caCertHashes: 
      - sha256:{{ kubeadm_cacert_hash }}
    unsafeSkipCAVerification: false
nodeRegistration:
  name: {{ ansible_nodename }}
controlPlane:
  certificateKey: {{ kubeadm_certificate_key }}
  localAPIEndpoint: 
    advertiseAddress: {{ app_ip }}
    bindPort: 6443
{% endif %}
```

Une fois que ce fichier est créé sur la machine du control plane qui va rejoindre la première, on peut lancer la commande `kubeadm join` qui devrait bien se passer ;-\).

```
kubeadm join {{ control_plane_endpoint_ip }} --config /etc/kubernetes/kubeadmcfg.yaml
```

## Conclusion

Utiliser les fichiers de configuration de `kubeadm` n'est pas trivial car assez mal documenté (je trouve, les docs sont éclatés entre plusieurs pages et les exemples pas parlants dans mon cas).

Je ne vais pas mentir, je me suis arraché les cheveux et j'ai demandé de l'aide plusieurs fois sur X. 

Bien sûr, vous pouvez aller potasser la doc officielle [Customizing components with the kubeadm API](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/control-plane-flags/#customizing-the-control-plane-with-flags-in-clusterconfiguration) et [kubeadm Configuration (v1beta3)](https://kubernetes.io/docs/reference/config-api/kubeadm-config.v1beta3/) mais j'ai quand même eu du mal à comprendre COMMENT l'utiliser, la première fois.

J'espère que cet article pourra aider à mieux comprendre comment les différentes API s'articulent entre elles et comment les utiliser.










