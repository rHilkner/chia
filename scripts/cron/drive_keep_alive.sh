# crontab -e
# * * * * * bash /home/cripto-hilkner/chia/scripts/cron/drive_keep_alive.sh

# Setting script directory as work directory
cd "$(dirname "${BASH_SOURCE[0]}")"

touch drive_keep_alive.itmp
base_dir="/media/cripto-hilkner"
for drive_dir in $(ls ${base_dir}); do
  cp drive_keep_alive.itmp "${base_dir}/${drive_dir}/drive_keep_alive.itmp"
  rm "${base_dir}/${drive_dir}/drive_keep_alive.itmp"
done
rm drive_keep_alive.itmp
