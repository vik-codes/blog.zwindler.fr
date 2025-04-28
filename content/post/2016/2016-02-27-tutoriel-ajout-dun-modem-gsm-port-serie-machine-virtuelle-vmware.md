---
title: '[Tutoriel] Ajout d’un modem GSM port série dans une machine virtuelle VMware'
authors:
  - zwindler
type: post
date: 2016-02-27T13:30:07+00:00
url: /2016/02/27/tutoriel-ajout-dun-modem-gsm-port-serie-machine-virtuelle-vmware/
image: /2016/02/233_800.jpg
categories:
  - Monitoring
  - Virtualisation
tags:
  - GSM
  - passthrough
  - port série
  - RS232
  - VMware

---
## GSM, supervision, ordonnanceurs et virtualisation

Avant de dérouler le tutoriel, je voudrais rapidement resituer pourquoi j’ai eu besoin d’affecter un port série physique à une machine virtuelle.

Aujourd’hui, dans mon équipe, on ne déploie presque plus de serveurs physiques. Les seuls qu’on intègre sont quelques rares progiciels dont les couts de licences se calculent en fonction du nombre de cœur et de nouveaux hyperviseurs bien entendu. Dans un proche avenir nous devrons peut être nous y remettre car nous étudions pas mal les technologies de conteneurs (Docker pour ne citer que lui), et l'empilement des couches virtualisation + conteneurs ne nous parait _pas toujours_ opportune.

Du coup, ma direction m’a demandé s’il était possible (je n’ai pas dis souhaitable) que notre future plateforme de supervision pour l’exploitation de notre infrastructure soit une machine virtuelle. Comme les administrateurs d’astreintes sont prévenus la nuit par le biais d’alertes SMS envoyés par un boitier GSM en port série (ou USB, le principe est le même), il fallait pouvoir garantir qu’on puisse reproduire cette fonctionnalité sur une machine virtuelle. C’est donc le but de ce tutoriel : affecter un port série physique (ou un port USB) à une machine virtuelle.

Je reviens sur la raison pour laquelle j’oppose possible et souhaitable. Les moteurs de supervision ne sont ni plus ni moins que des ordonnanceurs. Et qui dit ordonnancement dit nécessité de planifier des événements dans le temps de manière fiable. Et c’est sur le CPU que l’on compte surtout pour cela.

Or, sur une machine virtuelle, le temps CPU n’est pas garanti. Les machines virtuelles se partagent du « temps processeur physique » entre elles. Schématiquement, on pourrait dire que dans certains cas où l’hyperviseur est un peu chargé, les machines se mettent en pause régulièrement en attendant qu’il y ait suffisamment de processeurs physiques pour reprendre l’activité. Cela peut conduire à des dysfonctionnements lorsque les applications (leur cœur applicatif) n’ont pas été prévues pour tenir compte de cette contrainte. Car elle n’existe pas dans le monde physique, où, même si le serveur est chargé, il n’est jamais vraiment figé (pas comme une VM en tout cas).

## Transfert du port série GSM de l’hôte physique vers la machine virtuelle

Je vous passe le moment où vous branchez le module GSM sur le port série ;-).

Une fois le module GSM installé sur le port série de l’hyperviseur, l’ajout du port série se fait machine virtuelle arrêtée. Ouvrez le menu de modification de la machine virtuelle (client lourd ou web, peu importe).

![](/2016/02/serial_1.png)

![](/2016/02/serial_2.png)

![](/2016/02/serial_3.png)

Démarrez la machine virtuelle.

## Installation du smsd

Dans mon cas, pour vérifier que le port fonctionne bien comme je l’entend, j’installer smsd, qui me permet de reproduire ce que j’ai sur mes serveurs physiques.

Récupérez le fichier d’installation RPM sur un dépôt additionnel de type EPEL ou sur des repositories internes. Personnellement j’ai trouvé celui ci, qui fonctionne sur ma CentOS 7

* (lien mort)

Installez le serveur et configurer le fichier de configuration, notamment le code pin !

```
yum install smstools-3.1.15-12.el7.x86_64.rpm #ou smstools si on utilise les repositories
vi /etc/smsd.conf
```


Par défaut, le serveur scanne les fichiers qui sont envoyés dans **/var/spool/sms/outgoing**. Sauf que par défaut l’utilisateur smstools créé par le RPM peut ne pas avoir les droits.

```
chown -R smstools:smstools /var/spool/sms/outgoing
```


De la même manière, les ports séries ne sont utilisables que par **root** et les utilisateurs du groupe **dialout**.

```
ll /dev/ttyS*
crw-rw. 1 root dialout 4, 64  9 févr. 16:36 /dev/ttyS0
crw-rw. 1 root dialout 4, 65  9 févr. 10:40 /dev/ttyS1
crw-rw. 1 root dialout 4, 66  9 févr. 10:40 /dev/ttyS2
crw-rw. 1 root dialout 4, 67  9 févr. 10:40 /dev/ttyS3
```


Voici l’erreur qu’on peut avoir dans le cas où les droits n’ont pas été donnés

```
tail -f /var/log/smsd/smsd.log
2016-02-09 16:05:26,3, GSM1: Couldn't open serial port /dev/ttyS0, error: Permission denied, waiting 30 sec.
2016-02-09 16:05:56,3, GSM1: Cannot open serial port /dev/ttyS0, error: Permission denied
```


```
usermod -a -G dialout smstools
id smstools
uid=992(smstools) gid=990(smstools) groupes=990(smstools),18(dialout)
```


J’ai également eu des problèmes avec SELinux, qui bloquait l’écriture de **smstools** dans **ttyS0** malgré l’ajout au groupe **dialout**. Pour tester si le problème vient de là, vous pouvez temporairement désactiver SELinux, le temps de vérifier, puis affecter les bon droits SELinux.

```
setenforce 0
getenforce
```


Démarrez le démon et le mettez le en démarrage automatique.

```
systemctl daemon-reload
systemctl start smsd
systemctl enable smsd
```


Voici un petit script pour envoyer des SMS correctement formatés à **SMSd** dans le dossier **/var/spool/sms/outgoing**.

```
vi sendsms
#!/bin/sh
# This script send a text sms at the command line by creating
# a sms file in the outgoing queue.
# I use it for testing.

# $1 is the destination phone number
# $2 is the message text
# if you leave $2 or both empty, the script will ask you

DEST=$1
TEXT=$2

if [ -z "$DEST" ]; then
  printf "Destination: "
  read DEST
fi

if [ -z "$TEXT" ]; then
  printf "Text: "
  read TEXT
fi

FILE=`mktemp /var/spool/sms/outgoing/send_XXXXXX`

echo "To: $DEST" >> $FILE
echo "" >> $FILE
echo -n "$TEXT" >> $FILE
```


Modifier les droits de sendsms :

```
chmod +x sendsms
```


Faire un test d’envoi de SMS :

```
./sendsms +33XXXXXXXXX "Test 1 2, 1 2"
```


On peut voir les SMS passer et la communication avec le modem GSM dans le fichier de log **/var/log/smsd/smsd.log** :

```
tail -f /var/log/smsd/smsd.log
2016-02-09 16:17:42,5, GSM1: Modem handler 0 has started. PID: 11881.
2016-02-09 16:17:42,5, GSM1: Using check_memory_method 1: CPMS is used.
2016-02-09 16:17:42,6, GSM1: I have to send 1 short message for /var/spool/sms/checked/send_6G7MYe
2016-02-09 16:17:42,6, GSM1: Sending SMS from  to 33XXXXXXXXX
```
