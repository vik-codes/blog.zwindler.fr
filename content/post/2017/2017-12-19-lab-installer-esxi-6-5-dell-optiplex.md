---
title: 'Lab : installer ESXi 6.5 sur un Dell Optiplex'
authors:
  - zwindler
type: post
date: 2017-12-19T12:45:28+00:00
url: /2017/12/19/lab-installer-esxi-6-5-dell-optiplex/
image: /2017/12/esxi_cluster3.jpg
categories:
  - DIY
  - materiel
  - Virtualisation
tags:
  - ESX(i)
  - ESXi-customizer-PS
  - ISO
  - pilotes
  - VIB
  - Whitebox

---
## Customiser un ISO d’ESXi, mais pourquoi faire ???

Vous avez été plusieurs à réagir suite à mon post sur LinkedIn, du coup j’ai décidé de faire un petit article rapide pour en parler. Brièvement, j’avais posté une photo de deux Dell Optiplex sur lesquels j’avais installé ESXi.

Tout ça dans le but d’organiser une petite formation VMware improvisée pour des collègues, et sans investir quoique ce soit bien sûr ! Mon idée était de leur faire installer un hyperviseur from scratch, de créer un cluster avec un vCenter et de tester les fonctionnalités de base de la suite VMware.

![](/2017/12/whitebox_6.5.png)

Le point important à savoir lorsqu’on installe des serveurs ESXi est qu’il s’agit d’un Linux minimaliste, avec seulement une liste très restreinte de pilotes autorisés par VMware. Ce « problème » que tous les DIYer ont rencontrés existe depuis longtemps. Comme je l’explique dans le post LinkedIn, les bidouilleurs trouvent des moyens de contournement depuis au moins ESX 3/ESXi 4. Personnellement, je bidouille depuis 2010, moment où je me suis monté ma première Whitebox ;-).

## Le Matoss

> En informatique, à défaut de moyens, il faut avoir des idées !

Voilà comment j’ai introduis mon post sur LinkedIn et il représente assez bien ce qu’on va faire ici. A défaut de pouvoir acquérir ou même louer deux serveurs pour les quelques jours de formation, je me suis rabattu sur des desktops qui trainaient au stock.

Les modèles concernés sont :

  * Un Optiplex 390 avec un core i5 2400, 16 Go de RAM (barettes piquées sur d’autres PCs)
  * Un Optiplex 3020 avec un core i3 4150 avec 8 Go de RAM (barettes piquées elles aussi)

Dans mon tiroir, j’avais aussi en réserve une carte PCI Express Intel, juste au cas où (une carte perso, je vous expliquerai pourquoi après).

## L’installation échoue !

Au cas où vous ne sauriez pas où le trouver, l’ISO de l’hyperviseur de VMware peut se télécharger gratuitement sur le site MyVMware (lien mort, comme tout chez VMware). Il suffit de créer un compte sur le site puis télécharger la version souhaitée de l’hyperviseur (la dernière par exemple, « VMware vSphere Hypervisor (ESXi) 6.5 u1 » au moment de la rédaction de l’article). Il est même possible d’obtenir une licence gratuite, qui sera limitée et n’offrira pas le droit à du support, mais tout de même !

Si vous utilisez un PC et pas un serveur pour installer l’ISO que vous aurez téléchargé, il y a de très fortes chances pour que l’installation échoue au tout début du processus d’installation. En effet, l’installeur vérifie la présence d’une carte réseau compatible avant de démarrer complètement.

![](/2017/12/no_adaptor_detected_esxi65.png)

En cas d’échec de l’installation de l’ISO d’ESXi, on peut commencer par changer d’ISO. Les constructeurs de serveurs (Dell, HPe, whatever) mettent souvent à disposition sur leur site une image customisée par leurs soins.

Par exemple dans le cas de Dell, il est disponible [à l’adresse suivante][4].

![](/2017/12/custom_dell_esxi_6.5.png)

## A la recherche de la carte perdue

Aujourd’hui, la plupart des PCs de bureau disposent d’une carte réseau on-board Realtek, souvent un modèle de type **realtek 8168** (parfois du Intel et plus rarement du Killer Networks). Ce pilote n’est pas inclus dans l’ISO ESXi, ni d’ailleurs dans l’ISO customisé par Dell.

> YES ! Il va falloir mettre les mains dans le cambouis !

La première chose à faire est donc de trouver le modèle exact de carte réseau que vous avez sur votre PC. Le plus simple est en fait de se connecter en shell sur le PC juste après que l’installeur est planté (Et oui, c’est possible !).

Avec votre clavier, faites **[Alt] + [F1]**. A partir de là vous pouvez directement vous loguer (root + mot de passe vide), puis exécuter la commande suivante :

```
lspci -v | grep "Class 0200" -B 1
0000:02:00.0 Ethernet controller Network controller: Realtek Realtek 8168 Gigabit Ethernet
    Class 0200: 10ec:8168
```


Petite blague, le clavier est en US donc pour ceux qui n’ont pas pris qwerty en seconde langue (ahah...), il y a une petite astuce pour modifier le layout du clavier (trouvée grâce [au post suivant de akhpark][6]).

```
localcli system settings keyboard layout set -l French
```


Si vous galérez à faire le tiret pour le &lsquo;-l’, vous pouvez aussi utiliser la 2ème astuce que nous donne **akhpark**, à savoir la possibilité de faire des caractères spéciaux via leur code ASCII en maintenant la touche [ALT] enfoncée tout en tapant rapidement le code ASCII (**[ALT]+45** pour le &lsquo;-&lsquo;).

## Maintenant on peut customiser

OK, maintenant on connait le pilote réseau qui nous manque. En espérant que ce soit le seul composant qui nous pose problème (il peut aussi y avoir le contrôleur disque...), on va donc customiser notre ISO d’ESXi.

Heureusement pour nous, depuis la version 5.X, il existe des outils pour automatiser cette modification. Le site [v-front.de][7] héberge un script Powershell qui permet de customiser nos ISO en ligne de commande. Et c’est tant mieux parce qu’avant, c’était beaucoup plus pénible ! Il fallait aller modifier des fichiers texte à la main et copier des binaires dans les bons dossiers !

**ESXi customizer PS** supporte les ISO d’ESXi de la version 5.0 jusqu’à la version 6.5, en se basant directement sur les ISOs disponibles sur les sites de VMware.

Les prérequis sont :

  * Powershell 2+ (par défaut sur tous les Windows >= 7)
  * VMware PowerCLI 5.1+ (disponible sur MyVMware (lien mort))

Téléchargez [la dernière version du script][9] qui est compatible avec la version ESXi 6.5, puis récupérez le(s) pilote(s) dont vous avez besoin. Pour vous faciliter la vie, le site **v-front.de** met aussi à disposition les pilotes (.VIB) les plus utilisés, compilés par la communauté, dont le Realtek 8168 :-).

Ouvrez un terminal Powershell en mode administrateur et lancez la commande suivante :

```bash
.\ESXi-Customizer-PS-v2.5.1.ps1 -v65 -vft -load sata-xahci,net55-r8168
```


Vous devriez maintenant avoir un ISO ESXi modifier qui intègre en plus les pilotes pour la carte Realtek 8168 (et consorts) ainsi qu’un pilote SATA AHCI (souvent nécessaire aussi) !!

![](/2017/12/esxi_customizer-ps.png)

Trop facile !

## Bonus : If all else fails

Dans le cas où rien ne marche, que vous n’y arrivez pas... une solution de contournement peut être tout simplement d’acheter du matériel compatible. Certes ce n’est pas idéal mais il est possible d’acheter une carte Intel gigabit toute simple et compatible avec l’ESXi (6.5u1 support le [chipset 82574L][11] par exemple) pour une trentaine d’euros.

![](https://www.amazon.fr/gp/product/B01IR5SH3Q)

La liste des chipsets compatible est disponible sur les sites [d’Intel][12] et de [VMware][13].  

![](/2017/12/vmware_compatibility_guide.png)

C’est la solution que j’ai choisi moi pour ma Whitebox à l’époque d’ESXi 4.0. Les matériels compatibles ou quasi compatibles étaient à l’époque référencés sur des sites comme [vm-help][15]. Les utilisateurs qui réussissaient à faire marcher ESXi sur leurs matériels décrivaient les opérations nécessaires pour y arriver : c’était vraiment de la grosse bidouille ;-).

![](/2017/12/vm-help_asus_P7P55.png) 

## Sources

  * [Une procédure similaire pour la v6 (en anglais) sur le site de VDICloud.nl (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20200803221016/http://www.vdicloud.nl/2015/02/07/realtek-nic-on-vsphere-6/)
  * [Une procédure similaire pour la v5.5 (en anglais) sur le site de vladan][18]
  * [La documentation de esxi-customizer-ps][7]
  * [Configurer le proxy pour un script Powershell][19] (si vous aussi vous avez la maladie chronique du proxy capricieux)
  * [La documentation officielle pour vSphere ESXi Image Builder de VMware][20]. Cet outil permet de customiser soit même une image ESXi. Cette procédure est beaucoup plus complexe que le script Powershell, bien sûr !

 [4]: http://www.dell.com/support/home/fr/fr/frbsdt1/Drivers/DriversDetails?driverId=09M0X
 [5]: /2017/12/custom_dell_esxi_6.5.png
 [6]: https://akhpark.wordpress.com/2017/01/19/enable-realtek-nic-on-vmware-vsphere-6-5/
 [7]: https://www.v-front.de/p/esxi-customizer-ps.html
 [9]: https://www.v-front.de/p/esxi-customizer-ps.html#download
 [11]: http://partnerweb.vmware.com/comp_guide2/detail.php?deviceCategory=io&productid=5327
 [12]: https://www.intel.com/content/www/us/en/support/articles/000005693/network-and-i-o/ethernet-products.html
 [13]: https://www.vmware.com/resources/compatibility/search.php?deviceCategory=io&details=1&partner=46&releases=367&deviceTypes=6&page=1&display_interval=10&sortColumn=Partner&sortOrder=Asc
 [15]: http://www.vm-help.com/
 [17]: http://www.vdicloud.nl/2015/02/07/realtek-nic-on-vsphere-6/
 [18]: https://www.vladan.fr/realtek-8169-nics-not-detected-under-esxi-5-5/
 [19]: https://martin.hoppenheit.info/blog/2015/set-windows-proxy-with-powershell/
 [20]: https://docs.vmware.com/fr/VMware-vSphere/6.5/com.vmware.vsphere.install.doc/GUID-48AC6D6A-B936-4585-8720-A1F344E366F9.html
