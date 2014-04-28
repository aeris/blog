PELICAN=$(WORKON_HOME)/pelican/bin/pelican
PELICANOPTS=

BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/content
OUTPUTDIR=$(BASEDIR)/output
CONFFILE=$(BASEDIR)/pelicanconf.py
PUBLISHCONF=$(BASEDIR)/publishconf.py

FTP_HOST=localhost
FTP_USER=anonymous
FTP_TARGET_DIR=/

SSH_HOST=server.imirhil.fr
SSH_PORT=2222
SSH_USER=aeris
SSH_TARGET_DIR=/srv/www/imirhil.fr/blog

DROPBOX_DIR=~/Dropbox/Public/

all: rsync

help:
	@echo 'Makefile for a pelican Web site                                        '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make html                        (re)generate the web site          '
	@echo '   make clean                       remove the generated files         '
	@echo '   make regenerate                  regenerate files upon modification '
	@echo '   make publish                     generate using production settings '
	@echo '   make serve                       serve site at http://localhost:8000'
	@echo '   make devserver                   start/restart develop_server.sh    '
	@echo '   ssh                              upload the web site via SSH        '
	@echo '   rsync                            upload the web site via rsync+ssh  '
	@echo '   dropbox                          upload the web site via Dropbox    '
	@echo '   ftp                              upload the web site via FTP        '
	@echo '   github                           upload the web site via gh-pages   '
	@echo '                                                                       '


html: clean $(OUTPUTDIR)/index.html
	@echo 'Done'

$(OUTPUTDIR)/%.html:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

clean:
	find $(OUTPUTDIR) -mindepth 1 -delete

regenerate: clean
	$(PELICAN) -r $(INPUTDIR) -o $(OUTPUTDIR) -s $(CONFFILE) $(PELICANOPTS)

serve:
	cd $(OUTPUTDIR) && python -m SimpleHTTPServer

devserver:
	$(BASEDIR)/develop_server.sh restart

stop:
	$(BASEDIR)/develop_server.sh stop

publish:
	$(PELICAN) $(INPUTDIR) -o $(OUTPUTDIR) -s $(PUBLISHCONF) $(PELICANOPTS)

ssh: publish
	scp -P $(SSH_PORT) -r $(OUTPUTDIR)/* $(SSH_HOST):$(SSH_TARGET_DIR)

rsync: clean publish
	rsync -axPv --delete $(OUTPUTDIR)/ $(SSH_HOST):$(SSH_TARGET_DIR)

dropbox: publish
	cp -r $(OUTPUTDIR)/* $(DROPBOX_DIR)

ftp: publish
	lftp ftp://$(FTP_USER)@$(FTP_HOST) -e "mirror -R $(OUTPUTDIR) $(FTP_TARGET_DIR) ; quit"

github: publish
	ghp-import $(OUTPUTDIR)
	git push origin gh-pages

.PHONY: html help clean regenerate serve devserver publish ssh rsync dropbox ftp github
