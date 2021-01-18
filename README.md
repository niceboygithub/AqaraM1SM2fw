# Aqara Gateway M1S (ZHWG15LM) M2 (ZHWG12LM) Firmware

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
- Update Silicon Lab. EFR32BG by run_ble_dfu.sh, for example:
```
run_ble_dfu.sh /dev/ttyS1 full_125.gbl 125 1
```

5. stock firmware

6. scripts

   The python script utility to generate firmware, calcuate checksum of boot_info and other functions.

<a href="https://www.buymeacoffee.com/niceboygithub" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>