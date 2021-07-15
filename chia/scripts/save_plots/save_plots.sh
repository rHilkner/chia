#!/bin/bash

set -e

log() { echo "[$(date)] $1" ; }

is_element_in_array() {
  is_element_in_array="false"
  element=$1
  shift # shift arguments to the left
  array=($@)
  for value in ${array[@]}; do
    if [[ ${element} == ${value} ]]; then
      is_element_in_array="true"
      break
    fi
  done
  echo ${is_element_in_array}
}

# example of use: `index=$(get_index ${value} ${array[@]})`
get_index() {
  element=$1
  shift # shift arguments to the left
  array=($@)
  for i in ${!array[@]}; do
    if [[ "${my_array[$i]}" = "${value}" ]]; then
      echo $i
      break
    fi
  done
}

# example of use: `array=( $(remove_from_array_idx ${index} ${array[@]}) )`
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

# example of use: `array=( $(remove_from_array ${value} ${array[@]}) )`
remove_from_array_idx() {
  idx=$1
  shift # shift arguments to the left
  array=($@)
  unset "array[i]"
  echo "${array[@]}"
}

# returns a source file (plot) that is not yet being copied to some destination directory (not in copying_from array)
get_src_file() {
  # gets all files that are in the source_patterns
  src_files=()
  for src_pattern in ${src_array[@]}; do
    src_files_aux=( $(ls ${src_pattern} 2> /dev/null) )
    if [[ ! -z ${src_files_aux[0]} ]]; then
      src_files+=( ${src_files_aux[@]} )
    fi
  done
  # remove files that are in copying_from array
  for file in ${copying_from[@]}; do
    src_files=( $(remove_from_array ${file} ${src_files[@]}) )
  done
  # return only first file of the list of files (or none if there is none)
  if (( ${#src_files[@]} > 0 )); then
    echo "${src_files[0]}"
  fi
}

# returns a destination directory that has available space (greater than source file given as $1) and is not currently busy (not in copying_to array)
get_dest_dir() {
  src_file=$1
  # for each dest_dir from dest_array
  for dir in ${dest_array[@]}; do
    # if it is busy (in copying_to array), continue
    if $(is_element_in_array ${dir} ${copying_to[@]}); then
      continue
    fi
    filesize=$(stat -c%s "${src_file}")
    free_space_dir_in_kb=$(df | grep -w ${dir} | awk '{print $4}')
    free_space_dir="$((free_space_dir_in_kb*1024))"
    # if it don't have enough space (greater than src_file), continue
    if (( ${free_space_dir} < ${filesize} )); then
      continue
    fi
    # if the file is k32 and there are >= 12 files k32 already saved, continue
    # or if if the file is k33 and there are >= 12 files k33 already saved, continue
    # else return $dir
    count_k32=$(ls ${dir} | grep "k32" | wc -l)
    count_k33=$(ls ${dir} | grep "k33" | wc -l)
    if (( ${src_file} == *"k32"* && count_k32 >= 12 )) || (( ${src_file} == *"k33"* && count_k33 >= 12 )); then
      continue
    fi
    # return directory that is available and has no more than 12 k32 + 12 k33
    echo "${dir}"
    break
  done
}

# async (nohup) saves (cp + rm) file in $1 to directory in $2 and adds them to copying_from/copying_to/copying_pids arrays
save_file_to_dir() {
  file=$1
  dir=$2
  # nohup call another subscript that has cp+rm commands
  nohup bash save_file_to_dir.sh ${file} ${dir} > /home/cripto-hilkner/chia/logs/madmax/saves/save_file_to_dir_$(date +'%Y-%m-%d_%H_%M_%S').log 2>&1 &
  pid=$!
  copying_from+=(${file})
  copying_to+=(${dir})
  copying_pids+=(${pid})
  copying_start_times+=( $(date +%s) )
  log "PID ${pid}: file [${file}] started saving to [${dir}]"
}

# checks for copies that already finished and removes them from copying_from, copying_to, copying_pids arrays
check_done_copies() {
  last_idx=$(( ${#copying_pids[@]}-1 ))
  # going from last index to 0, with -1 increment
  for i in $(seq ${last_idx} -1 0); do
    pid=${copying_pids[$i]}
    if ! ps -p ${pid} > /dev/null; then
      start_time=${copying_start_times[i]}
      end_time=$(date +%s)
      total_time=$((end_time-start_time))
      if ((total_time < 30)); then
        log "PID ${copying_pids[i]}: file [${copying_from[i]}] copying to [${copying_to[i]}] seems to have failed, since it finished the copy in ${total_time} seconds. Unmounting desination folder [${copying_to}]."
        filesystem_name=$(df | grep "${copying_to}" | awk '{print $1}')
        cat ~/chia/scripts/utils/get_pw.txt | sudo -S umount ${filesystem_name}
        avoid_list+=(${filesystem_name})
      else
        log "PID ${copying_pids[i]}: file [${copying_from[i]}] finished saving to [${copying_to[i]}] in ${total_time} seconds"
      fi
      copying_from=( $(remove_from_array_idx ${i} ${copying_from[@]}) )
      copying_to=( $(remove_from_array_idx ${i} ${copying_to[@]}) )
      copying_pids=( $(remove_from_array_idx ${i} ${copying_pids[@]}) )
      copying_start_times=( $(remove_from_array_idx ${i} ${copying_start_times[@]}) )
    fi
  done
}

drive_name=$(bash ~/chia/scripts/utils/get_drive_name.sh)
src_array=("/mnt/crucial_0/chia_plots/*.plot"
           "/mnt/crucial_1/chia_plots/*.plot"
           "/mnt/${drive_name}_0/chia_plots/*.plot"
           "/mnt/${drive_name}_1/chia_plots/*.plot"
           "/mnt/${drive_name}_2/chia_plots/*.plot"
           "/mnt/${drive_name}_3/chia_plots/*.plot")

# adding all possible names of destination drives/directories
dest_array=( $(df | grep "/media/cripto-hilkner" | awk 'NF>1{print $NF}') )
# creating needed arrays
copying_from=()
copying_to=()
copying_pids=()
copying_start_times=()
avoid_list=()

log "Copying plots from sources:"
printf ' - %s\n' "${src_array[@]}"
log "Saving plots in destinations:"
printf ' - %s\n' "${dest_array[@]}"
echo;

while true; do
  # wait until there is a source file to be saved
  src_file=$(get_src_file)
  if [[ -z ${src_file} ]]; then
    log "Waiting for a plot to finish"
  fi
  while [[ -z ${src_file} ]]; do
    check_done_copies
    echo -n "."
    sleep 10
    src_file=$(get_src_file)
  done

  echo;

  # now that we have a source file, let's copy this file to any destination directory
  # let's get any available destination directory or wait until there is any
  check_done_copies
  dest_dir=$(get_dest_dir ${src_file})
  if [[ -z ${dest_dir} ]]; then
    log "All destination directories are busy or full, waiting for any destination to be available"
  fi
  while [[ -z ${dest_dir} ]]; do
    echo -n "."
    sleep 10
    check_done_copies
    dest_dir=$(get_dest_dir ${src_file})
  done

  echo;

  # now lets save source_file to destination_directory
  save_file_to_dir ${src_file} ${dest_dir}

  log "DEBUG: copying_from"
  printf ' - %s\n' "${copying_from[@]}"

  log "DEBUG: copying_to"
  printf ' - %s\n' "${copying_to[@]}"

  log "DEBUG: copying_pids"
  printf ' - %s\n' "${copying_pids[@]}"

  log "DEBUG: avoid_list"
  printf ' - %s\n' "${avoid_list[@]}"

done
