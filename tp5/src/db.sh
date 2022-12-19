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

#Installation de mariadb server
dnf install mariadb-server -y
if [ $? -eq 0 ]; then
    echo "MariaDB installé"
else
  error=$(( error + 1 ))
    echo "Problème lors de l'installation de MariaDB"
fi
systemctl start mariadb
systemctl enable mariadb

firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload

mysql -u root < nextcloud.sql
if [ $? -eq 0 ]
then 
  echo "BDD configuré"
else
  error=$(( error + 1 ))
  echo "Pb de configuration de la BDD"
fi

if [[ "${error}" == 0 ]]
then 
  echo "Tout est configuré"
else
  echo "Problème lors de la configuration"
fi
