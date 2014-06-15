Title: Gestion des cas d'erreur : les exceptions
Date: 2014-06-09
Category: dev
Tags: exception

# Génèse

Le premier jour, il n'y avait rien. Et le développeur s'ennuyait.
Alors le développeur inventa le C. Et tout marchait pour le mieux :

	:::c
	char* readFile(char *path) {
		…
	}

	void writeFile(char *path, char *content) {
		…
	}

	void main() {
		char *content = readFile("/mon/fichier/qui/existe");
		writeFile("/mon/fichier/qui/existe/aussi");
	}

Ainsi naquit le premier jour.
Le développeur ne faisant jamais d'erreur et connaissant l'intégralité de l'univers, ce code est propre et robuste.
Et le développeur était content.<br/>
Mais le développeur se sentait seul dans ce grand univers…
Aussi il inventa le client. Et là, il ne s'ennuyait plus du tout…

	:::c
	int readFile(char *path, char **content) {
		if (fileNotExist(path)) {
			return NO_SUCH_FILE;
		}
		content = …;
		return 0;
	}

	int writeFile(char *path, char *content) {
		if (fileNotExist(path)) {
			return NO_SUCH_FILE;
		}
		if (diskFullWithMoreContent(path, content)) {
			return DISK_FULL;
		}
		…
		return 0;
	}

	int main() {
		char *content;
		int ret;
		ret = readFile("/un/fichier/inconnu/avec/plein/de/contenu", content);
		if (ret) return ret;
		ret = writeFile("/un/autre/fichier/inconnu", content);
		if (ret) return ret;
		return 0;
	}

Ce fut le second jour. Le client était content, mais le développeur ne l'était plus du tout avec du code
aussi sale.<br/>
Alors le développeur envoya son client en enfer, et inventa Java.

	:::java
	class Main {
		public static void main() {
			try (InputStream input = new FileInputStream("/un/fichier")) {
				String content = IOUtils.toString(input);
				try (OutputStream output = new FileOutputStream("/un/autre/fichier")) {
					IOUtils.write(content, output);
				}
			} catch (IOException | FileNotFoundException e) {
				Logger.error("Something goes wrong…", e);
			}
		}
	}

Ainsi apparu le troisième jour. Le développeur était content, avec du code propre.
Et son client était content, avec une application robuste.<br/>
Du coup les quatre jours suivants, le développeur les passa à boire du café et à contempler son œuvre.

# Les erreurs à l'exécution, une plaie pour le programmeur

Dans un monde idéal, un programme informatique devrait être extrèmement simple, centré sur les besoins utilisateurs et ne faire que ce pour quoi il a été conçu.
Malheureusement, il y a beaucoup de choses qui viennent le perturber, choses qui n'ont strictement rien à voir avec le besoin métier.<br/>
Coupure réseau, fichier de configuration mal formaté, disque plein, erreur de lecture, fichier inexistant… Quand ce ne sont pas tout simplement [des besoins clients souvent ridicules](|filename|/20130916-code-propre-besoins-client.md).<br/>
Le long fleuve tranquille peut rapidement se transformer en torrent déchaîné…

Dans les langages bas niveau, comme le C, c'est de la responsabilité du développeur de détecter les erreurs et de les traiter.
On trouve ainsi énormément de fonctions qui retourne un entier qui, s'il n'est pas égal à 0, signale une erreur lors de l'appel.
Ce genre de solution pose de multiples problèmes.<br/>
Déjà, cela génère du code spaghetti, où chaque appel de méthode doit théoriquement être suivi d'un test pour vérifier si l'appel s'est bien passé.
Quand on a que deux ou trois appels relativement indépendants, le code obtenu reste maintenable :

	:::c
	int foo() {
		if (bar()) return SOME_ERROR;
		if (baz()) return SOME_OTHER_ERROR;
	}

Dès qu'on commence à avoir des dépendances entre appel, ça en devient rapidement inbouffable…

	:::c
	int foo() {
		char *buffer = malloc(256);
		if (buffer) {
			if (!readFile("/foo", buffer)) {
				free(buffer);
				return OK;
			} else {
				free(buffer);
				return IO_ERROR;
			}
		} else {
			return OUT_OF_MEMORY;
		}
	}

On se retrouve avec des imbrications de test en pagaille, du code dupliqué pour gérer les cas de sortie, peu ou pas de mutualisation de code, et surtout un code totalement illisible comparé à la version naïve (qui n'est correcte que s'il n'y a aucun accroc à l'exécution et conduit à une fuite mémoire dans tous les autres cas) :

	:::c
	int foo() {
		char *buffer = malloc(256);
		readFile("/foo", buffer);
		free(buffer);
	}

La complexité devient aussi très vite très élevée :

  * une méthode qui appelle 2 méthodes à 1 erreur possible peut échouer de 2 manières (la première méthode échoue, ou la première passe et la seconde échoue)
  * une méthode qui appelle 2 méthodes à 2 erreurs possibles peut échouer de 4 manières différentes
  * une méthode qui appelle 2 méthodes à 4 erreurs possibles échoue potentiellement selon 8 possibilités

Dans une architecture classique, on arrive facilement à au moins 5 ou 6 niveaux d'appel, donc à au moins une centaine de possibilités d'échec sur les méthodes de plus haut niveau.

Dans le cas du C, on est aussi obligé de réserver la valeur de retour des méthodes pour le retour d'erreur. Au lieu d'avoir un ``char* readFile(char *path)``, on est obligé d'avoir un ``int readFile(char *path, char **content)``.
Et donc d'avoir des appels bizarres du genre ``char buffer[256]; readFile("/foo", &buffer);``.
Vive les pointeurs, les pointeurs de pointeurs, la gestion de la mémoire à la main… et les fuites mémoires !

Au final, la gestion des erreurs dans l'application prend plus de temps et de code que le code véritablement métier et utile.
Pour gérer un cas qui surviendra dans 1% des cas, on multiplie le travail nécessaire par 20 ou 30, pour un résultat généralement peu fiable (cas oubliés, complexité cyclomatique…).

# Système de gestion d'exception

En fait, si on regarde bien ce qu'on cherche à traiter dans les exemples précédents, c'est uniquement que le code appelant soit notifié d'une erreur survenue dans le code appelé, de manière globale et générique, et sans parasiter le code avec des codes de retour ou des tests en cascade.<br/>
C'est pour accomplir cette tache que les systèmes de gestion des exceptions ont été créés.

	BusinessReturnValue foo(BusinessParameters params) throws QuzException  {
		try {
			bar(); // can throw BarException
			baz(); // can throw BazException
			quz(); // can throw QuzException
			return new BusinessReturnValue();
		} catch (BarException | BazException) {
			handleError();
		} finally {
			alwaysExecuted();
		}
	}

Chaque appel de méthode peut lever une ou plusieurs exceptions, interrompant brutalement l'exécution du code.
Si un ``catch`` existe pour l'exception levée, le code correspondant est exécuté.
Sinon, l'exception est propagée à la méthode appelante, qui pourra gérer l'exception ou la transférera à son propre appelant.

On retrouve plus ou moins le même système en Java, Python, Ruby et dans une moindre mesure en C++ (mais mixé avec des codes de retour la majeure partie du temps).<br/>
Smalltalk dispose d'un système encore plus puissant, avec un système natif de réexécution du bloc de code fautif ou la continuation du code malgré l'erreur rencontrée.

L'avantage des exceptions est que le code reste linéaire et n'est pas criblé de tests dans tous les sens. Mieux, si on ne sait pas gérer l'erreur à notre niveau, on n'a strictement rien de plus à faire que le code strictement métier, les couches supérieures s'occuperont de nettoyer derrière nous en cas d'erreur.

Quelques règles sont à respecter pour conserver l'intérêt des exceptions.
En particulier, aucune erreur ne devrait être masquée. Je ne vois que trop souvent des choses comme ça :

	:::java
	void foo() {
		…
		try {
			…
		} catch {
		}
		…
	}

Si un problème survient, il sera purement et simplement impossible à tracer, le code continuera à s'exécuter sans aucun erreur visible, et l'application risque fort de planter plus loin, avec un message sans aucun lien avec la véritable cause initiale.<br/>
Au minimum, pensez à tracer l'erreur, voire à la relancer plus haut, avec une préférence pour la seconde méthode plutôt que la première.

	:::java
	void foo() {
		…
		try {
			…
		} catch (Exception e) {
			// Please, avoid this…
			Logger.warn("Exception occur : " + e.getMessage());
		}
		…
		try {
			…
		} catch (Exception e) {
			// Prefer this way
			throw new RuntimeException(e);
		}
		…
	}

Les exceptions, si elles sont bien gérées, simplifient énormément le code et le
 rendent vraiment robuste (théoriquement, avec une bonne gestion, un crash
 applicatif est impossible sauf cas **VRAIMENT** graves)

# Checked / unchecked exceptions
## Quoi est-ce que ces bestios ?

Il existe 2 types d'exceptions : les exceptions vérifiées (*checked*) et les
 non-vérifiées (*unckecked*).
Fonction du langage de votre application, il est possible que seulement un de ces
 types soit disponible. Par exemple en C#, Python ou Ruby le concept de *checked
 exceptions* n'existe pas alors que dans des langages sécuritaires comme Ada,
 seules les *checked* existent. En Java, les 2 types sont accessibles.

La différence entre les 2 va conditionner le comportement de votre compilateur.<br/>
Avec une exception vérifiée, les méthodes pouvant générer une erreur doivent
 lister exhaustivement dans leur prototype quelles exceptions sont potentiellement
 générables à l'appel, et toute autre méthode qui y fera appel devra indiquer
 explicitement la manière de les traiter (au pire en les relançant à leur propre
 appelant, et donc en les déclarant à nouveau dans le prototype).
L'exception est donc vérifiée au sens où le code obtenu ne laisse aucune place
 au hasard et implique de gérer explicitement les cas d'erreur.<br/>
Avec une exception non vérifiée, les méthodes pouvant les générer ne les déclarent
 pas explicitement, et personne n'est obligé par le compilateur a les traiter.
Dans le pire des cas, l'exception remontera toute la pile d'appel et arrétera
 sauvagement votre application !

	:::java
	class CheckedException1 extends Exception {}
	class CheckedException2 extends Exception {}
	class UncheckedException1 extends RuntimeException {}
	class UncheckedException2 extends RuntimeException {}


	class Main {
		void foo() throws CheckedException1, CheckedException2 {
			throw new CheckedException1();
			throw new CheckedException2();
			throw new UncheckedException1();
			throw new UncheckedException2();
		}

		void bar() throws CheckedException1 {
			try {
				foo();
			} catch (CheckedException2 e) {
				…
			} catch (UncheckedException1 e) {
				…
			}
		}
	}

Dans l'exemple Java précédent, les exceptions non vérifiées héritent toutes de
 *RuntimeException*, toute autre exception qui ne dérive pas de cette classe sont
 des exceptions vérifiées.<br/>
La méthode *foo()* peut potentiellement échouée par un des 4 cas d'erreurs
 représentés par les 4 classes d'exception.
*CheckedException1* et *CheckedException2* étant des exceptions vérifiées, la
 méthode doit obligatoirement les déclarer dans son prototype sous peine d'erreur
 à la compilation. Les 2 autres sont non vérifiées, donc la déclaration n'est pas
 obligatoire.<br/>
À l'appel de *foo()*, il va donc falloir traiter explicitement celles qui sont
 vérifiées. Ici, on choisit de traiter localement un des cas d'erreur, et de ne
 pas gérer l'autre, qui doit donc être propagé à l'appelant et déclaré dans le
 prototype.
Pour les non vérifiées, rien n'est obligatoire et par défaut conduit à une
 remontée de toute la pile d'appel jusqu'à ce qu'elles soient traitées
 explicitement… ou non ! Ici, on traite un cas en local, et on laisse quelqu'un
 d'autre traiter la seconde erreur si elle survient.

## Checked ou unchecked alors ?

La grande question sur la Vie, l'Univers et le reste qu'on se pose généralement
 avec les exceptions, c'est quelle sorte choisir dans son programme.
On aurait bien aimé que la réponse soit 42, mais ce n'est malheureusement pas le
 cas…<br/>
Les exceptions vérifiées imposent d'être gérées à un moment ou à un autre. Elles
 ont donc tendance à « polluer » le code appelant qui ne sait généralement pas
 trop quoi en faire sinon refiler la patate chaude au suivant.
Il est en effet très rare de savoir comment gérer une exception dans les couches
 applicatives basses (domaine, DAO, voire même service), parce que ces couches
 sont sensées être génériques et mutualiser du code pour des appels métiers
 totalement différents.

Difficile de savoir quoi faire d'un fichier manquant dans une bibliothèque de
 lecture de fichier…<br/>
Est-ce que je suis en train de tester si mon fichier de configuration est
 présent afin d'appliquer ou non les paramètres par défaut ?
L'erreur est alors normale et pas vraiment une erreur.

	:::java
	try {
		this.params = File.read("config.properties");
	} catch (IOException e) {
		this.params = DEFAULT_PARAMS;
	}

Est-ce que je suis en train de générer un fichier de sortie ?
Là, ça en devient beaucoup plus méchant !

 	:::java
 	try {
 		File.write("output.ods", content);
 	} catch (IOException e) {
 		Gui.warn("Unable to generate output file");
 		throw e;
 	}

Ce n'est donc clairement pas dans la classe *File* qu'on pourra décider de quoi
 faire ou ne pas faire…

La première couche où une exception peut prendre un sens suffisant pour pouvoir
 être traitée se trouve généralement être la couche présentation (IHM).
Si les couches basses se mettent à lancer des exceptions vérifiées, on se
 retrouve rapidement à avoir des prototypes de méthode à 10 ou 20 exceptions
 déclarées dans les couches plus hautes, ce qui incite d'autant plus le
 développeur à les try/catcher sauvagement pour ne plus avoir à les gérer.

Je recommande donc de n'utiliser que des exceptions non vérifiées, qui de toute
 façon ne portent aucune information exploitable, jusqu'à la couche service,
 quitte à transformer des non-vérifiées en vérifiées par la suite.<br/>
Par exemple, un fichier manquant dans un *ConfigService* pourra générer une
 *IOException* classique (ou une *MissingPathException* plus spécifique si
 nécessaire), qui sera try/catcher dans la présentation pour être convertie en
 *InvalidConfigFileException* métier et vérifiée si on est en train de charger
 un fichier de configuration sélectionné par l'utilisateur, mais qu'on ignorera
 bien comme il faut si on est au démarrage de l'application et qu'on tente de
 charger le fichier par défaut.<br/>
Une règle simple est de n'utiliser une exception vérifiée que :

 * si l'erreur est métier, donc fait l'objet d'une spécification/cas
  d'utilisation/story à part entière
 * et si la gestion de l'erreur peut être traitée localement par l'appelant, ou
  en tout « rapidement » dans la pile d'appel (maximum 1 ou 2 rethrow possible)

On garantie alors qu'oublier de traiter le cas sera détecté immédiatement à la
 compilation, sans pour autant innonder le code d'exception diverses et variées
 dont plus personne ne tient compte ni ne sait correctement gérer.

On veillera aussi à bien tester les cas d'erreurs avec des tests unitaires et une
 couverture de code correcte, surtout les exceptions non vérifiées.
Le compilateur ne pouvant pas nous aider, laisser passer une seule exception qui
 peut réellement survenir, c'est courir le risque d'avoir l'application qui crash
 à un moment où à un autre.<br/>
Mais je préfère une application qui crash immédiatement avec une belle pile d'appel
 bien propre qu'une application qui va masquer violamment une erreur et continuer
 son exécution, explosant avec un *NullPointerException* indémerdable dont la
 cause réelle remonte peut-être à 10h, ou qu'une application « théoriquement »
 incrashable mais au comportement totalement incompréhensible, avec les ¾ des
 erreurs passées sous silence et qui parasitent l'intégralité du code restant…
