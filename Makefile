all: deploy

optimize:
	trimage -d assets/images

build:
	bundle exec jekyll build

deploy: build
	rsync -ahvxP --delete _site/ server:/srv/www/imirhil.fr/blog/
