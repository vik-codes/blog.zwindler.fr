---
title: Superviser votre instance Jitsi avec Prometheus et Grafana
authors:
  - zwindler
type: post
date: 2020-06-08T06:35:00+00:00
excerpt: Tutoriel pour ajouter une brique de supervision applicative à un serveur de visioconférence open source Jitsi
url: /2020/06/08/superviser-votre-instance-jitsi-avec-prometheus-et-grafana/
image: /2020/04/10participants.png
categories:
  - autohebergement
  - Monitoring
  - Système
tags:
  - grafana
  - Jitsi
  - Jitsi Meet
  - Jitsi Videobridge
  - monitoring
  - prometheus
  - Supervision

---

## Quel rapport entre Jitsi et Prometheus ?
  
  
Si vous avez suivi un peu mes articles depuis le début du confinement, vous aurez vu qu’en ce moment je fais du Jitsi (cf [Ta visio Open Source comme un pro avec Jitsi](/2020/03/17/ta-visio-open-source-comme-un-pro-avec-jitsi/)) et du Prometheus (cf [Découvrir Prometheus et Grafana par l’exemple](/2020/04/13/decouvrir-prometheus-et-grafana-par-lexemple/)).

Et ça tombe super bien, car aujourd’hui je vais vous parler des deux !


## L’appel des Chatons
  
  
J’ai pas trop communiqué là dessus, mais lorsque le confinement a commencé, les ENT étant down, beaucoup d’enseignants se sont tournés vers Framasoft, qui héberge entre autre des services d’éditions de texte en collaboratif ainsi que des instances de visio conférences Jitsi.

Ça a pas mal râlé côté Framasoft car ça fait des années qu’ils expliquent qu’en tant qu’association 1901, ils n’ont ni les moyens ni l’envie de supporter les conséquences des mauvais choix technologiques / budgétaires de l’éducation nationale. (Si vous voyez pas trop où que je veux en venir, allez voir leur site, ils l’expliquent mieux que moi). Et de fermer ces deux services temporairement dans la foulée.

Suite à quoi, les CHATONS se sont proposés de faire le relais en listant un ensemble de services Jitsi et Etherpad mis à dispositions par des CHATONS et des particuliers (et maintenant plus encore).

![](/2020/04/framasoft_jitsi_chatons.png)


J’ai pas trop communiqué là dessus, mais moi aussi j’ai mis mon instance à dispo.



![](/2020/04/chaton.png) 

> Coucouuuuuu, je suis là !! 


## Et alors, des gens s’en servent ?
  
  
C’est super cool, j’ai mis à dispo une instance jitsi qui a priori a été utile à plusieurs personnes.


![](/2020/04/jitsi_croixrouge_be.png)

Mais jusqu’à présent, au delà du trafic CPU/réseau que je vois monter de temps en temps, je n’avais aucune idée de la quantité de conférences qui se tenaient sur mon instance.

Puis, j’ai vu ce tweet de pyg, qui m’a relancé sur le sujet.

![](/2020/04/pyg_jitsi.png)

> Ouuuaaaah, la classe :D 

A vue de nez, c’est du Grafana. J’ai donc voulu trouver comment brancher Jitsi à ma supervision existante.

## Deux exporters pour le prix d’un

La première chose à faire était donc de trouver un exporter prometheus compatible avec Jitsi, histoire de pouvoir capitaliser sur l’infrastructure (Grafana/Prom) actuelle.

J’ai trouvé 2 projets en Go :
  
* jitsi-prom-exporter dont j’ai trouvé la trace sur [le forum de jitsi](https://community.jitsi.org/t/monitoring-jvb-metrics-prometheus-grafana/19822)
* [jitsiexporter](https://github.com/xsteadfastx/jitsiexporter)
      
  
Les deux n’étant pas franchement bien documentés (et je suis une quiche en Go), je me suis d’abord orienté vers jitsi-prom-exporter, plus "connu" (enfin, ça se joue à 10 étoiles sur Github hein...).

Mais je n’ai jamais réussi à le compiler (vive le Go) et comme je n’y comprend rien après avoir ragé quelques heures (ma femme confirme) j’ai laissé tombé. [Edit]En vrai j’ai fini par le faire marché avec de l’aide et beaucoup de trial and error mais bon... Il faut faire [ça](https://github.com/karrieretutor/jitsi-prom-exporter/issues/3#issuecomment-614512142), [ça](https://github.com/karrieretutor/jitsi-prom-exporter/issues/3#issuecomment-614651103) puis [ça](https://github.com/karrieretutor/jitsi-prom-exporter/issues/3#issuecomment-614909928) [/Edit]

En revanche, [jitsiexporter](https://github.com/xsteadfastx/jitsiexporter), j’ai réussi à le faire fonctionner assez vite ! Et je vous propose qu’on se l’installe ensemble !

## Activer les statistiques

La première chose à faire et de vérifier dans votre install de Jitsi si l’API REST est activée ou non. Si ce n’est pas le cas, vous pouvez tenter de modifier les propriétés du sip-communicator de videobridge.

```
ps -ef | grep jvb
jvb        164     1  0 20:09 ?        00:00:56 java -Xmx3072m [...] --apis=rest,
```

Pour être honnête, je ne suis pas encore bien bien sûr à 100% ce qu’il faut faire pour être sûr que c’est actif. La documentation du projet Github de l’exporter n’est pas hyper claire et j’ai lu pas mal d’instruction contradictoire sur les forums...

En fin d’article, je vous ai mis deux liens vers la doc officielle de Jitsi à ce sujet.

```
vi /etc/jitsi/videobridge/sip-communicator.properties
[...]
org.jitsi.videobridge.ENABLE_STATISTICS=true
org.jitsi.videobridge.STATISTICS_TRANSPORT=muc,colibri
org.jitsi.videobridge.STATISTICS_INTERVAL=1000
```

Une fois que c’est bon, un petit curl` vous permettra de vous assurer que tout va bien.

```
curl http://127.0.0.1:8080/colibri/stats
{"inactive_endpoints":0,"inactive_conferences":0,"total_ice_succeeded_relayed":0,"total_loss_degraded_participant_seconds":0,"bit_rate_download":0,"muc_clients_connected":1,"total_participants":0,...
```

## Installer l’exporter

Maintenant que notre Jitsi nous donne bien des statistiques en local, on va pouvoir commencer à utiliser un exporter pour consommer les métriques périodiquement et les servir au format Prometheus.

### Prérequis pour la compilation
  
D’abord il nous faut go... Sur un Ubuntu 18.04 ça donne ça :

```
sudo apt update
sudo apt install software-properties-common

sudo add-apt-repository ppa:longsleep/golang-backports
sudo apt update
sudo apt install golang-go git
```

### Compiler
  
  
Ensuite, il faut compiler l’exporter. En théorie, comme Go fait des binaires "qui marchent partout", vous pouvez compiler l’exporter sur votre poste et envoyer le binaire sur le serveur jitsi. En théorie...


```
su - jvb
mkdir -p go/src && mkdir -p go/bin
cd go/src
git clone https://github.com/xsteadfastx/jitsiexporter
cd jitsiexporter
go get ./...
```

Si tout se passe bien, un binaire est créé dans `~/go/bin`

## Tester l’exporter
  
  
Maintenant qu’on a un exporter, on va le tester en le lançant à la main, pour valider toute la chaîne. Les paramètres sont assez simples. Il faut renseigner d’un côté l’URL du serveur REST et de l’autre adresse/port sur lesquels on veut que l’exporter accepte les requêtes de Prometheus.

Par défaut c’est localhost donc il est fort probable que vous vouliez changer ça.

```
/usr/share/jitsi-videobridge/go/bin/jitsiexporter --url='http://127.0.0.1:8080/colibri/stats' --host=192.168.1.100 --port=9700
```

## Un service pour automatiser le démarrage au... démarrage
  
Comme d’habitude, une fois qu’on a l’exporter qui marche oneshot, le mieux c’est quand même d’avoir un service systemd` qui va nous faciliter le démarrage/l’extinction du service :

```
cat > /etc/systemd/system/jitsiexporter.service << EOF
[Unit]
Description=Jitsi videobridge Prometheus Exporter
After=jitsi-videobridge2.service
Requires=jitsi-videobridge2.service

[Service]
User=jvb
Restart=on-failure
ExecStart=/usr/share/jitsi-videobridge/go/bin/jitsiexporter --url='http://127.0.0.1:8080/colibri/stats' --host=192.168.1.100 --port=9700

[Install]
WantedBy=multi-user.target
EOF
```


```
systemctl daemon-reload
systemctl enable jitsiexporter
systemctl start jitsiexporter
```

## Configurer Prometheus
  
  
Vous l’avez compris, il reste donc maintenant à relier Prometheus à notre exporter pour commencer à scrapper des métriques. Ici, il s’agira donc simplement d’ajouter une nouvelle section "job" dans notre configuration de Prometheus et à redémarrer pour prise en compte.

```
vi /usr/share/prometheus/prometheus.yml
[...]
  - job_name: 'jitsi'
    static_configs:
      - targets:
        - 192.168.1.100:9700   # jitsiexporter for jitsi videobridge
```

```
systemctl restart prometheus
```

## Et le résultat ?

Bon, faut avouer que c’est pas foufou, j’ai eu quelques conférences en 2 semaines (pas beaucoup plus d’une par jour), mais un joli score tout de même cette conf d’1h30 avec au max 10 personnes !

![](/2020/04/10participants.png)

Vous savez tout ! Have fun :D

## Sources additionnelles

* [Documentation sur les statistiques sur le site de Jitsi](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md)
* [Documentation sur l’API REST sur le site de Jitsi](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest.md)
      
