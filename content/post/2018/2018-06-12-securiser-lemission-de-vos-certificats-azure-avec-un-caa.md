---
title: 'Sécuriser l’émission de vos certificats avec un CAA (Azure)'
authors:
  - zwindler
type: post
date: 2018-06-12T11:45:10+00:00
url: /2018/06/12/securiser-lemission-de-vos-certificats-azure-avec-un-caa/
image: /2018/06/azure.png
categories:
  - Script
tags:
  - azure
  - azure cli
  - CAA
  - "Let's Encrypt"
  - Microsoft
  - OVH
  - PowerShell

---
## CAA ? Azure ?!?

Et oui, je travaille sur Azure ! Je crois bien que c’est le premier article que je vais faire à ce sujet donc je commence par quelque chose de léger, créer un CAA.

Au-delà de toute considération purement dogmatique, le cloud de Microsoft fait quand même partie des plus grands, avec une richesse fonctionnelle et une API aussi riche que ce qu’on trouve chez les autres. J’aurai l’occasion de faire d’autres articles sur Azure car j’utilise énormément les modules Ansible développés par les équipes de Microsoft (qui s’appuient sur l’API d’Azure).

## Et donc, le CAA ?

Mais cet article parle de CAA. Pour ceux qui ne connaitraient pas, un CAA est un « nouveau » (2017) type d’enregistrement DNS :

> La CAA est une mesure de sécurité qui permet aux propriétaires d’un nom de domaine de préciser dans leur DNS (Domain Name System) les autorités de certification (AC) qui sont autorisées à émettre des certificats pour leur nom de domaine.
> 
> Global Sign (lien mort, pas disponible sur Internet Archive)

Concrètement, si je possède un domaine avec un grand nombre de sites web signés, que je n’utilise qu’une ou deux (ou un nombre fini) autorités de certifications, je peux maintenant spécifier lesquelles (parmi la centaine des AC existantes) sont autorisées à émettre un certificat pour mon domaine. Cela permettra d’éviter que des personnes mal intentionnées génèrent un certificat pour une URL dans un de vos sous domaines.

## Comment ça fonctionne ?

Il existe donc un nouveau type d’entrée dans votre DNS qui devrait ressembler à ça :

<table>
  <tr>
    <th>
      Name
    </th>
    <th>
      Type
    </th>
    <th>
      Value
    </th>
  </tr>
  <tr>
    <td rowspan="2">
      zwindler.fr.
    </td>
    <td rowspan="2">
      CAA
    </td>
    <td rowspan="1">
      0 issue « letsencrypt.org »
    </td>
  </tr>
  <tr>
    <td rowspan="1">
      0 iodef « mailto:zwindler@zwindler.fr »
    </td>
  </tr>
</table>

Pour l’entrée zwindler.fr., j’ai donc un CAA qui dispose de 2 variables (issue et iodef) :

  * La première indiquant que seul letsencrypt.org peut générer des certificats pour mon domaine. On peut en avoir plusieurs si on a plusieurs autorités de certification.
  * La seconde indiquant qu’il faut m’envoyer un email si jamais quelqu’un qui n’a pas les droits essaye de générer un certificat.

**A noter :** iodef n’est pas respecté par toutes les autorités de certifications, donc vous n’aurez potentiellement pas d'emails en cas de tentative de génération de certificat chez une AC non autorisé.

## Ok, comment je créé un CAA ?

Normalement, c’est trivial. Il s’agit d’un enregistrement DNS comme un autre. Par exemple chez OVH, vous pouvez directement le créer depuis l’interface :

![](/2018/06/caa01.png)

## Et sur Azure ?


Il faut bien que ce soit rigolo. Dans le portail d’Azure, il n’est pas possible de créer (ni même de voir !!!) les champs de types CAA, pourtant disponibles depuis mi 2017.

La seule solution est d’utiliser l’API REST, la CLI azure, ou Powershell :

  * [Page de documentation azure cli][3] (record-set)
  * [Gérer les enregistrements DNS avec Powershell][4] 

## Avec Azure cli

Du coup je suis parti de la doc pour faire ça :

En partant du principe que vous avez un compte sur Azure, que vous gérez les DNS de la zone **zwindler.fr** depuis Azure DNS (dans un resource group appelé **dns-rg**), voilà ce qu’il faut faire pour créer une protection pour le sous domaine ***.test.zwindler.fr**.

```
az network dns record-set caa add-record --resource-group dns-rg --zone-name zwindler.fr --record-set-name test --flags 0 --tag "issue" --value "letsencrypt.org"
az network dns record-set caa add-record --resource-group dns-rg --zone-name zwindler.fr --record-set-name test --flags 0 --tag "iodef" --value "zwindl3r@zwindler.fr"

az network dns record-set caa list --resource-group dns-rg --zone-name zwindler.fr 
{
  "caaRecords": [
    {
       "flags": 0,
       "tag": "iodef",
       "value": "zwindl3r@zwindler.fr"
     },
     {
       "flags": 0,
       "tag": "issue",
       "value": "letsencrypt.org" 
     }
  ],
  "etag": "aaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa",
  "fqdn": "test.zwindler.fr.",
  "id": "/subscriptions/aaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa/resourceGroups/dns-rg/providers/Microsoft.Network/dnszones/zwindler.fr/CAA/test",
  "metadata": null,
  "name": "test",
  "resourceGroup": "dns-rg",
  "ttl": 3600,
  "type": "Microsoft.Network/dnszones/CAA"
}
```


## Et si je veux le domaine entier ?

**Et là c’est la blague !**

Si vous créez un record-set « _test_« , il va vous créer un CAA pour _test_.zwindler.fr (voire le champ **fqdn** dans la réponse du list). Vous n’avez pas la main sur le **fqdn** directement (que ce soit en création ou en mise à jour), il est créé à partir du nom.

Or, vous avez très probablement envie de protéger **zwindler.fr**, pas seulement **test.zwindler.fr**, car ça n’aurait pas vraiment de sens (on rappelle que le but de la manœuvre et d'empêcher des gens de générer des certificats pour des sous domaine de votre domaine) sinon.

Créer une liste exhaustive de tous les sous domaines possibles me semble complexe ;-).

L’astuce, que vous ne trouverez pas dans la documentation (en tout cas dans les pages que j’ai lues), est de créer un recordset avec comme nom « @ » (j’avais testé, vide, « * », « . », mais pas « @ »...).

Et là, un recordset sera créé pour l’ensemble de votre zone DNS (**zwindler.fr** dans mon exemple).

Magie-magie...

## Liens utiles

  * [Un site pour tester son site en HTTPS (Qualys)][5]
  * [Un site pour générer les CAA records (SSLmate)][6]

 [2]: /2018/06/caa01.png
 [3]: https://docs.microsoft.com/en-us/cli/azure/network/dns/record-set/caa?view=azure-cli-latest
 [4]: https://docs.microsoft.com/fr-fr/azure/dns/dns-operations-recordsets
 [5]: https://www.ssllabs.com/ssltest/
 [6]: https://sslmate.com/caa/
