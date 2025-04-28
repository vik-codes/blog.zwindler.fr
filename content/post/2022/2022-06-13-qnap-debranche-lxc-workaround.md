---
title: 'QNAP débranche LXC sur les NAS ARM : comment contourner ?'
authors:
  - zwindler
type: post
date: 2022-06-13T08:00:00+02:00
url: /2022/06/13/qnap-debranche-lxc-workaround
image: /2018/01/qnap22.jpg
categories:
  - Autohébergement
  - Matériel
tags:
  - ARM
  - LXC
  - QNAP
  - container
  - hack

---

Si vous le suivez sur Twitter ou Masto, vous m'avez très probablement lu râler contre la sortie ~~de QTS 5~~ Container Station v2.4.0.2316, l'été dernier. 

![](https://preview.redd.it/6bouewrhnze71.png?width=1283&format=png&auto=webp&s=11aacee53bf931b47d1534cc1478b47aa7239701)

Ou plus particulièrement, contre une décision prise lors de ce passage : enlever LXC pour l'administration des containers, au profit de LXD. LXD étant juste une couche d'administration, LXC est toujours présent et fonctionnel, juste caché.

Pourquoi je râle ?

J'ai un [NAS QNAP TS431P2 depuis 2018 dont je suis pleinement satisfait](/2018/01/23/stockage-pour-un-admin-geek-qnap-ts431p2-ou-synology-ds418j), et qui m'a permis de passer moins de temps à administrer et ajouter des fonctionnalités à mon NAS ZFS maison, monté initialement en 2011 (merci *Dworak_of_sky* pour les souvenirs).

* [NAS/MediaCenter : Do It (the hardware part) Yourself!](/2011/06/29/nasmediacenter-do-it-yourself-or-not/)
* [NAS/MediaCenter : Do It (the software part) Yourself!](/2011/08/04/nasmediacenter-do-it-the-software-part-yourself/)

**Sauf** que mon QNAP est un NAS milieu de gamme, fonctionnant avec *un processeur ARM* et pas x86 ! Et ces charmantes personnes (grrrr) de chez QNAP **n'ont pas porté LXD sur les NAS ARM** (segmentation artificielle de l'offre ? Flemme ?).

Nous, propriétaires de NAS QNAP ARM, nous retrouvons donc sans solution puisque LXC est désactivé et LXD pas disponible.

Une fonction hyper pratique pour héberger de petits services à bas coût (autant en performance qu'en prix) disparaît. C'était un réel différenciant pour ce modèle et je me sens vraiment trahi (ou alors c'est ma faute, car je n'aurais pas dû leur faire confiance ?).

![](/2022/06/trahison.jpg)

Je ne suis pas près de recommander QNAP comme j'ai pu le faire par le passé. #PasContent

## Nuance

HEUREUSEMENT, les containers LXC ne se sont pas mis à ne plus marcher du jour au lendemain. 

Enfin, encore heureux ! Je n'ose imaginer les dégâts en prod !

C'est d'autant plus vicelard que le message d'information pour expliquer qu'il n'y a plus LXC indique que c'est pas grave puisque vous avez LXD à la place. Aucune mention du fait qu'en fait, sous ARM, non...

Il est toujours possible (**pour l'instant**) de démarrer, arrêter, utiliser et supprimer les containers existants. Mais il n'est plus possible d'en créer de nouveaux.

Ça veut donc dire que tout est encore présent pour faire fonctionner la fonctionnalité, ce n'est "juste" plus disponible en UI.

## En avoir le coeur net

En farfouillant, je me suis aussi rendu compte qu'il était toujours possible d'**exporter** des containers existants et d'**importer** les exports.

![](/2022/06/qnap_export.png)
![](/2022/06/qnap_import.png)

On peut donc contourner la limitation arbitraire de QNAP via des export / import. J'ai l'habitude de ce genre de bidouilles, [puisque je faisais déjà ça il y a plus de 10 ans avec les hyperviseurs VMware en licence gratuite](https://blog.zwindler.fr/2011/03/20/copier-une-vm-windows-xp-sous-esxi-sans-vcenter/)...

A l'usage, ça fonctionne mais c'est pas satisfaisant. D'abord parce que si on a pas, ou plus, de containers sur le NAS, on ne peut pas le faire trivialement. 

Ensuite, parce que le processus et long (l'export et l'import) et pénible (plusieurs étapes).

Enfin, parce que les images LXC mises à disposition par QNAP étaient antédiluviennes ! 

Ubuntu 14.04 !!! Sauf si vous avez pris le temps de faire le processus d'upgrade complet de 14.04 à 20.04 ou 22.04 (et vous devriez), il est probable que vous n'ayez pas envie de repartir de ces vieux machins.

## "Faites mieux"

Si vous êtes admin, vous avez probablement déjà activé SSH pour vous connecter directement à l'OS de votre NAS. ([Et sinon vous pouvez aller ici pour l'activer](https://www.qnap.com/fr-fr/how-to/knowledge-base/article/how-to-access-qnap-nas-by-ssh))

Une fois connecté, on peut sortir du menu TUI et bidouiller l'OS comme on en a envie.

![](/2022/06/qnap_ssh_admin.png)

```
[~] # id
uid=0(admin) gid=0(administrators)
```

Je n'ai pas fait beaucoup d'administration LXC/LXD directement, car j'avais toujours une interface à ma disposition pour me "cacher" la façon dont ça fonctionne vraiment, que ce soit dans le cas de QNAP ou de [Proxmox VE (que j'utilise beaucoup pour ça)](https://blog.zwindler.fr/recherche/?keyword=lxc).

En lisant rapidement [la doc sur ubuntu-fr](https://doc.ubuntu-fr.org/lxc), j'ai compris qu'il existait en fait chez Canonical un genre de dépôt d'images officielles de pleins d'OS, notamment compatible **armhf**.

* [images.lxd.canonical.com/](https://images.lxd.canonical.com/)
* [images.linuxcontainers.org//meta/1.0/index-system](http://images.linuxcontainers.org//meta/1.0/index-system)

Avec LXC, on peut accéder directement à ces images en ligne de commande avec `lxc-download`. Pas de bol, la commande n'est pas dispo sur QTS :

```console
[~] # lxc-download
-sh: lxc-download: command not found
```

(En fait elle n'est juste pas dans le PATH, mais je ne le savais pas à ce moment-là)

Sauf qu'on peut aussi appeler directement la commande pour créer des containers `lxc-create` avec un flag "download". Et ça tombe bien parce que `lxc-create` est disponible. Mais la joie sera de courte durée...

```console
lxc-create -t download -n container_jammy -- -d ubuntu -r jammy -a armhf

/usr/local/container-station/lxc/share/lxc/templates/lxc-download: line 237: getopt: command not found
```

## Hack...

Note : si vous trouviez que ce qu'on était en train de faire n'était déjà pas très propre, je tiens à vous prévenir, la suite est vraiment immonde... Pas merci QNAP de me forcer à faire ça !

Le script `/usr/local/container-station/lxc/share/lxc/templates/lxc-download` est moisi. Il manque la moitié des binaires dans la busybox.

Pire encore, la procédure que je donne ici semble être écrasée à chaque mise à jour de l'application **Container Station**. Mais, ça fonctionne...

La première chose qu'on va faire, c'est faire une sauvegarde du script `lxc-download` par sécurité.

```console
cp /usr/local/container-station/lxc/share/lxc/templates/lxc-download{,.old}
```

Le premier message d'erreur qu'on a `getopt: command not found` indique juste que de nombreux binaires "classiques" ne sont pas disponibles directement dans le shell de QTS.

Sauf qu'en fait, ils sont là, ces binaires. Pas besoin de les télécharger ou de les compiler. Ils ne sont juste "pas visibles".

QTS tourne, comme beaucoup de serveurs Linux minimalistes, avec [l'aide de Busybox](https://fr.wikipedia.org/wiki/BusyBox).

On peut donc "magiquement activer" les binaires qui nous manquent simplement avec des liens symboliques.

```console
for binary in getopt xz seq; do
  ln -s /share/CACHEDEV1_DATA/.qpkg/container-station/bin/busybox /share/CACHEDEV1_DATA/.qpkg/container-station/bin/${binary}
done

getopt
getopt: missing optstring argument
```

## ... and slash!

> C'est bon, mais pas suffisant.

La version du binaire `mktemp` de busybox n'est malheureusement PAS compatible avec le script `lxc-download`. On va devoir le modifier à la main...

```
Usage: mktemp [-dq] TEMPLATE
```

Le passage problématique se situe autour des lignes 320-325

```bash
320 if ! command -V mktemp >/dev/null 2>&1; then
321     DOWNLOAD_TEMP="${DOWNLOAD_TEMP}/tmp/lxc-download.$$"
322 else
323     DOWNLOAD_TEMP="${DOWNLOAD_TEMP}$(mktemp -d)"
324 fi
```

En vrai, `mktemp` s'attend à avoir le path complet, accompagné d'un pattern à base de XXXXXX. `mktemp` remplace ensuite les caractères XXXXXX par un nombre aléatoire en s'assurant que le dossier n'existe pas déjà, puis le créé. Par exemple

```bash
mktemp /tmp/mydirXXXXX
```

Mode bourrin, j'ai remplacé la ligne par :

```bash
323     DOWNLOAD_TEMP="${DOWNLOAD_TEMP}/tmpdir" && mkdir -p ${DOWNLOAD_TEMP}
```

De toute façon, il est supprimé à la fin de l'exécution du script, ce dossier (fonction cleanup dans le shell).

## GPG

On progresse !

```console
[~] # lxc-create -t download -n container_jammy -- -d ubuntu -r jammy -a armhf
Setting up the GPG keyring
chmod: /var/lib/lxc/container_jammy/tmpdir/gpg: No such file or directory
Error creating container container_jammy
```

En creusant un peu, la vraie erreur est que je n'ai pas le binaire `gpgkeys_curl` à l'endroit attendu :

```console
gpg: unable to execute program `/opt/cross-project/arm/linaro/arm-linux-gnueabihf/libc/libexec/gnupg/gpgkeys_curl': No such file or directory
```

Voilà un autre point que je n'ai pas réussi à corriger correctement. 

Le plus simple est de simplement ignorer la validation avec `--no-validate` mais si vous avez une piste, je suis preneur.

```console
lxc-create -t download -n container_jammy -- -d ubuntu -r jammy -a armhf --no-validate
```

## Des dossiers qui disparaissent tout seul ???

Dernier mystère... 

```console
Downloading the image index
ERROR: Failed to download http://images.linuxcontainers.org//meta/1.0/index-system
```

L'erreur n'est pas du tout un problème d'accès à l'URL pour télécharger l'index des systèmes disponibles sur `images.linuxcontainers.org` (code 302, page redirigée sur `uk.lxd.images.canonical.com`).

En réalité, si active les messages d'erreurs lors du `wget` dans le script, l'erreur est que le dossier `/var/lib/lxc/container_jammy/tmpdir/` n'existe pas !

Pourtant, ça devrait être corrigé, suite à la modif qu'on a faite ligne 323 (voir plus haut)... trop bizarre :/

J'en ai eu un peu marre de creuser et au bout d'un moment, j'ai juste fait :

```console
export CONTAINER_NAME=jammy
mkdir -p /var/lib/lxc/${CONTAINER_NAME}/tmpdir/
mkdir -p /var/lib/lxc/${CONTAINER_NAME}/rootfs/
lxc-create -t download -n ${CONTAINER_NAME} -- -d ubuntu -r jammy -a armhf --no-validate
```

Et croyez-le ou non, mais ça marche ! Le container existe (il n'est juste pas visible dans la console pour l'instant)

```console
[...]
You just created an Ubuntu jammy armhf (20220611_07:42) container.
```

On a plus qu'à redémarrer Container Station, il apparaît

![](/2022/06/qnap_lxc_jammy.png)

## Conclusion

Si jamais quelqu'un de chez QNAP lit ce blogpost... Arrêtez de vous fiche de nous et :
* mettez nous LXD dans nos NAS ARM
* OU si c'est trop de boulot (je peux l'entendre), remettre LXC en attendant.

Ce genre de hack est indigne et j'ai perdu plusieurs heures pour corriger votre m***e. J'ai payé pour un NAS compatible LXC, ce n'est pas pour que vous retiriez la fonctionnalité 1 an après. 

Ce genre de pratiques est vraiment dégueulasse et je n'hésiterais pas à dire tout le mal que je pense de cette décision.

## Sources

* [Un post sur le Forum QNAP qui m'a un peu guidé vers la solution](https://forum.qnap.com/viewtopic.php?t=159613)
* [Un fil de discussion Reddit qui en parle](https://www.reddit.com/r/qnap/comments/owkr63/qnap_container_station_loss_of_functionality/)
