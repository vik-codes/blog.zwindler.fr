---
title: Gérez vos secrets Kubernetes dans Vault
authors:
  - zwindler
type: post
date: 2020-08-31T06:30:00+00:00
excerpt: "Tutoriel pas à pas pour installer Vault de Hashicorp dans un cluster Kubernetes, puis d'accéder aux secrets depuis Kubernetes"
url: /2020/08/31/gerez-vos-secrets-kubernetes-dans-vault/
image: /2020/06/vault.png
categories:
  - systeme
  - Virtualisation
tags:
  - hashicorp
  - Kubernetes
  - secret
  - sidecar
  - Vault

---

## Hashicorp Vault + Kube = <3
  
  
Aujourd’hui je vous propose un tutoriel plus costaud que d’habitude car il demande d’avoir une connaissance basique de Kubernetes mais aussi une connaissance au moins minimale de ce qu’est Vault (de Hashicorp, parce qu’on va voir qu’il y en a plein).

Un des points qui m’a le plus choqué quand j’ai découvert Kubernetes est que les objets Secrets, qui contiennent tout ce qui devrait être sécure dans notre cluster, est tout simplement lisible en clair (modulo un base64 -d`). C’est pourquoi, lorsqu’on se prépare à déployer Kubernetes est de réfléchir au moyen de sécuriser ces Secrets.

![Je suis profondément choqué »](/2020/06/cope_choque.jpg)

L’état de l’art, c’est d’externaliser la gestion des Secrets dans un composant tiers. Et Vault rentre en jeu, un autre très bon produit de HashiCorp (comme [Terraform, dont j’ai déjà parlé](/2018/01/16/premiers-pas-avec-terraform/)).

Note : Si vous débutez avec Vault, plutôt que de faire un copier coller du tutoriel de Vault (et le traduire en Français), je vous invite simplement à aller sur le site officiel d’Hashicorp, qui dispose d’un guide [Getting Started](https://learn.hashicorp.com/collections/vault/getting-started) relativement bien fait.

Note 2 : Ce tutoriel est librement inspiré de ce Codelab de Google (edit : lien mort), que j’ai simplifié et pour lequel j’ai modifié/retiré quelques parties et corrigé une ou deux erreurs. Néanmoins, si vous voulez plus de détails ou aller plus loin, je vous invite à le suivre (en anglais).

## Prérequis sur votre poste
  
Avant de rentrer dans le vif du sujet, je vais donc partir du principe que vous avez installé une version récente de Vault ainsi que de l’outil de CLI de gcloud.

Pour éviter d’alourdir encore plus le tuto, je vais également m’appuyer sur Google Cloud Platform qui va nous simplifier le déploiement de Vault et de Kubernetes lui-même. Pour autant, les principes de ce tutoriel restent valides pour d’autres providers, modulo quelques modifications dans les parties spécifiques à Gcloud.

```console
vault -version
Vault v1.4.2

gcloud version
Google Cloud SDK 294.0.0
alpha 2020.05.21
beta 2020.05.21
bq 2.0.57
core 2020.05.21
gsutil 4.51
kubectl 2020.05.21
```

## Le plan de bataille
  
On va lister les choses qu’on va vouloir faire, pour avoir les idées claires avant de se lancer :
  
* D’abord, on va déployer un cluster GKE qui va nous servir pour l’ensemble du test
* Ensuite, on va configurer GCP pour préparer l’instanciation de notre Vault, puis le déployer dans notre GKE
* Une fois que ça sera fait, on va configurer Vault et Kubernetes pour qu’ils puissent parler ensemble
* On finira par déployer une application qui récupèrera son secret dans Vault et non pas dans un Secret Kubernetes.
      
## Prérequis gcloud
 
Je le disais plus haut, je pars du principe que vous utilisez GCP. Si ce n’est pas le cas, vous pouvez créer un compte avec un email bidon et une CB valide, qui vous ouvrira l’accès à un essai avec 300$ de crédits valable 1 an.

J’ai créé un project vau1tgke` dans lequel tout sera déployé. Un peu par hasard, j’ai choisi de déployer mes ressources dans la région europe-west6, mais vous pouvez bien sûr [déployer ça où vous voulez](https://cloud.google.com/compute/docs/regions-zones/)...

```console
gcloud projects list
PROJECT_ID          NAME                PROJECT_NUMBER
vaultgke            vaultgke            123424595046

export GOOGLE_CLOUD_PROJECT=vaultgke
export CLUSTER_NAME=vaultgke
export GCLOUD_REGION=europe-west6
export KUBE_CONTEXT_NAME="gke_${GOOGLE_CLOUD_PROJECT}_${GCLOUD_REGION}_${CLUSTER_NAME}"
export SERVICE_ACCOUNT="vault-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
```

Certaines ressources sur gcloud devant être _globalement_ unique, je vous conseille de ne pas choisir de noms trop bateau pour votre CLUSTER_NAME.

### Stockage sécurisé pour _Unseal_
  
On va ensuite créer un stockage qui va stocker les informations qui vont permettre de "unseal" le Vault au démarrage. Là encore, si vous ne voyez pas de quoi je parle, je vous renvoie au tuto de Vault, qui expliquera ça mieux que moi (TL;DR, débloquer le vault qui est "encrypted at rest").

Là où c’est un peu tricky, c’est qu’on va stocker les informations pour "unseal" le Vault d’Hashicorp dans... le Vault de GCP (qui n’a rien à voir) !

Je sens vos mines perplexes au travers l’écran ;-) mis en vrai c’est logique. On a besoin d’automatiser l’opération d’unseal. Il est donc normal que nous cherchions un autre endroit sécurisé pour stocker les secrets permettant de le faire. Une histoire de poule et d’oeuf.

```console
gsutil mb "gs://${GOOGLE_CLOUD_PROJECT}-vault-storage"
Creating gs://vaultgke-vault-storage/...
```

Ce blob doit être accessible depuis notre cluster Kubernetes, mais pas par n’importe qui ! On va donc activer la "Google Cloud KMS API" sur ce projet, pour pouvoir chiffrer la clé, puis créer un Vault GCP et enfin créer un secret (keys) vault-init.

```console
gcloud services enable \
    cloudapis.googleapis.com \
    cloudkms.googleapis.com \
    cloudresourcemanager.googleapis.com \
    cloudshell.googleapis.com \
    container.googleapis.com \
    containerregistry.googleapis.com \
    iam.googleapis.com
Operation "operations/acf.f0d9cb14-2d4b-44a7-bb3d-66bc679e013f" finished successfully.

gcloud kms keyrings create vault \
    --location ${GCLOUD_REGION}

gcloud kms keys create vault-init \
    --location ${GCLOUD_REGION} \
    --keyring vault \
    --purpose encryption
```

## Service Account
  
Maintenant qu’on a tout activé côté GCP, on va créer un service account (au sens GCP du terme) pour Vault, lui donner les accès sur le storage puis la capacité à déchiffrer la clé stockée dessus.

```console
gcloud iam service-accounts create vault-server \
      --display-name "vault service account"
Created service account [vault-server].

gsutil iam ch \
    "serviceAccount:${SERVICE_ACCOUNT}:objectAdmin" \
    "serviceAccount:${SERVICE_ACCOUNT}:legacyBucketReader" \
    "gs://${GOOGLE_CLOUD_PROJECT}-vault-storage"

gcloud kms keys add-iam-policy-binding vault-init \
    --location ${GCLOUD_REGION} \
    --keyring vault \
    --member "serviceAccount:${SERVICE_ACCOUNT}" \
    --role roles/cloudkms.cryptoKeyEncrypterDecrypter
```

On a donc un service account vault-server, qui a les droits dans l’API GCP pour accéder au blob qu’on vient de créer et y déposer/lire des fichiers chiffrés.

## Créer des certificats
 
C’est la partie que je trouve personnellement un peu pénible. On va devoir également créer toute notre chaîne de certification. Mais en suivant et en adaptant ces quelques commandes, ça va finalement assez vite.

Placez vous dans un dossier rien que pour ça car on va générer plein de fichiers qu’on réutilisera à plusieurs reprises.

```console
export DIR="$(pwd)/tls"
mkdir -p $DIR

cat > "${DIR}/openssl.cnf" << EOF
[req]
default_bits = 2048
encrypt_key  = no
default_md   = sha256
prompt       = no
utf8         = yes

distinguished_name = req_distinguished_name
req_extensions     = v3_req

[req_distinguished_name]
C  = FR
ST = NAQ
L  = zwindler
O  = demo
CN = vault

[v3_req]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names

[alt_names]
IP.1  = ${LB_IP}
DNS.1 = vault.default.svc.cluster.local
EOF

openssl genrsa -out "${DIR}/vault.key" 2048

openssl req \
    -new -key "${DIR}/vault.key" \
    -out "${DIR}/vault.csr" \
    -config "${DIR}/openssl.cnf"

openssl req \
    -new \
    -newkey rsa:2048 \
    -days 120 \
    -nodes \
    -x509 \
    -subj "/C=FR/ST=NAS/L=zwindler/O=Vault CA" \
    -keyout "${DIR}/ca.key" \
    -out "${DIR}/ca.crt"

openssl x509 \
    -req \
    -days 120 \
    -in "${DIR}/vault.csr" \
    -CA "${DIR}/ca.crt" \
    -CAkey "${DIR}/ca.key" \
    -CAcreateserial \
    -extensions v3_req \
    -extfile "${DIR}/openssl.cnf" \
    -out "${DIR}/vault.crt"

cat "${DIR}/vault.crt" "${DIR}/ca.crt" > "${DIR}/vault-combined.crt"
```

N’hésitez pas bien entendu à changer les valeurs que j’ai mises dans les fichiers de conf openssl (sinon vous aurez des services avec zwindler dedans).

## Déployer un cluster GKE

Mon idée ici, c’est d’avoir un cluster Kubernetes dans lequel j’ai à la fois Vault et mes applications.

Pour des raisons de sécurité, le tutoriel de Codelabs conseille lui de séparer ceci en 2 clusters. C’est effectivement mieux segmenté mais surtout plus cher, vu que GCP facture à la ressource mais aussi au nombre de clusters Kubernetes, depuis peu ;-).

J’ai donc préféré placer Vault sur un nodepool séparé, ce qui est quasiment aussi bien. Pour économiser encore un peu plus, on aurait pu également tout mettre sur le même nodepool, en se contentant de segmenter proprement avec des namespaces.

```console
gcloud container clusters create ${CLUSTER_NAME} \
  --cluster-version 1.16 \
  --enable-autorepair \
  --enable-autoupgrade \![](/2020/06/cope_choque.jpg)

> « 
  --num-nodes 1 \
  --region ${GCLOUD_REGION} \
  --scopes cloud-platform
```

Et on va également créer une adresse IP publique pour pouvoir accéder à Vault depuis notre poste.

```console
gcloud compute addresses create vault --region "${GCLOUD_REGION}"
export LB_IP="$(gcloud compute addresses describe vault --region ${GCLOUD_REGION} --format 'value(address)')"
```

Et un pool de nodes dédiés pour Vault avec comme accès à GCP le service account que nous avons créé plus tôt.

```console
gcloud container node-pools list --cluster=${CLUSTER_NAME}
NAME          MACHINE_TYPE   DISK_SIZE_GB  NODE_VERSION
default-pool  n1-standard-1  100           1.16.9-gke.2

gcloud iam service-accounts list
NAME                                    EMAIL                                                              DISABLED
Compute Engine default service account  123424595046-compute@developer.gserviceaccount.com                 False
vault service account                   vault-server@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com       False

gcloud container node-pools create vault-pool \
    --cluster=${CLUSTER_NAME} \
    --service-account "${SERVICE_ACCOUNT}" \
    --machine-type e2-medium \
    --num-nodes 1 \
    --region ${GCLOUD_REGION} \
    --node-labels dedicated=vault-pool \
    --node-taints dedicated=vault-pool:NoSchedule

gcloud container node-pools list --cluster=${CLUSTER_NAME}
NAME          MACHINE_TYPE   DISK_SIZE_GB  NODE_VERSION
default-pool  n1-standard-1  100           1.16.9-gke.2
vault-pool    e2-medium      100           1.16.9-gke.2
```

Vous aurez peut être remarqué que je déploie le second node-pool avec l’option node-taints qui nous permet de nous assurer que par défaut, aucune application ne puisse être déployée sur ce pool. On fera bien entendu une exception pour Vault lui-même !

## Créer la configuration

A partir de maintenant, on a tout les prérequis pour déployer notre Vault dans GKE. On créé donc les ConfigMaps, les Secrets (certificats) et le déploiement.

```console
kubectl create ns vault

kubectl create configmap vault --namespace vault \
    --from-literal "load_balancer_address=${LB_IP}" \
    --from-literal "gcs_bucket_name=${GOOGLE_CLOUD_PROJECT}-vault-storage" \
    --from-literal "kms_project=${GOOGLE_CLOUD_PROJECT}" \
    --from-literal "kms_region=${GCLOUD_REGION}" \
    --from-literal "kms_key_ring=vault" \
    --from-literal "kms_crypto_key=vault-init" \
    --from-literal="kms_key_id=projects/${GOOGLE_CLOUD_PROJECT}/locations/${GCLOUD_REGION}/keyRings/vault/cryptoKeys/vault-init"

kubectl create secret generic vault-tls --namespace vault \
    --from-file "$(pwd)/tls/ca.crt" \
    --from-file "vault.crt=$(pwd)/tls/vault-combined.crt" \
    --from-file "vault.key=$(pwd)/tls/vault.key"
```

Le déploiement en lui-même est intéressant. Comme nous sommes en présence d’un composant avec un état (un cluster avec replicats bien distincts), le plus indiqué dans ce cas est de créer un StatefulSet dans Kubernetes.

Les noeuds Vault seront démarrés un par un, en passant par une phase d’init (avec unseal du Vault en passant par la clé stockée dans notre blob créé précédemment).

Récupérer le fichier YAML créé pour le Codelab et ajouter un NodeSelector pour forcer les déploiements de Vault sur les nodes dédiés.

```console
wget https://raw.githubusercontent.com/sethvargo/vault-kubernetes-workshop/master/k8s/vault.yaml
```



Insérer les paragraphes nodeSelector: et tolerations: entre spec: et affinity:


```
[...]
    spec:
      nodeSelector:
        dedicated: vault-pool
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Equal
        value: vault-pool
      affinity:
      [...]
```



Appliquer le fichier une fois modifié


```
kubectl apply --namespace vault -f vault.yaml
statefulset.apps/vault created
```



Déployer un service pour pouvoir accéder à Vault depuis Internet


```
kubectl apply --namespace vault -f - <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: vault
  labels:
    app: vault
spec:
  type: LoadBalancer
  loadBalancerIP: ${LB_IP}
  externalTrafficPolicy: Local
  selector:
    app: vault
  ports:
  - name: vault-port
    port: 443
    targetPort: 8200
    protocol: TCP
EOF
```



## Vérifier l’accès à Vault
  
  
Si tout s’est bien passé, vous devriez au bout de quelques temps vous devriez pouvoir constater :
  
* le démarrage des 3 instances dans notre cluster GKE
* la création d’un Service de type LoadBalancer pointant sur l’IP publique que nous avons créé plus tôt
      

```
kubectl --namespace vault get pods
NAME      READY   STATUS    RESTARTS   AGE
vault-0   2/2     Running   0          5m50s
vault-1   2/2     Running   0          3m10s
vault-2   2/2     Running   0          2m52s

kubectl --namespace vault get service vault
NAME    TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)         AGE
vault   LoadBalancer   10.31.248.122   34.65.142.26   443:31349/TCP   57s
```



On peut ensuite essayer de se connecter depuis notre PC.


```
export VAULT_ADDR="https://${LB_IP}:443"
export VAULT_CACERT="$(pwd)/tls/ca.crt"
export VAULT_TOKEN="$(gsutil cat "gs://${GOOGLE_CLOUD_PROJECT}-vault-storage/root-token.enc" | \
  base64 --decode | \
  gcloud kms decrypt \
    --location ${GCLOUD_REGION} \
    --keyring vault \
    --key vault-init \
    --ciphertext-file - \
    --plaintext-file -)"

vault status
Key                      Value
---                      -----
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
[...]
```



Cool, tout marche. On va insérer un mot de passe qui sera utilisé par la suite par un de nos déploiement dans Kubernetes.


```
vault secrets enable kv
Success! Enabled the kv secrets engine at: kv/

vault kv put kv/myapp/config \
    username="appuser" \
    password="awesomepassword"
Success! Data written to: kv/myapp/config
```



## Créer un ServiceAccount pour lire dans Vault
  
Comme je viens de le dire, le but du jeu va être de configurer Vault et Kubernetes pour que ce dernier soit capable de récupérer des Secrets qu’on aura sécurisé. Cela peut se faire via l’intermédiaire d’un ServiceAccount (de Kubernetes cette fois), lui même s’authentifiant via des [JSON Web Token](https://jwt.io/).

Je copie honteusement le schéma du Codelabs de Google qui a le mérite d’être clair et concis.

(lien mort)

```
kubectl create serviceaccount vault-auth

kubectl apply -f - <<EOF
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: vault-auth
  namespace: default
EOF

export SECRET_NAME="$(kubectl get serviceaccount vault-auth \
    -o go-template='{{ (index .secrets 0).name }}')"
export TR_ACCOUNT_TOKEN="$(kubectl get secret ${SECRET_NAME} \
    -o go-template='{{ .data.token }}' | base64 --decode)"
export K8S_API_SERVER="$(kubectl config view --raw \
    -o go-template="{{ range .clusters }}{{ if eq .name \"${KUBE_CONTEXT_NAME}\" }}{{ index .cluster \"server\" }}{{ end }}{{ end }}")"
export K8S_CACERT="$(kubectl config view --raw \
    -o go-template="{{ range .clusters }}{{ if eq .name \"${KUBE_CONTEXT_NAME}\" }}{{ index .cluster \"certificate-authority-data\" }}{{ end }}{{ end }}" | base64 --decode)"
```



## Autoriser Kubernetes à accéder à des secrets
  
  
On va également devoir activer le [moteur de secret Kubernetes](https://www.vaultproject.io/docs/auth/kubernetes) dans Vault, puis ajouter l’IP de l’API serveur, le certificat CA de Kubernetes et le ServiceAccount qu’on vient de créer comme étant autorisés à requêter vault.


```
vault auth enable kubernetes
Success! Enabled kubernetes auth method at: kubernetes/

vault write auth/kubernetes/config \
    kubernetes_host="${K8S_API_SERVER}" \
    kubernetes_ca_cert="${K8S_CACERT}" \
    token_reviewer_jwt="${TR_ACCOUNT_TOKEN}"
```



> #EtCestPasFini
  
  
En plus de donner accès à Vault, on doit maintenant créer des poliques dans Vault pour dire _à quoi_ ce ServiceAccount va avoir accès. Le codelab va un peu plus loin, mais moi je vais juste me contenter de donner accès en lecture seule au mot de passe qu’on a créé à l’étape précédente (kv/myapp/config).


```
vault policy write myapp-ro - <<EOF
path "kv/myapp/*" {
  capabilities = ["read", "list"]
}
EOF

vault write auth/kubernetes/role/myapp-role \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=default \
    policies=default,myapp-ro \
    ttl=15m
```



## Déployer une application pour tester tout ça
  
  
Ca y est, on voit le bout du tunnel ! On a tout configuré, il ne nous reste plus qu’à vérifier qu’on peut, depuis Kubernetes, accéder à un mot de passe stocké dans Vault.

A la base, je me suis basé sur l’application mise à disposition dans le Codelabs. C’est une bête application qui est composée de 3 containers.
  
* un init container se connecte à Vault (sur l’adresse renseignée dans vault_addr) via un token JWT provenant du ServiceAccount vault-auth et le CA (dans vault-tls). Ce container met à disposition un token permettant d’accéder à Vault, accessible à tous les containers du Pod.
* un second container utilise ce token pour réellement se connecter à Vault et extraire le secret qu’on recherche (kv/myapp/config)
* l’application utilise le secret qu’on vient de récupérer et l’affiche en sortie standard (lol).
      
  
Si jamais vous le testez, sachez qu’il y a une petite dans le Codelabs... le fichier YAML créé un Deployment qui n’utilise pas le ServiceAccount vault-auth, et n’a donc pas les droits de se connecter à Vault. Il faudra donc corriger la configuration du sidecar pour y rajouter, au niveau de spec:, la mention _serviceAccountName: vault-auth_


```
kubectl create configmap vault \
    --from-literal "vault_addr=https://${LB_IP}"

kubectl create secret generic vault-tls \
    --from-file "$(pwd)/tls/ca.crt"

wget https://raw.githubusercontent.com/sethvargo/vault-kubernetes-workshop/master/k8s/kv-sidecar.yaml

vi kv-sidecar.yaml
[...]
    spec:
      serviceAccountName: vault-auth
      volumes:
      [...]

kubectl apply -f kv-sidecar.yaml
```



Une fois tout lancé, on remarque que ça fonctionne :

```

kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
kv-sidecar-77c9855977-7sdcw   2/2     Running   0          3m30s

kubectl logs kv-sidecar-77c9855977-dzn6r -c app
2020/06/09 19:26:39     ---
    username: appuser
    password: awesomepassword
```



On voit que ça fonctionne, le mot de passe est bien accessible à l’application.

Je ne vais pas plus loin sur cet exemple, car comme vous pouvez le constater, il nécessite de mettre en place un processus assez lourd côté application (un init container et un sidecar disposant du token pour se connecter au Vault). Sachez que maintenant, on peut faire plus simple !

L’important c’est que vous ayez compris le principe. Normalement, ça doit fonctionner, donc on est contents pour l’instant !

## Conclusion
  
  
Petit rappel, dans ce tutoriel (un peu riche), on a vu comment :
  
* Déployer un cluster GKE avec plusieurs node-pools (c’était pas le but mais ça peut être utile)
* Configuré GCP pour stocker notre base Vault de manière sécurisée
* Déployé Vault sur GKE dans un contexte séparé du reste des autres applications
* Configuré Vault et Kubernetes pour qu’ils puissent parler ensemble
* Déployé une application qui récupère un secret dans Vault et non pas dans un Secret Kubernetes
      
  
On voit que la dernière partie (que j’ai déroulé très vite) passe par l’intermédiaire de 2 sidecars et est loin d’être optimale. Heureusement, depuis aout dernier, [Hashicorp a ajouté un sidecar, vault-k8s](https://www.hashicorp.com/blog/whats-next-for-vault-and-kubernetes/), qui permet d’injecter de manière plus transparente.

Si ça vous intéresse, sachez que le projet est [librement accessible à cette adresse](https://github.com/hashicorp/vault-k8s), qu’il est inclus dans le Chart Helm officiel de Vault et que je ferai vraissemblablement un autre article à ce sujet ;)

Et en attendant, have fun ! :)
