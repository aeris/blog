---
title: Own-Mailbox, la réponse à la réponse
---

Suite [à mon article](own-mailbox-charlatanisme-ou-incompetence.html), Own-Mailbox [m’a répondu](https://www.own-mailbox.com/rep.html).
Et vu qu’ils ne semblent avoir rien compris aux problématiques exposées, je me permets une réponse à leur réponse.

Déjà, je me permets de signaler que je n’ai jamais été insultant ni agressif, j’essaie juste d’informer les utilisateurs
 que le discours **commercial** de Own-Mailbox est dangereux pour ses futurs acheteurs et que son discours **technique**
 est très limité.

Concernant le réseau, je connais parfaitement le protocole UPnP, et je sais aussi qu’il est totalement déconseillé par
 toute personne qui tient plus ou moins à la sécurité de son réseau.
En effet, ce protocole a pour objectif de permettre l’ouverture automatique de port sur la box ADSL à la demande d’un
 logiciel situé sur un autre ordinateur.
C’est donc un énorme trou de sécurité, toute machine infectée pouvant alors se publier seule sur Internet et typiquement
 exposer le port SSH que Own-Mailbox indique eux-même comme ne devant pas être exposé.
Ce protocole doit donc être désactivé chez tous les utilisateurs.

Pour le respect de la vie privée d’un point de vue réseau, je maintiens ma critique, étant donné que Own-Mailbox, dans
 le cas d’un tunnel de port, aura accès à vos méta-données, ce qui en fait une solution ni pire ni meilleure que GMail
 ou autre prestataire mail classique et n’est donc en aucun cas un argument de vente crédible.
C’est d’autant plus génant que, malgré ce que Own-Mailbox déclare, ils ont réellement la **possibilité** d’accéder à vos
 clefs privées, ce qui ne veut pas dire qu’ils le feront réellement, mais ce cas leur permettrait d’accéder au contenu
 de vos correspondances, ce que même GMail ne pourrait pas faire, ce qui rend Own-Mailbox pire que GMail dans ce cas.
Et comme dit dans leur réponse, on ne peut pas faire confiance à un tier de confiance… donc à Own-Mailbox eux-même :).

Sur le nom de domaine, comme je l’ai indiqué, Own-Mailbox a la **possibilité** de rediriger votre trafic mail là où ils
 le veulent. Ça ne veut pas dire qu’ils le feront, mais ils peuvent se faire eux-même pirater, ou être contraint par
 réquisition judiciaire (ou non) de le faire.
Ils n’améliorent donc pas la situation par rapport par rapport à la concurrence non plus, voire même font pire (vu
 qu’ils peuvent avoir accès à la clef privée aussi).  
Sur le même sujet, effectivement le DNS suppose la confiance en certains tiers, mais on peut limiter le plus possible
 cette confiance, par exemple en hébergent soi-même son DNS ce qui fait qu’on n’est plus dépendant que de votre
 [RIR](https://fr.wikipedia.org/wiki/Registre_Internet_régional), qui sont généralement des associations internationales
 donc très difficile à corrompre, en tout cas beaucoup plus que Own-Mailbox eux-même.
 
Pour GPG, le problème n’est pas que le certificat ou la clef soit extractible ou non mais qu’elle soit générée sur une
 machine hors du contrôle de l’utilisateur.
Le seul et unique endroit où peut et doit être généré du matériel privé, c’est directement sur la machine de l’utilisateur.
Tout autre solution la mettrait **potentiellement** accessible à un attaquant et est donc à proscrire.
Tout le monde est tombé sur la face de Google quand ils ont décidé de générer la clef privée de l’utilisateur, non pas parce
 que c’est Google mais parce que la pratique en elle-même est mauvaise.
On tape sur tous ceux qui fonctionneraient comme ça, Own-Mailbox compris.  
L’utilisation du logiciel libre ne suffit pas à garantir la sécurité, puisqu’il est actuellement très difficile voire
 impossible de garantir la corrélation entre le code-source publié et le logiciel réellement déployé.
Il existe bien des solutions type les
 [compilations reproductibles](https://2015.rmll.info/compilations-reproductibles-dans-debian-et-partout-ailleurs) mais elles
 sont très difficiles à mettre en place et souvent impossibles en pratique en particulier sur du matériel « spécial » (dont
 les Own-Mailbox puisque l’utilisateur n’a que très peu accès aux contenus du boîtier et pas du tout à son firmware).
Utiliser du logiciel libre est une condition nécessaire à une informatique de confiance, mais pas une condition suffisante.

Concernant l’implémentation de PGP dans Roundcube, je ne sais pas si ça me rassurerait qu’une équipe non formée à la
 cryptographie se lance dans ce type de travail.
La crypto est très difficile à mettre en œuvre et même les développeurs chevronnés du projet Tor évitent d’y toucher sans des
 audit de code par des scientifiques cryptologues et par une armée de pentesteurs divers et variés.  
Dans le cas particulier de Own-Mailbox, je maintiens en plus que PGP/MIME est inatteignable dans un webmail, puisque
 signifie soit l’utilisation de la clef privée côté serveur (ce qui est à proscrire d’après le point précédent) soit à
 utiliser du code Javascript côté client (ce dont le projet se refuse à faire d’après leur FAQ), et empècherait la lecture des
 mails sur mobile et tablette (ceux-ci ne le supportant actuellement pas) alors que Own-Mailbox annonce le support de ce type de
 matériel.
Il est donc impossible que Own-Mailbox implémente PGP/MIME, mais uniquement la version faible de GPG, PGP/inline.

Sur PLM, je maintiens mon argumentaire. Avoir un lien à usage unique ne permet pas de se protéger d’une interception par la NSA
 ou équivalent, ça sera même uniquement les espions qui auraient alors accès au contenu.
L’usage d’une question secrète peut potentiellement améliorer la situation, mais elle n’est documentée nul part et je n’en avais
 pas connaissance.
 
Pour la gestion courante, on ne peut et on ne doit faire aucune hypothèse sur l’état du réseau qui va environner la Own-Mailbox.
En particulier, on peut très bien imaginer une machine du réseau local qui soit infectée et qui va se mettre à brute-forcer le
 boîtier.
Ou encore une infection de la Own-Mailbox elle-même qui va alors publier ses ports théoriquement privés via UPnP…
Une machine dite sécurisée doit donc nécessairement se fermer au maximum, et doit alors nécessairement dépendre de la topologie
 du LAN ou de son plan d’adressage.

Pour les méta-données, le passage sur Tor est croustillant puisque mon article initial montre que Tor est techniquement
 inutilisable pour SMTP et le mail.
Même s’il était possible de le faire, on aurait de toute façon accès à l’émetteur et au destinataire, qui circulent en clair
 dans les entêtes lors de la sortie du réseau Tor au niveau du dernier nœud, IP disponibles ou non.
 
En conclusion, je n’ai rien contre le projet Own-Mailbox en tant que tel, c’est un projet qui ne fait ni pire ni moins bien
 qu’une solution tierce type ProtonMail ou Mailden, même si certains morceaux sont assez bordéliques niveau décentralisation
 et contrôle par l’utilisateur (nom de domaine, tunnel de port, génération de la clef SSH…).  
Le truc génant est le discours commercial associé, Own-Mailbox étant présenté comme une solution « 100% confidentielle »,
 et la plupart des personnes qui vont soutenir ce projet et acquérir un boîtier n’est attirée que par ce point de détail.
Il n’y a qu’à parcourir le net des articles qui touchent à ce projet, tous les commentaires des utilisateurs tournent autour de ce
 besoin.
Ils vont donc littéralement se faire flouer, ce point n’étant **pas** géré par Own-Mailbox à cause de tous les problèmes
 précédents.
Own-Mailbox est alors un projet **dangereux**, car il n’y a rien de pire qu’un faux sentiment de sécurité, et qu’un utilisateur
 du boîtier va un jour ou l’autre faire une connerie qui peut conduire à de graves conséquences.

Que ce projet retire définitivement la notion de sécurité et de vie privée de son business-modèle, ou tienne compte des remarques
 précédente et y trouve des solutions, et je n’aurais plus rien à y redire :)

*[Épisode 1]({% post_url 2015-09-25-ownmailbox-charlatanisme-incompetence %})* —
*[La conclusion]({% post_url 2015-09-27-ownmailbox-suite-fin %})*
