---
title: Mettre à jour le CA de Kubernetes, « the hard way »
authors:
  - zwindler
type: post
date: 2021-02-15T07:56:12+00:00
excerpt: "REX et procédure pour la mise à jour d'un CA dans kubernetes sur le point d'expirer"
url: /2021/02/15/mettre-a-jour-le-ca-de-kubernetes-the-hard-way/
image: /2021/02/yougetacert.jpeg
categories:
  - Cluster
  - Virtualisation
tags:
  - CA
  - Certificate Authority
  - etcd
  - flannel
  - hard way
  - kubectl
  - Kubernetes

---
## Les CA (Certificate Authority), ça expire !

Dans cet article, je vais vous ferai un petit retour d’expérience d’un souci un peu tricky que j’ai rencontré il y a quelques mois. 

Cela concerne des clusters Kubernetes, la Certificate Authority (CA), un Vault (Hashicorp) et le tout dans un contexte opérationnel, en production, avec des millions d’utilisateurs.

Attachez vos ceintures, ça risque de secouer :)

## The « automated » hard way

J’ai récemment changé de boite. 

Dans ce nouveau contexte technique, Kubernetes est en production depuis plusieurs années. Aujourd’hui, il existe de très nombreuses options pour déployer un cluster Kubernetes (j’en ai déjà abondamment parlé [ici](/2020/10/26/kubernetes-avec-rancheros-et-rke-partie-1/), [là](/2019/07/09/jai-teste-pour-vous-loffre-kubernetes-as-a-service-dovh/), [là](/2019/03/21/deployer-en-5-minutes-un-cluster-kubernetes-sur-arm-avec-k3s-et-ansible/), [là](/2017/12/05/installer-kubernetes-kubespray-ansible/) ou encore [là](/2018/12/18/jai-teste-pour-vous-aks-la-plateforme-kubernetes-managee-dazure/)). Chaque a ses avantages et ses inconvénients, qui dépendent de la topologie du cluster ainsi que de vos besoins (vous êtes plutôt cloud, baremetal, edge,...).

Plot twist : Vous l’avez peut-être deviné, le titre de l’article est une référence au célèbre [“Kubernetes the hard way”][1] de Kelsey Hightower.

La raison pour laquelle j’ai choisi ce titre est que, en 2017, les clusters Kubernetes de l’entreprise dans laquelle je travaille ont été déployés avec des playbooks Ansible écrits à la main. Et d’un point de vue extérieur, ça ressemble un peu à automatiser « Kubernetes the hard way » avec Ansible &#x1f609;.

Aujourd’hui, vous (je) le feriez pas comme ça. Mais il faut se replacer dans le contexte. Au moment où le cluster a été déployé, les options étaient bien plus limitées qu’aujourd’hui en termes de déploiements. Particulièrement pour les installations de type baremetal. [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/) par exemple, maintenant GA, affichait encore des gros messages d’avertissement « **NOT PRODUCTION READY**« .

## It’s the final countdown

Toutes nos applications ne sont pas hébergées dans Kubernetes, mais une portion relativement significative d’entre elles y sont. Suffisamment en tout cas pour que si le cluster Kubernetes était down, nos utilisateurs finaux finiraient pas d’en rendre compte. Et c’est là où notre histoire commence :

> L’autorité de certification de notre Kubernetes va expirer dans quelques mois, et avec elle, toute la chaîne de certifications
>
> Un zwindler un peu inquiet
Pour illustrer un peu mon propos, imaginez qu’à la place de ces indicateurs verts rassurants, il y avait du orange (rouge ?) partout.


![](/2021/02/certs_expiration.png)

Comme toutes les communications à l’intérieur du cluster Kubernetes sont chiffrées et authentifiées avec ce CA, le laisser expirer serait une très mauvaise idée. En gros, on perdrait le contrôle du cluster et de toutes les applications hébergées dedans &#x1f631;. Si vous faites des petites recherches sur Internet, vous trouverez peut-être des postmortem de ce genre de souci (je vous en mets un en fin d’article).

Donc, j’avais pour mission de trouver un moment de renouveler le certificat, sans interruption pour les utilisateurs de notre service, et AVANT la date d’expiration.

## Pourquoi est ce que c’est un problème ?

Renouveler un certificat, ce n’est pas la mer à boire. Cependant, ici, comme le CA est responsable de toutes les communications des composants internes de Kubernetes, c’est un peu moins trivial.

Pour rendre les choses encore plus complexe, la documentation officielle est incomplète (et même fausse, j’ai fait une PR et il faudrait probablement en faire d’autre) et les documentations externes sont parcellaires.

Il y a plein de raisons pour ça. La première est que beaucoup d’organisations préfèrent utiliser Kubernetes via une offre managée chez leur cloud provider préféré, qui leur cache la complexité de la gestion du cluster Kubernetes pour eux. Dans ce cas-là, les clouds providers sont ceux qui s’inquiètent de ce genre de problématiques (mais s’y inquiètent ils ?).

Parmi les utilisateurs restants (on-prem donc), la plupart utilisent les outils comme Kubespray ou kubeadm, qui contiennent dans une certaine mesures des outils pour faciliter les procédures de renouvellement de certificats (mais qui n’étaient pas disponibles au moment où les clusters ont été déployés).

Enfin, pour les rares damnés qui restent, régénérer un CA à la main n’est pas quelque chose qu’on fait souvent. Les CAs sont généralement générés pour des durées allant de 3 à 10 ans (même si les bonnes pratiques préfèrent des durées courtes). Si on compare cette durée moyenne par rapport à l’adoption relativement récente de Kubernetes (un projet vieux de seulement 6 ans), on peut supposer que beaucoup de CA n’ont pas encore eu l’occasion d’expirer ;-).

## Et maintenant ? Que vais-je faire ?

On doit donc trouver un moyen de modifier le CA de Kubernetes à la volée sans impact utilisateur. Heureusement, avec un peu de planification, ça devrait être possible pour la grande majorité des workloads.

La première chose à savoir est que, même si le cluster ne répond plus pendant qu’on renouvelle les certificats, les applications qui sont dans Kubernetes (les _Pods_) qui sont déjà déployés sont toujours opérationnels. Cependant, les nouveaux _Jobs_ ne seront pas démarrés, les _Pods_ en erreur ou les applications sur des nœuds HS ne seront pas redémarrés sur des nœuds en bonne santé.

La seconde chose à savoir est que toutes vos applications (dans les _Pods_) sont exécutées avec un contexte de sécurité qui dépend d’un _ServiceAccount_. Si vous n’en spécifiez pas dans le manifeste de l’application, vous hériterez par défaut de celui du _Namespace_ (d’ailleurs, pour information, ça peut être un problème de sécurité). 

Là où les choses se compliquent, c’est que le token qui authentifie ce _ServiceAccount_ est généré par le _Kubernetes Controller Manager_. Et pas de bol, quand vous générez le CA, tous les tokens sont bons à jeter à la poubelle...

Donc... Le but du jeu va être de ne redémarrer que ce qui est nécessaire, dans le bon ordre, puis de régénérer tous les tokens. Et tout ça, suffisamment vite pour qu’aucune application ne plante ou qu’un _Node_ tombe en panne pendant l’opération.

> Easy peasy

## MAIS !

Car bien sûr, il y a un mais car sinon ça serait trop facile :

  * Les applications qui ont besoin de communiquer avec l’API de Kubernetes seront perturbées dans leur fonctionnement tant qu’elles n’auront pas été redémarrées (une fois leur token régénéré). Cela inclus probablement vos applications de supervision (comme Prometheus) qui scrap l’API. Vous serez « aveugles » pendant quelques minutes.
  * Les applications qui maintiennent des connexions longues (typiquement des WebSockets par exemple) seront probablement coupées à un moment donné car vous devrez probablement redémarrer vos _IngressControllers_, qui ont souvent besoin d’accéder à l’API server (cf point précédent). Si vous avez implémenté un mécanisme de retry dans vos applications, ça devrait aller.
  * Toutes les applications devront à un moment donné être redémarrées pour obtenir leur nouveau token. Si vos applications n’ont pas de replicas (1 seul _Pod_), il y aura nécessairement une coupure. Pour éviter ça (et c’est valable pour tous les contextes, pas seulement quand on renouvelle des certificats) essayez de toujours avoir des replicas pour toutes vos applications. Dans le cas présent, si ces applications n’ont pas besoins d’accéder à l’API de Kubernetes, vous pouvez reporter le redémarrage à plus tard.

Maintenant vous savez tout, allons y &#x1f60a; !

## Okééééé. On renouvelle un CA dans Kubernetes, en prod, sans interruption (visible)

Avant de faire quoique ce soit qu’on pourrait regretter, le mieux est quand même d’être certain qu’on est capable de revenir à l’état initial au cas où on devrait rollback. Cela signifie des sauvegardes et surtout tester les procédures de restauration !

Sauvegardez tous les certificats que vous utilisez actuellement (probablement dans _/etc/kubernetes_, mais aussi dans _/var/lib/kubelet_) ainsi que ceux d’_etcd_.

```
CURDATE=`date +"%y%m%d%H%M"`
tar czf /tmp/pkibackup.${CURDATE}.tgz /var/lib/kubelet/pki/kubelet.* /etc/kubernetes
```


Vous allez probablement vouloir aussi sauvegarder tous vos tokens actuels (dans vos _ServiceAccounts_). Je rappelle que ces tokens sont générés par le _Kubernetes Controller Manager_ et qu’ils sont utilisés par les _Pods_ pour communiquer avec l’API server de Kubernetes (mais on y reviendra).

```
for namespace in $(kubectl get ns --no-headers | awk '{print $1}'); do
  for token in $(kubectl get secrets --namespace "$namespace" --field-selector type=kubernetes.io/service-account-token -o name); do
    kubectl get $token --namespace "$namespace" -o yaml >> /tmp/token_dump.${CURDATE}.yaml
  done
done
```


Et enfin, faire une sauvegarde complète de l’état du cluster via un dump de la base _etcd_ est probablement une bonne idée aussi (if all else fail comme on dit).

```
ETCDCTL_API=3 etcdctl --cacert=yourca.pem --cert=etcd.pem --key=etcd-key.pem --endpoints 127.0.0.1:2379 snapshot save /tmp/etcd.backup.$(date +'\%Y\%m\%d_\%H\%M\%S')
```

## Hashicorp Vault ?

Historiquement, les certificats avaient été générés à l’aide de la commande openssl, en se basant sur les recommandations officielles de la documentation de Kubernetes.

Ça fonctionne parfaitement bien (la documentation met plutôt en avant l’outil cfssl aujourd’hui, mais c’est le même principe). Cependant, cette façon de faire n’est ni efficace, ni vraiment safe (la clé privée du CA est stockée sur disque) et est également un facteur d’erreur humaine.

Parallèlement à ça, nous utilisons depuis plusieurs années [l’outil Vault de Hashicorp](https://www.vaultproject.io/) pour stocker nos secrets. Nous avons donc profité de l’opportunité offerte par ce renouvellement pour utiliser le module « pki » d’Hashicorp Vault.

Dans cet article, je ne rentrerai pas dans les détails de Vault et de son moteur PKI (j’ai fait [quelques articles sur les produits Hashicorp en revanche](/recherche/?keyword=hashicorp)), mais grosso modo l’idée est :

  * créer un nouveau « secret engine »
  * générer un CA qui sera gardé au chaud dans Vault
  * configurer un rôle permettant de paramétrer les futurs certificats pour correspondre aux recommandations de Kubernetes
  * générer les certificats et les déposer sur les serveurs

```
vault policy write pki-policy pki-policy.hcl
vault secrets enable -path=pki_k8s pki
vault secrets tune -max-lease-ttl=43800h pki_k8s
vault write pki_k8s/root/generate/internal common_name="kubernetes-ca" ttl=43800h
vault write pki_k8s/roles/kubernetes allowed_domains="kubernetes, default, svc, example.org" allow_subdomains=true allow_bare_domains=true max_ttl="43800h"
```

## Certs for everyone

![](/2021/02/yougetacert.jpeg)

Pour déposer de manière sécurisée et automatisée les certificats, on utilise un autre outil d’Hashicorp (décidémment) qui s’appelle [consul-template](https://github.com/hashicorp/consul-template). Ce binaire va nous permettre de générer des fichiers à partir de fichiers _templates_ et des objets qu’on a stockés dans Vault (et Consul).

Là encore, sans rentrer dans les détails, un template va ressembler à ça (je vous prends l’exemple du certificat pour l’API server) :

```
{{- /* apiserver-cert.tpl */ -}}
{{ with secret "pki_k8s/issue/kubernetes" "common_name=kube-apiserver" "alt_names=kubernetes, kubernetes.default, kubernetes.default.svc, kubernetes.default.svc.kubernetes, example.org" "ip_sans=100.64.0.1, IP.ADDRESS.MASTER.1, IP.ADDRESS.MASTER.2, IP.ADDRESS.MASTER.3" "exclude_cn_from_sans=true" "ttl=17520h" }}
{{ .Data.certificate }}{{ end}}
```


Le fichier de configuration de _consul-template_ ressemblera lui à ça :

```
template {
  source      = "/etc/consul.d/templates/ca.pem.tpl"
  destination = "/etc/kubernetes/pki/ca.pem"
}
template {
  source      = "/etc/consul.d/templates/admin-cert.tpl"
  destination = "/etc/kubernetes/pki/admin.pem"
}
template {
  blah blah blah
...
```


On lancera la commande suivante, qui remplacera d’un coup tous les anciens certificats par de nouveaux qui respectent les besoins de notre cluster et qui sont validé par notre nouveau CA :

```
consul-template -config /etc/consul.d/templates/consul-template-config-master.hcl
```


Petit bémol, cette solution ne marche pas pour tous les certificats. A chaque appel de consul-template, un nouveau certificat est produit. Pour tous les certificats individuels, comme les certificats pour chaque node, cela fonctionne très bien. Cependant, ce n’est pas vrai pour certains, par exemple pour la clé privée de l’API server qui nécessite d’être la même pour tous les serveurs. Nous avons donc fait une exception dans notre processus : tous les certificats nécessaires pour les masters ont été générés pour un seul serveur puis copiés sur les autres masters.

## Ground control to Major Tom

Tous les certificats sont maintenant régénérés. Mais pour autant, tous les composants de Kubernetes ne supportent pas le renouvellement de certificats à chaud. On va devoir tout redémarrer (et dans le bon ordre, en plus...).

La première urgence est de redémarrer les serveurs _etcd_, tous en même temps. Une fois que c’est fait, la course commence car l’API server ne sera plus capable d’interroger etcd pour connaître (et mettre à jour) l’état du cluster. Nous avons perdu tout contrôle sur notre cluster &#x1f631;.

```
systemctl restart etcd
```


A partir de maintenant, toutes les commandes kubectl vont échouer. Toutes les fonctionnalités de Kubernetes (autoscaling, scheduling des pods, etc) vont arrêter de fonctionner. 

Cela va heureusement facilement se régler, simplement en redémarrant l’_api-server_ manuellement (soit via le service _systemd_ soit, si c’est un _Pod_, envoyer un SIGKILL).

On peut ensuite s’attaquer au reste des composants du control plane qui nécessitent _etcd_ ou l’API server.

Je vous conseille de commencer par le CNI (comme _flannel_ par exemple), puis de supprimer la paire de certificats de vos _kubelet_ (ils seront régénérés automatiquement) avant de les redémarrer, sur tous les _Nodes_.

```
rm /var/lib/kubelet/pki/kubelet.{crt,key}
systemctl restart kubelet
```

  Et pour finir, on peut redémarrer tous les composants du control plane restant avec des commandes _kubectl_ depuis un master (ça devrait remarcher).

```
/usr/bin/kubectl --namespace kube-system delete pods --selector component=kube-apiserver
/usr/bin/kubectl --namespace kube-system delete pods --selector component=kube-controller-manager
/usr/bin/kubectl --namespace kube-system delete pods --selector component=kube-scheduler
```

Notre control plane est de nouveau opérationnel &#x1f389;.

## The tokens sleep tonight

Maintenant que notre control plane fonctionne avec nos nouveaux certificats, si vous regardez ce qui se passe dans les logs de l’API server, vous remarquerez qu’il y aura beaucoup de messages pas super explicites à propos de tokens pourris.

Si vous vous souvenez bien, on avait dit qu’il allait falloir rafraîchir tous nos tokens, qui sont tous invalidés depuis qu’on a redémarré l’API server. Cette partie est heureusement gérée par le _Kubernetes Controller Manager_ mais il va falloir lui donner un petit coup de pouce : on va supprimer les tokens contenus dans les _Secrets_ de type _service-account-token_ relatifs à chaque _ServiceAccount_ grâce à cette boucle :

```
for ns in `kubectl get ns | grep Active | awk '{ print $1 }'`; do
  for token in `/usr/bin/kubectl get secrets --namespace $ns --field-selector type=kubernetes.io/service-account-token -o name`; do
    /usr/bin/kubectl get $token --namespace $ns -o yaml | /bin/sed '/token: /d' | /usr/bin/kubectl replace -f - ;
  done
done
```

Et nous pouvons donc commencer à redémarrer nos applications.

## Now, the applications

Je vous conseille de redémarrer _coredns_ en premier (ou _kubedns_, selon votre installation). Sans ça, la résolution de nom à l’intérieur de votre cluster Kubernetes va commencer à échouer (et ça, ça craint).

```
/usr/bin/kubectl --namespace kube-system rollout restart deployment.apps/coredns
```


Mais vous devriez aussi redémarrer tous les applications qui vous semblent importantes pour le fonctionnement du cluster, comme notamment (mais pas uniquement) :

  * _kube-proxy_
  * les _Ingress controllers_
  * _prometheus_
  * toute autre application de monitoring

Enfin, redémarrer toutes les applications qui nécessitent un accès à l’API server pour fonctionner correctement. Pour les autres, vous avez le temps de le faire plus tard.

## Wrapping this up

Le CA de votre cluster Kubernetes a été renouvelé. Vous devriez pouvoir de nouveau dormir tranquilles pour quelques mois &#x1f60a;.

Renouveler vos CA n’est pas une tâche triviale dans Kubernetes, mais j’espère vous avoir montré que ce n’est pas impossible et que dans la plupart des cas et en le planifiant bien, il est possible de le faire sans interruption.

Toutes les tâches décrites dans cet article ont été automatisées dans des playbooks Ansible, que nous avons joué sur des environnements moins critiques autant de fois que nécessaire jusqu’à ce que nous ayons été sûr de leur exécution.

En décembre dernier, l’intervention a été planifiée sur les clusters de production. Toute la procédure a été jouée en quelques minutes, aucun impact utilisateur n’a été détecté et les services qui nécessitaient un accès à l’API n’ont pas été perturbées plus que prévu.

![](/2021/02/iloveit.jpg)

## Sources

  * [Github — Kelsey Hightower’s “Kubernetes the hard way”][3]

Postmortems d’expiration de certificats CA

  * [Vadosware — 2019–12 K8s certificate expiration outage][4]

Construire et détruire des clusters Kubernetes à la volée

  * [Youtube — Continuously Deliver your Kubernetes Infrastructure — Mikkel Larsen, Zalando SE][5]

Documentation officielle de Kubernetes a propos des certificats

  * [Kubernetes — Single Root CA best practices][6]
  * [Kubernetes — Manual rotation of CA certificates][7]
  * [Kubeadm — Manual certificate renewal][8]

Hashicorp Vault

  * Hashicorp — Build Your Own Certificate Authority (CA) (lien mort)
  * [Hashicorp Vault — PKI Secrets Engine (API)][10]
  * [Digital Ocean — Using Vault as a Certificate Authority for Kubernetes][11]
  * [Youtube — Streamline Certificate Management][12]

 [1]: https://github.com/kelseyhightower/kubernetes-the-hard-way
 [3]: https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md
 [4]: https://vadosware.io/post/2019-12-k8s-cert-expiration-outage/
 [5]: https://www.youtube.com/watch?v=1xHmCrd8Qn8
 [6]: https://kubernetes.io/docs/setup/best-practices/certificates/#single-root-ca
 [7]: https://kubernetes.io/docs/tasks/tls/manual-rotation-of-ca-certificates/
 [8]: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/#manual-certificate-renewal
 [10]: https://www.vaultproject.io/api-docs/secret/pki#allow_subdomains
 [11]: https://www.digitalocean.com/blog/vault-and-kubernetes/
 [12]: https://www.youtube.com/watch?v=k8FXTeFCp90&feature=youtu.be
