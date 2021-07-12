set -e

log() { echo "[$(date)] $1" ; }

file=$1
dir=$2
filename=$(basename -- "${file}")

log "Saving file [${file}] on directory [${dir}]"

cp ${file} "${dir}/${filename}.itmp"
mv "${dir}/${filename}.itmp" "${dir}/${filename}"
rm ${file}

log "Finished saving [${file}] on directory [${dir}]"
