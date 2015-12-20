---
title: CryptCheck, vérifiez vos implémentations de TLS
---

Si vous fréquentez régulièrement ce blog ou mes comptes sociaux, il ne vous aura pas échappé que ma préoccupation du moment, c’est essentiellement TLS et HTTPS.
J’ai même fini dans [un article](https://confs.imirhil.fr/20150824_zdnet_tls/) sur ZDNet à cause de ça :)

TLS est un monde malheureusement (très) compliqué, et source de (trop) nombreuses erreurs.
Suite à plusieurs demandes, un petit billet de survol.

# Fondamentaux

Vous trouverez des explications plus détaillées dans [cette conférence](https://confs.imirhil.fr/20141116_ubuntu-party_comprendre-https.webm) ou [celle-ci](https://confs.imirhil.fr/20150620_pses_tls.webm), mais le principal objectif de TLS est de pouvoir garantir la confidentialité de vos données lorsque vous surfez sur Internet.

TLS se base essentiellement sur un certificat, émis par une autorité de certification sensée s’assurer de l’identité du propriétaire du serveur, qui embarque une clef publique dont seul le serveur consulté possède la clef privée.
Via ce couple de clef, un visiteur est capable d’échanger une clef de chiffrement avec le serveur, bien que le canal de communication entre lui et le serveur ne soit pas fiable (on y peut être espionné).
L’intérêt de cette négociation est de pouvoir basculer sur du chiffrement symétrique par la suite pour protéger la communication, chiffrement qui est bien plus rapide que le chiffrement asymétrique permis par la bi-clef mais qui suppose, lui, un canal de communication fiable car il nécessite un secret partagé (vous ne pouvez pas vous mettre d’accord sur ce secret en clair sur Internet).

En pratique, on va avoir 5 morceaux distincts dans la chaîne :

  * Le protocole SSL/TLS lui-même, qui existe en 5 versions (SSLv2, SSLv3, TLSv1, TLSv1.1 et TLSv1.2), et qui définit grosso-modo la manière d’orchestrer une chaîne de chiffrement.
  * L’algorithme asymétrique utilisé. On en compte principalement 2 actuellement :
    [RSA](https://fr.wikipedia.org/wiki/Chiffrement_RSA) et
    [ECDSA](https://fr.wikipedia.org/wiki/Elliptic_curve_digital_signature_algorithm).
  * L’algorithme symétrique utilisé. Ils sont déjà bien plus nombreux, tels que [AES](https://fr.wikipedia.org/wiki/Advanced_Encryption_Standard), [Camellia](https://fr.wikipedia.org/wiki/Camellia_(algorithme)), [SEED](https://fr.wikipedia.org/wiki/SEED), [3DES](https://fr.wikipedia.org/wiki/Triple_DES) ou [RC4](https://fr.wikipedia.org/wiki/RC4).
  * Le mécanisme de protection des données, pour éviter qu’un assaillant puisse modifier les messages chiffrés. On utilise pour cela [HMAC](https://fr.wikipedia.org/wiki/Keyed-Hash_Message_Authentication_Code) ou [AEAD](https://en.wikipedia.org/wiki/AEAD_block_cipher_modes_of_operation).
  * La présence ou non de [confidentialité persistante](https://fr.wikipedia.org/wiki/Confidentialité_Persistante) ou PFS (Perfect Forward Secrecy) en anglais.

Chaque morceau va être détaillé par la suite.

## Protocole SSL/TLS

C’est presque la partie la plus facile du problème.

**SSLv1** n’a jamais été publié, car les études ont montrées que ce protocole était trop mauvais pour pouvoir être mis en production et n’avait aucun intérêt.

**SSLv2** a été publié en 1995 mais ses auteurs ont de suite prévenu qu’il y avait trop de failles à l’intérieur et qu’il fallait plutôt attendre la publication de SSLv3 pour déployer en production. Il a été officiellement déprécié en 2011 par le [RFC 6176](https://tools.ietf.org/html/rfc6176) et n’est plus supporté depuis longtemps par nos navigateurs.

**SSLv3** a été publié en 1996 et a été massivement déployé. Fin 2014, une faille énorme de ce protocole, [POODLE](https://fr.wikipedia.org/wiki/POODLE), est publiée par Google.
En raccourci, SSLv3 ne précise pas comment les logiciels doivent compléter un message pour lui donner une longueur définie.
Du coup un attaquant peut s’amuser à compléter avec 0000, envoyer le message au serveur et constater sa réponse, puis avec 0001, 0002, etc.
Par le biais des mathématiques, il peut ainsi décoder petit-à-petit le message complet.
Un attaquant malin ne cherchera pas à déchiffrer l’intégralité du message, mais s’arrêtera dès qu’il aura accès à vos cookies (ils sont situés en début de message) et pourra alors se connecter à vos comptes à votre place…
Actuellement, des exploitations existent pour casser du SSLv3 par ce moyen en quasi temps réel.
À cause de cette faille, SSLv3 a été officiellement déprécié par le [RFC 7568](https://tools.ietf.org/html/rfc7568).
Firefox 34+ a totalement désactivé le support de cette version, ainsi que Debian.

**TLSv1** est apparu en 1999 et **TLSv1.1** en 2006.
Ces protocoles sont eux aussi faillibles à POODLE car ils ne définissent pas non plus correctement la manière de compléter les messages.
L’exploitation reste cependant beaucoup plus difficile à réaliser que sur SSLv3.

**TLSv1.2** est apparu en 2008 et n’a pas de faille importante connue à ce jour.

Sur le choix des protocoles, la réponse est donc assez simple :

  * SSLv2 ou SSLv3, plus jamais. Vraiment.
    Il n’y a de toute façon que Internet Explorer 6 sous Windows XP qui ne supporte pas TLS… 
  * TLSv1 et TLSv1.1, si on peut s’en passer, c’est mieux.
    Malheureusement, quelques navigateurs ne supportent toujours pas mieux (Internet Explorer < 11, Java < 8, Android < 4.4…).
  * TLSv1.2 devrait être disponible partout voire même le seul protocole actif.

## Authentification du tiers

La première phase de TLS va être de s’assurer de l’identité du tiers qui se trouve en face de nous.
En pratique, seul le client (votre navigateur) authentifie le serveur, même si TLS permet aussi au serveur d’authentifier le client (authentification mutuelle).
Les algorithmes disponibles pour se faire sont les suivants :

**RSA** est basé sur de la factorisation en nombres premiers.
Si *p* et *q* sont de très grands nombres premiers, on sait très facilement calculer *n=p×q*, mais on est incapable de rapidement retrouver *p* et *q* uniquement à partir de *n*.
*n* est donc notre clef publique et le couple *(p, q)* la clef privée.
L’ANSSI [recommande](http://www.ssi.gouv.fr/uploads/2015/01/RGS_v-2-0_B1.pdf) aujourd’hui d’utiliser des tailles de clef d’au moins 3072 bits.
En pratique on utilisera donc des clefs d’au moins 4096 bits. 

**ECDSA** est lui basé sur de la géométrie sur des [courbes elliptiques](https://fr.wikipedia.org/wiki/Courbe_elliptique).
À partir d’une courbe *C*, on sait très facilement calculer la somme de 2 points *R=P+Q* de la courbe, mais on ne sait pas facilement retrouver *P* et *Q* à partir de *R*.
On peut donc à nouveau définir une clef publique et une clef privée.
ECDSA a l’avantage par rapport à RSA de nécessiter des clefs bien plus petites et bien moins de puissance de calcul.
Les recommandations ANSSI sont d’utiliser des courbes d’au minimum 256 bits.

**DSS** est un algorithme concurrent à RSA, aussi basé sur les nombres premiers.
Il souffre de plusieurs problèmes, dont d’être breveté et d’avoir des tailles de clefs fixes et plus faibles.

**PSK** (*Pre-Shared Key*) est un algorithme basé sur des clefs échangées manuellement à l’avance.
Il souffre donc de fait du problème de l’échange de ces clefs via un canal sécurisé.
En pratique, il n’est que peu utilisable puisqu’il impose au client de connaître à l’avance ces clefs, ce qui n’est que très rarement possible.

**SRP** (*Secure Remote Password*) est un algorithme basé sur un mot de passe.
Comme PSK, il nécessite donc non seulement de se mettre d’accord sur un mot de passe à l’avance, mais en plus de faire circuler celui-ci en clair au cours de
 l’échange.

Ici encore, le choix est simple :

 * DSS, PSK et SRP, dehors.
 * RSA, ECDSA, on garde, avec même plutôt une préférence pour ECDSA, les tailles de clef RSA minimales devenant relativement importantes (bientôt du 8192 voire du 16384 ?) et demandant donc de plus en plus de puissance de calcul.

Attention tout de même à une subtilité de TLS. RSA et ECDSA existent en version « anonyme », qui ne vérifient pas l’identité du correspondant.
Ces variantes, elles, ne doivent bien entendu pas être utilisées !

## Chiffrement

SSL/TLS propose un choix assez large d’algorithme de chiffrement symétrique.

**AES**, **Camellia**, **ARIA** et **SEED** sont des algorithmes fiables à l’heure actuelle.
AES a l’avantage d’être implémenté directement au niveau matériel dans les CPU modernes, ce qui lui donne un avantage non négligeable en termes de vitesse de chiffrement.
AES, Camellia et ARIA supportent des chiffrements de 128 et 256 bits, SEED uniquement du 128 bits.
Pour complexifier un peu le tout, AES supporte [CBC](https://fr.wikipedia.org/wiki/Mode_d'opération_(cryptographie)#Encha.C3.AEnement_des_blocs_:_.C2.AB_Cipher_Block_Chaining_.C2.BB_.28CBC.29), [CCM](https://en.wikipedia.org/wiki/CCM_mode) et [GCM](https://fr.wikipedia.org/wiki/Galois/Counter_Mode), Camellia et ARIA seulement GCM et CBC et SEED uniquement CBC.

**3DES** est un algorithme qui chiffre sur 112 bits, mais avec la particularité de n’utiliser que des blocs de 64 bits en interne.
Il est actuellement considéré comme trop faible par l’ANSSI, qui préconise du 128 bits minimum (en taille de clef et en taille de bloc).

**RC4**, mon préféré…
Cet algorithme chiffre sur du 128 bits, mais possède tellement de failles de sécurité qu’il est considéré aujourd’hui comme équivalent à pas de chiffrement du tout.
[Un PC standard bureautique casse du RC4 en 50h](https://www.rc4nomore.com/).
Il est tellement moisi qu’il a été officiellement déprécié par le [RFC 7465](https://tools.ietf.org/html/rfc7465).
Malheureusement, il reste avec 3DES un des plus déployés, parfois même exclusivement…

**DES**, un algorithme de chiffrement sur 56 bits, donc actuellement largement insuffisant pour apporter la moindre sécurité.

**IDEA** (128 bits), **RC2** (40 bits), de vieilles méthodes de chiffrement aujourd’hui dépréciées car trop faibles.

**NULL**. Non non, vous ne révez pas. NULL. Pas de chiffrement du tout. No comment…

Le bilan est ici très simple aussi :

  * AES, Camellia, ARIA et SEED, pas de soucis.
    Préférez si possible les modes non CBC (GCM ou CCM), qui ne sont pas faillibles à POODLE (mais qui réclament TLSv1.2). 
  * 3DES, à éviter le plus possible, il ne tiendra plus très longtemps.
  * RC4, DES, IDEA, RC2 et NULL, plus jamais.

Encore une subtilité de SSL/TLS : le mode « EXPORT ».
La cryptographie a été longtemps interdite de par le monde, y compris en France où elle n’a été légalisée qu’en 1999.
Avant cette date, les tailles de clefs utilisées devaient être cassables facilement par l’État et celles non cassables n’avaient pas le droit d’être exportées.
SSL/TLS a du coup implémenté un mode EXPORT, qui réduit volontairement la taille des clefs à 40 et 56 bits, et qui permettaient ainsi d’utiliser et d’exporter en toute légalité un logiciel embarquant du SSL/TLS.
Ce mode est malheureusement toujours existant par défaut, et certaines failles
([FREAK](https://fr.wikipedia.org/wiki/FREAK_(faille_informatique)))tbt cherchent à tromper le visiteur pour le faire tomber sur ce mode, qui est bien évidemment beaucoup plus facile à casser que le mode standard à 128 ou 256 bits…
Ce mode EXPORT doit donc bien évidemment être désactivé.

## Intégrité des données

L’intégrité des données est basée soit sur HMAC, soit sur AEAD.

Dans le cas de HMAC, il faut choisir une
[fonction de hachage](https://fr.wikipedia.org/wiki/Fonction_de_hachage_cryptographique) parmi : 

**[MD5](https://fr.wikipedia.org/wiki/MD5)**, sur 128 bits, dont on connaît aujourd’hui des moyens plus ou moins efficaces de le casser.
 
**[SHA-1](https://fr.wikipedia.org/wiki/SHA-1)**, sur 160 bits, qui commence à montrer ses premiers signes de faiblesse.
Microsoft et Google ont d’ailleurs annoncé en 2013 sa dépréciation prochaine (utilisable jusqu’à fin 2016).

**[SHA-2](https://en.wikipedia.org/wiki/SHA-2)** sur 256 ou 384 bits, actuellement considéré comme sûr.
Malheureusement SHA-2 nécessite le support de TLSv1.2, qui n’est pas encore disponible partout.

Le choix à faire est donc simple :

  * AEAD et SHA-2 sans soucis. 
  * SHA-1 en attendant un meilleur support de TLSv1.2.
  * MD5 non merci.

## Perfect Forward Secrecy

On a vu un peu plus haut que le but de TLS est de négocier un secret partagé et de le transmettre sur un lien non fiable.

Le lien étant non fiable, une fois ce secret calculé par un des bouts de la connexion TLS, il faut l’envoyer à l’autre bout de manière chiffrée, sous peine de voir un éventuel attaquant mettre la main dessus et ainsi avoir la capacité de lire l’intégralité de la communication chiffrée qui va avoir lieu par la suite.

Certains algorithmes de négociation vont envoyer ce secret chiffré avec la clef publique de la partie en face.
En soi, cela ne pose pas de soucis, étant donné que seul celui en face possède la clef privée associée à cette clef publique et peut donc déchiffrer le secret.
Le problème est que cette situation est vraie uniquement au moment de l’échange de clef, et plus forcément dans un futur proche ou éloigné.
La clef privée peut fuiter par la suite, par exemple suite à un bug ([HeartBleed](https://fr.wikipedia.org/wiki/Heartbleed)), au décommissionnement du serveur (disque dur jeté sans précaution et récupéré par un attaquant) ou suite à une erreur de manipulation (publication de la clef par erreur).
Un attaquant qui aurait intercepté toutes les communications (chiffrées) et les aurait stockées quelque part peut alors ressortir ses archives, déchiffrer chaque paquet d’échange du secret et avoir ainsi accès en clair à tout le reste des communications auparavant chiffrées…

Pour se protéger de cette faiblesse, TLS propose un mode d’échange de clef, basé sur un échange de clef de [Diffie-Hellman](https://fr.wikipedia.org/wiki/Échange_de_clés_Diffie-Hellman) qui ne nécessite pas de transférer le
 secret sur le canal de communication.
 Via la magie des mathématiques, on est alors capable de se mettre d’accord sur un secret partagé sans jamais s’échanger ce secret.
Avec ce mode d’échange, la bi-clef du cas précédent ne sert plus qu’à assurer l’authentification des parties en présence et plus à s’échanger le secret.
Si une des clefs privées est compromise dans le futur, un attaquant n’a plus moyen de déchiffrer ce qui est en train de s’échanger, même s’il avait enregistré tout l’historique de communication.
C’est la confidentialité persistante (ou Perfect Forward Secrecy en anglais).

Il existe 2 algorithmes permettant un échange de Diffie-Hellman et donc la PFS :
 
**EDH** (Ephemeral Diffie-Hellman), basé sur RSA (factorisation en nombres premiers).

**ECDHE** (Elliptic Curve Diffie-Hellman Exchange), basé sur ECDSA (géométrie sur des courbes elliptiques).

Comme pour l’algorithme d’authentification, les 2 solutions sont considérés comme fiables à l’heure actuelle, avec la même préférence pour ECDHE qui permet une meilleure protection pour une taille de clef et une consommation de temps de
 calcul plus faible.
À noter cependant que de plus en plus de vulnérabilités apparaissent sur EDH, par exemple [Logjam](https://en.wikipedia.org/wiki/Logjam_(computer_security)) (exploitant aussi la faille du mode EXPORT) ou [RSA-CRT](https://securityblog.redhat.com/2015/09/02/factoring-rsa-keys-with-tls-perfect-forward-secrecy/), lié à des défauts de configuration des serveurs plus qu’à une faille du protocole.

# Configuration de OpenSSL

Maintenant qu’on a posé une vue d’ensemble des possibilités de TLS, passons à la partie beaucoup plus complexe : configurer correctement OpenSSL pour refermer les vulnérabilités vues précédemment.

## Protocoles supportés

On doit désactiver le support de SSLv2 et SSLv3.

Il n’y a pas de recette magique et il faut se référer à la documentation de votre logiciel serveur.
Sur Apache, ceci peut être fait via la direction `SSLProtocol` :

    SSLProtocol +TLSv1.2 +TLSv1.1 +TLSv1 -SSLv3 -SSLv2

Si on souhaite refermer le plus possible la faille POODLE, on désactivera aussi TLSv1 et TLSv1.1, mais en excluant alors les clients qui ne supporteront pas encore ce mode (honte sur eux), c’est-à-dire Android < 4.4.2, Internet Explorer < 11 et Safari < 7.

    SSLProtocol +TLSv1.2 -TLSv1.1 -TLSv1 -SSLv3 -SSLv2

Personnellement, c’est la configuration actuelle de ce serveur web.

## Suites de chiffrement

Par défaut, OpenSSL 1.0.1k gère [111 chiffrements](https://www.openssl.org/docs/manmaster/apps/ciphers.html), incluant toutes sortes de choses, de NULL à PSK en passant par ECDHE ou RC4.
Quasiment toutes les combinaisons existantes y sont possibles, y compris les plus faibles.
Par défaut (DEFAULT), ils sont quand même sympa et désactivent NULL, ADH/AECDH (anonymous) et le mode EXPORT.

Pour limiter les suites de chiffrement de OpenSSL, 2 possibilités existent :

  * Lister explicitement les suites supportées
  * Partir d’une liste étendue (généralement DEFAULT ou ALL) et en exclure les suites faibles

Les 2 méthodes ont leurs avantages et inconvénients :
 
  * Par la méthode explicite, la mise-à-jour de OpenSSL ne pourra pas introduire de nouvelles suites vulnérables, mais ne pourra pas non plus faire automatiquement profiter des nouvelles suites plus sécurisées.
  * Par la méthode d’exclusion, c’est l’inverse, on profitera automatiquement des nouvelles suites fiables mais potentiellement une suite cassée pourrait refaire son entrée (faux négatif à l’exclusion).

Commençons par exclure toutes les suites vraiment connues pour être cassées, à savoir DSS, PSK & SRP pour l’authentification, 3DES, RC4, DES, IDEA, RC2 & NULL pour le chiffrement et MD5 pour l’intégrité.
On ne souhaite aussi conserver que les versions supportant PFS.
Il ne reste déjà plus que 21 suites survivantes :

    openssl ciphers 'ECDHE:EDH:!DSS:!PSK:!SRP:!3DES:!RC4:!DES:!IDEA:!RC2:!NULL'

    DHE-RSA-AES128-GCM-SHA256 DHE-RSA-AES128-SHA DHE-RSA-AES128-SHA256
    DHE-RSA-AES256-GCM-SHA384 DHE-RSA-AES256-SHA DHE-RSA-AES256-SHA256
    DHE-RSA-CAMELLIA128-SHA
    DHE-RSA-CAMELLIA256-SHA
    DHE-RSA-SEED-SHA
    ECDHE-ECDSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES128-SHA ECDHE-ECDSA-AES128-SHA256
    ECDHE-ECDSA-AES256-GCM-SHA384 ECDHE-ECDSA-AES256-SHA ECDHE-ECDSA-AES256-SHA384
    ECDHE-RSA-AES128-GCM-SHA256 ECDHE-RSA-AES128-SHA ECDHE-RSA-AES128-SHA256
    ECDHE-RSA-AES256-GCM-SHA384 ECDHE-RSA-AES256-SHA ECDHE-RSA-AES256-SHA384

Pour ceux souhaitant lister de manière explicite ces suites de manière plus compacte, on peut remarquer qu’il ne reste que de l’AES (DHE et ECDHE), du SEED et du CAMELLIA (DHE uniquement), on peut donc (actuellement) résumer la suite en :

    openssl ciphers 'EECDH+AES:EDH+aRSA+AES:EDH+aRSA+CAMELLIA:EDH+aRSA+SEED'

CAMELLIA et SEED n’étant que très peu supportées par les navigateurs (ni Firefox ni Internet Explorer ni Safari ne les supportent), on peut se limiter à uniquement du AES, ce qui donne 18 suites survivantes :
 
    openssl ciphers 'EECDH+AES:EDH+AES+aRSA'

    DHE-RSA-AES128-GCM-SHA256 DHE-RSA-AES128-SHA DHE-RSA-AES128-SHA256
    DHE-RSA-AES256-GCM-SHA384 DHE-RSA-AES256-SHA DHE-RSA-AES256-SHA256
    ECDHE-ECDSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES128-SHA ECDHE-ECDSA-AES128-SHA256
    ECDHE-ECDSA-AES256-GCM-SHA384 ECDHE-ECDSA-AES256-SHA ECDHE-ECDSA-AES256-SHA384
    ECDHE-RSA-AES128-GCM-SHA256 ECDHE-RSA-AES128-SHA ECDHE-RSA-AES128-SHA256
    ECDHE-RSA-AES256-GCM-SHA384 ECDHE-RSA-AES256-SHA ECDHE-RSA-AES256-SHA384

Si on souhaite en plus se limiter à ECDHE afin d’éviter les problèmes potentiels de EDH, il n’en reste plus que 12 :

    openssl ciphers 'EECDH+AES'

    ECDHE-ECDSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES128-SHA ECDHE-ECDSA-AES128-SHA256
    ECDHE-ECDSA-AES256-GCM-SHA384 ECDHE-ECDSA-AES256-SHA ECDHE-ECDSA-AES256-SHA384
    ECDHE-RSA-AES128-GCM-SHA256 ECDHE-RSA-AES128-SHA ECDHE-RSA-AES128-SHA256
    ECDHE-RSA-AES256-GCM-SHA384 ECDHE-RSA-AES256-SHA ECDHE-RSA-AES256-SHA384

À noter qu’en pratique, vous supporterez DHE/ECDHE-RSA **OU** ECDHE-ECDSA, fonction de la clef publique de votre certificat.
Si vous utilisez une clef RSA, vous êtes obligatoirement en ECDHE-RSA ou DHE-RSA, si vous utilisez une courbe elliptique ça sera automatiquement ECDHE-ECDSA.
Une machine correctement configurée ne supporte donc en réalité que 6 (ECDHE uniquement) à 10 (ECDHE & DHE) suites.

Lorsque SHA-1 sera définitivement déprécié d’ici à fin 2016, on devra alors le retirer, ce qui ne laissera plus que 12 suites disponibles :

    openssl ciphers 'EECDH+AES:EDH+AES+aRSA:!SHA'

    DHE-RSA-AES128-GCM-SHA256 DHE-RSA-AES128-SHA256
    DHE-RSA-AES256-GCM-SHA384 DHE-RSA-AES256-SHA256
    ECDHE-ECDSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES128-SHA256
    ECDHE-ECDSA-AES256-GCM-SHA384 ECDHE-ECDSA-AES256-SHA384
    ECDHE-RSA-AES128-GCM-SHA256 ECDHE-RSA-AES128-SHA256
    ECDHE-RSA-AES256-GCM-SHA384 ECDHE-RSA-AES256-SHA384

Cette configuration n’est pour le moment pas réellement utilisable, car certaines applications ne supportent pas autre chose que du SHA-1 (par exemple [DAVDroid](https://davdroid.bitfire.at/) ou [Mustard](http://mustard.macno.org/)).

Quand ça sera au tour de CBC de tomber (POODLE et companie), il n’en restera plus que 6 : 

    openssl ciphers 'EECDH+AESGCM:EDH+AESGCM+aRSA:!SHA'
    
    DHE-RSA-AES128-GCM-SHA256 DHE-RSA-AES256-GCM-SHA384
    ECDHE-ECDSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES256-GCM-SHA384
    ECDHE-RSA-AES128-GCM-SHA256 ECDHE-RSA-AES256-GCM-SHA384

C’est encore moins utilisable que sans SHA-1, la très grosse majorité des clients en dehors des navigateurs standards dans leur version la plus récente ne supportant pas SHA-2.
C’est pourtant actuellement la seule configuration permettant de fermer définitivement les vulnérabilités connues du moment et la faille POODLE en particulier.

Pour Apache, la directive de configuration est `SSLCipherSuite` et la configuration actuelle de ce serveur web est « AES & ECDHE, AES128 d’abord, AES256 ensuite et les suites en SHA-1 à la fin » 

    SSLCipherSuite EECDH+AES:+AES128:+AES256:+SHA

Ce qui donne en liste exhaustive :

    ECDHE-RSA-AES128-GCM-SHA256 ECDHE-ECDSA-AES128-GCM-SHA256
    ECDHE-RSA-AES128-SHA256 ECDHE-ECDSA-AES128-SHA256
    ECDHE-RSA-AES256-GCM-SHA384 ECDHE-ECDSA-AES256-GCM-SHA384
    ECDHE-RSA-AES256-SHA384 ECDHE-ECDSA-AES256-SHA384
    ECDHE-RSA-AES128-SHA ECDHE-ECDSA-AES128-SHA
    ECDHE-RSA-AES256-SHA ECDHE-ECDSA-AES256-SHA

N’ayant actuellement pas de certificat ECC mais uniquement RSA, je ne propose donc à mes visiteurs que :

    ECDHE-RSA-AES128-GCM-SHA256 ECDHE-RSA-AES128-SHA256
    ECDHE-RSA-AES256-GCM-SHA384 ECDHE-RSA-AES256-SHA384
    ECDHE-RSA-AES128-SHA ECDHE-RSA-AES256-SHA

L’ordre des suites est important, puisque c’est la suite commune entre le client et le serveur située au rang le plus élevée qui sera sélectionnée.
Il vaut donc mieux mettre en tête de liste les suites les plus fortes.
Une subtilité de TLS fait que c’est l’ordre du client qui fait foi par défaut, s’il supporte une suite plus faible mais de priorité plus élevée, c’est celle-ci qui sera utilisée.
Il est possible de signaler à OpenSSL de forcer à utiliser la priorité du serveur, via la directive Apache
 ```SSLHonorCipherOrder on``` par exemple.

## Paramètres de Diffie-Hellman

Lors de l’échange de Diffie-Hellman, le serveur va devoir générer et utiliser des clefs de session temporaires.
Ces clefs, si elles sont trop faibles, peuvent aussi compromettre la sécurité de la communication.
C’est par exemple le cas avec la vulnérabilité Logjam.

On peut forcer la main au serveur et lui imposer d’utiliser certains paramètres ou taille de paramètres.

Dans le cas de DHE (RSA), il faut générer des paramètres statiques de taille suffisamment importante (au moins 2048 bits, voire 4096) avec `openssl dhparam 4096 -out /etc/ssl/private/dh4096.pem` puis indiquer ce fichier à votre serveur web, via la directive `SSLCertificateFile /etc/ssl/private/dh4096.pem` pour Apache par exemple.

Pour ECDHE (ECDSA), il faut indiquer à OpenSSL d’utiliser des courbes elliptiques plus robustes (par défaut 256 bits) pour la génération de ses clefs de session, avec la directive Apache `SSLOpenSSLConfCmd Curves sect571r1:secp521r1:secp384r1` par exemple (nécéssite au minimum Apache 2.4.16 et
 OpenSSL 1.0.2 donc pas encore disponible sous Debian Jessie !).

## Test de la configuration

On peut utiliser des outils comme mon [CryptCheck](https://tls.imirhil.fr/) ou
 [SSLLabs](https://www.ssllabs.com/ssltest/index.html) pour faire des tests en ligne et voir si la configuration de sa machine est correcte.

Il existe aussi des outils en ligne de commande qui permettent de tester plus rapidement et plus souvent sa configuration, ce qui est pratique lors de sa mise-au-point.
On peut citer [CryptCheck](https://github.com/aeris/cryptcheck) à nouveau, ou [SSLScan](https://github.com/rbsec/sslscan).

En tant que gentil extrémiste, la configuration de mes serveurs est en mode Ayatollah paranoïaque :
 [HTTPS](https://tls.imirhil.fr/https/imirhil.fr) & [XMPP](https://tls.imirhil.fr/xmpp/imirhil.fr):)

# Pourquoi TLS est si mal déployé actuellement

Vu ce qui est présenté ci-dessus, on pourrait se dire qu’il n’est pas si compliqué que ça de déployer correctement une configuration TLS en production, et d’être relativement à l’abri des problèmes de sécurité.
[La preuve, les geeks y arrivent très bien](https://imirhil.fr/tls/#Serveurs%20personnels).

Pourtant, si on parcourt les sites [des banques](https://imirhil.fr/tls/#Banques%20en%20ligne), [des assurances](https://imirhil.fr/tls/#Assurances), [des administrations](https://imirhil.fr/tls/#Administration), [des sites de commerce en ligne](https://imirhil.fr/tls/#Sites%20de%20commerce%20en%20ligne), [des syndicats](https://imirhil.fr/tls/syndicats.html), [des sites de porn](https://imirhil.fr/tls/porn.html) ou même [des 100 plus gros sites du monde](https://imirhil.fr/tls/alexa.html), on se rend compte que la réalité est assez cinglante…
La très grosse majorité des sites précédents supportent SSLv3 alors qu’il est obsolète depuis des décénnies et déprécié depuis 1 an.
Quasiment tous supportent RC4 ou 3DES, respectivement troué et en passe de l’être.
À l’inverse, quasiment personne ne supporte TLSv1.2 qui existe pourtant depuis plus de 7 ans.

Le cas des banques est particulièrement dramatique, avec 65% du parc à supporter RC4, 15% SSLv3, et 44% à ne pas supporter TLSv1.2, malgré la criticité d’un tel service et le niveau de sécurité attendu par un client…
Une seule banque (ING Direct) sur la cinquantaine testée possède actuellement un niveau de sécurité globalement compatible avec les exigences de sécurité minimales demandées par l’ANSSI, toutes les autres n’étant pas conformes à
 l’état de l’art actuel.

Cette situation catastrophique s’explique par plusieurs choses.

D’abord (et je pense que c’est l’essentiel du problème), **la dette technique accumulée**.\\
Le parc informatique actuel est malheureusement encore rempli de poubelles ambulantes un peu partout, avec des personnes tournant encore sous Internet Explorer 6 et Windows XP, malgré la fin du support de la part de Microsoft et la
 dangerosité à utiliser un tel système troué.
Ces épaves peuvent même être internes aux banques par exemple, avec l’obligation d’utiliser du matériel « matricé » obsolète (c’est généralement le cas en entreprise), par souci de compatibilité avec de vieilles applications métier,
 ou encore par impossibilité de la migration (cas des distributeurs automatique de billet qui tournent sous Windows XP et ne sont pas remplaçables facilement ni rapidement).  
Parce que le marketing ne veut pas se mettre à dos ce pourcentage d’utilisateurs, ou que le support ne veut pas voir sa hotline exploser en vol et aussi parce que tout le monde refuse de parler technique avec des clients, on préfère laisser
 les suites de chiffrement moisies actives, pour ne pas exclure ces zombies qui ne mériteraient pourtant que d’être mis en orbite à coup de missile nucléaire.

Ensuite, c’est aussi parfois dû à **des contraintes techniques**.\\
Faire du chiffrement, ça a un coût en termes de ressources informatiques, avec du temps de calcul supplémentaire nécessaire, des problématiques de gestion des caches (si c’est chiffré, vous ne pouvez plus rien mettre en cache !)…
La plupart des gros déploiements de TLS passe par des terminaisons TLS matérielles, de grosses machines physiques dédiées uniquement au chiffrement/déchiffrement des données.
Par exemple, des [BIG-IP de chez F5](https://support.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/ltm_configuration_guide_10_0_0/ltm_ssl_profiles.html) ou encore du [FortiADC de chez Fortinet](http://help.fortinet.com/fadc/3-0-0/olh/index.html#page/FortiADC_Handbook/offloading_vs_inspection.html).
Pour des raisons de performance, le chiffrement est fait matériellement et non pas logiciellement, ou en tout cas par du logiciel très différent de ceux utilisés classiquement.
Ce matériel se met à jour beaucoup plus difficilement que du logiciel classique, une correction de bug dans une implémentation TLS pouvant aller jusqu’à devoir jeter les anciennes cartes électroniques pour les remplacer par des
 neuves, ce qui a un coût non négligeable et demande de toute façon un délai bien plus long pour voir apparaître le correctif sur le marché (redesign de la carte, re-fabrication…).
Du coup, ces solutions sont en permanence en retard de plusieurs années sur l’état de l’art courant.
Par exemple F5 n’a supporté TLSv1.2 que dans
 [sa version 10.2.3 en date du 15/10/2013](https://support.f5.com/kb/en-us/products/big-ip_ltm/releasenotes/product/relnotes-LTM-10-2-3.html), alors que OpenSSL l’a supporté dès [sa version 1.0.1 en date du 14/03/2012](https://www.openssl.org/news/changelog.html#x18),
 soit 18 mois plus tôt.

Enfin, parce que comme vu au-dessus, **SSL/TLS « c’est compliqué »**.\\
Du coup, il faut passer du temps pour se former, à tester, à comprendre, à tâtonner.
Il faut passer sa vie à faire un compromis entre sécurité et utilisabilité (ne pas exclure trop de clients).
Il faut se battre pour faire comprendre aux manageurs et autres responsables pourquoi la configuration TLS c’est important et pourquoi il faut investir dessus, alors que pour le pékin moyen, « si vous avez un cadenas et une barre
 verte, c’est sécurisé » ([voire sans en fait](https://tpeweb.paybox.com/images/page_paiement/E-Transactions_Info_securite_SSL.pdf)…).
Et du coup, on est mis sur autre chose, « ce n’est pas la priorité », « pourtant ça marche bien là » ou autre « on verra ça plus tard » fait que la sécurité passe au second plan et n’est pas considérée comme importante, y compris dans des milieux aussi critique que le bancaire…

# Le futur de TLS

[TLSv1.3](https://tools.ietf.org/html/draft-ietf-tls-tls13-07) est en cours de normalisation et devrait arriver « prochainement ».
Il est censé apporté de nouvelles sécurités pour bloquer les failles vues prochainement et surtout faire un gros ménage dans les suites de chiffrement autorisées (bye bye RC4 !).
Le même problème que celui de TLSv1.2 actuel risque cependant de se reproduire, avec une longue traîne de TLSv1.2 en attendant un meilleur support de TLSv1.3 par les clients.
Des réfléxions ont eu lieu, réclamant de la « brutal security », ie. arrêter de mettre l’intégralité de la population en danger pour s’épargner le mécontentement ou l’exclusion de 1% des visiteurs…

Côté chiffrement, de nouvelles suites sont très attendues.
La plus urgente devient [CHACHA20+POLY1305](https://tools.ietf.org/html/draft-agl-tls-chacha20poly1305-01) puisque AES reste le seul chiffrement fiable actuellement et qu’une faille qui le toucherait serait catastrophique étant donné qu’on n’a aucune solution de repli.
CHACHA20+POLY1305 a aussi énormément d’intérêt, parce que très rapide et peu gourmand en calcul, mais aussi parce qu’il permettrait de faire taire définitivement la suspicion qui plane sur AES, algorithme issu d’un concours NIST et adoubé par la NSA.

On attend aussi avec impatience le support de la courbe elliptique [ED25519](https://fr.wikipedia.org/wiki/EdDSA), qui permettrait aussi de se passer des actuelles courbes NIST-P et dont la fiabilité mathématique n’est actuellement
 [pas démontrable](http://safecurves.cr.yp.to/) (certains paramètres semblent sorti du chapeau et pourraient avoir été choisis pour volontairement affaiblir les algorithmes et ainsi faciliter leur cryptanalyse par la NSA).
