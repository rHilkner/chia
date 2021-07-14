#!/bin/bash

log() { echo "[$(date)] $1" ; }

is_element_in_array() {
  is_element_in_array="false"
  element=$1
  shift # shift arguments to the left
  array=($@)
  for value in "${array[@]}"; do
    if [[ ${element} == ${value} ]]; then
      is_element_in_array="true"
      break
    fi
  done
  echo ${is_element_in_array}
}

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

get_plot_dir_idx() {
  for (( i = 0; i < ${#plot_dir_array[@]}; i++ )); do
    if $(is_element_in_array ${plot_dir_array[i]} "${busy_dir_array[@]}"); then
      continue
    fi
  done
}

count_active_processes() {
  count=0
  for pid in ${pid_array[@]}; do
    if (( pid != 0 )); then
      ((count++))
    fi
  done
  echo ${count}
}

# machine and chia variables/parameters
farmer_key="83afd03a8c9d5a4f688811e66085d35d182b8a9b4b18c6e2bf3be9ec3161267f33f8efcaf6e74a5381f8345e115c2cd1"
pool_key="b960dc5634d5a314af4286aeab75bf78f2452f5abadcfce7e59c864a7a3ce9630297e2f5102577ab02a20991bde162b1"
drive_name=$(bash ~/chia/scripts/utils/get_drive_name.sh)
plot_dir_array=("/mnt/crucial_0/chia_plots/"
                "/mnt/crucial_1/chia_plots/"
                "/mnt/${drive_name}_0/chia_plots/"
                "/mnt/${drive_name}_1/chia_plots/"
                "/mnt/${drive_name}_2/chia_plots/"
                "/mnt/${drive_name}_3/chia_plots/")
thr_array=("6" "6" "6" "6" "4" "4")
bkt_array=("1024" "1024" "1024" "1024" "256" "256")
first_run_delay=12 # in minutes

# script parameters
parallelism=${#plot_dir_array[@]}
pid_array=()
start_time_array=()
plotdir_ksize_array=()
first_run="true"
plot_dir_idx=0
for (( i = 0; i <= parallelism; i++ )); do
  # setting one pid for each plot_dir
  pid_array+=(0)
  start_time_array+=(0)
  plotdir_ksize_array+=("32")
done

log "Starting to plot with parallelism of ${parallelism} using ${thr} threads and ${bkt} buckets. First run delay of ${first_run_delay} minutes. Plots will be made on directories below:"
printf ' - %s\n' "${plot_dir_array[@]}"

while true; do

  while (( $(count_active_processes) < parallelism )); do

    dir=${plot_dir_array[plot_dir_idx]}
    ksize=${plotdir_ksize_array[plot_dir_idx]}
    log_file="/home/cripto-hilkner/chia/logs/madmax/plots/madmax_$(date +'%Y-%m-%d_%H_%M_%S').log"
    log "Starting plot: nohup /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -k ${ksize} -r ${thr} -u ${bkt} -t ${dir} -d ${dir} -f ${farmer_key} -p ${pool_key} > ${log_file} 2>&1 &"
    nohup /home/cripto-hilkner/chia/chia-plotter/build/chia_plot -k ${ksize} -r ${thr} -u ${bkt} -t ${dir} -d ${dir} -f ${farmer_key} -p ${pool_key} > ${log_file} 2>&1 &
    busy_dir_array+=( ${dir} )
    pid_array+=($!)
    start_time_array+=( $(date +%s) )

    # Refreshing plots ksize and plot_dir_idx
    if (( plotdir_ksize_array[plot_dir_idx] == "32"  )); then
      plotdir_ksize_array[plot_dir_idx]="33"
    elif (( plotdir_ksize_array[plot_dir_idx] == "33" ))
      plotdir_ksize_array[plot_dir_idx]="32"
    fi
    plot_dir_idx=$(( (plot_dir_idx+1) % parallelism ))

    if ${first_run}; then
      log "First run: applying delay between plots of ${first_run_delay} minutes"
      sleep $(( 60*${first_run_delay} ))
      ((plot_dir_idx++))
    fi
  done

  first_run="false"

  log "Waiting until a plot finishes"

  while (( $(count_active_processes) >= parallelism )); do
    # check if any plot finished
    for (( i = 0; i < ${#pid_array[@]}; i++ )); do

      pid=${pid_array[i]}

      if ! ps -p ${pid} > /dev/null; then
        start_time=${start_time_array[i]}
        end_time=$(date +%s)
        log "One plot just finished with total time of: $((end_time-start_time)) seconds"
        pid_array[i]=0
        start_time_array[i]=0
        plot_dir_idx=i
        break
      fi
    done

    # if no plots finished above, sleep 10 seconds
    if (( $(count_active_processes) >= parallelism )); then
      echo -n "."
      sleep 10
    fi
  done

  echo;

  log "DEBUG: pid_array"
  printf ' - %s\n' "${pid_array[@]}"

done

log "End of execution"
