---
marp: true
theme: gaia
markdown.marp.enableHtml: true
paginate: true
---

<style>

section {
  background-color: #fefefe;
  color: #333;
}

img[alt~="center"] {
  display: block;
  margin: 0 auto;
}
blockquote {
  background: #ffedcc;
  border-left: 10px solid #d1bf9d;
  margin: 1.5em 10px;
  padding: 0.5em 10px;
}
blockquote:before{
  content: unset;
}
blockquote:after{
  content: unset;
}
</style>

<!-- _class: lead -->

# Du code Terraform ![height:55](binaries/terraform.png) **vraiment** factorisé avec Terragrunt 👹 !

---

## ~$ whoami

Denis GERMAIN

- SRE - Techlead ![height:40](binaries/kubernetes_small.png) chez ![height:40](binaries/deezer-logo.png)
- Blog tech (et +) : [blog.zwindler.fr](https://blog.zwindler.fr)*
<br/>

![width:50](binaries/twitter.png) [@zwindler](https://twitter.com/zwindler)

**#geek** 👨‍💻 **#SF** 🤖👽 **#courseAPied** 🏃‍♂️

![bg fit right:40%](binaries/denis.png)

<br/>

**Les slides de ce talk sont sur le blog*

---

<!-- _class: lead -->

# Du code Terraform ![height:55](binaries/terraform.png) **vraiment** factorisé avec Terragrunt 👹 !

---

## Pourquoi parler de Terragrunt ?

- Utile chez ![height:40](binaries/deezer-logo.png)
- Un outil utilisé par pas mal de monde
  ![](binaries/github_stars.png)
- Très peu de ressources en dehors de la documentation officielle

![bg fit right:27%](binaries/terragrunt.png)

---

## Mais... c'est quoi Terraform ![height:55](binaries/terraform.png) déjà ?

- Décrit l'état souhaité de notre infrastructure avec un DSL
- L'infrastructure devient
  - collaborative
  - versionnée
  - reproductible (répétable)

> [Terraform](https://www.terraform.io/) is an open-source **[infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code)** software tool that provides a consistent CLI workflow to manage cloud services. 

---

## A quoi ressemble le code ?

- Hashicorp utilise son propre DSL (le HCL) pour décrire l'infra

![center height:400](binaries/terraform_code.png)

---

## A quoi le "plan" ?

- Terraform stocke l'état actuel de l'infra (fichier **state**)
- Au "plan" : ![height:35](binaries/terraform.png) fait la différence entre le **state** et l'état souhaité

![center](binaries/terraform-plan1.png)

--- 

## Terraform chez ![height:50](binaries/deezer-logo.png)

On utilise **beaucoup** terraform !

- 900 fichiers terraform (“.tf”)
- 35k+ lignes de code
- ~4000 commits
- 1400+ pull requests
- ~40 contributeurs (SREs, devs, prestas, ...)
<br/>

![width:50](binaries/twitter.png) [@zwindler](https://twitter.com/zwindler)

![bg fit right:30%](binaries/terraform.png)

---

## Les limites de Terraform ![height:55](binaries/terraform.png)

- Monorepo *avec un seul state*
  - Blocage régulier du state
  - Temps de "plan" longs

- Plurirepo (un repo par projet)
  - Code copié/collé d'un projet/équipe à l'autre
  - Erreurs humaines
  - Mauvaises pratiques potentiellement dupliquées

---

## Les limites de Terraform ![height:55](binaries/terraform.png)

- Monorepo *avec plusieurs states*
  - chaque dossier contient un "projet"

- On peut factoriser :
  - une partie du code avec des [modules](https://www.hashicorp.com/blog/new-guides-terraform-modules)
  - une partie de la configuration avec les [tfvars](https://learn.hashicorp.com/tutorials/terraform/variables#assign-values-with-a-terraform-tfvars-file) et les [tfworkspaces](https://www.terraform.io/language/state/workspaces)

- Il reste encore du code dupliqué (variables)

[Padok - Terraform Workspaces](https://www.padok.fr/en/blog/terraform-workspaces)

![bg fit right:30%](binaries/arbo1.png)

---

## Terragrunt à la rescousse

- Wrapper pour terraform ![height:35](binaries/terraform.png)
- Développé par [Gruntwork](https://gruntwork.io/) 
  - aussi éditeur de [terratest](https://terratest.gruntwork.io/)
- Philosophie DRY ([Don't Repeat Yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself))

<br/>
<br/>
<br/>



[Github.com - Code source et distributions](https://github.com/gruntwork-io/terragrunt)

![bg fit right:30%](binaries/terragrunt.png)

---

## It's time to D-D-D-D-D-DEMO !

![center](binaries/demo.png)

---

## Objectif de la démo

- Déployer des folders/projects sur GCP avec terraform ![height:35](binaries/terraform.png)
- Factoriser la totalité des variables de mon projet
  - Soit en les mutualisant dans l'arborescence
  - Soit en utilisant des fonctionnalités de Terragrunt

![center](binaries/arbo2.png)

---

## Récap'

- Factorisé toutes les variables
  - soit en les mutualisant dans l'arborescence
  - soit en utilisant des fonctions de Terragrunt pour les "deviner"
- Factorisé la conf du **remote state**
- Appliqué des modifications à plusieurs projets en une commande

![bg fit right:30%](binaries/terragrunt.png)

---

## Conclusion

- Parfois c'est un peu de la "bidouille" 
  - mais aussi avec Terraform ![height:35](binaries/terraform.png)
- Utile à partir d'une certaine taille
  - nécessite rigueur et réflexion préalable
- Pas tellement complexe
  - mais peu de ressources sur le net

![width:50](binaries/twitter.png) [@zwindler](https://twitter.com/zwindler)
![height:50](binaries/denis.png) Slides et sources sur [blog.zwindler.fr](https://blog.zwindler.fr/conf%C3%A9rences/)

![bg fit right:30%](binaries/terragrunt.png)

---

<!-- _class: lead -->

# Sources

---

## Quelques billets de blogs qui en parle

- [Ichi pro - Gardez votre code terraform "sec"](https://ichi.pro/fr/terragrunt-comment-garder-votre-code-terraform-sec-et-maintenable-270595294583256) (FR)

- [easyteam FR - Configuration DRY avec terragrunt](https://easyteam.fr/terraform-remote-state-configuration-dry-avec-terragrunt/) (FR)

- [gaunacode - on Azure](https://gaunacode.com/using-terragrunt-to-deploy-to-azure) (EN)

- [myshittycode - run-all & outputs](https://myshittycode.com/2019/10/30/terragrunt-plan-all-while-passing-outputs-between-modules/) (EN)

- [transcend - why we use terragrunt](https://transcend.io/blog/why-we-use-terragrunt/) (EN)

- [geekculture - terragrunt cheat sheet](https://medium.com/geekculture/terragrunt-cheat-sheet-bedafbf9d61f) (EN)

---

## Quelques dépôts git d'examples

- [Le code de ce talk - zwindler/terragrunt-101](https://github.com/zwindler/terragrunt-101)

- [Exemple officiel](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example)

- [paddymorgan84 - terragrunt example](https://github.com/paddymorgan84/terragrunt-tutorial/tree/terragrunt)

- [pie-r - terragrunt vs terraspace](https://github.com/pie-r/terragrunt-vs-terraspace)
