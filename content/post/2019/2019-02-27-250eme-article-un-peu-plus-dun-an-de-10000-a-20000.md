---
title: '250ème article : un peu plus d’un an, de 10000 à 20000'
authors:
  - zwindler
type: post
date: 2019-02-27T17:00:42+00:00
url: /2019/02/27/250eme-article-un-peu-plus-dun-an-de-10000-a-20000/
image: /2017/03/nyanonimous_rond.png
classic-editor-remember:
  - classic-editor
categories:
  - autohebergement
tags:
  - anniversaire
  - blog
  - blogmotion
  - getfluence
  - journalduhacker
  - mastodon

---
## 250ème article : un peu plus d’un an, de 10000 à 20000

Il y a un peu plus d’un an maintenant, [je « fêtais » le 200ème article du blog (ya 15 mois, déjà...)](/2017/11/07/200eme-passer-de-300-a-10000-vues-par-mois/). Et là, paf! 250. L’occasion de regarder une nouvelle fois dans le miroir pour voir que les choses ont une nouvelle fois pas mal bougé ;).

L’an dernier, j’atteignais avec fierté les 10000 vues par mois. Aujourd’hui, on atteint les 20000, avec un record en octobre dernier avec 22400 vues.

Et ce, sans écrire plus souvent (un temps évoqué car j’ai toujours une 60aines de brouillons en attente qui ne se dépilent pas). C’est même plutôt le contraire (suite à un heureux événement, je vous rassure ;)).

## Et c’est pas fini...

Soyons honnête, ce qui m’a permis d’obtenir cette visibilité supplémentaire, c’est sans aucun doute les communautés IT existantes. D’abord, le gros du traffic non-récurrent provient du [Journal du Hacker et de ses contributeurs][2], qui relaient régulièrement mes articles et je les en remercie beaucoup :).

Ensuite, je commence à agréger un certain nombre de followers, que ce soit sur Twitter (j'ai quitté Twitter depuis) (& Mastodon, on en reparle après), LinkedIn ou via la mailing list qui grossie lentement mais sûrement.

Le trafic récurrent reste concentré sur [les articles sur Proxmox VE](/recherche/?keyword=proxmox), celui sur [le forfait jour en convention collective Syntec](/2017/12/12/convention-syntec-le-cadre-autonome-au-forfait-jour/) (que je vais remettre à jour), mes tutos [sur Kubernetes](/recherche/?keyword=kubernetes) et sur [Ansible](/recherche/?keyword=ansible). Pas très étonnant.

Enfin, le blog commence à être connu, notamment localement puisque je participe à des meetups/confs. Cette année, j’ai notamment donné 2 talks :

  * [Un talk sur Ansible à BDX.IO](/2018/11/09/bdx-i-o-2018-ami-developpeur-deviens-un-ops-sans-effort-avec-ansible/)
  * [Un talk au CNCF Meetup Bordeaux](/2019/02/12/cncf-bdx-les-slides-de-mon-rex-kubernetes/)

D’autres confs sont peut être à venir, puisque je poste régulièrement sur des CFPs :-).

Bon OK, mais tout ça, c’est très bien, mais le but du blog n’est pas de faire du chiffre (même si c’est toujours agréable). Le but reste de produire du contenu qui vous sera utile.

## Les articles à venir

J’espère ne pas vous avoir perdu, car c’est la partie la plus importante !!

Comme je l’ai dis plus haut, j’ai toujours une 60aine de brouillons en attente (moyenne constante depuis quelques années). Certains sont même relativement avancés et nécessitent juste d’être mis en forme ou éventuellement remis à jour avec la dernière version (tellement ils sont vieux).

On m’a gentiment fait remarquer que je n’avais qu’à vous proposer à des personnes qui n’ont pas encore de blog et qui voudraient se lancer de poster sur le blog. **C’est une excellente idée !** D’ailleurs, j’héberge déjà les articles de 2 anciens collègues et amis, [M4vr0x](/recherche/?keyword=m4vr0x) et [ventreachoux85](/recherche/?keyword=ventreachoux85).

Si vous en avez l’envie, n’hésitez donc pas à m’écrire pour voir ce qu’on peut faire ensemble.

Dans tous les cas, qu’il y ait des volontaires ou pas, voilà ce que j’aimerai sortir dans les mois qui viennent (et ya du très très lourd) :

  * Kubernetes 
      * Sauvegarder votre Kubernetes avec ARK
      * Grafana et Prometheus par l’exemple : tester l’anti affinité
      * Utiliser Azure files comme Storage Class dans Kubernetes
  * Proxmox VE 
      * Créer un cluster Proxmox VE en HA dans le cloud avec Tinc
      * Snapshots, sauvegarde, réplication dans Proxmox VE
  * Droit et divers 
      * **Quand des anti-linky détournent les résultats d’une thèse sérieuse en instrument de propagande**
      * Que risque-t-on vraiment avec l’abandon de poste ?
      * Peut on réutiliser un tweet sans l’accord de son auteur ?
      * Email perso sur boite pro, petite histoire d’une exception

## Ce qui a changé

Déjà, j’ai migré le blog sur un cluster Proxmox VE hautement disponible. Avant, on était sur un serveur stand alone avec un autre serveur en standby prêt à démarrer si nécessaire.

Ça peut paraître être un minimum pour un DevOps/SRE/Cloud engineer/whatever, mais vous le savez aussi bien que moi, ce sont les cordonniers les plus mal chaussés ;)

Ensuite, j’ai créé un compte dédié pour le blog sur [LinkedIn][4] et Facebook. Et depuis peu, j’ai aussi ouvert des comptes sur Mastodon ([@framapiaf.org/@zwindler_rflx][13] pour le blog, [@framapiaf.org/@zwindler][14] pour moi) pour relayer la bonne parole à ceux qui ont désertés les plateformes fermées :).

## Ce qui va changer

Plusieurs choses, si j’arrive à m’y atteler. J’ai pour projet de ...

### Me débarrasser de Worpress

**N°1 PRIORITY**

Sérieusement, j’en peux plus... J’ai besoin d’une 15aine d’extensions, je passe mon temps à les maintenir à jour, les perfs d’affichage sont bof, et ça, juste pour afficher du texte !

J’ai du tweaker le blog, ajouter des caches, analyser les trames et les waterfall views, etc. Alors oui, c’était intéressant de le faire une fois, pour savoir comment ça marche. Mais en vrai, est ce qu’on (nous bloggeurs) se fait pas du mal pour rien ?

De nombreuses personnes sont (re)partie vers des sites statiques (agrémentés d’un moteur de commentaire), qui sont plus que suffisant pour ce qu’on en fait...

Guttenberg est la goutte d’eau qui a fait déborder le vase ([même si je sais qu’on peut revenir 3 ans sur l’ancien moteur][15]).

Je ne suis pas le seul à faire ce constat, et comme beaucoup, [Hugo (gohugo.io)][16] sera très probablement le futur moteur du blog. Je vous tiendrai au courant. Mais bon, vous le verrez vite ;-).

### Dégager Google Analytics

Et oui... j’utilise Google Analytics. Pas cool pour les trackers, surtout que je n’ai pas trop le temps d’analyser le trafic entrant pour adapter mon SEO. Soit je m’en débarrasserais totalement, soit je passerai sur Matomo (Piwik) Là encore, d’autres l’ont fait avant moi, rien de foufou ([NextInpact entres autres][17]).

### Dégager Amazon Partenaires (et Adsense, soyons fous)

Là encore je vais être honnête, je monétise le blog (comme je peux). Ça me paye les frais d’hébergement et me permet (parfois) de payer des VMs pour tester des trucs (Scaleway par exemple) et ainsi écrire de nouveaux articles.

J’ai essayé les dons (via Paypal), ça n’a jamais marché. Le peu que j’ai eu, je l’ai reversé à Wikimedia, tellement c’était ridicule (~10 euros).

En revanche, ce qui marche pas mal, c’est les liens affiliés vers Amazon et les pubs via Google Adsense. Amazon, si je n’approuvais pas trop leur « éthique », je n’approuve plus non plus la façon dont ils traitent leurs clients. Arrêter de consommer chez eux n’aurait pas trop de sens si je continuais par derrière à leur aiguiller des clients.

La 2ème étape est de trouver d’autres méthodes de financement du blog, pour dégager aussi Adsense; et là c’est plus dur.

Depuis peu, j’essaye une nouvelle source de revenu. J’ai enregistré le blog sur [Getfluence][18]. Pour faire simple, il s’agit d’un site mettant en relation des marques et des éditeurs pour des articles sponsorisés.

Je vous vois froncer les sourcils. Je n’étais pas du tout fan de l’idée non plus jusqu’à ce que je vois que pouvait imposer MES conditions, à savoir :

  * **Refuser** le publi-rédactionnel. C’est MOI qui écris et c’est non négociable
  * **Refuser** que la marque relise l’article (et modifie les parties qui lui plaisent pas)
  * L’information comme quoi il s’agit d’un **article sponsorisé est clairement visible**
  * Et bien entendu, refuser les articles qui n’ont rien à voir avec la ligne éditoriale

Et là, ça me gêne moins. Si une marque (type éditeur de logiciel) me contacte pour tester leur outil et que je peux faire un article pour leur donner de la visibilité en tout honnêteté et sans pressions de leur part, je ne vois pas le problème. Et si des lecteurs refusent de lire mon article par dogme car il est sponsorisé, si c’est indiqué clairement, no pressure.

En tout cas, on verra bien si ça prend ou pas.

Si vous voyez une autre méthode ou que vous avez un avis sur la question, je suis bien entendu preneur, même si cette problématique longuement évoquée par d’autres blogueurs ([Xhark de Blogmotion par exemple][19]).

En attendant, à l’année prochaine ;)

 [2]: https://www.journalduhacker.net/
 [13]: https://framapiaf.org/@zwindler_rflx
 [14]: https://framapiaf.org/@zwindler
 [15]: https://www.justegeek.fr/wordpress-5-retrouvez-lancien-editeur-wordpress
 [16]: https://gohugo.io/
 [17]: https://www.nextinpact.com/blog/97835-pourquoi-next-inpact-arrete-publicite-classique-et-passe-au-https-pour-tous.htm
 [18]: https://affiliate-getfluence.com/fr/e38e2999e924e8fdc5f190e82bd70f6b
 [19]: http://blogmotion.fr/le-blog/avenir-blog-11782
