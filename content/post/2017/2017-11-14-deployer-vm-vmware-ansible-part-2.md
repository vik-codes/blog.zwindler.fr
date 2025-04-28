---
title: Déployer des VM VMware avec Ansible – part 2
authors:
  - zwindler
type: post
date: 2017-11-14T12:45:27+00:00
url: /2017/11/14/deployer-vm-vmware-ansible-part-2/
image: /2017/03/ansible_vpshere.png
categories:
  - Script
  - Système
  - Virtualisation
tags:
  - ansible
  - ESX(i)
  - RHEL
  - SSH
  - ssh-keyscan
  - template
  - VMware
  - Windows

---
## Où est ce qu’on en était ?

La dernière fois qu’on a parlé de [machines virtuelles déployées à l’aide d’Ansible sur une infrastructure VMware][1], on avait un playbook fonctionnel, mais il me manquait encore un petit quelque chose.

En fait, à l’issue du déploiement de la VM, je n’avais pas encore trouvé la possibilité d’enchaîner sur l’exécution d’autres playbooks permettant de configurer la VM. L’objectif ultime étant de faire en une seule étape de :

  * déployer la VM (que j’appellerai « déploiement »)
  * et de la configurer, c’est à dire modifier les fichiers de configuration de la VM, installer les logiciels, etc... (que j’appellerai « configuration »).

## Premier problème, connection:local

Pour rappel, le premier problème quand on veut déployer une VM qui n’existe pas encore... est justement le fait qu’elle n’existe pas encore !

Si j’exécute un playbook deploy_vm.yml sur une VM « ma-vm » tel quel, je vais me prendre un message d’erreur ([pour plus de détails, lire l’article précédent](/2017/06/20/deployer-machines-virtuelles-ansible-vmware/)) car Ansible tente de se connecter à la machine pour récupérer des informations sur elle.

La méthode pour s’affranchir de ce genre de problèmes est de feinter Ansible en lui disant :

  1. de ne pas récupérer les informations de la machine
  2. d’exécuter le playbook sur une autre machine (le plus simple c’est localhost)

Pour le premier point, la solution est mettre en haut du playbook l’option **gather_facts: false**. Cela aura un impact mais on verra ça plus loin.

Pour le second point, il existe 2 solutions. La première, que je préconisais dans l’article précédent, consiste à utiliser en haut du playbook l’option **connection: local**. Cette option permet d’exécuter l’ensemble du playbook sur la machine locale et non pas la machine qu’on déploie.

En réalité, il est en fait plus simple d’utiliser l’option **delegate_to**, qui se limite à une seule tâche ou à un rôle, ce qui permet de déléguer la partie déploiement à localhost, puis tenter d’exécuter les autres playbooks sur la VM qu’on veut configurer.

## Un problème de nom ... pas si facile à résoudre

> Vous avez vu le jeu de mot ? Ok, je sors...

Bien sûr, on va se heurter à plusieurs problèmes... Le premier est la résolution de nom. A moins d’avoir réalisé la mise à jour de votre DNS à l’avance (à la main du coup... c’est nul), dès que le déploiement sera terminé et qu’on passera à la partie configuration de la VM, Ansible essayera de contacter votre nouveau serveur.

Le plus propre serait d’ajouter à la partie « déploiement » une tâche permettant de mettre à jour le DNS. Dans mon environnement professionnel, le service DNS est géré par un serveur Windows Active Directory. La simple mise à jour du DNS depuis Linux est un vrai casse tête et le plus simple est d’intégrer la machine (qu’elle soit Windows ou Linux) dans le domaine Active Directory qui se charge alors de mettre à jour le DNS lui même.

C’est un gros sujet et je ferai un article à part dessus. Dans un premier temps on peut se contenter de juste mettre à jour le fichier **/etc/hosts** de la machine localhost.

```
- name: add to /etc/hosts file
  lineinfile:
    dest: /etc/hosts
    line: '{{ custom_ip }} {{ inventory_hostname }} {{ inventory_hostname }}.zwindler.fr'
  with_items: '{{play_hosts}}'
  when: "hostvars[item].inventory_hostname == inventory_hostname"
  delegate_to: localhost
```


### Accès concurrents

Si vous vous y connaissez un peu en Ansible, vous remarquerez que je ne me suis pas contenté d’un simple **lineinfile**, mais que j’ai utilisé un _with_items_ et un _when_.

En fait, on peut utiliser mon playbook pour déployer en parallèle un grand nombre de VMs en même temps. Le souci que j’ai rapidement eu a été un accès concurrent sur le fichier, et des noms de VMs ont alors manqué.

Il existe une fonction « serial » qui permet de désactiver la parallélisation des tâches, mais malheureusement, on ne peut l’appliquer qu’au playbook entier. Peut être qu’un jour la fonctionnalité sera ajoutée (la demande est référencée sur [Github](https://github.com/ansible/ansible/issues/1217))

J’ai donc du passer par une boucle pour enregistrer tous les serveurs du play courant.

## Clé SSH

OK, maintenant, on sait résoudre la (ou les) machine(s) qu’on vient d’ajouter. Cependant on est pas sorti de l’auberge !

En partant du principe que vous n’avez pas oublié de déposer la clé SSH du serveur _localhost_ pour qu’Ansible puisse se connecter sur votre nouvelle machine, voilà ce qui va se passer :

```
TASK [gather facts] *************************************************************************************************************************************************************************
The authenticity of host 'zwindler01 (x.x.x.x)' can't be established.
Are you sure you want to continue connecting (yes/no)? The authenticity of host 'zwindler02 (x.x.x.x)' can't be established.
Are you sure you want to continue connecting (yes/no)? The authenticity of host 'zwindler03 (x.x.x.x)' can't be established.
```


Ansible bloque à la première connexion SSH vers votre VM nouvellement crée car il faut accepter l'empreinte de chaque VM manuellement au préalable. Même si on essaye de renseigner **yes** à toutes les questions, ce n’est clairement pas idéal et encore moins automatisé !

### La solution temporaire, host\_key\_checking=False

Il existe un paramètre dans Ansible qui permet de passer outre la vérification de l'empreinte de la machine, soit en modifiant le fichier de configuration **ansible.cfg**, soit ajouter un flag à l’exécution de playbook, soit configurer une variable d’environnement.

```
ansible-playbook -l zwindler* -i hosts_deploy -e 'host_key_checking=False' deploy_vmware_guest.yml
#OU
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -l zwindler* -i hosts_deploy deploy_vmware_guest.yml
```


Vous trouverez plus d’informations sur cette solution de contournement sur les sites suivants :

* [stackoverflow.com/questions/23074412/how-to-set-host-key-checking-false-in-ansible-inventory-file](https://stackoverflow.com/questions/23074412/how-to-set-host-key-checking-false-in-ansible-inventory-file)
* [docs.ansible.com/ansible/latest/intro\_getting\_started.html#id7][2]

Cette solution de contournement est à proscrire en production, car elle va ignorer l'empreinte de TOUTES les machines et pour TOUS vos playbooks. Au delà du problème évident de sécurité que ça pose, si vous enlevez l’option à un moment donné, c’est retour à la case départ. Vous aurez de nouveau la question sur tous les serveurs dont vous n’avez pas explicitement accepté l'empreinte.

### ssh-keyscan à la rescousse

On va donc ajouter la tâche suivante à notre playbook de déploiement :

```
- name: accept new ssh fingerprints
  shell: ssh-keyscan {{ custom_ip }},{{inventory_hostname}} >> ~/.ssh/known_hosts
  with_items: '{{play_hosts}}'
  when: "hostvars[item].inventory_hostname == inventory_hostname"
  delegate_to: localhost
```


Je sais... c’est terrible : la solution que j’ai à l’heure actuelle, bien que fonctionnelle, N’EST PAS IDEMPOTENTE... :-( mais elle fonctionne.

Et on fini par un petit **setup** pour récupérer les facts.

```
- name: gather facts
  setup:
```


## Et maintenant ?

Et bien ! Maintenant, ça marche ! Vous pouvez enchainer d’autres tâches (ou des rôles) en ne mettant plus delegate_to, et ces tâches de « configuration » seront bien lancées sur le serveur que vous venez de déployer, dans un seul et même playbook.

```
---
- hosts: all
  gather_facts: false

  vars_prompt:
    - name: "vsphere_password"
      prompt: "vSphere Password"
    - name: "esxi_host"
      promt: "ESXi host"
      private: no
    - name: "notes"
      prompt: "VM notes"
      private: no
      default: "Deployed with ansible"

  roles:
     - deploy_vmware_guest
     - other_role_for_configuration
```


Pari réussi !

## Et le playbook, il est où ?

Une fois de plus, je suis sympa, [je vous donne un exemple de code sur mon Github][3] !

 [2]: http://docs.ansible.com/ansible/latest/intro_getting_started.html#id7
 [3]: https://github.com/zwindler/ansible-deploy-vmware-guest
