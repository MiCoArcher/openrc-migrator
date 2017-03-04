#!/bin/bash
#
# Copyright (c) 2017 Michael Corvin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# This is the Arch-specific version of the migrator script
# It has also been poorly tested, so use at your own risk. Really.

# add repos
 echo -e "[openrc-eudev]\nSigLevel=PackageOptional\nServer=http://downloads.sourceforge.net/project/archopenrc/\$repo/\$arch" >> /etc/pacman.conf
echo -e "[arch-nosystemd]\nSigLevel=PackageOptional\nServer=https://sourceforge.net/projects/archopenrc/files/\$repo/\$arch\nServer=ftp://ftp.heanet.ie/mirrors/sourceforge/a/ar/archopenrc/\$repo/\$arch" >> /etc/pacman.conf
echo -e "[arch-openrc]\nSigLevel=PackageOptional\nServer=https://sourceforge.net/projects/archopenrc/files/\$repo/\$arch\nServer=ftp://ftp.heanet.ie/mirrors/sourceforge/a/ar/archopenrc/\$repo/\$arch" >> /etc/pacman.conf
# fix the lennartware problem
echo -e "NoExtract=usr/lib/systemd/system/*" >> /etc/pacman.conf
# remove systemd
pacman -Rdd systemd libsystemd
# read -p "Enter users to be deleted: "  #whitespace-separated list of usernames to be deleted     
SYSTEMD_GROUPS="systemd-journal"
for GROUP in $SYSTEMD_GROUPS; do         
   groupdel $GROUP && echo "Group $GROUP deleted"       
done
SYSTEMD_USERS="systemd-journal-gateway systemd-coredump systemd-resolve systemd-timesync systemd-journal-upload systemd-network systemd-journal-gateway systemd-journal-remote"
for USER in $SYSTEMD_USERS; do         
   userdel $USER && echo "User $USER deleted"       
done
# install openrc
pacman -Sy sysvinit base-openrc eudev-systemd eudev-base dbus-nosystemd procps-ng-nosystemd displaymanager-openrc
# basic configuration
#vim /etc/rc.conf;
# setup display manager
#vim /etc/conf.d/xdm;
#rc-update add xdm default;
rm -f /etc/hostname; echo "hostname=openrc" >| /etc/conf.d/hostname;
#vim /etc/conf.d/net;
cd /etc/init.d;
#ln -s net.lo net.eth0;
#rc-update add net.eth0 boot
# get the X11 support. This command allows for the nosystemd xorg packages to be installed first, and then simply install everything else from the same group, which ensures that only openrc-relevant packages are being installed
pacman -S $(pac -Ssq xorg | grep nosystemd); pacman -S xorg xorg-drivers
# reboot
sysctl kernel.sysrq=1
echo "If no errors were reported from the pacman operations:"
echo "sync - remount-ro - reboot"
echo "echo s >| /proc/sysrq-trigger"
echo "echo u >| /proc/sysrq-trigger"
echo "echo b >| /proc/sysrq-trigger"
