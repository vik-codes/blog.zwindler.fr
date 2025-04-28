---
title: Aperçus de la version 3 de Vulture WebSSO
authors:
  - zwindler
type: post
date: 2016-06-16T12:00:53+00:00
url: /2016/06/16/sortie-de-vulture-3/
image: /2014/12/logo2-white1.png
categories:
  - Logiciel
tags:
  - application web
  - Firewall
  - Vulture 3
  - Vulture WebSSO

---
## Vulture est de retour, ça y est !

Après un peu d’attente (la fin du développement de la 2.0.X avait été annoncé en septembre 2014 même si quelques patch avaient été publiés), la version 3 de Vulture WebSSO vient de sortir !

Pour les concepteurs, ce changement de version a été l’occasion de repartir sur de nouvelles bases, notamment en abandonnant mod_perl, memcached et sqlite **mais surtout** en fournissant un OS clé en main (OS FreeBSD préconfiguré, contre Linux avant pour la version installable).

Si les fonctionnalités annoncées sont identiques à celle des versions précédentes (Web Applicative Firewall, portail SSO, redirections, clustering, réécriture de contenu à la volée et quelques additions, notamment le support de SPDY et HTTP/2), le code a forcément du être retravaillé pour remplacer les composants abandonnés et assurer la compatibilité des modules avec FreeBSD. Et au vue des premières images, l’interface graphique a reçu un nouveau coup de dépoussiérage.

## Qu’avons nous sous le capot ?

Autre point positif l’ensemble de la documentation qui a [visiblement été soigneusement travaillée sur cette version][1] (point qui pêchait parfois **un peu** pour la version 2.X et **beaucoup** pour la version 1.X). Sans faire de redite complète de la page de documentation, voici les prérequis de VultureOS pour fonctionner dans de bonnes conditions :

  * VultureOS doit être installé sur une machine virtuelle ou un serveur physique avec 2 Go de RAM et 30 Go d’espace disque
  * avoir une ou plusieurs adresses IP pour recevoir des connexions Web
  * pouvoir contacter les applications Web qu’il protège sur leurs ports habituels (80 et 443 en général)
  * disposer d’une résolution de noms fonctionnelle (soit par serveur DNS soit via /etc/hosts sur l’OS Vulture) et avoir accès à un serveur NTP
  * **avoir un accès HTTPS vers dl.vultureproject.org** pour s’enregistrer et télécharger les mises à jour

Le dernier point n’était pas ouvertement évoqué (sauf erreur de ma part) lors de la bêta ce qui a été un obstacle dans mon environnement de travail partiellement coupé d’Internet. Il faudra voir dans la pratique si des mécanismes de contournement peuvent être trouvés lorsque la connexion à Internet n’est pas envisageable.

## Quelques screenshots et c’est parti

Pour informations, les captures d’écrans qui suivent sont issues de la bêta, je n’ai pas encore eu le temps de les refaire mais la GUI n’a pas sensiblement évolué donc l’aperçu devrait être quasiment identique.

![](/2016/06/vultureOS1.png)

![](/2016/05/vultureOS12.png)

![](/2016/05/vultureOS15.png)

![](/2016/05/vultureOS17.png)

Maintenant que vous avez envie de vous y mettre, voici l’ISO et la documentation et roule ma poule ;-)

  * [Télécharger l’ISO][6]
  * [Getting Started][1]

 [1]: https://www.vultureproject.org/docs-v3/getting-started/
 [2]: /2016/06/vultureOS1.png
 [3]: /2016/05/vultureOS12.png
 [4]: /2016/05/vultureOS15.png
 [5]: /2016/05/vultureOS17.png
 [6]: https://www.vultureproject.org/download/
