#!/bin/bash

if [ $# -eq 0 ]; then
 threshold=10
else
 threshold=$1
fi

while true; do
 free_space=$(df -h --output=avail / | sed 1d | awk '{print $1}')

 if [[ ${free_space#0} < ${threshold#0} ]]; then
 echo "warning: free disk space is below $threshold GB"
 fi

 sleep 10
done
