cd ~/chia/chia-blockchain
. ./activate
chia init
chia start farmer

for d in /media/cripto-hilkner/*; do
  chia plots add -d ${d}
done;
