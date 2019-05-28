#!/bin/bash

isDocked() {
    boltctl list | grep disconnected
    echo $?
}

if [ "$(isDocked)" = "1" ]; then

    echo "docked"
    ~/.bin/dock_home.sh

else

    echo "undocked"
    ~/.bin/laptop.sh

fi;
