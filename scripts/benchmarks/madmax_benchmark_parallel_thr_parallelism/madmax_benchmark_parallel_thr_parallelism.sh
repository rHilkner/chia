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

drive_name=$(bash ~/chia/scripts/utils/get_drive_name.sh)
plotdir_array=("/mnt/${drive_name}_0/chia_plots/"
               "/mnt/${drive_name}_1/chia_plots/"
               "/mnt/${drive_name}_2/chia_plots/"
               "/mnt/${drive_name}_3/chia_plots/")
bkt=64
parallelism_array=(4 3 2)
thr_array=(8 10 16)
pid_array=()

for i in {0..2}; do
  parallelism=${parallelism_array[$i]}
  thr=${thr_array[$i]}
  log "Starting to plot with parallelism degree of ${parallelism} and ${thr} threads"
  initial_time=$(date +%s)
  for proc in $(seq 1 ${parallelism}); do
    plotdir=${plotdir_array[proc-1]}
    plot_log_file="/home/cripto-hilkner/chia/logs/madmax/plots/madmax_$(date +'%Y-%m-%d_%H_%M_%S')_thr${thr}parallel${parallelism}plot${proc}.log"
    log "- Plot ${proc}: nohup /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -r ${thr} -u ${bkt} -t ${plotdir} -d ${plotdir} -f ${farmer_key} -p ${pool_key} > ${plot_log_file} 2>&1 &"
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

  log "All plots with parallelism degree of ${parallelism} have finished"
  echo;echo;

done

log "End of execution"
