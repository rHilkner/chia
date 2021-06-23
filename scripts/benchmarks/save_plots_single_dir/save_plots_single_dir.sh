#!/bin/bash

log() { echo "[$(date)] $1" ; }

drive_name=$(bash ~/chia/scripts/utils/get_drive_name.sh)
source_pattern="/mnt/${drive_name}/chia_plots/*.plot"
final_dir="/media/cripto-hilkner/Elements/"

log "Observing plots with source pattern [${source_pattern}] to save on final directory [${final_dir}]"

while true; do
  if ls ${source_pattern} 2> /dev/null ; then
    log "Moving file $(ls ${source_pattern}) above to ${final_dir}"
    initial_time=$(date +%s)
    cp ${source_pattern} ${final_dir}
    rm ${source_pattern}
    final_time=$(date +%s)
    log "File moved successfully in $((final_time-initial_time)) seconds"
  else
    echo -n "."
    sleep 10
  fi
done;
