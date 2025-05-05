---
title: Avec Terragrunt, ne répétez plus vos variables Terraform 358 fois
authors:
  - zwindler
  - zed
type: post
date: 2022-08-29T06:45:00+02:00
url: /2022/08/29/terragrunt-ne-repetez-plus-vos-variables-terraform/
image: /2022/08/terragrunt.png
aliases:
  - /2022/08/29/premiers-pas-avec-Terraform/
categories:
  - Script
  - systeme
  - Virtualisation
tags:
  - Cloud
  - consul
  - etcd
  - hashicorp
  - Terraform

---

Cet article a initialement été écrit avec [ma collègue Chahrazed Yousfi (zed) en anglais](https://deezer.io/terragrunt-dont-repeat-your-terraform-variables-358-times-b6cdb4e09e9f). C'est donc une traduction pour mes copains francophiles ;-).

## Mais pourquoi tu fais çaaaaaa ???

L'article qui suit parle d'un cas d'usage avancé de Terraform qui n'est probablement pas nécessaire d'aborder pour un débutant. Si jamais vous voulez un aperçu de ce qu'on peut faire avec Terraform, vous pouvez aller relire mon article [Premiers pas avec Terraform](/2018/01/16/premiers-pas-avec-Terraform/).

Au travail, la majorité de notre infrastructure est hébergée sur site (hors d'un cloud) et dans la plupart des cas ça nous convient.

Mais maintenir un service en ligne avec des infras en propre c'est parfois compliqué et il arrive que les services proposés par les cloud providers soient plus adaptés à nos besoins que ce que nous, l'équipe SRE, pouvons apporter à nos utilisateurs (les développeurs).

Pour gérer de manière "DevOps" ces services "cloud", nous utilisons un outil d'Infrastructure as Code (IaC) : Terraform de Hashicorp.

> Terraform is an open-source infrastructure as code software tool that provides a consistent CLI workflow to manage hundreds of cloud services. Terraform codifies cloud APIs into declarative configuration files.
> – Terraform website

Ce que nous aimons vraiment avec Terraform c'est que cet outil nous permet de construire une infrastructure "répétable" avec seulement quelques lignes de HCL (le domain-specific-langage de Hashicorp). L'état de l'infrastructure est stocké soit en local (dans un fichier) soit sur un système de stockage externe. Seule la différence entre ce qu'on écrit dans le code et ce qui est stocké dans ce *state* est appliquée/modifiée. Dernier point, l'outil est devenu un standard de-facto, ce qui est beaucoup à obtenir des services fiables et facilite l'onboarding des équipes de dev.

Pour donner une idée de notre usage de Terraform, le répository sur lequel nous stockons notre IaC représente :

* Pratiquement 1000 fichiers ".tf" de Terraform, pour environ 35k lignes
* Environ 4000 commits, 1500 pull-requests
* Plus de 40 contributeurs venant de diverses équipes

## Les limites de Terraform ?

Tant que vous avez peu d'objets dans Terraform, tout va bien.

Mais quand vous commencez à avoir des centaines de fichiers (comme nous), cela devient compliqué de travailler simultanément sur le même code Terraform. Le fichier qui stocke l'état de l'infrastructure doit être à jour et synchronisé entre tous les contributeurs.

Cela provoque des problématiques de "locking", le calcul des "diffs" est de plus en plus long. En scalant, l'expérience utilisateur de Terraform se dégrade dans le temps.

Il y a plusieurs stratégies pour contourner cela, mais nous n'avons pas trouvé de solution qui éclipsait tous nos problèmes.

Par exemple, il est possible de découper le code Terraform dans différents dépôts git et avoir un état Terraform pour chacun d'entre eux. De cette manière, chaque équipe devient autonome est peut travailler de manière indépendante sur leur infrastructure. Cependant, le code Terraform tend à être dupliqué de projet en projet, puis d'équipe en équipe (même en utilisant les modules Terraform, on en parlera plus tard).

D'expérience, du code dupliqué conduit à des erreurs humaines et nous essayons donc d'éviter ça le plus possible.

Une autre solution pourrait être de créer un gros "monorepo" dans lequel on dépose tous les projets Terraform dans des répertoires différents (chacun avec son "state"). On peut utiliser des modules Terraform pour factoriser le code HCL commun de ses dossiers, soit directement dans le même monorepo, soit dans des dépôts distants.

Mais même comme ça, on se retrouve toujours à dupliquer toujours les mêmes variables (comme le "billing account" de votre cloud provider, par exemple, ou toute autre valeur que vous utilisez tout le temps).

## Arrive alors Terragrunt !

Pour contourner certaines des limitations de Terraform, la société [Gruntwork](https://gruntwork.io/) a créé un outil appelé Terragrunt, qui pour le dire simplement, est un wrapper de Terraform.

**Note :** vous connaissez peut-être déjà Gruntwork pour certains autres outils "cloud native", notamment "[Terratest](https://terratest.gruntwork.io/)" (qui permet de tester son code Terraform), "AWS Infrastructure as Code Library”, "Gruntwork Landing Zone for AWS", etc.

L'idée principale mise en avant par Terragrunt est que le code Terraform devrait pouvoir être écrit de manière à ne jamais avoir à répéter quoique ce soit (philosophie DRY pour [Don't Repeat Yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)).

Dans ce post, je vous montrerai donc une façon (opinionated) d'utiliser les fonctions principales de Terragrunt, pour vous montrer qu'on peut éviter de se répéter 358 fois ;-).

## On se prépare

La première chose à faire pour commencer à travailler avec Terragrunt est bien sûr de l'installer ;-). Le [code source de Terragrunt est disponible ici](https://github.com/gruntwork-io/terragrunt) et les [binaires précompilés sont disponibles là](https://github.com/gruntwork-io/terragrunt/releases).

Pour avoir une bonne idée des fonctionnalités offerts par Terragrunt, je vous propose d'utiliser un environnement cloud de démo avec la hiérarchie suivante :

![](/2022/08/gcp-org.png)

**Note :** Pour cet exemple on a choisi *Google Cloud Platform* comme cloud provider, mais Terragrunt peut évidemment être utile dans bien d'autres contextes. L'avantage de GCP dans ce cas là, c'est qu'il existe des *folders* et des *projects*, qui nous permettent de gérer les droits par département, équipe, etc.

Dans cette démo, on va utiliser un dépôt git, qui contient initialement du code Terraform classique, et on va ensuite le dé-dupliquer étape par étape avec l'aide de Terragrunt.

[github.com/deezer/terragrunt-example/](https://github.com/deezer/terragrunt-example/)

Pour des raisons de lisibilité, on va décrire les actions étapes par étapes mais pas afficher le code entier à chaque fois. Vous pouvez naviguer entre les commits pour voir le résultat.

## Factoriser les variables

Avoir beaucoup de projets différents implique qu'on va avoir beaucoup de variables à déclarer. Et beaucoup de ces variables vont souvent être identiques **ou** similaires d'un projet à l'autre. Le souci, c'est que copier le code  d'un projet devient alors source importante d'erreurs humaines. Si on oublie de changer une variable au milieu de celles qui doivent être copiées, le résultat peut être fâcheux.

C'est d'abord pour cette raison que nous avons cherché une solution pour factoriser nos variables Terraform (nous ne pouvions pas être les seuls à avoir ce problème).

Nous cherchions également une solution qui serait compatible avec un système d'héritage et nous avons trouvé Terragrunt !

La capture d'écran qui suit est un aperçu de ce qu'on a pu faire avec Terragrunt pour les variables d'un "projet" GCP. Nous disposons maintenant d'un moyen pour factoriser la quasi-totalité de nos variables à différents niveaux hiérarchiques, et je vais vous montrer comment ! 😉

![](/2022/08/before_after.png)

## Un fichier de configuration

La première chose qu'on va faire est de créer un fichier terragrunt.hcl qui va contenir les informations utilisées par Terragrunt pour fonctionner.

Ce fichier est écrit dans la même syntaxe que Terraform (c'est du HCL), avec en plus des [fonctions supplémentaires](https://terragrunt.gruntwork.io/docs/reference/built-in-functions/). Pour plus de détails, vous pouvez aller voir [la page officielle de documentation](https://terragrunt.gruntwork.io/docs/getting-started/configuration/).

Pour notre démo, j'ai besoin de créer le fichier terragrunt.hcl à 2 niveaux dans mon repository :

* un premier au niveau de mon projet (là où sont mes fichiers .tf), pour indiquer à Terragrunt qu'il peut s'éxecuter ici. Pour faire simple j'appelerai ça le "fichier de configuration local"
* un second au niveau de la racine de mon dépôt git, où on mettra toute la configuration qui sera commune à tous les répertoires. Je l'appellerai "fichier de configuration global"

Le dépôt va avoir la structure suivante :

![](/2022/08/folders.png)

Au niveau du projet (dans le fichier de conf "local"), on va ajouter un bloc **include**, suivi par la fonction *find_in_parent_folders()*. Cette fonction recherche dans les répertoires parents jusqu'à trouver un autre fichier terragrunt.hcl. La fonction renvoie ensuite le chemin pour retrouver le fichier terragrunt.hcl  "global" (situé à la racine), qui contient toute la configuration commune à tous les fichiers terragrunt.hcl.

Ce bloc nous permet donc de récupérer la configuration déclarée à la racine. Les projets ne contiennent donc pas de configuration spécifique, puisque vous est basé sur la configuration "globale".

```json
include "root" {
 path = find_in_parent_folders("terragrunt.hcl")
}
```

## Variables globales

Admettons maintenant qu'on veut qu'un certain nombre de variables soient identiques pour tous les projets, comme pour le "billingID" par exemple. Pour le faire, on va ajouter des [inputs](https://terragrunt.gruntwork.io/docs/features/inputs/#inputs) dans le fichier de configuration globale :

```json
inputs = {
 billing_account = "012345-ABCDEF-UVWXYZ"
 organization_id = "12345678"
 region = "europe-west1"
 zone = "europe-west1-b"
}
```

Les **inputs** permettent de remplacer des variables déclarées (mais vides) dans les projets. Souvent, on déclare ces variables dans un fichier variables.tf, au niveau du projet lui-même.

Une fois que vous déclarez la variable et son type, elle sera automatiquement remplacée par la valeur déclarée globalement (plus haut), par Terragrunt.

```json
variable "billing_account" {
 type = string
}
```

De cette manière, on peut donc déclarer une seule fois les variables qui sont valables pour TOUS les projets.

Mais comment faire si jamais on a envie de mutualiser des valeurs qu'avec une partie de nos projets et pas tous ?

## Variables intermédiaires

Contrairement aux fonctions, qui ne sont utilisables que dans le fichier de configuration terragrunt.hcl, il est possible de configurer des **inputs** dans d'autres fichiers ".hcl". On peut donc les mettre où on veut dans notre dépôt, idéalement à un endroit intelligent dans notre hiérarchie de dossiers, histoire que tous les projets similaires héritent des mêmes variables.

Pour le faire, on va utiliser la fonction *read_terragrunt_config* dans la configuration globale pour tous les fichiers ".hcl" qu'on va vouloir inclure, puis fusionner tout ça ensemble.

Pour donner un exemple, si pour dossier et sous-dossiers donné on a un même tag "team leader" ou "point de contact", on va positionner un fichier team.hcl dans le dossier qui les englobe tous.

```json
inputs = merge(
   read_terragrunt_config(find_in_parent_folders("global.hcl")).inputs,
   read_terragrunt_config(find_in_parent_folders("team.hcl")).inputs,
)
```

Dans le cas de la team-a, ce fichier pourrait être placé ici : *dept-datascience/team-a/team.hcl*, avec les valeurs suivantes :

```json
inputs = {
 tech_lead = "Freddie Mercury"
 contact = "fmercury@gmail.com"
}
```

Pour la team-b, *dept-datascience/team-b/team.hcl* et les valeurs :

```json
inputs = {
  tech_lead = "Abel Tesfaye"
  contact   = "atesfaye@gmail.com"
}
```

Notre arborescence d'exemple devrait ressembler à ça maintenant :

![](/2022/08/folders2.png)

## Variables non factorisables

On ne peut pas toujours factoriser toutes les variables pour tous les projets. Il arrive qu'il soit nécessaire de faire des exceptions, par exemple, un projet va être déployé dans une région inhabituelle. 

Si jamais vous avez besoin d'écraser la valeur par défaut, déclarée dans un niveau supérieur, c'est possible. Il suffit de déclarer un *inputs* dans la configuration locale de Terragrunt en utilisant le même nom.

## Allez plus haut

En tant que SREs, on cherche toujours à automatiser toujours plus de tâches manuelles.

Grâce aux fonctions de Terragrunt, nous avons trouvé comment automatiser la configuration de la variable "name" de nos projets GCP. Nous avons décidé que tous les projets (name + ID) devraient être définis directement par le nom du répertoire dans lequel le code Terraform/Terragrunt est stocké.

On peut le faire de la façon suivante dans le fichier de configuration global

```json
inputs = {
  project_name = "basename(get_terragrunt_dir())"
}
```

De cette manière, nous n'avons plus à ne pas oublier de changer le *project_name* ou *projet_id* dans nos ressources Terraform ou notre variables.tf quand on copie du code. On se base simplement sur la variable *project_name*, qui est déduite automatiquement du dossier concerné.

## Configuration du backend Terraform

Au travail, pour stocker nos états Terraform (les fameux fichiers de state), nous utilisons un bucket GCS. Tous les états des projets sont stockés dans des chemins différents et parfois dans des buckets GCS différents. Mais ce chemin doit toujours contenir le nom du projet et le nom du bucket concerné.

```json
terraform {
  backend "gcs"{
    bucket  = "tfstate-team-a"
    prefix  = "team-a-proj-product1"
  }
}
```

Avec Terraform, il est impossible de variabiliser cette partie **backend**.

> a backend block cannot refer to named values (like input variables, locals, or data source attributes).

Heureusement, Terragrunt propose lui la possibilité de le faire, dans un bloc *remote_state* à ajouter dans le fichier de configuration global.

Dans notre exemple, nous avons décidé de créer des buckets qui seraient mutualisés pour quelques projets chacun. 

On les définit donc dans un fichier backend.hcl placé au plus haut des sous dossiers que le bucket va gérer. On réutilise la même technique que précédemment (inputs + *find_in_parent_folders()* + *read_terragrunt_config()*)

Par exemple, tous les projets de la team-a utilisent le même "tfstate-teamA", on va donc créer le backend.hcl à la racine du dossier team-a. 

Pour ce qui est du préfixe (le chemin du state dans le bucket), on utilise ensuite une fonction *path_relative_to_include*() qui renvoie le chemin relatif depuis la racine du dépôt. 

Dans l'exemple, le path pour team-a-proj-product1 ça serait *dept-datascience/team-a/product1/team-a-proj-product1*. Ca nous permet de nous assurer que le state est toujours stocké dans un endroit unique.

```json
remote_state {
  backend = "gcs"
  config = {
    bucket = read_terragrunt_config(find_in_parent_folders("backend.hcl")).inputs.bucket
    prefix = path_relative_to_include()
  }
}
```

Note : dans cet exemple particulier, on voit bien que la façon dont on nomme nos dossiers ainsi que la hiérarchie des dossiers est très importante pour faciliter la façon dont on décrit notre configuration. Pour autant, ce n'est qu'un exemple et on peut tout à fait gérer cela différemment tout en profitant des fonctions de Terragrunt.

Dans notre projet, on devra remplacer la configuration du backend par l'extrait suivant. La configuration du backend sera automatiquement remplie par terragrunt à partir de la configuration globale.

```json
terraform {
  backend "gcs" {}
}
```

## Une commande pour les contrôler toutes...

Une commande que nous n'attendions pas et que nous avons découverte avec Terragrunt est l'ajout d'un `run-all`.

run-all est une commande de la CLI Terragrunt qui permet de lancer de manière terragrunt dans tous les sous-dossiers contenant un terragrunt.hcl.

Si vous avez changé une des globales variables, vous pouvez appliquer le changement à tous vos projets d'un seul coup avec la commande suivante :

```bash
$ terragrunt run-all apply
```

On peut également utiliser cette fonction dans une CI/CD pour s'assurer que l'infrastructure est toujours à jour et qu'il n'y a pas eu de "drift".

## Conclusion

J'espère vous avoir convaincu que Terragrunt peut réellement être utile lorsque vous travaillez avec un grand nombre de fichiers Terraform.

Cela nécessite un peu de rigueur et de réflexion pour créer une hiérarchie de dossiers, de manière à mutualiser de manière intelligente les variables dans l'arborescence.

Même si Terragrunt ajoute un peu de complexité, il permet également d'obtenir de nouvelles fonctions et facilite l'automatisation et la factorisation du code.

Tout ceci permet ensuite d'avoir du code plus propre, plus maintenable, moins dupliqué.

Je ne conseille pas de commencer directement avec Terragrunt si vous débutez dans Terraform (ça ajoute quand même un peu de complexité pour peu de gain). Cependant, si vous commencez à avoir beaucoup de fichier, de contributeurs, vous devriez clairement le tester.

## D'autres ressources externes sur le sujet

* [L'article en anglais co-écrit par ma collègue **zed** et moi même](https://deezer.io/terragrunt-dont-repeat-your-terraform-variables-358-times-b6cdb4e09e9f) (EN)
* [github.com/deezer/terragrunt-example - le code de l'article](https://github.com/deezer/terragrunt-example)

- [Mon support de conférence "Du code Terraform VRAIMENT factorisé avec Terragrunt](https://blog.zwindler.fr/talks/2022-terraform-vraiment-factorise-terragrunt/index.html) (FR)
- [Jérôme Masson - Terraform : remote state configuration DRY avec Terragrunt](https://medium.com/cncf-cloud-native-landscape-by-sphinxgaia-j%C3%A9r%C3%B4me/et-si-on-emballait-Terraform-de-hashicorp-b815b78dd178) (FR)
- [Ichi pro - Gardez votre code terraform "sec"](https://ichi.pro/fr/terragrunt-comment-garder-votre-code-terraform-sec-et-maintenable-270595294583256) (FR)
- [easyteam FR - Configuration DRY avec terragrunt](https://easyteam.fr/terraform-remote-state-configuration-dry-avec-terragrunt/) (FR)

* [Blog de Padok - Reduce redundancy in your Terraform code with Terragrunt](https://www.padok.fr/en/blog/Terraform-code-terragrunt) (EN)
* [gaunacode - on Azure](https://gaunacode.com/using-terragrunt-to-deploy-to-azure) (EN)
* [myshittycode - run-all & outputs](https://myshittycode.com/2019/10/30/terragrunt-plan-all-while-passing-outputs-between-modules/) (EN)
* [transcend - why we use terragrunt](https://transcend.io/blog/why-we-use-terragrunt/) (EN)
* [geekculture - terragrunt cheat sheet](https://medium.com/geekculture/terragrunt-cheat-sheet-bedafbf9d61f) (EN)

- [Gruntwork.io - L'exemple officiel](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example)
- [paddymorgan84 - terragrunt example](https://github.com/paddymorgan84/terragrunt-tutorial/tree/terragrunt)
- [pie-r - terragrunt vs terraspace](https://github.com/pie-r/terragrunt-vs-terraspace)
