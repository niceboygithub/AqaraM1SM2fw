#!/bin/sh

if [ "$(getprop ro.sys.model)" != "lumi.gateway.iragl5" ]; then
    echo "This is not supported M2 and exit!"
    exit 1
fi

cd /tmp

echo "Updating Coor"
/tmp/curl -s -k -L -o /tmp/ControlBridge.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/M2/3.3.2_0008.0605/ControlBridge.bin
[ "$(md5sum /tmp/ControlBridge.bin)" == "4d87296d2b06d71042209c9d83bb4ddf  /tmp/ControlBridge.bin" ] && zigbee_msnger zgb_ota /tmp/ControlBridge.bin
[ "$(zigbee_msnger get_zgb_ver | grep coor)" != "coor ver =0605" ] && zigbee_msnger zgb_ota /tmp/ControlBridge.bin
[ "x$(zigbee_msnger get_zgb_ver | grep Error)" != "x" ] && zigbee_msnger zgb_ota /tmp/ControlBridge.bin

echo "Updating linux kernel"
/tmp/curl -s -k -L -o /tmp/linux.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/M2/3.3.2_0008.0605/linux_3.3.2_0008.0605.bin
fw_update /tmp/linux.bin
echo 3 >/proc/sys/vm/drop_caches; sleep 1; sync

echo "Update root file system"
/tmp/curl -s -k -L -o /tmp/rootfs.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/modified/M2/3.3.2_0008.0605/rootfs_3.3.2_0008.0605_modified.bin
killall homekitserver; fw_update /tmp/rootfs.bin
sync; sync
