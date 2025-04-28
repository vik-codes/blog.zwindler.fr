---
title: 'Vulture 2.0.8 : des nouveautés et des impacts sur la WEBUI de Shinken'
authors:
  - zwindler
type: post
date: 2014-07-25T14:14:08+00:00
url: /2014/07/25/vulture-2-0-8-des-nouveautes-et-des-impacts-sur-la-webui-de-shinken/
image: /2014/12/logo2-white1.png
categories:
  - Autohébergement
  - Logiciel
  - Monitoring
tags:
  - 2.0.8
  - content rewrite
  - javascript
  - json
  - Shinken
  - sso
  - TransHandler
  - vulture
  - webui

---
Fin mai, la version 2.0.8 est sortie et a apporté un lot impressionnant de fonctionnalités supplémentaires (ainsi que quelques bugfixes d’usages)... ainsi que quelques petites surprises pour ma configuration, et notamment pour publier la WebUI de Shinken au travers de Vulture.

Mais le jeu en vaut largement la chandelle, regardez plutôt ...

**Réécriture de la documentation**

OMG ! Vulture dispose ENFIN d’une documentation (relativement complète) pour CHAQUE page de l’interface d’administration. Cela permet de remettre au clair les passages qui n’avaient pas été bien compris lors de mes premières installs et corriger quelques erreurs dues au manque d’information sur les versions précédentes.

A noter, si vous commencez, il faut aller sur ces deux pages, avant de lire la doc en entier, pour ne pas être perdu :

* [Documentation d'installation de Vulture](http://www.vultureproject.org/documentation/installation/) 
* [Premiers pas avec Vulture (pas indiqué assez clairement je trouve, ça devrait être le PREMIER lien après l’install)](http://www.vultureproject.org/premiers-pas-avec-vulture/)

**Refonte intégrale du packaging**

> Refonte intégrale du packaging : Vulture s’installe désormais simplement avec 3 paquets

ENFIN bis ! Et ça fonctionne bien, fini les galères pour installer les dépendances. Par contre la liste des distribs gérées se limite à sont plus simple appareil : CentOS 6.5 et Debian 7.

**Mise à jour automatique des configurations**

Bon... ça, ça fait un moment qu’on nous le promet, et j’ai du faire une fausse manipulation certainement car comme d’habitude... j’ai tout perdu... Si vous avez des retours positifs, je suis preneur ;)

**Support d’une URL par défaut dans les interfaces**

En voilà une bonne idée ! Cependant, j’ai eu à l’inverse la mauvaise idée d’en indiquer une pour mon interface, alors que cette appli/URL n’existait pas, et je me suis retrouvé avec de gros soucis sur mon portail, qui ne marchait tout simplement plus.

J’avais des erreurs au niveau des logs des applications, avec des messages d’erreurs faisant état d’une application inconnue depuis le fichier Core::AuthzHandler.

Je le re-testerai une autre fois, pour voir, mais je me demande s’il ne manque peut être des contrôles vu que c’est une nouvelle fonctionnalité. Si vous n’en avez pas besoin, je vous conseille de ne pas l’utiliser.

**Plugins – Transhandler**

Suite à l’installation de la 2.0.8 de Vulture, je n’arrivais plus à faire fonctionner la WebUI de Shinken. J’arrivais à avoir la mire d’authentification, mais pas les images et le CSS.

Après dépilage des logs, j’ai fini par remarquer que les connexions faisant appels au CSS et aux images (de type static/*) se retrouvaient redirigés sur le serveur où est installé Vulture, et pas sur le serveur Shinken où elles sont situées.

Après vérification, j’ai trouvé avec étonnement que le plugin TransHandler STATIC static/* livré par défaut lors de l’install était appliqué à toute mes applis, **alors que cette règle n’est normalement appliqué à AUCUNE application** (paramètre positionné à None)**. [Edit] En fait selon l’équipe de Vulture, c’est normal, quand on a la colonne « Application » à « None », ça signifie que ça s’applique à toutes les applications [/Edit]  
** 

La documentation fait bien état de ce plugin, qui sert effectivement à mettre en local sur le serveur qui héberge Vulture toutes les ressources statiques ([ici](http://www.vultureproject.org/documentation/configuration/configuration-des-applications-web/composants-plugins/plugins-transhandler/)).

J’ai désactivé ce plugin, et tout est rentré dans l’ordre. **[Edit]** Il semblerait que cela soit plus compliqué que cela. Ce contournement provoque notamment des effets de bord sur le portail. J’ai ouvert un thread sur le google group de vulture à ce sujet.**[/Edit]**

> Will not rewrite (Rewrite Content) this content-type: application/json 

Une fois Shinken de nouveau disponible, ce n’était pas terminé pour autant. Visiblement, depuis la 2.0.8 (peut être avant mais je n’ai pas remarqué en 2.0.4), le plugin de réécriture de contenu de la page à la volée _Rewrite Content_ ne prend plus en charge l’ensemble des contenus par défaut. Cela se traduit par une page web qui n’est simplement pas réécrite (on retrouve les URL privée de PNP dans la page Shinken) et par le message suivant dans le fichier de log

Le log est plutôt explicite, et la doc aussi ([vultureproject.org/documentation/configuration/configuration-des-applications-web/composants-plugins/reecriture-de-contenu](http://www.vultureproject.org/documentation/configuration/configuration-des-applications-web/composants-plugins/reecriture-de-contenu)/) !

> Vulture ne pourra altérer que les contenus dont le _content-type_ est l’un des suivants (il est cependant trivial d’en ajouter d’autres, contacter l’équipe de développement pour signaler un type non géré)

Les types sont les suivants :

  * text/xml
  * text/html
  * application/vnd.ogc.wms_xml
  * text/css
  * application/x-javascript

J’ai donc signalé ce manque à l’équipe mais en attendant qu’ils publient un patch, vous pouvez simplement ajouter dans l’expression régulière _application/json et text/javascript_ ligne 138 du fichier _/opt/vulture/lib/Vulture/Plugin/Plugin_OutputFilterHandler.pm_ 

```
diff /opt/vulture/lib/Vulture/Plugin/Plugin_OutputFilterHandler.pm*
138c138
<  if ($r->content_type ne '' and $r->content_type !~ /(text/xml|text/html|application/vnd.ogc.wms_xml|text/css|application/x-javascript|text/plain|application/json|text/javascript)/){
---
>  if ($r->content_type ne '' and $r->content_type !~ /(text/xml|text/html|application/vnd.ogc.wms_xml|text/css|application/x-javascript|text/plain)/){
```
