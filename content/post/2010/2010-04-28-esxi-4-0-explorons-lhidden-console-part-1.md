---
title: 'ESXi 4.0 : Explorons l’Hidden Console Part 1'
authors:
  - zwindler
type: post
date: 2010-04-28T08:32:20+00:00
url: /2010/04/28/esxi-4-0-explorons-lhidden-console-part-1/
image: /2014/10/vmware.jpg
categories:
  - Virtualisation
tags:
  - ESX(i)
  - Hidden Console
  - SSH

---
Je ne vous apprendrai probablement rien si vous connaissez un peu le mécanisme de la console cachée sur l’ESXi, mais j’aimerai apporter quelques précisions pour ceux qui ne connaissent pas.

Donc, pour ceux qui débutent, ESXi, la version non soumise à licence (comprennez « gratuite ») du paravirtualiseur de VMWare est une version allégée, et n’a donc pas de console en ligne de commande à la Unix comme celle de l’ESX, selon les specs fournies par VMWare. Idem pour le SSH. Qu’ils sont vilains menteurs sur VMWare. Elle existe, elle est juste caché, non supportée, et utilisé par l’assistance technique.



Sur le net, j’ai trouvé une multitude de blog offrant LA solution pour accéder à cette « hidden console » et activer par la même occasion le SSH. Cependant, la plupart du temps, la méthode était juste un copier coller d’un autre blog (ce qui n’est pas très gentil) et méritait quelques précisions supplémentaires.

Pour ouvrir la console cachée, la première étape consiste à lancer ESXi jusqu’à arrive à l’écran d’accueil de l’interface de configuration locale. Une fois fait, il est possible d’accéder à la console depuis n’importe quel écran de l’interface. Il faut effectuer les étapes suivantes:

  * Appuyer [Alt] + [F1], un écran noir avec quelques lignes indiquant la version de l’ESXi doit s’afficher
  * Entrer le mot « unsupported » au clavier, puis [Entrée]. Ce mot ne s’affiche pas à l’écran, mais s’il a bien été tapé, le mot « password » doit s’afficher à l’écran
  * Entrer le mot de passe du compte administrateur de l’ESXi, puis valider avec [Entrée]. Attention à bien le taper, vous avez 3 essais. Si vous vous trompez 3 fois de suite parce que vous êtes pressé/stressé, vous vous retrouverez comme moi, avec l’hidden console bloquée jusqu’au reboot de la machine.
  * Quelques lignes vous avertissant que ce mode n’est pas supporté blablabla doivent s’afficher, suivit d’un prompt. Félicitations

Une petite précision que je n’ai pas souvent trouvé dans les articles des blogs qui parlaient de cette méthode pour activer l’hidden console était le moyen d’en sortir. Pour vous éviter le besoin de devoir bruteforcer les touches du clavier, il suffit d’appuyer sur [Alt] + [F2] pour revenir à l’écran de configuration normal :-)

**Disclaimer : Je ne le dirai jamais assez, ce mode est censé être réservé au support technique VMWare. Toute utilisation hasardeuse pourrait résulter à l’instabilité du système, et l’assistance VMWare se fera un plaisir de vous envoyer balader. Ne venez pas me dire que vous n’avez pas été prévenus, ou que c’est de ma faute, ou *. Vous êtes grands, assumez vos bêtises *wink*.**

La suite bientôt (promis)
