#!/bin/bash

log() { echo "[$(date)] $1" ; }

# example of use: `array=( $(remove_from_array ${value} ${array[@]}) )`
remove_from_array() {
    value=$1
    shift # shift arguments to the left
    array=($@)
    for (( i=0; i<${#array[@]}; i++ )); do
        if [[ ${array[i]} == ${value} ]]; then
            unset "array[i]"
            break
        fi
    done
    echo "${array[@]}"
}

farmer_key="83afd03a8c9d5a4f688811e66085d35d182b8a9b4b18c6e2bf3be9ec3161267f33f8efcaf6e74a5381f8345e115c2cd1"
pool_key="b960dc5634d5a314af4286aeab75bf78f2452f5abadcfce7e59c864a7a3ce9630297e2f5102577ab02a20991bde162b1"

drive_name=$(bash /home/cripto-hilkner/chia/scripts/utils/get_drive_name.sh)
plotdir_array=("/mnt/${drive_name}_0/chia_plots/"
               "/mnt/${drive_name}_1/chia_plots/"
               "/mnt/${drive_name}_2/chia_plots/"
               "/mnt/${drive_name}_3/chia_plots/")
bkt_array=(64 128 256 512 1024 2048)
parallelism=4
thr=8
pid_array=()

for bkt in ${bkt_array[@]}; do
  log "Starting to plot with bucket size of ${bkt} (${parallelism}x ${thr}thr)"
  initial_time=$(date +%s)
  # Starting many plots in parallel
  for plot in $(seq 1 ${parallelism}); do
    plotdir=${plotdir_array[plot-1]}
    plot_log_file="/home/cripto-hilkner/chia/logs/madmax/plots/madmax_$(date +'%Y-%m-%d_%H_%M_%S')_thr${thr}parallel${parallelism}plot${plot}.log"
    log "- Plot ${plot}: nohup /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -r ${thr} -u ${bkt} -t ${plotdir} -d ${plotdir} -f ${farmer_key} -p ${pool_key} > ${plot_log_file} 2>&1 &"
    nohup /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -r ${thr} -u ${bkt} -t ${plotdir} -d ${plotdir} -f ${farmer_key} -p ${pool_key} > ${plot_log_file} 2>&1 &
    pid_array+=($!)
  done

  while (( ${#pid_array[@]} > 0 )); do
    echo -n "."
    sleep 10
    for pid in ${pid_array[@]}; do
      if ! ps -p ${pid} > /dev/null; then
        final_time=$(date +%s)
        log "- One of the plots just finished with total time of: $((final_time-initial_time)) seconds"
        pid_array=( $(remove_from_array ${pid} ${pid_array[@]}) )
        break
      fi
    done
  done

  log "All plots with bucket size of ${bkt} have finished"
  echo;echo;

done

log "End of execution"
