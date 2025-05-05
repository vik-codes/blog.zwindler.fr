---
title: Déployer des machines virtuelles avec Ansible (VMware)
authors:
  - zwindler
type: post
date: 2017-06-20T11:30:10+00:00
excerpt: Déployer des machines virtuelles VMware avec Ansible
url: /2017/06/20/deployer-machines-virtuelles-ansible-vmware/
image: /2017/06/ansible-vmware.png
categories:
  - Script
  - systeme
  - Virtualisation
tags:
  - ansible
  - Infrastructure as code
  - script
  - VM
  - VMware

---
## Déployer des VMs via Ansible ?

Depuis que j’automatise [tout ce qui peut l’être sur mes machines virtuelles avec l’aide d’Ansible](/recherche/?keyword=ansible), il y avait une corde qui manquait encore à mon arc.

Jusqu’à présent, j’utilisais Ansible simultanément en tant qu’outil de déploiement de logiciel et aussi comme logiciel de « Configuration Management ».

Je m’explique :

  * A partir d’un template de machine virtuelle, je suis capable de déployer une configuration par défaut en fonction du rôle de la machine (au sens large du terme, que ce soit des fichiers ou de l’installation de packages).
  * Si jamais une modification de la configuration est faite, je suis capable de « pousser » cette modification sur toutes les machines d’un seul coup.
  * Et enfin, si jamais des modifications ont été réalisées (par exemple en cas d’erreur) sur une partie de mes machines, je suis capable de « corriger » tous les serveurs « non-compliant » SANS TOUCHER à ceux qui le sont (car mes playbooks sont idempotent, comme mon module pour [centreon](/2016/12/20/ansible-module-clapi-centreon/)).

![](/2016/11/73068978.jpg)


Pour autant, j’étais frustré de ne pas avoir encore trouvé le moyen d’aller encore un peu plus loin : provisionner les machines directement depuis Ansible.

## Pourquoi ça coince

2 obstacles majeurs m'empêchaient d’aller au bout de la démarche.

### Gather facts

D’abord parce que par défaut, si vous donnez une liste de serveurs à Ansible dans votre inventaire avec pour but de les déployer, Ansible va tenter de les se connecter à ces machines... qui n’existent pas encore !

```
ansible-playbook -l 192.168.100.103 zwindler_deploy.yml

PLAY [xxxxxxaaaaaaaaaaa] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************
fatal: [192.168.100.103]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host 192.168.100.103 port 22: No route to host\r\n", "unreachable": true}

PLAY RECAP **********************************************************************************************************************************************************************************
192.168.100.103 : ok=0 changed=0 unreachable=1 failed=0
```


Dans ce cas précis, il faut donc dire à Ansible de ne pas essayer de s’y connecter dans un premier temps. J’ai mis un moment à trouver. Dans certains cas (comme pour [alimenter un serveur centreon avec CLAPI](/2016/12/07/automatisation-de-la-supervision-avec-centreon-et-ansible-3/)), j’ai utilisé la fonction **delegate_to**.

Mais le mieux dans le cas présent consiste à utiliser les options suivantes au début de votre playbook :

```
gather_facts: false
connection: local
```


Grâce à ces deux options, vous pourrez indiquer à Ansible de ne pas faire l’opération **gather_facts**, étape préliminaire à l’exécution de tout playbook, et de ne même pas essayer de se connecter sur les futurs serveurs mais de tout exécuter localement.

> Problem solved.

### vsphere\_guest versus vmware\_guest

Mon deuxième problème était qu’il existe 2 groupes de modules pour VMware dans les modules Ansible, et que l’un des deux est abandonné ! Et bien sûr comme c’est le plus ancien, c’est celui qui remonte le plus dans les exemples/articles sur Internet ;-).

Dans un premier temps, j’avais fais des tests avec [vsphere_guest][5]. Bien que « fonctionnel », ce module intégré à la suite Ansible en version 1.6 nécessite en dépendance python et surtout **pysphere**. Or, [pysphere][6] n’est plus maintenu depuis 2013 !

Dans l’absolu, on peut très bien utiliser **vsphere_guest** pour provisionner des machines virtuelles. La dernière version normalement pour vSphere 5.0 fonctionne parfaitement sur vSphere 6.X. Un très bon exemple de ce que vous pouvez faire avec ce module est expliqué dans un article de [EverythingShouldBeVirtual][7].

Pour autant, vous ne pourrez pas :

  * Réaliser de modifications sur la machine virtuelle si vous la copiez depuis un template
  * Réaliser des customisations côté OS

Personnellement, je travaille massivement avec des templates, qui sont ensuite agrémentés par des customisations via des playbooks Ansible. Mais j’ai besoin de customiser ces templates en fonction du contexte et je rechigne à faire la modification en 2 étapes. De plus, une fois déployée, j’ai quand même besoin de passer manuellement sur chacune des machines pour leur donner une adresse IP et un hostname unique par exemple.

Heureusement, VMware ne s’est pas contenté du VIPerl et de PowerCLI ! Depuis quelques années, il existe un module Python, maintenu par VMware, et qui est régulièrement étendu avec les nouvelles fonctionnalités de l’API : [pyvmomi][8].

A partir de cet API python, un module Ansible plus récent a donc été créé, et vous allez le voir, les possibilités sont bien plus étendues.

## Et la lumière fut

La liste des modules Ansible qui utilisent le module pyvmomi est assez impressionnant. Il s’agit de tous les modules qui commencent par **vmware_** (vous pouvez trouver la liste sur la [documentation officielle d’Ansible][9], dans la section VMware).

Deux d’entre eux ont particulièrement retenus mon attention, même s’il y en a plein d’autres intéressants :

  * [vmware_guest][10] qui permet de gérer les machines virtuelle
  * [vmware\_vm\_shell][11] qui permet d’exécuter des commandes directement sur l’OS invité de la VM (si elle dispose des VMware Tools)

### Prérequis

Pour exécuter ces modules, vous avez besoin de 2 choses :

  * **pyvmomi** et ces dépendances (python 2.6+ et sphinx)

```
pip install pyvmomi sphinx
```


  * **Ansible 2.2** minimum (mais plutôt 2.3 voire 2.4 !)

<del datetime="2017-06-20T14:31:16+00:00">Sur le papier, le module « fonctionne » avec Ansible 2.2, l’actuelle version stable que vous pourrez trouvez sur tous les dépôts. Sauf que la plupart des fonction intéressantes n’apparaissent qu’avec la version 2.3 d’Ansible, pour l’instant uniquement disponible si vous compilez les sources !~~

La version disponible en ce moment est la 2.3.1. Il n’est donc plus nécessaire de compiler les sources, SAUF si vous voulez utiliser les nouvelles fonctionnalités du modules introduites dans la 2.4. Je laisse la procédure de compilation en fin d’article.

## Et maintenant le playbook !

Voici un exemple de playbook qui :

  * Prompte pour un mot de passe administrateur pour se connecter au vCenter
  * Déploie une machine virtuelle depuis template

Ce déploiement dépend d’un certain nombre de variables qui peuvent être renseignées dans le fichier hosts tels que :

  * la taille du disque virtuel
  * le nombre de vCPU
  * la quantité de vRAM
  * l’ESXi ou le datastore destination
  * l’adresse IP de la VM
  * Une fois la VM créée, l’adresse IP et le hostname est configurée dans l’OS invité

```
cat zwindler_vmware_add_normal.yml
---
- hosts: all
gather_facts: false
connection: local

vars_prompt:
- name: "vsphere_password"
prompt: "vSphere Password"
- name: "notes"
prompt: "VM notes"
private: no
default: "Deployed with ansible"

tasks:
# get date
- set_fact: creationdate="{{lookup('pipe','date "+%Y/%m/%d %H:%M"')}}"

# Create a VM from a template
- name: create the VM
vmware_guest:
hostname: '{{ vsphere_host }}'
username: '{{ vsphere_user }}'
password: '{{ vsphere_password }}'
validate_certs: no
esxi_hostname: esxi_server
datacenter: 'ZWINDLER'
folder: A_DEPLOYER
name: '{{ inventory_hostname }}'
state: poweredon
guest_id: rhel7_64Guest
annotation: "{{ notes }} - {{ creationdate }}"
disk:
- size_gb: 150
type: thin
datastore: '{{ vsphere_datastore }}'
networks:
- name: server_network
ip: '{{ custom_ip }}'
netmask: 255.255.252.0
gateway: 192.168.100.1
dns_servers:
- 192.168.100.10
- 192.168.101.10
hardware:
memory_mb: 4096
num_cpus: 2
customization:
dns_servers:
- 192.168.100.10
- 192.168.101.10
domain : zwindler.fr
hostname: '{{ inventory_hostname }}'
template: tmpl-rhel-7-3-app
wait_for_ip_address: yes

- name: add to ansible hosts file
lineinfile:
dest: /etc/ansible/hosts
insertafter: '^\[{{ ansible_host_group }}\]'
line: '{{ inventory_hostname }}'
```


A partir là, vous pouvez tout faire :)

Juste une petite limitation que je n’ai malheureusement pas encore pu contourner : à la suite de la création de la VM, vous ne pourrez pas « enchainer » sur un autre playbook (par exemple pour vous connecter sur la machine pour ajouter un service). Vous devrez passez par un second playbook.

La raison principale à ceci est qu’on a spécifié « connection local » et « gather facts » à faux pour que ça ne plante pas au début. Du coup le playbook ne s’exécuterait pas sur la bonne machine.

**EDIT : [la solution à ce problème est disponible sur l’article suivant](/2017/11/14/deployer-vm-vmware-ansible-part-2/) !**

## Liens utiles

Le module pause peut être utile dans certain cas, même si je n’en suis pas fan dans un environnement type « production ».

* [docs.ansible.com/ansible/pause_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pause_module.html)

Également, je vais bientôt faire un article sur le module dédié a Proxmox dans les semaines qui viennent !!

* [docs.ansible.com/ansible/proxmox\_kvm\_module.html][13]

## Nouvelles fonctionnalités

En attendant donc que la <del datetime="2017-06-20T14:31:16+00:00">2.3~~ 2.4 soit distribuée partout, voici l’erreur que vous risquez d’avoir si vous utilisez les fonctions **linked_clone** ou **snapshot_src** :

```
ansible-playbook zwindler_vmware_add_micro.yml
vSphere Password:
VM notes [Deployed with ansible]:

PLAY [ansible_node] **********************************************************

TASK [create the VM] ***********************************************************
fatal: [ansible_node]: FAILED! => {"changed": false, "failed": true, "msg": "unsupported parameter for module: linked_clone"}

PLAY RECAP *********************************************************************
ansible_node : ok=0 changed=0 unreachable=0 failed=1
```


Voici la marche suivre pour compiler et installer la version 2.4 d’Ansible via les sources :

```
git clone https://github.com/ansible/ansible

cd ansible
make
make install

ansible --version
ansible 2.4.0
```

 [5]: https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_guest_module.html
 [6]: https://github.com/argos83/pysphere
 [7]: http://everythingshouldbevirtual.com/creating-vsphere-vms-using-ansible
 [8]: https://github.com/vmware/pyvmomi
 [9]: https://docs.ansible.com/ansible/2.9/modules/list_of_cloud_modules.html
 [10]: https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_guest_module.html
 [11]: https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_vm_shell_module.html
 [13]: https://docs.ansible.com/ansible/latest/collections/community/general/proxmox_kvm_module.html
