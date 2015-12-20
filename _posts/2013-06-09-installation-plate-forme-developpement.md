---
title: Installation d’une plate-forme de développement
---

Aller, au programme cette semaine, comment installer un environnement de développement.

Le développement d'un logiciel, c'est avant tout savoir s'entourer des bons outils.
Le code en lui-même n'est qu'un tout petit maillon de la chaîne pour réaliser un bon programme.

L'environnement Java est un des environnements les plus aboutis à ce niveau, avec le code pur et dur qui passe quasiment à l'arrière-plan et s'efface au profit d'une méthodologie et d'outils d'assistance au développement.

# Prérequis

Les outils présentés par la suite existent en deux versions.

 * une version standalone, qui fonctionne en autonomie
 * une version webapp, qui nécessite un conteneur de servlet

Pour éviter d'avoir 42 JVM à tourner sur la machine d'accueil et l'utilisation d'autant de ports différents, je préfère tout monter dans un [Tomcat](https://tomcat.apache.org/) en mode webapp.
Et comme je n'aime pas exposer directement mes Tomcat en plus de préférer de jolies URL sans port, je monte un serveur [Apache](http://httpd.apache.org/) en proxy devant, via les possibilités de communication [AJP](http://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html) de Apache et Tomcat.

L'installation de Tomcat est enfantine sous Debian :

	apt-get install openjdk-7-jdk tomcat7 libapr1

Comme je n'accèderai pas au Tomcat par HTTP mais uniquement par AJP, une modification s'impose dans */etc/tomcat7/server.xml*

{% highlight xml %}
<!-- Commentez cette ligne -->
<!-- Connector port="8080" protocol="HTTP/1.1" /-->

<!-- Décommentez cette ligne et ajouter l'attribut URIEncoding -->
<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" URIEncoding="UTF-8" />
{% endhighlight %}

Côté Apache, ce n'est guère plus compliqué

	apt-get install apache2
	a2enmod proxy_ajp

On déclare ensuite un nouveau vhost pour Apache, qui servira tout le contenu de notre forge, dans */etc/apache2/sites-available/forge* :

{% highlight apache %}
<VirtualHost *:80>
	ServerName forge
	DocumentRoot /var/www

	LogLevel warn
	CustomLog ${APACHE_LOG_DIR}/forge.log combined
	ErrorLog ${APACHE_LOG_DIR}/forge.err
</VirtualHost>
{% endhighlight %}

On active le vhost :

	a2ensite forge

Je conseille d'arrêter Tomcat et Apache avant d'aller plus loin, et de tout redémarrer une fois l'installation finie, sous peine d'avoir quelques petits problèmes de permission et/ou de configuration.

	service apache2 stop
	service tomcat7 stop

# Jenkins

J'ai souvent mentionné dans mes articles précédents l'[intégration continue](http://fr.wikipedia.org/wiki/Intégration_continue).
Le concept derrière ce nom est très simple : recompiler fréquemment (à chaque commit en gestion de configuration) et intégralement notre projet, en le soumettant à toute une batterie de tests (tests unitaires, tests d'intégration, test de déploiement…) et en alertant au plus tôt des problèmes rencontrés via des alertes et des rapports de build (métriques, couverture de tests, respect des normes de codage, détection des bugs ou mauvaises pratiques de programmation…).

Un outil extrêmement bien fait de CI est [Jenkins](http://jenkins-ci.org/).

L'installation n'est pas très complexe.
Il faut d'abord créer le futur répertoire d'accueil de Jenkins et lui donner les bons droits

	mkdir -p /srv/jenkins
	chown tomcat7:tomcat7 /srv/jenkins

Indiquer ensuite à Tomcat où trouver la future installation de Jenkins, dans le fichier */etc/default/tomcat7*

	# Ajouter la ligne suivante après JAVA_HOME
	JENKINS_HOME=/srv/jenkins

Ensuite, on télécharge Jenkins et on le prépare à être déployer dans Tomcat

	wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war -O /var/lib/tomcat7/webapps/jenkins.war

Côté Apache, on lui déclare de servir Jenkins via appel proxy AJP, dans */etc/apache2/sites-available/forge* :

{% highlight apache %}
<VirtualHost *:80>
	…
	ProxyPass        /jenkins ajp://localhost:8009/jenkins
	ProxyPassReverse /jenkins ajp://localhost:8009/jenkins
</VirtualHost>
{% endhighlight %}

Et voilà, c'est fini pour Jenkins !

# Sonar

La qualité d'un logiciel est quelque chose d'extrêmement important.
Un code-source avec des fichiers de milliers de lignes, des classes avec des centaines de méthodes ou des méthodes de centaines de lignes, c'est le meilleur moyen d'arriver à obtenir un logiciel totalement buggé, inmaintenable, non évolutif au possible, bref un truc infâme qui va coûter une blinde sur le long terme.

Pour s'assurer que notre code reste dans des métriques acceptables, il existe des outils d'analyse de code.
[Sonar](http://www.sonarsource.org/) en est un très bon exemplaire.
Il sort énormément de données, comme les couvertures de code, les métriques de code (nombre de lignes, nombre de classes, nombre de lignes par classe, nombre de méthodes par classe, nombre de lignes par méthode, complexité cyclomatique…) ainsi que des analyses de mauvaises pratiques (*equals* sans *hashCode*, « magic numbers », *instanceof*, ressources non fermées…).

Attention, cet outil sort *énormément* de données et graphiques en tout genre, ce n'est pas quelque chose à prendre au pied de la lettre.
Il faut surtout regarder la tendance générale du projet (la couverture de code ne doit pas s'écrouler, la complexité exploser ou les violations croître), pas chercher à arriver à 0 défaut sous peine de devenir totalement improductif !

L'installation est un peu plus complexe que celle de Jenkins, mais guère plus.

On commence par la base de données, avec un bon vieux [Postgresql](http://www.postgresql.org/) :

	apt-get install postgresql
	su postgres
	createuser -DRAP sonar
	createdb sonar -O sonar

Ensuite, on télécharge, on compile et on déploie :

	wget http://dist.sonar.codehaus.org/sonar-3.5.1.zip -O /srv/sonar.zip
	cd /srv
	unzip /srv/sonar.zip
	cd /srv/sonar-3.5.1/war
	vim ../conf/sonar.properties # On désactive la base par défaut et on active PostgreSQL
	./build-war.sh
	ln -s /srv/sonar-3.5.1/war/sonar.war /var/lib/tomcat7/webapps/sonar.war
	chown -R tomcat7:tomcat7 /srv/sonar-3.5.1

Et on finit par activer un nouveau proxy dans */etc/apache2/sites-available/forge* :

{% highlight apache %}
<VirtualHost *:80>
	…
	ProxyPass        /sonar ajp://localhost:8009/sonar
	ProxyPassReverse /sonar ajp://localhost:8009/sonar
</VirtualHost>
{% endhighlight %}

Il existe bien sûr un [plugin Sonar pour Jenkins](http://docs.codehaus.org/pages/viewpage.action?pageId=116359341), qui permet de lancer une analyse Sonar après un build réussi sur Jenkins.

Côté client, on peut indiquer à Maven comment accéder au Sonar, via *~/.m2/settings.xml*

{% highlight xml %}
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
	<profiles>
		<profile>
			<id>sonar</id>
			<activation>
				<activeByDefault>true</activeByDefault>
			</activation>
			<properties>
				<sonar.host.url>http://forge/sonar/</sonar.host.url>
				<sonar.jdbc.url>jdbc:postgresql:/forge/sonar/</sonar.jdbc.url>
				<sonar.jdbc.driver>org.postgresql.Driver</sonar.jdbc.driver>
				<sonar.jdbc.username>sonar</sonar.jdbc.username>
				<sonar.jdbc.password>sonar</sonar.jdbc.password>
			</properties>
		</profile>
	</profiles>
</settings>
{% endhighlight %}

# Nexus

[Maven](https://maven.apache.org/) est un véritable couteau-suisse, qui gère tout le cycle de vie de développement d'un logiciel.
Je ferai sans doute un article complet sur Maven, ici ce qui m'intéresse, c'est la gestion des dépendances.
Maven gère ça très proprement, via son fichier *pom.xml*, qui se contente de lister les bibliothèques nécessaires au projet (compilation, test, exécution…).
Les dépendances en elles-mêmes sont stockées dans des dépôts, celui par défaut étant [Maven Central](http://search.maven.org/).

Le téléchargement des dépendances avec Maven peut vite devenir (très) long, un projet de taille standard pouvant atteindre quelques centaines de bibliothèques.
Sur un réseau de mauvaise qualité ou à vitesse limitée, comme c'est généralement le cas en entreprise sur le trafic extérieur, cela devient vite pénible.
En plus, certaines dépendances ne sont pas publiées dans le dépôt central, mais sur d'autres dépôts, comme [Codehaus](http://repository.codehaus.org/) ou [Atlassian](https://maven.atlassian.com/content/groups/public/).
On peut préciser la liste des dépôts à utiliser dans chaque projet via le *pom*, mais pose quelques soucis (maintenance, performances dégradées, …).
Et pour finir, on rencontre aussi des contraintes techniques (présence de proxy dans les entreprises) qui rendent la configuration par défaut de Maven problématique.
Nexus permet aussi de publier en interne ses propres artifacts, ce qui facilite leur distribution entre équipes et éviter d'avoir tout à recompiler depuis les sources.

Pour résoudre tous ces problèmes, il est possible d'installer un proxy Maven, qui se chargera de récupérer les dépendances à l'extérieur et les stockera en local : le premier accès sera lent (téléchargement depuis l'extérieur), tout les suivants ultra-rapides (cache sur le disque + réseau local).
Il existe plusieurs solutions de proxy, comme par exemple [Archiva](http://archiva.apache.org/) ou [Artifactory](http://www.jfrog.com/home/v_artifactory_opensource_overview).
Le plus connu est [Nexus](http://www.sonatype.com/nexus/), par Sonatype, l'entreprise à l'origine de Maven.

L'installation de Nexus n'est pas plus compliqué que les autres.

	mkdir -p /srv/nexus
	chown tomcat7:tomcat7 /srv/nexus
	wget http://www.sonatype.org/downloads/nexus-latest.war -O /var/lib/tomcat7/webapps/nexus.war

Indiquer ensuite à Tomcat où se trouvera le répertoire des données de Nexus, dans le fichier */etc/default/tomcat7*

	# Ajouter la ligne suivante après JAVA_HOME
	PLEXUS_NEXUS_WORK=/srv/nexus

Pour publier Nexus via Apache, on ajoute à nouveau quelques lignes dans */etc/apache2/sites-available/forge* :

{% highlight apache %}
<VirtualHost *:80>
	…
	ProxyPass        /nexus ajp://localhost:8009/nexus
	ProxyPassReverse /nexus ajp://localhost:8009/nexus
</VirtualHost>
{% endhighlight %}

Zou, affaire classée côté serveur.
Attention tout de même, étant donné que Nexus va sauvegarder sur disque tout ce qui sera téléchargé, on peut vite utiliser beaucoup d'espace disque.
Dans mon cas, j'atteins déjà 2Go sur mon Nexus personnel, 15Go sur mon pro, sachant que tout Maven Central pèse près de 700Go.

Côté client, il faut indiquer à Maven qu'il faut passer par le nouveau Nexus au lieu de directement passer par Internet.
Ceci se fait via le fichier *~/.m2/settings.xml* :

{% highlight xml %}
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
	<mirrors>
		<mirror>
			<id>central</id>
			<mirrorOf>*,!central-snapshot</mirrorOf>
			<url>http://forge/nexus/content/groups/public</url>
		</mirror>
		<mirror>
			<id>central-snapshots</id>
			<mirrorOf>central-snapshot</mirrorOf>
			<url>http://forge/nexus/content/groups/public-snapshots</url>
		</mirror>
	</mirrors>
</settings>
{% endhighlight %}

Et voilà, tous nos outils nécessaires sont maintenant installés.
Pensez à redémarrer Tomcat (*service tomcat7 start*) et tout le nécessaire sera accessible.
Ne reste plus qu'à coder !
