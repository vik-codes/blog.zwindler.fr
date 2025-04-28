---
title: Répartir les queues équitablement entre vos nœuds RabbitMQ
authors:
  - zwindler
type: post
date: 2018-04-04T17:00:02+00:00
url: /2018/04/04/plugin-queue-master-balancer/
image: /2018/04/rabbitmq_master_relocate.png
categories:
  - Cluster
  - Logiciel
tags:
  - ActiveMQ
  - AMQP
  - erlang
  - master
  - plugin
  - queue
  - Rabbit
  - RabbitMQ
  - relocate

---
## RabbitMQ quoi?

Je vais être honnête, il y a 2 mois je ne connaissais pas grand chose aux messages brokers. Et depuis j’ai découvert RabbitMQ.

> Messaging that just works

Quoi de mieux pour mettre le pied à l’étriller que ce genre de logiciel qui vous explique d’emblée que ça va être simple ? Bon en réalité ça n’a pas été si simple que ça ;-)

RabbitMQ est un message broker open source écrit en erlang (er-quoi ?? oui, moi non plus...). Il est développé par les équipes Pivotal, qui a repris le projet en mai 2013.

![](/2018/04/rabbitmq_by_pivotal.png)

C’est donc une sorte de bus central de communication pour faire transiter des messages d’applications vers applications ([1:n]-to-[1:n]) sans qu’elles se parlent en direct. C’est particulièrement pratique dans le cas de microservices dont on veut découpler et donc sécuriser les échanges (plutôt que de faire du HTTP en best effort).

## Pourquoi RabbitMQ ?

L’avantage vraiment mis en avant par RabbitMQ, c’est qu’il est simple. Mais il est aussi puissant et relativement complet.

Il a l’avantage de supporter plusieurs protocoles (ce que les messages broker ne font pas tous), d’apporter une couche d’abstraction utile avec la notion d’**exchange** et de permettre sans effort la création du clusters via une simple ligne de commandes. J’aurai probablement l’occasion de revenir sur les « clusters » de RabbitMQ (notez les guillemets).

![](/2018/04/hello-world-example-routing.png)

> Source : Tutoriel helloworld de RabbitMQ // https://www.rabbitmq.com/tutorials/amqp-concepts.html

Au delà de ça, je ne vais pas vous insister, car d’une part la documentation est plutôt bien faite et comporte plusieurs tutoriels bien sympa, et d’autre part, j’ai vu passer d’autres tutos sur les réseaux récemment. Je vous colle quelques liens sympa pour commencer :

  * [Le site officiel][3]
  * [La documentation du site officiel][4]
  * [Les tutos en plein de langages pour commencer à bidouiller][5]
  * [Les bases de RabbitMQ sur eleven-labs][6]

## Racontes nous une histoire

Pour simplifier notre vie, le cluster agit de telle sorte que tous les objets logiques (utilisateur, queue, exchange), où qu’ils soient, sont connus et _adressables_ depuis tous les membres du cluster. Cependant, une notion importante à comprendre quand on parle de cluster sur RabbitMQ est qu’à un moment donné, **une** **_queue_** **n’est physiquement présente que sur un serveur**, même en cluster.

J’explique : si on adresse une requête au serveur B pour la queue/file 1 qui est sur le serveur A, celui ci redirigera gentiment la requête vers le serveur 1.

![](/2018/04/RabbitMQ_cluster_redirect.png)

Pour l’utilisateur / développeur, ça sera transparent, mais pour le sysadmin c’est une autre paire de manches.

Supposons que pour une raison ou pour une autre, **toutes** les queues soient hébergées sur un même nœud. Dans ce cas là, toute la charge sera portée par ce serveur et les autres ne feront que passe plat.

## Dans quels cas ça arrive ?

Alors vous allez me dire : _pfff ya aucune raison que toutes les queues soient sur le même nœud..._

Et ben si, yen a même plusieurs ;-)

Sans vous spoiler un article futur, on peut très rapidement se retrouver avec ce genre de blague lorsqu’on met à jour les serveurs du cluster uns par uns, jusqu’à ce que le dernier serveur se retrouve à supporter l’ensemble de la charge.

Et là, vous êtes bien embêtés, car vous n’avez pas de moyen de transférer les queues sur plusieurs autres serveurs. On peut toujours les supprimer puis les recréer une par une sur des serveurs distincts, mais niveau répartition de charge, on a vu mieux...

## Et alors comment on fait ?

Il est possible d’indiquer à RabbitMQ qu’il doit **répliquer** certaines queues sur un nœud en particulier, puis, une fois le contenu de la queue synchronisée, de retirer le serveur initial de la liste des nœuds de cette queue.

![](/2018/04/RabbitMQ_move_master.png)

Je vous sens encore sceptiques. « On est pas plus avancés » me direz vous ?

En effet, il faut encore prendre les queues unes par unes et les déplacer sur un autre nœud puis les supprimer du nœud initial. Oui, sauf que les développeurs de RabbitMQ, conscients du problème, ont créés un plugin pour automatiser tout ça. On en arrive à l’objet de cet article : **rabbitmq-queue-master-balancer**

> RabbitMQ Queue Master Balancer is a tool used for attaining queue master equilibrium across a RabbitMQ cluster installation. The plugin achieves this by computing queue master counts on nodes and engaging in shuffling procedures, with the ultimate goal of evenly distributing `queue masters` across RabbitMQ cluster nodes.

Traduction : ça permet de répartir nos queues de manière à peu près équitable entre les nœuds (en partant du principe _généralement erroné_ que la charge est proportionnelle au nombre de queues hébergées par le nœud).

## Installation

RabbitMQ, en plus de tout ce qu’on a dit de chouette à son propos, permet aussi d’être étendu à l’aide de plugins. On peut aller télécharger celui qui nous intéresse sur Github.

```
wget https://github.com/Ayanda-D/rabbitmq-queue-master-balancer/releases/download/v0.0.3/rabbitmq_queue_master_balancer-0.0.3.ez
```


Point qui n’est pas forcément mis en avant dans le projet **rabbitmq\_queue\_master_balancer**, les plugins peuvent être déposés dans 2 dossiers différents. Un commun à toutes nos versions, et un qui change à chaque mise à jour.

  * **/usr/lib/rabbitmq/plugins**
  * **/usr/lib/rabbitmq/lib/rabbitmq_server-[version]/plugins/**

Vous trouverez plus d’information sur les plugins RabbitMQ et leur fonctionnement au niveau de [la page dédiée à leur sujet][9].

Dans notre cas, le plugin n’est pas dépendant de votre version. On créé donc le dossier pour le contenir, puis on l’y dépose.

```
sudo  mkdir /usr/lib/rabbitmq/plugins
sudo mv rabbitmq_queue_master_balancer-0.0.3.ez /usr/lib/rabbitmq/plugins/
```

Comme n’importe quel autre plugin « built-in », on peut maintenant l’activer depuis la ligne de commande habituelle **rabbitmq-plugins**

```
sudo rabbitmq-plugins enable rabbitmq_queue_master_balancer
```

## Utilisation

Voici maintenant un exemple d’utilisation qui va vous permettre de vous familiariser avec l’outil. Tout se passe en ligne de commandes (c’est un peu spartiate). On va demander à **rabbitmqctl** d’exécuter des fonctions provenant de notre plugins.

On commence par afficher la répartition actuelle dans notre cluster avec la fonction **report()**

```
sudo rabbitmqctl eval 'rabbit_queue_master_balancer:report().'
{ok,[{'rabbit@rabbitmq2',{queues,0}},
     {'rabbit@rabbitmq3',{queues,30}},
     {'rabbit@rabbitmq1',{queues,0}}]}
```

Ici, on voit que toutes les queues se sont retrouvées sur le rabbitmq3 suite à un rolling upgrade.

![](/2018/01/truestory.jpg)

On lance donc le processus de répartition des queues avec la fonction **go()**

```
sudo rabbitmqctl eval 'rabbit_queue_master_balancer:go().'
ok
```

A partir de là, si vous êtes simultanément connecté sur votre console web d’administration de RabbitMQ, vous verrez en live qu’il s’y passe des choses. En ligne de commande, vous pourrez aussi voir où ça en est avec la fonction **status()**

```
sudo rabbitmqctl eval 'rabbit_queue_master_balancer:status().'
[{process_id,<9157.8313.0>},
 {queues_pending_balance,18},
 {memory_utilization,284640}]
```

Ici il reste encore 18 queues à re-répartir. Au final, tout devrait rentrer dans l’ordre :

```
sudo rabbitmqctl eval 'rabbit_queue_master_balancer:report().'
{ok,[{'rabbit@rabbitmq2',{queues,10}},
     {'rabbit@rabbitmq3',{queues,9}},
     {'rabbit@rabbitmq1',{queues,11}}]}
```

Les plus tatillons d’entre vous auront sûrement remarqué que nous n’avons pas eu une répartition parfaite de nos 30 queues (10*3). Ceci est voulu, pour une raison de _formule mathématique obscure_, explicitée sur le dépôt Github du plugin :

![](/2018/04/queue_equilibrium.png)

> https://github.com/Ayanda-D/rabbitmq-queue-master-balancer

## Et tu voudrais pas faire un playbook Ansible pour ça ?

Ahah la bonne blague. _**BIEN SUR**_ que j’en ai fais un playbook Ansible ([parce que je suis fan d’Ansible](/recherche/?keyword=ansible)).

```
---
- hosts: all
  vars:
    - queue_master_balancer_version: "0.0.3"
  tasks:
    - name: "Create /usr/lib/rabbitmq/plugins directory for queue balancer plugin"
      file:
        path: /usr/lib/rabbitmq/plugins
        state: directory
        mode: 0755
    - name: "Download rabbitmq-queue-master-balancer plugin"
      get_url:
        url: "https://github.com/Ayanda-D/rabbitmq-queue-master-balancer/releases/download/v{{queue_master_balancer_version}}/rabbitmq_queue_master_balancer-{{queue_master_balancer_version}}.ez"
        dest: "/usr/lib/rabbitmq/plugins/rabbitmq_queue_master_balancer-{{queue_master_balancer_version}}.ez"
    - name: "Add rabbitmq_queue_master_balancer to the list of enabled plugins"
      rabbitmq_plugin:
        names: rabbitmq_queue_master_balancer
        new_only: yes
        state: enabled
```


A noter, j’utilise l’option **new_only** du module **rabbitmq_plugin** pour éviter de désactiver bêtement les plugins déjà actifs.

Protip gratuite ;) ça serait balo de désactiver tout le reste.

 [3]: https://www.rabbitmq.com/
 [4]: https://www.rabbitmq.com/documentation.html
 [5]: https://www.rabbitmq.com/getstarted.html
 [6]: https://blog.eleven-labs.com/fr/rabbitmq-partie-1-les-bases/
 [9]: https://www.rabbitmq.com/installing-plugins.html
