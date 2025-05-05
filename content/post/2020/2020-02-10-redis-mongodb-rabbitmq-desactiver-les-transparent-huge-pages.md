---
title: Redis, MongoDB, RabbitMQ, désactiver les Transparent Huge Pages
authors:
  - zwindler
type: post
date: 2020-02-10T07:30:00+00:00
excerpt: Explication de ce que sont les transparent Huge pages et surtout comment les désactiver sur vos serveurs Linux
url: /2020/02/10/redis-mongodb-rabbitmq-desactiver-les-transparent-huge-pages/
image: /2020/01/mememe_1aa1a73fcaf242fa2e2642bfd90ccb42-1.jpg
classic-editor-remember:
  - classic-editor
categories:
  - systeme
tags:
  - couchbase
  - CPU
  - hugepages
  - kafka
  - Linux
  - mémoire
  - mmu
  - redis
  - transparent hugepages

---
 


## Transparents Huge Pages
  
Les THP et moi, ça remonte à quelques années (i.e.n un brouillon qui traîne depuis longtemps); Mais j’ai de nouveau eu besoin de toucher aux Transparent Huge Pages il y a peu donc c’est une bonne occasion de m’y remettre.

[Redis](https://redis.io/topics/admin), [MongoDB](https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/), RabbitMQ, Kafka... Tout ces logiciels vous demandent, à l’installation ou dans la documentation, de désactiver ce paramètre système de vos serveurs Linux.

> 01-07-2020 03:46:32.730 +0000 WARN ulimit - ulimits: This instance is running on a machine that has kernel transparent huge pages enabled. This can significantly reduce performance and is against best practices. Turn off kernel transparent huge pages using the method that is most appropriate for your Linux distribution.
> Même dmesg me dit de le désactiver :'(

Dans cet article, je vais vous montrer à quoi ça sert, mais surtout comment on va faire pour le désactiver (le plus proprement possible).

## Mais au fait, c’est quoi ?
  
Avant de lui couper la chique, le mieux c’est quand même peut-être de savoir de quoi il s’agit avant de respecter les précos des éditeurs.

Note : Ca me fait penser à [SELinux, la première chose qu’on nous demande de désactiver quand on installe un progiciel sur RHEL et qu’on connaît au final assez mal...](/2016/10/26/comprendre-configurer-selinux-rhel-7/)

Pour faire bref, la gestion de la mémoire par le CPU passe par une couche d’abstraction : la mémoire est découpée en pages de taille fixe (par défaut 4ko) et le CPU garde une table de correspondance de ces pages dans la MMU.

Pour des raisons de performance, il peut être intéressant, sur nos systèmes récents ayant beaucoup de RAM, d’avoir des pages plus grosses pour faciliter le travail du CPU (aka des "huge pages"). Cependant, il est nécessaire de modifier le code de l’application pour tirer parti des HugePages. Arrive alors une autre couche d’abstraction, les Transparent Huge Pages. Vous avez deviné, pour faire ça de manière transparente !

Je vous met en bas de l’article quelques liens pour comprendre en détail de quoi on parle.

## Oneshot
  
  
Maintenant qu’on sait ce que c’est, on peut le désactiver en tout quiétude.

Déjà, on va commencer par vérifier l’état de notre OS, pour savoir un peu où on en est au niveau des THP. Pour ça, un simple cat de _/sys/kernel/mm/transparent_hugepage/enabled_ nous donnera l’info :


```
cat /sys/kernel/mm/transparent_hugepage/enabled
[always] madvise never
```

Il existe 3 valeurs possibles pour ce paramètre : _always_, _madvise_ et _never_. always et never sont simples à comprendre, et pour ce qui est de madvise, il s’agit d’un paramètre intermédiaire qui dit que par défaut, les THP sont désactivées, mais que les applications peuvent utiliser un appel "madvise" pour allouer des THP dans la zone mémoire réservée pour ça.

Ici, on va donc vouloir désactiver les THP totalement (donc _never_).

Pour se faire, on peut simplement utiliser la commande suivante :


```
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```



Attention cependant, le paramètre ne sera pris en compte que jusqu’au prochain reboot.

## Les méthodes classiques pour désactiver durablement les THP
  
  
A partir de là, on va vouloir le désactiver pour les prochains boots. On va donc devoir indiquer d’une manière ou d’une autre à l’OS qu’il faut désactiver ce paramètre, activé par défaut.

La plupart des logiciels vous conseillent de faire un service qui ne fait que ça et qui sera lancé au démarrage de votre machine (ex. [vertica](https://www.vertica.com/docs/9.2.x/HTML/Content/Authoring/InstallationGuide/BeforeYouInstall/transparenthugepages.htm), [couchbase](https://docs.couchbase.com/server/current/install/thp-disable.html), ...).

Je suis pas fan, je trouve que modifier un paramètre au démarrage ne devrait pas se faire comme ça.

La façon la plus "propre" de le faire est probablement de modifier la configuration du bootloader (souvent GRUB). Si vous avez GRUB, c’est assez facile de le faire puisque c’est une option à ajouter dans le grub :


```
cat /etc/default/grub
[...]
GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0 earlyprintk=ttyS0 rootdelay=300"
GRUB_CMDLINE_LINUX=""
[...]

## APRES
cat /etc/default/grub
[...]
GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0 earlyprintk=ttyS0 rootdelay=300 transparent_hugepage=never"
GRUB_CMDLINE_LINUX=""
```



Cependant, cette méthode nécessite de reconstruire votre fichier grub (avec grub2-mkconfig) donc j’imagine que c’est pour cela que cette méthode n’est pas mise en avant.

## Une méthode alternative pour désactiver les transparent Huge Pages
  
  
Si vous ne vous sentez pas de modifier votre bootloader et que vous n’aimez pas, comme moi, l’idée de faire un service pour faire un echo au boot, il reste une dernière possibilité.


```
apt install sysfsutils
echo "kernel/mm/transparent_hugepage/enabled = never" >> /etc/sysfs.conf
echo "never" >> /sys/kernel/mm/transparent_hugepage/enabled
```



L’avantage, c’est que, contrairement à la modif du GRUB, ça va être ultra simple du coup d’automatiser ça avec Ansible. Je vais pouvoir intégrer la modification dans mes playbooks d’installation des logiciels cités en début d’article !


```
---
- hosts: all
  become: yes
  tasks:
  - name: "Install sysfsutils"
    apt:
      name: "{{item}}"
      state: present
    loop:
    - sysfsutils
  - name: "Disable permanently Transparent Huge Pages"
    lineinfile:
      path: /etc/sysfs.conf
      line: kernel/mm/transparent_hugepage/enabled = never
  - name: "Disable THP for this boot"
    shell: "echo 'never' >> /sys/kernel/mm/transparent_hugepage/enabled"
```



Et voilà :D



## Sources
  
  
* [Settling the Myth of Transparent HugePages for Databases](https://www.percona.com/blog/2019/03/06/settling-the-myth-of-transparent-hugepages-for-databases/)
* [How to use, monitor, and disable transparent hugepages in Red Hat Enterprise Linux 6 and 7?](https://access.redhat.com/solutions/46111)
* [Disabling THP with Ansible](https://stackoverflow.com/questions/51246128/disabling-thp-transparent-hugepages-with-ansible-role)
