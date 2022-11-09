# TP1 : Are you dead yet ?

Ce premier TP a pour objectif de vous familiariser avec les environnements GNU/Linux.  

On va apprendre à quoi servent les commandes élémentaires comme `cat`, `cd`, `ls`... **non c'est pas vrai, on va casser des machines d'abord. Hihi.**

L'idée est de vous faire un peu expérimenter et explorer un OS GNU/Linux, par vous-mêmes dans un premier temps, autour d'un sujet qui ESSAIE (très fort) d'être ludique.

---

**Munissez vous de :**

- votre créativité
- votre meilleur moteur de recherche
- une machine virtuelle GNU/Linux
  - p'tit snapshot ou clone de la VM avant de tout péter !

---

- [TP1 : Are you dead yet ?](#tp1--are-you-dead-yet-)
- [I. Intro](#i-intro)
  - [II. Feu](#ii-feu)

# I. Intro

**Le but va être de péter la machine virtuelle.**

Par "péter" on entend la rendre inutilisable :

➜ Si la machine boot même plus, c'est valide  
➜ Si la machine boot, mais que en mode *rescue*, et qu'on peut pas rétablir, c'est valide  
➜ Si la machine boot, mais que l'expérience utilisateur est tellement dégradée qu'on peut rien faire, c'est valide

**Bref si on peut pas utiliser la machine normalement, c'est VA-LI-DE.**  


---

Le but c'est de casser l'OS ou le noyau en soit, ou surcharger les ressources matérielles (disque, ram, etc), ce genre de choses.

Pour rappel : **parmi les principaux composants d'un OS on a :**

- un *filesystem* ou *système de fichiers*
  - des partitions quoi, des endroits où on peut créer des dossiers et des fichiers
- des *utilisateurs* et des *permissions*
- des *processus*
- une *stack réseau*
  - genre des cartes réseau, avec des IP dessus, toussa
- un *shell* pour que les humains puissent utiliser la machine
  - que ce soit une interface graphique (GUI) ou un terminal (CLI)
- des *devices* ou *périphériques*
  - écran, clavier, souris, disques durs, etc.

> **Essayez de penser par vous-mêmes, de raisonner.** Et pas direct Google "how to break a linux machine" comme des idiots. *(quand je dis de pas faire un truc, il faut le faire, c'est genre la règle n°1. Mais réfléchissez un peu quand même avant de Google ça ou des trucs similaires)*

Evidemment, tout doit être fait depuis le terminal, et vous faites ça avec l'OS que vous voulez (Ubuntu, Rocky, autres). Bien entendu, avec une VM.

Aucune contrainte d'utilisateur, vous pouvez utiliser l'utilisateur `root` ou la commande `sudo` pour tout ça.

## II. Feu

🌞 **Trouver au moins 4 façons différentes de péter la machine**

- elles doivent être **vraiment différentes**
- je veux le procédé exact utilisé
  - généralement une commande ou une suite de commandes (script)
- il faut m'expliquer avec des mots comment ça marche
  - pour chaque méthode utilisée, me faut l'explication qui va avec
- tout doit se faire depuis un terminal

Quelques commandes qui peuvent faire le taff :

- `rm` (sur un seul fichier ou un petit groupe de fichiers)
- `nano` ou `vim` (sur un seul fichier ou un petit groupe de fichiers)
- `echo`
- `cat`
- `python`
- `systemctl`
- un script `bash`
- plein d'autres évidemment

Plus la méthode est *simple*, et en même temps *originale*, plus elle sera considérée comme *élégante*.

> Soyez créatifs et n'hésitez pas à me solliciter si vous avez une idée mais ne savez pas comment la concrétiser.


1) Modifier Hash des mots de passes:

>sudo nano /etc/shadow

```
Ensuite on rajoute des caractères dans les hashs de root et de mat et quand on reboot on ne pourra plus se connecter.
```

![cpt1](./src/cpt1.gif)

2) Suppression du GRUB:

>sudo rm grub.cfg

```Lors du redémarrage il n'y a plus d'options de démarrage donc la machine est pt.```

![cpt2](./src/cpt2.gif)

3)Mettre le clavier en russe:

```Clavier russe pour pu pouvoir écrire```

>localectl list-keymaps

>localectl set-keymap cz-rus

```Ensuite cpt.```

![cpt](./src/vilebrequin-vilebrequin-sylvain-levy.gif)

4)Redémarrer en boucle le pc:

```On ajoute une tâche automatique dans crontab```

>crontab -e

```@reboot /sbin/reboot```

```Ensuite on donne les permissions pour tout le monde de shutdown```

>chmod a+s /sbin/reboot

Et ensuite quand on allume ou que l'on redémarre la machine, après avoir sélectionné l'option de boot elle redémarrera automatiquement.

![cpt4](./src/cpt4.gif)