---
title: 'Vous avez gagné NVidia, j’abandonne Surround (Triple écrans)'
authors:
  - zwindler
type: post
date: 2017-03-14T12:05:57+00:00
url: /2017/03/14/fr-youve-won-nvidia-i-give-up-surround-triple-screen-just-wont-work/
image: /2017/03/LUOWehvo_400x400.jpeg
categories:
  - Matériel
tags:
  - BF3
  - BF4
  - Dragon Age Origin
  - EA
  - Giving up
  - GTA-V
  - GTX
  - Metro 2033
  - Nvidia
  - Open Letter
  - Rise of the Argonauts
  - SLI
  - Surround

---
Dans ce post, je vais vous expliquer pourquoi je me suis acharné à faire fonctionner mon triple écran avec NVidia Surround et pourquoi j’ai finalement abandonné.

[English readers]The english version [is here](/2017/03/13/nvidia-i-give-up-surround-just-wont-work/)[/English readers]

## Je fais parti du segment d’acheteurs « Enthousiasts »

Je suis « Fan » des produits NVidia depuis bien longtemps. La première carte graphique que je me suis acheté avec mon argent de poche (précieusement économisé pendant des mois) était une [GeForce 4 Ti 4200][2]. Depuis, je n’ai (pratiquement) jamais été du « côté obscur ».

![](/2017/03/nvidia-geforce4-ti4200.jpg)

Ce n’est qu’à la sortie de la 770 que j’ai commencé à vouloir devenir « sérieux ». J’avais à l’époque une 570 qui marchait bien mais je savais que je ne pourrais pas espérer jouer sur 3 écrans avec un framerate décent, même en baissant les graphismes. J’ai donc cassé mon compte en banque, et j’ai acheté une 770 au prix fort dès sa sortie, ainsi que deux écrans supplémentaires.

C’était fantastique. L’immersion était totale.

![](/2017/03/IMG_20131225_204426.jpg)

C’était également un GROS avantage sur les autres joueurs, l’angle de vue était bien plus important.

![](/2017/03/umadbro-1.jpg)

Mais vraiment, j’insiste, l’argument majeur pour moi était que j’étais littéralement DANS le jeu. Ma femme peut en témoigner, de nombreuses fois elle m’a fait bondir de ma chaise juste en entrant dans la pièce.

## Mais ça n’ira malheureusement jamais mieux

J’avais pourtant mis beaucoup d’espoirs dans une évolution positive. En tant qu’ingénieur systèmes, en transposant à mon propre travail, j’avais imaginé que le support de ce genre de technologies ne pouvait que s’améliorer avec le temps. Les drivers, les jeux, les OS, ...

### J’aurai du rester sur BF3

Dès que j’ai commencé à jouer à d’autres jeux, j’ai compris que BF3 était en fait l’exception plutôt que la règle.

La plupart du temps, les jeux ne supportent tout simplement pas le 5760*1080 et forcent à repasser sur des résolutions FullHD, désactivant ou pas les écrans périphériques (donc écran noir ou bureau windows). Et c’est malheureusement presque le « meilleur » scenario. Certains jeux laissent espérer supporter la résolution, mais l’interface se retrouve écrabouillée, écartelée aux extrémités des 3 écrans, ou bien carrément invisible. Ou alors, parfois, c’est les cinématiques qui ne fonctionnent pas.

Dans certains cas extrêmes, le jeu se lance sur un seul écran, mais l’image est tellement déformée qu’on devine que le jeu a inséré l’image des 3 écrans sur un seul (Rise of the Argonauts & Metro 2033). La seule solution à ce genre de problèmes est de désactiver Surround et de le réactiver une fois la session de jeu terminée.

Alors je vous entend dire : « Ha ! Ce n’est donc pas la faute de NVidia. C’est le jeu qui ne supporte pas Surround. » Je suis obligé d’être d’accord, au moins en partie. Pour autant, NVidia vend sa technologie en laissant penser que de nombreux jeux sont compatibles; or pour que ce soit le cas, il faudrait qu’ils donnent aux développeurs des jeux les moyens pour créer simplement des jeux compatibles.

A minima, qu’ils donnent au joueur un moyen simple de désactiver Surround en entrant dans un jeu, ou mieux encore, que cela soit transparent (GeForce Experience ?). Pour ceux qui ne comprennent pas où je veux en venir, voici la procédure pour désactiver/réactiver Surround :

![](/2017/03/nvidia_on_off.png)

> From tacc (nvidia forum)

Ceux qui connaissent Surround savent peut être qu’il existe un combinaison de touches pour désactiver/réactiver Surround mais ne vous inquiétez pas, je reviendrai sur ce point précis plus tard.

### SLI and Surround

Je vais être honnête, mon framerate quand je jouais à BF3 en 3x Full HD était un peu faible, même avec les graphismes « pas au max ». Mais je n’ai jamais été exigeant au point de vouloir à tout prix mes 60 FPS et ça me suffisait.

Dès que BF4 est sorti, j’ai vite compris que ma 770 ne suffirait pas. Même si les 2 jeux ne sont séparés que d’un peu plus d’un an, BF4 était clairement plus gourmand. J’avais des baisses massives de framerate (du bon gros lag). La solution la plus économique pour moi, même si j’étais plutôt contre, était le SLI. La seule autre option était de changer pour une 780Ti, ce qui n’était pas du tout dans mon budget.

![](/2017/03/IMG_20141104_221126.jpg)

Vous le savez probablement, SLI est une blague. SLI a toujours été un blague.

Je m’y étais toujours refusé à cause de la longue histoire de bugs sur des SLI (ou Crossfire...) de mon entourage. Sans parler des limitations inhérentes à ces technologies (besoin d’avoir le même GPU, si possible des modèles strictement identiques, la mémoire virtuelle des GPU ne s’additionne pas, etc).

Du coup, utiliser à la fois SLI **et** Surround en même temps est probablement la plateforme la plus expérimentale en jeux vidéo que vous pouvez atteindre. Enfin au moins jusqu’à ce que les gens se mettent à tester DirectX 12 avec plusieurs vendeurs de cartes graphiques. Des gens qui essayeront de faire marcher à la fois des cartes AMD et NVidia, ça va vraiment être hilarant. Un peu comme le monstre de Frankeinstein ou Debian GNU kFreeBSD (le kernel FreeBSD avec le système de paquets Debian apt).

L’exemple le plus drôle de bug SLI que j’ai eu est GTA-V. Que les graphismes soient au minimum ou au maximum, en Surround + SLI, je suis tombé sur des artefacts graphiques très perturbants et de manière aléatoire.  
![](/2017/03/2015-05-04_00003.jpg)

Après plus de 50 emails échangés avec le support (sans exagération) de GTA-V, j’ai finalement trouvé la réponse parmi la communauté « Surround » du Forum NVidia.  
Helifax, un joueur de Witcher III [a passé des heures à tester de manière extensive les performances en SLI sur The Witcher, également abondamment buggé, pour finalement déterminer que la performance dépendait de comment les écrans étaient branchés sur les cartes][9].

> COMMENT. LES. ECRANS. SONT. BRANCHES.

Et miraculeusement, j’ai pu confirmer que changer la façon dont j’avais branché mes écrans a corrigé mon problème (que peu de gens semblaient avoir).

Après tout ces déboires, j’ai finalement vendu mes 770 et j’ai acheté une 1080, seule carte suffisamment puissante pour gérer 3 écrans en Full HD. Je ne peux toujours pas jouer aux jeux qui ne supportent pas Surround, mais au moins je n’ai plus de soucis de SLI.

[Carte Graphique MSI Nvidia GeForce GTX 1080 GAMING X 8G](https://www.amazon.fr/gp/product/B01GELBO1C)

### Surround et Windows 10

Je ne fais pas que jouer sur cet ordinateur. Je travaille aussi avec.

A savoir : le client RDP de Windows MSTSC ne supporte pas le Surround. La résolution maximale accessible est celle des écrans 21:9, ce qui a pour conséquence d’afficher une partie de l’image sur les bords des écrans extérieurs et 2 gros carrés noirs sur le reste.

Pour une raison inconnue, j’ai bêtement pensé que Windows 10 supporterait mieux Surround. Dès que j’ai pu, j’ai pu faire la migration gratuite de Windows 7 à Windows 10, je l’ai donc fait (comme beaucoup).

Et bien sachez que depuis ces 18 mois que l’OS est disponible, Surround ne fonctionne pas sur Windows 10 :  
- Redimensionner une fenêtre est un calvaire. Si vous maximisez une application, elle se maximisera sur les 3 écrans. Toutes les fenêtres sont donc à redimensionner à la main. [Edit]Soit la dernière version du driver corrige le problème, soit ça marche de manière aléatoire[/Edit]  
- Par défaut, la barre de tâches Windows prend les 3 écrans, ce qui n’est pas du tout ergonomique. Heureusement, NVidia propose dans les propriété du Driver de la réduire à 1 écran, celui du milieu par exemple. Cependant, quand vous cliquez sur le bouton du menu Windows, le menu apparaîtra TOUJOURS sur l’écran le plus à gauche. J’espère que vous n’avez pas trop de torticolis.  

![](/2017/03/nvidia_surround_windows10.png)

- Mais le plus amusant dans tout ça est à venir. Vous vous souvenez quand je râlais que la procédure pour désactiver Surround est très complexe quand vous avez une application qui ne supporte pas ce mode ? J’avais nuancé en expliquant qu’il existait une combinaison de touche pour automatiser cette action. **Et bien avec Windows 10, cette combinaison ne marche plus.** Du tout. Je vous renvoie donc à la procédure de « tacc » détaillée plus haut. Voilà.

## NVidia se fiche des enthousiastes et des utilisateurs de Surround

Bien sûr, ne me croyez pas sur parole. Vous voulez un autre point de vue ? Allez lire le [Forum NVidia Surround][11].

Alors OK. NVidia a gagné, j’abandonne Surround.

J’imagine qu’ils pourraient arrêter de le supporter car je me demande s’il reste encore beaucoup de résistance chez les enthousiastes.

**Mais après tout, c’était peut être le but depuis le début**

 [2]: http://www.hardware.fr/articles/419-1/nvidia-geforce4-ti-4200.html

 [9]: https://forums.geforce.com/default/topic/839311/nvidia-surround/-how-to-wticher-3-3d-surround-benchmark-solution/
 [11]: https://forums.geforce.com/default/topic/860380/nvidia-surround/windows-10-surround-not-fully-working/1/
