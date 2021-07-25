#!/bin/bash

log() { echo "[$(date)] $1" ; }

cat /home/cripto-hilkner/chia/scripts/utils/get_pw.txt | sudo -S chmod a+rwx -R /media

i=0
j=1

partitions=( $(ls /dev/sd**{1,2}* 2> /dev/null) )
echo "There are ${#partitions[@]} partitions"
while (( i < ${#partitions[@]} )); do
  partition=${partitions[i]}
  #file_path="/media/cripto-hilkner/hd${j}"
  file_path="/media/cripto-hilkner/hd${j}"
  # only mount partition if it's not yet mounted
  if [[ ! -z $(df | grep -w ${partition}) ]]; then
    log "Partition ${partition} already mounted"
    ((i++))
  elif [[ ! -z $(df | grep -w ${file_path}) ]]; then
    log "Drive name ${file_path} already exist"
    ((j++))
  else
    log "mount -t ntfs-3g ${partition} ${file_path}"
    cat /home/cripto-hilkner/chia/scripts/utils/get_pw.txt | sudo -S mkdir -p ${file_path}
    cat /home/cripto-hilkner/chia/scripts/utils/get_pw.txt | sudo -S mount -t ntfs-3g ${partition} ${file_path}
    exit_code=$?
    if (( exit_code == 0 )); then
      ((i++))
      ((j++))
    else
      ((i++))
      cat /home/cripto-hilkner/chia/scripts/utils/get_pw.txt | sudo -S rmdir ${file_path}
      log "----- ERROR MOUNTING ${partition} with EXIT_CODE ${exit_code} -----"
    fi
  fi
done
