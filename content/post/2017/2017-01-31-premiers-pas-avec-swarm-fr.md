---
title: '[Tutoriel] Premiers pas avec Swarm (FR)'
authors:
  - zwindler
type: post
date: 2017-01-31T13:00:42+00:00
url: /2017/01/31/premiers-pas-avec-swarm-fr/
image: /2017/01/docker-swarm.png
categories:
  - Virtualisation
tags:
  - Docker
  - docker service
  - Dockerhub
  - offline
  - registry
  - stateful
  - stateless
  - Swarm

---
## Pourquoi Docker Swarm ?

Docker Swarm est une fonctionnalité d’orchestration de clusters Docker initialement développée à part et finalement intégrée à la version 1.12 du moteur Docker. Il est donc nécessaire d’avoir a minima cette version pour pouvoir utiliser Swarm tel que je le présente dans cet article. En effet, dans les versions précédentes, l’installation était beaucoup plus complexe.

Swarm un orchestrateur de containers Docker relativement « simple ». On va donc pouvoir disposer d’un cluster de machines sur lesquelles seront répartis automatiquement les containers.  
A noter cependant, la gestion de la persistance entre nœuds n’est pas inclus dans la fonctionnalité Swarm elle même, qui doit être implémenté à part (via des volumes distribués). 

Swarm convient parfaitement aux contextes _stateless_, c’est à dire sans données stockées par le container, mais est moins adapté dans les contextes où la personnalisation des services et la gestion de la persistance (base de données) est importante. Si vous voulez un retour un peu plus argumenté que le mien sur la question, voilà notamment [l’avis de l’équipe MySQL sur la question (lien mort, j'utilise Internet Archive)](https://web.archive.org/web/20171221105814/http://mysqlrelease.com/2016/08/trying-out-mysql-in-docker-swarm-mode/).

Cet article a été rédigé en suivant le tutoriel officiel disponible [ici](https://docs.docker.com/engine/swarm/swarm-tutorial/) et adapté pour aller un peu plus loin (notamment en ajoutant un registry local pour permettre aux machines coupées d’Internet de fonctionner).

## Prérequis

### Serveurs

Dans ce tutoriel, je pars du principe que vous disposez de deux nœuds Docker sur lesquels vous avec installé l’OS RHEL 7.2 (ou CentOS). Je me référerai à ces deux nœuds sous les noms suivants :

* pocdocker01
* pocdocker02

J’ai également ajouté un serveur de configuration management (Ansible dans mon cas) avec un repository RPM local et sur lequel nous ajouterons le _registry Docker_. Ce serveur n’est pas obligatoire à proprement parler mais je l’avais sous la main et c’est la seule machine qui a accès à Internet. Cette machine aura pour nom « infra01 ».

### Préparation des machines

Depuis infra01, je récupère le dépôt RPM du projet Docker car par défaut RHEL 7.2 embarque une version antérieure de Docker (la 1.10 je crois).

```
cd /etc/yum.repos.d/
tee /etc/yum.repos.d/docker.repo <<-'EOF'
	> [dockerrepo]
	> name=Docker Repository
	> baseurl=https://yum.dockerproject.org/repo/main/centos/7/
	> enabled=1
	> gpgcheck=1
	> gpgkey=https://yum.dockerproject.org/gpg
	> EOF
	[dockerrepo]
	name=Docker Repository
	baseurl=https://yum.dockerproject.org/repo/main/centos/7/
	enabled=1
	gpgcheck=1
	gpgkey=https://yum.dockerproject.org/gpg
```


Je met ensuite à jour mon dépôt local de RPM (zwindlerrepo)

```
cd /share/zwindlerrepo
yumdownloader docker-engine

createrepo --update .
```


Si vous ne savez pas utiliser createrepo et yumdownloader, je vous invite à aller sur le [site des Howtos de CentOS][2] qui résume plutôt bien le concept.

Depuis infra01, je me connecte sur les deux serveurs pocdocker01 et 02 pour déposer la clé de mon serveur de configuration management, puis j’éxecute 2 playbooks (un pour configurer les dépôts locaux, l’autre pour installer Docker).

```
ssh-copy-id root@pocdocker01 #idem pour le 02

#Configuration par défaut repositories, ntp, supervision, firewall, SELinux
ansible-playbook -l pocdocker* /etc/ansible/zwindler_rhel.yml 

ansible-playbook -l pocdocker* /etc/ansible/zwindler_docker_linux.yml
	
cat zwindler_docker_linux.yml
	---
	# Playbook pour noeud Docker sous RHEL
	- name: "Docker RHEL node"
	  hosts: docker_rhel_nodes
	  roles:
	     - docker_linux

cat roles/docker_linux/tasks/main.yml
	---
	- name: insecure registry - temporary mesure until registry is TLS secured
	  lineinfile:
	    state: present
	    create: yes
	    dest: /etc/docker/daemon.json
	    line: '{ "insecure-registries":["infra01.zwindler.fr:5000"] }'
	
	- name: install docker engine
	  yum: name={{ item }} state=latest
	  with_items:
	    - docker-engine
	
	- name: start and enable docker engine
	  systemd: name=docker state=started enabled=yes
```


### Création d’un registry Docker sur infra01

Les nœuds pocdocker01 et 02 n’ayant pas accès à Internet, on utilisera le registry sur infra01. Pour cela, le plus simple est de récupérer l’image officielle sur le Dockerhub.

```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```


Pour les besoins du tutoriel, je récupère l’image alpine par défaut, puis la « push » sur mon registry interne.

```
docker pull alpine
docker images
	REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
	registry                2                   182810e6ba8c        15 hours ago        37.6 MB
	alpine                  latest              0766572b4bac        18 hours ago        4.799 MB
	zwindler/xwiki-tomcat   8.4.1               d4a1b1df7349        4 weeks ago         661.2 MB
	tomcat                  8-jre8              b3e4bba2bff8        5 weeks ago         334.9 MB
docker tag 0766572b4bac infra01.zwindler.fr:5000/alpine
docker push infra01.zwindler.fr:5000/alpine
```


A partir de là, nous avons donc tous nos prérequis pour créer et utiliser notre cluster Docker Swarm (coupé d’Internet).

## Mise en place du cluster

### Création du cluster

Dans la topology Swarm, il existe des nœuds **managers** et des **workers**. A noter, les commandes liées à Swarm ne peuvent être effectuées que sur les nœuds **managers**.

Depuis pocdocker01 (manager), on créé le cluster en une simple commande :

```
docker swarm init --advertise-addr 10.0.0.10
	Swarm initialized: current node (6zzehbr4ulsld8ofxe09h3djz) is now a manager.
	
	To add a worker to this swarm, run the following command:
	    docker swarm join \
	    --token SWMTKN-1-aaaaaaaaaeaxirr7ldxr3ucv4z0q1soddszao7b46ywz9q90-8ofnnub6kl7r39zmophu6qqq7 \
	    10.0.0.10:2377
	
	To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```


### Intégration du 2ème noeud

Depuis pocdocker02 (worker), on rejoint le cluster en copiant collant le résultat de la commande précédente réalisée sur le manager.

```
docker swarm join --token SWMTKN-1-5nufexjdjh6eaxirr7ldxr3ucv4z0q1soddszao7b46ywz9q90-8ofnnub6kl7r39zmophu6qqq7 10.0.0.10:2377
This node joined a swarm as a worker.
```


### Vérification de l’état du cluster

Depuis pocdocker01 (manager), on peut vérifier l’état du cluster avec les commandes suivantes :

```
docker info
	[…]
	Swarm: active
	 NodeID: 6zzehbr4ulslaaaaae09h3djz
	 Is Manager: true
	 ClusterID: 7a4lauts8xaaaaaa190tu4jf
	 Managers: 1
	 Nodes: 2
	[…]

docker node ls
	ID                           HOSTNAME                        STATUS  AVAILABILITY  MANAGER STATUS
	6zzehbr4ulsld8ofxe09h3djz *  pocdocker01.zwindler.fr  Ready   Active        Leader
	a7demo2k14obqp66gbxfsm7er    pocdocker02.zwindler.fr  Ready   Active
```


## Création d’un service orchestré par Docker

Dans un cluster Swarm, la notion de « service » a été ajoutée. Ce nom englobe un peu plus que le simple container, puisque nous avons également des notions de scaling, ...

Toutes les commandes relative à la création de services sont donc débutée par l’instruction « docker service ... », et je le rappelle, lancées depuis le manager, qui est le seul à pouvoir avoir les gérer.

### Création d’un service

Dans cet exemple simple, on va créer un « service » qui ne contente de récupérer notre container alpine disponible sur le registry interne et pinguer indéfiniment docker.com. Puis ensuite, on vérifiera que tout s’est bien passé avec la commande « docker service ls », l’équivalent du « docker ps » pour les services.

```
docker service create --replicas 1 --name helloworld infra01.zwindler.fr:5000/alpine ping docker.com
docker service ls
ID            NAME        REPLICAS  IMAGE                                   COMMAND
26krds5pwpqs  helloworld  1/1       infra01.zwindler.fr:5000/alpine  ping docker.com
```


On peut également avoir un peu plus de précision sur le service en cours avec la commande « docker service inspect ».

```
docker service inspect --pretty helloworld
	ID:             21e1ync4fjafudd4e7kzrurag
	Name:           helloworld
	Mode:           Replicated
	 Replicas:      1
	Placement:
	UpdateConfig:
	 Parallelism:   1
	 On failure:    pause
	ContainerSpec:
	 Image:         alpine
	 Args:          ping docker.com
	Resources:
```


### Scaling de l’application

Admettons que vous souhaitiez faire plus de pings simultanés sur le site de docker pour une raison ou pour une autre (ce qui je le concède volontiers n’est que modérément utile), vous pouvez très simplement faire un « up-scaling » de vos containers avec la commande « docker service scale ». 

```
docker service scale helloworld=5
	helloworld scaled to 5
	docker service ps helloworld
		ID                         NAME          IMAGE   NODE                            DESIRED STATE  CURRENT STATE             ERROR
		dn46s9z7zcet9iol79ej7e3h3  helloworld.1  alpine  pocdocker01.zwindler.fr  Running        Running 2 minutes ago
		1gme311su7osbz7m92hsv5vc3  helloworld.2  alpine  pocdocker02.zwindler.fr  Running        Preparing 21 seconds ago
		ew7o5gsszm6585moxf672inlb  helloworld.3  alpine  pocdocker02.zwindler.fr  Running        Preparing 21 seconds ago
		cwifuygmvlw44pit740n7z50q  helloworld.4  alpine  pocdocker01.zwindler.fr  Running        Running 19 seconds ago
		bidm8wth2tuxo25z261h87yy4  helloworld.5  alpine  pocdocker01.zwindler.fr  Running        Running 19 seconds ago
```


Simplissime !

### Désactivation des capacités du noeud 2

Pour vérifier que notre cluster fonctionne bien ou tout simplement réaliser une maintenance sur un des noeuds en fonctionnement nominal, il est possible de peut passer un noeud hors ligne. 

Les répliquas du services sont alors démarrés sur les nœuds encore disponibles.

```
docker node update --availability drain pocdocker02.zwindler.fr
docker service ps helloworld
	ID                         NAME              IMAGE                                   NODE                            DESIRED STATE  CURRENT STATE               ERROR
	92c4tbremj6iq7h65brs8u42l  helloworld.1      infra01.zwindler.fr:5000/alpine  pocdocker01.zwindler.fr  Running        Running about a minute ago
	18lwc3j7r1t3uqeij0g0qm701  helloworld.2      infra01.zwindler.fr:5000/alpine  pocdocker01.zwindler.fr  Running        Running 17 seconds ago
	9iozodo4q7be4klmib5znh9e0   \_ helloworld.2  infra01.zwindler.fr:5000/alpine  pocdocker02.zwindler.fr  Shutdown       Shutdown 18 seconds ago
	6dad19g5m6zd9b7wd9sczs10c  helloworld.3      infra01.zwindler.fr:5000/alpine  pocdocker01.zwindler.fr  Running        Running 17 seconds ago
	3autcjlnqfe4v6x2gsoov5853   \_ helloworld.3  infra01.zwindler.fr:5000/alpine  pocdocker02.zwindler.fr  Shutdown       Shutdown 18 seconds ago
	033idvu5mbo89q05p32nytpg9  helloworld.4      infra01.zwindler.fr:5000/alpine  pocdocker01.zwindler.fr  Running        Running about a minute ago
	53x5kbx0su09w2b639hnpcj8v  helloworld.5      infra01.zwindler.fr:5000/alpine  pocdocker01.zwindler.fr  Running        Running about a minute ago
```


### Réactivation des capacités du nœud 2

Et on peut bien entendu revenir en arrière :

```
docker node update --availability active pocdocker02.zwindler.fr
```


### Suppression du service

Et comme je suis sympa, je vous donne la commande pour nettoyer tout ça car je ne pense pas que Docker.com ait besoin que vous le pinguier _ad vitam æternam_.

```
docker service rm helloworld
```


## Conclusion

Dans cet article, j’ai essayer de vous montrer à quel point il est simple d’utiliser la fonctionnalité d’orchestration de containers Swarm. Et ça n’a pas toujours été au si simple comme le reconnaissent eux même les gens de Docker :  
![](/2017/01/docker_swarm_before1.12.jpg)

On peut ainsi gérer sur plusieurs machines un ensemble de containers sans se demander où les déposer. Les communications inter-hôtes sont également simplifiée avec l’ajout d’overlay-network qui monte des tunnels VPN entre réseaux virtuels de vos containers. Et enfin, vous pouvez simplement ajouter de nouvelles instances à votre service à la hausse ou à la baisse d’une simple commande.

Et c’est là un des avantages majeurs de l’orchestration de containers. Au delà de la simple création d’un cluster, on peut adapter en fonction du besoin le nombre de processus en frontend/backend d’une application, pour peut que ce processus soit :

  * capable de traiter de manière distribuée les requêtes
  * n’ait pas besoin d’être différencié car tous les containers d’un même service sont strictement identiques

C’est probablement **la** difficulté pour les applications « classiques ».  
A date, il existe encore beaucoup de workloads qui ne sont pas parallélisables et/ou qui nécessitent d’être différenciés. Je pense notamment aux bases de données ou aux applications web qui stockent des fichiers ou des informations de session en interne, qui auront besoin de composants externes supplémentaires pour fonctionner correctement sur ce type d’architectures pour pourvoir être « up-scalés ».

 [2]: https://wiki.centos.org/HowTos/CreateLocalRepos
