#!/bin/sh

. $HOME/rcgamestats2/config

if [ $# -ne 1 ]; then
	echo "Usage: $0 hostname"
	exit 1
fi

host=$1
echo "===================="
echo "sync to $host ..."
rsync -auzv ~/local/ $host:local/
rsync -auzv ~/.rcssserver/ $host:.rcssserver/
rsync -auzv --delete --exclude "*.h" --exclude "*.cpp" --exclude "*.a" --exclude "*.o" --exclude "*.Po" --exclude "*.lo" --exclude ".deps" --exclude ".git*" --exclude ".libs" --exclude "Makefile*" ~/work/ $host:work/
rsync -auzv --delete ~/teams/ $host:teams/
rsync -auzv --delete --exclude ".git" ~/rcgamestats2/ $host:rcgamestats2/

