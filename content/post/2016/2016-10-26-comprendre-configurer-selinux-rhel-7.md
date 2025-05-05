---
title: Comprendre et configurer SELinux sur RHEL
authors:
  - zwindler
type: post
date: 2016-10-26T12:00:13+00:00
url: /2016/10/26/comprendre-configurer-selinux-rhel-7/
image: /2016/10/selinux.png
categories:
  - systeme
tags:
  - CentOS
  - RHEL
  - SELinux

---
## Présentation

> Security-Enhanced Linux, abrégé SELinux, est un Linux security module (LSM), qui permet de définir une politique de contrôle d’accès obligatoire aux éléments d’un système issu de Linux.
> 
> - Wikipedia

Des fois, pas la peine de chercher plus loin : les définitions sont techniques sur Wikipedia sont souvent très bonnes et concises.

Concrètement, SELinux permet de n’autoriser des processus ou des groupes de processus à ne réaliser **que** des opérations (écrire dans tel FS, ouvrir un port, etc) qui sont légitimes par rapport à leur utilisation. L’avantage : en cas de vulnérabilité sur tel ou tel processus, l’attaquant sera limité aux fonctionnalités normalement utilisées par le processus en question, lui compliquant la tâche.

Par défaut, SELinux est activé sur tous les serveurs RHEL mais il est souvent désactivé pour pallier certains effets de bords difficilement décelables (charge CPU très importante, plantages de certaines fonctions d’un logiciels).

Je me souviens avoir lu un jour un fervent défenseur de ce mécanisme de sécurité le qualifier de logiciel le plus incompris de Linux et je suis assez en phase avec cette analyse, tant il est courant de voir comme premier élément d’une procédure d’installation « Désactivez SELinux », même de la part de grandes multinationales comme IBM...

Pour autant, comme toute mesure de sécurité, il n’est évidement pas conseillé de le désactiver, même si cela demande effectivement un peu plus de travail ;-). Et comme tout système, il n’est évidemment pas infaillible non plus donc n’allez pas nécessairement vous croire sortir couvert (plusieurs failles ont été remontées).

## Commandes de gestion de SELinux

### Afficher l’état actuel

```
getenforce
Disabled
```


SELinux est complètement désactivé

```
getenforce
Permissive
```


SELinux n'empêche pas les processus de réaliser des actions non préalablement autorisées mais logue tous les accès non autorisés dans _/var/log/messages_. Pour autant, certains effets de bords (comme des surcharges CPU) peuvent quand même apparaitre...

```
getenforce
Enforcing
```


SELinux est activé. Toutes les actions non préalablement autorisées sont bloquées par sécurité et logué dans _/var/log/audit/audit.log_ et _/var/log/messages_.

### Ajout d’autorisations SELinux

Par défaut lorsque SELinux est réglé sur _Permissive_ ou _Enforcing_, chaque action non autorisée génère une remontée dans _/var/log/messages_.

Exemple de message dans _messages_ :

```
Oct 16 03:43:38 tstbench01 setroubleshoot: SELinux is preventing /usr/bin/bash from getattr access on the file /usr/bin/sudo. For complete SELinux messages. run sealert -l 9a71f3f1-e624-470a-99ae-af04934769e3
Oct 16 03:43:38 tstbench01 python: SELinux is preventing /usr/bin/bash from getattr access on the file /usr/bin/sudo.

*****  Plugin catchall (100. confidence) suggests   **************************

If you believe that bash should be allowed getattr access on the sudo file by default.
Then you should report this as a bug.
You can generate a local policy module to allow this access.
Do
allow this access for now by executing:
# grep sh /var/log/audit/audit.log | audit2allow -M mypol
# semodule -i mypol.pp
```


SELinux a beaucoup évolué et est maintenant relativement simple a administrer. L’ensemble des erreurs provoquées par les modes _Enforcing_ et _Permissive_ sont logués dans _/var/log/messages_ et indiquent la marche à suivre pour corriger le problème.

#### Exemple de résolution pour des plugins Nagios exécutés via NRPE

Le check **check\_cpu\_stats** ne fonctionne pas correctement à cause de SELinux et provoque de fausse alertes sur l’utilisation du CPU. On peut créer un fichier de définitions et le réutiliser pour d’autres serveurs.

```
grep check_cpu_stats /var/log/audit/audit.log | audit2allow -M nrpe
  ******************** IMPORTANT ***********************
  To make this policy package active, execute:
  semodule -i nrpe.pp
```


La commande **audit2allow** parse le log **audit.log** puis consolide les autorisations à ajouter dans un fichier de définitions. On peut directement corriger le problème simplement en exécutant la commande suivante :

```
semodule -i nrpe.pp
```


Si on souhaite savoir quelles autorisations ont été ajoutés, il est possible de consulter les règles en ouvrant le fichier nrpe.te et éventuellement y réaliser des modifications si nécessaire.

```
cat nrpe.te
  module nrpe 1.0;
  require {
        type nrpe_t;
        type tmp_t;
        type var_lib_t;
        class dir { write remove_name add_name };
        class file { execute read create getattr execute_no_trans write ioctl unlink open };
  }
  #============= nrpe_t ==============
  allow nrpe_t tmp_t:dir { write remove_name add_name };
  allow nrpe_t tmp_t:file { write create unlink open };
  allow nrpe_t var_lib_t:file { ioctl execute read open getattr execute_no_trans };
```


Ici, on voit que le plugin souhaite effectuer des opérations sur /var/lib et /tmp.

Ce fichier « .te » modifié ne peut pas être directement appliqué sur le serveur. Il devra être compilé avant de pouvoir être appliqué sur les serveurs.

```
checkmodule -M -m -o nrpe.mod nrpe.te
semodule_package -o nrpe.pp -m nrpe.mod
semodule -i nrpe.pp
```


Une fois compilé et installé sur le serveur, le fichier « .pp » se retrouve dans un dossier spécifique de SELinux.

```
updatedb
locate nrpe
/etc/selinux/targeted/modules/active/modules/nrpe.pp
```


On peut ensuite propager ce fichier de définition de sécurité sur tous les serveurs concernés.

### Modification manuelle de la politique de sécurité

ATTENTION : la commande **setenforce** ne survie pas au reboot.

Passer de _Enforcing_ à _Permissive_ (pas possible de passer directement à _Disabled_).

```
setenforce 0
getenforce
Permissive
```


Passer à _Enforcing_.

```
setenforce 1
getenforce
   Enforcing
```


Pour faire des modifications permanentes, il est nécessaire de modifier le fichier **/etc/selinux/config**. La valeur a modifier est **SELINUX=** avec comme choix _enforcing_, _permissive_ ou _disabled._

```
vi /etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinu security policy is enforced.
#     permissive - SELinu prints warnings instead of enforcing.
#     disabled - No SELinu policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three two values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted

```


**ATTENTION : une erreur dans ce fichier (même une simple faute de frappe) aura pour effet de bloquer la machine au boot. Il faudra passer en mode maintenance ou rescue pour éditer et corriger le fichier. Prudence donc !**

**RAPPEL : Comme tout mécanisme de sécurité, il est évidemment fortement déconseillé de désactiver SELinux de façon permanente !**

### Désactivation automatisée

Pour ceux qui utilisent Ansible, sachez qu’il existe également un module officiel permettant de activer/désactiver SELinux.

```
cat no_selinux.yml
---
# Playbook pour couper SE Linux
- name: "No SE Linux"
  hosts: all
  remote_user: root
  tasks:
    - selinux: state=disabled
```


## Sources

Un article détaillant de manière plus complète SELinux est disponible sur [les HowTos de CentOS][1].

Et aussi :

  * [SELinux expliqué aux administrateurs frileux][2]
  * Le guide de déploiement de CentOS (lien mort, pas dispo sur Internet Archive)
  * [Les limites de la sécurité apportée par SELinux (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20220823151858/http://selinux.gave.me.this.remoteshell.org/)

 [1]: https://wiki.centos.org/HowTos/SELinux
 [2]: https://blog.microlinux.fr/selinux
