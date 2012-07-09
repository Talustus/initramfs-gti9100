#!/sbin/ext/busybox sh
/sbin/ext/busybox mount -t rootfs -o remount,rw rootfs 
mkdir -p /customkernel/property 
echo true >> /customkernel/property/customkernel.cf-root 
echo true >> /customkernel/property/customkernel.base.cf-root 
echo DreamKernel >> /customkernel/property/customkernel.name 
echo "DreamKernel 2.6" >> /customkernel/property/customkernel.namedisplay 
echo 104 >> /customkernel/property/customkernel.version.number 
echo 5.2 >> /customkernel/property/customkernel.version.name 
echo true >> /customkernel/property/customkernel.bootani.zip 
echo true >> /customkernel/property/customkernel.bootani.bin 
echo true >> /customkernel/property/customkernel.cwm 
echo 5.5.0.4 >> /customkernel/property/customkernel.cwm.version 
/sbin/ext/busybox mount -t rootfs -o remount,ro rootfs 
