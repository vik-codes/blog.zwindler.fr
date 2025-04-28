---
title: Migration du routage de cilium de iptables vers eBPF... à chaud !
authors:
  - zwindler
type: post
date: 2023-10-20T06:00:00+02:00
excerpt: Bouclez votre ceinture, on va parler d'iptables, d'eBPF, de per-node configuration et de cli cilium !
url: /2023/10/20/migration-routage-cilium-iptables-ebpf
image: /2023/10/cilium-logo.png
categories:
  - Cluster
  - DIY
  - Système
  - Virtualisation
tags:
  - k8s
  - Kubernetes
  - cilium
  - iptables
  - eBPF

---

## Contexte

Il se pourrait que j'aie configuré des clusters Kubernetes de prod avec [cilium](https://cilium.io/) en mode `iptables` et non pas `eBPF`. Mais vous n'avez aucune preuve...

Cependant, dans l'hypothèse hautement improbable où j'aurais pu faire une boulette pareille, voilà comment je m'y serai pris pour résoudre le problème. 

#trollface

Imaginons donc qu'en vérifiant la configuration de Cilium, voici ce que vous avez trouvé :

```yaml
kubectl -n cilium exec -it cilium-aaaaa -- cilium status
[...]
Host Routing: Legacy
Masquerading: IPTables [IPv4: Enabled, IPv6: Disabled]
[...]
```

Damned!

A y regarder de plus près, les containers cilium-agent dans vos pods cilium prennent beaucoup de CPU et de RAM et commencent à engorger vos workers...

**C'est la cata**.

## Pourquoi ça ?

Les premières implémentations du *réseau imaginaire* de Kubernetes (les fameux CNI plugins) utilisaient `iptables`. Or, on sait depuis très longtemps, notamment dans le cas d'usage de Kubernetes, qu'`iptables` est assez mauvais pour gérer de grandes quantités de règles.

Dans le cas particulier de Kubernetes, le nombre de règles à tendance à augmenter de manière exponentielle avec la taille du cluster et le CPU consommé pour router des paquets réseaux avec...

À un moment donné, parcourir la liste des règles prend tout le CPU d'un nœud donné et le rend non réactif.

> Allo patron ? On est mal.

C'est une des raisons pour lesquelles j'aime beaucoup cilium comme CNI plugin, les développeurs font partie des premiers à avoir misé sur [eBPF](https://ebpf.io/) comme remplacement d'iptables (même s'il existe d'autres implémentations / d'autres technos qui règles ce problème).

## Comment en est on arrivé là ?

A vrai dire, j'ai juste lu la doc et fait confiance...

> We introduced eBPF-based host-routing in Cilium 1.9 to fully bypass iptables and the upper host stack, and to achieve a faster network namespace switch compared to regular veth device operation. **This option is automatically enabled if your kernel supports it**. To validate whether your installation is running with eBPF host-routing, run cilium status in any of the Cilium pods and look for the line reporting the status for "Host Routing" which should state "BPF".

Grosso modo, [selon la doc officielle, si on dispose du kernel correct et des modules qui vont bien](https://docs.cilium.io/en/stable/operations/system_requirements/), l'installation de cilium est censée activer automatiquement le mode eBPF... Sauf qu'on voit bien un peu plus haut que ce n'est pas le cas, malgré un kernel récent (6.2).

En creusant un peu plus les logs, voilà ce qu'on peut trouver :

```bash
kubectl -n cilium logs cilium-7b5cp
[...]
level=info msg="BPF host routing requires enable-bpf-masquerade. Falling back to legacy host routing (enable-host-legacy-routing=true)." subsys=daemon
```

Bon... visiblement, il manque une option dans la chart Helm.

```diff
[...]
  kubeProxyReplacement: strict
+ bpf:
+  masquerade: true
[...]
```

Problem solved, fin de l'article ?

## Problème

Alors oui, forcément, on peut modifier la chart comme un⋅e bourrin⋅e et fin de l'histoire.

Mais admettons qu'on ait pas envie de couper le trafic de production... Comment on fait ?

La solution la plus clean qui me vient en tête est la suivante : 
* on `drain` un node
* on lui change sa configuration
* on l'`uncordon` pour lui remettre un peu de trafic dessus
* on vérifie que la nouvelle configuration fonctionne 
ET
* on vérifie que les nodes peuvent se parler entre eux entre ceux en `iptables` et ceux en `eBPF`

Bah oui, ça serait dommage d'avoir la moitié du cluster qui peut pas communiquer avec l'autre moitié...

## Vérifier la connectivité

Ce qui est cool avec cilium (je vous ai déjà dit que j'aime cilium ?), c'est qu'on a déjà du tooling pour tout tester.

La CLI cilium dispose d'une sous commande `cilium connectivity test` qui lance des dizaines de tests internes/externes pour tester que tout est OK.

```bash
➜  ~ cilium -n cilium connectivity test
ℹ️  Monitor aggregation detected, will skip some flow validation steps
✨ [node] Deploying echo-same-node service...
✨ [node] Deploying DNS test server configmap...
✨ [node] Deploying same-node deployment...
✨ [node] Deploying client deployment...
[...]
✅ All 32 tests (265 actions) successful, 2 tests skipped, 0 scenarios skipped.
```

Il existe aussi une commande `cilium-health`, embarquée dans le container cilium-agent, qui permet de remonter des statistiques périodiques de latences entre tous les nodes du cluster. Utile !

```bash
kubectl -n cilium exec -it cilium-ccccc -c cilium-agent -- cilium-health status
Probe time:   2023-09-12T14:47:03Z
Nodes:
  node-02 (localhost):
    Host connectivity to 172.31.0.152:
      ICMP to stack:   OK, RTT=860.424µs
      HTTP to agent:   OK, RTT=110.142µs
    Endpoint connectivity to 10.0.2.56:
      ICMP to stack:   OK, RTT=783.861µs
      HTTP to agent:   OK, RTT=256.419µs
  node-01:
    Host connectivity to 172.31.0.151:
      ICMP to stack:   OK, RTT=813.324µs
      HTTP to agent:   OK, RTT=553.445µs
    Endpoint connectivity to 10.0.1.53:
      ICMP to stack:   OK, RTT=865.976µs
      HTTP to agent:   OK, RTT=3.440655ms
[...]
```

Et enfin, on peut juste regarder la commande `cilium status` qui nous dit qui est "reachable" (là encore, dans le container cilium-agent)

```bash
➜  kubectl -n cilium exec -ti cilium-ddddd -- cilium status
[...]
Host Routing:            Legacy
Masquerading:            IPTables [IPv4: Enabled, IPv6: Disabled]
[...]
Cluster health:          5/5 reachable   (2023-09-14T12:01:51Z)
```

## Changer la configuration d'un node

On a de la chance, car, depuis la version 1.13 de cilium (la dernière en date est la 1.14), il est possible d'appliquer des configurations différentes pour un sous ensemble de nodes (documentation officielle du [Per-node configuration](https://docs.cilium.io/en/stable/configuration/per-node-config/#per-node-configuration)).

Note : avant ça, c'était quand même possible, *de manière temporaire*, en éditant la ConfigMap de cilium à la main, puis en redémarrant les pods concernés pour prise en compte.

Il existe maintenant une CRD pour le faire, qui s'appelle **CiliumNodeConfig**. Les seules choses qu'on a à faire, c'est ajouter un label sur un node (io.cilium.enable-ebpf: "true") et ajouter le manifest suivant sur notre cluster :

```bash
cat > cilium-fix.yaml << EOF
apiVersion: cilium.io/v2alpha1
kind: CiliumNodeConfig
metadata:
  namespace: cilium
  name: cilium-switch-from-iptables-ebpf
spec:
  nodeSelector:
    matchLabels:
      io.cilium.enable-ebpf: "true"
  defaults:
    enable-bpf-masquerade: "true"
EOF

kubectl apply -f cilium-fix.yaml

kubectl label node node-05 --overwrite 'io.cilium.enable-ebpf=true'
```

Si jamais on est en production, le plus propre est donc de `kubectl drain` le Node préalablement.

Par curiosité, j'ai quand même essayé de le faire "à chaud", pour le fun.

J'ai déployé un daemonset contenant [une app en V(lang) qui répond simplement le nom du container dans une page web](https://github.com/zwindler/vhelloworld) :

```yaml
cat > vhelloworld-daemonset.yaml << EOF
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: vhelloworld-daemonset
spec:
  selector:
    matchLabels:
      app: vhelloworld
  template:
    metadata:
      labels:
        app: vhelloworld
    spec:
      containers:
      - name: vhelloworld
        image: zwindler/vhelloworld:latest
        ports:
        - containerPort: 8081
        imagePullPolicy: Always
EOF

kubectl apply -f vhelloworld-daemonset.yaml
```

```bash
kubectl get pods -o wide
NAME                               READY   STATUS    RESTARTS   AGE     IP           NODE                 NOMINATED NODE   READINESS GATES
vhelloworld-daemonset-q4h44   1/1     Running   0          3m31s   10.0.4.87   nodekube-05   <none>           <none>
vhelloworld-daemonset-w97pv   1/1     Running   0          3m31s   10.0.3.85   nodekube-04   <none>           <none>
```

Puis j'ai créé des containers contenant un shell et `curl` pour vérifier périodiquement et depuis plusieurs nodes que les containers sont bien accessibles :

```bash
kubectl run -it --image curlimages/curl:latest curler -- /bin/sh
If you don't see a command prompt, try pressing enter.
~ $ curl http://10.0.4.87:8081
hello from vhelloworld-daemonset-g2zdw
~ $ curl http://10.0.3.85:8081
hello from vhelloworld-daemonset-65k2n

~ $ while true; do 
  date
  curl http://10.0.4.87:8081
  curl http://10.0.3.85:8081
  echo
  sleep 1
done

```

Une fois le label appliqué sur un node, son pod cilium tué (via un `kubectl delete`), les pods sont restés accessibles

```bash
Fri Sep 15 14:05:34 UTC 2023
hello from vhelloworld-daemonset-g2zdw
hello from vhelloworld-daemonset-65k2n

Fri Sep 15 14:05:35 UTC 2023
hello from vhelloworld-daemonset-g2zdw
hello from vhelloworld-daemonset-65k2n

Fri Sep 15 14:05:36 UTC 2023
hello from vhelloworld-daemonset-g2zdw
hello from vhelloworld-daemonset-65k2n
```

A un moment donné, cilium a redémarré, remarqué la présence de pods existants, et pris le relais avec eBPF !

```bash
evel=info msg="Rewrote endpoint BPF program" containerID=8b7be1b032 datapathPolicyRevision=0 desiredPolicyRevision=1 endpointID=1018 identity=4773 ipv4=10.0.3.85 ipv6= k8sPodName=default/vhelloworld-daemonset-w97pv subsys=endpoint
level=info msg="Restored endpoint" endpointID=1018 ipAddr="[10.0.3.85 ]" subsys=endpoint
```

## Ca fonctionne, mais est ce que c'est mieux en termes de consommation de ressources ?

Ca, c'était **la** bonne nouvelle. Je m'attendais à des gains car le cluster était vraiment pas loin de souffrir.

Les containers cilium prenaient 10% des CPU de mes nodes, et plusieurs Go de RAM en mode `iptables`. Ca aurait rapidement pu monter bien plus haut, si j'avais agrandi le cluster au-delà des 50 nodes / 2000 pods.

Le passage au mode eBPF a permis de retrouver des niveaux totalement indolores (1% de CPU par node, 1-2% de RAM) par rapport aux configurations de mes machines.

Pas mal, hein ?

## Bonus

* [Un tutoriel bien velu pour migrer totalement de CNI à chaud (de flannel à cilium)](https://isovalent.com/blog/post/tutorial-migrating-to-cilium-part-1/)
