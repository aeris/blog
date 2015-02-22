#!/
##
# This section should match your Makefile
##
PELICAN=$HOME/.virtualenvs/pelican/bin/pelican
PELICANOPTS=

BASEDIR=$(pwd)
INPUTDIR=$BASEDIR/content
OUTPUTDIR=$BASEDIR/output
CONFFILE=$BASEDIR/pelicanconf.py
PIDS=

trap "do_stop" SIGINT SIGQUIT
do_stop() {
	kill ${PIDS}
	exit
}

$PELICAN --debug --autoreload -r $INPUTDIR -o $OUTPUTDIR -s $CONFFILE $PELICANOPTS &
PIDS = "$PIDS $!"
rshare $OUTPUTDIR &
PIDS = "$PIDS $!"
PIDS = "$PIDS $!"
bundle exec guard -i -w $BASEDIR -G $BASEDIR/Guardfile &
