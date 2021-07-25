#!/bin/bash

# crontab -e
# 0 0 * * * bash /home/cripto-hilkner/chia/scripts/cron/maintenance.sh >> /home/cripto-hilkner/chia/logs/cron/maintenance/maintenance.log 2>&1

log() { echo "[$(date)] $1" ; }

log "Starting new maintenance job"

# Deleting log files with size 0
for drive_keep_alive_log_file in $(ls /home/cripto-hilkner/chia/logs/cron/drive_keep_alive/drive_keep_alive_*.log); do
  filesize=$(stat -c%s "${drive_keep_alive_log_file}")
  if ((filesize == 0)); then
    echo "Deleting file ${drive_keep_alive_log_file} with size ${filesize}"
    rm ${drive_keep_alive_log_file}
  fi
done

echo
echo "--------------------------------------------------------------------------"
echo
