---
title: Sauvegarder son Kubernetes avec Velero (ex Ark)
authors:
  - zwindler
type: post
date: 2021-08-02T06:15:00+00:00
excerpt: Tutoriel pour installer, configurer et restaurer des objets Kubernetes depuis VMware Tanzu Velero (ex Heptio Ark)
url: /2021/08/02/__trashed-2/
image: /2021/08/68747470733a2f2f76656c65726f2e696f2f646f63732f6d61696e2f696d672f76656c65726f2e706e67.png
categories:
  - Système
  - Virtualisation
tags:
  - AKS
  - azure
  - Kubernetes
  - restauration
  - sauvegarde
  - VMware

---
## Contexte

J’ai écris cet article / tuto en janvier 2019 sans jamais le terminer / mettre en forme. A l’époque, Heptio était en train de se faire racheter par VMware. Au moment où j’allais le poster, VMware a fait quelques modifications dans le tool, notamment en [changeant le nom de Ark vers Velero et en l’intégrant à Tanzu][1] (le Kubernetes de VMware).

Idéalement, j’aurais donc aimé réécrire l’article en remettant tout à jour, les noms, les lignes de commandes, etc. Sauf que je ne l’ai jamais fait. Et aujourd’hui, je ne travaille plus sur des clusters Kubernetes avec des workloads majoritairement Stateful et préfère l’approche Déclarative (type FluxCD) dans l’hypothèse où j’aurais un énorme crash à gérer plutôt que de tenter une restauration, avec tous les effets de bords et les risques que ça implique.

Cependant, plutôt que de mettre cet article « presque fini » à la corbeille, je prend donc le parti de le poster « tel quel », avec tous les défauts qu’il pourra avoir (notamment si certaines parties sont _outdated_). Le concept général lui, restera le même.

Pour illustrer le propos, j’avais déployé un cluster AKS mais ça marche bien évidemment avec n’importe quel cluster Kubernetes.

## Générer le cluster K8s AKS

```
az login
az group create --name myownkubernetescluster --location westeurope \
--subscription "Visual Studio Professional"

az aks create --resource-group myownkubernetescluster --name myawesomeakscluster \
--node-count 3 --enable-addons monitoring --node-vm-size Standard_B2s \
--kubernetes-version 1.10.9 --ssh-key-value ~/.ssh/dgermain_never_expire_rsa_openssl2.pub \
--subscription "Visual Studio Professional"

az aks get-credentials --resource-group myownkubernetescluster --name myawesomeakscluster \
--subscription "Visual Studio Professional"
```


## Éventuellement ajouter les droits pour le dashboard

```
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az aks browse --resource-group myownkubernetescluster --name myawesomecluster
```


## Sauvegarde / restauration avec Velero

Information sur Velero (Ark Heptio) [github.com/vmware-tanzu/velero](https://github.com/vmware-tanzu/velero)

Comme on est sur Azure dans mon exemple :  
* [github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure#setup)

On commencer par créer un ressource group spécifique aux backups (pour ne pas tout perdre si le ressource group est supprimé)

```
AZURE_BACKUP_RESOURCE_GROUP=arkbackups
az group create -n $AZURE_BACKUP_RESOURCE_GROUP --location westeurope \
--subscription "Visual Studio Professional"

AZURE_STORAGE_ACCOUNT_ID="ark$(uuidgen | cut -d '-' -f5 | tr '[A-Z]' '[a-z]')"
az storage account create \
    --name $AZURE_STORAGE_ACCOUNT_ID \
    --resource-group $AZURE_BACKUP_RESOURCE_GROUP \
    --sku Standard_GRS \
    --encryption-services blob \
    --https-only true \
    --kind BlobStorage \
    --access-tier Hot \
    --location westeurope \
    --subscription "Visual Studio Professional"

az storage container create -n arkblob --public-access off \
--account-name $AZURE_STORAGE_ACCOUNT_ID --subscription "Visual Studio Professional"
```


Récupérer le groupe de ressource du cluster K8s

```
az group list --query '[].{ ResourceGroup: name, Location:location }' --subscription "Visual Studio Professional"
[...]
  {
    "Location": "westeurope",
    "ResourceGroup": "MC_myownkubernetescluster_myawesomeakscluster_westeurope"
  },
  {
    "Location": "westeurope",
    "ResourceGroup": "myownkubernetescluster"
  }
```


Dans le cas d’AKS, il s’agit bien de choisir le groupe qui contient les VMs (MC\_myownkubernetescluster\_myawesomeakscluster_westeurope), et pas celui que vous avez créé en début de procédure (myownkubernetescluster) qui ne contient que l’objet « Kubernetes service ».

![](/2019/01/aks_ark.png)

```
AZURE_RESOURCE_GROUP=MC_myownkubernetescluster_myawesomeakscluster_westeurope
```


Créer un « Service principal » (compte de service dans Azure). Ne pas oublier de stocker le secret (contenu de la variable AZURE\_CLIENT\_SECRET) car on y aura plus accès a posteriori.

```
AZURE_CLIENT_SECRET=`az ad sp create-for-rbac --name "myarkserviceprincipal" --role "Contributor" --query 'password' -o tsv`
AZURE_CLIENT_ID=`az ad sp list --display-name "myarkserviceprincipal" --query '[0].appId' -o tsv`
```


### Récupérer les sources

Dans mon cas, la dernière version disponible est la v1.6.2, et j’ai besoin des la version linux amd64

```
mkdir velero && cd velero
wget https://github.com/vmware-tanzu/velero/releases/download/v1.6.2/velero-v1.6.2-linux-amd64.tar.gz
tar -xzf velero-v1.6.2-linux-amd64.tar.gz
```


### Créer un namespace et un service provider (différents de ceux par défaut)

Quelque soit le cloud provider, il faut modifier le fichier config/common/00-prereqs.yaml

Comme indiqué dans la documentation dédiée, ce fichier contient la plupart des informations génériques, notamment, les définitions (CRD pour les backups/restores Ark), le namespace, le service account et les rôles (RBAC).

Dans notre cas, on doit donc modifier le fichier config/common/00-prereqs.yaml pour qu’il créé un autre namespace, qu’on appellera « backup » pour faire original;  
On va aussi modifier le nom du service account pour qu’il colle à celui du Service Principal azure (pas obligatoire, mais c’est pour rester cohérent) et surtout son namespace.

```
vi config/common/00-prereqs.yaml
[...]
---
apiVersion: v1
kind: Namespace
metadata:
  name: backup

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: myarkserviceprincipal
  namespace: backup
  labels:
    component: ark

---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: ark
  labels:
    component: ark
subjects:
  - kind: ServiceAccount
    namespace: backup
    name: myarkserviceprincipal
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

```


Ensuite, il faut également modifier les spécifiques à notre cloud provider (ici Azure), en particulier le namespace, mais aussi nos informations de connexion à notre blob

Dans le déploiement, changer le namespace et le serviceAccountName

```
vi config/azure/00-ark-deployment.yaml
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  namespace: backup
  name: ark
[...]
    spec:
      restartPolicy: Always
      serviceAccountName: myarkserviceprincipal
[...]
```


```
vi config/azure/05-ark-backupstoragelocation.yaml
---
apiVersion: ark.heptio.com/v1
kind: BackupStorageLocation
metadata:
  name: default
  namespace: backup
spec:
  provider: azure
  objectStorage:
    bucket: arkblob
  config:
    resourceGroup: arkbackups
    storageAccount: arkANDTHEUUID

vi config/azure/06-ark-volumesnapshotlocation.yaml
---
apiVersion: ark.heptio.com/v1
kind: VolumeSnapshotLocation
metadata:
  name: azure-default
  namespace: backup
spec:
  provider: azure
  config:
    apiTimeout: 30s
    resourceGroup: ark-EUW-sandbox-RG
```


Créer les objets sur le cluster Kubernetes sur Azure

```
kubectl --context=myawesomeakscluster apply -f config/common/00-prereqs.yaml 
  customresourcedefinition.apiextensions.k8s.io/backups.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/schedules.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/restores.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/downloadrequests.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/deletebackuprequests.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/podvolumebackups.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/podvolumerestores.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/resticrepositories.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/backupstoragelocations.ark.heptio.com created
  customresourcedefinition.apiextensions.k8s.io/volumesnapshotlocations.ark.heptio.com created
  namespace/backup created
  serviceaccount/arkeuwsandboxsp created
  clusterrolebinding.rbac.authorization.k8s.io/ark created

kubectl --context=myawesomeakscluster apply -f config/azure/
deployment.apps/ark created
backupstoragelocation.ark.heptio.com/default created
volumesnapshotlocation.ark.heptio.com/azure-default created
daemonset.apps/restic created
```


A noter : avant le premier appel de ark, sur chaque machine, il faudra spécifier dans quel namespace est ark sur notre cluster K8s.

```
./ark client config set namespace=backup
```


Créer le secret du service provider

```
#AZURE_RESOURCE_GROUP=MC_myownkubernetescluster_myawesomeakscluster_westeurope
AZURE_SUBSCRIPTION_ID=d717105a-ac1d-457c-8ef8-7467aa90df5c
AZURE_TENANT_ID=15eb2494-5298-4347-81a3-e2d3c08a0f82
AZURE_CLIENT_ID=f44ae340-97a2-4d54-bdc5-c4d7b2a49a2a
AZURE_CLIENT_SECRET=r+VGoBqOwraH9uVdk/sED3Ezdb7bIZI1xjvZyyvmnzM=

kubectl --context=myawesomeakscluster --namespace=backup create secret generic ark-azure-credentials \
    --from-literal AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID} \
    --from-literal AZURE_TENANT_ID=${AZURE_TENANT_ID} \
    --from-literal AZURE_CLIENT_ID=${AZURE_CLIENT_ID} \
    --from-literal AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET} \
    --from-literal AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP}

secret/ark-azure-credentials created    
```


## Créer des données dans le cluster pour vérifier le fonctionnement

```
kubectl create ns testrestore
namespace/testrestore created

kubectl run pod ubuntu --image=ubuntu --namespace=testrestore
deployment.apps/pod created

kubectl --namespace=testrestore get all
NAME                       READY   STATUS              RESTARTS   AGE
pod/pod-5945cc9b88-sq8c8   0/1     RunContainerError   1          14s

NAME                  DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/pod   1         1         1            0           14s

NAME                             DESIRED   CURRENT   READY   AGE
replicaset.apps/pod-5945cc9b88   1         1         0       14s
```


## Créer une backup

```
./ark backup create $(date +"%Y%m%d-%H%M")
Backup request "20190109-1553" submitted successfully.
Run `ark backup describe 20190109-1553` or `ark backup logs 20190109-1553` for more details.

./ark backup describe 09-01-2019
Name:         09-01-2019
Namespace:    backup
Labels:       
Annotations:  

Phase:  New

Namespaces:
  Included:  *
  Excluded:  

Resources:
  Included:        *
  Excluded:        
  Cluster-scoped:  auto

Label selector:  

Storage Location:  

Snapshot PVs:  auto

TTL:  720h0m0s

Hooks:  

Backup Format Version:  0

Started:    <n/a>
Completed:  <n/a>

Expiration:  0001-01-01 00:00:00 +0000 UTC

Validation errors:  

Persistent Volumes: 
```


## Restaurer une backup

```
kubectl --namespace=testrestore delete ns testrestore
namespace "testrestore" deleted

./ark backup get
NAME            STATUS      CREATED                         EXPIRES   STORAGE LOCATION   SELECTOR
20190109-1553   Completed   2019-01-02 14:30:17 +0100 CET   23d       default            

./ark restore create restore-01 --from-backup 20190109-1553
Restore request "restore-01" submitted successfully.
Run `ark restore describe restore-01` or `ark restore logs restore-01` for more details.
```


 [1]: https://github.com/vmware-tanzu/velero
