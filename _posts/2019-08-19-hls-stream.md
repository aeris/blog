---
title: Streaming HLS
---

Déjà 2 ans sans article de blog… On va corriger ça du coup !

Aujourd’hui, on va parler streaming, et surtout comment en faire avec (presque) que du logiciel libre et en tout cas en évitant au maximum les outils habituels privateurs et en proposant des alternatives auto-hébergeables et décentralisées pour tous !

# Les problèmes du streaming « standard »

Le streaming « à l’ancienne » est généralement basé sur un flux TCP continu, type [RTP](https://fr.wikipedia.org/wiki/Real-time_Transport_Protocol), [RTSP](https://fr.wikipedia.org/wiki/Real_Time_Streaming_Protocol) ou [RTMP](https://fr.wikipedia.org/wiki/Real_Time_Messaging_Protocol).

Ces formats fonctionnent plutôt bien tant qu’on a à disposition du matériel professionnel de diffusion, mais c’est généralement la croix et la bannière quand on veut faire avec du matériel classique comme on en a partout à la maison.

Le principal problème de ce type de flux est qu’il s’agit justement d’un flux ! Il faut une connexion permanente et stable entre le lieu de la captation et le serveur de streaming. Au moindre glitch réseau, généralement tout plante et il faut tout relancer, et dans le bon ordre.
Ça suppose aussi des choses assez exotiques, type du [multicast](https://fr.wikipedia.org/wiki/Multicast) comme on en trouve dans [la documentation officielle](https://trac.ffmpeg.org/wiki/StreamingGuide) de [ffmpeg](https://ffmpeg.org/), qui nécessitent en plus du matériel réseau compatible.
Idem côté client, chaque client va devoir maintenir un flux constant ouvert, ce qui engorge rapidement le serveur. Et parler de cache ou de miroir sur du flux relève bien entendu de l’exploit voire de l’impossibilité… 

L’autre problème, c’est qu’on trouve tout plein de solutions qui reposent sur un encodage des vidéos au niveau du serveur en face et non de là où est effectuée la captation. C’est par exemple le cas avec [le module RTMP pour Nginx](https://github.com/arut/nginx-rtmp-module), qui prend un unique flux en entrée (généralement du 1080p) et le transcode dans les autres résolutions (720p, 480p, 320p, audio only…).
Sauf que le transcodage, c’est **TRÈS** gourmand en ressources.
4 encodages « rapides » en parallèle occupent sans problème un i5-3450 à 100% et les mêmes en version standard un i7-8700K.
Côté serveur, un CPU capable d’encaisser ça commence avec la gamme [Xeon](https://www.intel.fr/content/www/fr/fr/products/processors/xeon.html) à plus de 250€ pièce, soit des machines en location à plus de 100€/mois. Inaccessible pour du grand public…

# HLS à la rescousse !

Du coup, on veut trouver un système de streaming capable d’utiliser les ressources du lieu de captation et évitant d’avoir un flux permanent ouvert à la fois entre la captation et le serveur mais aussi entre le serveur et les clients. Et ça tombe bien, on a un format magique qui permet tout ça : [HLS](https://fr.wikipedia.org/wiki/HTTP_Live_Streaming).

À la différence des fluxs précédents qui se basent directement sur TCP ou UDP, HLS repose sur le protocole [HTTP](https://fr.wikipedia.org/wiki/Hypertext_Transfer_Protocol).
Les vidéos diffusées sont en fait découpées en tas de petits morceaux [MPEG-TS](https://fr.wikipedia.org/wiki/MPEG_Transport_Stream) de durée plus ou moins fixe (généralement quelques secondes), et le tout est servi de manière classique par le serveur web.
La vidéo complète est reconstituée par les clients à partir d’un index [M3U](https://fr.wikipedia.org/wiki/M3U) tout aussi classique et simple, qui donne l’ordre des morceaux.

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:6
#EXT-X-MEDIA-SEQUENCE:2350
#EXTINF:6.000000,
1080p/1566166537.ts
#EXTINF:4.000000,
1080p/1566166543.ts
#EXTINF:6.000000,
1080p/1566166547.ts
```

En bonus, le système est auto-adaptatif. Les fragments de toutes les résolutions étant disponibles, un client peut passer tranquillement d’une résolution à l’autre.
Un autre index permet de déclarer les bandes passantes nécessaires pour chaque résolution, le client fera ses courses avec ce qu’il peut supporter.

```
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
360p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1400000,RESOLUTION=842x480
480p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2800000,RESOLUTION=1280x720
720p.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=5000000,RESOLUTION=1920x1080
1080p.m3u8
```

Aucune magie ni protocole compliqué pour la diffusion donc ! N’importe quel serveur web, y compris un [Scaleway à 6 centimes de l’heure](https://www.scaleway.com/en/virtual-instances/development/)…  

L’encodage peut aussi se faire simplement sur la machine locale.
On encode dans tous les formats souhaités, on envoie ça sur le serveur web par n’importe quel moyen à disposition (FTP, SSHFS, rsync, IPoAC…), et basta !

L’effet Kiss-Cool continue, puisque le tout étant uniquement du HTTP classique, il est parfaitement possible de mettre en place de la répartition de charge tout aussi classiquement, avec du [HAProxy](https://www.haproxy.org/) ou du [DNS tourniquet](https://fr.wikipedia.org/wiki/DNS_round-robin) ou des miroirs avec du Nginx en [proxy inverse](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/) sur une source primaire avec [un peu de cache](https://docs.nginx.com/nginx/admin-guide/content-cache/content-caching/) pour soulager tout le monde.

Et ça continue encore et encore, parce que MPEG-TS étant du [H.264](https://fr.wikipedia.org/wiki/H.264), ça a le bon goût d’être [supporté nativement](https://caniuse.com/#feat=mpeg4) par les navigateurs ! On trouve même [un lecteur clef-en-main](https://github.com/video-dev/hls.js/) à intégrer sur un site Internet, histoire de pouvoir se passer des gros fournisseurs centralisés privateurs habituels.

# OBS NDI

Il nous reste du coup un dernier problème à résoudre : dans le cas d’un streaming de jeu vidéo par exemple, on veut généralement réaliser l’encodage sur une machine différente que celle de jeu. L’encodage étant un processus très consommateur, il est en effet assez peu envisageable d’utiliser massivement un CPU déjà bien occupé et qu’on aurait plutôt envie de le voir s’occuper du rendu du jeu…

Généralement, l’outil utilisé par les diffuseurs est [OBS](https://obsproject.com/fr/). Problème, par défaut il ne propose que des options nécessitant un encodage de la captation pour l’envoyer vers des serveurs de stream conventionnels (Twitch, Youtube, Periscope…) ou vers un ffmpeg distant (flux, multicast, tout ça tout ça…).

Heureusement, grâce à [Palakis](https://twitter.com/LePalakis) il existe une extension [OBS-NDI](https://github.com/Palakis/obs-ndi) utilisant le protocole (propriétaire… 😭) [NDI](https://fr.newtek.com/ndi/). NDI a beau être propriétaire, son concepteur fournit [un kit de développement](https://fr.newtek.com/ndi/sdk/) y compris pour GNU/Linux. Ce protocole se base sur [Avahi/Zeroconf](https://fr.wikipedia.org/wiki/Avahi_(logiciel)) pour la détection des sources et enchaîne ensuite avec des connexions TCP standard. Ceci permet l’envoi direct (sans encodage) du flux capté vers tout système causant NDI. Et ça tombe bien, ffmpeg supporte NDI [depuis sa version 3.4](https://www.newtek.com/blog/ffmpeg-3-4-adds-ndi-io/).

Un avantage notable de NDI est de ne pas nécessiter un ffmpeg permanent à tourner en face. On lance OBS quand on veut, et c’est la machine en face qui s’y connectera quand elle souhaitera. On peut ainsi relancer le ffmpeg sans nécessiter d’intervention sur l’OBS, par exemple en cas de problème ou pour changer les paramètres d’encodage.

À noter que conséquence de l’usage de Avahi, NDI est [un protocole réseau passant difficilement les pare-feu](https://fr.wikipedia.org/wiki/Protocole_r%C3%A9seau_passant_difficilement_les_pare-feu). En effet, après le requétage Zeroconf, [un port réseau éphémère](https://support.newtek.com/hc/en-us/articles/218109497-NDI-Video-Data-Flow) est ouvert pour chaque nouveau client qui arrive. Le premier client passera par le port 49152, le second par le 49153, etc. Veillez donc à désactiver vos pare-feu si vous utilisez ce protocole ou au moins d’ouvrir quelques ports à partir de 49152.

# Mettons tout ça ensemble

J’ai fais le choix de Arch Linux pour monter une machine de stream, tout simplement parce que [les dépôts AUR](https://wiki.archlinux.fr/AUR_4.0.0) contiennent tout ce qu’il faut pour OBS, NDI & ffmpeg, contrairement à d’autres distributions où il sera nécessaire de beaucoup bidouiller pour tout faire fonctionner.

* [SDK NDI](https://aur.archlinux.org/packages/ndi-sdk/)
* [OBS NDI](https://aur.archlinux.org/packages/ndi-sdk/)
* [OBS](https://www.archlinux.org/packages/community/x86_64/obs-studio/)

Il ne manque qu’un ffmpeg construit pour NDI, mais on peut facilement le compiler à la main une fois le SDK NDI installé :

```
git clone https://git.ffmpeg.org/ffmpeg.git --branch n4.2 --depth=1
cd ./ffmpeg
./configure --enable-gpl --enable-nonfree --enable-libndi_newtek --enable-libx264 --cpu=native
make -j8
```

Les invocations ffmpeg relevants plus du chamanisme que d’autre chose, j’ai simplifié le boulot dans quelques scripts :

* [encode.rb](https://git.imirhil.fr/aeris/streaming/src/branch/master/encode.rb) : un script consommant en entrée un flux NDI et l’encodant dans toutes les résolutions souhaitées, actuellement HLS 1080p@30 + 720p@30 + 480p@30 + 320p@30 + audio only, FLV 1080p@30 pour Twitch et un stockage MPEG4 1080p@30 sur disque.
* [rsync.py](https://git.imirhil.fr/aeris/streaming/src/branch/master/rsync.py) : un script un peu plus malin qu’un rsync global de tous les flux HLS. Il priorise d’abord les fragments `.ts avant d’envoyer le `.m3u8`, de sorte à ne pas publier un index dont certains bouts ne sont pas
  encore publiés, et le tout avec un processus `rsync` par résolution plutôt que d’attendre que tout 1080p soit envoyé avant d’attaquer le 720p.

 Une diffusion se résume à lancer `./encode.rb` (les 4 encodages HLS), `./encode.rb live` (pour le stockage et Twitch) et `./rsync.py` (pour l’envoi sur le serveur).

La configuration du serveur nginx est disponible [ici](https://git.imirhil.fr/aeris/streaming/src/branch/master/nginx-upstream.conf), celle pour un éventuel miroir-cache [là](https://git.imirhil.fr/aeris/streaming/src/branch/master/nginx-upstream.conf) et l’index m3u8 global [ici](https://git.imirhil.fr/aeris/streaming/src/branch/master/index.m3u8).

Ces scripts sont basés en grosse partie sur des idées de [Benjamin Sonntag](https://mamot.fr/@vincib) qui utilise ce genre de méthode pour les solutions de streaming de [Octopuce](https://www.octopuce.fr/). Ils sont largement améliorables, en particulier pour sortir quelques paramètres un peu trop en dur à mon goût (l’adresse du flux NDI, l’adresse du serveur SSH…).

Je m’en sers régulièrement pour les diffusions de [mon chaton](https://mamot.fr/@nlavielle), la machine d’encodage était un simple PC portable [W251HUQ](http://clevo-europe.com/default_zone/fr/html/Prod_Notebook_EpureS4_More.php) de chez Clevo, équipé d’un i5-2520M. En bande passante, comptez minimum 20Mbps, en dessous vous ne tiendrez pas la charge. C’est aussi ce système qui a assuré la diffusion de [PSES 2018](https://passageenseine.fr/), sur un i7-8700K cette fois, et avec une carte d’acquisition [BlackMagic DeckLink Mini Recorder](https://www.blackmagicdesign.com/fr/products/decklink/techspecs/W-DLK-06) (très [GNU](https://aur.archlinux.org/packages/decklink/) & [ffmpeg](https://www.ffmpeg.org/ffmpeg-devices.html#decklink) compatible aussi).

Résumons donc. On a OBS qui s’occupe de la captation. Qui transmet tout ça via NDI vers un ffmpeg qui tourne sur une autre machine. ffmpeg en charge de l’encodage dans les formats souhaités. Un bon vieux [rsync](https://rsync.samba.org/) des familles pour envoyer les morceaux & index HLS vers un serveur web. Et enfin un nginx qui sert tout ça classiquement aux visiteurs.

 Et voilà ! 😊