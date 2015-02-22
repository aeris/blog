#!/usr/bin/env ruby
require 'open3'

PELICAN = File.expand_path File.join %w(~ .virtualenvs pelican bin/pelican)

BASEDIR = Dir.pwd
INPUTDIR = File.join BASEDIR, 'content'
OUTPUTDIR = File.join BASEDIR, 'output'
CONFFILE = File.join BASEDIR, 'pelicanconf.py'
PIDS = []

trap('INT', 'TERM') do
	PIDS.each { |_, _, _, e| Process.kill 'INT', e.pid }
	exit
end

PIDS << Open3.popen2(PELICAN, '--debug', '--autoreload', '-r', INPUTDIR, '-o', OUTPUTDIR, '-s', CONFFILE) #{ |_, o, _| loop { print o.gets } }
PIDS << Open3.popen2('rshare', OUTPUTDIR) #{ |_, o, _| loop { print o.gets } }
PIDS << Open3.popen2('bundle', 'exec', 'guard', '-i', '-w', BASEDIR, '-G', "#{BASEDIR}/Guardfile") #{ |_, o, _| loop { print o.gets } }

sleep
