---
title: ! '« Que faut-il pour XXX ? » « Du logiciel libre ! » Non, une gouvernance éthique !'
---

Ce billet risque d’en surprendre plus d’un. Et pourtant.

Je commence à être légèrement saoulé d’entendre certains brandir le logiciel libre comme la solution à la plupart des maux de la terre, de la libération de l’Éducation Nationale à la priorité dans l’administration en passant par la protection de la vie privée, le retour de l’être aimé et la guérison du cancer. Et en particulier [durant les cafés-vie-privée](https://twitter.com/aeris22/status/831109717388836867).

Je suis pourtant un fervent défenseur du logiciel libre, mais je pense qu’il va aussi être temps de se mettre au goût du jour. Nous ne sommes plus en 1980 avec les problèmes d’imprimante de rms, les problématiques ont beaucoup évolué alors que le discours autour du Libre non.

# Le Logiciel Libre a gagné.

Oui, le Logiciel Libre a gagné. Je pense que personne ne dira le contraire.

Certes, sa victoire ne se mesure pas à son taux de pénétration sur le marché de l’OS pour ordinateur personnel où GNU/Linux, \*BSD et compagnie peinent à décoller du 1% de parts de marché.
Mais aujourd’hui, on entend parler du Logiciel Libre partout. Certes souvent sous sa forme « open-source » utilisé pour mieux vendre son produit et sans réelle volonté éthique derrière, mais quand même.

 * Microsoft fait du libre à tour de bras. [Grosses contributions](https://www.nextinpact.com/archive/69991-microsoft-contributeur-noyau-kernel-linux.htm) au noyau Linux, ouverture de [Visual Studio Code](http://www.zdnet.fr/actualites/microsoft-libere-le-code-source-de-visual-studio-code-39828348.htm), de [.Net](https://www.nextinpact.com/news/90895-microsoft-ouvre-net-a-open-source-et-propose-visual-studio-2013-gratuit.htm), [utilisation de GNU/Linux](http://www.zdnet.fr/actualites/azure-cloud-switch-la-distribution-linux-de-microsoft-39825136.htm) pour sa plate-forme Azure… Ils ont depuis quelques années changé leur fusil d’épaule et arrêté le tout privateur.
 * Google est bâti sur une montagne de logiciels libres et reverse beaucoup de ses programmes internes à la communauté. Son projet phare, Android, est libre depuis les débuts du projet et présent sur la très vaste majorité de nos téléphones.
 * Facebook a lancé les plus gros frameworks de développement web du moment (React, Flux, Flow, HHVM…), en libre.
 * L’usage de VLC, Firefox, LibreOffice ou autres Notepad++ et Filezilla est loin d’être anecdotique et je pense que la plupart des ordinateurs personnels d’aujourd’hui contiennent du logiciel libre utilisés par leur propriétaire.

Bref, le Libre, il y en a partout, et ça devient dorénavant difficile de faire sans.

Il reste effectivement quelques points durs qui limitent la diffusion du Libre, comme la grosse problématique de la vente forcée ou l’impossibilité d’avoir accès à des pilotes libres pour le matériel courant.

# Mais on a oublié de regarder autour de nous.

Alors qu’on se battait becs et ongles sur le plan juridique pour justement faire tomber ces points handicapants, ou à diffuser nos outils et idées de 1980, le monde lui, a continué à se transformer.

On n’est jamais sortis du problème de la vente forcée sur PC et on se retrouve encore aujourd’hui à épuiser toutes nos forces sur ce sujet quand tout le monde ne jure plus que par les tablettes ou les téléphones intelligents, qui représentent aujourd’hui plus de 50% des ventes, en progression constante depuis une décennie.
Et donc même si on arrivait à obtenir la mise à mort de la vente forcée d’ici 5 ou 10 ans, les seules personnes réellement touchées seraient les 2 ou 3 geeks dans un garage qui continuent à acheter des PC (et qui en plus ont à disposition [de plus en plus](http://pcw.fr/) [d’alternatives](http://www.zdnet.fr/actualites/dell-mise-un-peu-plus-sur-les-pc-sous-ubuntu-39833994.htm), même [en grande distribution](http://www.ldlc.com/informatique/ordinateur-portable/pc-portable/c4265/+fv403-2134.html)).
Et qu’il faudra aller se battre encore plus durement pour obtenir la même chose pour nos smartphones ou tablettes, problème qui sera ô combien plus difficile puisque ne concernant plus uniquement du logiciel mais aussi du matériel.

On en est encore à s’arracher la tête en permanence pour obtenir une priorité au logiciel libre pour notre administration, nos écoles ou notre armée. Alors que le « cloud » est en train de tout grignoter au grand galop.
Et que le jour où la priorité sera actée, on ouvrira les yeux pour découvrir que tout ce petit monde tourne sur des versions « cloudisées » de LibreOffice ou Microsoft Office, et que l’un ou l’autre pose les mêmes problèmes d’enfermement dans ce mode de fonctionnement. Voire que Microsoft aura lancé une offre à base de [LibreOffice Online](https://wiki.documentfoundation.org/Development/LibreOffice_Online) d’ici-là pour contrer une éventuelle loi sur le sujet et ainsi pouvoir continuer à ~~voler~~ remporter tous les marchés publics et à siphonner les données personnelles de ses utilisateurs tout en faisant de l’évasion fiscale massive.

On continue à se faire mal avec nos outils « desktop » du siècle passé alors que 90% de la population utilise totalement autre chose, entre les applications mobiles, les applications web, le « cloud », ou a besoin de mobilité, de la gestion des machines multiples, de synchronisation…
Même moi qui cherche à fuir cette « hype » du moment, je suis bien content de trouver un LastPass intégré à mon navigateur, multi-machines et multi-profils plutôt qu’un veillissant KeepassX resté bloqué au monde de la mono-machine de bureau et non-web…

# Et du coup on a tout perdu.

On se retrouve aujourd’hui avec du libre partout mais pourtant de la liberté nulle part.

Nos données sont dans des silos de données type Facebook ou Google. Stockées physiquement dans des outils libres ([Cassandra](https://cassandra.apache.org/) initié par Facebook) ou basés exclusivement sur du libre ([GoogleFS](https://fr.wikipedia.org/wiki/Google_File_System)), mais gérés par des entités totalement opaques.

Android, pourtant un [projet 100% libre](https://source.android.com/) est devenu le premier violeur de notre liberté individuelle et de notre vie privée, via à la fois les composants non libres des versions commerciales (Google Services) mais aussi [la saleté](https://twitter.com/fuolpit/status/799947440010960897) des applications (y compris libres) installées par la plupart des utilisateurs.

Amazon, proposant en très grande majorité du GNU/Linux à ses clients et possédant une infrastructure interne quasiment exclusivement libre, représente actuellement plus de 31% de parts de marché du secteur, nécessitant même que l’IETF revoie un des protocoles les plus anciens d’Internet ([RFC7626](https://tools.ietf.org/html/rfc7626) & [RFC7816](https://tools.ietf.org/html/rfc7816)) afin de protéger la vie privée des internautes.

Les gens écoutent de la musique sur SoundCloud, regardent des vidéos sur NetFlix, stockent leurs données sur DropBox ou leurs vidéos sur Youtube. Et devinez quoi ? Ces outils pourraient être libres que l’utilisateur n’y gagnerait pas grand-chose. Ils n’ont ni les compétences ni les moyens financiers ou matériels de remonter l’équivalent chez eux.  
Des objets connectés, basés exclusivement sous GNU/Linux, sont déployés par milliards sur le réseau. Et devinez quoi ? [Ça ne protège en rien ses utilisateurs](http://www.lemonde.fr/pixels/article/2017/02/20/en-allemagne-une-poupee-connectee-qualifiee-de-dispositif-d-espionnage-dissimule_5082452_4408996.html).

# Le Logiciel Libre n’apporte finalement plus grand chose.

On brandit en permanence le logiciel libre à bout de bras comme étant THE solution, le Graal, la balle en argent ou le marteau doré. Alors que cette propriété n’apporte en réalité plus aucune protection.

Dans les nouveaux usages ~~d’Internet~~ du web, peu d’utilisateurs seront capables de se lancer dans l’auto-hébergement. Parce que c’est compliqué (ça sera l’objet du billet suivant d’ailleurs) si on ne veut juste pas préparer le futur [Mirai](https://fr.wikipedia.org/wiki/Mirai_(logiciel_malveillant)).
Parce que les usages modernes demandent de « l’intelligence artificielle » qu’on ne pourra pas remonter à la maison (stockage, puissance de calcul…) ou qui sera quasiment sans intérêt si la « big data » n’est faite que sur un seul utilisateur.

La fameuse poupée espionne, même en 100% libre risque fort de nécessiter un serveur central pour fonctionner correctement. Et même si un utilisateur propose un patch pour sécuriser la ligne, il ne sera pas intégrable avant que la société qui la commercialise ne se décide à sécuriser sa propre infrastructure et à modifier aussi son API et son back-office.

Ou tout simplement parce que les systèmes deviennent tellement complexes que les seules personnes à même d’en monter un correctement sont administrateurs systèmes.

Et c’est là bien tout le problème… L’intelligence s’est massivement déplacée de la périphérie vers le centre du réseau. On le déplore tous et ça a des conséquences dramatiques à l’heure actuelle (neutralité du net, silo de données, vie privée…).
C’est certes un état de fait et même si on peut regarder à long terme et se battre pour faire changer la chose, il est aussi important de prendre des actions à plus court terme pour protéger les utilisateurs actuels.

Et malheureusement, le logiciel libre n’a plus d’effet à ce niveau.

Mozilla, pourtant logiciel 100% libre ([ou presque](https://fr.wikipedia.org/wiki/Renommage_des_applications_de_Mozilla_par_Debian)), repose sur des logiciels côté serveurs, par exemple pour la gestion des extensions disponibles, qui eux ne sont pas nécessairement libres. Et même s’ils l’étaient, ils échappent totalement à l’emprise de l’utilisateur final.
Et ça peut du coup donner ceci :
<figure>
	<img src="/assets/images/20170221/mozilla.png" alt="Mozilla" />
	<figcaption>
		Google Analytics sur Firefox
	</figcaption>
</figure>
J’ai beau être développeur, savoir modifier et recompiler Firefox, je ne peux **pas** empêcher Mozilla d’embarquer Google Analytics sur ses serveurs… J’ai pu trouver une parade via [µMatrix](https://addons.mozilla.org/fr/firefox/addon/umatrix/) (du coup attention, trackers violeurs de vie privée !), certainement pas parce que Firefox était libre.

À l’inverse, [Qwant](https://www.qwant.com/?l=fr), logiciel pourtant privateur (bien que libérant [beaucoup de morceaux](https://github.com/Qwant/)), respecte ma vie privée.
Idem pour [ProtonMail](https://protonmail.com/), qui n’est pas non plus libre (mais publie aussi [beaucoup](https://github.com/ProtonMail)).

# Le Logiciel Libre est mort. Vive la Gouvernance Éthique.

Le détail qui fait la différence ? La gouvernance et la confiance. Certainement pas la licence libre du logiciel.

J’ai confiance en Qwant parce que [des gens bien](https://twitter.com/gchampeau) y travaillent.
J’ai confiance en ProtonMail parce que les morceaux qu’ils publient me semblent corrects, même si je n’ai absolument aucune preuve que c’est exactement ceux qui tournent sur leur production.
J’ai confiance en [Mailden](https://www.mailden.net/) parce que quand tu leur tapes dessus à leur lancement, [ils viennent t’expliquer leur infra autour d’une fondue](https://twitter.com/aeris22/status/504529352969969664).

En fait avec les infrastructures modernes, les libertés d’étudier et de modifier ne sont plus réellement possibles. Parce que personne de sensé ne vous donnera les clefs de sa baie et son mot de passe root pour que vous puissiez aller voir ce qui tourne réellement dans son système. Et vous autorisera encore moins à y faire des modifications.

La gouvernance des projets devient alors la clef.

La naissance du projet [CHATONS](https://chatons.org/), même s’il impose pour le coup du logiciel libre dans sa charte, en est une belle illustration.
La transparence de qu’est-ce qu’on fait réellement, comment ça tourne, qui a accès, où sont les données, comment [on se fait mal](https://twitter.com/wallabagit/status/832628267819507712) pour se débarrasser des GAFAM partout.

La gouvernance devient le véritable enjeu du XXI<sup>e</sup> siècle.

L’usage imposé de logiciels libres dans la charte des CHATONS y est finalement plutôt anecdotique puisque d’une part le libre s’est plus qu’imposé dans le monde du serveur et donc va de soi et d’autre part des entités qui auraient utilisé du logiciel privateur n’auraient pas été plus problématiques que ça, le logiciel libre simplifiant « uniquement » la portabilité ou l’interopérabilité, un logiciel privateur pourrait les permettre aussi.

Hormis dans le contexte des OS pour PC ou des applications lourdes, qui est un contexte du passé, le Logiciel Libre n’est plus ni une condition nécessaire (Qwant) ni une condition suffisante (Mozilla) pour respecter les libertés de l’utilisateur.
Dans le monde moderne de la mobilité et des applications légères, c’est la Gouvernance Éthique qui devient ce facteur nécessaire et suffisant.

# La bataille pour la Gouvernance Éthique sera bien plus difficile à remporter.

Le problème de la Gouvernance Éthique est que contrairement au Logiciel Libre, elle n’est pas un avantage pour ceux qui souhaiteraient s’y mettre. Au contraire.

Le Logiciel Libre peut être gratuit, fait faire des économies d’échelle via l’absence de coûts d’entrée ou récurrents (achats de licence), permettant à de petites structures de se lancer sur le marché à égalité avec les grosses.  
La Gouvernance Éthique, elle, sera un caillou permanent dans votre chaussure par rapport à la concurrence ayant moins de scrupules que vous.

Déjà, en termes d’infrastructure.  
Vous ne pouvez plus avoir en 3 clics un système de statistique comme Google Analytics, il va vous falloir gérer un [Piwik](https://piwik.org/).
Vous ne pourrez plus gérer vos retours d’erreur via New Relic, il va aussi falloir investir dans du [Sentry](https://sentry.io/welcome/).
Finies les joies de claquer des doigts pour héberger tout ça via EC2, il va falloir gérer votre propre ferme [OpenStack](https://www.openstack.org/) sur des machines physiques vous appartenant.
C’était bien pratique le stockage S3, pas de bol, il va vous falloir monter un cluster [Ceph](https://ceph.com/).
Vous pouvez aussi dire adieu aux Google Fonts, à l’usage des [CDN](https://fr.wikipedia.org/wiki/Content_delivery_network), vos sauvegardes vont devenir un enfer, votre « big data » ou votre « intelligence artificielle » aussi.

Pour les fonctionnalités, vous allez aussi bien patauger.  
La portabilité des données ou l’intéropérabilité par exemple. L’usage du Logiciel Libre vous garantit une certaine intéropérabilité pour un format donné, mais hormis les usages bureautiques personnels du passé, ils ne garantissent aucunement la portabilité. Une instance [GNU/Social](https://gnu.io/social/) complète se transporte « facilement » d’une machine à une autre, mais en sortir un utilisateur particulier pour faire une migration vers une autre instance ne va pas être une sinécure… Cozy a [le même souci](https://forum.cozy.io/t/fr-a-propos-de-la-road-map-vers-cozy-version-3/3808/10?u=aeris). Chaque composant libre est techniquement intéropérable, mais l’ensemble (même libre) ne l’est pas nativement et on doit investir dans des développements coûteux pour le mettre en place.

Enfin votre modèle commercial s’oppose à la tendance moderne du tout gratuit.  
Les points précédents font que vous aurez en plus du mal à trouver un tarif viable, celui-ci allant être tiré vers le haut par les challenges à remporter mais vers le bas pour être compétitif face à la concurrence. Sans parler qu’une personne lambda n’aura pas les moyens d’investir dans 20 services différents à 3€/mois et donc que la compétition va être rude, y compris entre des projets ne proposant pas du tout les mêmes services…

Tout ça cumulé fait qu’un projet à Gouvernance Éthique sera très certainement plus coûteux et donc moins attractif, en tout cas sur le court/moyen terme, qu’un équivalent sans éthique.
Les concurrents peu scrupuleux n’auront pas à utiliser des pratiques illégales comme ils le font actuellement avec le Logiciel Libre (lobbying, marché public truqué, partenariat caché…) pour s’imposer, il leur suffira de présenter légalement une réponse à un appel d’offre donné, réponse qui sera par nature moins chère, avec plus de fonctionnalités et moins de délais…
Et donc la Gouvernance Éthique est vouée à l’échec si on ne l’aide pas.

Les solutions comme les CHATONS permettront sûrement de lancer la machine, de montrer qu’une autre voie est possible, mais il faudra des décisions juridiques fortes, comme la [GDPR](https://www.nextinpact.com/news/102927-vie-privee-cnil-europeennes-preparent-gdpr-quand-eprivacy-continue-son-chemin.htm) pour rétablir l’équilibre et espérer une adoption réellement massive des solutions éthiques via des offres commerciales (ou non) pérennes qui toucheront bien au-delà du milieu geek et libristes.

Bref, il est plus qu’urgent de faire le bilan du monde actuel pour recentrer nos combats, plutôt que de persister contre la muraille construite il y a 30 ans et qui a fini par nous obséder complètement depuis au moins 10 ans.
Pendant que de l’autre côté l’ennemi a conquis tout le reste du monde et ne fera qu’une bouchée de nous le jour où on parviendra enfin à traverser l’enceinte.
Parce ce qu’on aura toujours nos bons vieux boucliers quand lui aura fabriqué des armes nucléaires :)

Le Logiciel Libre restera une brique importante d’un écosystème sain, mais ne doit pas occulter tous les problèmes qu’il ne résout pas ou plus. Et ne doit certainement pas être brandi de manière quasi dogmatique, d’autant plus quand il n’est justement pas une réponse adaptée à la question posée.

(Merci à [@btreguier](https://twitter.com/btreguier) et [@goofy_fr](https://twitter.com/Goofy_fr) pour la relecture :))
