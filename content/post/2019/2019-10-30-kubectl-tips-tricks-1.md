---
title: kubectl tips and tricks n°1
authors:
  - zwindler
type: post
date: 2019-10-30T07:00:44+00:00
excerpt: Ensemble de tips and tricks rarement mis en avant pour améliorer votre productivité sur Kubernetes avec kubectl
url: /2019/10/30/kubectl-tips-tricks-1/
image: /2019/10/kubectl2.png
categories:
  - Cluster
tags:
  - astuces
  - cronjob
  - job
  - kubectl
  - kubectx
  - kubens
  - productivité
  - tips
  - tricks

---

## kubectl
  
  
Ça fait un moment que je garde sous le coudes quelques petites tips pour améliorer votre productivité via la CLI de Kubernetes kubectl.

  
Rassurez vous, je ne vais pas faire un énième article sur l’autocomplétion ou autre info triviale comme "vous savez que vous pouvez stocker plusieurs contexts dans votre kubectl ?" #shocking. (Si ce dernier point vous intéresse, [j’avais fais un article sur kubectx et kubens qui va surement vous plaire](/2018/08/28/utiliser-kubectx-kubens-pour-changer-facilement-de-context-et-de-namespace-dans-kubernetes/)).

  
Normalement, les astuces que je vais vous montrer ici ne sont pas dans la plupart des tutos que j’ai pu trouver sur le net.

  
C’est parti pour du fun avec kubectl !


## Pour les accrocs à la flèche du haut
  
  
Si, comme moi, vous faites partie de ces gens impatients qui ne peuvent pas prendre un café le temps qu’une opération se termine toute seule et que vous appuyez frénétiquement une la combinaison "flèche du haut + entrée" pour rappeler la dernière commande "kubectl get monobjetquejattendavecimpatience", ce paragraphe est pour vous.

  
Lors d’une commande de type "get" avec _kubectl_, il existe un flag "-w" qui fait... oui vous l’avez deviné... un genre de watch sur le (ou les) objet(s) que vous attendez.

  
Par exemple, dans le cas où vous souhaiteriez créer un objet _Service_ de type _LoadBalancer_ et que vous avez hâte que votre cloud provider vous assigne une IP publique, utilisez la commande suivante :

```
kubectl --context=cephk8s get svc traefik-ingress-controller --namespace kube-system -w
NAME                         TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)                      AGE
traefik-ingress-controller   LoadBalancer   10.0.21.75   <pending>     80:32347/TCP,443:30388/TCP   45s
traefik-ingress-controller   LoadBalancer   10.0.21.75   40.89.187.183   80:32347/TCP,443:30388/TCP   56s
```



Dans un premier temps, seul la première ligne _LoadBalancer_ s’affichera (tant que l’état restera à "Pending"), puis dès qu’il y aura une modification, la dernière ligne, avec l’IP publique, s’affichera.

  
C’est également pratique si vous avez des _Pods_ qui mettent du temps à s’initialiser dans un _Déploiement_ complexe.


## Relancer un job
  
  
Kubernetes, en bon orchestrateur qu’il est, est capable de lancer des tâches planifiées. C’est super pratique lorsque vous avez des tâches bien précises à réaliser mais qu’il n’y a pas de raison de laisser un container tourner H24 pour ça.

  
On a donc la notion d’objet Kubernetes _Job_ et de _Cronjob_. Sans rentrer dans les détails, le _Job_, c’est celui qui exécute la tâche (il lance un Pod qui contient un ou plusieurs containers). Le _Cronjob_, c’est une surcouche qui lance périodiquement le _Job_. Rien de bien sorcier.

  
Malheureusement pour nous, il arrive que nos Jobs échouent. Il n’y avait pas assez de ressources, ou alors on est tombé sur un bug, ou alors c’est "la faute à pas de chance".

  
Qu’à cela ne tienne, il faut que votre Job tourne aujourd’hui, vous voulez donc le relancer. Pas de chance pour vous, "by design", les _Jobs_ ne peuvent pas être relancés dans Kubernetes.

  
Jusqu’à récemment, il n’y avait pas de solution propre pour relancer un Job avec kubectl. Il fallait donc passer par un exposer du JSON du Job pour en recréer un nouveau identique en tout point. "Crude but effective" comme disent nos amis anglosaxons.


```
kubectl --context=moncontext --namespace=monnamespace get job monjob -o json | jq 'del(.spec.selector)' | jq 'del(.spec.template.metadata.labels)' | kubectl --context=moncontext --namespace=monnamespace replace --force -f -
```



Si vous voulez plus de détails sur ce que oneliner fait vraiment : la première partie dump en JSON la configuration du job, la partie du milieu retire les données spécifiques au Job qui a échoué (autogénéré à la création du Job) et la dernière partie réinjecte le job dans Kubernetes, ce qui a pour effet de le relancer.

  
Pas mal hein ?

  
Mais... si vous avez une version plus récente, vous avez de la chance, cette option est maintenant disponible par défaut dans _kubectl_, vous permettant de créer de manière unitaire un _Job_ à partir d’un template contenu dans un _Cronjob_, ce qui revient au même.


```
kubectl --context=moncontext --namespace=monnamespace create job --from=cronjob/lecronjobmaitre unnomuniquepourlejobrelancé
```



## Les selecteurs dans vos kubectl
  
  
Last but not least, il est possible de réaliser des opérations sur plusieurs objets d’un même type en même temps.

  
La manière la plus simple de le faire est simplement d’ajouter les noms de tous les objets à la fin de votre commande. Par exemple, la commande suivante va supprimer les _Pods_ pod1, pod2 et pod1000 :


```
kubectl --context=moncontexte --namespace==monnamespace delete pods pod1 pod2 pod1000
```



Cependant, on va rarement supprimer des pods (ou autre objet) au hasard. Généralement, on va vouloir supprimer tous les pods d’un même déploiement, ou alors supprimer tous les objets de la même applications, ou encore scaler tous les déploiements d’un même client.

  
Dans tous les cas, si vous avez bien fait votre travail, tous ces objets Kubernetes auront tous les labels cohérents les uns avec les autres. En partant du principe que les pods de l’exemple précédents ont tous le label app=blopiblop, je peux donc exécuter la commande suivante pour gagner du temps :


```
kubectl --context=moncontexte --namespace==monnamespace delete pods --selector=app=blopiblop
```



Attention à ne pas vous tromper dans les labels, c’est très puissant ;-)
