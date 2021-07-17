#!/bin/bash

log() { echo "[$(date)] $1" ; }

. ~/chia/chia-blockchain/activate

for dir in $(chia plots show | grep "/media"); do
  chia plots remove -d ${dir}
done