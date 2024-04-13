#!/bin/sh

. $HOME/rcgamestats/config

if [ $# -lt 1 ]; then
	echo "No command"
	exit 1
fi

echo "reset $availablehosts"
sort -u ${availablehosts}.tmpl > ${availablehosts}.command

for i in `cat ${availablehosts}.command`; do
	echo "=========="
	echo "$i: \"$*\""
	ssh $i "$*"
done

rm ${availablehosts}.command
