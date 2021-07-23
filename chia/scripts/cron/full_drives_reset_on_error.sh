#!/bin/bash

# crontab -e
# 0 * * * * bash /home/cripto-hilkner/chia/scripts/cron/rebind_xhci_driver.sh > /home/cripto-hilkner/chia/logs/cron/rebind_xhci_driver/rebind_xhci_driver_$(date +'\%Y-\%m-\%d_\%H_\%M_\%S').log 2>&1

log() { echo "[$(date)] $1" ; }

cat ~/chia/scripts/utils/get_pw.txt | sudo -S cd .

error_hds=()

for dir in /media/cripto-hilkner/*; do
  ls ${dir} > /dev/null 2>&1 || error_hds+=( ${dir} )
done

if [[ -z ${error_hds} ]]; then
  log "No errors, not rebinding drivers"
  exit 0
else
  log "Errors found in drives:"
  printf ' - %s\n' "${error_hds[@]}"
  echo "---"
  log "Full reseting all drives..."
  bash ~/chia/scripts/utils/full_drives_reset.sh
  echo "---"
fi
