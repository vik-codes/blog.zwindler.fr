---
title: 'Transparent Hugepages : mesurer l’impact sur les performances'
authors:
  - zwindler
type: post
date: 2020-02-24T07:30:00+00:00
excerpt: "Comprendre à quoi servent et mesurer l'impact des Transparents Hugepages sous Linux"
url: /2020/02/24/transparent-hugepages-mesurer-limpact-sur-les-performances/
image: /2020/02/thp_nothp-1.jpg
categories:
  - systeme
tags:
  - kernel
  - Linux
  - THP
  - transparent hugepages

---

## Encore les Transparent Hugepages ?

Il y a quelques jours, j’ai posté un article pour vous aider à [désactiver les Transparent Hugepages](/2020/02/10/redis-mongodb-rabbitmq-desactiver-les-transparent-huge-pages/).

A là suite de ça, Seboss666 (qui tient un [super blog bien Geek/sysadmin comme j’aime](https://blog.seboss666.info/)) m’a fait remarquer en commentaire que j’expliquais surtout comment désactiver les THP. Mais je n’ai pas beaucoup parlé d’à quoi ça sert (à part que [c’est mal aimé, comme SELinux](/2016/10/26/comprendre-configurer-selinux-rhel-7/)) et si ça a vraiment un impact sur les perfs.
  
Il m’a passé un [article hyper intéressant, en anglais, sur le sujet](https://alexandrnikitin.github.io/blog/transparent-hugepages-measuring-the-performance-impact/). Comme je ne l’aurais pas mieux écris moi-même ET que le but du blog est d’être une ressource francophone, j’ai donc proposé à l’auteur, Alexandr Nikitin, de le traduire en français. Le voilà donc.

## Introduction
  
TL;DR ce post a pour but d’expliquer en un mot ce que sont les Transparent Hugepages (THP), décrire les techniques qui seront utilisées pour mesurer leur impact sur les performances et enfin, montrer leur effet sur une application réelle.

Il est inspiré par un [thread a propos des Transparent Huge Pages sur le "Mechanical Sympathy group"](https://groups.google.com/forum/#!topic/mechanical-sympathy/sljzehnCNZU). Ce thread expose les pièges, les problématiques de performances ainsi que l’état actuel dans les dernières versions du kernel. Une grosse quantité d’information peut y être trouvé.

En général, vous allez trouver beaucoup de recommendations sur Internet à propos des Transparent Hugepages. La plupart d’entre eux vous diront de désactiver totalement les THP, comme Oracle Database (lien mort), [MongoDB](https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/), [Couchbase (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20171212085403/https://developer.couchbase.com/documentation/server/current/install/thp-disable.html), MemSQL (lien mort), [NuoDB](http://doc.nuodb.com/Latest/Content/Note-About-%20Using-Transparent-Huge-Pages.htm). Certains logiciels utilise la fonctionnalité, comme par exemple [PostgreSQL](https://www.postgresql.org/docs/9.6/static/kernel-resources.html#LINUX-HUGE-PAGES) (la fonctionnalité hugetlbpage, pas exactement les THP) et [Vertica](https://my.vertica.com/docs/7.2.x/HTML/index.htm#Authoring/InstallationGuide/BeforeYouInstall/transparenthugepages.htm). Il existe beaucoup de retours d’expériences de professionnels qui ont eu à se battre contre des freeze de leur système et l’ont "corrigé" simplement en désactivant les THP. [1](https://www.perforce.com/blog/tales-field-taming-transparent-huge-pages-linux), [2](https://community.microfocus.com/borland/managetrack/accurev/w/accurev_knowledge_base/27749/recommendation-to-disable-linux-kernel-transparent-hugepages-thp-setting-for-performance-improvement), [3 (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20200702063613/http://structureddata.org/2012/06/18/linux-6-transparent-huge-pages-and-hadoop-workloads/), [4](https://blogs.oracle.com/linux/performance-issues-with-transparent-huge-pages-thp), [5](https://www.percona.com/blog/why-tokudb-hates-transparent-hugepages/), [6](https://engineering.linkedin.com/performance/optimizing-linux-memory-management-low-latency-high-throughput-databases). Toutes ces histoires tendent à propager une vision faussée et le préjugé que cette fonctionnalité est dangereuse.

Malheureusement, je n’ai pas trouvé de post qui mesure ou montre comment mesurer l’impact et les conséquences d’activer ou de désactiver cette fonctionnalité. C’est ce que ce post va tenter de répondre.

## Les Transparent Hugepages en bref (presque)

Pour fonctionner, presque toutes les applications et les systèmes d’exploitation nécessitent de la mémoire "virtuelle". La mémoire virtuelle de tous les logiciels est ensuite mappée dans la mémoire physique. Ce mapping est géré par le système d’exploitation, qui maintient [une structure de donnée en RAM (page table)](https://en.wikipedia.org/wiki/Page_table). Pour passer de l’adresse virtuelle à l’adresse physique (page table walking), [on utilise un composant du CPU (la MMU)](https://fr.wikipedia.org/wiki/Unit%C3%A9_de_gestion_m%C3%A9moire). En plus de servir de table de traduction, la MMU sert également de cache des pages récemment utilisées. On appelle ce cache le Translation lookaside buffer (TLB).

> Lorsqu’une adresse virtuelle doit être traduite dans une adresse physique, on cherche d’abord dans le TLB. Si un résultat est trouvé (TLB hit), l’adresse physique est retournée et l’accès à la mémoire peut continuer. Cependant, si on ne trouve pas de résultat (TLB miss), la MMU va devoir rechercher le mapping de l’adresse dans la table de pages (page table) si il existe.

  
Ce processus de "page table walk" est coûteux en temps car il peut nécessiter plusieurs accès à la mémoire (cependant, avec de la chance on peut retrouver la page mémoire dans un des caches L1/L2/L3 du CPU). Cependant, on ne peut pas non plus compter tout le temps sur le TLB car sa taille est limitée (généralement quelques centaines de pages, au maximum).

  
Les systèmes d’exploitation gèrent la mémoire virtuelle en utilisant des pages (des blocks contigus de mémoire). Généralement, la taille d’une page mémoire est de 4 Ko. Petite règle de trois, 1 Go de RAM équivaut à 256000 pages, et 128 Go à 32,7 millions de pages. Clairement, on ne va pas pouvoir tout stocker dans le TLB et nous allons donc souffrir de problèmes de performances à cause des "TLB miss". Il y a deux façons d’améliorer cette situation. La première est d’augmenter la taille du TLB. Cependant, c’est coûteux et l’impact n’est pas significatif, surtout sur les systèmes disposant d’une très grande quantité de RAM. La seconde consiste à augmenter la taille d’une page est ainsi, avoir moins de pages à mapper. Les OS et les CPUs modernes sont typiquement capable de supporter des pages "larges" de 2 Mo, voire même de 1 Go. Ainsi, avec des pages de 2 Mo, 128 Go de RAM devient seulement 64000 pages.

  
Ce n’est pas pour rien que Linux supporte les Transparent Hugepages. C’est une optimisation ! Cela permet de gérer un grand nombre de pages de manière automatique et transparente pour les applications. Les bénéfices sont évidents : pas de modification à faire du coté des application, le nombre de "TLB miss" est réduit, le "page table walking" devient moins coûteux. Cette fonctionnalité peut être découpée en deux parties : allocation et maintenance.

  
Le THP fonctionne de la même manière pour ce qui est de l’allocation de la mémoire et nécessite que le système d’exploitation trouve des blocs alignés et contigus de mémoire. Dans ce cas précis, il souffre également des mêmes problèmes que les pages de mémoire classiques, à savoir la fragmentation. Si l’OS ne sait pas trouver de blocs de mémoire continus, il va essayer de "compacter", réclamer les partions inutilisées ou "page out" les autres pages. Ce processus est couteux et peut provoquer de grosses latences (jusqu’à quelques secondes). Heureusement, ce problème a été adressé dans la _version 4.6 du kernel Linux_ (avec l’option defer) ; l’OS retourne dans le mode classique (page de 4K) si jamais il ne trouve pas de place pour une hugepage.

  
La deuxième partie est la maintenance. Si une application ne modifie ne serait ce qu’un seul octet de mémoire, elle va consommer la taille d’une page entière, à savoir 2 Mo si on utilise des hugepages, ce qui est clairement un gaspillage de mémoire vive. Pour palier à ça, il existe une tâche de fond qui s’appelle khugepaged. Ce processus scanne les pages et essaye de défragmenter et concaténer toutes les pages presque vides dans une seule page. Cependant, même si c’est une tâche de fond, elle va bloquer les pages sur lesquelles elle fonctionne, ce qui peut aussi provoquer des pic de latence. Un dernier problème reste qu’il est parfois nécessaire de découper les grosses pages, car tous les composants de l’OS ne supportent pas les hugepages. C’est le cas de la swap par exemple. L’OS doit alors découper les grosses pages en plus petites pour ces composants là. Encore une fois, cette opération peut dans certain cas dégrader les performances et augmenter la fragmentation.

  
Le meilleur endroit pour apprendre comment fonctionnent les Transparent Hugepage est évidemment [la documentation officielle du Kernel Linux](https://www.kernel.org/doc/Documentation/vm/transhuge.txt). Cette fonctionnalité dispose de plusieurs éléments de configuration ainsi que des flags pour modifier son comportement. Ils évoluent avec le Kernel lui même.



## Comment le mesurer ?
  
  
C’est probablement la partie la plus importante de ce post. Basiquement, il y a deux façon de mesurer l’impact de cette fonctionnalité : les CPU counters et les kernel functions.

  
### CPU counters
  
  
Commençons par les CPU counters. J’utilise _perf_, qui est un outil génial et simple pour réaliser ce genre de mesures. _Perf_ dispose nativement d’alias pour les événements du TLB : dTLB-loads, dTLB-load-misses pour les hit et les miss en load; dTLB-stores, dTLB-store-misses (idem mais pour les stores).


```
[~]# perf stat -e dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses -a -I 1000
#           time             counts unit events
     1.006223197         85,144,535      dTLB-loads                                                    
     1.006223197          1,153,457      dTLB-load-misses          #    1.35% of all dTLB cache hits   
     1.006223197        153,092,544      dTLB-stores                                                   
     1.006223197            213,524      dTLB-store-misses                                             
...
```



Et la même chose pour les instructions (iTLB-load, iTLB-load-misses).


```
[~]# perf stat -e iTLB-load,iTLB-load-misses -a -I 1000
#           time             counts unit events
     1.005591635              5,496      iTLB-load
     1.005591635             18,799      iTLB-load-misses          #  342.05% of all iTLB cache hits
...
```



En réalité, perf supporte seulement un petit sous ensemble de tous les événements alors que les CPUs ont des centaines de compteurs pour évaluer la performance. Pour les CPUs Intels par exemple, on peut trouver la liste de tous les compteurs disponibles sur le site [Intel Processor Event Reference](https://download.01.org/perfmon/index/), dans le [Intel® 64 and IA-32 Architectures Developer’s Manual: Vol. 3B](https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-3b-part-2-manual.html) ou bien encore dans [les sources du Kernel Linux](https://github.com/torvalds/linux/blob/510c8a899caf095cb13d09d203573deef15db2fe/tools/perf/pmu-events/arch/x86/haswell/virtual-memory.json). Le manuel du développeur contient également des codes d’événements que nous devons passer pour analyser les performances.

Si on regarde les compteurs relatifs au TLB, voilà ce qu’on peut trouver d’intéressant :

<table class="">
  <tr>
    <th>
      Mnemonic
    </th>
    <th>
      Description
    </th>
    <th>
      Event Num.
    </th>
    <th>
      Umask Value
    </th>
  </tr>
  <tr>
    <td>
      DTLB_LOAD_MISSES.MISS_CAUSES_A_WALK
    </td>
    <td>
      Misses in all TLB levels that cause a page walk of any page size.
    </td>
    <td>
      08H
    </td>
    <td>
      01H
    </td>
  </tr>
  <tr>
    <td>
      DTLB_STORE_MISSES.MISS_CAUSES_A_WALK
    </td>
    <td>
      Miss in all TLB levels causes a page walk of any page size.
    </td>
    <td>
      49H
    </td>
    <td>
      01H
    </td>
  </tr>
  <tr>
    <td>
      DTLB_LOAD_MISSES.WALK_DURATION
    </td>
    <td>
      This event counts cycles when the page miss handler (PMH) is servicing page walks caused by DTLB load misses.
    </td>
    <td>
      08H
    </td>
    <td>
      10H
    </td>
  </tr>
  <tr>
    <td>
      ITLB_MISSES.MISS_CAUSES_A_WALK
    </td>
    <td>
      Misses in ITLB that causes a page walk of any page size.
    </td>
    <td>
      85H
    </td>
    <td>
      01H
    </td>
  </tr>
  <tr>
    <td>
      ITLB_MISSES.WALK_DURATION
    </td>
    <td>
      This event counts cycles when the page miss handler (PMH) is servicing page walks caused by ITLB misses.
    </td>
    <td>
      85H
    </td>
    <td>
      10H
    </td>
  </tr>
  <tr>
    <td>
      PAGE_WALKER_LOADS.DTLB_MEMORY
    </td>
    <td>
      Number of DTLB page walker loads from memory.
    </td>
    <td>
      BCH
    </td>
    <td>
      18H
    </td>
  </tr>
  <tr>
    <td>
      PAGE_WALKER_LOADS.ITLB_MEMORY
    </td>
    <td>
      Number of ITLB page walker loads from memory.
    </td>
    <td>
      BCH
    </td>
    <td>
      28H
    </td>
  </tr>
</table>

_Perf_ supporte le compteur `*MISS_CAUSES_A_WALK` via un alias. Mais nous devrons trouver l’identifiant numérique des autres événements pour les passer en arguments. Point important, les numéros d’événements et les valeurs _umask_ associées dépendent de chaque CPU. Par exemple, la liste ci dessus est spécifique à l’architecture Intel Haswell ! Il vous sera nécessaire d’adapter ces codes à votre CPU.
  
Une des métriques clé est le nombre de cycle CPU passés à faire du page table walking :

```
[~]# perf stat -e cycles \
>   -e cpu/event=0x08,umask=0x10,name=dcycles/ \
>   -e cpu/event=0x85,umask=0x10,name=icycles/ \
>   -a -I 1000
#           time             counts unit events
     1.005079845        227,119,840      cycles
     1.005079845          2,605,237      dcycles
     1.005079845            806,076      icycles
...
```

Une autre métrique importante est le nombre de lecture mémoire qui causent des TLB miss ; ces lectures ne profitent pas du cache CPU et sont donc coûteuses :

```
[~]# perf stat -e cache-misses \
>   -e cpu/event=0xbc,umask=0x18,name=dreads/ \
>   -e cpu/event=0xbc,umask=0x28,name=ireads/ \
>   -a -I 1000
#           time             counts unit events
     1.007177568             25,322      cache-misses
     1.007177568                 23      dreads
     1.007177568                  5      ireads
...
```

### Kernel functions

Une autre façon surpuissante de mesurer l’impact des THP sur les performances et la latence est d’utiliser les fonctions de tracing/probing du Kernel Linux. J’utilise [SystemTap](https://sourceware.org/systemtap/) pour ça, qui est un outil pour instrumenter dynamiquement les systèmes Linux en production.

La première fonction intéressante pour le cas qui nous intéresse est `__alloc_pages_slowpath`. Elle est exécutée lorsqu’il n’y a pas de bloc contigu de mémoire vive disponible lors d’une allocation. A son tour, cette fonction appelle la fonction de "récupération" et de "compaction" des pages, qui je le rappelle est une opération très couteuse qui peut engendrer des pics de latence.

La seconde fonction intéressante est `khugepaged_scan_mm_slot`. Elle est exécutée en tâche de fond par le thread _khugepaged_ du Kernel. Ce thread scanne les _hugepages_ et essaye de les compacter en une seule.

  
J’utilise un script SystemTap pour mesurer le temps d’exécution d’une fonction. Ce script stocke tous les temps d’exécution en microsecondes et affiche périodiquement un histogramme. Il ne consomme que quelques Mo par heure, en fonction du nombre d’exécutions. Le premier argument est la sonde à utiliser, le second est un nombre (en ms) pour afficher les statistiques.


```
#! /usr/bin/env stap
global start, intervals

probe $1 { start[tid()] = gettimeofday_us() }
probe $1.return
{
  t = gettimeofday_us()
  old_t = start[tid()]
  if (old_t) intervals <<< t - old_t
  delete start[tid()]
}

probe timer.ms($2)
{
    if (@count(intervals) > 0)
    {
        printf("%-25s:\n min:%dus avg:%dus max:%dus count:%d \n", tz_ctime(gettimeofday_s()),
             @min(intervals), @avg(intervals), @max(intervals), @count(intervals))
        print(@hist_log(intervals));
    }
}
```

Voici un exemple avec la fonction `__alloc_pages_slowpath` :


```
[~]# ./func_time_stats.stp 'kernel.function("__alloc_pages_slowpath")' 1000

Thu Aug 17 09:37:19 2017 CEST:
 min:0us avg:1us max:23us count:1538
value |-------------------------------------------------- count
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  549
    1 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  541
    2 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                 377
    4 |@@@@                                                54
    8 |@                                                   12
   16 |                                                     5
   32 |                                                     0
   64 |                                                     0
...
```

Il est également intéressant de savoir observer l’état général de l’OS. Un bon exemple peut être la fragmentation de la mémoire. **/proc/buddyinfo** est un outil utilise pour aider au diagnostic dans ce genre de cas. **Buddyinfo** va nous donner des pistes pour estimer la taille maximale que l’on peut allouer sans risque, ou pourquoi la précédent allocation a échoué par exemple. De même, on peut aussi trouver des informations utiles dans **/proc/pagetypeinfo**.

```
cat /proc/buddyinfo
cat /proc/pagetypeinfo
```

Vous pouvez en apprendre plus en lisant [la documentation officielle (lien mort, j'utilise Internet Archive)](https://elixir.bootlin.com/linux/v3.10.107/source/Documentation/filesystems/proc.txt) ou alors en lisant [cet article](http://andorian.blogspot.lt/2014/03/making-sense-of-procbuddyinfo.html).



## JVM
  
La JVM supporte les Transparent Hugepages via l’ajout de l’option `-XX:+UseTransparentHugePages`. Cependant, on aura alors un message d’avertissement contre de possibles problèmes de performance :
  
> -XX:+UseTransparentHugePages On Linux, enables the use of large pages that can dynamically grow or shrink. This option is disabled by default. You may encounter performance problems with transparent huge pages as the OS moves other pages around to create huge pages; this option is made available for experimentation.
  
Il est intéressant d’activer l’usage des large pages pour le "Metaspace" :
  
> -XX:+UseLargePagesInMetaspace Use large page memory in metaspace. Only used if UseLargePages is enabled.
  
De plus, utiliser l’option -XX:+AlwaysPreTouch avec les hugepages peut être une bonne idée. Cela permet de réallouer toute la mémoire physique utilisé par le tas (heap) et ainsi éviter une surcharge supplémentaire due à l’initialisation ou à la compaction. Cependant, cela induira une augmentation du temps nécessaire pour initialiser la JVM.

> -XX:+AlwaysPreTouch Enables touching of every page on the Java heap during JVM initialization. This gets all pages into the memory before entering the main() method. The option can be used in testing to simulate a long-running system with all virtual memory mapped to physical memory. By default, this option is disabled and all pages are committed as JVM heap space fills.

Aleksey Shipilёv montre l’impact sur la performance dans son article de post [JVM Anatomy Park #2: Transparent Huge Pages](https://shipilev.net/jvm-anatomy-park/2-transparent-huge-pages/).

  
## Un exemple de la vie réelle : une JVM très chargée
  
Regardons maintenant quel impact ont réellement les Transparent Hugepages sur une application réelle. Prenons une application lancée dans une JVM : un serveur TCP basé sur netty et recevant un trafic important. Le serveur reçoit jusqu’à 100k requêtes par secondes, analyse chaque requête, effectue un appel réseau à une base de données pour chacun des appels, fait un certain nombre de calculs dessus, puis retourne un réponse. L’application en question possède une heapsize de 200 Go. Les mesures ont été réalisées sur des serveurs de production, ainsi que la charge réelle de production. Les serveurs n’étaient pas surchargés et recevaient 50% du nombre maximal de requêtes qu’ils étaient capables de traiter.
  
### Transparent Hugepages désactivées

Désactivons les THP :

```
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

La première chose à faire et de mesurer les TLB misses. Ici on a environ 130 millions de TLB misses. Le ratio Miss/Hit est de 1% (ce qui ne semble pas énorme, au premier abord).

```
[~]# perf stat -e dTLB-loads,dTLB-load-misses,iTLB-load-misses,dTLB-store-misses -a -I 1000
#           time             counts unit events
...
    10.007352573      9,426,212,726      dTLB-loads                                                    
    10.007352573         99,328,930      dTLB-load-misses          #    1.04% of all dTLB cache hits   
    10.007352573         26,021,651      iTLB-load-misses                                              
    10.007352573         10,955,696      dTLB-store-misses                                             
...
```

Cependant, regardons plus précisément combien nous ont coûté en temps CPU ces TLB misses :

```
[~]# perf stat -e cycles \
>   -e cpu/event=0x08,umask=0x10,name=dcycles/ \
>   -e cpu/event=0x85,umask=0x10,name=icycles/ \
>   -a -I 1000
#           time             counts unit events
...
    12.007998332     61,912,076,685      cycles
    12.007998332      5,615,887,228      dcycles
    12.007998332      1,049,159,484      icycles
...
```

Oui, vous avez bien vu ! Plus de 10% des cycles CPUs sont utilisés pour parcourir la page table.

Le compteur suivant montre que nous avons 1 million de lectures RAM causées par des TLB misses (sachant que chacunes de ces lectures coûtent 100 ns chacunes) :

```
[~]# perf stat -e cpu/event=0xbc,umask=0x18,name=dreads/ \
>    -e cpu/event=0xbc,umask=0x28,name=ireads/ \
>    -a -I 1000
#           time             counts unit events
...
     6.003683030          1,087,179      dreads
     6.003683030            100,180      ireads
...
```

Tous les nombres que je viens de vous montrer sont intéressants, mais ils ne sont pas vraiment "exploitables". Les métriques les plus importantes pour un développeur d’application sont les métriques de l’application elle-même. Regardons donc comment la métrique de la latence end-to-end de l’application. Voilà les mesures (en microsecondes) qui ont été récoltées pendant quelques minutes :

```
"max" : 16414.672,
  "mean" : 1173.2799067016406,
  "min" : 52.112,
  "p50" : 696.885,
  "p75" : 1353.116,
  "p95" : 3769.844,
  "p98" : 5453.675,
  "p99" : 6857.375,
```

## Transparent Hugepages activées

Maintenant on va pouvoir commencer à faire des comparaisons ! Activons les THP :

```
echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag # consider other options too
```

Et lançons la JVM avec les options `-XX:+UseTransparentHugePages`, `-XX:+UseLargePagesInMetaspace` et `-XX:+AlwaysPreTouch`.

La première métrique que nous avions collecté (les TLB misses) ont été divisés par 6, passant de 130 millions à environ 20 millions. Mathématiquement, le ratio miss/hit tombe de 1% à 0,15%. Voici les nombres exacts :

```
[~]# perf stat -e dTLB-loads,dTLB-load-misses,iTLB-load-misses,dTLB-store-misses -a -I 1000
#           time             counts unit events
     1.002351984     10,757,473,962      dTLB-loads                                                    
     1.002351984         15,743,582      dTLB-load-misses          #    0.15% of all dTLB cache hits  
     1.002351984          4,208,453      iTLB-load-misses                                              
     1.002351984          1,235,060      dTLB-store-misses                                            
```

Les cycles CPU passés à parcourir la page table ont également diminué d’un facteur 5, d’environ 6,7 milliards à 1,3 milliards. Cette fois ci, nous avons donc utilisé seulement 2% de notre CPU à réaliser du "page table walking" :

```
[~]# perf stat -e cycles \
>   -e cpu/event=0x08,umask=0x10,name=dcycles/ \
>   -e cpu/event=0x85,umask=0x10,name=icycles/ \
>   -a -I 1000
#           time             counts unit events
...
     8.006641482     55,401,975,112      cycles
     8.006641482      1,133,196,162      dcycles
     8.006641482        167,646,297      icycles
...
```

Et enfin, le nombre de lecture en RAM a diminué de 1 million à 350k

```
[~]# perf stat -e cpu/event=0xbc,umask=0x18,name=dreads/ \
>    -e cpu/event=0xbc,umask=0x28,name=ireads/ \
>    -a -I 1000
#           time             counts unit events
...
    12.007351895            342,228      dreads
    12.007351895             17,242      ireads
...
```

Tout ça c’est bien beau, mais, une fois encore, les nombres qui vont le plus nous intéresser, c’est l’effet réel que ça va avoir sur notre application. Voici les chiffres de la latence end-to-end de l’application :

```
"max" : 16028.281,
  "mean" : 946.232869010599,
  "min" : 41.977000000000004,
  "p50" : 589.297,
  "p75" : 1080.305,
  "p95" : 2966.102,
  "p98" : 4288.5830000000005,
  "p99" : 5918.753,
```

La différence entre les deux runs sur les 95 percentiles est quasiment de 1 milliseconde ! Voici ce que cela représente visuellement :


![](/2020/02/grafana.png) 

> Source : https://alexandrnikitin.github.io/blog/images/transparent-hugepages-measuring-the-performance-impact/grafana.png 


Nous venons donc de mesurer l’amélioration apportée par l’activation des Transparent Hugepages. Cependant, nous savons que l’activation des THP peut avoir un impact sur les performances (à cause de l’overhead de la "maintenance" que nous avons expliqué plus haut) ainsi que les risques de pic de latence. Nous devons donc également les mesurer. Regardons le thread `kernel khugepaged` qui s’occupe de la défragmentation des hugepages. La mesure qui suit a été réalisée sur une durée d’environ 24 heures. Comme vous pouvez le constater, le temps maximum d’exécution est de 6 millisecondes et il y a de nombreuses exécutions qui ont pris moins d’une milliseconde. Si ce processus est en tâche de fond, mais il bloque les pages concernées pendant qu’il travaille dessus. Voici l’histogramme :

```
[~]# ./func_time_stats.stp 'kernel.function("khugepaged_scan_mm_slot")' 60000 -o khugepaged_scan_mm_slot.log
[~]# tail khugepaged_scan_mm_slot.log

Thu Aug 17 13:38:59 2017 CEST:
 min:0us avg:321us max:6382us count:10834
value |-------------------------------------------------- count
    0 |@                                                   164
    1 |@                                                   197
    2 |@@@                                                 466
    4 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  6074
    8 |@@@@@@                                              761
   16 |@@                                                  318
   32 |                                                     65
   64 |                                                     13
  128 |                                                      1
  256 |                                                      3
  512 |@@@                                                 463
 1024 |@@@@@@@@@@@@@@@@@@                                 2211
 2048 |                                                     85
 4096 |                                                     13
 8192 |                                                      0
16384 |                                                      0
```

Une autre fonction important du kernel est `__aloc_pages_slowpath`. Cette fonction aussi peut provoquer des pics de latence si un block contigue de mémoire n’est pas disponible. Lors de la mesure, l’histogramme est bien meilleur ici. Le temps maximum d’allocation était de 288 microsecondes. Même en le faisant tourner pendant des heures voire même des jours, nous sommes devenus confiant dans le fait que cette fonctionnalité n’allait pas provoquer de longs pics de latence.

```
[~]# ./func_time_stats.stp 'kernel.function("__alloc_pages_slowpath")' 60000 -o alloc_pages_slowpath.log
[~]# tail alloc_pages_slowpath.log

Tue Aug 15 10:35:03 2017 CEST:
 min:0us avg:2us max:288us count:6262185
value |-------------------------------------------------- count
    0 |@@@@                                                237360
    1 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     2308083
    2 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  2484688
    4 |@@@@@@@@@@@@@@@@@@@@@@                             1136503
    8 |@                                                    72701
   16 |                                                     22353
   32 |                                                       381
   64 |                                                         7
  128 |                                                       105
  256 |                                                         4
  512 |                                                         0
 1024 |                                                         0
```

Alors comment se fait il que les Transparents Hugepages fonctionnent aussi bien dans ce cas précis ? D’abord, on remarque un amélioration significative de la performance car dans ce cas précis on travaille avec une grande quantité de RAM. De même, on ne remarque pas de pics de latences car il n’y a pas de surcharge en terme de RAM sur le serveur. Il y a beaucoup de RAM (256 Go), la JVM sait tirer partie des THP, pré-alloue la totalité des 200 Go de heap dès le démarrage et ne la redimensionne jamais.
  
## Conclusion
  
Ne suivez pas aveuglément les recommandation que vous trouvez sur Internet ! Mesurez, mesurez, mesurez encore !

Les Transparent Hugepages sont une optimisation et qui peut avoir de réelles conséquences positives sur la performance, mais avec des inconvénients et des risques qui peuvent entrainer des conséquences imprévues. Le but de ce post était de donner les clés pour mesurer les gains potentiels et gérer les risques. Le Kernel Linux et ces fonctionnalités évoluent et certains des problèmes des THP ont été adressés dans les dernières versions, comme par exemple l’option "defer" de la défragmentation, qui permet à l’OS de repasser sur une allocation de taille normale, si jamais il n’est pas possible d’en allouer une large.

Note de zwindler : Encore merci à l’auteur ([Alexandr Nikitin](https://alexandrnikitin.github.io/blog/transparent-hugepages-measuring-the-performance-impact/)) pour son article, qui m’a appris beaucoup de choses !
