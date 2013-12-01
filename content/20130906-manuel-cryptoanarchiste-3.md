Title: Manuel du parfait petit crypto-anarchiste (3/3)
Date: 2013-09-07
Category: crypto
Tags: otr, bitcoin, tor, darknet

On est reparti dans notre panorama des solutions de cryptographie.

# Sécurité de la messagerie instantanée (OTR)

On vient de voir comment sécuriser ses courriels.
Mais l'échange de courriel est relativement asynchrone, c'est-à-dire qu'on ne s'attend pas à recevoir une réponse dans la minute qui suit, à l'inverse de la messagerie instantanée.
GPG n'est pas efficace pour du vrai dialogue intéractif.

Si vous voulez sécuriser vos discussions via messagerie instantanée, déjà comme d'habitude, fuyez les messageries type Skype, Windows Live ou Facebook.
La confiance en ces systèmes est nulle voire négative passé un [temps de Planck](https://fr.wikipedia.org/wiki/Temps_de_Planck).<br/>
Vous pouvez à la place utiliser [IRC](https://fr.wikipedia.org/wiki/Internet_Relay_Chat) ou [XMPP](https://fr.wikipedia.org/wiki/Extensible_Messaging_and_Presence_Protocol) (plus connu sous le nom Jabber), qui sont des messageries ouvertes et libres.

Encore une fois, tout ça circule bien en clair dans les tuyaux si vous n'utilisez pas SSL pour chiffrer les flux.
Mais une fois connecté, même en SSL, le propriétaire du serveur peut avoir accès à toutes vos communications, y compris privées.
Et vous ne pouvez pas non plus avoir confiance en les gens qui vont cotoyer le même serveur que vous.
En bon petit crypto-anarchiste, [OTR](https://fr.wikipedia.org/wiki/Off-the-Record_Messaging) va venir à votre secours.

Pour simplifier, OTR repose sur le même principe que GPG.
Chaque utilisateur est identifié par une clef. La confiance en votre correspondant s'effectue par trois moyens possibles :

  * la vérification directe de sa clef, via un moyen de confiance et sécurisé autre que la messagerie instantanée (par échange de courriels GPG par exemple)
  * le secret partagé, qui n'est ni plus ni moins qu'un mot de passe échangé lui aussi par un autre moyen fiable et sécurisé
  * la question/réponse, où vous posez une question dont seul votre correspondant peut connaître la réponse (et vous aussi bien entendu :D)

Lors de la première discussion avec votre correspondant, votre logiciel de messagerie vous demandera de confirmer l'identité de la personne en face. Et tout le reste de votre communication sera totalement chiffrée et illisible, même par le propriétaire du serveur.

La beauté de la chose avec OTR, c'est qu'il permet la [confidentialité persistante](https://fr.wikipedia.org/wiki/Confidentialité_persistante) ou *perfect forward secrecy* : même si votre clef privée venait à être compromise dans le futur, on ne pourra jamais accéder au contenu de votre conversation.<br/>
Cette caractéristique très intéressante est obtenue en chiffrant la communication non pas directement avec votre clef, mais avec une autre clef qui est générée à partir de cette dernière.
Cette clef intermédiaire est générée au début d'une session, ne peut pas être recalculée à partir de la clef principale, et est détruite à la fin de la session, enterrant à jamais la possibilité de déchiffrer la conversation plus tard.<br/>
La PFS n'est bien sûr plus possible si vous stockez un historique de vos conversations sur votre machine, où OTR n'aurait plus aucun effet.
Si vous êtes capables de lire vos messages *a posteriori*, alors un attaquant en sera capable aussi en compromettant tout votre nécessaire pour y arriver.

OTR est disponible sous forme d'extension pour la plupart des logiciels de messagerie instantanée ([Pidgin](http://www.pidgin.im/), [HexChat](http://hexchat.github.io/)…).
Il a par contre été supprimé de [Kopete](http://kopete.kde.org/) :(, et fait toujours l'objet d'<strike>un troll</strike> [une discussion](http://community.kde.org/KTp/RepeatedDiscussions/OTR).

Si on veut une conversation sécurisée et de confiance sur le pouce, on peut aussi installer et utiliser [CryptoCat](https://crypto.cat/), une extension Firefox qui utilise OTR.

# Sécurité du navigateur web (Firefox)

Avec tout ce qu'on a déjà vu, on arrive maintenant à avoir une bonne sécurité et une bonne confiance lors de nos communications avec une personne ou un serveur.
Il nous manque juste une chose, la confiance et la sécurité en le contenu, en particulier lors de la navigation sur le web.

Le web est devenu une véritable déchèterie mondiale de mauvaises pratiques en tous genres.
Publicités, cookies, tracking, services tiers… Quand vous visitez un site « normal », vous laissez des traces chez des dizaines d'entités différentes.
<center>
![WAT](/static/images/20130901/wat.png)<br/>
Ceci est le site de *Wat.tv*/*TF1*/*Facebook*/*Google*/*régie pub Y* ? (biffer les mentions inutiles)
</center>

Outre que votre vie privée peut se retrouver exposée aux quatres vents, c'est aussi un danger pour votre sécurité.
Sur un site tout ce qu'il y a de plus franco-français, on retrouve pourtant des entreprises américaines (Google, Facebook…).
Donc nous n'y sommes pas à l'abris de la NSA, qui pourraient une fois de plus <strike>demander</strike> imposer à ces sociétés d'inclure du contenu pour vous traquer. Voire carrément [y injecter des malwares](http://www.01net.com/editorial/600967/les-hackers-du-fbi-infiltrent-tor-pour-pieger-un-reseau-de-pedopornographie/) pour surveiller tout ça.

En prime, la minitélisation massive du web a conduit à devoir trouver des parades pour être capable d'absorber des milliards de visites par jour.
On trouve ainsi de plus en plus de [CDN](https://fr.wikipedia.org/wiki/Content_delivery_network) comme [CloudFlare](https://fr.cloudflare.com/), [Akamai](http://www.akamai.fr/) ou [CloudFront](https://aws.amazon.com/fr/cloudfront/), qui permettent de servir de point de distribution au contenu totalement centralisé, sans pour autant avoir toutes les requètes qui arrivent sur le même serveur.<br/>
Les soucis engendrés par ces caches et autres CDN sont multiples.
Déjà, ils sont présents sur beaucoup de sites, et peuvent donc s'amuser à recouper les visites pour savoir qui vient d'où et ira où. Difficile de parler de confidentialité dans ce cas là.<br/>
Ensuite, ils sont peu ou pas compatibles avec certaines technologies, comme SSL par exemple.
À chaque visite, on peut tomber sur une machine différente, qui va nous annoncer un certificat SSL différent. Exit donc la confiance…

Pour finir, agence de pub et autre système de suivi des visiteurs pullulent de partout, attendant la moindre parcelle de données de votre part pour lancer des calculs géants sur votre personnalité pour cibler au mieux les réclames publicitaires à vous afficher.
Ou encore pour tout revendre au plus offrant qui en fera de même.

Bref, **un gros bordel**…<br/>
Pour se protéger, on a à notre disposition pas mal de possibilités de bloquer tout ça avec nos navigateurs web.

On peut commencer par activer l'option [Do Not Track](https://fr.wikipedia.org/wiki/Do_Not_Track).
Même si elle est purement déclarative et que je doute que les agences de pub et autres traceurs en tiennent vraiment compte, l'option est sensée indiquer qu'on ne veut pas être suivi et donc désactiver les systèmes de calculs d'en face.
Pas convaincu par l'efficacité étant donné qu'il n'y a aucune pénalité (ni même moyen de contrôle d'ailleurs) si en face quelqu'un ne joue pas le jeu.
Mais comme ça ne coûte pas grand chose sinon 6 octets sur le réseau à chaque requête, autant y aller.

Étape primordiale, [AdBlock Edge](https://addons.mozilla.org/fr/firefox/addon/adblock-edge/), pour bloquer toutes les publicités qui consomment inutilement de la bande passante et du temps de cerveau disponible, en plus de raffoler de vos données personnelles.
À chaque encart publicitaire bloqué, Dieu sauve un châton.
En prime, [le contenu intéressant devient vraiment plus visible](http://www.nikopik.com/2013/07/google-est-en-train-de-faire-disparaitre-les-vrais-resultats-de-recherche.html) et la navigation bien plus agréable.

Ensuite, installez [HTTPS Everywhere](https://www.eff.org/https-everywhere).
Cette extension active SSL par défaut sur la plupart des sites connus, au lieu de tout balancer en clair sur le réseau.

Extension suivante, [No Script](http://noscript.net/). Cette extension bloque par défaut tout le contenu dynamique des sites visités.
On est donc à l'abris de pas mal de saloperies qui pourraient traîner.<br/>
C'est là aussi qu'on se rend le plus compte de la saleté du web.
Par exemple avec NoScript activé, [cette page](http://instagram.com/p/dxChd0kWnz/#) apparaît juste totalement blanche, alors qu'il n'y a aucune raison qu'on ne puisse pas arriver à la même chose avec du HTML tout ce qu'il y a de plus statique, sans le moindre JavaScript.
Ou en tout cas par pitié, mettez en place un mode dégradé pour ceux qui n'activent pas les scripts…

On continue avec [Request Policy](https://www.requestpolicy.com/), qui bloquera par défaut tout contenu qui ne vient pas directement du site visité.
Fini de charger des trucs Facebook sur quasiment chacune de vos pages, ou des traceurs type Xiti.
Vous contrôlez qui peut afficher des choses sur vos pages et vous évitez d'atterrir sur du contenu fourni par des choses dont vous n'avez pas confiance ni même connaissance.

Et on finit avec [Disconnect](https://disconnect.me/), un peu dans la même politique que Request Policy, avec du blocage de tout contenu dangereux pour la sécurité ou la confidentialité, comme la publicité, les réseaux sociaux malheureusement présents partout, ou les traceurs.

Je dois quand même vous avouez qu'une fois tout ça installé et avec tout bloqué par défaut, le web se prend quand même une sacrée claque et que plus grand chose n'est accessible simplement.
On prend aussi une bien meilleure conscience du problème du web, et on est un peu catastrophé de voir autant de choses essayer de récupérer des données sur vous.<br/>
Passée une semaine d'utilisation et quelques règles d'acceptation, le web redevient consultable, même si certains sites restent particulièrement inutilisables avec tout ça installé (mais dans ce cas, c'est direction la poubelle et un bon gros boycott).

*Pensez aussi à modifier vos habitudes*.<br/>
Par exemple le bon gros méchant Google (qui contrôle plus ou moins tout ce web moisi et est présent quasiment partout) raffole de vos données, possède en prime plusieurs régies publicitaires et donc est très enclin à vous traquer dans votre navigation.
Préférez-lui [DuckDuckGo](https://duckduckgo.com/) qui respecte votre vie privée (même si la pertinence des résultats de recherche n'est pas encore à la hauteur de celle de Google).

# Divers

Je ne savais pas trop où classer les points suivants, mais ils peuvent être importants pour un bon crypto-anarchiste.
Donc petit chapitre « misc ».

## Tor

Dans tout ce qui s'est dit auparavant, on a cherché à protéger aussi bien les données d'une communication que la communication en elle-même.
Mais il reste toujours quelque chose qu'on a pas encore protégé, c'est l'existence même de cette communication, et surtout son émetteur et son destinataire (au sens machine du terme).
En effet, vous avez beau avoir installé toutes les choses précédentes, un individu malveillant a toujours moyen de savoir que la machine Tartampion a ouvert une communication avec l'autre machine Duchmol (la version technique étant que *109.190.87.53* a communiqué avec *176.34.131.233*).<br/>
À force de recoupement, par exemple si des non crypto-anarchistes avaient la mauvaise idée d'accéder à ces machines en clair, les individus peu scrupuleux pourraient remonter à la source, et découvrir que *109.190.87.53* est un abonné à OVH (moi en l'occurence) et que *176.34.131.233* a la bonne idée d'héberger *duckduckgo.com*.<br/>
Malgré que cette personne soit dans l'incapacité la plus totale de savoir ce qui a bien pu être dit, elle peut encore parvenir à recouper les sources d'information.
Là avec DuckDuckGo, c'est pas forcément méchant de le savoir. Ça le serait presque plus avec [*194.71.107.27*](http://thepiratebay.sx/torrent/8552370/Debian_7.0_CD1_64-bit) (Coucou Hadopi ! Et au passage ce cas montre qu'on pourrait se méprendre sur mes intentions si on s'arrête juste aux machines que je fréquente, alors que je télécharge du contenu parfaitement légal et libre via BitTorrent) et encore plus avec [*141.101.112.19*](http://wikileaks.org/) ou [*5.150.255.100*](http://telecomix.org/).

C'est pour éviter l'identification des machines en présence que [Tor](https://www.torproject.org/) est apparu.
En version courte, Tor est un gros réseau de machines, qui vont faire en sorte de masquer la connexion directe entre vous et votre correspondant, via tout un jeu de relais et de sauts.
<center>
![Tor](/static/images/20130901/tor.png)<br/>
(Crédits image : [Electronic Frontier Foundation](https://ssd.eff.org/tech/tor))
</center>

Quelqu'un qui serait au cœur du réseau Tor serait incapable de trouver l'origine d'une connexion, chaque paquet étant chiffré il n'y a aucun moyen simple de relier un paquet qui sort d'une machine à un paquet qui y entre, et donc de retrouver la machine d'origine d'un paquet.<br/>
Et quelqu'un qui serait en périphérie du réseau verrait une machine qui n'est pas le vrai initiateur de la communication.

Tor propose aussi la notion de services cachés, ou *.onion*, par exemple *[https://3g2upl4pq6kufc4m.onion](https://3g2upl4pq6kufc4m.onion)* pour DuckDuckGo.
Le principe est le même que pour le masquage de l'auteur, mais pour le destinataire.
Vous n'avez aucun moyen de savoir qui fournit réellement le service au bout du tuyau juste à partir de l'adresse.

Tor peut être utilisé en l'installant sur sa machine et en configurant le proxy de son navigateur.
Pour encore plus de sécurité, il est conseillé de ne pas utiliser le même navigateur pour la vie de tous les jours.
C'est pourquoi Tor est aussi disponible prêt-à-l'emploi, sans configuration nécessaire, via le [Tor Browser Bundle](https://www.torproject.org/projects/torbrowser.html.en).
Pour les plus parano, il existe aussi une distribution sur Live-CD, pour utiliser Tor en n'ayant même pas à faire confiance à la machine à disposition, [Tails](https://tails.boum.org/).

## BitCoin / NameCoin / BitMessage

Il n'aurait pas été marrant d'être totalement anonyme et invisible sur le réseau mais de l'être dès qu'on parle argent.
C'est pour ça qu'est apparu le concept de crypto-monnaie, et en particulier [BitCoin](http://bitcoin.org/).
BitCoin possède des propriétés assez innovantes par rapport à la monnaie classique qu'on connaît.

Déjà, toutes les transactions financières qui y ont lieu sont totalement publiques.
Vous téléchargez toutes les transactions depuis le début du monde si vous installez le client BitCoin officiel (12Go de données quand même !), mais vous pouvez aussi les explorer par le web, via [BlockChain](https://blockchain.info/) par exemple.

Ensuite, il n'y a pas de notion de banque et tout est décentralisé.
Comme toutes les transactions sont publiques, c'est l'ensemble du réseau qui doit donner son accord pour dire si une nouvelle transaction est valide ou pas (vous devez bien être propriétaire des fonds que vous dépensez et vous ne devez pas déjà les avoir dépensez).

Enfin, et sûrement le plus étrange… vous pouvez fabriquer vous-même votre monnaie !<br/>
Pour fonctionner, le réseau BitCoin nécessite que les participants mettent à disposition leur puissance de calcul.
Pour les remercier de laisser tourner leurs machines, le réseau leurs accorde des BitCoin en échange.
N'espérez cependant pas faire fortune dès demain, il vous faudra 1200 ans pour toucher les 25฿ de récompense (soit ~2500€ aujourd'hui) avec le meilleur des processeurs actuels, et [le matériel](https://products.butterflylabs.com/homepage-new-products/600-gh-bitcoin-mining-card.html) qui vous permettrait de les toucher en 7 jours coûte rien de moins que 5000€.
Et le tout risque au final de vous coûter plus cher en électricité qu'autre chose à court terme, le pari étant une explosion du prix du BitCoin dans le futur (~100€/฿ aujourd'hui).

Chaque utilisateur de BitCoin peut générer autant d'adresses qu'il souhaite (une des miennes est [*1aerisnnLWPchhDSXpxWGYWwLiSFUVFnd*](https://blockchain.info/address/1aerisnnLWPchhDSXpxWGYWwLiSFUVFnd) par exemple).
Et il est impossible de remonter au possesseur d'une adresse, assurant ainsi l'anonymat des transactions malgré qu'elles soient toutes publiques.

Le système cryptographique sur lequel repose BitCoin a trouvé beaucoup d'autres utilisations.
Déjà dans d'autres crypto-monnaies ([Litecoin](https://litecoin.org/fr), [PPCoin](http://www.ppcoin.org/), [PrimeCoin](http://ppcoin.org/primecoin) ou encore [NovaCoin](http://novacoin.org/)).<br/>
Mais aussi dans un système DNS alternatif, [NameCoin](http://dot-bit.org/).
Ce dernier est très intéressant car il remet en question la centralisation du système DNS qui est dangereux à l'heure actuelle car très centralisé (malgré ce qu'en disent certains) et très états-unien (9 organisations sur les 11 qui gèrent DNS sont aux USA, avec tout ce que cela implique vis-à-vis de la NSA et autre).<br/>
Enfin, il a aussi donné naissance à un système de messagerie totalement anonyme et sécurisé, [BitMessage](https://bitmessage.org/).
On y retrouve les mêmes concepts que BitCoin, avec tous les messages complètement publics (mais chiffrés), autant d'adresses qu'on souhaite et l'anonymat garanti.
Attention quand même à bien sauvegarder vos messages reçus et envoyés, tout y est effacé au bout de deux jours (par soucis de place vu que tout le monde conserve une copie de tout) !

## Darknet

Beaucoup de personnes confondent [Internet](https://fr.wikipedia.org/wiki/Internet) et [Web](https://fr.wikipedia.org/wiki/World_Wide_Web).
Ce que vous fréquentez à longueur de journée se rapproche plus du Web que de l'Internet au vrai sens du terme.

Il existe une multitude de réseaux et de protocoles, et la plupart est inconnue du grand public.
Par exemple, en plus du traditionnel Web qu'on connait tous (avec les adresses en *http*), il existe le réseau [Gopher](https://fr.wikipedia.org/wiki/Gopher), qui fonctionne plus ou moins sur le même principe de [pages liées les unes aux autres](http://gopherproxy.meulie.net/gopher.floodgap.com/), avec [ses moteurs de recherche](http://gopherproxy.meulie.net/gopher.floodgap.com/7/v2/vishnu), etc.
Mais ce réseau souffre des mêmes problèmes que le web classique, à savoir pas d'anonymat, de confidentialité ni de sécurité.

Il existe aussi des réseaux beaucoup plus ésotériques, qu'on appelle les darknets.
Ces réseaux sont véritablement cachés et misent tout sur la sécurité et l'anonymat.
On peut citer [I2P](http://www.i2p2.de/) ou [FreeNet](https://freenetproject.org/).<br/>
Tout y est fait pour anonymiser les connexions et chiffrer toutes les communications.
Le fonctionnement en mode pair-à-pair garantit aussi une absence de censure et une robustesse à la fermeture de nœuds.<br/>
On y retrouve tout le nécessaire qu'on a à disposition d'habitude, avec des sites, des blogs, des forums, de la messagerie instantanée, la possibilité d'héberger ses propres pages (en garantissant son anonymat bien sûr, voire même la liste des personnes qui peuvent y avoir accès !)…
Autant vous dire que c'est le paradis pour les crypto-anarchistes, mais malheureusement aussi pour pas mal de monde peu recommandable, il vous faudra donc parfois avoir le cœur bien accroché si vous partez à l'aventure dans les méandres de ces darknets (en particulier sur FreeNet).

# Conclusion

Et voilà, c'est la fin de notre tour du monde de la crypto-anarchie.
Pour résumer un peu tout ce qui a été dit, trois choses sont à protéger le plus possible

  * la confidentialité, afin qu'on ne puisse pas dire qui discute avec qui
  * la confiance, afin d'être sûr de dialoguer avec la bonne personne
  * la sécurité, afin que seul le destinataire puisse accéder au contenu de la discussion

Se protéger correctement ne demande pas d'effort si surhumain et est à la portée de pas mal de monde

  * commencez par protéger vos machines (mots de passe robustes, chiffrement des disques, mise-à-jour régulière)
  * protégez ensuite votre navigation web avec les extensions adéquates et faites attention à SSL
  * mettez en place GPG et OTR pour vos courriels et vos messageries instantanées

Vous aurez déjà un niveau de sécurité plus que correct pour un usage courant d'Internet et si vous n'avez pas de données si sensibles que ça.

Si après vous voulez aller plus loin, que vous avez vraiment des choses sensibles à défendre et que vous sentez que vous en avez les compétences, essayez Tor ou BitCoin et fréquentez les darknet !

*[Première partie](|filename|/20130901-manuel-cryptoanarchiste-1.md)*<br/>
*[Seconde partie](|filename|/20130902-manuel-cryptoanarchiste-2.md)*
