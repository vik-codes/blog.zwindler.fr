---
title: 'Sidero Omni - Talos Linux sur Oracle Cloud (en free tier)'
authors:
  - zwindler
type: post
date: 2025-01-04T18:00:00+02:00
url: /2025/01/04/sideros-omni-talos-oracle-cloud
image: /2025/01/omni-oracle.png
categories:
  - DIY
  - Virtualisation
tags:
  - Homelab
  - Baremetal
  - Ubuntu
  - MAAS
  - Metal as a Service
  - Kubernetes

---

Fun fact, le 4 janvier 2024 (il y a tout pile un an donc), mon premier article de l'année était sur [Maas](/2024/01/04/un-peu-plus-loin-avec-maas-canonical). Commencer 2025, le même jour, avec un autre article à propos d'une solution qui vise à automatiser de l'infra, notamment en baremetal, c'est drôle :\)

## Contexte

J'ai gagné !!!

![](/2025/01/sidero-win.png)

Je joue de temps en temps à des jeux sur les réseaux sociaux (plus rarement maintenant) et il m'arrive aussi de faire des concours parfois en conférence.

Et là, j'ai gagné un an d'abonnement au SaaS de Sidero Labs (les créateurs de Talos Linux), **Omni**.

Pour celles et ceux qui se demandent, Omni est une solution de déploiement de clusters Kubernetes qui permet d'orchestrer des serveurs sous Talos, un système d'exploitation Linux minimaliste et sécurisé dédié à Kubernetes. Pour ce qui est de Talos, on en reparlera certainement dans de prochains articles.

## Quel rapport avec Oracle Cloud ?

Gagner, c'est bien, ça fait toujours plaisir. Mais j'en fais quoi, désormais, de ce SaaS ?

La première idée qui vient à l'esprit est de commander un serveur dédié quelque part et d'installer Talos dessus (avec un ISO généré par Omni), ou alors de faire la même chose, mais d'installer un hyperviseur, puis de pop des VMs Talos Linux (là encore, grâce à Omni).

Mais je suis ~~radin~~ un éternel économe et j'ai vu qu'Oracle Cloud Infrastructure (OCI) est supporté par Talos Linux et Omni, et donc j'ai voulu essayer.

Pour ceux qui ne connaissent pas OCI, j'ai fait une série d'articles en 2023 pour expliquer comment créer un cluster gratuit avec `kubeadm` sur le free tier (assez généreux) :

* [Un cluster Kubernetes gratuit pour vos labs persos ! - part 1](/2023/04/24/cluster-kubernetes-gratuit-part1/)
* [Un cluster Kubernetes gratuit pour vos labs persos ! - part 2](/2023/05/23/cluster-kubernetes-gratuit-part2/)

On va donc réutiliser le free tier ici, mais pour déployer et gérer des clusters avec Omni.

Note : vous pouvez les relire, mais j'ai fait mieux depuis car j'ai réussi à intégrer les machines du free tier DANS un cluster Kubernetes managé, bien plus agréable à utiliser. Stay tuned pour l'article à venir ;-).

## Prérequis

Pour Talos Linux sur Oracle Cloud Infrastructure (OCI) et plus spécifiquement intégrer les machines à Omni, il y a quelques étapes de configuration nécessaires.

Note : ce tutoriel s'appuie partiellement sur [la documentation officielle de Talos Linux](https://www.talos.dev/v1.9/talos-guides/install/cloud-platforms/oracle/), adapté pour Omni et avec des détails complémentaires sur Oracle Cloud Infrastructure.

Je pars du principe que vous avez déjà un compte sur Oracle Cloud Infrastructure, ainsi que les binaires `talosctl` et la CLI `oci`. Sinon un petit :

```bash
brew update && brew install oci-cli talosctl
```

Authentifiez-vous avec l'outil CLI :

```bash
oci session authenticate
```

Lorsque l'authentification est demandée, choisissez la région correspondant à votre localisation (par exemple, eu-paris-1). Une fois terminé, vous verrez un message de confirmation dans le navigateur et il faudra donner un petit nom mignon au profil pour `oci` dans le terminal et valider.

## Récupération du compartment ID

Un des concepts intéressant d'Oracle Cloud Infrastructure (qu'on retrouve chez d'autres cloud providers sous une forme ou une autre) est la notion de "compartment". Grosso modo, les ressources sont stockées dans des "compartiments" (la traduction littérale fonctionne pour comprendre) pour organiser les ressources. 

On peut travailler dans le "root" compartment, mais c'est quand même plus propre d'en créer un spécifique pour l'occasion.

![](/2025/01/compartments.png)

Exemple d'OCID :

```
ocid1.compartment.oc1..aaaaaaaayrmiilkb5m2b7never345435gonna345give87978you12upu6ifoh6csihm4awsjq
```

## Préparation de l'environnement Oracle Cloud

Une fois qu'on a ça, on va utiliser la CLI pour créer tous les trucs dont on va avoir besoin pour que nos machines virtuelles puissent s'enregistrer sur le SaaS d'omni.

Création d'un VCN (Virtual Cloud Network) et configuration réseau :

```bash
export cidr_block=10.0.0.0/16
export subnet_block=10.0.0.0/24
export compartment_id=<votre_ocid_compartment>
```

Créer le VCN et le sous-réseau :

```bash
export vcn_id=$(oci network vcn create --cidr-block $cidr_block --display-name talos-example --compartment-id $compartment_id --query data.id --raw-output)
export rt_id=$(oci network subnet create --cidr-block $subnet_block --display-name kubernetes --compartment-id $compartment_id --vcn-id $vcn_id --query data.route-table-id --raw-output)
```

À l'issue de la 2eme commande, on récupère non pas l'OCID du subnet (on n'en a pas besoin), mais celui de la "Route Table", un sous composant du subnet, qui permet de définir la table de routage du subnet qu'on vient de créer.

Configurer une passerelle (Internet Gateway) :

```bash
export ig_id=$(oci network internet-gateway create --compartment-id $compartment_id --is-enabled true --vcn-id $vcn_id --query data.id --raw-output)
```

Ajouter une règle de routage (à notre route table) pour permettre l'accès Internet :

```bash
oci network route-table update --rt-id $rt_id --route-rules "[{\"cidrBlock\":\"0.0.0.0/0\",\"networkEntityId\":\"$ig_id\"}]" --force
```

Désactiver les règles par défaut du pare-feu (YOLO) :

```bash
export sl_id=$(oci network vcn list --compartment-id $compartment_id --query 'data[0]."default-security-list-id"' --raw-output)
```

À partir de là, on a la partie réseau fonctionnelle, prête à accueillir nos machines !

## Mais ce n'est pas terminé :-/

Chez Oracle Cloud Infrastructure, il est possible de booter une liste d'OS prédéfinis, mais dans notre cas, Talos Linux n'est pas dans la liste.

Heureusement, Omni va nous générer un disque virtuel préconfiguré avec nos credentials, qui va nous permettre d'enrôler des serveurs Talos Linux à notre SaaS Omni dès le premier boot. Classe 😎.

On se connecte donc à notre interface Omni et on télécharge l'image de Talos Linux adaptée :

![](/2025/01/omni_iso_generation.png)

Ici, j'ai choisi la version 1.9.1 (la toute dernière car on aime le danger), pour architecture amd64. Je récupère l'image `oracle-amd64-omni-zwindler-v1.9.1.qcow2.xz` que je décompresse :

```bash
xz --decompress ./oracle-amd64-omni-zwindler-v1.9.1.qcow2.xz
```

Rappel : le free tier d'OCI consiste en :
* 2 machines **amd64** de 1 oCPU (= vCPU) et 1 Go de RAM chacunes
* une combinaison *flexible* d'instances **arm64** ayant 1 x **n** oCPU et 6 x **n** Go, tant que le total n'excède pas 4 oCPU (et donc 6x4 = 24 Go de RAM).

Sur OCI, il existe plusieurs formats pour importer des disques. Le plus simple est d'utiliser le format "maison" d'OCI (le .oci, extra original comme nom), qui se compose d'un fichier de métadonnées et du QCOW2.

Créez le fichier de métadonnées pour l'importation, avec la shape **VM.Standard.E2.1.Micro** car on a un image amd64 (sinon c'est VM.Standard.A1.Flex) :

```bash
cat > image_metadata.json << EOF
{
    "version": 2,
    "externalLaunchOptions": {
        "firmware": "UEFI_64",
        "networkType": "PARAVIRTUALIZED",
        "bootVolumeType": "PARAVIRTUALIZED",
        "remoteDataVolumeType": "PARAVIRTUALIZED",
        "localDataVolumeType": "PARAVIRTUALIZED",
        "launchOptionsSource": "PARAVIRTUALIZED",
        "pvAttachmentVersion": 2,
        "pvEncryptionInTransitEnabled": true,
        "consistentVolumeNamingEnabled": true
    },
    "imageCapabilityData": null,
    "imageCapsFormatVersion": null,
    "operatingSystem": "Talos",
    "operatingSystemVersion": "1.9.1",
    "additionalMetadata": {
        "shapeCompatibilities": [
            {
                "internalShapeName": "VM.Standard.E2.1.Micro",
                "ocpuConstraints": null,
                "memoryConstraints": null
            }
        ]
    }
}
EOF
```

Et créez ensuite l'image pour l'importation :

```bash
qemu-img convert -f raw -O qcow2 oracle-amd64-omni-zwindler-v1.9.1.raw oracle-amd64-omni-zwindler-v1.9.1.qcow2
tar zcf oracle-amd64-omni-zwindler-v1.9.1.oci oracle-amd64-omni-zwindler-v1.9.1.qcow2 image_metadata.json
```

## Importation de l'image sur Oracle Cloud

On a le fichier prêt à être uploadé... mais on l'upload où ??

Pas de chance, cette étape se fait en 2 parties. D'abord, il faut uploader le fichier .oci sur un bucket. C'est assez simple à faire dans l'UI (on aurait aussi pu le faire en CLI) :

* Créez un bucket dans la section Storage pour uploader l'image compressée.
* Uploadez l'image (oracle-amd64-omni-zwindler-v1.9.1.oci) dans ce bucket.

![](/2025/01/bucket.png)

Deuxième étape, on transforme le fichier en "Custom images" (dans la section **Compute**) :

![](2025/01/custom-images.png)

Cette étape est bizarrement assez longue, l'image qui ne fait que 100 Mo a pris 10 minutes à chaque essai que j'ai fait pour l'instant.

![](/2025/01/custom-images-2.png)

## Création de la VM

Une fois l'image importée, on peut maintenant utiliser notre image customisée par Omni pour booter nos machines freetier.

Je l'ai fait là aussi via l'interface OCI, mais là encore, on pourrait le faire en CLI.

![](/2025/01/vm1.png)

![](/2025/01/vm2.png)

Quelques secondes après le boot, elle apparait dans l'UI d'omni et peut être ajoutée à un cluster.

![](/2025/01/omni-oracle.png)

Have fun !!

## Addendum : est-ce que c'est vraiment gratuit ?

Oui...-ish.

**En théorie**, les machines sont gratuites (forever free comme ils disent). Mais attention, plein de petits trucs peuvent être payants.

Par exemple, le bucket sur lequel on a uploadé le QCOW2/.oci est très probablement payant. Idem pour la custom image, qui est facturée comme 1 Go de stockage (selon l'UI, j'ai pas encore la facture LOL).

Si vous mettez les VMs derrière un loadbalancer (il n'y a pas de raison que vous le fassiez ici), attention, seul le LB "non flexible" bridé à 10 Mbps est gratuit (et un seul).

Et si comme moi, vous avez déjà 4 disques de 50 Go, le stockage de l'OS est payant (1,85€ / mois).

Bref, vous l'aurez compris, c'est comme souvent dans le cloud, rien n'est vraiment gratuit et il faut bien lire tous les petits caractères.