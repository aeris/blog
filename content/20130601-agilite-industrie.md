Title: Agilité : et l'industrie alors ?
Date: 2013-06-01
Category: dev
Tags: agile

[Les méthodes agiles](https://fr.wikipedia.org/wiki/Méthode_agile), le grand sujet du moment dans le monde du développement !<br/>
Arrivées au début des années 2000, ces méthodes de travail ont été un véritable séisme par rapport aux méthodes précédentes.

En raccourci, cette méthode met la collaboration client/fournisseur beaucoup plus en avant et met fin à l'habituel carcan contractuel.
Le but d'un projet n'est plus de répondre à un cahier des charges initial gravé dans le marbre, mais d'obtenir un produit fonctionnel qui répond aux besoins du client, y compris si celui-ci change d'avis ou fait apparaître de nouveaux besoins en cours de route.

Pour cela, le monolitique [cycle en V](https://fr.wikipedia.org/wiki/Cycle_en_V) laisse place à de multiples phases itératives de développement (les sprints) et les retours clients sont ainsi pris en compte au plus tôt.

Tout semble beau dans le meilleur des mondes… en tout cas dans le domaine du tertiaire ou du web !<br/>
Personnellement, je travaille dans le domaine industriel (aéronautique, ferroviaire, militaire…), et j'ai vite été confronté à des problèmes métaphysiques avec l'application des méthodes agiles dans de tels environnements.

# Un produit minimum viable pas si minimal que ça

Première bonne pratique amenée par les méthodes agiles : être capable de livrer fréquemment (toutes les 2 à 4 semaines maximum) une application fonctionnelle au client (comprendre aux utilisateurs finaux), application qu'on doit être capable de déployer et tester en conditions réelles.<br/>
Autant sur du long terme, je n'ai pas trop de problème avec ce concept, autant le premier spring, sauf à le faire durer des mois, j'ai souvent du mal à voir comment m'en dépêtrer.

L'agilité est très souvent sinon exclusivement présentée dans un contexte web, comme des sites d'e-commerce, de reporting, de gestion…<br/>
Dans un tel contexte, on peut assez facilement retirer des morceaux sans pour autant rendre le logiciel inutile.

Prenons l'exemple d'un site d'e-commerce standard. C'est quoi l'utilisabilité minimale du point de vue utilisateur final ?

  * Naviguer parmi les produits
  * Sélectionner des produits
  * Passer commande

Tout ceux qui ont déjà fait du web une fois dans leur vie voient rapidement qu'en 3 semaines, on va pouvoir mettre ça en place sans aucun souci !<br/>
Démonstration faite à des collègues et assisté des bons outils (Rails ou Groovy), je met même moins de 2h…<br/>
Certes, ça sera moche (et encore, le template par défaut de Groovy est loin d'être répugnant) et assez limité en terme d'ergonomie et de fonctionnalités, mais c'est utilisable par un Monsieur Michu standard et ça répond à la problématique.<br/>
Et surtout, je peux déjà mettre ça en production, le présenter à mes utilisateurs, qu'ils me fassent leurs premiers retours sur l'application…

Passons dans le monde industriel auquel je suis confronté tous les jours, avec l'exemple d'une application de gestion des consignations électriques sur une ligne de métro.
Le besoin minimal tient en trois lignes qui tiennent du bon sens :

  * On ne fait pas travailler les gens avec le 750V allumé
  * On ne fait pas passer les trains là où il y a des gens qui travaillent
  * On doit avoir du courant pour faire passer les trains

Si je supprime une seule ligne, l'application est inutilisable :

  * Saucisse grillée au petit déj
  * Tartare bien saignant au déjeuner
  * Jeun au dîner

Si on veut que l'utilisateur puisse tester l'outil, il faut donc a minima :

  * Avoir une interface graphique
  * Avoir une ligne de métro (portions de voie et équipements électriques)
  * Pouvoir saisir des trains et les faire se déplacer
  * Pouvoir saisir des demandes de travaux
  * Pouvoir changer la tension sur les voies
  * Tous les algos de calcul de la tension
  * Tous les algos des trois règles de gestion

Aïe, on sent bien arriver le problème…<br/>
Pour avoir quelque chose qu'un développeur puisse utiliser rapidement, pas de souci, il attaquera la base de données en direct ou une ligne de commande lui conviendra parfaitement. Et il saura se contenter d'un « algo qu'on améliorera après ».<br/>
Pour pouvoir mettre l'application dans les mains des utilisateurs finaux, qui utilisent depuis 30 ans un truc ultra-complexe appelé « feuille-crayon-gomme », y'a pas, il faudra vraiment une vraie interface graphique avec la vraie saisie finale.
Et la moindre erreur d'algorithme (type remake de Spiderman qui arrête un métro, sauf que cette fois, le métro, il gagne…), vous pouvez être sûr que vous perdez définitivement la confiance de votre client !

Le produit minimal viable, je ne sais pas pourquoi, mais dans un contexte non web et/ou industriel, il tend franchement vers un truc qui ressemble à l'application finale…<br/>
Et tout sous-ensemble de l'application donne un truc peu voire pas utilisable par un utilisateur standard ou ne démontrant rien de ce que sera l'application finale, donc avec un retour client d'utilité quasi-nulle pour l'équipe de développement.<br/>
On se retrouve avec un paquet de taches classées *important-que-si-on-n-a-pas-l-appli-nous-sert-à-rien*, qui demandent un gros travail de développement et qui sont indissociables pour avoir une application un minimum présentable et surtout utilisable par le client.

# « On t'a dis trois parts, Obélix ! »
## La difficulté du développement itératif

Autre bonne méthode agile : faire du développement itératif, qui ajoute des fonctionnalités à ce qui a été obtenu à l'itération précédente.

Les applications web ont toutes un gros point commun : les fonctionnalités se résument très souvent à du [CRUD](https://fr.wikipedia.org/wiki/CRUD).
Les différents frameworks existants ([Ruby on Rails](http://rubyonrails.org/), [Grails](http://grails.org/), [Spring Roo](http://www.springsource.org/spring-roo)…) sont d'ailleurs exclusivement orientés CRUD, avec de la génération automatique des différentes pages standards d'une telle application.

Les applications orientées CRUD, telles qu'un site d'e-commerce, il est facile de les construire par morceau.<br/>
Je commencerai par **une seule** table *produit*, avec les pages de création/édition/liste/suppression associées.
Ensuite je ferais **une seule** table *caddy*, avec les pages associées, qui n'impacte pas ma table *produit* existante.
Après il y aura **une seule** table *commande*, toujours avec ses pages de CRUD, qui ne touche encore une fois aucune des tables existantes.<br/>
Il est alors facile de construire l'application petit-à-petit, en jouant aux poupées russes : chaque itération de développement enrichi l'itération précédente, sans tout remettre en question.

Côté industriel, les structures de données sont généralement complexes.
Il m'arrive de travailler sur des XSD de 30.000 lignes, des fichiers tableurs de 200 feuilles et 80Mo ou des bases de données de 250 tables, 3.000 colonnes et 1.200 relations.<br/>
Cette complexité est normale, un caddye de supermarché ou une gestion de stock ne se décrit pas comme une centrale nucléaire, une ligne de métro ou un A380 !<br/>
Il est du coup difficile d'arriver à construire l'étape N sans remettre en question l'étape N-1, ou en tout cas sans nécessiter sa revalidation intégrale, et nécessite en plus beaucoup d'itérations courtes pour arriver uniquement à bout du modèle de données.<br/>
Et encore une fois, les étapes intermédiaires ne signifient strictement rien pour le client final, ne donnent pas une application présentable.
Pire, l'étape finale après plusieurs itérations (donc mois) de travail ne représentent **que** le modèle de données, sans aucune interface ni autre applicatif.

## La plus-value : le comportement, pas les données

Sur les applications industrielles, l'essentiel n'est pas le CRUD, mais le comportement derrière.<br/>
Saisir un train ou une demande de travail, c'est du CRUD, ça va vite.
Gérer toutes les règles de gestion derrière, ça devient franchement plus galère.<br/>
La plus-value des logiciels industriels n'est que très rarement la saisie de la donnée en elle-même, mais surtout tout ce que ça implique derrière, en terme de contrôle, validation, application des règles du métier…

Ceci fait qu'au final, les données y restent relativement statiques (c'est assez rare de modifier une ligne de métro). Mais les dépendances entre données va vite devenir anarchique et va empécher le développement en couche.<br/>
Si je commence par développer ma saisie des trains, et ensuite ma saisie de demande de travail (qui contrôle qu'il n'y a pas de train), je serai ensuite obligé de revenir sur mes trains pour les faire tenir compte des demandes de travaux. Inversement si je commence par les travaux.<br/>
Et en prime là, on ne parle que de l'application minimale, imaginez maintenant si je vous ajoute la gestion des équipements en panne qui impactent les trains et les travaux, les travaux « de test » qui nécessitent la présence de courant, les trains diesel qui n'en nécessitent plus, la possibilité pour EDF de gérer le courant sur certains équipements…<br/>
Vous voyez un chat devant une pelote de laine ? Ben ça finit pareil !

Les applications qui sont souvent prises en exemple pour appliquer de l'agilité sont au final orienté *C__D* (ajouter un produit, supprimer une commande…),
avec les modifications pouvant très bien être simulées par une suppression suivit d'une insertion sans perturber le fonctionnel.<br/>
Alors que le monde industriel sera essentiellement *\_RU\_* (faire avancer un train, changer l'état d'un capteur…, mais pas ajouter une ligne TGV ou une centrale nucléaire !), et où un update doit réellement être un update (non non, tu ne supprimeras pas le capteur du cœur de réacteur !).

Tout ça mélangé, le cocktail est détonnant, avec une application minimale qui nécessite beaucoup de fonctionnalités, qui elles-mêmes reposent sur des développements longs, complexes et fortement inter-dépendants.<br/>
Triple effet tunnel, à la fois pour l'équipe qui passe des mois sur un nombre limité de taches, un client qui ne voit pas son application s'améliorer de jours en jours et tout le monde qui ne sait pas si ça fonctionnera au final.

Pour reprendre le titre de ce chapitre, une bonne grosse part qui représente 80% du gâteau… et on ne sait même pas s'il est empoisonné !

# Difficultés diverses
## Outillage

Les méthodes agiles mettent indirectement l'accent sur la qualité logicielle.
En effet, comme on doit livrer fréquemment, des choses fonctionnelles et en maîtrisant ce qu'on fait, il est plus que conseillé de mettre en place de l'intégration continue, des tests unitaires ou même une bonne gestion de conf.<br/>
Certains considèrent même que le seul manque de qualité sur un projet doit suffir à bloquer toute livraison et à mettre l'équipe à 100% sur la résolution du problème.

Oh, wait… On a déjà un début de projet avec des Epic difficilement découpables, sur des fonctionnalités minimales qui représentent 80% de l'outil, avec des dépendances dans tous les coins, on du mal à livrer des choses au client avant des mois, et en plus ça ne sera que des trucs pas forcément présentables et/ou représentatifs.<br/>
Et en plus il faudrait dire au client qu'on va commencer par passer du temps sur des trucs qui lui passent au moins à 42km au-dessus de la tête et qui va repousser d'autant un livrable fonctionnel, utilisable et représentatif ?<br/>
Eh, chef ? J'ai plein de congés à solder là, je peux, je peux ?

## Client lourd vs. client léger

Les interfaces web ([client léger](https://fr.wikipedia.org/wiki/Client_léger)) facilitent aussi la répartition du travail dans le temps.<br/>
Déjà, la structure même de HTTP et HTML permet d'ajouter des pages au fur et à mesure, sans remettre en cause les pages existantes et en pouvant anticiper les pages manquantes, au mieux on risque l'erreur 404, au pire l'erreur 500, mais dans tous les cas, un petit *précédent* dans le navigateur, et on reprend la route.<br/>
La séparation forme/contenu permise par HTML et CSS va aussi autoriser à finaliser l'application plus tard, à modifier la mise-en-page facilement, sans aucune intrusion lourde dans l'existant.<br/>
Et la testabilité est très bonne, il est facile de simuler un navigateur web ou un serveur web complet, même s'il existe des méthodes et outils bien plus efficaces.

Les applications industrielles sont essentiellement des applications [client lourd](https://fr.wikipedia.org/wiki/Client_lourd), type Swing ou SWT (les causes sont multiples, de l'interface avec du matériel, des contraintes sécuritaires ou encore le manque de confiance en le réseau).<br/>
Encore une fois, ça demande pas mal d'outillage initial, comme une machine à états pour gérer l'interface ou une certaine formation des développeurs.
Le code des IHM lourdes est aussi réputé pour être particulièrement peu qualitatif, faire virer au rouge cramoisi le moindre outil d'audit de code, et surtout non modulable au possible.
Côté maintenance et évolutivité, autant changer la couleur du texte ou la fonte par défaut d'un site web doit demander 10s et 2 lignes de code, autant je vous souhaite bien du courage en Swing ou pire en SWT pour arriver au même résultat… Personnellement, je considère même que les IHM lourdes sont la porte ouverte à toutes les demandes les plus délirantes de la part du client, alors qu'en environnement web, ils sont généralement plus posés et réfléchis.<br/>
Côté testabilité, les clients lourds tendent vers le 0 absolu ou une complexité infinie, se mettent à dépendre de la résolution de l'écran ou du contenu d'un bouton…

Encore une fois, on se retrouve avec un mur important à franchir au début du projet dans le cas de l'industriel, alors que la difficulté reste faible et constante dans les applications orientées tertiaire.

# Conclusion

Les méthodes agiles ont apporté de très bonnes pratiques, dont je ne pourrais plus me passer aujourd'hui.
Intégration continue, tests unitaires, qualité de code ou encore développement itératif, implication du client et adaptabilité, je suis 1000% pour, convaincu de l'utilité et j'applique tout ça sur mes petits projets personnels.<br/>
Seulement, la grande majorité des exemples pris pour appliquer une méthode agile est orienté web et application de gestion au sens large.

Sur des projets industriels, je n'ai aucun problème sur une vision long terme à me dire qu'une méthode type Scrum est applicable à 100%.<br/>
Une fois le produit minimal viable livré et déployé chez le client, oui, il est tout à fait possible de l'enrichir par itération, de prendre en compte ses nouveaux besoins ou corrections à apporter.

Mais sur toute la phase qui conduit à la livraison de ce PMV, la somme de travail *minimale*, *indivisible* et *représentative* est vite trop importante, et fait perdre tout l'intérêt de la mise en place de l'agilité, en tout cas d'un point de vue client, et ce d'autant plus qu'on voudra appliquer à la lettre les concepts agiles :

  * Livraison
    * Livrer fréquemment, c'est faire des embryons d'application sans intérêt pour le client
    * Faire un sprint de plusieurs mois, c'est laisser le client dans le noir total
  * Itération
    * Faire de l'itératif, c'est l'explosion des coûts et délais du à l'explosion exponentielle des dépendances
    * Faire du cycle en V, c'est l'effet tunnel assuré
  * Qualité
    * Mettre en place des outils, c'est se tirer une balle dans le pied niveau délai
    * Ne pas en mettre, c'est préparer la balle pour demain

Je compte sur mes deux collègues nouvellement Scrum Master pour me trouver une solution à ce problème existentiel !

NB : Pour avoir cherché à aborder ce problème lors de conférences, par exemple à la [DevoxxFr](http://www.devoxx.com/display/FR13/Accueil), la réponse obtenue a généralement été toujours la même : « Euh, wé, t'as peut-être raison… Mais sinon, tu sais que tu peux aussi démissionner et nous rejoindre, nous on a pas ce problème avec notre web de gestion ! ».<br/>
Je répondrai que si leurs serveurs web fonctionnent si bien, c'est peut-être grâce à une centrale nucléaire, et qu'ils sont peut-être venus à cette conférence en métro, en TGV ou en A380 :D
