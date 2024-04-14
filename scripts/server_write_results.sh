#!/bin/sh

. $HOME/rcgamestats/config

while true
do
    echo "server_write_results.sh"
    #
    # check lock file
    #
    while ! ln -s $$ $saver_lockfile > /dev/null 2>&1 ;
    do
	echo "server_write_results.sh wait lock"
	sleep 1
    done

    # check csv files
    if ls $HOME/logs/*.csv > /dev/null 2>&1 ; then
	echo "no csv files"
	if ls $HOME/running-* > /dev/null 2>&1 ; then
	    echo "no running files - break"
	    break
	fi
	echo "server_write_results.sh wait results"
	sleep 1
	continue
    fi

    # for all csv files
    for csvfile in `ls $HOME/logs/*.csv`; do
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

	path=`dirname $0`
	python3 $path/write_result.py $csvfile
    done

    rm -f HOME/logs/*.csv
    rm -f $saver_lockfile

    if ls $HOME/running-* > /dev/null 2>&1 ; then
	echo "no running file - break"
	break
    fi
    echo "server_write_results.sh wait loop"
    sleep 1
done


datetime=`date "+%Y%m%d-%H%M%S"`
echo "[$datetime] write the results."
echo "[$datetime] write the results." >> $global_log
