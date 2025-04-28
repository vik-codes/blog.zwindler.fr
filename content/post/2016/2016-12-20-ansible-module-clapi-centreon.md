---
title: 'Module Ansible ansible-module-clapi : automatiser la configuration dans Centreon'
authors:
  - zwindler
type: post
date: 2016-12-20T13:00:49+00:00
url: /2016/12/20/ansible-module-clapi-centreon/
image: /2016/12/centreon_clapi_3.png
categories:
  - Monitoring
  - Script
tags:
  - ansible
  - Centreon
  - CLAPI
  - extra module
  - GPLv3
  - module
  - Python

---
## Avant de parler de ansible-module-clapi

Cet article fait parti d’une suite d’articles ayant trait à l’automatisation de la configuration de la supervision Centreon à l’aide de CLAPI et d’Ansible, dont 2 que j’avais lu sur [monitoring-fr][1]. Dans [l’article précédent](/2016/12/07/automatisation-de-la-supervision-avec-centreon-et-ansible-3/), j’avais montré comment aller encore un peu plus loin que ce que Cédric Temple nous avait présenté.

A la fin de l’article, j’introduisais le fait qu’Ansible n’est pas seulement un outil permettant d’exécuter des tâches. Ansible est surtout un gestionnaire de configuration (comme Puppet, Salt, ...).

> _Ansible_ is the simplest way to automate apps and IT infrastructure. Application Deployment + Configuration Management + Continuous Delivery.

Le but est de garantir qu’un ensemble de serveurs donnés, on a **toujours** la même configuration.

Si on utilise Ansible de cet manière, le playbook n’a plus vocation a être utilisé « one shot » après installation d’un serveur. La gestion de la configuration de supervision devient un sous ensemble des configurations par défaut qui sont régulièrement vérifiées. Les playbooks qui définissent le SI sur l’ensemble des serveurs pour s’assurer qu’ils sont tous « conformes », tout est automatique et on élimine ainsi le risque d’erreurs humaines (type « oublis » ou « suppression accidentelle »).

## Quelle conséquence sur nos playbooks ?

Car bien entendu, cela demande un peu plus de travail et de réflexion.

### Les exécutions multiples

Si on exécute plusieurs fois le même playbook sur un serveur, -il faut impérativement que les commandes de ce playbook n’aient aucune incidence sur l’état du serveur si celui ci est déjà correctement configuré.

J’insiste... La modification **ne doit ce faire que si nécessaire**. Dans le langage Ansible, on dit d’une commande qu’elle est **idempotent**. Retenez bien, c’est important ;-).

![](/2016/11/73068978.jpg)

Prenons pour exemple l’ajout d’une ligne dans le fichier **/etc/sudoers** pour permettre à notre client NRPE d’avoir le droit de réaliser un sudo pour avoir l’exhaustivité des informations renvoyées par multipath. On pourrait « naïvement » réaliser la tâche suivante dans Ansible de la façon suivante :

```
---
- hosts: all
  tasks:
    - shell: 'echo 'nrpe ALL = NOPASSWD: /sbin/multipath' >> /etc/sudoers'
```


Ce playbook fonctionnerait parfaitement.

### Vraiment ?

Pour autant, à chaque exécution du playbook, une ligne sera ajoutée dans chaque serveur et on se retrouvera potentiellement avec des effets de bords à force de modifications successives.

On peut repérer ces changements à l’aide du récapitulatif en fin d’exécution qui serait toujours en _changed_.

```
PLAY RECAP *********************************************************************
srv-nouveau-01           : ok=11   changed=1    unreachable=0    failed=0
```


En fait, il est recommandé d’éviter d’utiliser les modules **shell** et **command** d’Ansible lorsqu’il existe des modules pour réaliser la même action. Typiquement dans ce cas là, l’idéal sera plutôt d’utiliser le module **lineinfile**, qui permet de s’assurer qu’une ligne bien précise est présente ou non, et de ne surtout rien faire (et donc ne rien modifier) si la ligne est déjà présente.

```
---
- hosts: all
  tasks:
    - lineinfile: 'dest=/etc/sudoers state=present line='nrpe ALL = NOPASSWD: /usr/sbin/pvs, /sbin/multipath''
```


**Pour vérifier que votre playbook est idempotent**, le plus simple est donc de lancer plusieurs fois un même playbook et de vérifier que le résultat à la seconde exécution est bien du type :

```
PLAY RECAP *********************************************************************
srv-nouveau-01           : ok=12   changed=0    unreachable=0    failed=0
```


### Les erreurs

Il ne faut pas non plus que les commandes renvoient un code erreur lorsqu’elles s’exécutent pour la 2ème fois. Auquel cas, l’exécution du playbook sera arrêtée en cours de route.

Si j’exécute une première fois le playbook centreon\_add\_host.yml, j’obtiendrais le retour suivant.

```
TASK [monitor : centreon add host] *********************************************
changed: [srv-nouveau-01 -> superviseur.company.lan]
```


Tout va bien, mon hôte apparaît dans Centreon. Par contre, si je l’exécute une seconde fois ...

```
TASK [monitor : centreon add host] *********************************************
fatal: [srv-nouveau-01 -> superviseur.company.lan]: FAILED! => {'changed': true, 'cmd': '/usr/bin/centreon -u admin -p admin -o HOST -a add -v \'srv-nouveau-01;srv-nouveau-01;192.168.1.12;generic-host;central;Ping_LAN\'', 'delta': '0:00:00.098198', 'end': '2016-07-25 17:17:01.268410', 'failed': true, 'rc': 1, 'start': '2016-07-25 17:17:01.170212', 'stderr': '', 'stdout': 'Object already exists (srv-nouveau-01)', 'stdout_lines': ['Object already exists (srv-nouveau-01)'], 'warnings': []}
```


### Ignorer les erreurs

La méthode la plus simple pour gérer ce problème serait d’ignorer les erreurs. Ici CLAPI ne renvoie une erreur que pour m’informer que l’hôte existe déjà. Donc la gestion des erreurs et ici l’ajout multiple d’un même hôte est correctement géré par CLAPI.

Ansible le permet à l’aide de l’option _ignore_errors: True_. Dans ce cas là, l’exécution de la commande CLAPI qui renvoie une erreur sera ignoré dans le cas où l’hôte est déjà présent.

Mais la solution n’est pas satisfaisante : on peut se retrouver à masquer de vraies erreurs. Par exemple, si je n’ai pas fourni le bon chemin d’accès au binaire, l’erreur sera cachée et je ne saurai pas que mon playbook ne fonctionne jamais correctement. On peut imaginer plein d’autres cas d’erreurs qui nous laisseraient penser que l’ajout d’hôte se fait bien alors qu’en fait l’erreur est juste masquée.

A l’inverse, on peut trouver des cas où masquer l’erreur peut être légitime. Vous pouvez donc aller voir [ici][4] pour plus de renseignements.

### Tester préalablement la présence de l’hôte

Toujours dans l’esprit **idempotent**, le mieux est donc de vérifier préalablement que le serveur n’est pas déjà renseigné avant de réaliser l’action d’ajout dans Centreon.

Malheureusement, à date, il n’existe pas de fonction dans CLAPI permettant de faire une recherche dans un seul hôte. Je le leur soufflerais peut être ;-). En attendant, on peut quand même s’en sortir grâce à la fonction _show_ qui affiche une liste de tous les serveurs et un _grep_.

En fonction de la présence ou non de la ligne, on obtiendra un code retour de 0 ou 1, ce qui nous permet de valider la présence ou non du serveur.

```
- name: centreon check presence
  shell: /usr/bin/centreon -u '{{ clapi_username }}' -p '{{ clapi_password }}' -o HOST -a show | grep '{{ inventory_hostname }};' >/dev/null
  delegate_to: '{{ centreon_poller }}'
  register: centreon_output

- name: centreon add host
  shell: /usr/bin/centreon -u '{{ clapi_username }}' -p '{{ clapi_password }}' -o HOST -a add -v '{{ inventory_hostname }};{{ inventory_hostname }};{{ ansible_default_ipv4.address }};generic-host;{{ centreon_poller }};Ping_LAN'
  delegate_to: '{{ centreon_poller }}'
  when: centreon_output.rc != 0
```


Cette solution fonctionne mais est loin d’être optimale. D’abord, elle se base sur _grep_, un binaire externe à CLAPI, pour valider la présence du serveur. Ça peut ne pas marcher à tous les coups !

Ensuite, le module **shell** à la fâcheuse caractéristique de ne pas être **idempotent** (c’est une obsession). A chaque exécution, Ansible considérera que le simple fait d’exécuter la commande change le système et affichera **toujours** « changed » même quand en réalité vos serveurs n’auront pas été modifiés !

```
PLAY RECAP *********************************************************************
srv-nouveau-01 : ok=10 changed=1 unreachable=0 failed=0
```


Avec **shell** il n’y a pas vraiment de parade au niveau Ansible. L’idéal serait donc pouvoir disposer d’un module Ansible capable d’interagir avec CLAPI tout en étant idempotent. #Teasing ;-)

## Créer un nouveau module Ansible

Heureusement il est très facile de créer un nouveau module dans Ansible. [Un exemple est proposé sur le site officiel][5] avec des guides pour la proposition de module pour ajout dans les « extra modules ». Et j’ai également pas mal utilisé ce site pour me guider (blog.toast38coza.me, lien mort pas sauvegardé dans Internet Archive).

J’ai donc développé pour mon usage personnel des modules Ansible qui utilisent CLAPI et qui permettent pour l’instant de :

  * ajouter/supprimer un hôte
  * ajouter/supprimer des templates d’hôtes à un hôte
  * ajouter/supprimer un groupe d’hôtes
  * ajouter/supprimer des serveurs dans un groupe d’hôtes
  * régénérer la configuration et redémarrer un poller pour prise en compte des modifications

Et le code est disponible [ici sur mon Github dans le projet ansible-module-clapi][7] sous licence GPLv3.

Une fois les sources récupérées, vous pouvez exécuter ces modules Ansible complémentaires en créant un dossier librairie au même niveau que vos playbooks et en collant les fichiers Python du dépôt.

Un dossier _test_suite_ contient le fichier hosts de cet article, le dossier group_vars avec les variables par groupes, ainsi qu’un playbook de test qui réalisera les actions suivantes :

  * ajouter un hôte dans centreon
  * supprimer ce même hôte de centreon
  * le resupprimer pour vérifier que la suppression d’un hôte déjà supprimé ne provoque pas d’erreur car l’hôte n’existe plus
  * supprimer un groupe testgroup qui n’existe pas pour voir si une erreur est renvoyée
  * ajouter le groupe testgroup
  * ajouter le groupe testgroup pour voir si cela génère une erreur à la 2ème exécution
  * ajouter l’hôte au groupe testgroup
  * ajouter un template à l’hôte
  * si un template d’hôte a été ajouté (oui, on vient de le faire) 
      * déclencher un « handler » => appliquer à l’hôte l’ensemble des templates de services liés au template d’hôte
  * et si n’importe laquelle de ces actions a provoqué une modification sur la base de Centreon (toutes en réalité) 
      * déclencher un « handler » => régénérer la configuration et redémarrer le moteur

### Conclusion

Ceci vous permet d’avoir une vue d’ensemble des fonctionnalités disponibles pour l’instant. Ce n’est bien entendu qu’un début et je continuerai d’ajouter des fonctionnalités à partir de l’API CLAPI qui propose beaucoup plus de fonctionnalités.

Pour autant, ce module me permet aujourd’hui automatiser complètement l’ajout et la suppression des hôtes dans mon serveur Centreon. Actuellement pratiquement 120 serveurs sont gérés de cette manière :

![](/2016/11/centreon_ces02.png)

J’attends bien entendu vos remarques, que ce soit sur le blog ou directement sur Github, avec impatience !


 [1]: https://www.monitoring-fr.org/
 [4]: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html
 [5]: http://docs.ansible.com/ansible/developing_modules.html
 [7]: https://github.com/zwindler/ansible-module-clapi
