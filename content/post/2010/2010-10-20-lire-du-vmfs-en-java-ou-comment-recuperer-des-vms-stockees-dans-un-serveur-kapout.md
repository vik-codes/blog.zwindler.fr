---
title: Lire du VMFS en Java, ou comment récupérer des VMs stockées dans un serveur Kapout
authors:
  - zwindler
type: post
date: 2010-10-20T13:43:51+00:00
url: /2010/10/20/lire-du-vmfs-en-java-ou-comment-recuperer-des-vms-stockees-dans-un-serveur-kapout/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
  - Stockage
tags:
  - Java
  - Linux
  - VMFS
  - Windows

---
Qui n’a jamais rêvé de disposer d’un outil vous permettant de lire du VMFS, cet obscur file system qui ne semble être supporté que par ESX et ESXi? Peut être que ce genre de problématiques ne concerne pas grand monde, tout compte fait ;-)

Mais pour ceux qui se sentent concernés, voici un petit [lien](http://code.google.com/p/vmfs/) vous conduisant sur un projet Java contenant un « driver » pour lire le VMFS (v3). Je ne l’ai pas testé sous tous les systèmes qui font tourner Java (100% des OS un peu récents?) bien entendu, mais ça a plutôt l’air de bien marcher (au moins sous Linux et Windows 7, avec un JRE à jour).

Comme indiqué sur le site, la version r95 du driver permet de naviguer dans l’arborescence, d’afficher les fichiers et les dossiers (récursivement ou non), d’afficher des informations sur un fichier précis, et de copier un fichier vers le disque local. Et en bonus track, il est également capable de s’interfacer avec un serveur WebDav qui permet d’explorer et/ou carrément de monter le disque sur certains OS (non testé, je n’y connais rien en WebDav)

> The VMFS volume can then be browsed using any HTTP browser, or it can be mounted as a file system on many operating systems.

Petit « détail » auquel je n’avais pas vraiment pensé initialement, mais l’opération se corse probablement pas mal si vous disposez d’un quelconque RAID (100% des pros?), puisqu’il devient pratiquement impossible de brancher le disque bêtement avec un adaptateur USB, comme je l’ai fais moi avec mes VMs sur mon stockage non redondé.

J’imagine qu’il est alors nécessaire de monter les disques en RAID tels qu’ils l’étaient sur la machine voulue, et je ne suis même par certain que cela soit trop possible (je devrais me pencher un peu sur le fonctionnement du RAID, je ne connais que la théorie...).

Pour info, j’avais un disque dur qui contenait mes VMs sous ESXi, que je voulais garder sous le coude, au cas où je voudrais les refaire fonctionner dans un Workstation ou de nous sous ESXi (j’ai bêtement activé une licence 2k3 r2 et une autre 2k8 r2 sur mes VM, juste avant de passer sous XenServer). Je l’ai branché sur un boitier disque dur SATA/USB, et j’ai pu naviguer en ligne de commandes dans mon disque, et copier des fichiers sur le disque local instantanément.

Pour ceux qui auraient un peu de mal à suivre les indications d’aide sur le site du projet, voici un petit walkthrough sous Windows. Je rappelle qu’il est nécessaire d’avoir au moins votre client java à jour, ce que tous le monde devrait faire tout le temps, mais bon...

  * Récupérez le disque à explorer, et le brancher sur un adaptateur SATA/USB
  * Ouvrez un interpréteur de commande (cmd.exe pour les « old school », Powershell pour ceux qui veulent se la péter ;-p)
  * Récupérez le numéro du disque par rapport à l’OS. Pour se faire: 
      * tapez « diskpart » dans votre interpréteur de commandes
      * puis « list disk »
      * le résultat retourné devrait être la liste des disques vus par le système, et vous devriez voir votre disque
      * notez son numéro (qu’on appellera [X])
  * Placez vous dans le dossier contenant le JAR du projet, puis tapez la commande « java -jar fvmfs.jar \.PhysicalDrive\[X\] \[commande\] »

Remplacez évidemment [commande] par la commande du CLI que vous souhaitez utiliser :

  * « dirall / » vous renverra l’ensemble de l’arborescence de votre disque
  * « filecopy \[fichier\_source\] \[fichier\_destination\] » vous copiera le fichier situé sur votre VMFS au chemin [fichier\_source] vers le chemin [fichier\_destination] sur votre disque local

La seule chose que je n’arrive pas à comprendre c’est pourquoi ils n’ont pas ajoutés quelques commandes simples comme « copier l’ensemble du disque sur un emplacement local ». On a rarement besoin d’UN seul fichier quand on sauve une VM (composée de fichiers vmdk/nvram/vmsd/vmx/vmxf/...). D’autant plus que le JAR dispose pourtant de toutes les commandes de bases qui permettraient de faire « facilement » cette commande (notamment dirall sur la cible de la copie, puis une boucle avec filecopy)!

Si j’ai un peu de temps, je pense que je jetterai un œil aux sources, pour voir si je ne peux pas patcher leur jar. En attendant que je prenne la peine de réinstaller un environnement de développement Java, voici un script TRES SALE en PowerShell qui fait la même chose [ici](/misc/vmfs.ps1).
