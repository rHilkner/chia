#!/bin/bash

log() { echo "[$(date)] $1" ; }

log "Removing CHIA folders"

. /home/cripto-hilkner/chia/chia-blockchain/activate

for dir in $(chia plots show | grep "/media"); do
  log "- Removing ${dir}"
  chia plots remove -d ${dir}
done

deactivate

log "Removing FLAX folders"
. /home/cripto-hilkner/chia/flax-blockchain/activate

for dir in $(flax plots show | grep "/media"); do
  log "- Removing ${dir}"
  flax plots remove -d ${dir}
done

deactivate
