---
title: 'Réinitialisation à eth0 l’indice de la carte Ethernet après clone CentOS / RHEL 6'
authors:
  - zwindler
type: post
date: 2016-02-20T19:00:58+00:00
url: /2016/02/20/nettoyage-carte-ethernet-apres-deploiement-dun-template-centos-rhel-6/
image: /2016/02/RedHatLogo.png
categories:
  - Système
  - Virtualisation
tags:
  - CentOS 6
  - eth0
  - ifconfig
  - net-rules
  - RHEL 6
  - VMware

---
## Après clone, la carte Ethernet s’appelle eth1 (ou plus) et pas eth0

Si vous avez essayé de faire de clones de machines virtuelles ou des déploiement de templates sous CentOS/RHEL 6, vous avez probablement remarqué qu’après déploiement, la carte réseau nouvellement créée ne s’appelle pas eth0 mais eth1.

Et le problème s’amplifie au fil des déploiements, car si vous clonez ou faites un modèle avec une machine dont la carte est devenue eth1, les suivantes auront pour indice eth2 et ainsi de suite.

Essayer de renommer à la main l’interface dans Network Manager fonctionne mal. Tenter de feinter le système avec l’_UUID_ ou l’_HWADDR_ de la « vraie » carte réseau via les scripts dans **/etc/system/network-scripts** ne donnera pas plus de résultats.

En réalité, le système garde en mémoire des traces de l’interfaces eth0 d’avant clonage. Ce comportement n’existait pas dans RedHat 5 et est corrigé dans RedHat 7.

## Solution manuelle

On peut quand même renommer l’interface via l’interface graphique mais il est nécessaire de réaliser quelques opérations complémentaires pour que cela fonctionne.

Dans le gestionnaire réseau, supprimer l’interface **System eth0** (qui n’existe plus) et renommer l’autre interface **Auto eth1** en **eth0** (juste eth0).

Enfin, exécuter les commandes suivantes

```
cd /etc/udev/rules.d
rm 70-persistent-net.rules
sed -i '/HWADDR*/d' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i '/UUID*/d' /etc/sysconfig/network-scripts/ifcfg-eth0
```


Si vous souhaitez juste résoudre le problème et pas refaire un template, vous pouvez rebooter la machine qui retrouvera un eth0 fonctionnel.

Pour éviter que le problème ne se reproduise, je conseille de toujours exécuter ces commandes puis d’éteindre la machine virtuelle avant transformation en template. Le problème n’apparaitra pas au déploiement des VMs provenant de ce template.

## Autre solution sur le même principe

Dans la VM qui va devenir un template, commenter les lignes dans /etc/udev/rules.d/70-persistent-net.rules et ajouter l’attribut immutable au fichier. Après extinction (ou reboot), le problème sera résolu.

```
chattr +i /etc/udev/rules.d/70-persistent-net.rules
```


## 3ème solution basée sur un script

La solution que je préfère car c’est celle qui est selon moi la plus « stable » dans le sens où on ne peut pas se tromper lors de l’exécution des opérations.

```
# Annoying bug in vmware guest centos6
# eth0 doesn't exist
ifconfig eth0 2>/dev/null >/dev/null
if [ $? -ne 0 ] ; then
       # Rename eth1 with eth0
       echo "UDEV Config..."
       rm /etc/udev/rules.d/70-persistent-net.rules
       # Change ifcfg-eth0 with hostname address (in /etc/hosts)
       echo "Changing eth0 address..."
       mac=`ifconfig eth1 | grep eth1 | awk '{ print $5}'`
       hostname=`hostname`
       ip=`grep $hostname /etc/hosts|cut -s -f 1`
       rm -f /etc/sysconfig/network-scripts/ifcfg-eth1
       cfg=`grep -v IPADDR /etc/sysconfig/network-scripts/ifcfg-eth0 |grep -v HWADDR`
       echo "$cfg" > /etc/sysconfig/network-scripts/ifcfg-eth0
       echo "HWADDR=\"$mac\"" >> /etc/sysconfig/network-scripts/ifcfg-eth0
       echo "IPADDR=\"$ip\"" >> /etc/sysconfig/network-scripts/ifcfg-eth0
       # Apply changes
       echo "Applying changes..."
       service network stop
       service NetworkManager stop
       ifconfig eth1 down
       udevadm trigger
       udevadm control --reload-rules
       service network start
       service NetworkManager start
```


Procédure tirée du [Cyberciti.biz][1]

 [1]: https://www.cyberciti.biz/tips/vmware-linux-lost-eth0-after-cloning-image.html
