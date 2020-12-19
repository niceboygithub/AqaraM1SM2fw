# Aqara M2 (ZHWG12LM) Firmware

The repository includes the following feature.

1. binutils

- Use fw_update to update firmware.
- User boot_ctrl switch slot 0 or slot 1.
- Better Busybox
- Dropbearmulti for ssh
- dgbserver

2. raw firmware

    If using dd or bootloader to flash, need to use raw file with padded (boundary 0x20000).

3. modified firmware

    a. The modified firmwares was enabled tty rx and telnetd.

    b. Use fw_update to update.

4. original firmware

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