Title: Déchiffrer plusieurs disques chiffrés avec une seule passphrase au boot
Date: 2014-04-29
Category: crypto
Tags: luks

On continue dans les petits tutoriels cette semaine !

# Introduction

Faire de la crypto-anarchie en chiffrant tout, tout le temps, c'est cool.
Avoir whatmille fois sa phrase de passe à taper au boot pour déchiffrer ses
 whatmille disques durs chiffrés, c'est beaucoup moins cool :D
Surtout comme dans mon cas où il y a 5 disques LUKS à monter au démarrage…

Comme d'habitude, un vrai geek cherche toujours à automatiser les taches
 répétitives.
On va donc voir ici comment déchiffrer tous les disques d'un coup et avec une
 seule phrase de passe, en utilisant la capacité de LUKS à utiliser plusieurs
 clefs, et un fichier au lieu d'une phrase de passe.

On va donc commencer par se faire un petit fichier qui nous servira de clef pour
 déverrouiller tous les disques.
On ne peut bien entendu pas laisser ce fichier en clair quelque part, sinon
 n'importe qui qui aurait accès à ce fichier pourrait déchiffrer le disque en
 question. Et donc réduire la sécurité au néant.<br/>
Il faut donc le chiffrer, et demander une phrase de passe pour y accéder.
La magie de la chose, c'est qu'on va faire ça… avec LUKS ! Joli, non ? :D

# Installation
## Génération de la clef

Une partition LUKS n'est au final qu'une partition comme les autres.
Et ça peut être un simple fichier et pas obligatoirement une vraie partition
 /dev.<br/>
Au niveau de son format, on trouve en début de partition des en-têtes LUKS qui
 servent au déchiffrement (cipher utilisé, clef principale, emplacement des
 clefs…).<br/>
LUKS utilise 4096 blocs de 512 octets (soit 2Mo) de données pour ses en-têtes.
Derrière ces en-têtes, on a des donnés classiques, qui peuvent être des données
d'une partition Ext4 normale… ou juste du bruit aléatoire !<br/>
On veut générer une clef de 512 octets, on va donc créer un fichier de 4096+1 blocs
 de 512 octets, qu'on va ensuite formater normalement avec LUKS

	:::bash
	# dd if=/dev/urandom of=/boot/key count=4097 bs=512
	# cryptsetup luksFormat --cipher aes-xts-essiv:sha256 --key-size 256 --hash sha256 /boot/key
	# cryptsetup luksOpen /boot/key lukskey
	# dd if=/dev/urandom of=/dev/mapper/lukskey

## Ajout de la clef aux conteneurs LUKS à ouvrir automatiquement

On se retrouve donc avec un `/dev/mapper/lukskey` de 512 octets, rempli de données
 aléatoires.
Le tout est bien à l'abris dans un container LUKS, dont il faut la passphrase
 pour accéder à son contenu.<br/>
Un parfait candidat pour une clef de déchiffrement !

On va donc ajouter ce fichier en tant que clef de déchiffrement sur chaque disque
 qu'on souhaite ouvrir au démarrage.
Ainsi, on n'aura plus qu'à saisir la passphrase de notre clef, qui se montera en
 disque LUKS, et qu'on pourra utiliser pour ouvrir tout le reste, sans saisie
 d'un mot de passe.

	:::bash
	# cryptsetup luksAddKey /dev/sda2 /dev/mapper/lukskey
	# cryptsetup luksAddKey /dev/sdb /dev/mapper/lukskey
	# …

## Mise-en-place de la clef au boot

On a donc une clef, protégée par un mot de passe, et tout plein de conteneurs
 LUKS avec cette clef autorisée à ouvrir le conteneur.
Ne reste donc plus qu'à embarquer tout ça au boot.<br/>
Pour faire ça, on va utiliser [initrd](https://fr.wikipedia.org/wiki/Initrd), qui
 permet d'avoir un système minimaliste au boot, et dans notre cas d'utiliser LUKS.

[Un petit hooks initrd](https://gist.github.com/aeris/4245691#file-lukskey-sh)
 qui permet de copier la clef dans l'initramfs :

 	:::bash
 	# wget https://gist.githubusercontent.com/aeris/4245691/raw/0ae19000d4ac901d81c01c10822ef693a0c70cf8/lukskey.sh -O /etc/initramfs-tools/hooks/lukskey
 	# chmod +x /etc/initramfs-tools/hooks/lukskey

[Un script de boot](https://gist.github.com/aeris/4245691#file-cryptroot-prepare-sh)
 qui s'occupe de tout le nécessaire pour ouvrir les conteneurs LUKS au boot, à
 partir de la clef embarquée précédemment :

	:::bash
 	# wget https://gist.githubusercontent.com/aeris/4245691/raw/2661b1ee4119c14b156fc341ed0523d18ef78e13/cryptroot-prepare.sh -O /etc/initramfs-tools/scripts/local-top/cryptroot-prepare
 	# chmod +x /etc/initramfs-tools/scripts/local-top/cryptroot-prepare

Bien sûr, on ne fait confiance à rien, surtout quand ça touche à de la crypto et
 de la sécurité.
Donc on vérifie [les empreintes SHA1](https://gist.github.com/aeris/4245691#file-sha1sums)
 des fichiers et que [c'est bien moi](https://gist.github.com/aeris/4245691#file-sha1sums-asc)
 qui ait écrit tout ça :

 	:::bash
 	$ wget https://gist.githubusercontent.com/aeris/4245691/raw/92e5af4408b5fc6f468d7af10c129d0b1fdd6c2b/sha1sums -O /tmp/sha1sums
 	$ wget https://gist.githubusercontent.com/aeris/4245691/raw/0cd5655eb38e898d9697024fe49231cdd29fad71/sha1sums.asc -O /tmp/sha1sums.asc
 	$ gpg --recv-key ECE4E222
 	$ gpg --verify /tmp/sha1sums.asc # C'est bien moi
 	$ sha1sum -c /tmp/sha1sums # Ce sont les bons fichiers

Vous devez ensuite éditer `/etc/initramfs-tools/scripts/local-top/cryptroot-prepare`
 pour y mettre tous les conteneurs LUKS que vous voulez ouvrir à partir de votre
 clef :

 	:::bash
	# Add here all your LUKS containers to open during boot
	luksOpen UUID=6a646cb8-cfa7-11e3-9748-9bbb835a1308 foo --key-file=/dev/mapper/luksKey

Dans cet exemple, `UUID=6a646cb8-cfa7-11e3-9748-9bbb835a1308` est le conteneur
 à ouvrir (Ici j'utilise un *block-device-UUID*, plus pérènne que les `/dev/sda1`
 ou autres qui peuvent changer d'un boot à l'autre (ah ah). Vous pouvez lister vos
 UUID avec la commande `blkid`.) et `foo` sera son petit nom dans `/dev/mapper`.

Pour la petite explication de comment que ça fait pour fonctionner :

	:::bash
	# On se crée un loop-device qui va servir à présenter un fichier en tant que block-device
	mknod /dev/loop0 b 7 0
	# On monte notre clef en tant que block-device
	losetup /dev/loop0 /key
	# On ouvre notre clef avec notre phrase de passe
	luksOpenPassphrase /dev/loop0 luksKey || exit $?
	# On monte tout le reste à partir de la clef ouverte
	luksOpen UUID=6a646cb8-cfa7-11e3-9748-9bbb835a1308 foo --key-file=/dev/mapper/luksKey
	# On ferme la clef
	luksClose luksKey
	# On supprime le loop-device
	losetup -d /dev/loop0
	# On rafraîchit LVM pour voir s'il n'y a pas des groupes de volume LVM sur les disques déchiffrés
	/sbin/lvm vgchange -a y --sysinit

Il n'y a plus qu'à reconstruire l'image initramfs du système pour prendre en
 compte tout ce petit monde :

 	:::bash
 	# update-initramfs -uk all

Pour vérifier si tout s'est bien passé, vous pouvez dumper le contenu du initramfs
 et voir la clef et le script de déverrouillage :

 	:::bash
 	$ cpio -t < /boot/initrd.img-$(uname -r) | egrep "(^key$|/cryptroot-prepare$)"

(Sauf si comme moi vous utilisez les mises-à-jour de votre CPU via le paquet
`intel-microcode`, et là vous devrez patauger à gros coups de `hexdump`, de la
spécification de `cpio` et de celle des `magic numbers` (ici pour `gzip`) pour
trouvez le bon offset, chez moi de 12945 octets :D

	:::bash
	# Roll a dice and/or expect good waves and/or cosmic ray and run this command
	$ tail -c +$(echo "ibase=16; $(hexdump /boot/initrd.img-$(uname -r) | \
		grep "^[0-9a-f]* 8b1f" | head -1 | awk '{print $1}')+1" | bc) \
		/boot/initrd.img-$(uname -r) | zcat | cpio -t | egrep "(^key$|/cryptroot-prepare$)"
)

Il n'y a plus qu'à rebooter et à croiser les doigts… Normalement il n'y a plus
 que la phrase de passe de la clef à saisir, le reste se déverrouille tout seul !
