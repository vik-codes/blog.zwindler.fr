---
title: 'Vulture 2.0.8 : problème d’ordre dans la directive ProxyPass dans le cas de plusieurs applis pour un même FQDN'
authors:
  - zwindler
type: post
date: 2014-12-30T13:48:52+00:00
url: /2014/12/30/vulture-2-0-8-probleme-dordre-dans-la-directive-proxypass-dans-le-cas-de-plusieurs-applis-pour-un-meme-fqdn/
image: /2014/12/logo2-white1.png
categories:
  - autohebergement
  - Monitoring
tags:
  - 2.0.8
  - apache
  - pnp4nagios
  - ProxyPass
  - Shinken
  - vulture

---
## Erreur de génération de conf Apache (ProxyPass) dans Vulture 2.0.8

Depuis la version 2.0.4 de Vulture, il est possible de présenter plusieurs « applications » (comprenez application web) sur un même FQDN, en les différenciant via leur URL complète.

C’est notamment utile dans le cas de l’utilisation de PNP intégré à shinken. Vous présentez la webui sur le WAN via https://shinken.example.org/, et les graphiques PNP sur https://shinken.example.org/pnp4nagios. Vous avez ainsi tout qui fonctionne comme en local dans un seul et même FQDN. Cette mise en place a fait l’objet d’[un précédent article](/2012/11/17/maj-publier-sur-le-wan-la-webui-de-shinken-via-vulture-2-0-4/)

Cependant, en plus d’apporter des fonctionnalités très appréciables, la mise à jour en 2.0.8 a apporté son lots de petits tracas supplémentaires sur mon installation, notamment pour Shinken (voir [ici](/2014/07/25/vulture-2-0-8-des-nouveautes-et-des-impacts-sur-la-webui-de-shinken/))

Je n’avais pas encore remarqué immédiatement, mais il y a eu également une régression de Vulture au niveau de la fonctionnalité dont je parle au début. Je ne pouvais plus accéder à mes graphes PNP4nagios dans Shinken.  
En fait, après avoir analysé les logs, je me suis rendu compte que toutes les requêtes, et en particulier celles pour PNP, était redirigées vers Shinken, provoquant inévitablement un code retour 404 ([Edit]403 en fait[/Edit]).



Après avoir cherché à différents endroits, j’ai fini par remarquer que le problème vient en fait de la génération de la configuration Apache par Vulture en version 2.0.8. Contrairement aux versions précédentes, les directives ProxyPass ne sont pas ordonnées correctement.

Voici à quoi ressemble la configuration dans l’exemple suivant :  
- https://appli.example.org/  
- https://appli.example.org/appli2

```
<VirtualHost 0.0.0.0:443>
    ServerName appli.example.org
    [...]
    <Location />
    [...]
    </Location>
    ProxyPass        / http://@IP_privee:port_appli1/
    [...]
    ProxyPass        /appli2/ http://@IP_privee:port_appli2/appli2
    <location /appli2/ >
        ProxyPassReverse /
        [...]
    </location>
```


La documentation Apache indique qu’il faut placer la directive ProxyPass avec l’URL la plus stricte/longue en premier, ce qui n’est pas le cas ici (Section encadrée « Ordre de classement des directives ProxyPass » dans [Doc Apache de mod_proxy](http://httpd.apache.org/docs/current/mod/mod_proxy.html#proxypass)).

Cela implique donc que toutes les requêtes sont redirigées sur Shinken. CQFD.

**En attendant un patch**, vous pouvez manuellement déplacer la seconde directive ProxyPass au dessus de la première et redémarrer Vulture.  
Ca m’a permis de contourner le problème et de retrouver mes graphes dans Shinken. Cependant, ce contournement ne survivra pas à la prochaine génération de la configuration en cas de modification depuis l’interface web Vulture.
