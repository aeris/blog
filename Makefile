all: deploy

optimize:
	trimage -d assets/images

build:
	jekyll build

deploy: build
	rsync -axPv --delete _site/ server:/srv/www/imirhil.fr/blog/
