#!/bin/sh

. $HOME/rcgamestats/config

if [ $# -ne 3 ]; then
	echo "Usage:"
	echo "  $0 <group name> <opponent name> <match number>"
	exit 1
fi

logtime=`date "+%Y%m%d-%H%M%S"`

hostname=`hostname`
path=`dirname $0`

group_name=$1
opponent_name=$2
match_number=$3

opponent_info=`grep "^${opponent_name}," $teamlist`
if [ -z $opponent_info ]; then
	echo "[$logtime] @$hostname [$opponent_name] not available."
fi

opponent_path=`echo $opponent_info | cut -d , -f 3`
if [ ! -d $opponent_path ]; then
	echo "[$logtime] @$hostname remote_run_match: No path for $opponent_name"
	ssh $server "~/rcgamestats/scripts/server_append_host.sh $hostname $match_number"
	exit 1
fi

synch_mode=`echo $opponent_info | cut -d , -f 2`

team_l_start=$left_team_start_script
team_r_start=$opponent_path/start.sh

if [ ! -x $team_l_start ]; then
	echo "[$logtime] @$hostname remote_run_match: left team start script not found'"
	ssh $server "~/rcgamestats/scripts/server_append_host.sh $hostname $match_number"
	exit 1
fi

if [ ! -x $team_r_start ]; then
	echo "[$logtime] @$hostname remote_run_match: start.sh not found '$opponent_path/start.sh'"
	ssh $server "~/rcgamestats/scripts/server_append_host.sh $hostname $match_number"
	exit 1
fi

if [ ! -d ~/logs ]; then
	mkdir ~/logs
fi


$path/cpufreq-set-all.sh performance


num=`printf %03d $match_number`
log_name="${group_name}-${opponent_name}-${num}-${hostname}"

opt="server::game_logging = true server::text_logging = true"
#opt="$opt server::game_log_dated = true server::text_log_dated = true"
opt="$opt server::game_log_dated = true server::text_log_dated = false"
#opt="$opt server::game_log_fixed = false server::text_log_fixed = false"
opt="$opt server::game_log_fixed = true server::text_log_fixed = true"
opt="$opt server::game_log_fixed_name = '$log_name' server::text_log_fixed_name = '$log_name'"
opt="$opt server::game_log_compression = 9 server::text_log_compression = 9"
#opt="$opt server::game_log_dir = '~/logs/' server::text_log_dir = '~/logs/'"
opt="$opt server::log_date_format = '%Y%m%d%H%M%S-'"
opt="$opt server::nr_normal_halfs = 2 server::nr_extra_halfs = 0 server::penalty_shoot_outs = false"
opt="$opt server::half_time = 300 server::extra_half_time = 100"
opt="$opt server::synch_mode = $synch_mode"
opt="$opt server::auto_mode = true"
opt="$opt server::team_l_start = '$team_l_start'"
opt="$opt server::team_r_start = '$team_r_start'"
opt="$opt CSVSaver::save = true CSVSaver::filename = '${log_name}.csv'"
#opt="$opt server::fixed_teamname_l = 'L' server::fixed_teamname_r = 'R'"

echo "[$logtime] @$hostname opponent=$opponent_name synch_mode=$synch_mode"
#echo $opt

start_epochtime=`date "+%s"`

$HOME/local/bin/rcssserver $opt 1> stdout.log 2> stderr.log

#sleep 2
sleep 1

end_epochtime=`date "+%s"`
elapsed_sec=`expr $end_epochtime - $start_epochtime`
elapsed_minutes=`expr \( $end_epochtime - $start_epochtime \) / 60`
elapsed_seconds=`expr \( $end_epochtime - $start_epochtime \) % 60`
printf "@%s match=[%d] elapsed %d:%02d\n" $hostname $match_number $elapsed_minutes $elapsed_seconds

#
# kill team scripts
#
$opponent_path/kill >/dev/null 2>&1

#
# analyze log file???
#

#
# copy logs & result to server
#

echo "[`date "+%Y%m%d-%H%M%S"`] @$hostname compressing debug log files..."

debug_log_dir="${log_name}"
mkdir -p $debug_log_dir
mv stdout.log stderr.log ${debug_log_dir}

if [ -e /tmp/HELIOS*-1.ocl ]; then
#	sleep 3.5
	mv /tmp/HELIOS*.ocl ${debug_log_dir}
else
	echo "[$logtime] @$hostname ocl not found"
fi

sleep 0.1
tar czf ${log_name}.tar.gz ${debug_log_dir}/*
rm -rf ${debug_log_dir}

echo "[`date "+%Y%m%d-%H%M%S"`] @$hostname copying log & result files to $server"

log_dir="${group_name}-${opponent_name}"
ssh $server mkdir -p ~/logs/${log_dir}
scp ${log_name}* ${server}:logs/${log_dir}
rm ${log_name}*


$path/cpufreq-set-all.sh powersave


#
# add the result to the queued csv
#
ssh $server "~/rcgamestats/scripts/server_add_result.sh $group_name $opponent_name $match_number $hostname ${log_name}.csv"

#
# add this host to available-hosts on the server
#
ssh $server "~/rcgamestats/scripts/server_append_host.sh $hostname $match_number"

#
# save result to the spreadshet
#
#ssh -f $server "~/rcgamestats/scripts/server_save_result.sh $group_name $opponent_name $match_number $hostname ${log_name}.csv"
