---
title: 'Signez votre console web Proxmox avec Let’s Encrypt, c’est trivial !'
authors:
  - zwindler
type: post
date: 2017-05-02T12:00:47+00:00
url: /2017/05/02/proxmox-lets-encrypt/
image: /2017/04/proxmox_letsencrypt.png
categories:
  - Autohébergement
  - Virtualisation
tags:
  - automatique
  - CAcert
  - certbot
  - github
  - "Let's Encrypt"
  - neilpang
  - Proxmox VE
  - renouvellement
  - SSH

---
## Vraiment, vous aurez votre petit cadenas vert Let’s Encrypt en 2 minutes

Difficile pour un geek d’avoir éviter la vague Let’s Encrypt.

Pendant longtemps, faire signer son site web en HTTPS par une autorité de certification était à la fois couteux et complexe. Le résultat : pendant des années, les sites en HTTPS ont été autosignés et des entreprises se sont fait du gras sur le dos des professionnels qui souhaitaient « faire les choses bien ».

Il y a bien eu quelques initiatives pour essayer de libérer les Internautes de ce système, mais rien qui n’ait vraiment percé... Jusqu’à Let’s Encrypt :

> Let’s Encrypt is a free, automated, and open certificate authority brought to you by the non-profit Internet Security Research Group (ISRG).

Cool, on peut maintenant obtenir simplement un certificat reconnu dans tous les navigateurs, et suffisament simplement pour que des gens commencent à automatiser le processus (certbot de l’EFF par exemple) !  
![](/2017/04/certbot.png)

Et le moins qu’on puisse dire, c’est que l’effet a été massif. regardez par vous même l’évolution des sites certifiés :

![](/2017/04/letencrypt_growth.png)

## Et Proxmox VE alors ?

Depuis la version 4 de ProxMox, il existe un script qui permet d’ajouter un certificat avec [Let’s Encrypt de manière triviale][3]. Vous n’aurez qu’à taper ces quelques commandes dans votre terminal (soit depuis la console web, soit en SSH)

```
#Renseignez votre email pour être au courant en cas d'échec
EMAIL=admin@example.org

#Installez git
apt-get install git -y

#Copiez le script sur le compte github Neilpang
git clone https://github.com/Neilpang/acme.sh.git acme.sh-master

#Creez un dossier dans le répertoire de configuration de ProxMox
mkdir /etc/pve/.le

#Exécutez le script
cd /root/acme.sh-master
./acme.sh --install --accountconf /etc/pve/.le/account.conf --accountkey /etc/pve/.le/account.key --accountemail "$EMAIL"

#On vérifie que la configuration est bonne dans le fichier de configuration account.conf Généré
cat /etc/pve/.le/account.conf

#On vérifie que la commande suivante renvoie bien le FQDN que l'on souhaite certifier et avec lequel on voudra se connecter (ici, l'adresse sera https://proxmox.example.org)
hostname -f
   proxmox.example.org
```


**Pour que ça fonctionne, vous devrez cependant avoir le port 80 ouvert vers votre ProxMox.**

A priori c’est une des limitations de Let’s Encrypt encore présente, on ne peut pas être en « full HTTPS ». N’oubliez pas de l’ouvrir pour que le client puisse demander à Let’s Encrypt de se connecter chez vous pour générer le certificat.

Maintenant que tout est prêt, on peut maintenant créer le certificat avec cette commande :

```
./acme.sh --issue --standalone --keypath /etc/pve/local/pveproxy-ssl.key --fullchainpath /etc/pve/local/pveproxy-ssl.pem --reloadcmd "systemctl restart pveproxy" -d `hostname -f`
```


A noter : Si la commande _hostname -f_ ne renvoie pas le même FQDN que celui que vous souhaitez certifier, remplacez juste « _-d \`hostname -f\`_ » par « _-d proxmox.example.org_ » ; mais si vous ne savez pas pourquoi vous faites ça, c’est probablement une mauvaise idée ;-).

![](/2017/04/proxmox_letsencrypt01.png)

> TA-DAH

## Mais un certificat, ça expire...

Et oui, les certificats ça expire !

C’est notamment une des raisons pour lesquelles les certificats avaient parfois « mauvaise presse » auprès des admins systèmes. Il fallait faire très attention que les certificats soient renouvelés et livrés dans l’application dans les temps, au risque de se retrouver avec une erreur sur le site web pouvant effrayer les utilisateurs.

Ici, si je ne me trompe pas, le certificat Let’s Encrypt expire au bout de 90 jours. Ça parait très court et ça serait très pénible à renouveler à la main. Heureusement, tout est prévu ;-).

En réalité, le script vérifie au lancement si le certificats est sur le point d’expirer ou pas. On peut donc le lancer régulièrement, sans risque ! Le plus simple est bien entendu de l’ajouter en crontab.

```
crontab -e
45 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null
```


On peut tester à la main pour voir :

```
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh"
[lundi 20 février 2017, 22:55:29 (UTC+0100)] Renew: 'proxmox.example.org'
[lundi 20 février 2017, 22:55:29 (UTC+0100)] Skip, Next renewal time is: vendredi 21 avril 2017, 21:55:01 (UTC+0000)
[lundi 20 février 2017, 22:55:29 (UTC+0100)] Add '--force' to force to renew.
[lundi 20 février 2017, 22:55:29 (UTC+0100)] Skipped proxmox.example.org
```


## Aller plus loin sur Let’s Encrypt

Quelques articles beaucoup plus poussés sur le sujet, certains peut être un peu outdated mais c’est toujours intéressant :

* [letsencrypt.org/](https://letsencrypt.org/)
* [linuxfr.org/news/reparlons-de-let-s-encrypt](http://linuxfr.org/news/reparlons-de-let-s-encrypt)
* [www.nextinpact.com/news/97852-de-cacert-a-lets-encrypt-longue-route-vers-https-pour-tous.htm](https://www.nextinpact.com/news/97852-de-cacert-a-lets-encrypt-longue-route-vers-https-pour-tous.htm)
* [blog.imirhil.fr/2015/12/12/letsencrypt-joie-deception.html](https://blog.imirhil.fr/2015/12/12/letsencrypt-joie-deception.html)


 [3]: https://pve.proxmox.com/wiki/HTTPS_Certificate_Configuration_(Version_4.x_and_newer)#1.29_Install_acme.sh
