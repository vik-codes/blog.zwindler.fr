---
title: 'Configurer Yum pour qu’il fouille ici plutôt qu’ailleurs (repository local)'
authors:
  - zwindler
type: post
date: 2010-07-02T14:01:28+00:00
url: /2010/07/02/configurer-yum-pour-quil-fouille-ici-plutot-quailleur/
image: /2010/07/logo_yum_yum.png
categories:
  - systeme
tags:
  - CentOS
  - EyesOfNetwork
  - RPM
  - Yum

---
Dans ma vie de tous les jours, installer des paquets compatibles avec ma version d’EyesOfNetwork (rappel: CentOS modifié) sans accès à Internet a été une petite souffrance. D’abord, vous êtes content quand vous avez trouvé qu’un paquet RPM pour CentOS (pour Red Hat Package manager) s’installe tout bêtement avec la commande « rpm -hiv [path\_du\_rpm.rpm] ». Après, vous vous amusez follement à installer les paquets qu’il vous manque un par un, en en trouvant par chance sur Internet qui ont la bonne version. Enfin ça c’est la méthode brutale. Ça marche, mais bon, ça marche surtout dans des cas simple avec des paquets pas trop regardant au niveau dépendances. Si jamais vous devez installer une version plus récente de la libxml sans aucun compilateur C, ça devient tout de suite un peu fastidieux...

Si comme moi vous êtes « heureux » de travailler offline, vous serez peut être quand même content d’apprendre comment installer des RPMs depuis un média quelconque (DVD de votre distrib, avec tous les paquets optionnels dessus, par exemple), comme si celui ci allait sur Internet.

Pas besoin d’être parfait pour être perfectionniste. Si vous voulez un tuto détaillé où qui fait tout bien dans les règles de l’art, vous trouvez probablement sur le web d’autres tutos écrit par des gens plus au point que moi (j’avais un lien à donner mais je n’arrive pas à le retrouver, bien sûr). Cela dit, ce que je propose est une méthode simple et efficace, et même si ce n’est pas tout à fait la même chose, le problème et la façon de le résoudre seront assez similaires.

Voyons donc plutôt une méthode rapide, sans entrer dans des considération trop techniques. Une fois l’ISO connecté (notamment dans le cas d’une machine virtuelle) ou le DVD inséré dans votre lecteur de galettes (EyesOfNetwork ou tout autre distrib utilisant Yum/des RPM), il faut le monter :

```
mount /dev/hdc /media/cdrom
```


Super! Maintenant que c’est fait, on va éditer les fichiers de configuration de Yum pour lui expliquer que le Net c’est mal. Pour cela, ouvrir avec votre éditeur de texte préféré (pour moi comme je suis en ssh ça sera VI, mais rien ne vous empêche de vous éclater avec sed et des regexp, si vous trouvez ça fun) **/etc/yum.repos.d/CentOS-Base.repo**, et pour chaque entrée (nom de dépôt délimité par [nom_dépôt]) ajouter **enabled = 0** (ou modifier le cas échéant).

Maintenant que c’est fait, on va dire à Yum qu’il doit chercher localement en modifiant les lignes contenant **enabled = 0** par **enabled = 1** en éditant le fichier /etc/yum.repos.d/CentOS-Media.repo

Enfin, tapez

```
rpm-import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
```


Maintenant, vous pouvez tenter des « yum update », « yum install gcc », et tout s’installera en douceur. Ce très cher yum se chargera de vous débarrasser de cette tâche aussi harassante qu’inutile qui est de chercher à résoudre manuellement des dépendances entre paquets!

> « Et là, le miracle s’accomplit »  
> « Ça vous épate hein? »  
> [Les inconnus - Jésus II, le retour]
