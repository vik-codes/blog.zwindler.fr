---
title: 'Un cluster Kubernetes gratuit pour vos labs persos ! - part 2'
authors:
  - zwindler
type: post
date: 2023-05-23T18:00:00+02:00
url: /2023/05/23/cluster-kubernetes-gratuit-part2/
image: /2023/04/kubernetes_banknote.png
categories:
  - DIY
  - Virtualisation
tags:
  - Homelab
  - Kubernetes
  - Oracle Cloud
  - Wireguard
  - VPN

---

Cet article fait partie d'une suite d'articles sur l'installation d'un cluster Kubernetes sur le free tier d'Oracle Cloud Infrastructure :

* [Un cluster Kubernetes gratuit pour vos labs persos ! - part 1](/2023/04/24/cluster-kubernetes-gratuit-part1/)
* [Un cluster Kubernetes gratuit pour vos labs persos ! - part 2](/2023/05/23/cluster-kubernetes-gratuit-part2/)

L'avantage principal de ce tuto est qu'il est gratuit. L'inconvénient est que l'installation est relativement longue...

## "Résumé des épisodes précédents"

Dans l'article précédent (que vous pouvez [retrouver ici](/2023/04/24/cluster-kubernetes-gratuit-part1/)), on avait pris en main Oracle Cloud et installé `k3s` sur deux machines ARM du free tier.

A l'issue de l'article, on avait donc, pour rappel, un cluster Kubernetes fonctionnel avec un master et un worker, mais pas encore accessible ni vraiment utilisable sur Internet.

Dans cette partie, on va donc finaliser tous les petits bouts qui manquent pour avoir quelque chose de vraiment propre.

## Creuse ton tunnel

Comme je le dis juste avant, on a un cluster fonctionnel. Si je me connecte sur la machine **controlplane** et que je lance la CLI `kubectl`, je pourrais interagir avec mon cluster Kubernetes.

Cependant, il est très probable que vous vouliez accéder à votre cluster flambant neuf sans avoir à vous connecter préalablement en SSH sur votre machine (enfin moi, c'est mon cas).

Et je n'ai pas envie non plus de publier l'API server (port 6443) de mon control plane sur Internet (en soi pour du POC, c'est faisable, mais ça ne me dit rien, perso).

Je vais donc monter un VPN `wireguard` entre ma machine et mon control plane. Dans un setup plus "pro", on montera un bastion dans notre LAN privé du cloud provider pour ça. Ici, pour les besoins de l'article, je me contente de monter le peer directement entre le node **controlplane** et mon PC.

J'installe d'abord wireguard sur les deux machines, et je génère un couple clé publique/privée :

```bash
$ sudo apt install wireguard

$ sudo -i
$ cd /etc/wireguard/
$ umask 077; wg genkey | tee private.key | wg pubkey > public.key
$ exit
```

Récupérez le contenu de la clé publique de chaque machine, ainsi que leur IP publique.

Note : pour trouver rapidement l'IP publique de chez vous, vous pouvez utiliser des services comme `dig +short myip.opendns.com @resolver1.opendns.com`,  `curl http://4.ifcfg.me` ou équivalent

Ensuite, je vais créer un fichier de configuration `/etc/wireguard/oci0.conf` sur mon pc. Dans mon cas, l'interface réseau s'appelle **enp8s0**

```bash
$ sudo -i
$ PEER_IP=IP.PUBLIQUE.DU.CONTROLPLANE
$ PEER_PUBLIC_KEY=CLE.PUBLIQUE.DE.VOTRE.CONTROLPLANE
$ cat > /etc/wireguard/oci0.conf << EOF
[Interface]
Address = 10.10.10.1/24
ListenPort = 55555
PrivateKey = `cat /etc/wireguard/private.key`

[Peer]
PublicKey = ${PEER_PUBLIC_KEY}
AllowedIPs = 10.10.10.2/32,10.0.0.0/24
Endpoint = ${PEER_IP}:55555
EOF
$ exit
$ wg-quick up oci0
```

Et on fait pareil sur le node **controlplane** (son interface réseau s'appelle `enp0s6` dans mon cas).

```bash
$ sudo -i
$ PEER_IP=IP.PUBLIQUE.DU.PC
$ PEER_PUBLIC_KEY=CLE.PUBLIQUE.DE.VOTRE.PC
$ cat > /etc/wireguard/oci0.conf << EOF
[Interface]
Address = 10.10.10.2/24
ListenPort = 55555
PrivateKey = `cat /etc/wireguard/private.key`

[Peer]
PublicKey = ${PEER_PUBLIC_KEY}
AllowedIPs = 10.10.10.1/32
Endpoint = ${PEER_IP}:55555
EOF
$ exit
$ wg-quick up oci0
```

Comme les machines OCI disposent toutes d'un pare-feu `iptables` et aussi d'un pare-feu au niveau du réseau virtuel, on doit ouvrir les ports côté **controlplane**

```bash
# allow wireguard access from your own public IP address
$ iptables -I INPUT -s IP.PUBLIQUE.DU.PC -p udp --dport 55555 -j ACCEPT

# save rules
$ sudo netfilter-persistent save
```

**Et** côté console Oracle Cloud (Security list dans l'administration du VCN, [je vous renvoie au précédent post où je détaille comment faire](/2023/04/24/cluster-kubernetes-gratuit-part1/#ouverture-des-ports-internes))

![](/2023/05/VCN_udp_55555.png)

A partir de maintenant, votre PC à l'IP 10.10.10.1 et votre control plane l'IP 10.10.10.2. Les deux doivent pouvoir se pinger :

```bash
$ ping 10.10.10.1
$ ping 10.10.10.2
```

On devrait aussi pouvoir ping l'IP privée (interne) de notre **controlplane** depuis notre pc

```bash
$ ping 10.0.0.xxx
```

Si wireguard vous intéresse, il existe énormément de documentation sur Internet à ce sujet, à commencer par le [site officiel](https://www.wireguard.com/quickstart/).

## Accéder au cluster depuis votre poste

On a maintenant un tunnel pour discuter de notre PC vers notre control plane Kubernetes, mais toujours pas la possibilité de discuter avec Kubernetes. Il reste encore une règle `iptables` à ajouter 😭.

Pour s'en convaincre, on tente de voir si le port répond depuis notre PC :

```bash
$ nc -zv 10.10.10.2 6443
nc: connect to 10.10.10.2 port 6443 (tcp) failed: No route to host
$ nc -zv 10.0.0.xxx 6443
nc: connect to 10.0.0.xxx port 6443 (tcp) failed: No route to host
```

Côté **controlplane**, on va donc autoriser le traffic provenant de wireguard (interface `oci0`) à se connecter à l'API server

```bash
# allow access to apiserver from wireguard interface
$ sudo iptables -I INPUT -i oci0 -p tcp --dport 6443 -j ACCEPT

# save rules
$ sudo netfilter-persistent save
```

Et maintenant, depuis notre PC :

```bash
$ nc -zv 10.10.10.2 6443
Connection to 10.10.10.2 6443 port [tcp/*] succeeded!
$ nc -zv 10.0.0.xxx 6443
Connection to 10.0.0.34 6443 port [tcp/*] succeeded!
```

Récupérez le contenu du fichier `/etc/rancher/k3s/k3s.yaml` sur le serveur **controlplane**.
Créez un fichier `k3s.yaml` sur votre machine et remplacez la valeur `server: https://127.0.0.1:6443` par `server: https://10.10.10.2:6443`.

Vous devriez maintenant avoir accès à votre cluster depuis votre PC !

```bash
$ export KUBECONFIG=k3s.yaml
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                                      READY   STATUS      RESTARTS      AGE
kube-system   helm-install-traefik-crd-xdg7s            0/1     Completed   0             29d
kube-system   helm-install-traefik-ncqzm                0/1     Completed   1             29d
kube-system   svclb-traefik-084208f2-dcsqr              2/2     Running     0             29d
kube-system   local-path-provisioner-5d56847996-x76zx   1/1     Running     5 (29d ago)   29d
kube-system   svclb-traefik-084208f2-zw6bv              2/2     Running     7 (29d ago)   29d
kube-system   coredns-7c444649cb-gg22s                  1/1     Running     3 (29d ago)   29d
kube-system   metrics-server-7b67f64457-r5c5n           1/1     Running     5 (29d ago)   29d
kube-system   traefik-56b8c5fb5c-px5pc                  1/1     Running     3 (29d ago)   29d
```

## Ouverture des ports pour Traefik

On peut maintenant interagir avec Kubernetes, mais on ne peut toujours pas en faire grand-chose. Je suis certain que vous allez déployer des applications web sur votre cluster et c'est quand même plus cool d'y accéder *depuis* Internet :-p.

Par défaut, `k3s` installe l'IngressController `traefik`. Vous l'avez deviné... on va devoir ouvrir des flux !

Si vous regardez sur quels IPs/ports traefik est disponible sur votre cluster, vous remarquerez que Traefik utilise un service de type **LoadBalancer**, directement accessible sur l'IP privée de vos machines (10.0.0.x et 10.0.0.y dans cet exemple)

```bash
kubectl -n kube-system get svc traefik 
NAME      TYPE           CLUSTER-IP     EXTERNAL-IP            PORT(S)                      AGE
traefik   LoadBalancer   10.43.44.139   10.0.0.xxx,10.0.0.yyy   80:30614/TCP,443:30839/TCP   42m
```

Dans OCI, ça sera pratique, on va pouvoir attaquer directement le port 80/443 de nos serveurs et avoir l'IngressController au bout du fil. 

```
$ curl http://10.0.0.xxx
404 page not found
```

Ne vous laissez pas tromper par l'erreur 404. Le fait qu'on nous réponde une erreur 404 prouve que traefik répond bien !

Sur les DEUX machines (control plane ET worker), on va autoriser l'accès au port 80 depuis partout :

```
# allow access to HTTP 80 from everywhere
$ sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT

# save rules
$ sudo netfilter-persistent save
```

Mais on va probablement vouloir exposer ça sur Internet et les IP privées sont... privées. On va donc créer un load balancer en frontal, ça nous permettra de diriger le trafic sur tous les noeuds du cluster, pas juste un seul (ça ferait un SPOF en plus).

## Créer un Loadbalancer

Dans l'onglet Networking, on va sélectionner Loadbalancer ([ici](https://cloud.oracle.com/load-balancer/load-balancers?region=eu-paris-1))

![](/2023/05/oci_lb.png)

Suivez le wizard, choisissez un Load balancer (L7)

![](/2023/05/oci_lb2.png)

Puis donnez-lui un petit nom (kube-traefik-lb par exemple), laissez Public (choix par défaut), sélectionnez votre VCN et votre subnet.

Au moment de choisir les "backends", cliquez sur "Add backends" et ajoutez vos 2 machines (c'est Kubernetes et flannel qui se chargent de rediriger les requêtes au bon endroit)

![](/2023/05/oci_add_backends.png)

Laissez le port 80 par défaut, puisqu'on vient de vérifier que ces ports répondent bien à `curl http://10.0.0.xxx` (pas besoin d'utiliser le NodePort, pour ceux qui savent de quoi je parle). Laissez aussi les paramètres par défaut pour la "health check policy", SAUF pour le code retour attendu (puisque notre traefik renvoie 404 si aucun Ingress ne matche l'"host" envoyé par la requête).

![](/2023/05/oci_healthcheck.png)

Dans la page d'après dans "configure Listener", si vous avez un certificat TLS valide, vous pouvez l'intégrer au loadbalancer avec l'option "Load balancer managed certificate" dans le cadre "SSL certificate". Vous pouvez aussi [gérer les certificats depuis Oracle Cloud Infrastructure](https://cloud.oracle.com/security/certificates/certificate?region=eu-paris-1). Je n'ai pas exploré cette option mais c'est très standard chez les cloud providers.

Sinon, cliquez sur "HTTP".

Une fois le LoadBalancer créé, il devrait devenir "vert" et vous pourrez récupérer son adresse IP publique pour y accéder.

![](/2023/05/oci-lb-green.png)

## Conclusion

Vous êtes arrivés jusque-là. Bravo !

Vous pouvez déployer des applications web avec des Ingress et faire pointer vos enregistrements DNS sur l'IP du LoadBalancer. Les requêtes HTTP seront correctement routées sur un des deux serveurs Kubernetes, puis vers Traefik, puis vers votre appli.

J'ai fait le test avec une image Docker personnelle (utilisée pour mon dernier talk) et ça a marché :-\).

![](/2023/05/oci_result.png)

On a fait plus d'iptables que de Kubernetes mais bon c'est pas très grave 😅. Ca aura été une excuse pour tester le free tier d'Oracle et de tester un peu le fonctionnement de ce cloud provider assez peu connu en France (je trouve).

## Autres blogs posts utiles

* [medium.com/oracledevs - k3s-on-oci-a-kubernetes-cluster-in-under-5-mins](https://medium.com/oracledevs/k3s-on-oci-a-kubernetes-cluster-in-under-5-mins-d7c194c19d59)
* [dev.to/armiedema - opening-up-port-80-and-443-for-oracle-cloud-servers](https://dev.to/armiedema/opening-up-port-80-and-443-for-oracle-cloud-servers-j35)
* [malekal.com - utiliser-wg-quick-wireguard](https://www.malekal.com/utiliser-wg-quick-wireguard/)
