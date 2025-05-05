---
title: Réduire la RAM consommée par VMware vCenter Server Appliance 5.1 (vCSA 5.1)
authors:
  - zwindler
type: post
date: 2013-05-07T15:49:57+00:00
url: /2013/05/07/reduire-la-ram-consommee-par-la-vmware-vcenter-appliance-5-1/
image: /2015/07/vCSA.jpg
categories:
  - Logiciel
  - systeme
  - Virtualisation
tags:
  - DB2
  - JVM
  - Novell Suse
  - PostgreSQL
  - Tuning JVM
  - Tuning RAM
  - vCenter
  - vCenter Server Appliance
  - vCSA 5.1
  - vma
  - VMware
  - VMware SSO
  - VMware tools
  - vSphere 5.1

---
Dans le cas où vous auriez la possibilité d’avoir un vCenter pour piloter votre/vos ESXi, vous avez probablement déjà installé vCenter sur un serveur Windows 2003/2008 qui traine (ou une VM), car ça a longtemps été le seul OS capable d’éxécuter l’installeur du vCenter.

C’était vraiment dommage, surtout quand on sait que ce n’est qu’une bête application Java derrière un Tomcat. Heureusement, après avoir vomi leur rage de Windows pendant des années sur les forums, les développeurs de chez VMware ont enfin pris le temps de penser aux Unixiens et réaliser un portage sous Linux. Il s’agit en fait d’une appliance prête à déployer (Novell Suse en l’occurrence pour l’appliance 5.1).

Après un bref passage sur le véloce (\*ironie\*) site de VMware, et un prompt téléchargement de ladite appliance, il est temps de la déployer sur notre hyperviseur préféré!

Une fois déployée, merci donc de jeter un petit coup d’œil sur la config de l’appliance vCSA (vCenter Server Appliance), ainsi que sur ce site :

* [KB VMware (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20151121173538/http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2005086)

Pourquoi je dis ça? Parce que moi lorsque je l’ai déployé et lancé sans me poser de question, j’ai entendu les disques grater. Mon ESXi s’est rapidement mis à swapper la RAM active de mes VMs... Oui, je n’ai qu’un petit lab avec 8Go de RAM, et l’appliance prend par défaut ... 8Go de RAM!!!

Voyons voir ce qu’on peut faire pour y remédier...

Déjà, commencez par configurer l’appliance avec un peu moins de RAM, disons 4Go pour commencer (moi j’en suis à 3, et je pense qu’on peut encore faire mieux en désactivant certains composants).

Démarrez la. Une fois la VM lancée, configurer le vCenter en suivant le programme d’installation. Je ne couvrirai pas cette partie, de nombreux blogs le font déjà.

Une fois le serveur configuré et que nous sommes logués dessus en console, on remarque tout de suite qu’on a quand même pas mal d’espace pour swapper au cas où Java prendrait un peu trop ses aises !

```
free -m
    total       used       free     shared    buffers     cached
    Mem:          3017       2939         77          0          3        139
    -/+ buffers/cache:       2797        219
    Swap:        15366       1206      14160
```


Le seul travail qu’à fait VMware ici, c’est faire rentrer un multitude d’applications serveurs Java pour héberger les différents services qui composent la suite vSphere 5.1. Et quand on connait la gloutonnerie de Java...

Pour trouver les billes pour réduire la quantité de RAM consommée par cette appliance, je me suis basé sur une partie de la blogosphère qui traite malheureusement majoritairement de la version précédente de l’appliance (v5), et notamment cet article sur [squishnet.org (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150401141357/http://www.squishnet.com/?p=375).

**Tuning de la base de données**

Dans les préconisations des blogueurs qu’on peut y voir parler d’une base DB2. Or à priori, depuis la 5.1, VMware utilisent maintenant une base PostGreSQL

```
df
    Filesystem     1K-blocks    Used Available Use% Mounted on
    /dev/sda3       10179904 4268324   5394460  45% /
    udev             1544716     104   1544612   1% /dev
    tmpfs            1544716       0   1544716   0% /dev/shm
    /dev/sda1         130888   20994    103136  17% /boot
    /dev/sdb1       20641788  176200  19416948   1% /storage/core
    /dev/sdb2       20641788  409008  19184140   3% /storage/log
    /dev/sdb3       20635732  319156  19268336   2% /storage/db
```


Je commence donc par tuner la mémoire kernel pour PostgreSQL (plus d’infos sur http://www.postgresql.org/docs/9.2/static/kernel-resources.html)

```
vi /etc/sysctl.conf
    kernel.shmall = 524288
    kernel.shmmax = 2147483648

sysctl -w kernel.shmmax=2147483648
sysctl -w kernel.shmall=524288
```


**Tuning des JVM**

Une fois que c’est fait, on peut maintenant s’attaquer au plus gros problème de cette appliance, les réservations ridicules de mémoires pour l’ensemble des composants Java

```
vi /usr/lib/vmware-vsphere-client/server/bin/dmk.sh
JAVA_OPTS="$JAVA_OPTS -Xmx512m -Xms512m -XX:PermSize-128m"
```


En plus des tweaks qui sont proposés, j’ai regardé les processus Java en cours de fonctionnement, et ai remarqué que le serveur VMware SSO consomme 2Go à lui seul.

```
ps -ef | grep ssod
[...] -Xms2048m -Xmx2048m [...]

2Go! -_- Même pas en rêve... Personnellement je ne l'utilise même pas dans mon lab, il faudrait que le trouve comme le couper carrément mais en attendant j'ai mis

vi /usr/lib/vmware-sso/bin/setenv.sh
[...] -Xms256m -Xmx512m [...]
```


Une fois que c'est fait, j'ai aussi remarqué qu'on pouvait modifier le fichier de conf de l'Inventory Service (dans le cadre d'un petit parc d'ESXi et de VMs), ainsi que le composant SPS (VMware vSphere Profile-Driven Storage Service) et les options par défaut des composants vpx.

```
vi /usr/lib/vmware-vpx/inventoryservice/wrapper/conf/wrapper.conf
    # Initial Java Heap Size (in MB)
    wrapper.java.initmemory=256
    # Maximum Java Heap Size (in MB)
    wrapper.java.maxmemory=1024
vi /usr/lib/vmware-vpx/sps/wrapper/conf/wrapper.conf
    # Initial Java Heap Size (in MB)
    wrapper.java.initmemory=256
    # Maximum Java Heap Size (in MB)
    wrapper.java.maxmemory=512
vi /etc/vmware-vpx/tomcat-java-opts.cfg
    -Xmx512m -XX:MaxPermSize=256m -Dvim.logdir=/var/log/vmware/vpx
```


**Aftermath (littéralement "après les maths")**

Après un redémarrage complet (un reboot est le plus crade mais le plus simple), les JVM devraient se tenir un peu plus à carreau. Je ne dis pas que tout fonctionne, car je n'ai pas tout testé (notamment le VMwareSSO pour lequel j'ai de sérieux doutes vu la quantité de RAM demandé à la base et le peu que je lui ai mis), mais le client VMware lourd ainsi que la version web répondent très bien.

Voici donc la liste des process java/vmware qui tournent sur la machine après tuning/reboot

```
/usr/lib/vmware-vpx/sps/wrapper/bin/./wrapper /usr/lib/vmware-vpx/sps/wrapper/bin/../conf/wrapper.conf (wrapper de vmware-sps)
/usr/java/jre-vmware/bin/java -Xms256m -Xmx512m (vmware-sps)

/usr/lib/vmware-vpx/inventoryservice/wrapper/bin/./wrapper /usr/lib/vmware-vpx/inventoryservice/wrapper/bin/../conf/wrapper.conf (wrapper de vpx/inventoryservice)
/usr/java/jre-vmware/bin/java -XX:PermSize=128m -XX:MaxPermSize=256m -Xms256m -Xmx1024m (vpx/inventoryservice)

/usr/java/jre-vmware/bin/java -Xmx512m -Xms512m -XX:PermSize=128m -XX:MaxPermSize=256m -XX:MaxPermSize=256m (vmware-vsphere-client/server dans /usr/lib/vmware-vsphere-client/server/bin/dmk.sh)
/usr/java/jre-vmware/bin/java -XX:MaxPermSize=256M -Xms512m -Xmx512m (vmware-sso/webapps  dans /usr/lib/vmware-sso/bin/setenv.sh)
```


Processus auquels je n'ai pas touché car je ne suis pas vraiment certain de l'eur utilité et que ça ne mange pas beaucoup de RAM

```
/usr/java/jre-vmware/bin/java -Xms128m -Xmx512m (vmware-logbrowser ou com.vmware.vide.ws.server ?)
/usr/java/jre-vmware/bin/java -XX:PermSize=64M -Xmx512m -XX:MaxPermSize=256m (vfabric-tc-server-standard et son watchdog perso)
```


En tout cas dans mon lab, c'est indéniablement mieux que lorsque j'avais la RAM de mon host en train de swapper ;-)

**BONUS TRACK : VMware Tools**

Pour finir de tuner cette appliance, j'en profite pour référencer la solution permettant de résoudre le soucis "vmware tools non reconnus" de la machine virtuelle par l'hôte, à l'aide des précieuses instructions de virtuallyghetto http://www.virtuallyghetto.com/2011/07/tips-and-tricks-for-vma-5.html

```
/etc/init.d/vmware-tools-services stop
cp VMwareTools-9.0.0-782409.tar.gz /tmp/
cd /tmp
tar xzf VMwareTools-9.0.0-782409.tar.gz
cd vmware-tools-distrib
./vmware-install.pl
```


Accepter toutes les valeurs par défaut, et **ignorer l'erreur** lorsque l'installeur indique que gcc n'est pas présent car il n'est pas nécessaire. Après ça, le client VMware Tools sera bien affiché comme **à jour** dans l'interface vSphere.
