---
title: ! 'Mes langages courants : petit tour du propriétaire'
---

# Introduction

Depuis maintenant plusieurs années, je flane à droite à gauche à la recherche du langage de programmation idéal, ou en tout cas qui s'en rapproche le plus possible.

C#, C++, Java, Python, Ruby… J'ai déjà fait pas mal d'infidélité dans ma courte carrière !
Mes critères de sélection d'un langage sont les suivants :

 * Une syntaxe efficace
 * Un environnement de dev bien intégré, y compris niveau outillage
 * Un langage qui permet au dev de se concentrer sur le métier, et non sur des préoccupations techniques

Petit tour d'horizon.

# C&#35;

Bon, autant commencer par celui qui fache…
Âmes sensibles, passez votre chemin, ça va saigner !!!

## Langage

Niveau langage et syntaxe, c'est un langage qui vaut n'importe lequel.
Il possède même des petits plus sympas, comme les propriétés.

Par contre, le langage souffre de graves défauts de conception.
Il casse souvent le modèle objet standard et possède des subtilités dangereuses durant le développement d'un logiciel.

Par exemple, l'héritage et la généricité sont un véritable cauchemard…

```c#
class Porte {
	public void Ouvre() { Console.WriteLine("Ouverture"); }
}

class Digicode : Porte {
	public new void Ouvre() {
		Console.WriteLine("Code ?");
		Console.ReadLine();
		base.Ouvre();
	}
}

class Program {
	static void Main(string[] args) {
		Porte porte = new Digicode();
		porte.Ouvre();
	}
}
```

Que va faire ce programme ? On s'attend tous à ce qu'on nous demande le code de la porte… Et ben non !!!
Adieu le polymorphisme enseigné en école ! La méthode appelée sera celle du type **déclaré** et non du type **réel**, ici _Porte_ et non _Digicode_…
Pour les non-développeurs, cela signifie que si je vous donne une bouteille de sirop de menthe en vous disant que c'est une bouteille d'eau, si vous vous servez un verre, vous aurez… de l'eau (et non du sirop de menthe) !

Il est théoriquement possible d'obtenir le résultat attendu en déclarant la méthode _Ouvre_ de _Porte_ « virtual » et celle de _Digicode_ « override ».
Mais il est donc **impossible** de réimplémenter la méthode d'une librairie qui aurait oublié le _virtual_ sans recompiler la librairie (et donc d'avoir son code-source).

Aller, on continue dans la débilité la plus profonde…

```c#
static void Main(string[] args) {
	List<Porte> portes = new List<Porte>();
	portes.Add(new Porte());
	foreach(Digicode digicode in portes) {
		digicode.Ouvre();
	}
}
```

Sisi, je vous garanti, ce code compile sans erreur et sans le moindre warning !!!
Par contre, il plante bien comme il faut à l'exécution, une _Porte_ n'étant pas un _Digicode_…
… (no comment) …

## Environnement de dev

On frise le 0 absolu niveau intégration des outils.

Visual Studio, qui occupe pourtant des gigas octets d'espace disque ne fait guère mieux qu'un bon Notepad++ bien pluggé comme il faut.
Complétion automatique qui ne complète pas grand chose, pas de compilation en arrière plan et donc pas d'assistance à la correction des erreurs sans recompilation manuelle…

Pas mieux niveau intégration des outils, par exemple les tests unitaires nécessitent des [plugins payants](https://www.jetbrains.com/resharper/) pour être lancés depuis l'IDE.
Après c'est vrai, il faudrait déjà qu'il y en ait, des outils… C'est la croix et la bannière si on veut automatiser le build, rien n'est fait pour permettre au dev de sortir de son IDE.
Et pas mal de choses sont hardcodés dans les fichiers de configuration du projet, comme les chemins des librairies externes. Une plaie pour le dev à plusieurs.

Et en plus, tout est assez souvent payant et relativement cher.
Le moindre environnement de développement minimal pour travailler revient à plusieurs milliers d'euro (Windows, Visual Studio, TFS, Sql Server, ReSharper…).

## Conclusion

Vous l'aurez compris, C# n'est pour moi pas un langage de développement décent.
Passez votre chemin si vous voulez faire les choses proprement, rapidement et de manière fiable.

Je dois quand même reconnaître que mes expériences en .net se limitent à du 2005 et du 2008, mais il ne me semble pas que les versions suivantes aient beaucoup évoluées depuis.

Et puis après, il est parfois impossible de faire autrement, quand le client impose le langage ou que certaines contraintes obligent à s'intégrer à du Microsoft.

# C++

Pour ce langage, ça va être très rapide.

Les fonctionnalités du langage sont trop riches, et généralement superflues et piégeuses. Des choses « simples » comme les templates sont une horreur à comprendre, et toutes les subtilités du langage font perdre beaucoup de temps pour rien au final.

L'absence de garbage-collector oblige également à gérer sa mémoire à la main, au lieu de se concentrer sur notre cœur de métier et les besoins du client.
Certains me diront que ce n'est pas une mauvaise chose, je leur rétorquerai que j'attend toujours un exemple d'application qui gère correctement sa mémoire.

On passe aussi plus de temps à galérer avec le compilateur qu'à développer notre code.
On en arrive même parfois à devoir casser une architecture logicielle conçue correctement en UML juste pour faire plaisir à GCC (au pif, les références circulaires).

Niveau IDE, il en existe quelques uns, par exemple [Eclipse CDT](http://eclipse.org/cdt/). Mais rien de bien révolutionnaire.

Et pour l'outillage, vous repasserez.
Rien n'est prévu pour intégrer des bibliothèques tierces, et vous devez régulièrement passer par root pour installer ce qu'il faut…
Priez pour ne jamais avoir 2 applications qui nécessitent 2 versions différentes de la même dépendance…
Et non, les [autotools](http://www.gnu.org/software/autoconf/) ne sont pas des outils dignes de ce nom…

Bref, pas emballé, on passe au suivant.

# Python

## Langage

Le langage Python est assez unique en son genre.

Déjà il utilise l'indentation pour délimiter les blocs de code, au lieu des « {} » plus classiques.
Au moins, ça oblige à faire du code propre et bien indenté !
Par contre, cela a quelques inconvénients assez énervants.

 * Débugger des caractères invisibles, on a pas fait plus difficile.
Une tabulation ou des espaces en trop, et pouf, plus rien ne fonctionne…
Et allez trouver la source de l'erreur…
 * La refactorisation est parfois laborieuse.
Un test à ajouter nécessite de réindenter toute une portion de code.
Les erreurs d'indentation sont assez fréquentes et conduisent à des comportements assez étranges dans le code.

**Le seul problème réellement bloquant pour moi chez Python est sa gestion des packages.**

Déjà, je trouve qu'il y a une notion en trop entre package (répertoire) et module (fichier).
Parce qu'une classe _Foo_ qui est déclarée dans _src/my-app/bar/foo.py_, c'est pas décent de devoir en faire référence par _bar.foo.Foo_.
Du coup on a tendance à faire des mono-fichiers de 3000 lignes de long plutôt que de déclarer chaque classe dans son propre fichier, à la Java, et d'avoir des imports de 30km de long (en hauteur comme en longueur) partout.

Il est aussi impossible de fusionner 2 arborescences de packages.
Si je défini _src/my-app/foo/_ et _test/my-app/foo/_, je n'aurais que l'un ou l'autre à être pris en compte, et non pas les 2 en même temps, même s'il n'y a pas de conflit de classe.
C'est assez handicapant pour les tests unitaires, qui doivent donc être dans des packages complètement disjoints de ceux de l'application.
Bonne nouvelle, ça a l'air de bouger sur ce point dans Python 3.3 (cf [PEP420](http://www.python.org/dev/peps/pep-0420/)).

Autre petit bémol pour moi, le duck typing…
J'ai toujours du mal avec ce concept, puisqu'on ne peut plus savoir *exactement* ce qui va nous arriver ou ce qu'on doit faire pour discuter avec le voisin. La fiabilité de l'application en prend forcément un coup (cf [cette thèse](https://docs.google.com/file/d/0B5C1aVVb3qRONVhiNDBiNUw0am8/edit?pli=1)), et la vitesse de dev aussi.

## Environnement de dev

Les bons IDE ne manquent pas, le mien étant [PyDev](http://pydev.org/), un plugin pour Eclipse. On peut aussi cité [Aptana](http://www.aptana.org/), basé sur PyDev.

Python vient aussi avec pas mal d'outils d'aide au développement.
Les [tests unitaires](http://docs.python.org/2/library/unittest.html) font partis du langage et y sont très bien intégrés.
Des outils comme _[easyinstall](https://pypi.python.org/pypi/setuptools)_ ou _[pip](https://pypi.python.org/pypi/pip/)_ permettent de récupérer et d'utiliser des dépendances externes.
_[virtualenv](https://pypi.python.org/pypi/virtualenv)_ permet d'isoler les applications les unes des autres et d'utiliser des versions différentes d'une même dépendance sans soucis.

## Conclusion

Python est un langage intéressant, qui permet de faire des choses assez sympas très rapidement. Son environnement est très riche et conceptuellement bien ficelé.

Mais son duck-typing et sa problématique des packages le rendent difficile à utiliser sur des applications relavement importantes.

Je me le réserve donc pour de petites applications rapidement développées, et du scripting.

# Java

Mon petit chouchou !!! Nous y voilà !
Je vais essayer de faire court, je peux y passer des heures ! :)

## Langage

Le langage en lui-même est un langage objet tout-à-fait classique.
Il ne sort pas vraiment du lot. On pourrait même lui reprocher d'être extrèmement verbeux.

Un des points qui lui donne vraiment un charme fou, ce sont les génériques, apparus avec Java 5.0.
Certains me prennent généralement pour un fou quand j'arrive à coder quelque chose du type

```java
abstract class Content<T> {
	T value;
}

abstract class Type<V, C extends Content<V>> {
	abstract V getDefaultValue();
	abstract boolean isValid(final C content);
}

class Column<U, C extends Content<U>, T extends Type<U, C>> {
	T type;
	U defaultValue;
}

class Cell<V, C extends Content<V>, T extends Type<V, C>, D extends Column<V, C, T>> {
	D column;
	C content;
}

class Row implements Iterable<Cell<?, ?, ?, ?>> {
	List<Cell<?, ?, ?, ?>> cells;
}

class Sheet implements Iterable<Row> {
	List<Column<?, ?, ?>> columns;
	List<Row> rows;
}

class Workbook implements Iterable<Sheet> {
	List<Sheet> sheets;
}
```

Ceci est pourtant la représentation d'un fichier de tableur totalement type-safe, auquel on ne peut pas mettre de valeurs d'un type différent de celui de sa cellule, et **avec les erreurs de typage détectées dès la compilation**.
Effectivement, on arrive à un niveau d'abstraction assez impressionnant, et je ne demanderai jamais à un débutant d'arriver à sortir ça du premier coup, encore moins d'y penser en phase de conception.
Mais derrière, on a une généricité de l'application à toute épreuve, qui va permettre de l'enrichir à moindre frais, quelque soit les évolutions futures de l'application, et avec très peu de code.

## Environnement de développement

Bon, là on rentre carrément dans le domaine du mystique.
C'est **THE** point fort du monde Java.

Les développeurs Java ont très vite travaillé plus sur les méthodes de développement que sur le langage en lui-même.
C'est plutôt une bonne chose d'après moi, un langage devant rester le plus simple possible pour être accessible sans prise de tête, mais on doit alors l'assister avec tout plein d'outillage.

Java a poussé le concept assez loin, et une bonne partie du travail de développement est « codifié » et automatisé.
Un gigantesque standard de développement mondial s'est mis en place, et passer d'un projet à un autre ne demande généralement aucun temps d'adaptation, toutes les méthodes et les process étant communs ou presque.

Au-dessus de ces méthodes, on a vu apparaître des outils d'automatisation, via des gestionnaires de build type [Maven](https://maven.apache.org/) ou [Gradle](http://www.gradle.org/), véritables couteaux suisse de la chaîne de développement.
Ces outils gèrent l'intégralité du process, de la récupération des dépendances au déploiement, en passant par la compilation, l'exécution des tests ou la génération des rapports.

Encore au-dessus, l'intégration continue, avec [Jenkins](http://jenkins-ci.org/) par exemple, permet d'obtenir des rapports en temps réel, insultant copieusement les développeurs qui cassent quelque chose dans le logiciel.
Et on rajoute encore quelques gestionnaires d'artifacts, comme [Nexus](http://www.sonatype.org/nexus/), pour centraliser tous les déploiements et permettre à chacun d'utiliser les quelques 382.000 bibliothèques disponibles.

Le tout s'installe très facilement, généralement en quelques clics et toutes les briques s'intègrent les unes aux autres sans problème.

Niveau IDE, je pense que toute personne qui a déjà utilisé [Eclipse](http://www.eclipse.org/) dans sa vie sera d'accord avec moi : ça déchire son poney rose tous les matins au petit dej' !
Complétion automatique extrèmement efficace, intégration de la gestion de conf (SVN, Git, Mercurial…), des outils de build (Maven, Gradle, Ant…), des outils de dev (JUnit, Jacoco…), outils de refactoring très puissants (move/rename, inline, extract variable/field/super-class/method…), j'en passe et des meilleurs comme l'intégration de pas mal de frameworks (Spring, Hibernate, Jaxb, Axis…).
**De l'or en barre pour un IDE totalement gratuit !**
(D'ailleurs, plutôt que de filer des milliers d'euros dans du logiciel bien privateur, il y a tout plein de gentils développeurs qui ne demandent qu'à encore améliorer cet IDE, donc [c'est par ici](http://www.eclipse.org/donate/) si vous voulez aider)

## Conclusion

Bon, vous l'aurez deviné, Java est mon langage préféré au jour d'aujourd'hui.
Je n'ai pas encore trouvé d'environnement plus intégré et abouti, très productif et efficace.
Malgré un langage plutôt banal, le monde Java a su compenser par des outils indispensables à tout développeur, et a supprimé toutes les taches pénibles, rébarbatives et chronophages.

On arrive ainsi à sortir des logiciels rapidement, avec une qualité de code élevée, et en se concentrant uniquement sur le cœur de métier de l'application à développer : comme je dis souvent : « Si ce n'est pas métier, on n'a pas à le coder ».

Le fait d'avoir une très grande homogénéité entre projets, du plus gros au plus petit, est aussi un gros avantage.
Les temps de formation sont diminués et mutualisés : un développeur Java sera à même d'intervenir sur tout type de projet.
Mais attention quand même à la formation initiale qui demande du coup beaucoup plus de travail et d'investissement que les autres environnements.

# Ruby

Un petit dernier pour la route, qui deviendra peut-être un jour le remplaçant de Java dans mon cœur. :)

Ce langage est un peu le croisement entre la flexibilité de Python et le rouleau-compresseur Java.

C'est un langage essentiellement orienté paradigme fonctionnel, ce qui permet d'écrire des programmes très concis.

```ruby
(0..10).collect { |i| i**2 }.select { |i| i % 3 == 1 }[-5..-2]
```

Ça ne sert strictement à rien, mais écrire des choses comme ça en Java ou autre demanderait au moins quelques bonnes dizaines de lignes peu lisibles.

Ce langage a aussi pris de Java sa méthodologie.
Des outils comme [Rake](http://rake.rubyforge.org/) et [Bundler](http://gembundler.com/) permettent de gérer tout le cycle de développement, en particulier la gestion des dépendances.
[Rbenv](http://rbenv.org/), lui, permet d'installer facilement Ruby sur sa machine, sans perturber le système.

Je me sers de Ruby essentiellement pour mes sites web, avec [Rails](http://rubyonrails.org/).
Niveau productivité, difficile de faire mieux, avec une ébauche de site fonctionnel en quelques minutes.

Côté IDE, le bât blesse un peu. Pas grand chose à se mettre sous la dent.
J'utilise [IntelliJ IDEA](https://www.jetbrains.com/idea/), qui fait très bien son travail. Dommage qu'il soit payant (les équipes de dev opensource peuvent avoir des licences gratuites), bien qu'il reste tout à fait abordable et bien moins cher que des environnement C# par exemple.

Aller, encore un effort et quelques améliorations (côté environnement de bureau et interfaces graphiques par exemple), et il pourra rivaliser avec Java en dehors du monde du web !

# Les outsiders

Reste quelques langages, que j'ai pu approcher par-ci par-là.

Entre autres Scala et Groovy, des langages pour la JVM, essentiellement orientés fonctionnel.
Des concepts intéressants, dont la compatibilité avec Java (et donc la possibilité de réutiliser du code existant), mais encore trop jeunes et manquants de maturité pour une utilisation au quotidien dans des applications un peu complexes.

À garder sous le coude quand même, ils pourraient devenir très intéressants à l'avenir s'ils s'étoffent un peu plus et que les entreprises deviennent moins frileuses à changer de paradigme de programmation. :)
