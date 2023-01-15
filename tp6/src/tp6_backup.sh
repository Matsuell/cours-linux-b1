#!/bin/bash

#On récupère la date
date=`date +"%y%m%d%H%M%S"`

#On définit le nom du fichier
filename=nextcloud-backup_$date.zip

#Activer le mode maintenance de nexctloud
sed -i "s/'maintenance' => false,/'maintenance' => true,/" /var/www/tp5_nextcloud/config/config.php

#Archivez le dossier nextcloud
cd /srv/backup
zip -r $filename /var/www/tp5_nextcloud > /dev/null

#Désactiver le mode maintenance de nextcloud
sed -i "s/'maintenance' => true,/'maintenance' => false,/" /var/www/tp5_nextcloud/config/config.php

echo "Zip folder available /srv/backup/$filename"


#Ce script permet de créer une archive de toutes les données de nextcloud
#que l'on pourra réutiliser si jamais le serveur web ne fonctionnait plus
#On active le mode maintenance sur nextcloud puis on archive le dossier
#nextcloud puis on désactive le mode maintenance
#Scriptécrit le 10/01/2023 par Mathéo Lang
