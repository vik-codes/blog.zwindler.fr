---
title: 'Configuration automatique d’un serveur VNC pour CentOS/RHEL avec XFCE'
authors:
  - zwindler
type: post
date: 2016-04-02T10:30:45+00:00
url: /2016/04/02/configuration-automatique-dun-serveur-vnc-centosrhel-xfce/
image: /2015/07/vnc.png
categories:
  - Système
tags:
  - KVM
  - tigerVNC
  - VNC
  - vncserver
  - XFCE

---
Encore un bon vieil article sorti des tiroirs ! Un peu outdated vu que j’ai tout migré sur du CentOS/RHEL 7, mais bon... Dans cet article, je donne pas à pas les commandes pour installer un serveur VNC dans un environnement de type CentOS/RHEL 6 avec XFCE (environnement graphique minimaliste donc), ce qui n’est pas forcément évident car il y a quelques manipulations à faire. Peut être que la procédure est toujours valide en 7, qui sait ?

Dans mon cas, je voulais pouvoir me connecter en VNC sur mon serveur KVM sans pour autant aller dans mon « dressing/salle serveur » brancher un écran. Un genre KVM/IP du pauvre en somme, sans la gestion de l’alimentation et qui nécessite que le serveur se porte bien. Pas très pratique... mais gratuit !

Cependant c’est plus compliqué qu’il n’y parait : Il faut que le serveur VNC se lance automatiquement au boot sans pour autant qu’un session utilisateur soit toujours ouverte. Et après investigation, ce n’est pas forcément évident à faire tant qu’on a pas passé l’écran de connexion.

## Installation des prérequis

La première chose est faire est la plus évidente. On commence par installer le package **vnc-server**

```
yum install tigervnc-server
```


Si vous êtes vraiment accro de la sécurité, ou que vous optimisez au maximum vos ressource et que vous avez installé un CentOS de type « graphique minimal », il faut également ajouter **xterm**

```
yum install xterm
```


Dans tous les cas, il faut impérativement avoir installé un environnement de type _Desktop_ pour que cela fonctionne (dans mon cas XFCE => si vous n’avez aucun environnement graphique vous pouvez toujours vous [raccrocher à ça](http://sharadchhetri.com/2014/01/09/install-xfce-desktop-minimal-installed-centos-6-x/)). Ça parait bête à dire, mais ...

## Configuration

Ensuite, il faut configurer le serveur VNC via le fichier _/etc/sysconfig/vncservers_

```
vi /etc/sysconfig/vncservers
VNCSERVERS="99:root"
VNCSERVERARGS[1]="-geometry 1024x768"
```


La première ligne permet de réserver le port 59**99** pour un accès à la machine avec l’utilisateur **root**.

Pour plus de sécurité (si tant est qu’on puisse parler de sécurité avec VNC), il faut a minima mettre un mot de passe lorsqu’on utilise ce genre de techno. On configure donc le mot de passe et on fait en test en lançant le serveur à la main :

```
vncpasswd
vncserver

New 'kvm.zwindler.fr:9 (root)' desktop is kvm.zwindler.fr:9

Creating default startup script /root/.vnc/xstartup
Starting applications specified in /root/.vnc/xstartup
Log file is /root/.vnc/kvm.zwindler.fr:9.log
```


A partir de ce moment là, les fichiers de configuration et de démarrage automatique sont créés. En voici le contenu, typiquement :

```
[root@kvm .vnc]# cat /root/.vnc/xstartup
#!/bin/sh

[ -r /etc/sysconfig/i18n ] && . /etc/sysconfig/i18n
export LANG
export SYSFONT
vncconfig -iconic &
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
OS=`uname -s`
if [ $OS = 'Linux' ]; then
case "$WINDOWMANAGER" in
*gnome*)
if [ -e /etc/SuSE-release ]; then
PATH=$PATH:/opt/gnome/bin
export PATH
fi
;;
esac
fi
if [ -x /etc/X11/xinit/xinitrc ]; then
exec /etc/X11/xinit/xinitrc
fi
if [ -f /etc/X11/xinit/xinitrc ]; then
exec sh /etc/X11/xinit/xinitrc
fi
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
twm &
```


On est déjà pas trop mal, mais il reste encore une étape pour que le serveur VNC démarre correctement au boot. Il faut ajouter le binaire /usr/bin/startxfce4 après l’invocation du /bin/sh dans le script xstartup de VNC et ajouter le serveur VNC dans la liste des services en démarrage automatique.

```
vi /root/.vnc/xstartup
    #!/bin/sh
    /usr/bin/startxfce4
    [...]
```


```
chmod +x ~/.vnc/xstartup
chkconfig vncserver on
```


Au prochain reboot, votre serveur sera accessible en VNC même si aucun utilisateur ne s’est encore logué.

## Quelques lectures supplémentaires sur le sujet

* wiki.centos.org/HowTos/VNC-Server (lien mort)
* [sharecoding.wordpress.com/2013/03/25/install-xfce4-tigervnc-server-firefox-flash-on-centos-6-2/](https://sharecoding.wordpress.com/2013/03/25/install-xfce4-tigervnc-server-firefox-flash-on-centos-6-2/)
