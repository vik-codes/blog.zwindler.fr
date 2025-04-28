---
title: vCenter, où, quand, comment… que choisir?
authors:
  - zwindler
type: post
date: 2010-06-01T11:02:49+00:00
url: /2010/06/01/vcenter-ou-quand-comment/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - Converter
  - ESX(i)
  - P2V
  - V2V
  - vCenter

---
**Attention :** cet article date de 2010. Depuis, les choses ont un peu bougées et j’ai préféré refaire une nouvel article, plus en phase avec la réalité d’aujourd’hui (2015). [C’est ici que ça se passe](/2015/03/30/echec-deploiement-package-ovf-cette-tache-a-ete-annulee-par-un-utilisateur/)

Attention, cet article est plutôt long, ne contient pas vraiment de technique pure mais plutôt un retour sur expérience et mon ressentis face à un choix que j’ai du faire. En effet, pour ce qui est de savoir comment et surtout où installer son vCenter, VMware n’est pas très clair. Il y a plein de solutions, et elles sont toutes bonnes, tout dépend de l’architecture choisie. Et si on parcours la toile pour trouver LA solution qui nous convient auprès des gens qui ont déjà choisi, on se rend compte que chacun à son idée sur la question, et c’est généralement l’argumentation se limite à « moi je fais comme ça, et ça a marché nickel du premier coup! »... super...

Cette article n’est donc que le reflet de mon opinion, forgée à partir de ma courte expérience du système. Je plante le décors :

  * Deux serveurs faisant chacun tourner un ESX 3.5.
  * Ces deux serveurs sont reliés à une baie de stockage haute performance NetApp, où sont stockées les VMs, bien proprement stockées dans des LUNS séparés.
  * Le tout est câblé comme il faut pour éviter tout problèmes, i.e. ne pas subir d’interruption de service au cas où n’importe quel lien ou matériel (switch, carte réseau, contrôleur de baie de disques) tomberait.
  * Une douzaine de VMs plus ou moins gourmandes en ressources
  * Un vCenter pour coordonner le tout avec les fonctionnalités chouettes comme vMotion et High Availability
  * Une machine physique à part qui sert à faire de la supervision. Cette machine est un peu une usine à gaz puisque par dessus son Debian il y a un VMware Server 2 (version Linux, bien sur...) qui fait tourner une VM Eyes of Network (distrib de supervision basé sur Nagios) ET le vCenter.

Pour clarifier un peu, mon vCenter, c’est un Windows XP sur lequel on fait tourner un serveur de bases de données (en l’occurrence un MS SQL 2K5 Express) et un service vCenter, qui permet de gérer les connexions entrantes (pilotage de la ferme depuis un VI Client) et sortantes (envoi des commandes à la ferme et réception des infos de la ferme).

L’idée initiale était d’éviter d’avoir une machine physique dédiée au vCenter (c’est vrai que ce serait un peu exagéré vu notre parc d’ESX/de VM) et de ne pas avoir le moyen d’administration des ESXs dépendant des ESXs. On gagne aussi l’avantage d’avoir un système de backups de l’OS qui fait tourner le vCenter tout prêt (snapshots) même si je rappelle que les Snapshots ne sont pas vraiment conseillés (par VMware) comme unique moyen de backup.

Seulement voilà, le PC physique en question était un superbe PC disposant d’un processeur 1.6 GHz et 1 GO de RAM complètement dépassé par tous les rôles qu’on lui avait attribué (serveur de virtualisation gérant à la fois la supervision et l’administration de la ferme). Parallèlement, le windows XP faisant tourner le vCenter était relativement limité par les 512 MO attribués pour pouvoir faire tourner le serveur vCenter et la base de données. En gros, le jour où j’ai commis « l’erreur » de me loguer dessus pour tenter de comprendre pourquoi j’avais de mauvaises perf quand j’utilisais le vCenter (comparé à un client vSphere pilotant un ESXi sur un autre réseau), j’ai complètement saturé la RAM de la machine physique et je n’ai plus été capable de contrôler quoique ça soit.

D’où une réflexion quant aux solutions qui s’offraient à moi:

  * La simplicité : Notre architecture telle qu’elle avait été pensée tient parfaitement la route si on met de côté notre problème de performance. J’aime bien l’idée (rassurante, je trouve) d’avoir un machine d’administration hors du système qu’elle administre, car en cas de problème sur un serveur, on garde toujours la possibilité de garder une vue d’ensemble et de revenir à la normale le plus vite possible. L’idée la plus naïve consisterait à simplement ajouter de la RAM (le facteur le plus limitant dans notre cas, et surtout le seul facilement changeable. Changer de CPU reviendrait à changer de machine physique)
  * La brutalité : Le plan initialement prévu était d’abandonner l’idée d’optimiser le nombre de machine physique et de régler « brutalement » notre problème de performance sur donnant au vCenter une machine physique pour lui tout seul. Cependant, restait à décider si le vCenter devait être réinstallé tout bêtement (avec migration de la base de données ou pas) ou migrer, et là on rentre dans une tout autre problématique, celle du V2P (virtual to physical), autrement plus difficile que le P2V (physical to virtual, généralement trivial).
  * Le choix VMware : Aussi étrange que cela puisse paraître, VMware **conseille et supporte** l’intégration du vCenter directement sur un des serveurs ESX(i) qu’il administre (le fait que le vCenter soit sur une machine physique aussi, cela parait évident). Ça fait froid dans le dos, à première vue, mais en y réfléchissant c’est assez tentant. En effet, si on part du principe qu’un serveur à beaucoup moins de chance de tomber en panne qu’une machine physique, et qu’on peut le cas échéant relancer la VM sur un autre serveur si il y en a un des deux qui tombe en panne, on se rend compte que le vCenter est beaucoup plus en sécurité s’il est sur la ferme que s’il est sur une vieille machine physique. De plus, les serveurs ESX possèdent énormément de ressources, et on pourra donc allouer tout ce dont on aura besoin pour notre vCenter.

A partir de là, réfléchissons un peu...

## Méthode n°1  

Avantages : Méthode simple à mettre en place, et pas de risques de tout casser (migrer, c’est potentiellement dangereux)  

Inconvénients : Méthode limitée. On ne pourra probablement pas rajouter grand chose, c’est une vieille machine. De toute façon, on est coincé pour ce qui est du processeur, et il était un peu faible. Enfin, un Debian avec un VMware Server 2 version Linux (même pas supportée par VMware, juste pour des tests normalement) pour pouvoir caser tout ce qu’on sait pas trop où mettre, c’est un peu sale, ça ne me plaisait pas...

## Méthode n°2  

Avantages : Performances optimales pour notre vCenter. Le rôle d’administration est bien hors du moyen qu’il administre.  

Inconvénients : Pour une petite archi comme la notre, immobiliser une machine rien que pour ça, c’est un peu « overkill ». Nécessité de mettre en place un mécanisme de backup et de restauration rapide, car le vCenter c’est quand même un peu critique. Nécessité de faire une migration ou une réinstallation.

  * Dans notre cas, la réinstallation (avec migration de la base de données pour ne pas perdre de temps à tout reconfigurer) était difficilement envisageable, mais c’est probablement le plus simple dans la plupart des cas normaux. A noter, il vaut mieux réinstaller un vCenter de la même version, à cause des problèmes de compatibilité de la base de données, quite à mettre à jour le vCenter avant ou après la migration.
  * La migration, c’est une autre paire de manche. C’était une machine virtuelle, et pour la passer en machine physique, il existe sur le site de VMware un article du KB pour décrire la procédure (**V2P**). Et oui... Le système d’exploitation tourne sur du matériel virtuel, et si d’un coup vous essayer de faire fonctionner votre XP sur un matériel qui devient tout d’un coup différent, il n’est pas content du tout... Pour faire simple, cette procédure vous demande d’utiliser un logiciel de backup de disque dur, puis de déployer le disque sauvé sur une machine physique vierge en préparant préalablement l’OS à l’aide d’un **sysprep**. Et là, j’avais vraiment pas envie de me lancer dans ça, parce que c’est un coup à tout péter ou à rendre le système instable de façon plus ou moins visible. A noter, la plupart des grands vendeurs de logiciels de backup de machines pour les redéployer proposent des modules payant ou des versions améliorées qui proposent d’automatiser tout le processus de remplacement des données matériel dans les fichiers de votre OS source. Si ça marche (pas testé), c’est probablement une bonne façon de faire.

## Méthode n°3  

Avantages : Des perfs meilleures (mais pas aussi bien qu’une machine physique dédiée). VMware conseille une VM à 2GO de RAM et 1 ou 2 processeurs pour 5 ESXs et 50 VM. On est loin de ça sur notre archi, c’est parfait! La stabilité des ESXs (sans parler du fait qu’on dispose d’un autre serveur au cas où) est quand même un grand plus par rapport à une machine physique ou une VM tournant sur une machine physique. Réutilisation du mécanisme de backup de l’ESX pour restaurer rapidement le vCenter en cas de corruption de l’OS du vCenter. Gros avantage pour l’étape migration:  conversion V2V (ou P2V) possible avec VMware Converter Standalone. Rien à faire, rien à configuré, ça marche du premier coup.

Inconvénients : Le moyen d’administration est sur les serveurs qu’il administre, et ça, je serai jamais trop rassuré par ça. Performance encore un peu limite mais là je comprend pas d’où ça vient...

## Conclusion

Au final, pour une petite archi comme la notre, moi je conseille l’utilisation en production du vCenter en temps que machine virtuelle sur un des ESX qu’il administre, car le ratio avantages/inconvénients m’a paru le plus avantageux. A noter, je ne me suis pas limité sur cette méthode en me disant que ça ne casserait jamais et que j’étais tranquille. J’ai mis en place un système de backup de la base de données de mon vCenter, j’ai gardé l’ancienne VM sur le « vieux VMware Server 2 de la machine physique » éteinte, capable de prendre le relais à tout moment.

N’oubliez de faire des backups/snapshots de la VM vCenter, et si possible, se garder (serveur virtuel ou physique) un vCenter de secours, si vous êtes vraiment parano comme moi, vaut mieux prévenir que guérir, comme dirait l’autre!
