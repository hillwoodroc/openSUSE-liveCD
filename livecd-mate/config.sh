#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006,2007,2008 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>, Stephan Kulow <coolo@suse.de>
#               :
# LICENSE       : BSD
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

set -e
set -x

exec | tee /var/log/config.log
exec 2>&1

pl=`rpmqpack | grep package-lists-` || true
test -z "$pl" || rpm -e $pl

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$name]..."

#--------------------------------------
# enable and disable services

for i in langset NetworkManager SuSEfirewall2; do
	systemctl -f enable $i
done
for i in sshd cron wicked purge-kernels; do
	systemctl -f disable $i
done

cd /

if test -e /etc/YaST2/liveinstall.patch; then
  patch -p0 < /etc/YaST2/liveinstall.patch
fi

for i in /rpmkeys/gpg*.asc; do 
   # the import fails if kiwi already had this key
   rpm --import $i || true
   rm $i
done
rmdir /rpmkeys

rm -rf /var/cache/zypp/raw/*

bash -x /var/lib/livecd/geturls.sh
rm /var/lib/livecd/geturls.sh

#======================================
# /etc/sudoers hack to fix #297695 
# (Installation Live CD: no need to ask for password of root)
#--------------------------------------
sed -i -e "s/ALL ALL=(ALL) ALL/ALL ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers 
chmod 0440 /etc/sudoers

/usr/sbin/useradd -m -u 999 linux -c "Live-CD User" -p ""

# delete passwords
passwd -d root
passwd -d linux
# empty password is ok
pam-config -a --nullok

: > /var/log/zypper.log

mv /var/lib/livecd/*.pdf /home/linux || true
rmdir /var/lib/livecd || true

chown -R linux /home/linux

chkstat --system --set

#for script in /usr/share/opensuse-kiwi/live_user_scripts/*.sh; do
#  if test -f $script; then
#     su - linux -c "/bin/bash $script"
#  fi
#done

rm -rf /var/cache/zypp/packages

# bug 544314, we only want to disable the bit in common-auth-pc
sed -i -e 's,^\(.*pam_gnome_keyring.so.*\),#\1,'  /etc/pam.d/common-auth-pc

#USB /usr/bin/correct_live_for_reboot usb
#USB /usr/bin/correct_live_install usb

ln -s /usr/lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER_AUTOLOGIN linux
baseUpdateSysConfig /etc/sysconfig/keyboard KEYTABLE us.map.gz
baseUpdateSysConfig /etc/sysconfig/keyboard YAST_KEYBOARD "english-us,pc104"
baseUpdateSysConfig /etc/sysconfig/keyboard COMPOSETABLE "clear latin1.add"

baseUpdateSysConfig /etc/sysconfig/language RC_LANG "en_US.UTF-8"

baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT "lat9w-16.psfu"
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_SCREENMAP trivial
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_MAGIC "(K"
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_ENCODING "UTF-8"

# bug 891183 yast2 live-installer --gtk segfaults
baseUpdateSysConfig /etc/sysconfig/yast2 WANTED_GUI qt
baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER lightdm
