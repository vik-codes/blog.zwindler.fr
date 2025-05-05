---
title: Administrer des serveurs Windows avec Ansible
authors:
  - zwindler
type: post
date: 2016-11-15T13:00:11+00:00
url: /2016/11/15/administrer-des-serveurs-windows-avec-ansible/
image: /2016/09/ansible-windows.png
categories:
  - Logiciel
  - systeme
tags:
  - ansible
  - kerberos
  - Linux
  - Microsoft
  - PowerShell
  - Python
  - Windows

---
## Ansible sur Windows

> Depuis que j’ai découvert Ansible, ma vie d’Ops a changée.

Tout doit pouvoir être géré par Ansible. Tous les playbooks doivent être **idempotent** (je reviendrais la dessus très probablement). Et du coup, ça vaut aussi pour les serveurs Windows qu’il nous reste !

![](/2016/11/73068978.jpg)


Il n’existe pas encore de version compatible Windows pour l’exécution locale des playbooks. Cependant, il existe tout de même des modules pour administrer via _PowerShell remoting_ des serveur Windows.

La liste des modules pour Windows est disponible [sur cette page](https://docs.ansible.com/ansible/2.9/modules/list_of_windows_modules.html#windows-modules). La plupart ne sont pas intégrés au cœur d’Ansible mais font partis des _extra-modules_.

## Prérequis côté serveur

### Configuration de base (connexion distante avec des comptes locaux)

Il est nécessaire d’installer un module Python permettant la connexion aux Windows via PowerShell sur le serveur Linux qui servira a exécuter les playbooks.

```
pip install "pywinrm>=0.1.1"
```


### Configuration Kerberos (connexion distante avec des comptes de domaine AD)

La configuration de base ne permet pas d’utiliser des comptes de domaine. Dans un environnement d’entreprise, la plupart des serveurs Windows sont intégrés à un domaine Active Directory.

Il est donc intéressant d’installer les clients kerberos qui permettront au serveur Linux avec Ansible de s’authentifier sur un domaine AD.

```
yum -y install python-devel krb5-devel krb5-libs krb5-workstation
pip install kerberos
```


On peut ensuite configurer le fichier **/etc/krb5.conf** en fonction du contexte. Voici les variables à renseigner :

```
[...]
[realms]
 ZWINDLER.INFO = {
  kdc = dc01.zwindler.info
  kdc = dc02.zwindler.info
  kdc = dc03.zwindler.info
 }

[domain_realm]
 .zwindler.info = ZWINDLER.INFO
```


On peut tester que la configuration fonctionne avec la commande **kinit**

```
kinit zwindler@ZWINDLER.INFO
Password for zwindler@ZWINDLER.INFO:
```


**ATTENTION : Il faut obligatoirement donner le nom du domaine en majuscules, et indiquer le nom complet du domaine et pas le nom Netbios. Ca vaut pour le fichier de configuration krb5.conf ET lors de l’appel de la commande kinit.**

La commande ne doit pas retourner d’erreur et on peut vérifier que tout fonctionne avec la commande **klist**

```
klist
Default principal: zwindler@ZWINDLER.INFO

Valid starting       Expires              Service principal
23/08/2016 15:15:33  24/08/2016 01:15:33  krbtgt/ZWINDLER.INFO@ZWINDLER.INFO
        renew until 30/08/2016 15:15:30
```


### Ajout d’un serveur Windows

#### Méthode 1 : Compte local, variables de connexion dans un fichier chiffré

A la différence d’Ansible sous Linux où l’authentification peut se faire sans mot de passe à l’aide de certificats, sous Windows, il sera nécessaire de stocker à un moment donné le mot de passe d’un compte qui pourra se connecter sur les serveurs Windows.

On ajoute d’abord les serveurs windows dans le fichiers hosts dans un groupe séparé

```
[zwindler_windows_prod]
antivirus
wsus

[zwindler_prod:children]
zwindler_ansible_prod
zwindler_linux_prod
zwindler_windows_prod

[zwindler_windows:children]
zwindler_windows_prod
```


On sécurise l’accès au fichier des variables qui contiendra les comptes d’accès aux machines Windows avec l’utilitaire **ansible-vault**. Le fichier ne pourra alors être lu/édité qu’avec le mot de passe.

```
ansible-vault create group_vars/zwindler_windows.yml
New Vault password:

cat group_vars/zwindler_windows.yml
$ANSIBLE_VAULT;1.1;AES256
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111
1111

ansible-vault edit group_vars/zwindler_windows.yml
Vault password:
---
ansible_user: local_admin
ansible_password: xxxxxxxx
ansible_port: 5986
ansible_connection: winrm
#Decommenter si vous utiliser Python 2.7.9+ et des certificats WinRM autosignes (defaut)
#ansible_winrm_server_cert_validation: ignore
```


Comme les serveurs qui ont été ajoutés dans le groupe _zwindler\_windows\_prod_ héritent des variables définies pour _zwindler_windows_ dans _group\_vars/zwindler\_windows.yml_, Ansible les utilisera pour s’y connecter.

#### Méthode 2 : utiliser kinit pour la connexion

Plutôt que d’utiliser un compte local et stocker le mot de passe dans des variables (de préférence chiffré donc) mais quand même devoir taper le mode de passe du vault à chaque fois, il est possible d’utiliser le binaire **kinit** pour gérer l’authentification AD via un ticket Kerberos.

```
# kinit domain_admin@ZWINDLER.INFO
Password for domain_admin@ZWINDLER.INFO:

# klist
Ticket cache: KEYRING:persistent:0:krb_ccache_B82OOxI
Default principal: domain_admin@ZWINDLER.INFO

Valid starting       Expires              Service principal
23/08/2016 16:37:37  24/08/2016 02:37:37  krbtgt/ZWINDLER.INFO@ZWINDLER.INFO
        renew until 30/08/2016 16:36:57
```


Cependant ce n’est pas suffisant. Pour que l’authentification Kerberos soit tentée par Ansible, il est tout même nécessaire que les variables **ansible_user**, **ansible_port** et **ansible_connection** soient renseignées (bizarrement...).

On doit dont créer un fichier de variable similaire à celui de la méthode précédente, mais sans pour autant nécessiter de le chiffrer puisqu’on ne stockera pas le mot de passe.

```
vi group_vars/zwindler_windows.yml
---
ansible_user: auth@by.kerberos
ansible_port: 5986
ansible_connection: winrm
#Decommenter si vous utiliser Python 2.7.9+ et des certificats WinRM autosignes (defaut)
#ansible_winrm_server_cert_validation: ignore
```


A noter, la valeur **ansible_user** n’est pas du tout utilisée. C’est écrit sur le site d’Ansible :

> Ansible will first attempt Kerberos authentication. This method uses the principal you are authenticated to Kerberos with on the control machine and not &lsquo;ansible_user’.

## Prérequis côté client

Pour pouvoir se connecter il est également nécessaire de réaliser des modifications sur les serveurs que l’on souhaite administrer avec Ansible.

La commande **win_ping** permet de vérifier la connectivité avec les serveurs Windows. Ici la commande échoue car l’exécution de commande PowerShell à distance nécessite l’autorisation explicite sur l’ensemble des serveurs concernés.

```
ansible wsus03 -m win_ping --ask-vault-pass
Vault password:
wsus03 | UNREACHABLE! => {
    "changed": false,
    "msg": "kerberos: 500 WinRMTransport. [Errno 111] Connection refused, ssl: 500 WinRMTransport. [Errno 111] Connection refused",
    "unreachable": true
}
```


De plus, les serveurs dont le pare-feu est activés doivent laisser passer les connexions vers le port 5986 défini dans le fichier _group\_vars/zwindler\_windows.yml_

### Powershell 3 (pour Windows 2008)

Sur les serveurs antérieurs à Windows 2012, seul Powershell 2 est installé et c’est Powershell 3 qu’il faut !

Ansible fournit un script pour aider à l’installation si la machine a accès à Internet

```
powershell https://raw.githubusercontent.com/cchurch/ansible/devel/examples/scripts/upgrade_to_ps3.ps1
```


### (Optionnel) ajouter une exception au pare-feu pour le port 5986

Cette exception n’est plus nécessaire car le script Ansible qui suit l’ajoute de lui même. Cependant si vous souhaitez gérer cela vous même, voici quoi faire.

Se connecter sur le serveur, puis lancer un prompt Powershell avec les droits administrateurs

![](ansible_windows_firewall1.png)

```
netsh advfirewall firewall add rule name="WinRM pour Ansible" dir=in localport=5986 protocol=TCP action=allow
```

![](/2016/09/ansible_windows_firewall2.png)

### Autoriser Ansible à réaliser des actions à distance (WinRM)

Récupérer le script disponible sur la branch « devel » et l’exécuter sur le serveur en question via un prompt Powershell administrateur.

* [github.com/ansible/ansible-documentation/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1](https://github.com/ansible/ansible-documentation/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1)

![](/2016/09/ansible_windows_winrm.png)

Autoriser l’exécution de script Powershell si nécessaire.

```
Set-ExecutionPolicy Unrestricted
```


### Tests et troubleshooting

```
ansible wsus03 -m win_ping --ask-vault-pass
Vault password:
wsus03 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```


Dans le cas où on souhaite réinitialiser les tickets kerberos pour valider le bon fonctionnement, on peut utiliser les commandes **klist** et **kdestroy**

```
klist
Ticket cache: KEYRING:persistent:0:krb_ccache_B82OOxI
Default principal: domain_admin@ZWINDLER.INFO

Valid starting       Expires              Service principal
23/08/2016 16:38:45  24/08/2016 02:37:37  HTTP/wsus03.zwindler.info@ZWINDLER.INFO
        renew until 30/08/2016 16:36:57
23/08/2016 16:37:37  24/08/2016 02:37:37  krbtgt/ZWINDLER.INFO@ZWINDLER.INFO
        renew until 30/08/2016 16:36:57

kdestroy -A
klist
```

Have fun !

## Sources

* [www.it-connect.fr/debutez-avec-ansible-et-gerez-vos-serveurs-windows/](http://www.it-connect.fr/debutez-avec-ansible-et-gerez-vos-serveurs-windows/)
* [docs.ansible.com/ansible/2.9/modules/list_of_windows_modules.html#windows-modules](https://docs.ansible.com/ansible/2.9/modules/list_of_windows_modules.html#windows-modules)
* [docs.ansible.com/ansible/devel/os_guide/intro_windows.html](https://docs.ansible.com/ansible/devel/os_guide/intro_windows.html)
