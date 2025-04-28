---
title: S'authentifier sur Proxmox VE avec Keycloak
authors:
  - zwindler
type: post
date: 2022-05-11T12:30:00+00:00
excerpt: "Tutoriel pour permettre de s'authentifier avec des sources tierces dans Proxmox VE à l'aide de Keycloak"
url: /2022/05/11/s-authentifier-sur-proxmox-avec-keycloak/
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

## Résumé des épisodes précédents

Cet article est la suite d'un article que j'avais sorti en aout dernier (time flies...) sur [l'installation de Keycloak (sans utiliser l'image Docker)](/2021/08/30/installer-keycloak-15-sur-ubuntu-20-04-sans-docker/).

J'avais bien entendu une idée derrière la tête (on installe pas un Keycloak pour le plaisir ?). cette idée était de tirer parti de l'authentification OIDC qui venait d'être ajoutée à Proxmox VE 7.

Je pars donc du principe que vous avez un serveur Keycloak fonctionnel et on va s'en servir pour ajouter l'authentification OIDC à notre cluster PVE.

## Getting Started

Dans l'article précédent, je vous avais laissé au moment où on se connectait à l'UI de Keycloak, et qu'on arrivait sur le "Getting Started". Si vous voulez plus de détails sur cette étape, je vous conseille de lire [l'article de documentation associé sur le site officiel](https://www.keycloak.org/guides).

![](/2021/08/keycloak_admin.png)

Nous, on va commencer direct par la création d'un "Realm".

Dans un contexte multi client ou multi entreprise, les Realms vous permettraient d'avoir un Realm par client par exemple, chacun avec son propre système d'authentification (LDAP, AD, ...). 

Ici, on ne va pas d'embêter, je fais un realm pour mon Proxmox et il servira juste pour ça.

## Créer un Realm

C'est peut-être un manque d'habitude, mais j'ai pas trouvé la navigation entre "Realm" hyper intuitive, au début. En fait, par défaut vous êtes sur un realm "master" (visible tout en haut à gauche de l'écran, sous le logo Keycloak).

![](/2021/08/keycloak_master.png)

En cliquant sur la flèche qui va vers le bas, à droite de "Master", on ouvre un menu déroulant, qui dévoile option "Add realm".

![](/2022/05/add_realm.png)

On lui donne un petit nom et c'est bon.

## Créer un client

Dans la terminologie Keycloak (OIDC en général), un client, ça va en fait être notre application qui va déléguer l'authentification à Keycloak.

Dans le realm Proxmox, on va donc créer un client pour ProxmoxVE. 

On lui donne un petit nom, mais surtout l'URL de connexion qui va avec (on prend le premier serveur du cluster, car chaque serveur à sa propre URL de connexion à l'UI, mais on va gérer ça plus tard).

![](/2022/05/add_client.png)

Vous devriez ensuite être redirigé vers les paramètres (plus complets) du client. De mémoire, il n'y a rien à changer, les paramètres par défaut sont bons, sauf si vous avez plusieurs URIs de connection.

C'est mon cas, j'ai plusieurs serveurs proxmox VE en cluster, mais je n'ai pas de loadbalancer qui me redirige sur les backends :8006 sur même URL en frontal.

Je dois donc renseigner dans la case "Valid Redirect URIs" autant d'URI que j'ai de serveurs PVE.

![](/2022/05/redirect_uri.png)

## Créer un utilisateur dans Keycloak

Avant d'aller configurer Proxmox VE, on va vouloir ajouter des utilisateurs dans Keycloak.

Idéalement, vous avez déjà une base de comptes interne (LDAP, AD, etc) ou externe (Google Gmail, Azure AD, que sais-je encore). C'est cet "Identity Provider" que vous allez devoir connecter à votre Keycloak. Cependant, ça sort du scope de cet article.

Pour info, j'ai réussi en très peu de temps, et en suivant cet article [How to setup Sign in with Google using Keycloak (lien mort, j'ai utilisé Internet Archive)](https://web.archive.org/web/20240204123315/https://keycloakthemes.com/blog/how-to-setup-sign-in-with-google-using-keycloak), à connecter mon compte gmail perso à Keycloak et je peux l'utiliser pour me logger dans ma console Proxmox.

Pour rester simple, on va seulement créer un login dans Keycloak, car l'outil offre une base de comptes interne qui suffiront pour cet article.

Dans le menu de gauche, sur le realm Proxmox qu'on vient de créer, allez dans "Manage / Users", puis cliquez sur "Add User".

On va vous demander des informations :

![](/2022/05/create_user_in_realm.png)

Une fois validé, affectez-lui un mot de passe.

![](/2022/05/user_set_password.png)

Normalement, une fois que c'est fait, on en a fini avec Keycloak.

## Configurer Proxmox VE

On peut donc aller configurer Proxmox VE. L'opération est relativement simple. Une fois loggé dans l'interface de management, on peut trouver le menu "Authentification" (dans le scope Datacenter).

![](/2022/05/proxmox_add_oidc.png)

On crée un provider de type OIDC :

![](/2022/05/proxmox_auth_openid.png)

Note: l'URL que vous devrez mettre dans issuer URL est de la forme https://mykeycloak.myexample.org/auth/realms/myrealm

Une fois que c'est fait, vous pouvez vous délogger. Dans le menu des "Realm" (les Realm au sens "Proxmox VE", cette fois-ci) doit apparaitre maintenant "keycloak".

Une fois que vous le sélectionnez, ça doit donner ça :

![](/2022/05/login_oidc_proxmox.png)

Si vous cliquez sur **Login**, vous serez redirigé sur une mire de login de Keycloak qui devrait ressembler à ça :

![](/2022/05/mire_login_keycloak.png)

(Ou ça, si vous avez suivi le tuto pour gmail)

![](/2021/08/sign_in_with_google.png)

Enjoy !!

## Bonus : debug OIDC

En partant du principe que votre Keycloak est accessible à l'URL mykeycloak.myexample.org et que vous avez créé le realm myrealm, dans lequel existe un user proxmox avec pour mot de passe KEYCLOAKPASSWORD :

```
curl https://mykeycloak.myexample.org/auth/realms/myrealm/protocol/openid-connect/token --user proxmox:cacf30e8-d71d-4cba-8dd6-cd1bf3661053     -H 'content-type: application/x-www-form-urlencoded'     -d 'username=proxmox&password=KEYCLOAKPASSWORD&grant_type=password'
```

La requête doit renvoyer un access token en JSON

```JSON
{"access_token":"eyJaaaaaaaaaaaaaaa90A","expires_in":300,"refresh_expires_in":1800,"refresh_token":"eyJaaaaaaaaaaaaaaa_Ks","token_type":"Bearer","not-before-policy":0,"session_state":"f68a1fcc-7741-4ba7-bea6-51756e81f6e1","scope":"profile email"}
```
