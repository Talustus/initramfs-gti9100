#!/sbin/busybox sh

mkdir /data/.dream
chmod 777 /data/.dream
[ ! -f /data/.dream/default.profile ] && cp /res/customconfig/default.profile /data/.dream
[ ! -f /data/.dream/battery.profile ] && cp /res/customconfig/battery.profile /data/.dream
[ ! -f /data/.dream/performance.profile ] && cp /res/customconfig/performance.profile /data/.dream


. /res/customconfig/customconfig-helper
read_defaults
read_config

if [ "$logger" == "off" ];then
rm -rf /dev/log
fi
if [ "$logger" == "on" ];then
insmod /lib/modules/logger.ko
fi
#fm radio, I have no idea why it isn't loaded in init -gm
insmod /lib/modules/Si4709_driver.ko
# for ntfs automounting
insmod /lib/modules/fuse.ko
