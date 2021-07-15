#!/bin/bash

log() { echo "[$(date)] $1" ; }

farmer_key="83afd03a8c9d5a4f688811e66085d35d182b8a9b4b18c6e2bf3be9ec3161267f33f8efcaf6e74a5381f8345e115c2cd1"
pool_key="b960dc5634d5a314af4286aeab75bf78f2452f5abadcfce7e59c864a7a3ce9630297e2f5102577ab02a20991bde162b1"

drive_name=$(bash ~/chia/scripts/utils/get_drive_name.sh)
tmpdir="/mnt/${drive_name}_0/chia_plots/"
finaldir="/mnt/${drive_name}_0/chia_plots/"
thr_array=(8 10 12 16)
bkt_array=(64 128 256 512)
count=0

for thr in ${thr_array[@]}; do
  for bkt in ${bkt_array[@]}; do
    ((count++))
    initial_time=$(date +%s)
    log "Starting plot ${count}: threads = ${thr} / buckets = ${bkt}"
    plot_log_file="/home/cripto-hilkner/chia/logs/madmax/plots/madmax_$(date +'%Y-%m-%d_%H_%M_%S')_thr${thr}bkt${bkt}.log"
    log "/home/cripto-hilkner/chia/chia-plotter/build/chia_plot -r ${thr} -u ${bkt} -t ${tmpdir} -d ${finaldir} -f ${farmer_key} -p ${pool_key} > ${plot_log_file}"
    /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -r ${thr} -u ${bkt} -t ${tmpdir} -d ${finaldir} -f ${farmer_key} -p ${pool_key} > ${plot_log_file}
    final_time=$(date +%s)
    log "Finished plot ${count} in $((final_time-initial_time)) seconds"
    echo;echo;
  done;
done;
