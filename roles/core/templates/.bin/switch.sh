#!/bin/bash

isDocked() {
    # Is here to force to rediscover available displays
    # And check if there is other monitors that laptop connected
    xrandr -q | grep -v "eDP1 connected" | grep " connected"
    echo $?
}

if [ "$(isDocked)" = "0" ]; then

    echo "docked"
    ~/.bin/dock_home.sh

else

    echo "undocked"
    ~/.bin/laptop.sh

fi;
