---
title: 'Utiliser le gestionnaire d’extension Perl CPAN derrière un proxy'
authors:
  - zwindler
type: post
date: 2017-03-29T12:00:26+00:00
url: /2017/03/29/utiliser-perl-cpan-derriere-proxy/
image: /2017/03/cpan.png
categories:
  - Script
tags:
  - cntlm
  - CPAN
  - FTP
  - ntlmaps
  - Perl
  - proxy

---
## Aaaah, CPAN, un vrai bonheur

Ceux qui me suivent savent que, bien qu’il m’arrive d’utiliser Perl de temps en temps (et même de coder un peu de Perl, ce qui m’a fait acheter Learning Perl et Programing Perl de chez O’Reilly), je passe surtout la plupart de mon temps à pester contre le CPAN ([voir cet article où je détaille entièrement comment installer un simple plugin Nagios sans accès à Internet](/2010/09/08/installer-3-plugins-nagios-dans-eon-1-2-coupe-dinternet-level-2/)).

![](/2016/11/cpan.jpg)

Car CPAN et les modules/dépendances Perl, c’est bien, mais c’est quand même mieux quand on a accès à Internet !

## Pas d’Internet dans mon DC (ou presque)

Il n’est pas rare que je n’ai pas accès à Internet lorsque j’installe un serveur, et c’est généralement dans ce genre de cas qu’on essaye de trouver des bidouilles.

Par exemple, dans les DC qui n’ont accès qu’à un proxy avec authentification NTLMv2 (Microsoft), je n’hésite pas à installer [cntlm][3] (ou avant ntlmaps). C’est crade, mais ça me permet d’avoir mon proxy pour Yum, wget, etc... qui ne seraient pas (ou mal) gérés autrement. Et ça m’a sauvé bien des fois !

Dans le cas qui nous concerne dans cet article sur CPAN, j’ai découvert avec stupeur qu’il existe un « shell » CPAN, auquel on peut tout simplement ajouter une configuration particulière, notamment pour lui donner un proxy !

Voilà de quoi régler une partie de mes problèmes !

Pour activer le shell CPAN, deux méthodes (similaires) :

```
perl -MCPAN -e shell
#ou
cpan
```


### Configurer le proxy pour CPAN

```
o conf init /proxy/


If you're accessing the net via proxies, you can specify them in the
CPAN configuration or via environment variables. The variable in
the $CPAN::Config takes precedence.

 <ftp_proxy>
Your ftp_proxy? [] @IP:<port>

 <http_proxy>
Your http_proxy? [] @IP:<port>

 <no_proxy>
Your no_proxy? [] @IP:<port>


Please remember to call 'o conf commit' to make the config permanent!
```


Et comme nous sommes disciplinés, nous n’oublierons pas d’enregistrer les modifications avec la commande indiquée plus haut

```
o conf commit
```


### Désactiver le proxy

```
o conf no_proxy 1
```


Et on sauvegarde !

```
o conf commit
```


### Bonus track : forcer le proxy HTTP plutôt que FTP

Je me suis retrouvé avec CPAN qui essayait à un moment donner de passer par FTP pour télécharger les packages alors que je n’avais qu’un proxy HTTP. Et pour ce problème particulier, je suis tombé sur cette page sur serverrfault qui donne quelques clés pour s’en sortir :

> Simplest way of having it not use FTP is to shove HTTP URLs on the front of your urllist - or replace it completely like sebastionopilla said.

Pour afficher les URLs utilisées

```
o conf urllist
    urllist
        0 [http://example.org/]
        1 [http://example.org/]
        2 [http://example.org/CPAN/]
```


Exclure une URL de la configuration (un miroir par exemple)

```
o conf urllist unshift http://example.org/here/
```

Pour tout vider

```
o conf urllist -
o conf urllist shift
```


Source : [serverfault.com/questions/130690/force-cpan-to-download-via-http/292696](http://serverfault.com/questions/130690/force-cpan-to-download-via-http/292696)

 [2]: /2016/11/cpan.jpg
 [3]: http://cntlm.sourceforge.net/
