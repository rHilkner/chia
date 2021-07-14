. ~/chia/chia-blockchain/activate
chia init
chia start farmer

echo
echo "---------------------------------------"
echo

for dir in /media/cripto-hilkner/*; do
#for dir in /media/chia-storage/*; do
  dir_name=$(echo "${dir}/" | sed 's/ /\\ /g')
  echo "Adding dir ${dir_name}" 
  chia plots add -d "${dir_name}"
done

echo
echo "---------------------------------------"
echo

chia plots show