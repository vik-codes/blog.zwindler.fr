---
title: Générer ses images Stable Diffusion sur Ubuntu 22.04
authors:
  - zwindler
type: post
date: 2023-01-03T07:15:00+00:00
excerpt: 'Tutoriel pour installer Stable Diffusion en local sur une machine Ubuntu 22.04 vierge (et une grosse carte graphique NVidia)'
url: /2023/01/04/generer-ses-images-stable-diffusion-sur-ubuntu-22.04/
image: /2023/01/stablediffusion.png
categories:
  - autohebergement
  - DIY
  - Matériel
tags:
  - AI
  - AI art
  - cuda
  - GPU
  - GTX
  - Machine Learning
  - OpenAI

---

## L'IA et le retour de la vengeance

Ce n'est pas la première fois que je parle de machine learning sur le blog. La première fois, j'avais testé pour le fun de selfhost [AIDungeon 2, un jeu de rôle où l'histoire est générée par l'"""IA"""](/2020/01/13/lancer-aidungeon-2-sur-ubuntu-18-04/).

A l'époque, j'essayais de jouer à AIDungeon sur l'application web disponible en ligne mais le site était très souvent down, car, à cause de l'engouement pour le jeu et son côté hyper ludique / technophile, l'auteur avait reçu une facture cloud de quelques dizaines de milliers de dollars (et c'était pas trop prévu).

Heureusement, le jeu étant (à l'époque) complètement open source, j'avais eu l'idée de faire un guide pour le lancer soi-même (enfin, fallait quand même un GPU avec 8 Go de VRAM)...

Et depuis l'an dernier, l'IA revient sur le devant de la scène.

Non, je ne vais pas parler de ChatGPT mais de DALL-E 2. Il faut bien le reconnaitre, a bluffé plus d'une personne. Et Dall-e n'étant pas open source, il n'a pas fallu bien longtemps pour que des alternatives open source voient le jour (avec des résultats souvent moins impressionnant mais quand même).

Sauf que... rebelote, les serveurs en ligne sont leeeeeents. Ca serait cool si on pouvait lancer ça en local.

Ca tombe bien, j'ai une machine avec Ubuntu 22.04 et une carte graphique NVidia RTX 3080 hors de prix sous mon bureau 😏😏😏.

Note: vous avez besoin d'une machine avec un GPU avec au minimum 4 Go de VRAM (sinon ça sera en mode CPU et ça sera extrêmement lent), de minimum 20 Go d'espace disque pour le modèle et les dépendances et d'un compte sur HuggingFace.com pour récupérer le modèle Stable Diffusion.

## Installer les mises à jour et les prérequis

La première chose à faire dans tout bon guide est évidemment de tout mettre à jour.

```bash
sudo apt-get update
sudo apt-get upgrade
```

Normalement sur Ubuntu 22.04 vous devriez avoir Python 3 installé par défaut, il nous faut la version 3.9 ou 3.10 avec les venvs.

```bash
sudo apt install python3.10 python3.10-venv
```

Si on veut profiter de notre GPU, il va falloir passer par les pilotes officiels nvidia (et pas "nouveau").

```bash
sudo apt-get install --no-install-recommends nvidia-driver-525 xserver-xorg-video-nvidia-525
```

Et surtout, il faudra absolument rebooter ensuite (sinon le GPU ne sera pas détecté).

## Galères d'installation

Sur AIDungeon j'avais pété un plomb, car les dépendances pour tout ce qui est GPU + machine learning et Python sont très capricieuses...

Pour ce qui est de Stable Diffusion, à l'époque de la sortie j'avais trouvé la documentation pas ouffissime et j'avais abandonné assez vite. Jusqu'à il y a peu il y avait très peu de guides pour l'installer facilement sur sa machine.

La plupart des guides proposaient de le lancer sur des notebooks en ligne (donc hosté quelque part) et c'est pas du tout ce que je voulais.

Heureusement, je suis tombé sur ce post [The simplest way to get started with Stable Diffusion on Ubuntu](https://code.mendhak.com/run-stable-diffusion-on-ubuntu/), qui parle d'un dépôt git [github.com/lstein/stable-diffusion](https://github.com/lstein/stable-diffusion.git).

Sauf que ce guide proposait d'installer toutes les dépendances avec Anaconda et ne marche plus aujourd'hui (problèmes de dépendances python, encore...).

Heureusement, rebondissant sur le dépôt mentionné juste avant, je me suis rendu compte que le dépôt avait changé de nom et beaucoup évolué depuis l'article sur mendhak.com.

Le dépôt s'appelle maintenant [github.com/invoke-ai/InvokeAI](https://github.com/invoke-ai/InvokeAI) et dispose de scripts d'installation assez poussés et multi plateformes.

## Récupérer l'installeur

On peut faire l'installation via les sources soit même (je donne des infos plus loin) mais le plus simple est de suivre le script d'installation, [disponible dans les "releases" dans Github](https://github.com/invoke-ai/InvokeAI/releases/tag/v2.2.4) :

```
wget https://github.com/invoke-ai/InvokeAI/files/10254727/InvokeAI-installer-2.2.4-p5-linux.zip
unzip InvokeAI-installer-2.2.4-p5-linux.zip && cd InvokeAI-Installer/
./install.sh
```

Vous serez guidé lors du processus d'installation, c'est assez simple

```bash
Welcome to InvokeAI. This script will help download the Stable Diffusion weight files and other large models that are needed for text to image generation. At any point you may interrupt this program and resume later.

** INITIALIZING INVOKEAI RUNTIME DIRECTORY **
Select the default directory for image outputs [/home/zwindler/invokeai/outputs]: /home/zwindler/invokeai/outputs

[...]
```

A un moment on va vous demander de valider des licences (étape "3. Accept the license terms located here"). Il faut juste les lire sur le site et appuyer sur entrée pour continuer (j'avais pas compris au début...).

La dernière étape consiste à générer ([ici](https://huggingface.co/settings/tokens)) et donner au script un token en "read" sur votre compte Hugging Face. C'est assez simple et ça permet de télécharger automatiquement le dernier modèle de Stable Diffusion.

![](/2023/01/hugging_face_token.png)

## Lancer !

Une fois installé, on peut lancer le script `invokeai/invoke.sh`

L'important est que la ligne suivante apparaisse quand vous lancez le script ("cuda" et pas "cpu")

```bash
>> Using device_type cuda
```

Ce qui est assez cool avec InvokeAI, c'est l'ajout d'une interface web pour faciliter vos générations, même s'il existe toujours un prompt terminal si vous préférez :

```bash
Do you want to generate images using the
1. command-line
2. browser-based UI
3. open the developer console
Please enter 1, 2, or 3: 1
```

![](/2023/01/invokeAI_launch.png)

A partir de là, vous pourrez générer autant de chats mignons que vous voudrez !

![](/2023/01/invokeAI_webui.png)

![](/2023/01/invokeAI_cuda.png)

Have fun :D

## Bonus : installation manuelle

Lors de ma première installation, j'avais oublié qu'il fallait absolument les drivers officiels nvidia pour faire du cuda sous Ubuntu (alors que j'avais eu le même problème pour AIdungeon 🤦). Le script se lançait en mode "CPU" et la génération de la moindre image prenait 5 minutes

```
* Initialization done! Awaiting your command (-h for help, 'q' to quit)
invoke> a cat
Generating:   0%|                                                                                                                | 0/1 [00:00<?, ?it/s]>> Ksampler using model noise schedule (steps >= 30)
>> Sampling with k_lms starting at step 0 of 50 (50 new sampling steps)
100%|██████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 50/50 [05:41<00:00,  6.82s/it]
Generating: 100%|███████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [05:49<00:00, 349.51s/it]
>> Usage stats:
>>   1 image(s) generated in 349.99s
Outputs:
[1] /home/zwindler/invokeai/outputs/000001.3257807215.png: a cat -s 50 -S 3257807215 -W 512 -H 512 -C 7.5 -A k_lms
```

J'ai donc tâtonné et essayé d'installer l'outil "à la main".

Si vous ne voulez pas utiliser l'installeur pour une raison ou pour une autre, vous pouvez donc aussi utiliser [cette page de documentation](https://invoke-ai.github.io/InvokeAI/installation/manual/).

J'ai essayé, ça marche (mais c'était pas mon problème).

## Bonus : Vérifier que votre GPU est bien détecté

```
Python 3.10.6 (main, Nov 14 2022, 16:10:14) [GCC 11.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import torch
>>> torch.cuda.is_available()
True
>>> torch.cuda.device_count()
1
>>> torch.cuda.get_device_capability()
(8, 6)
```
