#!/bin/bash

# Setting script directory as work directory
cd "$(dirname "${BASH_SOURCE[0]}")"

saveplots_log_file=/home/cripto-hilkner/chia/logs/madmax/benchmarks/save_plots_single_dir_$(date +'%Y-%m-%d_%H_%M_%S').log
echo "[$(date)] Starting save_plots_single_dir.sh: ${saveplots_log_file}"
nohup bash save_plots_single_dir.sh > ${saveplots_log_file} 2>&1 &
