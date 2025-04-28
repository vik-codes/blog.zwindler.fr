---
title: Créer un modèle/template VM Windows XP sous ESXi sans vCenter
authors:
  - zwindler
type: post
date: 2011-03-20T21:58:23+00:00
url: /2011/03/20/copier-une-vm-windows-xp-sous-esxi-sans-vcenter/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - ESX(i)
  - template
  - vCenter
  - vSphere
  - Windows XP

---
VMare a beau prétendre proposer un hyperviseur gratuit, la plupart des fonctions vitales d’un hyperviseur y sont absentes si on ne dispose pas d’une licence, contrairement aux concurrents (libres ou non). Sans prôner le libre à tout prix (je veux bien comprendre qu’il faut vivre de son produit, et ajouter des fonctionnalités selon les licences n’est pas une stratégie marketing dénuée de sens), il est quand même vraiment dommage de proposer un produit gratuit sans donner la possibilité de l’utiliser dans un environnement réel. Ça donne un peu le gout amer de shareware...

Parmi ces fonctions vitales qui n’ont aucunes raisons d’être payantes selon moi, j’ai nommé :

La possibilité de disposer d’un moyen de copier facilement des machines virtuelles pour déployer en peu de temps un SI virtualisé. Rien de plus horrible que de devoir se taper une demi heure de réponses débiles dans l’écran d’installation d’un OS. N’importe quel admin système a désespérément besoin de cette fonctionnalité, aussi petit soit le SI en question, et sans laquelle la virtualisation perd une bonne partie de son avantage en terme de gain de temps par rapport à une architecture physique...

Mais heureusement, il y a une petite astuce assez simple pour s’en affranchir.



Ne cherchez pas dans votre vSphere, la fonctionnalité pour copier des VMs n’apparaitra pas si vous ne disposez pas d’un vCenter. Cependant, en fouillant bien, on retrouve des fonctionnalités utilisant une notion un peu similaire, qui est la notion de template...

vSphere propose de créer et d’importer des virtuals appliances. Pour faire simple, ce sont des machines virtuelles « prêtes à fontionner », généralement diffusées sur Internet dans le but de fournir  des produits logiciels un peu complexe sans installation (OS de supervision prêt à l'emploi, VM faisant office de pare feu, ...).

En détournant cette fonctionnalité à notre avantage, il est donc possible de créer des templates (littéralement « modèle » ou « gabarit ») qui représentent des copies complètes de machines virtuelles à un instant donné. A partir de ce template, il sera donc possible de recréer autant de machines virtuelles identiques que l’on souhaite. CQFD

Voici donc un petit tuto dans la lignée du précédent (rien de techniquement agressif et probablement **beaucoup trop** détaillé) pour créer un template de VM Windows XP en prenant garde de modifier les paramètres qui doivent rester uniques. En effet, deux machines virtuelles créées à partir d’un template ne peuvent pas fonctionner sur un même réseau, pour les raisons suivantes :

  * Si la carte réseau virtuelle était configurée avec une adresse IP, elles auront la même adresse IP
  * Si elles hébergent un système d’exploitation Windows : 
      * Elles auront le même identifiant supposé unique (SID)
      * Elles auront le même nom complet sur le réseau

Comme les données du disque dur sont enregistrées dans le template, il est conseillé de créer des templates avec le moins de données possible sur le disque dur, autant pour des raisons d’économie de l’espace disque que pour gagner en temps de création/déploiement.

Ainsi, il deviendra possible de recréer en quelques minutes des machines virtuelles minimalistes préconfigurées pour une tâche. Attention à ne pas tomber dans l’excès non plus :  il est tout de même malin d’installer toutes les mises à jour et tous les logiciels susceptibles d’être installé sur tous les postes, le but de la création de template étant de gagner du temps!

Pour faciliter le déploiement de VM sous Windows, il est conseillé d’ajouter l’utilitaire NewSID.exe qui sera bine utile pour modifier les identifiants uniques de la machine avant de l’introduire sur le réseau.

**Créer un template à partir du client vSphere**

  * Choisir une machine à exporter en template, et l’éteindre
  * Sélectionner la machine virtuelle choisie
  * Cliquer sur **File/Export/Export OVF Template**
  * Entrer un nom et un répertoire de destination pour le template [Next]
  * Choisir le format d’enregistrement (OVF ou OVA) [Finish]

![](/2011/03/template.png)

![](/2011/03/ovf.png)

Ces deux formats sont tous les deux des valeurs possibles. OVF (Open Virtualization Format) est plus standard que OVA, il sera donc plus simple d’importer des fichiers OVF sur un autre système de virtualisation. Cependant, OVA offre la possibilité de tout stocker dans un seul fichier, contrairement à OVF qui génèrera plusieurs fichiers (configuration et disque dur).

**Exporter un template à partir du client vSphere**

  * Cliquer sur **File/Deploy OVF Template**
  * Choisir un template sur le disque ou depuis une url [Next]
  * L’assistant affiche une description du template [Next]
  * Entrez un nom pour la nouvelle machine virtuelle (qui n’existe pas déjà sur le serveur de virtualisation!) [Next]
  * Choisir dans quel pool la machine virtuelle doit être affectée [Next]
  * Choisir un Datastore dans lequel la machine virtuelle et sa configuration seront stockées [Next]
  * [Finish]

![](/2011/03/template2.png)

![](/2011/03/ovf2.png)

Une fois ces opérations terminées, la machine virtuelle est prête à être démarrée par le serveur ESXi. Cependant, il reste quelques opérations à effectuer :

  * Si la machine est sous Windows : 
      * Il faut changer le SID de la machine car cet SID est supposé unique. Or, toutes les machines déployées avec ce template auront le même SID : il faut donc en générer un nouveau. Ceci peut être fait à l’aide du programme **NewSID.exe** (voir la section « utilisation de NewSID.exe »). La modification de ce paramètre ne peut prendre effet qu’après redémarrage de la machine.
      * Il faut donner un nouveau nom complet à la machine, car ce nom est supposé unique sur le réseau, et des noms identiques pourraient provoquer des conflits. L’utilitaire NewSID.exe permet de changer ce nom complet, après avoir généré un nouvel SID. Une autre manière de le faire est de d’effectuer l’opération suivante : **Panneau de configuration/Système/Nom de l’ordinateur/Modifier** et entrer un nom unique sur le réseau. La modification de se paramètre ne peut prendre effet qu’après redémarrage de la machine.

  * Attribuer à l’interface réseau virtuelle une adresse IP unique en fonction du plan d’adressage du réseau, un masque de réseau adéquat et l’adresse IP du serveur DNS.
  * Intégrer la machine nouvellement configurée au domaine. Pour se faire, il faut effectuer l’opération suivante : **Panneau de configuration/Système/Nom de l’ordinateur/Modifier**, sélectionner **Membre de Domaine**, et entrez le nom du domaine à intégrer.

**Utilisation de NewSID.exe**

Pour pouvoir modifier le SID et le nom complet de la machine, il faut suivre les étapes suivantes :

  * Exécuter NewSID.exe [Next]
  * L’utilitaire affiche le SID actuel, et propose d’en générer un nouveau [Next]
  * [Next]
  * L’utilitaire propose de renommer la machine, entrer un nouveau nom complet [Next]
  * [Next]

Normalement, après ces étapes, le SID sera modifié dans le registre, le nom complet sera modifié, et la machine redémarrera d’elle-même à la fin de la procédure.
