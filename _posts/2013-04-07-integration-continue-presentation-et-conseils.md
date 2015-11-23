---
title: Intégration continue, présentation et conseils
---

Allez, cette semaine, un tour d'horizon de ce qu'est l'intégration continue et quelques conseils et bonnes pratiques pour se faciliter sa mise en place.

# Qu'est-ce que c'est et pourquoi

L'intégration continue… Vaste chantier en perspective.<br/>
Pour ceux qui étaient sur Mars ce week-end, envisager aujourd'hui de mener un projet sans intégration continue, c'est un peu comme essayer de cuisiner sans casserole. Certes on peut le faire, mais le résultat risque d'être… très médiocre !

Grosso-modo, [l'intégration continue](http://fr.wikipedia.org/wiki/Int%C3%A9gration_continue) (ou continuous integration, ou CI de son petit nom) est un ensemble de méthodes et processus qui permettent de suivre en temps réel l'évolution de l'avancement et de la qualité d'un projet.

Elle repose énormément sur l'automatisation de la chaîne de développement.
Nettoyage, compilation, exécution des tests, génération de rapport, analyse des métriques du code…
On automatise le plus possible, et on délègue à une machine de rejouer tout ça sur chaque commit dans [la gestion de configuration](http://fr.wikipedia.org/wiki/Logiciel_de_gestion_de_versions).

Les avantages sont multiples.

On commence par fortement **diminuer les erreurs** possibles via l'automatisation.<br/>
La plus grosse source d'erreur dans un projet informatique, c'est généralement l'humain.
Je ne compte plus les problèmes de livraison d'un projet (qui en plus arrive généralemement un vendredi vers 20h…), que ça soit l'oubli de l'incrément de version, la pose du tag en gestion de conf, la compilation en mode  *développement* au lieu du mode *production*.
Quand ce n'est pas le développeur qui ne sait tout simplement pas comment faire une release !<br/>
Si l'ensemble de la chaîne est automatisée, plus de risque d'erreur, plus de dépendance à une personne en particulier, et plus de surprise le lundi matin dans la boîte mail !

Les erreurs et régressions sont aussi **plus vite détectées**.<br/>
Sans intégration continue, on passe par une chaîne <s>standard</s> archaïque de tests.
Les développeurs doivent faire une livraison complète, la donner à l'équipe de validation, qui l'enverra au client… qui viendra nous taper sur les doigts car il y a une régression.
La chaîne complète peut facilement prendre des semaines.<br/>
Avec une bonne CI, chaque commit relance l'intégralité des vérifications, et on a un retour rapide (de l'ordre de la demie-journée, voire de l'heure) en cas de régression.

**On vérifie aussi beaucoup plus de choses.**<br/>
Les tests de validation classiques ne s'attèlent généralement qu'à des vérifications fonctionnelles.
Or, la qualité d'un projet ne se juge clairement pas par ses fonctionnalités.
Les critères de maintenance, d'évolutivité ou de qualité sont tout aussi voire plus importants.
Un client risque de se mordre les doigts très fort s'il paie une misère un logiciel mais que la moindre maintenance ou correction de bug lui coûte les yeux de la tête (en plus des doigts :)).<br/>
La CI va permettre d'aller bien au-delà du fonctionnel, par exemple via l'analyse de [la couverture de code](https://fr.wikipedia.org/wiki/Couverture_de_code) ou [des métriques](https://fr.wikipedia.org/wiki/Métrique_(logiciel)) du projet.
Ces chiffres permettent de vérifier que le projet est sur les bons rails, avec un niveau qualitatif correct, et donc qui sera facile à maintenir et à faire évoluer.

# Comment la mettre en place

Mettre en place de l'intégration continue (avec [Jenkins](http://jenkins-ci.org/) par exemple), ça peut en effrayer certains et il faut bien être conscient des implications que cela génère.

D'abord, autant tordre le cou à une idée assez fortement ancrée dans les têtes (en particulier des directions) et tout aussi fortement erronée : **non, mettre en place de la CI, ça ne coûte pas cher !**.
En tout cas, cela coûte beaucoup moins cher à moyen/long terme qu'un logiciel inmaintenable, avec une qualité exécrable ou une évolutivité proche de l'escargot sur le mont Éverest.

Par contre, oui, cela demande **une bonne implication des équipes de développement**, et un niveau technique relativement correct et surtout homogène.

Déjà, il faut s'astreindre à une certaine rigueur.
Les 2 principales qui sont pour moi obligatoires pour une bonne CI : « no broken windows » et « continuous improvement ».
Et on finira par le point le plus primordial, mais qui est <s>très</s> trop souvent négligé : la qualité technique.

## No broken windows

Ou « Pas de vitre cassée » en Français dans le texte, basé sur [une théorie](http://fr.wikipedia.org/wiki/Théorie_de_la_vitre_brisée) qu'une voiture avec une vitre cassée aura plus tendance à être encore plus dégradée que la même sans vitre cassée.

Le principe est extrèmement simple : **l'intégration continue casse, on arrête tout et on corrige !**.<br/>
[On n'attend pas demain ou après demain](http://www.commitstrip.com/fr/2013/03/21/je-verrais-ca-plus-tard/), c'est plus synonyme de « Ça ne sera jamais fait » que d'autre chose sinon.
Et généralement, si on ne fixe pas un problème à l'instant T, on ne fixera pas non plus celui de l'instant T+N (qui réclamerait d'avoir corriger celui de l'instant T), etc.
Le projet dérive et finit par pourrir sur pied.

Le <s>chef de projet</s> responsable des développements doit formellement interdire tout commit qui ne vise pas à corriger le problème. Et encore plus les commits qui introduisent de nouvelles fonctionnalités.
Toute la charge de travail doit être mise sur la résolution du problème.

## Continuous improvement

Ce n'est pas parce que la machine va s'occuper de toutes les taches ingrates que l'homme n'a plus rien à faire !<br/>
Toute la partie purement mécanique (compilation, tests unitaires…) est analysable par un programme et peut rendre un résultat relativement fiable.
La partie qualité de code l'est beaucoup moins et est très sensible aux conditions du projet.

Les métriques données par la CI (par exemple grâce à [Sonar](http://www.sonarsource.org/)) ne peuvent pas être pris autant au pied de la lettre qu'un rapport de tests unitaires qui sortira bêtement « C'est OK » ou « C'est pas OK ».
Il faudra l'intervention d'un humain standard pour analyser les résultats, vérifier si les variations des métriques sont normales ou non, et prendre les mesures correctives nécessaires si besoin.

**Penser à faire des revues hebdomadaires** de tout ce que donne l'intégration continue.
Le mieux étant de le faire en amont de la relecture de code : si les métriques explosent, on sera d'autant plus vigilant sur chaque modification du code, à la recherche du coupable.

Au passage, on peut en profiter pour détecter les faiblesses de chaque développeur et homogénéiser l'équipe.<br/>
Il faut donc aussi provisionner du temps de formation et d'encadrement, et ne pas considérer qu'un projet est à coût nul sur ces points.
Même le meilleur développeur du monde ne peut pas tout savoir et aura sûrement besoin de se mettre à niveau sur des détails techniques bien précis.

## L'ennemie mortelle : la dette technique

Attention Chérie, ça va saigner…

Le plus gros problème rencontré lors de la mise-en-place de l'intégration continue, c'est **le manque flagrant de compétences techniques des développeurs**. De là naît aussi le sentiment que la CI coûte cher.

OK, tout le monde n'a pas le niveau des speakers de la Devoxx ou ne travaille pas tous les matins sur un projet opensource techniquement encadré par des pointures du développement. Mais quand même, faut pas pousser…<br/>
Je ne compte plus le nombre de projets qui démarrent avec uniquement des juniors, sans encadrement de seniors et d'architectes, généralement pour des raisons de coûts et d'occupation des-dits architectes (cf plus loin).<br/>
Et on ne parle bien entendu pas d'intégration continue, le client n'est généralement pas intéressé pour payer pour un truc dont il ne voit strictement aucun intérêt, les délais sont déjà trop juste pour pouvoir se permettre de perdre X jours à mettre en place du test ou de la CI, etc.

Du coup, on se retrouve à accumuler de la dette technique à tout-va :

 * nième implémentation d'un système de fichier de configuration (moisi si possible)
 * nième implémentation d'un système de log (si possible qui plante en cas d'appel au code censé tracer les problèmes)
 * pas de [séparation des concepts](http://en.wikipedia.org/wiki/Separation_of_concerns)
 * pas de système de build
 * pas de gestion de conf
 * des paramètres hardcodés partout
 * pas de tests unitaires
 * une grosse boîte noire dont personne ne sait trop ce qu'il y a dedans
 * etc
 
Au début du monde, certes, le projet semble avancer, les fonctionnalités arrivent, tout le monde est content.<br/>
Jusqu'à ce que le client demande une évolution, qu'on découvre un bug ou un problème de performance.
Et là, c'est le drame…
Tout le système a été bâti sur un chateau de cartes, et on vient d'en retirer la carte d'en bas à droite.

À ce moment, on passe généralement en mode panique, et on fait arriver tous les seniors et architectes, qui se rendent compte de la catastrophe technique qui s'est jouée sournoisement dans leurs dos.<br/>
On veut bien sûr remettre tout ça sur les rails, mais c'est quasiment mission impossible :

 * L'absence de séparation de concepts et [d'inversion de contrôle](http://fr.wikipedia.org/wiki/Inversion_de_contrôle) empèchent de mettre en place rapidement des tests unitaires, tout le système étant un Bloubiboulga immonde de dépendances
 * Même si on y arrive, le système de log qui passe son temps à écrire dans « C:\Documents And Settings\M.Dupont\Temp\app.log » (en dur…) est non configurable pour être débrayé en prod ou en test, et échoue donc lamentablement sur un système UNIX (la majorité des système de CI sont sous GNU/Linux)
 * La mise-en-place d'un système de build automatique type [Maven](https://maven.apache.org/) ou [Gradle](http://www.gradle.org/) est difficile, les dépendances étant en dur dans les sources du développeur (et commiter en SCM…) voire même installées directement à gros coup d'exe dans « C:\Program Files\Ma Dependance ». Et le process de compilation est souvent suffisamment aléatoire (« Ben je fais « Export jar » dans Eclipse, pourquoi ? ») pour ne pas être reproductible.
 
La plupart du temps, un senior se rend compte que quasiment rien n'est reprenable en l'état et doit tout reprendre de 0.
Généralement, la réponse à la question « Mais pourquoi tout refaire ? » sera « Pour mettre en place de la CI », ce qui donne l'impression aux non-techniques que la CI est un boulet sur un projet et qu'elle n'apporte strictement rien sinon devoir tout refaire.<br/>
En fait, implicitement, la réponse indique que le niveau technique du projet est trop insuffisant, et que la CI n'est que le moyen de garantir que demain cette situation ne se reproduira plus.
Ce n'est pas la CI qui a coûté cher, mais la dette technique accumulée auparavant, qu'il faut maintenant absorber.<br/>
Et comme cette situation arrive la plupart du temps à 15 jours de la livraison théorique, les seniors sont toujours en mode pompier sur beaucoup de projets en parallèle, au final très peu productifs et surtout indisponibles pour encadrer correctement les projets en phase de lancement.

Tout ça pour en arriver à ma conclusion.<br/>
Un projet mal géré initialement va coûter extrêmement cher à moyen/long terme (voire même très court terme si la dette technique est vraiment très importante) et la situation sera quasiment inrattrapable sans investir énormément de ressources (généralement autant tout refaire).<br/>
À l'inverse, mettre en place de la CI dès le début du projet permet de se rendre compte immédiatement des problèmes et va forcer les développeurs à utiliser des bonnes pratiques de programmation.

Mettre en place de la CI implique donc aussi de **former les équipes à tous les outils nécessaires.**<br/>
Pas uniquement à se restreindre au langage en lui-même, mais aussi à toutes les bonnes pratiques et au maniement de tous les outils nécessaires.
[SLF4J](http://www.slf4j.org/), [Spring IoC](http://static.springsource.org/spring/docs/current/spring-framework-reference/html/beans.html), Maven, [Git](http://git-scm.com/) ou tant d'autres ne sont pas que des accessoires futiles, mais font réellement partis de la plus-value qu'on peut apporter à un logiciel.
Il faut les faire apprendre et comprendre par les juniors (ce ne sont pas des points abordés en école), et les mettre en application sur tous les projets, aidés et contrôlés par la CI.<br/>
Dans le cas contraire, la dette technique va s'accumuler et le projet va finir par s'écrouler sous son propre poids. Et une CI est absolument impossible à mettre en place sans une équipe formée à minima sur les bonnes pratiques de dev.

# Conclusion

Mettre en place de l'intégration continue n'est absolument pas anodin, mais est strictement obligatoire sous peine d'un échec cuisant vu la complexité actuelle des projets.
Elle nécessite de bonnes bases techniques et un niveau moyen suffisant et homogène de l'équipe, ainsi qu'un certains respects de process et de contraintes.<br/>
Mais elle sauvera vos projets, en garantissant une qualité constante dans le temps et un projet avec une dette technique raisonnable, donc pérenne dans le temps.<br/>
Bonus supplémentaire, elle impose aussi une rigueur dans la formation et l'encadrement technique des projets, ce qui n'est clairement pas une mauvaise chose !
