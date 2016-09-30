---
title: Installer Discourse sans Docker
---

[Discourse](https://www.discourse.org/) est un moteur de forum nouvelle génération, vraiment excellent comparé aux autres moteurs vieillissants comme [PHPBB](https://www.phpbb.com/) ou [Simple Machines Forum](http://www.simplemachines.org/).

Son principal et gros problème est qu’il n’est livré officiellement que [via un conteneur Docker](https://github.com/discourse/discourse/blob/master/docs/INSTALL-cloud.md).  
(Vous aurez d’ailleurs le loisir de savoir tout le mal que je pense de cette technologie et de cette tendance dans un prochain billet ici-même.)

Comme je n’aime pas Docker et que [Ruby on Rails](http://rubyonrails.org/), le framework web utilisé par Discourse, est pourtant très bien fait pour un déploiement simple et efficace, voici un tuto sur comment installer ce moteur de forum en se passant totalement de toute solution de virtualisation !  
Je me sers de cette procédure pour [ma propre instance Discourse](https://ask.imirhil.fr/).

# Prérequis : Ruby

Ruby est disponible nativement dans les paquets Debian, mais son installation via `apt`, au même titre que Python, est assez dangereuse pour votre système.  
En effet, un projet vient généralement avec ~~trop~~ plein de dépendances qui vont aller s’installer un peu partout sur votre système et risquent d’entrer en conflit avec votre gestionnaire de paquets.  
Du coup, il vaut mieux utiliser [RBEnv](https://github.com/rbenv/rbenv) qui va vous permettre d’avoir plusieurs versions de Ruby sur la même machine facilement, mais en plus isolera vos dépendances proprement.

Pour installer tout ça :

	apt install git-core
	apt install rbenv
	apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
	
	export RBENV_ROOT=/usr/local/rbenv
	eval "$(rbenv init -)"
	
	git clone --depth 1 https://github.com/rbenv/ruby-build $RBENV_ROOT/plugins/ruby-build -b v20160913
	rbenv install 2.3.1
	rbenv global 2.3.1
	
	echo "gem: --no-test --no-document" > ~/.gemrc
	gem install bundler
	rbenv rehash

# Discourse

L’installation n’est guère compliquée pour qui a déjà fait du Ruby on Rails, puisque c’est du 100% standard :

	export RBENV_ROOT=/usr/local/rbenv
	eval "$(rbenv init -)"
	
	export RAILS_ENV=production
	export DISCOURSE_DB_HOST=localhost
	export DISCOURSE_DB_PASSWORD=un-bon-gros-mot-de-passe
	export DISCOURSE_HOSTNAME=le.futur.domaine.de.votre.forum
	
	apt install redis-server postgresql postgresql-contrib libpq-dev nginx-light
	su postgres -s /bin/bash <<-EOF
		psql -c "CREATE USER discourse WITH PASSWORD '${DISCOURSE_DB_PASSWORD}';"
		createdb -O discourse discourse
	EOF
	
	mkdir -p /srv/www
	
	git clone https://github.com/discourse/discourse /srv/www/discourse --depth 1 -b v1.6.4
	cd /srv/www/discourse
	mkdir -p public/uploads
	chown -R www-data:www-data log tmp public/uploads
	bundle install
	
	su postgres -s /bin/bash -c 'psql -c "ALTER USER discourse WITH SUPERUSER;"'
	bundle exec rake db:migrate
	su postgres -s /bin/bash -c 'psql -c "ALTER USER discourse WITH NOSUPERUSER;"'
	
	bundle exec rake assets:precompile

# Services divers

Discourse nécessite un démon [Sidekiq](http://sidekiq.org/) pour ses taches d’arrière-plan.
Et j’ai tenté d’utiliser [Passenger](https://www.phusionpassenger.com/) comme serveur d’application Ruby on Rails, mais il ne tenait pas la charge et je me suis donc rabattu sur [Unicorn](https://unicorn.bogomips.org/).  
Et il faut donc démarrer ces deux services pour avoir un forum fonctionnel.
[Voici](https://gist.github.com/aeris/24862f2d0c34e831d80cb616e995957b) les services SystemD correspondants, à éditer en fonction de vos besoins !

	wget https://gist.github.com/aeris/24862f2d0c34e831d80cb616e995957b/raw/7d8b9f7519d5ad09c14ea17a9d5408cbe6f39ab0/discourse-sidekiq.service -O /etc/systemd/system/discourse-sidekiq.service
	wget https://gist.github.com/aeris/24862f2d0c34e831d80cb616e995957b/raw/7d8b9f7519d5ad09c14ea17a9d5408cbe6f39ab0/discourse-unicorn.service -O /etc/systemd/system/discourse-unicorn.service
	# Éditer ici les fichiers (mot de passe, domaine, répertoire…)
	
	systemctl enable discourse-sidekiq discourse-unicorn
	systemctl start discourse-sidekiq discourse-unicorn

Pour votre configuration Nginx, vous trouverez un exemple dans le fichier `config/nginx.sample.conf` de Discourse.
La seule véritable subtilité est que certaines URL (`/assets/`, `/uploads/`…) doivent être servies directement depuis le disque et ne doivent pas être transmises au serveur d’application et doivent donc être exclues de la directive `proxy_pass`.

# Mise-à-jour

Pour la mise-à-jour du moteur, c’est aussi une procédure tout à fait classique pour du Ruby on Rails :

	export RBENV_ROOT=/usr/local/rbenv
	eval "$(rbenv init -)"
	
	export RAILS_ENV=production
	export DISCOURSE_DB_HOST=localhost
	export DISCOURSE_DB_PASSWORD=un-bon-gros-mot-de-passe
	export DISCOURSE_HOSTNAME=le.futur.domaine.de.votre.forum
	
	cd /srv/www/discourse
	git fetch https://github.com/discourse/discourse
	git checkout vX.Y.Z
	
	systemctl stop discourse-sidekiq discourse-unicorn
	
	bundle install
	
	su postgres -s /bin/bash -c 'psql -c "ALTER USER discourse WITH SUPERUSER;"'
	bundle exec rake db:migrate
	su postgres -s /bin/bash -c 'psql -c "ALTER USER discourse WITH NOSUPERUSER;"'
	
	bundle exec rake assets:precompile

	systemctl start discourse-sidekiq discourse-unicorn
