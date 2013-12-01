Title: Manuel du parfait petit crypto-anarchiste (2/3)
Date: 2013-09-06
Category: crypto
Tags: gpg, ssl

Après cette introduction théorique à la crypto-anarchie, passons un peu à la pratique, avec les différents outils utilisables par le commun des mortels avec un peu de bonne volonté.

# Constats généraux
## Logiciel privateur / logiciel libre

Ceci sera sûrement **LE** point le plus difficile à faire passer.<br/>
**Il est impossible d'être en sécurité avec du [logiciel privateur](https://fr.wikipedia.org/wiki/Logiciel_propriétaire)**, comme par exemple Windows, Skype, Apple…

N'ayant pas accès au code-source desdits logiciels, on ne peut pas savoir ce qu'ils contiennent ni comment ils fonctionnent.
Peut-être contiennent-ils [une clef mystérieuse](https://fr.wikipedia.org/wiki/NSAKEY), ou encore [font de l'espionnage pour le compte de gouvernements étrangers](http://www.pcinpact.com/news/78112-skype-pris-en-flagrant-deli-despionnage-conversations-en-chine.htm).<br/>
Si vous voulez être en sécurité, il faut utiliser exclusivement du [logiciel libre](https://fr.wikipedia.org/wiki/Logiciel_libre) (GNU/Linux, Firefox…), qui vous garantit l'accès à son code-source et à son comportement.

## Logiciel en tant que service / auto-hébergement

**Il est tout aussi impossible d'être en sécurité avec du [logiciel en tant que service](https://fr.wikipedia.org/wiki/Logiciel_en_tant_que_service)** (SaaS ou encore « cloud »).

Vous n'avez aucun contrôle sur où et comment sont stockées vos données, qui est derrière votre prestataire et s'il a des arrangements avec les fameuses entités gouvernementales à trois lettres.
Exit donc Google, LiveMail, Facebook, Twitter et tout le reste.

[Hébergez](https://fr.wikipedia.org/wiki/Auto-hébergement_(Internet)) au maximum vos propres services sur vos propres machines. Ce n'est généralement pas aussi compliqué que ça en a l'air.<br/>
(À ce sujet, je vous recommande l'incontournable vidéo de notre incontournable [Benjamin Bayard](https://fr.wikipedia.org/wiki/Benjamin_Bayart), [Internet Libre ou Minitel 2.0](http://www.fdn.fr/Internet-Libre-ou-Minitel-2,94.html).)

## Sécurité physique

Ça peut être évident mais ça ira mieux en le disant : une bonne sécurité, c'est avant tout une bonne sécurité physique de nos machines.<br/>
Comme on le verra par la suite, beaucoup de systèmes de sécurité ont besoin de stocker, en plus des données elles-mêmes, des clefs de chiffrement. Si ces clefs tombent entre de mauvaises mains, c'est tout le système associé qui est compromis.

Premier effort à faire : la **gestion des mots de passe**. « toto », « 0000 » ou la date de naissance du petit dernier ne sont pas de bons mots de passe.
Il faut préférer utiliser soit des mots de passe suffisamment longs et complexes (« 3ppWc18P4o23qGzsvj9,h7tgB1kX2Q2+ ») soit une combinaison de noms communs (« lower public happy wild »). Le but est d'avoir un mot de passe complexe mais retenable, [ce qui n'est pas évident](https://xkcd.com/936/).<br/>
Évitez aussi d'utiliser toujours le même mot de passe partout. S'il venait à être découvert, c'est l'intégralité de votre système qui serait compromis, et non uniquement une partie limitée.<br/>
On peut aussi essayer d'utiliser le plus possible des systèmes d'authentification forte, qui deviennent de plus en plus abordables pour le grand public.
Une [Yubikey](http://www.yubico.com/products/yubikey-hardware/yubikey/) coûte moins de 20€ et un [OTP-OATH](http://www.gooze.eu/otp-c200-token-time-based-h3-casing-1-unit) moins de 10€.
Ces produits remplacent les mots de passe classiques par des mots de passe à usage unique générés automatiquement. Même s'ils s'égarent dans la nature, ils ne sont valables qu'un temps donné et ne sont pas rejouables (un mot de passe utilisé n'est plus réutilisable).
Malheureusement trop peu de logiciels sont compatibles avec ces systèmes d'authentification.

Ensuite, *c.f.* aparté 1, non, un Windows (même mis à jour tous les matins au réveil), ce n'est pas sécurisé.
Merci donc d'**installer une distribution GNU/Linux** digne de ce nom, au pif une [Debian](http://www.debian.org/index.fr.html). Là on est déjà sur du <strike>plus</strike> sécurisé.

Ensuite, il faut **chiffrer les disques durs** de la machine, de sorte que quelqu'un qui y aurait accès (au pif saisie de la justice, cambrioleur du coin, portable égaré, gamin du voisin, chat qui passe par là…) ne puisse y lire qu'un gros tas de bits tout bien aléatoires comme il faut, au lieu des vraies données.
<center>
![DPI](/static/images/20130901/cipher.png)<br/>
(Crédits image : [Wikipedia](https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation))
</center>

Les distributions GNU/Linux sont généralement fournies avec un outil tout prêt pour faire ça, [CryptSetup/LUKS/dm-crypt](https://code.google.com/p/cryptsetup/) (le premier qui m'explique qui est qui ou qui est le bon nom, il gagne un bisou).
L'installeur Debian permet de chiffrer les disques à l'installation (c'est pas vraiment super intuitif, peut-être ferais-je un tutoriel par la suite sur le sujet).<br/>
<strike>Si vous êtes vraiment parano,</strike> vous pouvez pousser le vice jusqu'à demander un remplissage intégrale du disque avec des données totalement aléatoires avant le chiffrement, histoire d'être sûr de ne plus rien avoir dessus de franchement lisible facilement (nos experts judiciaires ont cependant toujours moyen de lire les données précédentes avec le matériel adéquat). Comptez *juste* une bonne grosse journée pour 500Go :D.<br/>
Niveau sécurité du chiffrement, on a accès à la crème de la crème, [AES](https://fr.wikipedia.org/wiki/Advanced_Encryption_Standard), [Serpent](https://fr.wikipedia.org/wiki/Serpent_(cryptographie)) et [Twofish](https://fr.wikipedia.org/wiki/Twofish). Paraitrait que la NSA utilise AES pour ses informations top secrètes et que [le FBI s'est cassé les dents dessus pendant un an](http://g1.globo.com/English/noticia/2010/06/not-even-fbi-can-de-crypt-files-daniel-dantas.html).<br/>
Un petit chiffrement AES avec une clef de 256bits et des hashs en [SHA256](https://fr.wikipedia.org/wiki/SHA-2) est bien suffisant pour une sécurité personnelle sans pour autant réduire trop les performances de lecture/écriture sur le disque.

Une fois le système installé, pensez à **configurer un bon pare-feu**. Pas le pare-feu Windows qui laisse passer tout ce qu'il ne devrait pas et bloque tout ce qu'on aimerait qu'il laisse passer. Un bon pare-feu bien robuste basé sur [iptables](https://fr.wikipedia.org/wiki/Iptables).<br/>
Et un bon pare-feu est un pare-feu qui interdit tout par défaut et qui autorise uniquement ce qui doit l'être, quitte à devoir le reconfigurer de temps en temps pour être plus permissif.
Mieux vaut le modifier deux fois dans l'année que d'être troué autant.<br/>
Un bon pare-feu évitera un accès frauduleux à votre machine par le réseau. C'est aussi pour ça qu'il faut **mettre à jour régulièrement le système**, pour limiter au maximum les failles de sécurité qui pourraient être exploitées pour accéder à la machine.

# Sécurité des échanges (SSL/TLS)

Alors là, vaste chantier en perspective… Très vaste chantier…

Quand vous naviguez sur le web, les données que vous envoyez ou que vous recevez sur le réseau circulent en clair.
Par exemple si je demande la page de [DuckDuckGo](https://duckduckgo.com/) :

	GET / HTTP/1.1
	Host: duckduckgo.com
	User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0 Iceweasel/24.0

	HTTP/1.1 301 Moved Permanently
	Location: https://duckduckgo.com/
	<html>
	<head><title>301 Moved Permanently</title></head>
	<body bgcolor="white">
	<center><h1>301 Moved Permanently</h1></center>
	<hr><center>nginx</center>
	</body>
	</html>

On voit ici que j'ai demandé la page */* de *duckduckgo.com* (soit *http://duckduckgo.com/*), en utilisant Iceweasel 24.0 sur un GNU/Linux 64bits.
Et que DuckDuckGo me répond gentiment que la page se trouve en réalité à *https://duckduckgo.com/* (notez bien le *s* de *https*, on va y arriver).<br/>
Tout est en clair, tout est lisible, n'importe qui qui se trouverait en mesure de regarder dans n'importe quel câble entre moi et le serveur de DuckDuckGo (je compte une petite douzaine de machines intermédiaires) sait parfaitement ce que je suis en train de faire sur Internet.
Bref, c'est pas utilisable, par exemple sur le site de ma banque si je veux pouvoir donner mon mot de passe tranquillement, ou si je veux publier des informations confidentielles.

**[SSL/TLS](https://fr.wikipedia.org/wiki/Transport_Layer_Security)** a été inventé pour chiffrer les communications.
Les deux machines, votre navigateur et le serveur en face, échangent quelques messages pour se mettre d'accord sur une clef de chiffrement, et ce de manière sécurisée même si quelqu'un écoutait sur la ligne.<br/>
TLS garantit donc que seuls les deux correspondants sont capables de lire les données qui sont échangées, quelque soit l'état de la sécurité de la ligne entre les deux. C'est le fameux *https*, au lieu du *http* qui lui est non sécurisé.

Et les banques et autres sites de commerce en ligne sont arrivés… Et là, ce fut le drame…<br/>
Comme dit au-dessus, TLS ne garantit que et uniquement que la sécurité de la communication.
Les sites d'e-commerce ont besoin en prime d'assurer autre chose : que le serveur en face est bien celui qu'il prétend être.
En effet, il est peu conseillé de donner son code de carte bleue, même sur un canal sécurisé, si on n'est pas sûr de la personne qu'on a en face.
Ils ont donc inventé ce qui allait devenir une infâmie sans nom, une hérésie digne d'un bon bûcherpe : [les autorités de certification](https://fr.wikipedia.org/wiki/Autorité_de_certification), ou CA…

Avant les CA, un visiteur qui visitait pour la première fois un site sécurisé… ne voyait rien de particulier. Sinon un *https* dans sa barre des taches. Ce qui signifie que le site est protégé. Mais qui est le propriétaire de la machine en face ? Votre banque ? Ou un pirate ?<br/>
Les CA sont donc des entités qui délivrent des certificats qui garantissent que le propriétaire du site est bien celui qu'il prétend être.
Vous ne pourrez donc pas réclamer un certificat pour *duckduckgo.com* si vous ne pouvez pas apporter la preuve que vous agissez bien au nom de DuckDuckGo.<br/>
Afin d'alerter le visiteur, les navigateurs se sont mis à embarquer une liste des autorités habilitées à attribuer des certificats, et affichent une page d'alerte si quelque chose va mal. Comme par exemple quand le site utilise un certificat non issu d'une autorité, que le certificat ne correspond pas au nom de domaine du site, etc.
<center>![DPI](/static/images/20130901/ssl-alert.png)</center>

Au passage, les sites de commerce en ligne ou les banques ont joué un énorme tour à leurs clients.<br/>
Le système TLS n'affiche pas d'erreur, une barre d'adresse verte et un cadenas si les conditions suivantes sont réunies :

  * le certificat du site est issu d'une CA
  * la CA correspond à une CA embarquée dans le navigateur
  * le nom de domaine du certificat correspond au nom de domaine visité

Oh wait ! Où est-ce indiqué que le serveur en face est bien celui de ma banque ???
La réponse est très simple : nul part !<br/>
**Tout** certificat signé par une CA embarquée dans un navigateur est 100% valide, affichera une barre verte et un cadenas, et ce sans aucune erreur. Indépendamment de si la personne en face est bel et bien celle qu'elle prétend.<br/>
Le **gros** problème, c'est qu'aujourd'hui, on compte pas moins de 160 CA incluses dans Firefox. Et on y trouve de tout et de n'importe quoi.
De choses relativement sûre comme [Verisign](https://www.verisign.fr/) (même s'ils ont merdé [eux-aussi](http://support.microsoft.com/kb/293811)), en passant par des trucs beaucoup plus moyens comme [RapidSSL](https://www.rapidssl.com/), voire des trucs complètement fuités comme Diginotar. On trouve aussi des trucs franchement délirants, comme des sociétés privées (Microsoft, OVH, Gandi, Dell…), voire carrément des gouvernements (Chine, Tunisie…).<br/>
Bref, il doit bien y avoir la moitié de la planète à pouvoir émettre des certificats. Et on compte de plus en plus de [magouilles](http://reflets.info/microsoft-et-ben-ali-wikileaks-confirme-les-soupcons-d-une-aide-pour-la-surveillance-des-citoyens-tunisiens/) ou de [disfonctionnements](http://www.zdnet.fr/actualites/piratee-l-autorite-de-certification-diginotar-est-en-faillite-39764136.htm).

Pour un usage courant (e-commerce, banque…), c'est déjà pas top, des pirates pouvant « facilement » récupérer des certificats frauduleux pour se faire passer pour votre banque ou votre site d'achats en ligne sans aucune alerte.<br/>
Pour un usage sécuritaire, on voit bien qu'on tombe dans un truc franchement glauque. La NSA pourrait très bien demander à une CA américaine de générer des certificats pour se faire passer pour des sites intéressants. Par exemple pour espionner les communications GMail, voir les visiteurs de [Wikileaks](http://wikileaks.org/) ('fin non, [lui n'est pas en SSL justement]()) ou autre espionnage.

Pour se protéger de ce risque, on peut utiliser des extensions comme [CertificatePatrol](http://patrol.psyced.org/) qui vous demandera de confirmer le certificat à la première connexion, puis vous alertera si le certificat change lors des visites suivantes.
C'est assez efficace pour les sites simples, mais c'est parfois problématique vu que le web est aujourd'hui une vraie déchèterie technique (pour les connaisseurs, ça coince sur les CDN/load-balancers qui servent X-milles certificats par minute et sur les sites débiles qui utilisent des terrachiés de sous-domaines voire domaines différents).<br/>
Pour les plus téméraires, vous pouvez aussi supprimer toutes les CA de votre navigateur, mais la web-déchèterie vous indiquera alors sûrement des bouzillions de messages d'erreur à chaque page…

Il existe aussi une initiative intéressante, [CACert](https://www.cacert.org/), une CA à taille humaine qui demande plusieurs rencontres physiques afin de valider votre identité, mais malheureusement toujours pas incluse par défaut certains navigateurs.
Un comble quand on connaît la qualité de certaines CA déjà intégrées…

Pour conclure sur SSL/TLS en quelques mots, vous *devez* vous en servir pour chiffrer vos propres communications avec vos propres machines.
Si possible avec une double authentification, histoire d'être sûr que le serveur est bien le serveur côté client et le client bien le client côté serveur. Et ainsi éviter de laisser des traces lisibles sur le net.<br/>
Mais vous *devez* aussi vous en méfier dès que vous ne maîtrisez plus l'autre côté du tuyau.
Les certificats auto-signés, les CA alternatives et les extensions de navigateur peuvent vous y aider.

# Sécurité des courriels (GnuPG)

Occupons-nous de l'envoi de courriel maintenant.
On l'a vu lors de [l'épisode 1](<|filename|/20130901-manuel-cryptoanarchiste-1.md>), envoyer un courriel à quelqu'un ne peut pas être fait de manière fiable.
On peut avoir du *man-in-the-middle*, de l'interception de paquets… En plus, le protocole le plus utilisé pour s'échanger des courriels, [SMTP](https://fr.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) circule ultra-majoritairement en clair. Et même avec un chiffrement SSL/TLS vu précédemment, on n'est pas à l'abris d'un problème.
Bref, la communication ne peut pas être considérée comme fiable et sécurisée.

Afin de quand même protéger ses communications, on peut utiliser **[GnuPG](https://fr.wikipedia.org/wiki/Gnupg)** (plus couramment nommé GPG).<br/>
GPG est basé sur la notion de [cryptographie asymétrique](https://fr.wikipedia.org/wiki/Cryptographie_asymétrique) et de clef publique/clef privée.

Au début du monde, vous générez une paire de clefs (de plus de 1024bits si on veut être en sécurité, 4096 étant pour le moment sûr pour les prochaines années).
Votre clef privée doit absolument être protégée par un mot de passe robuste.
Profitez-en pour générer un certificat de révocation, que vous prendrez soin de stocker dans un endroit sûr, au cas où vous perdriez votre clef privée ou son mot de passe.
Votre clef privée vous servira à signer vos courriels (garantissant votre identité à votre correspondant), tandis que votre clef publique servira à vos correspondants pour chiffrer les messages qui vous seront destinés.<br/>
Votre clef publique est comme son nom l'indique publique, vous pouvez donc sans risque la communiquer à n'importe qui, voire même la mettre en ligne (la mienne est par exemple disponible [ici](http://pgp.mit.edu:11371/pks/lookup?op=get&search=0xAF3342FC436383FD)).
Votre clef privée par contre, doit rester absolument confidentielle. Elle est stockée dans votre trousseau de clefs, sur votre disque dur. Il est donc impératif de vous être déjà occupé de la sécurité physique de votre machine, en particulier le chiffrement des disques durs et la robustesse des mots de passe utilisateurs.<br/>
Vous êtes maintenant capable de chiffrer vos courriels, et ainsi rendre vos communications privées, même via le protocole SMTP, non fiable, en clair et pas sécurisé.

Attention cependant, seul le corps du courriel est chiffré, pas les entêtes (qui sont nécessaires à SMTP).
En particulier, l'émetteur du courriel, son destinataire et son sujet sont visibles en clair.
**GPG ne permet donc pas la confidentialité de la communication.**<br/>
Un exemple de communication qu'une personne malveillante pourrait obtenir serait :

	:::text
	From: Félix Martin <felix.martin@example.org>
	To: Georges Bernard <georges.bernard@example.com>
	Subject: Des chatons dans un tuyau
	
	-----BEGIN PGP MESSAGE-----
	Version: GnuPG v1.4.14 (GNU/Linux)
	
	mfrHK7uM9q1+MbIDgcGA/g02hptlOI6fYq3m+LIrxAslnbY9rYVcJQWaXoX2JE1QRJVuRrXmRDt2
	3/rb/rG2F4gIsfr38H/rfz9LENHm/6Wut7W4f9UTGGEnMjcNnaT1JtwIcB2waGwoOtBEQQh5D266
	pwGojrz6w1Gk73EkKH1n3Crw6anSAaDsz+vGyc6ODNjNgRmCvuGJlp2sgTdNdAb0eRwDMM2Z0GsV
	yu1a0xezYXVXFkEWDtQnh/1KdwZ8TppKW9gf/n5LtYI1k8w8NVDwRnXZQWeDcfUd4JT7nHDX3ubn
	2XgvUiaPC6379lFaHTPuHApBQvDUBm0dtwHeVeWsk/QiPSKLs9diHEhoIaoP6wxjpLh9Pk/caT4T
	cYhHgMEknapnwRCMDcDJIe126BoYRya5jS0PdBA2XISAOsGi7+rPBbHZL75UhcuWCXO5JwIjM0tl
	wXqeGncIvn1M+LsiqP7hvPbCQ/+COioLS+Tq/SDmdY04ruwr1BsENvGiKPxIZN4T64n/IvnK0bvT
	UzMZ28VxYnL6+da92jGF0LuAoEW3G9FUUsQXEdbByxvLPcmDeA+F+RUg06oJ0KS7pyEFs6jQcvi/
	g/aC/i/vP2oERDiA+rvvMtU9S+1tyzI5S7pwZ7aW+NCEBjClG8W3e2TWpFr5GE9ap7sn6wbjAys=
	-----END PGP MESSAGE-----

Pas d'accès aux données proprement dites, mais suffisamment d'informations accessibles pour commencer à faire du recoupement…

Il reste un dernier problème à régler : comment s'assurer que notre destinataire est bien celui à qui je veux écrire ?
On ne veut pas refaire l'erreur de SSL avec des CA sorties d'on ne sait trop où.
On va alors se baser sur un principe qui ne paraît pas si débile que ça :

  * Mes amis sont mes amis (sic)
  * Les amis de mes amis sont mes amis

Votre clef publique, vous allez la faire signer par vos proches, et vous signerez la leurs en retour.
La signature de clef est une étape très importante pour garantir la confiance en le système.
Elle doit donc être effectuée suivant un protocole très strict :

  * Vous devez rencontrez physiquement la personne à qui vous allez signer la clef
  * Cette personne doit vous présenter une pièce d'identité valide (carte nationale d'identité, passeport, permis de conduire)
  * Cette personne doit vous fournir l'empreinte de sa clef, une suite de lettres et de chiffres qui identifie de manière unique sa clef (la mienne est *E68F BD17 EE19 4910 B057 F9D3 AF33 42FC 4363 83FD* par exemple)
  * Vous pouvez alors signer sa clef, signifiant que vous reconnaissez qu'il est bien la personne qu'il prétend être et qu'il possède bien cette clef

À tout moment, si vous pensez qu'il y a un problème, que vous vous sentez mal à l'air ou que vous avez le moindre doute sur le moindre point, même mineur, vous ne devez en aucun cas signer la clef.

Les signatures de clefs forment une chaîne de confiance (*web of trust* ou *WoT* en anglais).
Vous avez confiance en les personnes pour qui vous avez signer la clef, et par transitivité, en les personnes qui ont une clef signée par une personne en qui vous avez confiance.<br/>
La confiance reste toute relative, plus la signature est basse dans la chaîne, moins la confiance étant bonne, la confiance ultime étant une signature directe.

CACert fonctionne sur le même principe, mais pour SSL/TLS.
D'ailleurs si vous êtes intéressé et sur Paris ou ses environs, n'hésitez pas à me contacter pour des signatures GPG ou des accréditations CACert :).
Sinon, les rendez-vous hackers ([Pas Sage en Seine](http://www.passageenseine.org/), [Ubuntu Party](http://ubuntu-paris.org/), [Chaos Communication Camp](https://fr.wikipedia.org/wiki/Chaos_Communication_Camp)…) sont généralement l'occasion d'organiser au passage des *[key signing parties](https://fr.wikipedia.org/wiki/Key_signing_party)* et de faire signer ses clefs par plusieurs personnes simultanément.

Les courrielleurs les plus courants peuvent signer et chiffrer automatiquement vos envois.
[Kontact](https://fr.wikipedia.org/wiki/Kontact) intègre GPG nativement. [Thunderbird](https://www.mozilla.org/fr/thunderbird/) nécessite par contre l'extension [Enigmail](https://www.enigmail.net/home/index.php). Idem pour [Roundcube](http://roundcube.net/) avec [WebPG](http://www.webpg.org/).<br/>
Pensez aussi à chiffrer automatiquement votre courrier entrant si vos correspondants oublient de le faire.
[GPGIt](https://grepular.com/Automatically_Encrypting_all_Incoming_Email) permet de le faire pour la plupart des serveurs de courriels existants ([Postfix](http://www.postfix.org/), [Exim](http://www.exim.org/)…). Cela ne protège bien sûr pas d'une interception des messages non chiffrés lors de leur transport, mais au moins le stockage est fiable et les données non lisibles après réception.

*To be continued…*

*[Première partie](|filename|/20130901-manuel-cryptoanarchiste-1.md)*<br/>
*[Troisième partie](|filename|/20130906-manuel-cryptoanarchiste-3.md)*
