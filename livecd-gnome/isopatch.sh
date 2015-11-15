#! /bin/sh

set -ex

desktop=gnome

#sed -i -e "s,label openSUSE.*,label $label," boot/*/loader/isolinux.cfg
if test "$desktop" != "x11"; then
  sed -i -e "s,label Failsafe.*,label linux," boot/*/loader/isolinux.cfg
  sed -i -e "s,showopts ide=nodma.*,liveinstall showopts," boot/*/loader/isolinux.cfg
else
  sed -i -ne ':ss;/^label media/{:s;n;/^ /b s;b ss};p' boot/*/loader/isolinux.cfg
  #sed -i -e "s,label Failsafe.*,label Failsafe $label," boot/*/loader/isolinux.cfg
fi
sed -i -e "s,label Hard-Disk,label harddisk," boot/*/loader/isolinux.cfg
#sed -i -e "s,default open.*,default $label," boot/*/loader/isolinux.cfg
#sed -i -e "s,openSUSE[^ ]*,$label," boot/*/loader/isolinux.msg
sed -i -e "s,showopts,splash=silent quiet showopts," boot/*/loader/isolinux.cfg
sed -i -e 's,key.F4=$,key.F4=kernelopts,' boot/*/loader/gfxboot.cfg

bootd=$(ls -1d boot/*/loader)
cp boot/*/loader/isolinux.cfg syslinux.cfg
sed -i -e "s,kernel linux,kernel $bootd/linux," syslinux.cfg
sed -i -e "s,initrd=initrd,initrd=$bootd/initrd," syslinux.cfg
sed -i -e "s,timeout *200,timeout 5," syslinux.cfg
# copyright matz
sed -i -ne ':ss;/^label media/{:s;n;/^ /b s;b ss};p' syslinux.cfg 

