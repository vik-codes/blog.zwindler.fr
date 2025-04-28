---
title: 'Comment veulent-ils que nous mettions à jour huit cents serveurs toutes les semaines !?'
authors:
  - zwindler
type: post
date: 2022-07-30T12:00:00+00:00
excerpt: "Petit retour à chaud sur un REX d'un cyberattaque en février 2021 chez Manutan"
url: /2022/07/30/comment-veulent-ils-que-nous-mettions-a-jour
image: /2022/07/manutan.png
categories:
  - Divers
tags:
  - cyberattaque 
  - cybersécurité
  - Manutan
  - Microsoft
  - Faille
  - Cryptolocker
  - DSI
  - RSSI
  - ComEx
  - EDR
  - AD
  - Exchange
---

C'est avec cet extrait d'un article de #LeMagIT que j'ai lancé (un peu malgré moi) un gros débat sur Twitter 🐦.

![](/2022/07/lemagit.png)

(Et il y a encore plus grave dans l'article, j'ai rajouté une note, plus loin)

Pour vous résumer la chose, j'ai lu un témoignage de Manutan qui a subit une cyberattaque en février 2021.

[Le Mag IT - Récit : comment Manutan s’est sorti de la cyberattaque du 21 février](https://www.lemagit.fr/etude/Recit-comment-Manutan-sest-sorti-de-la-cyberattaque-du-21-fevrier)

Le directeur des opérations IT du groupe explique que Microsoft n'a pas voulu les aider (enfin si, mais pas gratuitement et pas au pied levé 😏) car ils ne mettaient pas à jour leurs serveurs.

"Comment veulent-ils que nous mettions à jour huit cents serveurs toutes les semaines !?"

Je tombe de ma chaise 🪑

Quelques réponses que j'ai reçu à la suite de ça :

## "tout les Kevin je sais tout qui pense que c’est vraiment possible d’update 800 machine toute les semaines"

(oui quelqu'un m'a répondu ça)

Loin de moi l'idée de nier la difficulté de maintenir un parc de serveurs dans un environnement industriel + Windows (je connais, je l'ai déjà fait). 

Et bien entendu qu'il faut rester humble : même avec la meilleure des sécurités, une attaque reste toujours possible pour un criminel suffisamment motivé.

Mais quand même ! Que quelqu'un ose écrire, sans rougir, après attaque au cryptolocker, qu'ils ne mettent pas à jour leur parc, car c'est trop compliqué ???

Avec toutes les cyber attaques qui pleuvent depuis des années ? Avec tous les messages martellés par ANSSI, la gendarmerie et le gouvernement ?

## "cest chaud… surtout s’il y a des applications spécifiques avec des technos différentes…"

Que certains systèmes industriels soient mal conçus, peu maintenus par l'éditeur, impossible à mettre à jour sans interruption, ce sont des faits.

Pour autant, ça ne veut pas dire que c'est acceptable, hein ? 

A nous, professionnels de l'IT de peser sur les décideurs pour éviter d'en arriver là ! La maintenabilité et les logiciels à sources ouvertes devraient être dans la liste des critères pour choisir une solution logicielle / industrielle, quelle qu'elle soit.

## "Une plate-forme de QA Iso prod avec des tests automatisé de non régression est vu comme une charge et non pas comme mandatory. 🤷‍♂️"

Les outils/moyens pour automatiser les mises à jours ET les tests de régression existent (même sous Windows 😏). Encore faut-il y mettre les moyens (financiers, humains) et former les opérationnels ! Pas toujours facile à faire entendre à un ComEx, mais c'est là aussi le rôle et la responsabilité du DSI / RSSI. Ca me parait un peu facile de s'en défausser par la suite.

L'humain est aussi capital et souvent sous-estimé par rapport à l'outillage (acheter un EDR ou faire un audit de sécu oneshot, c'est rassurant, mais est ce suffisant ???).

![](/2022/07/lemagit2.png)

[EDIT] J'avais mal compris ce passage. Mais en fait, ils avaient les outils pour détecter l'intrusion (qui a duré 3 mois avant le lancement du cryptolocker) mais **personne n'a regardé les alertes** ! Clairement là c'est super grave.

## Si encore il n'y avait que les serveurs industriels, passons

Quand vraiment il n'y a pas de solutions (ou un passif trop important), il faut isoler les systèmes problématiques. Réseaux séparés (physiques ou logiques), pas d'accès à Internet, surveillance accrue... Je connais des industriels qui y arrivent très bien, ce n'est pas impossible.

Mais pour finir, sur les 800 serveurs touchés chez Manutan, il n'y avait pas QUE des serveurs industriels. 

Tout y est passé : AD, messagerie, bureautiques, espaces de stockages partagés. Des systèmes "standards" qui **eux** auraient **dû** être à jour, car il n'y a pas de difficulté technique particulière sur ces genres de briques techniques...

## Derniers mots

On peut quand même reconnaitre à Manutan d'avoir eu les bons réflexes post incident : faire les morts auprès des cybercriminels, chercher de l'aide, ne pas payer la rançon, restaurer les systèmes de manière méthodique.

Ils ont visiblement été bien accompagnés par leur partenaire.

Enfin, on peut surtout saluer la transparence de ce REX. 

Bravo pour tout ça.

Mais clairement, il nous reste encore beaucoup de chemin à parcourir et on va avoir besoin d'encore beaucoup de pédagogie pour sécuriser nos SI...

## Liens

* [Le Mag IT - Récit : comment Manutan s’est sorti de la cyberattaque du 21 février](https://www.lemagit.fr/etude/Recit-comment-Manutan-sest-sorti-de-la-cyberattaque-du-21-fevrier)
* Mon thread Twitter (lien mort, j'ai quitté Twitter)
* [La même chose sur LinkedIn](https://www.linkedin.com/posts/denis-germain_lemagit-cyberattaque-microsoft-activity-6959123398283169792-WeMR?utm_source=linkedin_share&utm_medium=member_desktop_web)
