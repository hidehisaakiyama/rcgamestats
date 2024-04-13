#!/bin/sh

. $HOME/rcgamestats2/config

ls $HOME/running-* > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo ">>>> rcgamestats2 exist a running match"
    exit 1
fi

if [ ! -e synched ]; then
    echo ">>>>> binary is not synched"
    exit 1
fi
if [ $HOME/work/src/rctools/helios/src/player/helios_player -nt synched ]; then
    echo ">>>>> binary may not be synched"
    exit 1
fi

if ! ln -s $$ $HOME/run.rcgamestats2 > /dev/null 2>&1 ; then
    echo ">>>>> rcgamestats2 already running."
    exit 1
fi

rm_runfile()
{
    rm -f $HOME/run.rcgamestats2
    echo ">>>>> $0. remove run.rcgamestats2 and exit."
    exit 0
}

# set handler
trap rm_runfile INT

match=""
host=""

if [ ! -e $matchlist ]; then
    echo ">>>>> No matchlist file. exit."
    rm_runfile
    exit 1
fi

match=`head -n 1 $matchlist`
if [ -z $match ]; then
    echo ">>>>> Empty matchlist. exit."
    rm_runfile
    exit 1
fi

get_next_match()
{
    if [ ! -e $matchlist ]; then
		echo ">>>>> No matchlist file. exit."
		rm_runfile
		exit 1
    fi

    # delete empty lines
    sed '/^$/d' -i $matchlist
    # read the first line
    match=`head -n 1 $matchlist`

    if [ -z $match ]; then
		echo ">>>>> $0 Empty match queue."
		rm_runfile
		exit 0
    fi

#    while [ -z $match ]
#    do
#	#echo `date "+%Y%m%d-%H%M%S"` INFO waiting a next match. >> $manager_log
#	echo "rcgamestats2-manager: waiting a next match..."
#
#	inotifywait $matchlist > /dev/null 2>&1
#	sleep 1
#
#	if [ ! -e $matchlist ]; then
#	    echo "No matchlist file. exit."
#	    exit 1
#	fi
#
#	# delete empty lines
#	sed '/^$/d' -i $matchlist
#
#	# read the first line
#	match=`head -n 1 $matchlist`
#    done
}

get_next_host()
{
    host=""

    while [ -z $host ]
    do
	# delete empty lines
	sed '/^$/d' -i $availablehosts
	# read the first line
	host=`head -n 1 $availablehosts`
	#echo "candidate host = [$host]"
	if [ -z $host ]; then
	    echo "@$server waiting an available host..."
		echo "[`date "+%Y%m%d-%H%M%S"`] @$server: waiting an available host..." >> $global_log
	    inotifywait $availablehosts > /dev/null 2>&1
	    continue
	fi

	# check the network connection
	ping -c 1 $host > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	    # detect the unavailable host
	    echo "***ERROR*** detect unreachable host $host. delete it from availablelist."
	    echo "[`date "+%Y%m%d-%H%M%S"`] unavailable host $host" >> $global_log

	    while ! ln -s $$ $lockfile > /dev/null 2>&1 ;
	    do
		sleep 0.5
	    done

	    # reset host variable
	    host=""
	    # delete the first line
	    sed -e '1d' -i $availablehosts

	    rm -f $lockfile
	fi
    done
}

if [ ! -e $matchlist ]; then
	echo "$matchlist does not exist."
	echo "creating empty file..."
	touch $matchlist
fi

if [ ! -e $availablehosts ]; then
	echo "$availablehosts does not exist."
	echo "creating empty file..."
	touch $availablehosts
fi

echo "reset $availablehosts"
#sort -u ${availablehosts}.tmpl > $availablehosts
cat ${availablehosts}.tmpl > $availablehosts

# delete empty lines
sed '/^$/d' -i $matchlist
sed '/^$/d' -i $availablehosts

while true
do
	#
	# get the first match from matchlist
	#
	get_next_match

	#
	# parse the match info
	#
	group_name=`echo $match | cut -d ',' -f 1`
	opponent_name=`echo $match | cut -d ',' -f 2`
	match_number=`echo $match | cut -d ',' -f 3`
	#num=`echo $match | cut -d ',' -f 3`
	#match_number="`printf %04d $num`"

	#
	# check the availability of the opponent team
	#
	opponent_info=`grep "^${opponent_name}," $teamlist`
	if [ -z $opponent_info ]; then
	    echo "ERROR: [$opponent_name] not available."
	fi

	opponent_path=`echo $opponent_info | cut -d , -f 3`
	if [ ! -d $opponent_path ]; then
		#echo `date "+%Y%m%d-%H%M%S"` ERROR $opponent_name not available. >> $manager_log
		echo "ERROR: [${opponent_name}] not available."
		# delete the first line from matchlist
		sed -e '1d' -i $matchlist
		continue
	fi

	#
	# get the first host from available-hosts
	#
	get_next_host

	#
	logdate=`date "+%Y%m%d-%H%M%S"`
	echo "[$logdate] @$host start [${match}]"  >> $global_log
	echo "[$logdate] @$host start [${match}]..."
	#

	while ! ln -s $$ $lockfile > /dev/null 2>&1 ;
	do
		sleep 0.5
	done

	# delete the first line
	sed -e '1d' -i $matchlist
	sed -e '1d' -i $availablehosts
	touch $HOME/running-$host
	echo "$group_name $opponent_name $match_number" > $HOME/running-$host
	rm -f $lockfile

	#
	# run the game at the remote host
	#
	#echo "start @$host: $opponent_name, $match_number"
	ssh -f $host "/home/robocup/rcgamestats2/scripts/remote_run_match.sh $group_name $opponent_name $match_number"
	sleep 0.1
done

rm_runfile
