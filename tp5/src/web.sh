#!/bin/bash

error=0
#Désactivation de SELinux:
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

#On vérifie que ce soit bien désactivé:
if [ $? -eq 0 ]
then
  echo "SELINUX désactivé"
else
  error=$(( error + 1 ))
  echo "SELINUX toujours actif"
fi


#Modification du hostname:
hostnamectl set-hostname  web.tp5.linux

#Installation apache:
dnf install httpd -y

if [ $? -eq 0 ]
then
  echo "Apache installé"
else
  error=$(( error + 1 ))
  echo "Problème lors de l'installation d'Apache"
fi

#On démarre apache et on le démarrage au démarrage de la machine
systemctl start httpd
systemctl enable httpd

#On ajoute le port au firewall
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --reload



#Installation de PHP:
dnf config-manager --set-enabled crb
dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
dnf module list php -y
dnf module enable php:remi-8.1 -y
dnf install -y php81-php
dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp


#On vérifie l'installation de PHP:
if [ $? -eq 0 ]
then 
  echo "PHP installé"
else
  error=$(( error + 1 ))
  echo "Problème lors de l'installation de PHP"
fi


#Installation de nextcloud:
mkdir -p /var/www/tp5_nextcloud/
curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip --output /var/www/tp5_nextcloud/nextcloud.zip
if [ $? -eq 0 ]
then
  echo "Nextcloud téléchargé"
else
  error=$(( error + 1 ))
  echo "Nextcloud Non téléchargé"
fi

#Installation de unzip pour extraire nextcloud.zip:
dnf install unzip -y
#Exctraction de nextcloud:
unzip /var/www/tp5_nextcloud/nextcloud.zip -d /var/www/tp5_nextcloud/
if [ $? -eq 0 ]
then 
  echo "Nextcloud extrait"
else
  error=$(( error + 1 ))
  echo "Problème d'extraction"
fi

cp /home/mat/tp5.conf /etc/httpd/conf.d/tp5.conf

systemctl restart httpd
if [ $? -eq 0 ]
then 
  echo "Apache reconfiguré pour Nextcloud"
else
  error=$(( error + 1 ))
  echo "Apache non configuré pour Nextcloud"
fi


if [[ "${error}" == 0 ]]
then 
  echo "Tout est configuré"
else
  echo "Problème lors de la configuration"
fi