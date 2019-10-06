#!/bin/bash

#Script coded by Berk Eroglu on 09/23/2019
#Last Update on 09/25/2019

#Don't use this script with ksm and ksmtuned
#Variable that you can change in MiB PROCESS_MEMORY_AT
PROCESS_MEMORY_AT=10000

if [[ ! -f "/usr/local/auto-balloon.bash" ]] 
then
   CURRENT_PATH=$($0)
   mv "$CURRENT_PATH/auto-balloon.bash" /usr/local/
   cat <(crontab -l) <(echo "* * * * * bash /usr/local/auto-balloon.bash") | crontab -
fi

if [[ -f "/usr/local/auto-balloon.bash" ]]
then
   TOTAL_VM=$(virsh list --state-running | grep . -c)    
   AVAILABLE_MEM=$(awk '/^Mem/ {print $7}' <(free -m))
   IN_USE_MEM=$(awk '/^Mem/ {print $3}' <(free -m))
   MEMORY_PER_VM=$(($IN_USE_MEM/$TOTAL_VM))
else
   if [[ $AVAILABLE_MEM < $PROCESS_MEMORY_AT ]]
   then
      DEFLATE_MEMORY_PER_VM=$(($PROCESS_MEMORY_AT - $AVAILABLE_MEM))/$(($TOTAL_VM))
      for i in `virsh list --all|awk '{print $2}'|grep -v Name`; do virsh setmem $i $(($MEMORY_PER_VM * 1000 - $DEFLATE_MEMORY_PER_VM * 1000)); done
   fi
fi
