---
title: 'L’open source bashing a encore de beaux jours devant lui'
authors:
  - zwindler
type: post
date: 2018-10-19T11:45:51+00:00
url: /2018/10/19/lopen-source-bashing-a-encore-de-beaux-jours-devant-lui/
image: /2018/10/2kh0qn.jpg
categories:
  - Logiciel
  - Système
tags:
  - bash
  - bashing
  - FOSS
  - HANA
  - humeur
  - Open Source
  - OSS
  - SAP

---
## Une fois n’est pas coutume

(ou même deux, avec [l’histoire sur la licence CC de Pepper and Carrot](/2016/09/09/2223/), et ça parlait déjà d’Open Source)

Petit billet d’humeur aujourd’hui. Voilà ce que j’ai trouvé sur Twitter dans mes « publications sponsorisées » :

![](/2021/tweet_sapfrance.png)

La BD (dont j’ignore qui est l’auteur car je n’arrive pas à déchiffrer sa signature et je n’ai pas trouvé de crédits sur le site de SAP ou dans le tweet), nous relate les aventures d’un chef de projet qui, après de nombreux déboires avec l’open source, décide de prendre SAP, **car c’est beaucoup plus simple**.

Délicieux.

## Vous avez dit bashing ?

Vous savez ! Le bashing. Cette expression anglosaxonne, qu’on nous sert à toute les sauces depuis quelques années dans les medias et sur les réseaux sociaux.

> Le bashing (mot qui désigne en anglais le fait de frapper violemment, d’infliger une raclée) est un anglicisme utilisé pour décrire le « jeu » ou la forme de défoulement qui consiste à dénigrer collectivement une personne ou un sujet.  
> [--Définition Wikipedia][2] (c’est quand même beau, le communautaire)

Alors c’est sûr que ce terme est carrément détourné de son utilisation initiale. Car aujourd’hui, on parle sans discernement de [Mélenchon bashing][3], mais aussi de [Benzema bashing][4], ou même de [plastique bashing][5]. On en est là ;)

Vous n’êtes probablement pas sans le savoir, mais pendant très longtemps, l’open source et les logiciels libres ont étés pendant longtemps mal vus dans le monde professionnels.

Combien de fois on a entendu dire :

  * « C’est un projet libre développé par des barbus dans un garage » (NdA : ça marche aussi pour les défenseurs des libertés individuelles)
  * « C’est gratuit, ça marchera jamais »
  * « Pourquoi tu contribues à ce projet ? Tu devrais te faire payer pour ça ».

Si ça ce n’est pas de l’open source bashing... je ne sais pas ce que c’est !

## C’est lui qu’a commencé !

Le summum de l’open source bashing est très probablement décerné pour l’éternité à Microsoft et à Steve Ballmer pour son [célèbre « Linux is a cancer »][6] de 2001.

A partir de là, la guerre était lancée.

> first they ignore you  
> then they laugh at you  
> then they fight you  
> then you win  
> - [A priori, pas Gandhi, qui n'aurait jamais dit ça (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20210419193743/https://professorbuzzkill.com/qnq-gandhi-first-they/)

Cependant, pas de chance pour Ballmer, il a fallut se rendre à l’évidence. La plupart des entreprises, d’abord les plus grandes, puis de plus en plus petites, utilisent massivement des solutions Linux et/ou qui ne fonctionnent que sous Linux. Tant qu’on était dans le monde des serveurs physique, _on premise_, ça allait encore.

## Tourne. Tourne ! Touuuuuuuuuurne !

Mais l’avènement de la virtualisation a forcé Microsoft a changer son fusil d’épaule.

Les premières versions d’Hyper-V, très très peu performantes lorsqu’ils s’agissait de faire tourner des VMs Linux, faisaient perdre un business considérable à Microsoft. Ceci a profité à VMware, déjà leader (et dans une moindre mesure à Citrix et KVM), qui a creusé le gap.

Cela avait, si ma mémoire et bonne, forcé Microsoft a passer un partenariat d’abord avec SUSE Linux, puis avec les autres grandes distributions et m’avait beaucoup surpris à l’époque.

Aujourd’hui, pour se décoller de cette image de l’**arch enemy de l’open source**, Microsoft dépense des sommes considérables en contribution sur tous les projets open sources qu’ils peuvent trouver. Microsoft a même mis en place un site dédié, [open.microsoft.com][8], pour mettre en avant leurs contributions :

> We are all in on open source  
> --Satya Nadella (CEO actuel de Microsoft)

Ça ne les a pas empêcher de se prendre un bon gros badbuzz lors du rachat de Github.com pour presque 8 milliards de dollars.

« Pourquoi le rachat de GitHub par Microsoft pour 7,5 milliards de dollars choque Internet » titraient alors les journaux. De nombreux projets ont quittés les navires Github.com en protestation, sans se rendre compte **qu’ils avaient toujours été sur une plateforme fermée** (Carl Chenet en parle assez bien dans son article [Le danger Github (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20210614213025/https://carlchenet.com/le-danger-github-revu-et-augmente/)).

## Au delà de Microsoft

D’autres on suivit la tendance. On peut à la fois open sourcer une partie de son code et/ou contribuer à de nombreux projets tout en faisant du business sur du **closed source**. Ce n’est pas forcément _éthique_, mais c’est communément accepté.

Un exemple parmi tant d’autre : VMware, qui a racheté Pivotal et qui met en avant de nombreux produits open source, tout en continuant à capitaliser sur les juteuses recettes de ses logiciels privateurs.

Et malgré ça, de grosses sociétés vendant des logiciels archicomplexes et fermés continuent leur lobbying. Quelques exemples me viennent en tête :

  * Un gros ETL qui explique que vous allez vous planter si vous prenez la solution Open source. L’image choisie pour illustrer le texte **est un âne** montrant les dents (je ne l’ai pas retrouvée).
  * Un logiciel d’entreprise d’échange de fichiers qui va vous coûter vos 2 bras vous explique qu’en fait vous allez perdre de l’argent si vous utilisez les technos libres. L’exemple qu’ils prennent pour illustrer leur propos est « FTP ». Forcément, comparer un système de communication qui coûte des centaines de K€ / an et FTP, j’espère bien que leur logiciel est mieux !
  * Et donc ... SAP

## On décortique le tweet de SAP ?

Dans le cas du jour, on est vraiment dans ce type de caricature.

![](/2021/tweet_sapfrance.png)

Dans le comic, le projet n’avance pas pour plein de raisons ! C’est la catastrophe !

### « Il faut ENCORE installer la nouvelle release. La 2.65 béta en plus ! »

Sous-entendu, les logiciels libres changent régulièrement de version, et ne sont pas stables au point qu’on soit obligé d’utiliser des béta pour se sortir des bugs bloquants.

C’est d’une mauvaise foi sans nom. Nombre de projets libres sont correctement outillés pour gérer proprement les releases, avec des contrôles qualité et des règles de développement très strictes.

Et inversement, nombre de logiciels, open source ou pas, déploient en production du code mal testé, parfois avec des impacts catastrophiques sur les utilisateurs (très récemment [la Fall update de Windows 10][10] qui n’a pas passé toutes les étapes de validation mais est quand même partie en production).

### « version pas compatible avec mon module / le texte qui passe en jaune »

Effectivement, monter de toute pièce une architecture basée sur de nombreuses briques (qu’elles soient libres ou pas en fait, mais bon on est plus à ça près), induit son lot de déconvenues et de problèmes de compatibilité à gérer.

Mais considérons l’alternative. Sur un gros logiciel bien mastoc (genre, un ERP, au hasard), comment ça se passe en général ?

Généralement (vécu à de nombreuses reprises), il y 2 cas :

  * Soit l’entreprise à les reins suffisamment solides pour mettre en place un processus complexe et dédie une équipe entière au maintien de l’ERP à jour (donc très coûteux).
  * Soit ce point est complètement occulté. Dans ce dernier cas de figure, les admins se retrouvent le bec dans l’eau au premier bug, avec un support qui refuse de résoudre tant que la solution n’est pas « à jour ». Au final, on se retrouve avec un ERP jamais mis à jour, de peur de tout casser, avec des failles de sécurités de partout.

C’est sûr, c’est beaucoup mieux.

### « Et le fork, on en fait quoi ? »

Bonne question !

Sous-entendu, a un moment donné, le code a du être forké (pour effectuer des modifications ou appliquer des fix maison) mais l’application officielle a fini par diverger.

Effectivement, si les entreprises souhaitent utiliser l’open source mais ne pas faire profiter le projet de leurs contributions, on va dans le mur ! Mais est ce que ce n’est pas l’entreprise et ses mauvaises pratiques qui est seule responsable, dans ce cas là ?

Donc pour ce point précis, j’ai une solution toute trouvée => si vous utilisez du logiciel open source, contribuez. Ne me remerciez pas, c’était cadeau.

### « Faut acheter un autre serveur / Rachète un serveur / Essaie avec un serveur d’une autre marque »

Alors là ... je ne sais pas quoi dire. Cet argument, martelé 3 fois (donc ça doit être un point important), est incompréhensible.

![](/2018/10/sense-this-picture-makes-non.png)

## Et pourtant, SAP contribue au libre !

Mais le plus incompréhensible dans cette histoire, c’est que SAP fait partie de ces entreprises qui s’engagent dans l’Open Source ! SAP a open sourcé 4 gros projets (et plusieurs centaine plus petits en tout), [disponibles sur Github][12] !

Je suis pratiquement certains que tous les produits de SAP reposent en partie sur nombre de composants open source tiers. Au delà de cette simple intuition (tout le monde utilise de l’open source, que ce soit des libs ou des intégrations vers des produits tiers), 2 indices tendent à prouver que j’ai raison, a minima pour une partie des outils vendus par SAP.

La première, c’est la liste OFFICIELLE des contributions sur des projets externes (lien mort, pas sauvegardé par Internet archive) auxquels SAP (l’entreprise) contribue de manière régulière. SAP n’a aucun intérêt à contribuer activement à ces logiciels, sauf s’ils sont utilisés dans leurs propres logiciels.

Le second, une page sur le site de SAP avec [la liste des outils FOSS (free open source software) inclus et les licences associées][14].

Je ne sais pas de quel logiciel il s’agit ou si cela s’applique à TOUS les logiciels vendus par SAP, mais ça prouve que c’est le cas pour au moins un.

## Au final

Au final, les défenseurs de ce tweet vont me dire que je suis simplement mauvaise langue car c’est simplement de la communication maladroite plutôt qu’une réelle volonté de dénigrer l’open source.

Et en même temps (je n’arrive pas à m'empêcher de le dire, _pas merci Manu_), quand on fait de la comm’, on ne peut pas ignorer que l’open source Bashing, **historique, est fortement ancré dans les entreprises** et particulièrement chez les gens « _qui ont toujours fait comme ça_« .

L’argument que l’open source est considéré comme non fiable continue probablement d’avoir un écho dans les oreilles du top management. **Et ce sont eux, la cible de ce genre de pubs**. Pas l’ingénieur système ou le dev qui fait un peu d’open source le soir, ni même le chef de projet.

**Donc non, je ne pense pas que ça soit maladroit; au contraire, je pense que c’est voulu et c’est même très habile.**

![](/2018/10/2kh0qn.jpg)

## Sources

* twitter.com/SAPFrance/status/1049286253533962241 (lien mort, compte Twitter probablement supprimé par SAP)
* [SAP HANA, la plateforme de données qui rend libre ! (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20210416040752/https://news.sap.com/france/2018/10/sap-hana-plateforme-de-donnees/?source=social-EMEA_North-SAPFrance-TWITTER-MarketingCampaign-DDM-SAPHANA&campaigncode=CRM-FR18-DDM-DIGBLSE)

 [2]: https://fr.wikipedia.org/wiki/Bashing
 [3]: https://melenchon.fr/2018/05/22/alerte-aux-consequences-du-bashing-mediatique/
 [4]: https://www.goal.com/fr/news/halte-au-benzema-bashing-ses-chiffres-ne-sont-pas-si-mauvais-que-/1stnj28oyxovb1wa0959azdo8i
 [5]: https://www.leprogres.fr/haute-loire-43/2018/10/14/stop-au-plastique-bashing
 [6]: https://www.theregister.co.uk/2001/06/02/ballmer_linux_is_a_cancer/
 [8]: https://open.microsoft.com/
 [10]: https://www.nextinpact.com/news/107145-windows-10-problemes-saccumulent-microsoft-bloque-october-2018-update.htm
 [12]: https://github.com/sap
 [14]: https://help.sap.com/saphelp_nw73ehp1/helpdata/de/0a/cad9cd019b4dc4a33baf824a751fce/frameset.htm
