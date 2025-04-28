---
title: 'Fusionner plusieurs dépôts Git tout en gardant l’historique'
authors:
  - zwindler
type: post
date: 2017-03-24T13:00:31+00:00
url: /2017/03/24/fusionner-plusieurs-repos-git-avec-historique/
image: /2017/03/git_logo.png
categories:
  - Script
tags:
  - amend
  - commit
  - git
  - Gitlab
  - historique
  - rebase
  - VCS

---
## Je découvre Git

L’avantage de travailler en **#DevOps** (et c’est d’ailleurs tout le principe), est que la proximité avec les Devs (et inversement les Ops) incite à comprendre les méthodes de travail et à utiliser les outils des autres. Et bien sûr, en cas de difficulté, je n’ai qu’à me retourner et demander un coup de main aux experts ;-). Dans mon exemple, j’avais un petit souci avec Git.

J’avais initialement stocké des playbooks Ansible dans des dépôts Git distincts et bien sûr quand j’ai commencé à en avoir beaucoup (~20) j’ai changé d’avis. Cela devenait trop contraignant à exploiter sachant que les playbooks (découpés en rôles) sont parfois interdépendants.

Le plus simple aurait été de regrouper l’ensemble des sources à la version actuelle dans un même dossier, puis de tout simplement recréer un dépôt. Cependant, de cette manière, je perdais l’ensemble de l’historique des commits. Idem si j’avais copié les fichiers dans un des dépôts existant (je n’aurai gardé que l’historique d’un seul dépôt).

N’étant pas expert Git, il y a probablement plusieurs façon, cependant, je peux attester que celle a fonctionné dans mon cas ;-).

## Regarder comment Git fonctionne

Je ne vais pas vous faire un cours pour vous expliquer comment Git fonctionne, il existe de nombreuses ressources qui mettent en avant les avantages de Git par rapport à d’autres logiciels de gestion de version.

_Note : Si vous débutez sur ce [VCS][1], je vous conseille vivement de commencer par dérouler un tutoriel pour comprendre les bases et pourquoi par faire quelques tutoriels interactifs (sous la forme de petites « énigmes »). Je donne quelques exemples en fin d’article._

Je me contenterais simplement rappeler que Git est un logiciel de gestion de version qui, à la différence de SVN, n’a pas de serveur centralisé. Ce point, pas forcément intuitif si vous venez de SVN, est extrêmement important.

Au delà du fait que ce caractère décentralisé est un des points qui a fait la popularité de ce VCS, cela va nous permettre de régler mon problème :

  * je vais créer un nouveau dépôt vierge
  * lui ajouter l’URL dans sa configuration les dépôts existants en tant que **remote**, lui faisant croire que ce sont des dépôts provenant du même code source
  * recréer artificiellement entre les deux dépôts un historique « commun » avec **git rebase**

## Au travail maintenant

La première étape consiste donc à créer un nouveau dépôt git. Créez un dossier vide, mettez vous dedans et initialisez un nouveau dépôt grâce à la commande suivante :

```
git init #pour créer un nouveau repo dans le dossier courant
```


Que fait Git ?

Et bien dans le cas présent, il se contente de créer un dossier **.git** dans lequel il stockera ses métadata, ainsi qu’un fichier **config** dans lequel on retrouve toutes les options du dépôt. Ouvrez le avec votre éditeur de texte préféré, voilà à quoi ça devrait ressembler :

```
[core]
repositoryformatversion = 0
filemode = false
bare = false
logallrefupdates = true
symlinks = false
ignorecase = true
hideDotFiles = dotGitOnly
```


On va donc maintenant y ajouter les URLs des dépôts en tant que « remotes ». Dans mon cas, les dépôts sont accessibles via des URL HTTPS via Gitlab, mais ce n’est aucunement un prérequis. Vous devez juste pouvoir renseigner les « remotes » dans votre fichier **.git/config**.

```
[remote "depot_ansible_1"]
url = https://@IPgitlab/automatisation/depot_ansible_1.g1t
fetch = +refs/heads/*:refs/remotes/origin/*
[remote "depot_ansible_2"]
url = https://@IPgitlab/automatisation/depot_ansible_2.g1t
fetch = +refs/heads/*:refs/remotes/origin/*
[remote "depot_ansible_3"]
url = https://@IPgitlab/automatisation/depot_ansible_3.g1t
fetch = +refs/heads/*:refs/remotes/origin/*
```


Dans l’exemple suivant, j’ai donc ajouté des dépôts, nommés **depot\_ansible\_1**, **depot\_ansible\_2** et **depot\_ansible\_3**, tous accessibles depuis mon Gitlab aux URLs données.

Comme on part d’un dépôt vide, le premier git pull vers **depot\_ansible\_1** devrait bien se passer. Git se contente d’intégrer l’ensemble du code et des commits du dépôt **depot\_ansible\_1** comme si on avait fait un « clone ».

```
git pull depot_ansible_1 master
```


> So far, so good

## Ca se complique « un peu »

Évidemment on ne peut plus reproduire la manœuvre précédente. Si vous tentez de le faire, vous recevrez un message qui vous dira que les deux dépôts ne partagent pas d’historique commun. On va donc faire un pull avec l’option **rebase**. Mais avant tout un petit coup d’œil au **man**.

![](/2017/03/git_pull_rebase.png)

Dans mon cas, c’est précisément ce que je souhaite faire. Pour autant, je vous engage moi aussi à faire attention ;-).

```
git pull -r depot_ansible_2 master
```

A partir de ce moment là, git tente de trouver un point commun entre les deux arbres des 2 premiers dépôts (potentiellement jusqu’à l’initialisation du dépôt), puis recréée un historique à partir des deux dépôts en rejouant un à un les commits des deux dépôts.

Un dernier point, si vous tombez, lors du rebase, sur un conflit, vous devez le résoudre manuellement. Ajoutez les fichiers corrigés avec « add », puis continuez avec « rebase --continue »

## C’est fini, on nettoie un peu

Mission accomplie pour ces deux dépôts, qui sont maintenant fusionnés dans un seul dépôts avec leurs historiques de commits respectifs ! Vous n’avez plus qu’à reproduire la procédure pour chacun des dépôts (si vous en avez d’autre, **depot\_ansible\_3** dans mon exemple).

Cependant, si vous avez des messages du genre « premier commit » dans chacun de vos dépôts, ces messages n’ont pas vraiment de sens. On peut donc réutiliser le principe du rebase pour réécrire une nouvelle fois l’historique. Le rebase vous proposera la liste des commits dans un éditeur et vous pourrez sélectionner manuellement ceux que vous voulez garder (pick) ou modifier (reword).

```
git rebase -i HEAD~X #puis sélectionner les commit à modifier et les corriger un à un
```


Par exemple, si j’ai 4 commits, et que je veux réécrire le 1er de depot\_ansible\_2

```
git rebase -i HEAD~3
pick 8c98724 commit 1 de depot_ansible_1
reword 5ad60bb commit 1 de depot_ansible_2
pick 82b0cc3 commit de depot_ansible_2

# Rebase dff1fb2..82b0cc3 onto dff1fb2 (3 command(s))
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# [...]
```


## Documentation complémentaire

  * [Pro Git : la référence des livres sur Git][2]
  * [Un tutoriel interactif de GitHub][3]
  * [Un article intéressant sur la différence entre git merge et git rebase][4]

 [1]: https://fr.wikipedia.org/wiki/Logiciel_de_gestion_de_versions
 [2]: https://@IPgit-scm.com/book/fr/v2
 [3]: https://try.github.io/levels/1/challenges/1
 [4]: https://delicious-insights.com/fr/articles/bien-utiliser-git-merge-et-rebase/
