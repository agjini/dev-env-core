#!/bin/bash

getActiveMonitorsCount() {
    xrandr --listactivemonitors | head -1 | awk '{ print$2 }'
}

getFirstExternalMonitor() {
    xrandr | grep " connected " | awk '{ print$1 }' | grep -v "eDP-1" | head -1
}

if [ "$(getActiveMonitorsCount)" -gt 0 ]; then

    if [ "$(getActiveMonitorsCount)" == 1 ]; then

        echo "Switching from mono screen to multi"
        ~/.bin/switch.sh

    else

        echo "Switching from multi screen to mono"

        xrandr --output eDP-1 --off

        xrandr --output DP-1-1 --off
        xrandr --output DP-1-2 --off

        xrandr --output HDMI-0 --off
        xrandr --output HDMI-1 --off
        xrandr --output HDMI-2 --off

        xrandr --output DP-2-1 --off
        xrandr --output DP-2-2 --off

        xrandr --output $(getFirstExternalMonitor) --auto --primary

    fi;

fi;
