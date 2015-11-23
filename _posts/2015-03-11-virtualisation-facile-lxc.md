---
title: Virtualisation facile avec LXC
---

On continue aujourd’hui sur de l’infrastructure, avec de la virtualisation.

La virtualisation est apparue il y a déjà pas mal de temps et a révolutionné le domaine de l’infrastructure et du déploiement.

Personnellement, j’ai touché à un peu tous les types de virtualisation, mais peu m’ont réellement convaincues.<br/>
J’utilise [VirtualBox](https://www.virtualbox.org/) pour monter des machines rapidement pour développer.
[OpenStack](https://www.openstack.org/) est une véritable usine-à-gaz et sauf à avoir 10.000 machines à provisionner, ce
n’est clairement pas fait pour une utilisation personnelle.
[KVM](http://www.linux-kvm.org) est trop complexe et pour réussir à faire tourner quelque chose, il faut vraiment le
vouloir, sauf à utiliser [des outils encore plus usine-à-gaz](http://libvirt.org/).<br/>
La virtualisation lourde (KVM, VirtualBox, OpenStack…) nécessite en plus de bien dimensionner à l’avance ses machines,
les modifications a posteriori (modification de l’espace disque ou de la quantité de mémoire) nécessitant un reboot de
la machine et pouvant s’afférer compliquées.

Au final, pour mes serveurs personnels, je suis passé à de la virtualisation légère, via [LXC](https://linuxcontainers.org/).<br/>
Le **gros** avantage que je trouve à LXC par rapport à tout le reste est que son utilisation ne nécessite que très peu de
connaissances supplémentaires : mis-à-part la création de la machine proprement dite, le reste de la gestion se fait
uniquement via les outils standard GNU/Linux, y compris pour la gestion du réseau.
Il n’y a pas besoin de lire le manuel de LXC pour savoir configurer quoi que ce soit, à l’inverse de KVM ou de libvirt
qui nécessite un (long) apprentissage de comment fonctionne la virtualisation en interne pour espérer trouver une
configuration correcte.<br/>
C’est à mon sens ce que devrait être la virtualisation : qu’on ait de la virtualisation ou non, une fois la machine
démarrée, je ne dois plus avoir à avoir conscience que je tourne en environnement virtuel et je dois gérer de la même
manière un hôte et un invité.

LXC utilise aussi [`debootstrap`](https://wiki.debian.org/fr/Debootstrap) pour construire ses invités, ce qui évite
d’avoir à construire et à maintenir des modèles de machine, à l’opposé de KVM ou OpenStack.

LXC repose sur les [cgroups](https://www.kernel.org/doc/Documentation/cgroups/cgroups.txt), il faut donc vous assurer
que vous les avez bien activés avant de tenter de jouer avec.
Si ce n’est déjà fait, il suffit de déclarer les cgroups dans votre `/etc/fstab` :

	# /etc/fstab
	cgroup  /sys/fs/cgroup          cgroup  defaults        0       0

puis de les monter :

	mount /cgroup

On peut ensuite installer LXC (`apt install lxc`) et vérifier si tout est OK :

	lxc-checkconfig

Par défaut, LXC utilise le système de fichier de l’hôte pour placer celui de l’invité.
Afin d’éviter de saturer l’hôte avec un invité un peu violent, je préfère isoler chaque invité sur une partition [LVM](https://fr.wikipedia.org/wiki/Gestion_par_volumes_logiques), ce qui permet en plus de pouvoir redimensionner la partition à chaud par la suite.
Ce cas est prévu par LXC via son option `-B lvm`, et qui s’attend dans ce cas à trouver un volume group (vg) du nom de
`lxc` (vous pourrez toujours préciser un autre nom via l’option `--vgname`).
Pour les personnes qui utiliseraient [BTRFS](https://fr.wikipedia.org/wiki/Btrfs) ou [ZFS](https://fr.wikipedia.org/wiki/ZFS),
LXC gère aussi ces supports pour y créer directement des systèmes de fichiers (`man lxc-create` pour plus de renseignements).

Pour créer un nouvel invité, il suffit d’utiliser `lxc-create`, en lui précisant son petit nom (ici `test`), quel système
invité (`debian`) on souhaite ainsi que la taille du futur système de fichier (10Go) :

	lxc-create -B lvm -n test -t debian --fssize=10G

Niveau réseau, je branche toutes mes VM sur un [pont](https://fr.wikipedia.org/wiki/Pont_(informatique)) `lxc-br`, qu’il
faut donc créer auparavant :

{% highlight bash %}
cat > /etc/network/interfaces.d/lxc-br <<EOF
auto lxc-br
iface lxc-br inet static
	address 10.0.0.1/24
	bridge_ports none
	bridge_fd 0
	bridge_maxwait 0
iface lxc-br inet6 static
	address 2001:bc8:XXXX:XXXX:101::1/64
EOF
{% endhighlight %}

et qu’on démarre ensuite :

	ifup lxc-br

On configure ensuite l’invité pour utiliser ce pont et y connecter sa future carte réseau virtuelle :

{% highlight bash %}
# cat > /var/lib/lxc/test/config <<EOF
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = lxc-br
lxc.network.name = eth0
lxc.network.veth.pair = test
lxc.network.hwaddr = 02:00:00:XX:XX:XX

lxc.rootfs = /dev/lxc/test

# Common configuration
lxc.include = /usr/share/lxc/config/debian.common.conf

# Container specific configuration
lxc.utsname = test
lxc.arch = amd64
EOF
{% endhighlight %}

On doit ensuite configurer la future carte réseau de l’invité, histoire qu’il accroche des IP dès le boot.
On fait ça normalement, via son fichier `/etc/network/interfaces.d/eth0` standard.
L’invité n’étant pas démarré, on va monter directement son système de fichier et éditer le fichier depuis l’hôte :

{% highlight bash %}
mount /dev/lxc/test /var/lib/lxc/test/rootfs
cat > /var/lib/lxc/test/rootfs/etc/network/interfaces.d/eth0 <<EOF
auto eth0
iface eth0 inet static
	address 10.0.0.2/24
	gateway 10.0.0.1
iface eth0 inet6 static
	address 2001:bc8:XXXX:XXXX:101::1/64
	gateway 2001:bc8:XXXX:XXXX:101::1
EOF
{% endhighlight %}

Vous devriez normalement maintenant pouvoir démarrer votre machine et la pinguer :

	lxc-start -n test -d

Pour avoir accès à une console TTY de l’invité, on passe par `lxc-console -n test`

Et voilà une jolie machine virtuelle opérationnelle en 3 lignes de commande !

En cas de soucis, on peut toujours passer par `lxc-console`, ou monter le système de fichiers de l’invité dans celui de
l’hôte (via `mount`) pour corriger un fichier incorrect ou carrément y faire un `chroot` pour y installer des paquets ou
y faire des choses plus complexes.

Pour donner accès à Internet aux invités, il suffit simplement d’activer l’IP forwarding et de faire un petit coup
de masquerading pour IPv4, comme si on était dans un réseau non virtualisé avec l’hôte en routeur/passerelle :

	#/etc/sysctl.conf
	…
	net.ipv4.ip_forward = 1
	
	net.ipv6.conf.default.forwarding = 0
	net.ipv6.conf.all.forwarding = 0
	net.ipv6.conf.eth0.forwarding = 1
	net.ipv6.conf.lxc-br.forwarding = 1
	
	net.ipv6.conf.all.accept_ra = 0
	net.ipv6.conf.eth0.accept_ra = 2
	net.ipv6.conf.eth0.autoconf = 0
	net.ipv6.conf.eth0.proxy_ndp = 1
	…
	
	#/etc/init.d/firewall
	…
	iptables -A FORWARD -i lxc-private -o eth0 -j ACCEPT
	iptables -A FORWARD -i eth0 -o lxc-private -j ACCEPT
	ip6tables -A FORWARD -i lxc-private -o eth0 -j ACCEPT
	ip6tables -A FORWARD -i eth0 -o lxc-private -j ACCEPT
	iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
	…

Si vous souhaitez à l’inverse router un port ou une IP publique vers un invité, on passe aussi par le pare-feu de l’hôte :

	#/etc/init.d/firewall
	…
	iptables -t nat -A PREROUTING -i eth0 -d X.X.X.X -j DNAT --to-dest 10.0.0.2
	iptables -t nat -A PREROUTING -i eth0 -p tcp --dport YYYY -j DNAT --to-destination 10.0.0.3
	…
