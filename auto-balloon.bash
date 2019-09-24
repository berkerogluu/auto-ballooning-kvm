#!/bin/bash

#Script coded by Berk Eroglu on 09/23/2019
#Last Update on 09/23/2019

#Variables that you can change in MiB

PROCESS_MEMORY_AT=10000

TOTAL_VM=$(virsh list --state-running | grep . -c)    
AVAILABLE_MEM=$(awk '/^Mem/ {print $7}' <(free -m))
IN_USE_MEM=$(awk '/^Mem/ {print $3}' <(free -m))
MEMORY_PER_VM=$(($IN_USE_MEM/$TOTAL_VM))

if [[ $AVAILABLE_MEM -lt $PROCESS_MEMORY_AT ]]
then
   DEFLATE_MEMORY_PER_VM=$(($PROCESS_MEMORY_AT - $AVAILABLE_MEM))/$(($TOTAL_VM))
   for i in `virsh list --all|awk '{print $2}'|grep -v Name`; do virsh setmem $i $(($MEMORY_PER_VM * 1000 - $DEFLATE_MEMORY_PER_VM * 1000)); done
fi
