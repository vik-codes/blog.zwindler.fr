---
title: 'ESXi – Problèmes de configuration : SSH a été activé. Non désolé, vraiment pour moi ce n’est pas un problème'
authors:
  - zwindler
type: post
date: 2014-10-27T10:38:11+00:00
url: /2014/10/27/esxi-problemes-de-configuraiton-ssh-a-ete-active-non-desole-vraiment-pour-moi-ce-nest-pas-un-probleme/
image: /2015/07/vmware2.png
categories:
  - Virtualisation
tags:
  - Disable
  - Enable
  - ESX(i)
  - esxcli
  - ESXi Shell
  - SSH
  - vim-cmd
  - Warning

---
![](/2014/10/ssh_esxi.png)

Vous l’avez peut être remarqué, depuis la version 5 de VMware, lorsque vous activez le SSH ou le Shell ESXi (anciennement réservé à la maintenance sur la version 3.5/4.0, voir </2010/04/28/esxi-4-0-explorons-lhidden-console-part-1/>) le client desktop ainsi que le client Web vous informe d’une erreur dans votre configuration.

Soyons clairs, si vous le faites, c’est généralement que vous savez pourquoi vous l’avez fait (A vos risques et périls, bien entendu). Vous n’avez pas envie que le client vous le rabâche, au risque de passer à côté d’un d’autre warning autrement plus grave (RAM, CPU, que sais je encore).

Pour le désactiver, la façon qui me parait la plus simple est d’aller modifier la variable prévue pour, en SSH justement ;-)

Connectez vous en root et exécutez la ligne suivante :

```
vim-cmd hostsvc/advopt/update UserVars.SuppressShellWarning long 1
```


Pour peu que vous soyez pris de remords par la suite et que vous vouliez les remettre, rien de plus simple

```
vim-cmd hostsvc/advopt/update UserVars.SuppressShellWarning long 0
```


A noter, il est également possible d’éditer ce paramètre directement depuis les propriétés avancées  (vous savez, ce menu là, où personne ne touche jamais rien ? ) dans le client Desktop ou le client Web

![](/2014/10/ssh_esxi_2.png)

[Plus d’infos sur le KB officiel (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20181223211844/https://kb.vmware.com/s/article/2003637)
