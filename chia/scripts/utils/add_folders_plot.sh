#!/bin/bash

log() { echo "[$(date)] $1" ; }

log "---------- CHIA ----------"

. /home/cripto-hilkner/chia/chia-blockchain/activate
chia init
chia start farmer

echo; echo "---------------------------------------"; echo

for dir in /media/cripto-hilkner/*; do
#for dir in /media/cripto-hilkner/*; do
  echo "Adding dir ${dir}"
  chia plots add -d "${dir}"
done

echo; echo "---------------------------------------"; echo

chia plots show
deactivate

echo; echo "---------------------------------------"; echo

log "---------- FLAX ----------"

. /home/cripto-hilkner/chia/flax-blockchain/activate
flax init
flax start farmer

echo; echo "---------------------------------------"; echo

for dir in /media/cripto-hilkner/*; do
#for dir in /media/cripto-hilkner/*; do
  echo "Adding dir ${dir}"
  flax plots add -d "${dir}"
done

echo; echo "---------------------------------------"; echo

flax plots show
deactivate

echo; echo "---------------------------------------"; echo
