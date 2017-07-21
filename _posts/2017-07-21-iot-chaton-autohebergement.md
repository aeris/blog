---
title: Réflexion autour de l’auto-hébergement et des CHATONS
---

Après [ma grosse réflexion autour du logiciel libre](|filename|/2017-02-21-logiciel-libre-gouvernance-ethique.md), une nouvelle réflexion autour de l’hébergement.
Une nouvelle fois, elle a été initiée suite à la publication d’un billet de blog et d’[un flux twitter](https://twitter.com/aeris22/status/831922352258686976)

# L’(auto-)hébergement est-il trop compliqué ?

Dans l’article initial, l’auteur fait le constat que les solutions actuelles de cloud personnel (Own/NextCloud & CozyCloud) sont complexes à installer et qu’il faut des connaissances en administration système si on souhaite héberger ça à la maison.

En pratique, on ne peut pas lui donner tord. C’est effectivement compliqué. Voire beaucoup.
Et même des personnes plutôt compétentes se prennent régulièrement les pieds dans le tapis.

Mais à la réflexion, cette complexité est en réalité normale.

## Un éco-système *de facto* complexe et unique

On parle d’installer des systèmes complexes, composés de beaucoup de sous-composants.
Outre l’application en elle-même, il y a quasiment toujours besoin d’un serveur de courriel, d’une base de données, d’un serveur web, de gérer des [certificats X.509](https://fr.wikipedia.org/wiki/X.509), un nom de domaine, de mettre les mains dans le réseau…
Certains morceaux sont même d’un niveau tel que même les « experts » du domaine se prennent régulièrement des claques et commettent des erreurs (le courriel, TLS ou DNS, si vous m’écoutez…).

En fait, il est même quasiment impossible d’avoir une recette miracle qui va s’adapter au contexte de l’hébergement final. Les configurations sont trop diverses, en particulier sur tout ce qui touche au réseau (FAI différents, box ADSL ou fibre différents…), pour espérer pouvoir gérer un service sans un minimum de configuration différentes.

Vous êtes chez Free ? Vous avez peut-être seulement [une demie-IP à disposition](http://www.numerama.com/tech/145703-free-peut-attribuer-la-meme-adresse-ip-a-plusieurs-abonnes.html). Vous êtes chez Bouygues ? Vous ne pouvez juste pas envoyer de courriel.
Chez OVH le réseau local est en `192.168.1.0/24` mais en `192.168.0.0/24` chez Free voire en `10.0.0.0/24` sur certaines configurations Bouygues. Et je ne parle même pas des manipulations complètement différentes dépendantes du modèle du modem et de la version de son firmware pour configurer le [NAT](https://fr.wikipedia.org/wiki/Network_address_translation) et ouvrir les ports nécessaires à l’utilisation du service. Ouverture de port qui nécessite d’assigner une IP fixe au périphérique, ce qui est déjà hors de portée d’un utilisateur lambda.
On pourrait aussi parler de la gestion d’un nom de domaine histoire de pouvoir taper autre chose que des IP pour accéder à son service.
Ou encore du problème d’[hairpinning](https://fr.wikipedia.org/wiki/Hairpinning) qui empêche sur certaines configurations d’accéder aux ressources internes d’un réseau à partir de son adresse externe si on est à l’intérieur du réseau.

Bref, on n’a pas le cul sorti des ronces… Parce qu’on n’a même pas commencer à effleurer le problème en fait…

## Un nécessaire besoin de compétences et de connaissances

Une fois qu’on aura le bagage nécessaire pour comprendre l’environnement dans lequel va évoluer son service (notions de TCP, DNS…), il va falloir maintenant comprendre comment interagir correctement avec lui (qui doit communiquer avec qui, comment et pourquoi). Comment emboîter tous les briques pour que tout fonctionne. Comment debugger en cas de problème (et les problèmes dans le monde réseau sont toujours **très** difficiles à cerner). Y intégrer des notions de sécurité, de mises-à-jour régulières, etc.

Bref, sans compétence, ça va être difficile et complexe. Très.

Prenons un exemple « simple ».
Il existe un outil, [ZMap](https://zmap.io/), capable de scanner tout Internet (en fait tout IPv4) en quelques heures. Oui, vous avez bien lu. Tout Internet. J’ai déjà joué avec pour lister [les serveurs VNC accessibles](|filename|/2016-03-02-vncfail.md) par exemple.
Des chercheurs [font tourner cet outil en permanence](https://scans.io/) pour analyser comment Internet est construit. Et ont même créé des outils très accessibles pour rechercher parmi les données récoltées, comme [Censys](https://www.censys.io/) ou [Shodan](https://www.censys.io/).
Le rapport avec la choucroute me direz-vous ? Et bien qu’il devient très facile de lister les instances [YunoHost](https://www.shodan.io/search?query=yunohost) publiques, ou celles de [OwnCloud](https://www.shodan.io/search?query=owncloud), de [NextCloud](https://www.shodan.io/search?query=nextcloud) ou de [CozyCloud](https://www.shodan.io/search?query=X-Cozy-Login-Page:).
En cas de faille de sécurité sur une de ces solutions, il se pose alors deux problèmes :

 * Sur les failles [0 day](https://fr.wikipedia.org/wiki/Vulnérabilité_Zero_day), un attaquant possède immédiatement une liste de machines à infecter. Shodan passant par exemple toutes les 24h, une nouvelle machine sera détectée et donc infectée dans le même délai.
 * Sur les failles standard, donc publiées volontairement par le projet initial, Shodan permettra aussi de lister toutes les instances pour chercher celles qui n’auront pas été mise à jour suffisamment rapidement, pour les infecter immédiatement.

Comment éviter ces problèmes ? Facile ! Très facile même. Ne pas apparaître dans Shodan et associés.
Comment fait-on en pratique ? Oups… Vous êtes bien assis ? C’est parti !

Il « suffit » d’avoir un [hôte virtuel](https://fr.wikipedia.org/wiki/Hébergement_virtuel) par défaut qui n’indique rien de ce qui tourne réellement sur la machine. Ainsi, quand ZMap va passer et vu qu’il ne se base que sur l’IP de la machine visée, il va tomber sur une page sans information utile.
Il faut aussi penser à lui assigner un certificat X.509 neutre, puisque si vous y mettez un certificat avec tous les autres domaines de votre machine (par exemple via du [SAN](https://en.wikipedia.org/wiki/Subject_Alternative_Name)), ZMap utilisera ces informations pour refaire des connexions réseaux correctes et lister les services qui tournent.
Du coup, il vous faudra aussi un nom de domaine donc, puisque l’accès par votre IP directe ne mènera à rien.
Donc mettre la main dans le DNS, au moins via votre [bureau d’enregistrement](https://fr.wikipedia.org/wiki/Bureau_d'enregistrement).
Du coup, cela nécessite aussi que l’installeur de votre solution ne soit plus 100% automatique, mais vous pose quelques questions pour pouvoir se configurer, au pif pour connaître votre nom de domaine.
Mais alors, comment je fais pour me connecter l’installeur à la première utilisation ? Zut, il va falloir que je trouve l’adresse IP qui va être assignée par la box. Donc trouver l’interface de gestion fournie par le FAI, comprendre où est le nouveau matériel pour enfin pouvoir s’y rendre via son navigateur web et enfin pouvoir configurer son service.

On récapitule ? Pour corriger ce simple problème qui relève des bonnes pratiques courantes pour un administrateur système, pour un utilisateur lambda il va falloir savoir acquérir un certificat X.509 correct (ce qui est un parcours du combattant à lui tout seul…), maîtriser sa box Internet et son interface d’administration pour trouver l’IP de départ du service et ouvrir les ports nécessaires, savoir répondre à la question « Quelle adresse IP libre de votre réseau souhaitez-vous assigner à votre service ? », trouver l’adresse IP publique de sa connexion (en espérant qu’elle soit statique et non dynamique…), savoir acquérir un nom de domaine, configurer son nom de domaine pour l’associer à l’IP publique, pour enfin avoir son service opérationnel… Et tout ça n’est absolument pas automatisable, puisque dépendant de bouzillions de contextes différents (OVH, Free ou Bouygues en FAI ? Let's Encrypt ou Gandi pour X.509 ? OVH, Gandi ou Online pour votre nom de domaine ?).

Et en cherchant à simplifier le processus, on le complexifie encore plus… Exemple ?
On simplifie la vie de l’utilisateur en installant [ZeroConf](https://fr.wikipedia.org/wiki/Zeroconf) pour éviter qu’il n’ait à chercher le service via l’interface de sa box mais directement en tapant `mon-service.local`. Problème ? ZeroConf se retrouve exposé sur Internet…
<figure>
	<img src="/assets/images/20170721/mdns.png" alt="mDNS" />
	<figcaption>
		mDNS ouvert sur un YunoHost
	</figcaption>
</figure>

Et du coup l’installeur devrait en plus réclamer que l’utilisateur soit en mesure de lui indiquer le sous-réseau et le masque de réseau utilisé par le réseau local histoire de mettre un bon pare-feu devant tout ça, ce qui nécessite encore plus de compétences par l’utilisateur…

Bilan : ce n’est pas de la mauvaise volonté si c’est compliqué de proposer un service en auto-hébergement, c’est **réellement** compliqué. Même pour ceux dont c’est le métier, il n’existe aucune recette de cuisine à dérouler pour obtenir le résultat souhaité. Il faut avoir des connaissances minimal en réseau, savoir réfléchir, prendre des décisions, tester, improviser…

# Quelles stratégies d’hébergement adopter ?

Pour traiter cette complexité, on a vu apparaître plusieurs stratégies autour de l’hébergement d’un service :

 * La prestation de service. Vous choisissez un prestataire qui va tout gérer pour vous. Vous payez, vous avez un service, point. C’est l’exemple de GMail ou de Microsoft Exchange.
 * Les objets connectés ou IoT. Vous achetez quelque chose au magasin du coin, vous le brancher chez vous, ça juste tombe en marche. Ce sont toutes les balances ou fontaine à chat connectées, ou d’une certaine manière les choses comme [Lima](https://meetlima.com/?lang=fr).
 * L’auto-hébergement. Vous êtes seul au monde pour installer des images toutes prêtes. C’est le mode de fonctionnement de [YunoHost](https://yunohost.org/) ou [CozyCloud](https://cozy.io/fr/).
 * L’hébergement communautaire. C’est la même chose qu’un service commercial, mais en version communautaire, généralement porté par une association. On peut citer tous [les CHATONS](https://chatons.org/).

Chacun possède ses avantages et ses inconvénients.

## Prestation de service : plus de prise de tête, mais plus liberté non plus…

Pour la prestation de service, ce mode a transféré toute la complexité précédente au niveau de votre prestataire, puisque plus rien n’est réellement chez vous et que vous ne faites que consommer des ressources externes (généralement web) situées sur son propre réseau, qu’il maîtrise pour le coup à 100%.

Vous êtes par contre très dépendant de votre prestataire, qui va souvent vous voler vos libertés au passage (difficulté de sortie, logiciel privateur…). Vous avez peu sinon pas de prise sur ses décisions et son infrastructure. Où sont vos données ? Quid si ses CGU/CGV changent du tout au tout du jour au lendemain ?

Le boulot est fait et même plutôt bien fait, sans que vous n’ayez besoin de mettre les mains dans la technique à un moment, mais en échange vous avez perdu votre âme…

## Objets connectés : fuyez pauvres fous !

Sauf très très rares solutions (comme Lima *a priori*), les choix techniques des objets connectés sont très criticables. En fait, il n’y a aucune prise en compte des difficultés présentées, qui sont juste contournées le plus salement possible…

Les problèmes de réseau sont « réglés » en faisant tout sortir sur Internet via un « cloud » géré par votre prestataire. Par exemple dans le cas d’une caméra connectée, vous ne vous connecterez jamais directement à elle, mais elle au « cloud » du fabriquant (le NAT ou le réseau ne pose pas de problème pour les flux de sortie) et vous aussi.

La sécurité y est trop souvent inexistante et les mises-à-jour fabriquant impossible (matériel pas pensé pour). Vous avez donc un truc pas cher, *plug & forget* (branchez & oubliez), mais une catastrophe en terme de bonnes pratiques.
C’est ce qui a conduit à la création de [botnets](https://fr.wikipedia.org/wiki/Botnet) géants tel que [Mirai](https://fr.wikipedia.org/wiki/Mirai_(logiciel_malveillant)). Ce qui donne [ça](https://fr.wikipedia.org/wiki/Cyberattaque_de_2016_contre_Dyn) et [ça](http://www.zdnet.fr/actualites/ovh-noye-par-une-attaque-ddos-sans-precedent-39842490.htm) en pratique…

## L’auto-hébergement : accompagnement nécessaire et ne passe pas l’échelle

Héberger ses services sur ses propres machines, on l’a vu, c’est (très) compliqué si on souhaite faire les choses proprement et ne pas devenir un danger pour les autres machines du réseau. Cela nécessite de solides compétences pour parvenir à un résultat acceptable qui ne transformera pas votre service en Mirai 2.0 à plus ou moins long terme.

Les solutions actuelles (YunoHost, CozyCloud, Own/NextCloud, La Brique Internet…) tentent de faire du mieux qu’elles peuvent pour fournir des images simples à installer.
Mais le manque de compétence côté utilisateur associée à la complexité de l’environnement d’accueil font que malheureusement, ces images sont souvent perfectibles en termes de bonnes pratiques et de sécurité.

Ces lacunes techniques, induites par l’impossibilité de réclamer un master en informatique aux utilisateurs, sont compensées par un accompagnement et une sensibilisation des utilisateurs à la problématique de l’auto-hébergement et aux devoirs et risques associés.
Vous ne repartez jamais réellement seul avec votre [Brique Internet](https://labriqueinter.net/), vous pouvez compter sur la communauté de [Franciliens](https://franciliens.net/) ou de [FDN](https://www.fdn.fr/) en cas de problème. Idem sur les autres solutions, les forums de support sont là pour aider les utilisateurs.

Malheuseurement, l’auto-hébergement ne passeraient pas l’échelle.

Niveau sécurité, les lacunes techniques constatées sont peu dangereuses parce qu’il n’y a que peu d’utilisateurs en réalité. Même si une faille était constatée, les machines infectées ne se compteraient que par dizaines ou centaines, et non par centaines de milliers comme pour les CCTV de Mirai. Il en serait certainement autrement si on comptait des millions d’utilisateurs de Brique Internet ou de CozyCloud auto-hébergé.

Pour la sensibilisation, on peut se permettre de prendre du temps pour les utilisateurs parce qu’on en forme 10 ou 20 sur un week-end. On ne pourrait très clairement pas tenir la cadence s’il fallait en gérer 1 000 ou 10 000 par jour.

Bref, l’auto-hébergement ne tient la route que parce qu’il reste anecdotique. S’il prenait de l’ampleur, on finirait très rapidement par finir dans la catégorie « IoT », avec des milliers de bidules oubliés dans un coin à la merci du premier botnet qui passe.
Pour démocratiser l’auto-hébergement, il faudra donc obligatoirement passer par une formation plus que poussée des utilisateurs.

## Les CHATONS : la solution idéale, mais des choses à inventer

Sur l’hébergement communautaire à la CHATONS, la complexité est gérée par ceux qui savent la gérer : les [administrateurs système](https://fr.wikipedia.org/wiki/Administrateur_système).
L’informatique a l’énorme avantage qu’il suffit de peu de personnes compétentes pour gérer des services pour beaucoup de monde. Via une association et des bénévoles, on peut donc proposer des services à grande échelle (1 000 à 10 000 personnes), gérés par quelques techniciens, sans pour autant tomber dans les travers précédents.

La charte des CHATONS empèche l’enfermement, vous pouvez facilement passer d’un CHATON à un autre (même si parfois le travail est toujours [en cours](https://framablog.org/2016/03/15/un-financement-pour-pouvoir-se-liberer-de-framasphere/) pour y parvenir).
La même charte impose la transparence, ce qui permet de contrôler ce qui est fait de vos données et l’orientation générale du projet est décidée collégialement. Le risque de dérive ou de perte de liberté sont donc plus que minimes.

Ça semble être une solution idyllique, pourtant ce nouveau type de projet va devoir innover dans plusieurs domaines pour être réellement intéressants à long terme.

Il est fort peu probable que tous les CHATONS se mettent à proposer l’ensemble de tous les services existants sur la planète. Les ressources techniques ou financières nécessaires calmeront rapidement les ardeurs. Les CHATONS vont du coup entrer en compétition les uns avec les autres, et de plusieurs manières.

Un utilisateur aura naturellement tendance à aller vers les CHATONS proposant le plus de services possibles, ne serait-ce que pour réduire le coût global (beaucoup de chatons risquent de ne pas être gratuits) ou la « paperasse » nécessaire (comptes à gérer, adhésions…). Ce qui risque de tuer dans l’œuf les petites solutions avec peu de moyens, au détriment des gros, en plus de recréer des silos de données.
Ce problème existe déjà dans le domaine de la presse en ligne : on ira plutôt s’abonner chez un ou deux journaux généralistes (le Monde, Next Inpact, Mediapart…), plutôt que chez de multiples petits journaux spécialisés.
Par définition les CHATONS vont devoir se limiter en nombre d’utilisateurs pour ne pas devenir un nouveau Google, les conflits et frustrations n’en seront que plus violent (un service généraliste allant rapidement saturer, il ne laissera que le choix de services spécialisés).

Un utilisateur risque aussi d’être fort peu content d’avoir à payer plusieurs fois un même service auprès de CHATONS différents juste parce que chacun propose un service spécial et en plus avoir à payer pour des services qu’il n’utilise pas.
Si par exemple je souhaite un service de courriel, un de pad, un de stockage et un de calendrier, mais que les seules offres disponibles sont « courriel + pad », « pad + stockage » et « courriel + calendrier + voip », je vais devoir m’abonner à tous ces services, me retrouver avec un doublon sur le pad et le courriel et un service de voip dont je n’ai pas besoin…
En pratique, on risque même de se heurter à des limitations financières et donc à des utilisateurs se restreignant sur les services parce qu’ils n’ont pas les moyens de tout payer, tout comme beaucoup doivent aujourd’hui se retreindre à certains médias en ligne.
Niveau frustration, ça risque donc d’être assez rigolo.

Côté opérateurs de CHATONS, il risque aussi d’y avoir des stratégies bizarres.
Les services les plus utilisés au quotidien (pad, sondage…) sont aussi généralement les moins onéreux et complexes à mettre en œuvre alors qu’ils vont être considérés comme à forte plus-value par les utilisateurs.
À l’inverse, les services pourtant utilisés plus ponctuellement dans la tête des utilisateurs (hébergement de vidéo, voip, minecraft…) sont des services extrêmement complexes à gérer et coûtants vraiment très chers en permanence (ce n’est pas parce que vous ne regardez pas une vidéo HD qu’il ne faut pas stocker ses 4Go quelque part tout le temps).
On risque donc de se retrouver avec des services très rentables d’un côté avec quasiment tout le monde qui les proposent, et des services clairement difficiles à rentabiliser proposé par peu de monde.

Sans grand gourou pour réguler un peu tout ça et mettre en place des vases communicants en particulier financiers (à-la-[FFDN](https://www.ffdn.org/)), la loi de la jungle risque d’être rapidement la règle.
