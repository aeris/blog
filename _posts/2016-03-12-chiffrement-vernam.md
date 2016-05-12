---
title: Chiffrement de Vernam ou « comment (ne pas) faire de la cryptographie (comme Blind Eagle) »
---

(J’aurais bien intitulé ce post « BlindEagle, charlatanisme ou charlatanisme ? », mais il paraît que c’était déjà pris :D)

# Chiffrement de Vernam

## Un système théoriquement sûr

Le chiffrement de Vernam (ou masque jetable, ou OTP (One Time Pad)) est un système de chiffrement inventé en 1917 par Gilbert Vernam.
Il a pour particularité d’être **prouvé mathématiquement comme incassable**, c’est-à-dire qu’il n’existe et n’existera jamais de méthode plus efficace que la force brute pour tenter de déchiffrer un message codé sans connaître la clef de chiffrement.

Le principe de ce chiffrement est pourtant extrêmement simple.
Si vous avez un message `M` de taille X à chiffrer, commencer par générer une clef `K` aléatoire de taille X.
Avec cette clef, vous calculez votre texte chiffré `C = M ⊕ K` (où `⊕` est le [ou exclusif](https://fr.wikipedia.org/wiki/Fonction_OU_exclusif)), que vous pouvez transmettre à votre destinataire.
Votre destinataire, lui, calculera `C ⊕ K = M` pour retrouver le texte d’origine.
Le procédé fonctionne bien puisque l’opération `⊕` est associative (`A ⊕ (B ⊕ C) = (A ⊕ B) ⊕ C`), que `X ⊕ X = 0` et donc que `C ⊕ K = (M ⊕ K) ⊕ K = M ⊕ (K ⊕ K) = M`.

Ce système est effectivement incassable puisque toute clef `K` déchiffrera quelque chose.
Mieux, il est toujours possible de trouver une clef `K′` tel que le déchiffré de `C` donnera n’importe quel texte donné.
Vous aurez donc beau tester les 2<sup>X</sup> clefs possibles, vous n’obtiendrez rien d’autre que l’ensemble des 2<sup>X</sup> messages possibles, certains n’ayant littéralement aucun sens, d’autres formant des textes parfaitement sensés et un seul étant le message réel.

## Mais en pratique extrêmement faible

Enfantin n’est-ce pas ?
Eh bien pas tant que ça…

Ce protocole incassable n’est réellement incassable qu’à 3 conditions.

 * La clef doit être au moins aussi longue que le message à chiffrer.
 	En effet, la cryptographie a horreur des répétitions, et utiliser la même clef pour chiffrer plusieurs bouts du message conduit aux mêmes attaques que pour le chiffrement [ECB]({% post_url 2016-03-03-chiffrement-donnees %}#au-commencement-tait-ecb).
 * La clef doit être vraiment aléatoire.
 	Pas question d’utiliser un générateur pseudo aléatoire, puisqu’un attaquant s’attaquera alors à bruteforcer ce CSPRNG pour trouver la clef en moins de 2<sup>X</sup> essais. 
 * La clef ne doit jamais être réutilisée.
 	Sinon on tombe à nouveau dans les problèmes de réutilisation de clef.  
 	`CA ⊕ CB = (K ⊕ A) ⊕ (K ⊕ B) = K ⊕ K ⊕ A ⊕ B = A ⊕ B`

Et du coup, la mise en pratique est tout sauf évidente.
Voire plutôt inatteignable en pratique. 

### Génération de la clef

La clef doit être générée par un processus réellement aléatoire.
Cela nécessite du matériel dédié, utilisant des processus physiques aléatoires pour générer de la donnée, par exemple la désintégration atomique, le bruit thermique ou des phénomènes quantiques.

Ce matériel doit être sous votre entier contrôle, il est inenvisageable que quelqu’un d’autre ait accès à ce matériel et aucun intermédiaire ne saurait être suffisamment de confiance pour vous fournir de telles données.

Si un tiers de confiance gère ce type de matériel, la génération des données doit être faite sous vos yeux, par un procédé extrêmement rigoureux et contrôlable (du type de celle de la [cérémonie de renouvellement de la clef racine de DNSSec](https://www.iana.org/dnssec/ceremonies) (4h !!!)) permettant (entre autres) de s’assurer de l’intégrité du matériel (vérification des scellés) et de la sécurité des données (HSM scellé par un secret partagé stocké dans un coffre-fort scellé dans une pièce scellée pour le cas de DNSSec).
Dans le cas contraire, il serait en effet très facile pour un attaquant de compromettre cette machine par un procédé quelconque ou de soudoyer un intermédiaire pour vous délivrer du faux aléatoire.
Un tel déploiement de matériel et de sécurité donne à un tel système un coût très largement prohibitif, surtout comparé à la sécurité supplémentaire réellement apportée par rapport à des systèmes à coût négligeable comme AES (ou CHACHA20 si vous avez peur de la NSA).

Sans tiers de confiance, la solution est déjà plus viable (petit matériel bien caché par vos soins) et à coût plus raisonnable.

### Échange et conservation des clefs

Les clefs sont des matériaux privés de cryptographie et à ce titre ne doivent jamais être communiquées à une tierce personne et conservées avec toute la prudence nécessaire.
Idéalement, elles ne devraient donc être générées que quelques instants avant leur utilisation, afin de limiter au maximum les risques de fuite.
Le problème du chiffre de Vernam est que tous les correspondants doivent posséder une copie de la clef et surtout que cette clef ne peut pas être transmise sur un canal non fiable.

Si on suppose un canal informatique fiable, alors Vernam est sans intérêt puisqu’on aurait tout intérêt à utiliser ce canal pour échanger directement les données plutôt que la clef.
Une rencontre physique juste avant l’établissement d’un canal protégé par Vernam est aussi un non-sens, puisqu’on aurait alors mieux fait de s’y échanger les données au passage…
Il n’y a donc pas d’autre moyen d’échange de la clef qu’une rencontre physique *très antérieure* à la communication chiffrée.

Cette rencontre physique ne peut utiliser aucun canal de communication physique standard (poste, coursier…) au risque de faire intervenir un tiers de confiance et donc de devoir mettre en place le même niveau de protection que pour la génération de la clef (enveloppe scellée, procédure d’identification…).
Le coût en devient tout aussi prohibitif et dans tous les cas peu utilisable en pratique par le commun des mortels.  
Comme pour la génération, l’absence de tiers de confiance (rencontre physique des correspondants) est plus abordable mais généralement difficile à organiser, l’utilisation de moyen informatique étant souvent là pour compenser de l’éloignement physique (communication trans-nationale) ou de l’impossibilité de déplacement (correspondant en situation délicate dans son pays).

On voit aussi que Vernam nécessite autant de partages de clef que de tuples de correspondants et que la clef d’un correspondant A ne peut pas être utilisée pour échanger avec B.

### Synchronisation des clefs

Chaque envoi de message nécessite l’utilisation d’une nouvelle clef, sous peine de compromettre la sécurité du système.
Étant donné la difficulté de génération et de transmission de la clef, le chiffre de Vernam réclame donc la mise-en-œuvre d’une sorte de dictionnaire de clefs. 
On va générer une très grosse quantité de données aléatoires (par exemple un fichier de 2Go), qu’on va transmettre en une seule fois lors d’une rencontre physique.

Lors de l’envoi d’un message, on va alors piocher dans ce paquet de données pour générer notre clef, chiffrer notre message puis détruire les données de la clef (évite la réutilisation et une compromission ultérieure).
Une manière de procéder est par exemple de lire le fichier de données séquentiellement et de le remplir de 0 au fur et à mesure de l’utilisation.
Se posent du coup deux problèmes.

D’abord, comment garantir que le(s) récepteur(s) auront bien encore toutes les données nécessaires à la génération de la clef.
Le support des données aléatoires (disque dur, clef USB, feuille de papier…) peut en effet s’être dégradé avec le temps (on parle ici de plusieurs années de rétention potentielle), avec des secteurs endommagés, des trous, des bits inversés à cause du rayonnement cosmique (non, [ce n’est pas une blague](http://lambda-diode.com/opinion/ecc-memory), une barrette de RAM de 4Go connaît un bit-flip tous les 5j à cause de ça)…

Plus grave, une [situation de compétition](https://fr.wikipedia.org/wiki/Situation_de_compétition) existe sur la consommation des données. Par exemple, si plus ou moins au même moment A envoie un message à B et consomme sa plage `[X, X+M]` alors que B envoie à A en consommant sa plage `[X, X+N]`, quand A et B vont recevoir leur message, leur plage `[X, X+min(M,N)]` va déjà être consommée et aucun des deux n’aura accès à la clef permettant le déchiffrement ! (--edit-- Un anonyme m’a fait remarquer [dans les commentaires](#isso-406) qu’en plus d’empécher le déchiffrement par les personnes légitimes, on a en fait chiffré deux messages avec un même bout de clef, et donc un attaquant potentiel peut lui calculer la somme des deux messages chiffrés pour obtenir les textes en clair…)

Pour illustrer le propos, imaginons que A et B correspondent via Vernam et une clef écrite sur un cahier (identique pour A et B), conservé précieusement à l’abri dans un coffre.
Quand A veut écrire à B, il sort son cahier et arrache la première page, ce qui lui donne la clef à utiliser.
Il chiffre ensuite son message, brûle la page de cahier (non réutilisation + non compromission) et poste sa lettre.
B reçoit la lettre, prend son cahier, déchire la première page (qui est obligatoirement la même que celle utilisée par A par construction), déchiffre le message et brûle aussi sa page.
A et B se retrouvent alors avec la même première page et jusque là, tout va bien.  
Maintenant, A et B ont subitement envie de s’écrire.
A prend donc son cahier, brûle sa première page et poste son message.
Le temps que la lettre lui parvienne, B prend aussi son cahier, brûle sa première page et poste aussi un message.
B va alors recevoir une lettre de A, chiffré avec une clef se trouvant sur une page brûlée !
Et idem pour A quelques jours plus tard !

On peut régler partiellement ces problèmes.  
On peut par exemple demander à avoir une clef différente pour chaque émetteur.
Dans l’exemple précédent, si A utilise un cahier pour chiffrer avec B et un autre pour déchiffrer B, alors chaque va consommer sa propre première page pour le chiffrement, laissant intacte celle de déchiffrement.
Mais on se retrouve alors à devoir non plus échanger des clefs par groupe de correspondants (si `[A, B, C]` communiquent ensembles et `[D, E, F]` aussi, 2 échanges suffisent `[A, B, C]` et `[D, E, F]`), mais par correspondants dans un groupe de correspondants (`[A, B, C]` nécessite `[A, [B, C]]`, `[B, [A, C]]` et `[C, [A, B]]`).
Ce qui rend Vernam encore plus infernal.  
On peut aussi imaginer ne détruire la clef qu’à l’émission et indiquer dans le message le numéro de page à utiliser pour le déchiffrement, mais alors on affaiblit la sécurité (disparition de la [confidentialité persistante](https://fr.wikipedia.org/wiki/Confidentialité_persistante) : si un cahier tombe, tous les messages précédemment émis sont compromis).

# Blind Eagle

La raison principale de cet article, que vous attendiez tous :)

[Blind Eagle](https://www.blindeagle.com/) vient de lancer un Kickstarter, et rejoint donc le [cimetière des projets charlatans](http://www.zdnet.com/article/charlatans-the-new-wave-of-privacy-profiteers/) vous promettant le retour de <s>l’être aimé</s> votre vie privée.
Ce projet se présente comme une solution totalement sûre puisque basée sur le chiffrement de Vernam qui est lui totalement sûr (en théorie seulement, comme montré précédemment).

Déjà pour rappel, un projet qui se présente comme un *100% sûr*, *absolument indécryptable* (sic), *infaillible*, vous pouvez être sûr que c’est juste du *100% absolument bullshit*.
Voir à ce sujet une [très bonne FAQ](http://www.interhack.net/people/cmcurtin/snake-oil-faq.html) (malheureusement en anglais) sur comment détecter un projet bullshito-crypto.
En particulier pour Blind Eagle, la lecture de ce [petit passage](http://www.interhack.net/people/cmcurtin/snake-oil-faq.html#SECTION00057000000000000000) leur sera très profitable je pense. 

## Sécurisation des clefs

Le projet annonce générer les clefs avec du matériel quantique (100% sécurité, audité, approuvé, certifié, fiable, whatever, sinon ce n’est pas drôle…).
La qualité de l’aléatoire obtenu ne pourra de toute façon pas être contrôlée par l’utilisateur, puisque un tel système se doit d’être en écriture seule, en tout cas pour la partie de stockage des clefs (leur module propose apparemment du stockage des messages en plus).

Même s’ils utilisent réellement un générateur quantique, le stockage des clefs et leur transmission va être un véritable challenge pour ne pas affaiblir la sécurité de Vernam.
Ils annoncent une livraison en main propre sous emballage scellé, mais je les imagine mal assurer une livraison par leur soins et donc plutôt recourir à un transporteur tiers, réduisant à néant la sécurité du système.  
L’emballage scellé n’apporte rien en termes de sécurité puisqu’un scellé n’a de sens que s’il est identifiable par le récepteur (par exemple dans le cas de la cérémonie DNSSec, on s’assure que les scellés sont les *mêmes* que ceux de la dernière cérémonie).
Une interception du paquet et un remplacement du scellé par un autre ne sera pas détectable.

Dans tous les cas, Blind Eagle pourra conserver une copie des clefs générées, réduisant à nouveau la confiance en ce système à quelque chose proche de la [constante de Planck](https://fr.wikipedia.org/wiki/Constante_de_Planck).
Pire, Blind Eagle ne se cache pas de les conserver pour faire fonctionner leur système en mode « solo » (voir juste après).

## Synchronisation

Je demande à voir comment Blind Eagle va gérer les problèmes de synchronisation.
Dans des tweets effacés depuis, ils envisagent de forcer un passage par leur serveurs afin de limiter les races-conditions.
Si A souhaite écrire à B, il le signale au serveur, qui interdira à B d’écrire à A jusqu’à ce que A ait terminé.
Mais ça sera à mon avis une véritable usine-à-gaz à mettre en place.
Par exemple comment déverrouiller la communication B→A si A n’a pas libéré son lock (passage sous un tunnel, application plantée, rédaction d’un mail pendant 10h…) ?

La zone de stockage risque aussi de se corrompre.
Je suppose qu’il s’agira de mémoire flash, qui déjà pose de gros problèmes de sécurité (il est très difficile d’y [effacer réellement une donnée écrite](https://www.cl.cam.ac.uk/~sps32/DataRem_CHES2005.pdf)), et à durée de vie relativement limitée (5 à 10 ans seulement pour les plus haut de gamme), mais qui connaissent souvent des problèmes de secteurs défectueux, qui conduiront à invalider certaines clefs, rendant impossible le déchiffrement.

## Centralisation

Un des modes de fonctionnement (« solo ») de Blind Eagle permet de s’affranchir (ie. de casser tout le système de Vernam…) de l’échange de clef en introduisant un point de centralisation. 
Vernam impose en effet que l’émetteur et le destinataire procèdent à un échange de clef avant la communication, ce qui est difficile à réaliser en pratique.
Blind Eagle va alors plutôt faire du chiffrement entre vous et eux, puis entre eux et votre destinataire.
Oh wait ! Ça ne serait pas exactement la notion de [man-in-the-middle](https://fr.wikipedia.org/wiki/Attaque_de_l'homme_du_milieu) en cryptographie ?

En plus, pour un projet qui cite Edward Snowden pour justifier leur intérêts, ils ont dû oublier un petit détail dans l’affaire de la NSA : cette surveillance n’a été possible que et uniquement parce que Internet est centralisé et réclame de gros tiers de confiance.
Je serais la NSA ou tout autre entité gouvernementale, j’irais immédiatement me poster pas très loin du centre de données du projet Blind Eagle, il va y avoir des choses intéressantes à compromettre…
(--edit-- [On me signale](https://twitter.com/_redsilk_/status/708718669539504129) en plus qu’ils ont l’ambition d’avoir plusieurs centres de données, donc votre clef privée va au pire se retrouver un petit peu partout sur la surface du globe, au mieux être centralisée à un seul endroit avec tout plein de machines y ayant accès…) 

Le projet propose un mode « twin » et « quad » permettant du chiffrement de Vernam direct, sans intermédiaire.
Les clefs provevant cependant toujours de Blind Eagle, il n’y a pas plus de garantie qu’ils n’ont pas conservé une copie des clefs de leur côté.

## Source or it didn’t happen

Comme d’habitude en cryptographie, la sécurité n’est réellement possible qu’avec du logiciel libre, avec le code-source accessible et analysable par la communauté.

Or ici, rien n’est publié, alors que ça devrait être l’action n°1 à réaliser, avant même toute communication officielle et mise à disposition du public, afin que la communauté crypto puisse faire les remarques nécessaires et évaluer réellement la sécurité de la solution proposée.

La sécurité globale d’un système ne peut de toute façon certainement pas être jugée par le concepteur du système, il faut nécessairement un œil externe, compétent et neutre pour avoir une vision propre de la sécurité apportée.

Protection par l’obscurité ?
Auriez-vous quelque chose à cacher ?

## Où est <s>Charlie</s> le cryptologue ?

Une présentation de l’équipe du projet est faite sur la page du Kickstarter.
On y trouve des entrepreneurs *expérimentés*, des informaticiens *chevronnés*, des avocats *adroits*, des designers *exaltés* et des philosophes *en herbe* (vous en aviez fumé ce soir-là ?).

Mais où est donc votre cryptologue ? Un « expert » (même si je déteste ce mot) en sécurité ?
Un papier de recherche appuyant votre méthodologie ou vos assertions sur votre système *100% fiable* ?
 
Non, rien de tout ça.
Juste une équipe de personnes qui n’ont a priori pas touché à la sécurité au mieux depuis leur sortie d’école pour les techniques, au pire jamais de leur vie pour les autres.

Au contraire, quand certaines personnes proches du domaine de la sécurité ([Geoffroy Couprie](https://twitter.com/gcouprie) par exemple, qui leur a gentiment proposé un audit, ou moi-même) leur ont posé des questions ou soulevé des problèmes, le projet a très vite fait n’importe quoi, allant jusqu’à [publier des correspondances privées](https://twitter.com/gcouprie/status/708409067228831745), ou même [à supprimer leur tweets](https://twitter.com/gcouprie/status/708565789520044033).
Pour un projet prônant la confiance, la transparence et le respect de la vie privée, on repassera.


Je terminerai par citer Matt Curtin à propos du chiffrement de Vernam et à l’attention directe de Blind Eagle

	But it is important to understand that any variation in the implementation means that it is not an OTP and has nowhere near the security of an OTP
	
	Mais il est important de comprendre que toute variation de mise-en-œuvre signifie que ce n’est plus de l’OTP et que ça n’a plus rien à voir avec la sécurité de l’OTP

Ne dites donc plus jamais à vos utilisateurs que vous implémentez un Vernam ou que votre technologie est prouvée comme étant théoriquement sûre, ce n’est pas vrai et donc au mieux un mensonge, au pire une pratique commerciale déloyale.
GPG, TLS, HTTPS ou OTR seront en tous points plus sécurisés que votre solution, même dans leur version la plus faible, jusqu’à preuve mathématique du contraire que **vous** devrez apporter.

Et enfin Bruce Schneier pour tous les crypto-charlatans de demain

	Security is a process, not a product

	La sécurité est un processus, pas un produit
