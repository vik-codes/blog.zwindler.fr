---
title: 'Mon iPad (ou Android), un écran de plus pour Ubuntu !'
authors:
  - zwindler
type: post
date: 2022-08-05T15:00:00+02:00
excerpt: "Mise à jour de l'article pour migrer ses VMs de Proxmox VE vers XCP NG"
url: /2022/08/17/ipad-un-ecran-de-plus-pour-ubuntu
image: /2022/08/partage3.jpg
categories:
  - DIY
tags:
  - Ubuntu
  - GNOME
  - iPad
  - Android
  - tablette
  - RDP
---

## Astuce bien pratique

Vous avez sûrement vu des gens sur Mac connecter un iPad comme écran secondaire, en nomadisme ? C'est officiellement supporté et [mis en avant comme une fonctionnalité par Apple](https://support.apple.com/fr-fr/HT210380).

De même, vous avez peut-être aussi croisé des gens qui ont investi dans des écrans secondaires nomades pour ordinateur portable (dans les 150€ souvent, parfois beaucoup plus).

Mais admettons que vous n'ayez ni Mac, ni envie de payer pour cet équipement supplémentaire, et que vous avez une vieille tablette Android ou un iPad à disposition.

C'est typiquement mon cas. J'ai un laptop sous Ubuntu et un iPad acheté il y a quelques années que j'utilise de manière occasionnelle. 

Et rarement (surtout en conférence), il m'arrive d'avoir besoin d'un second écran (typiquement quand j'ai un livecoding et ma doc à côté).

## GNOME 42 à la rescousse

J'avais vu passer la news sur Twitter il y a 2 mois, mais je n'avais pas encore essayé.

Tout est parti de ce commentaire sur [reddit](https://www.reddit.com/r/gnome/comments/uz5as7/gnome_has_made_it_super_simple_to_extend_your/), faisant suite à [cette PR](https://gitlab.gnome.org/GNOME/gnome-remote-desktop/-/merge_requests/69).

Pour vous la faire courte, les développeurs de Gnome ont ajouté (entre autres choses), les *virtual monitors* dans l'implémentation du bureau à distance inclus avec Gnome.

On va tirer parti de cette fonctionnalité pour se connecter sur notre PC depuis l'iPad, mais au lieu d'afficher l'écran principal, on va afficher sur l'iPad un nouvel écran, virtuel.

## Comment on l'active

Pour l'instant c'est encore un peu caché. En lisant le post reddit, vous verrez qu'il faut activer la fonction en ligne de commande

```console
gsettings set org.gnome.desktop.remote-desktop.rdp screen-share-mode extend
```

Une fois que c'est fait, allez dans les paramètres (Partage ou Sharing en anglais) de votre laptop. Il faut activer "Partage" tout en haut, avant de pouvoir activer "Bureau à distance" (grisé).

![](/2022/08/partage1.png)

On active le bureau à distance RDP (avec un login et un mot de passe hein).

![](/2022/08/partage2.png)

On récupère notre IP avec votre méthode préférée (`ip --brief address show` par exemple).

Dans le cas d'un setup en nomadisme, il faudra donc connecter tout ce petit monde sur un seul et même Wi-Fi pour que ça fonctionne, ou via un VPN (sur lequel serait le laptop ET la tablette).

## Client RDP

Ensuite, sur l'iPad (ou la tablette android ou tout autre device avec un écran et capable de faire du RDP), on installe un client RDP.

Le post initial parle du client officiel de Microsoft et a priori il marche bien.

On configure l'iPad pour se connecter à l'IP récupérée à l'étape d'avant, on renseigne le username et le password et ...

TADAM

![](/2022/08/partage3.jpg)

## Premiers retours

Contrairement à la fonctionnalité officielle d'Apple ou à un écran nomade, ici c'est clairement du "just hack it". 

Mais... ça fonctionne.

> crude, but effective

Il y a un peu de lag avec l'aller-retour wifi, mais c'est supportable. L'écran est bien détecté même si ça me casse le positionnement de mes écrans à chaque fois.

N'imaginez pas en revanche passer une vidéo dessus (quoique ?) ça ne sera probablement pas très agréable.

Je verrai si j'ose l'utiliser la prochaine fois que je fais un livecoding en présentiel, ou pas :).
