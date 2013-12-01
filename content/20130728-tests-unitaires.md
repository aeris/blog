Title: Tests unitaires
Date: 2013-07-28
Category: dev
Tags: junit, hamcrest, fest-assert, jacoco, cobertura, jenkins, sonarqube

Les tests unitaires ont mauvaise presse dans le monde du développement. Généralement, ils sont vus comme du temps perdu, des choses inutiles, et sont vécus comme une contrainte plutôt que comme un avantage.

À travers un exemple simple, petit tour d'horizon sur le sujet.

# Rédaction des tests unitaires

On souhaite développer une petite calculatrice, qui permet de diviser des nombres. L'API est relativement simple :

	:::java
	class Calculator {
		// @return a / b
		// @throw DivideByZeroException when b = 0
		double divide(double a, double b) throws DivideByZeroException;
	}

Un développeur débutant se ruerait sur son IDE pour coder directement l'application. Mauvaise idée !<br/>
Il vaut mieux appliquer une méthodologie TDD ([Test Driven Development](http://fr.wikipedia.org/wiki/Test_Driven_Development)) et développer les tests unitaires avant le code.<br/>
Ceci permet d'éviter des erreurs très courantes :

  * [être tenté d'écrire des tests qui valident le code](http://geek-and-poke.com/geekandpoke/2013/7/28/tdd), alors qu'on doit faire l'inverse
  * surcoder par rapport à la spécification, avec des cas superflus (cas des listes ou chaînes de caractères vides traitées à part, cas *1 unique élément* traité séparément du cas *n éléments* cas aux limites…)
  * à l'inverse, sous-coder, en oubliant des cas particuliers

Le code de l'application est bien entendu trivial :

	:::java
	public class Calculator {
		public double divide(final double a, final double b)
				throws DivideByZeroException {
			if (b == 0D) {
				throw new DivideByZeroException();
			}
			return a / b;
		}
	}


Ici, on a donc 2 tests à réaliser : que le résultat est bien la division de *a* par *b*, l'autre pour le cas particulier *b = 0*.

Un jeune développeur naïf, qui n'a jamais fait de test, il risque très probablement ceci :

« Comment tu as testé ton code ? »<br/>
« Ben j'ai lancé l'exe, pourquoi ? »<br/>
« Quel exe ‽‽‽ »

	:::java
	public class CalculatorTest {
		public static void main(String[] args) throws Exception {
			Calculator calculator = new Calculator();
			System.out.println(calculator.divide(6D, 2D));
			System.out.println(calculator.divide(1D, 0D));
		}
	}

… No comment …

## JUnit & Fest-Assert

Faire un bon test unitaire, c'est être capable de savoir exactement quelle portion de code fonctionne ou non.
Pour ça, on doit pouvoir exécuter chaque test unitaire indépendamment, ce qui n'est pas le cas <strike>du code</strike> de l'hérésie précédente.
En plus de ça, l'exécution des tests doit être entièrement automatisée et permettre de faire du reporting.

Pour faciliter la mise-en-place des tests-u, plusieurs librairies existent.
Parmis les plus connues, [JUnit](http://junit.org/) ou [TestNG](http://testng.org/).<br/>
JUnit tout seul ne fournit pas d'[assertion](http://fr.wikipedia.org/wiki/Assertion) suffisamment complexes (en réalité seule *assertTrue* est fournie), aussi il vaut mieux utiliser [Hamcrest](http://hamcrest.org/) qui fournit *assertThat* et toute sa clique de matchers (*is*, *hasItem*, *contains*…).
On peut aussi privilégier [Fest-Assert](https://github.com/alexruiz/fest-assert-2.x), qui propose une interface *fluent* à la place de méthodes statiques.

Pour les dépendances maven :

	:::xml
	<dependencies>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<scope>test</scope>
			<version>4.11</version>
		</dependency>
		<dependency>
			<groupId>org.easytesting</groupId>
			<artifactId>fest-assert</artifactId>
			<version>1.4</version>
			<scope>test</scope>
		</dependency>
	</dependencies>

Et les tests unitaires qui vont bien :

	:::java
	public class CalculatorTest {
		private final Calculator calculator = new Calculator();

		@Test
		public void testDivide() throws DivideByZeroException {
			assertThat(this.calculator.divide(6D, 2D)).isEqualTo(3D);
		}

		@Test(expected = DivideByZeroException.class)
		public void testDivideByZero() throws DivideByZeroException {
			this.calculator.divide(6D, 0D);
		}
	}

Tadam !!!
<center>![Tests results](/static/images/20130811/test-results.png)</center>

Pour les bonnes pratiques à avoir, on peut surtout citer :

  * chaque test doit tester une et une seule chose (le moins de *assert* possibles et tous cohérents)
  * chaque test doit être totalement autonome et ne rien présumer de son environnement (*setUp* et *tearDown* sont mes amis)

Ceci afin de permettre de détecter finement les régressions (et non pas se retrouver avec un *testAllTheApp* KO…) et d'avoir des tests reproductibles (« pourtant, il passait hier… » ou encore « ah tient, ça passe plus si je lance *testQuiNARienAvoir* avant *testQuiMInteresse* »…).

Les tests unitaires sont au final extrèmement importants pour la bonne marche d'un projet.<br/>
Sans eux, il est impossible de faire de la refactorisation de code sans avoir de garantie de n'avoir rien cassé au passage, surtout quand les modifications sont lourdes.<br/>
Ou encore ils permettent de savoir très exactement où en est un projet par rapport à la spécification. En méthode Agile, c'est ainsi un bon indicateur du travail terminé, et peut être utilisé pour le calcul de la vélocité par exemple.<br/>
Enfin, c'est aussi un moyen de faciliter le travail en équipe, chaque développeur ayant un moyen de vérifier que son travail n'a pas impacté d'autres personnes, mais aussi de permettre d'intervenir sur le code de quelqu'un d'autre en sûreté.

## Couverture de code

Une chose importante avec les tests unitaires est la notion de [couverture de code](https://fr.wikipedia.org/wiki/Couverture_de_code).
En effet, coder du test unitaire pour coder du test unitaire, ça n'a pas franchement d'intérêt.
Les tests unitaires doivent garantir trois choses :

  * l'ensemble des tests doit couvrir l'ensemble de la spécification
  * chaque ligne de code doit être couverte par au moins un test
  * chaque test doit couvrir au moins une ligne de code non couverte par le reste des tests

Ces trois règles permettent de garantir que toutes les fonctionnalités seront bien là, que le code écrit sera le code minimal possible et que les tests seront les tests minimums possibles, et donc qu'on a été le plus efficace possible.

Bien entendu, il est souvent difficile voire impossible d'atteindre ces trois points.<br/>
Le premier point généralement sur les cas qui dépendent de conditions difficiles à reproduire (disque plein, panne réseau…).
Le second aussi à cause des cas d'erreur, comme la gestion des exceptions ou des cas aux limites.
Le dernier parce qu'il est particulièrement difficile à quantifier et donc à vérifier.<br/>
Aussi en pratique on préfère se fixer des objectifs :

  * une spec couverte à 95% (le reste sera couvert par les tests d'intégration ou de validation)
  * une couverture de code à 85%
  * des tests qui semblent utiles et qui sont justifiables

Des outils de mesure de la couverture de code existent, comme [Cobertura](http://cobertura.github.io/cobertura/) ou [JaCoCo](http://www.eclemma.org/jacoco/).

Dans le cas de la mini-application précédente, on est tout bon niveau couverture de code :
<center>![Coverage results](/static/images/20130811/coverage-results.png)</center>

# Reporting et analyse

## Génération de rapports de test et de couverture de code

Maven permet de générer facilement des rapports de passage des tests unitaires et de sa couverture de code associée.<br/>
Tout se passe encore une fois dans le *pom.xml* :

	:::xml
	<build>
		<plugins>
			<plugin>
				<groupId>org.jacoco</groupId>
				<artifactId>jacoco-maven-plugin</artifactId>
				<version>0.6.3.201306030806</version>
				<configuration>
					<destfile>${basedir}/target/coverage-reports/jacoco-unit.exec</destfile>
					<datafile>${basedir}/target/coverage-reports/jacoco-unit.exec</datafile>
				</configuration>
				<executions>
					<execution>
						<id>jacoco-initialize</id>
						<goals>
							<goal>prepare-agent</goal>
						</goals>
					</execution>
					<execution>
						<id>jacoco-site</id>
						<phase>package</phase>
						<goals>
							<goal>report</goal>
						</goals>
					</execution>
				</executions>
			</plugin>
		</plugins>
	</build>
	<reporting>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-surefire-report-plugin</artifactId>
				<version>2.15</version>
			</plugin>
			<plugin>
				<groupId>org.jacoco</groupId>
				<artifactId>jacoco-maven-plugin</artifactId>
				<version>0.6.3.201306030806</version>
			</plugin>
		</plugins>
	</reporting>

C'est un peu indigeste, surtout pour la partie JaCoCo (Cobertura est plus simple mais ne fonctionne plus avec Java 7), mais le résultat est là après un petit *mvn site* :
<center>![Tests report](/static/images/20130811/test-report.png)</center>
<center>![Coverage report](/static/images/20130811/coverage-report.png)</center>

## Intégration continue

On <strike>peut</strike> doit intégrer JUnit et JaCoCo dans le processus d'intégration continue.

Pour JUnit, il existe un plugin intégré par défaut, qui suivra les résultats des tests et <strike>signalera</strike> spammera l'auteur du commit qui a tout cassé.
<center>![Tests trend](/static/images/20130811/test-trend.png)</center>

Idem pour Cobertura, on obtient facilement des graphiques de suivi de la couverture de code.
À l'inverse du passage des tests où on peut crucifier en place publique le responsable d'une régression dans le code, la qualité de la couverture de code s'effectue sur le long terme. C'est la tendance générale à la hausse ou à la baisse et son écart par rapport à l'objectif fixé qui décidera si l'équipe travaille bien… ou pas.
<center>![Coverage trend](/static/images/20130811/coverage-trend.png)</center>

Pour finir, [SonarQube](http://www.sonarqube.org/) permet aussi de suivre l'évolution de la qualité des tests (parmis tant d'autres choses) et s'intègre facilement à Jenkins.

# Conclusion

Les tests unitaires sont la pierre angulaire d'un projet de qualité.

Avec une couverture de code qui reste correcte au cours de la vie du développement, des tests unitaires toujours OK et des rapports générés et publiables facilement, la dette technique n'a qu'à bien se tenir et le client peut être rassuré !

Ils sont malheureusement mal vus, autant par les non-techniques (chef de projet, commercial, client, direction…) qui les considèrent comme du temps consommé inutilement (effectivement, ce code ne concerne aucune fonctionnalité réelle de l'application), que par les techniques à cause du côté rébarbatif de la chose et la difficulté à maintenir les tests unitaires opérationnels au cours du temps.

Mais ne pas en avoir serait bien pire pour un projet, avec des risques de régression non contrôlés ou une maintenance et évolutivité de l'application sans aucun échafaudage pour les guider.

À court terme, les tests unitaires peuvent sembler inutiles, mais sur le long terme, ils feront toute la différence entre une application de qualité et une application morte…
