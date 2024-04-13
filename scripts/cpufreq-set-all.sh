#!/bin/sh

#NUM=`cpufreq-info | grep analyzing | wc -l`
NUM=`nproc --all`

i=0
while [ $i -lt $NUM ] ; do
  sudo cpufreq-set -c $i -g $@
  i=`expr $i + 1`
done
