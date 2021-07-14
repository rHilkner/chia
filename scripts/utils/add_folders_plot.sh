cd ~/chia/chia-blockchain
. ./activate
chia init
chia start farmer

for dir in /media/cripto-hilkner/*; do
  dir_name=$(echo "${dir}/" | sed 's/ /\\ /g')
  echo "Adding dir ${dir_name}" 
  chia plots add -d "${dir_name}"
done
