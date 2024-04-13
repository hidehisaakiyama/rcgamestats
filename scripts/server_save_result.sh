#!/bin/sh

. $HOME/rcgamestats/config

# arg: group name
# arg: opponent name
# arg: match number
# arg: remote host name
# arg: name of the resulst csv file (the file must be located under ~/logs/ on server)

group_name=$1
opponent_name=$2
match_number=$3
remote_host=$4
log_dir="${group_name}-${opponent_name}"
csvfile=$HOME/logs/${log_dir}/$5

timestamp_file="$HOME/result_saver_timestamp"
minimum_interval_msec=1000

if [ ! -e $csvfile ]; then
	echo "$csvfile not found"
	exit 1
fi

sheet_name="${group_name}-${opponent_name}"

#
# check lock file
#
while ! ln -s $$ $saver_lockfile > /dev/null 2>&1 ;
do
	sleep 0.1
done

current_timestamp=`date +%s%3N`
last_timestamp=0
if [ -f "$timestamp_file" ]; then
    last_timestamp=`cat "$timestamp_file"`
fi

elapsed_time=`expr $current_timestamp - $last_timestamp`
#echo "save result... elapsed time $elapsed_time"
if [ "$elapsed_time" -lt "$minimum_interval_msec" ]; then
    sleep_time_msec=`expr $minimum_interval_msec - $elapsed_time`
    sleep_time_sec=$(echo "scale=3; $sleep_time_msec / 1000" | bc)
    #echo "${match_number}@${remote_host}: sleep $sleep_time_sec for avoiding Google quota"
    printf "%03d@%s sleep %.3f sec for avoiding Google quota.\n" $match_number $remote_host $sleep_time_sec
    sleep $sleep_time_sec
fi

path=`dirname $0`
python3 $path/write_result.py $sheet_name $match_number $remote_host $csvfile

current_timestamp=`date +%s%3N`
echo $current_timestamp > $timestamp_file

finish_datetime=`date "+%Y%m%d-%H%M%S"`
echo "[$finish_datetime] @$remote_host server saved group=[$group_name] match=[$match_number]"
echo "[$finish_datetime] @$remote_host server saved group=[$group_name] match=[$match_number]" >> $global_log
rm -f $saver_lockfile
