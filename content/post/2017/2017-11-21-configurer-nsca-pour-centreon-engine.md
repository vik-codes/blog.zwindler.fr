---
title: Configurer NSCA pour Centreon Engine
authors:
  - zwindler
type: post
date: 2017-11-21T12:45:26+00:00
url: /2017/11/21/configurer-nsca-pour-centreon-engine/
image: /2017/11/centreon-nsca.png
categories:
  - Monitoring
tags:
  - Centreon
  - centreon-engine
  - Nagios
  - nagios exchange
  - NRPE
  - NSCA
  - passif

---
## Petit rappel de ce qu’est NSCA

[NSCA][1], pour **Nagios Service Check Acceptor**, est un couple de binaires serveur et client permettant de réaliser les checks passifs avec Nagios. Le check passif est à l’initiative du serveur supervisé, alors qu’a contrario le check actif est déclenché par le serveur superviseur.

![](/2017/11/nsca.png.png)

Au delà de la question de philosophie (j’ai rencontré de fervents défenseurs du check passif avec que je suis plutôt pour ne pas faire confiance au serveur surveillé pour qu’il nous dise qu’il va mal), il y a clairement des cas d’usage où les checks passifs sont bien plus indiqués. 

Si vous voulez aller plus loin sur le sujet actif vs passif, je vous propose d’aller lire [l’article en Français de Olivier Jan][3], fondateur de [Check My Website][4] et figure assez connue de la supervision open source FR.

## Bon alors pourquoi tu fais du NSCA ?

Un bon exemple de usecase où les checks passifs sont clairement indiqués sont les événements applicatifs. Pour une raison ou pour une autre, un traitement applicatif (par exemple de type batch) a échoué. Je pourrais aller vérifier régulièrement les traitements en erreur mais l’ordonnanceur de nagios ne me permet pas de faire un polling plus fin qu’une minute, et en plus la plupart du temps, je vérifierai juste que tout est OK pour rien.

En revanche, l’application, si elle est fiable, sait quand il y a eu une erreur et est capable de me le dire, uniquement quand cela arrive. Le check passif est dans ce cas parfaitement indiqué.

Dans le cadre de la migration de ma supervision d’un Centreon 2.4 vers un CES 3.3 (un article est à venir, je ne fais rien dans l’ordre...), il a été nécessaire de reconfigurer NSCA sur la nouvelle plateforme. La plateforme CES 3.3 étant basée sur un CentOS 6 ainsi que Centreon Engine et non plus Nagios directement, de nombreuses documentations ne sont plus à jour. Et pour cause, NSCA n’a pas pratiquement évolué depuis 2007 (une version sortie en 2011 et une mineure sortie de nulle part fin 2016).

[Ce commentaire sur Nagios Exchange][5] en est assez révélateur :

> The NSCA addon has been ignored and neglected for years. For passive checks, try NRDP instead.
> 
> I can’t imagine why NSCA is still a featured plugin on the Nagios Exchange when it hasn’t received an update in over 3 years.
> 
> The NSCA addons work, but they are buggy, crash too often and will lead to false positives on your Nagios server.
> 
> The 2.9 branch and 2.7 branch are not compatible. The 2.7 branch is still in wide use due to these compatibility issues, but it hasn’t received an update since 1997. The 2.9 branch hasn’t received an update since 2012.

Ambiance.

### Aparté compatibilité

Comme l’indique le commentaire ci dessus que je n’ai malheureusement pas lu, les branches 2.9 et 2.7 ne sont pas compatibles. Ne vous fatiguez pas à essayer de les faire communiquer, ça ne fonctionnera pas. Vous verrez les connexions arriver mais aucun message passer côte serveur de supervision. 

Bon, il faut voir le bon côté des choses, ça me permet de vous offrir en fin d’article une superbe section debugging ;-).

## Comment l’installer ?

On récupère les sources, directement depuis le serveur Centreon :

```
wget https://github.com/NagiosEnterprises/nsca/releases/download/nsca-2.9.2/nsca-2.9.2.tar.gz
tar xzf nsca-2.9.2.tar.gz
cd nsca-2.9.2
./configure --prefix=/usr/share/centreon/ --with-trusted-path=/bin:/sbin:/usr/bin:/usr/sbin:/usr/share/centreon/bin:/usr/lib/nagios/plugins
make all
```


Les sources sont partiellement compilées avec les nouveaux chemins par défauts de CES, qui n’ont plus rien avoir avec ceux de Nagios (historiques). 

On copie le binaire « serveur » dans le dossier de Centreon Engine (pour rester cohérent avec l’ancien système de stockage des fichiers Nagios plus qu’autre chose, il peut être mis n’importe où).

```
cp src/nsca /usr/share/centreon/bin/
```


On n’utilise pas le fichier de configuration disponible dans **sample-config/nsca.cfg** car trop de paramètres ne sont plus en phase. Il est plus simple d’en créer directement un avec tous les bons paramètres :

```
cat > /etc/centreon-engine/nsca.cfg << EOF
    log_facility=daemon
    pid_file=/var/run/nsca.pid
    server_port=5667
    nsca_user=centreon-engine
    nsca_group=centreon-engine 
    debug=0
    command_file=/var/lib/centreon-engine/rw/centengine.cmd
    alternate_dump_file=/var/lib/centreon-engine/rw/nsca.dump
    aggregate_writes=0
    append_to_file=0
    max_packet_age=30
    decryption_method=1
EOF
```


A noter, la **encryption/decryption_method** par défaut et l’absence de mot de passe font de cette solution quelque chose de très peu sécurisé. Je vous invite à consulter [la page suivante pour plus de détails][6].

En revanche on peut utiliser la configuration par défaut pour avoir le client NSCA sur la machine (utile pour tester).

```
cp sample-config/send_nsca.cfg /etc/centreon-engine/send_nsca.cfg
chown centreon-engine:centreon-engine /etc/centreon-engine/send_nsca.cfg
cp src/send_nsca /usr/lib/nagios/plugins/
chown centreon-engine:centreon-engine /usr/lib/nagios/plugins/send_nsca
```


On créé ensuite un script de démarrage. On est encore sur System V et des scripts d’init car CES 3.3 n’est pas livré sur une CentOS 7 mais une 6. A noter, il est également possible de l’installer via xinetd si vous préférez ou que vous en avez l’habitude. Moi je préfère l’avoir comme un service à part.

```
cat /etc/init.d/nsca
#!/bin/sh

### BEGIN INIT INFO
# Provides:          nsca
# Required-Start:    $local_fs $remote_fs $syslog $named $network $time
# Required-Stop:     $local_fs $remote_fs $syslog $named $network
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/Stop the Nagios Service Check Acceptor (nsca) daemon
### END INIT INFO

DAEMON=/usr/share/centreon/bin/nsca
NAME=nsca
DESC="Nagios Service Check Acceptor"
CONF=/etc/centreon-engine/nsca.cfg
OPTS="--daemon -c $CONF"
PIDFILE="/var/run/nsca.pid"
. /etc/init.d/functions

test -f $DAEMON || exit 0

# support a default file
if [ -f /etc/default/nsca ]; then
    . /etc/default/nsca
fi

case "$1" in
start)
    echo "Starting $DESC" "$NAME"
    daemon --pidfile $PIDFILE $DAEMON $OPTS
;;
stop)
    echo "Stopping $DESC" "$NAME"
    killproc -p $PIDFILE $NAME
;;
restart)
    $0 stop
    $0 start
;;
status)
    status_of_proc -p $PIDFILE $DAEMON $NAME
;;
*)
    echo "Usage: $N {start|stop|restart|status}"
    exit 1
;;
esac

exit 0
```


On rend le script exécutable, on l’ajoute au démarrage, et on le lance :

```
chmod +x /etc/init.d/nsca
chkconfig --level 235 nsca on
/etc/init.d/nsca start
```


## Test

### Sur le serveur Centreon

Pour valider que tout fonctionne, on peut se créer un service **nsca_test** sur l’hôte par défaut (Centreon-Server). Ne pas oublier d’autoriser les checks passifs sur ce service dans sa configuration !

```
su - centreon-engine
echo -e "Centreon-Server\tnsca_test passif\t2\tNE PAS TENIR COMPTE" | /usr/lib/nagios/plugins/send_nsca -H 127.0.0.1 -c /etc/centreon-engine/send_nsca.cfg
```


### Sur un client

Maintenant que notre test fonctionne, le mieux c’est quand même de tester en vrai que notre serveur superviser peut déclencher une alerte et que le serveur la récupère. Pour ce faire vous pouvez créer un petit script qui vous servira à valider que tout fonctionne.

```
cat /usr/lib/nagios/libexec/test_nsca.sh
#!/bin/bash
#test_nsca.sh
echo -e "srv_supervise\tmon_service_passif\t2\tmessage" | /usr/lib/nagios/libexec/send_nsca -H 200.140.20.186 -c /etc/nagios/send_nsca.cfg

su - nagios
/usr/lib/nagios/libexec/test_nsca.sh
```


## Debugging

Et oui ! Des fois ça ne fonctionne pas... Lorsque côté client vous avez « 0 packet sent », pas la peine de se fatiguer, c’est côté client que ça coince dans ce cas là. Le format des séparateurs ou le nombre de champs n’est peut être pas le bon.

En revanche, si vous recevez « 1 data packet(s) sent to host successfully. », c’est que c’est bien parti et c’est côté serveur de supervision qu’il faut regarder.

J’ai retrouvé un article sur [le support de Nagios qui donne quelques pistes][7], bien qu’elles soient light...

On peut commencer par demander à NSCA de loguer quelque chose. Oui parce que par défaut, le serveur NSCA ne logue rien du tout... Dans **rsyslog.conf**, ajouter **daemon.debug** pour **/var/log/messages** :

```
vi /etc/rsyslog.conf
[...]
*.info;mail.none;authpriv.none;cron.none;daemon.debug                /var/log/messages
```


Dans la configuration de nsca, on peut aussi passer en mode debug (pas très bavard malheureusement).

```
cat /etc/centreon-engine/nsca.cfg
[...]
debug=1
```


Pour prise en compte, rechargez les deux démons :

```
service nsca restart
service rsyslog restart
```


### Erreur de décalage de temps entre les serveurs

Par défaut, les paquets plus vieux de 30 secondes sont ignorés. Ceci peut poser problème dans le cas où les serveurs de temps ne sont pas à jour.

Côté client, on a le message suivant :

```
1 data packet(s) sent to host successfully.
```


Côté serveur, on a le message suivant dans /var/log/messages (si debug=1 et daemon.debug dans rsyslog.conf)

```
Nov 14 16:00:03 sup02 nsca[6786]: Handling the connection...
Nov 14 16:00:04 sup02 nsca[6786]: End of connection...
```


Alors qu’on devrait avoir :

```
Nov 14 15:51:14 sup02 nsca[1721]: Handling the connection...
Nov 14 15:51:15 sup02 nsca[1721]: SERVICE CHECK -> Host Name: 'srv_supervise', Service Description: 'mon_service_passif', Return Code: '2', Output: 'TEST TEST TEST DGE DGE DGE'
Nov 14 15:51:15 sup02 nsca[1721]: Attempting to write to nagios command pipe
Nov 14 15:51:15 sup02 nsca[1721]: End of connection...
```


Le paramètre à modifier dans ce cas là (même si le mieux serait de corriger les serveurs de temps...) est **max\_packet\_age** dont la valeur par défaut est 30. Vous pouvez la monter jusqu’à 900 (15 minutes) ou bien la positionner à 0 pour accepter tous les paquets, quelque soit leur age.

 [1]: https://exchange.nagios.org/directory/Addons/Passive-Checks/NSCA--2D-Nagios-Service-Check-Acceptor
 [2]: /2017/11/nsca.png.png
 [3]: https://wooster.checkmy.ws/2014/05/monitoring-interne-externe-actif-passif/
 [4]: https://checkmy.ws/fr/
 [5]: https://exchange.nagios.org/directory/Addons/Passive-Checks/NSCA--2D-Nagios-Service-Check-Acceptor/details#rev-3575
 [6]: https://github.com/NagiosEnterprises/nsca/blob/master/SECURITY.md
 [7]: https://support.nagios.com/kb/article.php?id=83
