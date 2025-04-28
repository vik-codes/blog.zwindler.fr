---
title: Votre première VM dans Azure… déployée avec Ansible bien sûr !
authors:
  - zwindler
type: post
date: 2018-08-07T11:45:22+00:00
url: /2018/08/07/premiere-vm-dans-azure-avec-ansible-bien-sur/
image: /2018/06/azure.png
categories:
  - Système
  - Virtualisation
tags:
  - ansible
  - automatisation
  - azure
  - azure cli
  - playbook

---
## Mais tu n’as pas déjà fais un article sur Ansible et des VMs ?

Si vous me suivez depuis quelques temps, vous savez que j’apprécie particulièrement Ansible. J’ai déjà écris [plusieurs articles sur le sujet](/recherche/?keyword=ansible), ainsi que de nombreux playbooks que j’ai mis à votre disposition sur [mon compte github.][2]

Un des articles qui intéresse le plus les lecteurs du blogs est un article en deux parties ([part1](/2017/06/20/deployer-machines-virtuelles-ansible-vmware/) [part2](/2017/11/14/deployer-vm-vmware-ansible-part-2/)) qui détaille comment déployer des machines virtuelles sur une architecture VMware vSphere avec Ansible. J’en ai d’ailleurs fait une version en anglais également qui attire pas mal de monde aussi ;-).

Du coup, maintenant que je me suis attaqué aux principaux clouds providers (AWS, GCP et Azure), il était grand temps de faire un article sur cette partie également !

Comme d’autres outils d’automatisation, Ansible fait la part belle aux intégrations cloud. Je vous laisse jeter un oeil à la liste des modules Ansible disponibles pour le cloud :

* [docs.ansible.com/ansible/2.9/modules/list_of_cloud_modules.html](https://docs.ansible.com/ansible/2.9/modules/list_of_cloud_modules.html)

Et c’est particulièrement vrai pour Azure, dont l’équipe dédiée chez Microsoft est assez réactive et ajoute des features de manière très régulière (on aura l’occasion d’y revenir dans un prochain article, #teasing).

## Les prérequis

Finalement, déployer un VM dans Azure, c’est presque pareil que comme déployer une VM dans VMware. On a des prérequis, une liste de paramètres à renseigner et pouf, on va poper une VM.

Bon, en vrai, ce n’est pas aussi trivial : si pour VMware, on se contentait d’une API python relativement simple à installer avec **pip** et d’un mot de passe, sur Azure, il va falloir trimer un poil plus.

Deux ressources nous donnent la marche à suivre pour configurer notre poste :

  * [Le guide de Microsoft](https://learn.microsoft.com/fr-fr/azure/developer/ansible/overview)
  * [Le guide d’Ansible][7]

### Installer

Sur une machine mint/debian/ubuntu, récupérer les modules python nécessaires :

```
apt install python-pip ansible
pip install setuptools wheel 
pip install ansible[azure]
```


### Configurer

Pour déployer des VMs sur Azure, il faut... un compte sur Azure !

> Thanks, captain obvious.

Bon, si jamais vous voulez essayer, sachez que vous pouvez vous créer un compte gratuit avec 200$ de crédit offert, mais seulement valable 30 jours. C’est hyper radin de leur part, là où un GCP offre 300$ pendant 1 an, ce qui offre largement plus de temps pour tester.

Pour ouvrir le compte, il faut simplement aller à [cette URL][8] et renseigner **une carte bancaire**. Oui je sais, j’ai flippé moi aussi.

Normalement, ils ne vous prélèveront pas sans vous prévenir, c’est simplement pour éviter les bots. Personnellement je n’ai pas eu de problèmes mais je ne peux rien garantir (même si je pense que ça se saurait s’il y avait eu des soucis de ce côté là).

Une fois le compte créé, on va générer les fichiers de configuration pour Azure. Le plus simple pour le faire, c’est d’utiliser la commande « az login » (mais du coup il faut [installer az cli][9] en plus).

```
az login
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code CCHMTROLL to authenticate.
```


![](/2018/08/azcli.png)

Vous devriez avoir un dossier .azure dans votre homedir

```
ll .azure
total 8
drwxrwxrwx 1 zwindler zwindler  512 Aug  4 17:00 ./
drwxr-xr-x 1 zwindler zwindler  512 Aug  4 16:56 ../
-rw------- 1 zwindler zwindler 7124 Aug  4 17:00 accessTokens.json
-rw-rw-rw- 1 zwindler zwindler    5 Aug  4 16:56 az.json
-rw-rw-rw- 1 zwindler zwindler    5 Aug  4 16:56 az.sess
-rw-rw-rw- 1 zwindler zwindler  333 Aug  4 17:00 azureProfile.json
-rw-rw-rw- 1 zwindler zwindler   66 Aug  4 17:00 clouds.config
-rw------- 1 zwindler zwindler   27 Aug  4 16:56 config
```


## Et donc, on la déploie sur Azure, cette VM ?

Maintenant que notre poste est configuré, ça redeviens simple. Ouf !

Le module à invoquer dans notre playbook est **azure\_rm\_virtualmachine**, dont la documentation est disponible à l’adresse suivante :

[https://docs.ansible.com/ansible/latest/modules/azure\_rm\_virtualmachine_module.html#azure-rm-virtualmachine-module][11]

Voici un des exemples donnés dans la documentation du module :

```
- name: Create a VM with managed disk
  azure_rm_virtualmachine:
    resource_group: Testing
    name: testvm001
    vm_size: Standard_D4
    managed_disk_type: Standard_LRS
    admin_username: adminUser
    ssh_public_keys:
      - path: /home/adminUser/.ssh/authorized_keys
        key_data: < insert your ssh public key here... >
    image:
      offer: CoreOS
      publisher: CoreOS
      sku: Stable
      version: latest
```


La plupart des options que je vous met plus haut sont obligatoires. Il y en a beaucoup d’autre, mais celles ci sont un minimum. Pour expliquer un peu de quoi il s’agit, voici une petite traduction :

<u>resource_group</u>  
Sur Azure, il existe plusieurs entités logiques permettant de segmenter les ressources entre elles. La souscription (plus haut niveau de segmentation, utile au niveau billing) et les **resources groups**. On peut donc avoir plusieurs resource groups dans une souscription.

<u>name</u>  
Le nom de la ressource, telle qu’elle apparaîtra dans votre portail Azure. Pas plus important que ça.

<u>vm_size</u>  
Là on rentre dans le vif du sujet ; il s’agit de la taille de la VM (en terme de nombre de CPU et de Go de RAM) que va avoir votre VM. Un guide des tailles (sans le billing) est disponible [à l’adresse suivante](https://docs.microsoft.com/fr-fr/azure/virtual-machines/windows/sizes-general)

<u>managed_disk_type</u>

Pour faire simple, est ce que votre disque sera sur des baies SSD ou sur des baies mixant SSD et HDD classiques. On a assez peu d’information sur la façon dont sont stockées les données, au delà d’un nombre d’IOPS qui sera d’autant plus important que vous aurez réservé d’espace disque. Par exemple, un disque Premium de 128 Go, on aura droit à 500 IOPS et 100Mo/s max. Si vous passez au delà (de 129 à 256), vous aurez droit à 1100 IOPS et 125 Mo/s.

Quelques infos quand même :

* [docs.microsoft.com/fr-fr/azure/virtual-machines/windows/premium-storage](https://docs.microsoft.com/fr-fr/azure/virtual-machines/windows/premium-storage)
* [docs.microsoft.com/fr-fr/azure/virtual-machines/windows/standard-storage](https://docs.microsoft.com/fr-fr/azure/virtual-machines/windows/standard-storage)

Je vois vos petits yeux pétiller de malice.

Vous vous dites « ahah, je vais les feinter, me payer un disque de 129 Go pour avoir les perfs d’un disque de 256 pour à peine plus qu’un disque de 128 Go ».

Et bien non, ils ne sont pas fous, vous payerez pour un disque de 256 même si vous ne demandez que 129 (et même si vous n’utilisez 1 Go dedans).

<u>admin_username & ssh_public_keys</u>

Je ne vais pas vous faire l’affront de détailler ça. Il faut rentrer un utilisateur, un path pour la clé SSH et le contenu de votre clé publique.

<u>image</u>

Sur azure, vous avez accès à un magasin pré configuré d’images de VMs.

Si on veut un Ubuntu 16.04, on mettra :

```
image:
      offer: UbuntuServer 
      publisher: Canonical 
      sku: '16.04.0-LTS'
      version: latest
```


Pour un CentOS 7.4 :

```
image:
      offer: CentOS
      publisher: OpenLogic
      sku: '7.4'
      version: latest
```


## Toujours plus

Alors OK, avoir un bout de doc qui explique comment déployer une VM sur Azure, c’est chouette. Mais est ce qu’on pourrait pas faire mieux ?

Et oui, bien sûr ! Car en fait, dans Azure, on ne va pas simplement pouvoir déployer notre VM comme ça et espérer que ça marche.

Je l’ai déjà dis, il existe des ressources groups, dans lequel toutes vos ressources doivent être. On va devoir le créer. Mais il va aussi nous falloir une carte réseau, qui aura une adresse IP qui elle même proviendra d’un réseau virtuel, qui auront leur propres règles de sécurité (genre de firewalling basique). Et bien sûr, tout ça, c’est des objets à créer (à la main :-( ... ou pas) !

Mais comme je suis sympa, je vais vous donner un playbook clé en main qui fait tout ça pour vous ;)

```
---
- name: "Create Azure resources"
  connection: local
  hosts: all
  vars_prompt:
    - name: "location"
      prompt: "Choose region to deploy VMs"
      private: no
      default: "westeurope"
    - name: "project_prefix"
      prompt: "Choose a prefix for all the resources"
      private: no
      default: "test"
    - name: "instances_number"
      prompt: "Choose a number of virtual machines to create"
      private: no
      default: 1
    - name: "vm_size"
      prompt: "Choose a size for azure virtual machines"
      private: no
      default: "Standard_B2s"
    - name: "managed_disk_type"
      prompt: "Choose a type for azure virtual disks"
      private: no
      default: "Standard_LRS"
    - name: "admin_username"
      prompt: "Choose an admin username"
      private: no
      default: "zwindler"
    - name: "admin_pub_path"
      prompt: "Where can I find the admin public key ?"
      private: no
      default: "~/.ssh/id_rsa.pub"
    - name: "local_ip"
      prompt: "your local IP address (skip if you don't want to add 22 port to NSG)"
      private: no
      default: "skip"
    - name: "virtualnetwork_cidr"
      prompt: "Give a network CIDR for virtual network (large)"
      private: no
      default: "172.16.0.0/18"
    - name: "subnet_cidr"
      prompt: "Give a subnet of that network"
      private: no
      default: "172.16.1.0/24"
  vars:
    - resourcegroup_name: "{{project_prefix}}-rg"
    - availabilityset_name: "{{project_prefix}}-avset"
    - virtualnetwork_name: "{{project_prefix}}-vnet"
    - subnet_name: "{{project_prefix}}-subnet"
    - securitygroup_name: "{{project_prefix}}-nsg"
    - vm_root_name: "{{project_prefix}}-vm"
    - public_ip_name: "{{project_prefix}}-ip"
    - nic_root_name: "{{project_prefix}}-nic"
  tasks:
    - name: "Create {{project_prefix}}-rg Resource Group"
      azure_rm_resourcegroup:
        name: "{{resourcegroup_name}}"
        location: "{{location}}"

    - name: "Create {{availabilityset_name}} Availability Set"
      azure_rm_availabilityset:
        name: "{{availabilityset_name}}"
        location: "{{location}}"
        resource_group: "{{resourcegroup_name}}"
        sku: Aligned

    - name: "Create {{virtualnetwork_name}} Virtual Network"
      azure_rm_virtualnetwork:
        name: "{{virtualnetwork_name}}"
        resource_group: "{{resourcegroup_name}}"
        address_prefixes_cidr:
          - "{{virtualnetwork_cidr}}"

    - name: "create {{subnet_name}} Subnet in {{virtualnetwork_name}} for VMs"
      azure_rm_subnet:
        name: "{{subnet_name}}"
        virtual_network_name: "{{virtualnetwork_name}}"
        resource_group: "{{resourcegroup_name}}"
        address_prefix_cidr: "{{subnet_cidr}}"
      register: subnet

    - name: "Create {{securitygroup_name}} security rules (if local IP address was given)"
      azure_rm_securitygroup:
        name: "{{securitygroup_name}}"
        resource_group: "{{resourcegroup_name}}"
        purge_rules: yes
        rules:
          - name: 'AllowSSHFromYourOwnInternetIP'
            protocol: 'Tcp'
            source_address_prefix: "{{local_ip}}"
            destination_port_range: 22
            access: Allow
            priority: 1000
            direction: Inbound
      when: local_ip | ipaddr

    - name: "Create a {{nic_root_name}}X network interface for each VM"
      azure_rm_networkinterface:
        name: "{{nic_root_name}}{{item}}"
        resource_group: "{{resourcegroup_name}}"
        virtual_network: "{{virtualnetwork_name}}"
        subnet_name: "{{subnet_name}}"
        security_group: "{{securitygroup_name}}"
        ip_configurations:
          - name: "ipconfig"
            public_ip_address_name: "{{public_ip_name}}"
            primary: True
      with_sequence: count="{{instances_number}}"

    - name: "Create {{vm_root_name}}X VM with existing NIC"
      azure_rm_virtualmachine:
        resource_group: "{{resourcegroup_name}}"
        name: "{{vm_root_name}}{{item}}"
        vm_size: "{{vm_size}}"
        managed_disk_type: "{{managed_disk_type}}"
        admin_username: "{{admin_username}}"
        availability_set: "{{availabilityset_name}}"
        ssh_password_enabled: false
        ssh_public_keys:
          - path: "/home/{{admin_username}}/.ssh/authorized_keys"
            key_data: "{{lookup('file', '{{admin_pub_path}}') }}"
        network_interface_names: "{{nic_root_name}}{{item}}"
        image:
          offer: UbuntuServer
          publisher: Canonical
          sku: '16.04.0-LTS'
          version: latest
      with_sequence: count="{{instances_number}}"
```


Pour ceux qui veulent d’économiser un copier coller, j’ai mis à disposition ce playbook à l’adresse suivante :

* [github.com/zwindler/ansible-deploy-azure](https://github.com/zwindler/ansible-deploy-azure)

Et il ne reste plus qu’à l’exécuter :

```
pip install --user netaddr
echo localhost > hosts
ansible-playbook -i hosts azure-deploy.yml
[...]
TASK [Create test-vmX VM with existing NIC] *****************************************
changed: [localhost] => (item=1)

PLAY RECAP **************************************************************************
localhost                  : ok=1    changed=7    unreachable=0    failed=0
```


![](/2018/08/azure_vm.png)

## Le mot de la fin

Bon, on en est où maintenant ?

Et bien maintenant, vous avez un playbook qui vous permet de déployer des VMs à tour de bras dans Azure certes, mais aussi de les préconfigurer avec votre clé SSH et votre utilisateur administrateur, et seul votre IP (ou celle que vous aurez donné ou un subnet) pourra y accéder en SSH.  
Vous avez toutes vos VMs dans un même sous réseau, lui même dans un réseau virtuel.  
Vous avez également un AVSET qui vous permet de ne pas avoir toutes vos VMs sur les mêmes hyperviseurs et augmenter la disponibilité de votre application.  
Et tout ça, sans rien avoir eu à faire à la main.

Badass non ?

Et encore! J’en ai gardé un peu sous le coude, pour d’autres articles ;-)
 
 [2]: https://github.com/zwindler?utf8=%E2%9C%93&tab=repositories&q=ansible&type=&language=
 [7]: https://docs.microsoft.com/fr-fr/azure/ansible/ansible-overview
 [8]: https://azure.microsoft.com/fr-fr/free/search/?&WT.srch=1&wt.mc_id=AID719808_SEM_Xu5DFmXy&gclid=Cj0KCQjwv-DaBRCcARIsAI9sba9FHepWuC6mzBDlrT2LqPIAQzFYrCdyjTC72M2QqEtYRd6GXXoyooQaAhYsEALw_wcB&dclid=COf_zsaAutwCFY1h0wodDDcOqg
 [9]: https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli?view=azure-cli-latest
 [11]: https://docs.ansible.com/ansible/latest/modules/azure_rm_virtualmachine_module.html#azure-rm-virtualmachine-module
 