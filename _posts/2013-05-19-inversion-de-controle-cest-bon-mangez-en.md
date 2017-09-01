---
title: L’inversion de contrôle, c'est bon, mangez-en !
---

Aujourd'hui, un article un peu plus technique, avec de vrais morceaux de code dedans !
Au programme, l'inversion de contrôle ou IoC, qui est la clef-de-voûte d'une application bien construite.

Imaginons qu'on ait à réaliser une application très simple qui consiste à lire un nombre saisie par l'utilisateur et à afficher à l'écran son inverse.
« So simple » me direz-vous ? Et bien pas tant que ça en réalité !

# À l'origine était le code ad-hoc…

Si je soumet un tel problème à un candidat lors d'un entretien d'embauche, voici ce que j'obtiens généralement en quelques minutes :

```java
public class Program {
	public static void main(String[] args) {
		Scanner scanner = new Scanner(System.in);
		System.out.println(1D / scanner.nextDouble());
	}
}
```

Ok, ça répond au problème initial… Mais après ? Est-ce que ça démontre la moindre connaissance ou maîtrise d'un langage objet ?
Allez, seconde tentative !

```java
class KeyboardReader {
	private final Scanner scanner = new Scanner(System.in);
	
	public double read() {
		return this.scanner.nextDouble();
	}
}

class ScreenWriter {
	public void display(double value) {
		System.out.println(value);
	}
}

public class Program {
	private final KeyboardReader reader = new KeyboardReader();
	private final ScreenWriter writer = new ScreenWriter();

	public void process() {
		writer.display(1D / reader.read());
	}

	public static void main(String[] args) {
		new Program().process();
	}
}
```

Bon, y'a déjà du mieux. On sépare les concepts (lecture, écriture, traitement), on utilise des objets et des méthodes.
On se retrouve aussi rapidement avec un gros problème sur des applications un peu plus conséquentes.

En effet, on a ici de la chance d'avoir les classes *KeyboardReader*, *ScreenWriter* et *Program* qui ne dépendent d'aucun paramètre pour être instanciées et d'avoir un arbre de dépendence entre tout ça relativement linéaire.
Dans une application plus complexe, il n'est pas rare d'avoir plusieurs centaines de dépendances, avec des dizaines de paramètres de configuration.
L'architecture vu au-dessus n'est pas scalable dans ce cas. Passer des paramètres au *reader* imposerait de les passer aussi au *program*. Dit autrement, chaque composant de niveau N doit exposer la configuration de toutes ses dépendances de niveau N-1 :

```java
class Level11 {
	public Level11(params11) {}
}

class Level12 {
	public Level12(params12) {}
}

class Level2 {
	private final Level11 lvl11;
	private final Level12 lvl12;

	public Level2(params2, params11, params12) {
		this.lvl11 = new Level11(params11);
		this.lvl12 = new Level12(params12);
		this.init(params2);
	}
}
```

Ceci casse la notion de séparation de concepts, le niveau N ne devant pas avoir besoin de savoir comment fonctionne le niveau N-1, et encore moins la nécessité de gérer ce niveau inférieur.

Se pose aussi rapidement la problématique de réutilisation des composants.
Actuellement, on a de la chance que les *reader*, *writer* et *program* ne soient utilisés qu'à un seul et unique endroit.
Il est par exemple impossible d'obtenir un *program1* et *program2* qui utilisent le même *reader* ou *writer*, chacun allant initialiser ses propres instances.

# … Puis vint le singleton…

Pour résoudre le problème de scalabilité, la première solution que je vois <s>très</s> trop souvent apparaître est le bon vieux singleton :

```java
class Level11 {
	public static Level11 INSTANCE;
	public static init(params11) { INSTANCE = new Level11(params11); }
	public void process();
}

class Level12 {
	public static Level12 INSTANCE;
	public static init(params12) { INSTANCE = new Level12(params12); }
	public void process();
}

class Level2 {
	public static Level2 INSTANCE;
	public static init(params2) { INSTANCE = new Level2(params2); }

	public void process() {
		Level11.INSTANCE.process();
		Level12.INSTANCE.process();
		this.process();
	}
}

class Program {
	public static void main(String[] args) {
		Level11.init(params11);
		Level12.init(params12);
		Level2.init(params2);
		Level2.INSTANCE.process();
	}
}
```

Cette solution n'est vraiment pas idéale, et à plusieurs titres.

## Gestion des dépendences

On le voit bien, la gestion des dépendances reste à la charge du développeur.
Lorsque l'application grossit, il devient alors de plus en plus compliqué de maîtriser l'ensemble des composants.
En théorie, N composants peuvent nécessiter jusqu'à N-1 dépendances. Avec N=10, on a déjà 45 liens possibles, avec N=20 190 liens, N=100 4950 liens… Sur une application standard avec 200 composants, on frôle les 20.000 !
Il devient impossible de gérer nos composants de cette manière sur une application de taille standard.

De plus, il faut non seulement garantir que tout sera initialisé correctement, mais aussi dans le bon sens.
Par exemple, le bon vieux singleton *Config* qui surgit généralement le premier dans une application doit être initialisé avant tous les autres sous peine de gros problèmes.
Et lorsqu'il y a un problème à l'initialisation, le développeur se sent souvent bien seul devant une stacktrace de 2km de long (si possible sur le maillon le plus profond de l'application, Murphy aidant) ou avec une erreur qui survient 40min après le démarrage de l'application (typiquement un *NullPointerException* d'un truc pas (encore) initialisé).

## Généricité de l'application

Si on reprend notre problème de départ, la solution trouvée va poser un autre problème : les classes utilisées sont figées dans le marbre.
Je peux par exemple jouer mon client standard, et changer la spécification en cours de route, demandant que cette fois la lecture de l'entrée soit faite sur un socket TCP au lieu du clavier.

Solution 1 : rechercher *KeyboardReader*, remplacer par *TCPReader*.

```java
class TCPReader {
	public static TCPReader INSTANCE = new TCPReader();		
	public double read() { … }
}

class ScreenWriter {
	public static ScreenWriter INSTANCE = new ScreenWriter();
	public void display(double value) { … }
}

public class Program {
	public static void main(String[] args) {
		ScreenWriter.INSTANCE.display(1D / TCPReader.INSTANCE.read());
	}
}
```

En tant que bon client standard, je demande maintenant à ce que la lecture puisse être configurable, parce que j'aime parfois quand même bien reprendre mon bon vieux clavier !

```java
class Config {
	public static Config INSTANCE = new Config();
	public static void init(boolean keyboard) { INSTANCE = new Config(keyboard); }

	public final boolean keyboard;
	private Config(boolean keyboard) { this.keyboard = keyboard; }
}

class KeyboardReader {
	public static KeyboardReader INSTANCE = new KeyboardReader();		
	public double read() { … }
}

class TCPReader {
	public static TCPReader INSTANCE = new TCPReader();		
	public double read() { … }
}

class ScreenWriter {
	public static ScreenWriter INSTANCE = new ScreenWriter();
	public void display(double value) { … }
}

public class Program {
	public static void main(String[] args) {
		Config.init(Boolean.parseBoolean(args[0]));
		
		final double read;
		if ( Config.INSTANCE.keyboard ) {
			read = KeyboardReader.read();
		} else {
			read = TCPReader.read();
		}

		ScreenWriter.INSTANCE.display(1D / read);
	}
}
```

Bref, on voit bien que ça devient un gros tas de bordel, avec [des plâtrées de conditions partout](http://www.antiifcampaign.com/), et qu'on tend de plus en plus vers la non-maintenablité…

Apparaît en plus un nouveau problème : seuls les cas prévus par le code initial sont possibles.
Si par exemple je souhaite ajouter la possibilité de lire une page web ou consommer un web-service, je dois modifier l'application pour rajouter des cas dans les conditions ou utiliser de l'instrospection (en perdant au passage le type-safe).
Un tel code est donc inutilisable en tant que librairie, où l'utilisation réelle qui en est faite ne dépend pas du développeur initial mais d'un développeur tiers qui en sera un simple utilisateur.

Ce problème est d'autant plus grave qu'il interdit de mettre en place des tests unitaires.
Par exemple, j'aimerais bien valider le comportement de l'application, en particulier sur la valeur « 0 » en entrée.

```java
public ProgramTest {
	@Test
	public void testOnZero() {
		assertThat(Program.INSTANCE.process(), is(Double.POSITIVE_INFITY));
	}
}
```

Et mais ? Comment je peux faire pour automatiser mon test ?
En effet, j'aimerais bien pouvoir faire en sorte que mon *reader* me retourne « 0 » comme un grand, afin que mon test soit complètement autonome et ne dépende ni de l'utilisateur (saisie clavier), ni d'un service externe (appel TCP).
Histoire de pouvoir mettre en place une intégration continue par exemple.
Sauf que comme mon code est totalement hard-codé, soit je le modifie pour intégrer un nouveau composant *TestReader*, mais du coup j'impacte mon code de production pour mes tests unitaires (et accessoirement je le livre ainsi à mon client), soit je m'interdis définitivement de faire du test unitaire.
Peu réjouissant comme programme…

# … Et naquit l'inversion de contrôle

C'est là qu'entre en action l'inversion de contrôle. Tous les problèmes précédents vont s'envoler comme par magie.

2 nouveaux besoins sont apparus quand on réfléchit à la problématique initiale :

 * On doit s'abstraire du comportement réel de chaque composant, au profit de ce qu'on attend qu'ils nous rendent comme service,
 * On doit déléguer la mise en relation entre chaque composant à une couche au-dessus de notre application.

Pour le premier point, la programmation objet, avec les interfaces et l'héritage va pouvoir facilement nous venir en aide.
Pour le second, c'est ici que vont nous être utiles les divers frameworks d'IoC existants.

## Dis-moi ce que tu fais, pas comment tu le fais

Notre *KeyboardReader* ou autre *TCPReader*, au final, on s'en fiche de comment qu'ils vont nous retourner un nombre, ce qu'on veut, c'est qu'ils nous en retourne un.
Idem pour la sortie, la destination nous importe peu, on veut juste afficher quelque chose.
On voit émerger des interfaces :

```java
interface Reader {
	double read();
}

interface Writer {
	void write(double value);
}
```

Idem au niveau de notre programme, je n'ai que faire de qui, quoi ou comment va me donner un *reader* ou un *writer*, tout ce que je sais, c'est que j'en ai besoin d'un de chaque !

```java
class Program {
	private Reader reader;
	public Reader setReader(Reader reader) { this.reader = reader; }

	private Writer writer;
	public Writer setWriter(Writer writer) { this.writer = writer; }

	public process() {
		writer.write(1D / reader.read());
	}	
}
```

Tous nos composants seront de simples [beans Java](http://www.oracle.com/technetwork/java/javase/documentation/spec-136004.html), en gros des classes avec le constructeur vide par défaut et des getters/setters pour chaque attribut de classe.
Fini les singletons, les tests dans tous les sens et les dépendances en dur dans le code, tout le comportement de l'application va profiter au maximum des fonctionnalités de la programmation objet, via de l'héritage, du polymorphisme ou de la surcharge d'opérateur.

Niveau modularité, le client peut dorénavant me demander n'importe quoi comme lecture ou comme écriture, je n'ai qu'à définir une nouvelle implémentation des interfaces.

Pour notre problématique de test unitaire, idem, problème résolu, avec [Easymock](http://www.easymock.org/) par exemple :

```java
class ProgramTest {
	@Test
	public void testOnZero() {
		Reader reader = createMock(Reader.class);
		expect(reader.read()).andReturn(0D);
		Writer writer = createMock(Writer.class);
		expect(writer.write(Double.POSITIVE_INFINITY));
		replayAll();

		Program program = new Program();
		program.setReader(reader);
		program.setWriter(writer);
		program.process();
		verifyAll();
	}
}
```

Challenge accepted !

## Framework d'IoC

Reste le dernier problème de la complexité d'une application et de la gestion des dépendances.
Malgré que nos composants soient devenus très simples, l'application globale nécessite toujours de mettre une glue complexe entre chaque.

C'est là qu'entre en action les frameworks d'inversion de contrôle, dont le plus connu est sans conteste [Spring](http://www.springsource.org/) dans le monde Java.
Le nom d'inversion de contrôle vient d'ailleurs de l'architecture mise en place : ce n'est plus notre code qui se contrôle lui-même, mais le framework au-dessus.

On voit bien dans l'exemple précédent de test unitaire qu'en théorie, on pourrait faire tout le travail à la main, l'inversion de contrôle n'étant au final qu'une simple instantiation de tous les composants de l'application via le constructeur par défaut, puis de les assembler entre-eux via les setters.
Avec quelques composants, ce n'est pas forcément un problème, avec 100 ou 200, ça en est déjà un plus gros.

Spring va nous simplifier la vie avec 2 outils.
Le premier, un [DSL](http://fr.wikipedia.org/wiki/Domain-specific_programming_language) XML qui va nous permettre de décrire chaque composant applicatif. Dans notre cas :

```xml
<beans>
	<bean id="reader" class="KeyboardReader" />
	<bean id="writer" class="StdoutWriter" />
	<bean id="program" class="Program" />
</beans>
```

Même sur une application très complexe, on voit bien que la configuration reste relativement simple, surtout que Spring permet de découper la configuration dans les fichiers XML distincts.

On pourrait bien sûr passer des paramètres à nos composants, comme des fichiers de configuration ou du paramétrage applicatif, le DSL de Spring est extrèmement riche et permet de faire énormément de chose (cf [la doc](http://static.springsource.org/spring/docs/current/spring-framework-reference/html/beans.html)).

Pour faire l'assemblage de nos composants, on pourrait tout aussi bien le faire par du XML :

```xml
<beans>
	<bean id="reader" class="KeyboardReader" />
	<bean id="writer" class="StdoutWriter" />
	<bean id="program" class="Program">
		<property name="reader" ref="reader" />
		<property name="writer" ref="writer" />
	</bean>
</beans>
```

Le problème de la complexité des dépendances risque quand même de rendre cette configuration vite anarchique. Je préfère donc utiliser une autre possibilité de Spring, l'injection de dépendance :

```java
class Program {
	@Resource
	private Reader reader;
	@Resource
	private Writer writer;
}
```

Les développeurs n'ont qu'à déclarer ce dont ils ont besoin, Spring se chargera au démarrage d'injecter les bons composants au bon endroit au démarrage de l'application.
Encore une fois, on transforme le « comment » en « quoi », charge au framework de faire son travail et de nous fournir les outils dont on a besoin.

Une fois ceci fait, ne reste plus qu'à signaler à Spring où trouver nos fichiers de configuration et notre code, et à démarrer l'application !

```java
class Main {
	public static void main(String[] args) {
		ApplicationContext ctx = new ClassPathXmlApplicationContext("beans.xml");
		Program program = ctx.getBean(Program.class);
		program.process();
	}
}
```

Un avantage à tout ça, c'est que simplement en changeant de fichier de configuration et sans toucher à une seule ligne de code supplémentaire, je change totalement le comportement de l'application.
Ceci est particulièrement utile dans deux situations :

 * Pour les tests unitaires, où on peut changer par exemple le moteur de base de données pour utiliser une base en mémoire plutôt qu'une base sur disque, ou pour bouchonner tous les composants tierces de l'application (web services…),
 * Pour le debug en contexte opérationnel, où le simple changement du fichier de config permet d'activer des composants avec des logs plus verbeux ou simulant le comportement d'interfaces tierces.

# Conclusion

L'IoC est vraiment quelque chose de très important pour mettre en place une architecture modulable, fiable et simple, même sur des applications complexes.

Cette méthode de pensée permet d'éviter de brider le comportement de l'application, tout en simplifiant son extensibilité sans code supplémentaire, et en facilitant sa testabilité.
Et on le voit bien avec l'exemple a priori très simple choisi pour cet article, son utilité est loin d'être négligeable même pour un très petit projet.

Un projet sans un minimum d'IoC, c'est une future application qui connaîtra de très gros problème de maintenance et d'évolutivité, surtout que le surcoût de sa mise-en-place est proche de 0 et en tout cas bien inférieur au surcoût de dette technique si on n'en utilise pas.

Bref, l'IoC c'est bon, mangez-en !

