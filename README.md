# Aqara Gateway M1S (ZHWG15LM) M2 (ZHWG12LM) P3 (KTBL12LM) H1 (QBCZWG11LM) Firmwares

Notice: These modified firmwares work on CN version. They are different models. Please do not flash to models, like M2 HM2-G01.
Notice: Aqara was not allow downgrade zigbee firmware from 0605 to 05XX  officially!

The repository includes the following feature.

1. binutils

- Use fw_update to update firmware.
- User boot_ctrl switch slot 0 or slot 1.
- Better Busybox
- Dropbearmulti for ssh
- dgbserver
- mosquitto 1.6.4 (copy mosquitto to /data/bin to run as public)
- minidlnad (copy minidland to /data/bin and copy minidland.conf to /data/etc)
- post_init.sh (*for M2 above 3.0.7_0008_0515, you can copy to /data/scripts/post_init.sh before upgrade 3.0.7_0008_0515, it will enable tty and telnetd without modified rootfs*)

1. raw firmware

    If using dd or bootloader to flash, need to use raw file with padded (boundary 0x20000).

2. modified firmware

    a. The modified firmwares was enabled tty rx and telnetd.

    b. Can use fw_update to update.

3. original firmware

- Roll back to original firmware or upgrade firmware by fw_update.
```
fw_update linux.bin
```
- Update BT firmware by run_ble_dfu.sh, for example:
```
run_ble_dfu.sh /dev/ttyS1 full_125.gbl 125 1
```
4. update zigbee firmware
```
zigbee_msnger zgb_ota /tmp/ota_dir/ControlBridge.bin
```
5. stock firmware

6. tools

   The aqaragateway tool can help user to flash firmware by xmodem. The UART TTL need to wired out and connected with PC.
   While wired out the UART of M1S, please use power board to provide 3.3V and 5V. Otherwise Gateway M1S will not work probably.
   Notice: Do not use the 3.3 from USBtoUART.

   If flash finish successfully, it will display 'Programming filename.bin_raw Done!'
   <img src="https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/tools/flash_done.png">


<a href="https://www.buymeacoffee.com/niceboygithub" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
