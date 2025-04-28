---
title: kubectl tips and tricks n°2
authors:
  - zwindler
type: post
date: 2020-01-20T07:30:00+00:00
excerpt: Ensemble de tips and tricks rarement mis en avant pour améliorer votre productivité sur Kubernetes avec kubectl
url: /2020/01/20/kubectl-tips-and-tricks-n2/
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
  
  
Comme vous pouvez le voir, il s’agit du 2ème article d’une série sur la productivité quand on est dans un environnement Kubernetes. Et qui dit productivité dit forcément ligne de commande, donc kubectl :trollface:!

  
Le premier article, si vous l’avez loupé, est toujours disponible ici : [kubectl tips and tricks n°1](/2019/10/30/kubectl-tips-tricks-1/). J’avais parlé du flag "wait", de comment relancer un Job ou un CronJob et de comment utiliser les _selectors_.

  
Et j’ai aussi [écris un article sur kubectx et kubens qui pourrait vous plaire](/2018/08/28/utiliser-kubectx-kubens-pour-changer-facilement-de-context-et-de-namespace-dans-kubernetes/).

  
Normalement, les astuces que je vais vous montrer ici ne sont pas dans la plupart des tutos que j’ai pu trouver sur le net. Cet article se concentre tout particulièrement sur les Secrets de Kubernetes.

  
C’est parti pour du fun avec kubectl !



## Encoder/décoder facilement en base64 les Secrets
  
  
Quelque chose qu’on a TOUT le temps à faire quand on manipule les objets de type Secrets dans Kubernetes, c’est d’afficher en clair les "secrets" contenus dans notre Secret (ou de les encoder).

  
Car, pour ceux qui ne le savent pas, les Secrets dans Kubernetes ne sont malheureusement pas très secrets, puisqu’il s’agit ni plus ni moins que des strings encodées en base64 (ce qui est donc TOUT sauf secure). A vrai dire, je me demande même pourquoi s’être embêter à les encoder tout court. La seule sécurité qu’on ajoute par rapport aux ConfigMaps, c’est simplement que la string n’est pas lisible par un humain qui passerait sa tête par dessus votre épaule.

  
Enfin bref, vous allez surement devoir encoder ou décoder des strings en base64 et c’est parfois un peu pénible. La méthode communément admise est simplement d’utiliser les binaires linux echo et base64.


```
echo "ma string" | base64
bWEgc3RyaW5nCg==

echo bWEgc3RyaW5nCg== | base64 -d
ma string
```



C’est relou à taper, mais c’est relativement trivial.

  
## It’s a trap !
  



Sauf qu’il y a des pièges !

  
Le premier vous l’aurez à l’encodage. Dans mon premier exemple, la string est très courte. Et parfois, la taille compte.


```
echo "ma string très longue string pour montrer que ça va pas le faire" | base64
bWEgc3RyaW5nIHRyw6hzIGxvbmd1ZSBzdHJpbmcgcG91ciBtb250cmVyIHF1ZSDDp2EgdmEgcGFz
IGxlIGZhaXJlCg==
```



Ici, on se retrouve avec un saut de ligne dans notre string en sortie. Mais, si vous copiez collez ça dans votre YAML Kubernetes, vous allez vous prendre une bonne grosse erreur de syntaxe.

  
Le YAML ne sera valide que si vous mettez la string complète, sur une seule ligne.

```
echo "ma string très longue string pour montrer que ça va pas le faire" | base64 -w0
bWEgc3RyaW5nIHRyw6hzIGxvbmd1ZSBzdHJpbmcgcG91ciBtb250cmVyIHF1ZSDDp2EgdmEgcGFzIGxlIGZhaXJlCg==
```



## Et c’est pas fini !
  
  
Le 2 ème piège est encore un souci de saut de ligne, mais dans la string en base64 cette fois.

  
En fait, c’est hyper traitre car vous n’allez pas le voir à l’écran de prime abord, mais il faut savoir que echo rajoute un saut de ligne à la fin de votre string. Le retour que vous avez eu en base64 contient donc un saut de ligne, qui sera quasiment systèmatiquement non souhaité lorsqu’on gère des Secrets.

  
La bonne commande n’est donc pas echo mais echo -n !


```
#Pas bien
echo "ma string" | base64
bWEgc3RyaW5nCg==

#Bien
echo -n "ma string" | base64 -w0
bWEgc3RyaW5n
```



## Ok ça commence à devenir franchement pénible...
  
  
Pour décoder heureusement, c’est plus simple. La commande donnée au début suffit, même s’il sera plus safe de rajouter le "-n" au echo :


```
echo -n bWEgc3RyaW5n | base64 -d
ma string
```



## Gagner quelques caractères
  
  
Comme je suis fainéant, j’ai cherché une astuce pour gagner quelques caractères à taper en moins. Il existe une solution, mais qui ne marche malheureusement que pour decode, puisque dans le cas de l’encodage on risquera d’ajouter un saut de ligne non souhaité :


```
echo bWEgc3RyaW5n | base64 -d

base64 -d <<< bWEgc3RyaW5n
ma string
```



On vient de s’économiser 3 caractères (waaaah) mais surtout un "|", bien plus pénible à faire sur un clavier azerty standard que 3 "<".

  
Je vous l’accorde, c’est pas foufou.



## Un peu plus simple
  
  
Heureusement, mon collègue Julien (aka JUL, car il est fan de JUL, bien entendu) nous a écris un petit script pour nous faciliter la vie, donc je vous le partage :


```
dgermain:~$ cat > b64 <<EOF 
> #!/bin/bash
> echo -e "Base64 encoding.. \n"
> for arg in "\$@"; do
>   echo "\$arg :"
>   echo -n "\$arg" | base64
>   echo
> done
> EOF
dgermain:~$ cat > b64d <<EOF 
> #!/bin/bash
> echo -e "Base64 decoding.. \n"
> for arg in "\$@"; do
>   echo "\$arg :"
>   echo -n "\$arg" | base64 -d
>   echo
> done
> EOF
dgermain:~$ sudo cp b64* /usr/local/bin/
```



Vous pouvez maintenant invoquer directement b64 suivi d’un certain nombre de strings pour avoir leur valeur encodée, ou b64d suivi d’un certain nombre de string pour les décoder.



## Dernière astuce et après j’arrête
  
  
Si jamais vous voulez à l’écran toutes les strings encodées en base64 dans un Secret Kubernetes en une seule étape, j’ai également trouvé ce [_oneliner_ pas piqué des hannetons sur Stackoverflow](https://stackoverflow.com/questions/56909180/decoding-kubernetes-secret) qui tire parti de la possibilité de faire des gotemplates directement dans kubectl :


```
kubectl get secret name-of-secret -o go-template='
{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
```



Il faudra probablement que je fasse un article entier sur le go-templating avec kubectl car c’est juste ouf ce qu’on peut faire avec ;-)
