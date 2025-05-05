---
title: 'Ansible : subtilités avec « defined » et « skipped »'
authors:
  - zwindler
type: post
date: 2022-02-07T07:00:00+00:00
excerpt: "Présentation par l'exemple de l'utilisation de skipped et defined avec Ansible"
url: /2022/02/07/ansible-subtilite-defined-skipped
image: /2018/10/ansible_logo.png
categories:
  - automatisation
tags:
  - ansible
  - defined
  - skipped
  - variable
  - when
  - YAML

---
## Ansible des fois c’est pénible

Je vous parle souvent d’Ansible car c’est vraiment un outil qui a changé ma vie d’Ops. Pour autant, des fois c’est up peu pénible à comprendre...

Dans cet article je vais vous parler d’un de ces moments où j’ai vraiment pesté contre les Devs (c’est pas la première fois...). L’erreur initiale était mienne (*a priori*) mais les workarounds que j’ai testés me paraissaient légitimes...

Et cet article va me permettre de vous illustrer 2 concepts utiles pour vos tâches et variables Ansible qui sont skipped et defined.

## C’est l’histoire de deux tâches

Pour remettre les choses dans le contexte : j’ai certaines actions que j’effectue ou non selon les cas sur un groupe d’hôtes donnés. Et c’était typiquement le cas ici…

_Note: le code Ansible en lui-même n’est pas impeccable, on peut (et d’ailleurs, on va) faire beaucoup plus propre ; ce n’est pas ce que je veux montrer ici._

Voilà les tâches incriminés :

```yaml
- name: "Get some content from a command"
  command: "command outputting something"
  changed_when: false
  register: command_output
  when: not_in_test_env

- name: "Write command_output to file"
  copy:
    dest: "{{ command_output_file_path }}"
    content: "{{ command_output.stdout }}"
```

Le contenu des deux tâches importe peu, car c’est plus des limitations d’Ansible que je vais vous présenter ensuite qui importe. On pourra retrouver cette limitation dans d’autres cas plus pertinents.

Ce qu’il faut retenir, c’est que :

  * la première tâche génère un output texte et enregistre le contenu dans une variable **_command_output_**
  * la seconde tâche copie le contenu de cette variable dans un fichier texte

Cela pourrait donc être n’importe quelle variable qu’on collecte de n’importe quelle autre façon... On peut donc légitimement appliquer ce genre d’opération dans d’autres contextes, avec certains nodes où on souhaite exécuter ces deux actions et certains autres, non.

## Et là, c’est le drame.

Lors du moment où j’ai eu mon erreur, **j’étais persuadé d’avoir bien** **mis un when: not\_in\_test_env** pour skip la 2ème tâche aussi si la première l’est. Visiblement ce n’est pas le cas puisque je n’ai pas pu reproduire...

Dans le premier cas qui nous intéresse donc, si _**not\_in\_test_env**_ est positionné à **true**, pas de problème. 

En revanche, si je saute la première partie grâce à la variable _**not\_in\_test_env**_ positionnée à **false** dans les fichiers de configuration de l’inventaire, vu qu’a priori j’ai fait une erreur et n’ai pas correctement écrit mon when dans la 2ème tâche, la première tâche est bien « Skipped » lors de l’exécution du playbook, mais la tâche suivante « Fail » misérablement.

Et pour cause... Ansible essaye à tout prix de résoudre la variable **command_output.stdout** alors même que la tâche va être « Skipped ». Sur le moment, je n’arrivais pas à comprendre POURQUOI ça n’étais pas skip et j’ai donc essayer de trouver des parades.

## Pile, tu gagnes, ...

Ma première idée a été de tenter de feinter l’erreur en initialisant la variable dans le cas où elle n’est pas renseignée car la tâche est « Skipped ».

```yaml
- name: "Write command_output to file"
  copy:
    dest: "{{ command_output_file_path }}"
    content: "{{ command_output.stdout | default('') }}"
```

Manque de bol pour moi... je suis encore sur une vieille version d’Ansible, le **| default( »)** ne fonctionne pas sur les sous-variables (ici **.stdout**).

> Beginning in version 2.8, attempting to access an attribute of an Undefined value in Jinja will return another Undefined value, rather than throwing an error immediately. This means that you can now simply use a default with a value in a nested data structure (in other words, `{{ foo.bar.baz | default('DEFAULT') }}`) when you do not know if the intermediate values are defined.
>
> https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html

**| default** ou pas, Ansible essaye donc de résoudre **command_output.stdout** ; la tâche continue donc de « Fail »...

## ... Face, je perd

En passant en mode « debug », j’ai remarqué quelque chose que je ne savais pas. Quand on « Skip » une tâche avec un **register:**, la variable pas enregistrée (car skip) n’est **pas** vide. Mon problème est que **command_output.stdout** n’existe effectivement pas, mais **command_output** si. 

Plus précisément, Ansible injecte une sous entrée **command_output.skipped** positionnée à « true ».

Je me suis donc dit : banco ! Je vais modifier ma condition pour qu’elle empêche l’exécution de la tâche si **command_output.skipped** existe (car ça veut dire que **command_output.stdout** n’existe pas).

Ça donne quelque chose comme ça :

```yaml
- name: "Get some content from a command"
  command: "command outputting something"
  changed_when: false
  register: command_output
  when: not_in_test_env

- name: "Write command_output to file"
  copy:
    dest: "{{ command_output_file_path }}"
    content: "{{ command_output.stdout }}"
  when: not command_output.skipped
```

Et là, dans le cas où **not\_in\_test_env** est false, ça ne fail plus.

Victoire ? Non bien sûr... car **command_output.skipped** n’existe pas (pas de skipped = false) quand la tâche est exécutée (c’est à dire « pas skipped »). Retour à la case départ : maintenant ça « Fail » dans le cas où on ne « Skip » plus...

## Sur la tranche, je perds aussi

Dernière idée, on peut se dire que le plus simple / propre, c’est tout simplement de tester le fait qu’une variable (que ce soit **command_output.stdout** ou **command_output.skipped**) soit « defined » pour décider si on exécute ou pas la tâche.

```yaml
- name: "Write command_output to file"
  copy:
    dest: "{{ command_output_file_path }}"
    content: "{{ command_output.stdout }}"
  when: command_output.stdout is defined
```

Mais évidemment, pour que la blague soit complète, ce qu’il faut savoir c’est qu’une solution à base de **command_output.skipped is defined**, ne peut pas marcher...

En fait, il n’est pas possible avec Ansible d’utiliser **is defined** pour vérifier l’existence (ou non) d’un sous élément.

## Solutions

La solution la plus simple, que je croyais dur comme fer avoir implémenté (mais mes tests additionnels me prouvent que non) c’est simplement d’ajouter un **when: not\_in\_test_env** à la 2ème tâche...

Dans la même veine, et qui permet en plus d’éviter d’initialiser pour rien **_command_output.skipped_**, il aurait pu être malin de simplement utiliser un **block:** avec le when, englobant les deux tâches :

```yaml
- block:
    - name: "Get some content from a command"
      command: "command outputting something"
      changed_when: false
      register: command_output

    - name: "Write command_output to file"
      copy:
        dest: "{{ command_output_file_path }}"
        content: "{{ command_output.stdout }}"
  when: not_in_test_env
```

Et la vraie solution si jamais vous voulez absolument vérifier si la tâche précédente a été skipped ou pas, est d’utiliser la syntaxe suivante :

```yaml
- name: "Write command_output to file"
  copy:
    dest: "{{ command_output_file_path }}"
    content: "{{ command_output.stdout }}"
  when: 'skipped' not in command_output
```

Cette syntaxe n’est pas hyper évidente de prime abord, mais c’est la seule qui fonctionne dans Ansible pour faire ça...

## Bonus

Un lecteur ('Jof) m'a fait remarquer qu'il y a une autre solution qui marche dans tous les cas :

```yaml
- when command_output|skipped
```

Merci à lui !

## Conclusion

Le vrai problème ici est quand même que j’avais vraiment besoin de vacances pour ne pas avoir été capable de trouver l’erreur aussi basique ;-).

La seconde est que j’utilise une version antédiluvienne d’Ansible et que ça irait beaucoup mieux avec des versions plus récentes (pour le **| default** notamment).

La dernière chose à retenir est que quand on veut vérifier la présence ou non d’un sous élément dans une variable, le mieux reste d’utiliser **in** ou **not in** plutôt que **is defined** qui ne fonctionne pas dans tous les cas.

## Sources additionnelles

  * [stackoverflow.com/questions/56066503/i-am-having-ansible-issues-with-register-command-when-using-when-in-tasks](https://stackoverflow.com/questions/56066503/i-am-having-ansible-issues-with-register-command-when-using-when-in-tasks)
  * [github.com/ansible/ansible/issues/17500#issuecomment-246370020](github.com/ansible/ansible/issues/17500#issuecomment-246370020)
  * [github.com/ansible/ansible/issues/4297#issuecomment-356427588](github.com/ansible/ansible/issues/4297#issuecomment-356427588)
