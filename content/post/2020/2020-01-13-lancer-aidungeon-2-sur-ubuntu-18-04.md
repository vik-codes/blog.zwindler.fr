---
title: Lancer AIDungeon 2 sur Ubuntu 18.04
authors:
  - zwindler
type: post
date: 2020-01-13T07:15:00+00:00
excerpt: 'Tutoriel étape par étape pour héberger soit même le jeu  AIDungeon 2 localement sur un serveur Ubuntu 18.04 vierge (et une grosse carte graphique NVidia)'
url: /2020/01/13/lancer-aidungeon-2-sur-ubuntu-18-04/
image: /2020/01/aidungeon_screen.png
categories:
  - autohebergement
  - DIY
  - Matériel
tags:
  - AIDungeon
  - AIDungeon 2
  - GPU
  - GTX
  - Machine Learning
  - OpenAI
  - tegra

---

## AIDungeon 2
  
  
Il y a quelques semaines, je suis tombé sur AIDungeon 2, un jeu hilarant qui mixe jeu d’aventure textuel, machine learning et de gros (GROS) GPUs NVidia.

Note: English speakers, I’ve released [an english version of this tutorial here](/2020/01/08/run-aidungeon-2-on-ubuntu-18-04/)


> AIDungeon2 is a first of its kind AI generated text adventure. Using a 1.5B parameter machine learning model called GPT-2 AIDungeon2 generates the story and results of your actions as you play in this virtual world. Unlike virtually every other game in existence, you are not limited by the imagination of the developer in what you can do. Any thing you can express in language can be your action and the AI dungeon master will decide how the world responds to your actions.
> https://www.aidungeon.io/

Si vous n’en avez pas encore entendu parler, il s’agit d’un projet de machine learning créé par Nick Walton. Il est basé sur [le model GPT-2 d’OpenAI](https://openai.com/blog/better-language-models/) que vous avez peut être déjà croisé dans d’autre projets fun comme celui qui permet, à partir de quelques lignes de texte, d’écrire une suite : [TalkTotransformer by Adam D King](https://talktotransformer.com/).



## Et ça fait quoi ?
  
  
C’est là où le fun commence. Comme TalkToTransformer, à partir d’un texte de départ semi aléatoire, le modèle de machine learning commence à construire une nouvelle histoire, différente à chaque fois. Et ce sont vos actions et votre imagination qui vont diriger l’histoire dans un sens ou dans l’autre.

Je ne vais pas mentir, c’est encore loin d’être parfait. Le modèle a la fâcheuse tendance à tourner en rond, ou alors à oublier ce que les personnages viennent de faire, juste une ligne plus haut. Et ça peut un peu gâcher l’histoire.

Mais... si on met de côté ces petits soucis de jeunesse, ce qui est vraiment incroyable, ce sont les possibilités qui semblent vraiment illimités. C’est vraiment très impressionnant.

Au final, ce n’est pas tellement surprenant. La seule limite du modèle, c’est le savoir et le style d’écriture d’OpenAI, qui se base sur 40 Go de texte provenant d’Internet. C’est colossal !

Si jamais vous avez besoin d’exemples concrets, je vous invite à aller faire un tour sur le Twitter de Nick Walton ou alors sur le [subreddit dédié à AIDungeon](https://www.reddit.com/r/AIDungeon/). Vous y trouverez tout type d’aventures hilarantes compilées par les joueurs.



![](/2020/01/story.png) 

> In this example, my inputs are the 2 lines preceded by the « > » symbol, the machine did the rest 


## Ok c’est cool ! Quel est le problème ?
  
  
En fait, j’en ai déjà parlé.

Le jeu, qui n’est ni plus ni moins qu’un prompt et du texte qui s’affiche, est très probablement le jeu le plus gourmand en GPU que vous avez rencontré. Quelle délicieuse ironie ;).

En réalité, le jeu nécessite actuellement près de 9 Go de VRAM GPU et un très grand nombre de coeurs CUDA pour fonctionner. Cela écarte d’office toutes les cartes AMD, ainsi que presque toutes les cartes graphiques NVidia (hormis les plus chère, à + de 1000€).

Dommage.



## La communauté
  
  
Heureusement, l’enthousiasme de la communauté pour ce jeu a motivé Nick Walton et son frère à trouver des solutions. Pendant le mois de décembre, ils ont tout plaqué (dont des exams) pour proposer une infrastructure sous AWS, ainsi qu’une application iOS, Android, et une application web pour que tout le monde puisse en profiter.

Seulement, vous vous en douter, faire tourner une infra aussi gourmande à un coût. Selon les dires de Nick, les instances AWS avec des cartes Tegra leur coûtent autour de 65000 dollars par mois. Malgré le Patreon qu’ils ont ouvert et qui a permis de récolté 15000$, on est loin du compte.

Il est probable qu’à terme, le jeu ne soit plus gratuit. Du coup, si le jeu vous plait, [je vous invite à aller voir leur Patreon !](https://www.patreon.com/AIDungeon)

## Et maintenant ?
  
La troisième raison (au delà de la prouesse technique et du côté fun) pour laquelle je me suis intéressé au projet est que Nick l’a open sourcé, dès le début.

On peut donc imaginer, si on a suffisamment de puissance sur sa machine, pouvoir le lancer soit même (et ça c’est cool).

Les sources sont disponibles [sur le compte Github AIDungeons](https://github.com/AIDungeon/AIDungeon).

Mais à partir de là, je me suis dis que ça pourrait être sympa de lancer AIDungeon 2 sur une instance GPU d’un cloud provider lambda.

Donc j’ai décidé d’essayer ;-p.

Pour mon test, j’ai donc choisi de commander une instance virtuelle NC6 (6 vcpus, 56 GiB memory, Tegra K80) de chez Microsoft Azure avec un compte de test gratuit. Mais c’est évidemment applicable à n’importe quelle machine, physique ou chez un autre provider, que vous auriez à votre disposition. Il faut juste qu’elle soit équipée d’une GTX 1080 Ti, GTX 2080 Ti, GTX 2080ti super ou équivalent pro.

Ce type de machine coute, selon les datacenters (mais ça nous importe peu ici) environ 43 centime d’euro de l’heure. On peut même descendre à 0,21€ en utilisant des VMs préemptibles. Du coup, même sans avoir un compte d’essai, ça ne reviendra pas très cher si vous ne faites que l’essayer.

Sur ma NC6, j’ai déployé un basique Ubuntu 18.04 et c’est là que le tutoriel commence !



![](/2020/01/aidungeon.png) 


Note: En suivant à la lettre le tuto et en partant d’une Ubuntu 18.04 fraichement installée, vous devriez en avoir tout de même pour 30 à 45 minutes d’installation de packages et de prérequis.


## Installer les mises à jour et les prérequis
  
  
La première chose à faire est évidemment de tout mettre à jour.


```
sudo apt-get update
sudo apt-get upgrade
```



Une fois que c’est fait, on passe aux packages systèmes dont on a besoin pour la suite :


```
sudo apt-get install git aria2 unzip python3-pip
```



## L’enfer des dépendances
  
  
Et c’est la que le vrai fun commence (ou pas). Cette partie justifie quasiment à elle seule le tuto. AIDungeon utilise TensorFlow (la lib de machine learning) et les drivers NVidia et CUDA pour fonctionner correctement. Cependant, la blague, c’est que toutes les versions de chaque composants ne fonctionneront pas ensemble.

Pour démarrer AIDungeons, vous aller devoir explicitement installer tensorflow 1.15 (pas plus, pas moins). Et bien sûr tensorflow==1.15 nécessite spécifiquement cuda10.0 (pas cuda10.1 ni cuda10.2) et Python de la version 3.4 à la version 3.7!

Horreur...

## Installer les drivers NVidia, Cuda et les modules de machine learning
  
  
Ajoutez les dépôts pour cuda10.0:


```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1804_10.0.130-1_amd64.deb
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo apt-get update

wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt install ./nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt-get update
```



Maintenant, installer les drivers nvidia-driver, puis rebooter (c’est important) :


```
sudo apt-get install --no-install-recommends nvidia-driver-440 xserver-xorg-video-nvidia-440
sudo reboot
```



Après reboot, installer les libs pour cuda10.0

```
sudo apt-get install --no-install-recommends \
    cuda-10-0 cuda-runtime-10-0 cuda-demo-suite-10-0 cuda-drivers \
    libcudnn7=7.6.2.24-1+cuda10.0 libcudnn7-dev=7.6.2.24-1+cuda10.0

sudo apt-get install -y --no-install-recommends libnvinfer5=5.1.5-1+cuda10.0 \
    libnvinfer-dev=5.1.5-1+cuda10.0
```



## Récupérer les sources
  
  
Téléchargez les sources depuis Github :


```
git clone https://github.com/AIDungeon/AIDungeon/
cd AIDungeon/
```



## Installer python3, les dépendances via pip3
  
  
Et non, ce n’est toujours pas terminé. Maintenant qu’on a récupéré les sources, il est nécessaire d’installer tous les modules Python3 nécessaire à l’exécution du jeu.

Par défaut, Ubuntu 18.04 utilise toujours Python dans sa version 2 comme interpréteur Python par défaut. Or, vous le savez tous, Python 2 vient de tirer sa révérence ce 1er janvier.

De plus, pip, le package manager de Python, installé est une vieille version. Elle ne propose tensorflow que jusqu’à la 1.14 (voir l’annexe). La misère.

Et comme si ce n’était pas suffisant, ceux qui ont déjà essayé de mettre à jour pip depuis la version disponible dans le gestionnaire de paquet d’Ubuntu savent que c’est un bon moyen de tout casser.

On se retrouve très souvent avec l’erreur `pip ImportError: cannot import name ’main’ after update`

Pour passer outre cette difficulté, le plus simple est d’utiliser le script [upgrading pip](https://pip.pypa.io/en/stable/installing/#upgrading-pip) disponible sur la page officielle de pip.

```
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py
```



## Installer AIDungeon, enfin !
  
  
Entre le moment où j’ai écris le draft de l’article il y a quelques semaines et aujourd’hui, le script d’installation a été amélioré et fonctionne mieux (il manquait une dépendance entre autre). Du coup, cette partie devrait se limiter à simplement exécuter 2 scripts. Cependant, au cas où, j’ai laissé les commandes que MOI j’ai du utiliser pour débloquer la situation.


```
sudo ./install.sh
```



Si ça ne fonctionne pas, vous pouvez installer les packages python comme ceci :


```
python3 -m pip install -r requirements.txt --user
```



Le script qui suit va télécharger le modèle de machine learning via un client torrent (au début, Nick s’est pris une facture bien salée à cause des coûts de téléchargement du modèle).


```
./download_model.sh
[...]
Status Legend:
(OK):download completed.
Download Complete!
```



## Lancer AIDungeon 2
  
  
Bravo ! Vous pouvez enfin profiter du jeu

Si vous avez utilisé le script officiel (qui utilisez des venv Python), lancez les commandes suivantes :


```
source ./venv/bin/activate
./play.py
```



Sinon, vous pouvez vous passer de la partie _venvs_.


```
cd ~/AIDungeon/
python3 play.py
```


![](/2020/01/initializing.png) 


L’initialisation du jeu prennait quelques minutes mais c’est normal. A priori ce temps a été grandement réduit (on est passé de 5-10 minutes, c’était vraiment long, à 1 ou 2 max).



![](/2020/01/aidungeon_screen.png) 


## Bonus: Commandes utiles pour surveiller l’usage du GPU
  
  
Vous pouvez installer l’utilitaire gpustat pour vérifier que le GPU est bien utilisé par l’application


```
pip3 install gpustat --user
gpustat
gpustat -cp
aidungeon2           Mon Dec  9 13:22:24 2019  430.50
[0] Tesla K80        | 69'C,  17 % |     0 / 11441 MB |
```



Dans un genre plus simple, moins sexy, vous pouvez aussi tout simplement utiliser l’outil intégré avec le driver NVidia (mais c’est moche).


```
nvidia-smi --loop=1
```



## Bonus: Vérifier que tensorflow trouve bien le GPU
  
  
Un des problèmes que j’ai eu au début était que je n’avais pas les bonnes libs. Les commandes qui suivent permettent de vérifier que tout fonctionne correctement côté tensorflow, et le cas échéant, vous afficher le message d’erreur :


```
python3

from __future__ import absolute_import, division, print_function, unicode_literals
import tensorflow as tf

print("Num GPUs Available: ", len(tf.config.experimental.list_physical_devices('GPU')))
```



Exemple d’une install qui marche


```
2019-12-10 16:25:39.714605: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcuda.so.1
2019-12-10 16:25:39.743758: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1618] Found device 0 with properties: 
name: Tesla K80 major: 3 minor: 7 memoryClockRate(GHz): 0.8235
pciBusID: 81c7:00:00.0
2019-12-10 16:25:39.744001: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudart.so.10.0
[...]
2019-12-10 16:25:39.754396: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1746] Adding visible gpu devices: 0
Num GPUs Available:  1
```



Exemple d’une install qui ne marche pas :-(


```
[...]
Num GPUs Available:  0
```



Note : si vous n’avez pas de GPU (ou que les libs ou drivers sont mal installés) vous pourrez quand meme jouer au jeu, mais il sera extrêmement lent (1-2 minutes entre chaque réponse de votre part et le temps que le texte suivant s’affiche).



## Bonus: Erreurs gsutil et tensorflow
  
  
Si vous avez oublié de mettre à jour pip, vous aurez cette erreur :


```
Collecting tensorflow==1.15 (from -r requirements.txt (line 6))
  Could not find a version that satisfies the requirement tensorflow==1.15 (from -r requirements.txt (line 6)) (from versions: 0.12.1, 1.0.0, 1.0.1, 1.1.0rc0, 1.1.0rc1, 1.1.0rc2, 1.1.0, 1.2.0rc0, 1.2.0rc1, 1.2.0rc2, 1.2.0, 1.2.1, 1.3.0rc0, 1.3.0rc1, 1.3.0rc2, 1.3.0, 1.4.0rc0, 1.4.0rc1, 1.4.0, 1.4.1, 1.5.0rc0, 1.5.0rc1, 1.5.0, 1.5.1, 1.6.0rc0, 1.6.0rc1, 1.6.0, 1.7.0rc0, 1.7.0rc1, 1.7.0, 1.7.1, 1.8.0rc0, 1.8.0rc1, 1.8.0, 1.9.0rc0, 1.9.0rc1, 1.9.0rc2, 1.9.0, 1.10.0rc0, 1.10.0rc1, 1.10.0, 1.10.1, 1.11.0rc0, 1.11.0rc1, 1.11.0rc2, 1.11.0, 1.12.0rc0, 1.12.0rc1, 1.12.0rc2, 1.12.0, 1.12.2, 1.12.3, 1.13.0rc0, 1.13.0rc1, 1.13.0rc2, 1.13.1, 1.13.2, 1.14.0rc0, 1.14.0rc1, 1.14.0, 2.0.0a0, 2.0.0b0, 2.0.0b1)
No matching distribution found for tensorflow==1.15 (from -r requirements.txt (line 6))
```



Cette erreur ne devrait plus apparaitre maintenant, mais si vous n’avez pas le module gsutil, voici la stacktrace que vous aurez en quittant le jeu (sans conséquence) :


```
> ^C
Traceback (most recent call last):
  File "play.py", line 211, in <module>
    play_aidungeon_2()
  File "play.py", line 97, in play_aidungeon_2
    action = input("> ")
KeyboardInterrupt
Exception ignored in: <bound method Story.__del__ of <story.story_manager.Story object at 0x7f797f4af0f0>>
Traceback (most recent call last):
  File "/home/zwindler/AIDungeon/story/story_manager.py", line 35, in __del__
    self.save_to_storage()
  File "/home/zwindler/AIDungeon/story/story_manager.py", line 131, in save_to_storage
    p = Popen(['gsutil', 'cp', file_name, 'gs://aidungeonstories'], stdout=FNULL, stderr=subprocess.STDOUT)
  File "/usr/lib/python3.6/subprocess.py", line 729, in __init__
    restore_signals, start_new_session)
  File "/usr/lib/python3.6/subprocess.py", line 1364, in _execute_child
    raise child_exception_type(errno_num, err_msg, err_filename)
FileNotFoundError: [Errno 2] No such file or directory: 'gsutil': 'gsutil'
```


## Sources

* [Tensorflow installation guide](https://www.tensorflow.org/install/gpu)
* [Tensorflow install issues](https://github.com/tensorflow/tensorflow/issues/26182)
* [Tensorflow GPU guide](https://www.tensorflow.org/guide/gpu)
