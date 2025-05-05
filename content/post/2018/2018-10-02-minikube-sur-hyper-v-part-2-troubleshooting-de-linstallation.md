---
title: 'Minikube sur Hyper-V part 2 : troubleshooting de l’installation'
authors:
  - zwindler
type: post
date: 2018-10-02T11:45:54+00:00
url: /2018/10/02/minikube-sur-hyper-v-part-2-troubleshooting-de-linstallation/
image: /2018/09/minikube.png
categories:
  - Script
  - systeme
  - Virtualisation
tags:
  - 'attempted methods [publickey none]'
  - Chocolatey
  - Error deleting machine profile config
  - hyper-v
  - minikube
  - OpenSSH
  - PowerShell
  - starting stopped host
  - Troubleshooting
  - unable to authenticate
  - VBoxManage not found

---
## Minikube, le retour

Il y a deux semaines, j’ai fais un article sur l’installation de Minikube sur un poste Windows 10. Petite subtilité, l’article en question explique comment installer Minikube sur Hyper-V, nativement présent avec Windows 10, plutôt qu’avec Virtual Box, le choix par défaut mais qui nécessite un téléchargement et une installation complémentaire. Si vous l’avez loupé, [c’est par ici](/2018/09/12/installer-minikube-sur-windows-10-et-hyper-v-part-1/).

## Option 2 : Expectations meet life

On s’était arrêté dans l’article précédent à un monde merveilleux ou tout marche du premier coup.  
Mais, vous vous en doutez, dans la vie (et particulièrement dans l’IT), rien ne se passe jamais comme prévu.

Voilà donc un petit florilège des problèmes que vous pourriez (ou avez) rencontrer (et leur résolution !)

### VBoxManage not found

Si vous en venez à vous demander comment l’installer sur Hyper-V, c’est probablement que vous avez commencé par lancer la commande « minikube start » sans arguments... L’installeur a donc bêtement assumé que vous utilisiez Virtual Box (pourquoi ?) et vous vous retrouvez avec l’erreur suivante :

```
Error getting state for host: VBoxManage not found. Make sure VirtualBox is installed and VBoxManage is in the path.
```


Pourtant, vous avez beau forcer le start avec le flag suivant, rien y fait, ce n’est pas pris en compte.

```
--vm-driver hyperv
```

Pour trouver comment résoudre ce problème, vous pouvez jeter à œil à cette [issue sur github][2]

En réalité, une fois le premier « start » lancé, les fichiers de configuration sont générés dans **C:\users&#91;votrelogin]&#46;minikube** (et en particulier dans profiles\minikube\config.json).

Impossible d’expliquer à l’installeur que vous avez changé d’avis (oui oui...), il faut donc de supprimer tout le dossier _.minikube_ et recommencer avec les bons paramètres la prochaine fois (enfin c’est le plus simple, on va dire).

### minikube-v0.xx.x.iso: Le chemin d’accès spécifié est introuvable...

```
minikube-v0.28.1.iso: Le chemin d’accès spécifié est introuvable...
```

Ok, ça ne marche toujours pas. On passe en mode verbose pour avoir l’erreur exacte :

```
PS C:\windows\system32> minikube start --vm-driver hyperv --hyperv-virtual-switch "Primary Virtual Switch" -v=7
Starting local Kubernetes v1.10.0 cluster...
Starting VM...
[...]

[stderr =====>] :
Downloading D:\Users\zwindler\.minikub\cache\boot2docker.iso from file://D:/Users/zwindler/.minikub/cache/iso/minikube-v0.28.1.iso...
E0906 15:10:27.568262   14484 start.go:174] Error starting host: Error creating host: Error executing step: Creating VM.: open /Users/zwindler/.minikub/cache/iso/minikub-v0.28.1.iso: Le chemin d’accès spécifié est introuvable..

 Retrying.
E0906 15:10:27.873612   14484 start.go:180] Error starting host:  Error creating host: Error executing step: Creating VM.
: open /Users/zwindler/.minikube/cache/iso/minikube-v0.28.1.iso: Le chemin d’accès spécifié est introuvable.
```

Pourtant le fichier existe. Et c’est reparti pour un tour sur Github pour avoir plus de détails !

* [github.com/kubernetes/minikube/issues/1310](https://github.com/kubernetes/minikube/issues/1310)
* [github.com/kubernetes/minikube/issues/2564](https://github.com/kubernetes/minikube/issues/2564)

Ici, c’est donc tout simplement le script Minikube qui ne sait pas que vous avez un disque **D:\**... Alors qu’il vient de le déposer lui même dans **D:\** une ligne plus haut !!! La solution donc :

> you can specify the path for the .minikub directory by setting the MINIKUBE_HOME env variable

Bon en vrai la bonne syntaxe sous Windows (dans Powershell en tout cas) c’est :

```
$MINIKUBE_HOME="D:\Users\[votrelogin]\"
```


On oublie pas de nettoyer la tentative précédente avec un :

```
minikube delete
```


### FLMNH : « Error deleting machine profile config »

Si jamais en essayant de nettoyer votre environnement (pour recommencez, vous essayez un « minikube delete » et que vous vous prenez une erreur).

```
minikube delete
Deleting local Kubernetes cluster...
Machine deleted.
Error deleting machine profile config
```


Rebelotte, on supprime le dossier **D:\Users&#91;votrelogin]&#46;minikube** à la main.

### Error starting host: Error starting stopped host: exit status 1

Tout à l’air de fonctionner. Vous croyez que vous vous en êtes sortis ? Pauvres fous ;)

Au moment où tout se termine, le script vérifie que le cluster est opérationnel. Et après avoir boucler un moment : PAF !

```
Error starting host: Error starting stopped host: exit status 1
```


L’erreur n’est pas très explicite. En gros, vous êtes dans le cas où tout est bien installé, mais le curl pour vérifier que le cluster est UP échoue, pour un souci réseau. La plupart du temps, il s’agit de l’erreur suivante :

* [github.com/kubernetes/minikube/issues/1967](https://github.com/kubernetes/minikube/issues/1967)
* [github.com/kubernetes/minikube/issues/1945](https://github.com/kubernetes/minikube/issues/1945)

> After some troubleshooting and head banging, it became apparent that the external network adapter had an ethernet adapter selected that was not connected to a network. (ethernet selected, instead of the wireless adapter). Of course an IP wont be allocated on an external network if none is connected.

Vérifiez donc dans les paramètres d’Hyper-V que vous ne vous êtes pas trompé d’adaptateur réseau lors de la configuration du réseau virtuel (cf [l’article précédent](/2018/09/12/installer-minikube-sur-windows-10-et-hyper-v-part-1/)) !

![](/2018/09/minikube04.png)

### unable to authenticate, attempted methods [publickey none]

Ok, cette fois ci tout est censé être bon. Pourtant, à la fin, ça plante encore (désespoir).

```
Error dialing TCP: ssh: handshake failed: ssh: unable to authenticate, attempted methods [publickey none], no supported methods remain
```


Là je ne suis pas sûr à 100% ni de la cause, ni du fix, mais a priori, c’était un problème lié au client/serveur OpenSSH fourni par Microsoft, qui serait pourri. L’installation d’une autre version via Chocolatey semble avoir résolu le problème.

* [github.com/kubernetes/minikube/issues/2329](https://github.com/kubernetes/minikube/issues/2329)

```
PS D:\> minikube ip
172.16.25.217
```

```
choco install openssh
Chocolatey v0.10.11
Installing the following packages:
openssh
```

[2]: https://github.com/kubernetes/minikube/issues/2901
