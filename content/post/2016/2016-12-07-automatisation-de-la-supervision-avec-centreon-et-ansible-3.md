---
title: Automatisation de la supervision avec Centreon et Ansible (3)
authors:
  - zwindler
type: post
date: 2016-12-07T13:00:47+00:00
url: /2016/12/07/automatisation-de-la-supervision-avec-centreon-et-ansible-3/
image: /2016/12/centreon_clapi_3.png
categories:
  - Monitoring
  - Script
tags:
  - ansible
  - Centreon
  - CLAPI
  - configuration
  - idempotent
  - Monitoring-FR
  - NRPE
  - template
  - YAML

---
## Articles précédents sur Centreon et Ansible

Cet article fait suite aux deux articles rédigés en mai 2015 par Cédric Temple ([ici][1] et [ici][2]) qui donnent des pistes pour automatiser l’ajout de nœuds à superviser dans un console Centreon grâce à Ansible et CLAPI.

Pour ceux qui ne connaissent pas [Ansible][3], je vous invite fortement à vous documenter sur cet outil de déploiement et de gestion de configuration très complet et qui bénéficie en ce moment d’un fort engouement, surtout depuis qu’Ansible a été racheté par RedHat ;-).

Et pour ceux qui ne connaissent pas [CLAPI][4], il s’agit d’une API mise à disposition avec [Centreon][5]. Elle est installée par défaut dans les dernières versions. Elle permet de réaliser la totalité des opérations pouvant être faites depuis la console web en ligne de commande.

Les deux articles sur **Monitoring-fr** que je cite au début sont une bonne base pour appréhender ces deux sujets. Pour autant, on peut encore aller un peu plus loin et c’est pourquoi je vous propose de repartir de là où s’arrête l’article précédent.

## L’exemple de l’ajout de l’hôte

A la fin de l’article précédent, on sait donc :

  * installer automatiquement les clients de supervision sur un nouvel hôte
  * et réaliser de manière unitaire via Ansible et des playbooks l’ajout et la modification d’hôtes dans Centreon.

J’aimerai revenir sur l’ajout d’hôtes dans Centreon. Pour reprendre l’exemple du playbook d’ajout d’hôtes de Cédric :

```
cat centreon_add_host.yml
- name: centreon add host
   shell: /usr/share/centreon/www/modules/centreon-clapi/core/centreon -u admin -p admin -o HOST -a add -v '{{ inventory_hostname }};{{ inventory_hostname }};{{ ansible_default_ipv4.address }};generic-host;central;ALL_HOST'
   delegate_to: superviseur.company.lan
```


Et voici le fichier d’inventaire dans lequel on déclare l’ensemble de nos serveurs, triés par groupes.

```
cat /etc/ansible/hosts #fichier hosts d'Ansible
                       #ne pas confondre avec le hosts d'un serveur Linux 
[serveurs-centreon]
superviseur.company.lan
pollerprod.company.lan

[serveurs-prod]
srv-prod-01
srv-prod-02

[serveurs-rect]
srv-rect-01
srv-rect-02

[nouveaux]
srv-nouveau-01
srv-nouveau-02

[serveurs-linux:children]
serveurs-prod
serveurs-rect
nouveaux
```


Dans cet exemple simple, la première chose qu’on se dit si on regarde un peu rapidement, c’est qu’on aurait pu réaliser cet ajout à la main (ou via un script) avec CLAPI.

Le gain apporté par Ansible se situe « seulement » dans l’apport des variables _inventory_hostname_ et _ansible\_default\_ipv4.address_.

Ici on tire partie de la faculté qu’a Ansible de récupérer des « facts » sur les machines, telle que l’adresse IP, que nous n’avons pas eu à renseigner.

C’est déjà un bon point par rapport à un script ou une commande à la main ... mais on peut faire mieux !!

## Aller plus loin : avec les variables de groupes

La première chose que je vais montrer dans cet article est qu’on peut également affecter aux groupes d’hôtes dans Ansible des variables.

Dans notre exemple, je vais donc créer un répertoire _group_vars_ dans lequel je vais créer des fichiers de configuration dédiés à chaque groupe. J’en créé un par groupe (ou pas), et Ansible analysera automatiquement le répertoire group_vars et appliquera à mes hôtes toutes ces variables en fonction de ses groupes.

```
cat /etc/ansible/group_vars/serveurs-linux.yml
#NRPE Servers
nrpe_servers: ['192.168.100.10', '192.168.100.11']
#Poller Centreon
centreon_server: 'superviseur.company.lan'
centreon_pollername : 'Central'
centreon_clapi_username : 'admin'
centreon_clapi_password : 'admin'
centreon_clapi_path : '/usr/share/centreon/www/modules/centreon-clapi/core/centreon'
```


Je modifie donc mon playbook de la façon suivante :

```
cat centreon_add_host.yml
---
- name: centreon add host
   shell: '{{centreon_clapi_path}}' -u '{{ centreon_clapi_username }}' -p '{{ centreon_clapi_password }}' -o HOST -a add -v '{{ inventory_hostname }};{{ inventory_hostname }};{{ ansible_default_ipv4.address }};generic-host;{{ centreon_pollername }};ALL_HOST'
   delegate_to: '{{centreon_server}}'
```


Le playbook est beaucoup plus _réutilisable_ qu’avant. Qu’est ce qui a changé ?

  * J’ai variabilisé le chemin vers le binaire d’appel de CLAPI, qui était quand même vraiment long  (Même si on préfèrera probablement plutôt ajouter le chemin dans le PATH, simplement) !
  * Je n’ai plus à renseigner le username et le mot de passe pour CLAPI à chaque appel.
  * Si j’ai plusieurs serveurs Centreon (plusieurs réseaux distincts par exemple), je n’ai qu’à créer un groupe et un fichier de variables dans group\_vars dans lequel je renseignerai « centreon\_server », « clapi\_username » et « clapi\_password » différents. Mon playbook restera inchangé.
  * Si j’ai plusieurs pollers (pollerprod pour la prod dans cet exemple), je peux affecter le serveur directement au bon poller avec la variable « centreon_pollername ».

## Encore un peu plus loin : avec les groupes et l’héritage

Dans la configuration exemple que je donne plus haut, vous aurez peut être remarqué le groupe **serveurs-linux** qui regroupe tous les serveurs des groupes serveurs-prod, serveurs-rect et nouveaux.

```
[serveurs-linux:children]
serveurs-prod
serveurs-rect
nouveaux
```


De cette manière, tous les paramètres communs à tous les serveurs linux peuvent être configurés au niveau serveurs-linux. Les variables seront héritées lors de l’exécution du playbook.

On peut aussi utiliser les groupes comme conditions de l’exécution d’un playbook. Ainsi, le playbook suivant ne s’exécutera que si le serveur fait parti du groupe serveurs-prod.

```
cat centreon_add_host_prod.yml
---
- name: centreon add host when in serveurs-prod
   shell: '{{centreon_clapi_path}}' -u '{{ centreon_clapi_username }}' -p '{{ centreon_clapi_password }}' -o HOST -a add -v '{{ inventory_hostname }};{{ inventory_hostname }};{{ ansible_default_ipv4.address }};generic-host;{{ centreon_pollername }};ALL_HOST'
   delegate_to: '{{centreon_server}}'
   when: "'serveurs-prod' in group_names"
```


## Toujours plus loin : avec les variables et les templates

Les variables sont vraiment un gros plus !

Elles me permettent notamment de configurer les fichiers **nrpe.conf** (ou **ntpd.conf**, **snmpd**, **resolv.conf**, ...) pour accepter les connexions des bons serveurs en fonction de la localisation ou du groupe.

La fonctionnalité la plus utile dans ce cas là est l’utilisation de **templates**. Il s’agit de fichiers de configurations _variabilisés_ qui sont déployés uniquement si nécessaire sur les serveurs cibles en fonction de leurs variables.

**Exemple d’un template de fichier nrpe.conf**

```
{{ ansible_managed }}
cat nrpe.conf.j2
log_facility=daemon
pid_file=/var/run/nrpe.pid
server_port=5666

nrpe_user=nagios
nrpe_group=nagios

allowed_hosts={% for i in nrpe_servers %} {{ i }}, {% endfor %}

debug=0
command_timeout=60
connection_timeout=300

command[check_users]=/libexec/check_users -w 5 -c 10
[...]
```


Le playbook suivant permettra de le déployer sur l’ensemble de mes serveurs CentOS et Redhat le package du client **nrpe** et ses dépendances et configurer le fichier **nrpe.cfg** _en fonction du contexte_ (pour ceux qui n’ont pas encore ce fichier ou une version différente).

```
cat nrpe.yml
---
- hosts: all
  tasks:
    - yum: name={{ item }} state=installed
      with_items:
        - nrpe.x86_64
        - net-snmp
        - sysstat
        - ...

    - template: src=nrpe.cfg.j2 dest=/etc/nagios/nrpe.cfg
```


Une fois exécuté avec la commande suivante, Ansible balayera l’ensemble des serveurs renseignés dans le fichier /etc/ansible/hosts, vérifiera qu’ils ont tous les packages **nrpe** d’installés, puis déploiera sur les serveurs nécessaires le fichier de configuration en fonction des variables de chacun.

```
ansible-playbook -i /etc/ansible/hosts /etc/ansible/nrpe.yml
```


Et dans mon exemple on obtiendra un fichier de la forme suivante :

```
# Ansible managed: nrpe.cfg.j2 modified on 2016-08-14 10:52:51 by ansible on hostname
log_facility=daemon
pid_file=/var/run/nrpe.pid
server_port=5666

nrpe_user=nagios
nrpe_group=nagios

allowed_hosts=192.168.100.10, 192.168.100.11,

debug=0
command_timeout=60
connection_timeout=300

command[check_users]=/libexec/check_users -w 5 -c 10
[...]
```


## Mais Ansible est avant tout un gestionnaire de configuration

Ansible ne sert pas uniquement à déployer des applications sur un serveur ou à exécuter des tâches automatisables. Au delà de ces rôles qu’il rempli à merveille, Ansible est surtout un gestionnaire de configuration (comme Puppet, Salt, ...).

> _Ansible_ is the simplest way to automate apps and IT infrastructure. Application Deployment + Configuration Management + Continuous Delivery.

On le voit avec mon dernier exemple : le but est de garantir qu’un ensemble de serveurs donnés, on a **toujours** la même configuration.

C’est le principe fondamental des outils de gestion de configuration et on comprend vite le gain :

<p style="padding-left: 30px;">
  Si une modification est réalisée par erreur, elle sera automatiquement corrigée au prochain passage du playbook => on n’aura pas besoin d’attendre qu’un administrateur passe par hasard sur un serveur pour remarquer une anomalie sur le NTP par exemple.
</p>

Appliqué à la supervision et Centreon

<p style="padding-left: 30px;">
  Je garanti que tous les serveurs inscris dans Ansible sont automatiquement ajoutés dans Centreon, en fonction de leur groupe. Si un administrateur oublie d’ajouter un serveur ou en supprime un, il sera ré-ajouté à l’exécution d’après sans intervention manuelle.
</p>

C’est donc de cette manière qu’il est conseillé d’utiliser Ansible. Le playbook n’est pas là pour être joué une fois par serveur, au fil de l’eau, car c’est source d’erreur ou d’oublis. On préférera plutôt exécuter régulièrement l’ensemble des playbooks qui définissent le SI sur l’ensemble des serveurs pour s’assurer qu’ils sont tous « conformes », sur tous les aspects dont la supervision.

Le réel gain en terme d’automatisation ce trouve ici.

## Et dans l’article qui va suivre ?

Et c’est sur cette deuxième partie que nous nous attarderons dans le prochain article : la gestion de playbook pour automatiser la configuration de la supervision pour l’ensemble de nos hôtes via des playbooks idempotent (#teasing) !

 [1]: http://www.monitoring-fr.org/2015/05/automatisation-de-la-supervision-exemple-avec-centreon-et-ansible-1/
 [2]: http://www.monitoring-fr.org/2015/05/automatisation-de-la-supervision-exemple-avec-centreon-et-ansible-2/
 [3]: https://www.ansible.com/
 [4]: https://docs.centreon.com/fr/docs/api/clapi/
 [5]: https://www.centreon.com/fr/
