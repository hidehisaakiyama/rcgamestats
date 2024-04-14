#!/bin/sh

. $HOME/rcgamestats/config

if file "$HOME/work/src/rctools/helios/src/player/helios_player" | grep -q "not stripped"; then
    strip $HOME/work/src/rctools/helios/src/player/helios_player
fi
if file "$HOME/work/src/rctools/helios/src/coach/helios_coach" | grep -q "not stripped"; then
    strip $HOME/work/src/rctools/helios/src/coach/helios_coach
fi
if file "$HOME/work/src/rctools/helios/src/coach/helios_trainer" | grep -q "not stripped"; then
    strip $HOME/work/src/rctools/helios/src/trainer/helios_trainer
fi

echo "reset $availablehosts"
#sort -u ${availablehosts}.tmpl > ${availablehosts}.sync
cat ${availablehosts}.tmpl > ${HOME}/sync-hosts

for host in `cat ${HOME}/sync-hosts`; do
	echo "===================="
	echo "sync to $host ..."
	rsync -auzv ~/local/ $host:local/
	rsync -auzv ~/.rcssserver/ $host:.rcssserver/
	rsync -auzv --delete --exclude "*.h" --exclude "*.cpp" --exclude "*.a" --exclude "*.o" --exclude "*.Po" --exclude "*.lo" --exclude ".deps" --exclude ".git*" --exclude ".libs" --exclude "Makefile*" ~/work/ $host:work/
	rsync -auzv --delete ~/teams/ $host:teams/
	rsync -auzv --delete --exclude ".git" ~/rcgamestats/ $host:rcgamestats/
done

echo "sync" > synched
rm ${HOME}/sync-hosts
