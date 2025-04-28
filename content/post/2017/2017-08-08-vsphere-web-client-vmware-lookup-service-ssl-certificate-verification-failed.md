---
title: 'vSphere Web Client : VMware Lookup Service SSL certificate verification Failed'
authors:
  - zwindler
type: post
date: 2017-08-08T11:30:25+00:00
url: /2017/08/08/vsphere-web-client-vmware-lookup-service-ssl-certificate-verification-failed/
image: /2015/07/vmware2.png
categories:
  - Système
  - Virtualisation
tags:
  - flash
  - lenteur
  - ssl
  - SSL certificate verification failed
  - vCSA
  - VMware
  - VMware Lookup Service
  - vpshere
  - vSphere
  - vSphere 5.5
  - vSphere 5.X
  - web client

---
## Qui a entendu du VMware Lookup Service ?

_[Aparté]M4vr0x ayant pas mal monopolisé le temps de parole sur Proxmox VE, je retourne un peu sur VMware histoire de changer un peu, mais rassurez vous, d’autres articles sur le clustering vont suivre ;-).[/Aparté]_

Un matin d’astreinte comme les autres. On me réveille aux aurores car un serveur Business Object est encore dans les choux. Le serveur Windows qui l’héberge (je ne vous donnerai pas la version, vous allez vous moquer) est encore en carafe, encore pour une raison obscure (pas de pb de RAM, pas de charge CPU, pas de pic d’IO... normal ?).

C’est une vieille infra client, sur laquelle je n’ai plus trop mon mot à dire : elle n’est plus sous ma responsabilité directe, en dehors de l’astreinte. Mais j’ai quand même encore les accès en console VMware pour me connecter et regarder ce qui ne va pas.

> Dans le doute, reboot. Si ça rate, reformate.  
> - Un des hymnes de l’IT au bureau. Roy et Moss approuveraient.

Depuis quelques temps, j’ai des soucis avec mon client lourd vSphere. La console ne s’affiche pas en entier, du coup je ne vois que le quart supérieur gauche de l’écran, ce qui est relativement handicapant.

![](/2017/08/vsphere.png

> Ok je fais comment là ?

De toute façon comme il est déprécié et censé disparaitre depuis des années (la 5.5 je crois ?), je n’ai pas pris la peine de chercher pourquoi et n’utilise plus que le client Web, malgré sa lenteur épique sur les plus vieilles versions.

![](/2017/08/skeleton-gta-v-loading-vsphere-flash-client-please-wait.jpg)

Manque de chance, un message d’erreur m’attend au login !

## Failed to connect to VMware Lookup Service. SSL certificate verification failed

L’erreur a le mérite d’être assez clair. Quelque part, il y a un service qui se charge de vérifier un certificat et ce certificat est mauvais ! Heureusement on trouve pas mal de ressources en anglais sur le sujet, notamment chez Yellow bricks (pour la 5.1, lui).

> « Lorsque vous modifiez le nom d’hôte de vCenter Server Appliance, une erreur Lookup Service apparaît lorsque vous redémarrez le dispositif. »  
> - OK. Qui est le saucisson qui a modifié le hostname mais ne s’est pas logué après pour vérifier que ça fonctionnait ?

C’est donc tout simplement un certificat qui n’est plus valide car le nom d’hôte a changé.

On peut facilement corriger le problème en se connecter sur l’application d’administration de la VCSA. Vous l’avez utilisée lors de l’installation de l’appliance, via l’URL `https://@IP_ou_FQDN_vcenter:5480`.

Il faut se connecter avec le compte root de l’appliance, choisi au moment de l’installation.

Naviguez jusqu’à trouver l’onglet Admin. A partir de là, sur la 5.5, il y a un bouton radio qui permet de régénérer automatiquement les certificats si nécessaire. Passez le à « oui ». **Idéalement il faudra penser à l’enlever une fois le problème réglé, pour d’évidentes raisons de sécurité.**

La documentation officielle indique que redémarrer les services ne suffisent pas. Il est donc réellement nécessaire de rebooter complètement l’appliance car la régénération des certificats se fait au reboot.

![](/2017/08/vcenter_certificate1.png)

**Ne cliquez pas sur « Reset »**, ça efface tous le champs. J’en aurai une bonne à vous raconter à ce sujet d’ailleurs ;-).

Après le reboot, l’erreur sur le vsphere web client sur `https://@IP_ou_FQDN_vcenter:9443` devrait avoir disparue !

## Unable to connect to server

Tout est bien qui fini bien ? Non ! Si vous essayez comme moi de retourner sur le serveur de configuration du vCenter (pour prendre des captures d’écran et faire un article de wiki ou de blog par exemple), vous ne pourrez plus vous connecter. Après le login vous aurez le message suivant qui apparaitra en rouge :

Unable to connect to server

![](/2017/08/vcenter_certificate01.png)

En réalité, c’est simplement un problème de cache de votre navigateur web. Il faut vider votre cache navigateur et accepter le nouveau certificat qui vient d’être régénéré.

## Source

* [www.yellow-bricks.com/2012/12/19/failed-to-connect-to-vmware-lookup-service-ssl-certificate-verification-failed/](http://www.yellow-bricks.com/2012/12/19/failed-to-connect-to-vmware-lookup-service-ssl-certificate-verification-failed/)
* pubs.vmware.com/vsphere-51/index.jsp?topic=%2Fcom.vmware.vsphere.troubleshooting.doc%2FGUID-D9ACB836-2BB4-4DDC-9383-91EF6E546A30.html (lien mort comme absolument tout chez VMware)
