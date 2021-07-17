for dir in $(chia plots show | grep "/media"); do
  chia plots remove -d ${dir}
done