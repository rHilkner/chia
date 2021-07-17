#!/bin/bash

log() { echo "[$(date)] $1" ; }

. ~/chia/chia-blockchain/activate

for dir in $(chia plots show | grep "/media"); do
  chia plots remove -d ${dir}
done

. ~/chia/flax-blockchain/activate

for dir in $(flax plots show | grep "/media"); do
  flax plots remove -d ${dir}
done