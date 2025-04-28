---
title: 'Réinventons la roue : j’automatise des actions via SSH+mdp avec un script expect'
authors:
  - zwindler
type: post
date: 2016-08-11T17:30:13+00:00
url: /2016/08/11/reinventons-roue-jautomatise-actions-via-sshmdp-script-expect/
image: /2016/08/expect.jpg
categories:
  - Script
tags:
  - ansible
  - chef
  - expect
  - puppet
  - salt
  - script
  - SSH

---
## Dans quels cas ne pas utiliser ce script expect

Attention : je met en ligne ce script juste pour information. Cela peut aussi être utile si vous avez un besoin spécifique qui nécessite l’utilisation du binaire **expect.**

Si vous avez très rapidement besoin de réaliser sur un ensemble de serveur un tâche répétitive via SSH, le mieux est de jeter un œil vers **Ansible**. Les modules sont nombreux, les possibilités infinies, la facilité du langage déconcertante. Et contrairement aux autres (puppet, chef, salt), c’est sans agent !

## Alors pourquoi j’ai pris du temps pour développer un script expect ?

Il y a deux ans, j’ai été chargé de réaliser une petite étude sur Puppet, un gestionnaire de configuration qui permet de définir un standard pour un groupe de machine. Un exemple simple est la gestion du NTP. En prenant le temps d’apprendre, on peut assez facilement définir sous Puppet un template qui stipule que tous les serveurs Linux doivent avoir le démon NTPd installé et opérationnel avec le bon fichier de configuration.

Pour autant, la nécessité de déployer des agents sur des centaines de serveurs et le langage un peu pompeux (pour le néophyte que j’étais) m’avait freiné. Car bien sûr, j’avais besoin TOUT de suite de quelque chose d’opérationnel, je n’avais pas le temps de :

  * Mettre en production un serveur puppet
  * Déployer les agents sur les machines
  * Tester mes templates avant de passer la modification sur tous les serveurs

Une solution simple aurait été de déposer une clé SSH sur tous les serveurs et de réaliser une simple boucle. Dans le même temps, certains de mes collègues étaient en train de travailler sur ce sujet précis. Pour préserver la paix de l’openspace, je ne souhaitais pas leur marcher sur les pieds.

Pour résoudre dans l’immédiat mon problème, j’ai utilisé **expect**.

## « We do not forgive, we do not forget, ... »

Pour ceux qui ne connaissent pas l’outil, il s’agit d’un binaire qui permet d’automatiser des tâches en fonction du retour renvoyé par le terminal. Cela peut être utile pour réaliser un ensemble de tâche sur via des outils tels que FTP (ou [TFTP pour des switchs dans cet exemple (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20240301182514/https://blog.info16.fr/index.php?article61/scripter-des-commandes-a-distance-expect)). Et un script bash classique dans lequel vous ne pourrez **pas ** entrer un mot de passe (le prompt du mot de passe nécessite un « vrai » terminal). Expect lui peut le faire.

Deuxième avantage d’expect, il existe un langage de script qui permet d’automatiser relativement facilement vos actions avec des structures conditionnelles de base. J’ai rédigé un script qui m’a permis de copier des fichiers sur un liste de triplet de type _hostname;username_;_password_;.

Je l’ai [mis à disposition sur Github][2] et voici comment cela fonctionne.

Dans cet exemple je modifie le fichier repository yum sur un (seul) serveur distant et je nettoie le cache de yum.

```
./expect.us scp serveur_distant root votremotdepasseenclair source/newrepo_el7.1.repo /etc/yum.repos.d/newrepo_el7.1.repo
./expect.us ssh serveur_distant root votremotdepasseenclair "yum clean all"
```


Et dans cet exemple, le met à jour le fichier resolv.conf sur une liste de serveur avec un csv

```
#!/bin/bash
for line in `cat expect_dns_no_nm.csv`
do
hostname=`echo $line | cut -d";" -f1`
username=`echo $line | cut -d";" -f2`
password=`echo $line | cut -d";" -f3`

./expect.us ssh $hostname $username $password "cp /etc/resolv.conf /etc/resolv.conf.20151103"
./expect.us scp $hostname $username $password source/resolv.conf /etc/resolv.conf
done
```


## Le mot de la fin

Entre le moment où j’ai écris le script et aujourd’hui où j’écris cet article (oui j’ai toujours du retard), j’ai découvert Ansible. Quand j’écrivais expect.us je savais que je réinventais la roue.

> Depuis que j’utilise Ansible mon travail au quotidien a complètement changé.

**Dans le cas où vous souhaitez automatiser des tâches et que vous êtes pressés par le temps, allez absolument voir Ansible.**

 [2]: https://github.com/zwindler/expect.us
