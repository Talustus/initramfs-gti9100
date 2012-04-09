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
# Modul does not load on first insmod
/sbin/insmod /lib/modules/logger.ko
/sbin/insmod /lib/modules/logger.ko
fi

# j4fs should be already loaded?
#/sbin/insmod /lib/modules/j4fs.ko
#/sbin/insmod /lib/modules/j4fs.ko

#fm radio, I have no idea why it isn't loaded in init -gm
/sbin/insmod /lib/modules/Si4709_driver.ko

# for ntfs automounting
/sbin/insmod /lib/modules/fuse.ko
/sbin/insmod /lib/modules/fuse.ko

# for cifs mounts
/sbin/insmod /lib/modules/cifs.ko
/sbin/insmod /lib/modules/cifs.ko
