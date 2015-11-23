---
title: Manuel du parfait petit crypto-anarchiste (1/3)
---

Sauf à avoir hiberné ces six derniers mois ou à être un Michu complètement  standard (mais je suis heureux que vous soyez arrivé ici alors !), vous n'avez  pas pu ne pas entendre parler du programme [PRISM](https://fr.wikipedia.org/wiki/PRISM_(programme_de_surveillance)), mis en place par la NSA pour surveiller la vie numérique de tous les citoyens de ce  bas-monde et révélé par [Edward Snowden](https://fr.wikipedia.org/wiki/Edward_Snowden), aujourd'hui réfugié en Russie.

Ces révélations ont relancé l'intérêt pour la crypto-anarchie, ou en tout cas une prise de conscience collective (un peu trop tardive et toujours trop faible) du besoin de garantir *a minima* la confidentialité de ses communications.

Je vous propose donc un tour d'horizon des problèmes de sécurité potentiels qui existent sur Internet aujourd'hui, puis une présentation des différents outils utilisables dans la vie quotidienne pour s'en protéger.

# Les potentielles failles de sécurité lors de vos communications

Supposons un cas simple où vous souhaitez transmettre une information à une autre personne, par exemple un courriel.
La théorie voudrait qu'on soit dans l'environnement suivant :
<figure>
	<img src="/assets/images/20130901/com.png" alt="Communication" />
	<figcaption>
		(Crédits image : <a href="https://www.eff.org/pages/tor-and-https">Electronic Frontier Foundation</a>)
	</figcaption>
</figure>

Personne n'écoute vos communications, il n'y a pas de pirate dans les parages, etc. Théoriquement donc, je ne devrais avoir besoin d'aucun moyen particulier pour envoyer des données, confidentielles ou non, à mon correspondant.

En pratique, le gros câble rouge entre les deux correspondants est très complexe et est constitué de plusieurs morceaux :

  * un morceau entre votre PC et votre fournisseur d'accès à Internet
  * un morceau entre votre FAI et le FAI de votre correspondant
  * un morceau entre le FAI de votre correspondant et son PC

Le premier et le dernier segment sont assez simples, basiquement quelques centaines de mètres de câble de cuivre.<br/>
Le segment du milieu, par contre, c'est une autre paire de manches… Votre message va subir une partie de billard numérique, passant d'un prestataire à un autre à la recherche d'une route vers votre correspondant via ce qu'on appelle des [routeurs](https://fr.wikipedia.org/wiki/Routeur).<br/>
Comme vous êtes sûrement Français, votre FAI connaît probablement une route assez courte vers OVH (qui héberge mon blog et est aussi Français), il y a donc de grandes chances de n'avoir que deux prestataires dans la boucle, votre FAI et OVH.<br/>
Le cas est encore plus compliqué si vous êtes à l'étranger, où il est plus qu'improbable que votre FAI connaisse une route directe vers OVH, et vos données vont alors passer par plusieurs fournisseurs, en passant par des points d'échanges dit de *[peering](https://fr.wikipedia.org/wiki/Peering)* ou des [câbles sous-marins](http://www.telegeography.com/assets/website/images/maps/submarine-cable-map-2012/submarine-cable-map-2012-x.jpg).<br/>
Tout ça pour en arriver à dire qu'Internet, ce n'est qu'un jeu de ping-pong géant avec des données numériques, que vous n'avez absolument aucun moyen de savoir par où passeront vos données, et surtout que du coup vos données peuvent subir différentes attaques.

## Accès physique

La première attaque consiste simplement à attaquer directement les machines d'émissions ou de réception. Oui oui, la petite boîte que vous avez sous votre bureau et qui fait du bruit.
![Crack](/assets/images/20130901/crack.png){:.center}

Ça peut être fait à distance, via [un virus](https://fr.wikipedia.org/wiki/Virus_informatique), [un cheval de Troie](https://fr.wikipedia.org/wiki/Cheval_de_Troie_(informatique)) ou [du social engineering](https://fr.wikipedia.org/wiki/Social_engineering). Mais aussi directement à la source, par exemple suite à un cambriolage ou la saisie de votre matériel informatique par la justice, ou plus simplement si vous égarez votre PC portable…

## Attaque de l'homme du milieu

La seconde attaque est appelée *[attaque de l'homme du milieu](https://fr.wikipedia.org/wiki/Attaque_de_l'homme_du_milieu)* ou plus communément *man-in-the-middle* (MITM).
![MITM](/assets/images/20130901/mitm.png){:.center}

Elle consiste à s'insérer entre les deux correspondants sans qu'ils ne s'en rendent compte : tout ce que A dira à B, le pirate l'interceptera, fera ce qu'il a à faire avec les données et les enverra à B, idem sur le chemin du retour.

Si on prend le cas de l'envoi d'un courriel, le pirate peut s'y prendre de plusieurs manières.

### Usurpation DNS

Pour trouver quelle machine doit recevoir le courrier de truc-muche@example.org, les émetteurs de courriel vont chercher dans le [DNS](https://fr.wikipedia.org/wiki/DNS) (le grand annuaire de l'Internet en version vulgarisée) que dit le champ *[MX](https://fr.wikipedia.org/wiki/Enregistrement_Mail_eXchanger)* (*mail exchanger*). Dans mon cas par exemple :

	$ dig MX imirhil.fr +short
	1 mail.imirhil.fr.
	$ dig mail.imirhil.fr +short
	5.135.187.37

La machine à qui vous devez envoyer votre courriel si vous voulez m'écrire est donc *5.135.187.37*.

Quelqu'un qui aurait la capacité d'usurper le DNS serait donc en mesure de faire en sorte que vous lui envoyez tout le courrier qui m'est normalement destiné !

L'usurpation DNS est relativement difficile à réaliser, mais reste totalement possible, que ça soit par une attaque directe des serveurs DNS, [un empoisonnement des caches](https://fr.wikipedia.org/wiki/Empoisonnement_du_cache_DNS) ou plus simplement par décision judiciaire.

La Chine [a sûrement usage de ce genre de pratique](http://www.bortzmeyer.org/detournement-racine-pekin.html) pour censurer leur Internet national.<br/>
Certains FAI, y compris Français, [trafiquent aussi leurs serveurs DNS](http://www.numerama.com/magazine/13793-sfr-violerait-la-neutralite-du-net-avec-un-dns-menteur.html), pas forcément pour de mauvaises raisons mais en tout cas avec de bien mauvaises pratiques.


### Usurpation d'adresse IP

Un peu dans le même genre que l'usurpation DNS, l'usurpation d'adresse IP consiste à faire en sorte de prendre la place de la machine visée sur le réseau.<br/>
Si quelqu'un arrivait à vous faire croire que sa machine est *5.135.187.37*, tout courriel que vous m'enverriez passerait par lui.

Sur un réseau local, c'est possible par [empoisonnement du cache ARP](5.135.187.37). À plus grosse échelle, on peut s'attaquer au routeur pour leurs faire croire que la meilleure route pour aller vers telle adresse est une machine que vous controllez.<br/>
Ne rigolez pas, [le Pakistan a ainsi détourné Youtube](http://www.renesys.com/2008/02/pakistan-hijacks-youtube-1/) et [la Turquie carrément tout Internet](http://www.renesys.com/2005/12/internetwide-nearcatastrophela/).

### Divers

D'autres méthodes existent pour faire du MITM, par exemple avec des liens piégés et du social engineering et où vous ne ferez pas attention que l'adresse sur laquelle vous êtes réellement n'est pas celle où vous pensiez être.<br/>
C'est un peu une amélioration d'une [attaque par phishing](https://fr.wikipedia.org/wiki/Hameçonnage), mais où plutôt que d'avoir une fausse page sans rien derrière, la page affichée communique réellement avec le vrai site (votre banque par exemple) et filtre les données intéressantes au passage.

## Inspection de paquets

La technique qui devient à la mode en ce moment, c'est de juste regarder ce qui passe dans les tuyaux qui sont devant vous.
![DPI](/assets/images/20130901/dpi.png){:.center}

Internet étant Internet, les données qui passent dans un câble sont morcelées en plein de petits paquets. Pire, les paquets peuvent être dans le désordre voire ne même pas passer par les mêmes routes. Et toutes les données de tout le monde passent par plus ou moins les mêmes câbles.<br/>
Bref, si on se contente de regarder passer les données, on va surtout pouvoir se faire un bon générateur de nombres pseudo-aléatoires.<br/>
Il faut avoir du matériel intelligent et capable de comprendre ce qui passe dans le câble pour arriver à reconstituer les données échangées : c'est le rôle des équipements d'*[inspection des paquets en profondeur](https://fr.wikipedia.org/wiki/Deep_packet_inspection)* ou *Deep Packet Inspection* (DPI).

C'est le cas de ce qui se fait [en Iran](http://www.zdnet.fr/actualites/nokia-siemens-networks-accuse-de-contribuer-a-la-censure-en-iran-39700501.htm), [en Libye](http://surveillance.rsf.org/amesys/) ou encore [en Syrie](http://surveillance.rsf.org/blue-coat/) pour surveiller et censurer la population.

## Espionnage des hébergeurs

Le cas présenté initialement de communication entre deux personnes est en général plus complexe que ça car il fait intervenir un prestataire de service. C'est la centralisation <strike>d'Internet</strike> du Web (et c'est le mal…).<br/>
![SaaS](/assets/images/20130901/provider.png){:.center}

Quand vous envoyez un courriel à quelqu'un de « normal », je suppose que l'adresse du destinataire est plus en *jean.martin@gmail.com* ou *marie.bernard@orange.fr* que *moi@chez-moi.fr*.<br/>
Et donc que quelqu'un qui voudrait avoir accès à vos données, plutôt que de s'embêter avec toutes les techniques compliquées et coûteuses précédentes, il n'a qu'à toquer gentiment à la porte de Google en lui demandant toutes vos conversations.<br/>
Mieux, avec un peu de chance, il n'y a qu'à attendre [qu'ils vous]((http://www.ladepeche.fr/article/2013/06/24/1657105-facebook-panne-provoque-fuite-6-millions-donnees-personnelles.html)) [les donnent](http://reflets.info/sony-takedown-nouvelle-fuite-de-donnees-un-million-de-comptes-utilisateurs-dans-la-nature/) [tout seul](http://www.01net.com/editorial/514002/fuite-de-donnees-personnelles-sur-le-site-voyages-sncf-fr/).

Et le programme PRISM a montré que les plus gros prestataires existants (Google, Facebook, Microsoft, Youtube, Skype, AOL, Yahoo, Apple…) ont passé un marché avec la NSA et lui laissent mettre les mains dans les données de leurs utilisateurs.

# Crypto-anarchie à la rescousse !

Le chapitre précédent est assez explicite s'il y avait réellement besoin de l'être : sur Internet, vous n'êtes pas à l'abris et tous les liens entre vous et vos correspondants sont surveillés ou en tout cas ne peuvent pas être considérés comme fiable.
Si vous voulez donc protéger vos données, il va falloir prendre des mesures pour mettre de la sécurité et de la confiance au-dessus de quelque chose qui en est totalement dépourvu.<br/>
La crypto-anarchie va plus loin, en essayant de chiffrer au maximum ses communications, y compris les plus anodines.

## Pourquoi la crypto-anarchie, c'est bien

« Oui mais moi je n'ai rien à cacher ! » C'est généralement la réplique qui vient juste à ce moment…<br/>
Désolé, mais si, vous ne le savez peut-être pas encore, mais vous avez des choses à cacher ! Peut-être pas là, maintenant, tout de suite, mais dans les semaines, mois ou années qui suivent.<br/>
Peut-être même que vous avez déjà publié des choses qui vous semblent totalement banales et légales hier, mais qui peuvent devenir totalement illégales et répréhensibles demain. Au Mali par exemple, après l'arrivée des Talibans au pouvoir, vous pouviez être condamné à mort pour avoir suivi une marque d'alcool sur Twitter ou si vous aviez déclaré être athé sur votre profil Facebook…
Nous avons la chance de vivre aujourd'hui dans un pays (plus ou moins) démocratique, mais personne ne peut garantir qu'il en sera toujours ainsi demain.<br/>
Et si vous n'avez réellement rien à cacher, vous ne verrez donc aucun inconvénient à ce que je vous suive 7j/7, que je vous filme 24h/24 et que je diffuse tout ça à vous ne savez trop qui ? Comment ça « non » ? Auriez-vous quelque chose à cacher ?

La crypto-anarchie a aussi ça de bien qu'elle permet d'encore mieux protéger votre futur.
Si vous ne chiffrez jamais rien, et que d'un coup vous chiffrez juste un courriel, ça risque de faire un peu louche et la NSA pourra faire tourner ses centaines de milliers de machines pour casser votre gentil courriel chiffré et tenter de décoder les secrets qu'il contient très certainement.
Au contraire, si après avoir passé des semaines et dépensé des milliers d'euro à casser trois ou quatre de vos mails chiffrés, ils tombent sur des « Salut Maman, comment ça va ? » ou autre « N'oublie pas d'acheter une baguette en rentrant », à mon avis, ils vont vite lâcher le morceau.<br/>
Chiffrer tout dès maintenant, c'est camoufler le moment où vous aurez réellement besoin de sécurité.

Le big bonus, c'est que la crypto-anarchie permet aussi de mieux protéger tous ceux qui ont réellement besoin de sécurité, par exemple les résistants Syriens ou les lanceurs d'alerte ([Chelsea Manning](https://fr.wikipedia.org/wiki/Bradley_Manning), [Edouard Snowden](https://fr.wikipedia.org/wiki/Edward_Snowden)…).
Dans la même idée que le paragraphe précédent, quelqu'un qui écouterait un câble et ne voit passer que quelques communications chiffrées, il peut se focaliser dessus.
Si tout le monde chiffre même la moindre broutille, les données chiffrées importantes sont noyées dans un flot de données chiffrées sans le moindre intérêt.

Bref, la crypto-anarchie, ça devrait être enseigné au primaire et on devrait tous en user et en abuser.

## Se protéger, mais de quoi ?

Si on regarde les attaques exposées un peu avant, on distingue trois choses à tenter de protéger à tout prix :

  * La *sécurité* des données proprement dite. Vous ne voulez pas que vos données tombent entre de mauvaises mains.
  * La *confiance* en le réseau. Vous voulez avoir la certitude de causer avec la bonne personne.
  * La *confidentialité* en les échanges. Vous ne voulez pas que n'importe qui puisse savoir avec qui vous avez communiqué.

Une chose très importante à bien avoir en tête, c'est que personne ne pourra jamais vous garantir aucun de ces points de manière absolument certaine.
Si vous transferez des documents classifiés mettant en jeu la sûreté nationale, aucun système de sécurité ne vous mettra à l'abris des [moyens de l'État soumis au secret de la Défense Nationale](http://www.legifrance.gouv.fr/affichCodeArticle.do;jsessionid=9667020452754D4847B7667DB722BA54.tpdjo12v_1?idArticle=LEGIARTI000006576029&cidTexte=LEGITEXT000006071154&dateTexte=20110202). S'ils veulent accéder à vos données, ils s'en donneront les moyens. Certains pays y mettent même [tout leur cœur](https://fr.wikipedia.org/wiki/Camp_de_Guantánamo).

La confidentialité est sûrement la chose la plus difficile à garantir, mais pourtant peut être quelque chose d'extrèmement important à garantir.<br/>
Sans cette confidentialité, on peut tracer votre réseau proche, savoir à qui vous parlez, quand et parfois même le sujet de votre conversation.
On n'a pas accès au contenu même de la communication, mais ça peut donner suffisamment d'informations pour mettre en place un ciblage précis des moyens technologiques nécessaires à tout déchiffrer.
C'est plus intéressant de cibler toutes les communications chiffrées entre deux résistants Syriens plus ou moins connus que tout le trafic chiffré de toute la Syrie.<br/>
Comme dit l'adage, pour vivre heureux, vivons <strike>caché</strike> chiffré.

La suite au prochain épisode, avec les différents moyens à notre disposition pour devenir un parfait petit crypto-anarchiste !

*[Seconde partie]({% post_url 2013-09-02-manuel-du-parfait-petit-crypto-anarchiste-2 %})* —
*[Troisième partie]({% post_url 2013-09-06-manuel-du-parfait-petit-crypto-anarchiste-3 %})*
