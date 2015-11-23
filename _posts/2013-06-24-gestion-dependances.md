---
title: Gestion des dépendances
---

# Les développeurs, des (ré)inventeurs de roues (carrées) en série ?

Quand on développe une application, on a généralement besoin de fonctionnalités extrêmement standards : fichiers de configuration, logs applicatifs, accès à une base de données, écriture dans des fichiers, gestion de chaînes de caractères…<br/>
La tentation est alors très forte de les redévelopper *ad-hoc*, et du coup, généralement de manière peu fiable, buggée, non évolutive et non maintenable.
On se retrouve en plus rapidement avec pas mal de choses qui n'ont strictement rien à voir avec les fonctionnalités métiers principales de l'application.

Pourtant, comme ces fonctionnalités sont très standard et quasi-incontournables, elles ont déjà été développées par d'autres et sont disponibles sous forme de librairies, comme par exemple [Apache commons](http://commons.apache.org/), [SLF4J](http://www.slf4j.org/) et tant d'autres.<br/>
Il serait dommage de perdre du temps à les réécrire, surtout qu'on ne profiterait pas du retour d'expérience (et donc des corrections de bugs !) des millions d'utilisateurs de par le monde et de la communauté de développeurs autour de ces librairies.

# Comment utiliser les roues existantes de série

Chaque bibliothèque qu'on souhaite utiliser peut être considérée comme une dépendance externe de notre projet, qui n'est donc plus gérer par l'équipe de développement.<br/>
Vu qu'un projet peut rapidement compter plusieurs centaines de dépendances (voire quelques milliers), on a rapidement du déléguer à des outils la gestion de tout ça.

Ces outils doivent répondre à trois problèmes pour être réellement efficaces et faciliter l'utilisation de bibliothèques dans un projet.

## Intégrer facilement des bibliothèques

La première étape est d'être capable d'**intégrer la librairie** dans notre projet.
Dit comme ça, ça paraît simple et évident, pourtant la plupart des langages rend cette tache très compliquée…

En C/C++, tout passe par l'installation en dur des bibliothèques *.so* et des en-têtes *.h* nécessaires. Priez pour que la bibliothèque soit packagée pour votre distribution, sinon bonjour *make && make install* à vous salir (voire casser) un système…<br/>
En plus, le projet a de fortes chances de ne pas être portable, c'est-à-dire que d'un PC à un autre, fonction de l'OS, de la distribution GNU/Linux ou BSD, les fichiers de configuration de la construction du projet seront à modifier pour indiquer où et comment trouver les *.h* et *.so*.
Il faudra passer par des usines-à-gaz type *automake* pour trouver où sont installés les en-têtes pour mettre les bons *-I* et *-L* sur la ligne de commande si les bibliothèques ne sont pas dans les répertoires inclus par défaut.<br/>
Bref, le développeur il fait tout, l'outil il ne fait rien…

Ruby ([gems](http://rubygems.org/)), Java ([maven](https://maven.apache.org/)) ou Python ([pip](https://pypi.python.org/pypi/pip)) gèrent les choses beaucoup plus proprement, avec des dépôts centraux et des outils qui téléchargent nos dépendances et les installent dans des endroits bien définis et portables.<br/>
L'intégration des bibliothèques lors de la compilation/exécution se fait alors très simplement, en se basant sur des choses prévus par le langage (*site-packages* en Python, *gems* en Ruby, *classpath* en Java).<br/>
Et la déclaration des dépendances est tout aussi simple, avec un fichier qui liste chaque bibliothèque et les versions associées (*Gemfile* pour Ruby, *pom.xml* pour Java, *requirements.txt* pour Python)

# Gestion des dépendances transitives

Le second problème est de **gérer les dépendances transitives**.
Et oui, si nous avons besoin d'utiliser des librairies, ces dernières dépendent elles-aussi d'autres librairies !<br/>
On peut facilement arriver à des dépendances de 5ème niveau, ce qui est impossible à gérer à la main.

Encore une fois, C/C++ est à la traîne… Si la dépendance est packagée proprement, le gestionnaire de paquets installera tout le nécessaire.
Sinon… on commence par pleurer… et ensuite on se tape la chaîne à la main, en lançant un *make*, en regardant ce qui plante, en téléchargeant ce qui manque, en faisant un *make* dans la dépendance de niveau 1… ainsi de suite jusqu'à tout avoir de correct et en remontant toute la chaîne !

Les autres langages ont pensé à simplifier le problème : un fichier contenu dans la dépendance indique ses propres dépendances, et 
l'outil (gem, pip ou maven) s'occupe de rapatrier tout le nécessaire, récursivement.

# Isolation des applications

Le dernier problème, et non des moindres, **l'isolation des différentes applications**.
Il n'est pas rare d'avoir plusieurs applications en cours de développement et en production.
Pour une même application, il peut aussi y avoir plusieurs versions utilisées, fonction du client, de ses contrats de maintenance et de support, voire même de ses contraintes de qualification (une centrale nucléaire, c'est 30 ans de maintenance, et plusieurs millions d'euros pour qualifier une nouvelle version logicielle).<br/>
On se retrouve donc avec deux cas de figure possibles pour deux applications A et B qui utiliserait une bibliothèque C :

  * Incompatibilité entre deux versions d'une même application :
    * La version A1 de A réclame la version C1 de C
    * Mais la version A2 de A réclame la version C2 de C
  * Incompatibilité entre plusieurs applications :
    * La version A1 de A réclame la version C1 de C
    * Mais la version B1 de B réclame la version C2 de C

Pour ne pas changer, C/C++, hop, poubelle ! Il est impossible, ou en tout cas extrêmement difficile de pouvoir installer deux versions d'une même librairie, surtout par un gestionnaire de paquets. La même librairie pour tout le monde, quelque soit l'application ou la version de l'application !<br/>
Autant dire un gros bordel à maintenir à jour, des problèmes de compatibilité entre applications qui se règlent à gros coups d'upgrade massifs sur la machine, en croisant très fort tout ce qu'on peut pour espérer que ça passe sans problème…

Côté Ruby, Java ou Python, on peut installer plusieurs versions d'une même application, et le système standard intégré au langage (*classpath*, *gems*, *site-packages*) pour prendre le relai et charger la version de la bibliothèque qui correspond à ce que nécessite le projet.<br/>
On peut ainsi utiliser la version qu'on veut, mixer les projets qui utilisent des versions différentes, et upgrader une version d'une bibliothèque sans impacter toutes les autres qui utilisaient l'ancienne version.

# Conclusion

La gestion de dépendances est devenue incontournable aujourd'hui, surtout sur les applications un peu complexes, où on a déjà suffisamment de choses à faire sans parler d'avoir à réinventer la roue ou à gérer à la main des centaines de bibliothèques.

Les langages haut-niveau, type Ruby, Python ou Java ont pris en compte ces contraintes, et intégrés très tôt et en natif des mécanismes pour utiliser des dépendances externes.<br/>
Ils ont aussi développés des outils et des bonnes pratiques pour assister le développeur et le faire se concentrer sur son cœur de métier, et non plus sur les problèmes standards que les 10 générations de développeurs précédentes ont résolus depuis longtemps.

Pour les langages plus bas niveau (C/C++), tout reste encore à la charge du développeur, ce qui fait perdre beaucoup de temps au final, même s'il reste possible d'utiliser des bibliothèques, parfois en se faisant quelques nœuds au cerveau.

Dans tous les cas, je ne peux que conseiller très vivement à tous les développeurs en herbe d'arrêter de réinventer les roues carrées, et que la première étape avant d'implémenter quoi que ce soit est d'aller faire un tour sur le Web pour chercher si la fonctionnalité n'existe pas déjà ailleurs.<br/>
Avec les langages qui ont bien compris le concept, ça ne sera pas plus coûteux que deux lignes à ajouter dans un fichier !

