---
title: 'Tuning de l’IO Scheduler sous RHEL 4, 5, 6 ou 7 : CFQ, NOOP, Deadline'
authors:
  - zwindler
type: post
date: 2016-01-23T11:30:02+00:00
url: /2016/01/23/tuning-de-lio-scheduler-rhel-4-5-6-7-cfq-noop-deadline/
image: /2016/02/RedHatLogo.png
categories:
  - systeme
tags:
  - CFQ
  - Deadline
  - E/S
  - I/O
  - NOOP
  - RHEL 4
  - RHEL 5
  - RHEL 6
  - RHEL 7
  - SATA
  - scheduler

---
## Options d’IO Scheduler introduites depuis RHEL 4

Par hasard, en cherchant des informations sur des paramètres OS qu’on ne change pour ainsi dire jamais car ceux par défauts font très bien le job dans 99+% des cas, je suis tombé sur un article qui explique les différents modes offerts par RHEL sur le tuning de l’IO Scheduler et les différents impacts que cela peut avoir, notamment dans le cas de machines virtuelles.

J’insiste sur le fait que je ne pense pas que ce soit un sujet qui mérite un changement urgent et radical de votre infrastructure car comme le dit la devise :

> If it ain’t broke, don’t fix it.

Pour autant, j’ai trouvé les différents articles que j’ai lus sur le sujet extrêmement intéressants et j’ai voulu partager cette réflexion en Français.

## Le problème

D’abord, de quoi on parle ?

Comme je le disais en introduction, en cherchant des informations sur des paramètres kernel exotiques (tcp\_rmem/tcp\_wmem, tcp\_window\_scaling) dans le cadre d’un tuning fin pour une instance Oracle, je suis tombé sur cet article dans le [RedHat Magazine de juin 2008][1].

Il est question, à l’époque, d’une fonctionnalité amenée par le kernel linux 2.6, alors nouveau dans RHEL 4 : la possibilité de modifier l’algorithme de traitement des files d’entrée/sortie disques.

On y apprend que dans certains workloads I/O bien spécifiques, l’algorithme de scheduling n’est pas forcément optimal et que pour donner plus de liberté à l’administrateur, des profils distincts ont été ajoutés :

> Completely Fair Queuing—elevator=cfq (default)  
> Deadline—elevator=deadline  
> NOOP—elevator=noop  
> Anticipatory—elevator=as

L’article explique dans les grandes lignes ce que font ces différents algorithmes, ainsi que les avantages et les inconvénients de chaque, notamment en terme de performance grâce à un bench.

### CFQ

Complete Fair Queuing : comportement par défaut jusqu’à RHEL 6.

Le CPU gère les E/S par processus et les réparties équitablement. Ce mode a longtemps été considéré comme le meilleur compromis entre performances et latence des E/S.

### Deadline

Impose une limite maximale en temps de latence pour chaque E/S. Les E/S sont réordonnées parmi 5 files de traitement et celles dont la _deadline_ va bientôt expirer sont traitées en priorité, même s’il faut l’intercaler au milieu d’un grosse écriture séquentielle. On obtient ainsi un ressenti de quasi temps réel pour toutes les E/S.

Ce mode est à privilégier dans le cas de bases de données où les écritures sont intensives. Deadline est aussi moins complexe que CFQ et donc moins consommateur en cycles CPU que CFQ (+ latence).

### NOOP

Simplifie le traitement des E/S par le CPU en n’utilisant qu’une simple file de type « first in first out ». On améliore la charge CPU induite par les E/S tout en perdant le gain qu’apporte l’agencement intelligent de ces E/S (et on impacte donc les performances).

A priori, ce mode est également intéressant dans le cadre d’utilisation de SSD, car les secteurs à lire/modifier peuvent être accédés quasi instantanément, contrairement aux disques durs classiques qui subissent eux des latences à cause de la rotation des plateaux (le temps que le bras arrive sur le secteur). Cette absence de latence supprime la nécessité d’optimiser l’ordonnancement des E/S vers le disque, permet d’économiser quelques cycles CPU et donc des latences inutiles.

### Bonus : AS - Anticipatory

Impose un petit délai d’attente pour toutes les E/S avec pour objectif de les agréger et/ou de réordonner les E/S en fonction de la « localité » des E/S sur les disques (en tenant compte de la rotation). A priori plus efficace sur les systèmes où les disques sont lents mais peut réduire le nombre E/S par secondes.

## Afficher/modifier le scheduler actuel

Le site officiel de RedHat donne les commandes pour modifier ce scheduler dans un chapitre d’une documentation dédiée au [tuning des serveurs RHEL 4 et plus qui font fonctionner des instances Oracle 9 et 10][2]. Ce qui est dommage dans cette page c’est qu’on n’en sait pas plus sur ces différents modes... mais [cette page traite du sujet][3] (et [ici pour RHEL 7 - Performance tuning Guide][4]). Bref j’ai trouvé l’information à plusieurs endroits.

Ce qu’il faut savoir, c’est qu’on peut afficher _par disque_ le scheduler actuel de la façon suivante (selon l’OS).

**RedHat 4**

Sur RedHat 4, on ne peut pas changer ce mode dynamiquement (disponible uniquement à partir de RHEL 5). La consultation/modification se fait au niveau du fichier /etc/grub.conf.

Exemple « par défaut » (CFQ implicitement)

```
title Red Hat Enterprise Linux AS (2.6.9-67.ELsmp)
root (hd0,0)
kernel /vmlinuz-2.6.9-67.ELsmp ro root=LABEL=/ rhgb quiet
initrd /initrd-2.6.9-67.ELsmp.img
```


Exemple avec le scheduler « Deadline » (explicitement)

```
title Red Hat Enterprise Linux Server (2.6.18-8.el5)
root (hd0,0)
kernel /vmlinuz-2.6.18-8.el5 ro root=/dev/sda2 elevator=deadline
initrd /initrd-2.6.18-8.el5.img
```


**RedHat 5 et 6**

```
cat /sys/block/sda/queue/scheduler #pour afficher sur /dev/sda
noop anticipatory deadline [cfq]

echo sched_name > /sys/block/sdx/queue/scheduler #pour modifier, remplacer sched_name par le nom du scheduler
```


**RedHat 7 (machine virtuelle)**

Petite surprise lorsque j’ai lancé la commande, sur mes VMs RHEL 7, le scheduler est « **deadline** » par défaut et non plus CFQ.

```
cat /sys/block/sda/queue/scheduler #pour afficher sur /dev/sda
noop [deadline] cfq

echo sched_name > /sys/block/sdx/queue/scheduler #pour modifier, remplacer sched_name par le nom du scheduler```

```


En fait, depuis RHEL 7, le scheduler par défaut est toujours **CFQ** mais seulement lorsque l’OS détecte un disque SATA. Pour tous les autres types de disques, c’est **deadline**.

Les systèmes de stockage ont beaucoup évolués depuis RHEL 4 et il y a fort à parier que **deadline** fournit de meilleures performances des infrastructures récentes à base de SAS/RAID/Cache/SSD. CFQ ne se justifie donc plus que dans les cas où les disques sont des disques SATA simples.

## Et pour les VMs ?

En creusant un peu le sujet, je suis assez vite tombé sur cet article de **lonesysadmin** qui traite un point intéressant : [l’application de ce tuning au contexte des machines virtuelles][5]. Cet article fais partie d’une séries d’articles dédiés au tuning pour les machines virtuelles linux qui sont plutôt bien faits.

Le but de l’article de **lonesysadmin** est de rappeler le fonctionnement des IO Scheduler puis de soulever le problème que pose le comportement par défaut dans le cadre d’un système virtualisé.

> In the physical world, with operating systems on bare metal, we would choose an algorithm that is best suited to our workload. In the virtual world there is a hypervisor between the OS and the disks, and the hypervisor has its own disk queues. So what happens is:
> 
>   1. The VM has disk I/O occur.
>   2. The guest OS uses some CPU time to sort that I/O into an order it thinks is ideal, based on the disk algorithm that’s active.
>   3. The guest OS makes the requests to the underlying virtual hardware in that new order.
>   4. The hypervisor takes those requests and re-sorts them based on its own algorithms.
>   5. The hypervisor makes the requests to the actual hardware based on its own order.
> 
> Since the hypervisor is going to do its own sorting, into its own disk queues, there’s very little point in a guest OS attempting the same work. At the very least, the guest OS is introducing some latency and wasting some CPU cycles. At the worst it’s making things more difficult for the hypervisor and the back-end storage (see “I/O blender (lien mort)“). If we switch to the NOOP scheduler the guest OS will do as little as possible to the I/O before it passes it along, which sounds perfect for a virtual environment.

En Français :

  * la VM génère une E/S disque
  * l’OS de la VM consomme quelques cycles CPU pour décider dans quel ordre réaliser les E/S pour que l’écriture sur disque soit la plus efficace possible
  * l’OS de la VM traite les E/S dans l’ordre qui lui parait le plus efficace
  * l’hyperviseur récupère les E/S de toutes les VMs et les réorganisent lui même en fonction de ses propres algorithmes
  * l’hyperviseur traite les E/S

Dans ce schéma de figure, **lonesysadmin** pose le problème suivant : à quoi bon perdre des cycles CPU pour réorganiser des E/S qui seront de toute façon réorganisées par l’hyperviseur juste après pour écriture sur disques ? Son point de vue consiste à dire qu’au mieux des cycles CPU seront gaspillés pour rien et qu’au pire, la réorganisation de chaque VM de ses propres E/S sera contreproductive et dégradera les performances du stockage.

La solution qu’il propose consiste donc à dire qu’il vaut donc mieux supprimer ce travail inutile et positionner les machines virtuelles avec le scheduler IO NOOP (simple FIFO). Au delà de l’aspect intuitif du raisonnement, **lonesysadmin** ne donne pas de tests de performance ou de source pour étayer ses arguments.

Cependant, parmi les commentaires dans l’article et les différentes informations que je trouve sur Internet, l’information se confirme (même si on conseille généralement **deadline**), notamment grâce au KB 2011861 de VMware (lien mort, comme tout chez VMware) qui conseille clairement **noop** ou **deadline**.

## Bonus

  * [Recommandation de RedHat pour les bases de données][8] : changez pour **deadline** !
  * Dans ses Best Practices pour machines virtuelles Linux sur KVM (lien mort), IBM conseille : **deadline** encore !
  * Un article du [Linux Journal sur les I/O Schedulers][10] qui montre avec des exemples un peu théoriques des différences énormes entre elevators.
  * Un article sur NUODB qui conseille NOOP (blog tué par dassault, suite à un rachat probablement) dans le cas de l’utilisation de SSDs. Retrouvé sur dzone [dzone.com/articles/tuning-linux-io-scheduler-ssds](https://dzone.com/articles/tuning-linux-io-scheduler-ssds)
  * [L’article wikipedia de NOOP][12]

 [1]: https://www.redhat.com/magazine/008jun05/features/schedulers/
 [2]: https://docs.redhat.com/en/documentation/Red_Hat_Enterprise_Linux/5/html/Tuning_and_Optimizing_Red_Hat_Enterprise_Linux_for_Oracle_9i_and_10g_Databases/sect-Oracle_9i_and_10g_Tuning_Guide-Kernel_Boot_Parameters-The_IO_Scheduler.html
 [3]: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Performance_Tuning_Guide/ch06s04.html
 [4]: https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Performance_Tuning_Guide/chap-Red_Hat_Enterprise_Linux-Performance_Tuning_Guide-Storage_and_File_Systems.html#sect-Red_Hat_Enterprise_Linux-Performance_Tuning_Guide-Considerations-IO_Schedulers
 [5]: https://lonesysadmin.net/2013/12/06/use-elevator-noop-for-linux-virtual-machines/
 [8]: https://access.redhat.com/solutions/54164
 [10]: http://www.linuxjournal.com/article/6931?page=0,0
 [12]: https://en.wikipedia.org/wiki/Noop_scheduler
