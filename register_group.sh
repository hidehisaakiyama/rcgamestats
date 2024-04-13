#!/bin/sh

. $HOME/rcgamestats/config

if [ $# -lt 2 ]; then
	echo "Usage:"
	echo "  $0 <opponent name> <# of match> [<group tag>]"
	echo ""
	echo "Available teams:"
	cat $HOME/rcgamestats/teamlist
	exit 1
fi

opponent_name=$1
nr_match=$2
group_tag=""

if [ $# -ge 3 ]; then
	group_tag=$3
fi

if [ $nr_match -lt 1 ]; then
	echo "# of match has to be more than zero."
	exit 1
fi

if [ $((nr_match % result_saver_block_size)) -ne 0 ]; then
	echo "# of match has to be ${result_saver_block_size}*N."
	exit 1
fi

#
# check opponent availability
#
opponent_info=`grep "^${opponent_name}," $teamlist`
if [ -z $opponent_info ]; then
	echo "[$opponent_name]: not listed"
	exit 1
fi

opponent_path=`echo $opponent_info | cut -d , -f 3`
if [ ! -d $opponent_path ]; then
	echo "[$opponent_name]: no path"
	exit 1
fi

#
# append match list
#
while ! ln -s $$ $lockfile > /dev/null 2>&1 ;
do
	echo "exist lock file. wait for a while..."
	sleep 0.5
done

#group_name=`date +%Y%m%d%H%M%S`
datetime=`date +%Y%m%d-%H%M%S`
group_name=`echo $datetime | cut -c5-13`
#group_name=`date +%m%d-%H%M`
if [ -n "$group_tag" ]; then
	group_name="${group_name}-${group_tag}"
	echo "group_name= $group_name"
fi
sheet_name="${group_name}-${opponent_name}"

path=`dirname $0`
#python3 $path/scripts/create_sheet.py $sheet_name
python3 $path/scripts/create_sheet.py $sheet_name $datetime $opponent_name $group_tag


for i in `seq 1 $nr_match` ; do
	echo "${group_name},${opponent_name},${i}" >> $matchlist
done

rm -f $lockfile
