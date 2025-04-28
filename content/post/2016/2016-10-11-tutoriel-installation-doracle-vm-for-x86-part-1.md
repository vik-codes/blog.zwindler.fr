---
title: '[Tutoriel] Installation d’Oracle VM for x86 – partie 1'
authors:
  - zwindler
type: post
date: 2016-10-11T12:00:23+00:00
url: /2016/10/11/tutoriel-installation-doracle-vm-for-x86-part-1/
image: /2016/10/oracle-vm.png
categories:
  - Virtualisation
tags:
  - Oracle VM
  - Oracle VM for x86
  - Oracle VM Manager
  - OVMM
  - RHEL
  - RHEL 7
  - virtualisation

---
## Présentation d’Oracle VM

Dans le cadre d’un très sérieux **_Dossier de Choix de Solution d’Infrastructure_**, j’ai été amené à étudier la plateforme de virtualisation proposée par Oracle : **Oracle VM**.

Dans la lignée d’**Oracle Unbreakable Linux** qui est une copie de RHEL modifiée (les sources étant disponibles sur Internet car open source), Oracle tente depuis plusieurs années de pénétrer le marché de la virtualisation de serveur, sans jamais vraiment parvenir à percer. La faute à une concurrence trop forte de VMware et Hyper-V, trop loin en tête en adoption dans les entreprises et un retard fonctionnel conséquent, surtout dans les suites logicielles périphériques (internes ou tierces) de SDS, SDN, sauvegarde, VDI, cloud, etc etc.

Pourtant sur le papier, Oracle VM a de bons arguments pour séduire les administrateurs : un noyau robuste (RHEL + Xen), sans coût de licence et avec un coût de support (souscription comme chez Redhat) en 24×7 à 500$ / serveur / an en prix public, très en deçà de la concurrence moyenne !

Cerise sur le gâteau, **contrairement à l’ensemble des autres solutions de virtualisation x86**, Oracle permet de ne licencier que les vCPU réellement affectées aux VMs Oracle VM sur lesquelles sont installés des produits Oracle. Et c’est probablement là que le bat blesse. Dans bon nombre d’entreprises, Oracle est devenu synonyme d’audit et de changement de règles de licencing au petit bonheur la chance...

Ce sont quand même de sérieux atouts et je ne voyais pas passer outre un PoC pour me faire une idée du produit.

**Info :** Pour plus de lisibilité j’ai scindé l’article en 2 parties. Celle ci concerne les prérequis pour l’ensemble des composants et l’installation de la console (non trivial) et la seconde se concentrera sur la configuration de notre premier serveur (réseau, stockage, vms).

## Prérequis

### Oracle VM (virtualisation)

Pour la partie virtualisation, Oracle VM se base sur RHEL et Xen. Et ces deux composants sont peu gourmands et assez flexibles en terme de compatibilité matérielle. Vous n’aurez aucun mal à trouver un vieux serveur pour faire un PoC comme je l’ai fais.

On trouve assez facilement sur le site d’Oracle les valeurs minimum pour Oracle VM 3.4. A noter quand même que les liens qui remontent dans Google pointent parfois sur des versions antérieures. Attention donc.

<table>
  <tr>
    <td>
      Items 
    </td>
    <td>
      Minimum Value 
    </td>
  </tr>
  <tr>
    <td>
      Memory
    </td>
    <td>
      1.0 GB
    </td>
  </tr>
  <tr>
    <td>
      Processor Type
    </td>
    <td>
      64 bit i686 P4
    </td>
  </tr>
  <tr>
    <td>
      Processor Speed
    </td>
    <td>
      1.3 GHz x 2
    </td>
  </tr>
  <tr>
    <td>
      Available Hard Disk Space
    </td>
    <td>
      6 GB
    </td>
  </tr>
</table>

### Oracle VM Manager

Pour ce qui est de la console de management Oracle VM Manager, les prérequis sont par contre plus élevés, mais c’est malheureusement une habitude avec les consoles d’administration de plateforme de virtualisation (les premiers vCenter / appliances Linux plantaient dès qu’on passait sous les 8 Go de RAM).

<table>
  <tr>
    <td>
      Items 
    </td>
    <td>
      Minimum Value 
    </td>
  </tr>
  <tr>
    <td>
      Memory
    </td>
    <td>
      8.0 GB
    </td>
  </tr>
  <tr>
    <td>
      Processor Type
    </td>
    <td>
      64 bit
    </td>
  </tr>
  <tr>
    <td>
      Processor Speed
    </td>
    <td>
      1.83 GHz x 2
    </td>
  </tr>
  <tr>
    <td>
      Swap Space
    </td>
    <td>
      2.1 GB
    </td>
  </tr>
  <tr>
    <td>
      Hard Disk Space
    </td>
    <td>
      5.5 GB in /u01 
      3 GB in /tmp
      400 MB in /var
      300 MB in /usr
    </td>
  </tr>
</tbody>
</table> 
        
Vous trouverez la liste des OS compatible sur le site d’Oracle au même endroit que l’ISO pour Oracle VM Manager :

* Oracle Linux 5 Update 5 64-bit
* Oracle Linux 6 64-bit
* Oracle Linux 7 64-bit
* Red Hat Enterprise Linux 5 Update 5 64-bit
* Red Hat Enterprise Linux 6 64-bit
* Red Hat Enterprise Linux 7 64-bit
        
A noter, sans surprise, il peut s’agir soit d’une machine virtuelle soit d’un serveur physique.

## Installation
        
### Configuration d’Oracle VM Manager

Dans mon cas, j’ai installé OVMM sur un RHEL 7.
        
Il est nécessaire d’avoir (au moins localement) une résolution du nom de la machine qui héberge l’oracle VM Manager. Idéalement, il est préférable d’avoir une résolution de nom par DNS donc, mais à minima, vous devez avoir une entrée similaire au retour de la commande hostname dans votre fichier /etc/hosts :
    
```
# hostname
ovmm01.example.org
# vi /etc/hosts
[…]
192.168.100.10 ovmm01.example.org ovmm01
```
   
La documentation d’Oracle vous indique que selon votre contexte, vous pouvez soit désactiver complètement votre firewall soit ajouter les règles correspondantes. L’exemple donné dans la documentation (iptables) ne fonctionne pas avec firewalld installé par défaut sur RHEL 7. Voici les bonnes commandes :
        
```
firewall-cmd --get-active-zones
public
interfaces: eno16780032

firewall-cmd --permanent --zone=public --add-port=7002/tcpfirewall-cmd --permanent --zone=public --add-port=10000/tcp
firewall-cmd --permanent --zone=public --add-port=123/udp
firewall-cmd --reload

firewall-cmd --zone=public --list-ports

123/udp 10000/tcp 7002/tcp
```
        
Ou si vous n’avez peur de rien (et que c’est un serveur de test)

```
systemctl stop firewalld
systemctl disabled firewalld
```
  
Pour une bonne introduction avec les commandes firewalld je vous conseille [le post suivant](https://www.certdepot.net/rhel7-get-started-firewalld/)

### Prérequis complémentaires
 
Monter le fichier ISO sur le serveur sur lequel sera installé Oracle VM Manager. Oracle a mis au point un script qui permet de paramétrer les prérequis (utilisateur oracle, limites, /u01, …).

```
mount /dev/cdrom /mnt
cd /mnt
./createOracle.sh
Missing required package, Oracle VM Manager requires 'iptables-services' to be installed, you can use 'yum install iptables-services' to install it.
```
   
La encore, petit oubli d’Oracle ! Le script createOracle.sh utilise iptables et pas firewalld. Il ne fonctionne donc pas sur RHEL7 alors que cet OS est censé être supporté ! On ne peut pas utiliser ce script, il faut faire les modifications à la main (heureusement simples) !

```
mkdir /u01
chmod 755 /u01
groupadd dba
groupadd -g 54321 oinstall
useradd -u 54321 -g dba -G oinstall -d /home/oracle oracle
/bin/chown oracle:dba /home/oracle
vi /etc/security/limits.conf
  oracle       hard    nofile  8192
  oracle       soft    nofile  8192
  oracle       soft    nproc   4096
  oracle       hard    nproc   4096
  oracle       soft    core    unlimited
  oracle       hard    core    unlimited
```

Une fois les modifications réalisées, on peut lancer l’installeur à proprement parler.

### Installation du VM Manager

Lancer l’installeur présent sur l’ISO.

```
[root@ovmm01 mnt]#  ./runInstaller.sh
Oracle VM Manager Release 3.4.1 Installer
Oracle VM Manager Installer log file:
/var/log/ovmm/ovm-manager-3-install-2016-07-20-150727.log

Please select an installation type:
1: Install
2: Upgrade
3: Uninstall
4: Help

Select Number (1-4): 1

Verifying installation prerequisites ...
Conflicts when MySQL install. Oracle VM Manager requires 'mariadb-libs' to be uninstalled, you can use 'yum remove mariadb-libs' to uninstall it.
Configuration verification failed ...
```

Dans mon cas la première installation n’a pas fonctionné. Pour une raison que j’ignore, mon installation contenait déjà mariadb-libs dans une version entrant en conflit avec le MySQL embarqué par OVMM. Etrangement ils préfèrent qu’on utilise MySQL plutôt que MariaDB ;-). Je l’ai donc désinstallée comme demandé, mais attention aux dépendances qui sont désinstallées dans la foulée !
        
```
yum remove mariadb-libs
```

Et on recommence...

```
Verifying installation prerequisites ...
Starting production with local database installation ...
One password is used for all users created and used during the installation.
Enter a password for all logins used during the installation:
Invalid password.
Passwords need to be between 8 and 16 characters in length.
Passwords must contain at least 1 lower case and 1 upper case letter.
Passwords must contain at least 1 numeric value.
```

> Tu pouvais pas me le dire avant ? ;-)

```
Enter a password for all logins used during the installation:
Enter a password for all logins used during the installation (confirm):
********

Please enter your fully qualified domain name, e.g. ovs123.us.oracle.com, (or IP address) of your management server for SSL certification generation, more than one IP address are detected: 192.168.20.94 192.168.122.1 [ovmm01.example.org]:  ovmm01.example.org

Verifying configuration ...

Start installing Oracle VM Manager:

1: Continue
2: Abort

Select Number (1-2): 1

Step 1 of 7 : Database Software ...
Installing Database Software...
[...]

Oracle VM Manager UI:
https://ovmm01.example.org:7002/ovm/console
```

Vous pouvez maintenant vous connecter à l’URL donnée en fin d’installation.

![](/2016/10/Oracle-VM-manager_login.png)

## Sources

* [docs.oracle.com/cd/E64076_01/](http://docs.oracle.com/cd/E64076_01/)
* [www.oracle.com/technetwork/server-storage/vm/downloads/index.html](http://www.oracle.com/technetwork/server-storage/vm/downloads/index.html)
* [docs.oracle.com/cd/E64076_01/E64078/html/index.html](http://docs.oracle.com/cd/E64076_01/E64078/html/index.html)
* [docs.oracle.com/cd/E64076_01/E64078/html/vmiug-server-installation.html](http://docs.oracle.com/cd/E64076_01/E64078/html/vmiug-server-installation.html)
