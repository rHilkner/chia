set -e

file=$1
dir=$2
filename=$(basename -- "${file}")
cp ${file} "${dir}/${filename}.itmp"
mv "${dir}/${filename}.itmp" "${dir}/${filename}"
rm ${file}
