#!/bin/sh

enable_debug()
{

    # Enable Uart.
    echo enable > /sys/class/tty/tty/enable

    # Start telnet.
    local telnetd_running=`pgrep telnetd`
    if [ "$telnetd_running" == "" ]; then telnetd; fi
}

enable_mosquitto()
{
    # ReStart mosquitto.
    if [ -x "/data/bin/mosquitto" ]; then
        local mosquitto_running=`pgrep mosquitto`
        if [ "$mosquitto_running" != "" ]; then 
            kill $mosquitto_running
        fi
        /data/bin/mosquitto -d 
    fi
}

# MiniDLNA Daemond
enable_minidlna()
{
    if [ -x "/data/bin/minidlnad" ]; then
        /data/bin/minidlnad -f /data/etc/minidlnad.conf
    fi
}

mkdir -p /var/tmp/usb/sda1

fw_manager.sh -r

enable_debug
enable_mosquitto
enable_minidlna