---
title: Ansible, Chef, Puppet… Pourquoi ça ne juste marche pas :(
---

Depuis plusieurs années, les technologies de virtualisation (KVM, LXC, Virtualbox, Xen, VMWare…) se sont bien développées et sont maintenant présentes partout.
Avec elles, on s'est très vite retrouvé avec moultes et moultes machines virtuelles dans nos infrastructures, complexifiant le déploiement et la configuration de tout ce beau bordel…

Plus récemment, dans un soucis de simplifier et de rationaliser la gestion d'un parc informatique, sont apparus des outils comme [Chef](https://www.getchef.com/), [Puppet](http://puppetlabs.com/) ou [Ansible](http://www.ansible.com/) afin de considérer notre parc et nos machines comme un simple programme informatique standard, avec l'équivalent de classes, méthodes et autres variables.

Pour avoir utiliser les trois (Puppet, puis Chef, puis Ansible), j'ai été très vite déçu par ces outils, qui ne répondent à mon avis pas à <s>la</s> ma problématique initiale.
Petit retour d'expérience sur ce domaine.

# Ce dont on a besoin

Imaginons avoir une infrastructure de notre parc informatique basée sur la virtualisation, ie. chaque service isolé dans son propre conteneur.
A minima, on va vite se retrouver avec les conteneurs suivants : un Bind9, un Postfix, un Nginx, un Apache, un MySQL, un PostgreSQL…

## Gestion des rôles

Tout comme dans un vrai code informatique, on voudrait profiter de mécanisme d'héritage, de polymorphisme et d'agrégation pour définir notre infrastructure, afin d'éviter la duplication et de conserver une base robuste à un changement future d'infrastructure.

On doit pouvoir définir une description globale de tous les Apache (installation et configuration de Apache, ouverture des ports 80 et 443 du pare-feu, installation de RPaf…) et faire apparaître la notion de **rôle**.

On veut quand même vouloir en redéfinir certains morceaux machine par machine (liste des virtualhosts servis, déploiement des certificats SSL…), un peu à la manière d'un **héritage**

On doit pouvoir agréger les rôles, et signaler qu'un serveur Apache est aussi un serveur de courriel, par **composition**.

## Gestion des relations

Tous les services d'une infrastructure sont inter-dépendants : le Nginx sert de reverse-proxy au serveur Apache, qui sert un site web qui utilise une base de données PostgreSQL, le Nginx a donc besoin de l'adresse IP du serveur Apache et des virtualhosts servis, le Apache a besoin de l'IP du serveur MySQL.
Pire, les dépendances forment des boucles : le serveur Apache a besoin de l'IP du serveur Nginx devant lui pour configurer son module [RPaf](http://www.stderr.net/apache/rpaf/) (qui permet d'avoir l'IP réelle du client dans les logs et non celle du reverse-proxy), le MySQL a besoin de l'IP du serveur Apache pour ouvrir son pare-feu…

On a donc besoin de pouvoir définir son infrastructure d'une manière **déclarative** (le quoi) et non impérative (le comment), en évitant la redondance de l'information (l'IP d'une machine définie une et une seule fois), la duplication de code, le risque d'incohérence dans la configuration en cas de modification de l'infrastructure…
Dans l'exemple précédent, on veut ne définir les IP que dans la description de l'hôte en question, et ne définir qu'à un seul endroit la relation entre un Apache et son proxy Nginx.

Pour les relations, on aimerait même se minimiser le travail au cas où notre infrastructure soit amenée à évoluer demain, et donc pouvoir les définir de manière complexe, comme par exemple « *un Nginx proxite tous les virtualhost des Apaches situés sur la même machine physique* », et non se contenter de déclarer le proxy Nginx utilisé dans le descriptif du Apache, ou à l'inverse la liste de tous les Apache proxifiés dans le descriptif du Nginx (mais surtout pas les deux sous peine d'incohérence !)

## Gestion des tâches

On doit faire le déploiement et la configuration en elle-même. Installation de paquets, édition de fichiers de configuration, création d'un utilisateur, redémarrage d'un service…
L'outil doit fournir des **primitives basiques** et si possible avec une couche d'abstraction suffisante pour être indépendant de l'OS utilisé (on installe un paquet avec `apt` sous Debian mais avec `yum` sous Red-Hat).

Et comme dans un langage informatique, il doit être possible de **combiner** ces primitives pour obtenir des résultats plus complexes.
Par exemple, créer un administrateur, c'est créer un utilisateur, déployer sa clef SSH sur son compte et la déployer aussi sur le compte root.

# Outils existants

Pour répondre à tout ça, plusieurs outils sont disponibles pour les administrateurs système, dont les plus connus et utilisés sont sans conteste Puppet et Chef, et un petit dernier qui commence à creuser son trou (ou sa tombe, cf fin de ce billet), Ansible.

Pour des besoins persos et semi-pros, j'ai eu besoin de gérer un certain paquet de machines, et la configuration à la mimine est vite devenue un enfer.
Déployer une nouvelle clef SSH sur 15 machines virtuelles réparties sur 2 machines physiques, ça devenait de la haute lutte et quelques bonnes prises de tête pour y arriver, avec en plus toujours au moins 1 ou 2 machines qui étaient oubliées dans la boucle… 
Bref, un outil pour gérer tout ça s'est très vite imposé !

# Puppet : ça ne marche pas

Pour faire « comme tout le monde », j'ai commencé mon long périple <s>au travers du Mordor</s> par Puppet, à l'époque (2012) très utilisé un peu partout. 
Premier tour sur le site : « cool, c'est du Ruby ! » (mon petit langage de prédilection du moment). Première déception, c'est codé en Ruby mais la configuration s'effectue dans un [DSL](https://fr.wikipedia.org/wiki/Langage_dédié)…

{% highlight ruby %}
class ntp {
	# On installe le package si besoin
	package { ntp:
		ensure > installed,
		provider > aptitude
	}
	# Le fichier de configuration
	file { "/etc/ntp.conf":
		source  > "puppet://puppet/files/etc/ntp.conf",
		# On declenche ce controle "file" apres l'install du package
		require > Package[ntp]
	}
	# On declare aussi le service ntp qui sera démarré et contrôlé
	service { ntp:
		ensure    > running,
		provider  > debian,
		# Si le package ou le fichier de conf sont modifiés, on redémarre le service.
		subscribe > [Package[ntp], File["/etc/ntp.conf"]]
	}
}
{% endhighlight %}

Bref, c'est du ruby sans vraiment y être, avec des trucs parfois un peu mystiques dedans (les *>*, voire même des fois des *<<||>>*). Bon, passons…
(Au passage, merci [Vincib](https://twitter.com/vincib) pour l'[exemple de config](https://www.octopuce.fr/puppet-administration-systeme-centralisee/) :D)

Pour un service donné, l'outil fait clairement bien son job. On peut installer des paquets, déployer des fichiers tout fait ou via un template instancié à la volée avec les valeurs nécessaires.
Le DSL est plutôt assez concis et donne des descriptifs faciles à lire une fois passé l'apprentissage des incantations magiques.

Là où ça commence à pécher, c'est pour la gestion des relations…
Puppet est basé sur un mécanisme client/serveur, ou plus exactement master/slave.
Une machine, le puppet master, contient l'intégralité des descriptifs, rôles, fichiers et autres templates.
Sur chaque machine gérée par l'outil tourne en permanence un démon puppet, le puppet agent, qui vient régulièrement vérifier s'il a des choses à faire, une fois par jour par exemple.
Du coup, chaque machine est isolée et ne peut travailler qu'avec ce qui lui est directement destiné.
Une machine n'a pas la possibilité d'aller voir ce qu'une autre machine a déployé, par exemple un Nginx ne peut pas lister les Apaches sous sa responsabilité, c'est à l'administrateur de lui indiquer explicitement la liste quelque part, ce quelque part devant obligatoirement être dans le périmètre du Nginx et pas uniquement dans celui des Apaches.
Bref, c'est à l'administrateur de gérer manuellement les dépendances, sans aucune assistance de la part de l'outil pour lui dire qu'il a oublié de renseigner le nouvel Apache fraîchement arrivé dans la configuration du Nginx !

Pour palier à ce problème, il existe quand même un mécanisme de partage d'information, les [ressources exportées](https://docs.puppetlabs.com/puppet/latest/reference/lang_exported.html).
On veut par exemple que chaque installation d'un serveur Apache génère automatiquement une vérification [Nagios](http://www.nagios.org/) sur le port 80.
On va donc déclarer une ressource exportée, qui pourra être lue lors du déploiement du Nagios pour installer tout ça correctement.

{% highlight ruby %}
puppet/modules/nagios/manifests/target/apache.pp
class nagios::target::apache {
	@@nagios_host { $fqdn:
		ensure  => present,
		alias   => $hostname,
		address => $ipaddress,
		use     => "generic-host",
	}
	@@nagios_service { "check_host_${hostname}":
		check_command       => "check_port!80",
		use                 => "generic-service",
		host_name           => "$fqdn",
		notification_period => "24x7",
		service_description => "${hostname}_check_http"
	}
}
{% endhighlight %}

Et là, j'ai fais une crise cardiaque.
Et une grosse.
Voire même plusieurs…
grosses…

Déjà, on vient de devoir créer une nouvelle classe de serveurs, *nagios::target::apache*.
Pourtant, un serveur HTTP est juste un serveur HTTP.
Pas un serveur HTTP + vérification du port 80.
On a introduit de la redondance d'information…
Qui dit redondance dit erreur possible.
Je définis un nouveau serveur Apache dans mon infra mais je suis un jeune admin tout fraîchement démoulu de l'école ?
Je n'ai pas les 10 ans d'historique et d'expérience de mes collègues ?
Ben on m'a demandé d'installer un nouveau serveur Apache, donc j'ai juste mis la classe *apache* à ma nouvelle machine… et elle n'est donc pas monitorée par Nagios !
Le simple fait d'avoir un port 80 en écoute devrait **automatiquement** entraîner le monitoring !
Parce que si l'admin sys en chef passe sous un poney demain et qu'il y a toutes les chances du monde qu'il soit le seul à avoir conscience qu'il y a un Nagios <s>mort</s> dans un coin, plus personne ne pensera à le faire !

J'entend déjà les esprits taquins : « oui-mais-y-a-qu-à-faire-de-la-doc ».
Si on a voulu utilisé un outil du type de Puppet, c'est bien parce que la doc d'un SI (comme plus ou moins toute doc sur Terre) est par définition même d'une documentation… jamais à jour !
Et encore, ça c'est dans le meilleur des univers parallèles, dans tous les autres la doc a juste été perdue depuis des lustres…
Même un commentaire — par sa nature même de documentation — est *de facto* erroné/incomplet/obsolète/manquant.
La doc étant même le seul phénomène quantique connu observable sans destruction de l'intrication : elle est généralement les 4 à la fois et l'observation même de longue durée — y compris par un N+1 — ne change rien à son état superposé.
La seule et unique chose qui puisse faire foi et qui est la Vérité Absolue, c'est le code, et rien que le code.

La redondance appelant généralement à toujours plus de redondance, que se passe-t-il si on souhaite maintenant monitorer le port 80 et le port 443 ?
Pas de soucis, il n'y a qu'à rajouter une vérification du port 443 dans la classe *nagios::target::apache*.
Oh mais attendez, si mon serveur Apache n'a que du HTTP ou que du HTTPS ?
Ah mais les tests Nagios vont se mettre à échouer sur le port non présent…
Pas grave, il n'y a qu'à faire 2 classes, *nagios::target::http* et *nagios::target::https* et le tour est joué !
Ah mais oui, j'ai aussi un [Munin](http://munin-monitoring.org/) tient.
Ok, ben disons « munin::target::http » et « munin::target::https ».
On voit bien le risque de fonctionner ainsi : à chaque modification de l'infrastructure, comme les dépendances ont été codées « à la main » dans l'outil, rien ne s'adapte tout seul, et toute modification devient intrusive…
Un simple serveur Apache qui devrait n'avoir qu'une seule classe *apache* va se retrouver avec une foultitude de classes présentes uniquement dans un but technique et non métier.

En plus, on ne parle ici que d'une dépendance simple qui devrait en réalité s'exprimer ainsi : « j'active une vérification Nagios sur le port 80 si la machine possède la classe *apache* ou *nginx* et au moins un virtual-host sur le port 80 ».
Imaginez maintenant devoir régler de cette manière une dépendance plus complexe de type « déploie des virtual-host nginx en reverse proxy pour chaque virtual-host de chaque Apache présent sur la même machine physique que toi, en utilisant comme IP de proxy l'IP du Apache ».
Je vous tend déjà le tabouret et la corde…

Le système a une dernière limite : il ne gère que ce que le concepteur d'une classe a bien voulu gérer (sic).
Si vous utilisez des classes tierces comme c'est généralement le cas, et qu'aucune ressource exportée n'a été déclarée alors que vous en aviez besoin, vous êtes bon pour refaire une n-ième classe juste pour la ressource…
Les classes « Apache oriented » deviennent « Nagios oriented » à l'introduction d'un Nagios et « Munin oriented » à celle d'un Munin.
Les classes elles-mêmes introduisent des dépendances dans le système.

Comme on dit, « mauvais outil, changer outil »…

# Chef : ça ne marche pas non plus

J'ai donc été voir à la concurrence et auprès de Chef en l'occurence.
Chef est aussi en Ruby et fonctionne aussi en mode master/slave, donc rien de nouveau sous le soleil à ce niveau.

Là où tout change c'est que Chef fournit de base une base de données [Solr](https://lucene.apache.org/solr/) qui va stocker l'intégralité de la description d'une machine.
Cette base est bien entendue requétable depuis les descriptions, ce qui permet de faire des choses assez sympathiques pour régler les problèmes précédents.
Par exemple, on a une tache qui a créé les comptes des administrateurs de la machine :

{% highlight json %}
# data_bags/users/root.json
{
	"id": "root", "uid": 1, "gid": 1,
	"password": "$6$Ew3a5…eV/"
}

# data_bags/users/aeris.json
{
	"id": "aeris", "uid": 1000, "gid": 1000,
	"password": "$6$mHFbw…98/"
}
{% endhighlight %}
{% highlight ruby %}
# cookbooks/users/recipes/default.rb
data_bag(:users).each do | id |
	user = data_bag_item(:users, id)
	user id do
		uid user['uid']
		gid user['gid']
		password user['password']
	end
end
{% endhighlight %}

Déjà on remarque qu'on est en pur Ruby, avec un DSL beaucoup plus léger et qu'on navigue donc en terrain connu.
On retrouve aussi toute la puissance des boucles et autres fonctions Ruby, on peut réellement coder quelque chose et ne plus subir le DSL.
Par rapport à Puppet, on a aussi la notion de databags, qui permettent de séparer proprement la partie données de la partie traitement.
Une telle séparation est très difficile à atteindre avec Puppet.

Donc là, on a une recette (cookbook) *users* qui crée nos petits administrateurs. Tout fonctionne, tout est testé, tout est valide.
Niquel, je peux partir en week-end.
Et là, y'a une demande du client qui se pointe à l'arrache : faut déployer du SSH, et en particulier, les clefs des administrateurs…
En Puppet, j'aurais du revoir ma recette *users* pour ajouter des ressources  exportées, et en prime commencer à mixer des données « compte UNIX » et « clefs SSH » dans cette recette, comme on l'a vu précédemment.
En Chef, le problème se règle en quelques lignes et sans tricks :

{% highlight json %}
# data_bags/users/root.json
{
	"id": "root", "uid": 1, "gid": 1,
	"password": "$6$Ew3a5…eV/",
	"ssh_keys": [ "ssh-rsa AAAA…4nv5 aeris@imirhil.fr" ],
	"ssh" : true
}

# data_bags/users/aeris.json
{
	"id": "aeris", "uid": 1000, "gid": 1000,
	"password": "$6$mHFbw…98/",
	"ssh_keys": [ "ssh-rsa AAAA…4nv5 aeris@imirhil.fr" ],
	"ssh" : [ "2001:41d0:fc8e:1e00:d63d:7eff:fe49:eb0d" ]
}
{% endhighlight %}
{% highlight ruby %}
# cookbooks/ssh/recipes/default.rb
service 'ssh' do
  supports status: true, restart: true, reload: true
  action %i(enable start)
end

allow_users = []
search(:users, 'ssh:*').each do | user |
	if user[:ssh].kind_of?(Array)
		user[:ssh].each { | ip | allow_users << "#{user[:id]}@#{ip}" }
	else
		allow_users << user[:id]
	end

	if user['ssh_keys']
		directory "~#{user[:id]}/.ssh" do
			owner id
			group id
			mode '700'
		end

		file "~#{user[:id]}/.ssh/authorized_keys" do
			owner id
			group id
			mode '600'
			content user['ssh_keys'].join("\n")
		end
	end
end

node[:ssh][:users].each do | user |
	if user[:ip]
		user[:ip].each { | ip | allow_users << "#{user[:id]}@#{ip}" }
	else
		allow_users << user[:id]
	end
end

template '/etc/ssh/sshd_config' do
	source 'sshd_config.erb'
	mode '644'
	notifies :restart, 'service[ssh]'
	variables(
		allow_users: allow_users.uniq.sort
	)
end
{% endhighlight %}

J'ai uniquement éditer les fichiers de données (databag), qui ne sont pas liés à une recette et peuvent donc contenir pas mal d'information, pour y ajouter les clefs SSH à déployer ainsi que les IP autorisées pour les accès SSH.
Et la recette *ssh* va utiliser exactement le même jeu de données que la recette *users*, pour déployer tout ça proprement et remplir les fichiers de clefs et la config SSH.
Impact sur la recette *users* : 0 !
Impact sur les anciennes classes des serveurs : 0 !
Ce qui n'aurait très clairement pas été le cas avec du Puppet (ajout d'une ressource exportée toute moche ou refacto lourde de l'infra pour introduire des classes fantômes) !
On obtient donc des configurations bien plus claires d'un point de vue sémantique avec Chef qu'avec Puppet.
Tout ça grâce à la primitive *search*, qui va interroger la base de données Solr pour récupérer l'état de la configuration.
Ce truc est extrêmement utile et fait toute la différence avec Puppet, l'intégralité de la configuration est accessible depuis n'importe quelle recette, ce qui évite la duplication d'information et/ou la création de classes fantômes pour gérer les dépendances.
La recette Nginx passera par *search* pour lister les Apache de sa machine hôte (`search(:node, "apache:* AND physical:#{node[:physical]}")`), ou encore la recette DNS l'utilisera de la même manière pour récupérer l'IP du DNS tournant sur le même réseau pour renseigner *resolv.conf*.
Chef, vainqueur par KO…

Bon, ben ça y est, on a résolu notre besoin de rationalisation de déploiement de machines du coup, et Chef est notre outil magique, non ?
Ben pas vraiment en fait…
Le problème avec *search*, c'est que les données sont publiées dans la base Solr non pas quand vous les publiez sur le serveur Chef mais **après** l'exécution de l'agent Chef…
Et ça change tout…
Chef utilisant un agent sur chaque machine, on n'a aucun moyen de garantir l'ordre d'exécution du déploiement.
Si par malheur le Nginx passe avant les Apaches, la config vue par Nginx est l'ancienne config et ne tient pas compte des potentielles modifications introduites par l'admin !
Pire, Chef a tendance à effacer toutes les configs existantes quand un admin publie ses modifications, le prochain passage sur le Nginx va donc virer tous les virtualhost de proxy et les Apaches vont se retrouver coupés du monde !
On pourrait résoudre ce problème en désactivant tous les agents et en exécutant le passage de Chef « à la main », via un script qui ordonne correctement les machines à déployer et s'y connecte dans l'ordre via SSH par exemple.
Ça ne résoud qu'une partie du problème car dans le cas d'une boucle de dépendances (Nginx proxite les Apaches qui ont besoin de l'IP du Nginx), il faudrait passer plusieurs fois sur chaque machine et avec des recettes différentes pour parvenir à avoir le bon résultat.
Discussions faites avec les équipes de Chef : « c'est pas un bug, c'est une feature »… Okkaaaaaay…

Bref, on retombe dans les travers de Puppet, avec des considérations systèmes qui doivent continuer à vivre dans la tête des admins (ordre des machines, séparation en sous-recettes sémantiquement inutiles…).

Idem, « mauvais outil, changer outil ».

# Ansible : et ben… ça ne marche pas mieux…

Allez, zou, tout poubelle pour ne pas changer, et on repart de zéro, ou presque.
Quitte à devoir désactiver les agents et se taper du script SSH sur les machines pour le déploiement, autant que ça soit directement prévu par l'outil.
Au passage, ça permet de s'abstraire de l'installation d'un serveur pour l'outil et tout reste sur la machine de l'admin. Plus [KISS](https://fr.wikipedia.org/wiki/Principe_KISS), tu meurts.

Donc on consulte nos petites tablettes, et il y a Ansible qui pointe le bout de son nez.
Agentless, nécessitant uniquement SSH (mais malheureusement codé en Python :(), ça semble être l'outil idéal pour réaliser ce qu'on souhaite.

Déjà, on repart sur du DSL qui masque le langage derrière, ici en l'occurence du [YAML](http://www.yaml.org/), qui est d'une syntaxe propre et élégante, que j'apprécie particulièrement (à ceci près qu'elle est basée sur l'indentation).

{% highlight yaml %}
# roles/apache/main.yml
- name: Install related Apache stuff
  apt: name={{"{{ item "}}}}
  with_items:
    - apache2
    - libapache2-mod-php5
    - libapache2-mod-rpaf
    - php-apc
    - php5-gd
    - php5-mysql
    - ssl-cert
- name: Allow www-data to access TLS parameters
  user: name=www-data groups=ssl-cert
  notify: Restart apache
- name: Configure reverse proxy IP for clean logs
  lineinfile: |
    dest=/etc/apache2/mods-available/rpaf.conf
    regexp='RPAFproxy_ips .*'
    line='RPAFproxy_ips 127.0.0.1 ::1 {{"{{ apache.proxy "}}}}'
  notify: Restart apache
- name: Activate modules
  command: a2enmod {{"{{ item "}}}} creates=/etc/apache2/mods-enabled/{{"{{ item "}}}}.load
  with_items:
    - headers
    - rewrite
    - ssl
    - rpaf
  notify: Restart apache
{% endhighlight %}

Propre net et sans bavure.

Ensuite, on retrouve aussi la notion de groupes que j'avais appréciée chez Chef, et qui modélise assez bien notre infrastructure réelle : chaque machine est associée à un groupe données, et en hérite donc des caractéristiques de configuration.
Par exemple toutes les machines déployant SSH vont écouter sur le même port (pas le 22 s.v.p. :D), et il suffira donc de déclarer un petit

{% highlight yaml %}
# group_vars/apache.yml
firewall:
  rules:
    - fw -A INPUT -p tcp --dport http -j ACCEPT
    - fw -A INPUT -p tcp --dport https -j ACCEPT
apache:
  admin: foo@example.org
  root: /srv/www

# group_vars/ssh.yml
firewall:
  rules:
    - fw -A INPUT -p tcp --dport 42 -j ACCEPT
ssh:
  port: 42
{% endhighlight %}

Et le travail est fait !

Enfin presque, sinon je n'aurais pas mis ce titre à ce billet…

Au début du monde, sur les premières taches, j'ai été très agréablement surpris par la concision de Ansible et ses possibilités.
Le tout étant agentless, le processus est beaucoup plus compréhensible que sur du Puppet et du Chef, où on a l'impression de plutôt jouer à l'apprenti chimiste qui relance ses déploiements à la volée jusqu'à ce que ça tombe plus ou moins en marche tout seul.
Passé ce premier stade et les « Hello, World ! » de circonstance, j'ai attaqué la mise-en-place d'une infra digne de ce nom, avec dépendances bouclées et tout le bordel.
Et je n'ai pas été déçu du voyage…

D'abord, je n'ai pas trouvé comment définir des méta-taches, ie. une tache réutilisable qui appelle plusieurs sous-taches.
Typiquement, ma tache de création d'un utilisateur (humain) est décomposable en création d'un utilisateur (UNIX) et déploiement de sa clef SSH.
La création d'un administrateur est la création d'un utilisateur (humain) et déploiement de sa clef SSH pour root.
J'aurais donc envie d'écrire quelque chose dans le style de

{% highlight yaml %}
# groups_var/users.yml
users:
  admins:
    - { name: aeris, uid: 1000, password: $6$JXZAHJ…xe2/, key: ssh-rsa AAAAB3NzaC1yc2…v4nv5 aeris@example.org }
  simples:
    - { name: foo, uid: 1100, password: $6$JXZAHJ…xe2/, key: ssh-rsa AAAAB3Nzayc2…v4nv5 foo@example.org }

# roles/users/main.yml
- name: Create generic user
  - name: Create UNIX user
    user: name={{"{{ item.name "}}}} uid={{"{{ item.uid "}}}} password={{"{{ item.password "}}}} groups={{"{{ item.groups "}}}} shell=/bin/zsh
  - name: Deploy SSH key for user
    authorized_key: user={{"{{ item.name "}}}} key={{"{{ item.key "}}}}

- name: Create user
  - call: Create generic user
    item.groups={{"{{ item.name "}}}}

- name: Create admin
  - call: Create generic user
    item.groups={{"{{ item.name "}}}},adm,sudo
  - authorized_key: user=root key={{"{{ item.key "}}}}

- name: Create admins
  call: Create admin
  with_items: {{"{{ users.admins "}}}}

- name: Create users
  call: Create user
  with_items: {{"{{ users.simples "}}}}
{% endhighlight %}

Et bien non !
Ça n'existe tout simplement pas en Ansible !
(Ou alors je n'ai pas trouvé…)
Pas de possibilité de définir des taches réutilisables !
Du coup j'en suis réduit à faire

{% highlight yaml %}
# roles/users/main.yml
- user: name={{"{{ item.name "}}}} uid={{"{{ item.uid "}}}} password={{"{{ item.password "}}}} groups={{"{{ item.name "}}}},adm,sudo shell=/bin/zsh
  with_items: users.admins
- authorized_key: user={{"{{ item.name "}}}} key={{"{{ item.key "}}}}
  with_items: users.admins
- authorized_key: user=root key={{"{{ item.key "}}}}
  with_items: users.admins

- user: name={{"{{ item.name "}}}} uid={{"{{ item.uid "}}}} password={{"{{ item.password "}}}} groups={{"{{ item.name "}}}} shell=/bin/zsh
  with_items: users.simples
- authorized_key: user={{"{{ item.name "}}}} key={{"{{ item.key "}}}}
  with_items: users.simples
{% endhighlight %}

3 boucles pour rien…
De la répétition partout…
Et là encore, j'ai de la chance, j'ai mis ça dans le même fichier de taches…
Pour un peu que j'ai besoin de créer un utilisateur dans un autre rôle, je suis à poil…
Le concept de [DRY](https://fr.wikipedia.org/wiki/Ne_vous_répétez_pas) a du échapper un peu aux concepteurs de Ansible, non ?

Bon, continuons…
Les groupes maintenant…
J'ai dit un peu plus haut que les variables pouvaient être héritées via les variables de groupe.
Mais Ansible a un concept d'héritage somme toute assez intéressant.

{% highlight yaml %}
# group_vars/ssh.yml
firewall:
  rules:
    - fw -A INPUT -p tcp --dport ssh -j ACCEPT

# group_vars/apache.yml
firewall:
  rules:
    - fw -A INPUT -p tcp --dport http -j ACCEPT
    - fw -A INPUT -p tcp --dport https -j ACCEPT
apache:
  admin: foo@example.org
  root: /srv/www

# group_vars/apache.proxy.yml
apache:
  proxy: 192.168.1.6

# host_vars/www.yml
apache:
  sites:
    - host: foo.example.org
      root: /srv/www/example.org/foo
    - host: bar.example.org
      root: /srv/www/example.org/bar
{% endhighlight %}

Naïvement, j'ai voulu faire des choses comme ça.
Naïvement hein, vu que c'est juste une description de ce qu'est réellement mon infra…
Toutes mes machines qui ont du SSH doivent avoir le port SSH d'ouvert.
Toutes les machines qui font du Apache doivent avoir le port HTTP et HTTPS d'ouvert, ont pour adresse mail de contact une certaine chose commune et servent leur contenu depuis /srv/www.
Et enfin, toutes les machines Apache derrière le même proxy Nginx seront configurées toutes pareilles niveau RPAF.
Et donc tout à fait naïvement toujours, je m'attend très logiquement à trouver comme valeurs de configuration à l'exécution pour la machine *www* Apache derrière le Nginx *proxy* quelque chose dans le goût de

{% highlight yaml %}
firewall:
  rules:
    - fw -A INPUT -p tcp --dport ssh -j ACCEPT
    - fw -A INPUT -p tcp --dport http -j ACCEPT
    - fw -A INPUT -p tcp --dport https -j ACCEPT
apache:
  admin: foo@example.org
  root: /srv/www
  proxy: 192.168.1.6
  sites:
    - host: foo.example.org
      root: /srv/www/example.org/foo
    - host: bar.example.org
      root: /srv/www/example.org/bar
{% endhighlight %}

Ça ne semble pas trop stupide, non ?
Mais quel benêt j'ai bien pu faire… Vraiment…

{% highlight yaml %}
firewall:
  rules:
    - fw -A INPUT -p tcp --dport http -j ACCEPT
    - fw -A INPUT -p tcp --dport https -j ACCEPT
apache:
  sites:
    - host: foo.example.org
      root: /srv/www/example.org/foo
    - host: bar.example.org
      root: /srv/www/example.org/bar
{% endhighlight %}

Voilààààààààà…
L'héritage au sens Ansibli-ien du terme, c'est « Zyva, pourquoi j'ai déjà une valeur moi ? Allez zou, fait pas suer, j'écrase ! ».
Du coup, j'en suis réduit à calculer moi-même le résultat du merge que j'aurais envie d'avoir eu, et à le coller dans le `hosts_var/www.yml` et à supprimer tous les `groups_var`.
Très pratique le jour où il y a un paramètre commun à changer…

Bon, c'est pas possible, doit y avoir un bug, je dois mal m'y prendre.
C'est pas humainement possible qu'un outil ne puisse pas gérer ça alors que c'est sensé être la principale utilité de l'outil…
Je relis la doc… Nada.
Je re-relis la doc… Que tchi…
Je sors IRC, et là, heureusement que j'étais très confortablement <s>avachi</s> assis à mon bureau :

	[2014/08/05] [22:39:29] [#ansible] <XXXXX> _aeris_: ansible just isn't set up to handle merging of vars like that.
	You are doing something most people would call an "antipattern"

S'il y a un seul lecteur de ce blog qui considère que ce que je cherche à faire est un antipattern, qu'il m'envoie un mail par IPoAC immédiatement, il faut que j'entame ma reconversion professionnelle dans l'élevage de chèvres dans le Larzac, non ?

Bon. Aller, j'vais réussir à m'en remettre… J'vais déployer du firewall en attendant…

{% highlight yaml %}
# roles/firewall/tasks/main.yml
- name: Install IPTables
  apt: name=iptables

- name: Deploy firewall script
  template: src=firewall dest=/etc/init.d/firewall mode=744
  notify: Restart firewall

# sites.yml
- hosts: all
  roles: firewall
{% endhighlight %}

Jusque là, c'est bon, tout le monde suit, et Ansible aussi…

Passont à [fail2ban](http://www.fail2ban.org/) maintenant.
Dans mon déploiement, le `service fail2ban restart` nécessaire à la prise en compte des nouvelles règles de blocage de `fail2ban` est en réalité fait via un `service firewall restart`, vu que le firewall doit déployer des règles avant celle de fail2ban.
J'ai donc besoin de faire

{% highlight yaml %}
roles/fail2ban/tasks/main.yml
- name: Install Fail2Ban
  apt: name=fail2ban

- name: Deploy Fail2Ban config
  template: src=fail2ban/jail.conf dest=/etc/fail2ban/jail.conf
  notify: Restart firewall

# sites.yml
- hosts: all
  roles: [firewall, fail2ban]
{% endhighlight %}

Question à 10 balles : où et comment je peux faire pour mutualiser le `Restart firewall` et ne définir sa tache associée qu'à un seul et unique endroit (principes KISS et DRY) ?
Grand naïf que je suis, je tente un petit

{% highlight yaml %}
# roles/firewall/handlers/main.yml
- name: Restart firewall
  action: service name=firewall state=restarted
{% endhighlight %}

Bam…
Ça passe très bien à l'exécution de la tache `firewall` mais ça plante violemment à celle de `fail2ban`, comme quoi le handler est manquant.
Bon ok, j'ai peut-être été un peu vache avec toi Ansible, j'vais quand même te mettre le handler dans un truc un peu plus commun et pas directement dans le role `firewall`…

{% highlight yaml %}
# roles/common/handlers/main.yml
- name: Restart firewall
  action: service name=firewall state=restarted

# sites.yml
- hosts: all
  roles: [common, firewall, fail2ban]
{% endhighlight %}

Bon là, c'est cool, ça passe bien…
Et en plus c'est doublement cool parce que je peux mettre tous mes handlers dans le même fichier en fait !

{% highlight yaml %}
# roles/common/handlers/main.yml
- name: Reload MySQL
  action: service name=mysql state=reloaded
- name: Restart MySQL
  action: service name=mysql state=reloaded

- name: Reload SSH
  action: service name=ssh state=reloaded
- name: Restart SSH
  action: service name=ssh state=restarted

- name: Reload Nginx
  action: service name=nginx state=reloaded
- name: Restart SSH
  action: service name=nginx state=restarted

- name: Reload Apache
  action: service name=apache2 state=reloaded
- name: Restart Apache
  action: service name=apache2 state=restarted

- name: Reload Postfix
  action: service name=postfix state=reloaded
- name: Restart Postfix
  action: service name=postfix state=restarted
{% endhighlight %}

(Et parce qu'on se rend bien compte que ce fichier va devenir ultra-barbant à maintenir, on va faire une ptite moulinette en Ruby pour le générer tout seul \o/)

Mais en fait, non, j'ai fait une erreur, je n'ai pas tous mes serveurs qui déploient du fail2ban, mais juste ceux avec ssh.
Gros naïf va…

{% highlight yaml %}
# sites.yml
- hosts: all
  roles: [common, firewall]

- hosts: ssh
  roles: fail2ban
{% endhighlight %}

Le firewall ? Ça passe ! \o/
Le fail2ban ? Ça paaaaass… pas ! /o\
Handler manquant… 
Mais il est commun à tout le monde en fait, non ?
Retour sur IRC. Et là, une « solution » m'est proposée…

{% highlight yaml %}
# sites.yml
- hosts: all
  roles: [common, firewall]

- hosts: ssh
  roles: [common, fail2ban]
{% endhighlight %}

Wait ? [Wat](https://www.destroyallsoftware.com/talks/wat) ‽
J'ai bien lu ?
C'est une blague à ce niveau-là, non ?
Elle est où la caméra ?
J'vais quand même pas devoir déclarer dans chaque groupe/rôle/whatever le role `common` juste pour avoir des handlers qui sont déjà théoriquement communs à toutes les machines, si ?

Bref…
Pour conclure, alors que Ansible me semblait assez prometteur et intéressant sur ses concepts (agentless + ssh + DSL pas trop dégeu), je me retrouve à devoir quasiment réfléchir à la place de l'outil pour lui prémâcher tout le travail, un peu comme si vous aviez une super machine sensée faire le café mais où vous deviez la remplir avec du café déjà tout fait qu'elle n'a plus qu'à réchauffer pour servir…

# Conclusion

J'ai à peine dépassé la dizaine de machines virtuelles sur deux virtualiseurs et sans dépendances ultra-complexes (je m'en suis arrêté aux couples NGinx/Apache, j'espérais aller jusqu'à la génération, à partir des certificats X.509 déployés dans les Apache et NGinx, des entrées DNS TLSA dans une zone signée avec OpenDNSSec !!!) que je me sens déjà très largement à l'étroit avec chacun des outils précédents.
Puppet pour son manque de gestion des dépendances et de séparation des concepts, Chef pour plus ou moins les mêmes raisons même s'il va un peu plus loin, et Ansible pour environ tout le reste…

D'où ma très grosse question : mais comment ils font tous ces DSI et assimilés qui gèrent des machines par brouettes de 1.000 et dans des environnements où les chaînes de dépendances doivent faire pâlir Lustucru ?
Comment ça se fait que des outils comme Puppet ou Chef (et apparemment bientôt Ansible) soient aussi encensés par les admins alors que je m'y sens aussi à l'étroit qu'un paquet IP qui passe dans un routeur sous DDOS ?
Est-ce qu'ils arrivent réellement à exporter dans ces outils tout ce qui était auparavant dans la tête des admins sys en chef ou dans une doc plus ou moins @Deprecated dans un coin, ou est-ce qu'au final, Puppet/Chef/Ansible a juste permis de massivement accélérer le déploiement sur whatmille machines, la configuration elle-même ayant été compilée dans la tête d'un admin et implémentée directement dans l'outil (avec les soucis de mise-à-jour que ça implique) ?

Est-ce que c'est uniquement mon délire de développeur qui veut du code au cordeau qui fait que je recherche un outil qui serait en réalité le mouton à 5 pattes et à la toison d'or ?
Est-ce que mes exigences de départ, à savoir un outil qui va gérer de lui-même les dépendances du SI, à notre place et à partir d'une description factuelle de l'environnement, ça juste n'existe pas actuellement ?
Est-ce qu'il va falloir que je sorte mon IDE pour en coder un ? (Et accessoirement ajouter un n-ième projet sur ma todo-liste ? :D)

Les questions sont ouvertes, les commentaires en bas de cette page aussi si vous avez des réponses. :)

(NB: On pourrait croire que j'ai beaucoup tapé sur Ansible, mais c'est au final le seul outil que j'ai conservé actuellement. Mais il ne me sert plus que pour ce que je considère dorénavant qu'il est : un exécuteur de procédures via SSH, ni plus, ni moins)
