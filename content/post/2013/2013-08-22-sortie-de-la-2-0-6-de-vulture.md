---
title: '[En bref] Sortie de Vulture 2.0.6'
authors:
  - zwindler
type: post
date: 2013-08-22T19:38:28+00:00
url: /2013/08/22/sortie-de-la-2-0-6-de-vulture/
image: /2014/12/logo2-white1.png
categories:
  - autohebergement
tags:
  - CentOS
  - content rewrite
  - debian
  - django_evolution
  - Rewrite Header
  - Shinken
  - vulture
  - websso
  - webui

---
## Sortie de Vulture 2.0.6

Dans le genre news pas très fraîche, je voudrais la sortie Vulture 2.0.6, vieille d’environ 2 mois... [Sortie de Vulture 2.0.6](http://www.vultureproject.org/2013/07/sortie-de-vulture-2-0-6/)

Le changelog fait état de la correction de 3 bugs et l’ajout de quelques petites features sympa. Je ne sais pas si c’est les mises à jours des dépendances (ou les modifications de celles ci?), mais j’avais plusieurs comportements étranges sur mes vulture (Debian et CentOS de test) qui semblent aujourd’hui être de l’histoire ancienne!

Comme d’habitude avec Vulture, mise à jour = suppression de la base de données. Vous aurez donc tous vos paramétrages à refaire, mais personnellement, je trouve que le jeu en vaut la chandelle dans ce cas précis.

Sachez aussi que normalement cela devrait être la dernière fois si l’on en croit la doc d’install de Vulture.

A tester la prochaine fois, j’ai hâte de ne plus avoir besoin de tout refaire à chaque fois !

> **Activation de django-evolution**

Depuis la version 2.0.6, il est possible d’activer l’application django-evolution sur vulture, qui permettra une mise à jour de la base de données lors des mises à jour.

Afin de l’utiliser, il faut d’abord l’installer:

```
easy_install -U django_evolution
```


N’hésitez pas à remonter à la dev-list toutes les anomalies que vous pourriez rencontrer. Ils sont assez réactifs.
