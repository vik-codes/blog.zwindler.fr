---
title: Erreur DataProtector 110:1022 Impossible de se connecter au Gestionnaire de contrôle des services
authors:
  - zwindler
type: post
date: 2015-06-28T18:13:17+00:00
url: /2015/06/28/erreur-dataprotector-1101022-impossible-de-se-connecter-au-gestionnaire-de-controle-des-services/
image: /2015/06/HP_Data_Protector.png
categories:
  - Logiciel
  - Système
tags:
  - 110:1022
  - antivirus
  - Cell Manager
  - Client DP
  - DataProtector
  - pare feu
  - Trend
  - Windows

---
[Edit]A priori, ça ne marche pas à tous les coups (mais ça a marché au moins une fois). J’ai aussi réussi à m’en sortir en installant le client directement depuis le serveur à sauvegardé. Le serveur était là encore « hors domaine » Active Directory...[/Edit]

L’autre jour en installant un client DataProtector sur un serveur hors de mon domaine MS AD, j’ai eu un nouveau bug étrange de la part de DP. Lors de l’installation du client depuis la console, le message suivant s’affiche :

![](/2015/06/00_dp_error.png)

Ce n’est pas un problème de mot de passe : le message d’erreur qui s’affiche est différent lorsqu’on entre un mot de passe erroné. Ce n’est pas un problème de privilèges comme le message le laisse penser, puisque j’ai essayé avec un compte administrateur local et un compte administrateur du domaine, KO pour les deux. Ce n’est pas un problème d’antivirus (déjà rencontré avec Trend) ni de pare feu.

Je n’ai malheureusement aucune explication sur le problème en lui même, ni sur la solution, que j’ai trouvée grâce à [ce post (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20210922030343/https://dynamic-datacenter.be/?p=1149#more-1149).

A priori, il faut aller sur le **Cell Manager** (et je parle bien du Cell Manager, pas le client sur lequel on souhaite installer l’agent DP) et vérifier qu’il n’y a pas des entrées login/mdp dans la base de DataProtector. Aucune idée de quoi il s’agit, mais l’idée ici est de nettoyer cette liste.

![](/2015/06/01_dp_error.png)

Dans cet exemple, la commande suivante ramène deux entrées :

```
omniinetpasswd -list
```


On supprime les entrées avec

```
omniinetpasswd -clean
```


Et enfin (je ne sais pas si c’est nécessaire), on ajoute à nouveau un compte habilité à installer l’agent DP avec les commandes :

```
```

```
omniinetpasswd -add DOMAIN_AD\login
```

```
omniinetpasswd -inst_srv_user DOMAIN_AD\login
```


A la suite de quoi et sans explication, l’installation marche de nouveau... DP !

![](/2015/06/02_dp_error-640x6031.png)
