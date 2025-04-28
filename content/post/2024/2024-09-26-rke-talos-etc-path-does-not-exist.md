---
title: 'RKE, Talos Linux, ... : MountVolume.NewMounter initialization failed for volume : path does not exist'
authors:
  - zwindler
type: post
date: 2024-09-26T20:00:00+02:00
excerpt: "Pourquoi le provisioner de stockage Local échoue sur Talos Linux, RKE ou tout autre container OS"
url: /2024/09/26/rke-talos-etc-path-does-not-exist
image: /2024/09/bizu.png
categories:
  - Divers
tags:
  - kubernetes
  - k8s
  - container OS
  - Talos Linux
  - RKE
  - Flatcar
  - hostPath
  - PVC

---

## Tout a commencé...

Sans trop dévoiler de mon nouveau travail, je bosse sur une plateforme Kubernetes que nous gérons nous-même avec du [Talos Linux](https://www.talos.dev/) (un OS Kubernetes immutable pas piqué des hannetons !).

La plateforme est encore assez jeune, et sur mon environnement de développement, j'ai de quoi faire des buckets S3 mais pas de PVC avec du stockage de type "block". J'aurais pu monter un rook à [la méthode RACHE](https://www.la-rache.com/).

![](/2024/09/Certif_a_LARACHE_DenisGERMAIN.png)

Mais que voulez-vous... Par acquit de conscience pro (aka la grosse flemme de l'espace), et pour m'économiser 4 secondes et demi de requête à Google/ChatGPT, je demande à un collègue s'il a pas un petit bout de YAML pour monter un petit PVC à l'aide d'un hostPath vitef.

![](/2024/09/pvc-local.png)

cf [kubernetes.io/docs/concepts/storage/storage-classes/#local](https://kubernetes.io/docs/concepts/storage/storage-classes/#local)

## Ca commence mal

Bon déjà, si vous essayer de jouer ce manifest, ça ne va pas fonctionner. En effet, ce que la doc officielle ne dit pas (pas dans la page sur les storage classes en tout cas), c'est que le provisioner Local `kubernetes.io/no-provisioner` ne peut pas créer de PV si vous ne spécifiez pas d'affinité (nodeAffinity).

```bash
% kubectl apply -f toto.yaml
storageclass.storage.k8s.io/pour-la-science-sc created
The PersistentVolume "pour-la-science-pv" is invalid: spec.nodeAffinity: Required value: Local volume requires node affinity
```

Ça se corrige facilement :

```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: pour-la-science-sc
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pour-la-science-pv
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  local:
    path: /opt/tempDir
  storageClassName: pour-la-science-sc
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - worker-1
```

À partir de là, ça fonctionne (sur le papier). Une fois les manifests créés, vous devriez avoir une storage class et un PV, prêt à être utilisé. On peut même aller un cran plus loin et créer le PVC et le bind au PV.

```yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pour-la-science-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: pour-la-science-sc
```

Fin de l'article ?

```yaml
kubectl apply -f toto.yaml
storageclass.storage.k8s.io/pour-la-science-sc unchanged
persistentvolume/pour-la-science-pv created
persistentvolumeclaim/pour-la-science-pvc created
```

Non, bien sûr...

## Cours, pod ! Couuuuuurs !

Lançons donc un petit Pod de debug pour voir si on arrive à monter notre PVC dans un container :

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-pvc
spec:
  containers:
    - name: ubuntu
      image: ubuntu:latest
      command: ["/bin/bash", "-c", "sleep 3600"]
      volumeMounts:
        - name: storage
          mountPath: /toto
  volumes:
    - name: storage
      persistentVolumeClaim:
        claimName: pour-la-science-pvc
  restartPolicy: Never
```

Ici, pas besoin de spécifier l'**affinity** qu'il faut que le Pod se schedule sur le worker-1 (là où se trouve le PV). Le scheduler de Kubernetes est assez intelligent pour le retrouver tout seul.

```bash
% kubectl apply -f toto2.yaml 
pod/ubuntu-pvc created
```

Et là, c'est le drame. Le Pod reste bloqué en ContainerCreating !!

```bash
%  kubectl get pods
NAME           READY   STATUS              RESTARTS   AGE
ubuntu         0/1     ContainerCreating   0          52s

% kubectl get events
LAST SEEN   TYPE      REASON                 OBJECT                                      MESSAGE
4m6s        Warning   ProvisioningFailed     persistentvolumeclaim/pour-la-science-pvc   storageclass.storage.k8s.io "pour-la-science-pv" not found
100s        Normal    WaitForFirstConsumer   persistentvolumeclaim/pour-la-science-pvc   waiting for first consumer to be created before binding
88s         Normal    Scheduled              pod/ubuntu-pvc                              Successfully assigned default/ubuntu to worker-1
25s         Warning   FailedMount            pod/ubuntu-pvc                              MountVolume.NewMounter initialization failed for volume "pour-la-science-pv" : path "/opt/tempDir" does not exist
```

Hum... ok, ` path "/opt/tempDir" does not exist`, c'est relativement explicite comme erreur. J'ai oublié de créer le dossier sur le host en question.

Je vais créer un nouveau Pod qui lui va monter le /opt de l'hôte dans /mnt/opt, et créer le dossier à la main (souvenez-vous, méthode RACHE) :

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-hostpath
  namespace: somespecialnamespace
spec:
  containers:
    - name: ubuntu
      image: ubuntu:latest
      command: ["/bin/bash", "-c", "sleep 3600"]
      volumeMounts:
        - mountPath: /host/opt
          name: host
      securityContext:
        privileged: true
  volumes:
    - name: mnt
      hostPath:
        path: /host
        type: Directory
  restartPolicy: Never
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                  - worker-1
```

Note : les PodSecurity de Talos m'empêchent de créer le Pod (hostPath & priviledge) si je ne le créé pas dans un namespace disposant d'exceptions.

```bash
% kubectl exec -it -n somespecialnamespace pods/ubuntu-hostpath -- /bin/bash
root@ubuntu-hostpath:/# mkdir /host/opt/tempDir/
[control] + d
exit
command terminated with exit code 1
```

## C'est bon maintenant ?

Répertoire : créé. Mission accomplie, right ? Right ?

Et ben non !! Le Pod est toujours bloqué.

Pourquoi diantre je peux voir ce dossier dans mon Pod ubuntu-hostpath, mais pas dans ubuntu-pvc, qui monte le même dossier, mais via un PVC ???

La raison, c'est... Parce que c'est un PVC.

Bon ok, d'accord. Ce n'est pas JUSTE parce que d'un côté, je passe par un hostpath et de l'autre par un PVC. 

Les plus astucieux/astucieuses d'entre vous se seront surement douté qu'il y a un rapport avec le titre de mon article. Le problème est le même sur RKE, Talos Linux et surement d'autres OS similaires.

Ces OS ont la particularité d'être des "Container OS". Les composants de kubernetes ne sont pas "installés" à proprement parlé dans l'OS, mais lancé dans des containers. L'OS n'est en fait qu'une grosse coquille vide avec juste de quoi lancer des containers. Ça limite la surface d'attaque et ça les rend plutôt légers.

Et il y a une différence fondamentale entre la façon dont est géré "un Pod avec hostPath" et "un pod qui monte un PVC". Dans le cas du PVC provisionné avec `kubernetes.io/no-provisioner`, le kubelet a besoin de pouvoir monter le dossier **avant** le Pod.

Vous voyez où je veux en venir ? Dans un container OS, le kubelet est un container. Il ne voit rien d'autre que sa propre arborescence de container (pas le / de l'hôte comme un binaire classique, juste le contenu du gros ZIP qu'on a téléchargé depuis dockerhub avec `docker pull`), et éventuellement les dossiers de l'hôte qu'on lui a explicitement monté.

![](/2024/09/kubelet-talos.png)

Dans mon cas, pour le container du kubelet, ce dossier `/opt/tempDir` n'existe pas, simplement parce que dans son arborescence de container, il n'a pas été monté (ni créé).

## La solution

En fait, il suffisait, comme souvent, de lire la documentation. Talos Linux donne 2 méthodes pour résoudre ce problème :

* explicitement monter les dossiers dont on a besoin dans le container du kubelet
* passer par un provider tiers qui va créer des PVCs à partir de dossier sur l'hôte, sans passer par le kubelet.

* [www.talos.dev/v1.8/kubernetes-guides/configuration/local-storage/](https://www.talos.dev/v1.8/kubernetes-guides/configuration/local-storage/)

J'ai testé les deux, elles fonctionnent parfaitement. Mais au-delà de la solution, c'est plus le chemin que j'ai trouvé intéressant à vous partager :\)

![](/2024/09/bizu.png)

## Quelques liens sur le sujet

* [FAQ su SIG storage de Kubernetes - **Volume does not exist with containerized kubelet**](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/docs/faqs.md#volume-does-not-exist-with-containerized-kubelet)
* [Kubernetes 1.14: Local Persistent Volumes GA](https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local-persistent-volumes-ga/)
* [stackoverflow - Kubernetes - MountVolume.NewMounter initialization failed for volume "<volume-name>" : path does not exist](https://stackoverflow.com/questions/68503386/kubernetes-mountvolume-newmounter-initialization-failed-for-volume-volume-na)