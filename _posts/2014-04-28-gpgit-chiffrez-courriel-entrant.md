---
title: ! 'Chiffrez vos courriels entrants : GPGIt'
---

# Présentation

« Le chiffrement c'est maintenant ! » Après l'affaire Snowden et tant d'autres, c'est un peu ce que tout le monde devrait avoir à l'esprit en ce moment.
Malheureusement en pratique, les personnes qui utilisent GPG pour chiffrer leurs courriels ne représentent encore qu'une infime partie des utilisateurs…

Ce qui pose problème et qu'on a généralement tendance à oublier, c'est que dans toute communication, il y a un auteur… et un ou plusieurs destinataires !
Ce n'est pas parce que moi, auteur, je n'ai pas envie de faire attention à ma vie privée et/ou que je n'ai pas l'impression de pouvoir être une cible intéressante pour la NSA qu'il en est de même pour les personnes avec qui je souhaite correspondre.
Et malheureusement, beaucoup de personnes n'y pense pas…
Au final, je me retrouve avec 99% de mon courriel entrant en clair, sans aucun chiffrement. Et moi je n'en ai pas du tout envie !!!

J'ai donc du me mettre à développer une solution de chiffrement de tout mon courriel entrant.
Si un courriel arrive à mon serveur en clair, il est automatiquement chiffré par GPG.
Ainsi, tout mon stockage des courriels sur mes disques est chiffré, et un accès physique aux machines en question ne remet pas en question la sécurité de mes données.
Vous pouvez saisir mes machines, vous n'aurez au mieux qu'un joli tas de bits aléatoires.

Je suis parti d'[une idée de Mike Cardwell](https://grepular.com/Automatically_Encrypting_all_Incoming_Email).
La solution qu'il propose fonctionne mais ne traite pas tous les cas.
En particulier, elle a tendance à casser les signatures GPG des courriels juste signés sans chiffrement.
Et elle est développée en Perl.
Et chiffre tout le trafic directement à la réception, donc fait l'hypothèse d'un destinataire unique sur le serveur.
J'ai donc implémenté [ma propre version de GPGIt](https://gist.github.com/aeris/7858418#file-gpgit-py), en Python cette fois, et en l'intégrant avec [Sieve](https://fr.wikipedia.org/wiki/Sieve), ce qui me permet d'avoir un contrôle très fin du chiffrement et des clefs à utiliser.

Le comportement du chiffrement est le suivant :

  * Courriel en texte clair → chiffrement en PGP/inline
  * Courriel signé avec PGP/inline → pas de modification **<u>/!\\ Stocké en clair /!\\</u>**
  * Courriel chiffré avec PGP/inline → pas de modification
  * Courriel signé et chiffré avec PGP/inline → pas de modification
  * Courriel MIME → chiffrement en PGP/MIME
  * Courriel signé avec PGP/MIME → chiffrement en PGP/mime, avec signature valide
  * Courriel chiffré avec PGP/MIME → pas de modification
  * Courriel signé et chiffré en PGP/MIME → pas de modification

Les seuls courriels que ce système ne peut pas chiffrer sont les courriels reçus signés avec GPG en mode « inline », puisque GPG ne permet pas un chiffrement par dessus sans casser la validité de la clef.
En même temps, un utilisateur de PGP/inline devrait être brûlé en place publique, et devrait plutôt utiliser PGP/Mime (voir [ici](http://www.phildev.net/pgp/pgp_clear_vs_mime.html)).
Le courriel sortant n'est pas non plus chiffré automatiquement pour le stockage, mais je réfléchis à une solution.
Enfin, chiffrer ses courriels, c'est cool, mais ça casse plus ou moins la plupart des lecteurs de courriels hors clients lourds.
Adieu webmail, application mobile et lecteur ne supportant pas GPG !
Ça a quand même comme effet bénéfique de ne plus permettre de lire ses courriels depuis n'importe où.
Pour ma part, j'utilise [Kontact](http://userbase.kde.org/Kontact/fr), qui
  intègre GPG nativement.

# Installation

Mon serveur de courriels est une bonne vieille Debian Wheezy, avec [Postfix](http://www.postfix.org/) pour la réception et l'envoi des courriels, et [Dovecot](http://www.dovecot.org/) pour le stockage et la consultation (IMAP).
GPGIt nécessite d'avoir Sieve actif, ainsi que le plugin [Extprograms](http://wiki2.dovecot.org/Pigeonhole/Sieve/Plugins/Extprograms) pour Sieve autorisant l'exécution de commandes comme action d'un filtre.
J'utilise [PyMe](http://pyme.sourceforge.net/) pour le chiffrement GPG, les parties traitement du courriel et gestion MIME étant fournies en standard avec Python.

Les paquets installés qui nous intéresse ici :

 * postfix : 2.9.6-2
 * dovecot-core : 1:2.1.7-7
 * dovecot-sieve : 1:2.1.7-7
 * python2.6 : 2.6.8-1.1
 * python-pyme : 1:0.8.1-2

Sous Debian Wheezy, le plugin Extprograms n'est pas encore disponible dans les dépôts, aussi il faut le compiler à la main :

	apt-get install dovecot-dev
	hg clone http://hg.rename-it.nl/pigeonhole-0.3-sieve-extprograms/
	cd pigeonhole-0.3-sieve-extprograms
	./autogen.sh
	./configure --with-dovecot=/usr/lib/dovecot
	make
	cp src/.libs/lib90_sieve_extprograms_plugin.so /usr/lib/dovecot/modules/sieve/lib90_sieve_extprograms_plugin.so

Ensuite, il faut configurer Dovecot pour activer le plugin, et indiquer quel répertoire est autorisé pour l'exécution des commandes :

	# /etc/dovecot/conf.d/90-sieve.conf
	plugin {
		…
		sieve_plugins = sieve_extprograms
		sieve_filter_bin_dir = /usr/lib/dovecot/sieve-filter
		sieve_extensions = +vnd.dovecot.filter
		…
	}

On finit en copiant GPGIt au bon endroit :

	wget https://gist.githubusercontent.com/aeris/7858418/raw/ad339b67a476177d1b2eb2b864e7ac207751944a/gpgit.py -O /usr/lib/dovecot/sieve-filter/gpgit

Pour ceux qui voudraient s'assurer d'avoir reçu le bon fichier, la petite vérification de la signature GPG qui va bien :

	gpg --recv-key ECE4E222
	gpg --verify - /usr/lib/dovecot/sieve-filter/gpgit <<EOF
	-----BEGIN PGP SIGNATURE-----
    Version: GnuPG v1

    iQIcBAABCgAGBQJTXtpMAAoJECAWrwIKfDZo+bkP/1UU3CCoLy8dGRIFxho7ilsF
    xL2CQ5VSi19xvekFa/VUEqhVOq5yH3iZjffLreUf85fb/XEqR7dPpMRqWKZfbviU
    fASSJMJpGEzqUgVx9CymlrcsmHQpNGcBjkhDQ4bAmuKqvrsAG5wzEnzDKchGrarI
    VJgLRWnWc/cMwgeUIBaGzVVDQGDix8KokxepBHo9MghEWGi15yGYGG7j+NsMDvec
    45qu5yX2ISWi64G4uakoh6xfVLES62TJwKtjCr9EIatxyuYB5/s70tHJd3N91q+i
    td7fbc6GU/VRjQam0LZtI5yE69wHQMTrQPWWmg98qI5rJ1XhPkzxcI76mZRP/dXy
    K/JkyarIOh4wcRybb292t+jVsTXC1bABYa2Mn/VBP+uV+tSzQZelPm4iF+XY6IKA
    9YzuyZHPwM0xdaBtl4jndI67mz8KATHUU8mV91rGgo+gLIOB+E6tCjO7MLzSJO94
    hk58pzxFHtc2cOqMtieh9aV6k53lce3zwSFOmT5zS/G46U8q9FhpBU1WYQqK/ygm
    xshpB8AH7PBdleUy617xS07lpeBKoFSVx7qVU1KtAQIafnM3TDXt/42KspknAx/p
    V0jlXxui83/VFcTnHGjkpd+20tUZ8jCbB0s/qooJOQmt+DO1aF8Ytjneo4p7H0mc
    u5XYsuuBeaN8FEjWhhqP
    =dtOd
    -----END PGP SIGNATURE-----
    EOF

Ensuite, il ne reste plus qu'à configurer Sieve pour chiffrer le trafic entrant.
Dans mon cas, c'est simple, tout ce qui rentre passe par la moulinette du chiffrement :

	# ~/.sieve/filters.sieve
	require ["vnd.dovecot.filter"];
    # rule:[GPGit]
	filter "gpgit" ["ECE4E222"];

Pensez à importer votre clef publique dans le trousseau du serveur :

	gpg --recv-key ECE4E222

Et voilà, du bon courriel tout chiffré sur les disques !
