---
title: 'Harbor : la docker registry d’entreprise open source de VMware – part 1'
authors:
  - zwindler
type: post
date: 2018-02-27T12:45:35+00:00
url: /2018/02/27/harbor-la-docker-registry-dentreprise-open-source-de-vmware-part-1/
image: /2018/02/harbor.png
categories:
  - Logiciel
  - Système
  - Virtualisation
tags:
  - Docker
  - github
  - OSS
  - registry
  - VMware

---
## Harbor ?

Rien à voir avec l’île dans le Pacifique ou l’accord entre les Etats Unis et l’Union Européenne dans les années 90. Le Harbor dont je vais vous parler, c’est la registry Docker d’entreprise et Open Source de VMware !

![](/2017/10/harbor.png)

Harbor est un des produits open sourcé par VMware. C’est un serveur permettant de stocker « on premise » ou dans le cloud des images Docker, au même titre que le produit historiquement appelé Docker Registry (maintenant _Docker Distribution_), mais avec des fonctionnalités supplémentaires, notamment :

  * Gestion de la sécurités, des comptes, rôles, habilitation (RBAC)
  * Réplication des images entre plusieurs instances de Harbor
  * Portail web
  * Logging de toutes les opérations à des fins d’audit
  * API RESTful
  * Scan de vulnérabilité intégré
  * Nettoyage automatique des images inutiles (garbage collection)
  * Intégration native avec Notary pour la signature des images

> Rien que ça ;)

Pour ceux que ça intéressent et qui ne savaient pas (comme moi) que VMware met à disposition des logiciels open source, les autres sont disponibles [sur la page Github de VMware][2].

## Petite étude du marché

Je ne vais pas vous faire une analyse poussée du marché de la registry privée, mais si jamais vous cherchez des produits similaires, vous pouvez aller jeter un œil aux produits suivants qui ont attirés mon attention :

  * [Docker Trusted Registry (version entreprise de Docker Distribution)][3]
  * [Gitlab Container Registry, fortement intégré à Gitlab CI][4]
  * [Artifactory supporte maintenant les containers][5]
  * [Quay de CoreOS, Inc.][6] (maintenant racheté par Redhat)

Et je vous met aussi quelques articles sympas qui parlent de ces différentes solutions :

* [blog.wercker.com/ultimate-guide-to-container-registries (lien mort, racheté et tué par Oracle, retrouvé sur Internet Archive)](https://web.archive.org/web/20180320225423/http://blog.wercker.com/ultimate-guide-to-container-registries)
* [rancher.com/container-registries-might-missed/](http://rancher.com/container-registries-might-missed/)
* [blog.codeship.com/overview-of-docker-registries/](https://blog.codeship.com/overview-of-docker-registries/)

## Méthode choisie

Ok ! Maintenant qu’on connaît un peu l’écosystème, on peut s’attaquer à la bête. Il existe plusieurs méthodes pour installer Harbor sur une infrastructure « on premise » :

  * Installer Harbor sur un serveur Docker via 
      * l’installeur « online » (qui télécharge les images nécessaires sur Dockerhub)
      * l’installeur « offline » (qui dispose déjà des images nécessaires)
  * Déployer une VM VMware via un OVA VIC (VMware vSphere Integated Containers) qui contient _entre autre_ un serveur Harbor préinstallé et préconfiguré
  * Déployer Harbor directement sur un cluster Kubernetes via YAML (option communautaire)

Les releases [sont disponibles depuis la page « release » sur le dépôt Github][7]. [L’OVA est lui disponible sur myvmware (lien mort, comme tout chez VMware, j'utilise Internet Archive)](https://web.archive.org/web/20240410013515/https://customerconnect.vmware.com/en/downloads/#all_products), le site de téléchargement habituel de VMware.

Dans le cadre de cette article, la méthode d’installation que j’ai choisie est l’installation via les sources en mode « offline » car il m’arrive souvent dans les datacenters de ne pas avoir accès à Internet facilement (pour des raisons de sécurité).

## Récupération des sources

Depuis un poste qui a accès à Internet, on va donc télécharger l’ensemble des fichiers dont nous aurons besoins : le fichier d’installation ainsi que sa signature md5.

```
curl -L https://github.com/vmware/harbor/releases/download/v1.2.0/harbor-offline-installer-v1.2.0.md5.txt -o harbor-offline-installer-v1.2.0.md5.txt
curl -L https://github.com/vmware/harbor/releases/download/v1.2.0/harbor-offline-installer-v1.2.0.tgz -o harbor-offline-installer-v1.2.0.tgz
```


C’est super d’avoir mis un fichier MD5... mais la comparaison avec la signature ne peut pas être faite telle quelle car un fichier de signature MD5 « valide » doit avoir le nom du fichier indiqué APRÈS la signature en elle même. Ce n’est pas le cas dans le fichier mis à disposition par VMware.

```
cat harbor-offline-installer-v1.2.0.md5.txt
    235fcfb9fe00ad61f6cbc2de4920b477
#Un fichier MD5 valide doit contenir "235fcfb9fe00ad61f6cbc2de4920b477 harbor-offline-installer-v1.2.0.tgz"
```


Pour pouvoir le comparer sous Linux avec md5sum, on doit recréer un fichier correct avec la commande suivante :

```
file="harbor-offline-installer-v1.2.0"
md5sum -c <(echo $(<${file}.md5.txt) ${file}.tgz)
    harbor-offline-installer-v1.2.0.tgz: Réussi
```


Source : [Most practical way to compare MD5 checksums sur StackExchange][9]

## Installation des prérequis

La documentation d’installation officielle nous indique les dépendances suivantes :

  * python 2.7+
  * docker 1.10+
  * docker-compose 1.6+

Depuis un serveur qui a accès à Internet, on va donc récupérer les sources de Docker compose

```
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```


Vous ne trouvez pas que ça commence à être un peu relou toutes ces étapes ?

Vous le voyez venir ? Quoi donc ?

Et bien le playbook Ansible pardi !! Pour faciliter cette installation, j’ai écris des rôles Ansible pour automatiser ça ;-)

Pourquoi ? [Parce que je kiffe Ansible](/recherche/?keyword=ansible).

## Ansible à la rescousse

[Tout est sur mon Github][11], sauf docker compose et l’installeur d’Harbor évidemment (que vous aurez récupéré lors des étapes précédentes)

```
cd /etc/ansible
git clone https://github.com/zwindler/ansible-deploy-harbor
cp /usr/local/bin/docker-compose /etc/ansible/roles/prereqs_harbor/files
cp harbor-offline-installer-v1.2.0.tgz /etc/ansible/roles/install_harbor/files
```


Et si vous voulez un coup d’œil rapide au fichier principal qui appelle les rôles, voici ce qu’il contient (et les variables qu’il convient de renseigner) :

```
cat deploy_harbor.yml
---
# Playbook pour installer Harbor
- name: "Install harbor prerequisites"
  hosts: zwindler_linux
  vars_prompt:
    - name: "db_password"
      prompt: "Harbor Database Password"
      default: "HarborPassword"
    - name: "clair_db_password"
      promt: "ClairDB password"
      default: "HarborPassword"
    - name: "harbor_admin_password"
      promt: "Harbor Admin password"
      default: "HarborPassword"
  vars:
    - add_notary: false
    - use_https : true
    - generate_ssl: true
    - harbor_install_path : "/usr/local/"

  roles:
     - prereqs_harbor
     - install_harbor
```


Dans le cas où l’on ne souhaite pas utiliser Notary, la configuration d’Harbor est plus simple et la configuration se fait en HTTP simple. Il est nécessaire de modifier la variable **add_notary** à **False** dans le playbook dans ce cas particulier.

Dans le cas où l’on souhaite utiliser Notary, il est obligatoire de passer en HTTPS et d’avoir un certificat. Si tel est le cas, vous l’avez compris, il faut laisser le paramètre **add_notary** à **True** ce qui permettra de gérer ce cas particulier. Pour être honnête, je n’ai pas testé la partie Notary, je ne peux donc pas certifier à 100% que cette partie fonctionne convenablement.

Enfin, le script Ansible peut générer un certificat autosigné en laissant la variable **generate_ssl** à **True**. Il est aussi possible [d’en générer un à la main en suivant la documentation sur le site de Harbor][12]. Auquel cas il ne faudra pas oublier de passer le paramètre **generate_ssl** à **False**.

## Configuration

Le playbook déploie Harbor avec une authentification login/mdp stockés dans une base de données interne. Pour tester, c’est pas mal mais évidemment, dans un second temps, il sera opportun de déporter cette authentification à une source de type LDAP ou Active Directory par exemple.

La première connexion se fait donc avec le login admin et le mot de passe tel que défini lors du déploiement du playbook.

Une fois connecté, le portail permet d’explorer les projets et de réaliser les configurations complémentaires, telle que la création d’utilisateurs (si on est en mode de stockage « base de données »), la gestion des habilitations, ou la réplication des registries entre elles.

![](/2017/10/harbor01.png)

## Configurer un client

Comme le playbook est très bien fait (enfin normalement, hahaha), tout s’est bien passé et on peut maintenant configurer son poste client pour qu’il s’authentifie sur la Registry et commence à pousser/tirer des images Docker.

Si vous êtes en HTTPS, vous aurez besoin sur le poste client du CA autosigné généré lors du déploiement d’Harbor, car la registry est du coup sécurisée. Il devrait être disponible dans **/etc/ssl/ca/** et dans **/etc/docker/certs.d/[hostname\_de\_la_registry]/** et doit être déposé dans **/etc/docker/certs.d/** du _client_ depuis lequel on souhaite se connecter :

```
scp /etc/docker/certs.d/ca.crt [machine_cliente]:/etc/docker/certs.d/[hostname_de_la_registry]/
```


Une fois fait, on peut tenter de se connecter sur la registry avec la commande suivante :

```
REGISTRY=[hostname_de_la_registry]

docker login https://$REGISTRY
    Username: admin
    Password:
    Login Succeeded
```


> Tadam !

## Et la suite ?

Et ben c’est déjà pas mal pour un premier article sur Harbor, non ? Vous venez, sans effort, de déployer une registry privée d’entreprise pour vos images Docker ;-)

Mais comme vous l’avez sûrement vu dans le titre, ce n’est que la partie 1. J’ai encore plein de choses à vous raconter sur Harbor. La suite au prochain épisode !

 [2]: https://vmware.github.io/
 [3]: https://docs.docker.com/datacenter/dtr/2.3/guides/
 [4]: https://docs.gitlab.com/ee/user/packages/container_registry/
 [5]: https://www.jfrog.com/artifactory/
 [6]: https://quay.io/plans/?tab=enterprise
 [7]: https://github.com/vmware/harbor/releases
 [9]: https://unix.stackexchange.com/questions/322286/most-practical-way-to-compare-md5-checksums
 [11]: https://github.com/zwindler/ansible-deploy-harbor
 [12]: https://github.com/goharbor/harbor
