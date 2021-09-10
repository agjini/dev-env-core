#!/bin/bash

isDocked() {
    # Is here to force to rediscover available displays
    # And check if there is other monitors that laptop connected
    xrandr -q | grep -v "eDP-1 connected" | grep " connected" > /dev/null 2>&1
    echo $?
}

echo $(isDocked)

if [ "$(isDocked)" = "0" ]; then

    echo "docked"
    ~/.bin/dock_home.sh

else

    echo "undocked"
    ~/.bin/laptop.sh

fi;
