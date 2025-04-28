---
title: Superviser des onduleurs/UPS avec Nagios/Centreon et SNMP
authors:
  - zwindler
type: post
date: 2017-01-17T13:00:52+00:00
url: /2017/01/17/superviser_ups_centreon_snmp/
image: /2016/12/ups.jpg
categories:
  - Monitoring
tags:
  - Centreon
  - monitoring
  - Nagios
  - Shinken
  - snmp
  - UPS

---
## Être alerté par l’onduleur en SNMP

Il n’est pas rare que les onduleurs (ou Uninterrupted Power Supply chez nos amis anglosaxons), même sans être très haut de gamme, disposent de sortie Ethernet permettant de superviser l’état de l’onduleur, sa charge, ...

Généralement, ce genre d’onduleur est également livré avec des clients propriétaires qui vous permettent de configurer la partie réseau de l’onduleur, puis ensuite de définir des alertes, voire des actions à réaliser lorsque l’onduleur commence à se décharger. Cependant, dans un environnement un tant soit peu industrialisé, ce genre d’outil est rarement pratique :

  * Il y a généralement déjà un outil de supervision en place, et en ajouter un va à l’encontre de l’efficacité pour les équipes support. Des consoles de supervision doivent être installés sur les postes des administrateur.
  * Les agents pour éteindre les serveurs alimentés doivent être installés (ce qui induit une tâche d’exploitation/maintenance supplémentaire), parfois en s’appuyant sur des versions hors d’age de Java comme dépendance, et avec bien peu de support une fois que le produit est chez vous.

Heureusement, la plupart des onduleurs exposent également une MIB SNMP standard, que vous pouvez donc très simplement ajouter pour réaliser vous même votre propre supervision. Et même pourquoi pas votre propre agent d’extinction, en se basant sur un script ainsi qu’un agent déjà présent sur les machines pour la supervision (NSClient/NRPE pour moi).

Pour trouver cette MIB (.1.3.6.1.4.1.21111.1.1, originalement nommée UPS), j’ai tout simplement utiliser un _snmpwalk_ sous Unix en me connectant à l’adresse IP de l’onduleur après configuration. Sous Windows, on peut aussi utiliser un utilitaire graphique pour faire la même chose, notamment avec iReasoning MIB Browser qui nous donne également quelques informations sur les indicateurs disponibles.

![](/2016/11/ups2.png)

> MIB Browser donne des informations sur la MIB de manière graphique, ce qui peut être plus lisible qu’un simple snmpwalk

## Quoi surveiller ?

Les indicateurs de la MIB UPS qui m’ont parus les plus opportuns à surveiller sont les suivants :

  * **upsBatStatus (.1.3.6.1.4.1.21111.1.1.3.1.0)** : L’état de la batterie qui peut être chargé ou en cours de déchargement. Tout ce qui n’est pas 2 est inquiétant.
  * **upsBatEstChargeRemaining (.1.3.6.1.4.1.21111.1.1.3.4.0)** : L’estimation de la charge restant de la batterie en %age. Si on descend sous 90% c’est que l’onduleur se décharge et que ce n’est pas une microcoupure !
  * **upsBatEstMinutesRemaining (.1.3.6.1.4.1.21111.1.1.3.3.0)** : L’estimation du temps restant avant que la batterie soit épuisée. Je trouve cet indicateur pratique pour 2 raisons 
      * On peut lancer des actions d’urgence (ssh + shutdown sur tous les linux) à partir d’un certain temps avant l’épuisement plutôt qu’un pourcentage, car on peut estimer que 5 minutes avant l’échéance, on aura plus le temps de rétablir avant coupure. Ce qui est plus difficile à fixer en pourcentage.
      * On peut éventuellement détecter un problème sur les batteries ou sur la charge de l’onduleur si en fonctionnement normal (sur secteur) on se retrouve avec un temps de charge trop bas.
  * **upsBatSecondsOnBattery (.1.3.6.1.4.1.21111.1.1.3.2.0)** : Le nombre de secondes depuis que l’onduleur est sur batterie et n’est donc plus sur secteur. Si on dépasse 0, c’est mauvais signe mais pour éviter les alertes intempestives j’ai mis 2.

Et comme je suis sympa, je vous passe la configuration Nagios/Centreon (ou tout autre produit compatible) associée qui vous permettra d’obtenir les indicateurs en question sans effort. Enjoy !

![](/2016/11/ups.png)

```
define command {
    command_name                   check_snmp
    command_line                   $USER1$/check_snmp -H $HOSTADDRESS$ -o $ARG1$ -w $ARG2$ -c $ARG3$
}

define service {
    service_description            Template_par_défaut_pour_tous_les_serivces
    name                           generic-service
    contacts                       generic-contact
    check_period                   24x7
    notification_period            24x7
    max_check_attempts             5
    check_interval                 5
    retry_interval                 5
    notification_interval          15
    notification_options           w,u,c
    first_notification_delay       0
    register                       0
    notifications_enabled          1
}

define service {
    service_description            2_tentatives_et_interval_de_5_minutes_en_24_7
    name                           2retry_5min_24x7
    check_period                   24x7
    max_check_attempts             2
    check_interval                 5
    retry_interval                 5
    notification_interval          5
    register                       0
    use                            generic-service
}

define service {
    service_description            Check_SNMP_upsBatStatus
    name                           snmp_upsBatStatus
    check_command                  check_snmp!.1.3.6.1.4.1.21111.1.1.3.1.0!2!2
    register                       0
    use                            2retry-5min-24x7
}

define service {
    service_description            Check_SNMP_upsBatEstChargeRemaining
    name                           snmp_upsBatEstChargeRemaining
    check_command                  check_snmp!.1.3.6.1.4.1.21111.1.1.3.4.0!90:!80:
    register                       0
    use                            2retry-5min-24x7
}

define service {
    service_description            Check_SNMP_upsBatEstMinutesRemaining
    name                           snmp_upsBatEstMinutesRemaining
    check_command                  check_snmp!.1.3.6.1.4.1.21111.1.1.3.3.0!30:!20:
    register                       0
    use                            2retry-5min-24x7
}

define service {
    service_description            Check_SNMP_upsBatSecondsOnBattery
    name                           snmp_upsBatSecondsOnBattery
    check_command                  check_snmp!.1.3.6.1.4.1.21111.1.1.3.2.0!2!2
    register                       0
    use                            2retry-5min-24x7
}
```
