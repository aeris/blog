---
title: ! 'Framework CSS : bénédiction ou hérésie ?'
---

# Introduction

Depuis quelques temps déjà se développent des frameworks CSS pour réaliser nos sites Internet.
Le plus connu de tous étant sûrement [Bootstrap](http://twitter.github.com/bootstrap/), utilisé initialement par Twitter et rendu libre par la suite.

**Bonne ou mauvaise idée d'utiliser de tels frameworks dans vos applications ?**
Petit retour d'expérience…

# Une bonne idée

## Un design sympa accessible

Disons-le clairement, on est généralement très mauvais en design. Voire même très très mauvais.
Et en plus, faire quelque chose de joli depuis 0, ça prend du temps, beaucoup de temps.

Ces frameworks sont du pain béni pour les développeurs qui veulent une interface agréable sans se prendre la tête.
Ils arrivent avec un design clef-en-main, et donne un rendu quasi-professionel à moindre coûts.
Images, modèles, documentation… Rien ne manque pour se lancer immédiatement et se concentrer uniquement sur le corps de métier de l'application, sans penser à son design.

Redévelopper le même niveau de qualité coûterait facilement plusieurs dizaines de milliers d'euros.

## Ne pas réinventer la roue

Le web est semé d'embuches pour nous, pauvres développeurs.
Entre les soucis de non compatibilité avec les navigateurs, le support partiel ou buggé de certains standards (HTML, JavaScript ou CSS), il est très difficile de faire du code qui fonctionnera à peu près partout avec le même rendu.

Avec un framework CSS, plus besoin de se prendre la tête, tous les cas particuliers sont gérés nativement, et le rendu est quasi-identique quelque soit la configuration du client.
Plus de soucis de mise-à-jour à chaque version d'un navigateur, pour peu qu'on utilise des versions récentes du framework (par exemple via un CDN), notre site est automatiquement fonctionnel partout.

Et souvent, des bonus loin d'être négligeables, comme les fluid-layout pour un affichage sur mobile sans la nécessité de faire un site dédié !

# Une mauvaise idée

## Le syndrôme « je pense pour vous »

Utiliser une librairie n'est jamais quelque chose d'anodin : on remet entre les mains d'une personne tierce les fonctionnalités possibles de sa future application.
Tant que le framework fait ce que vous avez envie, tout va bien dans le meilleur des mondes.
Par contre, le jour où on souhaite faire quelque chose d'un peu spécifique, on peut se retrouver limiter par la généricité de la librairie.

Un site web est quelque chose d'assez personnel, et si on demandait à 100 développeurs de réaliser la même application, on aurait autant de sites différents que de personnes.
Il est donc très difficile d'appréhender ce que sera un site web, et encore plus de trouver une structure commune à tous.

Conceptuellement parlant, j'ai même encore du mal à envisager qu'il puisse être possible de réutiliser du code CSS d'un site à l'autre, comme on peut le faire si facilement avec des librairies de code plus conventionnel.

Les frameworks ont donc du commencer par inventer un espèce de formalisme pour site web.
La plupart impose une structure des pages sous forme de grille, ou l'utilisation de marqueurs et de classes qui leurs sont propres, afin de pouvoir mutualiser le code CSS.
On se retrouve alors avec une pseudo-généricité : plutôt que de gérer les cas « ronds » et « carrés », on va au mieux transformer tous les ronds en carré, au pire n'accepter que les carrés.

Et le jour où vous voulez vous écarter de leurs choix imposés, vous allez au devant de gros problèmes…
Il est par exemple impossible en Bootstrap de faire des en-têtes à menu déroulant en pur CSS. Ils imposent de le faire avec du JavaScript, ce qui est vraiment une hérésie. Ça a même existé à une époque et été supprimé depuis, et les développeurs refusent de l'intégrer à nouveau, malgré la colère des utilisateurs.
Idem, impossible de jouer avec certaines largeurs, par exemple pour agrandir une colonne de table avec un contenu un peu long.

Bref, faites comme les concepteurs de la librairie souhaitent que vous le fassiez… ou ne le faites pas !

## Des frameworks trop intrusifs

Bon, y'a pas, là-dessus, c'est **LE** mauvais point de ces frameworks, et un corollaire du point précédent.
**À cause du besoin de pseudo-généricité inversée, ils sont tous extrèmement intrusifs dans le code HTML.**

Alors qu'on martèle à tous les apprentis web-développeurs que HTML doit uniquement concerner le contenu et CSS uniquement la forme, ces frameworks imposent une certaine mise-en-forme HTML pour obtenir le rendu souhaité.

Le pire exemple est Bootstrap. On doit développer le site que Bootstrap nous impose, et non pas le site tel qu'on le souhaite.
Par exemple, alors qu'on aurait aimé afficher une ligne centrée qui prend 50% de la page, en HTML sans framework, cela donnerait (je mélange volontairement HTML et CSS par soucis de lisibilité)

{% highlight html %}
<div style="margin: auto; width: 50%">...</div>
{% endhighlight %}

alors qu'avec Bootstrap, on se retrouve rapidement à du

{% highlight html %}
<div class="container-fluid">
	<div class="row-fluid span6 offset3">
		...
	</div>
</div>
{% endhighlight %}

Pourquoi un container ? Pourquoi un offset de 3 et un span de 6 (Ah oui, la grid fait 12 donc 3 de marge à gauche + 6 pour la div + 3 pour la marge de droite ! Euh attend, c'est 12 ou 16 colonnes ?) ?
On est contraint d'ajouter des balises et du contenu uniquement pour tomber sur les bons sélecteurs CSS de Bootstrap.
Pour de la séparation forme/contenu, on a vu mieux…

Et cela se ressent aussi sur le code JavaScript de l'application, les id et autres sélecteurs JQuery devenant  parfois assez cryptiques, et plus du tout orienté application.
Idem, vous avez envie de changer un tout petit coin de votre page (au pif une colonne d'une table pas de la même table que les autres) ? Malheur à vous, ça risque de vous demander un effort surhumain.

## Une homogéinisation des sites web

Un autre corollaire de la pseudo-généricité : **tous les sites se mettent à se ressembler !**

Comme tout le monde se met à faire la même chose, il n'y a plus de réflexion, de créativité, d'innovation…
On se retrouve avec un web fade et sans saveur.

Les librairies CSS sont une finalité en soi, alors que les librairies non-web visaient quelque chose de plus grand en se combinant entre-elles.

Mais malheureusement, il me semble que notre société actuelle aime bien les modes de pensée uniques…

# Conclusion

Pour des petits sites rapides, pas de soucis, foncez sur les frameworks CSS !!!
Vous gagnerez du temps et serez capables de sortir un site agréable sans trop de problème.

Pour des sites plus costauds, ces librairies peuvent être un véritable piège.
La maintenabilité globale est assez faible, et la maîtrise du rendu quasi-inexistante.
On court à chaque instant à la catastrophe, en étant incapable de faire exactement ce qu'on souhaite.

Et en prime, un site qui aura vraiment un design qui lui est propre aura aussi un impact visuel plus fort et marquera d'avantage les esprits.
Niveau com', on fait difficile pire que de tomber dans la banalité…
