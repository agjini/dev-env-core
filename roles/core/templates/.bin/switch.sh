#!/bin/bash

isDocked() {
    boltctl list | grep disconnected
    echo $?
}

# Is here to force to rediscover available displays
xrandr -q

if [ "$(isDocked)" = "1" ]; then

    echo "docked"
    ~/.bin/dock_home.sh

else

    echo "undocked"
    ~/.bin/laptop.sh

fi;
