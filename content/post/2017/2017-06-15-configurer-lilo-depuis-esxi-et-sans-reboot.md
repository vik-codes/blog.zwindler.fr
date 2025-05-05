---
title: 'Configurer l’ILO depuis ESXi (et sans reboot !)'
authors:
  - zwindler
type: post
date: 2017-06-15T12:00:02+00:00
url: /2017/06/15/configurer-lilo-depuis-esxi-et-sans-reboot/
image: /2017/06/HP-iLO.jpg
categories:
  - systeme
  - Virtualisation
tags:
  - Asrock
  - BMC
  - Dell
  - ESX(i)
  - HP
  - iDRAC
  - ILO
  - IPMI
  - KVM
  - KVM sur IP
  - VMware
  - vSphere

---
## Un KVM sur IP pour les contrôler tous

Une des fonctionnalités vitales pour l’administrateur de serveurs (physiques) est la capacité de pouvoir réaliser des modifications sur un serveur comme si on était physiquement devant la machine, vissé devant le kit clavier-souri-écran. **Non**, ce n’est pas (que) de la flemme. On ne peut pas toujours aller en salle serveur dès qu’un serveur a besoin d’une maintenance !

![](/2017/06/obrian_datacenter.jpg)

> Ça c’est ce qu’on voit dans les séries TV, des techies qui tirent des KVM intégrés dans les racks pour intervenir. Ça arrive parfois, mais en vrai, mais 95% du temps on ne va pas jusqu’au datacenter, on utilise l’ILO ;-)

Ces technologies sont particulièrement utiles lorsque les systèmes d’exploitation sont crashés et que la seule solution pour reprendre la main sur le serveur est de le rebooter en appuyant _virtuellement_ sur le bouton Power.

Dans les technos du marché, on peut citer ILO (pour Integrated Lights-Out) chez HP, [iDRAC](/recherche/?keyword=idrac) chez Dell-EMC, mais il existe bien d’autres solutions plus ou moins avancées.  
Pour la route je citerai les technos que [j’ai envisagé pour mon serveur perso](/2011/06/29/nasmediacenter-do-it-yourself-or-not/), à savoir [BMC sur certaines cartes mère Asrock](/2017/04/04/installation-dun-serveur-compact-a-la-maison/), le protocole IPMI, ou alors la solution d’Intel AMT disponible sur les i5 et plus pour peu que vous ayez la bonne carte mère compatible « vPRO ».

**Aparté** : vous avez peut être entendu parler d’AMT récemment à cause de plusieurs failles qui ont rendu nombre de systèmes vulnérables ([ici][5] et plus récemment [ici][6]).

## ILO : un 2ème OS en parallèle

Alors évidemment pour que ça marche, ça nécessite nécessairement que l’ILO (ou équivalent) fonctionne en parallèle de l’OS principal du serveur. C’est ce qui différencie l’ILO et l’iDRAC de Remote Desktop Protocol de Micro$oft ou VNC, qui ne vous servent plus à rien en cas de plantage ou d’extinction du serveur.

Mais qui dit système parallèle dit potentiellement que l’un ne puisse pas communiquer avec l’autre ! Pour revenir à mon exemple de l’ILO d’un serveur ESXi, généralement la première configuration (adresse IP, etc) se fait en interrompant la séquence de boot du serveur. En théorie, si on voulait faire une modification a posteriori de la même manière, il serait donc nécessaire de rebooter le serveur ESXi et donc de couper toutes les VMs qui sont hébergées dessus.

Heureusement, pour éviter de devoir faire ça, HP a mis à disposition des outils ! Et en plus, ces binaires sont directement intégrés dans la version modifiée de l’ISO ESXi d’HP.

Pour ceux qui ne savent pas de quoi je parle, il s’agit d’images dites « custom HP » et qui contiennent notamment des outils HP dédiés à l’administration et à l’intégration dans l’écosystème HP, mais surtout les pilotes compatibles avec le matériel HP. Cette version custom est donc celle qui est conseillée si vous avez un serveur HP, [même si elle n’est pas exempte de bugs parfois](/2015/05/30/bug-esxi-custom-hp-globalcartel-1-vmk_no_memory-cant-fork/) !!! Vous pouvez les retrouver en recherchant dans Google « ESXi HP custom » ou sur le site d’HPe.

C’est d’ailleurs ces modifications qui permettent de remonter des informations sur l’état de santé du serveur physique dans les données de vSphere.  
![](/2017/05/ilo_01.png)

## Piloter l’ILO depuis l’OS de l’ESXi

Rentrons dans le vif du sujet. Ça dépend des versions de vSphere (5.5, 6.0, 6.5), mais en version 6.0, sur les images ESXi custom HP, les binaires spécifiques sont déposés dans le dossier **/opt/hp/tools**. Le binaire qui nous intéresse est **hponcfg**.

![](/2017/05/ilo_02.png)

```
~ # cd /opt/hp/tools
/opt/hp/tools # ls
conrep              hpbootcfg           hponcfg             hptestevent_esxcli
conrep.xml          hpbootcfg_esxcli    hptestevent
```


Pour modifier la configuration, le plus simple est d’exporter la configuration actuelle, de la modifier, puis de la réimporter. On peut l’exporter avec la commande suivante :

```
/opt/hp/tools # ./hponcfg -w /tmp/current_ilo.cfg
HP Lights-Out Online Configuration utility

Version 4.4-0 (c) Hewlett-Packard Company, 2014
Firmware Revision = 1.81 Device type = iLO 2 Driver name = hpilo
iLO IP Address: x.x.x.x
Management Processor configuration is successfully written to file "/tmp/current_ilo.cfg"
```


Et si vous regardez le contenu de ce fichier, vous aurez un retour similaire :

```
/opt/hp/tools # cat /tmp/current_ilo.cfg
<!-- HPONCFG VERSION = "4.4-0.0" -->
<!-- Generated 5/9/2017 9:56:44 -->
<RIBCL VERSION="2.1">
 <LOGIN USER_LOGIN="Administrator" PASSWORD="XXXXXXXX">
[...]
  <RIB_INFO MODE="write">
  <MOD_NETWORK_SETTINGS>
    <SPEED_AUTOSELECT VALUE = "Y"/>
    <NIC_SPEED VALUE = "10"/>
    <FULL_DUPLEX VALUE = "N"/>
    <IP_ADDRESS VALUE = "x.x.x.x"/>
    <SUBNET_MASK VALUE = "255.255.255.0"/>
    <GATEWAY_IP_ADDRESS VALUE = "x.x.x.y"/>
    <DNS_NAME VALUE = "ILO-XXXX"/>
[...]
```


Il ne vous reste plus qu’à modifier ces valeurs pour refléter vos nouveaux besoins et de l’appliquer avec la commande suivante :

```
./hponcfg -f /tmp/current_ilo.cfg
```


## Source

[Le tutoriel sur VMwarearena (EN)][10]

 [5]: https://www.nextinpact.com/news/104173-amt-intel-corrige-vieille-faille-dans-processeurs-pour-entreprises.htm
 [6]: https://www.nextinpact.com/news/104513-un-malware-detourne-technologie-amt-dintel-pour-masquer-ses-communications.htm
 [10]: https://www.vmwarearena.com/how-to-configure-hp-ilo-from-esxi-host/
