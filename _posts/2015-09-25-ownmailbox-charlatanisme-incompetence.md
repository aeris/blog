---
title: Own-Mailbox, charlatanisme ou incompétence ?
---

[Own-Mailbox](https://www.own-mailbox.com) est une solution se présentant comme « La boîte mail 100% confidentielle ».
Surf sur la vague de la vie privée, quitte à faire du [bullshit](http://www.zdnet.com/article/charlatans-the-new-wave-of-privacy-profiteers/) ou vraie solution de protection, une petite analyse rapide de ce nouveau projet.

Je précise que ce produit n’étant pas encore sorti, je n’ai pas pu tester en réel ce qui va suivre et je ne me base que sur les données disponibles sur le site du projet, les commentaires d’une [dépêche Linuxfr](https://linuxfr.org/news/own-mailbox-la-boite-mail-confidentielle-qui-vous-appartient-vraiment) et d’un [article sur Framablog](http://framablog.org/2015/09/23/mon-courrier-securise-cest-dans-la-boite/).
Si quelqu’un du projet me donne accès à une vraie Own-Mailbox, je me ferai une joie de faire des tests et de revoir ma position.

# Matériel & logiciel

Sur ce point, rien à redire, Own-Mailbox semble bien basé sur du logiciel et du matériel libre, qui est le seul type de logiciel compatible avec de la sécurité ou de la protection de la vie privée.

# Réseau

Own-Mailbox se présente comme une solution « plug-and-use » : vous juste branchez la machine, et ça juste tombe en marche tout seul. Sauf que le réseau, ce n’est généralement pas aussi simple que ça…

Un équipement derrière une box ADSL n’est pas accessible directement depuis Internet, puisqu’il y a la box devant.
On doit donc procéder à ce qu’on appelle une « ouverture de port » : on signale à notre box ADSL que si elle voit passer du trafic sur son port X, elle doit le transférer à la machine Y.
Problème, cette procédure est 100% dépendante de votre fournisseur d’accès et du modèle de votre box ADSL.
Own-Mailbox annonce vouloir supporter l’ensemble du parc existant, ce qui me semble difficile à envisager et conduira de manière quasi-certaine à une période de pré-chauffage du projet, le temps que les auteurs traitent les nouveaux cas qui vont se présenter à eux au fur et à mesure de l’arrivée de nouveaux utilisateurs et donc configurations.

Le mail étant aussi une véritable plaie pour le réseau à cause du très gros volume de spam, la plupart des plus gros FAI (Orange, Free, Numéricable…) bloque le trafic mail sortant, afin de bloquer tous les spammeurs de leur réseau (en fait toutes les machines zombies de leur client…).
Certains FAI (Free) autorisent l’utilisateur à supprimer ce blocage, d’autres non (Numéricable) ou au prix d’un passage sur des lignes professionnelles hors de prix (Orange).  
Problème pour Own-Mailbox, un utilisateur chez un de ces fournisseurs ne pourra jamais héberger un serveur de mail chez lui, puisque tout est bloqué indépendamment de sa volonté.

L’équipe du projet propose alors un tunnel de port : c’est eux qui vont gérer le trafic mail de votre petite boîte, et vous le transmettra via un canal non bloqué.
Niveau sécurité et vie privée, cette solution pose sérieusement question…
Dans ce mode, Own-Mailbox aura en effet accès à l’intégralité de votre trafic mail, qu’il soit chiffré ou non…
Sachant que la majeure partie des utilisateurs de Own-Mailbox risque de se retrouver dans ce cas, les personnes étant chez les trop rares FAI ne posant pas problème (OVH, FAI associatifs…) n’ayant généralement pas besoin de Own-Mailbox pour se monter un serveur de mail sécurisé à la maison, le côté « 100% confidentiel » prend une sacrée dose de plomb dans l’aile…  

De plus, j’imagine mal Own-Mailbox dédier une adresse IP par client juste pour y héberger le port 25 (SMTP n’ayant aucun moyen de signaler l’usage d’un port alternatif, c’est forcément le port 25 pour chacun), surtout en période de pénurie
IPv4, la solution technique retenue risque fort d’être un serveur mail unique hébergé chez Own-Mailbox qui relaie ensuite le mail chez le bon client en fonction de l’adresse du destinataire.
Niveau centralisation du net, on se pose donc là et Own-Mailbox n’apporte plus un vrai auto-hébergement ni une décentralisation du net.

# Nom de domaine

On retrouve le même genre de soucis avec le nom de domaine.
Own-Mailbox ne propose que d’utiliser un de leur sous-domaine en *.obm.me*.
C’est donc eux, et uniquement eux qui vont pouvoir contrôler le [MX](https://fr.wikipedia.org/wiki/Enregistrement_Mail_eXchanger) associé à votre boîte mail, ie. la machine qui va réellement recevoir le courier en premier.
Si Own-Mailbox en a envie, et même en mode vraiment auto-hébergé (cf. problème précédent), ils peuvent donc rerouter l’intégralité de votre trafic mail vers où ils le veulent…
Et tout le monde sait qu’en terme de vie privée et de sécurité, les tiers de confiance, ça a **toujours** finit par déconner…  
Own-Mailbox a annoncé qu’il sera sans doute possible « dans un mode expert » de gérer son propre nom de domaine, mais
 comme pour le tunnel de port, quelqu’un ayant les compétences pour utiliser ce mode le place de facto parmi les personnes qui ne sont *plus* le marché de Own-Mailbox…

La position de Own-Mailbox, en plus de créer 2 [vendors-lockin](https://fr.wikipedia.org/wiki/Enfermement_propriétaire) assez sévères, est d’autant plus surprenant qu’ils militent pour exactement l’inverse via [leur FAQ sur JavaScript](https://www.own-mailbox.com/index-fr.php#javascript) :

	Le code JavaScript peut-être changé à tout moment par l'entreprise proposant le service.
	Donc sauf si vous vérifiez le code à chaque fois que vous accédez à vos e-mails (ce qui est impossible), vous laissez tout le pouvoir à cette entreprise de casser votre chiffrement à tout moment et pour toujours, sans même que vous ne le sachiez, puisque vous ne vérifiez pas.

# GPG

On arrive sur la partie vraiment croustillante.

Own-Mailbox annonce que la gestion des clefs GPG va être automatique, directement prise en charge par le boîtier.
Or, tout le monde sait que dans la notion de clef privée, il y a **privée**, et donc qu’une telle clef ne doit se trouver qu’à un seul et unique endroit : sur la machine de l’utilisateur.
Si le boîtier est volé ou égaré, vos clefs sont dans la nature.
Premier point noir donc.

Couplé aux problèmes précédents, ça peut donner des choses assez drôle.
En effet, pour pouvoir gérer l’ouverture ou le tunnel de port, Own-Mailbox s’autorise à pouvoir se connecter à votre boîtier pour le configurer correctement ou agir sur votre modem.
Vos clefs privées étant sur ce même boîtier, Own-Mailbox y a donc potentiellement accès… Gloups…  
On peut imaginer encore pire.
J’ai précisé au dessus que Own-Mailbox pouvait rerouter l’ensemble de votre trafic mail, y compris celui chiffré par GPG.
Ils ont maintenant aussi accès à la clef privée permettant de déchiffrer les données…
Confidentialité vous aviez-dit ?  

Own-Mailbox intègre aussi GPG à leur webmail.
Déjà, ceci confirme bien que la clef privée est positionnée sur le boîtier, puisque le traitement ne peut alors être fait que côté serveur et pas sur la machine du client.
Ensuite, les webmails ne supportent qu’un seul des modes de fonctionnement de GPG, PGP/inline (l’autre étant PGP/MIME).
Or PGP/inline est le mode de fonctionnement qui protège le moins un message.
Il ne chiffre rien d’autre que le corps « texte » du message. Vous avez des pièces-jointes ? Pas chiffré. Un corps « HTML » ? Pas mieux.

L’utilisation du mode PGP/inline est confirmé par le fait que vous pourrez lire vos couriers sur smartphone.
PGP/MIME n’est actuellement géré par aucun client mail Androïd (par exemple [K9-mail](https://code.google.com/p/k9mail/issues/detail?id=5864) ou iOS et seul PGP/inline y est supporté.
PGP/inline pose aussi d’autres problèmes, comme de polluer tous les lecteurs mails qui ne supportent pas du tout GPG.
Pire, PGP/inline souffre de beaucoup de [défaut de conception](https://dkg.fifthhorseman.net/notes/inline-pgp-harmful/) qui le rendent en réalité très dangereux pour une utilisation réellement critique (on peut usurper une signature, etc).  
Si un utilisateur souhaite utiliser PGP/MIME, il devra utiliser un vrai client mail (Thunderbird+Enigmail ou Kontact par exemple), et réussir à extraire la clef privée du boîtier pour pouvoir s’en servir avec son client lourd.

Un autre problème, qui a été soulevé par plus ou moins tous ceux qui gravitent autour de la sécurité et de la vie privée en ce moment : le mail est un protocole non fiable, qui ne **peut** pas être confidentiel.
En effet, même avec GPG, un mail qui circule sur le réseau contient énormément de méta-données. Émetteur, destinataire, sujet du mail, pièces-jointes si on utilise PGP/inline, ces morceaux-là ne sont pas chiffrés par GPG et circulent donc en clair.
Ce sont ces données dont raffole aujourd’hui la NSA et toutes les agences gouvernementales, y compris les fameuses boîtes noires françaises.
Avec ou sans GPG, on finit donc à poil sur le réseau, le contenu réel d’un mail n’intéressant pas du tout les espions.
Ce n’est pas pour rien que le mail et GPG ont été rayés de la carte des ateliers café-vie-privée, vous avez beaucoup trop de manières de mal l’utiliser et de vous retrouver à poil sur Internet sans le savoir.

Bref, la gestion de GPG par Own-Mailbox semble juste catastrophique et ne peut de toute façon pas apporter la confidentialité annoncée, d’autant plus avec le mode inline de GPG…

# Technologie « PLM »

Dans le cas où notre correspondant ne supporte pas GPG, Own-Mailbox a défini un mode de secours : le PLM ou « Private Link Message ».
Plutôt que d’envoyer un message avec le contenu en clair, Own-Mailbox va envoyer un mail avec un lien qui permettra d’accéder au contenu réel qui lui restera bien à l’abri sur votre boîtier.

Vu les remarques du point précédent, ce mode n’apporte **strictement** aucune sécurité ni confidentialité supplémentaire.
En effet, le mail d’alerte circulera « en clair » dans le réseau et les agences de renseignement n’auront aucun mal à récolter le fameux lien « privé » du mail pour accéder au contenu réel.

Même en supposant que le mail circule via le protocole [STARTTLS](https://fr.wikipedia.org/wiki/StartTLS) qui chiffre le transport d’un mail, ce protocole est très facilement contournable par une agence NSA-like puisque son signalement dans le réseau est non authentifié et qu’il suffit simplement de supprimer les paquets réseaux contenant « STARTTLS » pour que le boîtier pense que son correspondant ne supporte pas STARTTLS et balance son mail en clair complet.

# TLS

Own-Mailbox envisage d’utiliser [Let’s Encrypt](https://letsencrypt.org/) pour la génération des certificats pour HTTPS et SMTP/STARTTLS.
C’est une très bonne idée, Let’s Encrypt allant être une des trop rares autorités de certification non commerciales ou étatique (la seconde étant [CAcert](https://www.cacert.org/)) et la seule intégrée par défaut aux navigateurs.

TLS n’est cependant pas la panacée, et d’autant plus dans un contexte d’auto-hébergement.
En effet, TLS laisse aussi passer des méta-données via [SNI](https://fr.wikipedia.org/wiki/Server_Name_Indication) qui permettent par simple observation du réseau de savoir ce que vous visitez.
Il n’y a même à nouveau rien à observer dans le cas de l’auto-hébergement, les IP source ou destination portant déjà par elles-mêmes l’identité des personnes derrière.

Dans le cas de SMTP, TLS est aussi une protection très faible pour des raisons techniques, STARTTLS étant très facilement annulable par quelqu’un qui serait situé entre les deux extrémités du réseau (une sonde NSA par exemple) et dont on ne peut pas durcir la sécurité sous peine de problèmes avec certains serveurs mails encore (trop) présents dans le réseau.

TLS ne permet donc que de protéger sa sécurité, et en aucun cas sa confidentialité.

# Gestion courante d’une machine

Un des gros soucis de l’auto-hébergement actuel reste la gestion courante de la machine.
Appliquer les patchs de sécurité, vérifier qu’on n’est pas devenu un zombi du réseau participant à l’envoi de spam ou au bruteforce de serveur, ça demande du temps et des compétences techniques, que beaucoup du cœur de marché visé par Own-Mailbox ne possédera pas.

Cette administration n’est pas facilement automatisable, puisqu’elle dépend bien souvent de votre configuration de réseau, par exemple pour n’autoriser que vos machines locales à se connecter au service SSH ou pour bien régler fail2ban pour éviter qu’il ne blackliste par erreur votre machine.
Et les différents paramètres échappent totalement à quelqu’un qui souhaite du « plug-and-use » parce qu’il n’a justement pas les compétences pour faire par lui-même…
On risque donc fort d’avoir affaire à la vente de boîtier qui créeront dans un avenir proche un botnet géant au service du mal parce qu’ils auront échappé au contrôle de leur propriétaire…

Dans les discussions que j’ai pu avoir avec les auteurs du projet, il semble qu’ils souhaitent s’orienter vers faire cette gestion par eux-même, en mode automatique.
Même si cette gestion était réellement automatisable et en supposant que l’utilisateur soit en mesure de renseigner  les paramètres de configuration nécessaires, cela signifie une fois de plus que le véritable maître du boîtier est plus Own-Mailbox que vous même, avec tout ce que cela implique…

# Incompétences des développeurs Own-Mailbox

Au cours des différents échanges que j’ai pu avoir avec les auteurs de Own-Mailbox, une chose qui frappe assez rapidement quelqu’un du domaine est leur apparente incompétence technique.
Un florilège de ce que j’ai pu relever.

**« Tout d’abord en France la majorité des FAI ne bloque pas le port 25, encore moins le port entrant (Free, Numéricable: aucun problème) »**  
C’est totalement faux, Free étant même le parfait contre-exemple puisque [tout est bloqué en sortie par défaut](http://www.freenews.fr/freenews-edition-nationale-299/assistance-13/lutte-contre-le-spam-blocage-du-smtp-sortant-des-jeudi-4317), même si effectivement ce blocage est débrayable.
C’est aussi le cas [chez Orange](http://communaute.orange.fr/t5/mon-mail-Orange/Utilisation-du-port-25-pour-acceder-à-un-autre-serveur-smtp-avec/td-p/148447) qui lui ne permet pas le déblocage, tout comme [SFR](http://assistance.sfr.fr/runtime/internet-et-box/securite/filtrage-port-smtp-25.html).
Les seuls FAI ne bloquant pas SMTP en France sont à ma connaissance OVH et tous les FAI associatifs de la galaxie FDN.
C’est encore pire pour nos amis belge, [quasiment aucun FAI ne laisse passer SMTP](http://www.behostings.be/client/knowledgebase/6/Configuration-Serveur-mail-sortant-SMTP.html).

**« La plage d’adresses du LAN n’ont strictement aucun impact sur la conf de la Own-Mailbox »**  
Ceci est tout simplement impossible si on veut faire les choses correctement avec une machine directement accessible sur Internet.
La configuration du serveur SSH ou de fail2ban doit nécessairement contenir des données propres au réseau sous peine d’avoir des trous dans la raquette.

**« En ce qui concerne les méta-données, l’auto-hebergement est une prérogative pour pouvoir commencer à penser à protéger les méta-données »**  
C’est même totalement le contraire.
Si tout le monde est chez le même prestataire pour faire du mail, le trafic mail entre chaque utilisateur passe par le réseau local du prestataire, donc sous les radars des sondes NSA & cie déployées elles sur le réseau Internet public.
Au contraire, plus on fait d’auto-hébergement, plus on simplifie la tache des espions, puisqu’il suffit d’intercepter un seul mail pour y associer une adresse IP d’émission et de réception et ensuite ne plus avoir besoin de s’attaquer au contenu du trafic mail pour savoir qui intervient (l’IP suffit alors).

**« Faire tourner un serveur mail sur un serveur Tor et/ou envoyer les mail en SMTPS over TOR peut résoudre complétement le problème des méta-données »**  
C’est aussi totalement faux.
Tor ne permet que (et uniquement que) de masquer l’adresse IP de son émetteur, et l’adresse IP du destinataire dans le cas d’un [service caché](https://www.torproject.org/docs/hidden-services.html).
Si on fait passer du trafic SMTP dans Tor, le nœud de sortie relaiera quand même le mail sur l’Internet public, donc aux sondes NSA & cie avec les métadonnées accessibles voire le contenu si pas de GPG.
Et on ne peut actuellement pas faire un service caché mail dans Tor, puisque Tor interdit l’usage du DNS alors que SMTP repose massivement dessus (au moins pour la détermination du MX, mais aussi pour la gestion du spam comme avec
 [DNSBL](https://fr.wikipedia.org/wiki/DNS_Black_Listing), [DKIM](https://fr.wikipedia.org/wiki/DomainKeys_Identified_Mail) ou [SPF](https://fr.wikipedia.org/wiki/Sender_Policy_Framework)).

**« Avec un simple Capcha (sic) tu échappes avec certitude à la surveillance de masse »**  
Si c’est vraiment le cas, je pense que ce n’est pas Own-Mailbox que vous devriez kickstarter…
Voire même vous devriez immédiatement contacter le Ministère de l’Intérieur, je crois qu’ils ont du travail pour vous…

**« Si tous le monde utilisait son serveur smtpS (chiffré en TLS) chez soit et envoyait ses mail via tor il n’y aurait pas de fuite de meta-données »**  
Sur le principe, je suis d’accord. Mais ça demande de revoir **tous** les protocoles mail existants. 
SMTPS a été [déprécié](https://en.wikipedia.org/wiki/SMTPS) au profit de STARTTLS (ce qui est possiblement une erreur vis-à-vis de la sécurité et de la vie privée, mais c’est un fait) et comme mentionné ci-dessus, SMTP n’est actuellement pas compatible avec Tor à cause du DNS inexistant.
Tous les cryptologues et chercheurs en sécurité du moment sont unanimes sur un seul point : SMTP est mort et enterré si on se place d’un point de vue sécurite & vie privée, mais il n’existe actuellement aucun protocole pour remplacer réellement le mail et encore moins de manière compatible.
Il existe bien des solutions émergentes, type [Tox](https://tox.im/) ou [Bitmessage](https://bitmessage.org/), mais ni utilisés ni utilisables à grande échelle, ou encore [Caliopen](https://caliopen.org/), mais ces projets sont de très grosses envergures et mettront encore des années avant d’être accessible au grand public.  
En prime, en prenant la déclaration de Own-Mailbox au pied de la lettre, on ne peut que leur donner raison : leur projet est mort-né, ni sécurisé ni confidentiel et il faut commencer à monter quelque chose de neuf qui ne soit pas du mail. 

**« Oui les méta données permettent à la NSA de savoir qui sont tes amis, mais le contenu leur permet de savoir ce que tu penses et ce que tu fais, ce qui est bien plus grave »**  
C’est faux aussi.
Les méta-données sont [aussi voire plus révélatrices que le contenu lui-même](https://www.eff.org/fr/deeplinks/2013/06/why-metadata-matters).
La surveillance de masse dénoncée par Edward Snowden ou le tracking publicitaire sur Internet se contre-fiche réellement de votre contenu tant que vous ne devenez pas une de leur cible prioritaire.
Et si vous l’êtes réellement, GPG et TLS ne vous seront d’[aucune utilité](https://en.wikipedia.org/wiki/Tailored_Access_Operations).

**« Though it should be said that man in the middle attack cannot be used for mass surveillance. Because Man in the middle attacks are highly detectable »**  
(Commentaire caché dans le source de leur site web).
La NSA appréciera donc que [ses attaques](https://nsa.imirhil.fr/documents/media-35658/pages/5.png?size=big) soient inutilisables, en particulier leur système [BYZANTINE HADES](https://nsa.imirhil.fr/documents/media-35686/pages/21.png?size=big) ou encore [QUANTUM](https://nsa.imirhil.fr/documents/media-35689/pages/14.png?size=big)…

# Conclusion

Charlatanisme avéré ou manque de bagage technique évident ?
Je me pose encore la question…

L’équipe semble de bonne volontée et on est à des lieux des véritables arnaques comme [Anonabox](https://www.indiegogo.com/projects/anonabox-access-deep-web-tor-privacy-router), [Wemagin](https://www.kickstarter.com/projects/1052775620/wemagin-smart-usb-drive), ou [Webcloak](https://www.kickstarter.com/projects/916285694/webcloak-advanced-web-security-and-online-privacy), puisqu’au pire, Own-Mailbox sera, elle, une bonne solution d’auto-hébergement.
Mais elle se retrouve alors en compétition directe avec [La brique Internet](http://labriqueinter.net/) ou [YunoHost](https://yunohost.org/) et n’est du coup plus du tout compétitive, puisqu’elle se concentre uniquement sur le mail quand les autres proposent n’importe quel service (XMPP, blog, partage de fichiers…) et de manière beaucoup plus propre (VPN et IP dédiée).

Les auteurs cherchent-ils à profiter de la vague Snowden pour glisser un peu de bullshit bingo et attirer la ménagère de moins de 50 ans dans leurs filets ?
En tout cas sur la partie sécurité et confidentialité, pourtant mise en avant partout et reprise massivement pas la presse, ils sont autant à poil qu’un mail sur le réseau.
 
En espérant qu’ils tiendront compte de l’énorme historique qu’on a déjà sur la (non-)sécurisation du mail et reverront
 leur campagne de communication, avant de fonder au mieux un énorme botnet et au pire un [futur cimetière](https://about.okhin.fr/posts/Crypto_parties/) de [lanceurs d’alerte]({% post_url 2015-06-02-extremiste-fier-de-letre %}#de-grands-pouvoirs-impliquent-de-grandes-responsabilits-)…

En bref, Own-Mailbox auto-hébergement peut-être, Own-Mailbox sécurité & vie privée, définitivement non.

*[La réponse à la réponse de Own-Mailbox]({% post_url 2015-09-27-ownmailbox-reponse %})* —
*[La conclusion]({% post_url 2015-09-27-ownmailbox-suite-fin %})*
