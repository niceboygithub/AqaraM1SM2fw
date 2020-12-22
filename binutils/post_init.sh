#!/bin/sh

telnetd_running=`pgrep telnetd`
if [ "x${telnetd_running}" == "x" ]; then telnetd; fi
fw_manager.sh -r
echo enable > /sys/class/tty/tty/enable