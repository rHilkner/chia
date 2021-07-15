#!/bin/bash

# crontab -e
# * * * * * bash /home/cripto-hilkner/chia/scripts/cron/automount.sh > /home/cripto-hilkner/chia/scripts/cron/logs/automount_$(date +'%Y-%m-%d_%H_%M_%S').log

log() { echo "[$(date)] $1" ; }

for partition in $(ls /dev/sd**{1,2}* 2> /dev/null); do
  file_name=$(basename -- "${partition}")
  file_path="/media/cripto-hilkner/${file_name}"

  # only mount partition if it's not yet mounted
  if [[ -z $(df | grep ${partition}) ]]; then
    # echo 1q2w3e | sudo -S echo ${partition}
    # echo 1q2w3e | sudo -S echo ${file_path}
    log "mount -t ntfs-3g ${partition} ${file_path}"
    echo 1q2w3e | sudo -S mkdir -p ${file_path}
    echo 1q2w3e | sudo -S mount -t ntfs-3g ${partition} ${file_path}
  fi
done
