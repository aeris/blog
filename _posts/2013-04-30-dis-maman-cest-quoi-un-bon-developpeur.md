---
title: Dis Maman, c’est quoi un bon développeur ?
---

Récemment, une nouvelle école a été fondée par Xaviel Niel, [42](http://www.42.fr/).
L'ambition annoncée de cette école est d'enfin en finir avec les problèmes de l'éducation actuelle en France et de former de vrais développeurs à même de survivre dans le monde actuel.<br/>
Le programme de cette nouvelle école est assez clair : former des warrior développeurs, des bêtes entraînées à survivre dans les environnements de dev les plus arides, engloutissants chaque jour des millions de lignes de code et anéhantissant tout bug osant se dresser sur leur passage.

Suite à cette annonce, pas mal de débats ont surgi un peu partout sur la Toile, remettant en cause le postulat de base de cette école qu'il faut des Dieux de la ligne de code pour assurer notre futur.

Mon avis sur la question.

# Un environnement vaste et mouvant

Aujourd'hui, il ne se passe plus un mois sans voir sortir un nouveau langage ou un nouvel environnement.
Beaucoup vont être très éphémères, mais certains vont s'ancrer plus profondément et perdurer.<br/>
On peut citer [Dart](http://www.dartlang.org/), [Go](http://golang.org/), [Fantom](http://fantom.org/).<br/>
Et même sur des langages existants depuis des lustres, des langages alternatifs apparaissent, tels [Coffeescript](http://coffeescript.org/), [SASS](http://sass-lang.com/) ou [XTend](http://www.eclipse.org/xtend/).

Idem au niveau environnement de travail, entre le cloud ([Heroku](https://www.heroku.com/), [OpenStack](http://www.openstack.org/)), la problématique [Big Data](https://fr.wikipedia.org/wiki/Big_data) ou encore les nouveaux IDE (en ce moment, le phénomène [SublimeText](http://www.sublimetext.com/)), les changements sont très rapides et difficiles à anticiper.

Je ne peux donc pas concevoir qu'un développeur n'ait bâti ses compétences que sur des méthodes qui datent de déjà plusieurs années.
Et même une fois sorti d'école, il faut qu'ils soient complètement autonomes pour s'auto-former au monde qu'ils vont rencontrer.<br/>
Il faut donc former les étudiants sur des méthodes de travail et non des outils et que les environnements rencontrés au cours de la formation soient clairement mentionnés comme un simple exemple ou une implémentation d'un concept plus général.

À titre d'exemple, connaître la documentation complète de [Hibernate](http://www.hibernate.org/) c'est très bien sur le principe.
Mais connaître le concept d'[ORM](http://fr.wikipedia.org/wiki/Mapping_objet-relationnel) qui se cache derrière, ça permettra à ce même développeur de passer sans problème sur [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) pour [Ruby on Rails](http://rubyonrails.org/).<br/>
Ceci est d'autant plus vrai que sur 99% des projets sur lesquels nous sommes amenés à travailler, nous n'avons pas besoin de connaître tous les détails techniques d'une techno, sa simple utilisation basique telle qu'enseignée dans n'importe quel tutorial suffira.

Lors des entretiens d'embauche que je suis amené à réaliser, **je préfère donc largement une personne qui saura parler d'un détail technique de manière très généraliste plutôt qu'une qui ne fera que m'étaler une seule implémentation de cette technique**.<br/>
Être capable de citer une ou plusieurs technos correspondantes n'est qu'un plus, pas une obligation.

# Des technos simples, mais un environnement complexe

On n'a que très rarement besoin de mettre les mains en profondeur dans une libraire utilisée sur un projet.
On se contente généralement de l'utiliser simplement, comme l'indique son manuel, avec en prime un peu d'expérience sur quelques paramètres bien pratiques ou un raccourci qui nous fera gagner un peu de temps.

La complexité provient que les librairies utilisées vont très vite se compter par dizaine voire centaines même sur un projet de taille modeste.<br/>
Sur un projet JEE, on va vite se retrouver avec du [Spring](http://www.springsource.org/), de l'Hibernate, du [SLF4J](http://www.slf4j.org/), [Tomcat](http://tomcat.apache.org/), [PostgreSQL](http://www.postgresql.org/), sans oublier des outils autour de tout ça comme [Maven](https://maven.apache.org/), [Jenkins](http://jenkins-ci.org/) ou encore [Git](http://git-scm.com/) et [Gerrit](http://code.google.com/p/gerrit/).

Alors que chaque librairie prise indépendamment trouve son petit tuto bien ficelé en 10 minutes sur Internet ou un bouquin de 500 pages qui la décrit en long en large et en travers, trouver une source d'information correcte qui mettra en œuvre en même temps toutes les technos d'un projet relève du miracle.

Un bon exemple est de mettre en place Spring et Hibernate ensembles, et de corser le tout en ajoutant un soupçon d'intégration et de déploiement continus, avec des confs qui s'adapteront automatiquement à l'environnement visé (H2 pour les tests, PostgreSQL pour la prod, l'embarquement de la conf de prod dans les exécutables et setups sans impacter les tests U, etc).<br/>
Si le développeur qui va mettre ça en place n'a vu que chaque morceau indépendamment, il n'arrivera pas à mettre en place l'environnement complet rapidement.

On a donc besoin de personnes ayant un angle de vue à 360°, qui ne se focalise pas sur un morceau en particulier, mais qui vise au contraire un objectif et un système global.<br/>
Avec **un bagage technique généraliste le plus vaste possible, capable de s'adapter à n'importe quel environnement, du plus simple au plus complexe**.<br/>
Et surtout avec des compétences annexes au code, comme l'intégration continue, les outils de build ou encore la gestion de configuration.

# Des chirurgiens, pas des bouchers

À mon avis le point le plus important.<br/>
Développer un logiciel, c'est tout sauf de l'automatisation et du pissage de code.

Face à un problème, je rencontre généralement deux types de développeurs.

  * Les bouchers du code
  * Les chirurgiens de l'architecture

Le boucher va passer en mode zombie jusqu'à trouver une solution ultra-pointue, en jouant sur toutes les subtilités les plus tordus du langage, empiler des cascades de « if » et autres jonglages de pointeurs.
Comptez sur lui pour ne relever la tête que quand il aura trouvé la solution.<br/>
Le problème, c'est que sa solution a de très fortes probabilités d'être la plus inmaintenable, la plus incompréhensible et la plus spécifique possible au problème à résoudre…

À l'opposé, le chirurgien va commencer par s'éloigner du problème, peut-être remettre en question certains choix techniques précédents.<br/>
Sa solution sera sûrement plus longue à trouver que celle du boucher, mais elle sera bien plus efficace, pérenne et prendra en compte toutes les caractéristiques du projet (intégration continue, environnement particulier…).

Une des grosses différences entre les 2 modes de fonctionnement, mis-à-part la qualité, sera surtout la robustesse de la solution trouvée.<br/>
La 1ère solution-boucher ne corrige généralement que la partie visible du problème, et la partie invisible ressurgira au cours du reste de la vie du projet.
Et le développeur repassera en mode bourrinage pur et dur…<br/>
Dans le 2nd cas de la solution de chirurgien, le problème sera fixé et bien fixé, y compris sur la partie invisible.
Le développeur pourra vaquer à d'autres occupations le jour où une nouvelle contrainte apparaîtra sur le projet et que la solution trouvée s'avérera robuste à ce changement.

Au final, connaître tous les tricks les plus improbables des langages les plus farfelus n'apporte pas grand chose sur un projet, sinon gagner quelques pouillièmes à très court terme qu'on se fera une joie de reperdre avec un gros coeff multiplicateur peu de temps après.<br/>
**Trouver une solution pérenne demande surtout du bon sens et du pragmatisme, pas du bourrinage pur et dur.**

# Conclusion

On récapitule.

  * Les technos sont extrèmement mouvantes : impossible de dire qu'on les maîtrise quand on a appris sur des choses qui sont déjà obsolètes à la sortie de l'école, et qu'on maîtrisera les futurs innovations quand on n'a pas vu la généralité cachée derrière
  * Les projets sont complexes et mettent en jeu beaucoup de technos qu'il faudra intriquer correctement ensemble : impossible de dire qu'on est formé à tous les cas possibles et imaginables qui se présenteront à nous
  * Jouer les guerriers sur des systèmes aussi sensibles que des systèmes informatiques, c'est comme tirer à l'arme atomique pour dégommer un moustique, le moustique est bien mort mais il y a un peu de dommages collatéraux sur les bords
 
Un bon développeur, c'est donc avant tout quelqu'un avec un bon bagage généraliste, axé code mais pas que, capable de monter une architecture regroupant plusieurs technos et pour finir qui va avant tout réfléchir avant d'agir, et sortir des solutions pérènes et viables.

Et pour ça, je pense que les écoles publiques Françaises forment déjà de très bonnes graines de développeurs, avec de très bonnes formations généralistes.<br/>
Il ne manque qu'un peu plus de pratique de la réflexion plus haut niveau sur de vrais environnements techniques complets.
Une direction que semble prendre l'initiative [Upstream University](http://upstream-university.org/) par exemple !


