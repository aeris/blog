---
title: ! 'Développeurs & utilisateurs, comment gérer vos mots de passe'
---

La gestion des mots de passe est sûrement une des choses les plus difficiles à réaliser et pourtant la plus critique quand on parle de sécurité et d’hygiène numérique.

Voici la vision que devrait avoir un développeur et son pendant version utilisateur !

# Le monde des développeurs

## Vous avez bien dit « en clair » ?

Au début du monde était le stockage du mot de passe en clair dans la base de données.
Ça ne dérange pas grand monde, seuls les administrateurs du site en question peuvent y avoir accès, et tout le monde sait à quel point ces personnes sont fiables…

Tout le monde sait aussi qu’un site, ça n’a qu’une seule vocation : se faire trouer et finir dans la nature.  
Une fois publiées, ces centaines de milliers de mot de passe peuvent alors être utilisées en toute tranquillité par les pirates ou n’importe qui qui va avoir accès à ces données, pour tous les buts les plus inavouables que vous pourriez imaginer.

En plus, les utilisateurs ont généralement la très fâcheuse tendance de réutiliser tout le temps le même mot de passe partout, la compromission d’un compte d’un site risque donc de compromettre au passage l’ensemble des comptes de l’ensemble des plate-formes de l’utilisateur…

## Et le Dieu des chatons inventa le hachage

Pour éviter de compromettre le mot de passe des utilisateurs, le développeur a alors inventé [les fonctions de hachage](https://fr.wikipedia.org/wiki/Fonction_de_hachage).
Par l’utilisation de fonctions bien choisies, on va « masquer » le mot de passe réel par son équivalent haché.
Une fonction de hachage a la propriété intéressante d’être unidirectionnelle : on sait calculer le haché d’un mot de passe donné, mais on ne sait pas retrouver le mot de passe d’origine à partir d’un haché.

Du coup, si à la place de stocker le mot de passe en clair `P` dans une base de données on y stocke son haché `H = f(P)`, on empêche un attaquant de pouvoir remonter au mot de passe d’origine si il était compromis (haché vers mot de passe impossible) tout en permettant d’authentifier l’utilisateur correctement (si on a `f(Psaisi) = H = f(P)`, alors on est quasiment sûr (au risque de collision près) que `P = Psaisi`.

Il existe pléthores de fonctions de hachage, dont [MD5](https://fr.wikipedia.org/wiki/MD5), [SHA-1](https://fr.wikipedia.org/wiki/SHA-1), [SHA-2](https://fr.wikipedia.org/wiki/SHA-2), [SHA-3](https://fr.wikipedia.org/wiki/SHA-3), [RIPEMD-160](https://fr.wikipedia.org/wiki/RIPEMD-160), [GOST](https://en.wikipedia.org/wiki/GOST_(hash_function)) ou [Whirlpool](https://fr.wikipedia.org/wiki/Whirlpool_(algorithme)) parmis les plus connus.
Chaque fonction possède ses caractéristiques propres et certaines sont dorénavant [considérés comme non sûres](https://en.wikipedia.org/wiki/Hash_function_security_summary), comme MD5 et SHA-1, et sont donc à éviter (on sait générer « rapidement » des collisions sur ces fonctions).

## Le sel, c’est la vie

Avec l’amélioration des processeurs, les fonctions de hachage sont globalement de moins en moins robustes.
On sait en effet calculer de plus en plus rapidement des quantités astronomiques de hachés, parfois même avec du matériel dédié, les [ASIC](https://fr.wikipedia.org/wiki/Application-specific_integrated_circuit).
La monnaie électronique [Bitcoin](https://bitcoin.org/) est même basée sur [ce genre de matériel](https://www.minerslab.com/product/smart-miner-3-0-rack-mount-20ths-bitcoin-miner/) capable de calculer jusqu’à 20THs soit 20 mille milliards de doubles SHA-256 à la seconde pour environ $5000.

C’est assez problématique pour la protection des mots de passe, puisque si une liste de mots de passe hachés se retrouvaient dans la nature, il suffirait de s’offrir un de ces petits jouets et de lui faire générer des milliards de milliards de hachés : si un haché `H` trouvé correspond à un des hachés dans la base, on a donc trouvé le mot de passe `P` d’un des utilisateurs.
Les utilisateurs ayant la fâcheuse tendance à utiliser toujours les mêmes types de mot de passe (0000, 123456, password, la date d’anniversaire ou le nom du chat), on a même une probabilité non nulle d’avoir plusieurs utilisateurs utilisant le même mot de passe qui vont donc avoir le même haché et qui vont donc tous tombés en même temps…

On peut donc grandement améliorer la sécurité en utilisant un [sel cryptographique](https://fr.wikipedia.org/wiki/Salage_(cryptographie)) avant de calculer le haché du mot de passe.
Plutôt que de le calculer directement (`H = f(P)`), on va lui ajouter en tête une chaîne de caractères totalement aléatoire propre à chaque utilisateur (`H = f(v | P)`).
On stocke donc dans la base le couple `(v, H)`, ce qui permet par calcul de `f(v | Psaisi) = H = f(v | P)` de s’assurer de l’authenticité d’un utilisateur.
Ça n’a l’air de rien comme ça, mais ce petit détail change tout.

Déjà, un même mot de passe utilisé par plusieurs utilisateurs va être associé à des sels différents, et donc générer un haché différent.
On réduit donc considérablement (on peut même dire qu’en pratique il est quasi nul) le risque de se retrouver avec plusieurs fois le même haché dans la base et donc d’avoir plusieurs utilisateurs compromis par la compromission d’un seul haché.
Ceci n’est bien sûr vrai que si on change de sel pour chaque utilisateur.

En prime, on complexifie aussi le travail d’un attaquant.
Sans sel, l’attaquant pouvait simplement générer des hachés à la pelle et rechercher dans la base s’il trouvait une correspondance.
S’il conserve la même technique avec un sel, même s’il trouvait par hasard un haché dans la base, il faudrait en plus que le mot de passe qu’il va pouvoir associer commence exactement par le sel correspondant à l’utilisateur, ce qui est statistiquement plus que très fortement improbable (et inversement proportionnel à la longueur du sel utilisé).
Il va donc devoir changer de tactique et s’attaquer à chaque utilisateur successivement : je prend le sel `v` de l’utilisateur, je génère des tonnes de hachés de `v | P`, si ça me donne un `H` de la base, j’ai le mot de passe `P` de l’utilisateur `v`.
On l’empêche donc d’espérer casser les utilisateurs au petit bonheur la chance comme c’est le cas dans la version sans sel cryptographique et son coût d’attaque est multiplié par le nombre d’utilisateurs à casser.

## La dérivation de clef, c’est mieux

On l’a vu précédemment, les puissances de calcul augmentent de plus en plus, et un attaquant vraiment motivé pourrait toujours trouver les ressources nécessaires pour calculer rapidement des hachés, par exemple via l’utilisation d’un [botnet](https://fr.wikipedia.org/wiki/Botnet) ou d’ASIC dédiés à cette tache.
On peut donc augmenter encore plus le coût d’une attaque via de la [dérivation de clef](https://en.wikipedia.org/wiki/Key_derivation_function) ou l’utilisation de fonctions de hachage robuste à l’attaque par du matériel dédié (ASIC).

Par exemple, [scrypt](https://fr.wikipedia.org/wiki/Scrypt) est un algorithme demandant un compromis vitesse/mémoire : vous ne pouvez être rapide que si vous lui fournissez une grosse quantité de mémoire.
À l’inverse de SHA-256 qui s’implémente uniquement par des [portes logiques](https://fr.wikipedia.org/wiki/Fonction_logique) et peut donc être massivement accéléré par du matériel dédié, scrypt est très difficile à implémenter efficacement dans du matériel, l’installation d’une zone mémoire importante (interface avec une barrette de RAM par exemple) étant relativement complexe et restera de toute façon bien plus lent en temps d’accès qu’une simple porte `ET`.  
À titre d’exemple, on sait faire des ASIC calculant à 10THs du SHA-256, mais [les meilleurs ASIC scrypt](https://www.minerslab.com/product/litecoin-scrypter-pro-900mhs-rack-mount-miner/) du marché atteignent péniblement le GHs pour le double du prix, soit une efficacité 20.000× plus faible.
En utilisant ce type de fonction « matériel-résistant » plutôt que du SHA-2 par exemple, on se met à l’abri d’une future attaque massive sur la base.

Ces fonctions robustes au matériel ne sont pas légions, il faut donc trouver une astuce pour durcir les autres fonctions de hachage qui elles peuvent être accélérées par du matériel.
Une astuce simple consiste à enchaîner plusieurs fois la fonction de hachage (`H = f(f(…f(v | P)…))`) (en réalité, l’algorithme est plus complexe mais le principe reste le même).
Plus on enchaînera d’appels de fonction de hachage, plus l’algorithme sera lent à calculer et pénalisera fortement un attaquant.

On calcule le nombre de tour `n` à réaliser en fonction de l’état de l’art de la cryptographie de manière à ce qu’un calcul complet prenne de l’ordre de 100ms, suffisamment peu pour être handicapant pour l’utilisateur réel (qui devra attendre ce temps à chacune de ses tentatives d’authentification) mais extrêmement pénalisant pour un attaquant (il ne peut plus calculer que quelques hachés par seconde).
Dans notre base de données, on stockera donc le n-uplet `(n, v, H)` qui permettra de recalculer `f(n, v, Psaisi) = H = f(n, v, P)` et de toujours assurer l’authentification de l’utilisateur.

Les plus connus des algorithmes de dérivation de clef sont [PBKDF2](https://fr.wikipedia.org/wiki/PBKDF2) (qui présente l’intérêt de prendre en plus en paramètre la fonction de hachage à utiliser), scrypt, et [bcrypt](https://fr.wikipedia.org/wiki/Bcrypt).
En terme de paramètres recommandés, PBKDF2(SHA-256) est au alentour de 10.000 tours (~100ms), bcrypt devrait être utilisé avec un *cost factor* d’au moins 10 (~100ms) et scrypt avec les paramètres `N=16384, r=8, p=1` (16Mo de mémoire, ~100ms).

Les dérivations de clef ont aussi l’intérêt de pouvoir être durcies avec le temps.
Si vos paramètres de génération devenaient trop faibles, vous pouvez parfaitement modifier votre configuration pour ajouter plus de tours de boucle (vous calculerez le nouveau haché à la prochaine connexion de votre utilisateur).

Il va sans dire que cette méthode de la dérivation de clef devrait être la seule et unique manière de stocker les mots de passe dans une base de données encore utilisée aujourd’hui…
Ce n’est malheureusement pas le cas et beaucoup continuent même à stocker vos mots de passe en clair (généralement au motif que comme ça on est capable de vous le renvoyer par courriel…).

# Le monde des utilisateurs

Comme vu précédemment, si vous utilisez un mot de passe trop faible ou trop commun, un attaquant pourra déjà avoir pré-calculé des pilées de hachés et trouvera votre mot de passe très rapidement.
Si en plus vous utilisez le même mot de passe partout, la compromission d’un seul site fera tomber l’ensemble de vos sites, votre nom d’utilisateur ou votre adresse de courriel allant être elle aussi la même partout.

Vous devez donc vous assurer que vous utilisez sur chaque site un mot de passe différent, et si possible un mot de passe différent de tous les utilisateurs du site (pour ne pas être compromis vous aussi si les administrateurs du site ont mal fait leur travail et qu’une autre personne utilisait le même mot de passe que vous et se retrouve compromise).  
La seule manière de faire est donc de générer des mots de passe aléatoires et suffisamment longs (au moins 20 caractères) pour chacun des services auxquels vous allez devoir vous connecter, par exemple `uhPaz27aOEmaa2ztxTRZ` ou `x0vtYD41I4_7T6rep4Q5`.

Comme il est impossible d’espérer retenir de tels mots de passe, utilisez un gestionnaire de mots de passe pour stocker tout ça bien à l’abri, par exemple [KeepassX](https://www.keepassx.org/).
Votre gestionnaire est lui protégé par une phrase de passe (et [non un mot de passe](https://xkcd.com/936/)) mémorisable, par exemple généré par la méthode [Diceware](https://en.wikipedia.org/wiki/Diceware), comme par exemple `tuner sentir pochon scopie 1950 sabir` ou `bougie parsie fourmi tacet setier sterol`, qui débloquera l’accès à tous vos autres mots de passe in-mémorisables.  
(Vous pouvez même [acheter de telles phrases de passe à une petite fille de 11 ans pour $2](http://rue89.nouvelobs.com/2015/10/25/a-11-ans-fabrique-vend-mots-passe-securises-261826)) si vous habitez aux États-Unis :)).
