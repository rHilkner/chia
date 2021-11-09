cd /media/cripto-hilkner
hd_folders=( $(ls) )
for folder in ${hd_folders[@]}; do
    og_plots=( $(ls ${folder} | grep 'plot-k32-2021-07-0') )
    og_plots+=( $(ls ${folder} | grep 'plot-k32-2021-06') )
    og_plots+=( $(ls ${folder} | grep 'plot-k32-2021-05') )
    if (( ! ${#og_plots[@]} )); then
        echo $folder: ${#og_plots[@]}
    fi
done | sort
