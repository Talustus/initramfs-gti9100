#!/sbin/busybox sh
#
## Create the kernel data directory
mkdir /data/.dream
chmod 777 /data/.dream

## Enable "post-init" Logging do not enable if /sbin/init is already logging ...
mv /data/.dream/post-init.log /data/.dream/post-init.log.bak
busybox date >/data/.dream/post-init.log
exec >>/data/.dream/post-init.log 2>&1

ccxmlsum=`md5sum /res/customconfig/customconfig.xml | awk '{print $1}'`
if [ "a${ccxmlsum}" != "a`cat /data/.dream/.ccxmlsum`" ];
then
  rm -f /data/.dream/*.profile
  echo ${ccxmlsum} > /data/.dream/.ccxmlsum
fi
[ ! -f /data/.dream/default.profile ] && cp /res/customconfig/default.profile /data/.dream
[ ! -f /data/.dream/battery.profile ] && cp /res/customconfig/battery.profile /data/.dream
[ ! -f /data/.dream/performance.profile ] && cp /res/customconfig/performance.profile /data/.dream

. /res/customconfig/customconfig-helper
read_defaults
read_config

## cpu undervolting
echo "${cpu_undervolting}" > /sys/devices/system/cpu/cpu0/cpufreq/vdd_levels

## change cpu step counts
case "${cpustepcount}" in
  5)
    echo 1200 1000 800 500 200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    ;;
  6)
    echo 1400 1200 1000 800 500 200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    ;;
  7)
    echo 1500 1400 1200 1000 800 500 200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    ;;
  8)
    echo 1600 1400 1200 1000 800 500 200 100 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    ;;
  9)
    echo 1600 1500 1400 1200 1000 800 500 200 100 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    ;;
  18)
    echo 1600 1500 1400 1300 1200 1100 1000 900 800 700 600 500 400 300 200 100 50 25 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
    ;;
esac;

## Android Logger
if [ "${logger}" == "on" ];then
  insmod /lib/modules/logger.ko
else
  ## disable debugging on some modules
  rm -rf /dev/log
  echo 0 > /sys/module/ump/parameters/ump_debug_level
  echo 0 > /sys/module/mali/parameters/mali_debug_level
  echo 0 > /sys/module/kernel/parameters/initcall_debug
  echo 0 > /sys//module/lowmemorykiller/parameters/debug_level
  echo 0 > /sys/module/earlysuspend/parameters/debug_mask
  echo 0 > /sys/module/alarm/parameters/debug_mask
  echo 0 > /sys/module/alarm_dev/parameters/debug_mask
  echo 0 > /sys/module/binder/parameters/debug_mask
  echo 0 > /sys/module/xt_qtaguid/parameters/debug_mask
fi

#enable kmem interface for everyone by GM.
echo 0 > /proc/sys/kernel/kptr_restrict

# Set color mode to user mode
echo "1" > /sys/devices/platform/samsung-pd.2/mdnie/mdnie/mdnie/user_mode

## for ntfs automounting
# insmod /lib/modules/fuse.ko
mount -o remount,rw /
mkdir /mnt/ntfs
mount -t tmpfs tmpfs /mnt/ntfs
chmod 777 /mnt/ntfs
mount -o remount,ro /

/sbin/busybox sh /sbin/ext/properties.sh

/sbin/busybox sh /sbin/ext/install.sh

## run this because user may have chosen not to install root at boot
## but he may need it later and install it using ExTweaks
/sbin/busybox sh /sbin/ext/su-helper.sh

##### Early-init phase tweaks #####
/sbin/busybox sh /sbin/ext/tweaks.sh

/sbin/busybox mount -t rootfs -o remount,ro rootfs

##### EFS Backup #####
(
# make sure that sdcard is mounted
sleep 30
/sbin/busybox sh /sbin/ext/efs-backup.sh
) &

# apply ExTweaks defaults
/res/uci.sh apply

/res/uci.sh soundgasm_hp ${soundgasm_hp}
/res/customconfig/actions/usb-mode ${usb_mode}

##### init scripts #####
(
/sbin/busybox sh /sbin/ext/run-init-scripts.sh
)&

