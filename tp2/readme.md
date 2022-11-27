# TP2 : Appréhender l'environnement Linux

# I. Service SSH

## 1. Analyse du service

🌞 **S'assurer que le service `sshd` est démarré**

```
[mat@tp2-linux ~]$ sstemctl status sshd

● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-11-22 15:19:54 CET; 10min ago
```

🌞 **Analyser les processus liés au service SSH**

```
[mat@tp2-linux ~]$ ps -ef | grep sshd

root         699       1  0 15:19 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         972     699  0 15:25 ?        00:00:00 sshd: mat [priv]
mat          977     972  0 15:26 ?        00:00:00 sshd: mat@pts/0
mat         1057     978  0 15:32 pts/0    00:00:00 grep --color=auto sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

```
[mat@tp2-linux ~]$ sudo ss -alpnt | grep sshd

LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=699,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=699,fd=4))
```

🌞 **Consulter les logs du service SSH**

```
[mat@tp2-linux ~]$ journalctl -xe -u sshd | tail -n 10

░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit sshd.service has finished successfully.
░░
░░ The job identifier is 230.
Nov 22 15:23:53 localhost.localdomain sshd[931]: Accepted password for mat from 10.4.1.1 port 64372 ssh2
Nov 22 15:23:53 localhost.localdomain sshd[931]: pam_unix(sshd:session): session opened for user mat(uid=1000) by (uid=0)
Nov 22 15:26:02 tp2-linux sshd[972]: Accepted password for mat from 10.4.1.1 port 64375 ssh2
Nov 22 15:26:02 tp2-linux sshd[972]: pam_unix(sshd:session): session opened for user mat(uid=1000) by (uid=0)
```

```
[mat@tp2-linux ~]$ sudo cat /var/log/secure | grep sshd | tail -n 10

Nov 22 15:19:54 localhost sshd[699]: Server listening on :: port 22.
Nov 22 15:23:53 localhost sshd[931]: Accepted password for mat from 10.4.1.1 port 64372 ssh2
Nov 22 15:23:53 localhost sshd[931]: pam_unix(sshd:session): session opened for user mat(uid=1000) by (uid=0)
Nov 22 15:25:57 localhost sshd[935]: Received disconnect from 10.4.1.1 port 64372:11: disconnected by user
Nov 22 15:25:57 localhost sshd[935]: Disconnected from user mat 10.4.1.1 port 64372
Nov 22 15:25:57 localhost sshd[931]: pam_unix(sshd:session): session closed for user mat
Nov 22 15:26:02 localhost sshd[972]: Accepted password for mat from 10.4.1.1 port 64375 ssh2
Nov 22 15:26:02 localhost sshd[972]: pam_unix(sshd:session): session opened for user mat(uid=1000) by (uid=0)
Nov 22 15:50:27 localhost sudo[1155]:     mat : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/journalctl -xe -u sshd
Nov 22 15:52:13 localhost sudo[1162]:     mat : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/journalctl -xe -u sshd
```


## 2. Modification du service

Dans cette section, on va aller visiter et modifier le fichier de configuration du serveur SSH.

Comme tout fichier de configuration, celui de SSH se trouve dans le dossier `/etc/`.

Plus précisément, il existe un sous-dossier `/etc/ssh/` qui contient toute la configuration relative au protocole SSH

🌞 **Identifier le fichier de configuration du serveur SSH**

```
[mat@tp2-linux ~]$ ls /etc/ssh | grep sshd

sshd_config
sshd_config.d
```

Celui de configuration est sshd_config.

🌞 **Modifier le fichier de conf**

```
[mat@tp2-linux ~]$echo $RANDOM

16341
```

```
[mat@tp2-linux ~]$ sudo cat /etc/ssh/sshd_config | grep 'Port '

Port 16341
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --remove-port=22/tcp

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=16341/tcp --permanent

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=16341/tcp 

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --list-all | grep -m 1 ports:

ports: 16341/tcp
```

🌞 **Redémarrer le service**

```
[mat@tp2-linux ~]$ sudo systemctl restart sshd
```

🌞 **Effectuer une connexion SSH sur le nouveau port**

```
PS C:\Users\matsu>ssh mat@10.4.1.25 -p 16341
```

✨ **Bonus : affiner la conf du serveur SSH**

```
[mat@tp2-linux ~]$ sudo nano /etc/ssh/sshd_config

PermitRootLogin no
```

```
[mat@tp2-linux ~]$ sudo systemctl restart sshd
```

# II. Service HTTP

## 1. Mise en place

![nngijgingingingijijnx ?](./pics/njgjgijigngignx.jpg)

🌞 **Installer le serveur NGINX**

```
[mat@tp2-linux ~]$ sudo dnf install nginx -y
```

🌞 **Démarrer le service NGINX**

```
[mat@tp2-linux ~]$ sudo systemctl enable nginx

Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
```

```
[mat@tp2-linux ~]$ sudo systemctl start nginx
```

🌞 **Déterminer sur quel port tourne NGINX**

```
[mat@tp2-linux ~]$ sudo ss -alnpt | grep nginx

LISTEN 0      511          0.0.0.0:80         0.0.0.0:*    users:(("nginx",pid=11437,fd=6),("nginx",pid=11436,fd=6))
LISTEN 0      511             [::]:80            [::]:*    users:(("nginx",pid=11437,fd=7),("nginx",pid=11436,fd=7))
```

Le service tourne sur le port 80.

```
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=80/tcp

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=80/tcp --permanent

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --list-all | grep -m 1 ports

ports: 22/tcp 80/tcp
```

🌞 **Déterminer les processus liés à l'exécution de NGINX**

```
[mat@tp2-linux ~]$ ps -ef | grep nginx

root       11436       1  0 16:37 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      11437   11436  0 16:37 ?        00:00:00 nginx: worker process
mat        11464    1556  0 16:43 pts/0    00:00:00 grep --color=auto nginx
```

🌞 **Euh wait**

```
[mat@tp2-linux ~]$ curl 10.4.1.25:80 | head -n 7

<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">

```

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```
[mat@tp2-linux ~]$ ls -al /etc/nginx/nginx.conf

-rw-r--r--. 1 root root 2334 May 16  2022 /etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**

```
[mat@tp2-linux ~]$ cat /etc/nginx/nginx.conf | grep -m 1 'server {' -A 16

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

```

```
[mat@tp2-linux ~]$ cat /etc/nginx/nginx.conf | grep include

include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;
```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

```
[mat@tp2-linux ~]$ sudo mkdir /var/www
```

```
[mat@tp2-linux ~]$ sudo mkdir /var/www/tp2_linux
```

```
[mat@tp2-linux ~]$sudo nano /var/www/html/index.html

<h1>MEOW mon premier serveur web</h1>
```


🌞 **Adapter la conf NGINX**

```
[mat@tp2-linux ~]$echo $RANDOM

32125
```

```
[mat@tp2-linux ~]$ sudo nano /etc/nginx/conf.d/tp2.conf

server {
  listen 32125;

  root /var/www/tp2_linux;
}

```

```
[mat@tp2-linux ~]$ sudo systemctl restart nginx
```

Ensuite faut modiifer le firewall

```
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=32125/tcp --permanent

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=32125/tcp 

success
```

```
[mat@tp2-linux ~]$ sudo systemctl restart firewalld
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --remove-port=80/tcp 

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --reload

success
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --list-all | grep -m 1 ports

ports: 22/tcp 32125/tcp
```

🌞 **Visitez votre super site web**

```
matsu@DESKTOP-6259DEV MINGW64 ~
$curl 10.4.1.25:32125

<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services

## 1. Au cas où vous auriez oublié

## 2. Analyse des services existants

🌞 **Afficher le fichier de service SSH**

```
[mat@tp2-linux ~]$ systemctl status sshd

#On peut récupérer grâce à cette commande l'emplacement du fichier du service sshd (/usr/lib/systemd/system/sshd.service).

● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2022-11-26 14:59:45 CET; 4min 18s ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 696 (sshd)
      Tasks: 1 (limit: 5907)
     Memory: 5.6M
        CPU: 50ms
     CGroup: /system.slice/sshd.service
             └─696 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"

Nov 26 14:59:44 tp2-linux systemd[1]: Starting OpenSSH server daemon...
Nov 26 14:59:44 tp2-linux sshd[696]: Server listening on 0.0.0.0 port 16341.
Nov 26 14:59:44 tp2-linux sshd[696]: Server listening on :: port 16341.
Nov 26 14:59:45 tp2-linux systemd[1]: Started OpenSSH server daemon.
Nov 26 15:02:03 tp2-linux sshd[913]: Accepted password for mat from 10.4.1.1 port 61306 ssh2
```

```
[mat@tp2-linux ~]$ sudo cat /usr/lib/systemd/system/sshd.service | grep ExecStart

#On récupère grâce à cette commande la commande executée lorsqu'on démarre le service sshd

ExecStart=/usr/sbin/sshd -D $OPTIONS
```



🌞 **Afficher le fichier de service NGINX**

```
[mat@tp2-linux ~]$ systemctl status nginx

#On peut récupérer grâce à cette commande l'emplacement du fichier du service sshd (/usr/lib/systemd/system/nginx.service).

● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
     Active: active (running) since Sat 2022-11-26 14:59:45 CET; 13min ago
    Process: 791 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 793 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 797 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 798 (nginx)
      Tasks: 2 (limit: 5907)
     Memory: 3.7M
        CPU: 18ms
     CGroup: /system.slice/nginx.service
             ├─798 "nginx: master process /usr/sbin/nginx"
             └─803 "nginx: worker process"

Nov 26 14:59:45 tp2-linux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Nov 26 14:59:45 tp2-linux nginx[793]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Nov 26 14:59:45 tp2-linux nginx[793]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Nov 26 14:59:45 tp2-linux systemd[1]: Started The nginx HTTP and reverse proxy server.
```

```
[mat@tp2-linux ~]$ sudo cat /usr/lib/systemd/system/nginx.service | grep ExecStart=

#Qaund on démarre le service nginx on exécute la commande suivante: /usr/sbin/nginx

ExecStart=/usr/sbin/nginx
```

## 3. Création de service

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

```
[mat@tp2-linux ~]$ echo $RANDOM

#On génère un  nombre aléatoire qui nous servira de port de connexion pour le service netcat

13923
```

```
[mat@tp2-linux ~]$ sudo nano /etc/systemd/system/tp2_nc.service
#On configure le fichier de commande du service
[sudo] password for mat:
```

```
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 13923
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=13923/tcp
success
[mat@tp2-linux ~]$ sudo firewall-cmd --add-port=13923/tcp --permanent
success

#On autorise le traffic venant du port 13923 en tcp à passer afin de pouvoir utiliser nc depuis le pc
```

```
[mat@tp2-linux ~]$  sudo systemctl restart firewalld
#On relance le firewall pour appliquer les modifications
```

```
[mat@tp2-linux ~]$ sudo firewall-cmd --list-all | grep 13923
  ports: 22/tcp 32125/tcp 13923/tcp
#Le port 13923 est désormais autorisé à ecouter à l'extérieur.
```


🌞 **Indiquer au système qu'on a modifié les fichiers de service**

```
[mat@tp2-linux ~]$ sudo systemctl daemon-reload
#On applique les modifications.
```

🌞 **Démarrer notre service de ouf**

```
[mat@tp2-linux ~]$ sudo systemctl start tp2_nc
#On démarre le service en utilisant sudo sinon on a pas les perms.
```

🌞 **Vérifier que ça fonctionne**

```
[mat@tp2-linux ~]$ systemctl status tp2_nc

#On check l'état du service et on voit qu'il a bien démarré.

● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Sat 2022-11-26 15:25:35 CET; 1min 28s ago
   Main PID: 1023 (nc)
      Tasks: 1 (limit: 5907)
     Memory: 776.0K
        CPU: 3ms
     CGroup: /system.slice/tp2_nc.service
             └─1023 /usr/bin/nc -l 13923

Nov 26 15:25:35 tp2-linux systemd[1]: Started Super netcat tout fou.
```

```
[mat@tp2-linux ~]$ sudo ss -alnpt | grep 13923

#On vérifie que le service nc écoute bien sur port définit plus tôt 13923

LISTEN 0      10           0.0.0.0:13923      0.0.0.0:*    users:(("nc",pid=1023,fd=4))                 
LISTEN 0      10              [::]:13923         [::]:*    users:(("nc",pid=1023,fd=3))   
```

🌞 **Les logs de votre service**

```
[mat@tp2-linux ~]$ sudo journalctl -xe -u tp2_nc | grep start
░░ Subject: A start job for unit tp2_nc.service has finished successfully
#Log de démarrage du service
```

```
[mat@tp2-linux ~]$ sudo journalctl -xe -u tp2_nc | grep "test"
░░ Nov 26 15:26:22 TP2 nc[1023]: test
#Log de démarrage du service
```

```
[mat@tp2-linux ~]$ sudo journalctl -xe -u tp2_nc | grep dead
░░ The unit tp2_nc.service has successfully entered the 'dead' state.
#Log de fin de service
```

🌞 **Affiner la définition du service**

```
[mat@tp2-linux ~]$ sudo nano /etc/systemd/system/tp2_nc.service
```

```
[mat@tp2-linux ~]$ sudo systemctl daemon-reload
#On applique les modifications.
```

```
[mat@tp2-linux ~]$ journalctl -xe -u tp2_nc

Nov 27 13:09:44 tp2-linux systemd[1]: tp2_nc.service: Scheduled restart job, restart counter is at 1.
░░ Subject: Automatic restarting of a unit has been scheduled
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ Automatic restarting of the unit tp2_nc.service has been scheduled, as the result for
░░ the configured Restart= setting for the unit.
```
