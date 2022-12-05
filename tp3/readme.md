# TP 3 : We do a little scripting

Aujourd'hui un TP pour appréhender un peu **le scripting**.

➜ **Le scripting dans GNU/Linux**, c'est simplement le fait d'écrire dans un fichier une suite de commande, qui seront exécutées les unes à la suite des autres lorsque l'on exécutera le script.

Plus précisément, on utilisera la syntaxe du shell `bash`. Et on a le droit à l'algo (des variables, des conditions `if`, des boucles `while`, etc).

➜ **Bon par contre, la syntaxe `bash`, elle fait mal aux dents.** Ca va prendre un peu de temps pour s'habituer.

![Bash syntax](./pics/bash_syntax.jpg)

Pour ça, vous prenez connaissance des deux ressources suivantes :

- [le cours sur le shell](../../cours/shell/README.md)
- [le cours sur le scripting](../../cours/scripting/README.md)
- le très bon https://devhints.io/bash pour tout ce qui est relatif à la syntaxe `bash`

➜ **L'emoji 🐚** est une aide qui indique une commande qui est capable de réaliser le point demandé

## Sommaire

- [TP 3 : We do a little scripting](#tp-3--we-do-a-little-scripting)
  - [Sommaire](#sommaire)
- [0. Un premier script](#0-un-premier-script)
- [I. Script carte d'identité](#i-script-carte-didentité)
  - [Rendu](#rendu)
- [II. Script youtube-dl](#ii-script-youtube-dl)
  - [Rendu](#rendu-1)
- [III. MAKE IT A SERVICE](#iii-make-it-a-service)
  - [Rendu](#rendu-2)
- [IV. Bonus](#iv-bonus)

# 0. Un premier script

➜ **Créer un fichier `test.sh` dans le dossier `/srv/` avec le contenu suivant** :

```bash
#!/bin/bash
# Simple test script

echo "Connecté actuellement avec l'utilisateur $(whoami)."
```

> La première ligne est appelée le *shebang*. Cela indique le chemin du programme qui sera utilisé par le script. Ici on inscrit donc, pour un script `bash`, le chemin vers le programme `bash` mais c'est la même chose pour des scripts en Python, PHP, etc.

➜ **Modifier les permissions du script `test.sh`**

- si c'est pas déjà le cas, faites en sorte qu'il appartienne à votre utilisateur
  - 🐚 `chown`
- ajoutez la permission `x` pour votre utilisateur afin que vous puissiez exécuter le script
  - 🐚 `chmod`

➜ **Exécuter le script** :

```bash
# Exécuter le script, peu importe le dossier où vous vous trouvez
$ /srv/test.sh

# Exécuter le script, depuis le dossier où il est stocké
$ cd /srv
$ ./test.sh
```

> **Vos scripts devront toujours se présenter comme ça** : muni d'un *shebang* à la ligne 1 du script, appartenir à un utilisateur spécifique qui possède le droit d'exécution sur le fichier.

# I. Script carte d'identité

[idcard.sh](./src/idcard.sh)


```
[mat@tp3 ~]$ sudo /srv/idcard/idcard.sh
Machine name : tp3
OS Rocky Linux and kernel version is Linux 5.14.0-162.6.1.el9_1.x86_64
IP : 10.4.1.36
RAM : 1.2Gi memory available on 1.5Gi total memory
Disk : 5.0G space left
Top 5 processes by RAM usage :
  - /usr/bin/python3
  - /usr/sbin/NetworkManager
  - /usr/lib/systemd/systemd
  - /usr/lib/systemd/systemd
  - sshd:
Listening ports :
  - 323 udp : chronyd
  - 22 tcp : sshd
Here is your random cat: ./cat_pic.jpeg
```

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu**, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

# II. Script youtube-dl

## Rendu

📁 **Le script `/srv/yt/yt.sh`**

[Youtube-downloader](./src/yt.sh)

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

```
[mat@tp3 yt]$ cat /var/log/yt/download.log
2022-11-29 16:38:53 Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded. File path : /srv/yt/downloads//.mp4
2022-11-29 16:39:10 Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded. File path : /srv/yt/downloads//.mp4
2022-11-29 16:43:13 Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded. File path : /srv/yt/downloads/One_Second_Video/One_Second_Video.mp4
2022-11-29 16:44:02 Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded. File path : /srv/yt/downloads/One_Second_Video/One_Second_Video.mp4
```

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.


```
[mat@tp3 yt]$ /srv/yt/yt.sh https://www.youtube.com/watch?v=jhFDyDgMVUI
Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded.
File path: /srv/yt/downloads/One_Second_Video/One_Second_Video.mp4
```

# III. MAKE IT A SERVICE

![Now witness](./pics/now_witness.png)

## Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

[Yt-v2](./src/yt-v2.sh)

📁 **Fichier `/etc/systemd/system/yt.service`**

[Yt.service](./src/yt.service)

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

- un `systemctl status yt` quand le service est en cours de fonctionnement

```
[mat@tp3 yt]$ systemctl status yt
● yt.service - Dl des vidéos ytb.
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor preset: disabled)
     Active: active (running) since Sun 2022-12-04 22:48:54 CET; 4s ago
   Main PID: 1915 (yt-v2.sh)
      Tasks: 2 (limit: 4638)
     Memory: 22.2M
        CPU: 3.356s
     CGroup: /system.slice/yt.service
             ├─1915 /bin/bash /srv/yt/yt-v2.sh
             └─1931 python /usr/local/bin/youtube-dl --get-description "https://www.youtube.com/watch?v=jhFDyDgMVUI"

Dec 04 22:48:54 tp3 systemd[1]: Started Dl des vidéos ytb..
Dec 04 22:48:57 tp3 yt-v2.sh[1924]: mkdir: cannot create directory ‘/srv/yt/downloads/One_Second_Video’: File exists
Dec 04 22:48:59 tp3 yt-v2.sh[1915]: Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded.
Dec 04 22:48:59 tp3 yt-v2.sh[1915]: File path: /srv/yt/downloads/One_Second_Video/One_Second_Video.mp4
Dec 04 22:48:59 tp3 yt-v2.sh[1930]: mkdir: cannot create directory ‘/srv/yt/downloads/One_Second_Video/description’: File exists
```
- un extrait de `journalctl -xe -u yt`

```
[mat@tp3 yt]$ journalctl -xe -u yt
Dec 04 22:48:54 tp3 systemd[1]: Started Dl des vidéos ytb..
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit yt.service has finished successfully.
░░
░░ The job identifier is 1374.
Dec 04 22:48:57 tp3 yt-v2.sh[1924]: mkdir: cannot create directory ‘/srv/yt/downloads/One_Second_Video’: File exists
Dec 04 22:48:59 tp3 yt-v2.sh[1915]: Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded.
Dec 04 22:48:59 tp3 yt-v2.sh[1915]: File path: /srv/yt/downloads/One_Second_Video/One_Second_Video.mp4
Dec 04 22:48:59 tp3 yt-v2.sh[1930]: mkdir: cannot create directory ‘/srv/yt/downloads/One_Second_Video/description’: File exists
Dec 04 22:49:09 tp3 yt-v2.sh[1942]: mkdir: cannot create directory ‘/srv/yt/downloads/One_Second_Video’: File exists
Dec 04 22:49:11 tp3 yt-v2.sh[1915]: Video https://www.youtube.com/watch?v=jhFDyDgMVUI was downloaded.
Dec 04 22:49:11 tp3 yt-v2.sh[1915]: File path: /srv/yt/downloads/One_Second_Video/One_Second_Video.mp4
Dec 04 22:49:11 tp3 yt-v2.sh[1948]: mkdir: cannot create directory ‘/srv/yt/downloads/One_Second_Video/description’: File exists
```