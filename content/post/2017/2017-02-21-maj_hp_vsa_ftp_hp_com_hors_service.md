---
title: 'Mise à jour HP VSA StoreVirtual : site FTP HP.COM hors service'
authors:
  - zwindler
type: post
date: 2017-02-21T13:00:36+00:00
url: /2017/02/21/maj_hp_vsa_ftp_hp_com_hors_service/
image: /2017/02/hp_vsa-1.png
categories:
  - Stockage
  - Système
  - Virtualisation
tags:
  - CMC
  - FTP
  - HP
  - HP VSA
  - HPe
  - HTTPS
  - Mise à jour

---
## Ma CMC pour HP StoreVirtual ou VSA ne parvient plus à accéder aux mises à jours !

Aaaah, ça faisait longtemps que je n’avais pas dis tout le bien que je pensais d’HPe et notamment d’HP VSA. Mais l’actualité m’a poussé, entre autres choses, à relancer des projets en stand-by.

Note : pour ceux qui ne sauraient pas de quoi je parle, je pense au rachat Simplivity par HPE pour 650 M$ le mois dernier. Racheter le n°2 lorsqu’on a un produit maison envoie un signal clair à tous ceux qui ont investit dans HP VSA => dommage pour vous !

Aujourd’hui, nous avons un cluster HP VSA qui nécessite un petit upgrade avec l’ajout de 2 nœuds supplémentaires. Histoire de faire les choses bien, j’ai voulu m’assurer que les nœuds étaient correctement à jour et quelle n’a pas été ma surprise quand j’ai découvert que la console n’arrivait même plus à contacter le serveur contenant les mises à jour !

## Où sont ces mises à jours ?

Pour simplifier le processus de mise à jour des nœuds StoreVirtual, on utilise la console centralisée CMC -qui peut être installée sur un Linux ou un Windows-. Cette console a l’avantage de servir de pivot pour télécharger les patchs depuis un seul et même endroit (dans mon cas, un serveur Windows).

Dans ce cas-là, c’est bien le client (CMC) qui réalise le téléchargement, pas les serveurs VSA.

Et depuis quelques semaines (mois?), visiblement ça ne marche plus, avec un message qui laisse penser (à tort!) à un souci de connectivité Internet entre mon serveur Windows et les serveurs d’HP.

![](/2017/02/hpvsa_ftp-1.png)

Une partie de la réponse se trouve dans [ce post du forum de la communauté HPE][2].

> Check your upgrades.xml file in the download folder. One of the updates from HP added an incorrect FTP address to the top of the section.

En allant fouiller dans le dossier d’installation de la console CMC, j’ai vite compris le problème. Les URLs contenues dans le fichier _upgrades.xml_ pointent vers un FTP hébergé par **hp**.com.

J’insiste sur **HP** car il faut bien faire la distinction entre HP et HPe, la société HP ayant effectué sa scission entre Hewlett Packard et HPe l’an dernier. Le client CMC avait d’ailleurs été mis à jour entre la 12.5 et la 12.6 pour retirer toutes les références et les images HP pour les remplacer par la charte graphique HPe !

```
C:\Program Files (x86)\HP\StoreVirtual\UI\downloads\upgrades.xml
[...]
    <DownloadURLs>
        <URL>ftp://ftp:cmcdnlds@ftp.hp.com/pub/hp_LeftHandOS/</URL>
[...]
```


Pour vérifier mon intuition, je suis allé directement parcourir le FTP et effectivement, il n’y a plus de dossier **hp_LeftHandOS** sur ce FTP.

![](/2017/02/hpvsa_ftp2.png)

HPe a donc migré tout simplement son FTP vers le site d’HPe et le client ne peut juste pas se mettre à jour...

... Mais ils n’ont pas mis à jour le client pour qu’il pointe sur HPe au moment de la mise à jour 12.5 vers 12.6 quand ils ont changé la charte graphique.

Non non. Ils ont migré leur FTP après.

## Résolution

Le problème est fort heureusement simple à résoudre. Il suffit d’aller chercher la dernière version de la CMC sur le site d’HPe.

Fermez la CMC, allez chercher la dernière version (lien mort, pas disponible sur Internet Archive) et installez la.

![](/2017/02/hpvsa_ftp3.png)

Bon à date l’URL de téléchargement que je vous donne est bonne mais avec HPe on est jamais trop sûr que ça dure donc vous m’excuserez si le lien est cassé à l’avenir ;-).

![](/2017/02/hpvsa_ftp4.png)

Une fois installée, la nouvelle version devrait maintenant se connecter sur le bon site.

![](/2017/02/hpvsa_ftp5-1.png)

Pour information, la connexion se fait même maintenant en HTTPS et non plus en FTP, comme on peut le constater dans le fichier _upgrades.xml_.

```
[...]
    <DownloadURLs>
        <URL>https://downloads.hpe.com/pub/StoreVirtual/CMC/</URL>
[...]
```


Comme quoi, il n’y avait vraiment aucune chance que ça fonctionne avant mise à jour...

 [1]: /2017/02/hpvsa_ftp-1.png
 [2]: https://community.hpe.com/t5/HPE-StoreVirtual-Storage/Cannot-connect-to-FTP-to-update/td-p/6720916
 [4]: /2017/02/hpvsa_ftp3.png
 [5]: /2017/02/hpvsa_ftp4.png
 [6]: /2017/02/hpvsa_ftp5-1.png
