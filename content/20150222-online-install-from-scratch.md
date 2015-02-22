Title: Online - Installation from scratch
Date: 2015-02-22
Category: dev

[Online](http://www.online.net/fr/serveur-dedie) propose des serveurs assez sympas avec des prix raisonnables pour faire
du self-hosting comme un grand.<br/>
Problème, la procédure d’installation automatique de Debian n’est franchement pas top, surtout au niveau du partitionnement.
On ne peut pas profiter d’un partitionnement full [LVM](https://fr.wikipedia.org/wiki/Gestion_par_volumes_logiques),
d’un `/var` séparé, etc.<br/>
Debian et Online étant tous les deux très bien fait, on peut quand même s’en sortir en faisant tout à la main !

On est malheureusement obligé de commencer par l’installation automatique via Online, le serveur ne pouvant pas être
passé en mode secours avant. On laisse donc toutes les options par défaut, et une fois fini, on passe la bestiole en mode
rescue et on reboot. Après s’être connecté via SSH, on est parti pour faire une installation complète de Debian via
[Debootstrap](https://wiki.debian.org/fr/Debootstrap).

# Partitionnement

On commence par le partitionnement des disques proprement dit.<br/>
La mode étant à la virtualisation, on va réserver une (grosse) partie de l’espace disponible pour de futurs conteneurs
[LXC](https://linuxcontainers.org/fr/lxc/introduction/).

NB : Pour une raison obscure, en mode rescue Online, la table des partitions n’est pas mise à jour en cas de modification.
Si les commandes suivantes sortent des erreurs, il ne faut pas hésiter à rebooter la machine pour que le système voit les
bonnes partitions.

Au cas où des volumes LVM existeraient déjà sur le système, on va désactiver tous les volumes logiques existants :

    :::bash
    # vgchange -a n

Ensuite, on s’occupe de désactiver tous les volumes RAID potentiels, puis de remettre à 0 la détection automatique :

    :::bash
    # ls /dev/md[0-9]* | xargs -n 1 mdadm -S
    # ls /dev/sd*[0-9]* | xargs -n 1 mdadm --zero-superblock

(Généralement à ce moment-là, il faut rebooter pour faire prendre en compte les modifications…)<br/>
On s’occupe ensuite des partitions proprement dites. Personnellement, je prévois une partition de 100Go pour la Debian,
le reste ira aux conteneurs LXC. Comme on va avoir tout ça en RAID-1, on recopie la table des partitions du disque `sda`
vers le disque `sdb` :

    :::bash
    # /sbin/parted -a optimal --script /dev/sda \
    mklabel msdos \
    mkpart primary 8M 100GB \
    mkpart primary 100GB 100% \
    toggle 1 boot
    # sfdisk -d /dev/sda | sfdisk /dev/sdb

(Généralement à ce moment-là, il faut rebooter pour faire prendre en compte les modifications…)<br/>
On met ensuite du RAID-1 en place autour de tout ça :

    :::bash
    # mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 --assume-clean /dev/sda1 /dev/sdb1
    # mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 --assume-clean /dev/sda2 /dev/sdb2

(Généralement à ce moment-là, il faut rebooter pour faire prendre en compte les modifications…)<br/>
On finit par créer les conteneurs LVM :

    :::bash
    # pvcreate /dev/md0
    # vgcreate debian /dev/md0
    # lvcreate -n root -L 10G debian
    # lvcreate -n boot -L 200M debian
    # lvcreate -n var -L 20G debian
    # lvcreate -n log -L 10G debian
    # lvcreate -n tmp -L 10G debian
    # lvcreate -n home -L 10G debian
    # lvcreate -n swap -L 1G debian
    # lvcreate -n srv -l 100%FREE debian

    # pvcreate /dev/md1
    # vgcreate lxc /dev/md1

Et enfin, les systèmes de fichiers :

    :::bash
    # mkfs.ext4 /dev/mapper/debian-root -L debian-root
    # mkfs.ext4 /dev/mapper/debian-boot -L debian-boot
    # mkfs.ext4 /dev/mapper/debian-var -L debian-var
    # mkfs.ext4 /dev/mapper/debian-log -L debian-log
    # mkfs.ext4 /dev/mapper/debian-tmp -L debian-tmp
    # mkfs.ext4 /dev/mapper/debian-home -L debian-home
    # mkfs.ext4 /dev/mapper/debian-srv -L debian-home
    # mkswap /dev/mapper/debian-swap -L debian-swap

# Debootstrap

Maintenant qu’on a toutes les partitions nécessaires, on peut s’attaquer à l’installation de Debian avec Debootstrap.<br/>
On commence par recréer toute l’arborescence standard du futur GNU/Linux et par y monter les bonnes partitions :

    :::bash
    # mount /dev/mapper/debian-root /mnt
    # mkdir -p /mnt/{boot,var,tmp,home}
    # mount /dev/mapper/debian-boot /mnt/boot
    # mount /dev/mapper/debian-var /mnt/var
    # mkdir -p /mnt/var/log
    # mount /dev/mapper/debian-log /mnt/var/log
    # mount /dev/mapper/debian-tmp /mnt/tmp
    # mount /dev/mapper/debian-home /mnt/home
    # mkdir -p /mnt/{proc,sys,dev}
    # for i in proc sys dev; do mount -o bind /$i /mnt/$i

Et ensuite, en avant Debootstrap !

    :::bash
    # debootstrap --arch=amd64 stable /mnt http://cdn.debian.net/debian/

# Configuration de Debian

Pour une raison qui m’échappe aussi, il arrive parfois que `/proc` et `/sys` se démontent à l’issu du `debootstrap`.
On prend donc le temps de vérifier via un `mount` que tout est bien présent et on fait le nécessaire si besoin
(`for i in proc sys dev; do mount -o bind /$i /mnt/$i`).<br/>
On rentre dans notre nouveau système Debian pour finir l’installation de tout ce qui est nécessaire :

    :::bash
    # chroot /mnt

On configure APT et on met à jour le système :

    :::bash
    # cat > /etc/apt/sources.list <<EOF
      deb http://cdn.debian.net/debian/ stable main
      deb http://cdn.debian.net/debian/ stable-updates main
      deb http://security.debian.org/debian-security/ stable/updates main
      EOF
    # cat >/etc/apt/apt.conf.d/60recommends <<EOF
      APT::Install-Recommends "0";
      APT::Install-Suggests "0";
      EOF
    # apt-get update && apt-get -y dist-upgrade

On installe les paquets qui fournissent certains composants essentiels :

    :::bash
    # apt-get -y install busybox locales locales-all vim bind9 bash-completion less cron rsyslog
    # apt-get -y install localepurge
    # apt-get -y autoremove --purge nano

Configurer le réseau :

    :::bash
    # cat > /etc/network/interface <<EOF
      auto lo
      iface lo inet loopback

      auto eth0
      iface eth0 inet static
          address 62.210.X.X/24
          gateway 62.210.X.1
      iface eth0 inet6 static
          address 2001:bc8:X:X::X/56
      EOF

    # cat > /etc/resolv.conf <<EOF
      search example.org
      domain example.org
      nameserver ::1
      nameserver 62.210.16.6
      nameserver 62.210.16.7
      EOF

    # echo pony > /etc/hostname
    # hostname -F /etc/hostname

    # cat > /etc/hosts <<EOF
      127.0.0.1       pony.example.org pony
      127.0.0.1       localhost

      ::1             localhost ip6-localhost ip6-loopback
      ff02::1         ip6-allnodes
      ff02::2         ip6-allrouters
      EOF

    # cat > /etc/dibbler/client.conf <<EOF
      iface eth0 {
          ia pd
      }
      EOF
    # echo XX:XX:XX:XX:XX:XX:XX:XX:XX:XX > /var/lib/dibbler/client-duid

On renseigne ensuite le `/etc/fstab` et le RAID :

    :::bash
    # cat > /etc/fstab <<EOF
      # /etc/fstab: static file system information.
      #
      # Use 'vol_id --uuid' to print the universally unique identifier for a
      # device; this may be used with UUID= as a more robust way to name devices
      # that works even if disks are added and removed. See fstab(5).
      #
      # <file system>   <mount point>   <type>  <options>         <dump>  <pass>
      proc              /proc           proc    defaults          0       0
      sysfs             /sys            sysfs   defaults          0       0
      cgroup            /sys/fs/cgroup  cgroup  defaults          0       0
      /dev/debian/root  /               ext4    errors=remount-ro 1       1
      /dev/debian/boot  /boot           ext4    defaults          1       2
      /dev/debian/srv   /srv            ext4    defaults          1       2
      /dev/debian/home  /home           ext4    defaults          1       2
      /dev/debian/var   /var            ext4    defaults          1       2
      /dev/debian/log   /var/log        ext4    defaults          1       2
      /dev/debian/tmp   /tmp            ext4    defaults          1       2
      /dev/debian/swap  none            swap    swap              0       0
      EOF

    # mkdir -p /mnt/etc/mdadm
    # /usr/share/mdadm/mkconf > /mnt/etc/mdadm/mdadm.conf

Enfin, les logiciels par eux-mêmes :

    :::bash
    # apt-get install -y postfix lvm2 mdadm openssh-server mdadm
    # rm -f /var/lib/mdadm/CONF-UNCHECKED

Et on finit par le noyau et le bootloader :

    :::bash
    # apt-get install -y grub2 linux-image-amd64

On s’assure que tous les services qui auraient pu démarrer sont bien arrêtés :

    :::bash
    # for i in atd postfix cron bind9 dibbler-client mdadm rsyslog; do service $i stop; done
    # service --status-all | grep +

# Nettoyage et reboot

On nettoie dernière nous, on démonte tous les disques et on reboot :

    :::bash
    # exit

    # umount /mnv/var/log
    # umount /mnt/{boot,var,home,tmp}
    # umount /mnt/{proc,dev,sys}
    # umount /mnt

    # vgchange -a n

    # reboot

Et normalement votre nouvelle machine devrait prendre vie et connaître son premier paquet IP !

Il est conseillé de rebooter en étant connecté à l’[iDrac](http://documentation.online.net/fr/serveur-dedie/materiel/controleur-dell-idrac)
fourni par Online. Ainsi, en cas de problème de boot, on sera capable rapidement de trouver ce qui plante.<br/>
Si le boot se passe mal, vous pouvez reprendre la main en rescue, remonter les disques et corriger :

    :::bash
    # mdadm --assemble --scan
    # vgchange -a y
    # mount /dev/mapper/debian-root /mnt
    # mount /dev/mapper/debian-boot /mnt/boot
    # mount /dev/mapper/debian-var /mnt/var
    # mount /dev/mapper/debian-log /mnt/var/log
    # mount /dev/mapper/debian-tmp /mnt/tmp
    # mount /dev/mapper/debian-home /mnt/home
    # for i in proc sys dev; do mount -o bind /$i /mnt/$i
    # chroot /mnt

