---
title: 'ESXi 4.0 : Explorons l’Hidden Console Part 3'
authors:
  - zwindler
type: post
date: 2010-09-10T08:11:49+00:00
url: /2010/09/10/esxi-4-0-explorons-lhidden-console-part-3/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - ESX(i)
  - Hidden Console
  - SSH
  - Tech Support Mode

---
Il y a un moment, j’avais promis une dernière partie sur l’hidden console, qui n’est jamais venue parce que j’ai zappé. Du coup maintenant ce n’est plus très frais dans mon esprit. Je vais quand même faire un effort pour me souvenir de l’essentiel dans cette partie où j’aborderai surtout la création d’utilisateurs supplémentaires (plutôt que de n’avoir que root).

Enfin, j’essayerai d’écrire un dernier article qui parlera de l’application de patchs  à l’aide des bundles, le tout en local (ou via SSH).  
Quelques autres infos que je ne sais pas vraiment où mettre : depuis la 4.1, il est possible d’activer depuis le menu gris/jaune l’hidden console, qui n’est plus vraiment cachée, du coup. Cette « toute nouvelle fonctionnalité » s’appelle le **Tech Support Mode**, et vous permet de faire ... la même chose qu’avant! En gros, accès en direct à la console, mais aussi support d’accès à distance via SSH. Ça évite la petite gymnastique VIesque, ce qui peut rassurer certains.  
Mais revenons à nos moutons virtuels...

Accéder en SSH sur votre ESXi, c’est bien, mais si vous êtes obligés de le faire en temps qu’utilisateur **root** à chaque fois, des considérations quant à la sécurité relative de la chose vont peut être vous faire tiquer, et vous aurez bien raison. Du coup, la première idée qui vous vient à l’esprit est « je n’ai qu’à créer un nouvel utilisteur », et vous aurez la encore totalement raison. Ca ne sera peut être pas forcément très sécurisé, mais c’est toujours mieux que de devoir passer votre mot de passe **root** à chaque fois.

Dans un vieux tuto du net, j’ai lu qu’il n’était pas possible d’avoir un autre utilisateur que root pour faire du SSH avec ESXi. Ce n’est pas tout à fait vrai...

Déjà, il faut savoir qu’il est possible de créer des utilisateurs directement depuis le client vSphere. Ok, cela demande un petit effort car dans la version 4.0 U1 (celle dont je dispose, mais c’est probablement pareil depuis au moins VMware Infrastructure) du client, l’opération fonctionne très bien. Ce genre d’utilisateurs peuvent être utilisés pour donner accès à une machine spécifique à un utilisateur, ou bien, comme dans l’exemple qui va suivre, créer un compte possédant des droit read-only pour servir de compte de monitoring dans Nagios (avec check_esx3, par exemple).

Dans la console vSphere, cliquer sur votre serveur, sélectionnez l’onglet **groupes et utilisateurs**. Dans la partie **utilisateurs**, faites un clic droit, puis **ajouter**. Une fenêtre apparait, entre toutes les informations nécessaires, c’est à dire au moins un login, un password, et ajoutez le au groupe **user.**

![](/2010/10/screen11.jpg)

Une fois créé, il est possible d’accorder des permission dans l’onglet **permissions** du serveur. Clic droit dans le tableau qui s’affiche, **ajouter permission**, une fenêtre s’ouvre. Dans cette fenêtre, il faut **ajouter** un utilisateur, puis lui appliquer le privilège qui convient. Dans l’exemple, je lui attribue **Read-only**. Validez, et hop, c’est fait, nous disposons d’un utilisateur non privilégié qui nous servira pour nos sondes nagios.

![](/2010/10/screen21.jpg)

Mais si on essaye de se connecter, effectivement, on se rend compte que cet utilisateur read\_only\_guy n’a pas  accès à SSH. Pourquoi? Tout simplement parce qu’il n’a pas accès à la console tout court. Pour des raisons de sécurité, les utilisateurs créés dans le client vSphere ne peuvent pas se loguer sur la console. Ça parait logique : un utilisateur à qui vous avez donné les droits sur une VM n’a aucune raison d’aller se balader sur votre serveur (encore moins quand on est dans la pensée VMware qui est que seuls les techniciens VMware ont le droit d’utiliser la console)...

« Comment fonctionne cette limitation? ». Vous allez rire, mais c’est tout simplement que le shell utilisé lors de la connexion de l’utilisateur est un programme qui refuse tout accès.

Sous Unix, quand on veux créer un utilisateur pour un service (apache par exemple) mais qu’on ne veux pas que quelqu’un utilise se compte pour se connecter. Au lieu d’attribuer un shell **/bin/sh** (ou **/bin/ash** dans ESXi 4) au compte, on lui attribue **/bin/false**, qui renvoie toujours « faux ». Plus récemment, pour être plus explicite, on spécifie que le compte se connecte avec un shell **/sbin/nologin**, même si c’est strictement la même chose.

Pour pouvoir disposer d’un compte SSH non-root sur votre ESXi, vous avez donc deux solutions :

  * Soit vous créez un compte ssh_guy depuis vSphere, et vous allez vous connecter en root, le temps d’éditer le fichier **/etc/passwd** pour remplacer**/bin/false** par **/bin/ash** dans la ligne correspondant à votre utilisateur. Enfin, il faut impérativement lui créer un dossier home, sans quoi il pourra se loguer mais aucun prompt n’apparaitra.

```
# mkdir /home
# mkdir /home/ssh_guy
```


  * Soit vous créez directement le compte avec le shell qui vous convient depuis votre accès root, de la façon suivante :

```
# mkdir /home
# useradd ssh_guy-s /bin/ash
# passwd ssh_guy
    [entrer le mot de passe pour ssh_guy]
```


Dans un soucis de sécurisation de la connexion SSH, vous pouvez donc imaginer un scénario où le login root pour SSH est interdit, et de passer par un utilisateur ssh_guy qui passe root si nécessaire grâce à `su -` , ce qui évite de devoir faire circuler le mot de passe root partout sur le réseau.

Pour interdire le login root via SSH, il suffit de modifier votre inetd.conf en ajoutant un -w à la fin de la ligne correspondant à l’accès SSH. Moyennant un redémarrage du démon inetd, il ne devrait plus être possible de se loguer directement root via SSH sur votre ESXi.
