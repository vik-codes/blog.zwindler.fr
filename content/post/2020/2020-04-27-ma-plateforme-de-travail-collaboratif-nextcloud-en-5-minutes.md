---
title: Ma plateforme de travail collaboratif Nextcloud en 5 minutes
authors:
  - zwindler
type: post
date: 2020-04-27T06:45:00+00:00
excerpt: "Tutoriel pour installer la plateforme de travail collaboratif Nextcloud en moins de 5 minutes à l'aide de scaleway et d'ansible"
url: /2020/04/27/ma-plateforme-de-travail-collaboratif-nextcloud-en-5-minutes/
image: /2020/04/Nextcloud_Logo.svg_.png
categories:
  - Autohébergement
tags:
  - ansible
  - collabora
  - libre office
  - Nextcloud
  - notes
  - office 365
  - OwnCloud
  - scaleway
  - talk
  - video

---

## C’est quoi Nextcloud ?
  
  
Par où commencer ? Nextcloud, c’est tellement de choses ;-)

Historiquement, [Nextcloud](https://nextcloud.com/) est un fork du projet [Owncloud](https://owncloud.org/), qui visait à fournir un service en ligne de stockage de fichier via une interface web. Un peu comme Dropbox, mais hébergé par vous, chez vous, et donc respectueux de votre vie privée !

Mais aujourd’hui, Nextcloud c’est bien plus que ça. C’est une véritable plateforme de travail collaboratif avec certes un service de gestion, de partage et de synchronisation de fichiers entre plusieurs devices/utilisateurs, mais aussi un serveur libreoffice/collabora de l’édition de fichiers collaboratifs (Office 365/Google Docs), un serveur Talk (visioconférence), calendrier, gestion de notes et bien plus encore.

La solution s’est même nettement étoffée depuis la version 18 qui vient de sortir, avec de très nombreuses extensions.



## Pourquoi attendre si longtemps pour en parler ?
  
  
La première fois que j’ai testé Owncloud, c’était en 2014 lorsque j’ai créé (sans succès) une entreprise d’infogérence spécialisée dans les outils open source. Le but était de fournir, entre autre, un service autohébergé pour justement remplacer Dropbox. Cette annecdote fera peut être sourire certains de mes lecteurs, très impliqués dans Nextcloud :-p.

A l’époque, je n’avais pas du tout aimé Owncloud, que j’avais trouvé moyen en terme d’ergonomie, très lent, etc.

Récemment cependant, Nextcloud a gagné beaucoup de traction et c’est tant mieux, car ça m’a forcé à rester l’outil, qui a vraiment évolué pour le mieux.



## Et comment on va faire pour le déployer si vite ?
  
  
Ahah ! En voilà une bonne question... Grosse surprise, on va déployer tout ça avec un playbook, bien sûr !

Pour ceux qui ne savent pas, à chaque fois que j’installe un soft, j’automatise ça avec ansible, car j’automatise TOUT avec ansible.


![](/2020/04/automate_all_the_things.png)


Je vous met à disposition sur [Github](https://github.com/zwindler/ansible-nextcloud) cet ensemble de playbooks qui vous permettront d’installer un serveur Nextcloud de A à Z en partant d’un serveur Ubuntu 18.04 sur lequel vous avez un accès SSH.

Et pour ceux qui n’ont pas de serveur à disposition, je vous ai également mis un playbook permettant de déployer une machine sur le cloud provider français Scaleway.

Pourquoi Scaleway ? Pas parce que j’ai le moindre partenariat avec eux (pas pour l’instant en tout cas), mais parce :
  
* ils sont français
* ils ont une super API et des modules Ansible qui marchent très très bien (j’ai même fais un live coding avec) avec l’inventaire ansible dynamique (ce que d’autres n’ont pas forcément)
* ils proposent des instances à moins de 4€ par mois, payable à l’heure, ce qui est parfait pour des petits tests
      
  
Mais n’importe quelle autre machine sous Ubuntu 18.04 fera l’affaire !



## Créer une VM sur Scaleway
  
  
Je ne détaillerai pas l’instanciation de la VM sur Scaleway si vous choisissez cette option, car tout est expliqué en détail sur le [README.md du dépôt Github](https://github.com/zwindler/ansible-nextcloud/blob/master/README.md). J’ai également abondamment parlé de [ce sujet à l’occasion d’autres articles](/recherche/?keyword=scaleway)


![](/2020/04/scaleway_vm.png)


## Préparer l’installation de Nextcloud
  
  
Avant de pouvoir installer Nextcloud sur notre nouveau serveur Ubuntu 18.04 tout neuf, il est important de choisir un nom de domaine pour notre futur service Nextcloud. Ajoutez un CNAME permettant de mapper ce nom de domaine sur l’adresse IP de votre machine virtuelle Ubuntu.

Maintenant que le serveur Ubuntu 18.04 est disponible et que le futur service est résolvable, on dispose de 2 méthodes pour installer Nextcloud. Soit on lance le playbook ansible en local sur la machine Nextcloud, soit on l’installe à distance via ansible.

### Si on le lance en local
  
  
Récupérer le repository [zwindler/ansible-nextcloud](https://github.com/zwindler/ansible-nextcloud) directement sur le serveur via un `git clone`. Nous utiliserons le paramètre "-i hosts_local" quand on exécutera `ansible-playbook`.

### Si on a généré une VM avec Scaleway
  
  
Dans ce cas, on profitera de la fonctionnalité d’inventaire dynamique fournie par Scaleway. Nous utiliserons le paramètre "-i dynamic_inventory.yml" quand on exécutera `ansible-playbook`.

### Si vous voulez installer à distance
  
  
Il sera nécessaire de pouvoir se connecter en SSH à la machine distante mais aussi de générer un inventaire pour qu’ansible sache sur quel machine il doit se connecter. Pour le faire on créera un fichier texte avec l’IP du serveur distant, et nous utiliserons "-i hosts_distant" quand on exécutera `ansible-playbook`.


```
echo "IP_of_the_server" > hosts_distant
```



## Installer Nextcloud
  
  
En partant du principe que vous avez utilisé la méthode Scaleway avec l’inventaire dynamique, voilà ce que vous devrez faire :


```
ansible-playbook -i dynamic_inventory.yml -u root nextcloud_install.yml
```



Le playbook vous promptera pour renseigner un certain nombre de variables qui correspondent à votre installation :


```
MariaDB root password: awesome_mariadb_password
Nextcloud MariaDB password: awesome_mariadb_user_password
Your domain: example.org
Nextcloud HTTPS port [8443]: 443
Nextcloud instance name (URL will be https://thisvalue.example.org) [nextcloud]: nextcloudscw
```


![](/2020/04/nextcloud_ansible_prompt.png) 


A l’issue du playbook, vous devriez pouvoir vous connecter sur votre instance pour finaliser l’installation. Lorsque vous vous connecterez pour la première fois, vous tomberez sur un écran qui vous demandera une partie des informations rentrées préalablement



![](/2020/04/nextcloudscw.png) 


## Et la sécurité ?
  
  
Et oui, la sécurité pour un outil aussi sensible que vos documents, c’est important.

Heureusement, Nextcloud est un outil bien packagé et un projet pour lequel la sécurité est au cœur du développement.

Nextcloud met à disposition un scan de sécurité ([scan.nextcloud.com](https://scan.nextcloud.com/)) qui vous permettra de vous tester contre un certain nombre d’attaques connues.

Comme vous pouvez le voir, ça se passe plutôt bien ;-)



![](/2020/04/nextcloudscw_scan.png) 


De même, la configuration nginx (le frontal de notre serveur) coté TLS est elle aussi sécurisée. Par défaut, je désactive TLS 1.0 et 1.1, ce qui peut poser des soucis pour les plus vieux appareil mais permet d’obtenir un joli A+ chez SSL Labs



![](/2020/04/nextcloudscw_ssllabs_a.png) 


Dans le cas où vous souhaiteriez les réactiver, c’est possible (il y a un flag dans le playbook) mais dans ce cas là la note sera rétrogradée à B.



![](/2020/04/nextcloudscw_ssllabs.png) 


Et c’est fini ! Have fun !
