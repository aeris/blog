---
title: Stockage chiffré intégral sur serveur distant
---

# Vous n’aurez pas ma liberté de chiffrer (ni mes données) !

Suite à [une petite mésaventure](https://www.nextinpact.com/news/104302-wannacrypt-nuds-tor-saisis-par-autorites-francaises.htm) qui m’est arrivée à la mi-mai (je rédigerai peut-être un post-mortem un jour, tiens), j’ai dû encore plus renforcer ma paranoïa sur mes serveurs, et j’en suis dorénavant arrivé à devoir chiffrer intégralement mes disques durs, y compris pour mes serveurs distants.
 
Le problème est qu’autant chiffrer son téléphone, son PC de bureau et son PC portable est relativement simple, autant chiffrer une machine distante est une autre paire de manches !
En effet, au démarrage, vous n’aurez aucune possibilité d’avoir à disposition un écran et un clavier pour saisir votre phrase de passe !
Il va donc falloir ruser un peu et embarquer un serveur SSH dès le démarrage (avant même le déchiffrement des disques !) pour avoir un accès suffisant pour déverrouiller le reste et lancer le reste du système.

Personnellement, je reste chez Online malgré ma petite déconvenue, et donc j’ai repris [le tutoriel initial]({% post_url 2015-02-22-online-install-from-scratch %}) d’installation d’une machine chez eux pour l’adapter à une version intégralement chiffrée des disques durs.

Histoire de corser un peu le tout, j’ai en plus décider de passer tout mon système sous LVM, et en prime de faire du [*thin provisionning*](https://fr.wikipedia.org/wiki/Dynamic_Provisioning), ce qui permet un meilleur usage des ressources sur le disque.

Les tutoriels sur le sujet disponibles sur le net ont tendance à un peu trop bidouiller le système, surtout que Debian a (presque) fait le nécessaire pour que tout fonctionne nativement.

Donc voici ma recette personnelle.

# Procédure

Comme pour l’ancienne procédure, tout va se passer en mode secours Online. À défaut d’avoir du Debian de disponible, choisissez une version récente d’Ubuntu (à l’heure actuelle, la 16.04).

Étant donné qu’on va faire du chiffrement de disque, je préconise de faire au moins une passe complète d’écriture aléatoire sur vos disques, afin de minimiser encore plus les informations accessibles par un attaquant. Vous pouvez utiliser [`shred`](https://linux.die.net/man/1/shred) ou pour aller plus vite, [un petit outil](https://gist.github.com/aeris/2a0f9beeed94102fd0cb2a8caad964d0) que j’ai commis en ruby.

Une fois connecté en SSH, on commence par installer les outils nécessaires. Il va y avoir des erreurs à l’installation, c’est « normal » et ça ne bloquera pas la suite.

```bash
apt update
apt install -y dialog
apt dist-upgrade -y
apt install -y cryptsetup lvm2 thin-provisioning-tools debootstrap debian-archive-keyring
```

On passe ensuite au formatage proprement dit. J’ai choisi de faire une partition (nécessairement) en clair de 1G pour mon `/boot`, puis tout le reste du disque en tant que *physical volume* LVM. Si vous faites [du LXC]({% post_url 2015-03-11-virtualisation-facile-lxc %}), vous pouvez faire deux PV LVM, un pour le système et un pour vos machines virtuelles. Vous pouvez bien entendu adapter les *logical volumes* à vos besoins.

```bash
swapoff -a
vgchange -a n

/sbin/parted -a optimal --script /dev/sda mklabel msdos
sfdisk /dev/sda <<EOF
/dev/sda1 : size=1G, type=83, bootable
/dev/sda2 : type=e8
EOF

cryptsetup -q luksFormat --verify-passphrase --hash sha256 --key-size=512 --cipher aes-xts-plain64 /dev/sda2
cryptsetup luksOpen /dev/sda2 crypt_system

pvcreate /dev/mapper/crypt_system
vgcreate system /dev/mapper/crypt_system
lvcreate -l 100%FREE --type thin-pool --thinpool system system
lvcreate --thin --virtualsize 10G  -n root system/system
lvcreate --thin --virtualsize 20G  -n var  system/system
lvcreate --thin --virtualsize 10G  -n log  system/system
lvcreate --thin --virtualsize 10G  -n home system/system
lvcreate --thin --virtualsize 100G -n srv  system/system
lvcreate --thin --virtualsize 1G   -n swap system/system

mkfs.ext4 -F /dev/sda1 -L boot -m 0
for d in root var log home srv; do mkfs.ext4 "/dev/system/${d}" -L "${d}" -m 0; done
mkswap /dev/system/swap -L swap
```

On monte ensuite tout ça et on lance la création du nouveau système Debian.

```bash
mount /dev/system/root /mnt
mkdir -p /mnt/{boot,var,tmp,home}
mount /dev/sda1 /mnt/boot
mount /dev/system/var /mnt/var
mkdir -p /mnt/var/log
mount /dev/system/log /mnt/var/log
mount /dev/system/home /mnt/home
mkdir -p /mnt/srv
mount /dev/system/srv /mnt/srv

debootstrap --arch=amd64 --variant=minbase stretch /mnt http://deb.debian.org/debian/

mkdir -p /mnt/{proc,sys,dev}
for i in proc sys dev; do mount -o bind "/${i}" "/mnt/${i}"; done
```

On est alors prêt à configurer le minimum vital pour un démarrage correct.

```bash
chroot /mnt

cat > /usr/sbin/policy-rc.d <<EOF
#!/bin/sh
exit 101
EOF
chmod +x /usr/sbin/policy-rc.d

rm /etc/apt/sources.list
mkdir -p /etc/apt/sources.list.d
cat > /etc/apt/sources.list.d/debian.list <<EOF
deb http://deb.debian.org/debian/ stretch main contrib
deb http://deb.debian.org/debian/ stretch-updates main contrib
deb http://deb.debian.org/debian/ stretch-backports main contrib
deb http://deb.debian.org/debian-security/ stretch/updates main contrib
EOF
cat >/etc/apt/apt.conf.d/60recommends <<EOF
APT::Install-Recommends "0";
APT::Install-Suggests "0";
EOF
apt update
apt dist-upgrade -y

mkdir -p /etc/network/interfaces.d
echo "source-directory /etc/network/interfaces.d" > /etc/network/interfaces
cat > /etc/network/interfaces.d/lo <<EOF
auto lo
iface lo inet loopback
EOF
cat > /etc/network/interfaces.d/enp0s20f0 <<EOF
auto enp0s20f0
iface enp0s20f0 inet static
	address X.X.X.X/24
	gateway X.X.X.1
iface enp0s20f0 inet6 static
	address XXXX:XXXX:XXXX:100::1/56
	pre-up dhclient -cf /etc/dhcp/dhclient6.enp0s20f0.conf -pf /var/run/dhclient6.enp0s20f0.pid -6 -P enp0s20f0
	pre-down dhclient -x -pf /var/run/dhclient6.enp0s20f0.pid
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

mkdir -p /etc/dhcp/
cat > /etc/dhcp/dhclient6.enp0s20f0.conf <<EOF
interface "enp0s20f0" {
	send dhcp6.client-id XX:XX:XX:XX:XX:XX:XX:XX:XX:XX;
	request;
}
EOF

cat > /etc/fstab <<EOF
proc				/proc			proc	defaults			0	0
sysfs				/sys			sysfs	defaults			0	0
cgroup				/sys/fs/cgroup	cgroup	defaults			0	0
tmpfs				/tmp			tmpfs	nodev,nosuid,nodev,noatime,size=1G	0	0
$(blkid /dev/disk/by-label/swap | awk '{print $3}' | tr -d '"')	none	swap	swap	0	0

$(blkid /dev/disk/by-label/root | awk '{print $3}' | tr -d '"')	/			ext4	errors=remount-ro,noatime	0	1
$(blkid /dev/disk/by-label/boot | awk '{print $3}' | tr -d '"')	/boot		ext4	defaults,noatime			0	2
$(blkid /dev/disk/by-label/var | awk '{print $3}' | tr -d '"')	/var		ext4	defaults,noatime			0	2
$(blkid /dev/disk/by-label/log | awk '{print $3}' | tr -d '"')	/var/log	ext4	defaults,noatime			0	2
$(blkid /dev/disk/by-label/srv | awk '{print $3}' | tr -d '"')	/srv 		ext4	defaults,noatime			0	2
EOF

cat > /etc/crypttab <<EOF
crypt_system $(blkid /dev/sda2 | awk '{print $2}' | tr -d '"') none luks
EOF

apt -y install dialog locales
apt -y install localepurge
localepurge
dpkg-reconfigure localepurge
apt -y install bash-completion less rsyslog unbound systemd-sysv kbd console-setup console-data net-tools isc-dhcp-client
```
	
Jusque-là, pas grand-chose de très nouveau par rapport à la version non chiffrée. C’est à partir d’ici que les choses vont se gâter un peu.

On va maintenant installer le nécessaire pour que le système embarque un serveur SSH léger, [`dropbear`](https://matt.ucc.asn.au/dropbear/dropbear.html) et réclamer à [`initramfs`](https://www.kernel.org/doc/Documentation/filesystems/ramfs-rootfs-initramfs.txt) d’embarquer tout ça et de monter les interfaces réseau au démarrage histoire qu’on puisse se connecter, alors que nos disques durs ne seront pas accessibles à ce moment-là !  
Deux difficultées réelles ici. *dropbear* ne supporte pas encore toutes les possibilités de SSH. En particulier, il ne tolère pas les clefs ED25519. Vous devez donc utiliser soit une ECDSA, soit une RSA. Et côté Debian, *thin-provisioning-tools* ne déploie pas nativement de hook sur *initramfs*, ce qui fait qu’il n’est pas embarqué. Il faut donc penser à patcher un peu à la main.

```bash
apt -y install lvm2 thin-provisioning-tools cryptsetup dropbear busybox ifupdown
apt -y install linux-image-amd64 linux-headers-amd64 grub2

cat > /etc/dropbear-initramfs/authorized_keys <<EOF
ecdsa-sha2-nistp521 xxxx you@example.org
EOF

cat >> /etc/initramfs-tools/initramfs.conf <<EOF
IP=X.X.X.X::X.X.X.1:255.255.255.0::enp0s20f0:off
EOF

cat > /etc/initramfs-tools/hooks/thin-provisioning-tools <<EOF
#!/bin/sh

PREREQ="lvm2"

prereqs() {
	echo "$PREREQ"
}

case \$1 in
prereqs)
	prereqs
	exit 0
	;;
esac

[ ! -x /usr/sbin/cache_check ] && exit 0

. /usr/share/initramfs-tools/hook-functions

copy_exec /usr/sbin/thin_check
copy_exec /usr/sbin/thin_dump
copy_exec /usr/sbin/thin_repair
copy_exec /usr/sbin/thin_restore
copy_exec /sbin/dmeventd

manual_add_modules dm_thin_pool
EOF
chmod +x /etc/initramfs-tools/hooks/thin-provisioning-tools

update-initramfs -uk all
```

On finit par tout nettoyer et préparer pour le reboot.

```bash
systemctl enable getty@ttyS1.service
systemctl disable dropbear

rm -f /usr/sbin/policy-rc.d

cat > /etc/resolv.conf <<EOF
search example.org
domain example.org
nameserver ::1
nameserver 127.0.0.1
nameserver 62.210.16.6
nameserver 62.210.16.7
EOF

mkdir -p /root/.ssh
cat > /root/.ssh/authorized_keys <<EOF
ssh-ed25519 xxxx you@example.org
EOF

passwd

exit
```

On démonte tout ça, et hop, reboot !

```bash
for i in dev sys proc var/log var home srv boot ""; do umount "/mnt/${i}"; done
vgchange -a n
cryptsetup luksClose crypt_system

reboot
```

« Normalement », vous devriez pouvoir vous connecter à votre serveur en cours de démarrage en SSH, puis pouvoir lancer le déchiffrement des disques avec `cryptroot-unlock`. Vous saisissez votre phrase de passe et votre machine va continuer son processus de boot normal (ça peut prendre un peu de temps, soyez patient !).

# En cas de problème

Cette procédure est particulièrement galère à debugger quand ça ne fonctionne pas. Parce que votre serveur n’est plus capable de rien et risque même de ne pas booter du tout.

Il est donc conseillé de redémarrer votre machine en gardant un œil sur [son KVM IP](https://documentation.online.net/fr/dedicated-server/hardware/kvm-over-ip) ou [sa console série](https://documentation.online.net/fr/dedicated-server/hardware/configure-ipmi-server/serial-console-suchard).

Pour corriger une erreur, vous devrez redémarrer en mode secours, déchiffrer vos disques et les monter.

```bash
apt install -y cryptsetup lvm2 thin-provisioning-tools
cryptsetup luksOpen /dev/sda2 crypt_system
vgchange -a y
mount /dev/system/root /mnt
for i in proc sys dev; do mount -o bind "/${i}" "/mnt/${i}"; done
chroot /mnt
mount -a
…
umount -a
exit
for i in dev sys proc ""; do umount "/mnt/${i}"; done
vgchange -a n
cryptsetup luksClose crypt_system
reboot
```

En piste de trucs qui peuvent merder sur l’`initramfs` :

* le module `dm_thin_pool` pas chargé
* l’exécutable `thin_check` pas chargé
* `busybox` pas pris en compte
* votre clef SSH pas prise en compte
* la connectivité réseau qui ne se fait pas
* les fichiers `/etc/crypttab` ou `/etc/fstab` incorrects
* …

Bon courage à vous !
