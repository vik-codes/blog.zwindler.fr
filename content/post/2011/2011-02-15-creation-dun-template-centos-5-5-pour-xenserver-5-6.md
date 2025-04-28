---
title: 'Création d’un template CentOS 5.5 pour XenServer 5.6'
authors:
  - zwindler
type: post
date: 2011-02-15T21:46:29+00:00
url: /2011/02/15/creation-dun-template-centos-5-5-pour-xenserver-5-6/
image: /2011/02/citirx-xenserver11.jpg
categories:
  - Virtualisation
tags:
  - appliance
  - CentOS
  - netinstall
  - Shinken
  - template
  - XenServer

---
Depuis quelques temps, ma solution de virtualisation est en place, mes VMs ronronnent, et je me suis lancé un peu plus profondément dans la supervision et tout ce qui s’en approche. Ceux qui lisent mes lignes de temps à autres sauront que j’avais déjà travaillé sur EyesOfNetwork et Nagios, mais j’ai voulu m’attaquer à quelque chose de nouveau et (à mon avis) mieux pensé.

Je parle bien évidemment de l’épopée Shinken, démarrée par un gars de la région, qui a aussi fait mon école, et dont je suis la progression depuis maintenant un moment (pratiquement le début en fait, même si ca à souvent été d’un œil distrait). Seulement voilà, pour pouvoir tester Shinken au maximum de ses capacitées, j’ai besoin de plusieurs VM vierges.

Fini l’époque bénie des VMs construites sur l’envie du moment : j’en ai marre! Il à donc bien fallut s’y résoudre : Créer des templates pour déployer rapidement (et proprement) un réseau complet.

Donc rien de bien « techniquement agressif » (comme dirait l’autre) aujourd’hui, je vous propose un petit tuto pour créer de bout en bout un template CentOS 5.5 sur un XenServer 5.6 (qui ne supporte théoriquement que CentOS jusqu’à 5.4 même si nous verrons que ce n’est vraiment pas un problème).

La première chose à faire pour créer un template c’est de commencer par créer la VM qui nous servira de modèle. Ceux qui auront toujours la même version 5.6 de XenServer que moi s’apercevront qu’il n’y a pas de template prédéfini pour CentOS 5.5. Nous prenons donc un 5.4, ça ne pose pas de problèmes dans le cas d’une installation par le Net (ce que je présenterai ici). Dans le cas d’une installation par l’iso, je crois que c’est plus problématique, et qu’il n’y a pas vraiment de solution à par installer via un DVD 5.4 puis changer de version par la suite (à vérifier).

![](/2011/02/new_vm.png)

Comme je l’ai sous-entendu plus haut, je vais profité du fait qu’il est possible d’installer CentOS via HTTP pour pouvoir disposer directement d’une version CentOS 5.5 dans ma VM.

![](/2011/02/install_url.png)

Dans le cas où vous passez par un DVD, il est possible de réaliser cette installation par le net de la même façon, en sélectionnant le média FTP ou HTTP lors de l’installation.

  * URL : mirrors.centos.org
  * Directory : centos/5.5/os/x86_64

CentOS se met donc à s’installer sur la VM, une fois que vous avez répondu à toutes les questions. Pour tous les paramètres réseaux, comme il s’agit d’un template, il vaut mieux se contenter de garder des paramètre simple : Si possible, laisser le DHCP, on pourra reconfigurer l’IP de la VM au cas par cas sans risquer de provoquer de conflit d’IP lors de gros déploiement.

Si tout se passe bien, il fini par rebooter au bout d’un moment. La première chose à faire une fois que la VM est fonctionnelle, c’est d’installer les XenServer-Tools. En effet, ce sont eux qui permettent à la VM d’être complètement « consciente » de son état de VM et donc d’atteindre ~~l’ataraxie~~ la paravirtualisation (gain de performance et gain en contrôle sur la VM). Par défaut, ces XenServer Tools sont situées dans un iso que l’on monte donc sur la VM.

![](/2011/02/xs-tools.png)

Et on lance les commandes suivantes pour monter et exécuter le programme d’installation :

```
mkdir /mnt/cdrom
mount /dev/xvdd /mnt/cdrom
/mnt/cdrom/Linux/install.sh
```

Une fois le programme installé, un reboot s’impose! Selon les gouts « shutdown -r now » ou « init 6 ». Une fois que c’est fait, il faut mettre son système à jour avec « yum upgrade », et pourquoi pas installer tous les produits et logiciels indispensable à tout votre parc? Pourquoi pas non plus ajouter des repos additionnels tant qu’on y est (cf cette page du [wiki.centos.org (lien mort, remplacé par Internet Archive)](https://web.archive.org/web/20150811012515/http://wiki.centos.org/AdditionalResources/Repositories))?

```
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -K rpmforge-release-0.5.2-2.el5.rf.*.rpm
rpm -i rpmforge-release-0.5.2-2.el5.rf.*.rpm
```

et

```
yum list htop
```

pour vérifier que l’importation à bien fonctionné (d’ailleur il y a la base des rpms dispo qui devrait se reconstruire dans la foulée)

![](/2011/02/rpmforge.png)

Voilà, on a maintenant le parfait candidat pour un template! Pour pouvoir le créer, on doit éteindre la VM. Pour créer ce template, on a plusieurs possibilités. D’abord, on peut créer une Appliance, qui est en fait un template destiné à être exporté sur le web dans un format standardisé (.ovf). Typiquement, ce mécanisme est utilisée par des personnes qui fournissent une VM fournissant un service préinstallé, ou, dans le cas de la virtualisation VMware, par les utilisateurs de ESXi sans vCenter pour contourner l’absence de cette fonctionnalité :-p (je ferai un article là dessus bientôt).

![](/2011/02/appliance.png)

Sinon on peut aussi convertir la VM en un template (opération « définitive ») et elle n’apparaitra plus dans la liste comme une VM mais bien comme un template. C’est ce que je vais faire ici.

Il est désormais possible de créer très rapidement des VMs à partir de ce template. Les seules choses à modifier une fois le déploiement terminés sont donc

  * le hostname (bah oui, c’est quelque chose d’unique!)
  * supprimer l’interface eth0.bak créée par XenServer lors du déploiement
  * et éventuellement modifier les infos IP de la machine

```
rm /etc/sysconfig/networking/devices/ifcfg-eth0.bak
rm /etc/sysconfig/network-scripts/ifcfg-eth0.bak
system-config-network
service network restart
```
