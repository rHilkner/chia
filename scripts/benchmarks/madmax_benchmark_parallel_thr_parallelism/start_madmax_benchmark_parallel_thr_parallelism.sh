#!/bin/bash

# Setting script directory as work directory
cd "$(dirname "${BASH_SOURCE[0]}")"

letsplot_log_file=/home/cripto-hilkner/chia/logs/madmax/benchmarks/madmax_benchmark_parallel_thr_parallelism_$(date +'%Y-%m-%d_%H_%M_%S').log
echo "[$(date)] Starting madmax_benchmark_parallel_thr_parallelism.sh: ${letsplot_log_file}"
nohup bash madmax_benchmark_parallel_thr_parallelism.sh > ${letsplot_log_file} 2>&1 &
