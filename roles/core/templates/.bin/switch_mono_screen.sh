#!/bin/bash

getActiveMonitorsCount() {
    xrandr --listactivemonitors | head -1 | awk '{ print$2 }'
}

getActiveMonitorsExceptFirst() {
    xrandr --listactivemonitors | tail -n+3 | awk '{ print$4 }'
}

if [ "$(getActiveMonitorsCount)" -gt 0 ]; then

    if [ "$(getActiveMonitorsCount)" == 1 ]; then

        echo "Switching from mono screen to multi"
        ~/.bin/switch.sh

    else

        for value in $(getActiveMonitorsExceptFirst)
        do
            xrandr --output "${value}" --off
        done

    fi;

fi;
