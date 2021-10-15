#!/bin/bash

isConnected() {
    local monitor=${1}
    # Is here to force to rediscover available displays
    # And check if there is other monitors that laptop connected
    xrandr -q | grep "${monitor} connected" > /dev/null 2>&1
    echo $?
}

isActive() {
    local monitor=${1}
    xrandr --listactivemonitors | grep ${monitor} > /dev/null 2>&1
    echo $?
}

# check if naming is eDP-1 or eDP1
checkDisplayName() {
    xrandr -q | grep eDP1 > /dev/null 2>&1
    echo $?
}

autoConfigure() {
    local laptop=${1}
    local monitor1=${2}
    local monitor2=${3}

    if [ "$(isActive ${monitor1})" = "0" ] || [ "$(isConnected ${monitor1})" = "1" ]; then
        xrandr --output ${laptop} --auto --primary
        xrandr --output ${monitor1} --off
        xrandr --output ${monitor2} --off
    else
        xrandr --output ${monitor1} --auto --primary 
        xrandr --output ${monitor2} --auto --right-of ${monitor1} 
        xrandr --output ${laptop} --off
    fi;
}


if [ "$(checkDisplayName)" = "0" ]; then

    autoConfigure eDP1 DP1-1 DP1-2

else

    autoConfigure eDP1-1 DP1-1 DP1-2

fi;
