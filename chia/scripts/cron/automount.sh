# crontab -e
# * * * * * bash /home/cripto-hilkner/chia/scripts/cron/automount.sh > /home/cripto-hilkner/chia/scripts/cron/logs/automount_$(date +'%Y-%m-%d_%H_%M_%S').log

# Remember to do this below before executing the script:
# sudo chmod a+rwx /usr/share/polkit-1/actions/org.freedesktop.UDisks2.policy
# vim /usr/share/polkit-1/actions/org.freedesktop.UDisks2.policy
#
# lines 9, 93, 168
# under `org.freedesktop.udisks2.filesystem-mount`
# ..    `org.freedesktop.udisks2.filesystem-mount-system`
# ..    `org.freedesktop.udisks2.filesystem-mount-other-seat`
# .. change last part of block to be like this:
#    <defaults>
#      <allow_any>yes</allow_any>
#      <allow_inactive>yes</allow_inactive>
#      <allow_active>yes</allow_active>
#    </defaults>

for partition in $(ls /dev/sd**{1,2}* 2> /dev/null); do
	udisksctl mount -b ${partition}
done
