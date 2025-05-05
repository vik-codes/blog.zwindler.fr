---
title: 'Déléguer l’authentification Gitlab à Azure AD avec OAuth2'
authors:
  - zwindler
type: post
date: 2019-05-14T11:45:56+00:00
url: /2019/05/14/deleguer-lauthentification-gitlab-a-azure-ad-avec-oauth2/
image: /2019/05/gitlab_azuread-1.png
categories:
  - Logiciel
  - systeme
tags:
  - Active Directory
  - authentification
  - azure
  - Azure AD
  - Cloud
  - Confluence
  - Gitlab
  - JIRA
  - OAuth2
  - SAML
  - sso

---
## Gérer les comptes internes à Gitlab, c’est bof, le SSO, c’est mieux !

Dans le cadre de l’hébergement d’un nouveau serveur Gitlab, j’ai voulu intégrer notre base de compte existante, synchronisée dans Azure à l’aide de l’outil Azure AD, qui est le pendant « cloud » de l’Active Directory, bien connus de mes amis Windowiens (oui, il y en a). La plupart des applications savent aujourd’hui déléguer l’authentification à des fournisseurs tiers, généralement de type LDAP, via des protocoles tels que SAML(2) ou OAuth(2).

Cependant, bien que ces protocoles soient standards, leur implémentation dépend fortement du logiciel en question et il n’est pas toujours facile de s’y retrouver.

Pour faciliter cette opération, Azure a mis à disposition, directement dans Azure AD, des objets préconfigurés pour des milliers d’applications tierces. C’est comme ça qu’on peut implémenter, de manière simple et rapide, le SSO Active Directory avec les produits Atlassian (JIRA + Confluence), par exemple.

## Tout commence dans Azure

Dans le portail Azure, ouvrir « Entreprise applications », puis cliquer sur « New Application »

![](/2019/05/git_azuread1.png)

Malheureusement pour nous, il n’y a pas de template pour Gitlab ! Il va falloir le faire à la main.

A noter, le principe déroulé dans ce tutoriel est valable pour n’importe quelle autre application supportant des mécanismes similaire. Il est possible de réutiliser un template utilisé pour un soft et le réadapter pour d’autres logiciels qui fonctionnent de la même façon. C’est juste une histoire de paramètres.

![](/2019/05/git_azuread2.png)

Le menu nous conseille donc de choisir « Non-gallery application », puisque nous ne trouvons pas Gitlab. Sauf que, bizarrement, il faut un compte Premium pour utiliser cette feature.

On se rabat donc sur « Application you’re developing ». C’est d’ailleurs ce que conseille d’utiliser [la documentation de Gitlab](https://docs.gitlab.com/ee/integration/azure.html). Sauf que, pas de chance non plus, ça ne marche plus comme ça, maintenant ;)

![](/2019/05/git_azuread3.png)

## Créer une App registration pour Gitlab

Pour toutes les applications qui ne sont pas dans le store, on ne peut donc plus passer par les « Entreprise Applications ». On va donc créer une « App registration », qui n’est ni plus ni moins qu’un compte de service avec un ID et un (ou plusieurs) secrets.

Cliquer sur « New registration », puis lui donner un nom.

Sélectionner le type de comptes qui pourront accéder à cette application. Dans mon cas, il s’agit uniquement d’autoriser les comptes provenant de mon AD, mais on peut imaginer le cas d’une application ouverte en BtoB ou carrément ouverte à tout Internet.

Enfin, renseigner l’URL de callback, qui permettra à Azure de rediriger l’utilisateur qui s’est authentifié avec succès vers notre Gitlab.

> We’ll return the authentication response to this URI after successfully authenticating the user. Providing this now is optional and it can be changed later, but a value is required for most authentication scenarios.

Dans le cas précis de Gitlab, cette URL aura la forme : [mongitlab.example.org/users/auth/azure_oauth2/callback](https://mongitlab.example.org/users/auth/azure_oauth2/callback)

![](/2019/05/git_azuread4-1.png)

## Récupérer des valeurs qui intéressent Gitlab

Retourner ensuite dans l’overview de notre nouvelle « App registration ». Dans les détails, elle dispose d’un Application ID, aussi appelé Client ID et d’un Tenant ID :

![](/2019/05/git_azuread5.png)

On va maintenant créer un Secret. Pour les secrets, on peut choisir soit d’uploader un certificat (conseillé car plus sécurisé), ou de lui générer un mot de passe. Pour la simplicité de ce tutoriel, je vais créer un mot de passe pour notre application, mais je le répète, mieux vaut uploader un certificat.

![](/2019/05/git_azuread6.png)

On dispose maintenant de notre CLIENT\_ID, notre TENANT\_ID et de notre CLIENT_SECRET. Notez les bien, car une fois que la fenêtre sera fermée, il ne sera plus possible de relire à nouveau le secret et il faudra en générer un nouveau...

## Ajouter des restrictions ou des fonctionnalités complémentaires

En fonction de votre niveau de licence pour Azure AD, vous aurez accès à plus ou moins de choses. Moi, je n’ai accès à pratiquement aucune feature, mais si vous avez mieux, vous aller pouvoir ajouter des options très pratiques telles que le self service (les utilisateurs peuvent demander eux même à avoir accès à l’application, et si c’est validé, ils sont ajouté dans le bon groupe) et aux autorisations/restrictions par groupes Azure AD.

Pour se faire, il faut RETOURNER dans les Entreprises Applications (#RollingEyes), puis chercher notre « App registration » qui y apparaît maintenant dans la liste (avec le filtre All applications).

![](/2019/05/git_azuread7.png)

## Configuration de Gitlab

Gitlab ayant été installé avec les packages, la configuration se situe dans le fichier **/etc/gitlab/gitlab.rb**.

Dans le fichier de configuration, ajouter le bloc suivant en remplaçant les valeurs en majuscules par celles qu’on vient de récupérer :

```
gitlab_rails['omniauth_providers'] = [
{
    "name" => "azure_oauth2",
    "args" => {
    "client_id" => "CLIENT_ID",
    "client_secret" => "CLIENT_SECRET",
    "tenant_id" => "TENANT_ID",
    }
}
]
```


Rechargez ensuite Gitlab pour prise en compte de ce nouveau paramètre

```
sudo gitlab-ctl reconfigure
[...]
Running handlers complete
Chef Client finished, 13/637 resources updated in 26 seconds
gitlab Reconfigured!
```


Une boite d’authentification Azure Oauth2 devrait apparaître sous le login classique !! Youpi :)

![](/2019/05/git_azuread8.png)

## Et voilà c’est fini... ou presque...

Vous avez maintenant ajouté du SSO et l’authentification via Azure AD pour l’accès à votre Gitlab ! On essaye de se connecter ?

Et Paf !!

![](/2019/05/git_azuread9.png)

> Signing in using your Azure Oaut2 account without a pre-existing gitLab account is not allowed

En fait, c’est normal.

Par défaut, il n’est pas possible de s’authentifier avec Azure Oauth2 si un compte n’existe pas préalablement dans Gitlab, ce qui est quand même bien dommage si vous avez beaucoup de comptes à créer.

Deux cas de figure.

### Soit vous ne souhaitez pas que n’importe qui dans votre AD puisse se connecter sans votre accord préalable

Dans ce cas là, ce cas vous est finalement assez favorable, puisque vous allez pouvoir explicitement dire qui peut ou ne peut pas se connecter. Si vous ne disposez pas des bonnes licences et que vous avez pas pu restreindre l’accès à un groupe d’utilisateurs, c’est une « solution » de contournement acceptable.

Cependant, pour éviter de créer à la main tous les comptes, il sera probablement préférable de les créer de manière automatique [à l’aide de l’API Gitlab](https://docs.gitlab.com/ee/api/) et même [du très bon module Ansible gitlab_user](https://docs.ansible.com/ansible/latest/modules/gitlab_user_module.html) :

```
- name: "Create Gitlab User"
  gitlab_user:
    server_url: "{{gitlab_api}}"
    login_token: "{{token}}"
    validate_certs: True
    name: "Zwindler"
    username: "zwindler"
    password: "{{ 99999999 | random | to_uuid }}"
    confirm: no
    email: "zwindler@zwindler.fr"
    state: present
```


### Soit, à l’inverse, vous souhaitez que tous les utilisateurs de votre AD puissent avoir accès, sans pour autant devoir les ajouter uns par uns

Il existe alors des lignes sont à ajouter dans la configuration gitlab pour autoriser cette option :

```
gitlab_rails['omniauth_allow_single_sign_on'] = ['azure_oauth2']
gitlab_rails['omniauth_block_auto_created_users'] = false
gitlab_rails['sync_profile_from_provider'] = ['azure_oauth2']
gitlab_rails['sync_profile_attributes'] = ['name', 'email']
```


D’un point de vue sécurité, c’est un peu moins bien puisque n’importe qui avec un compte pourra se connecter, sans que vous le sachiez.

Cependant, ce problème est un peu moins grave qu’il n’y parait puisque l’utilisateur sera logué mais n’aura accès à rien (ou juste ce qui est « public »).

Dans le cas d’un Gitlab d’entreprise, où tous les développeurs doivent pouvoir se connecter, cette seconde option me parait quasi obligatoire. C’est encore plus acceptable si vous avez pu restreindre l’accès au SSO par groupe dans Azure AD, comme indiqué plus haut.

Have fun :)

## Sources

* [docs.gitlab.com/ee/integration/azure.html](https://docs.gitlab.com/ee/integration/azure.html)
* [serverfault.com/questions/874484/gitlab-and-oauth-to-azure-ad](https://serverfault.com/questions/874484/gitlab-and-oauth-to-azure-ad)
