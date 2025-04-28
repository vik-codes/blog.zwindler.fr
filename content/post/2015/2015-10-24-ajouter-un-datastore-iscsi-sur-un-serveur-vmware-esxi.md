---
title: Ajouter un Datastore iSCSI sur un serveur VMware ESXi
authors:
  - zwindler
type: post
date: 2015-10-24T10:30:00+00:00
url: /2015/10/24/ajouter-un-datastore-iscsi-sur-un-serveur-vmware-esxi/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - ESX(i)
  - iSCSI
  - VMKernel
  - VMware

---
Pour pouvoir profiter d’un datastore iSCSI sur VMware ESXi, il faut respecter un certain nombre d’étapes de configuration. Et pour vous éviter de chercher, je vais vous guider pour y parvenir ;-).

## Ajout de l’adaptateur iSCSI {#HAjoutdel27adaptateuriSCSI}

Dans cet article je me concentre sur la version « client lourd » de la console VMware (et donc pas la Web), d’abord parce que tout le monde n’a un vCenter et ensuite parce que c’est somme toute assez similaire sur la version web.

Ouvrez donc votre client VMware, allez dans la page d’administration du serveur, puis dans l’onglet **Configuration** puis sélectionner le menu **Matériel/Adaptateur de Stockage**, vérifier si la ligne **iSCSI Software Adapter** existe ou pas (ici c’est **vmhba33**).

![](/2015/09/01_vmware_iscsi.png)


Si elle n’existe pas, on peut l’ajouter simplement en cliquant sur le bouton « Ajouter » en haut à droite.

## Dédier une interface {#HDE9dieruneinterface}

Une fois qu’on s’est assuré que l’adaptateur iSCSI est présent, on peut commencer à configurer les interfaces réseaux et les réseaux virtuels pour utiliser ce mode de stockage.

Toujours dans l’onglet **Configuration**, ouvrir le menu **Matériel/Mise en réseau**. Avec VMware, il n’est pas possible d’affecter plusieurs interfaces physiques à un même VMKernel capable de faire de l’iSCSI. En clair, si on souhaite faire passer le trafic iSCSI sur plusieurs interfaces, il faut donc créer plusieurs VMKernel,notamment pour du multipathing, voir ce post sur le VMUG Français (lien mort, Internet Archive ne l'a pas).

![](/2015/09/02_vmware_iscsi.png)


Choisir une interface réseau physique à dédier. Dans l’exemple on choisit le _vmnic4_.

On va donc retirer la vmnic4 de tous les autres VMKernel pour dédier le trafic de cette interface au iSCSI. Cliquer sur **Propriétés**, puis sélectionner tour à tour tous les VMKernel et cliquer sur **Modifier**.

![](/2015/09/03_vmware_iscsi.png)


Dans l’onglet Association de cartes réseau, cocher **Changer l’ordre de basculement du commutateur**, puis déplacer la vmnic4 dans les **Adaptateur inutilisés**.

![](/2015/09/04_vmware_iscsi.png)


Reproduire la manipulation pour tous les VMKernel (VMNetwork et Management Network dans l’exemple, mais pas le vSwitch, qui doit lui avoir toutes les interfaces).

## Créer un VMKernel pour l’iSCSI {#HCrE9erunVMKernelpourl27iSCSI}

Créer un nouveau VMKernel avec **Ajouter **et qu’on va nommer de manière particulièrement originale **iSCSI Kernel** ;).

![](/2015/09/05_vmware_iscsi.png)


![](/2015/09/06_vmware_iscsi.png)


Lui attribuer une adresse IP sur le réseau iSCSI puis cliquer sur **Terminer**.

De la même manière que pour l’étape suivante, cliquer sur **Modifier **pour n’affecter que la carte vmnic4 au VMKernel et ainsi la dédier à l’usage iSCSI.

![](/2015/09/07_vmware_iscsi.png)


## Configurer le VMKernel dans l’adaptateur iSCSI {#HConfigurerleVMKerneldansl27adaptateuriSCSI}

Sélectionner le menu **Matériel/Adaptateur de Stockage**, puis le périphérique de stockage iSCSI (**vmhba33**) et enfin clic droit + **Propriété**.

Dans l’onglet **Configuration du réseau**, cliquer sur **Ajouter** pour ajouter le nouveau VMKernel** iSCSI Kernel** remonte comme conforme (ici c’est **vmk2**).

![](/2015/09/081_vmware_iscsi.png)


Le groupe de port **iSCSI Kernel** doit apparaitre dans la liste comme conforme.

![](/2015/09/0811_vmware_iscsi.png)


Une des raisons courantes de « Non conformité » est le fait que l’interface du VMKernel ne soit pas unique (vu dans le paragraphe précédent). On peut cliquer sur le point d’exclamation jaune pour avoir plus de détails sur l’erreur rencontrée.

![](/2015/09/082_vmware_iscsi.png)


Toujours dans la même fenêtre mais dans l’onglet **Découverte dynamique**, cliquer sur **Ajouter**.

Renseigner l’adresse IP de la cible iSCSI à ajouter, puis cliquer sur CHAP pour renseigner les informations d’authentification (décocher **Hériter du parent** pour modifier).

![](/2015/09/08_vmware_iscsi.png)


Une fois validé, le serveur VMware va proposer de rescanner la liste des cibles dynamiques renseignées.

![](/2015/09/09_vmware_iscsi.png)


Le périphérique doit apparaitre dans la liste des périphériques disponibles de ce menu. A partir de là, il peut être utilisé comme un disque ou un LUN classique dans le menu **Matériel/Stockage** qui liste les datastores.

![](/2015/09/0812_vmware_iscsi.png)


Une fois le Datastore iSCSI ajouté il apparait dans la liste comme un datastore normal. Have fun !

![](/2015/09/10_vmware_iscsi.png)

