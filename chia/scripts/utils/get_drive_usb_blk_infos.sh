get_usb_dir() {
  error_blk=$(basename -- $1)
  error_blk=${error_blk::-1}
  for usb_dir in /sys/bus/usb/devices/*; do
    blockName=$(ls ${usb_dir}/host*/target*:0:0/*:0:0:0/block/ 2>/dev/null)
    if [[ ${blockName} == ${error_blk} ]]; then
      echo "${usb_dir}"
      break
    fi
  done
}

error_hds=()
error_blks=()
error_usb_dirs=()

for dir in /media/cripto-hilkner/*; do
  ls ${dir} > /dev/null 2>&1 || error_hds+=( ${dir} )
done

for (( i = 0; i < ${#error_hds[@]}; i++ )); do
  error_blks+=( $(df | grep -w ${error_hds[i]} | awk '{print $1}') )
done

for (( i = 0; i < ${#error_blks[@]}; i++ )); do
  error_usb_dirs+=( $(get_usb_dir ${error_blks[i]}) )
done

for (( i = 0; i < ${#error_hds[@]}; i++ )); do
  echo "${error_hds[i]} --- ${error_blks[i]} --- ${error_usb_dirs[i]} --- runtime_status: $(cat ${error_usb_dirs[i]}/power/runtime_status)"
done | sort