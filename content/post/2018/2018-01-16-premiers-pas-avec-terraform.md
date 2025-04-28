---
title: Premiers pas avec Terraform
authors:
  - zwindler
type: post
date: 2018-01-16T12:45:42+00:00
url: /2018/01/16/premiers-pas-avec-terraform/
image: /2017/11/terraform.png
categories:
  - Script
  - Système
  - Virtualisation
tags:
  - Cloud
  - consul
  - etcd
  - hashicorp
  - terraform

---
## Terraform ?

Si vous avec passé un peu de temps sur Twitter, LinkedIn ou dans n’importe quel conf un peu orientée DevOps, vous ne pouvez pas avoir loupé [Terraform][1].

Terraform est un outil d’Infrastructure as Code développé par [Hashicorp][2]. Que le nom de cette entreprise vous dise quelque chose ou pas, vous avez très probablement entendu parlé de **Vagrant** (eh oui c’est eux) et de **Consul** (peut être même de Packer, Vault ou Nomad). Bref, l’entreprise propose un certain nombre d’outils pour faciliter l’exploitation et l’automatisation de ressources, particulièrement dans le cloud.

![](/2018/01/hashicorp_tools.jpg)

## Ok, mais Terraform c’est quoi ?

Des fois le plus simple est de laisser les développeurs en parler d’eux même ;-)

> What is Terraform?  
> Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular service providers as well as custom in-house solutions.

Il y a deux phrases, et les deux sont importantes. En Français :  
- Terraform est un outil pour construire, changer, versionner l’infrastructure de manière sécurisée et efficace (efficiente?).  
- Terraform peut gérer des fournisseurs de services (comprenez cloud plublic) mais aussi des solutions maison sur site (comprenez cloud privé).

### Pourquoi c’est important ?

Comme je le disais un peu plus haut, même s’ils disent le contraire, Terraform est quand même (historiquement) plutôt à destination des cloud providers.

C’est là où Terraform a apporté la plus-value qui a fait sa renommée. Il permet une gestion plus agnostique des ressources et permet de passer facilement d’un cloud à l’autre.

### Et mon cluster VMware/Openstack on-premise alors ?

Heureusement, l’outil s’enrichit de jour en jour et on dispose aujourd’hui de beaucoup de providers au delà des AWS, Azure et GCP et s’ouvre à d’autres usages comme MySQL, Kubernetes, Grafana, ... La liste complète est [disponible sur le site de Hashicorp][4].

Le tutoriel « officiel » est [disponible à l’adresse suivante][5], mais on reste un peu sur sa faim. Et surtout on ne voit pas comment faire du on-premise (ou que vous êtes allergiques à AWS).

## Quelques concepts

Je ne peux pas faire un article sans vous donner un minimum de concepts pour appréhender Terraform. La première chose à savoir est que Terraform utilise un langage de configuration appelé HCL qui lui est propre [HashiCorp Configuration Language][6]. C’est avec ce langage de configuration qu’on va décrire l’infrastructure à construire et _l’état_ dans lequel on souhaite avoir cette infrastructure. Moi qui suis habitué au YAML, dommage...

On va donc devoir décrire un _**provider**_, qui sera notre point d’entrée pour créer/interagir avec l’infrastructure (un login/mdp pour AWS, un serveur vCenter et les logins/mdp privilégiés, etc). Il est très probable qu’on ait plusieurs providers.

Ensuite on pourra commencer à décrire nos _**ressources**_ (tout objet nécessaire pour notre application, que ce soit une VM, un container, un réseau virtuel, une URL dans un loadbalancer, etc).

## Assez de théorie, la pratique !

Pour voir autre chose et mettre un peu plus les mains dans le cambouis, je vous propose donc un petit exemple avec un cluster VMware que vous auriez sous la main.

La première chose à faire est sans surprise de récupérer terraform ([ici](https://www.terraform.io/downloads.html))

### Installer et configurer Terraform

Si vous travaillez sur un Linux, un petit curl et on en parle plus.

```
curl https://releases.hashicorp.com/terraform/0.10.6/terraform_0.10.6_linux_amd64.zip -o terraform_0.10.6_linux_amd64.zip
unzip terraform_0.10.6_linux_amd64.zip
mv terraform /usr/local/bin
```

Sous Windows, le plus simple est de télécharger le binaire, de le déposer dans un dossier de votre disque et d’alimenter le PATH (modifier les variables d’environnement du systèmes)

![](/2018/01/terraform3-640x470.png)

On peut maintenant tester que la commande répond correctement :

![](/2017/10/terraform4.png)

## Mon premier script Terraform

Dans cet exemple, je me base sur le _provider_ vSphere, dont vous retrouvez [la documentation ici][9]. Ce simple script va se connecter à mon vcenter, créer un répertoire test à la racine du cluster, puis créer une VM dans ce répertoire.

```
cat example_vsphere.tf

# Configure the VMware vSphere Provider
  provider "vsphere" {
  user = "root"
  password = "xxxx"
  vsphere_server = "vcenter.zwindler.fr"
  # if you have a self-signed cert
  allow_unverified_ssl = true
}

# Create a folder
resource "vsphere_folder" "test" {
  path = "test"
  datacenter = "VMware zwindler"
}

# Create a virtual machine within the folder
  resource "vsphere_virtual_machine" "test" {
  name = "terraform-test"
  datacenter = "VMware zwindler"
  cluster = "Cluster_VMware"
  folder = "${vsphere_folder.test.path}"
  vcpu = 2
  memory = 4096
  network_interface {
    label = "Virtual Network"
    ipv4_address = "192.168.1.100"
    ipv4_prefix_length = "24"
    ipv4_gateway = "192.168.1.1"
  }
  disk {
    template = "tmpl-rhel-7-3"
    datastore = "VMFS01"
  }
}
```


On récapitule. Le premier objet de base dans terraform est le « provider », qui nous permet de prendre le contrôle du cluster. Les deux autres objets sont les « ressources » qu’on souhaite créer/modifier.

## It’s alive!

La première commande à lancer est **terraform init**, dans le dossier qui contient notre fichier de définition de l’infrastructure. Cela permet d’initialiser le contexte recherché ainsi que des variables. **terraform plan** permet ensuite de faire un essai à blanc des modifications pour s’assurer que tout fonctionnera bien comme attendu (dry run).

```
terraform init
terraform plan
```


![](/2017/10/terraform5.png)

![](/2017/10/terraform6.png)

Et pour finir, on exécute notre plan avec **terraform apply** (création du dossier et génération de la machine virtuelle) :

```
terraform apply
```


A l’issue de ces commandes, une VM devrait être créée dans votre cluster comme spécifiée. Vous remarquerez également la présence dans le même dossier que votre fichier **example_vsphere.tf** un fichier **terraform.state**. Ce fichier **terraform.tfstate** (qui enregistre l’état dans lequel est l’infrastructure) est important et doit être disponible **pour tous les postes/utilisateurs** qui utilisent terraform pour cette infrastructure (sinon ça ne marche pas).

Hashicorp conseille d’utiliser un moyen de _rendre ce fichier disponible à distance_, par exemple avec un serveur **Consul** (de Hashicorp, bien sûr). On peut utiliser **etcd** ou **artifactory** ou même un simple partage mais il y aura des risques d’accès concurrents (il n’y aura pas de locking au niveau Terraform).

> With remote state, Terraform stores the state in a remote store. Terraform supports storing state in Terraform Enterprise, Consul, S3, and more.  
> Remote state is a feature of backends. Configuring and using backends is easy and you can get started with remote state quickly. If you want to migrate back to using local state, backends make that easy as well.

Si vous voulez en savoir plus, [allez lire cette page][12].

## Conclusion

J’ai essayé de faire bref pour vous donner un aperçu très rapide de ce qu’est Terraform et de ce qu’on peut faire avec mais il reste forcément encore beaucoup de choses à dire. Déjà, j’ai résumé à l’extrême la partie théorie et n’ai pratiquement expliqué aucun concept. Ensuite, je n’ai pas beaucoup exploré les limites de Terraform, notamment dans l’utilisation à plusieurs et les manques par rapport à d’autres outils.

Pour ma part j’ai trouvé l’outil intéressant mais je ne peux pas m'empêcher de faire le parallèle avec [Ansible][13], que je maitrise beaucoup mieux.

Que peut faire Terraform que ne peux pas faire [Ansible][13] ? Peut être une meilleure gestion de fournisseurs de services autres que AWS Azure et GCP (Dyn, Datadog ou Mailgun).

A l’inverse, Ansible permet de faire beaucoup _plus_ de choses que Terraform, car c’est un outil bien plus fourni (à date) et surtout plus généraliste, qui sert à la fois à déployer ET à configurer.

Pour autant, je ne m’interdis pas de l’utiliser dans un prochain contexte professionnel qui devrait justement me demander plus d’interaction avec les clouds public.

Have fun !

## [Bonus]Life in graphic, it’s fantastic

Une fonctionnalité sympathique de Terraform est la possibilité offerte de générer un « graphe » de vos ressources et de leurs dépendances les unes aux autres. Certes, dans des cas concrets et complexes c’est peut être un peu gadget, mais l’idée est bonne.

En réalité, c’est même pour cette raison que je me suis intéressé à Terraform. A la base, on m’a demandé de trouver un outil permettant de visualiser une infrastructure complexe. Or celle ci étant changeante car en pleine conception, je n’avais pas envie de repasser 50 fois sur un diagramme de type Visio. J’ai donc cherché une solution pour le faire de manière automatique.

Voilà le genre de résultats que vous pouvez attendre de Terraform :

![](/2017/10/terraform-7-2-graph.png)

> Notre example_vsphere.tf donne ceci en graphe

Pour se faire, installez simplement la bibliothèque **graphviz** et utilisez la commande **terraform graph**.

```
yum install graphviz
terraform graph | dot -Tpng > terraform-graph.png
```


A noter : je n’ai pas trouvé la solution satisfaisante et c’est pour ça que j’ai commencé à développer ma propre bibliothèque Python pour grapher des infrastructures. Quand ça ressemblera à quelque chose je ferai un article dessus (#Teasing).

 [1]: https://www.terraform.io/
 [2]: https://www.hashicorp.com/?_ga=2.237048704.181949482.1515658044-1057723858.1515658044
 [4]: https://www.terraform.io/docs/providers/index.html
 [5]: https://www.terraform.io/intro/getting-started/install.html
 [6]: https://www.terraform.io/docs/configuration/syntax.html
 [9]: https://www.terraform.io/docs/providers/vsphere/index.html
 [12]: https://www.terraform.io/docs/state/remote.html
 [13]: /recherche/?keyword=ansible
