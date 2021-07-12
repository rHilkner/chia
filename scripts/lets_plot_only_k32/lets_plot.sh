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

# example of use: `array=( $(remove_from_array_idx ${index} "${array[@]}") )`
remove_from_array_idx() {
  idx=$1
  shift # shift arguments to the left
  array=($@)
  unset "array[i]"
  echo "${array[@]}"
}

# machine and chia variables/parameters
farmer_key="83afd03a8c9d5a4f688811e66085d35d182b8a9b4b18c6e2bf3be9ec3161267f33f8efcaf6e74a5381f8345e115c2cd1"
pool_key="b960dc5634d5a314af4286aeab75bf78f2452f5abadcfce7e59c864a7a3ce9630297e2f5102577ab02a20991bde162b1"
drive_name=$(bash ~/chia/scripts/utils/get_drive_name.sh)
plotdir_array=("/mnt/${drive_name}_0/chia_plots/"
               "/mnt/${drive_name}_1/chia_plots/"
               "/mnt/${drive_name}_2/chia_plots/"
               "/mnt/${drive_name}_3/chia_plots/")
parallelism=4
thr=8
bkt=1024
first_run_delay=18 # in minutes

# script parameters
pid_array=()
start_time_array=()
first_run="true"
plotdir_idx=0

log "Starting to plot with parallelism of ${parallelism} using ${thr} threads and ${bkt} buckets. First run delay of ${first_run_delay} minutes. Plots will be made on directories below:"
printf ' - %s\n' "${plotdir_array[@]}"

while true; do
  # Starting many plots in parallel
  while (( ${#pid_array[@]} < parallelism )); do
    plotdir=${plotdir_array[plotdir_idx]}
    plotdir_idx=$(( (plotdir_idx+1) % parallelism ))
    plot_log_file="/home/cripto-hilkner/chia/logs/madmax/plots/madmax_$(date +'%Y-%m-%d_%H_%M_%S').log"
    log "Starting plot: nohup /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -r ${thr} -u ${bkt} -t ${plotdir} -d ${plotdir} -f ${farmer_key} -p ${pool_key} > ${plot_log_file} 2>&1 &"
    nohup /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -r ${thr} -u ${bkt} -t ${plotdir} -d ${plotdir} -f ${farmer_key} -p ${pool_key} > ${plot_log_file} 2>&1 &
    pid_array+=($!)
    start_time_array+=( $(date +%s) )
    if ${first_run}; then
      log "First run: applying delay between plots of ${first_run_delay} minutes"
      sleep $(( 60*${first_run_delay} ))
    fi
  done

  first_run="false"

  log "Waiting until a plot finishes"

  while (( ${#pid_array[@]} >= parallelism )); do
    for (( i = 0; i < ${#pid_array[@]}; i++ )); do
      pid=${pid_array[i]}
      if ! ps -p ${pid} > /dev/null; then
        start_time=${start_time_array[i]}
        end_time=$(date +%s)
        log "One plot just finished with total time of: $((end_time-start_time)) seconds"
        pid_array=( $(remove_from_array_idx ${i} ${pid_array[@]}) )
        start_time_array=( $(remove_from_array_idx ${i} ${start_time_array[@]}) )
        break
      fi
    done

    # if no plots finished above, sleep 10 seconds
    if (( ${#pid_array[@]} >= parallelism )); then
      echo -n "."
      sleep 10
    fi
  done

  echo;

  log "DEBUG: pid_array"
  printf ' - %s\n' "${pid_array[@]}"

done

log "End of execution"
