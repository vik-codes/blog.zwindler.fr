---
title: '[Tutoriel] Installer Prometheus/Grafana sans Docker'
authors:
  - zwindler
type: post
date: 2019-11-12T07:30:45+00:00
excerpt: Tutoriel pas à pas pour installer un Prometheus et un Grafana sur un serveur Linux et sans utiliser Docker
url: /2019/11/12/tutoriel-installer-prometheus-grafana-sans-docker/
image: /2019/11/grafana_prometheus_proxmox.png
categories:
  - Monitoring
  - Système
  - Virtualisation
tags:
  - Docker
  - grafana
  - Kubernetes
  - monitoring
  - prometheus
  - Supervision

---

## Prometheus et Grafana dans Docker, quelle horreur ?
  
  
Je sais que certains d’entre vous ne sont pas super fan (euphémisme) de la technologique containers Docker (et je ne parle même pas de Kubernetes, cf [Concerning Kubernetes](/2019/09/03/concerning-kubernetes-combien-de-problemes-ces-stacks-ont-generes/)). Pour autant, pas besoin de Docker pour avoir besoin du couple Prometheus / Grafana.

  
Prometheus a plein de features sympas (notamment l’auto discovery, le langage de requêtage PromQL, ...). De son côté, Grafana est vraiment top pour ce qui est visualisation rapide provenant de plusieurs sources de données.

  
Peut être même que vous avez du Docker (ou même Kubernetes) mais que vous n’avez pas envie d’intégrer la supervision dans votre infra de compute.

  
Il y a plein de bonnes raisons pour ça, comme ne pas vouloir héberger la supervision sur l’infra qu’elle est censé surveillée ou encore pour des problématiques de performances, ...

  
Avec Docker, lancer Prometheus ou Grafana se fait en une ligne de commande, c’est pour ça qu’on voit cette manière de faire partout. Sans Docker, c’est nécessairement un poil plus compliqué (mais à peine) à faire. Et c’est pourquoi je fais ce petit tuto rapide.



## Prometheus
  
  
Dans ce tuto, on va partir des sources. Pour [Prometheus](https://prometheus.io/download/), vous pourrez trouver un raccourci vers la dernière version [sur le site officiel](https://prometheus.io/download/).

  
On télécharge cette version et on configure un utilisateur exécuter Prometheus


```
wget https://github.com/prometheus/prometheus/releases/download/v2.13.1/prometheus-2.13.1.linux-amd64.tar.gz
tar xzf prometheus-2.13.1.linux-amd64.tar.gz
sudo mv prometheus-2.13.1.linux-amd64/ /usr/share/prometheus

sudo useradd -u 3434 -d /usr/share/prometheus -s /bin/false prometheus
sudo mkdir -p /var/lib/prometheus/data
sudo chown prometheus:prometheus /var/lib/prometheus/data
sudo chown -R prometheus:prometheus /usr/share/prometheus
```



Une fois que c’est fait, le mieux c’est de tester que Prometheus "fonctionne" correctement en le lançant à la main pour voir si le logiciel se lance bien, avec la configuration par défaut.


```
/usr/share/prometheus/prometheus --config.file=/usr/share/prometheus/prometheus.yml
[...]
level=info ts=2019-09-20T14:56:18.244Z caller=main.go:768 msg="Completed loading of configuration file" filename=/usr/share/prometheus/prometheus.yml
level=info ts=2019-09-20T14:56:18.244Z caller=main.go:623 msg="Server is ready to receive web requests."
```



Ici tout s’est bien passé, on peut donc le couper (Ctrl-C) et créer un script SystemD pour pouvoir le démarrer automatiquement avec le serveur.


```
sudo vi /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=prometheus
Restart=on-failure
WorkingDirectory=/usr/share/prometheus
ExecStart=/usr/share/prometheus/prometheus --config.file=/usr/share/prometheus/prometheus.yml

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus
```

## Grafana
  
  
Maintenant que c’est fait, on passe à Grafana. Vous allez voir, ça va aussi vite.

  
Dans le cas de Grafana, [la méthode mise en avant sur le site officiel](https://grafana.com/grafana/download) est l’utilisation des packages systèmes (".deb" pour Debian ou Ubuntu, RPM pour CentOS). Par souci de cohérence dans l’article, je ne vais pas utiliser le .deb et installer le binaire précompilé pour l’installer de la même manière que Prometheus. Cependant, le .deb aurait très bien fait l’affaire (et ça ira plus vite si vous êtes pressés).

  
On télécharge donc la version précompilée, on positionne les bons dossiers/binaires/fichiers de config aux bons endroits.


```
wget https://dl.grafana.com/oss/release/grafana-6.4.4.linux-amd64.tar.gz
tar -xzf grafana-6.4.4.linux-amd64.tar.gz

sudo useradd -d /usr/share/grafana -s /bin/false grafana
sudo mkdir -p /var/lib/grafana/plugins /etc/grafana /var/log/grafana
sudo chown -R grafana:grafana /var/lib/grafana

sudo mv grafana-6.4.4/ /usr/share/grafana
sudo cp /usr/share/grafana/bin/grafana-server /usr/sbin/
sudo cp /usr/share/grafana/conf/sample.ini /etc/grafana/grafana.ini
```



On configure systemD puis on démarre le service.


```
sudo vi /etc/default/grafana-server
GRAFANA_USER=grafana
GRAFANA_GROUP=grafana
GRAFANA_HOME=/usr/share/grafana
LOG_DIR=/var/log/grafana
DATA_DIR=/var/lib/grafana
MAX_OPEN_FILES=10000
CONF_DIR=/etc/grafana
CONF_FILE=/etc/grafana/grafana.ini
RESTART_ON_UPGRADE=true
PLUGINS_DIR=/var/lib/grafana/plugins
PROVISIONING_CFG_DIR=/etc/grafana/provisioning
PID_FILE_DIR=/var/run/grafana
```


```
sudo vi /etc/systemd/system/multi-user.target.wants/grafana-server.service
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target
After=postgresql.service mariadb.service mysql.service

[Service]
EnvironmentFile=/etc/default/grafana-server
User=grafana
Group=grafana
Type=simple
Restart=on-failure
WorkingDirectory=/usr/share/grafana
RuntimeDirectory=grafana
RuntimeDirectoryMode=0750
ExecStart=/usr/sbin/grafana-server                                                  \
                            --config=${CONF_FILE}                                   \
                            --pidfile=${PID_FILE_DIR}/grafana-server.pid            \
                            cfg:default.paths.logs=${LOG_DIR}                       \
                            cfg:default.paths.data=${DATA_DIR}                      \
                            cfg:default.paths.plugins=${PLUGINS_DIR}                \
                            cfg:default.paths.provisioning=${PROVISIONING_CFG_DIR}


LimitNOFILE=10000
TimeoutStopSec=20
UMask=0027

[Install]
WantedBy=multi-user.target
```


```
systemctl start grafana-server
systemctl enable grafana-server
systemctl status grafana-server
[...]
Nov 10 15:40:17 nostromo grafana-server[14606]: t=2019-11-10T15:40:17+0000 lvl=info msg="Initializing Stream Manager"
Nov 10 15:40:17 nostromo grafana-server[14606]: t=2019-11-10T15:40:17+0000 lvl=info msg="HTTP Server Listen" logger=http.server address=0.0.0.0:3000 protocol
```


## On cable le tout ensemble
  
  
Vous avez vu, je vous avais pas menti, c’est assez simple en fait.

  
Maintenant que Prometheus et Grafana tournent, on va les coufigurer pour qu’ils parlent ensemble.

  
Tout se passe sur l’interface d’administration de Grafana, qui devrait maintenant être accessible à l’URL http://@IP_de_votre_serveur:3000

  
Authentifiez vous en tant qu’administrateur. Par défaut à la première instanciation, seul un compte "admin" est créé, avec le mot de passe hautement sécurisé "admin". Heureusement on change ça tout de suite...

  
La dernière étape consiste à simplement se rendre dans la partie administration de Grafana, puis de créer un source de données.

![](/2019/11/grafana_data_source.png)

Il existe de nombreuses sources de données différentes. Nous dans notre cas, c’est bien une source de type Prometheus qu’on veut créer.

Renseignez simplement l’URL d’accès à Prometheus (par défaut http://localhost:9090 dans ce tutoriel) et sauvez.

A partir de maintenant, vous avez un couple Prometheus / Grafana fonctionnel. Vous allez pouvoir commencer à créer des Dashboard.

![](/2019/11/grafana_prometheus_proxmox.png) 

Enjoy !
