---
title: '[Tutoriel] Modem GSM RS232 via convertisseur USB dans une VM VMware'
authors:
  - zwindler
type: post
date: 2016-03-26T11:30:39+00:00
url: /2016/03/26/modem-gsm-rs232-convertisseur-usb-vm-vmware/
image: /2016/02/233_800.jpg
categories:
  - Monitoring
tags:
  - passthrough
  - port série
  - RS232
  - USB
  - VMware

---
Cet article fait suite à mon précédent article dans lequel j’expliquais pas à pas [comment ajouter un modem port série connecté à l’hyperviseur dans un machine virtuelle VMware.][1]

Sauf qu’il n’est pas rare que les serveurs n’aient pas de port RS232 !

Pour pouvoir ajouter quand même ce modem à une VM (car il y en a peu voire pas en USB directement, bizarrement), on peut alors passer par un convertisseur USB/RS232.

## Transfert du port USB du convertisseur de l’hôte physique vers la machine virtuelle

Une fois le module GSM installé sur le port série du convertisseur  **et** le port USB connecté à l’hyperviseur, l’ajout du port USB se fait machine virtuelle arrêtée. Ouvrir le menu de modification de la machine virtuelle et ajouter d’abord un contrôleur USB.

![](/2016/03/usbsms1.png)

![](/2016/03/usbsms2.png)

En l’état, le contrôleur permet maintenant de connecter des périphériques USB provenant du client sur lequel vous êtes connecté (vSphere Client ou Web client). C’est utile pour passer des fichiers aux machines virtuelles depuis une clé USB sur votre poste.

Dans notre cas, on veut ajouter un périphérique qui est sur l’ESXi pour qu’il soit connecté de manière permanente. Ouvrir le menu de modification de la machine virtuelle et ajouter maintenant le convertisseur USB/RS232.

![](/2016/03/usbsms3.png)

![](/2016/03/usbsms4.png)

Ici je n’ai pas choisi de valider le support du vMotion. La machine ne pourra donc pas être basculée tant que le périphérique est « passé » à la VM.

Cette option n’était pas disponible dans les précédentes versions de VMware. Pour autant, j’imagine que ça doit bien fonctionner : en cas de bascule, la machine perd juste l’accès à son périphérique USB ce qui peut ne pas être grave en soit (à vous de le dire).

Démarrez la machine virtuelle.

## Configuration de smsd

L’installation de smsd a été réalisée dans [l’article précédent][1].

De la même manière que pour les ports séries, les ports USB ne sont utilisables que par root et les utilisateurs du groupe _dialout_.

```
ll /dev/ttyUSB*
crw-rw----. 1 root dialout 188, 0 22 mars 16:03 ttyUSB0
```


Configurez le fichier smsd.conf pour qu’il n’utilise plus ttyS0 mais ttyUSB0 !

```
vi /etc/smsd.conf
[GSM1]
device = /dev/ttyUSB0
incoming = yes
```


Démarrez le démon et le mettre en démarrage automatique

```
systemctl daemon-reload
systemctl start smsd
systemctl enable smsd
```


On fait maintenant un test d’envoi de SMS

```
./sendsms +33XXXXXXXXX "Test 1 2 1 2"
```


On peut voir les SMS passer et la communication avec le modem GSM dans le fichier de log /var/log/smsd/smsd.log

```
tail -f /var/log/smsd/smsd.log
2016-02-09 16:17:42,5, GSM1: Modem handler 0 has started. PID: 11881.
2016-02-09 16:17:42,5, GSM1: Using check_memory_method 1: CPMS is used.
2016-02-09 16:17:42,6, GSM1: I have to send 1 short message for /var/spool/sms/checked/send_6G7MYe
2016-02-09 16:17:42,6, GSM1: Sending SMS from to 33XXXXXXXXX
```


 [1]: /2016/02/27/tutoriel-ajout-dun-modem-gsm-port-serie-machine-virtuelle-vmware/
