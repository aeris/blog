---
title: ! 'Développeurs, comment chiffrer vos données' 
---

Après avoir vu [comment stocker ses mots de passe]({% post_url 2015-10-27-stockage-mot-passe %}), voyons comment gérer le chiffrement de vos données.

# Au commencement était ECB.

Le mode de chiffrement [ECB](https://fr.wikipedia.org/wiki/Mode_d'opération_(cryptographie)#Dictionnaire_de_codes_:_.C2.AB_Electronic_codebook_.C2.BB_.28ECB.29) (Electronic CodeBook) a été le premier mode inventé pour chiffrer une donnée.
Le principe est très simple : on découpe les données à chiffrer en bloc de X bits, et on [XOR](https://fr.wikipedia.org/wiki/Fonction_OU_exclusif) chaque bloc avec une clef de chiffrement de X bits.

C<sub>i</sub> = K ⊕ P<sub>i</sub>
{:.center}

Ce mode souffre du coup d’un énorme problème.
Si plusieurs blocs contiennent les mêmes données, alors les blocs de sortie contiendront aussi les mêmes données !

Ce problème est très visible sur le chiffrement d’une image.
Par exemple si je vous montre
![Tux ECB](/assets/images/20160303/ecb.png){:.center}
vous n’aurez aucun problème à deviner les données d’entrée…
![Tux](/assets/images/20160303/tux.png){:.center}

Vous ne devez aussi jamais réutiliser la même clef pour chiffrer 2 messages différents.
En effet, si A et B sont chiffrés en CA et CB avec la clef K, alors :

CA = K ⊕ A  
CB = K ⊕ B  
CA ⊕ CB = (K ⊕ A) ⊕ (K ⊕ B) = K ⊕ K ⊕ A ⊕ B = A ⊕ B
{:.center}

Vous obtenez donc les données en clair XORées entre elles.
Avec un peu d’analyse, on peut retrouver A et B.
![Réutilisation de clef](/assets/images/20160303/reusage.png){:.center}

# Puis CBC apparu

Pour corriger ces problèmes, on a alors inventé le mode [CBC](https://fr.wikipedia.org/wiki/Mode_d'opération_(cryptographie)#Encha.C3.AEnement_des_blocs_:_.C2.AB_Cipher_Block_Chaining_.C2.BB_.28CBC.29) (Cipher Block Chaining).

On voit que le soucis de ECB vient du fait qu’on réutilise la même clef pour tous les blocs, ce qui fait qu’à entrée (et donc clef) identique, la sortie sera identique.
Vu qu’on ne maîtrise pas les données d’entrée, on ne peut jouer que sur la clef de chiffrement.
Il faut trouver un moyen de la faire varier pour chaque bloc, pour qu’enfin à données identiques, on obtienne bien une sortie différente.
La solution retenue est simplement d’utiliser la sortie du bloc précédent, de la mixer avec la clef et d’utiliser le résultat comme nouvelle clef de bloc :

C<sub>i</sub> = K ⊕ C<sub>i-1</sub> ⊕ P<sub>i</sub>  
{:.center}

Les petits malins en mathématiques vont s’apercevoir d’un problème pour i=0.
En effet, on n’a pas encore de bloc précédent pour mixer avec la clef…
Du coup, on va résoudre cette étape avec une donnée aléatoire, appeler vecteur d’initialisation (IV) :

C<sub>0</sub> = K ⊕ IV ⊕ P<sub>0</sub>
{:.center}

Si on reprend notre petit Tux de départ, on obtient alors quelque chose de beaucoup plus cryptique :
![Tux CBC](/assets/images/20160303/cbc.png){:.center}

Bien que cela soit beaucoup moins critique que pour ECB, il ne faut à nouveau jamais réutiliser la même clef ou le même IV pour chiffrer 2 données.
Un attaquant possédant 2 textes chiffrés par la même clef ou IV peut à nouveau en déduire des choses sur les données d’entrées.

Il reste aussi un autre problème à résoudre.
Les données chiffrées restent malléables par un attaquant potentiel, le fonctionnement des chiffrements ne pouvant en effet pas détecter une modification et toute entrée chiffrée conduit obligatoirement à une donnée en clair valide.
Pour illustrer ce problème, un petit bout de code (je suis passé en mode [CTR](https://fr.wikipedia.org/wiki/Mode_d'opération_(cryptographie)#Chiffrement_bas.C3.A9_sur_un_compteur_:_.C2.AB_CounTeR_.C2.BB_.28CTR.29) pour des questions de simplicité, le problème est identique en CBC mais nécessiterait d’aussi corriger le padding) :

{% highlight ruby %}
require 'openssl'

data = 'You win 1.000.000€'

cipher = OpenSSL::Cipher.new 'aes-128-ctr'
cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv
encrypted = cipher.update(data) + cipher.final

# Un attaquant modifie la version chiffrée
encrypted[8] = (encrypted[8].ord ^ 0x08).chr

decipher = OpenSSL::Cipher.new 'aes-128-ctr'
decipher.decrypt
decipher.key = key
decipher.iv = iv

plain = decipher.update(encrypted) + decipher.final
puts plain # You win 9.000.000€
{% endhighlight %}

Sans rien connaître du texte en clair, l’attaquant est capable de le modifier sans que cette modification ne soit décelable.
 
# AEAD à la rescousse

Afin d’authentifier plus fortement les données chiffrées, les cryptologues ont conçu un dernier mode de chiffrement : [AEAD](https://en.wikipedia.org/wiki/Authenticated_encryption) (Authenticated Encryption with Associated Data).
Dans le cadre du chiffrement, le mode AEAD le plus connu est sans conteste [GCM](https://en.wikipedia.org/wiki/Galois/Counter_Mode) (Galois/Counter Mode).

Je vous passe les détails techniques qui sont autrement plus complexes que les modes précédents, mais en l’utilisant, toute modification du contenu chiffré sera détecté, comblant cette lacune de CBC.

Si GCM n’est pas disponible dans vos bibliothèques de crypto, vous pouvez toujours vous en sortir avec CBC en mettant en place du [Encrypt-then-MAC](https://en.wikipedia.org/wiki/Authenticated_encryption#Encrypt-then-MAC_.28EtM.29) (EtM), mais la mise-en-œuvre est plus complexe (introduction d’une clef supplémentaire) et demande généralement de développer beaucoup de code cryptographique, alors que tout le monde sait que
![Roll your own crypto](/assets/images/20160303/own.png){:.center}

# Implémentation concrète 

Implémenter du chiffrement correct n’est pas si simple.
La difficulté vient du fait qu’on ne doit jamais réutiliser la même clef de chiffrement ni le même IV.
La clef de chiffrement ne doit en plus jamais être communiquée au public (alors que l’IV peut l’être).
Et en pratique, on souhaite pouvoir déchiffrer les données en s’échangeant uniquement un mot de passe.

On peut régler tous les problèmes à partir d’une dérivation de clef [PBKDF2](https://fr.wikipedia.org/wiki/PBKDF2).
Partant du mot de passe, d’un sel généré aléatoirement et d’un nombre d’itérations, on peut calculer 2X bits aléatoire en calculant `random = PBKDF2(password, salt, iterations, 2X)` (en pratique, X = 128 ou 256). 
Ces 2X bits sont ensuite découpés en X bits de clef de chiffrement et X bits d’IV `key, iv = random[0..X], random[X..2X]`.
Cette procédure garantie au passage que la clef et l’IV ne seront jamais réutilisés puisque à mots de passe identique, le sel sera différent donc la clef et l’IV aussi.
On peut ensuite chiffrer proprement avec AES-X-GCM `ciphered, tag = AES(X, GCM).encrypt(plain, key, iv)` (`tag` étant les données d’authentification calculées par GCM).
Les données chiffrées sont alors `(iteration, salt, tag, ciphered, X)`, qui peuvent être communiquées à qui de droit (sérialisez ça comme vous le sentez).

Le déchiffrement se passe en inversant tout le processus.
À partir du sel et des itérations des données et du mot de passe échangé de manière sécurisée, on peut en déduire les 2X bits de données aléatoire qui donneront la clef et l’IV par le même procédé que précédemment.
On procède ensuite au déchiffrement des données via `plain = AES(X, GCM).decrypt(ciphered, key, iv, tag)`.

Pour ceux qui préfèrent du bon code :

{% highlight ruby %}
require 'openssl'

def generate_salt(size)
	OpenSSL::Random.random_bytes size
end

def derive_password(password, salt, iterations, size)
	OpenSSL::PKCS5.pbkdf2_hmac_sha1 password, salt, iterations, size
end

def derive_key_iv(password, salt, iterations, block_size)
	random = derive_password password, salt, iterations, 2*block_size
	[random[0...block_size], random[block_size...2*block_size]]
end

def cipher(block_size)
	# Bug on OpenSSL ruby extension, OpenSSL::Cipher::AES.new(block_size, :GCM) doesn’t work…
	# See https://stackoverflow.com/questions/24619503/ruby-unsupported-cipher-algorithm-aes-256-gcm
	OpenSSL::Cipher.new "aes-#{block_size}-gcm"
end

def encrypt(data, password, salt_size = 16, iterations = 20000, block_size = 128)
	salt = generate_salt salt_size
	cipher = cipher block_size
	key, iv = derive_key_iv password, salt, iterations, block_size

	cipher.encrypt
	cipher.key = key
	cipher.iv = iv
	encrypted = cipher.update(data) + cipher.final
	tag = cipher.auth_tag
	[iterations, salt, tag, encrypted, block_size]
end

def decrypt(data, password)
	iterations, salt, tag, encrypted, block_size = data

	decipher = cipher block_size
	key, iv = derive_key_iv password, salt, iterations, block_size

	decipher.decrypt
	decipher.key = key
	decipher.iv = iv
	decipher.auth_tag = tag

	decipher.update(encrypted) + decipher.final
end

data = 'Very sensitive content !!!'
password = 'password'
encrypted = encrypt data, password
p encrypted # [20000, "4\x03@\xB3\tBi\xC9\x04\x9D\x15\x91x\xBAiK", "\xB2\xEF\x0E\x96\xF8Vi\e\x0E\xC7\xF8\xFA\xB3\xA8e\x98", "&\x0E\xA4[\xFF\x99\x12\x91\xD5h\x9B\xF3\x05\xC8\xB0q\xDB\xDE\xC9o\xA5\xBC\xC7y\\]\xB3", 128]
plain = decrypt encrypted, password
puts plain # Very sensitive content !!!
{% endhighlight %}
