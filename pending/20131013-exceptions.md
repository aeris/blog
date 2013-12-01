Title: Gestion des cas d'erreur : les exceptions
Date: 2013-10-13
Category: dev
Tags: exception

Après une petite absence le mois dernier, reprise du clavier pour cette fois-ci
un article sur la gestion des exceptions.

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
				Logger.error("Something goes wrong… : " + e.getMessage();
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
				return IO_ERROR;
				free(buffer);
			}
		} else {
			free(buffer);
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
Au minimum, pensez à tracer l'erreur, voire à la relancer plus haut, même si les deux cas restent à éviter le plus possible.

	:::java
	void foo() {
		…
		try {
			…
		} catch (Exception e) {
			Logger.warn("Exception occur : " + e.getMessage());
		}
		…
		try {
			…
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		…
	}

# Checked ou unchecked exceptions ?

