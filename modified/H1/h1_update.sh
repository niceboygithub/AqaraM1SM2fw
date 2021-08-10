#!/bin/sh

if [ "$(getprop ro.sys.model)" != "lumi.gateway.sacn01" ]; then
    echo "This is not supported H1 and exit!"
    exit 1
fi

cd /tmp

echo "Updating Coor"
/tmp/curl -s -k -L -o /tmp/ControlBridge.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/H1/3.0.8_0001.0512/ControlBridge.bin
[ "$(md5sum /tmp/ControlBridge.bin)" = "637f5e7a51b25aa46fa8c016be18ffc7  /tmp/ControlBridge.bin" ] && zigbee_msnger zgb_ota /tmp/ControlBridge.bin
[ "$(zigbee_msnger get_zgb_ver | grep coor)" != "coor ver =0512" ] && zigbee_msnger zgb_ota /tmp/ControlBridge.bin

echo "Updating linux kernel"
/tmp/curl -s -k -L -o /tmp/linux.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/H1/3.0.8_0001.0512/linux_3.0.8_0001.0512.bin
fw_update /tmp/linux.bin
echo 3 >/proc/sys/vm/drop_caches; sleep 1; sync

echo "Update root file system"
/tmp/curl -s -k -L -o /tmp/rootfs.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/modified/H1/3.0.8_0001.0512/rootfs_3.0.8_0001.0512_modified.bin
killall homekitserver; fw_update /tmp/rootfs.bin
sync; sync
