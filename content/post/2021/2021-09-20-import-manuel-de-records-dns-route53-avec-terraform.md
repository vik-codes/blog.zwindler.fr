---
title: Import manuel de records DNS route53 avec Terraform
authors:
  - zwindler
type: post
date: 2021-09-20T06:10:00+00:00
excerpt: Importer et modifier avec terraform un record TXT existant dans route53
url: /2021/09/20/import-manuel-de-records-dns-route53-avec-terraform/
image: /2017/11/terraform.png
categories:
  - automatisation
  - cloud
tags:
  - aws
  - DNS
  - hashicorp
  - record
  - route53
  - terraform
  - txt

---
## Terraform et l’Infrastructure as Code

Ce n’est pas la première fois que je parle de terraform, l’outil d’Infrastructure as Code particulièrement efficace dans les environnements cloud (mais pas que) de Hashicorp.

J’avais fait un [petit « tour d’horizon »](/2018/01/16/premiers-pas-avec-terraform/) de l’outil quand il était encore en v0.10 ([Hashicorp a passé terraform en v1.0 en juin](https://www.hashicorp.com/blog/announcing-hashicorp-terraform-1-0-general-availability)), si vous avez besoin d’un petit rafraîchissement de mémoire ou que vous découvrez l’outil.

Pour la faire courte, l’intérêt de terraform (et de l’infrastructure as code) par rapport à l’automatisation plus classique est de passer dans un mode « déclaratif » où vous déclarez dans des manifests l’état souhaité de votre infrastructure plutôt que de dérouler un script qui fait les opérations unes à unes.

Vos manifests deviennent la « source de vérité », auditable, versionnable, absolue (pas de diff possible entre ce que vous pensez avoir déployé et le bidule modifié à la main hier que vous avez oublié).

## Réconcilier l’existant avec l’infrastructure as code

Tout ça c’est super si jamais vous venez de commencer à travailler dans le cloud et que vous partez de 0.

Si vous avez déjà de l’existant, c’est plus compliqué puisque vous vous retrouvez avec une partie décrite dans votre dépôt Git et une autre partie « historique ». 

Et même si on peut se dire que cette partie « historique » va finir par disparaitre au profit des nouveaux projets gérés par IaC, il existe une zone floue où on ne sait plus très bien si c’est géré à la main ou en IaC.

Du coup, autant en profiter quand on a le temps pour réintégrer le legacy dans l’IaC.

## Route53, le DNS by AWS

Je suis donc arrivé dans un contexte technique où le DNS externe est géré par AWS depuis bien longtemps, et qu’on intègre progressivement les nouveaux records dans terraform. Cependant, j’avais besoin de modifier un record déjà existant (de type TXT) et je n’avais pas envie de le faire à la main.

Sachez donc qu’il existe pour une grande partie (tous ?) des providers terraform une commande **_terraform import_** qui permet comme son nom l’indique d’importer l’existant dans terraform.

Le souci est que cette import n’est réalisée que dans le « state » de terraform, pas la configuration elle même. 

> The current implementation of Terraform import can only import resources into the [state](https://www.terraform.io/docs/language/state/index.html). It does not generate configuration. A future version of Terraform will also generate configuration.


Vous allez donc devoir écrire le pavé HCL à la main.

D’un certain côté, c’est presque plus rassurant quand on y réfléchit, car ça permet de bien se poser la question de comment on souhaite découper nos projets, comment on veut construire l’IaC (avec des variables, avec des boucles, etc).

## Récupérer les IDs uniques

L’idée ici va être de récupérer le record en donnant à terraform toutes les infos nécessaire pour qu’il retrouve celui qui nous intéresse. A la suite de **terraform import**, on doit lui donner les informations suivantes :

```
terraform import {resource_type}.{resource_name} {zone_id}_{record_name}_{record_type}
```


Dans mon cas, le **resource_type** était _[aws_route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)_, le **resource_name** _mytxtrecord_ (le nom que je veux lui donner dans ma conf et mon state terraform). La zone ID dépend de votre compte AWS/route53, le **record_name**, c’est le nom du record (comme sur la console) et le **record_type** dans mon cas, un TXT mais ça aurait très bien pu être un A, un AAAA, un CNAME, etc.

```
terraform import aws_route53_record.mytxtrecord ABCDE1234567890_awesomeexample.org_TXT

aws_route53_record.mytxtrecord: Importing from ID "ABCDE1234567890_awesomeexample.org_TXT"...
aws_route53_record.mytxtrecord: Import prepared!
  Prepared aws_route53_record for import
```


A l’issue de la commande, si tout s’est bien passé, vous devriez avoir un message qui indique le succès de l’opération et l’ajout du record dans le _state_ de votre terraform. Il ne reste plus qu’à rédiger le pavé HCL pour votre IaC qui a cette tête là dans mon exemple :

```
resource "aws_route53_record" "mytxtrecord" {
  zone_id  = data.aws_route53_zone.awesomedomain.zone_id
  name     = "awesomeexample.org"
  type     = "TXT"
  ttl      = "60"
  records  = ["existingsuperimportantdata"]
}
```


On peut commiter ça, puis faire nos modifications comme d’habitude et en toute sécurité :-)

```
terraform plan
[...]

Terraform will perform the following actions:

  # aws_route53_record.mytxtrecord will be updated in-place
  ~ resource "aws_route53_record" "mytxtrecord" {
        fqdn    = "awesomeexample.org"
        id      = "ABCDE1234567890_awesomeexample.org_TXT"
        name    = "awesomeexample.org"
      ~ records = [
          + "newtxtstring=veryimportantdata",
            "existingsuperimportantdata",
        ]
      ~ ttl     = 300 -> 60
        type    = "TXT"
        zone_id = "ABCDE1234567890"
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```


## Informations/sources additionnelles

* [www.terraform.io/docs/cli/import/index.html](https://www.terraform.io/docs/cli/import/index.html)
* [registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)
* [hackernoon.com/how-to-migrate-an-existing-infrastructure-into-terraform-qn173uag](https://hackernoon.com/how-to-migrate-an-existing-infrastructure-into-terraform-qn173uag)
