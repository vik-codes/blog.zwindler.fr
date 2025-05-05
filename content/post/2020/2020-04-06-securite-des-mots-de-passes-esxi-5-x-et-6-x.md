---
title: Sécurité des mots de passes ESXi 5.X et 6.X
authors:
  - zwindler
type: post
date: 2020-04-06T06:50:00+00:00
excerpt: Gestion de la sécurité des mots de passe locaux dans vSphere ESXi via un module PAM
url: /2020/04/06/securite-des-mots-de-passes-esxi-5-x-et-6-x/
image: /2015/07/vmware2.png
categories:
  - systeme
  - Virtualisation
tags:
  - ESXi
  - Linux
  - pam
  - password
  - securité
  - VMware
  - vSphere

---

## Pourquoi tu nous parles d’ESXi 5 ?
  
  
En voilà une bonne question ! Comme la majorité des blogueurs tech, j’ai dans mes brouillons une bonne 30aines d’articles en attente depuis plus ou moins longtemps (demandez à [Seboss666](https://blog.seboss666.info/) ce qu’il en pense).

Ca fait presque deux ans que je n’ai pas touché à un serveur VMware et pourtant, cette doc était pratiquement "prête à poster". Tout comme "_Intégrer un RHEL 7 dans un Active Directory avec Ansible_" et "_Mise en place de DRBD 8.4 sous CentOS 6.3_", mais c’est une autre histoire...

Et comme je n’aime pas gâcher, je _"profite"_ du confinement pour déconfiner des vieilles docs avant qu’elles ne soient plus définitivement plus d’actualité (trop tard, [vSphere 7 vient de sortir](https://blogs.vmware.com/vsphere/vsphere-7)).

## Les mots de passe dans vSphere
  
  
Un truc que je n’ai pas trouvé très très clair et qu’il est possible dans VMware d’avoir des comptes utilisateurs internes à l’ESXi avec des mots de passe plutôt bof complexes. En effet, il est tout à fait possible d’avoir un mot de passe avec que des lettres minuscules (voire même des chiffres ??) ce qui -nous sommes d’accord- est absolument catastrophique.

Lorsqu’on sait qu’on a parfois besoin de se loguer sur la console à distance et que l’émulation des terminaux KVM des constructeurs est une bouse intergalactique qui vous transforme votre AZERTY en un gloubiboulga à mis chemin entre le QWERTY et DVORAK, c’est parfois tentant...

Bref, j’ai voulu comprendre la logique de VMware pour l’acceptation de la longueur des mots de passe.

En fait, tout est expliqué, en fonction des versions, dans ce KB (lien mort, comme tout chez VMware).

## Password quality-control PAM module
  
  
Je ne savais pas, mais VMware utilise tout simplement le module PAM [Password quality-control PAM](https://linux.die.net/man/8/pam_passwdqc). Il permet de réaliser des contrôles simples sur la qualité des mots de passe choisi pour les utilisateurs Linux.

Globalement, on dispose, via ce module, de différents flags pour valider une politique simple de gestion de mot de passe sur un système Linux (car oui, ESXi c’est un Linux).

Les arguments retenus par VMware sont uniquement basés sur une taille minimale de mots de passe en fonction du nombre de type de caractères différents dont dispose ce mot de passe. Voilà à quoi ça ressemble :


```
password requisite /lib/security/$ISA/pam_passwdqc.so retry=N min=N0,N1,N2,N3,N4
```



Par défaut, voici ce que vous allez trouver dans vSphere 6 :
  
* retry=3 : Un utilisateur a droit à trois tentatives pour entrer un mot de passe suffisant.
* N0=12 : Le mot de passe comportant des caractères d’une seule classe doit contenir au moins 12 caractères.
* N1=9 : Le mot de passe comportant des caractères de deux classes doit contenir au moins neuf caractères, mais qui n’est pas éligibles aux conditions des passphrases.
* N2=8 : Le mot de passe respecte les conditions des passphrases. Il comporte des caractères de deux classes et doit contenir au moins huit caractères.
* N3=7 : Le mot de passe comportant des caractères de trois classes doit contenir au moins sept caractères.
* N4=6 : Le mot de passe comportant des caractères des quatre classes doit contenir au moins six caractères.
      
  
## Procédure pour modifier la politique de sécurité
  
  
Si pour une raison ou pour une autre, vous souhaitez modifier ces paramètres (pour les durcir, hein !), voici la marche à suivre :
  
* Connectez-vous au Shell ESXi et obtenez les privilèges root.
* Ouvrez le fichier passwd avec un éditeur de texte.
      
  
  
```
vi /etc/pam.d/passwd
```
  
* Modifiez la ligne suivante :
      
```
password requisite /lib/security/$ISA/pam_passwdqc.so retry=3 min=disabled,20,20,15,10
```



Cette commande vous permettra de désactiver la possibilité d’ajouter des utilisateurs dans ESXi dont les mots de passe n’ont qu’une classe de caractères et de complexifier fortement les autres types de mots de passe.

Il existe de nombreux autres paramètres. Je vous invite à aller lire [la page man de ce module](https://linux.die.net/man/8/pam_passwdqc) pour améliorer encore la sécurité des mots de passe dans vos ESXi.

## Bonus GUI pour ESXi 6.0
  
  
Si vous êtes allergique à la console jaune et noire d’ESXi (ou que vous n’avez pas la main sur un KVM), sachez que depuis ESXi 6.0, il est possible de modifier directement les valeurs du module PAM depuis la console vSphere. Ça se passe dans les options avancées de l’hôte (cf [cet article de Vladan](https://www.vladan.fr/esxi-6-0-security-password-complexity-changes/)).

> Password Complexity Rules – change here where In previous versions of ESXi, password complexity changes had to be made by hand-editing the /etc/pam.d/passwd file on each ESXi host. In vSphere 6.0 now this can be done by adding an entry in Host Advanced System Settings, enabling centrally managed setting changes for all hosts in a cluster.
  


![](/2017/12/esxi_cluster3.jpg) 

> Ouah, cébo ! 


## Sources
  
  
  
* VMware KB 1012033 (lien mort, comme tout chez VMware)
* Doc vSphere 5, en français (lien mort, comme tout chez VMware)
* [Page man de pam_passwdqc](https://linux.die.net/man/8/pam_passwdqc)
* [Vladan : ESXi 6.0 Security and Password Complexity Changes](http://www.vladan.fr/esxi-6-0-security-password-complexity-changes/)
      
