#!/sbin/busybox sh
#
## Create the kernel data directory
mkdir /data/.dream
chmod 777 /data/.dream

## Function to extract the payload from the zImage
## forked from gokhanmorals siyah
extract_payload()
{
  payload_extracted=1
  chmod 755 /sbin/read_boot_headers
  eval $(/sbin/read_boot_headers /dev/block/mmcblk0p5)
  load_offset=$boot_offset
  load_len=$boot_len
  cd /
  dd bs=512 if=/dev/block/mmcblk0p5 skip=$load_offset count=$load_len | tar x
}

## Enable "post-init" Logging do not enable if /sbin/init is already logging ...
mv /data/.dream/post-init.log /data/.dream/post-init.log.bak
date >/data/.dream/post-init.log
exec >>/data/.dream/post-init.log 2>&1

echo "Mounting System RW"
mount -o remount,rw /system

echo "Remounting RootFS RW"
mount -t rootfs -o remount,rw rootfs

# echo "Enabling KMEM interface ..."
# echo 0 > /proc/sys/kernel/kptr_restrict

payload_extracted=0

echo "Checking for SU binary"
if [ -f /system/xbin/su ];
then
  echo "SU Binary already exists, skipping install ..."
else
  # Extract Payload from zImage if needed ...
  if [ "$payload_extracted" == "0" ];
  then
    extract_payload
  fi

  echo "SU Binary not found, installing it ..."
  rm -v /system/bin/su
  rm -v /system/xbin/su
  chmod 755 /system/xbin
  xzcat /res/misc/payload/su.xz > /system/xbin/su
  chown 0.0 /system/xbin/su
  chmod 6755 /system/xbin/su
  echo "SU Binary installed ..."

  echo "Installing Superuser APP"
  rm -f /system/app/*uper?ser.apk
  rm -f /system/app/?uper?u.apk
  rm -f /system/app/*chainfire?supersu*.apk
  rm -f /data/app/*uper?ser.apk
  rm -f /data/app/?uper?u.apk
  rm -f /data/app/*chainfire?supersu*.apk
  rm -rf /data/dalvik-cache/*uper?ser.apk*
  rm -rf /data/dalvik-cache/*chainfire?supersu*.apk*
  xzcat /res/misc/payload/Superuser.apk.xz > /system/app/Superuser.apk
  chown 0.0 /system/app/Superuser.apk
  chmod 644 /system/app/Superuser.apk
fi;

echo "checking liblights.exynos4.so ..."
lightsmd5sum=`/sbin/busybox md5sum /system/lib/hw/lights.exynos4.so | /sbin/busybox awk '{print $1}'`
blnlightsmd5sum=`/sbin/busybox md5sum /res/misc/lights.exynos4.so | /sbin/busybox awk '{print $1}'`

if [ "${lightsmd5sum}a" != "${blnlightsmd5sum}a" ];
then
    echo "Installing lights.exynos4.so to your ROM ..."
    mv /system/lib/hw/lights.exynos4.so /system/lib/hw/lights.exynos4.so.BAK
    cp /res/misc/lights.exynos4.so /system/lib/hw/lights.exynos4.so
    chown 0.0 /system/lib/hw/lights.exynos4.so
    chmod 644 /system/lib/hw/lights.exynos4.so
fi;

mkdir /system/.dream
echo 1 > /system/.dream/liblights-installed

if [ "$payload_extracted" == "1" ];
then
  echo "Cleaning UP Payload Directory"
  rm -rf /res/misc/payload
else
  echo "Payload not extracted skipping cleanup ..."
fi;

date >>/data/.dream/post-init.log
echo "Install Script finished ..."
echo "Remounting FileSystem RO"
mount -t rootfs -o remount,ro rootfs
mount -o remount,ro /system
