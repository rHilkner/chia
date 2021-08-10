#!/bin/bash

# Setting script directory as work directory
cd "$(dirname "${BASH_SOURCE[0]}")"

letsplot_log_file=/home/cripto-hilkner/chia/logs/madmax/scripts/lets_plot_$(date +'%Y-%m-%d_%H_%M_%S').log
echo "[$(date)] Starting lets_plot.sh: ${letsplot_log_file}"
nohup bash lets_plot.sh > ${letsplot_log_file} 2>&1 &
