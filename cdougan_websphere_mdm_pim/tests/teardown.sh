#!/bin/bash
ps -ef | grep [W]ebSph | awk '{print $2}' | xargs kill -9
killall -u wasadmin -9
tac /etc/fstab | grep datavg | awk '{print $2}' | xargs umount
rm -rf /opt/IBM /var/ibm /dumps /tmp/ND* /tmp/IM* /tmp/java* /tmp/osgi* /tmp/puppet*
vgremove -y datavg
pvremove /dev/sdc
grep -v datavg /etc/fstab > /tmp/fstab
mv -f /tmp/fstab /etc/fstab
userdel -r db2inst1
userdel -r wasadmin
systemctl reset-failed
systemctl daemon-reload

