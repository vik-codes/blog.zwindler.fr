---
title: 'Sauvegarder des dashboards Grafana dans Kubernetes, en s’amusant (j’explique les RBAC, Job et les CronJob)'
authors:
  - zwindler
type: post
date: 2024-10-01T18:00:00+02:00
excerpt: Article dans lequel on va utiliser les outils à notre disposition (Kubernetes, Scaleway) pour sauvegarder simplement nos dashboards Grafana
url: /2024/10/01/sauvegarder-dashboards-grafana/
image: /2020/01/20200102_084825-2.jpg
categories:
  - Système
tags:
  - Grafana
  - Kubernetes
  - API
  - Job
  - CronJob

---

Note : Pour les allergiques à Kubernetes, cet article peut être vu comme une entrée en la matière, car je vais progressivement explorer certains concepts, de manière très progressive. 

Note 2 : par convention dans cet article, j'ai essayé de nommer tous les objets Kubernetes avec une majuscule à tous les mots (exemple : **ServiceAccount**) pour que ce soit plus clair.

## Grafana

Je ne vous ferai pas l'affront de vous présenter Grafana, l'outil de visualisation open source de la société éponyme. C'est un outil que j'utilise depuis un moment et qui est quasiment incontournable dans toutes les solutions de monitoring modernes (ou non ? xD).

D'ailleurs, [j'ai écrit déjà quelques articles sur Grafana au fil des années](https://blog.zwindler.fr/recherche/?keyword=grafana), c'est un outil aussi simple qu'irremplaçable (jusqu'à ce qu'on trouve mieux, bien entendu).

Si vous avez déjà utilisé au moins une fois Grafana, vous savez donc que les visualisations sont organisées comme suit :

* des dossiers
* dans lesquels on range des dashboards
* qui contiennent des panels (nos visualisations)

On peut donc créer des dashboards à gogo en fonction du besoin, les cloner, les modifier, les importer depuis un magasin sur grafana.com (assez inutilisable maintenant, mais bon) et en afficher le code JSON.

Et ça, c'est super cool, parce que si mon Grafana brûle (mes machines persos ne sont pas hébergées dans les conditions les plus pros possibles... 😱), je n'ai pas envie de tout perdre. Mais aller régulièrement copier / coller le code JSON de chaque dashboard, c'est pénible.

## Because I'm API

Un truc qui est cool avec Grafana, c'est que comme tout logiciel un peu pro qui se respecte, il dispose d'une API. Je ne vais pas juger de sa qualité globale d'API (vous connaissez peut-être bien mieux que moi), mais elle a le mérite d'exister.

Récemment, je me suis donc demandé quelle quantité d'effort, il faudrait déployer pour sauvegarder de manière automatisée des dashboards Grafana avec l'API et Kubernetes (oui hein, vous n'allez pas y couper).

Partons donc du principe que j'ai un cluster Kubernetes sur lequel [j'ai déployé la chart Helm officielle de Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana) (rappel, Helm, c'est à la fois un package manager et un moyen de déployer des applications dans Kubernetes).

À partir de là, de quoi j'ai besoin ?

* Je suis le roi des fainéants, je ne veux pas avoir à aller créer les accès dans Grafana moi même (via 3 clics clics). Il faut donc que j'automatise la création d'un token pour communiquer avec l'API
* Une fois que j'ai mon token, je veux créer une tâche périodique qui va se connecter à l'API, lister les dashboards disponibles et les sauvegarder sur un bucket s3 chez Scaleway (il y a 75 Go gratuit dans le free-tier, ça suffira largement)

## Se préparer à créer un token

Bon, là en apparence, on se retrouve face à un problème d'œuf / poule. Comment je fais pour me connecter à l'API si je n'ai pas un accès à l'API ?

Heureusement, on va tricher... grâce à Kubernetes 😏

Quand on déploie Grafana dans Kubernetes, la chart officielle va créer un **Secret** (au sens Kubernetes du terme) qui contient le login / password du compte local administrateur de Grafana. 

```yaml
apiVersion: v1
kind: Secret
metadata:
  creationTimestamp: "2024-10-01T13:11:48Z"
  name: grafana
  namespace: grafana
  resourceVersion: "1234567"
  uid: deadbeef-dead-cafe-baba-123456789012
data:
  admin: YWRtaW4=
  password: TmV2ZXJHb25uYUdpdmVZb3VVcAo=
type: Opaque
```

S'il est déconseillé de l'utiliser au jour le jour (mieux vaut utiliser des comptes nominatifs, idéalement via un [Identity Provider](https://en.wikipedia.org/wiki/Identity_provider)), c'est super pratique ici !

Il suffit de créer un **Job** Kubernetes avec suffisamment de droits pour lire ce **Secret**, qui va se connecter (une seule fois) sur l'API avec le compte admin, créer un token, le récupérer, et le stocker dans un autre **Secret** !

Sans rentrer à fond dans les détails de comment fonctionne le RBAC (Role Based Access Control) dans Kubernetes, voilà à quoi ça ressemble :

```yaml
---
apiVersion: v1
# le compte de service (ServiceAccount) qui va être utilisé par le Job et qui a besoin de droits particuliers
kind: ServiceAccount
metadata:
  name: grafana-backup-sa
  namespace: grafana
---
apiVersion: rbac.authorization.k8s.io/v1
# le rôle, c'est la politique de sécurité qui va nous permettre de faire des trucs
kind: Role
metadata:
  namespace: grafana
  name: grafana-backup-role
rules:
# ici je n'autorise qu'à lire le secret contenant l'admin/password de grafana, pas plus
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["grafana"]
  verbs: ["get"]
# ici, je vais autoriser le fait de modifier un secret qui s'appelle grafana-backup
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["grafana-backup"]
  verbs: ["get", "update", "patch"]
# ici, je vais autoriser le fait de créer des secrets
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create"]
---
# ici, je lie simplement ServiceAccount à un Role pour lui donner les droits dont j'ai besoin
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: grafana-backup-rolebinding
  namespace: grafana
subjects:
- kind: ServiceAccount
  name: grafana-backup-sa
  namespace: grafana
roleRef:
  kind: Role
  name: grafana-backup-role
  apiGroup: rbac.authorization.k8s.io
```

Note : vous aurez remarqué que je n'ai pas autorisé la création ET la modification du **Secret** grafana-backup en une seule étape, mais en deux. Ceci est dû à une limitation de l'API de Kubernetes, qui ne permet pas de limiter la création d'un objet via son "ressource name". Je vous laisse aller lire la doc officielle si ça vous intéresse.

Sachez que je me suis un peu "embêté" à gérer la politique de droits et qu'on aurait pu faire bien plus simple. Mais c'est pour respecter [le principe en sécurité informatique du moindre privilège](https://fr.wikipedia.org/wiki/Principe_de_moindre_privil%C3%A8ge) (c'est important).

## Bon... on va le créer, ce token ??

Maintenant qu'on a géré les aspects de sécurité (ça limitera les possibilités d'un attaquant qui réussirait à prendre la main sur notre **Pod** / container), on peut créer la tâche qui va créer le token.

Ici, il n'y a pas de raison de laisser tourner un container ad vitam une fois que le token est créé, on peut l'éteindre. Pour ça, il existe un objet dans Kubernetes qui s'appelle le **Job** (avec une gestion d'erreur et de retry intégré). Voilà à quoi il va ressembler :

```yaml
---
apiVersion: batch/v1
kind: Job
metadata:
  name: grafana-backup-api-token-job
  namespace: grafana
spec:
  template:
    spec:
      # on lui donne bien le bon ServiceAccount sinon on a fait tout ce RBAC pour rien T_T
      serviceAccountName: grafana-backup-sa 
      containers:
      - name: grafana-create-api-token
        # une petite astuce pour de la bidouille, merci Jérôme :-*
        image: nixery.dev/shell/curl/jq/kubectl:latest
        # on "monte" le Secret Kubernetes comme des fichiers dans notre container
        volumeMounts:
        - name: grafana-secret-volume
          mountPath: /etc/grafana-secret
          readOnly: true
        command:
        - /bin/sh
        - -c
        - |
          # Comme on a monté le secret dans notre container, c'est super facile de récupérer
          # l'utilisateur et le mot de passe admin sans avoir à le stocker nulle part (surtout pas sur github) 
          GRAFANA_ADMIN_USER=$(cat /etc/grafana-secret/admin)
          GRAFANA_ADMIN_PASS=$(cat /etc/grafana-secret/password)

          # On peut maintenant faire une requête HTTP via curl sur l'API de Grafana
          GRAFANA_API_TOKEN=$(curl -s -X POST http://@IPgrafana:80/api/auth/keys \
            -u "$GRAFANA_ADMIN_USER:$GRAFANA_ADMIN_PASS" \
            -H "Content-Type: application/json" \
            -d '{
              "name": "Kubernetes Backup Token",
              "role": "Admin",
              "secondsToLive": 31536000
            }' | jq -r '.key')

          # On termine par stocker le token dans le nouveau Secret grafana-backup
          kubectl create secret generic grafana-backup \
            --from-literal=GRAFANA_API_TOKEN=$GRAFANA_API_TOKEN \
            --dry-run=client -o yaml | kubectl apply -f -
      restartPolicy: OnFailure
      volumes:
      - name: grafana-secret-volume
        secret:
          secretName: grafana
```

Normalement, avec ce bon script code BASH, j'ai réconcilié les amateurs de bash avec Kubernetes. 

Comment ça, "non" ?

Il ne me reste plus qu'à appliquer le manifest YAML sur mon cluster Kubernetes et le **Secret** grafana-backup contenant la clé d'API devrait apparaitre sur notre cluster :

```yaml
kubectl apply -f job.yaml

kubectl get secrets
NAME                                      TYPE                DATA   AGE
grafana-backup                            Opaque              1      1m

kubectl describe secret grafana-backup
Name:         grafana-backup
Namespace:    grafana
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
GRAFANA_API_TOKEN:  104 bytes
```

Première victoire :\)

## RBAC, again

On peut s'attaquer à la deuxième partie du problème : comment récupérer puis sauvegarder les JSON ?

Ben, avec une nouvelle couche de moindres privilèges, pardi !!

Vous connaissez la musique maintenant. On crée un **ServiceAccount**, on ne lui donne le droit qu'à lire les **Secrets** qui nous intéressent via un **Role** / **RoleBinding** pour ne pas faciliter le travail d'un attaquant qui aurait compromis mon **Pod**.

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: grafana-backup-cron-sa
  namespace: grafana
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: grafana
  name: grafana-backup-cron-role
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["grafana-backup", "grafana-backup-s3-credentials"]
  verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: grafana-backup-cron-rolebinding
  namespace: grafana
subjects:
- kind: ServiceAccount
  name: grafana-backup-cron-sa
  namespace: grafana
roleRef:
  kind: Role
  name: grafana-backup-cron-role
  apiGroup: rbac.authorization.k8s.io
```

Petite subtilité, ici, je vais aussi devoir créer un **Secret** supplémentaire pour que mon container puisse s'authentifier sur le bucket S3 sur lequel je vais déposer mes JSONs. Je ne rentre pas dans les détails, on sort du cadre de l'article, vous pouvez aller l[ire la doc officielle de scaleway qui est plutôt bien faite (Using Object Storage with the AWS-CLI)](https://www.scaleway.com/en/docs/storage/object/api-cli/object-storage-aws-cli/).

Voilà à quoi ressemble le **Secret** grafana-backup-s3-credentials :

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana-backup-s3-credentials
  namespace: grafana
type: Opaque
stringData:
  # le Secret se compose de 2 entrées, qui seront montés comme des fichiers textes 
  # dans le container ; pratique pour des fichiers de config avec des secrets !!
  credentials: |
    [default]
    aws_access_key_id=SCxxxxxxxxxxxxxxxxxx
    aws_secret_access_key=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  config: |
    [default]
    region = fr-par
    output = json
    services = scw-fr-par
    [services scw-fr-par]
    s3 =
      endpoint_url = https://s3.fr-par.scw.cloud
```

Et pour finir, on veut donc créer une tâche planifiée, qui va s'occuper de réaliser notre sauvegarde régulièrement. Dans Kubernetes, il s'agit de l'objet **CronJob**, qui va lancer périodiquement des **Job** (le même qu'on a vu précédemment).

```yaml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: grafana-backup-cronjob
  namespace: grafana
spec:
  schedule: "0 */2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: grafana-backup-cron-sa
          containers:
          - name: grafana-backup
            image: nixery.dev/shell/curl/jq/awscli:latest
            volumeMounts:
            - name: grafana-backup-s3
              mountPath: /.aws/credentials
              subPath: credentials
            - name: grafana-backup-s3
              mountPath: /.aws/config
              subPath: config
          restartPolicy: OnFailure
            env:
            - name: GRAFANA_API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: grafana-backup
                  key: GRAFANA_API_TOKEN
            command:
            - /bin/sh
            - -c
            - |
              # Ici, on récupère un gros JSON listant les dashboards et on utilise jq pour extraire l'identifiant unique "uid"
              dashboards=$(curl -s -H "Authorization: Bearer $GRAFANA_API_TOKEN" 'http://@IPgrafana:80/api/search?query=&type=dash-db' | jq -r '.[] | .uid')

              # On boucle ensuite sur la liste des uid
              for uid in $dashboards; do
                # On récupère le JSON qu'on copie en local
                dashboard_json=$(curl -s -H "Authorization: Bearer $GRAFANA_API_TOKEN" http://@IPgrafana:80/api/dashboards/uid/$uid)
                echo "$dashboard_json" > /tmp/dashboard-$uid.json

                # Puis on utilise aws-cli pour uploader le fichier sur notre bucket s3
                aws s3 cp /tmp/dashboard-$uid.json s3://grafana-backup/grafana-backups/dashboard-$uid.json --profile default
              done
          volumes:
          - name: grafana-backup-s3
            secret:
              secretName: secret-grafana-backup-credentials
```

Toutes les deux heures, nos dashboards seront tous sauvegardés sur notre bucket chez Scaleway. Si la fonction de versioning a été activé sur le bucket, on pourra même garder un historique des versions.

Deuxième victoire :\)

## Conclusion

Ok, écrire ces scripts et les manifests qui vont avec a surement pris un peu plus de temps que d'aller manuellement créer un token dans l'UI de Grafana, puis de le donner en dur dans un gros script bash.

Cependant, il y a quand même quelques différences avec cette approche : 

1. A part pour les crédentials du bucket S3 (et encore on aurait pu utiliser minIO dans Kubernetes), on a manipulé aucun identifiant. Toute cette gestion des **Secrets** est déléguée à Kubernetes, loin de l'admin (avec les limitations que ça peut avoir). On n'aura pas de leaks sur github de secrets git-és par erreur et si on gère son RBAC correctement, seuls les **Pods** qui sont habilités à lire ses **Secrets** pourront le faire.
2. Tout est géré "as-code" et automatisé. Le faire une fois à la main va plus vite. Le faire 100 fois, car on a 100 clusters identiques, c'est quand même dommage.
3. On profite des fonctions de Kubernetes de gestion des erreurs et de retries des Jobs et des Cronjobs. C'est du code (bash ou autre) en moins à gérer si on veut fiabiliser l'outil dans une utilisation plus "industrielle".

Que je vous aie convaincu ou pas, au-delà de l'exemple, le but était surtout d'introduire quelques concepts de Kubernetes (le RBAC et les **Jobs**, comment on construit des manifests, ...) et j'espère que ça vous a plu. 

## Bonus

Si vous trouvez ces scripts trop limités pour vos besoins, vous pouvez aller voir les outils suivants, plus poussés. Attention cependant, certains ne sont pas/plus maintenu, et je n'ai pas audité le code. A vos risques et périls donc :

* https://staffordwilliams.com/blog/2021/02/14/grafana-in-kubernetes/
* https://github.com/ysde/grafana-backup-tool
* https://github.com/grafana-wizzy/wizzy (archivé)
* https://github.com/esnet/gdg