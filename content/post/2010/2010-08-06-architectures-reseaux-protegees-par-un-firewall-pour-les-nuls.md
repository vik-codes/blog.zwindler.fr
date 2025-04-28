---
title: '[En bref] Architectures réseaux protégées par un firewall pour les nuls'
authors:
  - zwindler
type: post
date: 2010-08-06T08:55:22+00:00
url: /2010/08/06/architectures-reseaux-protegees-par-un-firewall-pour-les-nuls/
image: /2010/08/images.jpg
categories:
  - Divers
tags:
  - DMZ
  - Firewall
  - Netfilter
  - Réseaux
  - Whitebox

---
## J’aime pas les Firewall

Dès que ça touche aux réseaux, je suis tout de suite moins à l’aise. J’ai toujours préféré les systèmes, mais il faut savoir se faire violence et toucher un peu à tout. Cela inclus aussi ces aspects réseau/sécu/firewall :-(.

Maintenant que je dispose de ma Whitebox ESXi, je commence progressivement à ajouter des VMs. Et plus il y en a, plus je me dis que mettre tout ça dans un réseau à plat... n’est pas très carré comme approche.

Du coup ça fait un moment que je cherchais comment « organiser » tout ça, si possible dans les règles de l’art. En surfant sur l’Internet, je suis tombé sur un PDF qui explique comment mettre en place différents types de réseaux protégés par un firewall en fonction de leur taille et leurs besoins, [ici (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150419205220/http://publications.jbfavre.org/CFI/Firewall/7-Application.pdf).

Alors OK, quand je dis pour les nuls, il faut avoir au moins une connaissance minimum d’Unix, des réseaux TCP/IP, etc.

Ce cours est bien détaillé et progressif ce qui le rend très accessibles aux novices. Il se base sur NetFiler, une distribution Firewall bien connue et propose d’apprendre les bases du cloisonnement réseau par l’exemple.

Merci à son auteur (Jean Baptiste Favre), ça m’évite de devoir ressortir mes cours de réseau.
