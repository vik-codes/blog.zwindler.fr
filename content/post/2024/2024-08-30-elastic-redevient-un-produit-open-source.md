---
title: 'Elastic redevient un ensemble de produits open source'
authors:
  - zwindler
type: post
date: 2024-08-30T10:00:00+02:00
excerpt: "Dernier rebondissement dans l'histoire Elastic versus AWS et de son passage en SSPL."
url: /2024/08/30/elastic-redevient-un-produit-open-source
image: /2021/01/sp_vole_travail.jpg
categories:
  - Divers
tags:
  - agpl
  - aws
  - Elastic
  - licence
  - opensource
  - sspl
  - AGPLv3

---

## Récap'

En 2021, j'avais écrit un article assez acide sur la décision d'Elastic (la société qui développe en grande partie les outils ElasticSearch, Kibana, Logstach, etc) de quitter de facto le monde de l'open source en remplaçant la licence par la SSPL, une licence inventée par MongoDB (qui n'est pas open source au sens de l'OSI). MongoDB avait fait le même move exact qu'ElasticSearch quelques années plus tôt.

J'avais été extrêmement critique face à ces changements, mais aussi l'attitude de Shay Bannon (patron d'Elastic), qui avait été extrêmement agressif, réduisaient toutes critiques (certaines légitimes à mon sens) à du simple FUD sans aucune argumentation sensée.

* [L’open source saute à L’Elastic avec la SSPL](/2021/01/23/lopen-source-saute-a-lelastic-avec-la-sspl/)

Depuis, plusieurs autres entreprises ont fait le même move, celle qui a fait couler le plus d'encre (numérique surtout) cette année étant Hashicorp, juste avant le rachat par IBM (changement en BSL avec des conditions très restrictives).

## AGPLv3, la revanche du retour de la vengeance

Très grosse news d'Elastic hier.

Shay Bannon annonce qu'Elastic fait le chemin inverse et réintroduit une vraie licence open source (au sens de l'OSI), l'AGPLv3.

* [www.elastic.co/fr/blog - Elasticsearch is open source, again](https://www.elastic.co/fr/blog/elasticsearch-is-open-source-again)

L'AGPLv3 est une très bonne licence, qui est certes restrictive, car elle oblige l'utilisateur à reverser énormément (ce qui peut bloquer certaines entreprises, mais c'est peut-être pour le mieux ?) mais est parfaitement conforme en tant que "vrai" licence open source.

Pour ceux qui veulent plus de détails, je vous conseille l'excellent tldrLegal

* [tl;drLegal - GNU Affero General Public License v3 (AGPL-3.0)](https://www.tldrlegal.com/license/gnu-affero-general-public-license-v3-agpl-3-0)

## Mon avis

Même si Shay Bannon s'en défend, je ne peux m'empêcher d'y voir un début de mea culpa. Peut-être que la cible initiale du changement de licence était effectivement Amazon, mais contrairement à ce que Shay disait avant aujourd'hui, ElasticSearch n'était plus open source (il le reconnait aujourd'hui).

Et ça a blessé / mis en colère une partie des utilisateurs ET des contributeurs, au point qu'une partie, pourtant pas concurrents d'Elastic, ont changé de crèmerie et sont partis soutenir OpenSearch d'Amazon (!!!).

> Open source is in my DNA. It is in Elastic DNA. Being able to call Elasticsearch Open Source again is pure joy.

Revenir sur cette décision était donc un moyen de dire "ok, on est quand même content d'avoir vos contributions, revenez". Cependant, un lecteur me disait à juste titre que la confiance se perd plus facilement qu'elle se (re)gagne.

Cela étant dit, si la communauté parvient à "pardonner" à Elastic, on peut aussi voir ce move comme un énième f**k à Amazon, qui a investi sur son fork et qui verra (peut-être ?) des contributeurs revenir côté Elastic. 

Tout ça n'est que pure spéculation de ma part, bien entendu, et les prochains mois vont être déterminant pour jauger de l'efficacité ou non de ce revirement de situation.

Quoi qu'il en soit, je ne peux aujourd'hui que féliciter Elastic pour ce move inverse, à contre-courant des récentes modifications de licences dans l'OSS. Bravo :\)