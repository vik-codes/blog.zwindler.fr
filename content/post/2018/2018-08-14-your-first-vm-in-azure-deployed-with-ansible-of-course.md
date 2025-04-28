---
title: Your very first VM in Azure… deployed with Ansible, of course!
authors:
  - zwindler
type: post
date: 2018-08-14T11:45:31+00:00
url: /2018/08/14/your-first-vm-in-azure-deployed-with-ansible-of-course/
image: /2018/06/azure.png
categories:
  - Script
  - Système
  - Virtualisation
tags:
  - ansible
  - automation
  - azure
  - Infrastructure as code
  - playbook

---
## Haven’t you already wrote an article about Ansible and VM provisioning?

You might have read already a few articles on Ansible on this blog. I **really** like Ansible. I already wrote a [few articles on this topic](/recherche/?keyword=ansible), even a few in english, and there are a few playbooks on [my Github account][2] if you want to check it out.

[French readers]Au cas où vous l’auriez manqué, la version française de cet article [est disponible ici](/2018/08/07/premiere-vm-dans-azure-avec-ansible-bien-sur)[/French readers]

One of the articles that you like the most, especially my english speaking viewers, is the one about deploying virtual machines on VMware vSphere platform. But now that I have moved on past VMware and started working on cloud providers (mostly the big ones, AWS, GCP and Azure), I felt it was time to share my automation playbooks about that also ;)

As you might have guessed, Ansible and cloud providers teams have been working hard to provide integrations. You can have a look at the BIG list of modules for cloud integrations only!  
[https://docs.ansible.com/ansible/latest/modules/list\_of\_cloud_modules.html][4]

That’s especially true for Azure and Microsoft teams, which are relatively available and that provide regular updates (this is going to be the topic of another article, #teasing).

## Prerequisites

Now that I introduced the subject, let’s deploy a VM on Azure. Yay!

Good news is that’s it’s almost the same thing as deploying a VM in vSphere. We have prerequisites, parameters to fill in and pouf, a VM appears.

Bad news is that prerequisites are going to be a little bit more tedious to install/configure, but worry not, I’ll give you all the steps ;)

There are two guides giving us info on how to configure our workstation to start working with Azure:

  * [the one form Microsoft][5]
  * [the one from Ansible][6]

### Install

On a mint/debian/ubuntu, get the necessary python modules :

```
apt install python-pip ansible
pip install setuptools wheel 
pip install ansible[azure]
```


### Configure

To deploy a VM in Azure, you need... an Azure account!

> Thanks, captain obvious.

Ok, so assuming you don’t have one, you have to know that you can get a 200$ free credit. To open the account, simply go to [this page][7]

The only two issues with this is that this credit expires after 30 days (while AWS of GCP gives 365 days!) and that you need a credit card. I know that having to register a credit card can be a little frightening.

If you read all the informations, they claim that it’s only to avoid bots and that they won’t get money from it. If you consume all you credit or move past the 30 days, the account will be locked. Personnaly it worked great indeed and I didn’t lost a cent, but you shouldn’t believe me and be careful to avoid a bad surprise I case it dooesn’t work as well for you.

Once we have our account, we have to configure our workstation. The easiest way to do this is to use az cli for linux (but then you need to [install it][8]). You can also configure the files by hand (following the guides I gave previously).

```
az login
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code CCHMTROLL to authenticate.
```


![](/2018/08/azcli.png)

After that, you should have a .azure in your homedir

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


## Soooo... we deploy this VM or not?

Yeah, now that our workstation is configured, this becomes easy again!

The Azure module to create a VM in a playbook is **azure\_rm\_virtualmachine**. Documentation can be found here [docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_virtualmachine_module.html](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_virtualmachine_module.html)

Here’s one of the examples given in the documentation:

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


Most of the options given here are a strict minimum. There are many many more. I’ll explain a little what’s what:

<u>resource_group</u>  
On azure, there are multiple logic entities to segment resources between each other. Subscription is the highest level of segmentation (mostly used for multitenancy, environment segregation or billing) and resources groups. You can have multiple subscription in a same account, and many resource groups in a single subscription.

<u>name</u>  
The name of the resource we are going to deploy.

<u>vm_size</u>  
Now we enter inside the topic. This is a size of the VM (in terms of vCPUs and GB of RAM) we are going to give our VM. A guide of the available size can be found here => [docs.microsoft.com/fr-fr/azure/virtual-machines/windows/sizes-general](https://docs.microsoft.com/fr-fr/azure/virtual-machines/windows/sizes-general)

<u>managed_disk_type</u>

The type of the virtual disk we are going to create at the same time. Basically, will your disk be on full SSD disk array or not. You won’t find much information on exactly how your data is stored aside from SLAs (availability and performance).

* [docs.microsoft.com/fr-fr/azure/virtual-machines/windows/premium-storage](https://docs.microsoft.com/fr-fr/azure/virtual-machines/windows/premium-storage)
* [docs.microsoft.com/fr-fr/azure/virtual-machines/windows/standard-storage](https://docs.microsoft.com/fr-fr/azure/virtual-machines/windows/standard-storage)

For example, we know that a Premium disk of 128 GB will have a performance threshold of 500 IOPS and 100 MB/s. If you add just one GB (from 129 GB to 256), you’ll get 1100 IOPS and 125 Mo/s. Don’t expect to swindle Azure by have the performance of a 256 GB disk for the price of 128+1 GB, because a the moment you move past 128 GB, you’ll pay for a 256 GB (even if you ask only for 129, and even if you only you 10 GB).

<u>admin_username & ssh_public_keys</u>

Self explainatory.

<u>image</u>

On Azure, you can access preconfigured images:

If we want a Ubuntu 16.04:

```
image:
      offer: UbuntuServer 
      publisher: Canonical 
      sku: '16.04.0-LTS'
      version: latest
```


If we want a CentOS 7.4 :

```
image:
      offer: CentOS
      publisher: OpenLogic
      sku: '7.4'
      version: latest
```


## Mooooar!

Ok, I gave you a little piece of YAML and I explained it to you. That’s nice, but you want more. Can we have more, you ask?

Of course, you can!

In fact, you need more to have a working VM. In Azure, as we are not in our own datacenter where everything has been previously set up from network to hypervisors, we need more objects (resources) than just a VM.

I already told you about it, we first need a resource group, in which we’ll put our VM. But, we also need a virtual network interface that we will attach to the VM. This vNIC will have to have a public IP address if we are going to connect on it. Also, we will need a virtual network for the vNIC, and maybe add some basic firewalling rules.

We could do all this by hand... :(

Or... we could automated it all with an Ansible playbook !!!

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


For those of you that want to be spare the copy paste, this playbook can also be found on this Github repository

* [github.com/zwindler/ansible-deploy-azure](https://github.com/zwindler/ansible-deploy-azure)

You only have to run it:

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

## Final words

Where are we now?

Now, we have a playbook, deploying VMs on Azure, but not only!

These machines are preinstalled with a Linux OS, preconfigured with your own SSH key and user. Only your local IP address can access it through SSH, all the VMs are in a single private virtual network; All the VMs are spread evenly accross Azure hypervisors to avoid SPOF by adding the VMs in an AVSET (availability set).

All of this could have been done by someone else by hand, with a little time. But not you. You, you used this playbook to do it all with only one command ;)

Aren’t you badass?

 [2]: https://github.com/zwindler?utf8=%E2%9C%93&tab=repositories&q=ansible&type=&language=/
 [4]: https://docs.ansible.com/ansible/2.9/modules/list_of_cloud_modules.html
 [5]: https://docs.ansible.com/ansible/2.9/scenario_guides/guide_azure.html
 [6]: https://docs.microsoft.com/fr-fr/azure/ansible/ansible-overview
 [7]: https://azure.microsoft.com/fr-fr/free/search/?&WT.srch=1&wt.mc_id=AID719808_SEM_Xu5DFmXy&gclid=Cj0KCQjwv-DaBRCcARIsAI9sba9FHepWuC6mzBDlrT2LqPIAQzFYrCdyjTC72M2QqEtYRd6GXXoyooQaAhYsEALw_wcB&dclid=COf_zsaAutwCFY1h0wodDDcOqg
 [8]: https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli?view=azure-cli-latest

