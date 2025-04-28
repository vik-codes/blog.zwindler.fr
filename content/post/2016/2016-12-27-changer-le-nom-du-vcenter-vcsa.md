---
title: Changer le nom du vCenter 6 (vCSA)
authors:
  - zwindler
type: post
date: 2016-12-27T12:55:00+00:00
url: /2016/12/27/changer-le-nom-du-vcenter-vcsa/
image: /2016/11/vcenter.png
categories:
  - Virtualisation
tags:
  - cli
  - ESX(i)
  - Hidden Console
  - vCenter
  - vCSA
  - vCSA 6
  - VMware

---
## Changer le nom du vCenter, facile ?

La version 6 de l’appliance vCSA est sortie depuis un moment déjà (début 2015). Et pas mal de choses ont changés depuis les premières versions [que j’ai pu tester](/recherche/?keyword=vcsa) ! Au début, c’était moins léché, peu efficace (un SUSE très gourmand en RAM et avec moins de fonctionnalités). Et puis au fur et à mesure des versions, ça s’est amélioré.

Si vous souhaitez un tutoriel sur l’installation du vCSA 6, je vous conseille d’aller voir [le très bon vladan][2].

Dans les versions précédentes, j’ai souvent du me connecter sur le shell du Linux pour modifier des paramètres qui ne pouvaient pas être modifiés autrement, comme [le layout du clavier (Qwerty par défaut !)](/2015/04/08/changer-le-clavier-qwerty-par-defaut-de-lappliance-vcenter-vcsa-de-5-0-a-5-5/) ou [la quantité de RAM allouée à chaque composants du vCSA pour réduire son empreinte mémoire](/2013/05/07/reduire-la-ram-consommee-par-la-vmware-vcenter-appliance-5-1/).

Dans cette nouvelle version, une surcouche a été ajoutée en console, ce qui change drastiquement l’administration ! Pour les non linuxiens, c’est certainement plus simple.

Je me suis donc demandé comment changer le hostname du vCenter que je venais d’installer. Et la première chose que j’ai tentée a été de retrouver un bash, pour rester dans ce que je connaissais.

## Bash 2 en 1

Voilà à quoi ressemble la console lorsqu’on s’y connecte.

```
VMware vCenter Server Appliance 6.0.0.10000
Type: vCenter Server with an embedded Platform Services Controller
Using keyboard-interactive authentication.
Password:
Last login: xxx from xxx
Connected to service

* List APIs: "help api list"
* List Plugins: "help pi list"
* Enable BASH access: "shell.set --enabled True"
* Launch BASH: "shell"
```


A première vue, on peut toujours lancer un **bash**. Chouette !

```
Command> shell
Shell is disabled.
```


Ok...

```
Command> shell.set --enabled True
Command> shell
---------- !!!! WARNING WARNING WARNING !!!! ----------

Your use of "pi shell" has been logged!

The "pi shell" is intended for advanced troubleshooting operations and while
supported in this release, is a deprecated interface, and may be removed in a
future version of the product.  For alternative commands, exit the "pi shell"
and run the "help" command.

The "pi shell" command launches a root bash shell.  Commands within the shell
are not audited, and improper use of this command can severely harm the
system.
```


C’est donc clair. Le shell est encore là, pour l’instant. Mais il faut explicitement l’activer pour l’utiliser et il est clairement indiqué que ce n’est pas comme cela qu’il faut administrer votre vCSA car cette possibilité (dépréciée) sera probablement retirée à l’avenir.

## La nouvelle façon d’administrer la console

Du coup, retour en mode non-bash pour jeter un œil aux possibilités offertes par la nouvelle méthode d’administrer en CLI le vCSA.

```
Command> help api list

Supported API calls by this server:
com.vmware.appliance.version1.access.consolecli.get
com.vmware.appliance.version1.access.consolecli.set
com.vmware.appliance.version1.access.dcui.get
com.vmware.appliance.version1.access.dcui.set
com.vmware.appliance.version1.access.shell.get
com.vmware.appliance.version1.access.shell.set
com.vmware.appliance.version1.access.ssh.get
com.vmware.appliance.version1.access.ssh.set
com.vmware.appliance.version1.localaccounts.user.add
com.vmware.appliance.version1.localaccounts.user.delete
[...]
com.vmware.appliance.version1.services.list
com.vmware.appliance.version1.services.restart
com.vmware.appliance.version1.services.status.get
com.vmware.appliance.version1.services.stop
com.vmware.appliance.version1.system.update.get
com.vmware.appliance.version1.system.update.set
com.vmware.appliance.version1.system.version.get
com.vmware.appliance.version1.timesync.get
com.vmware.appliance.version1.timesync.set
```


On voit qu’il existe un nombre relativement important de commandes. En réalité, à bien regarder, cela correspond finalement à l’ensemble des opérations que l’on peut réaliser directement depuis l’interface graphique web.

Cela n’a donc rien à voir avec l’accès direct qu’on peut avoir sur un Linux en shell, ce qui d’expérience est pourtant utile. Une fois de plus, VMware nous enferme dans le mode boite noire, ce qui aura le don d’agacer les habitués du monde Linux/Unix.

Je ne vais pas tout traiter dans ce tutoriel et juste me concentrer sur l’exemple que je cite en début d’article. Pour autant, vous avez l’accès à l’ensemble de la documentation sur le site de VMware (lien mort comme tout chez VMware).

Les commandes sont assez explicites et assez simples, avec une commande « get » et « set » et des « --help » à chaque fois.

```
Command> com.vmware.appliance.version1.networking.dns.hostname.get
Name: toto01
Command> com.vmware.appliance.version1.networking.dns.hostname.set --help
Usage:
com.vmware.appliance.version1.networking.dns.hostname.set
[--help/-h] --name STR
Description:
Set the Fully Qualified Domain Name.
Input Arguments:
--name STR
FQDN.

Command> com.vmware.appliance.version1.networking.dns.hostname.set --name vcenter.zwindler.fr
Command> com.vmware.appliance.version1.networking.dns.hostname.get
Name: vcenter01.zwindler.fr
```


## Conclusion

Au final, c’est assez simple à utiliser, même si assez limité !

On ne peut pas dire que ce soit étonnant de la part de VMware : leur but, c’est bien entendu de faire un produit simple d’utilisation et éviter aux gens d’aller bidouiller.

Ainsi, il permettent au plus grand nombre d’administrer un vCenter sous Linux sans pour autant avoir des connaissances dans le domaine.  
Personnellement, ça me rappelle la [« hidden console » des ESXi](/2010/04/28/esxi-4-0-explorons-lhidden-console-part-1/) lors des premières releases, qu’on ne pouvait accéder qu’après une combinaison de touches.

A vos shells limités ! ;-)

 [2]: http://www.vladan.fr/install-vmware-vcsa-6-0/
