#!/bin/bash

getActiveMonitorsCount() {
    xrandr --listactivemonitors | head -1 | awk '{ print$2 }'
}

getActiveMonitors() {
    xrandr --listactivemonitors | tail -n+2 | awk '{ print$4 }'
}

if [ "$(getActiveMonitorsCount)" -gt 0 ]; then

    if [ "$(getActiveMonitorsCount)" == 1 ]; then

        echo "Switching from mono screen to multi"
        ~/.bin/switch.sh

    else

        echo "Switching from multi screen to mono"

        local i=0
        for value in $(getActiveMonitors)
        do
            if [ "${i}" = "0" ]; then
                xrandr --output "${value}" --auto --primary
            else
                xrandr --output "${value}" --off
            fi;
            i=$(expr $i + 1)
        done


    fi;

fi;
