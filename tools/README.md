# Aqara/Xiaomi Gateway tools

## AqaraGateway
   The aqaragateway tool now can support the M2 CN and the NEW M2 EU/Global which use non-signed firmwares.

## Gateway Global tool
   Download the files [gw_global_tool.ttl](https://github.com/niceboygithub/AqaraM1SM2fw/blob/main/tools/gw_global_tool.ttl), [flasher_mgl03.bin](https://github.com/niceboygithub/AqaraM1SM2fw/blob/main/tools/flasher_mgl03.bin), [flasher_m2gl.bin](https://github.com/niceboygithub/AqaraM1SM2fw/blob/main/tools/flasher_m2gl.bin), [flasher_m2kor.bin](https://github.com/niceboygithub/AqaraM1SM2fw/blob/main/tools/flasher_m2kor.bin) then put them into the same folder.

### Windows
1. Download [gw_global_tool.ttl](https://github.com/niceboygithub/AqaraM1SM2fw/blob/main/tools/gw_global_tool.ttl)
1. Download and install [Tera Term](https://ttssh2.osdn.jp/index.html.en)
1. Run Tera Term
1. Choose "Serial -> COM port", OK
1. Choose "Control -> Macro"
1. Open gw_global_tool.ttl file you downloaded in step [1]
1. Follow on-screen instructions

### Linux
1. Download [gw_global_tool.expect](https://github.com/niceboygithub/AqaraM1SM2fw/blob/main/tools/gw_global_tool.expect)
1. make sure following programs are installed:
  * expect
  * sx (from package lrzsz)
  * stty
1. make sure that flasher (flasher*.bin) are in the same folder
1. make sure you're in "dialout" group
1. run:
   ```
   chmod +x gw_global_tool.expect
   ./gw_global_tool.expect
   ```
1. follow on-screen instructions


<a href="https://www.buymeacoffee.com/niceboygithub" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
