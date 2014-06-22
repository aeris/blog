Title: Parce que vous vous foutez de vos libertés, ce sont les miennes qui disparaissent
Date: 2014-06-22
Category: crypto
Tags: sécurité, confiance, ergonomie, liberté, centralisation

NSA, Snowden, Heartbleed, TrueCrypt… Ce début d'année est tellement riche en évènements cryptographiques que ça en devient presque difficile à suivre…
C'est surtout tout ce qui en a découlé qui est devenu très intéressant, de « [Everything is broken](https://medium.com/@quinnnorton/everything-is-broken-81e5f33a24e1) » par Quinn Norton en passant par « [Lettre aux barbus](http://reflets.info/lettre-aux-barbus/) » par Laurant Chemla (ainsi que [la réponse](http://blog.chown.me/reponse-a-la-lettre-aux-barbus.html) de Vigdis), ou encore « [OpenSSL Valhalla Rampage](http://opensslrampage.org/) » sur la
 vaste blague qu'est OpenSSL (je tiendrais d'ailleurs une conférence sur le sujet durant [PSES](http://www.passageenseine.org/Passage/PSES-2014))…

Toutes ces problématiques ont foutu un gros coup de pied au cul de tout le monde, réveillant toute lafourmillière, avec une gueule de bois comme elle n'en avait jamais connue auparavant.
On cumulait connerie sur connerie et personne n'avait rien vu. On exposait notre vie privée en 4 par 3 et ça n'avait choqué personne.

Je ne sais pour quelle raison, mais j'ai eu un déclic, un truc qui a fait tilt entre deux neurones : et si j'avais perdu ma sécurité parce que la majorité des gens se foutaient juste de la leur ? Et si tout ça, c'était uniquement du au fait que les gens n'en ont rien à faire de l'informatique ?

# L'informatique « facile », ou comment on a remis les clefs de nos maisons à d'illustres inconnus

Parce que ça doit être « simple à installer et à utiliser ». Parce qu'on vend l'informatique par pack de 12 au supermarché du coin. Parce que les beaux discours commerciaux et les plaquettes sur papier glacé recoivent plus d'attention de la part des futurs <strike>mougeons (le croisement d'un mouton
 et d'un pigeon)</strike> clients que les préconisations techniques minimales qu'on **devrait** maîtriser avant de mettre ses petits doigts potelés sur un clavier…<br/>
Pour beaucoup sinon l'extrême grosse majorité, l'informatique est vu comme un truc compliqué, mais qu'on se doit d'utiliser sans rien comprendre, à cliquer sur des boutons tout partout, mais sans rien réellement y piper au final.

À cause de ça, on ne compte plus les machines zombies sur le réseau, qui spamme massivement Internet (90% du trafic réseau est du spam) parce que leur propriétaire n'a pas voulu passer quelques minutes par jour à mettre à jour sa machine (aussi parce que la plupart sont sous des systèmes d'exploit<strike>ation</strike> non sécurisable).<br/>
La majorité des PC sont sans pare-feu correctement configuré (c'est-à-dire rien qui ne rentre par défaut) parce qu'expliquer le concept de port est incompatible avec le besoin pressant de l'utilisateur final et qu'il n'y pas envie d'avoir à reconfigurer son pare-feu à chaque nouvelle application (débile) qu'il va installer.<br/>
Les gens refusent de comprendre ce qu'est un executable ou pourquoi il ne faut pas juste ouvrir un fichier reçu par courriel, et se feront une joie de s'empresser de double-cliquer dessus pour en vérifier le contenu.<br/>
Alors forcément, commencer à parler aux gens de monter un serveur à la maison, de gérer leur propre serveur de courriel… C'est peine perdue.
Espérer leur faire comprendre la différence entre un chiffrement asymétrique et symétrique, c'est du domaine du doux rève utopique.

Pourtant, quand GMail annonce chiffrer l'intégralité de ses données, c'est juste totalement obligatoire de savoir faire la différence entre du chiffrement point-à-point et du chiffrement bout-en-bout (merci Amaëlle ♥).<br/>
Dans le bout-en-bout, c'est bien entre 2 personnes clairement identifiées que les données sont chiffrées (les 2 correspondants d'un courriel), et alors on peut espérer échapper à la NSA.

<center>![end-to-end](/static/images/20140615/end-to-end.png)</center>

Dans celui de point-à-point, c'est uniquement l'échange entre serveurs qui sera chiffré, donc au mieux entre votre serveur personnel et le serveur de Google, au pire du serveur de Google à lui-même ! Google est alors capable de déchiffrer les données échangées, et chiffrement ou pas chiffrement, la NSA y a accès…

<center>![point-to-point](/static/images/20140615/point-to-point.png)</center>

Idem, l'effet d'annonce toujours de GMail avec l'introduction de GPG en natif. Y'a quelqu'un qui s'est posé la question d'où et comment était stockée la clef privée ? On aura bien du chiffrement point-à-point cette fois, mais si la clef vous est fournie ou est stockée par Google, vous n'êtes plus le seul à pouvoir les déchiffrer, vos données ! Une clef privée se doit d'être générée et stockée uniquement par des moyens que vous contrôlez.

Je ne parle même pas d'être capable de comprendre qu'un AES 256bits est robuste alors qu'un RSA 1024bits est tout moisi alors qu'il fait 4× la taille du premier. Ou encore de savoir vérifier si on envoie bien ses courriels chiffrés par PGP/mime et non PGP/inline, avec les pièces-jointes incluses dans le corps du courriel et non à côté (et donc que vous fuitez leur nom…). Ou de vérifier qu'un chiffrement point-à-point n'utilise pas d'algorithme tout pourri ou NSA-troué comme RC4 ou DES… (Non, ça, même les banques ne semblent pas parvenir à le comprendre…)

<center>![ssl](/static/images/20140615/ssl.png)</center>

Il n'y a qu'un seul et unique principe applicable en terme de sécurité : ne faites confiance à personne (pas même à vous-même si vous le pouvez).<br/>
Comment voulez-vous espérer être en sécurité si vous ne comprenez rien à ce qui vous entoure ?
Si vous faites confiance « à l'ami qui s'y connaît » pour gérer vos affaire, alors la NSA n'a qu'à cibler votre ami, pour faire d'une pierre deux coups. Et aussi bien, il a lui-même fait appel à « un ami qui s'y connaît » parce qu'il n'y connaît en réalité pas beaucoup plus que vous et a juste (très mal) réappliqué ce qu'on lui avait déjà (mal) appliqué…

**L'informatique, ce n'est pas compliqué, mais ce n'est pas non plus simple.**<br/>
Il faut juste accepter que ça ne vous tombera pas tout cru dans la gueule, qu'il va vous falloir mouiller la chemise, accorder quelques minutes pas jour à cette machine qui vous attend patiemment sur un coin de bureau, et qui est aujourd'hui des millions de fois plus puissante que l'ordinateur qui a emmené l'Homme sur la Lune.
Alors que la NASA avait des équipes complètes 24h/24 7j/7 pour chouchouter leurs machines, comment pouvez-vous osez espérer n'avoir qu'à la sortir du carton pour la poser sur un coin de meuble et de n'avoir plus qu'à lui chatouiller le mulot de 5 à 7 ?

Au final, les gens se sont fait dépouiller de leur informatique et donc de leur sécurité, et la confient à des trucs étranges et étrangers, que ça soit une simple connaissance ou une entreprise commerciale (« cloud », quand tu nous tiens…), parce qu'ils ne veulent pas s'impliquer plus que la signature du chèque à la caisse du supermarché au coin de la rue lorsqu'ils veulent « faire de l'informatique » (et encore, c'est même plutôt juste « avoir un ordinateur »).<br/>
S'ils vivaient dans un bout de réseau à eux, isolés du reste, ça n'aurait que peu d'importance. Mais malheureusement, ils sont sur le même réseau que moi, communiquent avec moi, volontairement (courriels, messagerie instantanée…) ou non (bruteforce de mes machines par les leurs). Et parce qu'ils ne sont du coup plus du tout à l'abris ni en mesure de le redevenir, c'est eux qui serviront de vecteur d'attaque pour m'atteindre, malgré toutes les protections techniques auxquelles je pourrais m'astreindre.<br/>
Tout ça par pure flemmingite chronique et un discours commercial qui passe sa vie à bourrer le crâne des gens que l'informatique, c'est juste « branche et oublie ».

# L'informatique « cosmétique », ou comment on a fait de la non-sécurité pour tout le monde

Parce qu'aujourd'hui, ta « puissance » se mesure à la quantité de 0 que tu claques quand tu achètes un <strike>téléphone</strike> ordinateur portable, si possible tous les 6 mois.
Parce que ton degré de sociabilité s'exprime par ton nombre de « Like » sur Facebook (qu'on peut même s'acheter par 1.000 pour 30€).
Parce que tu choisiras la solution la plus kikoolol si on te donne le choix entre une application sécurisée mais un peu austère et une autre pas sécurisée mais qui s'adapte tout pile à l'écran 15″.
Parce qu'un écran tout noir avec des lettres bizarres dessus que tu tapes avec tes petits doigts potelés sur ton clavier, ça fait « too cheap »…

Tous les discours actuels tournent autour de la cosmétique, de l'expérience utilisateur, de l'accessibilité, du trop fameux « cloud ».
On doit avoir accès à nos données de partout, au boulot, à la maison, dans le train, l'avion, au bar, au lit, aux toilettes. Sur ordinateur, portable, mobile, tablette, télé, frigo et niche du chien.<br/>
Même des systèmes sensés faire de la sécurité, comme [Mailpile](https://www.mailpile.is/) ou [Caliopen](https://www.caliopen.org/) s'y mettent, en axant tout sur une interface utilisateur « à la Gmail » pour l'un et « intuitive » pour l'autre.

Arrêtons-nous 2 minutes et réfléchissons à comment on pourrait envoyer un courriel avec un maximum de sécurité et de confiance.

**Scénario n°1.** Je rédige mon petit message dans un éditeur de texte tout ce qu'il y a de plus simple. Ça a l'énorme avantage de sauvegarder un éventuel brouillon sur mon disque dur tout chiffré, plutôt que sur un éventuel webmail que je ne maîtrise pas (typiquement, en clair sur GMail…). Et de ne pas nécessiter une usine-à-gaz qui est peut-être en train de me rédiger mon courriel en HTML…<br/>
Une fois fini, je chiffre gentiment en ligne de commande mon petit courriel. `gpg -var foo@example.org -e mon-courriel.txt`. L'option *-v* me permet de vérifier au passage que j'utilise la bonne clef GPG et pas celle d'un voisin ou de la NSA qui m'en aurait injectée dans ma machine.<br/>
J'obtiens un fichier *mon-courriel.txt.asc*, que je peux ouvrir avec mon même éditeur de texte débile. Je peux alors vérifier que c'est bien chiffré, et que ma commande *gpg* n'a pas été simplement remplacée par un bête *cat* qui recopie son entrée sur sa sortie (ou que je me suis trompé de commande…). Je peux aussi m'assurer que mes éventuelles pièces-jointes sont bien intégrées au corps de mon courriel, et donc que leur nom de fichier (qui peuvent être des informations sensibles) n'y sont pas en clair.<br/>
Je me connecte alors au serveur de courriel de mon destinataire. En telnet. Avec SSL/TLS activé histoire de protéger mon adresse, celle de mon destinataire et le sujet de la conversation d'éventuelles oreilles indiscrètes. Que si le truc en face me répond qu'il ne cause pas TLS, même pas que je lui cause. Que s'il me dit qu'il supporte RC4, même pas que je lui cause non plus. Que s'il utilise une clef RSA de 1024 bits, juste je l'ignore. Que s'il m'annonce ne pas supporter [PFS](https://fr.wikipedia.org/wiki/Confidentialité_Persistante), je lui coupe la ligne au nez. Que s'il me présente un certificat qui ne correspond pas à celui de la veille que j'ai vérifié par téléphone avec mon destinataire lors d'une rencontre physique, même sentence. Pas la peine d'expliquer ce que je fais s'il me présente un certificate signé par Microsoft, le gouvernement chinois ou une machine Bluecoat en train de faire du DPI…<br/>
Donc là maintenant, je prend mon petit texte tout chiffré, et je le copie-colle manuellement dans ma belle session telnet toute bien sécurisée. Ce qui évite d'y envoyer des données bien en clair par mégarde.<br/>
Et voilà, je viens d'envoyer un courriel !<br/>
(NB : vous noterez la proportion significative de daube diverse et variée apportée par TLS…)

**Scénario n°2:** J'ouvre GMail sans vérifier si je suis en HTTPS, ni même si c'est bien un certificat Google. Je rédige un courriel qui sera bien gentillement sauvegardé en clair dans mes brouillons. Je coche bien gentillement la case « chiffrer pour mon destinataire ». Que Google se plante de clef pour le destinataire ou chiffre pour lui au passage, voire ne chiffre réellement rien, peu me chaut. Qu'il se mette à communiquer en clair avec le serveur de mon destinataire, ou qu'il utilise des algos cassables par la NSA, histoire de bien annoncer à l'ensemble du monde mon identité, celle de mon destinataire et notre sujet actuel, rien à foutre non plus.<br/>
Et voilà, je viens d'envoyer un courriel !<br/>

Se pose la problématique de l'ergonomie. Le scénario 1 est anti-ergonomique au possible, et tout le monde ou presque sur cette Terre risque fort d'avoir un petit problème conceptuel avec… Le scénario 2, qui se réduit à 3 clics (« nouveau message », « chiffrer », « envoyer »), lui, est ergonomique et c'est ce que **veut** le grand public. Sauf que…

Le simple fait d'introduire de l'ergonomie diminue la sécurité. Les deux sont juste totalement incompatibles.

Déjà parce que *ergonomie* signifie *usinagaz*.<br/>
Dans le cas 1, on est obligé d'utiliser des outils simples (un simple éditeur de texte, gpg, telnet, openssl) qui ne font qu'une seule chose, mais correctement (rédiger du texte, chiffrer, établir une connexion réseau, parler TLS) et de les combiner entre-eux pour réaliser une action complexe (rédiger et envoyer un courriel chiffré via une connexion réseau sécurisée). Chaque morceau est simple, auditable, compréhensible et testable à 100%.
Dans le cas 2, l'utilisateur ne veut pas avoir à changer d'outil, et veut tout faire depuis un seul. On se retrouve alors avec un gros outil très complexe, avec plein de cas particuliers, qui doit gérer des domaines très différents (réseau, chiffrement, rédaction…). On a alors affaire à un tas informe, incompréhensible, intestable. Donc non sécuritaire.

Ensuite, *ergonomie* signifie *fainéantise*.<br/>
Dans le scénario 1, on va avoir à réaliser un nombre élevées d'actions. Mais chaque action est auditable, et une erreur à l'étape N est détectable à l'erreur N+1. Vous avez oublié de chiffrer ? Vous vous rendrez bien compte que vous recopier du texte lisible lors du passage dans le réseau !<br/>
Dans le scénario 2, certes, vous cliquez sur 3 boutons et c'est torché. Mais si votre logiciel de courriel a un bug et que le bouton « chiffrer » n'est en réalité pas pris en compte ? Ah ben vous enverrez votre message en clair sans vous en rendre compte… Ne rigolez pas, c'est ce qui s'est passé [avec Kmail pendant presque 1 an](https://bugs.kde.org/show_bug.cgi?id=314930#c8)… Idem sur SSL/TLS, un serveur Google n'a aucun moyen de vérifier que le serveur de votre destinataire est réellement celui qu'il prétend être. La plupart du temps, il enverra votre courriel, que le serveur en face soit chiffré ou non, par la bonne personne ou non. Et même s'il détectait une incohérence ou un risque, vous n'avez pas envie d'avoir à confirmer 40.000 boîtes de dialogue toutes plus cryptiques les unes que les autres. Pire, il y a de fortes probabilités que vous soyez déjà retourné dans votre cuisine pour surveiller vos macarons…<br/>
Même ajouter des *pipes* (`echo "gros bordel" | gpg -ver foo@example.net | telnet -z ssl example.net smtp`) au cas 1 diminue la sécurité ! Parce que si *gpg* est tout moisi et ne chiffre rien ou mal, je n'ai plus aucun moyen de le savoir et/ou d'arrêter le processus en cours de route. Une fois encore, pas de sécurité.

Enfin, *ergonomie* signifie *débilité*.<br/>
Scénario 1, si vous ne parvenez pas à comprendre un minimum de technique, vous êtes juste mort. Ça impose de savoir lire [une empreinte GPG](https://en.wikipedia.org/wiki/Public_key_fingerprint), d'avoir pris [MIME](https://fr.wikipedia.org/wiki/Multipurpose_Internet_Mail_Extensions) en langue vivante 1, de [distinguer](https://dkg.fifthhorseman.net/notes/inline-pgp-harmful/) [PGP/MIME de PGP/inline](http://www.phildev.net/pgp/pgp_clear_vs_mime.html), de savoir que le courriel s'échange par [le port 25](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml), de connaître [la liste des chiffrements acceptables SSL/TLS](https://www.openssl.org/docs/apps/ciphers.html), d'avoir pris [SMTP](https://fr.wikipedia.org/wiki/Smtp) en LV2…<br/>
Scénario 2, je dois savoir manier [un vague truc avec 2 boutons et un fil qui sort](https://fr.wikipedia.org/wiki/Souris_(informatique)). Et encore, si ça avait pu être fait à la voix, ça aurait été fait à la voix (SIRI, si tu m'écoutes… Euh en fait non ><)… Les connaissances nécessaires que les gens voudront bien avoir à maîtriser pour utiliser un outil seront plus proches du vide sidéral ou de la constante de Planck que d'autre chose.<br/>
Parce que j'ai voulu être débile et que j'ai considéré que c'était à mon client de courriel de causer MIME et pas à moi, j'ai mis 6 mois avant de me rendre compte que malgré du chiffrement GPG sur nos échanges, une amie me balançait ses pièces-jointes avec le nom de fichier en clair dans ses messages. Autant quand ça s'appelle « recette-pizza-4-fromages.txt », on va s'en foutre un peu (sauf si ton fichier fait 300Mo, là ça va faire franchement louche…), autant quand c'est « doc-snowden.pdf », on sent de suite un malaise certain s'installer… et surtout 6 mois de communications électroniques à éplucher pour voir ce qu'on avait bien pu fuiter sans faire gaffe et si c'était critique ou non. J'ai découvert ça en lisant le code-source de mes courriels. Mais qui peut/veut bien lire ça quoi… Toujours pas de sécurité en tout cas…

Bref, *ergonomie*, c'est antinomique avec *sécurité*.<br/>
Encore une fois, les gens feraient leur ergonomie dans leur coin, j'en aurait rien à faire. Mais ça vient encore empietter sur ma sécurité, parce que malheureusement, je dois avoir des relations sociales avec ces personnes.
80% de ma boîte courriel, pourtant auto-hébergée, provient de GMail ou Microsoft, sont rédigés avec des bouses infâmes type Outlook (sans support GPG), ou même Thunderbird (avec un support GPG tout moisi, merci Enigmail…), avec du HTML tout moisi dedans. Que personne ne pense jamais à vérifier que son courriel est bien parti chiffré (même si c'est trop tard si ce n'est pas le cas…) quelque soit ce que lui indique son client de messagerie.<br/>
Les vrais logiciels, simples, efficaces, mono-taches, sont introuvables ou peu maintenus, parce qu'aujourd'hui, un logiciel doit ressembler au parc Disney pour avoir une chance de se vendre. Ou embarquer des fonctionnalités que personne n'utilise mais que tout le monde réclame (stockage dans le « cloud », indexation…), et que toi tu galères à essayer de désactiver parce que ça tue ta sécurité (Tu indexes comment, un courriel chiffré, hein ? Catégorie « gros tas de bits bizarres » ou « bouffe de la RAM pour rien » ?)…

# Centralisation du net, ou comment surveiller la planète avec 2 bouts d'allumettes

La NSA ne s'est sûrement pas réveillée un matin « tient, et si j'allais surveiller  l'intégralité de la population mondiale ». Elle s'est juste réveillé en voyant une dizaine de monceaux de données concentrant 90% du trafic mondial.
[Avec une clef à molette à $5](https://xkcd.com/538/), il lui suffisait d'aller casser 5 paires de genoux (Google, Facebook, Amazon, Microsoft, Apple) pour récupérer le profil de milliards d'individus.
 
<center>![prism-provider](/static/images/20140615/prism-provider.png)</center>
 
Avec une machine à $10.000, il suffisait de se brancher à quelques grosses fibres transocéaniques (USA/Europe, USA/Amérique Latine, Europe/Asie et USA/Asie) pour observer 90% du trafic mondial.

<center>![prism-backbone](/static/images/20140615/prism-backbone.png)</center>

On sait tous qu'un gros banc de poissons attire les prédateurs beaucoup plus qu'un petit banc de poisson et encore bien plus qu'un poisson isolé, car l'énergie dépensée pour la chasse sera alors bien supérieure à ce que le poisson pourra
 t'apporter.
La NSA ne serait pas venue si ses coûts de surveillance avaient été largement supérieurs à ce que les données récoltées leurs rapportaient réellement.
On s'est retrouvé avec une surveillance d'une facilité déconcertante, accessible avec peu de moyens et en tout cas largement à la portée du premier État (voire entreprise) venu.

Comment a-t-on pu en arriver là ? Pourquoi personne ne s'est réveillé avant ?
Tout le monde sait que nous ne vivons pas dans le monde magnifique des bisounours, et que toute possibilité de surveiller voire d'asservir sa population *sera* un jour ou l'autre réellement utilisée, pour de vagues causes au mieux présentées comme sécuritaires, au pire servant uniquement des causes mercantiles et personnelles.<br/>
Mais personne n'a bougé. Tout le monde a continué à utiliser massivement GMail (malgré mon autohébergement mail, 80% de mon courrier continue à partir vers eux), ou Facebook (un quart de l'humanité !), à tout concentrer dans 3 ou 4 grands centres de données, tous exclusivement sous contrôle États-Uniens. On a tous continué à regarder des vidéos en full-HD sous Youtube, à utiliser des applications totalement débiles comme Snapchat ou Whatsapp, achetés des milliards par Facebook.

Vous voulez un Internet NSA-proof by-design ? Décentralisez !
Faites des clusters d'auto-hébergement, faites en sorte que les plus gros points de concentration du réseau doivent se compter en centaines de milliers voire millions pour oser espérer toucher 50% du réseau !<br/>
Montez vos propres services, vos propres fournisseur d'accès à Internet, dispersez vos données, essaimez votre cluster dès que vous dépasser une taille critique. Allez consommer les données de Mr Michu sur la machine de Mr Michu, et que les vôtres soient sur votre propre machine. Ne remettez pas vos données à une entité autre que vous-même.<br/>
Rendez la surveillance tellement coûteuse et difficile à mettre en place qu'elle ne sera plus enviseagable par un quelconque État.
Le ministère de la Défense État-Unien, c'est 3.2 millions d'employés. Donc, au doigt mouillé, contrôler 1 million de nœuds intéressants, c'est du domaine de leurs possibilités.
7 milliards d'individus sur Terre, ça signifie une taille de cellule d'environ 7.000 individus. Avec une marge de sécurité, tout nœud qui dépasse une taille de 1.000 individus se doit d'essaimer !

Mais voilà, encore une fois, entre la théorie et la pratique…<br/>
Parce que les gens ont voulu une informatique simple et cosmétique (cf précédemment), personne n'est plus capable d'installer un serveur à la maison, sinon 3 ou 4 pelés qui font tourner la baraque. Et en tout cas clairement pas 1 personne sur 1.000.<br/>
Parce que du coup tout le monde travaille pour Google, Facebook ou Microsoft, les outils alternatifs ont pris du retard, sans parler du fait qu'ils ont tous du s'axer sur la cosmétique plutôt que la sécurité pour espérer toucher quelques malheureux pourcentages de parts de marché.
Même [Firefox est aujourd'hui obligé d'intégrer une solution totalement moisie et fermée développée par Adobe](http://www.april.org/drm-dans-firefox-annonce-dune-defaite), sous prétexte de mourir sinon, pour que les gens puissent continuer à visionner Game Of Thrones sous Youtube ou Netflix, en espérant vaguement parvenir à l'isoler dans un coin de la machine, histoire qu'elle ne puisse pas venir lire les données de mon disque dur (déchiffrées, du coup…).<br/>
Et encore une fois, je suis directement impacté par ce bordel ambiant…

# Conclusion

Parce que vous n'avez pas voulu vous prendre par la main, faire ce qui était techniquement bon pour ce très cher réseau, je me retrouve aujourd'hui à devoir communiquer avec vos bouses immondes de silos de données aux mains de la NSA. Mais vous continuerez à pouvoir vous créer vos addresses mail en 3 clics chez Google et à organisez vos beuveries hebdomadaires sur Facebook…<br/>
Parce que vous ne vous bougez pas le cul quand on vous tond, je vais bientôt devoir payer 10.000€ mon abonnement internet pour pouvoir faire exactement ce que je parviens encore à faire aujourd'hui. Et encore, c'est le meilleur des cas, le pire étant de n'avoir plus que des « Internet by XXX », avec juste les services de XXX et plus ceux de YYY. Mais oui, effectivement, vous pourrez continuez à regarder Game-of-Throne en full-HD sur Netflix…<br/>
Parce que vous ne voulez pas sortir du modèle commercial totalement pourri actuel où « c'est gratuit parce que c'est vous le produit », je n'ai aucune chance de pouvoir échapper à la NSA sinon à aller élever des chèvres dans le Larzac et à
 envoyer des pigeons voyageurs pour communiquer avec mes amis.<br/>
Parce que vous refusez d'essayer de comprendre la moindre once de technique et/ou de comprendre ce qui devrait être réellement fait et que vous préférez vous en remettre à des sociétés qui ne jurent que par les dividendes qu'elles pourront se verser en fin d'année, j'en suis réduit à être considéré comme un danger pour la Nation parce que je cherche à protéger ma vie privée et celle des autres.<br/>
Parce que vous voulez des applications kikoolol où seule la qualité ergonomique et graphique vous intéresse, c'est ma sécurité qui passe son temps à baisser.

**Parce que vous n'en avez strictement rien à foutre de votre sécurité et de votre liberté, ce sont les miennes auxquelles je tiens précieusement qui sont en train de s'envoler !!!**

Putain, les gens ! On vous met entre les mains la première implémentation utilisable par tout un chacun de la liberté d'expression, situation jamais atteinte depuis 1789 et la Déclarations des Droits de l'Homme et du Citoyen. Et vous l'avez remise entre les mains de sociétés vénales et autres entités étatiques…
