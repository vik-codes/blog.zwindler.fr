---
title: Monitorez le fait que les URLs bloquées sont bien bloquées par le proxy
authors:
  - zwindler
type: post
date: 2017-11-18T12:45:25+00:00
url: /2017/11/18/supervisez-vos-urls-bloquees-proxy/
image: /2017/11/check_proxy_http_url.png
categories:
  - Monitoring
  - Script
tags:
  - Centreon
  - cntlm
  - critical
  - Nagios
  - ok
  - proxy
  - redirect
  - Shinken
  - Warning

---
## Comment je vérifie que les sites bloqués par mon proxy sont bien bloqués ?

Il y a plein de raisons qui peuvent expliquer qu’un site non légitime soit bloqué sur un lieu de travail (par exemple). Et autant de raisons qui font que, parfois, les proxies ne bloquent pas bien des sites que vous aviez pourtant bloqués !

Pour tout ce qui est supervision des pages web, Nagios fourni le plugin **check_http**, dans les _nagios-plugins_ (collection officielle de plugins), et qui permet de vérifier qu’une page web donnée est accessible (ou non).

## Limitations

Cependant, il existe plusieurs cas où ce plugin ne « fonctionne pas » comme je le souhaite :

  * D’abord, dans le cas où l’URL checkée renvoie un 30x (redirection), le check\_http considère que c’est bon et ne va pas chercher plus loin. Hors, il arrive que le site soit down au-delà de la redirection. Dans ce cas là, check\_http ne nous notifie pas de l’échec.
  * Ensuite, dans le cas où vous voulez traverser un proxy pour vérifier si une page est accessible ou non comme dans mon introduction, vous ne pouvez pas spécifier si un code retour 40x est une bonne chose ou non. Dans tous les cas, avec check_http, un 40x sera considéré comme un WARNING, jamais comme un CRITICAL ou un OK.

Pour résoudre ces problèmes, j’ai donc réécris un petit script bash simple, permettant de résoudre tous les cas ci-dessus. Avec **check\_proxy\_http_url**, vous pouvez vérifier des URLs en spécifiant un proxy, suivre correctement les redirections (301 ou 302 par ex.) et spécifier si le fait qu’une page soit accessible (ou pas accessible) est une bonne chose ou non.

## Installation

Le script est simplissime. Pour des raisons de facilité je me suis simplement appuyé sur un script **bash** et de **wget**, présents sur la plupart des serveurs par défaut. Il n’y a pas d’autres prérequis.

Dans un futur (plus ou moins) proche j’ajouterai également une compatibilité avec **cURL**, qui a tendance à le remplacer.

## Usage

Là encore, j’ai fait au plus simple. Le script dispose d’un nombre limité d’arguments, permettant de réaliser les usecases indiqués précédemment.

```
/var/lib/nrpe/plugins/check_proxy_http_url.sh -u TARGET_URL [-p PROXY_ADDRESS:PROXY_PORT] [-r] [-v]
```


  * TARGET_URL : obligatoire - l’URL que vous souhaitez superviser. Par défaut, un code retour de type 200 induira un OK, un 4XX/5XX un CRITICAL
  * PROXY\_ADDRESS & PROXY\_PORT : optionnels - le hostname ou l’adresse de votre proxy, si nécessaire
  * -r : optionnel - permet d’inverser les codes retours de Nagios. Un code retour 200 induira un CRITICAL (URL qui est accessible alors qu’elle ne le devrait pas) et un 4XX/5XX induira un OK

## Exemples

Vérifier que http://@IPsome\_forbidden\_website.com n’est pas accessible et renvoyer un CRITICAL sinon.

```
[root@lanhost ~]# /var/lib/nrpe/plugins/check_proxy_http_url.sh -u some_forbidden_website.com -r
OK: URL some_forbidden_website.com isn't available and it shouldn't - 403
```


Vérifier que http://@IPsome\_allowed\_website\_that\_isnt_accessible.com n'est pas accessible et renvoyer un CRITICAL sinon.

```bash
[root@lanhost ~]# /var/lib/nrpe/plugins/check_proxy_http_url.sh -p internal_proxy:8181 -u some_allowed_website_that_isnt_accessible.com
CRITICAL: URL some_allowed_website_that_isnt_accessible.com isn't available and it should - 403
```


## Code source

Comme d’habitude avec mes plugins « Nagios compatibles », les sources sont disponibles sur Github à l’adresse suivante :

  * [github.com/zwindler/check\_proxy\_http_url][1]

Le lien pour [Nagios Exchange est également disponible ici !][2]

Mes autres plugins sont également disponibles sur le Github :

  * [Plugin check\_mem\_ng.sh compatible RHEL 7+](/2015/07/16/plugin-check_mem_ng-sh-compatible-rhel-7/)
  * [check\_emc\_rlp : supervision des LUNs dans le RLP sur baies VNX EMC²](https://blog.zwindler.fr/2017/04/25/plugin-de-supervision-rlp-emc%C2%B2-check_emc_rlp/)
  * [Plugin de supervision check\_wlst\_sessions (WebLogic 9+)](/2016/11/09/plugin-check_wlst_sessions-weblogic-9/)

 [1]: https://github.com/zwindler/check_proxy_http_url
 [2]: https://exchange.nagios.org/directory/Plugins/Network-Protocols/HTTP/check_proxy_http_url/details

