---
title: Deploy VMware virtual machines with Ansible
authors:
  - zwindler
type: post
date: 2017-09-26T11:30:00+00:00
url: /2017/09/26/deploy-vmware-virtual-machines-with-ansible/
image: /2017/03/ansible_vpshere.png
categories:
  - Script
  - systeme
  - Virtualisation
tags:
  - ansible
  - API
  - idempotent
  - VMware
  - vmware_guest
  - vSphere
  - vSphere 5.X
  - vSphere 6.X

---
## Why would I deploy virtual machines with Ansible

[Update]I wrote another article about [VM automation, for Azure this time. Check it out!](/2018/08/14/your-first-vm-in-azure-deployed-with-ansible-of-course/[/Update]

[French readers]La version française de l’article « Déployer des machines virtuelles VMware avec Ansible) est [disponible à l’adresse suivante](/2017/06/20/deployer-machines-virtuelles-ansible-vmware/)[/French readers]

Since a few month, [I automate all that can be automated with Ansible (FR)](/recherche/?keyword=ansible). Still, there was something that I still had to do manually and it bothered me (a lot).

Until then, I used Ansible both as a deployment tools (to install things on my machines) and also as a « Configuration Management » tool.

Let me explain :

  * From a virtual machine template, I can deploy default configuration (depending of the machine role). I mean by configuration, the first sense of the term like configuration files, but also package installations.
  * If I need to modify something on a subset of (or all!) my servers, I can push it on them with one command line.
  * Should something/someone modify something on the server managed configuration, I can correct this with my Ansible magic wand by just playing all my playbooks on all the servers once in a while. All « non compliant » servers will be automatically corrected WITHOUT TOUCHING those that ARE compliant.

For the last part, it’s not really « magic ». Playbooks have to be written while keeping I mind that they must be « idempotent ». This is really important and that’s why I had to develop [my own Ansible module for Centreon](/2016/12/20/ansible-module-clapi-centreon).

![](/2016/11/73068978.jpg)

Still, I was frustrated because one last step was still missing: Provisioning VMs directly from Ansible!

## What is the problem?

2 obstacles prevented me from doing it.

### Gather facts

First, Ansible works with an inventory. If you try to tell Ansible that you want to create new machines and you add them to the inventory, the first thing Ansible will try to do is to connect to them... before they exists!

```
ansible-playbook -l 192.168.100.103 zwindler_deploy.yml

PLAY [xxxxxxaaaaaaaaaaa] ********************************************************************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************************************************************
fatal: [192.168.100.103]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host 192.168.100.103 port 22: No route to host\r\n", "unreachable": true}

PLAY RECAP **********************************************************************************************************************************************************************************
192.168.100.103 : ok=0 changed=0 unreachable=1 failed=0
```


We need to tell Ansible **not to connect**, at least at first.

You can do that by using the option **gather_facts: false**, which, you guessed, tells Ansible not to gather facts...

But that’s still not enough. If you try to run the playbook with just this option, Ansible will still try to connect to the yet to be created server, failing.

Most of the time, people use the **delegate_to** option, which tells Ansible to connect to another server for one specific task. I had used it previously [to feed informations in Centreon with CLAPI](/2016/12/07/automatisation-de-la-supervision-avec-centreon-et-ansible-3/).

Here, if you need to run several tasks and none of them have to be executed on the remote machine (that we are trying to deploy), you can just specify at the head of the playbook _that all tasks_ are to be executed from the local machine, with **connection: local** :

```
gather_facts: false
  connection: local
```


To sum this up, with these 2 options, you can tell Ansible not to « gather facts » as a preliminary step of every playbook, and to execute everything locally, thus avoiding the failing connection to the yet inexistant servers.

> Problem solved.

### vsphere\_guest versus vmware\_guest

My second issue was that 2 groups of modules were available in Ansible core, and one of them was abandoned. _Of course_, I was using the oldest abandoned one, because it’s the one that posts up in all the tutorials/examples I could find on Internet ;-) .

You can find it here [vsphere_guest][7]. It « works », and it has been integrated to the core way sooner (v 1.6) and needs the python dependancy [pysphere][8] (not maintained since 2013)!

There is no reason « not » to use **vsphere_guest** to provision your virtual machine. Latest version of this module works for vSphere v5 and should work for 6.X. A good example of what can be done with this module can be found on this nice blog-post from [EverythingShouldBeVirtual][9].

Yet, you won’t be able to:

  * Modify the virtual machine (like vCPU, ...) if you generate it from a vm template
  * Customize it on the OS level (change hostname, IP, ...)

I massively use templates so this was clearly an issue. My typical usecase is this : I deploy a virtual machine from a given template (depending which type of service I want) and then finalize customisation through Ansible playbooks.

In this case, I would have to deploy my virtual machine, and still have to go into them to modify them (like hostname and IP) before playing my playbooks to customise them.

Hopefully, people at VMware didn’t stop at VIPerl and PowerCLI. It’s been a few years than there is a Python module, maintained by VMware, and regularly updated to take advantage of the new API functionnalities: [pyvmomi][10].

From there, a new Ansible module, taking advantage of this python API, you have much more possibilities.

## Let there be light

The list of Ansible modules taking advantage from **pyvmomi** is quite impressive. You can find them, they all start with **vmware_** (you can find the list on [the official Ansible documentation][11], VMware section).

Two of them particularly got my attention (but there are a lot more!):

  * [vmware_guest][12] can help manage virtual machines
  * [vmware\_vm\_shell][13] can execute commands directly inside the guest OS, provided it executes VMware Tools

### Prerequisites

To execute this modules, you need:

  * **pyvmomi** and its dependancies (python 2.6+ and sphinx)

```
pip install pyvmomi sphinx
```


  * **Ansible 2.2** minimum (but you’d better have 2.3 or even 2.4!)

<del datetime="2017-06-20T14:31:16+00:00">On paper, the module « works » with 2.2, the actual version on stable depots. But most interesting functions appear in 2.3 so for now you have to compile sources!~~

The actual version on RHEL/CentOS 7 is 2.3.X. You don’t need to compile sources anymore, UNLESS you need the very latest additions which can be found in 2.4. I give you the necessary steps at the end of the article.

## And now, the playbook !

The following playbook will:

  * ask you for a priviledged account for vCenter
  * deploy a virtual machine on the vCenter from a template

This deployment needs some variables that can be given directly from the Ansible host inventory like:

  * virtual disk size
  * vCPU number
  * vRAM quantity
  * target ESXi and target datasotre
  * VM IP address and hostname

The virtual machine will be deployed as expected, except for hostname and IP. Those 2 parameters will be modified after first boot by VMware Tool.

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
      line: '{{ item }}'
    with_items: '{{play_hosts}}'
    run_once: true
```


From there... well, you can do anything that pops in your mind!

## Useful links

« pause » module might be useful in some cases when you really have to wait some time. I don’t use it and I wouldn’t even consider it for production.

* [Pause Module][14]

Also, I might write the same article with the Proxmox VE module. Stay tuned!

* [Proxmox Kvm Module][15]

## New functionnalities

Until <del datetime="2017-06-20T14:31:16+00:00">2.3~~ 2.4 becomes available in your OS repository, you might encounter this error if you use functions that aren’t included (yet) in your own version of Ansible (**linked_clone** or **snapshot_src** released in 2.4 for example) :

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


Should you need a « yet to be released » functionnality, you can compile the latest version of Ansible from the sources (2.4 in my example here):

```
git clone https://github.com/ansible/ansible

cd ansible
make
make install

ansible --version
    ansible 2.4.0
```

 [7]: https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_guest_module.html
 [8]: https://github.com/argos83/pysphere
 [9]: http://everythingshouldbevirtual.com/creating-vsphere-vms-using-ansible
 [10]: https://github.com/vmware/pyvmomi
 [11]: https://docs.ansible.com/ansible/2.9/modules/list_of_cloud_modules.html
 [12]: https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_guest_module.html
 [13]: https://docs.ansible.com/ansible/latest/collections/community/vmware/vmware_vm_shell_module.html
 [14]: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/pause_module.html
 [15]: https://docs.ansible.com/ansible/latest/collections/community/general/proxmox_kvm_module.html
