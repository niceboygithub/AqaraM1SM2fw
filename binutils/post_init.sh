#!/bin/sh

enable_debug()
{

    # Enable Uart.
    echo enable > /sys/class/tty/tty/enable

    # Start telnet.
    local telnetd_running=`pgrep telnetd`
    if [ "$telnetd_running" = "" ]; then telnetd; fi
}


# MiniDLNAd
mkdir -p /var/tmp/usb/sda1
if [ -x "/data/bin/minidlnad" ]; then
    /data/bin/minidlnad -f /data/etc/minidlnad.conf
fi

fw_manager.sh -r

enable_debug
