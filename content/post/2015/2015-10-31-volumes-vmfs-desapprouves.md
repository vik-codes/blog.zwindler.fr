---
title: 'vSphere 6.0 : Volumes VMFS désapprouvés'
authors:
  - zwindler
type: post
date: 2015-10-31T11:30:57+00:00
url: /2015/10/31/volumes-vmfs-desapprouves/
image: /2015/10/0001_deprecated_vmfs.png
categories:
  - Stockage
  - Virtualisation
tags:
  - 5.61
  - 6.0
  - Console
  - Deprecated VMFS volumes
  - ESX(i)
  - vCenter
  - VMFS
  - volumes VMFS désapprouvés
  - vSphere 6.0

---
## Symptômes

Si vous venez de passer à vSphere 6.0 comme moi, vous êtes peut être tombés sur le bug suivant. Dans un cluster vCenter, vous ajouter une datastore à partir d’un LUN que vous venez de créer. Celui ci est bien créé dans la toute dernière version (5.61), mais pour une raison inconnue, un avertissement « VMFS désapprouvés » apparaît sur tous les **autres** membres du clusters.

![](/2015/10/000_deprecated_vmfs.png) 

ou en anglais (l’erreur me semble souvent plus parlante en anglais chez VMware ... c’est assez énervant) :

![](/2015/10/00_deprecated_vmfs.png) 

Pourtant nous sommes bien dans la dernière version, le datastore est bien visible sur tous les serveurs et même utilisable sans soucis.

![](/2015/10/01_deprecated_vmfs.png) 

Et bien ne vous fatiguez pas, c’est effectivement un bug, référencé par le KB suivant (lien mort).

Mais ...

> Currently, there is no resolution.

Ah ben cool sympa merci !

## Contournement

En fait, ils donnent quand même une astuce pour contourner le problème, mais on ne peut pas dire que ça soit particulièrement pratique à mettre en place. En effet, l’erreur disparaît si vous redémarrez les agents de management de l’hôte.

Déjà, ça veut dire que vous devez passer sur TOUS vos serveurs et appliquer la procédure un par un (on peut le faire de différentes manières, notamment par ssh donc ...), mais surtout, votre hôte devient temporairement inaccessible et donc c’est potentiellement problématique (surtout dans un cluster!).

Pour rappel, voici le KB (lien mort) qui liste les méthodes pour le faire. Moi je l’ai fais via la console (en iLO).

![](/2015/10/02_deprecated_vmfs.png)

![Notez le texte rouge vif pour vous décourager de le faire... Arrrrh, que choisir ? Un warning ou mettre en l’air la production ? Cruel dilemme.](/2015/10/03_deprecated_vmfs.png)

Sinon vous pouvez le faire par ligne de commande comme ceci :

```
/etc/init.d/hostd restart
/etc/init.d/vpxa restart
```

En attendant mieux, il va falloir faire avec. Je ne manquerait pas de vous donnez la solution si VMware venait à réagir dans les prochains jours, mais il est fort à parier que cela passera par un patch à appliquer sur vos serveurs.
