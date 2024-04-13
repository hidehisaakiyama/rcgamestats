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

sheet_name="${group_name}-${opponent_name}"
queued_results_csv="$HOME/${sheet_name}.csv"

if [ ! -e $csvfile ]; then
	echo "$csvfile not found"
	exit 1
fi

#
# check & create lock file
#
while ! ln -s $$ $saver_lockfile > /dev/null 2>&1 ;
do
	sleep 0.1
done

#
# add the match number column to the result csv
#
cp $csvfile match.csv
sed -i "1s/^/match_id,host,/" match.csv
sed -i "2,\$s/^/${match_number},${remote_host},/" match.csv

if [ ! -e $queued_results_csv ]; then
	cat match.csv > $queued_results_csv
else
	mv $queued_results_csv tmp.csv
	awk 'FNR!=1||NR==1' tmp.csv match.csv > $queued_results_csv
	rm tmp.csv
fi

rm match.csv

finish_datetime=`date "+%Y%m%d-%H%M%S"`
echo -n "[$finish_datetime] @$remote_host adds the result: group=[$sheet_name] match=[$match_number]"
awk -F', ' 'NR > 1 { printf(" (%s - %s)\n", $6, $7) }' $csvfile
echo "[$finish_datetime] @$remote_host adds the result: group=[$sheet_name] match=[$match_number]" >> $global_log

n_lines=`wc -l < $queued_results_csv`
if [ "$n_lines" -gt "$result_saver_block_size" ]; then

	current_timestamp=`date +%s%3N`
	last_timestamp=0
	if [ -f "$result_saver_timestamp" ]; then
		last_timestamp=`cat "$result_saver_timestamp"`
	fi

	elapsed_time=`expr $current_timestamp - $last_timestamp`
	if [ "$elapsed_time" -ge "$minimum_interval_msec" ]; then
		path=`dirname $0`
		python3 $path/write_queued_results.py $queued_results_csv
		rm $queued_results_csv
	fi
fi

#
# remove lock file
#
rm -f $saver_lockfile
