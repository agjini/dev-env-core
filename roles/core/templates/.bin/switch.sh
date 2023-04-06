#!/bin/bash

isActive() {
    local monitor=${1}
    xrandr --listactivemonitors | grep "${monitor}" > /dev/null 2>&1
    echo $?
}

listConnectedMonitors() {
    local monitorType=${1}

    xrandr -q | grep " connected" | grep "^${monitorType}" | awk '{print $1}'
}

autoConfigure() {
    local laptop=$(listConnectedMonitors eDP)
    local monitors=$(listConnectedMonitors DP) $(listConnectedMonitors HDMI)

    if [ -z "${monitors}" ]; then
        echo "No external monitor found, no change"
        return;
    fi;

    echo "Find external monitors :"
    for monitor in ${monitors}
    do
        echo "  - '${monitor}'"
    done

    if [ "$(isActive ${laptop})" = 0 ]; then

        xrandr --output "${laptop}" --off

        local previous=0
        for monitor in ${monitors}
        do
            if [ "${previous}" = 0 ]
            then
                xrandr --output "${monitor}" --auto --primary
            else
                xrandr --output "${monitor}" --auto --right-of "${previous}"
            fi
            previous="${monitor}"
        done

    else
        
        for monitor in ${monitors}
        do
            xrandr --output "${monitor}" --off
        done
        xrandr --output "${laptop}" --auto --primary
        
    fi;
    killall dunst
}

autoConfigure