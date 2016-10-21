---
title: ! 'Docker et la tendance de la conteneurisation : a-t-elle vraiment été en production ?'
---

[Docker](https://www.docker.com/). Une technologie si jeune (2013) et pourtant dorénavant vendue un peu partout comme la technologie miracle qui va résoudre tous les problèmes de déploiement, vous rendre riche et vous ramener l’être aimé.

Et pourtant, en pratique cette technologie me pose pas mal de problèmes et de cas de conscience.
Revue de détails.

# Objectif : portabilité

Le but initial est un peu dans le prolongement de ce qu’a fait Java : construire une fois, déployer partout (« build once, deploy everywhere »).
On ne peut nier que l’idée initiale soit bonne tellement le problème du déploiement est un véritable parcours du combattant en pratique.

Un logiciel est rarement un morceau totalement isolé.
Il vient avec son interpréteur, ses bibliothèques, nécessite un moteur de base de données, des fichiers de configuration, un serveur web et tout un tas d’autres choses.
Cet écosystème va être à gérer tout au long de la chaîne de fabrication, que ça soit en développement, en phase de validation/qualification, en recette ou encore en production.

Avant Docker, chaque étape nécessitait de remonter l’ensemble de l’environnement, d’y installer le logiciel (parfois à partir des sources via compilation), de le lancer…
Et c’était un gros bordel, puisque la moindre déviation entre deux environnements pouvait conduire à des bugs non reproductibles en fonction de l’endroit où l’on lançait le logiciel, d’où l’apparition du trop fameux « Ça marche chez moi ™ ».

Avec Docker, point de tout cela.
Les développeurs construisent une image du logiciel qui va contenir tout ce qui lui faut pour fonctionner, depuis l’OS jusqu’au logiciel lui-même en passant par toutes les autres briques.
S’ils ont satisfaction de ce qu’ils ont obtenu, ils livreront à l’étape suivante cette image, qui n’aura pas bougé d’un iota et pourra être lancée à l’identique, et ainsi de suite jusqu’à la très attendue mise en production.

Ça c’est la théorie. Maintenant, la pratique :D

# Besoins de dev ≠ besoin de la prod

Le premier rempart à l’usage de Docker est que les besoins entre la production et le développement sont assez différents.  
Un développeur va vouloir accéder facilement aux journaux, si possible en mode `debug`, alors que la prod préférera les envoyer à un [Logstash](https://www.elastic.co/fr/products/logstash) et en mode `info` voire `warn` ou `error`.
Un développeur préférera utiliser directement le serveur d’application léger de son choix comme [Jetty](https://eclipse.org/jetty/), [Thin](http://code.macournoyer.com/thin/) ou [Gunicorn](http://gunicorn.org/), alors que la production configurera un backend [Nginx](https://nginx.org/) devant ou utilisera des serveurs d’application plus puissant tel que [Tomcat](https://tomcat.apache.org/) ou [Passenger](https://www.phusionpassenger.com/).
Un développeur préférera sûrement compiler en mode `debug` pour avoir des retours utilisables en cas de problème alors que la production insistera pour le faire en mode `release`.
La production voudra mettre en place un pare-feu, ou ses outils de supervision de parc, dont le développement n’a même aucune idée de l’existence puisque ça ne fait pas partie de ses compétences !
J’évite même de parler d’intégrer ses outils de développement à un environnement Docker, par exemple lancer son projet Java présent sur son Eclipse local sur le Tomcat présent sur l’image Docker, ça ferait trop mal.  
Bref, en pratique, c’est compliqué…
On peut quand même s’en sortir pour certains morceaux, surtout grâce à certaines fonctionnalités de Docker, mais l’intérêt en devient limité.

Pour les environnements différents, il « suffit » que les devs travaillent hors Docker à l’ancienne, puis une fois parvenus à quelque chose de satisfaisant, s’attaquent à la construction d’une image Docker. 
Ça implique une espèce de mini-chaîne complète (dev/test/validation/qualification/production) faite uniquement par les développeurs, afin de s’assurer que l’image finale est à peu près conforme à ce qui est attendu (quel logiciel fournir, quelles dépendances disponibles…).
Parce que du coup ça n’implique plus que si ça tourne sur leur environnement de dev, ça tourne sur l’environnement Docker.
Pas forcément très folichon niveau processus sinon avoir ramené toutes les considérations des autres étapes sur celle de développement.

Pour les besoins propres à la production (pare-feu, monitoring…), Docker permet de créer une image à partir d’une autre.
La production repartira donc de l’image fournie par les développeurs pour refaire sa propre image incluant tout le nécessaire.
Ça casse aussi l’intérêt de Docker qui garantit que ça tournera en production, étant donné que la production peut elle aussi introduire des bugs.
Par exemple l’installation d’un pare-feu va peut-être installer une bibliothèque utilisée par l’application mais dans une version différente.
La production devra donc aussi repasser une bonne partie des étapes précédentes (test/validation/qualification) avant la mise en production réelle.
Pas folichon non plus.

Dans les deux cas il aurait été plus intelligent que le dev et la prod travaillent ensemble dès le départ (qui a dit [Devops](https://fr.wikipedia.org/wiki/Devops) ?) pour fournir une image Docker à la QA qui partira en production telle quelle une fois approuvée.
Mais alors qu’on utilise Docker ou n’importe quelle autre technologie (virtualisation classique, automatisation d’installation via un outil comme [Chef](https://www.chef.io/), [Puppet](https://puppet.com/), [Ansible](https://www.ansible.com/) ou [Salt](https://saltstack.com/)) on aurait obtenu le même résultat.

# Quid de la sécurité ?

**LE** gros point noir selon moi.

Docker repose sur le principe d’**immuabilité** des images.
Une fois une image livrée, on n’y touche plus et au prochain changement nécessaire, on refait une image depuis zéro.

Ça pose un problème assez énorme en termes de sécurité.
Le jour où vous avez une faille dans le logiciel livré, on comprend bien qu’on n’échappera de toute façon pas à un correctif, une regénération, un passage intégral de toute la chaîne de qualification et une nouvelle mise en production.
Mais si c’est une bibliothèque utilisée par le logiciel, par exemple [OpenSSL](https://www.openssl.org/) qui connaît au moins une faille critique de sécurité par jour ?

Dans une infrastructure sans Docker, les gentils administrateurs systèmes se seraient sagement connectés en SSH aux machines impactées, auraient simplement fait un `apt update && apt upgrade` et basta.  
Un patch de sécurité n’introduisant pas de changement de fonctionnalités et les développeurs de OpenSSL faisant bien leur travail, ils livrent des versions patchées assurant la rétro-compatibilité avec les versions précédentes.
Les admins peuvent donc appliquer le patch assez rapidement sans avoir besoin de consulter les développeurs.
Et la faille est rapidement corrigée avec un risque de régression négligeable (qu’on a parfaitement su accepter et maîtriser pendant des décennies, et même Docker ne pourra jamais garantir le 0 bug). En prime, le logiciel final, lui, n’a pas changé de version.

Dans une infrastructure dockerisée, c’est une autre histoire…  
Les conteneurs devant être immuables, il est interdit aux administrateurs de se connecter aux machines pour les mettre à jour.
Un changement de sécurité sur une bibliothèque réclame donc de redérouler l’intégralité de la chaîne : on met à jour la bibliothèque, on construit une nouvelle image Docker (qui change donc de version), on repasse toute la QA, on met en production.
La mise en production nécessite un arrêt de l’ancienne image, la migration des données sur la nouvelle image et le redémarrage du système.
Bref, vous allez tourner un long moment avec votre image trouée avant d’avoir pu fixer le problème…

Quand on évoque ce problème avec la communauté Docker, ils avancent alors leur recette miracle : l’**[intégration continue](https://fr.wikipedia.org/wiki/Intégration_continue)**.  
Certes, si vous réussissez à intégrer l’intégralité de la QA (tests unitaires, tests fonctionnels, tests d’intégration, tests de validation, tests de qualification, tests de recette) dans une suite de tests automatiques, c’est peut-être envisageable de faire une modification dans le code, de cliquer sur un bouton et d’avoir automagiquement la nouvelle version en production.  
En pratique, on a déjà du mal à atteindre 100% de couverture sur les tests unitaires, et plus on monte dans les étages plus c’est compliqué. Les tests fonctionnels doivent simuler des humains presse-boutons, les tests d’intégration sont un enfer à réaliser vu le nombre de composants en jeu, les tests de qualification sont souvent longs (tests de performance, de tenue de charge…), etc.  
Sauf à investir un budget colossal en automatisation de tests, l’intégration continue revient finalement à se restreindre à un sous-ensemble des tests (on se limite aux cas principaux et on laisse tomber les cas dégradés par exemple) et donc à potentiellement laisser passer des bugs lorsque les administrateurs pousseront le bouton « Déployer » après une modification rapide pour fixer une faille de sécurité.
Seuls les grands comme Google ou Amazon peuvent se permettre l’outillage de détection d’un problème en production (du [test A/B](https://fr.wikipedia.org/wiki/Test_A/B) par exemple) et donc d’alléger ou de supprimer toutes les phases de test : on déploie plus ou moins à l’arrache, si ça merde, on revient en arrière immédiatement !

Les plus perspicaces d’entre vous auront noté que tout ce qui précède repose sur une hypothèse très forte : on doit être mainteneur de l’image Docker utilisée !  
En pratique, beaucoup utilisent des images pré-construites qu’ils assemblent selon leurs besoins.
Il existe des dépôts d’images, dont le plus connu est le [Hub Docker](https://hub.docker.com/).
Du coup, en cas de faille, il va vous falloir attendre une mise-à-jour.
L’unique mainteneur est [passé sous un bus](http://savoiragile.com/2015/03/19/mefiez-vous-des-bus/) ? Vous êtes mal…  
En termes de sécurité, c’est même encore plus gore dans ce cas, puisque vous n’avez pas beaucoup de moyens de vous assurer que l’image de 600Mo (n’oublions pas que ça intègre un OS complet) que vous allez utiliser n’intègre pas une porte dérobée ou une version obsolète d’une bibliothèque, surtout quand l’image [est réalisée avec les pieds](https://github.com/discourse/discourse_docker/blob/master/image/base/install-nginx#L18-L34) et ne permettent aucune vérification a posteriori.
Les paquets Debian sont par exemple construits en [compilation reproductible](https://wiki.debian.org/ReproducibleBuilds) et vous pouvez facilement vous assurer que le `nginx` que vous utilisez est bien le même que celui du paquet Debian officiel alors que sous Docker, je vous souhaite bien du courage ne serait-ce que pour connaître le numéro de version utilisé.
Sur chaque image Docker, il faudrait faire une revue assez poussée de ce qui se trouve sur l’image, au moins pour lister les différents composants et bibliothèques intégrés et ainsi connaître les impacts réels sur votre parc d’un correctif de sécurité.

# Mono-processus : ma vie, mon œuvre

L’humanité s’est battue pendant des décennies pour mettre en place le multi-processus, puis le multi-thread…
Mais ça c’était avant ! Avec Docker, vous ne pouvez lancer qu’un seul et unique processus dans une image. Pas plus.  
Ça n’a l’air de rien, mais c’est très handicapant en pratique.
Vous ne pouvez pas avoir [`cron`](https://fr.wikipedia.org/wiki/Cron) à tourner régulièrement par exemple. Donc pas de [`logrotate`](https://linux.die.net/man/8/logrotate).
Vous ne pouvez pas avoir de serveur [SSH](http://www.openssh.com/) pour vous connecter à distance sur l’image.
Pas de serveur de mail non plus, par exemple pour les rapports journaliers de [`logwatch`](https://wiki.debian-fr.xyz/Logwatch) (de toute façon on n’a pas `cron` pour les lancer…). Rien.
La seule et unique chose que vous allez pouvoir lancer sera donc votre application. Et c’est tout.

Le problème est que comme on l’a vu précédemment, une application se suffit généralement assez peu à elle-même.
Elle nécessite par exemple une base de données, un frontal web, de pouvoir envoyer des courriels…
Et donc de lancer plusieurs processus !

En méthode *quick & dirty*, vous pouvez contourner le problème en lançant un bête script bash qui lancera tout en arrière-plan, ou plus malin un gestionnaire de processus comme [supervisord](http://supervisord.org/) ou [pups](https://github.com/SamSaffron/pups) qui se chargera lui-même de lancer tout le reste de ce que vous avez besoin.
C’est tout de même assez galère à faire puisque votre distribution adorée vous fournira des scripts de démarrage pour le système d’init habituel (sysv, systemd, upstart…) et non pour supervisord ou pups, il vous faudra donc faire un travail de portage pour chaque composant nécessaire.

La méthode recommandée par Docker pour gérer vos environnements est l’utilisation de [Docker Compose](https://docs.docker.com/compose/).
Vous allez créer autant de conteneurs que de composants de votre écosystème (un pour l’application, un pour la base de données, un pour le serveur de courriel…) et les assembler entre-eux pour qu’ils communiquent correctement.  
Pour certains composants comme la base de données, je trouve ça intéressant de séparer du reste, exactement comme on l’aurait fait dans une infrastructure non virtualisée.
Pour d’autres, comme un serveur de courriel dédié pour envoyer 3 courriels au mois, c’est du gaspillage de ressources flagrant.
Et pour la majorité, c’est d’une prise de tête sans nom…
Par exemple dans une application [Ruby-on-Rails](http://rubyonrails.org/) utilisant [Sidekiq](http://sidekiq.org/) comme ordonnanceur, on va se retrouver à avoir 4 conteneurs :

* 1 pour l’application Ruby-on-Rails
* 1 pour le backend web [nginx](https://nginx.org/)
* 1 pour Sidekiq
* 1 pour le serveur [Redis](http://redis.io/) qui sert à la communication entre RoR et Sidekiq

Alors que tout mettre sur la même machine se justifie largement tant qu’on n’a pas une volumétrie délirante (je tiens les 200.000 vues quotidiennes sur [Cryptcheck](https://tls.imirhil.fr/) sans soucis avec 1 seul conteneur), on se retrouve avec 4 machines à gérer et à devoir mettre à jour (les 4 utilisent OpenSSL par exemple) et une duplication de l’environnement Ruby (RoR & Sidekiq).
On risque aussi de rencontrer des dégradations de performances, puisqu’on passe de communications sur la [boucle locale](https://fr.wikipedia.org/wiki/Localhost) voire des [sockets UNIX](https://fr.wikipedia.org/wiki/Berkeley_sockets) à une communication TCP/IP externe.
Et la sécurité devient tout autant un enfer, avec de la gestion de pare-feu à mettre en œuvre.

Pour gérer autant de conteneurs, vous allez aussi devoir passer à des outils de gestion de déploiement et d’orchestration, comme [Kubernetes](http://kubernetes.io/).
Toujours pareil, quand vous vous appelez Google, Wikimedia, SAP ou Ebay, c’est peut-être gérable. Si vous êtes une petite boîte, ça risque d’avoir un surcoût non négligeable et pas forcément rentable.

# De la chasse aux méga-octets à la chasse aux bugs non reproductibles

On a vu juste avant que Docker incite à créer plein de conteneurs pour les assembler entre eux.
En interne pour la fabrication de ses propres images, Docker se base aussi sur des images pré-construites qu’il empile les unes sur les autres au travers de [OverlayFS](https://docs.docker.com/engine/userguide/storagedriver/overlayfs-driver/).
Pour l’[image Sidekiq](https://hub.docker.com/r/opensnp/rails-sidekiq/), c’est pas moins de 39 couches empilées.

Déjà, ça n’aide pas à la sécurité non plus, puisqu’une faille corrigée sur une couche réclame la reconstruction de toutes les images situées sur les couches supérieures. Ou alors vous corrigez violemment sur votre couche terminale, mais vous dupliquez alors vos bibliothèques (installées par une couche N mais masquées via overlayfs par la couche N+X) et vous avez le travail à faire sur toutes vos images utilisant la couche faillible.

Ensuite, si on utilisait des images standard, on se retrouverait à consommer plusieurs giga-octets pour pas grand-chose.
Du coup, la communauté Docker a commencé à faire la chasse aux méga-octets, et s’est prise de passion pour une distribution présentée comme très légère : [Alpine Linux](https://www.alpinelinux.org/).

Cette distribution vient avec un gros piège… Elle est conçue à la base pour aider à débugger des kernel ! Parce que quand vous développez ce genre de logiciel, vous êtes bien content d’avoir une image de 5Mo qui démarre en 2s, vu le nombre de redémarrages que vous allez faire.
Et comme vous ne ferez presque rien côté utilisateur, on peut y mettre des trucs très légers comme [musl](http://www.musl-libc.org/) et [busybox](https://busybox.net/) au lieu des mastodontes que sont la [glibc](https://www.gnu.org/software/libc/) et les [coreutils](https://www.gnu.org/software/coreutils/).

Sauf que musl n’est pas compatible avec la glibc disponible un peu partout.  
Ni au niveau binaire, ce qui signifie que vous devez compiler explicitement vos logiciels avec cette libc et donc maintenir à la fois un livrable *-glibc* pour les gens hors de Alpine et un *-musl* pour Alpine.  
Ni au niveau fonctionnalités, ce qui fait que vous pouvez rencontrer des bugs incompréhensibles et non reproductibles sur d’autres plate-formes plus standard. Ça peut aller jusqu’à l’impossibilité totale de compiler votre logiciel, comme c’est le cas actuellement avec [OpenJDK 8](https://github.com/gliderlabs/docker-alpine/issues/11) ou [Phusion Passenger](https://github.com/phusion/passenger/issues/1870).

Bref, vous allez vous retrouver à soit utiliser des images du Hub Docker avec une chance [non négligeable](https://github.com/search?l=dockerfile&q="FROM+alpine"&ref=searchresults&type=Code&utf8=✓) d’utiliser un conteneur Alpine dans votre chaîne et faire la chasse aux bugs vraiment chiants à comprendre, soit à devoir faire votre propre image personnelle sans Alpine…
Le tout en croisant les doigts à chaque construction d’image pour ne pas tomber en plus sur une image contenant une faille de sécurité…

Au final, Docker passe en plus complètement à côté de la plaque en termes de consommation de ressources.
À titre d’exemple, la stack précédente RoR/Redis/Sidekiq/Nginx ramène pour 60 overlays Docker et 3.1 Go d’espace disque, quand je m’en tire pour 1.8 Go pour Cryptcheck avec une stack dev/RoR/Redis/Sidekiq/Nginx/Elasticsearch/CryptCheck/données.
[Un beau gâchis d’espace](https://www.youtube.com/watch?v=tXFYxBdKiNY)…

# Une tendance qui se propage de plus en plus

Cette tendance du « je package tout dans un seul truc » est devenu à la mode et on la retrouve vraiment partout.
Même si la complexité induite par ce type de systèmes peut être problématique, c’est vraiment le problème de la gestion de la sécurité qui est très dangereuse en pratique.
On a déjà du mal à maintenir nos parcs plus ou moins à jour avec une infrastructure pas trop complexe, ça risque de devenir un véritable carnage une fois des outils comme Docker (mal) utilisé un peu partout…  

[Go](https://golang.org/), langage d’ailleurs utilisé par Docker lui-même, compile vos projets sous forme d’un [exécutable statique](https://fr.wikipedia.org/wiki/Édition_de_liens) qui embarque donc toutes vos bibliothèques.
Ça a l’avantage de ne pas nécessiter leur installation, mais ça pose tous les problèmes de sécurité vus auparavant avec la recompilation nécessaire de tous vos binaires au moindre changement d’une bibliothèque.  
Sachant en plus que la gestion des dépendances y est très mauvaise puisque se base par défaut sur les branches `master` de dépôts GitHub et non sur des tags, c’est une bombe à retardement dans vos systèmes.
Par exemple vous êtes actuellement incapable de recompiler d’anciennes versions de pas mal de logiciels puisque des dépendances ont fait [des modifications](https://www.google.fr/search?q=undefined:+os.Unsetenv) [non rétro-compatibles](https://www.google.fr/search?q=undefined:+os.Unsetenv#q=+unknown+tls.Config+field+'GetCertificate'+in+struct+literal) avec les anciennes versions de Go et que les versions des dépendances utilisées à l’époque ne sont mentionnées nulle part.
La situation devrait cependant s’améliorer avec l’introduction du *vendoring* depuis [Go 1.5](https://github.com/golang/go/wiki/PackageManagementTools#go15vendorexperiment).

[Snap](http://snapcraft.io/docs/snaps/), ~~la nouvelle idée à la con~~ le nouveau format de paquets d’Ubuntu/Canonical embarque aussi dans une image statique votre logiciel et toutes ses bibliothèques.
La problématique de sécurité devient encore pire puisqu’ici, on parle d’une utilisation en tant qu’environnement de bureau.  
Par exemple sur mon PC, je me retrouverais avec 60 versions de libssl, utilisée par postfix, openssl, bind9, gstreamer, virtualbox, isync, ntp, postgresql, nmap, tor, mumble, irssi, xca, openssh, apache2, telnet ou encore socat…
Le jour où il faudra mettre à jour tout ça, ça va être une belle tranche de rigolade et on n’aura sûrement pas la réactivité qu’a pu avoir le projet Debian sur Heartbleed par exemple, corrigé en [quelques heures](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=743883) et disponible tout aussi rapidement sur l’ensemble des dépôts.
[Quand je leur ai posé la question](https://kyrofa.com/posts/snapping-nextcloud-mysql#comment_39), ils ont uniquement réfléchi à la mise-à-jour d’un point de vue « binaires » et n’ont même pas pensé à la problématique des migrations de données.  
Encore une fois, transformer les mainteneurs d’une application en mainteneurs d’un écosystème complet est loin d’être anodin ici, et le travail à abattre fera que la sécurité ne pourra plus être assurée.

# Comment fait-on alors ?

Utiliser des conteneurs, ça peut quand même avoir du bon.

Je m’en sers beaucoup en développement pour monter un environnement stable et surtout pouvoir gérer des environnements difficiles à mixer proprement dans un même système (gcc 4.9 & 6.1 par exemple) ou avec des dépendances pouvant entrer en conflit avec celles du système (l’enfer ffmpeg/avidemux/audacity…).  
Ça permet aussi de revenir rapidement à un état propre et maîtrisé. En phase de développement on a généralement tendance à installer des tonnes de choses à la truelle et à modifier violemment son système pour faciliter le debug ou pour chercher la cause d’un problème. Mais c’est toujours intéressant de recompiler sur une machine vierge pour vérifier qu’on n’a pas oublié un bout.  
Et enfin ça peut faciliter la reproductibilité d’un bug si l’utilisateur qui le détecte parvient à vous fournir une image démontrant le problème plutôt que de faire face à des « mais ça ne marche pas chez moi ™ ».

Mais par pitié, arrêtez de vouloir mettre en production des blobs galères à gérer, en particulier en termes de sécurité, qui compliquent le moindre audit pour savoir ce qui tourne là-dedans et qui transforment les infrastructures en plat de spaghetti…

Un petit conteneur [LXC](https://linuxcontainers.org/lxc/) tout simple, construit à partir de [debootstrap](https://wiki.debian.org/fr/Debootstrap) générant une image de maximum 200Mo toute mouillée et dans laquelle vous allez installer vos logiciels au mieux avec du apt/dpkg standard et au pire quelques scripts automatisant l’installation (du bon vieux bash over chroot ou du ansible/salt), ça fonctionne simplement et c’est [facile à gérer](https://wiki.debian.org/UnattendedUpgrades) côté sécurité.
Et vous découpez vos conteneurs non plus par logiciel comme sous Docker, mais par besoin : 1 conteneur pour toute la stack Discourse, 1 pour votre serveur de courriel entrant, 1 pour votre serveur DNS faisant autorité, etc.
