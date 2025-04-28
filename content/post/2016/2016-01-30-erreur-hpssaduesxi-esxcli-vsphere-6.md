---
title: Erreur hpssaduesxi et esxcli depuis vSphere 6
authors:
  - zwindler
type: post
date: 2016-01-30T14:00:16+00:00
url: /2016/01/30/erreur-hpssaduesxi-esxcli-vsphere-6/
image: /2016/01/VSA-StoreVirtual-1.png
categories:
  - Stockage
  - Virtualisation
tags:
  - credstore_admin.pl
  - esxcli
  - HP
  - HP VSA
  - hpssadu
  - hpssaduesxi
  - Smart Storage
  - thumbprint
  - vSphere 6.X

---
## Contexte

J’ai eu une petite mésaventure avec mes amis d’HP lors d’un incident sur une plateforme HP VSA storeVirtual et j’ai perdu pas mal de temps avec l’utilitaire **hpssaduesxi** qui ne fonctionnait pas.

Rapidement pour ceux qui ne savent pas de quoi il s’agit, c’est le pendant virtuel de la solution de virtualisation du stockage HP LeftHand (appliances physiques).

Vos nœuds de _compute_ (hyperviseurs) ESXi ou Hyper-V distribuent la totalité du stockage interne ou DAS (ou autre) à une machine virtuelle (HP VSA, 1 pour chaque serveur). Elles se coordonnent ensuite en cluster pour vous fournir un espace de stockage réparti sur tous vos serveurs. Cela permet entre autre d’obtenir à moindre cout du stockage hautement disponible et scalable.

![](/2016/01/VSA-StoreVirtual-1.png)

Je reviendrais peut être là dessus dans un autre article.

## hpssaduesxi, esxcli et vSphere 6

Comme je le dis en introduction, j’ai eu incident lié au stockage après l’intégration de ma plateforme HP VSA et j’ai donc du ouvrir un ticket auprès de mon support HP.

Sans surprise, la première chose qu’on m’a demandé de faire pour pouvoir traiter ma demande était de collecter les logs de la carte RAID des serveurs ESXi concernés (rapport ADU de son petit nom). Si vous êtes familier des serveurs HP, vous savez qu’un des moyens de récupérer ces informations est de lancer l’utilitaire **hpssadu**, présent sur les différents OS lorsque vous installez les pilotes HP Smart Storage.

Dans mon cas, on m’a demandé de réaliser cet extrait de configuration et de logs à partir d’un serveur Microsoft ayant accès aux serveurs et la CLI VMware d’installée.

Ok, pas de soucis, le technicien me donne la procédure. J’installe la dernière version de la CLI trouvée sur le site de VMware (lien mort, comme tout chez VMware), j’installe le « _HP Smart Storage Administrator Diagnostic Utility (HP SSADU) CLI_« .

Anecdote amusante : le technicien **_HP_** me donne le lien pour la CLI _VMware_, mais pas le lien pour le logiciel de sa propre entreprise... Et quand on connait un peu les méandres du site d’HP (surtout en pleine scission Hewlett Parkard vs HPe) c’est très drôle. Peut être que lui non plus ne sait pas où il est ? Pour vous éviter des sueurs froides et des accès de rage, [il est ici][2].

L’étape d’après consiste à installer la CLI, **PUIS** de copier le binaire **hpssaduesxi.exe** dans le dossier C:\Program Files (x86)\VMware\VMware vSphere CLI\bin (installation par défaut de la CLI vSphere). A quoi bon l’installer alors, si c’est pour le copier à la main ? Mais bon, passons ces détails insignifiants ;-). **  
** 

Et c’est bon, le technicien est formel, ça devrait marcher maintenant : vous pouvez extraire votre rapport ADU en tapant la commande suivante dans un prompt (cmd ou PowerShell) dans le bon dossier.

```
C:\Program Files (x86)\VMware\VMware vSphere CLI\bin> hpssaduesxi.exe --server=[ip_serveur] --user=root --password=[password] report.zip
```


Coup de théâtre : ça ne fonctionne pas.

![](/2016/01/hpssaduesxi2.png)

```
Retrieving report...

   HPSSADUESXI requires the use of the vSphere CLI (esxcli) client
   application. Make certain that this client has been installed
   and is available from this directory. If vSphere CLI has been
   installed, check the correctness of the inputted parameters.
```


Mieux, aucun des techniciens que j’ai eu chez HP ne savait pourquoi. Le niveau 1 je peux comprendre. Mais le plateau entier de niveau 2 ?

A force de perdre du temps, j’ai essayé de générer le rapport ADU directement sur les ESXi.

Mais bien sûr, ça ne fonctionne pas. C’est la raison pour laquelle le rapport ADU doit être généré sur un serveur Windows depuis **hpssaduesxi.exe**.

## Solution

En fait, sans trop de surprises, **hpssaduesxi** n’est qu’une surcouche à **esxcli**. Et du coup l’erreur est tout de suite apparue lorsque j’ai essayé simplement de me connecter en **esxcli** aux serveurs VMware.

![](/2016/01/esxcli2.png)

```
C:\Program Files (x86)\VMware\VMware vSphere CLI\bin> esxcli.exe --server=[ip_serveur] --user=root --password=[password]
   Connect to [ip_serveur] failed. Server SHA-1 thumbprint: BD:F9:D9:40:35:77:E9:AA:8F:BC:04:42:97:AA:A7:4E:AA:E5:BB:4D (not trusted).
```


Le problème vient du fait que depuis la version 6, VMware a renforcé la sécurité et qu’on ne peut plus « ignorer » les certificats qui ne sont pas acceptés. Tout est expliqué ici (lien mort, comme tout chez VMware).

Le site de VMware donne plusieurs solutions, notamment celle d’ajouter le certificat du vCenter comme autorité de certification dans le serveur Windows. Je n’ai malheureusement pas réussi à faire fonctionner cette solution, qui est pourtant selon moi la meilleure.

En revanche, j’ai réussi à faire fonctionner **esxcli** et par conséquent **hpssaducli** en ajoutant l'empreinte SHA-1 de mes serveurs ESXi dans le « credstore », à l’aide de la commande suivante sur le serveur Windows :

```
C:\Program Files (x86)\VMware\VMware vSphere CLI\Perl\apps\general> credstore_admin.pl add --server [ip_serveur] --thumbprint BD:F9:D9:40:35:77:E9:AA:8F:BC:04:42:97:AA:A7:4E:AA:E5:BB:4D

PS C:\Program Files (x86)\VMware\VMware vSphere CLI\bin> .\hpssaduesxi.exe --server=[ip_serveur] --user=root --password=[mdp] report_esxi.zip
   Retrieving report... Decoding... report_esxi.zip saved.
```


## Mot de la fin

Je suis vraiment dépité que personne chez HP ne se soit posé la question de l’impact que ça avait sur leur binaire et que personne n’ait mis à jour la documentation fournie au support pour indiquer la marche à suivre en cas d’erreur !

J’espère être mal tombé et que ce problème est connu chez HP, car le fait que ça ait été à moi de leur trouver la réponse me dépasse...

 [2]: http://h20564.www2.hpe.com/hpsc/swd/public/detail?swItemId=MTX_98b4bd5f4ffb4a59bc17709594&swEnvOid=4168
