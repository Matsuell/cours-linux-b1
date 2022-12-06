# Partie 1 : Partitionnement du serveur de stockage

🌞 **Partitionner le disque à l'aide de LVM**

```
[mat@storage ~]$ sudo pvcreate /dev/sdb
[sudo] password for mat:
  Physical volume "/dev/sdb" successfully created.
```

```
[mat@storage ~]$ sudo pvdisplay
#On vérifie que le Pv soit bien créé.
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBcd82f4d5-715af34e_ PVID qdYJvsqctgLAvctEN1HCs24erJwDQ5Mk last seen on /dev/sda2 not found.
  "/dev/sdb" is a new physical volume of "2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb
  VG Name
  PV Size               2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               2MhhcL-TG2I-AwFR-EMkB-fdqe-c4Sj-Q6u034
```

```
[mat@storage ~]$ sudo vgcreate storage /dev/sdb
#On créé un groupe de volume
  Volume group "storage" successfully created
```

```
[mat@storage ~]$ sudo vgs
#On vérifie que le volume soit bien créé.
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBcd82f4d5-715af34e_ PVID qdYJvsqctgLAvctEN1HCs24erJwDQ5Mk last seen on /dev/sda2 not found.
  VG      #PV #LV #SN Attr   VSize  VFree
  storage   1   0   0 wz--n- <2.00g <2.00g
```

```
[mat@storage ~]$ sudo lvcreate -l +100%FREE storage -n storage-tp4
#On créé un Logical Volume qui contient tout ce que storage contient.
  Logical volume "storage-tp4" created.
```

```
[mat@storage ~]$ sudo lvdisplay
#On vérifie que le LV soit bien créé.
  Devices file sys_wwid t10.ATA_____VBOX_HARDDISK___________________________VBcd82f4d5-715af34e_ PVID qdYJvsqctgLAvctEN1HCs24erJwDQ5Mk last seen on /dev/sda2 not found.
  --- Logical volume ---
  LV Path                /dev/storage/storage-tp4
  LV Name                storage-tp4
  VG Name                storage
  LV UUID                V2PbcL-Z0YD-MRWJ-HV0V-JNMI-TMCO-pGvTbK
  LV Write Access        read/write
  LV Creation host, time storage.tp4.linux, 2022-12-05 16:42:13 +0100
  LV Status              available
  # open                 0
  LV Size                <2.00 GiB
  Current LE             511
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
```

🌞 **Formater la partition**

```
[mat@storage ~]$ sudo mkfs -t ext4 /dev/storage/storage-tp4
#On formate la nouvelle partition que l'on vient de créer storage-tp4
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 84b8dcb2-46ae-4cbb-88a3-f658f032e859
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**

```
[mat@storage ~]$ sudo mkdir /storage
#On créé le dossier qui stockera les données de la partition.
```

```
[mat@storage ~]$ sudo mount /dev/storage/storage-tp4 /storage/
#On monte la partition dans le dossier.
```

```
[mat@storage ~]$ df -h | grep storage
#On vérifie que la partition soit créée.
/dev/mapper/storage-storage--tp4  2.0G   24K  1.9G   1% /storage
```

```
[mat@storage ~]$ sudo nano /etc/fstab
#On définit un point de montage automatique.
/dev/storage/storage-tp4 /mnt/storage-tp4 ext4 defaults 0 0
```

```
[mat@storage ~]$ sudo umount /storage/
On démonta la partition
```

```
[mat@storage ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /storage does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
/storage                 : successfully mounted
```


# Partie 2 : Serveur de partage de fichiers

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

```
[mat@storage ~]$ sudo dnf install nfs-utils -y
#On installe le serveur nfs
```

```
[mat@storage ~]$ sudo nano /etc/exports
#On modifie la liste des dossiers à exporter en rajoutant la ligne.

/storage 10.4.1.84(rw,sync,no_root_squash,no_subtree_check)
```

```
[mat@storage ~]$ cat /etc/exports
/storage 10.4.1.84(rw,sync,no_root_squash,no_subtree_check)
```

```
#On configure le serveur pour qu'il s'allume dès le démarrage de la machine et on le lance directement.
[mat@storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[mat@storage ~]$ sudo systemctl start nfs-server
```

```
#On autorise le service à passer la pare-feu.
[mat@storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[mat@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[mat@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[mat@storage ~]$ sudo firewall-cmd --reload
success
```

```
[mat@storage ~]$ ls /storage/site_web_1/
#On vérifie que le fichier créé sur le serveur web soit bien dans le serveur de stockage.
test.txt
```

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

```
[mat@web ~]$ sudo dnf install nfs-utils -y
#On installe le client.
```

```
[mat@web ~]$ sudo mkdir /var/www
#On créé le dossier www dans /var pour acceuillir les sites.
```

```
[mat@web ~]$ sudo mkdir -p /var/www/site_web_1
[mat@web ~]$ sudo mkdir -p /var/www/site_web_2
```

```
#On monte les 2 partitions sur le client.
[mat@web ~]$ sudo mount 10.4.1.65:/storage/site_web_1 /var/www/site_web_1
[mat@web ~]$ sudo mount 10.4.1.65:/storage/site_web_2 /var/www/site_web_2
```

```
[mat@web ~]$ df -h
#On vérifie que les 2 partitons soit montées.
Filesystem                     Size  Used Avail Use% Mounted on
devtmpfs                       462M     0  462M   0% /dev
tmpfs                          481M     0  481M   0% /dev/shm
tmpfs                          193M  3.0M  190M   2% /run
/dev/mapper/rl-root            6.2G  1.2G  5.1G  18% /
/dev/sda1                     1014M  210M  805M  21% /boot
tmpfs                           97M     0   97M   0% /run/user/1000
10.4.1.65:/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1
10.4.1.65:/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2
```

```
[mat@web ~]$ sudo touch /var/www/site_web_1/test.txt
#On créé un fichier pour vérifier si on a accès au dossier.
```

```
[mat@web ~]$ sudo nano /etc/fstab   
#On modifie le fichier pour ajouter le montage des 2 partitons au démarrage.

10.4.1.65:/storage/site_web_1  /var/www/site_web_1 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
10.4.1.65:/storage/site_web_2 /var/www/site_web_2 nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```


# Partie 3 : Serveur web


## 1. Intro NGINX



## 2. Install

🖥️ **VM web.tp4.linux**

🌞 **Installez NGINX**

```
[mat@web ~]$ sudo dnf install nginx -y
#On installe nginx.
```

## 3. Analyse

🌞 **Analysez le service NGINX**

```
[mat@web ~]$ sudo systemctl start nginx
#On lance le servce nginx pour pouvoir l'analyser.
```

```
[mat@web ~]$ ps -ef | grep nginx
root        1129       1  0 14:16 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1130    1129  0 14:16 ?        00:00:00 nginx: worker process
```

```
[mat@web ~]$ sudo ss -alnpt | grep nginx
[sudo] password for mat:
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=1130,fd=6),("nginx",pid=1129,fd=6))
LISTEN 0      511             [::]:80           [::]:*    users:(("nginx",pid=1130,fd=7),("nginx",pid=1129,fd=7))

#Le service écoute sous le port 80 en TCP.
```

```
[mat@web ~]$ cat /etc/nginx/nginx.conf  | grep /html
    # See http://nginx.org/en/docs/ngx_core_module.html#include
        root         /usr/share/nginx/html;
#        root         /usr/share/nginx/html;

#La racine web se trouve dans le dossier /usr/share/nginx/html
```

```
[mat@web ~]$ ls -l /usr/share/nginx/html/
total 12
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Dec  6 14:15 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png

#Tous les utilisateurs peuvent lire les fichiers, ils ont tous la permission "r".
```

## 4. Visite du service web

**Et ça serait bien d'accéder au service non ?** Genre c'est un serveur web. On veut voir un site web !

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```
[mat@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[mat@web ~]$ sudo firewall-cmd --reload
success
[mat@web ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 22/tcp 80/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:

  #On ajoute le port 80 en TCP, on relance le firewall et on vérifie que les modifications soit appliquées.
```

🌞 **Accéder au site web**

```
matsu@DESKTOP-6259DEV MINGW64 ~
$ curl http://10.4.1.84 | head -n 5
7  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  2566k      0 --:--:-- --:--:-- --:--:-- 3720k<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>

```

🌞 **Vérifier les logs d'accès**

```
[mat@web ~]$ sudo cat /var/log/nginx/access.log | tail -n 3
10.4.1.1 - - [06/Dec/2022:14:51:06 +0100] "GET / HTTP/1.1" 200 7620 "-" "Mozilla/5.0 (Windows NT; Windows NT 10.0; fr-FR) WindowsPowerShell/5.1.19041.1682" "-"
10.4.1.1 - - [06/Dec/2022:14:55:15 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.85.0" "-"
10.4.1.1 - - [06/Dec/2022:14:55:38 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.85.0" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

```
[mat@web ~]$ sudo nano /etc/nginx/nginx.conf
#On remplace la ligne listen     80;

listen       8080;
```

```
[mat@web ~]$ sudo systemctl restart nginx

```

```
[mat@web ~]$ systemctl status nginx | grep Active
#On vérifie qu'il tourne toujours.
     Active: active (running) since Tue 2022-12-06 15:05:47 CET; 3min 14s ago
```

```
[mat@web ~]$ sudo ss -alnpt | grep 8080
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*    users:(("nginx",pid=1257,fd=6),("nginx",pid=1256,fd=6))
```

```
#On supprime l'ancien port, on ajoute le nouveau, on relance le firewall et on vérifie que les modifs soit prises en compte
[mat@web ~]$ sudo firewall-cmd --remove-port=80/tcp --permanent
success
[mat@web ~]$ sudo firewall-cmd --add-port=8080/tcp --permanent
success
[mat@web ~]$ sudo firewall-cmd --reload
success
[mat@web ~]$ sudo firewall-cmd --list-all | grep ports:
  ports: 22/tcp 8080/tcp
  forward-ports:
  source-ports:
```

```
#On vérifie que le site est toujours accessible.
matsu@DESKTOP-6259DEV MINGW64 ~
$ curl http://10.4.1.84:8080 | head -n 5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0  2983k      0 --:--:-- --:--:-- --:--:-- 3720k<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>

```

🌞 **Changer l'utilisateur qui lance le service**

```
[mat@web ~]$ sudo useradd web
```

```
[mat@web ~]$ ls /home/
mat  web
#Web possède son dossier personnel.
```

```
[mat@web ~]$ sudo passwd web
#On ajoute un mot de passe à l'utilisateur web.
Changing password for user web.
New password:
```


```
[mat@web ~]$ sudo nano /etc/nginx/nginx.conf
#On modifie l'utilisateur qui lance le service.

[mat@web ~]$ sudo cat /etc/nginx/nginx.conf | grep web;
user web;

[mat@web ~]$ sudo systemctl restart nginx
#On relance le service
```

```
[mat@web ~]$ ps -ef | grep web
#On vérifie que le service soit bien lancé avec l'utilisateur web.
web         1499    1498  0 15:33 ?        00:00:00 nginx: worker process
mat         1503     891  0 15:34 pts/0    00:00:00 grep --color=auto web
```

**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

🌞 **Changer l'emplacement de la racine Web**

```
[mat@web ~]$ cat  /etc/nginx/nginx.conf | grep site_web_1
#On change la racine
        root         /var/www/site_web_1;
```

```
[mat@web ~]$ cat /var/www/site_web_1/index.html
Salut à tous c'est Lassale
```

```
matsu@DESKTOP-6259DEV MINGW64 ~
#On curl le site pour voir si il a changé.
$ curl http://10.4.1.84:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    28  100    28    0     0   5132      0 --:--:-- --:--:-- --:--:--  5600
Salut à tous c'est Lassale

```


## 6. Deux sites web sur un seul serveur

🌞 **Repérez dans le fichier de conf**

```
[mat@web ~]$ cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

🌞 **Créez le fichier de configuration pour le premier site**

```
[mat@web ~]$ sudo nano /etc/nginx/conf.d/site_web_1.conf
#On rajoute le bloc
    server {
        listen       8080;
        listen       [::]:80;
        server_name  _;
        root         /var/www/site_web_1;

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

🌞 **Créez le fichier de configuration pour le deuxième site**

```
[mat@web ~]$ sudo cp /etc/nginx/conf.d/site_web_1.conf /etc/nginx/conf.d/site_web_2.conf
```

```
[mat@web ~]$ sudo cat /etc/nginx/conf.d/site_web_2.conf | grep 8888
#On modifie le port d'écoute en 8888 et le dossier où est situé le site2.
        listen       8888;

[mat@web ~]$ sudo cat /etc/nginx/conf.d/site_web_2.conf | grep site_web_2
        root         /var/www/site_web_2;
```

```
#On ouvre le port 8888 sur le firewall on relance le firewall et on vérifie que les modifications soient appliquées.
[mat@web ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[mat@web ~]$ sudo firewall-cmd --reload
success

[mat@web ~]$ sudo firewall-cmd --list-all | grep ports:
  ports: 22/tcp 8080/tcp 8888/tcp
  forward-ports:
  source-ports:
```

🌞 **Prouvez que les deux sites sont disponibles**

```
Site1:

matsu@DESKTOP-6259DEV MINGW64 ~
$ curl http://10.4.1.84:8080
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    28  100    28    0     0   4820      0 --:--:-- --:--:-- --:--:--  5600Salut à tous c'est Lassale
```

```
Site 2:
matsu@DESKTOP-6259DEV MINGW64 ~
$ curl http://10.4.1.84:8888
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    27  100    27    0     0   1675      0 --:--:-- --:--:-- --:--:--  1800Test deuxxxxxxxxxxxxxxxxxx

```