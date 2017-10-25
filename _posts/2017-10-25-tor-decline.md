---
title: Le réseau Tor a besoin de vous !
---

Un petit billet rapide pour vous signaler que le projet [Tor](https://www.torproject.org/) a besoin de vous !

Effectivement, le nombre de relais disponibles [est en chute libre depuis cet été](https://lists.torproject.org/pipermail/tor-relays/2017-October/013345.html), ce qui est assez inhabituel et pas forcément bon signe pour la suite…

![Tor metrics](/assets/images/20171025/metrics.png){:.center}

Ce réseau a donc besoin de vous pour allumer tout plein de nœuds et ainsi redresser la tendance !

Par contre, il ne faut pas se lancer dans cette aventure sans un minimum de précautions et de prérequis, dont voici une petite liste, en particulier si vous êtes français.

# Responsabilité juridique

En théorie, l’activité de gestion d’un relai Tor est protégée par la législation européenne et française et vous ne <s>pouvez pas</s> devriez pas pouvoir être poursuivi pour avoir opéré un nœud Tor, quel que soit le trafic que vous aurez relayé.

En effet, vous êtes protégé par l’article 12 de la [directive européenne 2000/31/CE du 8 juin 2000](http://eur-lex.europa.eu/LexUriServ/LexUriServ.do?uri=CELEX:32000L0031:Fr:HTML) ainsi que par sa transposition en droit français, l’[article L32-3-3 du Code des Postes et des Communications Électroniques](https://www.legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006465735&cidTexte=LEGITEXT000006070987).
Comme vous ne modifiez, filtrez ou sélectionnez pas ce qui passe par votre nœud, vous n’avez pas à endosser la responsabilité du trafic. En clair, vous avez exactement la même position que les opérateurs de réseau « classiques » type Orange, OVH, Level 3 et tant d’autres.

Il n’empêche qu’en pratique, il existe un risque non nul de subir des désagréments oscillants de [un peu génant](https://www.nextinpact.com/news/104302-wannacrypt-nuds-tor-saisis-par-autorites-francaises.htm) à [très fâcheux](https://twitter.com/corzntin/status/905146927951564801).
Il est donc conseillé d’avoir à sa portée l’adresse d’un avocat, si possible spécialiste du domaine, afin de le contacter rapidement en cas de problème. Personnellement, j’ai maintenant toujours le numéro d’[Alexandre Archambault](https://www.archambault-avocat.fr/).

Et on ne le rappellera jamais assez, en garde-à-vue

  1. Je garde le silence
  2. Je ne dis rien
  3. Je me tais
  4. Je demande à être assisté par un avocat
  5. Y compris si l’officier de police vous dit que ça ira plus vite sans

En effet, on est généralement dans une situation de stress ou en tout cas pas agréable, et donc on n’apprécie pas forcément correctement la portée de ce qu’on va dire et on peut complexifier sa défense par mégarde.

Ces situations délicates seront d’autant moins délicates qu’on sera nombreux à faire tourner des nœuds afin de rendre cette situation « normale » et non plus être perçus comme des criminels en puissance…

# Déclaration ARCEP

En France, les systèmes de communications électroniques sont régulés par l’[ARCEP](https://www.arcep.fr/), l’Autorité de Régulation des Communications Électroniques et des Postes.

En particulier, il existe une procédure vous permettant de vous [déclarer opérateur de communications électroniques](https://extranet.arcep.fr/portail/OpérateursCE/DéclarationL33-1/Déclarerenligneunnouvelopérateur.aspx).
Même si vous pouvez vous réclamer comme relevant de l’article 12 et de l’article L32-3-3 sans cette déclaration, avoir un tel statut officiel vous donnera toujours plus de poids pour faire valoir vos droits.
Ce statut protège aussi votre matériel car il ne sera plus saisissable sans une procédure spéciale (ça n’empêchera pas une éventuelle saisie, mais ça sera un motif de nullité en plus).

La procédure en elle-même n’est pas compliquée et est accessible à un simple particulier sans structure juridique type auto-entrepreneur ou entreprise, mais l’ARCEP n’ayant pas (encore) trop l’habitude de gérer une simple personne physique, il faut (souvent) la relancer pour obtenir le précieux sésame à la fin.

Le dossier à renseigner n’est guère compliqué, une lettre de demande (dont vous trouverez un modèle [ici](/assets/images/20171025/arcep.txt) si vous êtes en manque d’inspiration) et une copie de votre carte d’identité, et c’est tout.
Vous sélectionnez juste « (Autre) Personne physique », vous contournez l’obligation de saisie du RCS/SIREN en indiquant votre ville de naissance (après tout, c’est bien là qu’on est immatriculé 😂).

Après quelques échanges de courriel ou d’appels téléphoniques avec l’ARCEP qui n’arrive pas à comprendre qu’on est juste un gens normal personne physique sans entité morale ni statut administratif et qui ne comprend pas plus qu’on fait ça bénévolement et sans engagement auprès de nos « clients », vous devriez obtenir votre n° d’opérateur.

Soyez aussi conscient que votre identité ainsi que votre adresse postale sera publiquement accessible dans la base de données des opérateurs.

# Sélection du réseau

Le réseau Tor cherche avant tout à assurer une bonne diversité dans le réseau, afin d’éviter d’avoir trop de nœuds contrôlés/contrôlables par une même entité.
Ce qui éviterait par exemple qu’une unique perquisition chez OVH et Online conduise à la disparition des 10 plus gros nœuds d’entrée dans le réseau…

Avant d’allumer votre propre nœud, consultez [Metrics](https://metrics.torproject.org/bubbles.html) ainsi que [Atlas](https://atlas.torproject.org/) pour voir quels sont les gros hébergeurs actuels et éviter ainsi d’en allumer plus chez eux.

C’est un peu un problème de la quadrature du cercle qui se pose sur ce sujet, puisqu’un nœud Tor intéressant (*ie* avec une bande passante importante) est plus que très consommateur en trafic (comptez 100To de données par mois pour un nœud à 300Mbps…). Or, hormis chez quelques trop rares hébergeurs illimités comme OVH, Online ou Hertzner, la bande passante ou le trafic est bridé ou (très fortement) facturé (comptez entre 500 à 1000€/mois pour 300Mbps au prix actuel du marché).
Et donc tout le monde va mettre ses œufs dans les mêmes paniers…

Si vous avez la possibilité d’allumer votre nœud chez un [AS](https://fr.wikipedia.org/wiki/Autonomous_System) peu couvert actuellement, faites-le !

# Allumer le nœud

Afin de se prémunir d’un effet de bord (type une saisie du matériel), il est conseillé de faire tourner votre nœud sur une machine dédiée au nœud, et d’éviter autant que possible de le mélanger avec d’autres usages (Ou d’avoir des backups. Vérifiés. Avec un PRA. Vérifié).
Jusqu’à récemment, on considérait que les nœuds les plus exposés aux ennuis étaient les nœuds de sortie, mais l’affaire Renault/Wannacry a montré que tous les nœuds sont susceptibles d’être impactés.
Du plus risqué au moins risqué : exit, guard & bridge (ou plus exactement toute machine susceptible d’être directement contactée par un client Tor, comme par exemple les [fallback directories](https://trac.torproject.org/projects/tor/wiki/doc/FallbackDirectoryMirrors)) et enfin middle.

Toujours en vue d’éviter les problèmes, il est fortement recommendé de chiffrer intégralement le disque qui fera tourner votre nœud.
Si vous utilisez un serveur dédié ou un VPS, vous pouvez vous inspirer de [ce billet]({% post_url 2017-07-22-stockage-chiffre-serveur %}) pour le faire à distance.

Vous pouvez ensuite passer à [l’installation proprement dite]({% post_url 2015-09-22-installer-noeud-tor %}) de votre nouveau nœud.

Et enfin, toujours pour limiter la casse en cas d’effet de bord, vous pouvez durcir votre configuration pour [utiliser des clefs d’identités offline](https://trac.torproject.org/projects/tor/wiki/doc/TorRelaySecurity/OfflineKeys) et ainsi éviter qu’on puisse trop longtemps usurper l’identité de votre nœud en cas de saisie !
