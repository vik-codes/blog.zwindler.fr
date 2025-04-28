---
title: 'J’ai testé pour vous Shadow, la plateforme FR de cloudgaming'
authors:
  - zwindler
type: post
date: 2019-04-02T11:45:27+00:00
url: /2019/04/02/jai-teste-pour-vous-shadow-la-plateforme-fr-de-cloudgaming/
image: /2019/03/286682-Horizontal_Dark-4aef44-large-1533040181.png
categories:
  - Divers
  - DIY
  - Matériel
tags:
  - Blade
  - cloud computing
  - cloud gaming
  - Nvidia
  - Shadow

---
Note : **Il ne s’agit pas** d’un article sponsorisé. Pour être honnête, j’avais des questions techniques et Shadow/Blade a même refusé de me répondre ;-p. Vous pouvez donc lire cet article sans craindre que j’aie été influencé.

## Mais pourquoi tu nous parles de Cloud Gaming ??

A l’heure où tout le monde s’extasie (ou pas) suite à l’annonce de [Stadia de Google][1], je prend le contre-pied de (quasiment) tout le monde et je vais vous parler un peu [de Shadow de la société Blade, la plateforme de cloud Gaming à la française][2] !

En fait, ce sujet m’intéresse depuis le début du blog et mes premières bidouilles en 2010. Un des objectifs que je m’étais fixé était de pouvoir avoir une plateforme mutualisant à la fois mon serveur avec ses VMs ainsi qu’une plateforme de jeu, dans une même boite. L’idée était d’avoir juste un écran/clavier/souris ou un portable, n’importe où dans la maison, et de déporter le bruit et la chaleur dans une pièce, plus loin.

A l’époque, j’avais monté une plateforme de virtualisation, idéale pour le serveur, mais pas trop pour une plateforme de gaming déportée. Dans les soucis que j’avais rencontré, la partie virtualisation de GPU et/ou GPU passthrough était un peu capricieuse, et surtout, le plus gros souci de l’époque, étaient les protocoles de streaming.

Clairement, on n’avait pas ce qu’il fallait pour streamer efficacement et facilement un jeu, même en LAN (malgré quelques avancées chez Citrix et Microsoft avec 2008r2).

## Un peu plus tard, le streaming by Steam et NVidia

Quelques années après, Steam a carrément cassé la baraque en apportant la possibilité de streamer des jeux d’un PC à un autre dans la maison. Sur un LAN Ethernet, les contrôles sont fluides, l’image aussi, et j’ai rencontré très peu de bugs. Côté streaming, c’était clairement gagné. On peut aussi noter le NVidia Shield, qui apporte une expérience similaire, mais qui nécessite d’acheter le produit (c’est pour ça que je ne l’ai jamais testé, mais ça marche bien a priori).

Mais il me manquait encore un petit quelque chose. J’avais encore besoin d’avoir un PC séparé pour le jeu et un autre pour les machines virtuelles, ne sachant toujours pas comment mutualiser le jeu et la virtu (voire de virtualiser le GPU dans une VM).

## Et vint Shadow

Clairement, j’avais laissé de côté cet objectif. Et puis, au fil du temps, est arrivé fin 2017 Blade, avec son service Shadow. La promesse, alléchante, était : avoir un PC gamer haut de gamme, évolutif au fil des années, sans avoir à acheter/installer du matériel haut de gamme.

> Plus besoin de hardware : ton Shadow tient dans une simple application. Un PC complet avec des performances haut de gamme, accessible sur tous tes écrans, en un clic.

> Comme nous prenons en charge le hardware, ton Shadow n’est jamais obsolète. Processeur, carte graphique, mémoire... Ta configuration est mise à jour régulièrement

Si on regarde la fiche technique telle qu’elle est disponible aujourd’hui (shadow.tech/discover/specs lien mort, pas disponible sur Internet Archive), pour ~30€ par mois avec une offre d’engagement, on peut avoir une machine avec une GTX 1080, 8 threads dédiés (Xeon), 12 Go de DDR4 et 256 Go de stockage SSD. Shadow s’adresse donc bien, a première vue, à un public gamer relativement haut de gamme.

2ème point important, si Shadow -et plus généralement le cloud gaming- ont un peu de mal à percer, c’est notamment car de nombreuses personnes n’avaient pas de connexion suffisamment stable, avec une faible latence et un débit suffisant pour jouer dans de bonnes conditions.

Si sur de la diffusion type IP-TV, on peut se contenter d’un flux avec un peu de différé pour absorber la latence et la gigue, voire pour optimiser la bande passante, et ainsi permettre à ceux qui ont peu de débit d’en profiter.

Ce n’est évidemment pas possible pour un jeu vidéo, où l’expérience utilisateur sera dégradée, même pour le moins exigeant des gamers, dès ~50 ms (et bien moins pour les plus exigeants).

Avec une latence souvent inférieure, beaucoup plus stable, et des débits très largement suffisant pour passer un flux vidéo même peu compressé, la fibre semble donc être un prérequis (on y reviendra) à Shadow.

## Comparer ce qui est comparable

Maintenant que c’est dit, revenons à mon expérience Shadow, par rapport à mon expérience de jeu habituelle.

Et ça tombe super bien, parce que c’est à peu de choses près la configuration Gamer que j’ai chez moi également (i7 gen4, GTX 1080, 16 Go de RAM, SSD). On est donc sur des machines comparables sur le papier.

En réalité, il y a probablement de grosses différences entre une machine bien ventilée et dédiée sous son bureau et une VM (ou une machine physique ?) avec un GPU dans un rack, et qui accède à une baie de disque SSD partagée par des centaines de personnes.

![Crédits : Blade](/2019/03/305362-DataCenter_PA1_1-0b3205-large-1551539354.png)

Pour finir, la raison qui m’a vraiment décidé à tester récemment, c’est parce que j’ai enfin la fibre chez moi ! A moi les connexions rapides et stables (ENFIN!).

## Économiquement, est ce que ça tient la route ?

Je ne suis (vraiment) pas le premier à tester Shadow (je vous ai laissé en fin d’article une petite compilation des blogs que j’ai lus avant de me décider de tester le service), mais un point que je n’ai vu dans aucun article, c’est l’analyse du prix.

Cette analyse est très difficile à faire car elle dépend de beaucoup de facteurs subjectifs, notamment sur la durée de vie et d’amortissement du matériel. Pour certains, un GPU ne dure pas plus d’un an quand d’autre le garderont jusqu’à ce qu’il tombe en panne ou soit réellement obsolète dans 10 ans. On peut aussi compliquer le problème en partant du principe que le matériel vieillissant peut être revendu !

Je suis donc parti sur les hypothèses suivantes :

  * J’ai profité d’une promotion pour Shadow à 30€/mois sans engagement. Cependant, vous pouvez obtenir un prix similaire hors promo en vous engageant sur 1 an
  * J’ai estimé le prix des composants de mon PC (similaire à Shadow en terme de caractéristiques) au moment où je les ai acheté
  * Je garde mes composants environ 5 ans, sauf le boîtier et le ventirad (10 ans), après quoi je considère que leur valeur résiduelle est négligeable (ils peuvent même être tombés en panne et remplacés hors garanti AVANT les 5 ans)
  * Ça peut paraître anecdotique, mais avec Shadow, vous allez faire des économies d’électricité, puisque vous pouvez vous contenter d’un PC basse consommation. J’ai donc estimé la consommation électrique de ma machine de guerre et j’ai multiplié cette quantité d’électricité par 4h de jeu / semaine

Voilà le détail du calcul :

![](/2019/03/etude_shadow.png)

Avec MES hypothèses, on tombe donc sur un prix sur 5 ans relativement similaire à l’achat d’une machine montée soit même, avec les composants achetés à l’unité et durant 5 ans.

**D’un point de vue purement économique, la bonne nouvelle est donc que Shadow est totalement pertinent par rapport à l’achat d’un PC haut de gamme.**.

## Qualité vidéo

Maintenant que c’est dit, on peut s’attaquer au ressenti utilisateur, en commençant par la qualité du flux vidéo.

Comme je l’ai dis plus haut, contrairement à de la TV sur IP, le stream de jeu doit être le plus rapide et fluide possible. On ne peut pas perdre trop de temps à compresser de manière optimale le flux. Cela induit donc des protocoles nécessitant peu de calculs (et donc potentiellement moins perfectionnés) et des bandes passantes importantes.

Ça va être difficile de vous « montrer » la différence entre l’image réelle et l’image affichée sur mon écran. Je ne vais pouvoir parler que de ressenti.

![](/2019/03/full_screen_2.png)

Mon ressenti (personnel donc), quand j’ai lancé pour la première fois Shadow, est une image _un peu_ baveuse; ce n’est pas aussi net qu’en local.

Mais ce n’est qu’une impression, car en regardant en détail, je n’ai rien pu déceler de visible, en me concentrant sur une partie de l’écran par exemple. Les caractères paraissent nets, il n’y a pas d’artefacts liés à une compression (comme quand on compresse trop un JPG par exemple).

Mais dès la première heure de jeu, je ne le voyais plus. A un tel point, que je me suis finalement dis que j’avais du me tromper, que c’était un biais cognitif... jusqu’à ce que j’arrête d’utiliser le Shadow !

Dès que je suis retourné jouer exclusivement sur mon PC, j’ai tout de suite senti une image plus nette, sans réussir à expliquer pourquoi.

Je précise que je joue sur un 29 pouces extra large (21:9ème) en 2560*1080. Je ne peux donc pas dire quel impact cela a par rapport à une configuration plus classique en 16:9ème (qu’on soit en Full HD ou plus). Certaines personnes avec des résolutions plus élevées (et donc plus rares) ont eu des retours plus ou moins positifs.

Cette résolution n’a posé aucun problème (parfois le cas sur des protocoles de streaming/prise en main à distance).

## Bande passante

La première chose à faire lorsqu’on lance le client Shadow sur un nouveau device est de lancer un test de connexion.

Grosso modo, vous pouvez fixer une bande passante maximale, jusqu’à 50 Mb/s, ou choisir le test de connexion, qui vous permettra, le cas échéant, d’avoir jusqu’à 70 Mb/s (mon cas).

![](/2019/03/shadow1.png)

Récemment, Blade a communiqué sur une nouvelle fonctionnalité du Shadow => la possibilité d’utiliser le protocole H.265 sur des machines récentes (capable de le décoder nativement), pour réduire la bande passante et ainsi permettre aux gens disposant d’une connexion ADSL/VDSL de bonne qualité d’en profiter.

Dans l’interface Shadow, il est question d’un « Mode faible connexion ».

![](/2019/03/shadow4.png)

Je trouve cette terminologie étonnante. sur le papier, le protocole H.265 est très probablement un bon protocole, AUSSI pour les bonnes connexions.

Pour autant, **effectivement**, en faisant des tests, je n’ai pas trouvé d’amélioration à passer sur ce protocole, voire même des dégradations dans la netteté (là encore, c’est du ressenti).

Le point le plus visible que je peux vous montrer, sont les caractères sur fonds blancs dans l’explorateur Windows autours desquels ont peut déceler un léger halo rouge :

![](/2019/03/compression_h265.png)

En plus de ça, en consultant les stats, je n’ai pas remarqué un réel gain en terme de bande passante par rapport au protocole standard....

![](/2019/03/shadow_stats.png)

Je ne me l’explique pas vraiment, mais cela explique très certainement pourquoi Shadow ne le met pas en avant, avec cette dénomination que je trouve un peu « péjorative ». A voir si ça s’améliore dans le futur.

## Réactivité des contrôles, latence

C’est là où je m’attendais à un gros flop et j’ai vraiment été bluffé. Avec une latence entre chez moi (Bordeaux) et les datacenters de Blade (hébergés par Equinix, près de Paris) à 20 ms (très stable), je m’attendais à être capable de déceler un lag, notamment sur les jeux multijoueurs.

![Crédits: Blade](/2019/03/265682-Shadow_DC_Equinix13-e2e69c-large-1511776752.jpg)

En réalité, après avoir joué en ligne à Star Wars Battlefront 2, une partie de la latence induite par l’aller-retour entre chez moi <=> DC de Blade est probablement compensée par le fait que les serveurs de jeu sont plus près. Le tout étant masqué par le « netcode », je n’ai ABSOLUMENT pas vu d’impact sur le jeu, même en FPS/multijoueur.

Les plus hardcores d’entre vous qui cherchent le moindre ms pour sniper dans CS:GO ou qui vivent dans un datacenter seront bien entendu vent debout contre cette affirmation. Cependant, dans mes conditions de jeu, à mon échelle de semi-casual vivant en province, je n’ai pas réussi à voir de différence ! C’est vraiment bluffant.

## Autres configurations du client

Au delà du protocole vidéo, le client Shadow propose un grand nombre d’options et de fonctionnalités (expérimentales, ou pas), c’est très agréables. Je ne les ai d’ailleurs pas toutes essayées.

![](/2019/03/shadow2.png)

![](/2019/03/shadow3.png)

Un des gros points gênant pour Shadow -jusqu’à il y a peu- était le fait qu’il n’y avait pas moyen de passer le son du microphone quand vous aviez un micro-casque jack. C’est normalement corrigé, comme vous pouvez le voir, avec le support Expérimental de l’option.

Personnellement, ayant plusieurs plusieurs périphériques USB (micro-casque, contrôleurs, ...), la fonctionnalité de « forwarding USB » a parfaitement fonctionné. Aucun bug à remonter.

## Et sur d’autres écrans ?

Dans sa publicité pour Shadow, Blade met en avant le fait qu’on peut jouer n’importe où. Sur le papier, l’idée séduit, une fois de plus : c’est tout l’avantage du cloud, plus besoin d’amener sa tour en déplacement, un simple PC portable suffi(rai)t.

Dans la pratique, ce n’est évidemment pas si facile. S’il existe une application Apple et Android, je vois mal qui jouerait un jeu PC sur un iPad, encore moins sur un smartphone. En terme d’ergonomie, utiliser un PC sur une tablette à toujours été un peu fantaisiste, encore plus dans un contexte du jeu.

Quant au PC portable, il va falloir avec :

  * Une bonne connexion sur le lieu où vous voulez accéder à Shadow. On en revient toujours au même => pas de Fibre = risques de problèmes à prévoir
  * Attention à la connectivité Wifi ! J’ai eu une expérience catastrophique (injouable) avec le wifi (N) de ma Freebox v6. Le wifi AC est d’ailleurs fortement conseillé par Blade si vous n’avez pas le choix. Gardez en tête que c’est quasiment ethernet (sans CPL si possible) ou rien si vous voulez éviter de vous faire peur.

Avec ces 2 contraintes, ça limite donc grandement les lieux éligibles à l’accès à votre plateforme Shadow en mobilité...

## Au delà du jeu

Un point qu’on oublie quand on compare Shadow aux autres offres de cloud gaming est le fait que Shadow est une VM dédiée dans le cloud.

C’est VOTRE Windows. Rien ne vous empêche donc de l’utiliser pour autre chose que jouer.

Vue la puissance du bouzin, vous pourriez très bien héberger des serveurs quand vous ne jouez pas. Pour autant, j’ai du mal à voir le cas d’usage, puisque la machine est éteinte quand vous ne l’utilisez pas...

Autre idée, on pourrait en faire une plateforme de téléchargement pour de gros fichiers. Je vous voit arriver avec vos gros sabots (et Blade aussi) => dans une interview, il était questions de surveiller les trafic upload/download anormaux par rapport à la charge. Mais dans tous les cas, vu le prix, on ne peut pas dire que Shadow soit une offre idéale pour faire une seedbox...

## Conclusion

Je me suis déjà beaucoup étalé sur Shadow, et je trouve que c’est un produit super. Vient donc le temps d’arrêter d’en rajouter et de faire un petit résumé.

**Techniquement, Shadow est un produit qui fonctionne, à un tarif cohérent**. Le pari de fournir une machine dans le cloud pour remplacer un PC coûteux est tenu, **dans certaines limites**.

  * Les joueurs les plus acharnés trouveront que la latence ou la (très légère) dégradation de l’image n’est pas acceptable
  * Beaucoup d’utilisateurs se plaignent des performances du stockage, certes sur des baies SSD, mais probablement trop sollicité par rapport au nombre d’utilisateurs
  * La promesse de pouvoir jouer partout est purement marketing // sans connexion fibre (ou VDSL très stable) et full Ethernet, point de cloud gaming ; c’est la vie
  * Ça fait un bon moment que le Shadow fonctionne avec une GTX 1080. Difficile de tenir la promesse « d’un PC toujours à jour » quand NVidia sort des GPU aussi cher que les RTX...

Personnellement, quand j’ai démarré l’abonnement, au vue du prix et des fonctionnalités proposées, je me suis réellement posé la question d’abandonner mon PC fixe et de ne garder que Shadow. Mon objectif était de vendre ma tour et de jouer sur mon portable, via Shadow.

Après un mois d’utilisation, j’ai résilié l’abonnement. Cependant, j’insiste : **ce n’est pas parce que Shadow est un mauvais produit**. Shadow est un produit abouti et stable.

Cependant, il ne faut pas non plus se voiler la face, Shadow n’est pas à la hauteur d’une machine physique avec un i7 et une GTX sous votre bureau.

En revanche, si demain, mon PC tombe en panne, la question se reposera (très sérieusement). Mais en l’état, je préfère garder ma machine de guerre ;).

## Lectures complémentaires

* [www.numerama.com/tech/203045-shadow-tout-savoir-sur-le-pc-du-futur-en-19-questions.html](https://www.numerama.com/tech/203045-shadow-tout-savoir-sur-le-pc-du-futur-en-19-questions.html)
* [www.lesnumeriques.com/informatique/shadow-bilan-apres-mois-d-utilisation-pc-delocalise-a3263.html](https://www.lesnumeriques.com/informatique/shadow-bilan-apres-mois-d-utilisation-pc-delocalise-a3263.html)
* [www.geekzone.fr/2019/01/22/shadow-apres-les-promesses-le-bilan/](https://www.geekzone.fr/2019/01/22/shadow-apres-les-promesses-le-bilan/)

 [1]: https://stadia.dev/
 [2]: https://shadow.tech/
