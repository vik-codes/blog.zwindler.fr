---
title: '[En bref] Mapper plus de 20 imprimantes dans une session RDP – Erreur 1124'
authors:
  - zwindler
type: post
date: 2016-01-09T11:30:29+00:00
url: /2016/01/09/reminder-mapper-plus-de-20-imprimantes-session-rdp-erreur-1124/
image: /2015/12/rdp.png
categories:
  - Système
tags:
  - DWORD
  - imprimantes
  - MaxPrintersPerSession
  - printer
  - queue
  - RDP
  - regedit
  - Terminal Services
  - Windows 2008

---
## Erreur 1124

Voilà la petite histoire de l’erreur 1124. Après avoir mis à disposition un serveur Windows en mode bureau à distance RDP (familièrement appelé TSE), des utilisateurs sont venus râler à mon bureau. Ils n’avaient pas leurs imprimantes dans leur session RDP !

Je me connecte, regarde : je vois plein d’imprimantes. Qu’est ce qu’ils me racontent ?!

En fait, ils avaient « raison ». Ils n’avaient pas LEURS imprimantes. Ils en avaient d’autres, mais pas les leurs. Ce serveur avait été mis à disposition d’utilisateurs d’une autre société, société dans laquelle tous les utilisateurs ont par défaut TOUTES les imprimantes mappés sur leur compte (donc les 3/4 ne leur servent à rien).

Or, par défaut, on ne peut pas mapper plus de **20 imprimantes** dans une session. J’ai réussi à trouver des informations à ce sujet car des événements remontent dans le journal d’événement.

> Erreur 1124 : The number of printers per session limit was reached. The following print queue was not created

Pour aller au delà il faut modifier le registre (ou mieux appliquer la modification par GPO).

Se placer dans _HKEY\_LOCAL\_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\_

Rajouter une clé **MaxPrintersPerSession** de type « DWORD (32 bits) » et mettre la valeur qui convient (200 par exemple).

Après reboot le paramètre sera appliqué et les utilisateurs pourront monter leurs dizaines d’imprimantes.
