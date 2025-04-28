---
title: 'Erreur StreamServer : Moteur impossible à redémarrer suite à une coupure électrique'
authors:
  - zwindler
type: post
date: 2016-01-16T11:30:15+00:00
url: /2016/01/16/erreur-streamserver-moteur-impossible-a-redemarrer-suite-a-coupure-electrique/
image: /2016/01/streamserve.jpg
categories:
  - Logiciel

---
Après une opération de maintenance annuelle, j’ai eu un souci pour redémarrer une partie de mes moteurs StreamServe (solution de génération de documents acquise par OpenText). Normalement mes moteurs sont configurés pour démarrer automatiquement mais là, un moteur restait éteint. Et lorsque j’essayais de le relancer à la main, il se remettait aussitôt en status éteint sans pour autant m’afficher un message d’erreur (du moins, un visible au premier abord).

En fait, il fallait regarder les logs de plus près. En fouillant un peu le log du serveur, les messages suivants apparaissent :

```
0707-005546: (3175) Server: Started.
0707-005546: (3112) Server: Failed to create queue.(Input)
0707-005546: (3178) Server: Stopped.
0707-005546: (2388) Stopped
```


Au début j’ai pensé de pas avoir d’information utile car je pensais qu’il s’agissait de messages génériques pour m’indiquer que le moteur ne démarre pas. Mais la mention « Failed to create queue.(Input) » est un message d’erreur explicite qui correspondait à mon problème.

En fait dans StreamServe, les files de traitements en entrée et en sortie sont réalisés avec des fichiers. Pour chaque moteur, on a donc un fichier .dat et .idx pour chaque file (entrée et sortie) et chaque moteur.

C’est fichiers sont situés directement dans l’arborescence des moteurs. Dans le cas du MOTEUR1 :

  * C:\editique\SOCIETE1\export_MOTEUR1\data\data\queues\Input\Input.idx (et Input.dat)
  * C:\editique\SOCIETE1\export_MOTEUR1\data\data\queues\Output\Output.idx (et Output.dat)

Les fichiers étaient bien présents mais probablement corrompus suite a un problème électrique qui a eu lieu pile pendant le redémarrage de StreamServe.

J’ai donc réalisé une restauration des fichiers de la queue « input » à une date antérieure.

Lors du démarrage du moteur, le log a affiché que les fichiers avaient été mal fermés (normal car les fichiers sont sauvegardé à chaud, sans coupure préalable du moteur ce qui n’est probablement pas idéal) et les indexs ont donc été reconstruits automatiquement.

J’imagine que l’étape **restauration** n’est peut être pas nécessaire : en l’absence du fichier il est possible que StreamServe décide de les reconstruire de lui même, mais je n’ai pas pu le confirmer.

Solution trouvée sur le site [erp.ittoolbox.com (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20150913051435/http://erp.ittoolbox.com/groups/technical-functional/intentia-l/streamserve-error-on-startup-of-broker-server-failed-to-create-queueinput-3614537).
