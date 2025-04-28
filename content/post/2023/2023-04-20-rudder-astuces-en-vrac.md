---
title: Rudder - astuces en vrac
authors:
  - zwindler
type: post
date: 2023-04-20T18:00:00+02:00
excerpt: Articles d'astuces en vrac avec le logiciel de configuration management rudder
url: /2023/04/20/rudder-astuces-en-vrac
image: /2023/03/rudder_logo.png
categories:
  - Système
tags:
  - gestion de configuration
  - rudder
  - normation
  - ansible
  - configuration management
  - gestion de la conformité

---

Cet article fait partie d'une suite d'articles sur Rudder. La version qui est testée ici sera la version open source (car je n'ai pas les moyens de me payer une licence pour mon infra perso 😛) :
* [Présentation, installation du serveur et des agents](/2023/03/19/premiers-pas-avec-rudder-installation/)
* [Concepts et configuration des groupes, des directives, des rules](/2023/03/27/premiers-pas-avec-rudder-concept-configuration/)
* [Astuces en vrac](/2023/04/20/rudder-astuces-en-vrac/)

*Note : une fois de plus, je tiens à préciser qu'il ne s'agit PAS d'un article sponsorisé. J'ai eu des contacts (techniques) avec la team Rudder, mais je n'ai été influencé d'aucune manière, en particulier dans la rédaction de cet article.*

## But de l'article

Dans les deux articles précédents, j'ai parlé des concepts de Rudder, de l'installation du serveur et des agents. Je suis allé un poil plus loin avec mon installation perso mais avec ce que j'ai déjà écrit, on est déjà en capacité de jouer avec Rudder et je pense pas qu'on ait besoin d'aller beaucoup plus loin.

Cependant, au cours de mes péripéties avec Rudder, je suis tombé sur quelques petits "os". Rien de bien poussé, qui ne justifierait un article seul. Je vais donc tout regrouper ici, en vrac ;-P.

## Tuning pour les petits CPUs et les petites RAMs

On l'a dit dans le premier article, Rudder est assez doux en termes de prérequis matériels. Quelques Mo de mémoire suffisent pour l'agent, et grosso modo pas besoin de machine de guerre pour le CPU.

Cependant, comme je suis extrêmement économe (aka radin) dans la gestion de mon infra perso, je suis quasiment un anti pattern dans le cas de Rudder. J'ai un cluster Proxmox monté sur des machines louées à 6€/mois à base d'un antédiluvien Atom C2350 (des duals core de 2013 !). 

C'est d'ailleurs pour essayer de grappiller quelques % de CPU que j'avais publié les articles [Optimisation de PFsense dans Proxmox VE](/2020/07/06/optimisation-de-pfsense-dans-proxmox-ve/) et [Proxmox - Tips and tricks](/2022/10/22/proxmox-tips-tricks/).

Ces machines ne supportant même pas les instructions VT-x, je ne fais donc pas de machines virtuelles mais uniquement des machines à bases de containers LXC. Je me retrouve donc à installer une dizaine d'agents (oui, je suis vraiment bourrin) sur un même Atom.

Rudder a beau être économe, multiplier les agents sur une machine aussi faible avait un coût difficilement soutenable sur ma machine, comme en témoigne le graphique CPU ci-dessous (mon serveur ne fait quasiment rien, c'est donc quasiment exclusivement de la charge Rudder).

![](/2023/04/cpu_avant_tuning.png)

Il est très peu probable que vous ayez **vous** une charge perceptible sur vos infras. Dans le cas de machines aussi peu puissantes, il est probable que la team Rudder recommanderait de ne pas installer d'agent sur mes containers LXC. Mais dans le cas de machines très très peu puissantes et/ou très très densifiées en termes de nombre de VMs, sachez qu'il est quand même possible de tuner le scheduling des runs de Rudder et ainsi limiter la casse.

Dans le menu **Administration** / **Settings**, il existe une section **Agent run schedule**. Par défaut, l'ordonnancement est prévu de la façon suivante : Rudder lance les vérifications / corrections sur sa liste d'agent sur une plage de 5 minutes, le premier tiré au hasard commençant à 0 minutes (directement donc) et le dernier jusqu'à 4 minutes (1 minute avant la fin de la fenêtre de tir).

Note : au-delà de mon cas particulier, c'est quand même intéressant à savoir, car en fonction de ce qu'on lancera (scripts très longs par exemple, upgrades `apt`, ...), il peut être intéressant de tuner ce dernier paramètre (Maximum delay) pour être certain que 2 jobs ne se chevauchent pas.

![](/2023/04/agent_run_schedule.png)

En modifiant le scheduling pour que les runs se lancent non pas sur 5 minutes mais sur 30, avec un dernier lancement à la 29 ème minute, j'ai pu retrouver une charge relativement acceptable sur mon infra.

![](/2023/04/cpu_apres_tuning.png)

Deuxième astuce, si vous êtes limité en RAM, que vous avez moins de 50 machines et que vous n'utilisez pas beaucoup les plugins, il est possible de diminuer la taille de la JVM de rudder (par défaut à 1 Go) et ainsi un peu mieux respirer sur une machine à 2 Go (prérequis Rudder, un peu justes).

```bash
sed -i 's/JAVA_XMX=1024/JAVA_XMX=512/' /etc/default/rudder-jetty
systemctl restart rudder-server.service
```

Merci Nicolas pour l'astuce :\)

## Changer le nom des machines du point de vue de Rudder

Autre problème, je n'ai pas toujours la main sur le FQDN des machines que je loue. En particulier, le retour de la commande `hostname -f` renvoit parfois le nom de la machine telle que l'appelle l'hébergeur.

![](/2023/04/fqdn.png)

Je me retrouve avec un inventaire rudder plein de machines avec des noms du type `int.nua.ge` et `randomid.dedibox.fr`...

Dans certains cas, je peux le modifier moi-même et/ou feinter Rudder (en modifiant le fichier /etc/hosts par exemple) mais plutôt que de faire ça, j'ai préféré utiliser une technique détaillée dans la documentation officielle de Rudder appelée [override node fqdn](https://docs.rudder.io/reference/7.2/usage/advanced_node_management.html#override-node-fqdn)

La méthode pour le faire à la main est la suivante. En tant que root, je crée un script qui renvoie un JSON contenant une variable avec le nom que je souhaite pour mon hôte :

```
# mkdir -p /var/rudder/hooks.d/
# vi /var/rudder/hooks.d/override-hostname.sh
    echo '{"rudder_override_hostname": "myhost.example.org"}'
# chmod +x /var/rudder/hooks.d/override-hostname.sh

# rudder agent inventory
Rudder agent 7.2.4
Node uuid: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

C'est relativement simple, mais j'étais pas satisfait car ça nécessite une action manuelle et je suis super fainéant. Comme les noms courts de mes machines sont eux toujours bons, quel que soit le provider et que je connais le domaine par avance (zwindler.fr), j'ai créé une**directive** Rudder pour le faire à ma place !

A partir d'une technique de type **Distribution files** / **File content**, j'ai mis les valeurs suivantes :

![](/2023/04/file_content1.png)

![](/2023/04/file_content2.png)

Et voilà le résultat, 5 minutes pour tard :\)

![](/2023/04/fqdn2.png)

## Agent qui ne démarre pas après une désinstallation / réinstallation

Au début, quand je commençais à jouer avec Rudder, je me suis un peu mélangé les pinceaux au point qu'il était plus simple de tout désinstaller et recommencer proprement.

En théorie, quand on veut debug et/ou réinstaller un agent qui marche mal, on peut utiliser les commandes suivantes :

```
rudder agent factory-reset 
rudder agent inventory
rudder agent check
```

Sauf que dans mon cas, j'avais désinstallé puis réinstallé l'agent. Et à chaque fois, tout avait l'air OK, mais rudder ne faisait rien et voici le message d'erreur que j'avais :

```
rudder agent check

INFO: No disable file detected and no agent executor process either. Restarting agent service... Done
WARNING: The file /var/rudder/cfengine-community/last_successful_inputs_update is older than twice 10 minutes, the agent is probably stuck. Purging the CFEngine lock database... Done
FINISH: Rudder agent check ran properly, please look at messages above to see if there has been any error.
```

Pour essayer de comprendre pourquoi Rudder ne se lançait jamais alors que la communication avec le serveur semblait OK, je suis allé voir ce que faisait le service systemd **rudder-agent.service**. 

```
cat /lib/systemd/system/rudder-agent.service
[Unit]
Description=Rudder agent umbrella service
Documentation=man:rudder(8)
Documentation=https://docs.rudder.io
After=syslog.target
# Dependencies register themselves with a WantedBy/RequiredBy
# currently they are rudder-cf-serverd and rudder-cf-execd

[Service]
Type=oneshot
RemainAfterExit=yes
# This is required for the service to be able to
# pass these commands to its dependencies
ExecStart=/bin/true
ExecReload=/bin/true

[Install]
WantedBy=multi-user.target
```

Et là, c'était tout de suite plus clair. Le service rudder-agent est en réalité un simple service "chapeau", dont dépendent 2 sous services `rudder-cf-serverd` et `rudder-cf-execd`.

Or, par défaut, quand vous désinstallez **rudder-agent** (à minima sur Debian/Ubuntu), les services `rudder-cf-serverd.service` et `rudder-cf-execd.service` sont "disabled" mais pas re-"enabled" à la réinstallation.

```
root@node01:/# systemctl status rudder-cf-serverd
● rudder-cf-serverd.service - CFEngine file server
     Loaded: loaded (/lib/systemd/system/rudder-cf-serverd.service; disabled; vendor preset: enabled)
     Active: inactive (dead)
```

Rudder ne faisait rien, tout simplement parce qu'il n'était juste pas activé :D. On règle ça en 4 commandes :-P

```
root@node01:/# systemctl enable rudder-cf-serverd
Created symlink /etc/systemd/system/multi-user.target.wants/rudder-cf-serverd.service → /lib/systemd/system/rudder-cf-serverd.service.
Created symlink /etc/systemd/system/rudder-agent.service.wants/rudder-cf-serverd.service → /lib/systemd/system/rudder-cf-serverd.service.
root@node01:/# systemctl start rudder-cf-serverd

root@node01:/# systemctl enable rudder-cf-execd
Created symlink /etc/systemd/system/multi-user.target.wants/rudder-cf-execd.service → /lib/systemd/system/rudder-cf-execd.service.
Created symlink /etc/systemd/system/rudder-agent.service.requires/rudder-cf-execd.service → /lib/systemd/system/rudder-cf-execd.service.
root@node01:/# systemctl start rudder-cf-serverd
```

Note : je ne suis pas convaincu que ce soit un comportement voulu, j'ai remonté le point à la team Rudder, je vous tiendrais au courant.

## Conclusion

Voilà les quelques petits trucs rigolos que j'ai eu avec Rudder pour l'instant. 

Je ne sais pas quand je ferai le prochain article sur Rudder. La version 8 approche doucement, ça sera peut-être à cette occasion (il y a une fonctionnalité que j'attends dedans). 

On a pas non plus parlé des plugins. Ca pourrait valoir le coup (il en existe certains uniquement utilisables avec la version entreprise que je n'ai pas, mais aussi des gratuits).

A voir. En attendant, have fun !
