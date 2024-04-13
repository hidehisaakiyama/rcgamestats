#!/bin/sh

. $HOME/rcgamestats/config


if ! ln -s $$ $saver_lockfile > /dev/null 2>&1 ; then
	echo "$0: lock file exits."
	return 1
fi

# check running-* files
if ls $HOME/running-* > /dev/null 2>&1 ; then
	echo "$0: running files exist."
	rm -f $saver_lockfile
	return 1
fi

# check csv files
if ! ls $HOME/*.csv > /dev/null 2>&1 ; then
	echo "$0: no csv files"
	rm -f $saver_lockfile
	return 0
fi

# for all csv files
for csvfile in $HOME/*.csv ; do
	current_timestamp=`date +%s%3N`
	last_timestamp=0
	if [ -f "$result_saver_timestamp" ]; then
	    last_timestamp=`cat "$result_saver_timestamp"`
	fi

	elapsed_time=`expr $current_timestamp - $last_timestamp`
	if [ "$elapsed_time" -ge "$minimum_interval_msec" ]; then
	    sleep_time_msec=`expr $minimum_interval_msec - $elapsed_time`
	    sleep_time_sec=$(echo "scale=3; $sleep_time_msec / 1000" | bc)
	    printf "sleep %.3f sec for avoiding Google quota.\n" $sleep_time_sec
	    sleep $sleep_time_sec
	fi

	python3 $HOME/rcgamestats/script/write_result2023.py $csvfile
done

rm -f HOME/*.csv
rm -f $saver_lockfile
