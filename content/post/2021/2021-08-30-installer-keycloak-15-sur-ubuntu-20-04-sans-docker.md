---
title: Installer Keycloak 15 sur Ubuntu 20.04 (sans Docker)
authors:
  - zwindler
type: post
date: 2021-08-30T06:30:00+00:00
excerpt: "Installer Keycloak 15 (produit d'IAM / SSO de Redhat) sur Ubuntu 20.04 (sans Docker)"
url: /2021/08/30/installer-keycloak-15-sur-ubuntu-20-04-sans-docker/
image: /2021/08/sign_in_with_google.png
categories:
  - Système
tags:
  - IAM
  - keycloak
  - OIDC
  - Proxmox VE
  - Redhat
  - SAML
  - sso

---
## Keycloak sur Ubuntu, pour faire de l’OIDC comme un chef

J’en ai parlé un peu lors de l’article sur les soucis que j’ai rencontré lors de mon passage de Proxmox VE 6 à 7 : une des features (surprise en plus) de cette release a été le support d’**OpenID Connect** pour l’authentification dans Proxmox VE.

Ça fait très longtemps que j’ai envie d’ajouter une authentification externe de type SSO à mon cluster Proxmox VE perso, mais je n’ai pas eu le courage (l’envie) d’installer un LDAP et encore moins un Active Directory ([heureusement cette période de ma vie est loin derrière](/recherche/?keyword=windows)).

Or, je sais que dans les produits permettant de faire de l’OpenID Connect (et du SAML), il y a **[Keycloak](https://www.keycloak.org/)**, le IAM récupéré par Redhat et qui cartonne pas mal depuis quelques années maintenant.

> Add authentication to applications and secure services with minimum fuss. No need to deal with storing users or authenticating users. It’s all available out of the box.
>
> You’ll even get advanced features such as User Federation, Identity Brokering and Social Login.


Et il se trouve aussi que j’ai pour plan d’installer, dans les jours / semaines / mois qui viennent un keycloak au boulot pour d’autres besoins qui n’ont rien à voir. Vous me voyez donc venir, j’ai pris les devant et j’ai installé keycloak sur mon infra perso ;-)

Note : dans cet article, **on ne va parler que de l’installation de Keycloak**. S’il n’y a que ça qui vous intéresse, ne vous inquiétez pas, la partie Proxmox sera traitée dans un autre article.

## Pourquoi pas un container Docker ?

La plupart des gens installent keycloak de la façon qui est maintenant mise en avant par beaucoup d’éditeurs quand leur soft est un peu pénible à installer : un container Docker.

Effectivement ça simplifie grandement l’installation, surtout comparé à la doc d’install sans docker qui est pas terrible terrible... 

> For more details go to [about](https://www.keycloak.org) and [documentation](https://www.keycloak.org/documentation), and don’t forget to [try Keycloak](https://www.keycloak.org/guides). It’s easy by design!
>
> easy by design ??? p%$$£ç*µ !!!


Alors qu’avec Docker, l’image est prête à l'emploi et « juste marche » (pour peu qu’on sache à peu près faire de l’OIDC ce qui n’était pas mon cas mais ça c’est une prochaine histoire ;-p).

```
docker run -p 8080:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin quay.io/keycloak/keycloak:15.0.2
```


## Et donc du coup, nous on va l’installer à la mano

Eux disent que c’est une installation « baremetal ». Enfin, ça, c’est leur terminologie à eux. Moi je vais l’installer dans un container LXC, mais ça aurait très bien pu être installé sur une « vraie » VM Linux, un serveur physique ou un raspberry Pi (des gens l’ont porté sur ARM avec succès).

Keycloak est relativement peu gourmand (surtout pour une application Java !!) et tourne sans broncher dans mon container LXC avec 512 Mo de RAM. Je suis certain que j’aurais pu mettre moins en tweakant la JVM.

L’installation « baremetal » donc se base sur un serveur Wildfly à faire tourner sur un OpenJDK > 8. Une fois mon container LXC (ou ma VM) installée en Ubuntu 20.04, j’ai donc installé le dernier JRE disponible (16)

```
apt update
apt dist-upgrade
apt install openjdk-16-jre
java -version
  openjdk version "16.0.1" 2021-04-20
  OpenJDK Runtime Environment (build 16.0.1+9-Ubuntu-120.04)
  OpenJDK 64-Bit Server VM (build 16.0.1+9-Ubuntu-120.04, mixed mode, sharing)
```


Dans les autres prérequis que je m’impose moi-même, c’est la création d’un utilisateur Linux non privilégié (ne pas lancer un soft en tant que root sauf si c’est vraiment nécessaire !)

```
groupadd keycloak
useradd -r -g keycloak -d /usr/lib/keycloak -s /sbin/nologin keycloak
```


## Récupérer la dernière version

Redhat package son soft dans un tar.gz disponible sur github dans la section **releases** de dépôt principal de keycloak. Vous trouverez aussi [des raccourcis sur cette page](https://www.keycloak.org/downloads). Dans mon cas, je n’ai pas essayé encore la version Quarkus (en preview) mais bien la bonne vieille version Wildfly.

```
cd /usr/lib

wget https://github.com/keycloak/keycloak/releases/download/15.0.1/keycloak-15.0.1.tar.gz

tar xzf keycloak-15.0.1.tar.gz 
ln -s keycloak-15.0.1 keycloak
rm keycloak-15.0.1.tar.gz

chown -R keycloak: /usr/lib/keycloak-15.0.1
chmod o+x /usr/lib/keycloak/
```


## Configuration

A partir de là, on a quasiment tout pour démarrer le serveur Keycloak. En vrai, on pourrait déjà lancer le script **standalone.sh** et ça démarrerait. 

Mais ça ne marcherait pas très très bien, car on a pas mal de configuration à faire. Ce genre de procédure cracra m’a rappelé la bonne époque de configuration des produits Redhat et IBM (maintenant la même maison, comme par hasard) qui fleure bon la prise de tête et les erreurs humaines...

La première chose à faire est de créer quelques dossiers et de copier des fichiers :

```
mkdir /etc/keycloak
mkdir -p /var/run/keycloak
chown keycloak: /var/run/keycloak

cp /usr/lib/keycloak/docs/contrib/scripts/systemd/launch.sh /usr/lib/keycloak/bin/
cp /usr/lib/keycloak/docs/contrib/scripts/systemd/wildfly.conf /etc/keycloak/keycloak.conf
cp /usr/lib/keycloak/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/keycloak.service
```


La « blague » c’est que les PATH sont rentrés en durs dans la plupart de ces fichiers et pointent vers « /opt/wildfly » ce qui a peut-être beaucoup de sens pour les gens de chez Redhat mais pas dans mon setup (j’installe keycloak, pas un serveur wildfly, dans /usr/lib, pas dans /opt...).

Comme je suis feignant et que je crains les fautes de frappes difficiles à voir à l’œil nu, j’édite les fichiers incriminés avec des **sed**. Mais libre à vous de préférer les éditer à la main avec **vi** (d’ailleurs, ça vaut le coup de vérifier que le fichier est pas en vrac).

```
sed -i 's!wildfly!keycloak!g' /etc/systemd/system/keycloak.service
sed -i 's!/opt/keycloak!/usr/lib/keycloak!' /etc/systemd/system/keycloak.service

sed -i 's!/opt/wildfly!/usr/lib/keycloak!' /usr/lib/keycloak/bin/launch.sh
#lire la suite avant de lancer la suivante
sed -i 's!\$3$!\$3 -Dkeycloak.frontendUrl=https://keycloak.example.org/auth!' /usr/lib/keycloak/bin/launch.sh
```


Petite subtilité pour la dernière commande sed, j’ai mis keycloak derrière un reverse proxy pour faire plus joli et ajouter une couche TLS gérée par moi (et pas par wildfly) et arrêter de faire du PLAIN sur un soft d’IAM (facepalm).

[](/2021/08/image-1.png)

(lien mort, je ne suis plus sur Twitter)

Sauf que la totalité liens sur les pages d’admin de keycloak pointaient en HTTP plain qui échouaient donc. 

* [La solution dans ce genre de cas est décrite ici](https://www.keycloak.org/server/configuration-provider) et en gros le plus simple c’est de coller l’URL de votre frontend / reverse proxy dans les paramètres de lancement. Pourquoi faire simple quand on peut faire compliqué ?

## Démarrer le service

A partir de là, on a quasiment un keycloak vraiment fonctionnel. Vous pouvez lancer la console :

```
systemctl enable keycloak.service
systemctl start keycloak.service
```


La console est accessible sur votre LAN via l’IP de la VM sur le port 8080

![](/2021/08/keycloak_admin.png)

Reste la dernière petite subtilité : il n’y a aucun compte pour s’y connecter _:trollface:_. 

On retourne dans notre shell et on lance le script suivant, qui va injecter un bout de XML dans notre conf (qu’est ce que c’est crade... heureusement que le soft est bien au-delà de l’install...)

```
/usr/lib/keycloak/bin/add-user-keycloak.sh -r master -u youruser
Press ctrl-d (Unix) or ctrl-z (Windows) to exit
Password: 
Added 'youruser' to '/usr/lib/keycloak/standalone/configuration/keycloak-add-user.json', restart server to load user
```


Ah, et bien sûr, comme c’est de la configuration XML en dur, il faut redémarrer wildfly ;-)

```
systemctl restart keycloak.service
```


Et maintenant, à partir de là, vous pouvez commencer le "[Getting Started](https://www.keycloak.org/getting-started/getting-started-zip)".

![](/2021/08/keycloak_master.png)

 [1]: /2021/08/keycloak_admin.png
 [2]: /2021/08/keycloak_master.png
