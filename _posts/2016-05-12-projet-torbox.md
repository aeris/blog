---
title: Projet Tor Box
---

Un petit billet pour vous présenter un projet qui me tient à cœur mais qui malheureusement traîne un peu faute de temps libre, mon projet de « Tor Box ».

# Besoins

Une Tor Box, c’est une idée qui a commencé à germer il y a quelque temps dans la communauté (et dans ma tête).

Sur le papier, c’est assez simple : vous branchez une Tor Box à une prise de courant, vous vous connectez au réseau Wifi qui apparaît, c’est gagné, toutes vos connexions sortantes vont dorénavant être torrifiées sans que vous n’ayez quoi que ce soit à installer sur votre machine.
Tout ce qui n’est pas du Tor y est de force envoyé.
Tout ce qui ne peut pas l’être y est de force sauvagement interdit et bloqué.
De base. Sans exception. Jamais.

Personnellement, c’est quelque chose qui m’intéresse assez, puisque les solutions actuellement proposées ne me conviennent pas complètement.

À l’extrême, vous avez [Tails](https://tails.boum.org/), un système live USB qui ne laisse pas de traces et qui va aussi faire passer toutes vos connexions au travers du [réseau Tor](https://www.torproject.org/).
Difficile à utiliser au quotidien, le fait d’être amnésique (même s’il est possible de créer un [disque persistant](https://tails.boum.org/doc/first_steps/persistence/configure/index.fr.html)) fait que vous ne pouvez rien sauvegarder entre chaque reboot, ni vos documents personnels ni des applications installées par la suite.
Si vous êtes journaliste en zone de guerre, dissident dans un pays peu démocratique ou lanceur d’alerte en voyage, Tails est parfait, mais pour le commun des mortels, c’est un peu lourd à utiliser.

Pour votre navigation web, vous pouvez vous munir du [Tor Browser](https://www.torproject.org/projects/torbrowser.html), un Firefox modifié pour protéger votre vie privée.
Ou prochainement le [Tor Messenger](https://trac.torproject.org/projects/tor/wiki/doc/TorMessenger) pour votre messagerie instantanée.
Ces solutions ont pour moi quelques inconvénients.
Déjà, vous ne mettez votre identité à l’abri que si vous utilisez ces logiciels bien précis.
Vous utilisez Chrome ou Pidgin ? Vous n’êtes pas à l’abri…
Vous êtes plus geek et vous utilisez SSH ou ZNC ? Pas de bol, pas protégé non plus…
En plus de ça, pour chaque application Tor QuelqueChose, vous avez un client Tor complet à se lancer.
Donc si vous utilisez Tor Brower et Tor Messenger en même temps, pouf, deux clients Tor.
Clairement ça ne passe pas l’échelle et le processus ne serait pas utilisable si on se mettait à torrifier l’ensemble des applications utilisées.

Il reste la dernière solution : l’huile de coude.
Monter un client Tor directement sur sa machine (via [Vidalia](https://en.wikipedia.org/wiki/Vidalia_(software)), malheureusement plus maintenu, ou [Arm](https://www.torproject.org/projects/arm.html.en)), et configurer chaque application pour utiliser le [proxy SOCKS](https://fr.wikipedia.org/wiki/SOCKS) fournit par le client Tor.
Non seulement ce n’est pas à la portée de tout le monde (voire « [c’est compliqué](https://twitter.com/aeris22/status/728211588059107328) © »), mais en plus [certaines applications](https://github.com/znc/znc/issues/143) ne supportent tout simplement pas les proxy SOCKS et on doit se résoudre à alors utiliser des contournements à base de [torsocks](https://trac.torproject.org/projects/tor/wiki/doc/torsocks), de [privoxy](https://www.privoxy.org/faq/misc.html#TOR) pour monter un proxy HTTP (généralement mieux supporté que SOCKS) par-dessus ou encore à devoir jouer avec iptables et le [proxy transparent](https://trac.torproject.org/projects/tor/wiki/doc/TransparentProxy) fourni par le client Tor.
C’est en plus loin d’être idéal en termes d’anonymat (fuite DNS, problème de configuration)…

Histoire d’être complet, on peut aussi citer le projet [QubeOS](https://www.qubes-os.org/) qui prend en charge vos connexions via Tor, et qui en plus d’être soutenu par [Edward Snowden](https://twitter.com/Snowden/status/728208443002101760), semble plus utilisable au quotidien que Tails, mais est aussi parfois difficile à l’usage à cause / grâce à son modèle de menace assez élevé.

Une Tor Box serait donc l’outil idéal pour éviter de se prendre la tête et mettre toutes ses connexions à l’abri, tout en étant utilisable par le grand public, y compris ses invités à la maison, pour toutes les applications utilisées.  
(NB: c’est évident mais ça ira mieux en le disant, passer par Tor ne suffit pas à garantir votre anonymat, en particulier si vous utilisez un navigateur web !)

# Difficultés

Beaucoup d’équivalents à la Tor Box ont déjà été mis plus ou moins sur le marché.
Par exemple l’[Anonabox](http://www.journaldugeek.com/2014/10/19/lanonabox-quand-le-tor-tue/), le [SafePlug](https://pogoplug.com/safeplug) ou encore [TorFi](https://www.kickstarter.com/projects/torfi/torfi), [Project Sierra](https://www.kickstarter.com/projects/2125059549/project-sierra-plug-and-play-data-encryption-and-w), [WE Magin](https://www.kickstarter.com/projects/1052775620/wemagin-smart-usb-drive), [InvizBox](https://www.indiegogo.com/projects/invizbox-privacy-made-easy/) ou [Cloak](https://www.kickstarter.com/projects/1227374637/cloak?token=8b00d141).
Ces projets ne sont **pas** sécurisés et ne doivent **pas** être utilisés, parce qu’en apparence un tel système semble simple à réaliser mais en pratique, il est rempli de pièges…

## Mises-à-jour

Déjà, la plupart des projets « concurrents » se basent sur des systèmes type [OpenWRT](https://openwrt.org/) ou [Yocto](https://www.yoctoproject.org/).
Ces systèmes compilent un gros binaire ([BSP](https://en.wikipedia.org/wiki/Board_support_package)) qu’il faut flasher tel quel sur la carte-mère.
Ce qui veut dire qu’il est très difficile de les mettre à jour, et encore moins pour quelqu’un sans compétence technique.
En cas de mise-à-jour, il faut en effet refaire tout le binaire, l’envoyer aux utilisateurs, qui doivent flasher à nouveau leur matériel, avec le risque de le casser (bricker) à chaque fois.
Il faut même parfois sortir le fer-à-souder ou le [port série](https://fr.wikipedia.org/wiki/UART) pour y parvenir.
En bref, ce type de matériel est plus proche du kleenex jetable que d’autre chose : une fois dans la nature, il est quasiment impossible à mettre à jour.

Or, on va devoir mettre du matériel cryptographique sur notre petit joujou, au minimum Linux, GNU, OpenSSL et Tor.
Donc on va devoir s’assurer que nos utilisateurs seront à jour sans devoir racheter un matériel complet.
OpenSSL se met à jour [plusieurs fois par mois](https://www.openssl.org/news/changelog.html), Tor [tous les quelques mois](https://gitweb.torproject.org/tor.git/refs/).
Et le plus rapidement possible en cas de découverte de grave faille de sécurité.

Pour une Tor Box décente, on doit donc plutôt privilégier les systèmes qu’on peut mettre à jour facilement, à distance, et s’orienter vers une bonne vieille distribution GNU/Linux des familles.

## Ne jamais croiser les effluves

Comme signalé au-dessus, on va torrifier tout le trafic des utilisateurs de la Tor Box.
Mais il se passe quoi si l’un d’eux utilise aussi Tor ?
On se retrouve avec du Tor dans du Tor…
Et [c’est le mal](https://trac.torproject.org/projects/tor/wiki/doc/TorifyHOWTO#ToroverTor)…

On ne peut pourtant pas interdire à un utilisateur d’utiliser Tor (il peut ne même pas savoir qu’il l’utilise d’ailleurs), d’autant plus qu’il est plus que conseillé d’utiliser le Tor Browser pour sa navigation web.
Il faut donc parvenir à détecter l’usage de Tor.
Hors de question d’utiliser du [DPI](https://fr.wikipedia.org/wiki/Deep_packet_inspection), déjà parce que ce n’est pas éthique, ensuite parce que la box n’aura jamais les resources nécessaires pour le faire, et enfin parce que ça ne serait pas efficace, le but de Tor étant justement d’éviter d’être détectable facilement par du DPI.

Par contre, on a une énorme base de données des nœuds Tor connus par le réseau Tor : [son consensus](https://consensus-health.torproject.org/).
On peut s’en servir pour deux choses : ouvrir les ports du pare-feu afin que le client Tor de la box puisse communiquer avec le réseau (tout le reste est bloqué), mais en profiter aussi pour détecter qu’un utilisateur utilise déjà Tor pour ne pas retorrifier sa connexion.

## UDP

Tor ne supporte que TCP comme mode de communication. UDP n’est donc pas utilisable.
Pas de bol, c’est en UDP que fonctionne le système [DNS](https://fr.wikipedia.org/wiki/Domain_Name_System) (pour la résolution des noms de domaine) ainsi que le protocole [NTP](https://fr.wikipedia.org/wiki/Network_Time_Protocol) (pour la mise à l’heure).

Alors que le manque de DNS peut être contourné (Tor en supporte quand même une partie), le manque de NTP va être handicapant puisqu’il faut absolument une horloge relativement à jour pour pouvoir se connecter au réseau Tor (son consensus n’est valable que sur une plage de 3h).

# État d’avancement

Le but de la Tor Box est d’être abordable aux plus grands nombres et facilement transportable.
Les petites cartes [A20 OLinuXino Lime](https://www.olimex.com/Products/OLinuXino/A20/A20-OLinuXino-LIME/open-source-hardware) d’Olimex, à 30€ pièce semblent de bonnes candidates pour ce projet, d’autant plus qu’elles ont un côté hardware libre intéressant (rappelez-vous, la sécurité par l’obscurité, ce n’est pas possible).

Le plus gros du travail a été de porter le noyau LIME d’une [version 3.4 patchée pour sunxi](https://linux-sunxi.org/) à un noyau 4.4 vanilla, en particulier pour le support de l’[USB OTG](https://fr.wikipedia.org/wiki/USB_On-The-Go) et de l’[Ethernet CDC](https://en.wikipedia.org/wiki/Ethernet_over_USB) qui permettent d’utiliser le port mini-USB de la LIME comme carte réseau pour le développement et à terme pourra servir d’interface d’administration de la box (non torrifiée mais du coup limitée au réseau interne).

Une Tor Box doit pouvoir être mise-à-jour régulièrement pour corriger les trous de sécurité, ça tombe bien les Olimex sont capables de faire tourner un environnement GNU/Linux standard, en l’occurence une [Debian](https://www.debian.org/).
Le projet actuel permet de cross-compiler une Debian ARM flashable sur carte SD et contenant tout le nécessaire pour monter un client Tor.

La LIME ne possédant pas d’[horloge temps réel](https://fr.wikipedia.org/wiki/Horloge_temps_réel) (elle repart au 1er janvier 1970 à chaque démarrage), et NTP étant inutilisable avec Tor, le processus de boot de Tor [a du être amélioré](https://github.com/aeris/torbox/blob/master/overlay/usr/local/bin/boot-tor) pour pouvoir détecter l’heure depuis les informations disponibles sur le réseau et ainsi corriger l’heure système.

Enfin, une fois Tor démarré, l’analyse du consensus via la bibliothèque [Stem](https://stem.torproject.org/) et l’outil réseau [ipset](http://ipset.netfilter.org/) permet de [collecter les adresses et ports](https://github.com/aeris/torbox/blob/master/overlay/usr/local/bin/update-tor-ipset) des nœuds Tor pour initialiser le pare-feu.

Le projet est disponible en l’état [ici](https://github.com/aeris/torbox).
Il contient le nécessaire pour construire une image Debian démarrant un client Tor avec un pare-feu de nazi.
La documentation ainsi que l’environnement de développement (Virtualbox) devraient arriver bientôt.

# Les (beaucoup de) choses restant à faire

Pour le réseau Wifi, il reste à trouver des antennes Wifi compatibles GNU/Linux.
La plupart de celles que j’ai trouvées sur Internet à pas cher sont vendues comme des Ralink RT5370, pouvant faire point d’accès, mais sont en réalité des Ralink MT7601U, qui n’ont [pas de pilote point d’accès pour GNU/Linux](https://github.com/kuba-moo/mt7601u/issues/4).
Les cartes a priori garanties RT4370 sont introuvables sauf à les payer autant voire plus chères que la carte LIME elle-même…
Je tourne actuellement avec des Realtek RTL8188CUS, mais elles n’ont pas beaucoup de portée car sans antenne.
La gestion du point d’accès est encore à réaliser avec [hostapd](https://w1.fi/hostapd/).

Pour le contrôle du client Tor, on ne peut pas demander aux utilisateurs de maîtriser SSH et la ligne de commande…
Il va donc falloir développer une interface web « à-la-arm/vidalia » pour générer le torrc nécessaire au bon usage de Tor (passage par un proxy, utilisation de bridge ou de protocoles d’obfuscation, etc), lancer les mises-à-jour logicielle…
Stem pourrait aussi servir pour ça, vu qu’il a déjà beaucoup de choses de disponibles pour [contrôler un démon Tor](https://stem.torproject.org/api/control.html).
Compétences en Python/Django bienvenues !

Enfin, la box ne servira pas uniquement de client Tor, mais permettra d’avoir accès à des ressources sur la protection de sa vie privée en ligne, par exemple à des images de Tails, à des exemplaires du [Guide d’Autodéfense Numérique](https://guide.boum.org/), en local sur la box. Une trousse d’urgence en quelque sorte.
Un outil pour mettre à jour tout ça doit être développé.

Et enfin, la partie la plus galère du projet : assurer un [build reproductible](https://2015.rmll.info/compilations-reproductibles-dans-debian-et-partout-ailleurs).
Et ça, ça ne va clairement pas être de la tarte :P

Si vous voulez filer un coup de main sur ce projet, vous êtes les bienvenus !
