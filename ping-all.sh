#!/bin/sh

count=0
for i in `cat available-hosts.tmpl`; do
    count=`expr $count + 1`
    if ! ping -c 1 -W 1 $i > /dev/null 2>&1; then
	echo "$count: $i ... Unavailable"
    else
	echo "$count: $i ... Ok"
    fi
done
