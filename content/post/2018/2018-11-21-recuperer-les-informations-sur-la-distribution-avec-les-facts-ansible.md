---
title: Récupérer les informations sur la distribution avec les facts Ansible
authors:
  - zwindler
type: post
date: 2018-11-21T12:45:40+00:00
url: /2018/11/21/recuperer-les-informations-sur-la-distribution-avec-les-facts-ansible/
image: /2018/10/ansible_logo.png
categories:
  - Script
  - systeme
tags:
  - ansible
  - CentOS
  - facts
  - jinja
  - OS
  - RHEL
  - task
  - template
  - Ubuntu
  - YAML

---
## Les facts d’Ansible

Si vous suivez le blog, vous savez que [j’utilise énormément Ansible](/recherche/?keyword=ansible). J’ai même été faire un [talk sur le sujet à BDX I/O 2018, à l’ENSEIRB](/2018/11/09/bdx-i-o-2018-ami-developpeur-deviens-un-ops-sans-effort-avec-ansible).

Aujourd’hui, plutôt que de vous donner un playbook tout fait pour installer sans effort une des multiples applications dont j’ai automatisé le déploiement avec Ansible, je vous propose d’explorer une des features les plus importantes et utiles d’Ansible, les **facts**, par le biais d’un petit exemple.

## C’est quoi les facts dans Ansible

Si vous avez déjà lancé un playbook, vous avez sûrement remarqué lors de son exécution, que la première tâche qui est réalisée n’est pas une tâche que vous avez demandée explicitement.

```
ansible-playbook -i inventory/prod/blop -u blop --private-key=blop.key configure-blop.yml
[...]]
TASK [Gathering Facts] *********************************************************
ok: [blop-vm1]
```


Cette tâche **[Gathering Facts]**, qui ne fait à première vue rien, correspond en fait à la connexion à la ou les machines sur lesquelles seront exécutées les playbooks. Si la connexion échoue, le playbook échouera sur cette cible, et continuera éventuellement sur les autres (s’il en reste). Si l’hôte répond, alors Ansible en profite pour récupérer moult informations en rapport avec cette machines et les stockent dans une variable **ansible_facts**.

## A quoi ça ressemble ?

Comme je ne disais, à première vue, cette commande de fait rien. Si on ne sait pas qu’elle stocke des informations dans une variables, on ne peut rien en faire.

Un bon moyen d’avoir un premier aperçu de ce qu’on peut en faire est de les afficher. On peut faire ça avec [le module « setup »](http://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html), qui est en réalité le même module qui est appelé lors de l’étape **[Gathering facts]**.

Le retour se fera au format JSON, ce qui est certes peu digeste, mais facilitera grandement les manipulations de type « filtre » (via le flag filter intégré ou via l’utilitaire **jq** par exemple).

```
ansible blop-vm1 i inventory/prod/blop -m setup
blop-vm1 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "10.1.1.10"
        ], 
        "ansible_apparmor": {
            "status": "enabled"
        }, 
[...]
```


Je ne vous copie-colle pas tout, rien que pour cette machine, j’ai 719 lignes... La quantité d’informations disponible est impressionnante, et on peut même en venir à se demander à quoi ça va bien pouvoir nous servir.

## Ok, on en fait quoi ?

Du coup je profite de cet article pour faire un tuto tout simple et qui peut être utile dans de nombreux cas, réaliser des opérations différentes en fonction de la distribution de la machine concernée.

L’information qui va nous intéresser ici concerne donc les remontées en tant que « nom » ou « version » d’une distribution. Je vais vous économiser la lecture de nos 700+ lignes, et vous indiquer que vous pouvez trouver ces informations en filtrant sur les mots clés « ansible\_distribution... » et « ansible\_os... »

Voilà ce qu’on pourrait obtenir sur une machine CentOS :

```
ansible blop-vm1 -m setup -a 'filter=ansible_distribution*'
blop-vm1 | SUCCESS => {
  "ansible_facts": {
    "ansible_distribution": "CentOS",
    "ansible_distribution_major_version": "7",
    "ansible_distribution_release": "Core",
    "ansible_distribution_version": "7.2.1511"
  },
  "changed": false
}

ansible blop-vm1 -m setup -a 'filter=ansible_os_family'
blop-vm1 | SUCCESS => {
  "ansible_facts": {
    "ansible_os_family": "RedHat"
  },
  "changed": false
}
```


Et sur une machine Ubuntu :

```
ansible blop-vm2 -m setup -a 'filter=ansible_distribution*'
ansible blop-vm2 | SUCCESS => {
    "ansible_facts": {
        "ansible_distribution": "Ubuntu", 
        "ansible_distribution_file_parsed": true, 
        "ansible_distribution_file_path": "/etc/os-release", 
        "ansible_distribution_file_variety": "Debian", 
        "ansible_distribution_major_version": "16", 
        "ansible_distribution_release": "xenial", 
        "ansible_distribution_version": "16.04"
    }, 
    "changed": false
}
ansible blop-vm2 -m setup -a 'filter=ansible_os*'
blop-vm2 | SUCCESS => {
    "ansible_facts": {
        "ansible_os_family": "Debian"
    }, 
    "changed": false
}
```


## Utiliser les facts dans un playbook

Pour continuer dans l’exemple, on va faire une chose qu’il ne faut jamais faire : désactiver le firewall et SELinux.

Imaginons que vous souhaitiez quand même le faire. Si vous lancez ce playbook sur tout votre parc et qu’il n’est pas homogène, vous allez tomber sur des groupes de machines Ubuntu, CentOS 5, 6, 7...

Un moyen de gérer les cas particuliers pourrait être de les classer tous vos hosts dans des groupes, et de créer un playbook pour chaque OS/version, restreint à un groupe de machines uniquement.

```
---
- hosts: rhelcentos6only
  tasks:
[…]
```


Ce n’est d’ailleurs pas une mauvaise idée, surtout pour gérer les distrib aussi différentes que RHEL et Ubuntu par exemple.

En revanche, dans le cas de RHEL, on a des différences qui apparaissent à partir de la RHEL 7, notamment la gestion du Firewall qui passe de IPtables à firewalld.

On va donc faire appel à la clause **when:** de ansible, qui conditionne l’exécution d’une tâche (ou d’un rôle ou d’un block) à une validation. Et ça donnerait quelque chose comme ça :

```
---
- hosts: rhelcentos6only
  tasks:
  - name: "shutdown and disable IPtables for RHEL <= 6"
    service: 
      name=iptables
      state=stopped
      enabled=no
    when: (ansible_distribution == "CentOS" or ansible_distribution == "RedHat") and
          (ansible_distribution_major_version <= "6") 

  - name: "shutdown and disable firewalld for RHEL >= 7"
    service:
      name=firewalld
      state=stopped
      enabled=no
    when: (ansible_distribution == "CentOS" or ansible_distribution == "RedHat") and
          (ansible_distribution_major_version >= "7")

  - name: "disable selinux"
    selinux:
     state=disabled
```


Dans cet exemple, lors de l’exécution du playbook, on aura donc, pour chaque VM CentOS ou RHEL, une tâche qui sera exécutée, et l’autre qui sera marquée « skipping » (en bleu clair) et le playbook marchera pour toutes les RHEL, quelque soit leur version.

## Aller plus loin

Il existe une page spécifique sur la documentation d’Ansible pour parler des conditions dans les playbooks, accessible à l’adresse suivante : https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html

Vous pouvez aussi utiliser les facts dans les options des tasks, et dans les templates, en encadrant le nom de la variable souhaitée avec des « doubles curly braces » : `{{ xxx }}`

```
- command: "echo {{ ma_super_variable }}"
```


## Sources

* [docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html](http://docs.ansible.com/ansible/latest/collections/ansible/builtin/setup_module.html)
* [docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)
