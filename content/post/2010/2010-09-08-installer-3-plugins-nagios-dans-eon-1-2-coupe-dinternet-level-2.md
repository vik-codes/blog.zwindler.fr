---
title: Installer 3 plugins Nagios dans EON (Eyes of Network) 1.2, coupé d’Internet, level 2
authors:
  - zwindler
type: post
date: 2010-09-08T12:16:33+00:00
url: /2010/09/08/installer-3-plugins-nagios-dans-eon-1-2-coupe-dinternet-level-2/
image: /2010/09/icone_EON.png
categories:
  - Monitoring
  - Virtualisation
tags:
  - check_esx3
  - CPAN
  - ESX(i)
  - EyesOfNetwork
  - Nagios
  - Perl

---
Maintenant que la première partie (check\_esxi\_wbem.py) s’est passée sans encombres, nous allons pouvoir passer à quelque chose d’un peu plus fun : [check_esx3](http://www.op5.com/support/documentation/how-to/400-monitoring-vmware-esx-3x-esxi-vsphere-4-and-vcenter-server). Je rappelle que cet article n’est utile que pour les gens qui se tirent vraiment une balle dans le pied, en utilisant pour des raisons divers un Eyes Of Network 1.2 (EON) et qui n’ont pas accès à Internet sur leur machine de supervision.

Comme son nom l’indique, il s’agit d’un plugin Nagios pour superviser des produits VMware à partir de la version 3. Comme son nom ne l’indique pas, il s’agit d’un plugin en Perl. Joie et bonne humeur, CPAN.org nous voilà...

[Edit]Si vous avez une version de ce plugin antérieure à mai 2010, vous serez peut être heureux d’apprendre que la communauté à retravaillé ce script. Il semblerait que celui ci souffrait de redondances lors des requêtes. Après avoir jeté un œil aux remarques de la communauté, l’éditeur du script a effectué les modifications, et sur une machine peu performante, j’arrive à avoir des gains très significatifs entre les deux versions (2 secondes au lieu de 6 pour une sonde sur l’usage cpu/mémoire), ce qui la soulage beaucoup. Peut être que les gains ne seront pas aussi important pour des machines plus récentes, mais ça ne peut pas faire de mal de mettre ce plugin à jour...[/Edit]

Si vous êtes familier avec Perl, vous saurez que les scripts en Perl utilisent souvent des modules qui peuvent eux même dépendre d’autres modules, et ainsi de suite. Pour régler simplement ces problèmes de dépendance, il existe d’autres modules Perl qui permettent d’automatiser ce processus, en gérant récursivement les dépendances et en les téléchargeant sur Internet, un peu comme un gestionnaire de paquets. Seulement voilà, nous sommes offline, pas d’Internet sur notre serveur de supervision! Damnation...

Bon, commençons par le plus simple... Il arrive que ces modules Perl nécessitent des paquets rpm pour fonctionner. Ici c’est le cas pour notre script, qui nécessite au moins les outils suivants :

  * gcc
  * libxml2
  * libxml2-devel

Pour éviter de devoir se payer l’installation des dépendances des rpms à la main, je vous invite à vous reporter sur « l’astuce » du dépôt local de RPM, disponible [ici](/2015/04/11/tutoriel-migrer-facilement-son-blog-de-wordpress-com-vers-un-hebergement-mutualise-ovh/).

Ça, c’est fait. Passons maintenant aux modules Perl nécessaires qui ne sont pas préinstallés sur notre EON 1.2 :

  * Nagios::Plugin 
      * Class::Accessor
      * Config::Tiny
      * Math::Calc::Units
      * Params::Validate 
          * Module::Build 
              * ExtUtils::CBuilder
              * ExtUtils::Manifest
              * ExtUtils::ParseXS
              * TestHarness
          * Attribute::Handlers
  * VIPerlToolkit 
      * XML::LibXML 
          * XML::SAX
      * Class:MethodMaker
      * SOAP::Lite 
          * URI

Wa-hou... Sacrée liste... Vous aurez remarqué que j’ai respecté une hiérarchie entre les modules. Ce sont les niveaux de dépendances. Ainsi, XML::LibXML nécessite XML::SAX pour pouvoir fonctionner, et XML::SAX doit donc être installé avant XML::LibXML.  
La plupart des modules Perl listés ci-dessus sont disponibles en téléchargement sur le site Internet CPAN.org, et le VI Perl Toolkit est disponible sur le site de téléchargement de VMware.

Je n’ai pas trouvé de moyen d’installer ces modules d’une seule commande sans passer par Internet. On aurait pu imaginer un genre de mécanisme de repository local, comme pour l’astuce avec Yum, qui se chargerait de tout installer d’un coup, où au moins une partie. J’ai quand même du mal à y croire et si quelqu’un à la solution, je serai très content d’avoir votre retour là dessus.

A la place, j’ai du installer un à un tous les modules en respectant l’ordre des dépendances. Comme si ça ne suffisait pas, la procédure pour installer un module Perl diffère selon le module d’installation que son développeur à choisit -_-.

Si vous trouvez un fichier Makefile.PL dans l’archive téléchargée, c’est que le module utilise le module Perl Makefile pour faire les installation :

```
# tar xvzf [module_perl].tar.gz
# cd module_perl
# perl Makefile.PL
# make
# make test
# make install
```


Mais si en revanche vous trouvez un fichier Build.PL, c’est que le module s’installe grâce au module Perl Module::Build (qui est d’ailleurs dans les listes des modules non présents de base dans EON)

```
# tar xvzf [module_perl].tar.gz
# cd module_perl
# perl Build.PL
# ./Build
# ./Build install
```


Deux possibilités : soit vous le savez, soit vous tâtonnez comme un idiot jusqu’à trouver les bonnes commandes. J’ai choisi la seconde solution, je vous le déconseille, donc...

Une fois tous les modules installés, il ne reste plus qu’à utiliser ./check_esx3 en temps qu’utilisateur **nagios**. Plus de détails sur l’utilisation de ce script franchement génial sur [le site d’OP5](http://www.op5.com/support/documentation/how-to/400-monitoring-vmware-esx-3x-esxi-vsphere-4-and-vcenter-server).

## La même chose avec un CentOS 5

Sur un CentOS classique (avec le DVD par défaut), la liste des dépendances manquantes sans Internet est malheureusement plus longue. Jugez par vous même

  * Builder-0.05

  * Nagios-Plugin-0.36 
      * Math-Calc-Units-1.07
      * Config-Tiny-2.14
      * Params-Validate-1.06 
          * Module-Build-0.4001 
              * ExtUtils-ParseXS-3.15
              * ExtUtils-MakeMaker-6.62
              * ExtUtils-Manifest-1.60
              * ExtUtils-CBuilder-0.280205 
                  * PathTools-3.33
                  * IPC-Cmd-0.78 
                      * Locale-Maketext-Simple-0.21
                      * Module-Load-Conditional-0.50 
                          * Module-Load-0.22
                          * Module-CoreList-2.68
                          * Params-Check-0.36 
                              * Perl-OSType-1.002 
                                  * Test-Simple-0.98
              * Test-Harness-3.25
              * Module-Metadata-1.000009
          * Class-Accessor-0.34
          * Attribute-Handlers-0.93

  * SOAP-Lite-0.714 
      * URI-1.60
  * Class-MethodMaker-2.18
  * XML-LibXML-2.0002 
      * XML-SAX-0.99 
          * XML-SAX-Base-1.08

  * Module-Implementation-0.06 
      * Try-Tiny-0.11
      * Test-Fatal-0.010
      * Test-Requires-0.06
      * Module-Runtime-0.013

Pour le fun, voici ma « procédure d’installation » hors ligne pour ce plugin (160 lignes, quand même !).

```
for i in `ls -1`; do tar xzf $i; done
/Builder-0.05
perl Makefile.PL
make
make install
cd ../ExtUtils-MakeMaker-6.62
perl Makefile.PL
make 
make install
cd ../PathTools-3.33
perl Makefile.PL
make 
make install
cd ../Test-Simple-0.98
perl Makefile.PL
make 
make install
cd ../Perl-OSType-1.002
perl Makefile.PL
make 
make install
cd ../Locale-Maketext-Simple-0.21
perl Makefile.PL
make 
make install
cd ../Params-Check-0.36
perl Makefile.PL
make 
make install
cd ../Module-Load-0.22
perl Makefile.PL
make 
make install
cd ../Module-CoreList-2.68
perl Makefile.PL
make 
make install
cd ../ExtUtils-Manifest-1.60
perl Makefile.PL
make 
make install
cd ../Module-Load-Conditional-0.50
perl Makefile.PL
make 
make install
cd ../IPC-Cmd-0.78
perl Makefile.PL
make 
make install
cd ../ExtUtils-CBuilder-0.280205
perl Makefile.PL
make 
make install
cd ../ExtUtils-ParseXS-3.15
perl Makefile.PL
make 
make install
cd ../Attribute-Handlers-0.93
perl Makefile.PL
make 
make install
cd ../Math-Calc-Units-1.07
perl Makefile.PL
make 
make install
cd ../Config-Tiny-2.14
perl Makefile.PL
make 
make install
cd ../Class-Accessor-0.34
perl Makefile.PL
make 
make install
cd ../URI-1.60
perl Makefile.PL
make 
make install
cd ../SOAP-Lite-0.714
perl Makefile.PL
make 
make install
cd ../Class-MethodMaker-2.18
perl Makefile.PL
make 
make install
cd ../XML-SAX-Base-1.08
perl Makefile.PL
make 
make install
yum install libxml2 libxml2-devel
cd ../XML-LibXML-2.0002
perl Makefile.PL
make 
make install
cd ../XML-NamespaceSupport-1.11
perl Makefile.PL
make 
make install
#ou yum install perl-XML-NamespaceSupport.noarch
cd ../XML-SAX-0.99
perl Makefile.PL
make 
make install
cd ../Test-Harness-3.25
perl Makefile.PL
make 
make install
cd ../Module-Metadata-1.000009
perl Makefile.PL
make 
make install
cd ../Try-Tiny-0.11
perl Makefile.PL
make 
make install
cd ../Test-Fatal-0.010
perl Makefile.PL
make 
make install
cd ../Test-Requires-0.06
perl Makefile.PL
make 
make install
cd ../Nagios-Plugin-0.36
perl Makefile.PL
make 
make install
cd ../Archive-Tar-2.02
perl Makefile.PL
make 
make install
cd ../ExtUtils-Install-2.04
perl Makefile.PL
make 
make install
cd ../Module-Build-0.4001
perl Makefile.PL
make 
make install
cd ../Module-Runtime-0.013
perl Makefile.PL
./Build
./Build install
cd ../Module-Implementation-0.06
perl Makefile.PL
make 
make install
cd ../Params-Validate-1.06
perl Build.PL
./Build
./Build install
yum install perl-Crypt-SSLeay.x86_64
cd ..
tar xzf VMware-vSphere-SDK-for-Perl-4.0.0-161974.x86_64.tar.gz
cd vmware-vsphere-cli-distrib/
perl Makefile.PL
make 
make install
cd ..
#necessite aussi le module perl UUID (prérequis, pas optionnel) mais fonctionne quand même sans
tar xzf check_vmware_api-1aae4f6.tar.gz && check_vmware_api-1aae4f6
```
