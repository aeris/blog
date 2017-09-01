---
title: OVH - Installer une machine FreeBSD avec root ZFS raidZ
---

Un petit billet rapide pour expliquer comment installer un serveur dédié sous FreeBSD avec votre partition racine sur un raidZ ZFS.
En effet, par défaut, l’installeur automatique proposé par OVH permet un root ZFS, mais le raid est en raid1, ce qui réduit drastiquement l’espace disque final (avec 3 disques de 4To, vous obtenez 4To utilisables en raid1, contre 8To en raidz).

Pour installer votre système en raidZ, il faut d’abord faire l’installation « à l’arrache » via l’installeur OVH, puis rebooter le serveur sur le mode rescue, et refaire l’installation à la main avec la procédure suivante.


On commence par dézinguer tous les anciens pools ZFS :

```shell
zpool import -fR /mnt zroot
zpool destroy zroot
```

On crée ensuite les partitions qui vont bien aller :

* une partition de boot de 512ko
* une partition de swap de 2Go
* le reste en partition de pool ZFS

On en profite pour installe le bootloader GPT au passage.  
(Le script suivant considère que vous utilisez 3 disques, adaptez-le en conséquence)

```shell
foreach n ( 0 1 2 )
    gpart destroy -F ada${n}
    gpart create -s gpt ada${n}

    gpart add -a 4k -s 512k -t freebsd-boot -l boot${n} ada${n}
    gpart add -a 4k -s 2g -t freebsd-swap -l swap${n} ada${n}
    gpart add -a 4k -t freebsd-zfs -l disk${n} ada${n}

    gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada${n}

    gnop create -S 4096 /dev/gpt/disk${n}
end
```

On créé ensuite le pool ZFS en raidZ, avec les 3 disques formatés :

```shell
zpool create -o altroot=/mnt -O canmount=off -o compression=lz4 -o checksum=fletcher4 -o atime=off -m none zroot raidz /dev/gpt/disk0 /dev/gpt/disk1 /dev/gpt/disk2

zfs create -o mountpoint=none -o quota=10G zroot/ROOT
zfs create -o mountpoint=/ zroot/ROOT/default
zfs create -o mountpoint=/tmp -o quota=2G -o setuid=off zroot/tmp
```

Ensuite, on installe le futur système sur le pool nouvellement créé :

```shell
chmod 1777 /mnt/tmp

zpool set bootfs=zroot/ROOT/default zroot

set FREEBSD_VERSION = 10.3-RELEASE
foreach file ( base kernel lib32 )
wget -O - ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/${FREEBSD_VERSION}/${file}.txz | tar -Upxf - -C /mnt
end

cat > /mnt/etc/fstab <<EOF
/dev/gpt/swap0                 none                    swap    sw              0       0
/dev/gpt/swap1                 none                    swap    sw              0       0
/dev/gpt/swap2                 none                    swap    sw              0       0
EOF

echo zfs_load="YES" >> /mnt/boot/loader.conf

sed -i "" "s/^#PermitRootLogin .*/PermitRootLogin prohibit-password/" /mnt/etc/ssh/sshd_config

cat > /mnt/etc/rc.conf <<EOF
hostname="pony.example.org"

ifconfig_igb0="inet X.X.X.X netmask 255.255.255.0 broadcast X.X.X.255"
defaultrouter="X.X.X.254"

ifconfig_igb0_ipv6="inet6 XXX:XXX:XXX:XXXX:: prefixlen 64 accept_rtadv no_radr"
ipv6_network_interfaces="igb0"
ipv6_default_interface="igb0"
ipv6_defaultrouter="XXXX:XXXX:XXXX:XXff:ff:ff:ff:ff"
ipv6_route_ovhgw="XXXX:XXXX:XXXX:XXff:ff:ff:ff:ff -prefixlen 128 -interface igb0"
ipv6_static_routes="ovhgw"

dumpdev="AUTO"
clear_tmp_enable="YES"
accounting_enable="YES"

unbound_enable="NO"
sshd_enable="YES"
ntpd_enable="YES"
postfix_enable="YES"
zfs_enable="YES"
EOF

mkdir -p /mnt/root/.ssh/
cat > /mnt/root/.ssh/authorized_keys <<EOF
<vos clefs SSH qui va bien>
EOF

cat > /mnt/etc/resolv.conf <<EOF
domain example.org
search example.org
nameserver 213.186.33.99
EOF

chroot /mnt passwd
```

On repasse le serveur en boot sur le disque, et on lance un reboot.
Normalement, votre nouvelle machine devrait prendre vie rapidement !

En cas de soucis, vous pouvez toujours repasser en mode rescue, et remonter votre pool pour travailler dessus :

```shell
zpool import -fR /mnt zroot
```
