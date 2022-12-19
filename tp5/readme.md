# Partie 1 : Mise en place et maîtrise du serveur Web

Dans cette partie on va installer le serveur web, et prendre un peu la maîtrise dessus, en regardant où il stocke sa conf, ses logs, etc. Et en manipulant un peu tout ça bien sûr.

On va installer un serveur Web très très trèèès utilisé autour du monde : le serveur Web Apache.

- [Partie 1 : Mise en place et maîtrise du serveur Web](#partie-1--mise-en-place-et-maîtrise-du-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)

![Tipiii](../pics/linux_is_a_tipi.jpg)

## 1. Installation

🌞 **Installer le serveur Apache**

```
[mat@web ~]$ sudo dnf install httpd -y
```

```
[mat@web ~]$ sudo vim /etc/httpd/conf/httpd.conf
:g/^ *#.*/d
```

🌞 **Démarrer le service Apache**

```
[mat@web ~]$ sudo systemctl start httpd
[sudo] password for mat:
[mat@web ~]$ sudo systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
```

```
[mat@web ~]$ sudo ss -altnp | grep httpd
#On récupère le port sur lequel apache écoute.
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=11189,fd=4),("httpd",pid=11188,fd=4),("httpd",pid=11187,fd=4),("httpd",pid=11185,fd=4))
```

```
#On ajoute le port 80 au firewall.
[mat@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[mat@web ~]$ sudo firewall-cmd --reload
success
[mat@web ~]$ sudo firewall-cmd --list-all | grep ports:
  ports: 22/tcp 80/tcp
  forward-ports:
  source-ports:
```

🌞 **TEST**

```
[mat@web ~]$ systemctl status httpd | grep Active
#On check le status du service httpd.
     Active: active (running) since Mon 2022-12-12 14:44:18 CET; 14min ago
```

```
[mat@web ~]$ sudo systemctl is-enabled httpd
#On verifie que le service démarre bien au lancement de la machine.
enabled

[mat@web ~]$ curl localhost | grep apache
#On vérifie qu'on joint bien le serveur .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--    100  7620  100  7620    0     0  1240k      0 --:--:-- --:--:-- --:--:-- 1240k
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
```

```
matsu@Matsuel_Ynov MINGW64 ~
$ curl 10.105.1.11:80 | grep apache
#On vérifie que la page soit accessible depuis le pc
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  2851k      0 --:--:-- --:--:-- --:--:-- 3720k
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />

```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

```
[mat@web ~]$ sudo cat /etc/systemd/system/multi-user.target.wants/httpd.service | grep Description
Description=The Apache HTTP Server
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

```
[mat@web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep ^User
#On vérifie l'utilisateur qui utilise apache
User apache
```

```
[mat@web ~]$ ps -ef | grep apache
apache     11186   11185  0 14:44 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache     11187   11185  0 14:44 ?        00:00:01 /usr/sbin/httpd -DFOREGROUND
apache     11188   11185  0 14:44 ?        00:00:01 /usr/sbin/httpd -DFOREGROUND
apache     11189   11185  0 14:44 ?        00:00:01 /usr/sbin/httpd -DFOREGROUND
apache     11513   11185  0 15:10 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
mat        11654    1245  0 15:29 pts/0    00:00:00 grep --color=auto apache
```

```
[mat@web ~]$ ls -al /usr/share/testpage/
#Tout le monde peut lire les fichiers dans testpage.
total 12
drwxr-xr-x.  2 root root   24 Dec 12 14:33 .
drwxr-xr-x. 82 root root 4096 Dec 12 14:33 ..
-rw-r--r--.  1 root root 7620 Jul 27 20:05 index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

```
[mat@web ~]$ sudo useradd tp5-apache -d /usr/share/httpd/ -s /sbin/nologin
useradd: warning: the home directory /usr/share/httpd/ already exists.
useradd: Not copying any file from skel directory into it.
Creating mailbox file: File exists
```

```
[mat@web ~]$ sudo nano /etc/httpd/conf/httpd.conf
#On change l'user qui utilise apache
User tp5-apache

[mat@web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep ^User
User tp5-apache
```

```
[mat@web ~]$ ps -ef | grep tp5-apache
#Le service tourne bien sous tp5-apache
mat        12001    1245  0 15:52 pts/0    00:00:00 grep --color=auto tp5-apache
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

```
[mat@web ~]$ sudo nano /etc/httpd/conf/httpd.conf
Listen 12005
```

```
#On ajoute le port 12005 et on supprime le port 80.
[mat@web ~]$ sudo firewall-cmd --add-port=12005/tcp --permanent
success
[mat@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[mat@web ~]$ sudo firewall-cmd --reload
success
[mat@web ~]$ sudo firewall-cmd --list-all | grep 12005
  ports: 22/tcp 12005/tcp
```

```
[mat@web ~]$ sudo systemctl restart httpd
```

```
[mat@web ~]$ sudo ss -alnpt | grep 12005
#Le service écoute bien sur le port 12005
LISTEN 0      511                *:12005            *:*    users:(("httpd",pid=12078,fd=4),("httpd",pid=12077,fd=4),("httpd",pid=12076,fd=4),("httpd",pid=12073,fd=4))
```

```
[mat@web ~]$ curl localhost:12005 | grep apache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--    100  7620  100  7620    0     0  2480k      0 --:--:-- --:--:-- --:--:-- 2480k
        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />
```

```
matsu@Matsuel_Ynov MINGW64 ~
$ curl 10.105.1.11:12005 | grep apache
#DEpuis mon pc 
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0        <a href="https://httpd.apache.org/">Apache Webserver</strong></a>:
100  7620  100  7620    0     0  3622k      0 --:--:-- --:--:-- --:--:-- 7441k      <a href="https://apache.org">Apache&trade;</a> is a registered trademark of <a href="https://apache.org">the Apache Software Foundation</a> in the United States and/or other countries.<br />

```

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

[Httpd.conf](./src/httpd.conf)



# Partie 2 : Mise en place et maîtrise du serveur de base de données

🖥️ **VM db.tp5.linux**

🌞 **Install de MariaDB sur `db.tp5.linux`**

```
[mat@db ~]$ sudo dnf install mariadb-server -y
#On installe mariadb client sur db
```

```
[mat@db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.
```

```
[mat@db ~]$ sudo systemctl start mariadb
```

```
[mat@db ~]$ sudo mysql_secure_installation
#Puis Y à chaques questions
```

🌞 **Port utilisé par MariaDB**

```
[mat@db ~]$ sudo ss -alntp | grep mariadb
#On regarde sur quel port écoute mariadb.
LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=4392,fd=19))
```
```
#On ajoute Le port 3306 dans le firewall.
[mat@db ~]$ sudo firewall-cmd --add-port=3306/tcp --permanent
success
[mat@db ~]$ sudo firewall-cmd --reload
success
[mat@db ~]$ sudo firewall-cmd --list-all | grep ports:
  ports: 22/tcp 3306/tcp
  forward-ports:
  source-ports:
```
🌞 **Processus liés à MariaDB**

```
[mat@db ~]$ ps -ef | grep mariadb
mysql       4392       1  0 16:12 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
mat         4644    1222  0 16:19 pts/0    00:00:00 grep --color=auto mariadb
```

```
[mat@db ~]$ ps -ef | grep mariadb
mysql       4392       1  0 16:12 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
mat         4644    1222  0 16:19 pts/0    00:00:00 grep --color=auto mariadb
```

# Partie 3 : Configuration et mise en place de NextCloud


## 1. Base de données

🌞 **Préparation de la base pour NextCloud**

```
[mat@db ~]$ sudo mysql -u root -p
```

```
MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)
```

🌞 **Exploration de la base de données**

```
[mat@web ~]$ sudo dnf install mariadb
#On installe mariadb client sur web
```

```
[mat@web ~]$ mysql -u nextcloud -h 10.105.1.12 -p -D nextcloud
```

```
MariaDB [nextcloud]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.001 sec)

MariaDB [nextcloud]> USE nextcloud;
Database changed
MariaDB [nextcloud]> SHOW TABLES;
Empty set (0.001 sec)
```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

```
DEPUIS web:
MariaDB [nextcloud]> select user,host from mysql.user;
ERROR 1142 (42000): SELECT command denied to user 'nextcloud'@'10.105.1.11' for table 'user'
```

```
DEPUIS db:

MariaDB [(none)]> select user,host from mysql.user;
+-------------+-------------+
| User        | Host        |
+-------------+-------------+
| nextcloud   | 10.105.1.11 |
| mariadb.sys | localhost   |
| mysql       | localhost   |
| root        | localhost   |
+-------------+-------------+
4 rows in set (0.001 sec)
```
## 2. Serveur Web et NextCloud

🌞 **Install de PHP**

```
[mat@web ~]$ sudo dnf config-manager --set-enabled crb
[mat@web ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
[mat@web ~]$ dnf module list php
[mat@web ~]$ sudo dnf module enable php:remi-8.1 -y
[mat@web ~]$ sudo dnf install -y php81-php
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```
[mat@web ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 **Récupérer NextCloud**

```
[mat@web ~]$ sudo mkdir -p /var/www/tp5_nextcloud
```

```
[mat@web ~]$ sudo curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip --output /var/www/tp5_nextcloud/nextcloud.zip
```

```
[mat@web ~]$ sudo dnf install unzip -y
[mat@web ~]$ unzip /var/www/tp5_nextcloud/nextcloud.zip    
[mat@web tp5_nextcloud]$ sudo mv ~/nextcloud/* ../tp5_nextcloud/    
```

```
[mat@web ~]$ ls -al /var/www/tp5_nextcloud/
[mat@web ~]$ ls  /var/www/tp5_nextcloud/ | grep index.html
index.html
```

🌞 **Adapter la configuration d'Apache**

```
[mat@web ~]$ sudo nano /etc/httpd/conf.d/tp5.conf

<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>

```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

![NextCloud error](../pics/nc_install.png)

## 3. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- modifiez votre fichier `hosts` (oui, celui de votre PC, de votre hôte)
  - pour pouvoir joindre l'IP de la VM en utilisant le nom `web.tp5.linux`
- avec un navigateur, visitez NextCloud à l'URL `http://web.tp5.linux`
  - c'est possible grâce à la modification de votre fichier `hosts`
- on va vous demander un utilisateur et un mot de passe pour créer un compte admin
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

- connectez vous en ligne de commande à la base de données après l'installation terminée
- déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation
  - ***bonus points*** si la réponse à cette question est automatiquement donnée par une requête SQL


# Partie 4: Automatiser la résolution du TP

## Web :

[Script Web](./src/web.sh)
[Conf Httpd](./src/tp5.conf)

## Db:

[Script DB](./src/db.sh)
[Conf Db nextcloud](./src/nextcloud.sql)