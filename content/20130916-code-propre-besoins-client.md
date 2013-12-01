Title: Code propre, incompatible avec besoins client ?
Date: 2013-09-16
Category: dev
Tags: qualité, besoins, client, code propre

Cette semaine, une petite digression sur quelque chose que je remarque de plus en plus et qui me pose aussi de plus en plus de cas de conscience.<br/>
Est-il réellement possible de faire un code à peu près propre tout en respectant les besoins parfois même très élémentaires du client ?

J'ai en effet de plus en plus besoin de faire du code sale, voire même très très sale, pour arriver à respecter les demandes qui proviennent de mes clients.

# La gestion de la saisie utilisateur
## Détecter toutes les erreurs en une seule fois

Les applications que je développe sont généralement de gros valideurs de données.
Elles consomment des données fournies par l'utilisateur, vérifient si elles respectent les contraintes métier du secteur d'activité, et alertent l'utilisateur en cas d'erreur.

La théorie voudrait donc que je code quelque chose comme :

	:::java
	class SomeService {
		public void load(input) throws BusinessException {
			checkRule1(input);
			checkRule2(input);
			…
		}
		
		private void checkRule1(input) throws BusinessException1 {
			…
		}

		private void checkRule2(input) throws BusinessException2 {
			…
		}
	}

Code clair, facilement testable unitairement, avec une complexité cyclomatique très faible…
On peut même imaginer générifier facilement le système en externalisant les vérifications (dans un fichier de configuration par exemple).
Pour les tests unitaires, je peux aussi tester unitairement uniquement les méthodes de vérification, la méthode globale n'ayant que peu d'intérêt à être tester toute seule si tout le reste est bon (au pire, on a oublié une vérification).

Tout irait bien dans le meilleur des mondes… si on avait pas un client et des utilisateurs…<br/>
Le soucis, c'est que si on donne à manger au code précédent un gros fichier d'entrée, du genre tableur de 200 onglets et plusieurs milliers de lignes, le système ne remontera que la première erreur rencontrée.
Si l'utilisateur corrige cette erreur et réinjecte le fichier, il tombera sur la seconde erreur. Etc.<br/>
Le retour du client est généralement mauvais : « je ne peux pas utiliser cette application, mes utilisateurs n'en sont pas du tout satisfait ».
C'est encore pire quand la vérification prend parfois plusieurs heures, obtenir un fichier valide en devient même plus lent qu'une vérification manuelle.

On en arrive donc à coder des choses du style :

	:::java
	class SomeService {
		public Collection<BusinessException> load(input) {
			Collection<BusinessException> errors = new List<>();
			try {
				checkRule1(input);
			} catch (BusinessException1 e) {
				errors.add(e);
			}
			try {
				checkRule2(input);
			} catch (BusinessException2 e) {
				errors.add(e);
			}
			…
			return errors;
		}
		
		private void checkRule1(input) throws BusinessException1 {
			…
		}

		private void checkRule2(input) throws BusinessException2 {
			…
		}
	}

Gloups… SonarQube en perd son joli vert pomme…<br/>
Ce code devient difficile à tester (dans quel sens vont sortir les erreurs, je ne peux pas différencier facilement deux cas d'erreurs différents qui remontent la même exception…), est peu évolutif (ajouter une règle = beaucoup de lignes de code et de risque d'erreur).
On voit aussi que si les règles deviennent complexes, avec aussi plusieurs cas d'erreurs possibles à l'intérieur, la complexité devient aussi anarchique dans les méthodes de vérification elles-mêmes.

On introduit aussi un type de retour non métier, qui vient polluer le code.
Par exemple si nos méthodes sont aussi chargées de créer des objets du domaine (cas avec une base de données), elles ne peuvent plus remonter directement l'objet nouvellement créé.<br/>
On en arrive à encapsuler les types de retour dans des conteneurs non métier (`GenericReturn<T, E extends Exception>`) ou à revenir à l'hérésie du passage par référence (`private BusinessObject parse(final SomeInput input, Collection<Exception> notFinalAndMutableErrors`, avec du bon gros argument mutable voire pire non final). Pouark…

On rencontre aussi un autre problème qui est la dépendance entre les vérifications.<br/>
Autant quand on s'arrête dès la première erreur rencontrée, on a la garantie que tout ce qu'on a est correct.
Si on continue malgré l'erreur, on peut générer une erreur lors d'une vérification ultérieure (attribut manquant, objet nul…).
Le code devient alors une plâtrée de `if/then/else` et autres `try/catch` dans tous les coins, des tests de nullité partout pour s'assurer qu'on a bien tout ce qu'il nous faut…<br/>
Et on ne sait pas quoi faire si on tombe sur un cas non géré.
L'afficher à l'utilisateur se résumerait à des erreurs « techniques » (null pointer, missing attribut…) sans la capacité à remonter à la cause primaire de l'erreur.
Chercher à la filtrer est quasiment impossible, on n'a que difficilement la capacité de déterminer si l'erreur est « normale » (due uniquement aux entrées) ou « induise » (due à une erreur précédente).

Bref, vouloir afficher toutes les erreurs d'entrées, qui est effectivement un besoin recevable pour un utilisateur lambda, conduit à de la dette technique importante.<br/>
Le barbu du coin est moins enclin à ce genre de demande car à l'habitude de se faire envoyer bouler loin du terminal à la moindre erreur sur sa ligne de commande, et de devoir jouer au Petit Poucet à corriger ses erreurs une à une.

## Le syndrôme « Windows »

« Une erreur est survenue. Voulez-vous tout de même continuer ? »
Qui n'a jamais pesté devant ce message…
Et bien pourtant, certains clients en redemandent !<br/>
Dans le cas idéal, une application est censée vérifier les données saisies et d'interdire formellement toute saisie erronée.

	:::java
	class SomeGui {	
		void onValid() {
			try {
				service.doIt(someInput);
			} catch (Exception e) {
				showError(e);
			}
		}
	}
	
	class SomeService {
		void doIt(SomeInput someInput) throws BusinessException {
			checkRule1();
			checkRule2();
			…
			act();
			…
		}
	}

Là encore, code propre, complexité cyclomatique proche de 0, bonne testabilité…
Et surtout la garantie que l'API de l'application (couches *service* et inférieures sur une architecture 3-tiers) ne permet pas de faire quelque chose d'interdit au niveau métier.

Mais voilà, le métier du client étant ce qu'il est, on voit souvent des besoins du style « théoriquement ce n'est pas sensé pouvoir arriver, mais sur le cas TrucMuche du projet Tartampion, on a déjà du le gérer ».
Bref, c'est interdit mais c'est autorisé…<br/>
Le besoin exprimé en terme technique est « On doit vérifier que ce cas n'arrive pas. S'il arrive, on doit le signaler à l'utilisateur qui prendra la décision de continuer ou non ».
Niveau code :

	:::java
	class SomeGui {	
		public void onValid() {
			try {
				service.check(someInput);
			} catch (Exception e) {
				if (showErrorAndAskIfContinue(e)) {
					service.act();
				}
			}
		}
	}
	
	class SomeService {
		void check(SomeInput someInput) throws BusinessException {
			checkRule1();
			checkRule2();
			…
		}

		void act(SomeInput someInput) {
			act();
			…
		}
	}

Rhaaaaaaaaaa… « Complexité cyclomatique en hausse… Testabilité en baisse… Environnement critique… Danger… Danger… Veuillez évacuer le vaisseau, auto-destruction dans 10… 9… ».

En dehors de la qualité de code pour elle-même, là on a aussi un énorme problème de sécurité de l'application : les contrôles métier peuvent être contournés.
On n'interdit plus les saisies erronées, et l'utilisateur peut très bien se tromper et confirmer la saisie sans voir l'impact de sa saisie sur le reste de son processus.<br/>
Et encore une fois, on pollue aussi tout le reste de l'application, on ne peut peut-être plus mettre de contrainte *not null* dans la base ou avoir des objets manquants plus tard, ce qui peut mettre en péril l'intégrité de la base ou faire planter l'application sur un `NullPointerException` totalement incompréhensible car du à une erreur de saisie 10h auparavant.

Pour finir, on amène aussi un autre problème : si l'utilisateur a déjà souhaité continuer le processus malgré une erreur, il ne veut plus se faire notifier du problème à chaque action future…
Ben oui, si on fait une vérification à un endroit, on risque fort de faire cette vérification ailleurs dans le code…<br/>
On se retrouve alors à devoir coder des heuristiques et des tests dans tous les coins (« Ah oui, si on a ça, alors c'est qu'il a du faire ça et donc là on ne doit pas lever d'erreur ») ou à essayer d'enregistrer quelque part le contexte de la saisie pour détecter une double détection d'erreur (merci les faux positifs et surtout les faux négatifs…).

Encore une fois, le besoin primaire du client est recevable d'un point de vue utilisabilité, mais conduit à une augmentation de la dette technique.
Et il n'est généralement pas prêt à payer cette dette, et encore moins à comprendre pourquoi le développeur rechigne autant à lui développer sa demande ou lui chiffre un coût énorme pour ce qu'il perçoit comme une petite modification.

# Les interfaces graphiques
## Le méga pack bonus « all-in-one » qui fait Papa-Maman

**LE** classique du classique. Et en prime celui qui n'a pas de solution…

L'utilisateur, tout comme le développeur, n'est qu'un gros fainéant.
Et comme tout bon fainéant, il veut en faire le moins possible en un minimum de temps.
Et réclame donc une interface graphique où il peut tout saisir en une seule fois.<br/>
Faire une interface bardée de boutons, de grilles, d'onglets, comme on en voit à la télé dans n'importe quelle série américaine, tout développeur avec suffisamment de café dans le sang sait le faire.<br/>
Lui donner vie après, c'est là que ça devient coton…

Les bonnes pratiques indiquent qu'on doit mettre en place du [MVC](http://fr.wikipedia.org/wiki/Modèle-vue-contrôleur), c'est-à-dire que la partie vue est branchée sur un modèle de données, et que les deux sont mis en relation par un contrôleur.<br/>
La partie dynamique de l'interface est gérée par des évènements (« tel bouton a été cliqué », « telle valeur a été modifiée »…), de manière asynchrone.
Au final, derrière la richesse de l'interface se cachent une armée de petits évènements qui n'attendent qu'un courant d'air pour entamer la danse de l'enfer : « ah tient, ça a bougé ici, faut que je rafraîchisse là », « ah tient, ça a bougé là, faut que je mette à jour là-bas », « ah tient, ça a bougé là-bas, faut que je change par-ici »…<br/>
Il est passé par ici, il repassera par-là ! Ça commence tout mignon [comme ça](/static/images/20130916/chaton1.png), ça finit tout mal [comme ça](/static/images/20130916/chaton2.png). Et du coup le développeur, il regarde son client [comme ça](/static/images/20130916/chaton3.png).

Le code théorique pour gérer une interface très complexe ne serait pas si complexe que ça au final.
Tout au plus il serait assez long, mais il se limiterait à associer un traitement à un évènement, les évènements étant eux aussi relativement simples.<br/>
Mais tout se déclencherait en parallèle, sans qu'on puisse contrôler le flot réel (qui suivrait en réalité uniquement les dépendances des données).
En terme de spécifications, il n'y a donc pas un seul cas d'utilisation à s'exécuter, mais tous à la fois : si un cas A dit que telle valeur doit être modifiée et qu'un autre cas B dit que la modification de cette valeur doit déclencher un traitement, alors ce traitement sera déclenché si la valeur est modifiée, même si on n'est pas dans le cas B.

Un exemple typique est les listes liées.
Une liste B affiche les éléments associés aux éléments sélectionnés d'une liste A. Idem entre la liste C et la liste B.<br/>
Le code est donc très simple :

	:::java
	class SomeGui {
		SomeGui() {
			listA.onSelectionChange({
				listB.setItems(listA.getSelectedItem());
				listB.selectItem(0);
			});
			listB.onSelectionChange({
				listC.setItems(listB.getSelectedItem());
				listB.selectItem(0);
			});
		}
		
		void reload() {
			listA.setItems(someDatas)
			listA.selectItem(0);
		}
	}

Ça peut paraître très simple comme ça, mais en fait le processus des évènements va être ultra-complexe. Un des effets de bord les plus visibles a lieu lorsqu'on change les données de la liste A, par exemple si on recharge les données.

  * En interne, la liste A commencera par être vidée.
  * Cela change la sélection dans la liste A, donc déclenche le traitement de B.
  * A n'ayant pas (encore) d'éléments, B va aussi vider sa liste (pas d'élément associé).
  * Cela change aussi la sélection de B, donc déclenche le traitement de C.
  * B n'a pas d'élément sélectionné, C se vide donc.
  * Les nouveaux éléments de A sont insérés.
  * On sélectionne (par programmation) le premier élément de A, donc on déclenche le traitement de B.
  * B affiche les éléments associés.
  * On sélectionne le premier élément de B, donc lance le traitement de C.
  * C affiche les données associés.

On se retrouve avec un double rafraîchissement de l'interface, totalement involontaire et non souhaitable.
Quand les traitements sont suffisamment rapides, ce n'est pas perceptible par l'utilisateur. Dès qu'ils deviennent long ou intéractifs (accès à une base de données relativement lourde, message à l'utilisateur…), ça en devient de suite plus visible et est même considéré comme un bug par le client.

En plus de ça, on a ici une interface ultra-simple, les effets de bord explosent exponentiellement avec le nombre d'évènements potentiels à gérer.
Sur une interface un tant soit peu plus compliqué, on arrive très vite à ne plus savoir quelle cascade va se déclencher au moindre mouvement.

Si on veut éviter ces boucles, il faut soit débrayer l'évènementiel interne du langage utilisé (si c'est possible), soit le coder nous-même (booléens et test `if (eventXEnabled)` partout).
Dans les deux cas, le problème se pose de quand désactiver et réactiver les évènements. La moindre erreur d'appréciation conduit à une interface complètement gelée (évènementiel désactivé trop tôt on jamais réactivé), ou à l'inverse trop réactive (évènementiel désactivé trop tard ou réactivé trop tôt).<br/>
On peut aussi chercher à ne plus passer par la gestion d'évènements et coder directement les actions *ad-hoc*.
Mais on complexifie énormément le code et l'évolutivité/maintenance tend alors vers zéro.

Encore et toujours, un besoin recevable (quoi que déjà plus litigieux) mais une implémentation [à faire boire du Coca-Cola à Richard Stallman](http://stallman.org/rms-lifestyle.html).<br/>
Ce point est sûrement le plus handicapant de tous ceux qui seront abordés ici, car il n'y a à mon avis pas de solutions élégantes à ce problème, sinon à remettre en cause la plupart des bibliothèques graphiques existantes, qui se reposent exclusivement sur du MVC ou dérivé.

## « Ah oui, mais ici je préfère ça comme ça »

Ici, on va passer surtout dans le monde web, même si on peut trouver la même chose dans une version client lourd, en moins violent.

Le problème est simple : on aimerait pouvoir définir des composants graphiques réutilisable. Par exemple, le formulaire de création d'un utilisateur.<br/>
Conceptuellement parlant, on devrait écrire quelque chose comme ça :

	:::erb
	<%= form_for @user, class: %w(well) do |f| %>
		<%= f.text_field :name, required: true %>
		<%= f.text_field :surname, required: true %>
		<%= f.password_field :password, required: true %>
		<%= f.submit %>
	<% end %>

En Ruby on Rails, on pourrait en faire un *partial* réutilisable en définissant ça dans un fichier `_user.html.erb` séparé, et en l'appelant avec un `render 'user'`.

Tadam ! On n'est-y pas les rois du monde là ?<br/>
« Euh oui, mais moi sur la page X, je veux le formulaire centré et qui prend la moitié de la page, alors que sur Y, je le veux tout à droite à 33% »<br/>
Bam… Dur retour à la réalité du terrain… Bon, rajoutons des arguments :

	:::erb
	<% classes = %w(well)
		classes << span
	%>
	<%= form_for @user, class: classes do |f| %>
		<%= f.text_field :name, required: true %>
		<%= f.text_field :surname, required: true %>
		<%= f.password_field :password, required: true %>
		<%= f.submit %>
	<% end %>
	
	<%= render 'user', span: 'span6' %>

Où est le couteau que je me coupe la main d'avoir osé écrire ça !!!<br/>
« Ah oui, mais si on est sur la page des administrateurs, on saisit le mot de passe pour l'utilisateur, donc il doit être en clair et pas avec des étoiles »<br/>
Quuuuuuuoi ! Comment ça les admins connaissent le mot de passe de vos utilisateurs ‽‽‽ Et en plus parce que tu fais n'importe quoi, tu me demandes d'en faire de même ‽‽‽ Awé, zut, c'est toi qui paie… Bon…

	:::erb
	<% classes = %w(well)
		classes << span
	%>
	<%= form_for @user, class: classes do |f| %>
		<%= f.text_field :name, required: true %>
		<%= f.text_field :surname, required: true %>
		<%= f.call("#{clear ? 'text', 'password'}_field", :password, required: true) %>
		<%= f.submit %>
	<% end %>
	
	<%= render 'user', span: 'span6', clear: true %>

La seconde main vient d'y passer… Et il reste encore à gérer la couleur, la police, la gestion des erreurs, à intégrer le framework graphique ([qui a dit *Bootstrap* !](|filename|/20130313-frameworks-css.md))…
« Dev cherche mains d'occasion, bon état, peu kilométrages. Faire suivre au journal qui transmettra »

On voit bien que le côté réutilisable d'un composant va être proportionnel à son nombre d'arguments et à sa complexité, donc inversement proportionnel à sa qualité. Un comble quand même…<br/>
Et on va finir par mélanger forme et fond, à faire du copié/collé de partout, au détriment de l'évolutivité et de la maintenance encore une fois.

# Conclusion

Si on lâche un client dans la nature, on se retrouve vite avec une usine-à-gaz improbable, avec des besoins tous plus délirants et complexes les uns que les autres.
Et des développeurs qui finissent manchots, pendus au plafond par un câble RJ45 ou la tête dans le broyeur de la machine à café.

Ceci vient en fait qu'on a habitué les utilisateurs à de l'assistanat pur et dur et à céder à tous leurs caprices.
On comprend mieux que de véritables champs de mine à la Windows aient autant de succès.<br/>
À l'inverse, les utilisateurs plus barbus, habitués à la ligne de commande, préfèrent cascader une foultitude de commandes simples pour obtenir un résultat complexe (mais avec un processus au final maîtrisable et compréhensible).
Ils n'oseraient même pas réclamer ce genre de fonctionnalités gogo-gadgeto-couteau-suisse (au mieux uniquement du domaine de la cosmétique, au pire totalement inutiles) et les considèrent comme de l'hérésie pure et dure.

Ce problème de mauvaise qualité de code due à des demandes « farfelues » sont d'autant plus piégeuses qu'on a du mal à annoncer (et donc à faire payer) au client le coût de cette dette accumulée.<br/>
La fonctionnalité demandée est perçue comme primordiale par le client, et simple à réaliser par les chefs de projets, et sera donc implémentée à tout prix sans tenir compte des alertes des développeurs.<br/>
La dette technique éclatera juste en plein jour pile au moment critique qu'il ne fallait pas.
L'accumulation de taches simples mais sales conduira à moyen terme à ne plus pouvoir implémenter une fonctionnalité réellement importante théoriquement simple mais infaisable avec la dette technique totale, ou à surcoût/complexité totalement incompréhensible par le client, ou avec des effets de bords incroyables.

Comme on dit en anglais : « When the shit hits the fan… »
