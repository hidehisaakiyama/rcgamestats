#!/bin/sh

. $HOME/rcgamestats/config

if [ $# -ne 2 ]; then
    echo "Usage:"
	echo "  $0 <hostname>"
    exit 1
fi


host=$1
match_number=$2

while ! ln -s $$ $lockfile > /dev/null 2>&1 ;
do
	sleep 0.1
done

received_time=`date "+%Y%m%d-%H%M%S"`

rm $HOME/running-$host
echo $host >> $availablehosts
rm -f $lockfile

echo "[$received_time] @$host match=[$match_number] finished. server append the host" >> $global_log
echo "[$received_time] @$host match=[$match_number] finished. server append the host"
