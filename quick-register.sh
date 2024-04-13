#!/bin/sh

tag=
if [ $# -lt 1 ]; then
	echo "$0 TAG"
	exit 1
fi
tag=$1

num=500

#./register_group.sh yushan2022 $num $tag
./register_group.sh cyrus2021 $num $tag
#./register_group.sh pyrus2022 $num $tag
#./register_group.sh alice2021 $num $tag
#./register_group.sh opuham2021 $num $tag
#./register_group.sh hts2021 $num $tag

