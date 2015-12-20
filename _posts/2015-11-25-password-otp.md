---
title: De l’authentification sans mot de passe
---

Après avoir vu [comment gérer proprement ses mots de passe]({% post_url 2015-10-27-stockage-mot-passe %}), allons un peu plus loin et regardons comment gérer de l’authentification sans mot de passe (ou presque) !

L’authentification a pour but de donner l’accès à une ressource protégée en vérifiant par une manière donnée que la personne qui cherche à obtenir l’accès est bien celle qu’elle dit être.
Via un mot de passe ou une phrase de passe, on authentifie une personne par une chose qu’elle sait (son mot de passe).
On pourrait aussi authentifier une personne par ce qu’elle détient, un petit objet physique dont on a la certitude qu’elle en est bien l’unique détentrice.
On a de la chance, de tels objets existent.

La difficulté de conception de ces objets est d’arriver à trouver une méthode permettant de prouver qu’on est bien détenteur de l’objet à l’instant où on réalise l’authentification.
On ne peut évidemment pas se baser sur des choses aussi simple qu’un numéro de série inscrit sur l’objet ou qu’il enverrait par un moyen ou par un autre, puisque qu’il suffirait de récupérer ce numéro une seule fois pour pouvoir s’authentifier sans avoir réellement l’objet sur soi.

La plupart des systèmes d’authentification de ce type repose donc classiquement sur des clefs de chiffrement (symétrique ou asymétrique) dont la clef privée va être en écriture seule sur l’objet, et dont personne ne pourra donc jamais avoir accès sinon le fabriquant (et généralement même pas son utilisateur).

# Token physique

## Yubikey

On va commencer par le plus utilisable en pratique, et le plus libre, [Yubikey](https://www.yubico.com/products/yubikey-hardware/).

![Yubikey](/assets/images/20151125/yubikey.png){:.center}

Une Yubikey est une petite clef USB qui simule un clavier USB.
À l’intérieur se trouve une clef AES en écriture seule (pas de lecture possible de la clef), possédée aussi par Yubico (l’entreprise fabriquant la Yubikey).

À chaque appui sur le bouton de la clef, celle-ci va émettre une chaîne composée de son identifiant de clef, d’un compteur de session (s’incrémente à chaque branchement de la clef), d’un compteur d’horloge (s’incrémente 8× par seconde) et d’un compteur d’utilisation (s’incrémente à chaque appui sur le bouton).
La chaîne complète est chiffrée avec la clef AES interne, et envoyée ainsi à l’application qui cherche à vous authentifier.

Votre application va alors contacter le serveur de Yubico et lui soumettre la chaîne chiffrée.
Le serveur possédant lui aussi la clef privée, il peut déchiffrer les données et les vérifier.
S’il est capable de déchiffrer les données et que l’identifiant d’utilisateur correspond bien à celui associé à la clef, on est en présence d’une clef valide.
Si les valeurs de tous les compteurs sont bien strictement supérieures à celles de la dernière chaîne validée, on est en présence d’un nouveau identifiant et non d’un rejeu d’une chaîne interceptée.

La dernière propriété (la vérification des compteurs) est assez intéressante, puisque même si vous parvenez à subtiliser une clef et à lui faire générer des millions de chaînes pour ensuite la remettre à sa place sans que son propriétaire ne remarque son absence, la prochaine utilisation de la clef invalidera l’intégralité de toutes les chaînes enregistrées (compteur de session ou d’utilisation inférieur au compteur de la clef) !
Vous pouvez même volontairement générer des clefs pour n’importe qui (au pif, une des miennes : `cccccccirlrfrvldfubllgjdjkbdgeejbuvcfcvfdurb`, que vous pouvez tester sur le [serveur de démo](https://demo.yubico.com/) de Yubico), ça ne compromet pas votre sécurité (sauf à vous permettre de bruteforcer la clef AES 128 de la clef).

Une fois la vérification de la chaîne réalisée, le serveur Yubico répond à votre application (via du chiffrement asymétrique) si elle est valide ou non, et votre application autorise alors ou non l’accès à la ressource protégée.

[Pas mal d’applications](https://www.yubico.com/applications/) sont compatibles avec Yubikey. LUKS, PAM, LastPass, GitHub, DropBox, WordPress, Drupal, RoundCube, OwnCloud, j’en passe et des meilleurs.

Tous les logiciels nécessaires à l’intégration d’une Yubikey sont [libres](https://github.com/Yubico) et [intégrés nativement](https://packages.debian.org/jessie/yubikey-personalization) à la plupart des distributions GNU/Linux.
Vous avez même tout le nécessaire pour monter votre propre serveur de validation si vous ne voulez plus dépendre de celui de Yubico.
Attention tout de même, peu d’applications supportent un serveur personnalisé, en particulier les services que vous ne contrôlez pas directement (GitHub, DropBox…).

Autre intérêt d’une Yubikey : elle possède 2 entrées en interne, un appelé par un appui court (slot 1), l’autre par un long (slot 2).
On peut donc utiliser une clef pour le serveur Yubico et l’autre pour son serveur personnel, ou encore une clef Yubico et un mot de passe standard classique (mais de 64 caractères aléatoires !!!
À garder par contre bien précieusement et vous n’avez plus le droit de vous séparer de votre clef, quelqu’un y ayant accès peut obtenir votre mot de passe statique).

Cette clef ne coûtant que $25, ça en fait un excellent moyen d’authentification à pas trop cher.

Petit bémol pour les très geek. Comme cette clef émule un clavier USB, si vous utilisez une disposition de clavier peu conventionnelle (au pif, un bépo ou un dvorak), cette clef ne fonctionne plus (elle est prévue pour fonctionner en qwerty ou en azerty uniquement).
En bidouillant un peu X.Org pour lui signaler que le périphérique USB de la clef doit être en qwerty, mais pas les autres, on peut arriver à utiliser une Yubikey sans trop de galère :

	/etc/X11/xorg.conf.d/90-keyboard.conf
	Section "InputClass"
		Identifier          "typematrix"
		MatchIsKeyboard     "yes"
		MatchVendor         "TypeMatrix.com"
		MatchProduct        "USB Keyboard"
		Option "XkbModel"   "tm2030USB-102"
		Option "XkbLayout"  "fr,fr"
		Option "XkbVariant" "bepo,"
		Option "XkbOptions" "kpdl:kposs,grp:sclk_toggle,compose:lwin"
	EndSection

	Section "InputClass"
		Identifier          "yubikey"
		MatchIsKeyboard     "yes"
		MatchVendor         "Yubico"
		MatchProduct        "Yubikey"
		Option "XkbModel"   "pc101"
		Option "XkbLayout"  "us"
		Option "XkbVariant" "intl"
	EndSection

Malheureusement, ça ne fonctionne pas forcément sur toutes les configurations, en particulier sur les PC portables (ils ont des configurations USB matérielles tordues et le clavier du PC se retrouve généralement sur le même bus USB que la Yubikey)…
Si vous n’avez pas de chance, vous devrez donc jongler avec le gestionnaire de disposition de clavier de votre environnement de bureau pour passer en qwerty à chaque utilisation de votre clef.

## TOTP / HOTP

Une autre solution basée sur un matériel physique dédié : les OTP c100 et c200 de chez [FTSafe](http://www.ftsafe.com/product/otp)

![OTP FTSafe](/assets/images/20151125/ftsafe.png){:.center}

Le principe est le même que pour les Yubikeys, une clef privée est embarquée à l’intérieur et ne peut en sortir.
Cette clef privée vous est aussi communiquée sur un bout de papier (dans un envoi séparé physiquement et temporellement de celui du token physique lui-même !!!).
Lorsqu’on appuie sur le bouton, l’écran affiche un numéro à 6 chiffres calculé à partir de la clef privée et d’un compteur (pour la version HOTP / « event based ») ou de l’heure (TOTP / « time based »).

Dans le cas d’un HOTP, chaque appui sur le bouton incrémente un compteur `C`, et la valeur affichée `V` est calculée en appliquant une [fonction de hachage HMAC](https://fr.wikipedia.org/wiki/Keyed-Hash_Message_Authentication_Code) avec la clef privée `K` : `V = HMAC(K, C)`.
Dans le cas de TOTP, on prend l’[heure courante UNIX](https://fr.wikipedia.org/wiki/Heure_Unix) `T` ramenée à des tranches de `X` secondes (généralement 30s) et on calcule de même `V = HMAC(K, T/X)`.

Quand on veut s’authentifier la première fois auprès d’une ressource, il suffit de recopier sa clef privée et de saisir la valeur affichée et le serveur peut alors identifier votre valeur initiale de compteur (HOTP) ou d’horloge (TOTP).
Pour chaque authentification suivante, on saisit uniquement la valeur affichée et le serveur est capable de faire le même calcul que le token.
Si la valeur calculée est identique à celle fournit par l’utilisateur, on est bien en présence du token physique.  
On retrouve la même propriété que pour les Yubikeys : une valeur récupérée à l’instant T n’est plus valable à l’instant T+1, subtiliser discrètement votre token pour en extraire quelques valeurs et le remettre en place ensuite est peine perdue.

Les horloges du serveur et du token (TOTP) ou du compteur (HOTP) ne sont pas forcément tout à fait identiques (décalage de l’horloge ou utilisateur qui s’est amusé à appuyer plusieurs fois sur le bouton), le serveur accepte donc une légère tolérance dans la valeur d’horloge et de compteur (en fait il calcule X valeurs et la valeur saisie par l’utilisateur doit être parmi ces X, avec généralement X = 4).  
Les petits malins remarqueront qu’il faut donc un token HOTP par service (chaque authentification sur un service désynchroniserait le compteur côté serveur des autres services), alors qu’on peut réutiliser un token TOTP pour autant de service qu’on souhaite (à ceci prêt que tous les services auront accès à votre clef privée et pourraient donc s’authentifier ailleurs à votre place).

HOTP & TOTP ont été normalisés par des RFC, respectivement [4226](https://tools.ietf.org/html/rfc4226) et [6238](https://tools.ietf.org/html/rfc6238), ils ont donc pléthores d’implémentations disponibles et sont relativement assez intéropérables.
On les trouve généralement dans les solutions de sécurité professionnelles, pour les administrateurs systèmes par exemple.

On trouve ces solutions pour quelques dizaines d’euros, ce qui en fait une solution accessible facilement.

# TOTP sur téléphone mobile

Des solutions existent pour faire du TOTP en version logicielle sur téléphone mobile, l’import de la clef privée se faisant via le scan d’un [code QR](https://fr.wikipedia.org/wiki/QRcode).
On perd simplement la capacité du matériel à empêcher d’extraire votre clef privée (vous vous faites voler votre téléphone éteint ou verrouillé, on peut en extraire la clef quand même).

Cette solution est de plus en plus présente, poussée essentiellement par Google et sa solution [Google Authenticator](https://fr.wikipedia.org/wiki/Google_Authenticator).
On peut utiliser [FreeOTP](https://f-droid.org/repository/browse/?fdid=org.fedorahosted.freeotp) disponible sur le dépôt [F-Droid](https://f-droid.org/) pour se connecter sur énormément de services (Amazon/Heroku, BitBucket/GitHub, Coinbase, Drupal/WordPress/Joomla, Facebook/Tumblr, Keepass/LastPass…). 

![Free OTP](/assets/images/20151125/freeotp.png){:.center}

Le seul soucis que je rencontre est que, alors que je n’ai aucun problème à conserver mes Yubikeys sur moi en permanence, il m’est compliqué d’avoir mon téléphone toujours avec moi.
Il est alors malheureusement compliqué de partager un secret entre plusieurs applications de gestion TOTP, par exemple pour pouvoir s’authentifier avec FreeOTP quand on a son téléphone à portée, mais aussi via [la ligne de commande](https://gist.github.com/aeris/fd59fd49205cb085374c), sauf à conserver le code QR d’origine dans un endroit fiable pour pouvoir l’insérer dans d’autres applications par la suite.

# Certificat X.509

[X.509](https://fr.wikipedia.org/wiki/X.509) est une norme bien compliquée que peu de monde aime toucher tellement elle est bordélique (en particulier parce que basée sur [ASN.1](https://fr.wikipedia.org/wiki/ASN.1), le seul langage plus facilement compréhensible par une machine que par un développeur…).
Elle est essentiellement (non) connue du grand public pour son usage au cœur de [TLS](https://fr.wikipedia.org/wiki/Transport_Layer_Security) et donc de [HTTPS](https://fr.wikipedia.org/wiki/HyperText_Transfer_Protocol_Secure).

Pour TLS/HTTPS, X.509 est utilisé principalement pour permettre au navigateur d’authentifier de manière (plus ou moins) forte le serveur en face, et ainsi de vous garantir (ou pas) que la machine sur laquelle vous allez saisir vos coordonnées bancaires est bien celle de votre banque (ou pas).
Cette garantie vous est fournie par une des (trop) nombreuses autorités de certification [embarquées directement dans votre navigateur](https://mozillacaprogram.secure.force.com/CA/IncludedCACertificateReport) : si l’une d’elles déclare que c’est bien le serveur de votre banque, alors c’est que c’est vrai et que c’est bien le serveur de votre banque.  
En pratique, en plus de souvent être d’origine douteuse (Chine, USA, Turquie, France…), la majorité sinon la totalité des autorités de certification se sont faites trouer un jour et/ou ont émis de faux certificats, d’où l’ironie du paragraphe précédent.

X.509 permet de faire la vérification dans l’autre sens, et autorise ainsi au serveur de s’assurer de l’identité du client via un certificat client, tout comme le serveur de votre banque vous présente le sien.
Cette possibilité est malheureusement trop peu utilisée, le seul exemple notable étant la tentative de l’administration fiscale française en 2009 qui s’est soldée par un cuisant échec face à la complexité technique engendrée…

L’énorme avantage de la solution du certificat X.509 personnel est que c’est la seule solution qui passe l’échelle.
En effet, les solutions précédentes sont utilisables pour un petit groupe d’une dizaine de personnes, après la gestion devient trop complexe (révocation, perte, arrivée d’un petit nouveau…).
X.509 étant basé sur une chaîne de confiance, on peut au contraire créer sa propre autorité de certification, gérée par sa propre [PKI](https://fr.wikipedia.org/wiki/Infrastructure_à_clés_publiques), et tout certificat émis par cette autorité est valide et reconnu comme tel par le système.
On peut alors générer à la chaîne des pilées de certificat sans avoir à toucher à une ligne de configuration d’un des services, alors que les solutions précédentes demandaient une intervention manuelle à chaque ajout/retrait d’une personne.
X.509 fournit aussi tous les outils pour gérer la révocation d’un certificat (perte, départ, compromission…).

Cette solution a aussi l’avantage d’être implémentée nativement dans tous les navigateurs web et dans la plupart des outils pouvant utiliser TLS (courriel, messagerie instantanée…).
Par contre, elle reste mal comprise des utilisateurs, demande un peu de gestion régulière (renouveler les certificats chaque année…) et pose parfois des problèmes techniques (importer son certificat utilisateur sur X machines ou navigateurs, logiciels ne supportant pas ou mal ce mode de fonctionnement…).

# Données biométriques

Empreintes digitales, oculaires, palmaires… Non, je rigole bien sûr !
Ces solutions ne sont **pas** des solutions d’authentification, mais uniquement d’identification.

Une solution d’authentification doit pouvoir être révocable à tout moment en cas de compromission.
Vous pouvez changer votre mot de passe ou révoquer votre Yubikey/C100/X.509, mais vous ne pouvez en aucun cas changer vos empreintes digitales ou votre fond d’œil.
Et pourtant, faites confiance à un gus dans un garage pour vous [pirater vos empreintes digitales](http://rue89.nouvelobs.com/2014/12/28/pirater-empreinte-digitale-cette-photo-suffit-256786) et ne sous-estimez jamais l’intelligence d’une [petite fille de 5 ans](https://i.imgur.com/iYENVxU.jpg).

Servez-vous des données biométriques tout au plus pour vous assurer de l’identité de votre utilisateur (en remplacement d’un login par exemple), mais certainement pas en remplacement d’un mot de passe ! 

De la même manière, ne protégez pas uniquement vos ressources critiques avec seulement un token, demandez aussi à votre utilisateur de saisir un mot de passe standard en supplément, ceci afin de parer au vol du token (ou au collègue qui aura lu ponctuellement un de vos OTP).
Ce mot de passe a moins besoin de répondre aux critères standards d’un bon mot de passe (unicité, longueur, aléa…) puisqu’il vient en complément de la solution d’authentification forte.

Et en résumé, un bon mot de passe, c’est pas de mot de passe du tout (ou pas tout seul) !
