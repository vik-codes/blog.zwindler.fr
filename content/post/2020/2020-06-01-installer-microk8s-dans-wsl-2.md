---
title: Installer Microk8s dans WSL 2
authors:
  - zwindler
type: post
date: 2020-06-01T06:25:00+00:00
excerpt: Tutoriel pas à pas pour installer Microk8s dans Windows 10 sans passer par une VM Virtual Box ou Hyper-V, via WSL 2
url: /2020/06/01/installer-microk8s-dans-wsl-2/
image: /2020/05/external-content.duckduckgo.com_.png
categories:
  - Système
  - Virtualisation
tags:
  - hyper-v
  - k8s
  - Kubernetes
  - MicroK8s
  - minikube
  - virtualbox
  - Windows 10
  - WSL
  - WSL2

---

## Microk8s sur Windows 10
  
  
Dans un article que je vais bientôt sortir sur OPA et Gatekeeper, j’ai épuisé mon crédit mensuel et mon cluster AKS s’est éteint... "Qu’à cela ne tienne" me dis-je, "je vais installer Kubernetes dans mon Windows" ! Mais plutôt que de partir sur Microk8s (le titre de l’article, vous l’aurez noté), je suis initialement parti sur Minikube...

Ce n’est pas la première fois que je ~~fais du~~ me prend la tête avec Kubernetes dans un Windows 10, notamment avec Minikube.

* [Installer Minikube sur Windows 10 et Hyper-V - part 1](/2018/09/12/installer-minikube-sur-windows-10-et-hyper-v-part-1/)


Pour rappel, Minikube utilise une VM (bah oui, Docker partage le kernel et j’ai pas envie de faire des containers avec celui de Windows). Par défaut sous Windows, cette VM c’est via Virtual Box.

Et si vous utilisez Hyper-V à côté (au hasard, Docker pour windows) et ben vous aurez un conflit car Windows/Hyper-V interdit les autres logiciels de virtualisation quand il est activé. Me demandez pas pourquoi, c’est comme ça.

Bref, c’est relou.

## En fait, les VMs tout court, c’est un peu relou
  
  
Des fois, je me demande si je ne me fais pas du mal pour rien...

Mon PC pro est sous Ubuntu, mais à la maison, les habitudes ont la vie dure (je joue un peu sous Windows du coup c’est mon OS)...

Heureusement pour moi, WSL (Windows Subsystem for Linux) a pas mal évolué. Quand je suis sous Windows, j’utilise beaucoup cette fonctionnalité, car, même si c’est effectivement une VM (moins lourde qu’Hyper-V), Microsoft fait beaucoup d’efforts pour que l’expérience utilisateur se rapproche le plus possible d’une machine classique.

Du coup, plutôt que me reprendre la tête avec Hyper-V et VritualBox, je me suis demandé s’il n’était pas possible maintenant de faire tourner Kuberbetes dans WSL2.

Et je ne suis pas le seul à avoir eu l’idée comme on peut le voir [dans cette issue Github](https://github.com/kubernetes/minikube/issues/5392)!

## Les solutions disponibles
  
  
Pour l’instant, dans Ubuntu, je connais 4 façons de mettre un pseudo Kubernetes sur un PC/laptop de manière "rapide" :
  
* minikube
* microk8s (via les snaps)
* k3s
* kind (que j’ai pas encore testé)
      
  
La plus connue (pas forcément le plus simple), c’est minikube. Si vous me suivez sur Twitter, vous aurez vu que pour l’instant j’ai pas encore réussi à le faire marcher, malgré 2 méthodes différentes (driver=none et driver=docker).

![](/2020/05/minikube_twitter.png)

(Lien mort, je ne suis plus sur Twitter)


Pourtant, en théorie, c’est possible, car plusieurs témoignages dans l’issue Github et même des articles sur [ubuntu.com](https://ubuntu.com/blog/kubernetes-on-windows-with-microk8s-and-wsl-2) et [kubernetes.io](https://kubernetes.io/blog/2020/05/21/wsl-docker-kubernetes-on-the-windows-desktop/) en parlent.
J’y reviendrais donc quand je serais plus fâché ;).
Mon second plan était donc microk8s, qui est un déploiement de kube proposé par Canonical via les snaps d’Ubuntu.
C’est parti pour du fun !


![](/2020/05/rebecca.gif) 


## Prérequis
  
### WSL 2
  
  
Ici on part du principe que vous venez d’installer un Ubuntu sur votre Windows 10 avec WSL2 et que tout est correctement à jour.

Bon déjà ça commençait mal pour moi... Je pensais être sous WSL2 quand j’ai commencé l’article, mais en fait non...

Au moment de la rédaction de l’article, et comme l’explique cet [article Docker in WSL2](https://code.visualstudio.com/blogs/2020/03/02/docker-in-wsl2), WSL2 est disponible avec Windows 10 2004 (20h1). Avant, il n’est pour l’instant accessible que pour les Windows Insiders qui utilisent les versions previews.

Heureusement vous avez de la chance, depuis hier elle commence à être déployée sur tous les Windows 10 et vous allez pouvoir sauter l’étape suivante.

### 20H1 ou devenir Insider ? (oh la chance)
  
  
Si vous n’êtes toujours pas en 20H1, vous pouvez toujours faire comme moi et devenir Insider (bêta tester c’était moins sexy comme terme).

Équipez-vous d’un peu de temps libre et armez-vous de patience, vous en aurez besoin... Il faudra aussi accepter d’envoyer de la télémétrie à Microsoft (n’est pas Insider qui veut...).

On suit donc [cet article pour devenir _Insider_](https://insider.windows.com/insidersigninboth/), puis celui-ci pour [upgrader de WSL à WSL2](https://docs.microsoft.com/fr-fr/windows/wsl/install-win10).

La modification est assez pénible, demande de redémarrer plusieurs fois et d’aller télécharger soi-même le dernier kernel WSL2 [ici](https://docs.microsoft.com/fr-fr/windows/wsl/wsl2-kernel).

### Migration WSL 1 => WSL 2
  
  
La "bonne nouvelle" quand même, c’est qu’il est possible de migrer des OS WSL existants vers la nouvelle version. Si vous avez déjà une machine WSL configurée aux petits oignons, vous pourrez éviter de tout réinstaller.

Dans un Powershell (en tant qu’administrateur), exécutez la commande suivante :


```
wsl --list --verbose
  NAME      STATE           VERSION
* Ubuntu    Running         1
```


Si comme moi vous êtes en version 1, mettez à jour (et ouais, ça va prendre quelques minutes. Genre, euphémisme...).

```
wsl --set-version Ubuntu 2
La conversion est en cours. Cette opération peut prendre quelques minutes...
Pour plus d’informations sur les différences de clés avec WSL 2, visitez https://aka.ms/wsl2

#TREEEEES LONGTEMPS plus tard sur mon laptop
La conversion est terminée.

wsl --list --verbose
  NAME      STATE           VERSION
* Ubuntu    Stopped         2
```



Ok, on peut reprendre...

### Docker
  
  
Même une fois WSL2 installé, si vous essayez d’installer Docker (CE) comme si on était pas dans WSL2, vous n’allez pas rigoler...


```
sudo systemctl status docker
Failed to connect to bus: No such file or directory
```



> C’est un échec

([Pour ceux qui ne l’ont pas, c’est ici que ça se passe](https://www.dailymotion.com/video/x7vm1))

On va devoir passer par Docker desktop (ancien Docker for Windows) qui a une option pour installer Docker dans WSL2.

Allez sur [cette doc de Docker](https://docs.docker.com/docker-for-windows/wsl/), qui donne les instructions.

Une fois Docker Desktop installé (n’oubliez pas de cocher la case qui propose d’utiliser WSL2), on vous demandera de vous délogguer de Windows.

Au démarrage de la session, normalement Docker for Windows devrait vous informer qu’il a démarré. On peut vérifier que tout est bien configuré :



![](/2020/05/docker_desktop_wsl2_engine.png) 

> On utilise WSL2 comme moteur plutôt qu’hyper-V, fini les conflits avec virtualbox 

Vous pouvez retourner dans votre WSL.

Note : normalement ça ne devrait pas être nécessaire, mais si vous comme moi pour une obscure raison, n’avez pas les droits de faire du Docker, il faut ajouter à votre utilisateur WSL le groupe qui va bien.

```
votreuser@awesomelaptop:~$ sudo usermod -aG docker votreuser
exit
```



### Vérifier que maintenant Docker fonctionne correctement
  
  
Relancez WSL2, vous pouvez maintenant utiliser docker.


```
votreuser@awesomelaptop:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
votreuser@awesomelaptop:~$ docker container run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:6a65f928fb91fcfbc963f7aa6d57c8eeb426ad9a20c7ee045538ef34847f44f1
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
```



Maintenant qu’on a un Docker qui marche, on va pouvoir essayer de faire marcher Microk8s. Je préviens, il y a pas mal de bidouille, car WSL ne s’appuie pas sur systemd (contrairement à presque toutes les distribs mainstream aujourd’hui).

La procédure détaillée est disponible ici, ainsi que les scripts, dans le [post suivant](https://forum.snapcraft.io/t/running-snaps-on-wsl2-insiders-only-for-now/13033).


```
sudo apt install -y daemonize dbus-user-session fontconfig
```

* /usr/sbin/start-systemd-namespace
* /usr/sbin/enter-systemd-namespace
      
```
sudo chmod +x /usr/sbin/enter-systemd-namespace
```



Ajoutez les lignes suivantes dans les sudoers :


```
sudo vi /etc/sudoers
Defaults        env_keep += WSLPATH
Defaults        env_keep += WSLENV
Defaults        env_keep += WSL_INTEROP
Defaults        env_keep += WSL_DISTRO_NAME
Defaults        env_keep += PRE_NAMESPACE_PATH
%sudo ALL=(ALL) NOPASSWD: /usr/sbin/enter-systemd-namespace
```


Et enfin, lancez la commande suivante pour que le script s’exécute au démarrage de la session :

```
sudo sed -i 2a"# Start or enter a PID namespace in WSL2\nsource /usr/sbin/start-systemd-namespace\n" /etc/bash.bashrc
```



Lancez un nouveau WSL2 en parallèle pour voir si ça fonctionne toujours (moi la première fois, j’ai loupé une étape et flingué mon Ubuntu...).

Si ça marche toujours, on passe à l’étape suivante !

## DNS dans systemd
  
  
A priori, quand on bascule WSL2 vers systemd, on se retrouve avec des petits soucis de DNS. Le plus simple est d’ajouter en dur votre propre DNS ou un DNS qui respecte votre vie privée, du type 9.9.9.9 ([quad9](https://www.quad9.net/)).


```
sudo vi /etc/systemd/resolved.conf
[...]

[Resolve]
DNS=9.9.9.9
```



Et redémarrez resolved`. Si tout fonctionne correctement vous devriez pouvoir faire le apt update` sans erreur.


```
sudo systemctl restart systemd-resolved
sudo apt update
```



## It’s alive !
  
  
Et enfin, on tente l’installation de microk8s en lui-même, en croisant tous les doigts à notre disposition.

L’avantage de Microk8s est que la procédure d’installation est très très simple (vous pouvez la retrouver [ici](https://microk8s.io/#get-started))


```
sudo snap install microk8s --classic --channel=1.18/stable

sudo microk8s status --wait-ready
  microk8s is running
  addons:
  [...]
```



Dernier point, par défaut vous risquez de ne pas avoir les droits pour faire du microk8s avec votre utilisateur. Pour éviter de faire des sudo` à tout bout de champs, on se les rajoute, comme pour Docker :


```
sudo usermod -a -G microk8s votreuser
sudo chown -f -R votreuser ~/.kube
```



Délogguez vous puis rouvrez WSL pour prise en compte de la modification de droits.


```
microk8s.kubectl get nodes
NAME            STATUS   ROLES    AGE   VERSION
awesomelaptop   Ready    <none>   30m   v1.18.2
```

## Conclusion
  
Bravo ! Vous faites partie des valeureux qui ont maintenant Microk8s _dans_ WSL2.

Sur ce, je vais m’occuper des derniers cheveux qu’il me reste en espérant avoir la même procédure pour minikube dans quelques jours ;)
