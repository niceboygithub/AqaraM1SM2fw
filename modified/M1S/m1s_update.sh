#!/bin/sh

REVISION="2"
REVISION_FILE="/data/utils/fw_manager.revision"

#
# @file    m1s_update.sh
# @brief   This script is used to manage program operations,
#          including, but not limited to,
#          1. update firmware.
#
# @author  Niceboy (niceboygithub@github.com)
# @author  Michael (huiwang.zhu@aqara.com)
#
# Copyright (c) 2020~2021 ShenZhen Lumiunited Technology Co., Ltd.
# All rights reserved.
#

#
# Script options.
# -h: helper.
# -u: update.
#
OPTIONS="-h;-u;"

#
# Platforms.
# -a: AIOT.
# -m: MIOT.
#
PLATFORMS="-a;-m"

#
# Default platform.
# Must in aiot;miot.
#
DEFAULT_PLATFORM="aiot"

#
# Tag files.
#
MODEL_FILE="/data/utils/fw_manager.model"

#
# Product model, support list: AC_P3, AH_M1S, AH_M2.
#
# AC_P3 : Air Condition P3.
# AH_M1S: Aqara Hub M1S.
# AH_M2 : Aqara Hub M2.

#
# Version and md5sum
#
VERSION="3.4.0_0004.0616"
COOR_MD5SUM="f719bc9887d879abe0ef8774a6208481"
KERNEL_MD5SUM="c4afe3c3c019ad598eae2551c1ef15c5"
ROOTFS_MD5SUM="c500bf5b14a5b053355fda903e5271fe"
BTBL_MD5SUM=""
BTAPP_MD5SUM=""
IRCTRL_MD5SUM=""

#
# note: default is unknow.
#
model=""
ble_support=""
UPDATE_BT=0

#
# Enable debug, 0/1.
#
debug=1

#
# Show green content, in the same way to use as echo.
#
green_echo()
{
    if [ $debug -eq 0 ]; then return; fi

    GREEN="\033[0;32m"; BLACK="\033[0m"
    if [ "$1" = "-n" ]; then echo -en $GREEN$2$BLACK; else echo -e $GREEN$1$BLACK; fi
}

#
# Show red content, in the same way to use as echo.
#
red_echo()
{
    RED="\033[0;31m"; BLACK="\033[0m"
    if [ "$1" = "-n" ]; then echo -en $RED$2$BLACK; else echo -e $RED$1$BLACK; fi
}

#
# Match sub-string.
#
# param $1: string.
# Param $2: sub-string.
#
# return: 1 - matched.
# return: 0 - unmatch.
#
match_substring()
{
	string="$1"; substr="$2"

	case $string in
        *$substr*) return 1 ;;
        *)         return 0 ;;
	esac
}

#
# Convert rom string to number.
# Param: value string.
#
convert_str2int()
{
    local str=$1
    local length=${#str}
    local sum=0; local index=0

    while [ ${index} -lt ${length} ]; do
        let sum=10*sum+${str:${index}:1}
        let index+=1
    done

    echo ${sum}
}

#
# Set some tags into file.
# Param1: file.
# Param2: tags.
#
set_tags()
{
    local file="$1"
    local tags="$2"

    if [ ! -f "$file" ]; then
        local dir=`dirname "$file"`
        if [ ! -d "$dir" ]; then mkdir "$dir"; fi
    fi

    echo "$tags" > "$file"
}

usage_helper()
{
    green_echo "Helper to show how to use this script."
    green_echo "Usage: m1s_update.sh -h [$OPTIONS]."
}

usage_updater()
{
    green_echo "Update firmware."
    green_echo "Usage: m2_update.sh -u [$UPDATER] [path]."
    green_echo " -s : check md5sum."
    green_echo " -n : don't check md5sum."
}

#
# Stop AIOT programs.
# Note: We can specifing some programs to keep alive
#       by use of format string: "x;x;x...".
#
# Flag: ha_driven        : d
#       ha_master        : m
#       ha_basis         : b
#       ha_agent         : a
#       property_service : p
#       zigbee_agent     : z
#
# For example: keep ha_basis and ha_master alive: stop_aiot "b;m"
#
stop_aiot()
{
    local d=0; local m=0; local b=0
    local a=0; local p=0; local z=0

    match_substring "$1" "d"; d=$?
    match_substring "$1" "m"; m=$?
    match_substring "$1" "b"; b=$?
    match_substring "$1" "a"; a=$?
    match_substring "$1" "p"; p=$?
    match_substring "$1" "z"; z=$?
    match_substring "$1" "l"; l=$?

    green_echo "d:$d, m:$m, b:$b, a:$a, p:$p, z:$z, l:$l"

    # Stop monitor.
    killall -9 app_monitor.sh

    #
    # Send a signal to programs.
    #
    if [ $d -eq 0 ]; then killall ha_driven        ;fi
    if [ $m -eq 0 ]; then killall ha_master        ;fi
    if [ $b -eq 0 ]; then killall ha_basis         ;fi
    if [ $a -eq 0 ]; then killall ha_agent         ;fi
    if [ $p -eq 0 ]; then killall property_service ;fi
    if [ $z -eq 0 ]; then killall zigbee_agent     ;fi
    if [ $l -eq 0 ]; then killall ha_ble           ;fi

    sleep 1

    #
    # Force to kill programs.
    #
    if [ $d -eq 0 ]; then killall -9 ha_driven        ;fi
    if [ $m -eq 0 ]; then killall -9 ha_master        ;fi
    if [ $b -eq 0 ]; then killall -9 ha_basis         ;fi
    if [ $a -eq 0 ]; then killall -9 ha_agent         ;fi
    if [ $p -eq 0 ]; then killall -9 property_service ;fi
    if [ $z -eq 0 ]; then killall -9 zigbee_agent     ;fi
    if [ $l -eq 0 ]; then killall -9 ha_ble           ;fi
}

#
# Stop MIOT programs.
# Note: We can specifing some programs to keep alive
#       by use of format string: "x;x;x...".
#
# Flag: mha_basis        : b
#       mha_master       : m
#       homekitserver    : h
#       miio_agent       : g
#       miio_client      : c
#       mzigbee_agent    : z
#       mijia_automation : a
#       property_service : p
#
# For example: keep mha_basis and mha_master alive: stop_miot "b;m"
#
stop_miot()
{
    local b=0; local m=0; local h=0; local g=0
    local c=0; local z=0; local a=0; local p=0

    match_substring "$1" "b"; b=$?
    match_substring "$1" "m"; m=$?
    match_substring "$1" "h"; h=$?
    match_substring "$1" "g"; g=$?
    match_substring "$1" "c"; c=$?
    match_substring "$1" "z"; z=$?
    match_substring "$1" "a"; a=$?
    match_substring "$1" "p"; p=$?

    # Stop monitor.
    killall -9 app_monitor.sh

    #
    # Send a signal to programs.
    #
    killall -9 miio_client_helper_nomqtt.sh
    if [ $a -eq 0 ]; then killall mijia_automation ;fi
    if [ $h -eq 0 ]; then killall homekitserver    ;fi
    if [ $m -eq 0 ]; then killall mha_master       ;fi
    if [ $c -eq 0 ]; then killall miio_client      ;fi
    if [ $b -eq 0 ]; then killall mha_basis        ;fi
    if [ $p -eq 0 ]; then killall property_service ;fi
    if [ $g -eq 0 ]; then killall miio_agent       ;fi
    if [ $z -eq 0 ]; then killall mzigbee_agent    ;fi

    # P3 programs.
    if [ "$model" = "AC_P3" ]; then killall mha_ir ;fi

    sleep 1

    #
    # Force to kill programs.
    #
    if [ $a -eq 0 ]; then killall -9 mijia_automation ;fi
    if [ $h -eq 0 ]; then killall -9 homekitserver    ;fi
    if [ $m -eq 0 ]; then killall -9 mha_master       ;fi
    if [ $c -eq 0 ]; then killall -9 miio_client      ;fi
    if [ $b -eq 0 ]; then killall -9 mha_basis        ;fi
    if [ $p -eq 0 ]; then killall -9 property_service ;fi
    if [ $g -eq 0 ]; then killall -9 miio_agent       ;fi
    if [ $z -eq 0 ]; then killall -9 mzigbee_agent    ;fi

    # P3 programs.
    if [ "$model" = "AC_P3" ]; then killall -9 mha_ir ;fi
}

#
# Switch to platform: AIOT.
#

parse_json()
{
    echo "${1//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}
#to avoid coor cloud status confused

check_coor_cloud()
{
    CUR_CLOUD=$1
    local COOR_MIOT_FALG="0x126e"
    local COOR_AIOT_FALG="0x115f"

    local COOR_INFO="/data/zigbee/coordinator.info"
    for n in `seq 3`
    do
        buf=`cat /data/zigbee/coordinator.info`
        manu_code="$(parse_json "$buf" "manuCode")"
        if [ "$CUR_CLOUD" = "aiot" ]; then
            if [ "$manu_code" != $COOR_AIOT_FALG ]; then
                zigbee_msnger cloud aiot
                sleep 2
            else
                return 0
            fi
        fi
        if [ "$CUR_CLOUD" = "miot" ]; then
            if [ $manu_code != "$COOR_MIOT_FALG" ]; then
                zigbee_msnger cloud miot
                sleep 2
            else
                return 0
            fi
        fi
    done
    return 1;
}

#
# Prepare for update.
# Return value 1 : failed.
# Return value 0 : ok.
#
update_prepare()
{
    # Clean old firmware directory.
    if [ -d $fws_dir_ ]; then rm $fws_dir_ -rf; fi
    if [ -d $ota_dir_ ]; then rm $ota_dir_ -rf; fi

    # Clean log files.
    rm /tmp/bmlog.txt* -f
    rm /tmp/zblog.txt* -f
    rm /tmp/aulog.txt* -f

    echo 3 >/proc/sys/vm/drop_caches; sleep 1

    dfu_pkg_="$1"

    ota_dir_="/tmp/ota_dir"
    fws_dir_="/data/ota_dir"
    flash_ok_="/tmp/flash_ok"

    firmwares_="$fws_dir_/lumi_fw.tar"

    kernel_bin_="$ota_dir_/linux.bin"
    rootfs_bin_="$ota_dir_/root.bin"
    zbcoor_bin_="$ota_dir_/ControlBridge.bin"
    irctrl_bin_="$ota_dir_/IRController.bin"
    ble_bl_bin_="$ota_dir_/bootloader.gbl"
    ble_app_bin_="$ota_dir_/full.gbl"

    zbcoor_bin_bk_="/data/ControlBridge.bin"
    ble_bl_bin_bk_="/data/bootloader.gbl"
    ble_app_bin_bk_="/data/full.gbl"

    local dfusize=1703936
    local memfree=`cat /proc/meminfo | grep MemFree | tr -cd "[0-9]"`
    local romfree=`df | grep ubi | awk '{print $4}'`

    dfusize_=`convert_str2int "$dfusize"`
    memfree_=`convert_str2int "$memfree"`; memfree_=$((memfree_*1024))
    romfree_=`convert_str2int "$romfree"`; romfree_=$((romfree_*1024))

    green_echo "Unpack path          : $ota_dir_"
    green_echo "Firmware path        : $fws_dir_"
    green_echo "Available ROM size(b): $romfree_"
    green_echo "Available RAM size(b): $memfree_"

    # Check memory space.
    # Failed to get var if romfree_/memfree_ equal zero.
    if [ $romfree_ -gt 0 ] && [ $memfree_ -gt 0 ] &&
       [ $romfree_ -lt $dfusize_ ] && [ $memfree_ -lt $dfusize_ ]; then
        red_echo "Not enough storage available!"
        return 1
    fi

    mkdir -p $fws_dir_ $ota_dir_

    return 0
}

update_getpack()
{
    local platform="$1"
    local simple_model=""
    local path="$2"
    local nocheck="$3"

    # Air Condition.
    if   [ "$model" = "AC_P3" ]; then simple_model="P3"
    # Aqara Hub M1S.
    elif [ "$model" = "AH_M1S" ]; then simple_model="M1S"
    # Aqara Hub M2.
    elif [ "$model" = "AH_M2_BLE" ]; then simple_model="M2"
    # Aqara Hub H1.
    elif [ "$model" = "AH_H1" ];  then simple_model="H1"
    # End
    fi

    if [ "x${simple_model}" == "x" ]; then
        echo "Error: Unknow model"
        return 1
    fi

    echo "Get packages, please wait..."
    if [ "x${simple_model}" == "xP3" ]; then
        /tmp/curl -s -k -L -o /tmp/IRController.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/${simple_model}/${VERSION}/IRController.bin
        [ "$(md5sum /tmp/IRController.bin)" != "${IRCTRL_MD5SUM}  /tmp/IRController.bin" ] && return 1
    fi

    if [ "x${UPDATE_BT}" == "x1" ]; then
        /tmp/curl -s -k -L -o /tmp/bootloader.gbl https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/${simple_model}/${VERSION}/bootloader.gbl
        [ "$(md5sum /tmp/bootloader.gbl)" != "${BTBL_MD5SUM}  /tmp/bootloader.gbl" ] && return 1

        /tmp/curl -s -k -L -o /tmp/full.gbl https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/${simple_model}/${VERSION}/full.gbl
        [ "$(md5sum /tmp/full.gbl)" != "${BTAPP_MD5SUM}  /tmp/full.gbl" ] && return 1
    fi

    /tmp/curl -s -k -L -o /tmp/ControlBridge.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/${simple_model}/${VERSION}/ControlBridge.bin
    [ "$(md5sum /tmp/ControlBridge.bin)" != "${COOR_MD5SUM}  /tmp/ControlBridge.bin" ] && return 1

    /tmp/curl -s -k -L -o /tmp/linux.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/original/${simple_model}/${VERSION}/linux_${VERSION}.bin
    [ "$(md5sum /tmp/linux.bin)" != "${KERNEL_MD5SUM}  /tmp/linux.bin" ] && return 1

    /tmp/curl -s -k -L -o /tmp/rootfs.bin https://raw.githubusercontent.com/niceboygithub/AqaraM1SM2fw/main/modified/${simple_model}/${VERSION}/rootfs_${VERSION}_modified.bin
    [ "$(md5sum /tmp/rootfs.bin)" != "${ROOTFS_MD5SUM}  /tmp/rootfs.bin" ] && return 1

    echo "Got packages done"
    return 0
}

update_clean()
{
    rm -rf "$fws_dir_" "$ota_dir_"
    sync;sync;sync; sleep 1
}

#
# Check update status was block or not.
# return value 1: true.
# return value 0: false.
#
update_block()
{
    local result=`getprop sys.dfu_progress`
    if [ "$result" = "-1" ]; then return 1; fi

    return 0
}

confirm_coor()
{
    zigbee_msnger get_zgb_ver
    sleep 0.1
    local index2=`getprop sys.coor_update`
    if [ "$index2" != "true" ]
    then
        return 1
    fi
    return 0;
}

vertify_block()
{
    local UPDATE_RES=`grep Success $flash_ok_`
    if [ "$UPDATE_RES" = "" ]
    then
        echo "fw_update $1 failed"
        setprop sys.dfu_progress -1
    else
        echo "fw_update $1 suceess"
    fi

    rm -fr $flash_ok_
}
    kernel_bin_="$ota_dir_/linux.bin"
    rootfs_bin_="$ota_dir_/root.bin"
    zbcoor_bin_="$ota_dir_/ControlBridge.bin"
    irctrl_bin_="$ota_dir_/IRController.bin"
    ble_bl_bin_="$ota_dir_/bootloader.gbl"
    ble_app_bin_="$ota_dir_/full.gbl"


update_before_start()
{
    local platform="$1"

    if [ -f "/tmp/IRController.bin" ]; then
        mv /tmp/IRController.bin $irctrl_bin_
    fi

    if [ -f "/tmp/ControlBridge.bin" ]; then
        mv /tmp/ControlBridge.bin $zbcoor_bin_
    fi

    if [ -f "/tmp/bootloader.gbl" ]; then
        mv /tmp/bootloader.gbl $ble_bl_bin_
    fi

    if [ -f "/tmp/full.gbl" ]; then
        mv /tmp/full.gbl $ble_app_bin_
    fi

    if [ -f "/tmp/linux.bin" ]; then
        mv /tmp/linux.bin $kernel_bin_
    fi

    if [ -f "/tmp/rootfs.bin" ]; then
        mv /tmp/rootfs.bin $rootfs_bin_
    fi
}

update_start()
{
    local platform="$1"

    # Update IR-Controller firmware.
    if [ -f "$irctrl_bin_" ]; then
        if [ "$platform" = "miot" ]; then
            setprop sys.app_monitor_delay 60
            killall mha_ir
            sleep 2
        fi

        ir_ota ttyS2 115200 "$irctrl_bin_"
        # Check result
        update_block; if [ $? -eq 1 ]; then return 1; fi
    fi

    # Update zigbee-coordinator firmware.
    local DFU_VER=`getprop persist.app.dfu_ver`
    local CLOUD_VER=`echo $DFU_VER | cut -d '.' -f 4`
    local LOCAL_VER=`getprop persist.sys.zb_ver`
    local can_upg=true;
    if [ "$LOCAL_VER" -ge "600" ] && [ "$CLOUD_VER" -lt "600" ];then
	    echo "Can't downgrade and upgrade,cloud_ver=$CLOUD_VER,local_ver=$LOCAL_VER"
        can_upg=false;
    fi

    if [ $can_upg = "true" ] && [ "$CLOUD_VER" != "$LOCAL_VER" ]; then
        if [ -f "$zbcoor_bin_" ]; then
            cp -f "$zbcoor_bin_" "$zbcoor_bin_bk_"
            for retry in `seq 3`
            do
                zigbee_msnger zgb_ota "$zbcoor_bin_"
                sleep 4
                # Check result
                confirm_coor
                var=$?
                if [ $var -eq 0 ]; then break; fi
            done
            if [ $var -eq 1 ]; then
                setprop sys.dfu_progress -1
                return 1
            fi
	    rm -f "$zbcoor_bin_bk_"
    fi

        # RGB light control by the coordinator.
        # Update coordinator will to stop light flashing.
        # So we need to indicate OTA state again.
        if [ "$model" = "AH_M1S" ]; then
            if [ "$platform" = "aiot" ]; then basis_cli -sys -d 0; basis_cli -sys -d 1; fi
            if [ "$platform" = "miot" ]; then mbasis_cli -sys -d 0; mbasis_cli -sys -d 1; fi
        fi
    fi

    #Update ble bootloader app firmware
    if [ -f "$ble_bl_bin_" ] && [ "$ble_support" = "true" ]; then
        killall -9 ha_ble
        cp -f "$ble_bl_bin_" "$ble_bl_bin_bk_"
        uart-dfu /dev/ttyS2 115200 $ble_bl_bin_ 101 0
        # Check result
        BLE_OTA_RESULT=`grep success /tmp/ble_ota/stat`
        if [ ! $BLE_OTA_RESULT ]
        then
            setprop sys.dfu_progress -1
            ha_ble &
            return 1
        fi
        rm -f "$ble_bl_bin_bk_"
    fi

    # Update kernel.
    if [ -f "$kernel_bin_" ]; then
        fw_update "$kernel_bin_" > $flash_ok_

        #Check result
        vertify_block $kernel_bin_; if [ $? -eq 1 ]; then return 1; fi
        rm "$kernel_bin_" -f
        echo 3 >/proc/sys/vm/drop_caches; sleep 1; sync
    fi

    # Update rootfs.
    if [ -f "$rootfs_bin_" ]; then fw_update "$rootfs_bin_" > $flash_ok_; sync; fi

    #Check result
    vertify_block $rootfs_bin_; if [ $? -eq 1 ]; then return 1; fi
    sync
    sync
    sleep 1
    return 0
}

update_failed()
{
    local platform="$1"
    local errmsg="$2"
    local clean="$3"

    green_echo "Update failed, reason: $errmsg"

    if [ "$clean" = "true" ]; then update_clean; fi

    if [ "$platform" = "miot" ]; then setprop sys.dfu_progress -33005;
    else setprop sys.dfu_progress -1; fi
}

update_done()
{
    update_clean
    sleep 1
    sync
    sleep 6
#    reboot
    green_echo ""
    green_echo "Update Done, Please manually reboot!"
}

#
# Document helper.
#
helper()
{
    local cmd="$1"

    case $cmd in
        -u) usage_updater  ;;

         *) usage_helper   ;;
    esac

    return 0
}

#
# Update firmware.
#
updater()
{
    local sign="0"
    local path="/tmp"

    # Check file existed or not.
    if [ ! -e "/tmp/curl" ]; then update_failed "$platform" "/tmp/curl not found!"; return 1; fi

    # Need check sign?
    if [ "$2" = "-s" ]; then sign="1"; fi

    local platform=`getprop persist.sys.cloud`
    if [ "$platform" = "" ]; then platform=$DEFAULT_PLATFORM; fi

    green_echo "platform: $platform, path: $path, sign: $sign"

    # Prepare...
    update_prepare "$path"
    if [ $? -ne 0 ]; then
        update_failed "$platform" "Not enough storage available!";
        return 1
    fi

    # Get DFU package and check it.
    update_getpack "$platform" "$path" "$sign"
    if [ $? -ne 0 ]; then
        update_failed "$platform" "getpack failed!" "true"
        return 1
    fi

    update_before_start "$platform"

    update_start "$platform"
    if [ $? -eq 0 ]; then update_done;
    else update_failed "$platform" "OTA failed!" "true"; fi

    return 0
}


#
# Get product model.
#
info_model()
{
    # Try: Get by attribute: persist.sys.model.
    for i in 1 2 1 0; do
        local userattr=`getprop persist.sys.model`
        if [ ! -n "$userattr" ]; then sleep $i; continue; fi

        if [ ! -f "$MODEL_FILE" ]; then set_tags "$MODEL_FILE" "$userattr"; fi

        echo "$userattr"; return
    done

    # Try: Get from file.
    if [ -f "$MODEL_FILE" ]; then local fileattr=`cat $MODEL_FILE`; echo "$fileattr"; return; fi

    # Try: Get by attribute: ro.sys.model.
    local sysattr=`getprop ro.sys.model`; echo "$sysattr"
}

#
# Initial params.
#
initial()
{
    local exit_flag=1

    # Is another script running?
    for i in 2 3 1 0; do
        local info=`ps`
        local this_num=`echo "$info" | grep "$1" | wc -l`

        if [ $this_num -le 1 ]; then exit_flag=0; break; fi

        sleep $i # Waitting...
    done

    if [ $exit_flag -ne 0 ]; then exit 1; fi

    green_echo "$1 revision: $REVISION"

    local product=`info_model`
    ble_support=`getprop persist.sys.ble_supported`
    # Air Condition.
    if   [ "$product" = "lumi.aircondition.acn05" ]; then model="AC_P3"
    elif [ "$product" = "lumi.aircondition.acn04" ]; then model="AC_P3"
    elif [ "$product" = "lumi.acpartner.acn04" ];    then model="AC_P3"
    # Aqara Hub M1S.
    elif [ "$product" = "lumi.gateway.acn01" ]; then model="AH_M1S"
    elif [ "$product" = "lumi.gateway.aeu01" ]; then model="AH_M1S"
    # Aqara Hub M2.
    elif [ "$product" = "lumi.gateway.iragl01" ]; then model="AH_M2_BLE"
    elif [ "$product" = "lumi.gateway.iragl5" ];  then model="AH_M2_BLE"
    elif [ "$product" = "lumi.gateway.iragl6" ];  then model="AH_M2_BLE"
    elif [ "$product" = "lumi.gateway.iragl7" ];  then model="AH_M2_BLE"
    # End
    fi

    green_echo "type: $product, model: $model"

    if [ "$product" != "lumi.gateway.acn01" ]; then
        echo "This is not supported M1S and exit!"
        exit 1
    fi
}

#
# Main function.
#
main()
{
    initial ${0##*/}

    local option="$1"

    case $option in
        -h) local cmd="$2"; helper   $cmd ;;

        -u|*) updater $* ;;

    esac

    return $?
}

#
# Run script.
#
main $*; exit $?

