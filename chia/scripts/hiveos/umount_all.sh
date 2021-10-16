log() { echo "[$(date)] $1" ; }; for dir in $(df | grep "/media" | awk '{print $1}'); do log "Umount'ing ${dir}"; sudo umount ${dir}; done; rmdir /media/cripto-hilkner/*
