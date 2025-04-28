---
title: 'ESXi 4.0 : Explorons l’Hidden Console Part 2'
authors:
  - zwindler
type: post
date: 2010-04-30T13:49:03+00:00
url: /2010/04/30/esxi-4-0-explorons-lhidden-console-part-2/
image: /2014/10/vmware.jpg
categories:
  - Virtualisation
tags:
  - Busybox
  - ESX(i)
  - Hidden Console
  - SSH
  - VMware

---
Dans la partie 1, j’introduisais la console cachée de l’ESXi (aussi bien valable pour la version 3.5 que la version 4.0) et vous donnais LA tips hyper répandue pour y accéder. Allons voir un peu plus loin.  

La console de l’ESXi ressemble beaucoup à un environnement en ligne de commande du même type qu’un système Unix. Et pour cause! Il s’agit en fait d’une version simplifiée appelée [Busybox](http://www.busybox.net/). La plupart des commandes Unix incontournables et l’arborescence typiques sont donc de la partie:

```
ls : lister le contenu du dossier courant
cd [destination]: changer de répertoire courant
cp  [destination] : copier des fichiers
mv  [destination] : déplacer des fichiers
cat [fichier] : afficher à l'écran le contenu d'un fichier, mais aussi utilisé pour écrire dans des fichier en redirigeant les flux vers les entrées/sorties standards
more [fichier] : afficher à l'écran le contenu d'un fichier
vi : l'Editeur de texte (avec un grand E)
ps : lister les processus
grep : recherches dans un texte
kill : envoyer des signaux aux processus, notamment pour les arrêter de façon peu orthodoxe (hin hin hin!)
/ la racine
/etc pour l'aspect configuration du système et des démons/programmes
dev pour accéder aux périphériques, dont les partitions du disque
...
```


J’en passe... A ces classiques s’ajoutent les commandes spécifiques à VMWare, qui permettent la configuration de l’ESXi telle que nous la connaissons :

```
esxtop : l'équivalent de top sous Unix pour voir la charge prise du serveur
esxcfg-* : liste de commandes pour modifier des paramètres de l'ESXi. Ces commandes sont les équivalents des commandes vicfg-* utilisée par le vCli. Je citerai notamment *esxcfg-swscsi* qui permet de gérer l'émulation logicielle du support du scsi par l'ESX(i), qui m'a notamment permit de débugger un ESX qui ne voyait pas des LUN sur le réseau (et mon vCenter était HS).
esxupdate : la commande qui permet de mettre à jour le système ESX(i)
vim-cmd : commande permettant d'accéder à des informations concernant les machines virtuelles, et effectuer certains opérations de bases sur celle ci (du même genre qu'avec la GUI).
```


Le détail de ces commandes peut se trouver dans le document décrivant l’utilisation du [VCLI sous vSphere 4 (lien cassé, j'utilise Internet Archive)](https://web.archive.org/web/20120724043304/http://www.vmware.com/pdf/vsphere4/r40/vsp_40_vcli.pdf).

A partir de là, un des trucs funs et simples à faire est l’activation du ssh. Et oui, là encore, VMWare nous mens, car ESXi est tout à fait capable de communiquer en SSH, il suffit de configurer le démon `inetd` correctement pour qu’il gère ssh (il n’y a pas de sshd dédié).

  * Ouvrir la configuration du démon `inetd` à l’aide de **vi /etc/inetd.conf** (pour les neophytes de vi, accrochez vous, et lisez quelques tutos sur le net, sous peine de vous arracher les cheveux)
  * Supprimer le # devant la ligne qui commence par « ssh » (le # sert à commenter la ligne)
  * Entrer **ps aux | grep inetd** et récupérer le pid ID du processus inetd actif
  * Entrer **kill -HUP [ID].** On tue le processus inetd pour éviter des soucis lors du redémarrage des services
  * Entrer **services.sh restart** pour redémarrer les agents de management

Une fois activé, le SSH permet(par exemple) d’effectuer des transferts depuis un client connecté sur le même réseau vers notre ESXi. Par exemple, on peut utiliser un client WinSCP pour se connecter sur le serveur à l’aide du protocole SCP.

Dernier point sur lequel je vais revenir encore et toujours : Le SSH sur l’ESXi n’est pas une fonctionnalité prévue. En conséquence, son utilisation peut provoquer des dysfonctionnements de votre système. Je vous déconseille donc de l’utiliser, sauf si vous n’avez vraiment pas d’autres choix. De plus, d’éminents blogueurs ont l’air de penser que le SSH de notre Busybox n’étant pas vraiment configuré, l’utilisation de celui ci puisse présenter une faille en terme de sécurité. N’y connaissant pas grand chose en sécurité du protocole SSH s’il est mal configuré, je m’en remet à leur expertise et prône le **principe de précaution**!

Prochaine partie: Mettre à jour l’ESXi depuis l’hidden console, et autres subtilités en vrac sortant de mon REX

HF !
