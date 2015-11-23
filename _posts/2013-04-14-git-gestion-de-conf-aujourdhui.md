---
title: Git, la gestion de conf d’aujourd'hui
---

# Introduction

Le monde de la gestion de configuration (SCM) est devenu totalement incontournable aujourd'hui.
Pas un projet digne de ce nom ne peut aujourd'hui se gérer sans un de ces outils, ne serait-ce que pour pouvoir travailler à plusieurs et sans bon vieux [CPOLD](http://roland.entierement.nu/blog/2008/01/22/cpold-la-poudre-verte-du-suivi-de-versions.html).

Il n'y a pas si longtemps que ça, il n'y avait qu'une seule sorte de logiciel de SCM, fonctionnant en mode client/serveur.
C'était l'époque du vénérable [CVS](http://www.nongnu.org/cvs/) puis de [SVN](http://subversion.apache.org/).

Et puis récemment est apparue une nouvelle sorte de SCM : la DSCM ou gestion de configuration décentralisée.
C'est la nouvelle ère où on croise dorénavant [Git](http://git-scm.com/), [Mercurial](http://mercurial.selenic.com/) ou encore [Bazaar](http://bazaar.canonical.com/).

Quelles sont les avantages et inconvénients de chacun et comment les utiliser correctement.
Petite comparaison rapide entre les 2 outils majoritairement utilisés aujourd'hui, à savoir Git et SVN.

# Centralisé contre décentralisé

La grosse différence entre Git et SVN tient essentiellement en un seul point : SVN fonctionne en mode centralisé et nécessite un serveur pour fonctionner, quand Git est décentralisé et considère chaque dépôt comme l'égal d'un autre.<br/>
Alors que cette différence aurait pu être anecdotique, elle apporte en réalité tout son intérêt aux outils DSCM.

Déjà, on peut enfin travailler sans être connecté avec un serveur.
Il devient possible de travailler en déplacement, chez un client ou à la maison, sans avoir une connexion directe avec une quelconque machine.<br/>
Beaucoup d'utilisateurs de SVN se retrouvaient en effet à devoir fonctionner à nouveau avec du bon vieux CPOLD dès qu'ils n'avaient plus accès au serveur.

On gagne aussi énormément en vitesse, n'ayant plus besoin d'accès réseau pour travailler.<br/>
Alors qu'avec SVN tout prend tout de suite beaucoup de temps, comme un simple « svn log » ou la création d'une branche, Git n'utilise que des ressources locales, et est donc extrèmement performant.

# Pour en finir avec les mauvaises pratiques…

SVN était une sacrée avancée par rapport à CVS, qui souffre de graves limitations pour une utilisation quotidienne.
Mais il a aussi beaucoup contribuer à de mauvaises pratiques.

SVN fonctionne suivant le principe des branches et tags matérialisés.
Alors qu'un tag n'est sensé qu'être une étiquette nommant un commit bien précis et une branche qu'une bifurcation (temporaire ou définitive) de la vie d'un projet, SVN a fait une tambouille de tout ça…<br/>
Déjà, SVN ne fait plus de distinction entre trunk, branches et tags. Et tout ça est matérialisé par un répertoire quelque part dans l'arborescence.
Oui oui, vous avez bien lu. **Quelque part**… Mais où ? Ben là où le développeur voudra bien les mettre…
On se retrouve ainsi avec des projets qui ont des tags dans le trunk ou dans les branches, des branches dans des tags ou toute autre combinaison que vous jugerez bonne (ou pas…) !<br/>
Dans la même veine, pas de commande *branch* ou *tag*, mais une seule commande *copy*. C'est clair que

	svn copy http://svn/myProject/trunk http://svn/myProject/tags/v1.0.0

c'est super intuitif qu'on est en train de poser un nouveau tag…
Et vive les typos dans la commande, ou le dev récemment arrivé qui ne connaît pas la politique de nommage…<br/>
Et vous l'aurez aussi remarqué, cela rend possible les commits dans un tag… qui du coup perdent tout leur intérêt de traçabilité !

Ensuite, de par sa lenteur due aux accès distants, SVN n'a pas convaincu les développeurs de l'utilité des branches de travail.<br/>
Créer une branche peut facilement prendre une bonne dizaine de secondes sur un projet lambda et tout changement de branche prend globalement le même temps.
Un vrai calvaire à vivre au quotidien si on voulait réellement travailler proprement avec une branche par fonctionnalité.

Pour finir, vu que tout passe par un serveur central, il est impossible pour les développeurs de sauvegarder un travail en cours sans casser tout le projet en face.
Du coup les travaux sont généralement des *long-run*, avec aucun commit pendant 1 semaine puis un gros commit de 800 lignes sur 200 fichiers, puis plus rien, puis un gros commit, etc.<br/>
En cas de problème, si le développeur doit passer sur une autre branche ou s'il doit faire un bugfix, il se retrouve avec d'énormes modifications dont il ne sait pas trop quoi faire.
Committer casserait le projet sur le serveur (intégration continue, tout ça tout ça), perdre les modifications reviendrait à perdre 1 semaine de travail. Et zou, « CPOLD powered &#8482; ».

# … et mettre en place les bonnes

De par sa nature décentralisée, Git corrige tous les défauts vus auparavant.

Déjà, un vrai concept propre de tags et de branches. Fini les dépôts anarchiques et les branches au bon vouloir du développeur, ou encore les commits dans les tags.<br/>
Les tags deviennent enfin de véritables étiquettes et les branches retrouvent leurs sens initial, à savoir un commit avec 2 descendants.

## Des branches, encore des branches, toujours des branches

Alors que SVN est d'une lenteur sans nom, toutes les fonctions de Git sont quasiment instantanées. En particulier la création de branche et le merge.<br/>
Du coup, **usez et abusez des branches !!!**

Généralement, j'utilise 4 types de branche sur un projet :

 * La branche *master*, réservée aux versions officielles, correctement taggées
 * La branche *develop*, qui contient la version courante fonctionnelle en cours de travail. En particulier, c'est sur cette branche que l'intégration continue doit **toujours** être verte et **sur chacun de ses commits**. Elle doit être livrable en l'état à n'importe quel moment.
 * Les branches de *release*, qui partent de *develop* et seront mergées sur *master* et permettent de finaliser une future version. Elles ne doivent contenir que des bugfixes, pas de nouvelles fonctionnalités.
 * Les branches de *feature*, qui partent de *develop*. Elles correspondent au développement d'une fonctionnalité unique. Elles seront mergées à *develop* après une revue de code.
 * Les branches de *bugfix*, qui partent de *master* et la réintègrent. Elles correspondent à des correctifs apportées sur des versions livrées. Elles ne doivent pas introduire de nouvelles fonctionnalités.

Un diagramme qui colle assez bien à mon fonctionnement serait [celui-ci](http://nvie.com/posts/a-successful-git-branching-model/).

Avec une telle organisation, la traçabilité du code devient très bonne, tout en facilitant la revue de code et en garantissant peu de régressions entre versions.

## La ronde des commits

SVN ne permettait pas de faire des commits propres à un développeur, il devait obligatoirement commiter sur le serveur central, quitte à impacter tout le reste de l'équipe. L'absence de branches n'aidait clairement pas non plus.<br/>
Avec Git, comme chaque développeur a son propre dépôt et même ses propres branches, on peut envisager de travailler différemment.

Déjà, une bonne pratique est de **committer fréquemment**.
En plus d'éviter les mauvaises surprises et du temps perdu suite à une erreur de manipulation si vite arrivée, committer souvent permet aussi de revenir en arrière sans perdre trop de choses.
J'ai comme bonne habitude d'essayer de committer toutes les 10 minutes, tout en tentant de le faire avec des choses qui ont un minimum de sens et de cohérence.<br/>
De toute façon, à l'opposé de SVN, Git vous permettra de fusionner des commits multiples (*git rebase*) ou de modifier le dernier commit (*git commit --amend*) pour en faire de plus gros morceaux et éviter de polluer l'historique final.
Et à aucun moment vous n'impacterez un collègue ou ne casserez la CI, tout est uniquement local tant que vous n'aurez pas pushé quelque part.

La notion de commit « local » de Git est aussi très intéressant pour gérer des cas classiques qui posent problèmes avec SVN.

1er scénario : j'ai terminé de coder mes tests, je vais commencer à coder la fonctionnalité (et non l'inverse, merci la [TDD](https://fr.wikipedia.org/wiki/Test_Driven_Development) !!!).
Vu que je n'ai pas encore ma fonctionnalité, il est normal que tous mes nouveaux tests soient rouges. Mais j'aimerais quand même sauvegarder ma demie-journée de travail pour éviter de tout perdre et/ou pouvoir revenir en arrière facilement.<br/>
Avec SVN, pas d'autre choix que de commiter sur le serveur… et de me prendre un énorme retour de bâton de la CI (Comment ça elle était encore verte chez vous ???) !.
Avec Git, je commit simplement dans mon dépôt, sans pusher ailleurs. Une fois que j'aurais fini ma feature, je recommiterais et j'enverrais le tout. Il est même possible de fusionner *a posteriori* les multiples commits pour n'en faire plus qu'un seul (*git rebase*), et ainsi garantir que tout commit sur *develop* est valide pour la CI.

2nd scénario : le changement de contexte (très très mauvais pour la productivité ceci dit, mais pourtant si courant…). Ici, j'ai commencé à travailler sur une fonctionnalité. Bim, bug sur la production, évolution urgente à réaliser, revue de code KO… Et j'aimerais bien sauvegarder mon travail effectué pour ne pas le perdre et y revenir plus tard.<br/>
Comme d'habitude, SVN, « CPOLD, l'empire contre-attaque », commit sur le serveur qui casse tout, etc.<br/>
Avec Git, plusieurs solutions possibles, toutes aussi propres et efficaces les unes que les autres :

 * À la mode précédente, un commit sur le pouce, qu'on fusionnera par la suite avec un *rebase*. Je me réserve généralement cette méthode si j'ai un état un minimum cohérent et assez conséquent.
 * Une petite variation, avec un *commit --amend* pour éditer le dernier commit. Mais du coup cette méthode ne permet pas de revenir en arrière. À réserver à de petites modifs à sauvegarder, qui sont relativement cohérentes avec le dernier commit.
 * Une fonctionnalité qui n'existe pas dans le monde SVN : *git stash*. Grosso-modo, ça a l'odeur d'un commit, ça ressemble à un commit, mais ce n'est pas un commit. Le stashing permet de sauvegarder les modifications courantes du code pour y revenir plus tard, sans pour autant polluer l'historique. À réserver à de très petites modifications qui ne méritent pas un commit pour elles toutes seules.

## La revue de code et l'intégration

Avec SVN, vu que les branches sont inexistantes et que donc tous les commits ont lieu au même endroit, la phase de relecture de code devient très pénible.

Déjà, elle a obligatoirement lieu *a posteriori* : le développeur qui souhaite soumettre son code au relecteur n'a d'autre choix que de commiter dans le *trunk*. Si le relecteur considère que le code n'est pas de qualité suffisante, le mal est déjà fait, tout le monde utilise déjà ce code…

Avec Git, on peut faire de la vraie **relecture de code <i>a priori</i>** très simplement.

 1. Le développeur commit dans sa branche de feature et pousse dans son dépôt,
 2. Le relecteur peut alors récupérer la branche en question
   1. Si le code est jugé correct, la branche de feature est marquée pour intégration dans la branche *develop* officielle par un intégrateur qui procédera au merge
   2. Sinon, le développeur est renvoyé dans ses pénates, et proposera une autre solution un peu plus tard, en ayant recommité dans sa branche de feature

À noter qu'à aucun moment du code n'ayant pas subit de relecture de code et/ou de qualité médiocre ne peut se retrouver dans le dépôt officiel et donc en production. On peut même envisager de restreindre le dépôt officiel en lecture seule pour les développeurs et en écriture uniquement pour les intégrateurs. Qualité garantie  !

L'avantage des branches de feature et de l'intégration est aussi de reporter au plus tard l'ajout de fonctionnalités dans la version officielle.
Dans un cadre [Agile](https://fr.wikipedia.org/wiki/M%C3%A9thode_agile), cela veut dire qu'on peut modifier le contenu d'un livrable quasiment jusqu'au dernier moment, et donc éviter des régressions.
Et si une fonctionnalité s'avère en cours de route plus difficile que prévue, manquant de spécifications ou trop instable, les livraisons et le reste du développement peuvent continuer normalement, le code en question étant totalement isolé du reste.

# Conclusion

Sans conteste, SVN est aujourd'hui complètement détrôné par Git et les autres DSCM. Un projet qui se lancerait sans des outils de ce type ne ferait que perdre du temps et va au-devant de gros problèmes. À se demander comment on pouvait bien faire avant !

Git permet d'augmenter de manière très significative la qualité des projets, en garantissant de la traçabilité et un cloisonnement à la fois des développeurs et des fonctionnalités.

De l'or en barre à adopter de toute urgence !
