---
title: Convertir une clé au format SSH2 vers OpenSSH
authors:
  - zwindler
type: post
date: 2019-01-15T11:55:18+00:00
url: /2019/01/15/convertir-une-cle-au-format-ssh2-vers-openssh/
image: /2018/06/openssh.png
categories:
  - Divers
tags:
  - clé
  - convertir
  - OpenSSH
  - ppk
  - PuTTY
  - PuTTYgen
  - sed
  - SSH2
  - tr

---
## Mais pourquoi tu fais ça ?

Ça y est !! Je travaille enfin dans une entreprise où les gens qui le souhaitent peuvent travailler sous Linux. Exit [les VMs hyper-V ou Virtualbox][1], le Linux subsystem for Windows, Docker for Windows, [minikube][2], et autre bidouilles pour faire mon travail.

Malheureusement, tout le monde n’est pas encore totalement convaincu, et je suis encore amené à travailler avec des gens qui n’ont pas (encore ?) sauté le pas.

> Come to the Dark side... we’ve got cookies

Quand ces gens là m’envoient des clés SSH (c’est bien les **publiques** que je veux, hein Loïc ;p), ils utilisent PuTTYgen, comme presque tout le monde sous Windows ([livré avec le célebrissime PuTTY][3]).

![](/2019/01/Putty.png)

Et vous ne le savez peut être pas, mais PuTTYgen ne sait générer que des **ppk** (le format de PuTTY) et éventuellement de les convertir au format SSH2. C’est donc dans ce dernier format qu’ils m’envoient leurs clés.

## Et en quoi ça gène ?

Souvent, ces clés sont utilisées pour se connecter à des machines sous Linux, qui la plupart du temps disposent d’un serveur OpenSSH. Et par défaut, les clés dans **.ssh/authorized_keys** doivent être au format OpenSSH, pas SSH2...

### Mais c’est quoi la différences ?

Voilà à quoi ressemble une clé SSH2

```
---- BEGIN SSH2 PUBLIC KEY ----
Comment: "generated_blop"
AAAABCDEFGHIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxZZZZZZZZ==
---- END SSH2 PUBLIC KEY ----
```


Et maintenant, une clé au format OpenSSH

```
ssh-rsa AAAABCDEFGHIxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxZZZZZZZZ== generated_blop
```


On voit au final que les deux formats sont assez similaires. En fait, si vous avez la fleme de chercher la ligne de commande, pour obtenir la clé au format OpenSSH quand vous avez une clé au format SSH2, il suffira de supprimer les lignes « ---.... » et « Comment: « , puis de retirer les sauts de ligne pour tout mettre sur une seule ligne par clé (avec éventuellement un commentaire en fin de ligne).

Dans mon cas, on m’a donné BEAUCOUP de clés SSH2 et je n’avais pas encore de toute me les taper à la main.

## La solution barbare

Pourquoi faire propre quand on peut faire du sed, tr et des regex ?

```
sed -e "/^[---|Comment]/d" my_ssh2_key | tr -d '\n'
```


## La VRAIE solution

Au final, même si la solution précédente me faire sourire, la vraie solution est simplement d’utiliser le binaire **ssh-keygen** qui dispose d’une fonction pour le faire « out of the box ».

```
ssh-keygen -i -f ssh2.pub
```


Pour un répertoire donné ou toutes les clés à convertir sont des fichiers textes dont le nom de fichier se termine par « key », lancer la commande suivante :

```
for i in `ls -1 *key`; do echo "$(ssh-keygen -i -f $i) $i"; done
```


Cerise sur le gateau, si vous en avez beaucoup, vous serez content d’avoir le nom du fichier initial en tant que commentaire OpenSSH à la fin de la clé (c’est ce que fait le $i à la fin de mon « echo ».

Et là si on veut le copier coller directement dans le .ssh/authorized_keys :

```
for i in `ls -1 *key`; do echo "$(ssh-keygen -i -f $i) $i >> ~/.ssh/authorized_keys"; done
```


## Fun fact sur PuTTY qui n’a rien à voir avec la choucroute

En astreinte avec un N3 de chez VMware qui travaillait aux Etats Unis, j’ai passé une dizaine de secondes au téléphone à ne pas comprendre de quoi il me parlait et lui demander de répéter.

En fait, il me demandait d’ouvrir un terminal PuTTY et je n’avais jamais entendu comment était prononcé PuTTY à part en France. On dit généralement « pou-ti » ou parfois « pu-ti ».

Aux US (et probablement dans tous les pays anglosaxons), on le prononce « peuh-ti ».

La prochaine fois, vous pourrez vous la péter et prononcer PuTTY avec l’accent de l’oncle Sam ;-).

## Sources

  * [Un article en anglais qui donne quelques commandes supplémentaires][5]
  * [Un convertisseur en ligne fourni par l’université de Berkeley (lien mort, j'ai mis Internet Archive pour que vous voyez à quoi il ressemble mais il ne fonctionne probablement pas)](https://web.archive.org/web/20200103000937/https://svnkeys.berkeley.edu/)

 [1]: /recherche/?keyword=hyper-v
 [2]: /recherche/?keyword=minikube
 [3]: https://www.putty.org/
 [4]: /2019/01/Putty.png
 [5]: https://tutorialinux.com/convert-ssh2-openssh/
