---
title: Online - Installation from scratch
---

[Online](http://www.online.net/fr/serveur-dedie) propose des serveurs assez sympas avec des prix raisonnables pour faire du self-hosting comme un grand.
Problème, la procédure d’installation automatique de Debian n’est franchement pas top, surtout au niveau du partitionnement.
On ne peut pas profiter d’un partitionnement full [LVM](https://fr.wikipedia.org/wiki/Gestion_par_volumes_logiques), d’un `/var` séparé, etc.
Debian et Online étant tous les deux très bien fait, on peut quand même s’en sortir en faisant tout à la main !

On est malheureusement obligé de commencer par l’installation automatique via Online, le serveur ne pouvant pas être passé en mode secours avant.
On laisse donc toutes les options par défaut, et une fois fini, on passe la bestiole en mode rescue et on reboot.
Après s’être connecté via SSH, on est parti pour faire une installation complète de Debian via [Debootstrap](https://wiki.debian.org/fr/Debootstrap).

# Partitionnement

On commence par le partitionnement des disques proprement dit.
La mode étant à la virtualisation, on va réserver une (grosse) partie de l’espace disponible pour de futurs conteneurs [LXC](https://linuxcontainers.org/fr/lxc/introduction/).

Au cas où des volumes LVM existeraient déjà sur le système, on va désactiver tous les volumes logiques existants :

```shell
swapoff -a
vgchange -a n
```

Ensuite, on s’occupe de désactiver tous les volumes RAID potentiels, puis de remettre à 0 la détection automatique :

```shell
ls /dev/md[0-9]* | xargs -n 1 mdadm -S
ls /dev/sd*[0-9]* | xargs -n 1 mdadm --zero-superblock
```

On s’occupe ensuite des partitions proprement dites.
Personnellement, je prévois une partition de 100Go pour la Debian, le reste ira aux conteneurs LXC.
Comme on va avoir tout ça en RAID-1, on recopie la table des partitions du disque `sda` vers le disque `sdb` :

```shell
/sbin/parted -a optimal --script /dev/sda \
    mklabel msdos \
    mkpart primary 8M 100GB \
    mkpart primary 100GB 100% \
    toggle 1 boot
sfdisk -d /dev/sda | sfdisk /dev/sdb
```

On met ensuite du RAID-1 en place autour de tout ça :

```shell
mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 --assume-clean /dev/sda1 /dev/sdb1
mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 --assume-clean /dev/sda2 /dev/sdb2
```

(Généralement à ce moment-là, il faut rebooter pour faire prendre en compte les modifications…)
On finit par créer les conteneurs LVM :

```shell
pvcreate /dev/md0
vgcreate debian /dev/md0
lvcreate -n root -L 10G debian
lvcreate -n boot -L 200M debian
lvcreate -n var -L 20G debian
lvcreate -n log -L 10G debian
lvcreate -n tmp -L 10G debian
lvcreate -n home -L 10G debian
lvcreate -n swap -L 1G debian
lvcreate -n srv -l 100%FREE debian

pvcreate /dev/md1
vgcreate lxc /dev/md1
```

Et enfin, les systèmes de fichiers :

```shell
for d in root boot var log tmp home srv; do mkfs.ext4 /dev/mapper/debian-${d} -L debian-${d}; done
	mkswap /dev/mapper/debian-swap -L debian-swap
```

# Debootstrap

Maintenant qu’on a toutes les partitions nécessaires, on peut s’attaquer à l’installation de Debian avec Debootstrap.
On commence par recréer toute l’arborescence standard du futur GNU/Linux et par y monter les bonnes partitions :

```shell
mount /dev/mapper/debian-root /mnt
mkdir -p /mnt/{boot,var,tmp,home}
mount /dev/mapper/debian-boot /mnt/boot
mount /dev/mapper/debian-var /mnt/var
mkdir -p /mnt/var/log
mount /dev/mapper/debian-log /mnt/var/log
mount /dev/mapper/debian-tmp /mnt/tmp
mount /dev/mapper/debian-home /mnt/home
mkdir -p /mnt/{proc,sys,dev}
for i in proc sys dev; do mount -o bind /$i /mnt/$i; done
```

Et ensuite, en avant Debootstrap !

```shell
debootstrap --arch=amd64 jessie /mnt http://http.debian.net/debian/
```

# Configuration de Debian

Pour une raison qui m’échappe, il arrive parfois que `/proc` et `/sys` se démontent à l’issu du `debootstrap`.
On prend donc le temps de vérifier via un `mount` que tout est bien présent et on fait le nécessaire si besoin (`for i in proc sys dev; do mount -o bind /$i /mnt/$i`).
On rentre dans notre nouveau système Debian pour finir l’installation de tout ce qui est nécessaire :

```shell
chroot /mnt
```

On configure APT et on met à jour le système :

```shell
cat > /etc/apt/sources.list <<EOF
deb http://http.debian.net/debian/ jessie main
deb http://http.debian.net/debian/ jessie-updates main
deb http://security.debian.org/ jessie/updates main
EOF
cat >/etc/apt/apt.conf.d/60recommends <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
apt update && apt -y dist-upgrade
```

On installe les paquets qui fournissent certains composants essentiels :

```shell
apt -y install locales
apt -y install localepurge
apt -y install busybox vim bind9 bash-completion less cron rsyslog
apt -y autoremove --purge nano
```

Configurer le réseau :

```shell
cat > /etc/network/interfaces.d/eth0 <<EOF
auto eth0
iface eth0 inet static
	address 62.210.X.X/24
	gateway 62.210.X.1
iface eth0 inet6 static
	address 2001:bc8:X:X::X/56
EOF

cat > /etc/resolv.conf <<EOF
search example.org
domain example.org
nameserver ::1
nameserver 62.210.16.6
nameserver 62.210.16.7
EOF

echo pony > /etc/hostname
hostname -F /etc/hostname

cat > /etc/hosts <<EOF
127.0.0.1       pony.example.org pony
127.0.0.1       localhost

::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

cat > /etc/dibbler/client.conf <<EOF
iface eth0 {
	ia pd
}
EOF
echo XX:XX:XX:XX:XX:XX:XX:XX:XX:XX > /var/lib/dibbler/client-duid
```

On renseigne ensuite le `/etc/fstab` et le RAID :

```shell
cat > /etc/fstab <<EOF
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
/dev/debian/root  /               ext4    errors=remount-ro,noatime 1       1
/dev/debian/boot  /boot           ext4    defaults,noatime  1       2
/dev/debian/srv   /srv            ext4    defaults,noatime  1       2
/dev/debian/home  /home           ext4    defaults,noatime  1       2
/dev/debian/var   /var            ext4    defaults,noatime  1       2
/dev/debian/log   /var/log        ext4    defaults,noatime  1       2
/dev/debian/tmp   /tmp            ext4    defaults,noatime  1       2
/dev/debian/swap  none            swap    swap              0       0
EOF

mkdir -p /etc/mdadm && /usr/share/mdadm/mkconf > /etc/mdadm/mdadm.conf
```

Enfin, les logiciels par eux-mêmes :

	apt install -y postfix lvm2 mdadm openssh-server mdadm dibbler-client bind9
	rm -f /var/lib/mdadm/CONF-UNCHECKED

Et on finit par le noyau et le bootloader :

	apt install -y grub2 linux-image-amd64

On s’assure que tous les services qui auraient pu démarrer sont bien arrêtés :

	for s in atd postfix cron bind9 ssh dibbler-client mdadm mdadm-raid rsyslog; do service ${s} stop; done
	service --status-all | grep +

# Nettoyage et reboot

On nettoie dernière nous, on démonte tous les disques et on reboot :

	exit
	
	umount /mnt/var/log
	umount /mnt/{boot,var,home,tmp}
	umount /mnt/{proc,dev,sys}
	umount /mnt
	
	vgchange -a n
	
	reboot

Et normalement votre nouvelle machine devrait prendre vie et connaître son premier paquet IP !

Il est conseillé de rebooter en étant connecté à l’[iDrac](http://documentation.online.net/fr/serveur-dedie/materiel/controleur-dell-idrac) fourni par Online.
Ainsi, en cas de problème de boot, on sera capable de trouver rapidement ce qui plante.
Si le boot se passe mal, vous pouvez reprendre la main en rescue, remonter les disques et corriger :

	mdadm --assemble --scan
	vgchange -a y
	mount /dev/mapper/debian-root /mnt
	mount /dev/mapper/debian-boot /mnt/boot
	mount /dev/mapper/debian-var /mnt/var
	mount /dev/mapper/debian-log /mnt/var/log
	mount /dev/mapper/debian-tmp /mnt/tmp
	mount /dev/mapper/debian-home /mnt/home
	for i in proc sys dev; do mount -o bind /$i /mnt/$i; done
	chroot /mnt
	… do stuff…
	exit
	umount /mnt/var/log
	umount /mnt/{boot,var,home,tmp}
	umount /mnt/{proc,dev,sys}
	umount /mnt
	vgchange -a n
