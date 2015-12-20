---
title: ! 'Let’s Encrypt : joies… et déceptions !'
---

# Les autorités de certification, cette plaie de HTTPS…

Les [autorités de certification racine](https://fr.wikipedia.org/wiki/Certificat_racine)…
Comment pourrait-on ne pas en parler quand on parle de TLS ou de HTTPS…

Ces autorités, point d’ancrage de la chaîne de confiance bâtie par [X.509](https://fr.wikipedia.org/wiki/X.509) (le standard derrière les certificats HTTPS), ont généralement toutes connues un problème à un moment de leur vie, que ça soit parce qu’elles se sont fait trouer ([Comodo & DigiNotar](http://www.clubic.com/antivirus-securite-informatique/virus-hacker-piratage/hackers/actualite-444714-diginotar-comodo-pirate-ssl.html), [Vasco](http://www.mag-securs.com/news/articletype/articleview/articleid/28740/gmail-vise-par-un-faux-certificat-ssl.aspx)…), parce qu’elles font n’importe quoi ([ANSSI](http://www.nextinpact.com/news/84805-google-bloque-certificats-corrompus-emis-par-autorite-liee-a-l-anssi.htm)), parce qu’elles sont à la fois juges et parties (Visa, Amazon, Wells Fargo Bank…), parce qu’elles sont directement liées à un gouvernement quelconque ([ANSSI](https://en.wikipedia.org/wiki/Agence_nationale_de_la_sécurité_des_systèmes_d'information), [CNNIC](https://en.wikipedia.org/wiki/China_Internet_Network_Information_Center), [TurkTrust](https://nakedsecurity.sophos.com/2013/01/08/the-turktrust-ssl-certificate-fiasco-what-happened-and-what-happens-next/)…), voire carrément parce qu’elles collaborent avec des dictatures ([Microsoft](https://reflets.info/microsoft-et-ben-ali-wikileaks-confirme-les-soupcons-d-une-aide-pour-la-surveillance-des-citoyens-tunisiens/)).

Comme si ça ne suffisait pas, ces autorités vendent à prix d’or leurs certificats (comptez environ une centaine d’euros par an par certificat), soi-disant parce que la procédure de vérification d’identité est compliquée (ce qui en prime ne les empêche même pas d’émettre de faux certificats) ou qu’il y a une assurance de plusieurs centaines de milliers d’euros derrière.

En bref, pour un pixel tout seul dans son coin, il est quasiment impossible d’obtenir un certificat sans se ruiner, et encore pire sans avoir à dévoiler son identité, et les utilisateurs finaux ne sont de toute façon pas à l’abri d’une erreur (volontaire ou involontaire) de la part d’une des [centaines autorités de certification embarquées en dur dans nos navigateurs](https://mozillacaprogram.secure.force.com/CA/IncludedCACertificateReport) (sachant qu’une seule compromise suffit à casser l’ensemble de la chaîne, n’importe laquelle pouvant émettre un certificat totalement valide pour n’importe qui). 

Des alternatives ont vu le jour, comme [StartSSL](https://www.startssl.com/) qui permet d’obtenir des certificats gratuitement ou [CAcert](https://www.cacert.org/), une autorité de certification communautaire mais malheureusement pas reconnue par nos navigateurs.

Entre StartSSL qui était reconnue par les navigateurs mais qui n’autorise aucune automatisation et CAcert qui n’était pas reconnue et réclamait la rencontre physique de plusieurs personnes de la communauté pour pouvoir émettre son premier certificat, un administrateur n’avait aucune possibilité simple pour obtenir un certificat et ainsi pouvoir déployer HTTPS sur ses services.

# Let’s Encrypt

Et plus récemment, une petite nouvelle est apparue : [Let’s Encrypt](https://letsencrypt.org/).

## À première vue, une bonne alternative…

Let’s Encrypt est un projet soutenu par [Mozilla](https://www.mozilla.org/), l’[Electronic Frontier Foundation](https://www.eff.org/) et plein d’autres.

L’offre semble alléchante : gratuite, 100% automatisée, pas de procédure fastidieuse de preuve d’identité, libre, soutenue par de grands noms en qui on peut avoir confiance.

J’ai eu la chance de faire partie des alpha-testeurs de cette solution, donc j’ai déjà pu faire un peu mes armes avant le lancement de [la béta publique](https://letsencrypt.org/2015/12/03/entering-public-beta.html) ce 3 décembre, la solution est assez facile à mettre en place, il suffit de suivre à la lettre [le tutoriel](https://github.com/letsencrypt/letsencrypt) du projet et tout se passe pour le mieux.

La procédure se résume très grossièrement à :

	git clone https://github.com/letsencrypt/letsencrypt && cd letsencrypt
	./letsencrypt-auto
	/root/.local/share/letsencrypt/bin/letsencrypt certonly --webroot \ 
	--webroot-path /var/www/example --renew-by-default --email \
	example@example.org --text --agree-tos --agree-dev-preview -d \
	site.example.org

On obtient alors une clef privée et un certificat tout frais, prêts à être utilisé classiquement sur votre serveur web préféré.

Le client officiel de Let’s Encrypt étant assez lourd et compliqué à utiliser ([virtualenv](https://virtualenv.readthedocs.org/) python, droits utilisateurs particuliers…), une solution alternative (l’intérêt d’une solution libre et ouverte !) est rapidement apparue, [ACME tiny](https://github.com/diafygi/acme-tiny).

## … Mais qui pèche assez fortement un peu partout.

Malheureusement, Let’s Encrypt fait l’impasse sur pas mal de chose, ce qui en fait une solution assez peu pratique à déployer, surtout si comme moi on est un grand extrémiste de la sécurité.

### Des paramètres par défaut insuffisants

Déjà, les paramètres par défaut de Let’s Encrypt ne sont pas corrects.
Pourtant, tout le monde sait, en particulier dans le monde de la crypto, qu’un outil de crypto est correcte quand sa configuration par défaut est correcte, la plupart des utilisateurs n’allant de toute façon jamais la modifier.
C’est même la principale raison de l’énorme échec de GPG : des paramètres par défaut mauvais sur toute la ligne.

Par exemple, l’outil génère par défaut des clefs RSA de 2048 bits.
Cette taille est dorénavant très insuffisante, et [déconseillée officiellement par l’ANSSI](http://www.ssi.gouv.fr/uploads/2015/01/RGS_v-2-0_B1.pdf) au profit de clefs d’au moins 3072 bits.
Certes, vos machines ne réclament sûrement pas un niveau de sécurité digne d’Edward Snowden, mais il ne sert à rien de rester dans la zone rouge de la crypto surtout quand l’usage d’une clef de 4096 bits n’est absolument pas une contrainte.
Le problème a été [officiellement soulevé](https://github.com/letsencrypt/letsencrypt/issues/489) à Let’s Encrypt, qui a donné [une fin de non-recevoir](https://github.com/letsencrypt/letsencrypt/issues/489#issuecomment-153757615), arguant que 2048 était la configuration par défaut et que si on voulait plus, il fallait juste changer le fichier de configuration. 

### Arrêt de production ou HTTPS only non supporté

Ensuite, Let’s Encrypt, par défaut encore, réclame d’arrêter le serveur de production pour valider la détention du domaine à signer.
Il embarque en effet son propre serveur web pour échanger avec leur back-office, et il ne peut évidemment pas fonctionner si le nôtre est déjà en fonctionnement.
C’est juste un comportement totalement inutilisable, personne de censé ne va arrêter sa production [tous les 90 jours](https://letsencrypt.org/2015/11/09/why-90-days.html) pour renouveler un certificat…
Encore une fois, il est possible de contourner le problème via l’utilisation de la méthode [*webroot*](https://letsencrypt.readthedocs.org/en/latest/using.html#webroot) au lieu de la méthode par défaut [*standalone*](https://letsencrypt.readthedocs.org/en/latest/using.html#standalone).

ACME tiny souffre aussi du problème qu’il [ne supporte pas](https://github.com/diafygi/acme-tiny/blob/master/acme_tiny.py#L114-L129) HTTPS mais uniquement HTTP pour communiquer avec le back-office de Let’s Encrypt.
Ça se corrigera sûrement avec le temps ([le patch étant trivial](https://github.com/aeris/acme-tiny/commit/5eb7037fdd3073389840ed3d50bc0faf08a3063f)), mais en l’état, ça n’est pas utilisable sur un système HTTPS only (un comble…).

### Non prise en compte des standards annexes de HTTPS

Enfin, et c’est à mon sens la plus grave erreur de Let’s Encrypt : ils se sont assis sur l’intégralité de ce qui touche à TLS de manière indirecte.
L’IETF a fait [exactement la même erreur](https://lists.w3.org/Archives/Public/ietf-http-wg/2015JanMar/0000.html) avec HTTP/2.
X.509, TLS & HTTPS sont des écosystèmes très complexes, avec énormément de standards construits par-dessus tout ça, et en particulier parce que les autorités de certification n’ont jamais été fiables.
C’est pour ça qu’on a mis en place [HSTS](https://fr.wikipedia.org/wiki/HTTP_Strict_Transport_Security), [HPKP](https://fr.wikipedia.org/wiki/HTTP_Public_Key_Pinning), ou encore [DANE/TLSA](https://fr.wikipedia.org/wiki/DNS_-_based_Authentication_of_Named_Entities).
Pas de bol, Let’s Encrypt ne prend pas suffisamment en compte ces standards…

Le fait que les certificats soient par défaut émis avec une durée de vie de 90 jours demandent de les renouveler souvent.
[Les justifications](https://letsencrypt.org/2015/11/09/why-90-days.html) du projet sur cette durée très courte (on a plutôt l’habitude aux certificats valables 1 an) sont déjà à la limite du recevable pour ma part, mais en plus, l’automatisation complète du processus pourtant posée comme justification principale est littéralement impossible à mettre en place si on active d’autre systèmes de sécurité.

Commençons par le plus simple : DANE/TLSA.
DANE/TLSA permet à un administrateur de déclarer dans son DNS (protégé par [DNSSec](https://fr.wikipedia.org/wiki/Domain_Name_System_Security_Extensions) sinon aucun intérêt) le certificat qui va être utilisé par le serveur web.
On peut ainsi se passer des autorités de certification et on possède un second canal sécurisé pour vérifier qu’on n’est pas en train de se prendre une attaque de l’homme du milieu.
Ce protocole n’est pas encore disponible nativement dans Firefox, mais [une extension](https://addons.mozilla.org/fr/firefox/addon/dnssec-validator/) permet de l’ajouter.  
Comme Let’s Encrypt réclame de régénérer fréquemment son certificat, il va falloir modifier régulièrement sa configuration DNS. Déjà avec un serveur DNS standard la modification n’aurait pas été évidente, mais avec DNSSec, l’automatisation relève vraiment du miracle, surtout que les clefs de signature de sa zone DNSSec ne doivent idéalement pas être sur la même machine que ses certificats X.509 (sinon DANE/TLSA n’a que peu d’intérêt) ou qu’on met en place des serveurs DNS fantômes pour garder les clefs DNSSec hors ligne la majeure partie du temps.  
On peut minimiser le problème en n’entrant dans le DNS que la clef publique des certificats, ce qui évite d’avoir à changer les entrées DANE à chaque renouvellement.
Ça suppose alors de ne pas utiliser le client officiel Let’s Encrypt (qui régénère à la fois le certificat et la clef privée), mais plutôt ACME tiny et un peu de bidouille avec OpenSSL.

Le cas le pire se produit avec HPKP si on utilise Let’s Encrypt par défaut.
HPKP va demander à votre navigateur de stocker l’empreinte de la clef du certificat, et vous **interdira** purement et simplement de vous connecter à nouveau au site visité s’il se met à présenter par la suite un certificat avec une clef différente.
Pour quand même pouvoir traiter le cas d’une clef compromise, HPKP nécessite de déclarer deux clefs, la clef utile et la clef de secours, afin de pouvoir basculer sur la clef de secours en cas de compromission.
HPKP ne supporte aucune erreur de déploiement : vous renouvelez votre certificat trop tôt ou sans faire un roulement de clef suffisamment à l’avance et l’ensemble de vos clients n’ont juste plus aucun moyen de communication avec vous, leur navigateur allant juste leur interdire de visiter votre site.  
On voit bien le problème avec le client Let’s Encrypt standard : au renouvellement du certificat (et donc de la clef privée), l’ensemble de vos visiteurs vont avoir le droit à une jolie page blanche, la clef présentée ne pouvant pas être une de celles mémorisées par vos visiteurs (l’ancienne clef n’est plus valide, mais aussi la clef de backup !)!  
Encore une fois, en passant par ACME tiny et l’utilisation de [CSR](https://fr.wikipedia.org/wiki/Demande_de_signature_de_certificat), on peut résoudre le problème, mais on fait tout le travail de Let’s Encrypt à la main.

Sachant que HSTS réclame a minima [18 semaines](https://hstspreload.appspot.com/) (126 jours) pour pouvoir être intégré par défaut aux navigateurs, [6 mois](https://www.ssllabs.com/downloads/SSL_Server_Rating_Guide.pdf) (180 jours) pour être considéré comme *A+* sur SSLLabs ou encore que la norme HPKP préconise [60 jours](https://tools.ietf.org/html/rfc7469#section-4.1) de délai de rétention, les 90 jours de Let’s Encrypt sont totalement en dehors des clous.
Pour commencer à être utilisable, la durée de vie d’un certificat et encore plus d’une clef privée devrait être d’au moins le double de la période de validité de HPKP, soit 120 jours, pour laisser aux administrateurs la possibilité de palier à un problème grave.
La zone de confort se situe en pratique à 1 an si on tient compte des délais ou des tests nécessaires au changement d’une clef privée.

Le bilan de Let’s Encrypt est du coup assez mitigé.
L’initiative d’avoir une autorité de certification accessible à tous gratuitement est une excellente nouvelle, et ne peut qu’être saluée.
Par contre, une mise-en-œuvre correcte de cette solution reste une fois encore uniquement à la portée de geek maîtrisant X.509 et assimilés sur le bout des doigts, la solution officielle se contentant de paramètres faibles et de cas d’usage rapidement très limités voire dangereux si l’utilisateur ne se rend pas compte des implications (HPKP), alors qu’on aurait aimé quelque chose d’accessible plus facilement les yeux fermés.

En attendant, j’ai quand même passé tous mes sites sous Let’s Encrypt.
Si ça devient tout blanc à un moment, vous saurez donc pourquoi ! :D

