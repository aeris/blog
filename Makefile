deploy:
	jekyll build
	rsync -axPv --delete _site/ server:/srv/www/imirhil.fr/blog/
