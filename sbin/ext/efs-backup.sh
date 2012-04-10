#!/sbin/busybox sh
if [ ! -f /data/.dream/efsbackup.tar.gz ];
then
  mkdir /data/.dream
  chmod 777 /data/.dream
  /sbin/busybox tar zcvf /data/.dream/efsbackup.tar.gz /efs
  /sbin/busybox cat /dev/block/mmcblk0p1 > /data/.dream/efsdev-mmcblk0p1.img
  /sbin/busybox gzip /data/.dream/efsdev-mmcblk0p1.img
  #make sure that sdcard is mounted, media scanned..etc
  (
    sleep 500
    /sbin/busybox cp /data/.dream/efs* /sdcard
  ) &
fi

