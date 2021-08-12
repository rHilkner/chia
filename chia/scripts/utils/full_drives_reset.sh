#!/bin/bash

# crontab -e
# 0 * * * * bash /home/cripto-hilkner/chia/scripts/cron/rebind_xhci_driver.sh > /home/cripto-hilkner/chia/logs/cron/rebind_xhci_driver/rebind_xhci_driver_$(date +'\%Y-\%m-\%d_\%H_\%M_\%S').log 2>&1

log() { echo "[$(date)] $1" ; }

# granting sudo privileges
cat /home/cripto-hilkner/chia/scripts/utils/get_pw.txt | sudo -S cd .

log "Full drives reset: Going to unmount all drives, unbind+bind all pci drivers, unmount+mount all drives and then remove+add all drives to chia farm"
echo "---"
log "Unmounting all drives"
bash /home/cripto-hilkner/chia/scripts/utils/umount_all.sh
echo "---"

# source: https://tomlankhorst.nl/unresponsive-usb-unbind-bind-linux
# .. this have been tested and it's the solution to an intermitent drives that start...
# ... giving 'Input/Output error' after a while connected
log "Unbinding + binding all XHCI drivers"

for driver in /sys/bus/pci/drivers/xhci_hcd/*:*; do
  driver_basename=$(basename -- ${driver})
  log "${driver}"
  log "echo ${driver_basename} | sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind"
  echo ${driver_basename} | sudo tee /sys/bus/pci/drivers/xhci_hcd/unbind
  sleep 1
  log "echo ${driver_basename} | sudo tee /sys/bus/pci/drivers/xhci_hcd/bind"
  echo ${driver_basename} | sudo tee /sys/bus/pci/drivers/xhci_hcd/bind
done


echo "---"
sleep 15
log "Unmounting all drives again"
bash /home/cripto-hilkner/chia/scripts/utils/umount_all.sh
echo "---"
log "Mounting all drives"
bash /home/cripto-hilkner/chia/scripts/utils/automount.sh
echo "---"
log "Removing old drives from chia farm"
bash /home/cripto-hilkner/chia/scripts/utils/remove_folders_plot.sh
echo "---"
log "Adding all drives to chia farm"
bash /home/cripto-hilkner/chia/scripts/utils/add_folders_plot.sh

log "End of execution"
