---
title: Installer un nœud Tor
---

Le [projet Tor](https://www.torproject.org/) vise à construire un réseau d’anonymisation, géré par la communauté et donc très robuste à la plupart des attaques courantes.
La seule véritable attaque à laquelle ce réseau soit faillible est une [attaque sibylle](https://en.wikipedia.org/wiki/Sybil_attack), c’est-à-dire qu’un attaquant parvienne à infester le réseau de nœuds sous son contrôle et à dépasser les 66% de présence, ce qui d’un point de vue probabiliste lui permet de s’assurer que tout utilisateur va passer par au moins 2 de ses nœuds
 sur les 3 que constitue un circuit Tor et ainsi de désanonymiser le circuit.

Pour se protéger de cette attaque, le réseau Tor possède une protection logicielle qui sélectionne correctement les 3 nœuds d’un circuit pour éviter de tomber sur des nœuds potentiellement utilisés par la même personne (3 pays différents, sur 3 plages d’IP différentes, en sélectionnant plutôt les nœuds les plus anciens, etc) mais on peut aussi la combattre en diversifiant nous-même le réseau et en allumant le plus possible de machines saines (plus il y a de nœuds, plus en contrôler au moins 66% nécessite de moyens financiers, techniques et humains).

Si vous avez des machines à disposition, n’hésitez donc pas à allumer des nœuds, dont voici un tutoriel d’installation !

# Ressources nécessaires

## Bande passante

La vitesse réelle d’un client via le réseau Tor est la vitesse du plus lent des 3 nœuds choisis pour construire un circuit.
Pour ne pas pénaliser un client, il faut donc avoir un nœud le plus rapide possible.
Si vous hébergez votre nœud derrière votre ligne ADSL à 50kbps en sortie, vous n’imaginez même pas comment vos clients vont littéralement vous haïr…

Si vous n’avez pas une bande passante d’au moins 10Mbps **en sortie**, passez votre chemin ou tournez-vous vers l’hébergement d’un [bridge](https://www.torproject.org/docs/bridges.html), qui cherche plus à permettre de continuer à
 émettre dans les pays vraiment censurés qu’à faire des concours de visionnage de vidéo HD sur [YouPorn](http://www.youporn.com/watch/9912017/sexe-alcool-et-vie-privee/).

Un nœud Tor consommera potentiellement toute la bande passante que vous lui accorderez, il est donc plus que conseillé de calculer le coût de sa bande passante mensuelle, qui peut vite atteindre des sommes colossales si vous n’êtes pas en *unmetered* !
Comptez au bas-mot 5.000€ mensuel (300To/mois de données up **ET** down) pour un nœud 100Mbps au tarif habituel…

## CPU

Un nœud Tor passe sa vie à servir de routeur pour relayer le trafic qui lui arrive, qui en plus est chiffré.
Il va donc avoir besoin de *beaucoup* de CPU.
Le chiffrement utilisé étant de l’AES, il est conseillé d’utiliser plutôt un processeur possédant les extensions [AES-NI](https://en.wikipedia.org/wiki/AES_instruction_set) qui permettent du chiffrement matériel plutôt que logiciel, donc plus rapide et moins consommateur en temps de calcul.

Pour fixer les idées, un nœud 100Mbps consomme 30 à 40% d’un
 [Intel Xeon E3-1220](http://ark.intel.com/products/65734/Intel-Xeon-Processor-E3-1220-v2-8M-Cache-3_10-GHz).

Tor souffre actuellement d’un problème logiciel :
 [il ne profite pas du multi-cœur/multi-threading](https://trac.torproject.org/projects/tor/ticket/1749).  
Le facteur limitant est donc généralement le CPU. Vous saturerez bien plus vite votre CPU que votre bande passante ou votre mémoire, le meilleur des CPU du marché actuel n’arrive à tirer que 500Mbps de trafic Tor et les CPU classiques
 dans les serveurs dépassent péniblement les 100 ou 200Mbps.  
Si on veut profiter à plein de sa bande passante au-delà de 100Mbps, il est fort probable qui faille alors lancer plusieurs instances de Tor sur la même machine pour tirer 100 ou 200Mbps sur chaque et ainsi utiliser toute la bande passante disponible.
(Ce tutoriel ne traite pas ce point, pour le moment en tout cas.)

## Mémoire

Un nœud a besoin de stocker les circuits construits, et plus un nœud est gros, plus il construit de circuits en permanence.
Ces informations sont stockées en RAM, il faut donc s’assurer d’en avoir assez.

Toujours pour ordre de grandeur, un nœud 100Mbps construit en permanence 2.000 à 3.000 circuits, pour une consommation de RAM de l’ordre de 500Mo.

## Sélection de l’AS et de l’IP

Les AS (pour [Autonomous System](https://fr.wikipedia.org/wiki/Autonomous_system)) sont des numéros attribués aux acteurs du réseau Internet.
Pour éviter une attaque sibylle, on souhaite éviter qu’une entité, quelle qu’elle soit, ne puisse contrôler une grosse partie du réseau.
Un AS pouvant décider de se mettre à analyser son trafic Tor pour faire de la corrélation de trafic, on doit donc chercher à disséminer le plus possible les nœuds chez des AS différents.

Le numéro d’AS étant assez difficile à obtenir de manière fiable quand on est simple client Tor, le réseau ne peut (pour le moment) pas s’en servir pour déterminer un circuit de 3 nœuds ne passant pas 2× par le même AS.
Puisqu’il faut quand même bien limiter le risque, il a été décidé de se baser sur la plage d’adresse du nœud pour faire la distinction, et d’empêcher un circuit de contenir plus de 2× la [même plage /16](https://fr.wikipedia.org/wiki/Sous-réseau), un même /16 n’étant que très rarement partagé par plusieurs AS.

Si on veut héberger un nœud, il vaut donc mieux chercher à le mettre sur une plage d’IP (et si possible un AS) qui n’en héberge pas déjà ou peu.
On peut se servir des données de [Tor metrics](https://metrics.torproject.org/) pour trouver si [une plage](https://metrics.torproject.org/bubbles.html#network-family) ou [un AS](https://metrics.torproject.org/bubbles.html#as) contient déjà des nœuds.

Le problème de ce choix de l’IP/AS est qu’il doit résoudre une quadrature du cercle.
On a besoin de gros nœuds sous peine de ralentir la connexion des clients.
Héberger un gros nœud consomme de facto beaucoup de bande passante (300-500Mbps, voire 1Gbps), qui n’est disponible en grande quantité (>100Mbps) que chez les gros fournisseurs.
Le gros volume de bande passante consommé ne rend possible l’hébergement que sur des offres dites *unmetered* (où on ne paie pas ou presque cette bande passante), offres qui ne sont actuellement accessibles que chez 3 prestataires (
 [OVH](https://www.ovh.com/fr/serveurs_dedies/)/[Kimsufi](http://www.kimsufi.com/fr/), [Online](https://www.online.net/fr/serveur-dedie) et plus anciennement [Hetzner](https://www.hetzner.de/en/hosting/produktmatrix/rootserver)), sous peine de vider son compte Bitcoin chaque mois.
Du coup on se retrouve actuellement avec OVH et Online qui trustent la majorité des gros nœuds Tor, comme l’atteste Tor metrics, et qui pourraient donc faire des choses assez moches avec ce réseau si l’envie leur prenait !

À vous donc de résoudre ce douloureux problème : hébergez de gros nœuds chez les seuls hébergeurs qui permettent de le faire mais qui trustent le réseau, de ne rien héberger du tout, ou de donner des sous à [Nos Oignons](https://nos-oignons.net/) !
Évitez tout de même OVH, [qui concentre trop de nœuds actuellement](https://lists.riseup.net/www/arc/tor-relays-fr/2015-07/msg00000.html).

## Sélection du mode de fonctionnement 

Un nœud Tor peut fonctionner dans 3 modes : Guard, Exit ou Bridge.
Pour schématiser, les guards sont les points d’entrée des circuits (position 1), les exits les points de sortie (position 3) et les bridges sont des guards cachés (les nœuds Tor non bridges étant publiques et donc blacklistables facilement par une entité qui souhaiterait interdire l’usage du réseau Tor).

Si vous avez une grosse bande passante (>10Mbps), préférez le mode Guard, le réseau en a besoin.
Pour les petites bandes passantes (<10Mbps), un bridge peut être très intéressant pour se défendre contre la censure.

Il est plus que fortement déconseillé de se lancer seul dans l’aventure d’un Exit.
La sortie du circuit se substituant au client final, si le circuit est utilisé à des fins malhonnêtes (pédo-pornographie, terrorisme…), c’est l’Exit qui va apparaître partout.
Même si les lois [européenne](http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CELEX:32000L0031:En:HTML) et [française](http://www.legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006465735&cidTexte=LEGITEXT000006070987) protègent les opérateurs de nœuds de sortie (ils ne peuvent pénalement pas être poursuivis pour l’usage qui est fait de
 leurs nœuds), ça peut tout de même conduire à de [mauvaises](https://lists.riseup.net/www/arc/tor-relays-fr/2012-12/msg00001.html) [surprises](https://lists.riseup.net/www/arc/tor-relays-fr/2013-05/msg00000.html).
Si vous voulez aider le réseau dans ce sens, rejoignez-plutôt [Nos Oignons](https://nos-oignons.net/), une association qui gère des nœuds de sortie en France et qui peut s’appuyer sur des juristes, de la trésorerie et des bénévoles pour répondre aux mails, convocations et saisies associés à la gestion d’un nœud de sortie.

# La pratique

## Instance Tor

Pour commencer, il faut éviter d’utiliser la version Tor fournie par Debian, mais plutôt privilégier celle du projet Tor lui-même, cf [ici](https://www.torproject.org/docs/debian.html.en) :

	gpg2 --recv-key 0xEE8CBC9E886DDD89
	gpg2 --fingerprint 0xEE8CBC9E886DDD89
	pub   2048R/0xEE8CBC9E886DDD89 2009-09-04 [expire : 2020-08-29]
	 Empreinte de la clef = A3C4 F0F9 79CA A22C DBA8  F512 EE8C BC9E 886D DD89
	uid                [ inconnue] deb.torproject.org archive signing key
	sub   2048R/0x74A941BA219EC810 2009-09-04 [expire : 2018-08-30]
	gpg2 --export -a 0xEE8CBC9E886DDD89 | apt-key add -
	echo "deb http://deb.torproject.org/torproject.org jessie main" > deb http://deb.torproject.org/torproject.org jessie main
	apt update && apt install tor deb.torproject.org-keyring

Prenez bien soin de vérifier l’empreinte de la clef GPG du projet Tor !
Si la clef est mauvaise, vous pourriez installer une version compromise !

Ensuite, on configure l’instance Tor elle-même via `/etc/tor/torrc`, ici pour une instance de 150Mbps :

	SocksPort 0
	NumCPUs 2
	
	ORPort 9001
	ORPort [<votre adresse IPv6 ici]:9001
	Address <l’IP de votre nœud ou son FQDN>
	Nickname <un petit nom sympa>
	
	MaxAdvertisedBandwidth 150Mbits
	BandwidthRate          135Mbits
	BandwidthBurst         175Mbits
	
	DirPort 9030
	DirPort [::]:9030 NoAdvertise
	
	ExitPolicy reject *:*
	ExitPolicy reject6 *:*

Pour ma part, j’ai 300Mbps de bande passante garantie, ce qui ne peut pas être saturé qu’avec une seule instance Tor.
J’ai donc 2 instances, bloquées à 135Mbps (avec des dépassements à 175Mbps autorisés), soit 270Mbps continus (et des pics à 310Mbps possibles).
Adaptez les limites de bande passante à votre configuration, et consultez
  [la documentation](https://www.torproject.org/docs/tor-manual.html.en) Tor pour plus d’informations.

On démarre ensuite le service via `service tor restart` et voilà, on a un joli petit nœud Tor :)

Ensuite, il faut attendre. [68 jours](https://blog.torproject.org/blog/lifecycle-of-a-new-relay) !!!
En effet, un nouveau nœud inconnu ne peut pas avoir la confiance du réseau. Il va donc passer en mode « sous surveillance » pour juger de ses compétences et qualités (stabilité, bande passante disponible…).
Au fur et à mesure de sa jeunesse, il va acquérir de plus en plus de drapeaux : Running, Stable, Valid, Fast et enfin le tant convoité Guard au bout de 8 jours si tout se passe bien et que le nœud est suffisamment rapide et stable.

Et là… On repart à 0 ! Chaque client stocke sa liste de Guard pour une durée comprise entre 4 et 8 semaines, et donc personne ne vous connaîtra à nouveau dans le réseau et il faudra attendre jusqu’à 8 semaines pour arriver à pleine capacité, le temps pour l’ensemble du réseau de vous connaître et de vous utiliser.

Au bout de 70 jours, on a donc obtenu son nœud final.  
On peut suivre l’évolution de son nœud sur [Atlas](https://atlas.torproject.org/) ou [Globe](https://globe.torproject.org/) ou installer [Tor-ARM](https://www.torproject.org/projects/arm.html.en) directement sur le serveur.

## Anti-DDOS (SYN-flood)

Les nœuds Tor étant mal vus de certaines personnes, il est courant de voir son nœud attaqué par du [DDOS](https://fr.wikipedia.org/wiki/Attaque_par_déni_de_service), surtout à ses débuts.
Si vous hébergés vos nœuds chez Online ou OVH, leur réseau est
 [déjà protégé](https://www.online.net/fr/serveur-dedie/ddos-arbor) [contre ce type d’attaque](https://www.ovh.com/fr/anti-ddos/) mais laisse quand même passer quelques bouts, en particulier des attaques [SYN-flood](https://fr.wikipedia.org/wiki/SYN_flood).

Pour les détecter et les bloquer, j’ai du innover un peu, et concevoir ce joli one-liner qui détecte les tentatives de syn-flood dès 10 connexions SYN ouvertes par la même adresse IP :

	ss -4n state SYN-RECV | tail -n +2 | awk '{print $5}' | awk -F: '{print $1}' \
		| sort | uniq -c | awk '{ if ($1 > 10) print $2 }'

À vous de voir ensuite ce que vous voulez en faire fonction de votre type de firewall, pourquoi pas dans un cron horaire.

## Anti-auto-flood

Un nœud Tor a tendance à consommer toute la bande passante disponible si on le laisse faire et le but est d’avoir le nœud le plus efficace possible, donc de le laisser prendre ses aises.
 
Mais on peut rencontrer deux effets de bords :

  * la connectivité de votre serveur est peut-être en 1Gbps mais votre fournisseur ne vous garantit que 300Mpbs réel,
  * vous avez peut-être envie d’utiliser votre serveur pour autre chose (même si ce n’est pas forcément une bonne idée, surtout si vous hébergez un nœud de sortie).

Du coup, on va vouloir limiter l’utilisation du nœud Tor pour lui faire consommer uniquement la bande passante maximum autorisée par le fournisseur mais aussi lui faire diminuer son débit si votre serveur en a besoin.
On va pour cela utiliser le *[traffic shapping](https://fr.wikipedia.org/wiki/Traffic_shaping)*.

On va mettre le trafic Tor dans une file moins prioritaire que le reste du trafic réseau (ce qui limitera le trafic Tor en cas de besoin de la bande passante pour autre chose) tout en lui garantissant au moins 100Mbps, puis bloquer le trafic de la carte au maximum autorisé par notre hébergeur (ici 300Mbps).
L’incantation magique :

	DEV=eth0
	CAP_BW=300mbit
	TOR_BW=100mbit
	
	tc qdisc add dev $DEV root handle 1: htb default 10
	
	tc class add dev $DEV parent 1:  classid 1:1 htb rate $CAP_BW ceil $CAP_BW
	tc class add dev $DEV parent 1:1 classid 1:10 htb rate $CAP_BW ceil $CAP_BW prio 0
	tc class add dev $DEV parent 1:1 classid 1:11 htb rate $TOR_BW ceil $CAP_BW prio 1
	
	tc qdisc add dev $DEV parent 1:10 handle 10: sfq perturb 10
	tc qdisc add dev $DEV parent 1:11 handle 11: sfq perturb 10
	
	tc filter add dev $DEV parent 1:0 prio 0 protocol ip handle 10 fw flowid 1:10
	tc filter add dev $DEV parent 1:0 prio 0 protocol ip handle 11 fw flowid 1:11
	
	iptables -t mangle -A POSTROUTING -p tcp --sport 9001 -j MARK --set-mark 11
	iptables -t mangle -A POSTROUTING -p tcp --sport 9030 -j MARK --set-mark 11

Si vous souhaitez (mieux) la comprendre, direction la documentation de [tc](http://lartc.org/manpages/tc.txt) [tc-htb](http://lartc.org/manpages/tc-htb.txt) et [iptables-mangle](http://www.inetdoc.net/guides/iptables-tutorial/mangletable.html).

Adaptez ce script à vos besoins, et faites-le s’exécuter au démarrage de votre machine ou de votre carte réseau.
