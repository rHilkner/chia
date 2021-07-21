log() { echo "[$(date)] $1" ; }

for dir in $(df | grep "/media" | awk '{print $1}'); do
  log "Umount'ing ${dir}"
  cat ~/chia/scripts/utils/get_pw.txt | sudo -S umount ${dir}
  cat ~/chia/scripts/utils/get_pw.txt | sudo -S rmdir ${dir}
done
