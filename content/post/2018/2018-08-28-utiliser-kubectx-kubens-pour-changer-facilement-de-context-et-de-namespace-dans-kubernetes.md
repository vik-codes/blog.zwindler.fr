---
title: Utiliser kubectx/kubens pour changer facilement de context et de namespace dans Kubernetes
authors:
  - zwindler
type: post
date: 2018-08-28T11:45:26+00:00
url: /2018/08/28/utiliser-kubectx-kubens-pour-changer-facilement-de-context-et-de-namespace-dans-kubernetes/
image: /2017/06/kubernetes2.png
categories:
  - Script
  - Système
  - Virtualisation
tags:
  - k8s
  - kubectl
  - kubectx
  - kubens
  - Kubernetes

---
# Vous avez plusieurs clusters Kubernetes et de nombreux namespaces

Si vous avez la main sur plusieurs clusters Kubernetes, vous utilisez très probablement la commande kubectl à tour de bras. Et le moins qu’on puisse dire, c’est que switcher d’un cluster à l’autre est parfois pénible, surtout si vous avez en plus de nombreux namespaces dans chacun d’entre eux.

Pour ceux qui voudraient en savoir plus sur Kubernetes et qui voudraient monter un petit cluster rapidement, je vous renvoie sur mes [autres articles sur le sujet](/recherche/?keyword=Kubernetes); en particulier [celui sur Kubespray](/1017/11/05/installer-kubernetes-kubespray-ansible/), qui a l’avantage incommensurable d’utiliser Ansible pour déployer k8s ;-).

# Avec kubectl

Voilà ce qu’il faut faire si vous voulez naviguer de cluster en cluster et de namespace en namespace, simplement avec kubectl (en partant du principe que vos contexts sont déjà configurés).

On commence par lister les contexts. Oui je ne connais pas par coeur leur nom alors j’ai besoin de regarder comment ils s’appellent et lequel est sélectionné en ce moment.

```
kubectl config get-contexts
CURRENT   NAME               CLUSTER            AUTHINFO                     NAMESPACE
          k8s-par-prod       k8s-par-prod       k8s-par-prod-zwindler
          k8s-dub-dev        k8s-dub-dev        k8s-dub-dev-zwindler
*         k8s-par-test       k8s-par-test       k8s-par-test-zwindler
```


Ici, la petite étoile nous dit que c’est **k8s-par-test** qui est sélectionné. Pas de bol, c’est en prod que je veux faire mes modifications.

```
kubectl config use-context k8s-par-prod
Switched to context "k8s-par-prod".
```


Si je ne veux pas que le context prod soit celui par défaut (pour éviter de supprimer par erreur des pods en **prod** alors que je pense être en **dev**), il est plus prudent de spécifier explicitement à chaque fois dans quel context je me trouve

```
kubectl --context k8s-par-prod get nodes
[...]
```


Maintenant que j’ai sélectionné mon contexte, je veux lister des pods d’un namespace en particulier. Bon, le souci c’est que j’en ai beaucoup des namespaces et je ne me souviens pas toujours comment ils s’appellent. Rebelotte, je liste une nouvelle fois les objets disponibles :

```
kubectl get ns
NAME                    STATUS    AGE
kube-public             Active    361d
kube-system             Active    361d
[...]
zwindler                Active    126d
```


Ok, je me souviens que mes pods sont dans le namespace « zwindler ». Comme pour le context, je peux maintenant soit configurer un namespace par defaut, soit le nommer explicitement :

```
kubectl -n zwindler get pods
NAME                      READY     STATUS    RESTARTS   AGE
ubuntu-1111111111-aaaaa   1/1       Running   0          31d
```


A noter, si je veux spécifier le context explicitement aussi, ça commence à faire long comme lignes de commandes, juste pour un « get pods » :

```
kubectl --context k8s-par-prod -n zwindler get pods
NAME                      READY     STATUS    RESTARTS   AGE
ubuntu-1111111111-aaaaa   1/1       Running   0          31d
```


## Contourner la difficulté

Si je suis un peu bourrin, j’aurai pu afficher les pods de TOUS les namespaces avec l’option « --all-namespaces ». C’est une bonne idée si on a pas beaucoup de containers et si on ne sait plus trop dans quel namespace est notre pod. Mais clairement, au delà de 50 pods, ça devient totalement illisible.

```
kubectl get pods --all-namespaces
NAMESPACE               NAME                                                           READY     STATUS      RESTARTS   AGE
toto                    ubuntu-1111111111-aaaaa                                        1/1       Running     0          4h
[... et c'est parti pour des centaines de lignes !!!]
```


Pour se gagner du temps, il existe aussi des fichiers d’autocomplétion pour **kubectl**. Vous n’avez plus qu’à appuyer sur la touche [tab] une fois que vous avez écris « kubectl --context  » pour éviter de faire un get préalable et des copier coller le nom du contexte souhaité.

Vous trouverez des infos sur l’autocomplétion de **kubectl** sur le site officiel de Kubernetes : [kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion](https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion)

```
echo "source <(kubectl completion bash)" >> ~/.bashrc
```


Mais ça ne vous évite pas les lignes de commande à rallonge avec contexts et namespaces explicitement indiqués.

## Un petit hack simple pour se simplifier la vie

Si l’autocomplétion ne vous suffit pas, vous pouvez utiliser deux petits binaires très pratiques, disponibles sur le [dépôt Github de ahmedb][3].

Vu sur Twitter (comme quoi des fois ça sert), ces deux petits binaires **kubectx** et **kubens** permettent de configurer respectivement le **contexte** et le **namespace** par défaut. Le projet fourni même l’autocomplétion pour les shells les plus utilisés.

## Installation rapide de kubectx et kubens

Ici, rien de bien compliqué. On copie le dépôt sur son poste et on link les binaires dans un dossier du PATH, et on colle l’autocomplétion dans notre shell :

```
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
echo "source /opt/kubectx/completion/kubectx.bash" >> ~/.bashrc
echo "source /opt/kubectx/completion/kubens.bash" >> ~/.bashrc
```


Simple, non ?

## Utilisation de kubectx et kubens

```
kubectx [tab]
-                 k8s-par-prod     k8s-dub-dev      k8s-par-test
kubectx k8s-par-prod 
Switched to context "k8s-par-prod".

kubens
-                      default                blip                     blup
kube-public            kube-system            blop                     [...]
```


Pour le fun le développeur a simplifié la liste des objets et a ajouté un peu de couleur (jaune) pour indiquer quel context/namespace est sélectionné par défaut (plutôt qu’un tableau et une étoile). Peut être un peu gadget mais je ne dis pas non.

![](/2018/08/kubectx01.png)

## Et c’est tout ?

Et enfin, **kubectx** ne sert pas qu’à sélectionner le context par défaut. On peut également réaliser la plupart des commandes sur les contexts avec :

```
kubectx --help
USAGE:
  kubectx                       : list the contexts
  kubectx                 : switch to context 
  kubectx -                     : switch to the previous context
  kubectx =     : rename context  to 
  kubectx =.          : rename current-context to 
  kubectx -d  [] : delete context  ('.' for current-context)
                                  (this command won't delete the user/cluster entry
                                  that is used by the context)

  kubectx -h,--help         : show this message
```


Alors certes, ça ne va pas révolutionner votre vie, mais ça peut vous faire gagner quelques secondes dans la journée. Et si vous êtes comme moi, vous n’êtes jamais contre quelques secondes de gagnées ;)

 [3]: https://github.com/ahmetb/kubectx
