all: deploy

dev:
	bundle exec guard -i

optimize:
	trimage -d assets/images

build:
	JEKYLL_ENV=production bundle exec jekyll build

deploy: build
	rsync -ahvxP --delete _site/ server:/srv/www/imirhil.fr/blog/
