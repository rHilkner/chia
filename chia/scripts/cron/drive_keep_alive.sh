#!/bin/bash

# crontab -e
# * * * * * bash /home/cripto-hilkner/chia/scripts/cron/drive_keep_alive.sh > /home/cripto-hilkner/chia/logs/cron/drive_keep_alive/drive_keep_alive_$(date +'\%Y-\%m-\%d_\%H_\%M_\%S').log

log() { echo "[$(date)] $1" ; }

# Setting script directory as work directory
cd "$(dirname "${BASH_SOURCE[0]}")"

touch drive_keep_alive.itmp
base_dir="/media/cripto-hilkner"
for drive_dir in $(ls ${base_dir}); do
  log "Keeping alive drive ${base_dir}/${drive_dir}"
  cp drive_keep_alive.itmp "${base_dir}/${drive_dir}/drive_keep_alive.itmp"
  rm "${base_dir}/${drive_dir}/drive_keep_alive.itmp"
done
rm drive_keep_alive.itmp
